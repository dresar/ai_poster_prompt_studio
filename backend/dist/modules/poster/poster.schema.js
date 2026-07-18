"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.improvePromptSchema = exports.getHooksSchema = exports.getIdeasSchema = exports.generateEnhanceSchema = exports.generatePosterSchema = exports.analyzeTopicSchema = void 0;
const zod_1 = require("zod");
exports.analyzeTopicSchema = zod_1.z.object({
    topic: zod_1.z.string().min(1, 'Topic is required'),
});
exports.generatePosterSchema = zod_1.z.object({
    feature: zod_1.z.string().optional(),
    slideCount: zod_1.z.number().optional(),
    topic: zod_1.z.string().min(1, 'Topic is required'),
    description: zod_1.z.string().optional(),
    extraDetails: zod_1.z.string().optional(),
    style: zod_1.z.string().optional(),
    layout: zod_1.z.string().optional(),
    aspectRatio: zod_1.z.string().optional(),
    textRule: zod_1.z.string().optional(),
    characterFocus: zod_1.z.string().optional(),
    colorPalette: zod_1.z.string().optional(),
    mood: zod_1.z.string().optional(),
    watermark: zod_1.z.string().optional(),
    referenceImageUrl: zod_1.z.string().optional(),
    // Extra collapsed settings
    typography: zod_1.z.string().optional(),
    targetAudience: zod_1.z.string().optional(),
    composition: zod_1.z.string().optional(),
    visualDensity: zod_1.z.string().optional(),
    illustrationStyle: zod_1.z.string().optional(),
    renderingStyle: zod_1.z.string().optional(),
    lighting: zod_1.z.string().optional(),
    negativePrompt: zod_1.z.string().optional(),
    language: zod_1.z.string().optional(),
    complexity: zod_1.z.string().optional(),
    brandTone: zod_1.z.string().optional(),
    iconStyle: zod_1.z.string().optional(),
    ctaStyle: zod_1.z.string().optional(),
});
exports.generateEnhanceSchema = zod_1.z.object({
    imageUrl: zod_1.z.string().min(1, 'Image URL is required'),
    enhanceStyle: zod_1.z.string().min(1, 'Enhance style is required'),
    changeLevel: zod_1.z.string().min(1, 'Change level is required'),
    notes: zod_1.z.string().optional(),
});
exports.getIdeasSchema = zod_1.z.object({
    category: zod_1.z.string().min(1, 'Category is required'),
});
exports.getHooksSchema = zod_1.z.object({
    topic: zod_1.z.string().min(1, 'Topic is required'),
});
exports.improvePromptSchema = zod_1.z.object({
    promptDraft: zod_1.z.string().min(1, 'Prompt draft is required'),
});
