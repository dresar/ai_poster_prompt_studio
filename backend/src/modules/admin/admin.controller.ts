import { Request, Response, NextFunction } from 'express';
import { db } from '../../config/db';
import { users, prompts, geminiApiKeys, logs, appSettings, visualStyles, licenseKeys, developerApiKeys, characters, promptTemplates } from '../../db/schema';
import { eq, and, gte, lte, desc, asc, count, avg, sql } from 'drizzle-orm';
import { AppError } from '../../middlewares/errorHandler';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { formatGeminiError, formatAiError } from '../../utils/errorFormatter';
import crypto from 'crypto';
import { encrypt, decrypt, getEncryptionKey } from '../../core/utils/encryption';
import { AIGatewayService } from '../ai-gateway/ai-gateway.service';

export const getDashboardStats = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [totalUsersArr, totalPromptsTodayArr, avgScoreResultArr, healthyKeysArr, totalKeysArr] = await Promise.all([
      db.select({ value: count() }).from(users),
      db.select({ value: count() }).from(prompts).where(gte(prompts.createdAt, today)),
      db.select({ value: avg(prompts.viralScore) }).from(prompts),
      db.select({ value: count() }).from(geminiApiKeys).where(and(eq(geminiApiKeys.healthStatus, 'healthy'), eq(geminiApiKeys.isActive, true))),
      db.select({ value: count() }).from(geminiApiKeys),
    ]);

    const chartData = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const start = new Date(d);
      start.setHours(0, 0, 0, 0);
      const end = new Date(d);
      end.setHours(23, 59, 59, 999);

      const countResult = await db.select({ value: count() }).from(prompts).where(and(gte(prompts.createdAt, start), lte(prompts.createdAt, end)));
      chartData.push({
        date: start.toISOString().split('T')[0],
        count: countResult[0].value,
      });
    }

    res.status(200).json({
      success: true,
      data: {
        totalUsers: totalUsersArr[0].value,
        totalPromptsToday: totalPromptsTodayArr[0].value,
        averageViralScore: Math.round(Number(avgScoreResultArr[0].value) || 0),
        geminiKeys: {
          healthy: healthyKeysArr[0].value,
          total: totalKeysArr[0].value,
        },
        chartData,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getGeminiKeys = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const keys = await db.select().from(geminiApiKeys).orderBy(asc(geminiApiKeys.priority));
    
    const rotationLogs = await db.select().from(logs).where(eq(logs.action, 'key_rotation'));

    const keysWithErrors = keys.map(k => {
      const errorCount = rotationLogs.filter(log => {
        const detail = log.detail as any;
        return detail && (detail.keyId === k.id || detail.keyId === k.keyEncrypted);
      }).length;
      return { ...k, errorCount };
    });

    const masked = keysWithErrors.map(k => {
      let actualKey = k.keyEncrypted;
      if (k.isEncrypted) {
        try {
          actualKey = decrypt(actualKey);
        } catch (e) {
          // ignore decrypt errors for masking
        }
      }
      return {
        ...k,
        keyEncrypted: actualKey.length > 8 
          ? `${actualKey.substring(0, 4)}••••${actualKey.substring(actualKey.length - 4)}` 
          : '••••',
      };
    });

    res.status(200).json({ success: true, data: masked });
  } catch (error) {
    next(error);
  }
};

export const createGeminiKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const key = req.body.key || req.body.apiKey;
    const priority = req.body.priority !== undefined ? req.body.priority : 0;
    const provider = (req.body.provider || 'gemini').toLowerCase();

    // Check for duplicate priority for the same provider
    const existing = await db.select().from(geminiApiKeys).where(and(eq(geminiApiKeys.provider, provider), eq(geminiApiKeys.priority, priority))).limit(1);
    if (existing.length > 0) {
      throw new AppError(`Prioritas ${priority} sudah digunakan untuk provider ${provider.toUpperCase()}. Harap gunakan angka prioritas lain.`, 400, 'DUPLICATE_PRIORITY');
    }

    // Feature 1: Additive Encryption
    const encryptionKey = getEncryptionKey();
    const shouldEncrypt = !!encryptionKey;
    const finalKey = shouldEncrypt ? encrypt(key) : key;

    const [newKey] = await db.insert(geminiApiKeys).values({
      id: crypto.randomUUID(),
      keyEncrypted: finalKey,
      isEncrypted: shouldEncrypt,
      priority: priority !== undefined ? priority : 0,
      isActive: true,
      healthStatus: 'healthy',
      provider: provider.toLowerCase(),
    }).returning();

    if (req.user?.id) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'create_gemini_key',
        detail: { keyId: newKey.id, provider: newKey.provider },
      });
    }

    res.status(201).json({
      success: true,
      message: 'Key added successfully',
      data: newKey,
    });
  } catch (error) {
    next(error);
  }
};

