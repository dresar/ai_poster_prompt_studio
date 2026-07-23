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
      .where(and(
        eq(geminiApiKeys.provider, 'gemini'),
        eq(geminiApiKeys.isActive, true),
        eq(geminiApiKeys.healthStatus, 'healthy')
      ))
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

  /**
   * Primary Native Multi-API Key Auto-Rotation execution using GoogleGenerativeAI SDK
   */
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
      throw new AppError('Terjadi kendala koneksi: Tidak ada API Key Gemini yang aktif. Silakan tambahkan API Key di Admin Panel.', 500, 'NO_API_KEYS');
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
        logger.warn(`Gemini native call failed with key ID ${keyObj.id}. Error: ${errorMessage}`);

        const isQuotaError = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('Quota') || errorMessage.includes('LIMIT');
        const isNetworkOrTimeout = errorMessage.includes('timeout') || errorMessage.includes('FETCH_ERROR') || errorMessage.includes('500') || errorMessage.includes('503') || errorMessage.includes('API_KEY_INVALID');

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
              reason: isQuotaError ? 'API Rate Limit (429)' : 'API Key Error/Invalid',
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
      `Gagal memproses permintaan AI. Kendala: ${formatGeminiError(cleanErr)}`,
      502,
      'AI_SERVICE_ERROR'
    );
  }

  /**
   * Helper method for text & chat completion using native Gemini SDK with model fallback
   */
  public async generateChatCompletion(
    messages: Array<{ role: string; content: string }>,
    options: { temperature?: number; model?: string; max_tokens?: number } = {}
  ): Promise<string> {
    const requestedModel = options.model || 'gemini-3.1-flash-lite';
    const fallbackModels = ['gemini-3.1-flash-lite', 'gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash'];
    const candidateModels = Array.from(new Set([requestedModel, ...fallbackModels]));

    const systemMsg = messages.find(m => m.role === 'system')?.content || '';
    const userMsgs = messages.filter(m => m.role !== 'system').map(m => m.content).join('\n\n');
    const fullPrompt = systemMsg ? `${systemMsg}\n\n${userMsgs}` : userMsgs;

    return await this.executeWithKey(async (genAI: GoogleGenerativeAI) => {
      let lastModelError: any = null;

      for (const modelName of candidateModels) {
        try {
          const model = genAI.getGenerativeModel({
            model: modelName,
            generationConfig: {
              temperature: options.temperature ?? 0.7,
              maxOutputTokens: options.max_tokens ?? 4096,
            },
          });

          const result = await model.generateContent(fullPrompt);
          const text = result.response.text();
          if (text && text.trim().length > 0) {
            return text.trim();
          }
        } catch (err: any) {
          logger.warn(`Native Gemini model ${modelName} failed: ${err?.message || err}`);
          lastModelError = err;
        }
      }

      throw lastModelError || new Error('All native Gemini models failed for key.');
    });
  }
}
