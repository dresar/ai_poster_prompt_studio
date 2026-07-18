"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.transferCreditsDirectly = exports.deleteDeveloperKey = exports.createDeveloperKey = exports.getDeveloperKeys = exports.testAllGeminiKeys = exports.testGeminiKey = exports.deleteLicense = exports.generateLicenses = exports.getLicenses = exports.deleteVisualStyle = exports.updateVisualStyle = exports.createVisualStyle = exports.getVisualStyles = exports.updateImageKitSettings = exports.getImageKitSettings = exports.getAuditLogs = exports.updateUserRole = exports.updateUserSubscription = exports.getUsers = exports.updateSystemSettings = exports.getSystemSettings = exports.deleteGeminiKey = exports.updateGeminiKey = exports.createGeminiKey = exports.getGeminiKeys = exports.getDashboardStats = void 0;
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const errorHandler_1 = require("../../middlewares/errorHandler");
const generative_ai_1 = require("@google/generative-ai");
const errorFormatter_1 = require("../../utils/errorFormatter");
const crypto_1 = __importDefault(require("crypto"));
const getDashboardStats = async (req, res, next) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const [totalUsersArr, totalPromptsTodayArr, avgScoreResultArr, healthyKeysArr, totalKeysArr] = await Promise.all([
            db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.users),
            db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.prompts).where((0, drizzle_orm_1.gte)(schema_1.prompts.createdAt, today)),
            db_1.db.select({ value: (0, drizzle_orm_1.avg)(schema_1.prompts.viralScore) }).from(schema_1.prompts),
            db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.geminiApiKeys).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.healthStatus, 'healthy'), (0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.isActive, true))),
            db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.geminiApiKeys),
        ]);
        const chartData = [];
        for (let i = 6; i >= 0; i--) {
            const d = new Date();
            d.setDate(d.getDate() - i);
            const start = new Date(d);
            start.setHours(0, 0, 0, 0);
            const end = new Date(d);
            end.setHours(23, 59, 59, 999);
            const countResult = await db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.prompts).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.gte)(schema_1.prompts.createdAt, start), (0, drizzle_orm_1.lte)(schema_1.prompts.createdAt, end)));
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
    }
    catch (error) {
        next(error);
    }
};
exports.getDashboardStats = getDashboardStats;
const getGeminiKeys = async (req, res, next) => {
    try {
        const keys = await db_1.db.select().from(schema_1.geminiApiKeys).orderBy((0, drizzle_orm_1.desc)(schema_1.geminiApiKeys.priority));
        const rotationLogs = await db_1.db.select().from(schema_1.logs).where((0, drizzle_orm_1.eq)(schema_1.logs.action, 'key_rotation'));
        const keysWithErrors = keys.map(k => {
            const errorCount = rotationLogs.filter(log => {
                const detail = log.detail;
                return detail && (detail.keyId === k.id || detail.keyId === k.keyEncrypted);
            }).length;
            return { ...k, errorCount };
        });
        const masked = keysWithErrors.map(k => ({
            ...k,
            keyEncrypted: k.keyEncrypted.length > 8
                ? `${k.keyEncrypted.substring(0, 4)}••••${k.keyEncrypted.substring(k.keyEncrypted.length - 4)}`
                : '••••',
        }));
        res.status(200).json({ success: true, data: masked });
    }
    catch (error) {
        next(error);
    }
};
exports.getGeminiKeys = getGeminiKeys;
const createGeminiKey = async (req, res, next) => {
    try {
        const key = req.body.key || req.body.apiKey;
        const priority = req.body.priority;
        const provider = req.body.provider || 'gemini';
        const [newKey] = await db_1.db.insert(schema_1.geminiApiKeys).values({
            id: crypto_1.default.randomUUID(),
            keyEncrypted: key,
            priority: priority !== undefined ? priority : 0,
            isActive: true,
            healthStatus: 'healthy',
            provider: provider.toLowerCase(),
        }).returning();
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({
                id: crypto_1.default.randomUUID(),
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
    }
    catch (error) {
        next(error);
    }
};
exports.createGeminiKey = createGeminiKey;
const updateGeminiKey = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { priority, isActive, healthStatus } = req.body;
        const [updated] = await db_1.db.update(schema_1.geminiApiKeys)
            .set({
            ...(priority !== undefined ? { priority } : {}),
            ...(isActive !== undefined ? { isActive } : {}),
            ...(healthStatus !== undefined ? { healthStatus } : {}),
        })
            .where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, id))
            .returning();
        if (!updated)
            throw new errorHandler_1.AppError('Gemini Key not found', 404, 'NOT_FOUND');
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({
                id: crypto_1.default.randomUUID(),
                userId: req.user.id,
                action: 'update_gemini_key',
                detail: { keyId: id, priority, isActive, healthStatus },
            });
        }
        res.status(200).json({ success: true, message: 'Gemini Key updated successfully', data: updated });
    }
    catch (error) {
        next(error);
    }
};
exports.updateGeminiKey = updateGeminiKey;
const deleteGeminiKey = async (req, res, next) => {
    try {
        const { id } = req.params;
        const [deleted] = await db_1.db.delete(schema_1.geminiApiKeys).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, id)).returning();
        if (!deleted)
            throw new errorHandler_1.AppError('Gemini Key not found', 404, 'NOT_FOUND');
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'delete_gemini_key', detail: { keyId: id } });
        }
        res.status(200).json({ success: true, message: 'Gemini Key deleted successfully' });
    }
    catch (error) {
        next(error);
    }
};
exports.deleteGeminiKey = deleteGeminiKey;
const getSystemSettings = async (req, res, next) => {
    try {
        const defaultPackages = [
            { id: 'starter', name: 'Starter Pack', priceText: 'Rp 15.000', billingCycle: 'bulan', credits: 300, checkoutUrl: 'https://checkout.placeholder.com/starter' },
            { id: 'standard', name: 'Standard Pack', priceText: 'Rp 25.000', billingCycle: 'bulan', credits: 500, checkoutUrl: 'https://checkout.placeholder.com/standard' },
            { id: 'professional', name: 'Professional Pack', priceText: 'Rp 45.000', billingCycle: 'bulan', credits: 1000, checkoutUrl: 'https://checkout.placeholder.com/professional' }
        ];
        let settingsArr = await db_1.db.select().from(schema_1.appSettings).where((0, drizzle_orm_1.eq)(schema_1.appSettings.key, 'system_settings')).limit(1);
        let settings = settingsArr[0];
        if (!settings) {
            const [newSettings] = await db_1.db.insert(schema_1.appSettings).values({
                id: crypto_1.default.randomUUID(),
                key: 'system_settings',
                value: {
                    appName: 'Studio Prompt',
                    footerText: 'Studio Prompt · Hak Cipta Dilindungi',
                    maxQuotaPerDay: 50,
                    maintenanceMode: false,
                    bannerPosterInfo: '✨ Ditenagai AI. Isi form, klik GENERATE...',
                    bannerEnhanceInfo: '✨ Upload fotomu...',
                    packages: defaultPackages
                }
            }).returning();
            settings = newSettings;
        }
        else {
            const val = settings.value;
            if (!val.packages) {
                val.packages = defaultPackages;
                const [updated] = await db_1.db.update(schema_1.appSettings).set({ value: val }).where((0, drizzle_orm_1.eq)(schema_1.appSettings.key, 'system_settings')).returning();
                settings = updated;
            }
        }
        res.status(200).json({ success: true, data: settings.value || {} });
    }
    catch (error) {
        next(error);
    }
};
exports.getSystemSettings = getSystemSettings;
const updateSystemSettings = async (req, res, next) => {
    try {
        const { value } = req.body;
        const [updated] = await db_1.db.insert(schema_1.appSettings).values({ id: crypto_1.default.randomUUID(), key: 'system_settings', value })
            .onConflictDoUpdate({ target: schema_1.appSettings.key, set: { value } }).returning();
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'update_system_settings', detail: { value } });
        }
        res.status(200).json({ success: true, message: 'System settings updated', data: updated.value });
    }
    catch (error) {
        next(error);
    }
};
exports.updateSystemSettings = updateSystemSettings;
const getUsers = async (req, res, next) => {
    try {
        const usersList = await db_1.db.select().from(schema_1.users).orderBy((0, drizzle_orm_1.desc)(schema_1.users.createdAt));
        const promptsCount = await db_1.db.select({ userId: schema_1.prompts.userId, count: (0, drizzle_orm_1.count)() }).from(schema_1.prompts).groupBy(schema_1.prompts.userId);
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
    }
    catch (error) {
        next(error);
    }
};
exports.getUsers = getUsers;
const updateUserSubscription = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { subscriptionStatus, subscriptionExpiresAt, credits } = req.body;
        const [updated] = await db_1.db.update(schema_1.users).set({
            subscriptionStatus,
            subscriptionExpiresAt: subscriptionExpiresAt ? new Date(subscriptionExpiresAt) : null,
            credits: credits !== undefined ? Number(credits) : undefined,
        }).where((0, drizzle_orm_1.eq)(schema_1.users.id, id)).returning();
        if (!updated)
            throw new errorHandler_1.AppError('User not found', 404, 'NOT_FOUND');
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'update_user_subscription', detail: { targetUserId: id, subscriptionStatus, subscriptionExpiresAt } });
        }
        res.status(200).json({ success: true, message: 'Updated successfully', data: updated });
    }
    catch (error) {
        next(error);
    }
};
exports.updateUserSubscription = updateUserSubscription;
const updateUserRole = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { role } = req.body;
        const [updated] = await db_1.db.update(schema_1.users).set({ role }).where((0, drizzle_orm_1.eq)(schema_1.users.id, id)).returning();
        if (!updated)
            throw new errorHandler_1.AppError('User not found', 404, 'NOT_FOUND');
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'update_user_role', detail: { targetUserId: id, newRole: role } });
        }
        res.status(200).json({ success: true, message: 'Role updated successfully', data: { id: updated.id, email: updated.email, role: updated.role } });
    }
    catch (error) {
        next(error);
    }
};
exports.updateUserRole = updateUserRole;
const getAuditLogs = async (req, res, next) => {
    try {
        // Basic join with users
        const logsList = await db_1.db.select({
            id: schema_1.logs.id,
            action: schema_1.logs.action,
            detail: schema_1.logs.detail,
            createdAt: schema_1.logs.createdAt,
            user: {
                email: schema_1.users.email
            }
        })
            .from(schema_1.logs)
            .leftJoin(schema_1.users, (0, drizzle_orm_1.eq)(schema_1.logs.userId, schema_1.users.id))
            .orderBy((0, drizzle_orm_1.desc)(schema_1.logs.createdAt))
            .limit(100);
        res.status(200).json({ success: true, data: logsList });
    }
    catch (error) {
        next(error);
    }
};
exports.getAuditLogs = getAuditLogs;
const getImageKitSettings = async (req, res, next) => {
    try {
        const settingsArr = await db_1.db.select().from(schema_1.appSettings).where((0, drizzle_orm_1.eq)(schema_1.appSettings.key, 'imagekit_settings')).limit(1);
        res.status(200).json({ success: true, data: settingsArr[0]?.value || { publicKey: '', privateKey: '', urlEndpoint: '' } });
    }
    catch (error) {
        next(error);
    }
};
exports.getImageKitSettings = getImageKitSettings;
const updateImageKitSettings = async (req, res, next) => {
    try {
        const { publicKey, privateKey, urlEndpoint } = req.body;
        const value = { publicKey, privateKey, urlEndpoint };
        const [updated] = await db_1.db.insert(schema_1.appSettings).values({ id: crypto_1.default.randomUUID(), key: 'imagekit_settings', value })
            .onConflictDoUpdate({ target: schema_1.appSettings.key, set: { value } }).returning();
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'update_imagekit_settings', detail: { publicKey, urlEndpoint } });
        }
        res.status(200).json({ success: true, message: 'Settings updated', data: updated.value });
    }
    catch (error) {
        next(error);
    }
};
exports.updateImageKitSettings = updateImageKitSettings;
const getVisualStyles = async (req, res, next) => {
    try {
        const styles = await db_1.db.select().from(schema_1.visualStyles).orderBy((0, drizzle_orm_1.desc)(schema_1.visualStyles.createdAt));
        res.status(200).json({ success: true, data: styles });
    }
    catch (error) {
        next(error);
    }
};
exports.getVisualStyles = getVisualStyles;
const createVisualStyle = async (req, res, next) => {
    try {
        const { name, promptTemplate, previewImageUrl } = req.body;
        const [newStyle] = await db_1.db.insert(schema_1.visualStyles).values({
            id: crypto_1.default.randomUUID(),
            name, promptTemplate, previewImageUrl, isActive: true
        }).returning();
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'create_visual_style', detail: { name, styleId: newStyle.id } });
        }
        res.status(201).json({ success: true, message: 'Style created', data: newStyle });
    }
    catch (error) {
        next(error);
    }
};
exports.createVisualStyle = createVisualStyle;
const updateVisualStyle = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { name, promptTemplate, previewImageUrl, isActive } = req.body;
        const [updated] = await db_1.db.update(schema_1.visualStyles).set({
            ...(name !== undefined ? { name } : {}),
            ...(promptTemplate !== undefined ? { promptTemplate } : {}),
            ...(previewImageUrl !== undefined ? { previewImageUrl } : {}),
            ...(isActive !== undefined ? { isActive } : {}),
        }).where((0, drizzle_orm_1.eq)(schema_1.visualStyles.id, id)).returning();
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'update_visual_style', detail: { styleId: id, name } });
        }
        res.status(200).json({ success: true, message: 'Style updated', data: updated });
    }
    catch (error) {
        next(error);
    }
};
exports.updateVisualStyle = updateVisualStyle;
const deleteVisualStyle = async (req, res, next) => {
    try {
        const { id } = req.params;
        await db_1.db.delete(schema_1.visualStyles).where((0, drizzle_orm_1.eq)(schema_1.visualStyles.id, id));
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'delete_visual_style', detail: { styleId: id } });
        }
        res.status(200).json({ success: true, message: 'Style deleted' });
    }
    catch (error) {
        next(error);
    }
};
exports.deleteVisualStyle = deleteVisualStyle;
const getLicenses = async (req, res, next) => {
    try {
        const keys = await db_1.db.select().from(schema_1.licenseKeys).orderBy((0, drizzle_orm_1.desc)(schema_1.licenseKeys.createdAt));
        res.status(200).json({ success: true, data: keys });
    }
    catch (error) {
        next(error);
    }
};
exports.getLicenses = getLicenses;
const generateLicenses = async (req, res, next) => {
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
            keysToCreate.push({ id: crypto_1.default.randomUUID(), key, days: validDays, credits: validCredits });
        }
        await db_1.db.insert(schema_1.licenseKeys).values(keysToCreate);
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'generate_licenses', detail: { count: validCount, days: validDays } });
        }
        res.status(201).json({ success: true, message: `Successfully generated ${validCount} license keys.` });
    }
    catch (error) {
        next(error);
    }
};
exports.generateLicenses = generateLicenses;
const deleteLicense = async (req, res, next) => {
    try {
        const { id } = req.params;
        await db_1.db.delete(schema_1.licenseKeys).where((0, drizzle_orm_1.eq)(schema_1.licenseKeys.id, id));
        res.status(200).json({ success: true, message: 'License deleted' });
    }
    catch (error) {
        next(error);
    }
};
exports.deleteLicense = deleteLicense;
const testGeminiKey = async (req, res, next) => {
    try {
        const { id } = req.params;
        const keyRecords = await db_1.db.select().from(schema_1.geminiApiKeys).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, id)).limit(1);
        const keyRecord = keyRecords[0];
        if (!keyRecord)
            throw new errorHandler_1.AppError('Gemini Key not found', 404, 'NOT_FOUND');
        let success = false;
        let errorMessage = '';
        try {
            if (keyRecord.provider === 'groq') {
                const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
                    method: 'POST',
                    headers: { 'Authorization': `Bearer ${keyRecord.keyEncrypted}`, 'Content-Type': 'application/json' },
                    body: JSON.stringify({ model: 'llama-3.3-70b-versatile', messages: [{ role: 'user', content: 'say OK' }], max_tokens: 5 })
                });
                const resJson = await response.json();
                if (response.ok && resJson.choices?.[0]?.message?.content) {
                    success = true;
                    await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: 'healthy' }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, id));
                }
                else {
                    throw new Error(resJson.error?.message || `Groq test failed: ${response.status}`);
                }
            }
            else {
                const genAI = new generative_ai_1.GoogleGenerativeAI(keyRecord.keyEncrypted);
                const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });
                const response = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: 'say OK' }] }], generationConfig: { maxOutputTokens: 5 } });
                const text = response.response.text();
                if (text) {
                    success = true;
                    await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: 'healthy' }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, id));
                }
                else {
                    throw new Error('Empty response');
                }
            }
        }
        catch (err) {
            errorMessage = err?.message || String(err);
            const isQuota = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('Quota');
            const newStatus = isQuota ? 'limited' : 'error';
            await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: newStatus }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, id));
            if (req.user?.id) {
                await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'key_rotation', detail: { keyId: id, reason: 'Manual Health Check Failure', error: errorMessage, newStatus } });
            }
        }
        res.status(200).json({
            success,
            message: success ? 'Key is working' : 'Key test failed',
            error: errorMessage ? (0, errorFormatter_1.formatGeminiError)(errorMessage) : '',
            data: { id, healthStatus: success ? 'healthy' : (errorMessage.includes('429') || errorMessage.includes('quota') ? 'limited' : 'error') }
        });
    }
    catch (error) {
        next(error);
    }
};
exports.testGeminiKey = testGeminiKey;
const testAllGeminiKeys = async (req, res, next) => {
    try {
        const keys = await db_1.db.select().from(schema_1.geminiApiKeys);
        const results = [];
        for (const keyRecord of keys) {
            let success = false;
            let errorMessage = '';
            try {
                if (keyRecord.provider === 'groq') {
                    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
                        method: 'POST',
                        headers: { 'Authorization': `Bearer ${keyRecord.keyEncrypted}`, 'Content-Type': 'application/json' },
                        body: JSON.stringify({ model: 'llama-3.3-70b-versatile', messages: [{ role: 'user', content: 'say OK' }], max_tokens: 5 })
                    });
                    const resJson = await response.json();
                    if (response.ok && resJson.choices?.[0]?.message?.content) {
                        success = true;
                        await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: 'healthy' }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, keyRecord.id));
                    }
                    else {
                        throw new Error(resJson.error?.message || `Groq test failed: ${response.status}`);
                    }
                }
                else {
                    const genAI = new generative_ai_1.GoogleGenerativeAI(keyRecord.keyEncrypted);
                    const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });
                    const response = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: 'say OK' }] }], generationConfig: { maxOutputTokens: 5 } });
                    const text = response.response.text();
                    if (text) {
                        success = true;
                        await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: 'healthy' }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, keyRecord.id));
                    }
                    else {
                        throw new Error('Empty response');
                    }
                }
            }
            catch (err) {
                errorMessage = err?.message || String(err);
                const isQuota = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('Quota');
                const newStatus = isQuota ? 'limited' : 'error';
                await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: newStatus }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, keyRecord.id));
                if (req.user?.id) {
                    await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId: req.user.id, action: 'key_rotation', detail: { keyId: keyRecord.id, reason: 'Manual Health Check Failure', error: errorMessage, newStatus } });
                }
            }
            results.push({ id: keyRecord.id, success, error: errorMessage ? (0, errorFormatter_1.formatGeminiError)(errorMessage) : '' });
        }
        res.status(200).json({ success: true, message: `Tested ${keys.length} keys`, data: results });
    }
    catch (error) {
        next(error);
    }
};
exports.testAllGeminiKeys = testAllGeminiKeys;
const getDeveloperKeys = async (req, res, next) => {
    try {
        if (!req.user?.id)
            throw new errorHandler_1.AppError('Unauthorized', 401, 'UNAUTHORIZED');
        const keys = await db_1.db.select().from(schema_1.developerApiKeys).where((0, drizzle_orm_1.eq)(schema_1.developerApiKeys.userId, req.user.id)).orderBy((0, drizzle_orm_1.desc)(schema_1.developerApiKeys.createdAt));
        res.status(200).json({ success: true, data: keys });
    }
    catch (error) {
        next(error);
    }
};
exports.getDeveloperKeys = getDeveloperKeys;
const createDeveloperKey = async (req, res, next) => {
    try {
        const { name } = req.body;
        const userId = req.user?.id;
        if (!userId)
            throw new errorHandler_1.AppError('Unauthorized', 401, 'UNAUTHORIZED');
        const secureToken = crypto_1.default.randomBytes(20).toString('hex');
        const apiKey = `ps_live_${secureToken}`;
        const [newKey] = await db_1.db.insert(schema_1.developerApiKeys).values({
            id: crypto_1.default.randomUUID(),
            userId,
            name: name || 'Default Key',
            apiKey,
            isActive: true,
        }).returning();
        await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId, action: 'create_developer_key', detail: { keyId: newKey.id, name: newKey.name } });
        res.status(201).json({ success: true, message: 'Key generated successfully', data: newKey });
    }
    catch (error) {
        next(error);
    }
};
exports.createDeveloperKey = createDeveloperKey;
const deleteDeveloperKey = async (req, res, next) => {
    try {
        const { id } = req.params;
        const userId = req.user?.id;
        if (!userId)
            throw new errorHandler_1.AppError('Unauthorized', 401, 'UNAUTHORIZED');
        const [deleted] = await db_1.db.delete(schema_1.developerApiKeys).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.developerApiKeys.id, id), (0, drizzle_orm_1.eq)(schema_1.developerApiKeys.userId, userId))).returning();
        if (!deleted)
            throw new errorHandler_1.AppError('Key not found', 404, 'NOT_FOUND');
        await db_1.db.insert(schema_1.logs).values({ id: crypto_1.default.randomUUID(), userId, action: 'delete_developer_key', detail: { keyId: id, name: deleted.name } });
        res.status(200).json({ success: true, message: 'Key deleted' });
    }
    catch (error) {
        next(error);
    }
};
exports.deleteDeveloperKey = deleteDeveloperKey;
const transferCreditsDirectly = async (req, res, next) => {
    try {
        const { email, credits } = req.body;
        const adminId = req.user?.id;
        if (!email || credits === undefined)
            throw new errorHandler_1.AppError('Email dan jumlah kredit wajib diisi', 400, 'BAD_REQUEST');
        const targetCredits = Number(credits);
        if (isNaN(targetCredits) || targetCredits <= 0)
            throw new errorHandler_1.AppError('Jumlah kredit harus berupa angka positif', 400, 'BAD_REQUEST');
        const userRecords = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.email, email.trim())).limit(1);
        const user = userRecords[0];
        if (!user)
            throw new errorHandler_1.AppError('Pengguna dengan email tersebut tidak ditemukan', 404, 'NOT_FOUND');
        const newCredits = (user.credits || 0) + targetCredits;
        const [updated] = await db_1.db.update(schema_1.users).set({
            credits: newCredits,
            subscriptionStatus: 'PRO',
        }).where((0, drizzle_orm_1.eq)(schema_1.users.id, user.id)).returning();
        if (adminId) {
            await db_1.db.insert(schema_1.logs).values({
                id: crypto_1.default.randomUUID(),
                userId: adminId,
                action: 'direct_credit_transfer',
                detail: { targetUserId: user.id, targetUserEmail: email, addedCredits: targetCredits, newTotalCredits: updated.credits },
            });
        }
        res.status(200).json({ success: true, message: `Berhasil menambahkan ${targetCredits} kredit. Total: ${updated.credits}`, data: updated });
    }
    catch (error) {
        next(error);
    }
};
exports.transferCreditsDirectly = transferCreditsDirectly;
