import { GoogleGenerativeAI } from '@google/generative-ai';
import { db } from '../../../config/db';
import { geminiApiKeys, logs } from '../../../db/schema';
import { eq, and, asc } from 'drizzle-orm';
import { env } from '../../../config/env';
import { logger } from '../../../config/logger';
import { AppError } from '../../../middlewares/errorHandler';
import crypto from 'crypto';
import { decrypt } from '../../../core/utils/encryption';
import { formatGeminiError } from '../../../utils/errorFormatter';

export class GeminiClient {
  private async getHealthyKeys(): Promise<any[]> {
    return await db.select()
      .from(geminiApiKeys)
      .where(and(eq(geminiApiKeys.provider, 'gemini'), eq(geminiApiKeys.isActive, true), eq(geminiApiKeys.healthStatus, 'healthy')))
      .orderBy(asc(geminiApiKeys.priority));
  }
  
  public sanitizeJson(text: string): string {
    const jsonMatch = text.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
    if (jsonMatch) {
      return jsonMatch[1].trim();
    }
    const startIdx = text.indexOf('{');
    const endIdx = text.lastIndexOf('}');
    if (startIdx !== -1 && endIdx !== -1 && endIdx >= startIdx) {
      return text.substring(startIdx, endIdx + 1).trim();
    }
    return text.trim();
  }

  public async executeWithKey<T>(
    fn: (genAI: GoogleGenerativeAI) => Promise<T>
  ): Promise<T> {
    const keys = await this.getHealthyKeys();

    const keyPool = [...keys];
    if (keyPool.length === 0 && env.GEMINI_API_KEY) {
      keyPool.push({
        id: 'env_fallback',
        keyEncrypted: env.GEMINI_API_KEY,
        priority: 0,
        usageCount: 0,
      });
    }

    if (keyPool.length === 0) {
      throw new AppError('Terjadi kendala koneksi dengan server AI. Silakan coba lagi nanti.', 500, 'NO_API_KEYS');
    }

    let lastError: any = null;

    for (const keyObj of keyPool) {
      try {
        let apiKey = keyObj.keyEncrypted;
        if (keyObj.isEncrypted) {
          try {
            apiKey = decrypt(apiKey);
          } catch (decryptErr) {
            logger.error(`Failed to decrypt API key ${keyObj.id}. Skipping.`);
            continue;
          }
        }
        const genAI = new GoogleGenerativeAI(apiKey);
        const result = await fn(genAI);

        if (keyObj.id !== 'env_fallback') {
          await db.update(geminiApiKeys).set({
            usageCount: (keyObj.usageCount || 0) + 1,
            lastUsedAt: new Date(),
          }).where(eq(geminiApiKeys.id, keyObj.id));
        }

        return result;
      } catch (error: any) {
        lastError = error;
        const errorMessage = error?.message || String(error);
        logger.warn(`Gemini call failed with key ID ${keyObj.id}. Error: ${errorMessage}`);

        const isQuotaError = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('Quota');
        const isNetworkOrTimeout = errorMessage.includes('timeout') || errorMessage.includes('FETCH_ERROR') || errorMessage.includes('500') || errorMessage.includes('503');

        if ((isQuotaError || isNetworkOrTimeout) && keyObj.id !== 'env_fallback') {
          const newStatus = isQuotaError ? 'limited' : 'error';

          await db.update(geminiApiKeys).set({ 
            healthStatus: newStatus,
            priority: 100
          }).where(eq(geminiApiKeys.id, keyObj.id));

          await db.insert(logs).values({
            id: crypto.randomUUID(),
            action: 'key_rotation',
            detail: {
              provider: 'gemini',
              keyId: keyObj.id,
              reason: isQuotaError ? 'API Rate Limit (429)' : 'API Error/Timeout',
              error: errorMessage,
              newStatus,
              demotedToPriority: 100
            },
          });
        }
      }
    }

    const cleanErr = lastError?.message || String(lastError);
    throw new AppError(
      `Gagal memproses permintaan Anda. Kendala: ${formatGeminiError(cleanErr)}`,
      502,
      'AI_SERVICE_ERROR'
    );
  }
}
