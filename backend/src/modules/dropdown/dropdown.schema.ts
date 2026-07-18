import { z } from 'zod';

export const createDropdownOptionSchema = z.object({
  groupKey: z.string().min(1, 'Group key is required'),
  label: z.string().min(1, 'Label is required'),
  value: z.string().min(1, 'Value is required'),
  helperText: z.string().optional(),
  icon: z.string().optional(),
  isActive: z.boolean().optional(),
  sortOrder: z.number().int().optional(),
});

export const updateDropdownOptionSchema = z.object({
  groupKey: z.string().min(1).optional(),
  label: z.string().min(1).optional(),
  value: z.string().min(1).optional(),
  helperText: z.string().optional(),
  icon: z.string().optional(),
  isActive: z.boolean().optional(),
  sortOrder: z.number().int().optional(),
});

export const queryDropdownSchema = z.object({
  groupKey: z.string().optional(),
});
