import * as dotenv from 'dotenv';
import path from 'path';
dotenv.config({ path: path.join(__dirname, '../../.env') });

import { db } from '../config/db';
import { promptTemplates } from '../db/schema';
import { ulid } from 'ulid';

const templates = [
  // POSTER (5)
  {
    category: "poster",
    previewImageUrl: "https://images.unsplash.com/photo-1626808642875-0aa545481fd6?w=500&q=80",
    template: "A striking, highly detailed promotional poster for {{topic}}. Brand description: {{description}}. Key features/points to display: {{keyPoints}}. Style: {{style}}, layout format: {{layout}}, aspect ratio: {{aspectRatio}}, color palette: {{colorPalette}}, visual mood: {{mood}}. Target audience: {{targetAudience}}. Call-to-Action (CTA): {{cta}}. Negative prompts: {{negativePrompt}}. Watermark: {{watermark}}.",
    isActive: true,
  },
  {
    category: "poster",
    previewImageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80",
    template: "A futuristic cyberpunk-style promotional poster for {{topic}}. Detailed brand elements: {{description}}, emphasizing key points: {{keyPoints}}. Cinematic lighting: {{lighting}}, dramatic camera angle: {{cameraAngle}}. Rendered in {{style}} with vibrant {{colorPalette}} neons. Mood: {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Bold text inclusion: {{textRule}}. Exclude: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "poster",
    previewImageUrl: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500&q=80",
    template: "An elegant, minimalist event poster about {{topic}}. Featuring clean typography and ample white space. Details: {{description}}. Key highlights: {{keyPoints}}. Art direction: {{style}}, strictly adhering to {{colorPalette}}. Mood: {{mood}}. Composition: {{layout}}, ratio: {{aspectRatio}}. Target demographic: {{targetAudience}}. Text rule: {{textRule}}. Do not include: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "poster",
    previewImageUrl: "https://images.unsplash.com/photo-1518600506278-4e8ef466b810?w=500&q=80",
    template: "A nostalgic, retro 80s synthwave poster for {{topic}}. Context: {{description}}. Crucial elements: {{keyPoints}}. Visual aesthetic: {{style}} with authentic VHS grain and {{colorPalette}} colors. Lighting: {{lighting}}. Vibe: {{mood}}. Layout constraint: {{layout}} ({{aspectRatio}}). CTA: {{cta}}. Avoid: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "poster",
    previewImageUrl: "https://images.unsplash.com/photo-1506152983158-b4a74a01c721?w=500&q=80",
    template: "A photorealistic blockbuster movie poster for {{topic}}. Synopsis: {{description}}. Cast/features: {{keyPoints}}. Rendered using Unreal Engine 5 level detail, style: {{style}}. Lighting: {{lighting}} with dramatic rim lights. Camera: {{cameraAngle}}. Emotional tone: {{mood}}, Colors: {{colorPalette}}. Aspect ratio: {{aspectRatio}}, layout: {{layout}}. Negative prompt: {{negativePrompt}}.",
    isActive: true,
  },

  // BANNER (4)
  {
    category: "banner",
    previewImageUrl: "https://images.unsplash.com/photo-1508739773402-3ce87515bbac?w=500&q=80",
    template: "A wide, high-conversion web banner for {{topic}}. Offer details: {{description}}. Bullet points: {{keyPoints}}. Design style: {{style}} with high contrast {{colorPalette}} for maximum CTR. Layout: {{layout}} optimized for {{aspectRatio}}. Mood: {{mood}}. Strong CTA button: {{cta}}. Text rules: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "banner",
    previewImageUrl: "https://images.unsplash.com/photo-1557683316-973673baf926?w=500&q=80",
    template: "A professional LinkedIn/Twitter header banner showcasing {{topic}}. Brand identity: {{description}}. Core values: {{keyPoints}}. Corporate yet modern style: {{style}}. Color scheme: {{colorPalette}}. Lighting: soft, studio {{lighting}}. Mood: {{mood}}. Composition: {{layout}} taking advantage of the extreme {{aspectRatio}} width. Avoid: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "banner",
    previewImageUrl: "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=500&q=80",
    template: "An aggressive, flashy sale/discount banner for {{topic}}. Promo info: {{description}}. Key triggers: {{keyPoints}}. Loud pop-art style: {{style}}. Eye-catching colors: {{colorPalette}}. Vibe: {{mood}} and urgent. Layout: {{layout}} ({{aspectRatio}}). Massive text: {{textRule}}. Do not show: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "banner",
    previewImageUrl: "https://images.unsplash.com/photo-1616423640778-28d1b53229bd?w=500&q=80",
    template: "A serene, aesthetic YouTube channel banner about {{topic}}. Channel theme: {{description}}. Features: {{keyPoints}}. Lo-fi / aesthetic style: {{style}}. Pastel palette: {{colorPalette}}. Soft lighting: {{lighting}}. Relaxing mood: {{mood}}. Panoramic layout: {{layout}} ({{aspectRatio}}). Text positioning: {{textRule}}. Negative prompt: {{negativePrompt}}.",
    isActive: true,
  },

  // EDUKASI (4)
  {
    category: "edukasi",
    previewImageUrl: "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=500&q=80",
    template: "An engaging educational infographic about {{topic}}. Content breakdown: {{description}}. Key learning points: {{keyPoints}}. Illustrated style: {{style}} making complex ideas simple. Colors: {{colorPalette}}. Mood: {{mood}} and academic. Layout: structured {{layout}}, ratio: {{aspectRatio}}. Text instructions: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "edukasi",
    previewImageUrl: "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500&q=80",
    template: "A 3D isometric educational diagram illustrating {{topic}}. Mechanism/details: {{description}}. Main components: {{keyPoints}}. Clean, modern 3D render style: {{style}}. Scientific color grading: {{colorPalette}}. Lighting: {{lighting}}. Angle: {{cameraAngle}}. Vibe: {{mood}}. Format: {{layout}} ({{aspectRatio}}). Avoid: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "edukasi",
    previewImageUrl: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500&q=80",
    template: "A vintage botanical or anatomical textbook style illustration of {{topic}}. Description: {{description}}. Focal points: {{keyPoints}}. Hand-drawn etching style: {{style}}. Sepia or muted colors: {{colorPalette}}. Lighting: flat {{lighting}}. Mood: {{mood}}, historical. Layout: {{layout}}, {{aspectRatio}}. Text: {{textRule}}. Exclude: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "edukasi",
    previewImageUrl: "https://images.unsplash.com/photo-1588072432836-e10032774350?w=500&q=80",
    template: "A bright, playful educational flashcard design for children about {{topic}}. Simple concept: {{description}}. Elements to include: {{keyPoints}}. Cartoon/vector style: {{style}}. Primary colors: {{colorPalette}}. Lighting: flat {{lighting}}. Cheerful mood: {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Big readable text: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },

  // AFFILIATE (4)
  {
    category: "affiliate",
    previewImageUrl: "https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=500&q=80",
    template: "A compelling affiliate marketing lifestyle photo promoting {{topic}}. Product context: {{description}}. Benefits to highlight: {{keyPoints}}. Instagram influencer style: {{style}}. Trendy palette: {{colorPalette}}. Lighting: golden hour {{lighting}}. Camera: {{cameraAngle}} with bokeh. Mood: {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Text: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "affiliate",
    previewImageUrl: "https://images.unsplash.com/photo-1526947425960-945c6e72858f?w=500&q=80",
    template: "A high-end unboxing/review thumbnail for affiliate product {{topic}}. Specs: {{description}}. Features: {{keyPoints}}. Tech-reviewer studio style: {{style}}. Contrast colors: {{colorPalette}}. Lighting: dramatic neon/RGB {{lighting}}. Focus: {{cameraAngle}}. Vibe: {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Clickbait text: {{textRule}}. Avoid: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "affiliate",
    previewImageUrl: "https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=500&q=80",
    template: "A split-screen 'Before & After' style affiliate graphic for {{topic}}. Transformation: {{description}}. Results: {{keyPoints}}. Authentic UGC (User Generated Content) style: {{style}}. Natural colors: {{colorPalette}}. Lighting: everyday {{lighting}}. Mood: relatable, {{mood}}. Ratio: {{aspectRatio}}, format: {{layout}}. Text overlay: {{textRule}}. No: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "affiliate",
    previewImageUrl: "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=500&q=80",
    template: "A flatlay composition showcasing the affiliate product {{topic}}. Surrounding items: {{description}}. Core focus: {{keyPoints}}. Minimalist editorial style: {{style}}. Monochromatic or {{colorPalette}} scheme. Lighting: soft diffused top-down {{lighting}}. Angle: overhead {{cameraAngle}}. Mood: {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Avoid: {{negativePrompt}}.",
    isActive: true,
  },

  // DIGITAL_PRODUCT (4)
  {
    category: "digital_product",
    previewImageUrl: "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=500&q=80",
    template: "A sleek 3D software box or digital bundle mockup for {{topic}}. Product contents: {{description}}. Value propositions: {{keyPoints}}. Premium SaaS style: {{style}}. Colors: trust-building {{colorPalette}}. Lighting: studio rim lights {{lighting}}. Angle: isometric {{cameraAngle}}. Mood: {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Text: {{textRule}}. Avoid: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "digital_product",
    previewImageUrl: "https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=500&q=80",
    template: "A glowing, futuristic representation of a digital course / ebook about {{topic}}. Details: {{description}}. Highlights: {{keyPoints}}. Abstract tech style: {{style}}. Palette: {{colorPalette}}. Lighting: glowing holograms {{lighting}}. Mood: cutting-edge, {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Typography: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "digital_product",
    previewImageUrl: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&q=80",
    template: "A clean iPad/MacBook device mockup showcasing a digital dashboard/template for {{topic}}. Context: {{description}}. Features: {{keyPoints}}. Apple-like minimalist style: {{style}}. Colors: {{colorPalette}}. Lighting: bright, airy {{lighting}}. Camera: slight angle {{cameraAngle}}. Mood: productive, {{mood}}. Format: {{layout}}, {{aspectRatio}}. No: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "digital_product",
    previewImageUrl: "https://images.unsplash.com/photo-1618761714954-0b8cd0026356?w=500&q=80",
    template: "An explosive, high-value 'Ultimate Toolkit' visual representation for {{topic}}. Contents: {{description}}. Assets: {{keyPoints}}. Hyper-detailed 3D render style: {{style}}. Vibrant colors: {{colorPalette}}. Lighting: dynamic {{lighting}}. Vibe: overwhelming value, {{mood}}. Composition: dense {{layout}} ({{aspectRatio}}). Text: {{textRule}}. Exclude: {{negativePrompt}}.",
    isActive: true,
  },

  // BALIHO (3)
  {
    category: "baliho",
    previewImageUrl: "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&q=80",
    template: "A massive, ultra-legible billboard (baliho) design for {{topic}}. Core message: {{description}}. Massive elements: {{keyPoints}}. Bold, high-contrast style: {{style}}. Colors: neon/solid {{colorPalette}} for outdoor visibility. Lighting: bright {{lighting}}. Mood: impactful, {{mood}}. Format: extreme landscape {{layout}} ({{aspectRatio}}). Huge text: {{textRule}}. No: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "baliho",
    previewImageUrl: "https://images.unsplash.com/photo-1520607162513-77708c026b43?w=500&q=80",
    template: "A political or campaign style billboard for {{topic}}. Figure/Subject: {{description}}. Promises/Slogans: {{keyPoints}}. Formal, authoritative style: {{style}}. Colors: patriotic/brand {{colorPalette}}. Lighting: studio portrait {{lighting}}. Angle: heroic low angle {{cameraAngle}}. Mood: inspiring, {{mood}}. Layout: {{layout}} ({{aspectRatio}}). Avoid: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "baliho",
    previewImageUrl: "https://images.unsplash.com/photo-1580130281320-0ef0754f2bf7?w=500&q=80",
    template: "An architectural / real-estate mega billboard promoting {{topic}}. Property details: {{description}}. Luxury points: {{keyPoints}}. Elegant architectural render style: {{style}}. Palette: gold and {{colorPalette}}. Lighting: sunset/twilight {{lighting}}. Mood: luxurious, {{mood}}. Composition: expansive {{layout}} ({{aspectRatio}}). Text: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },

  // LOGO (3)
  {
    category: "logo",
    previewImageUrl: "https://images.unsplash.com/photo-1626785776573-4b799315345d?w=500&q=80",
    template: "A minimalist vector logo design for a brand named {{topic}}. Industry: {{description}}. Key symbols: {{keyPoints}}. Flat, clean style: {{style}}, simple vector art, white background. Color palette: {{colorPalette}}. Lighting: flat vector. Mood: professional, {{mood}}. Aspect ratio: 1:1, Layout: central isolated icon {{layout}}. Text: {{textRule}}. Do not include: {{negativePrompt}}, realistic shadows, 3D.",
    isActive: true,
  },
  {
    category: "logo",
    previewImageUrl: "https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?w=500&q=80",
    template: "An esports/gaming mascot logo featuring {{topic}}. Aggressive vibe: {{description}}. Elements: {{keyPoints}}. Thick lines, vector illustration style: {{style}}. Colors: high contrast {{colorPalette}}. Lighting: dynamic vector shading. Mood: fierce, {{mood}}. Composition: shield or badge background {{layout}}, ratio: 1:1. Text: {{textRule}}. Negative: {{negativePrompt}}, photorealistic.",
    isActive: true,
  },
  {
    category: "logo",
    previewImageUrl: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&q=80",
    template: "A luxury monogram / emblem logo for {{topic}}. Heritage details: {{description}}. Core motifs: {{keyPoints}}. Elegant, serif or metallic style: {{style}}. Colors: gold, silver, and {{colorPalette}}. Lighting: subtle metallic reflection. Mood: exclusive, {{mood}}. Layout: symmetric {{layout}}, ratio: 1:1. Text: {{textRule}}. Negative: {{negativePrompt}}, childish, cartoon.",
    isActive: true,
  },

  // QUOTES (3)
  {
    category: "quotes",
    previewImageUrl: "https://images.unsplash.com/photo-1555626906-fcf10d6851b4?w=500&q=80",
    template: "An inspirational quote aesthetic background featuring {{topic}}. Atmosphere: {{description}}. Elements: {{keyPoints}}. Cinematic, moody photography style: {{style}}. Colors: muted {{colorPalette}}. Lighting: dramatic {{lighting}}. Mood: deep, {{mood}}. Layout: negative space for text {{layout}}, ratio: {{aspectRatio}}. Typography rule: {{textRule}}. Avoid: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "quotes",
    previewImageUrl: "https://images.unsplash.com/photo-1490730141103-6cac27aaab94?w=500&q=80",
    template: "A bright, cheerful daily motivation background about {{topic}}. Setting: {{description}}. Objects: {{keyPoints}}. Clean, sunny lifestyle style: {{style}}. Palette: pastel {{colorPalette}}. Lighting: natural morning sunlight {{lighting}}. Mood: positive, {{mood}}. Layout: balanced {{layout}} ({{aspectRatio}}). Quote text: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "quotes",
    previewImageUrl: "https://images.unsplash.com/photo-1534796636912-3652891398bb?w=500&q=80",
    template: "A stoic, dark and gritty philosophical background for a quote about {{topic}}. Visual metaphor: {{description}}. Subject: {{keyPoints}}. Dark fantasy or historical style: {{style}}. Colors: monochrome or {{colorPalette}}. Lighting: chiaroscuro {{lighting}}. Mood: serious, {{mood}}. Composition: central focus {{layout}} ({{aspectRatio}}). Text positioning: {{textRule}}. Negative: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "video",
    previewImageUrl: "https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=500&q=80",
    template: "A high-retention vertical story video for {{topic}}. Detailed video outline: {{description}}, emphasizing highlights: {{keyPoints}}. Visual storytelling: {{style}} style with {{colorPalette}} tone. Camera pathing: {{cameraMovement}} per segment. Vibe: {{mood}}. Exclude: {{negativePrompt}}.",
    isActive: true,
  },
  {
    category: "video",
    previewImageUrl: "https://images.unsplash.com/photo-1461151304267-38535e780c79?w=500&q=80",
    template: "A cinematic promotional showcase video of product/brand {{topic}}. Description: {{description}}. Key features: {{keyPoints}}. Styling: {{style}} aesthetic. Dynamic motion direction: {{cameraMovement}}. Color palette: {{colorPalette}}.",
    isActive: true,
  }
];

async function seedTemplates() {
  console.log("Menghapus data template lama...");
  await db.delete(promptTemplates);

  console.log("Menyemai 30 Template PRO baru...");
  const mapped = templates.map(t => ({
    id: ulid(),
    category: t.category,
    previewImageUrl: t.previewImageUrl,
    template: t.template,
    isActive: t.isActive,
    createdAt: new Date(),
    updatedAt: new Date(),
  }));

  // Insert in batches of 10 to avoid any query size limits just in case
  for (let i = 0; i < mapped.length; i += 10) {
    const batch = mapped.slice(i, i + 10);
    await db.insert(promptTemplates).values(batch);
  }

  console.log(`Berhasil menyemai ${mapped.length} templates!`);
  process.exit(0);
}

seedTemplates().catch((e) => {
  console.error("Error seeding templates:", e);
  process.exit(1);
});