export const bulkImportGeminiKeys = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { rawKeys, provider = 'gemini' } = req.body;
    if (!rawKeys || typeof rawKeys !== 'string' || rawKeys.trim().length === 0) {
      throw new AppError('Daftar API Key (rawKeys) tidak boleh kosong.', 400, 'BAD_REQUEST');
    }

    // Split by newlines, commas, or semicolons
    const keysArray = rawKeys
      .split(/[\n,\;\r]+/)
      .map(k => k.trim())
      .filter(k => k.length > 10);

    if (keysArray.length === 0) {
      throw new AppError('Tidak ada API Key valid yang ditemukan dalam teks import.', 400, 'NO_VALID_KEYS');
    }

    const encryptionKey = getEncryptionKey();
    const shouldEncrypt = !!encryptionKey;

    const existingKeys = await db.select().from(geminiApiKeys).where(eq(geminiApiKeys.provider, provider.toLowerCase()));
    let startPriority = existingKeys.length > 0 ? Math.max(...existingKeys.map(k => k.priority || 0)) + 1 : 0;

    let addedCount = 0;
    const insertedKeys = [];

    for (const key of keysArray) {
      const finalKey = shouldEncrypt ? encrypt(key) : key;
      const [newKey] = await db.insert(geminiApiKeys).values({
        id: crypto.randomUUID(),
        keyEncrypted: finalKey,
        isEncrypted: shouldEncrypt,
        priority: startPriority++,
        isActive: true,
        healthStatus: 'healthy',
        provider: provider.toLowerCase(),
      }).returning();

      insertedKeys.push(newKey);
      addedCount++;
    }

    if (req.user?.id) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'bulk_import_gemini_keys',
        detail: { addedCount, provider },
      });
    }

    res.status(201).json({
      success: true,
      message: `Berhasil mengimpor ${addedCount} API Key ${provider.toUpperCase()}!`,
      data: { addedCount, keys: insertedKeys },
    });
  } catch (error) {
    next(error);
  }
};

export const updateGeminiKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { priority, isActive, healthStatus, provider } = req.body;

    // Check for duplicate priority on update if priority is changing
    if (priority !== undefined) {
      // Get current key to know its provider if not sent in request
      const [currentKey] = await db.select().from(geminiApiKeys).where(eq(geminiApiKeys.id, id)).limit(1);
      if (currentKey) {
        const keyProvider = (provider || currentKey.provider).toLowerCase();
        const existing = await db.select().from(geminiApiKeys)
          .where(and(eq(geminiApiKeys.provider, keyProvider), eq(geminiApiKeys.priority, priority))).limit(1);
        
        // If we found a key with the same priority, and it's not the same key we are updating
        if (existing.length > 0 && existing[0].id !== id) {
          throw new AppError(`Prioritas ${priority} sudah digunakan untuk provider ${keyProvider.toUpperCase()}. Harap gunakan angka prioritas lain.`, 400, 'DUPLICATE_PRIORITY');
        }
      }
    }

    const [updated] = await db.update(geminiApiKeys)
      .set({
        ...(priority !== undefined ? { priority } : {}),
        ...(isActive !== undefined ? { isActive } : {}),
        ...(healthStatus !== undefined ? { healthStatus } : {}),
      })
      .where(eq(geminiApiKeys.id, id))
      .returning();

    if (!updated) throw new AppError('Gemini Key not found', 404, 'NOT_FOUND');

    if (req.user?.id) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'update_gemini_key',
        detail: { keyId: id, priority, isActive, healthStatus },
      });
    }

    res.status(200).json({ success: true, message: 'Gemini Key updated successfully', data: updated });
  } catch (error) {
    next(error);
  }
};

