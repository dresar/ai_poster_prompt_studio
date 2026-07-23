import { z } from 'zod';

export const analyzeTopicSchema = z.object({
  topic: z.string().min(1, 'Topic is required'),
  category: z.string().optional(),
});

export const generatePosterSchema = z.object({
  feature: z.string().optional(),
  slideCount: z.number().optional(),
  topic: z.string().min(1, 'Topic is required'),
  description: z.string().optional(),
  extraDetails: z.string().optional(),
  style: z.string().optional(),
  layout: z.string().optional(),
  aspectRatio: z.string().optional(),
  textRule: z.string().optional(),
  characterFocus: z.string().optional(),
  colorPalette: z.string().optional(),
  mood: z.string().optional(),
  watermark: z.string().optional(),
  referenceImageUrl: z.string().optional(),
  duration: z.number().optional(),
  cameraMovement: z.string().optional(),
  useManualLogo: z.boolean().optional(),
  includeCaption: z.boolean().optional(),
  // Extra collapsed settings
  typography: z.string().optional(),
  targetAudience: z.string().optional(),
  composition: z.string().optional(),
  visualDensity: z.string().optional(),
  illustrationStyle: z.string().optional(),
  renderingStyle: z.string().optional(),
  lighting: z.string().optional(),
  negativePrompt: z.string().optional(),
  language: z.string().optional(),
  complexity: z.string().optional(),
  brandTone: z.string().optional(),
  iconStyle: z.string().optional(),
  ctaStyle: z.string().optional(),
});

export const generateEnhanceSchema = z.object({
  imageUrl: z.string().min(1, 'Image URL is required'),
  enhanceStyle: z.string().min(1, 'Enhance style is required'),
  changeLevel: z.string().min(1, 'Change level is required'),
  notes: z.string().optional(),
});

export const getIdeasSchema = z.object({
  category: z.string().min(1, 'Category is required'),
  slideCount: z.string().optional(),
});

export const getHooksSchema = z.object({
  topic: z.string().min(1, 'Topic is required'),
});

export const improvePromptSchema = z.object({
  promptDraft: z.string().min(1, 'Prompt draft is required'),
});

export const analyzeStoryboardSchema = z.object({
  topic: z.string().min(1, 'Topic is required'),
  duration: z.number().optional(),
});

export const importExternalPromptSchema = z.object({
  feature: z.string().optional(),
  slideCount: z.number().optional(),
  topic: z.string().min(1, 'Topic is required'),
  description: z.string().optional(),
  extraDetails: z.string().optional(),
  style: z.string().optional(),
  layout: z.string().optional(),
  aspectRatio: z.string().optional(),
  textRule: z.string().optional(),
  characterFocus: z.string().optional(),
  colorPalette: z.string().optional(),
  mood: z.string().optional(),
  watermark: z.string().optional(),
  referenceImageUrl: z.string().optional(),
  useManualLogo: z.boolean().optional(),
  externalJson: z.union([z.string(), z.record(z.any())]),
});

export const saveExternalDraftSchema = z.object({
  draftId: z.string().optional(),
  formState: z.record(z.any()),
  instructionsText: z.string().min(1, 'Instructions text is required'),
});

