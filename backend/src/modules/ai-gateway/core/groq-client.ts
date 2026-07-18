import { db } from '../../../config/db';
import { geminiApiKeys, logs } from '../../../db/schema';
import { eq, and, asc } from 'drizzle-orm';
import { logger } from '../../../config/logger';
import { AppError } from '../../../middlewares/errorHandler';
import crypto from 'crypto';
import { decrypt } from '../../../core/utils/encryption';
import { formatAiError } from '../../../utils/errorFormatter';

export class GroqClient {
  private async getHealthyKeys(): Promise<any[]> {
    return await db.select()
      .from(geminiApiKeys)
      .where(and(eq(geminiApiKeys.provider, 'groq'), eq(geminiApiKeys.isActive, true), eq(geminiApiKeys.healthStatus, 'healthy')))
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
    fn: (apiKey: string) => Promise<T>
  ): Promise<T> {
    const keyPool = await this.getHealthyKeys();

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
        const result = await fn(apiKey);

        await db.update(geminiApiKeys).set({
          usageCount: (keyObj.usageCount || 0) + 1,
          lastUsedAt: new Date(),
        }).where(eq(geminiApiKeys.id, keyObj.id));

        return result;
      } catch (error: any) {
        lastError = error;
        const errorMessage = error?.message || String(error);
        logger.warn(`Groq call failed with key ID ${keyObj.id}. Error: ${errorMessage}`);

        const isQuotaError = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('rate limit') || errorMessage.includes('limit exceeded');
        const isAuthError = errorMessage.includes('401') || errorMessage.includes('invalid') || errorMessage.includes('api key');
        const isNetworkOrTimeout = errorMessage.includes('timeout') || errorMessage.includes('500') || errorMessage.includes('503') || errorMessage.includes('502');

        if (isQuotaError || isAuthError || isNetworkOrTimeout) {
          const newStatus = isQuotaError ? 'limited' : 'error';
          
          await db.update(geminiApiKeys).set({ 
            healthStatus: newStatus,
            priority: 100
          }).where(eq(geminiApiKeys.id, keyObj.id));

          await db.insert(logs).values({
            id: crypto.randomUUID(),
            action: 'key_rotation',
            detail: {
              provider: 'groq',
              keyId: keyObj.id,
              reason: isQuotaError ? 'API Rate Limit (429)' : (isAuthError ? 'Invalid API Key (401)' : 'API Error/Timeout'),
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
      `Gagal memproses permintaan Anda. Kendala: ${formatAiError(cleanErr, 'groq')}`,
      502,
      'AI_SERVICE_ERROR'
    );
  }

  public async post(apiKey: string, body: any): Promise<any> {
    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const resJson: any = await response.json();

    if (!response.ok) {
      const errMsg = resJson.error?.message || `Groq API Error: ${response.status} ${response.statusText}`;
      throw new Error(errMsg);
    }

    return resJson;
  }
}
