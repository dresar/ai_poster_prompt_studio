import { Request, Response, NextFunction } from 'express';
import { db } from '../../config/db';
import { dropdownOptions, logs, characters, visualStyles } from '../../db/schema';
import { eq, and, asc } from 'drizzle-orm';
import { AppError } from '../../middlewares/errorHandler';
import crypto from 'crypto';

export const getDropdownOptions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { groupKey } = req.query;
    const groupKeyStr = groupKey ? String(groupKey) : undefined;

    const conditions = [eq(dropdownOptions.isActive, true)];
    if (groupKeyStr) {
      conditions.push(eq(dropdownOptions.groupKey, groupKeyStr));
    }

    const options = await db.select()
      .from(dropdownOptions)
      .where(and(...conditions))
      .orderBy(asc(dropdownOptions.sortOrder));

    // Inject karakter dari Character table untuk groupKey karakter poster & video
    const isCharacterGroup = !groupKeyStr
      || groupKeyStr === 'fokus_karakter_poster'
      || groupKeyStr === 'fokus_karakter_video';

    if (isCharacterGroup) {
      const activeCharacters = await db.select()
        .from(characters)
        .where(eq(characters.isActive, true))
        .orderBy(asc(characters.name));
      
      // Add to both poster & video groups when no groupKey (full fetch)
      const groups = groupKeyStr
        ? [groupKeyStr]
        : ['fokus_karakter_poster', 'fokus_karakter_video'];

      for (const grp of groups) {
        const characterOptions = activeCharacters.map(c => ({
          id: `char_${grp}_${c.id}`,
          groupKey: grp,
          label: c.name,
          value: c.id,
          helperText: c.description,
          icon: c.imageUrl,
          isActive: true,
          sortOrder: 100,
        }));
        options.push(...characterOptions);
      }
    }

    // Inject VisualStyle dari tabel visualStyles sebagai gaya_visual_video
    const isVisualStyleGroup = !groupKeyStr || groupKeyStr === 'gaya_visual_video';
    if (isVisualStyleGroup) {
      const activeStyles = await db.select()
        .from(visualStyles)
        .where(eq(visualStyles.isActive, true))
        .orderBy(asc(visualStyles.name));
      
      const styleOptions = activeStyles.map((s, idx) => ({
        id: `vs_${s.id}`,
        groupKey: 'gaya_visual_video',
        label: s.name,
        value: s.id,
        helperText: s.promptTemplate.substring(0, 80),
        icon: s.previewImageUrl,
        isActive: true,
        sortOrder: idx,
      }));
      options.push(...styleOptions);
    }

    res.status(200).json({
      success: true,
      data: options,
    });
  } catch (error) {
    next(error);
  }
};

export const createDropdownOption = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { groupKey, label, value, helperText, icon, isActive, sortOrder } = req.body;

    const [option] = await db.insert(dropdownOptions).values({
      id: crypto.randomUUID(),
      groupKey,
      label,
      value,
      helperText,
      icon,
      isActive: isActive !== undefined ? isActive : true,
      sortOrder: sortOrder || 0,
    }).returning();

    // Log admin action
    if (req.user?.id) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'create_dropdown_option',
        detail: { optionId: option.id, groupKey, label },
      });
    }

    res.status(201).json({
      success: true,
      message: 'Dropdown option created successfully',
      data: option,
    });
  } catch (error) {
    next(error);
  }
};

export const updateDropdownOption = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const optionsArr = await db.select().from(dropdownOptions).where(eq(dropdownOptions.id, id)).limit(1);
    const option = optionsArr[0];

    if (!option) {
      throw new AppError('Dropdown option not found', 404, 'NOT_FOUND');
    }

    const [updated] = await db.update(dropdownOptions)
      .set(updateData)
      .where(eq(dropdownOptions.id, id))
      .returning();

    // Log admin action
    if (req.user?.id) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'update_dropdown_option',
        detail: { optionId: id, updateData },
      });
    }

    res.status(200).json({
      success: true,
      message: 'Dropdown option updated successfully',
      data: updated,
    });
  } catch (error) {
    next(error);
  }
};

export const deleteDropdownOption = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const optionsArr = await db.select().from(dropdownOptions).where(eq(dropdownOptions.id, id)).limit(1);
    const option = optionsArr[0];

    if (!option) {
      throw new AppError('Dropdown option not found', 404, 'NOT_FOUND');
    }

    await db.delete(dropdownOptions).where(eq(dropdownOptions.id, id));

    // Log admin action
    if (req.user?.id) {
      await db.insert(logs).values({
        id: crypto.randomUUID(),
        userId: req.user.id,
        action: 'delete_dropdown_option',
        detail: { optionId: id, groupKey: option.groupKey, label: option.label },
      });
    }

    res.status(200).json({
      success: true,
      message: 'Dropdown option deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
