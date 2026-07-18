import { Router } from 'express';
import { db } from '../../config/db';
import { formDescriptions } from '../../db/schema';
import { eq } from 'drizzle-orm';
import { authenticate, requireRole } from '../../middlewares/auth';

const router = Router();

// GET all form descriptions
router.get('/', async (req, res, next) => {
  try {
    const list = await db.select().from(formDescriptions);
    res.json({ success: true, data: list });
  } catch (error) {
    next(error);
  }
});

// PUT update a form description (Admin only)
router.put('/:key', authenticate, requireRole(['ADMIN']), async (req, res, next) => {
  try {
    const { key } = req.params;
    const { title, description } = req.body;

    const [existing] = await db.select().from(formDescriptions).where(eq(formDescriptions.featureKey, key));

    let record;
    if (existing) {
      const [updated] = await db.update(formDescriptions)
        .set({ title, description, updatedAt: new Date() })
        .where(eq(formDescriptions.featureKey, key))
        .returning();
      record = updated;
    } else {
      const [inserted] = await db.insert(formDescriptions)
        .values({ id: `info-${Date.now()}`, featureKey: key, title, description })
        .returning();
      record = inserted;
    }

    res.json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
});

export default router;