export const deleteGeminiKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const [deleted] = await db.delete(geminiApiKeys).where(eq(geminiApiKeys.id, id)).returning();
    
    if (!deleted) throw new AppError('Gemini Key not found', 404, 'NOT_FOUND');

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'delete_gemini_key', detail: { keyId: id } });
    }

    res.status(200).json({ success: true, message: 'Gemini Key deleted successfully' });
  } catch (error) {
    next(error);
  }
};

export const encryptOldKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const keyRecords = await db.select().from(geminiApiKeys).where(eq(geminiApiKeys.id, id)).limit(1);

    if (keyRecords.length === 0) {
      throw new AppError('Key not found', 404, 'KEY_NOT_FOUND');
    }

    const keyObj = keyRecords[0];
    if (keyObj.isEncrypted) {
      return res.status(400).json({ success: false, message: 'Key is already encrypted' });
    }

    const encryptionKey = getEncryptionKey();
    if (!encryptionKey) {
      throw new AppError('ENCRYPTION_KEY not configured', 500, 'NO_ENCRYPTION_KEY');
    }

    const encryptedText = encrypt(keyObj.keyEncrypted);
    await db.update(geminiApiKeys).set({
      keyEncrypted: encryptedText,
      isEncrypted: true
    }).where(eq(geminiApiKeys.id, id));

    if (req.user?.id) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'encrypt_gemini_key',
        detail: { keyId: id },
      });
    }

    res.status(200).json({
      success: true,
      message: 'Key successfully encrypted manually'
    });
  } catch (error) {
    next(error);
  }
};

export const getSystemSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const defaultPackages = [
      { id: 'starter', name: 'Starter Pack', priceText: 'Rp 15.000', billingCycle: 'bulan', credits: 300, checkoutUrl: 'https://checkout.placeholder.com/starter' },
      { id: 'standard', name: 'Standard Pack', priceText: 'Rp 25.000', billingCycle: 'bulan', credits: 500, checkoutUrl: 'https://checkout.placeholder.com/standard' },
      { id: 'professional', name: 'Professional Pack', priceText: 'Rp 45.000', billingCycle: 'bulan', credits: 1000, checkoutUrl: 'https://checkout.placeholder.com/professional' }
    ];

    let settingsArr = await db.select().from(appSettings).where(eq(appSettings.key, 'system_settings')).limit(1);
    let settings = settingsArr[0];

    if (!settings) {
      const [newSettings] = await db.insert(appSettings).values({
        id: crypto.randomUUID(),
        key: 'system_settings',
        value: {
          appName: 'PROMTING STUDIO',
          footerText: 'PROMTING STUDIO · Hak Cipta Dilindungi',
          maxQuotaPerDay: 50,
          maintenanceMode: false,
          bannerPosterInfo: '✨ Ditenagai AI. Isi form, klik GENERATE...',
          bannerEnhanceInfo: '✨ Upload fotomu...',
          packages: defaultPackages
        }
      }).returning();
      settings = newSettings;
    } else {
      const val = settings.value as any;
      if (!val.packages) {
        val.packages = defaultPackages;
        const [updated] = await db.update(appSettings).set({ value: val }).where(eq(appSettings.key, 'system_settings')).returning();
        settings = updated;
      }
    }

    res.status(200).json({ success: true, data: settings.value || {} });
  } catch (error) {
    next(error);
  }
};

export const updateSystemSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { value } = req.body;
    const [updated] = await db.insert(appSettings).values({ id: crypto.randomUUID(), key: 'system_settings', value })
      .onConflictDoUpdate({ target: appSettings.key, set: { value } }).returning();

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'update_system_settings', detail: { value } });
    }

    res.status(200).json({ success: true, message: 'System settings updated', data: updated.value });
  } catch (error) {
    next(error);
  }
};

