import { Payload, VideoPayload } from './payload.schema';

function renderObject(obj: Record<string, any>, indent: string = '    '): string {
  let result = '';
  for (const [key, value] of Object.entries(obj)) {
    const dslKey = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`).toUpperCase();
    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      result += `${indent}${dslKey}\n${renderObject(value, indent + '    ')}`;
    } else if (Array.isArray(value)) {
      result += `${indent}${dslKey} = [${value.join(', ')}]\n`;
    } else {
      result += `${indent}${dslKey} = ${value}\n`;
    }
  }
  return result;
}

export function renderDSL(payload: Payload): string {
  let dsl = '';

  const sections = [
    { key: 'SYSTEM_INIT', data: payload.systemInit },
    { key: 'RULE_ENGINE', data: payload.ruleEngine },
    { key: 'CONTENT_SYSTEM', data: payload.contentPayload },
    { key: 'VISUAL_DESIGN_SYSTEM', data: payload.designSystem },
    { key: 'VISUAL_BLUEPRINT', data: payload.visualBlueprint },
    { key: 'RENDERING_BLUEPRINT', data: payload.renderingBlueprint },
    { key: 'BRANDING_ENGINE', data: payload.brandingEngine },
  ];

  for (const section of sections) {
    if (section.data) {
      dsl += `${section.key}\n${renderObject(section.data)}\n`;
    }
  }

  if (payload.slidesContent) {
    dsl += `SLIDES_CONTENT\n`;
    for (const slide of payload.slidesContent) {
      dsl += `    SLIDE_${slide.slideNumber}\n`;
      dsl += `        SLIDE_NUMBER = ${slide.slideNumber}\n`;
      dsl += `        HEADLINE = ${slide.headline}\n`;
      dsl += `        DESCRIPTION = ${slide.description}\n`;
      if (slide.subject) dsl += `        SUBJECT = ${slide.subject}\n`;
      if (slide.sceneDescription) dsl += `        SCENE_DESCRIPTION = ${slide.sceneDescription}\n`;
      if (slide.visualEmphasis) dsl += `        VISUAL_EMPHASIS = ${slide.visualEmphasis}\n`;
    }
    dsl += '\n';
  }

  dsl += 'END_CONFIGURATION';

  return dsl;
}

/**
 * Validation Engine & Auto-Repair:
 * Memeriksa kelengkapan data, konsistensi spacing, layout, warna, dan typo hierarchy.
 * Melakukan perbaikan otomatis (auto-repair) apabila ditemukan parameter kosong.
 */
function validateAndHealPayload(payload: Payload): void {
  if (!payload.designSystem) {
    payload.designSystem = {
      gridStructure: "Strict professional asymmetric Swiss column-grid layout",
      whitespaceRatio: "Minimum 40% empty negative space used as a compositional element",
      colorPalette: "Clean minimalist HSL tailored color scheme",
      typographyHierarchy: "Strict typography scale: Bold heading, clean medium body copy, small minimal footer"
    };
  }

  if (!payload.designSystem.gridStructure) {
    payload.designSystem.gridStructure = "Strict asymmetric grid with modular typographic alignments";
  }

  if (!payload.designSystem.whitespaceRatio) {
    payload.designSystem.whitespaceRatio = "Minimum 45% white space to maximize visual breathing room";
  }

  if (!payload.designSystem.colorPalette || payload.designSystem.colorPalette.trim().length < 5) {
    payload.designSystem.colorPalette = "Curated harmonized colors (60% dominant background tone, 30% supporting neutral, 10% active visual accent)";
  }

  if (!payload.designSystem.typographyHierarchy) {
    payload.designSystem.typographyHierarchy = "Editorial typographic scale using geometric sans-serif fonts";
  }

  if (!payload.visualBlueprint) {
    payload.visualBlueprint = {
      coreVisualStyle: "Minimalist graphic design poster style",
      compositionRules: "Focal point hierarchy, rule of thirds, clean geometric shapes",
      illustrationIconography: "Clean vector iconography and line art illustration style"
    };
  }

  if (!payload.renderingBlueprint) {
    payload.renderingBlueprint = {
      renderStyle: "Professional vector/graphic rendering style",
      qualityParameters: "Sharp details, crisp text, high resolution render, no artifacts",
      negativePrompt: "blurry, low-resolution, generic, cartoonish outlines, chaotic overlapping elements, collage, split screens"
    };
  }

  if (!payload.renderingBlueprint.negativePrompt || payload.renderingBlueprint.negativePrompt.trim().length < 10) {
    payload.renderingBlueprint.negativePrompt = "blurry layout, low quality, bad text rendering, overlapping boxes, split screens, collage frames, multi-image preview";
  }

  if (!payload.brandingEngine) {
    payload.brandingEngine = {
      logoPlacement: "DILARANG KERAS menggambar logo kecuali diminta secara eksplisit.",
      watermarkFooter: "DILARANG KERAS menggambar watermark teks kecuali diminta secara eksplisit."
    };
  }
}

/**
 * Prompt Enrichment Engine:
 * Secara otomatis memperkaya informasi sederhana menjadi deskripsi visual profesional.
 * Melakukan ekspansi subject, scene, camera, lighting, material, dan texture secara deterministic.
 */
function enrichSlidePrompt(
  slide: any,
  payload: Payload,
  characterFocusPrompt?: string
): string {
  const subjectStr = slide.subject || "central visual focal point metaphor";
  const sceneStr = slide.sceneDescription || "clean minimalist environment with stark contrast";
  const emphasisStr = slide.visualEmphasis || "high contrast, sharp focus, clean layout hierarchy";

  // Penentuan lighting dan camera secara deterministic berdasarkan gaya visual poster/grafis
  const lighting = "soft diffused studio lighting, casting delicate soft shadows, highlighting geometric form, no harsh reflections";
  const camera = "flat graphic front-facing perspective, orthographic camera angle, clean eye-level view, 0-degree tilt";
  const materials = "premium matte paper texture, smooth vector lines, flat color fills, clean non-reflective surfaces";

  const parts = [
    `- Communication Goal: Render Slide ${slide.slideNumber} with strong visual clarity and storytelling`,
    `- Visual Style: ${payload.visualBlueprint.coreVisualStyle}`,
    `- Layout & Grid: ${payload.designSystem.gridStructure} utilizing ${payload.designSystem.whitespaceRatio}`,
    `- Main Subject: ${subjectStr}`,
    characterFocusPrompt ? `- Subject Consistency: ${characterFocusPrompt.trim()}` : '',
    `- Environment Background: ${sceneStr}`,
    `- Camera Angle & Perspective: ${camera}`,
    `- Lighting Setup: ${lighting}`,
    `- Materials & Textures: ${materials}`,
    `- Typography Rule: Headline text "${slide.headline}" set in large bold typeface, body copy text "${slide.description}" set in clean medium typeface`,
    slide.communicationGoal ? `- Communication Goal: ${slide.communicationGoal}` : '',
    slide.educationalObjective ? `- Educational Objective: ${slide.educationalObjective}` : '',
    (slide.keyPoints && slide.keyPoints.length > 0) ? `- Key Points: ${slide.keyPoints.join(', ')}` : '',
    (slide.supportingFacts && slide.supportingFacts.length > 0) ? `- Supporting Facts: ${slide.supportingFacts.join(', ')}` : '',
    (slide.calloutSuggestions && slide.calloutSuggestions.length > 0) ? `- Visual Callout Suggestion: ${slide.calloutSuggestions.join(', ')}` : '',
    slide.storytellingSequence ? `- Storytelling Sequence Position: ${slide.storytellingSequence}` : '',
    `- Composition & Focal Balance: Aligned to composition rule "${payload.visualBlueprint.compositionRules}" with focus on "${emphasisStr}"`
  ];

  return parts.filter(Boolean).join('\n');
}

/**
 * Prompt Optimizer:
 * Menghapus kalimat berulang, menyaring instruksi semantik yang sama,
 * dan mengurutkan prioritas visual sesuai cara kerja AI Image Generator.
 */
function optimizeFinalPrompt(prompt: string, targetModel: string): string {
  const lines = prompt.split('\n');
  const uniqueLines: string[] = [];
  const seenNorms = new Set<string>();

  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed === '') {
      uniqueLines.push('');
      continue;
    }

    // Normalisasi untuk mendeteksi baris dengan makna semantik serupa
    const normalized = trimmed.toLowerCase()
      .replace(/[^a-z0-9]/g, '')
      .substring(0, 40); // ambil 40 karakter pertama untuk perbandingan kemiripan

    if (!seenNorms.has(normalized)) {
      seenNorms.add(normalized);
      uniqueLines.push(line);
    }
  }

  let optimized = uniqueLines.join('\n').trim();

  // Model-Aware Prompt Rendering
  const model = targetModel.toLowerCase();
  if (model.includes('midjourney')) {
    // Midjourney menyukai format deskriptif koma dengan parameter di akhir
    optimized = optimized
      .replace(/\[VISUAL STYLE & CONFIGURATION BLUEPRINT\]/gi, '')
      .replace(/\[ACTIVE CONTENT LAYERS\]/gi, '')
      .replace(/\[NEGATIVE FILTERS\]/gi, '')
      .replace(/\[IMAGE STRUCTURE DIRECTIVE\]/gi, '')
      .replace(/\n+/g, ', ')
      .replace(/\s+/g, ' ')
      .replace(/,\s*,/g, ',')
      .trim();

    // Pastikan tidak ada tag negatif bawaan, ganti dengan format --no Midjourney jika diperlukan
    const noMatch = optimized.match(/Avoid:\s*([^,\.]+)/i);
    if (noMatch && noMatch[1]) {
      optimized = optimized.replace(/Avoid:\s*([^,\.]+)/gi, '');
      optimized += ` --no ${noMatch[1].trim()}`;
    }
    
    if (!optimized.includes('--ar')) {
      optimized += ' --ar 16:9';
    }
    if (!optimized.includes('--v')) {
      optimized += ' --v 6.0 --style raw';
    }
  } else if (model.includes('flux') || model.includes('recraft') || model.includes('imagen')) {
    // Flux / Recraft / Imagen menyukai deskripsi natural kontinu
    optimized = optimized
      .replace(/\[[^\]]+\]/g, '') // hapus semua header bracket
      .replace(/\n+/g, '. ')      // pisahkan dengan titik menjadi paragraf mengalir
      .replace(/\s+/g, ' ')
      .replace(/\.+\s*\./g, '.')
      .trim();
  }

  return optimized;
}

/**
 * Kompilasi prompt akhir secara deterministik, modular, dan Model-Aware.
 * Merakit data slide aktif menggunakan Prompt Enrichment Engine,
 * lalu dioptimalkan oleh Prompt Optimizer untuk generator target.
 */
export function compileFinalPrompt(
  payload: Payload,
  activeSlideIndex: number,
  styleTemplate?: string,
  characterFocusPrompt?: string,
  dropdownSpecs?: string,
  targetModel: string = 'flux' // Default model-aware targeting
): string {
  // 1. Jalankan Validation & Auto-Repair Engine
  validateAndHealPayload(payload);

  const slides = payload.slidesContent || [];
  const slide = slides.find(s => s.slideNumber === activeSlideIndex) || (slides.length > 0 ? slides[0] : null);
  if (!slide) return '';

  // 2. Jalankan Prompt Enrichment Engine untuk slide aktif
  const slideContentEnriched = enrichSlidePrompt(slide, payload, characterFocusPrompt);

  // 3. Gabungkan Style, Specs, dan Branding
  const styles = [
    styleTemplate ? `[VISUAL STYLE BASE]: ${styleTemplate.trim()}` : '',
    `[VISUAL STYLE METAPHOR]: ${payload.visualBlueprint.coreVisualStyle}`,
    `[ILLUSTRATION DESIGN]: ${payload.visualBlueprint.illustrationIconography}`
  ].filter(Boolean).join('\n');

  const designSpecs = [
    `[GRID SYSTEM]: ${payload.designSystem.gridStructure}`,
    `[WHITESPACE STRATEGY]: ${payload.designSystem.whitespaceRatio}`,
    `[COLOR SYSTEM HARMONY]: ${payload.designSystem.colorPalette}`,
    `[TYPOGRAPHY HIERARCHY]: ${payload.designSystem.typographyHierarchy}`,
    dropdownSpecs ? `[DB LAYOUT RULES]: ${dropdownSpecs.trim()}` : ''
  ].filter(Boolean).join('\n');

  const branding = [
    payload.brandingEngine.logoPlacement ? `[LOGO REQUIREMENT]: ${payload.brandingEngine.logoPlacement}` : '',
    payload.brandingEngine.watermarkFooter ? `[WATERMARK REQUIREMENT]: ${payload.brandingEngine.watermarkFooter}` : ''
  ].filter(Boolean).join('\n');

  const negative = `[NEGATIVE RULES]\nAvoid: ${payload.renderingBlueprint.negativePrompt}`;

  // 4. Asosiasikan dengan ACTIVE_SLIDE_RENDERER untuk fokus tunggal
  const activeRendererDirective = `[ACTIVE_SLIDE_RENDERER]
Render target: SLIDE_${activeSlideIndex} ONLY.
DILARANG KERAS membuat multi-panel, kolase, preview banyak halaman, moodboard, style guide, atau template portfolio.
Render slide ini sebagai satu artwork final beresolusi tinggi, fullscreen tunggal.`;

  const promptParts = [
    `[VISUAL STYLE & CONFIGURATION BLUEPRINT]`,
    styles,
    designSpecs,
    `\n[RENDERING BLUEPRINT]`,
    `Quality Parameters: ${payload.renderingBlueprint.qualityParameters}`,
    branding,
    `\n[ACTIVE CONTENT LAYERS]`,
    slideContentEnriched,
    `\n${activeRendererDirective}`,
    `\n${negative}`,
    `\n[IMAGE STRUCTURE DIRECTIVE]`,
    `Single fullscreen image, strictly one frame, no split screen, no grid, no collage, no multiple pages.`
  ];

  // 5. Jalankan Prompt Optimizer & Model-Aware Rendering
  const finalCompiledPrompt = promptParts.join('\n').trim();
  return optimizeFinalPrompt(finalCompiledPrompt, targetModel);
}

export function renderVideoDSL(payload: VideoPayload): string {
  let dsl = '';

  const sections = [
    { key: 'SYSTEM_INIT', data: payload.systemInit },
    { key: 'RULE_ENGINE', data: payload.ruleEngine },
    { key: 'CONTENT_SYSTEM', data: payload.contentPayload },
    { key: 'VIDEO_STYLE_SYSTEM', data: payload.videoStyle },
    { key: 'RENDERING_BLUEPRINT', data: payload.renderingBlueprint },
    { key: 'BRANDING_ENGINE', data: payload.brandingEngine },
  ];

  for (const section of sections) {
    if (section.data) {
      dsl += `${section.key}\n${renderObject(section.data)}\n`;
    }
  }

  if (payload.segmentsContent) {
    dsl += `SEGMENTS_CONTENT\n`;
    for (const seg of payload.segmentsContent) {
      dsl += `    SEGMENT_${seg.segmentNumber}\n`;
      dsl += `        SEGMENT_NUMBER = ${seg.segmentNumber}\n`;
      dsl += `        TIMESTAMP = "${seg.timestamp}"\n`;
      if (seg.headline) dsl += `        HEADLINE = "${seg.headline}"\n`;
      if (seg.description) dsl += `        DESCRIPTION = "${seg.description}"\n`;
      dsl += `        VISUAL_PROMPT = "${seg.visualPrompt}"\n`;
      dsl += `        MOTION_PROMPT = "${seg.motionPrompt}"\n`;
      dsl += `        TRANSITION_PROMPT = "${seg.transitionPrompt}"\n`;
      if (seg.textOverlay) dsl += `        TEXT_OVERLAY = "${seg.textOverlay}"\n`;
      if (seg.audioSuggestion) dsl += `        AUDIO_SUGGESTION = "${seg.audioSuggestion}"\n`;
    }
    dsl += '\n';
  }

  dsl += 'END_CONFIGURATION';

  return dsl;
}

export function compileFinalVideoPrompt(
  payload: VideoPayload,
  activeSegmentNumber: number,
  styleTemplate?: string,
  characterFocusPrompt?: string,
  dropdownSpecs?: string,
  targetModel: string = 'veo'
): string {
  const segments = payload.segmentsContent || [];
  const segment = segments.find(s => s.segmentNumber === activeSegmentNumber) || (segments.length > 0 ? segments[0] : null);
  if (!segment) return '';

  const visualStyle = styleTemplate || payload.videoStyle?.coreVisualStyle || 'cinematic portrait style';
  const colorPalette = payload.videoStyle?.colorPalette || 'natural cinematic colors';
  const cameraMovement = payload.videoStyle?.cameraMovementStyle || 'smooth tracking shot';
  
  const visualPrompt = segment.visualPrompt || '';
  const motionPrompt = segment.motionPrompt || '';
  const transitionPrompt = segment.transitionPrompt || '';
  const negative = payload.renderingBlueprint?.negativePrompt || '';

  // Combine elements in a descriptive way suitable for video generation (Luma, Veo, Runway, etc.)
  const promptParts = [
    `[SCENE CONTENT]: ${visualPrompt}`,
    characterFocusPrompt ? `[SUBJECT CONSISTENCY]: ${characterFocusPrompt}` : '',
    `[MOTION PATH]: ${motionPrompt}. Camera movement style: ${cameraMovement}`,
    `[VISUAL STYLE & ENVIRONMENT]: ${visualStyle} look. Color theme: ${colorPalette}`,
    `[TRANSITION DIRECTIVE]: ${transitionPrompt}`,
    `[QUALITY BLUEPRINT]: ${payload.renderingBlueprint?.renderStyle || 'High fidelity video'}, ${payload.renderingBlueprint?.qualityParameters || 'ultra-sharp details, high resolution'}`,
    `[NEGATIVE FILTERS]: Avoid: ${negative}`
  ];

  const rawPrompt = promptParts.filter(Boolean).join('\n');
  return rawPrompt;
}

