"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSharedPrompts = exports.toggleSharePrompt = exports.deletePrompt = exports.duplicatePrompt = exports.toggleFavorite = exports.getHistory = void 0;
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const errorHandler_1 = require("../../middlewares/errorHandler");
const crypto_1 = __importDefault(require("crypto"));
const getHistory = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { page = '1', limit = '10', search, mode, category, favorite } = req.query;
        const pageNum = parseInt(String(page), 10);
        const limitNum = parseInt(String(limit), 10);
        const skip = (pageNum - 1) * limitNum;
        // Build filter conditions
        const conditions = [(0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId)];
        if (mode)
            conditions.push((0, drizzle_orm_1.eq)(schema_1.prompts.mode, String(mode)));
        if (category)
            conditions.push((0, drizzle_orm_1.eq)(schema_1.prompts.category, String(category)));
        if (favorite === 'true')
            conditions.push((0, drizzle_orm_1.eq)(schema_1.prompts.isFavorite, true));
        if (search) {
            conditions.push((0, drizzle_orm_1.or)((0, drizzle_orm_1.ilike)(schema_1.prompts.topic, `%${search}%`), (0, drizzle_orm_1.ilike)(schema_1.prompts.promptFinal, `%${search}%`)));
        }
        const whereClause = (0, drizzle_orm_1.and)(...conditions);
        const [totalResult, promptsList] = await Promise.all([
            db_1.db.select({ count: (0, drizzle_orm_1.sql) `count(*)` }).from(schema_1.prompts).where(whereClause),
            db_1.db.select().from(schema_1.prompts)
                .where(whereClause)
                .offset(skip)
                .limit(limitNum)
                .orderBy((0, drizzle_orm_1.desc)(schema_1.prompts.createdAt)),
        ]);
        const total = Number(totalResult[0]?.count || 0);
        res.status(200).json({
            success: true,
            data: {
                prompts: promptsList,
                pagination: {
                    total,
                    page: pageNum,
                    limit: limitNum,
                    totalPages: Math.ceil(total / limitNum),
                },
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getHistory = getHistory;
const toggleFavorite = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const promptArr = await db_1.db.select().from(schema_1.prompts).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.prompts.id, id), (0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId))).limit(1);
        const prompt = promptArr[0];
        if (!prompt) {
            throw new errorHandler_1.AppError('Prompt not found', 404, 'NOT_FOUND');
        }
        const [updated] = await db_1.db.update(schema_1.prompts)
            .set({ isFavorite: !prompt.isFavorite })
            .where((0, drizzle_orm_1.eq)(schema_1.prompts.id, id))
            .returning();
        res.status(200).json({
            success: true,
            message: updated.isFavorite ? 'Prompt ditambahkan ke favorit' : 'Prompt dihapus dari favorit',
            data: updated,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.toggleFavorite = toggleFavorite;
const duplicatePrompt = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const promptArr = await db_1.db.select().from(schema_1.prompts).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.prompts.id, id), (0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId))).limit(1);
        const prompt = promptArr[0];
        if (!prompt) {
            throw new errorHandler_1.AppError('Prompt not found', 404, 'NOT_FOUND');
        }
        // Clone the prompt in database
        const [cloned] = await db_1.db.insert(schema_1.prompts).values({
            id: crypto_1.default.randomUUID(),
            userId,
            mode: prompt.mode,
            topic: `${prompt.topic} (Copy)`,
            payloadJson: prompt.payloadJson || {},
            promptFinal: prompt.promptFinal,
            referenceImageUrl: prompt.referenceImageUrl,
            category: prompt.category,
            hooks: prompt.hooks,
            viralScore: prompt.viralScore,
        }).returning();
        res.status(201).json({
            success: true,
            message: 'Prompt duplicated successfully',
            data: cloned,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.duplicatePrompt = duplicatePrompt;
const deletePrompt = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const promptArr = await db_1.db.select().from(schema_1.prompts).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.prompts.id, id), (0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId))).limit(1);
        const prompt = promptArr[0];
        if (!prompt) {
            throw new errorHandler_1.AppError('Prompt not found', 404, 'NOT_FOUND');
        }
        await db_1.db.delete(schema_1.prompts).where((0, drizzle_orm_1.eq)(schema_1.prompts.id, id));
        res.status(200).json({
            success: true,
            message: 'Prompt deleted successfully',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.deletePrompt = deletePrompt;
const toggleSharePrompt = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const promptArr = await db_1.db.select().from(schema_1.prompts).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.prompts.id, id), (0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId))).limit(1);
        const prompt = promptArr[0];
        if (!prompt) {
            throw new errorHandler_1.AppError('Prompt not found', 404, 'NOT_FOUND');
        }
        const [updated] = await db_1.db.update(schema_1.prompts)
            .set({ isShared: !prompt.isShared })
            .where((0, drizzle_orm_1.eq)(schema_1.prompts.id, id))
            .returning();
        res.status(200).json({
            success: true,
            message: updated.isShared ? 'Prompt berhasil dibagikan ke kolaborasi' : 'Prompt dihapus dari kolaborasi',
            data: updated,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.toggleSharePrompt = toggleSharePrompt;
const getSharedPrompts = async (req, res, next) => {
    try {
        const { page = '1', limit = '15', search, category } = req.query;
        const pageNum = parseInt(String(page), 10);
        const limitNum = parseInt(String(limit), 10);
        const skip = (pageNum - 1) * limitNum;
        // Build filter conditions
        const conditions = [(0, drizzle_orm_1.eq)(schema_1.prompts.isShared, true)];
        if (category)
            conditions.push((0, drizzle_orm_1.eq)(schema_1.prompts.category, String(category)));
        if (search) {
            conditions.push((0, drizzle_orm_1.or)((0, drizzle_orm_1.ilike)(schema_1.prompts.topic, `%${search}%`), (0, drizzle_orm_1.ilike)(schema_1.prompts.promptFinal, `%${search}%`)));
        }
        const whereClause = (0, drizzle_orm_1.and)(...conditions);
        const [totalResult, rawPrompts] = await Promise.all([
            db_1.db.select({ count: (0, drizzle_orm_1.sql) `count(*)` }).from(schema_1.prompts).where(whereClause),
            db_1.db.select({
                prompt: schema_1.prompts,
                userEmail: schema_1.users.email,
            })
                .from(schema_1.prompts)
                .leftJoin(schema_1.users, (0, drizzle_orm_1.eq)(schema_1.prompts.userId, schema_1.users.id))
                .where(whereClause)
                .offset(skip)
                .limit(limitNum)
                .orderBy((0, drizzle_orm_1.desc)(schema_1.prompts.createdAt)),
        ]);
        const total = Number(totalResult[0]?.count || 0);
        const formattedPrompts = rawPrompts.map(item => ({
            ...item.prompt,
            user: { email: item.userEmail }
        }));
        res.status(200).json({
            success: true,
            data: {
                prompts: formattedPrompts,
                pagination: {
                    total,
                    page: pageNum,
                    limit: limitNum,
                    totalPages: Math.ceil(total / limitNum)
                }
            }
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getSharedPrompts = getSharedPrompts;