export const getUsers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const usersList = await db.select().from(users).orderBy(desc(users.createdAt));
    const promptsCount = await db.select({ userId: prompts.userId, count: count() }).from(prompts).groupBy(prompts.userId);
    const countMap = Object.fromEntries(promptsCount.map(p => [p.userId, p.count]));

    const usersWithCount = usersList.map(u => ({
      id: u.id,
      email: u.email,
      role: u.role,
      subscriptionStatus: u.subscriptionStatus,
      subscriptionExpiresAt: u.subscriptionExpiresAt,
      createdAt: u.createdAt,
      _count: { prompts: countMap[u.id] || 0 }
    }));

    res.status(200).json({ success: true, data: usersWithCount });
  } catch (error) {
    next(error);
  }
};

export const updateUserSubscription = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { subscriptionStatus, subscriptionExpiresAt, credits } = req.body;

    const [updated] = await db.update(users).set({
      subscriptionStatus,
      subscriptionExpiresAt: subscriptionExpiresAt ? new Date(subscriptionExpiresAt) : null,
      credits: credits !== undefined ? Number(credits) : undefined,
    }).where(eq(users.id, id)).returning();

    if (!updated) throw new AppError('User not found', 404, 'NOT_FOUND');

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'update_user_subscription', detail: { targetUserId: id, subscriptionStatus, subscriptionExpiresAt } });
    }

    res.status(200).json({ success: true, message: 'Updated successfully', data: updated });
  } catch (error) {
    next(error);
  }
};

export const updateUserRole = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    const [updated] = await db.update(users).set({ role }).where(eq(users.id, id)).returning();
    if (!updated) throw new AppError('User not found', 404, 'NOT_FOUND');

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'update_user_role', detail: { targetUserId: id, newRole: role } });
    }

    res.status(200).json({ success: true, message: 'Role updated successfully', data: { id: updated.id, email: updated.email, role: updated.role } });
  } catch (error) {
    next(error);
  }
};

export const getAuditLogs = async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Basic join with users
    const logsList = await db.select({
      id: logs.id,
      action: logs.action,
      detail: logs.detail,
      createdAt: logs.createdAt,
      user: {
        email: users.email
      }
    })
    .from(logs)
    .leftJoin(users, eq(logs.userId, users.id))
    .orderBy(desc(logs.createdAt))
    .limit(100);

    res.status(200).json({ success: true, data: logsList });
  } catch (error) {
    next(error);
  }
};

export const getImageKitSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const settingsArr = await db.select().from(appSettings).where(eq(appSettings.key, 'imagekit_settings')).limit(1);
    res.status(200).json({ success: true, data: settingsArr[0]?.value || { publicKey: '', privateKey: '', urlEndpoint: '' } });
  } catch (error) {
    next(error);
  }
};

export const updateImageKitSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { publicKey, privateKey, urlEndpoint } = req.body;
    const value = { publicKey, privateKey, urlEndpoint };

    const [updated] = await db.insert(appSettings).values({ id: crypto.randomUUID(), key: 'imagekit_settings', value })
      .onConflictDoUpdate({ target: appSettings.key, set: { value } }).returning();

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'update_imagekit_settings', detail: { publicKey, urlEndpoint } });
    }

    res.status(200).json({ success: true, message: 'Settings updated', data: updated.value });
  } catch (error) {
    next(error);
  }
};

export const getVisualStyles = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const styles = await db.select().from(visualStyles).orderBy(desc(visualStyles.createdAt));
    res.status(200).json({ success: true, data: styles });
  } catch (error) {
    next(error);
  }
};

export const createVisualStyle = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name, promptTemplate, previewImageUrl } = req.body;
    const [newStyle] = await db.insert(visualStyles).values({
      id: crypto.randomUUID(),
      name, promptTemplate, previewImageUrl, isActive: true
    }).returning();

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'create_visual_style', detail: { name, styleId: newStyle.id } });
    }

    res.status(201).json({ success: true, message: 'Style created', data: newStyle });
  } catch (error) {
    next(error);
  }
};

