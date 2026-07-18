import { Request, Response, NextFunction } from 'express';
import { db } from '../../config/db';
import { prompts, users } from '../../db/schema';
import { eq, and, or, ilike, desc, sql } from 'drizzle-orm';
import { AppError } from '../../middlewares/errorHandler';
import crypto from 'crypto';

export const getHistory = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { page = '1', limit = '10', search, mode, category, favorite } = req.query;

    const pageNum = parseInt(String(page), 10);
    const limitNum = parseInt(String(limit), 10);
    const skip = (pageNum - 1) * limitNum;

    // Build filter conditions
    const conditions = [eq(prompts.userId, userId)];
    if (mode) conditions.push(eq(prompts.mode, String(mode)));
    if (category) conditions.push(eq(prompts.category, String(category)));
    if (favorite === 'true') conditions.push(eq(prompts.isFavorite, true));
    if (search) {
      conditions.push(or(
        ilike(prompts.topic, `%${search}%`),
        ilike(prompts.promptFinal, `%${search}%`)
      )!);
    }

    const whereClause = and(...conditions);

    const [totalResult, promptsList] = await Promise.all([
      db.select({ count: sql<number>`count(*)` }).from(prompts).where(whereClause),
      db.select().from(prompts)
        .where(whereClause)
        .offset(skip)
        .limit(limitNum)
        .orderBy(desc(prompts.createdAt)),
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
  } catch (error) {
    next(error);
  }
};

export const toggleFavorite = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const promptArr = await db.select().from(prompts).where(and(eq(prompts.id, id), eq(prompts.userId, userId))).limit(1);
    const prompt = promptArr[0];

    if (!prompt) {
      throw new AppError('Prompt not found', 404, 'NOT_FOUND');
    }

    const [updated] = await db.update(prompts)
      .set({ isFavorite: !prompt.isFavorite })
      .where(eq(prompts.id, id))
      .returning();

    res.status(200).json({
      success: true,
      message: updated.isFavorite ? 'Prompt ditambahkan ke favorit' : 'Prompt dihapus dari favorit',
      data: updated,
    });
  } catch (error) {
    next(error);
  }
};

export const duplicatePrompt = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const promptArr = await db.select().from(prompts).where(and(eq(prompts.id, id), eq(prompts.userId, userId))).limit(1);
    const prompt = promptArr[0];

    if (!prompt) {
      throw new AppError('Prompt not found', 404, 'NOT_FOUND');
    }

    // Clone the prompt in database
    const [cloned] = await db.insert(prompts).values({
      id: crypto.randomUUID(),
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
  } catch (error) {
    next(error);
  }
};

export const deletePrompt = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const promptArr = await db.select().from(prompts).where(and(eq(prompts.id, id), eq(prompts.userId, userId))).limit(1);
    const prompt = promptArr[0];

    if (!prompt) {
      throw new AppError('Prompt not found', 404, 'NOT_FOUND');
    }

    // Delete associated local reference images from disk
    const { deleteLocalFileByUrl } = await import('../../utils/image-cleanup');
    deleteLocalFileByUrl(prompt.referenceImageUrl);
    if (Array.isArray(prompt.referenceImageUrls)) {
      prompt.referenceImageUrls.forEach(url => deleteLocalFileByUrl(url));
    }

    await db.delete(prompts).where(eq(prompts.id, id));

    res.status(200).json({
      success: true,
      message: 'Prompt deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const toggleSharePrompt = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const promptArr = await db.select().from(prompts).where(and(eq(prompts.id, id), eq(prompts.userId, userId))).limit(1);
    const prompt = promptArr[0];

    if (!prompt) {
      throw new AppError('Prompt not found', 404, 'NOT_FOUND');
    }

    const [updated] = await db.update(prompts)
      .set({ isShared: !prompt.isShared })
      .where(eq(prompts.id, id))
      .returning();

    res.status(200).json({
      success: true,
      message: updated.isShared ? 'Prompt berhasil dibagikan ke kolaborasi' : 'Prompt dihapus dari kolaborasi',
      data: updated,
    });
  } catch (error) {
    next(error);
  }
};

export const getSharedPrompts = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '15', search, category } = req.query;
    const pageNum = parseInt(String(page), 10);
    const limitNum = parseInt(String(limit), 10);
    const skip = (pageNum - 1) * limitNum;

    // Build filter conditions
    const conditions = [eq(prompts.isShared, true)];
    if (category) conditions.push(eq(prompts.category, String(category)));
    if (search) {
      conditions.push(or(
        ilike(prompts.topic, `%${search}%`),
        ilike(prompts.promptFinal, `%${search}%`)
      )!);
    }

    const whereClause = and(...conditions);

    const [totalResult, rawPrompts] = await Promise.all([
      db.select({ count: sql<number>`count(*)` }).from(prompts).where(whereClause),
      db.select({
        prompt: prompts,
        userEmail: users.email,
      })
      .from(prompts)
      .leftJoin(users, eq(prompts.userId, users.id))
      .where(whereClause)
      .offset(skip)
      .limit(limitNum)
      .orderBy(desc(prompts.createdAt)),
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
  } catch (error) {
    next(error);
  }
};

export const updatePromptImage = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;
    const { imageUrl } = req.body;

    if (!imageUrl || typeof imageUrl !== 'string') {
      throw new AppError('URL gambar tidak boleh kosong', 400, 'BAD_REQUEST');
    }

    const promptArr = await db.select().from(prompts).where(and(eq(prompts.id, id), eq(prompts.userId, userId))).limit(1);
    if (!promptArr[0]) {
      throw new AppError('Prompt tidak ditemukan', 404, 'NOT_FOUND');
    }

    const [updated] = await db.update(prompts)
      .set({ referenceImageUrl: imageUrl })
      .where(eq(prompts.id, id))
      .returning();

    res.status(200).json({
      success: true,
      message: 'Gambar berhasil disimpan',
      data: { referenceImageUrl: updated.referenceImageUrl },
    });
  } catch (error) {
    next(error);
  }
};

// PATCH /history/:id/images — update full images array (max 10)
export const updatePromptImages = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;
    const { imageUrls } = req.body;

    if (!Array.isArray(imageUrls)) {
      throw new AppError('imageUrls harus berupa array', 400, 'BAD_REQUEST');
    }
    if (imageUrls.length > 10) {
      throw new AppError('Maksimal 10 gambar', 400, 'TOO_MANY_IMAGES');
    }

    const promptArr = await db.select().from(prompts).where(and(eq(prompts.id, id), eq(prompts.userId, userId))).limit(1);
    if (!promptArr[0]) throw new AppError('Prompt tidak ditemukan', 404, 'NOT_FOUND');

    const [updated] = await db.update(prompts)
      .set({
        referenceImageUrls: imageUrls as any,
        referenceImageUrl: imageUrls[0] || null,
      })
      .where(eq(prompts.id, id))
      .returning();

    res.status(200).json({
      success: true,
      message: `${imageUrls.length} gambar berhasil disimpan`,
      data: {
        referenceImageUrls: updated.referenceImageUrls,
        referenceImageUrl: updated.referenceImageUrl,
      },
    });
  } catch (error) {
    next(error);
  }
};
