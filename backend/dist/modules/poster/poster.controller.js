"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.chat = exports.uploadImage = exports.activateLicense = exports.getPublicVisualStyles = exports.improvePrompt = exports.getHooks = exports.getContentIdeas = exports.generateEnhance = exports.generatePoster = exports.analyzeTopic = void 0;
const ai_gateway_service_1 = require("../ai-gateway/ai-gateway.service");
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const errorHandler_1 = require("../../middlewares/errorHandler");
const https_1 = __importDefault(require("https"));
const crypto_1 = __importDefault(require("crypto"));
const aiService = new ai_gateway_service_1.AIGatewayService();
// Helper to check user daily quota
async function checkQuota(userId) {
    const foundUsers = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, userId)).limit(1);
    const user = foundUsers[0];
    if (!user) {
        throw new errorHandler_1.AppError('Pengguna tidak ditemukan.', 404, 'NOT_FOUND');
    }
    // Admin bypass daily limits
    if (user.role === 'ADMIN') {
        return;
    }
    if (user.subscriptionStatus === 'PRO') {
        if (user.credits <= 0) {
            throw new errorHandler_1.AppError('Kredit Premium Anda telah habis (0 token tersisa). Silakan beli/aktivasi paket kredit baru untuk terus menggunakan AI Studio!', 429, 'QUOTA_EXCEEDED');
        }
    }
    else {
        // Midnight 00:00 local time reset for FREE tier daily limit
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);
        const countResult = await db_1.db.select({ count: (0, drizzle_orm_1.sql) `count(*)` })
            .from(schema_1.prompts)
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId), (0, drizzle_orm_1.gte)(schema_1.prompts.createdAt, startOfDay)));
        const count = Number(countResult[0]?.count || 0);
        const settingsObjArr = await db_1.db.select().from(schema_1.appSettings).where((0, drizzle_orm_1.eq)(schema_1.appSettings.key, 'system_settings')).limit(1);
        const settingsObj = settingsObjArr[0];
        const settings = settingsObj?.value || {};
        const maxFreeQuota = settings.maxQuotaPerDay || settings.quotaDailyLimit || 10;
        if (count >= maxFreeQuota) {
            throw new errorHandler_1.AppError(`Kuota harian gratis Anda telah habis (${count}/${maxFreeQuota} kredit). Reset otomatis pada jam 00:00 tengah malam. Silakan beli paket kredit tambahan untuk terus berkarya!`, 429, 'QUOTA_EXCEEDED');
        }
    }
}
const analyzeTopic = async (req, res, next) => {
    try {
        const { topic } = req.body;
        const analysis = await aiService.analyzeTopic(topic);
        res.status(200).json({
            success: true,
            data: analysis,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.analyzeTopic = analyzeTopic;
const generatePoster = async (req, res, next) => {
    try {
        const userId = req.user.id;
        // 1. Quota check
        await checkQuota(userId);
        const formState = req.body;
        // 2. Resolve visual style template from database if selected
        let styleTemplate = '';
        if (formState.style && formState.style !== 'auto') {
            const visualStyleObjArr = await db_1.db.select().from(schema_1.visualStyles)
                .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.visualStyles.name, formState.style), (0, drizzle_orm_1.eq)(schema_1.visualStyles.isActive, true)))
                .limit(1);
            const visualStyleObj = visualStyleObjArr[0];
            if (visualStyleObj) {
                styleTemplate = visualStyleObj.promptTemplate;
            }
        }
        // 3. Reference image analysis if provided
        let aiAnalysis = null;
        if (formState.referenceImageUrl) {
            aiAnalysis = await aiService.analyzeReferenceImage(formState.referenceImageUrl);
        }
        const payloadState = {
            ...formState,
            styleTemplate,
            referenceImage: {
                url: formState.referenceImageUrl || null,
                aiAnalysis,
            },
        };
        // 3. Generate prompt
        const { payloadJson, promptFinal } = await aiService.generatePrompt(payloadState);
        // 4. Calculate viral score & hooks
        const viralData = await aiService.scoreViral(promptFinal);
        const generatedHooks = payloadJson.output?.hooks || [];
        const fallbackHooks = await aiService.generateHooks(formState.topic);
        const finalHooks = generatedHooks.length > 0 ? generatedHooks : fallbackHooks;
        // 5. Update payload JSON output
        payloadJson.output = {
            ...payloadJson.output,
            promptFinal,
            viralScore: viralData.score,
            hooks: finalHooks,
        };
        // 6. Save prompt to DB
        const promptId = crypto_1.default.randomUUID();
        const [savedPrompt] = await db_1.db.insert(schema_1.prompts).values({
            id: promptId,
            userId,
            mode: formState.feature || 'poster',
            topic: formState.topic || 'Untitled',
            payloadJson: payloadJson,
            promptFinal: promptFinal,
            referenceImageUrl: formState.referenceImageUrl || null,
            category: formState.feature || 'poster',
            hooks: finalHooks,
            viralScore: viralData.score,
        }).returning();
        // Decrement credits for PRO user
        const foundUsers = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, userId)).limit(1);
        const userObj = foundUsers[0];
        if (userObj && userObj.subscriptionStatus === 'PRO') {
            await db_1.db.update(schema_1.users)
                .set({ credits: (0, drizzle_orm_1.sql) `credits - 1` })
                .where((0, drizzle_orm_1.eq)(schema_1.users.id, userId));
        }
        // 7. Write audit log
        await db_1.db.insert(schema_1.logs).values({
            id: crypto_1.default.randomUUID(),
            userId,
            action: 'generate_poster_prompt',
            detail: { promptId: savedPrompt.id, topic: formState.topic },
        });
        res.status(201).json({
            success: true,
            message: 'Poster prompt generated successfully',
            data: {
                prompt: savedPrompt,
                viralBreakdown: viralData.breakdown,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.generatePoster = generatePoster;
const generateEnhance = async (req, res, next) => {
    try {
        const userId = req.user.id;
        // 1. Quota check
        await checkQuota(userId);
        const { imageUrl, enhanceStyle, changeLevel, notes } = req.body;
        if (!imageUrl) {
            throw new errorHandler_1.AppError('imageUrl is required for photo enhancement', 400, 'BAD_REQUEST');
        }
        // 2. Gemini Vision: analyze photo AND generate structured enhance prompt
        const { payloadJson, promptFinal } = await aiService.generateEnhancePrompt(imageUrl, enhanceStyle || 'kpop_aesthetic', changeLevel || 'natural', notes || '');
        // 3. Score viral potential
        const viralData = await aiService.scoreViral(promptFinal);
        // 4. Merge viral score into payload
        payloadJson.output = {
            ...payloadJson.output,
            promptFinal,
            viralScore: viralData.score,
        };
        // 5. Save to DB
        const promptId = crypto_1.default.randomUUID();
        const [savedPrompt] = await db_1.db.insert(schema_1.prompts).values({
            id: promptId,
            userId,
            mode: 'photo_enhance',
            topic: `Enhance: ${enhanceStyle || 'kpop_aesthetic'}`,
            payloadJson: payloadJson,
            promptFinal: promptFinal,
            referenceImageUrl: imageUrl,
            category: enhanceStyle || 'kpop_aesthetic',
            hooks: payloadJson?.output?.hooks || [],
            viralScore: viralData.score,
        }).returning();
        // 6. Decrement credits for PRO user
        const foundUsers = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, userId)).limit(1);
        const userObj = foundUsers[0];
        if (userObj && userObj.subscriptionStatus === 'PRO') {
            await db_1.db.update(schema_1.users)
                .set({ credits: (0, drizzle_orm_1.sql) `credits - 1` })
                .where((0, drizzle_orm_1.eq)(schema_1.users.id, userId));
        }
        // 7. Write audit log
        await db_1.db.insert(schema_1.logs).values({
            id: crypto_1.default.randomUUID(),
            userId,
            action: 'generate_enhance_prompt',
            detail: { promptId: savedPrompt.id, enhanceStyle, imageUrl },
        });
        res.status(201).json({
            success: true,
            message: 'Photo enhancement prompt generated successfully',
            data: {
                prompt: savedPrompt,
                viralBreakdown: viralData.breakdown,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.generateEnhance = generateEnhance;
const getContentIdeas = async (req, res, next) => {
    try {
        const { category } = req.query;
        const userId = req.user.id;
        const ideas = await aiService.generateContentIdeas(userId, String(category));
        // Save each recommended idea to the ContentIdea table
        await Promise.all(ideas.map((idea) => db_1.db.insert(schema_1.contentIdeas).values({
            id: crypto_1.default.randomUUID(),
            userId,
            category: String(category),
            idea,
        })));
        res.status(200).json({
            success: true,
            data: ideas,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getContentIdeas = getContentIdeas;
const getHooks = async (req, res, next) => {
    try {
        const { topic } = req.query;
        const hooks = await aiService.generateHooks(String(topic));
        res.status(200).json({
            success: true,
            data: hooks,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getHooks = getHooks;
const improvePrompt = async (req, res, next) => {
    try {
        const { promptDraft } = req.body;
        const improved = await aiService.improvePrompt(promptDraft);
        res.status(200).json({
            success: true,
            data: improved,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.improvePrompt = improvePrompt;
const getPublicVisualStyles = async (req, res, next) => {
    try {
        const styles = await db_1.db.select({
            id: schema_1.visualStyles.id,
            name: schema_1.visualStyles.name,
            promptTemplate: schema_1.visualStyles.promptTemplate,
            previewImageUrl: schema_1.visualStyles.previewImageUrl,
        }).from(schema_1.visualStyles)
            .where((0, drizzle_orm_1.eq)(schema_1.visualStyles.isActive, true))
            .orderBy((0, drizzle_orm_1.asc)(schema_1.visualStyles.name));
        res.status(200).json({
            success: true,
            data: styles,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getPublicVisualStyles = getPublicVisualStyles;
const activateLicense = async (req, res, next) => {
    try {
        const { key } = req.body;
        const userId = req.user.id;
        const userEmail = req.user.email;
        const licenseArr = await db_1.db.select().from(schema_1.licenseKeys).where((0, drizzle_orm_1.eq)(schema_1.licenseKeys.key, key)).limit(1);
        const license = licenseArr[0];
        if (!license) {
            throw new errorHandler_1.AppError('Lisensi tidak valid atau tidak ditemukan', 404, 'NOT_FOUND');
        }
        if (license.isUsed) {
            throw new errorHandler_1.AppError('Lisensi ini sudah pernah diaktifkan', 400, 'ALREADY_USED');
        }
        // Calculate expiry date
        const expiry = new Date();
        expiry.setDate(expiry.getDate() + license.days);
        // Update User & License
        await db_1.db.transaction(async (tx) => {
            await tx.update(schema_1.users)
                .set({
                subscriptionStatus: 'PRO',
                subscriptionExpiresAt: expiry,
                credits: (0, drizzle_orm_1.sql) `credits + ${license.credits}`,
            })
                .where((0, drizzle_orm_1.eq)(schema_1.users.id, userId));
            await tx.update(schema_1.licenseKeys)
                .set({
                isUsed: true,
                usedBy: userEmail,
                usedAt: new Date(),
            })
                .where((0, drizzle_orm_1.eq)(schema_1.licenseKeys.id, license.id));
            await tx.insert(schema_1.logs).values({
                id: crypto_1.default.randomUUID(),
                userId,
                action: 'activate_license',
                detail: { key, days: license.days, credits: license.credits },
            });
        });
        res.status(200).json({
            success: true,
            message: `Selamat! Lisensi berhasil diaktifkan. Anda mendapatkan tambahan ${license.credits} kredit prompt.`,
            data: {
                subscriptionStatus: 'PRO',
                subscriptionExpiresAt: expiry,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.activateLicense = activateLicense;
const uploadImage = async (req, res, next) => {
    try {
        const { image, fileName } = req.body;
        if (!image) {
            throw new errorHandler_1.AppError('Image data is required', 400, 'BAD_REQUEST');
        }
        // 1. Fetch ImageKit credentials from the database
        const settingsObjArr = await db_1.db.select().from(schema_1.appSettings).where((0, drizzle_orm_1.eq)(schema_1.appSettings.key, 'imagekit_settings')).limit(1);
        const settingsObj = settingsObjArr[0];
        if (!settingsObj) {
            throw new errorHandler_1.AppError('ImageKit settings not configured in database', 500, 'NOT_CONFIGURED');
        }
        const config = settingsObj.value;
        if (!config.privateKey || !config.urlEndpoint) {
            throw new errorHandler_1.AppError('ImageKit credentials missing or invalid in database', 500, 'INVALID_CREDENTIALS');
        }
        // 2. Upload to ImageKit
        const fileUrl = await uploadToImageKit(image, fileName || `upload-${Date.now()}.png`, config);
        res.status(200).json({
            success: true,
            url: fileUrl,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.uploadImage = uploadImage;
function uploadToImageKit(base64File, fileName, config) {
    return new Promise((resolve, reject) => {
        // Strip data prefix if present (e.g. data:image/jpeg;base64,)
        let cleanBase64 = base64File;
        if (base64File.includes(';base64,')) {
            cleanBase64 = base64File.split(';base64,')[1];
        }
        const postData = JSON.stringify({
            file: cleanBase64,
            fileName: fileName,
        });
        const options = {
            hostname: 'upload.imagekit.io',
            port: 443,
            path: '/api/v1/files/upload',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData),
                'Authorization': 'Basic ' + Buffer.from(config.privateKey + ':').toString('base64'),
            },
        };
        const req = https_1.default.request(options, (res) => {
            let responseBody = '';
            res.on('data', (chunk) => {
                responseBody += chunk;
            });
            res.on('end', () => {
                try {
                    const parsed = JSON.parse(responseBody);
                    if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
                        if (parsed.url) {
                            resolve(parsed.url);
                        }
                        else {
                            reject(new Error(parsed.message || 'ImageKit upload failed'));
                        }
                    }
                    else {
                        reject(new Error(parsed.message || `HTTP error ${res.statusCode}`));
                    }
                }
                catch (e) {
                    reject(e);
                }
            });
        });
        req.on('error', (e) => {
            reject(e);
        });
        req.write(postData);
        req.end();
    });
}
const chat = async (req, res, next) => {
    try {
        const { message, history } = req.body;
        if (!message) {
            throw new errorHandler_1.AppError('Pesan tidak boleh kosong', 400, 'BAD_REQUEST');
        }
        const reply = await aiService.chat(message, history || []);
        res.status(200).json({
            success: true,
            data: { reply },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.chat = chat;