export const updateVisualStyle = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { name, promptTemplate, previewImageUrl, isActive } = req.body;

    // Fetch existing style to check for image changes
    const existing = await db.select().from(visualStyles).where(eq(visualStyles.id, id)).limit(1);
    const oldStyle = existing[0];

    const [updated] = await db.update(visualStyles).set({
      ...(name !== undefined ? { name } : {}),
      ...(promptTemplate !== undefined ? { promptTemplate } : {}),
      ...(previewImageUrl !== undefined ? { previewImageUrl } : {}),
      ...(isActive !== undefined ? { isActive } : {}),
    }).where(eq(visualStyles.id, id)).returning();

    // If image changed, delete old local file
    if (oldStyle && previewImageUrl !== undefined && oldStyle.previewImageUrl !== previewImageUrl) {
      const { deleteLocalFileByUrl } = await import('../../utils/image-cleanup');
      deleteLocalFileByUrl(oldStyle.previewImageUrl);
    }

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'update_visual_style', detail: { styleId: id, name } });
    }

    res.status(200).json({ success: true, message: 'Style updated', data: updated });
  } catch (error) {
    next(error);
  }
};

export const deleteVisualStyle = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const existing = await db.select().from(visualStyles).where(eq(visualStyles.id, id)).limit(1);
    const oldStyle = existing[0];

    await db.delete(visualStyles).where(eq(visualStyles.id, id));

    if (oldStyle) {
      const { deleteLocalFileByUrl } = await import('../../utils/image-cleanup');
      deleteLocalFileByUrl(oldStyle.previewImageUrl);
    }

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'delete_visual_style', detail: { styleId: id } });
    }
    res.status(200).json({ success: true, message: 'Style deleted' });
  } catch (error) {
    next(error);
  }
};

export const getLicenses = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const keys = await db.select().from(licenseKeys).orderBy(desc(licenseKeys.createdAt));
    res.status(200).json({ success: true, data: keys });
  } catch (error) {
    next(error);
  }
};

export const generateLicenses = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { count, days, credits } = req.body;
    const keysToCreate = [];
    const validDays = Number(days) || 30;
    const validCount = Number(count) || 1;
    const validCredits = Number(credits) || 300;

    for (let i = 0; i < validCount; i++) {
      const part1 = Math.random().toString(36).substring(2, 6).toUpperCase();
      const part2 = Math.random().toString(36).substring(2, 6).toUpperCase();
      const key = `KEY-${part1}-${part2}`;
      keysToCreate.push({ id: crypto.randomUUID(), key, days: validDays, credits: validCredits });
    }

    await db.insert(licenseKeys).values(keysToCreate);

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'generate_licenses', detail: { count: validCount, days: validDays } });
    }
    res.status(201).json({ success: true, message: `Successfully generated ${validCount} license keys.` });
  } catch (error) {
    next(error);
  }
};

export const deleteLicense = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    await db.delete(licenseKeys).where(eq(licenseKeys.id, id));
    res.status(200).json({ success: true, message: 'License deleted' });
  } catch (error) {
    next(error);
  }
};

export const testGeminiKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const keyRecords = await db.select().from(geminiApiKeys).where(eq(geminiApiKeys.id, id)).limit(1);
    const keyRecord = keyRecords[0];
    if (!keyRecord) throw new AppError('Gemini Key not found', 404, 'NOT_FOUND');

    let success = false;
    let errorMessage = '';

    try {
      let actualKey = keyRecord.keyEncrypted;
      if (keyRecord.isEncrypted) {
        actualKey = decrypt(actualKey);
      }

      const genAI = new GoogleGenerativeAI(actualKey);
      const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });
      const response = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: 'say OK' }] }], generationConfig: { maxOutputTokens: 5 } });
      const text = response.response.text();
      
      if (text) {
        success = true;
        await db.update(geminiApiKeys).set({ healthStatus: 'healthy' }).where(eq(geminiApiKeys.id, id));
      } else {
        throw new Error('Empty response');
      }
    } catch (err: any) {
      errorMessage = err?.message || String(err);
      const isQuota = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('Quota');
      const newStatus = isQuota ? 'limited' : 'error';
      
      await db.update(geminiApiKeys).set({ healthStatus: newStatus }).where(eq(geminiApiKeys.id, id));

      if (req.user?.id) {
        await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'key_rotation', detail: { keyId: id, reason: 'Manual Health Check Failure', error: errorMessage, newStatus } });
      }
    }

    res.status(200).json({
      success,
      message: success ? 'Key is working' : 'Key test failed',
      error: errorMessage ? formatAiError(errorMessage, keyRecord.provider) : '',
      data: { id, healthStatus: success ? 'healthy' : (errorMessage.includes('429') || errorMessage.includes('quota') ? 'limited' : 'error') }
    });
  } catch (error) {
    next(error);
  }
};

