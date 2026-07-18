import { Request, Response, NextFunction } from 'express';
import { db } from '../../config/db';
import { dropdownOptions, visualStyles, characters } from '../../db/schema';
import { eq, asc } from 'drizzle-orm';
import crypto from 'crypto';

/**
 * GET /api/sync/checksum
 * Returns a lightweight MD5 hash of all active dropdown + visual style + character data.
 * The Flutter app calls this on startup to detect if a sync is needed.
 * No auth required - intentionally public and lightweight.
 */
export const getSyncChecksum = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const dropdowns = await db
      .select({ id: dropdownOptions.id, value: dropdownOptions.value })
      .from(dropdownOptions)
      .where(eq(dropdownOptions.isActive, true))
      .orderBy(asc(dropdownOptions.id));

    const styles = await db
      .select({ id: visualStyles.id, name: visualStyles.name })
      .from(visualStyles)
      .where(eq(visualStyles.isActive, true))
      .orderBy(asc(visualStyles.id));

    const chars = await db
      .select({ id: characters.id, name: characters.name })
      .from(characters)
      .where(eq(characters.isActive, true))
      .orderBy(asc(characters.id));

    const dataString = JSON.stringify({ dropdowns, styles, chars });
    const checksum = crypto.createHash('md5').update(dataString).digest('hex');

    res.status(200).json({
      success: true,
      checksum,
      counts: {
        dropdownOptions: dropdowns.length,
        visualStyles: styles.length,
        characters: chars.length,
      },
      checkedAt: new Date().toISOString(),
    });
  } catch (error) {
    next(error);
  }
};
