import { Router } from 'express';
import { db } from '../../config/db';
import { promptTemplates, logs } from '../../db/schema';
import { eq, and, ilike, or } from 'drizzle-orm';
import { authenticate } from '../../middlewares/auth';
import { AppError } from '../../middlewares/errorHandler';
import crypto from 'crypto';

const router = Router();

// POST /api/templates — Allow authenticated users to save history entries as templates
router.post('/', authenticate, async (req, res, next) => {
  try {
    const { title, category, template, previewImageUrl, viralScore, viralBreakdown, payloadJson, hooks, analysis } = req.body;
    if (!category || !template) {
      throw new AppError('Kategori dan template wajib diisi', 400, 'BAD_REQUEST');
    }

    const [newTpl] = await db.insert(promptTemplates).values({
      id: crypto.randomUUID(),
      title: title || payloadJson?.formState?.topic || payloadJson?.topic || null,
      category: category.toString().toLowerCase().trim(),
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
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'create_template_from_history',
        detail: { templateId: newTpl.id, category, title }
      });
    }

    res.status(201).json({ success: true, message: 'Template berhasil dibuat', data: newTpl });
  } catch (error) {
    next(error);
  }
});

// GET /api/templates — Public (user authenticated) list templates with search + category filter
router.get('/', authenticate, async (req, res, next) => {
  try {
    const { search, category } = req.query;

    const conditions: any[] = [eq(promptTemplates.isActive, true)];

    if (category && typeof category === 'string' && category !== 'all') {
      conditions.push(eq(promptTemplates.category, category));
    }

    if (search && typeof search === 'string' && search.trim().length > 0) {
      const q = `%${search.trim()}%`;
      conditions.push(
        or(
          ilike(promptTemplates.template, q),
          ilike(promptTemplates.category, q)
        )
      );
    }

    const list = await db
      .select()
      .from(promptTemplates)
      .where(and(...conditions));

    res.status(200).json({ success: true, data: list });
  } catch (error) {
    next(error);
  }
});

// GET /api/templates/categories — Get unique categories list
router.get('/categories', authenticate, async (req, res, next) => {
  try {
    const rows = await db
      .selectDistinct({ category: promptTemplates.category })
      .from(promptTemplates)
      .where(eq(promptTemplates.isActive, true));

    const categories = rows.map((r) => r.category).filter(Boolean);
    res.status(200).json({ success: true, data: categories });
  } catch (error) {
    next(error);
  }
});

// GET /api/templates/:id — Get single template
router.get('/:id', authenticate, async (req, res, next) => {
  try {
    const { id } = req.params;
    const rows = await db
      .select()
      .from(promptTemplates)
      .where(eq(promptTemplates.id, id))
      .limit(1);

    if (!rows[0]) {
      return res.status(404).json({ success: false, message: 'Template tidak ditemukan' });
    }

    res.status(200).json({ success: true, data: rows[0] });
  } catch (error) {
    next(error);
  }
});

export default router;