export const testAllGeminiKeys = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const keys = await db.select().from(geminiApiKeys);
    const results = [];

    for (const keyRecord of keys) {
      let success = false;
      let errorMessage = '';

      try {
        let actualKey = keyRecord.keyEncrypted;
        if (keyRecord.isEncrypted) {
          actualKey = decrypt(actualKey);
        }

        const genAI = new GoogleGenerativeAI(actualKey);
        const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });
        const response = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: 'say OK' }] }], generationConfig: { maxOutputTokens: 5 } });
        const text = response.response.text();
        
        if (text) {
          success = true;
          await db.update(geminiApiKeys).set({ healthStatus: 'healthy' }).where(eq(geminiApiKeys.id, keyRecord.id));
        } else {
          throw new Error('Empty response');
        }
      } catch (err: any) {
        errorMessage = err?.message || String(err);
        const isQuota = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('Quota');
        const newStatus = isQuota ? 'limited' : 'error';
        
        await db.update(geminiApiKeys).set({ healthStatus: newStatus }).where(eq(geminiApiKeys.id, keyRecord.id));

        if (req.user?.id) {
          await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'key_rotation', detail: { keyId: keyRecord.id, reason: 'Manual Health Check Failure', error: errorMessage, newStatus } });
        }
      }

      results.push({ id: keyRecord.id, success, error: errorMessage ? formatAiError(errorMessage, keyRecord.provider) : '' });
    }

    res.status(200).json({ success: true, message: `Tested ${keys.length} keys`, data: results });
  } catch (error) {
    next(error);
  }
};

export const getDeveloperKeys = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) throw new AppError('Unauthorized', 401, 'UNAUTHORIZED');
    const keys = await db.select().from(developerApiKeys).where(eq(developerApiKeys.userId, req.user.id)).orderBy(desc(developerApiKeys.createdAt));
    res.status(200).json({ success: true, data: keys });
  } catch (error) {
    next(error);
  }
};

export const createDeveloperKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name } = req.body;
    const userId = req.user?.id;
    if (!userId) throw new AppError('Unauthorized', 401, 'UNAUTHORIZED');

    const secureToken = crypto.randomBytes(20).toString('hex');
    const apiKey = `ps_live_${secureToken}`;

    const [newKey] = await db.insert(developerApiKeys).values({
      id: crypto.randomUUID(),
      userId,
      name: name || 'Default Key',
      apiKey,
      isActive: true,
    }).returning();

    await db.insert(logs).values({ id: crypto.randomUUID(), userId, action: 'create_developer_key', detail: { keyId: newKey.id, name: newKey.name } });

    res.status(201).json({ success: true, message: 'Key generated successfully', data: newKey });
  } catch (error) {
    next(error);
  }
};

export const deleteDeveloperKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;
    if (!userId) throw new AppError('Unauthorized', 401, 'UNAUTHORIZED');

    const [deleted] = await db.delete(developerApiKeys).where(and(eq(developerApiKeys.id, id), eq(developerApiKeys.userId, userId))).returning();
    if (!deleted) throw new AppError('Key not found', 404, 'NOT_FOUND');

    await db.insert(logs).values({ id: crypto.randomUUID(), userId, action: 'delete_developer_key', detail: { keyId: id, name: deleted.name } });

    res.status(200).json({ success: true, message: 'Key deleted' });
  } catch (error) {
    next(error);
  }
};

export const transferCreditsDirectly = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, credits } = req.body;
    const adminId = req.user?.id;

    if (!email || credits === undefined) throw new AppError('Email dan jumlah kredit wajib diisi', 400, 'BAD_REQUEST');

    const targetCredits = Number(credits);
    if (isNaN(targetCredits) || targetCredits <= 0) throw new AppError('Jumlah kredit harus berupa angka positif', 400, 'BAD_REQUEST');

    const userRecords = await db.select().from(users).where(eq(users.email, email.trim())).limit(1);
    const user = userRecords[0];

    if (!user) throw new AppError('Pengguna dengan email tersebut tidak ditemukan', 404, 'NOT_FOUND');

    const newCredits = (user.credits || 0) + targetCredits;
    const [updated] = await db.update(users).set({
      credits: newCredits,
      subscriptionStatus: 'PRO',
    }).where(eq(users.id, user.id)).returning();

    if (adminId) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: adminId,
        action: 'direct_credit_transfer',
        detail: { targetUserId: user.id, targetUserEmail: email, addedCredits: targetCredits, newTotalCredits: updated.credits },
      });
    }

    res.status(200).json({ success: true, message: `Berhasil menambahkan ${targetCredits} kredit. Total: ${updated.credits}`, data: updated });
  } catch (error) {
    next(error);
  }
};

// ═══════════════════════════════════════════
// CHARACTER CRUD
// ═══════════════════════════════════════════

export const getCharacters = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const list = await db.select().from(characters).orderBy(desc(characters.createdAt));
    res.status(200).json({ success: true, data: list });
  } catch (error) {
    next(error);
  }
};

export const createCharacter = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name, description, imageUrl, promptConsistency, category, characterBible, positivePrompt, negativePrompt, masterPrompt } = req.body;
    if (!name || !description || !promptConsistency) {
      throw new AppError('Nama, deskripsi, dan prompt konsistensi wajib diisi', 400, 'BAD_REQUEST');
    }

    const [newChar] = await db.insert(characters).values({
      id: crypto.randomUUID(),
      name,
      description,
      imageUrl: imageUrl || null,
      promptConsistency,
      category: category || 'general',
      characterBible: characterBible || null,
      positivePrompt: positivePrompt || null,
      negativePrompt: negativePrompt || null,
      masterPrompt: masterPrompt || null,
      isActive: true,
    }).returning();

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'create_character', detail: { characterId: newChar.id, name } });
    }

    res.status(201).json({ success: true, message: 'Karakter berhasil dibuat', data: newChar });
  } catch (error) {
    next(error);
  }
};

export const updateCharacter = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { name, description, imageUrl, promptConsistency, category, isActive, characterBible, positivePrompt, negativePrompt, masterPrompt } = req.body;

    // Fetch existing character to check for image changes
    const existing = await db.select().from(characters).where(eq(characters.id, id)).limit(1);
    const oldChar = existing[0];

    const [updated] = await db.update(characters).set({
      ...(name !== undefined ? { name } : {}),
      ...(description !== undefined ? { description } : {}),
      ...(imageUrl !== undefined ? { imageUrl } : {}),
      ...(promptConsistency !== undefined ? { promptConsistency } : {}),
      ...(category !== undefined ? { category } : {}),
      ...(isActive !== undefined ? { isActive } : {}),
      ...(characterBible !== undefined ? { characterBible } : {}),
      ...(positivePrompt !== undefined ? { positivePrompt } : {}),
      ...(negativePrompt !== undefined ? { negativePrompt } : {}),
      ...(masterPrompt !== undefined ? { masterPrompt } : {}),
      updatedAt: new Date(),
    }).where(eq(characters.id, id)).returning();

    if (!updated) throw new AppError('Karakter tidak ditemukan', 404, 'NOT_FOUND');

    // If image changed, delete old local file
    if (oldChar && imageUrl !== undefined && oldChar.imageUrl !== imageUrl) {
      const { deleteLocalFileByUrl } = await import('../../utils/image-cleanup');
      deleteLocalFileByUrl(oldChar.imageUrl);
    }

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'update_character', detail: { characterId: id, name } });
    }

    res.status(200).json({ success: true, message: 'Karakter diperbarui', data: updated });
  } catch (error) {
    next(error);
  }
};

export const deleteCharacter = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const [deleted] = await db.delete(characters).where(eq(characters.id, id)).returning();
    if (!deleted) throw new AppError('Karakter tidak ditemukan', 404, 'NOT_FOUND');

    // Delete associated image file from disk
    const { deleteLocalFileByUrl } = await import('../../utils/image-cleanup');
    deleteLocalFileByUrl(deleted.imageUrl);

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'delete_character', detail: { characterId: id } });
    }

    res.status(200).json({ success: true, message: 'Karakter dihapus' });
  } catch (error) {
    next(error);
  }
};

// ═══════════════════════════════════════════
// PROMPT TEMPLATE CRUD
// ═══════════════════════════════════════════

export const getPromptTemplates = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const list = await db.select().from(promptTemplates);
    res.status(200).json({ success: true, data: list });
  } catch (error) {
    next(error);
  }
};

export const createPromptTemplate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, category, template, previewImageUrl, viralScore, viralBreakdown, payloadJson, hooks, analysis } = req.body;
    if (!category || !template) {
      throw new AppError('Kategori dan template wajib diisi', 400, 'BAD_REQUEST');
    }

    const [newTpl] = await db.insert(promptTemplates).values({
      id: crypto.randomUUID(),
      title: title || payloadJson?.formState?.topic || payloadJson?.topic || null,
      category,
      template,
      isActive: true,
      previewImageUrl: previewImageUrl || null,
      viralScore: typeof viralScore === 'number' ? viralScore : null,
      viralBreakdown: viralBreakdown || null,
      payloadJson: payloadJson || null,
      hooks: hooks || null,
      analysis: analysis || null,
    }).returning();

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'create_prompt_template', detail: { templateId: newTpl.id, category } });
    }

    res.status(201).json({ success: true, message: 'Template berhasil dibuat', data: newTpl });
  } catch (error) {
    next(error);
  }
};

export const updatePromptTemplate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { title, category, template, isActive, previewImageUrl, viralScore, viralBreakdown, payloadJson, hooks, analysis } = req.body;

    const [updated] = await db.update(promptTemplates).set({
      ...(title !== undefined ? { title } : {}),
      ...(category !== undefined ? { category } : {}),
      ...(template !== undefined ? { template } : {}),
      ...(isActive !== undefined ? { isActive } : {}),
      ...(previewImageUrl !== undefined ? { previewImageUrl } : {}),
      ...(viralScore !== undefined ? { viralScore } : {}),
      ...(viralBreakdown !== undefined ? { viralBreakdown } : {}),
      ...(payloadJson !== undefined ? { payloadJson } : {}),
      ...(hooks !== undefined ? { hooks } : {}),
      ...(analysis !== undefined ? { analysis } : {}),
    }).where(eq(promptTemplates.id, id)).returning();

    if (!updated) throw new AppError('Template tidak ditemukan', 404, 'NOT_FOUND');

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'update_prompt_template', detail: { templateId: id, category } });
    }

    res.status(200).json({ success: true, message: 'Template diperbarui', data: updated });
  } catch (error) {
    next(error);
  }
};

export const deletePromptTemplate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    await db.delete(promptTemplates).where(eq(promptTemplates.id, id));

    if (req.user?.id) {
      await db.insert(logs).values({ id: crypto.randomUUID(), userId: req.user.id, action: 'delete_prompt_template', detail: { templateId: id } });
    }

    res.status(200).json({ success: true, message: 'Template dihapus' });
  } catch (error) {
    next(error);
  }
};

export const generateSuggestedTemplate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { category, idea } = req.body;
    if (!category || !idea) {
      throw new AppError('Kategori dan ide wajib diisi', 400, 'BAD_REQUEST');
    }

    const aiService = new AIGatewayService();
    const result = await aiService.generatePromptTemplate(category, idea);

    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};
