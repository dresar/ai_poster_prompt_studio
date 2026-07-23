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
    `- Slide Render Directive: Render Slide ${slide.slideNumber} as a single final high-resolution fullscreen artwork with strong visual clarity and storytelling impact`,
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

export function compileEdukasiMasterPrompt(
  payload: Payload,
  fullFormState: any,
  styleTemplate?: string,
  characterFocusPrompt?: string,
  dropdownSpecs?: string,
  watermarkInstruction?: string
): string {
  validateAndHealPayload(payload);
  const slides = payload.slidesContent || [];
  const slidesCount = slides.length || fullFormState.slideCount || 5;
  const topic = fullFormState.topic || payload.contentPayload?.topic || "Edukasi";

  const masterPromptObj = {
    judul_project: `${topic} - Carousel Edukasi ${slidesCount} Slide`,
    instruksi_cara_kerja_ai: `PERINTAH UTAMA — BACA DAN INGAT SELAMA SESI INI BERLANGSUNG:\nIni adalah satu paket prompt master untuk membuat ${slidesCount} gambar carousel edukasi secara berurutan. JANGAN generate semua ${slidesCount} gambar sekaligus. Ikuti alur kerja berikut:\n\n1. KONFIRMASI: Setelah membaca prompt ini, berikan rangkuman singkat bahwa kamu paham aturan global, gaya visual, dan daftar ${slidesCount} slide, lalu TUNGGU perintah 'lanjut'.\n2. EKSEKUSI PER SLIDE: Setiap user mengetik 'lanjut' atau 'next', generate SATU gambar untuk slide berikutnya sesuai urutan.\n3. KONSISTENSI KARAKTER & VISUAL (FITUR WAJIB): Simpan metadata visual (warna dominan, ciri fisik karakter, pakaian, jenis lighting, environment/background) di ingatanmu. Gunakan seed atau deskripsi referensi yang identik di setiap prompt gambar selanjutnya untuk mempertahankan konsistensi identitas.\n4. VARIASI ANGLE & KOMPOSISI: Selalu bandingkan rencana komposisi slide baru dengan slide sebelumnya. Variasikan angle kamera (close-up, medium shot, wide shot, top-down) dan posisi objek utama agar tidak repetitif, NAMUN tetap 100% patuh pada 'gaya_visual_global'.\n5. KONSISTENSI UI/OVERLAY: Pastikan elemen UI seperti nomor slide, CTA follow, dan footer diletakkan pada posisi pixel yang identik di setiap gambar.\n6. ATURAN LATAR/BACKGROUND: WAJIB gunakan latar belakang dengan nuansa Putih Bersih di seluruh slide.\n7. PROGRESS TRACKING: Jika ditanya 'sudah sampai mana', berikan laporan progres dari total ${slidesCount} slide.`,
    aturan_global: {
      platform_target: "Instagram Carousel Post",
      peran: "Kamu adalah Senior Graphic Designer & Art Director yang mengetahui kombinasi warna, tipografi, dan estetika visual premium.",
      target_audiens: payload.contentPayload?.targetAudience || fullFormState.targetAudience || "Pelajar & Mahasiswa",
      level_kesulitan_konten: "Pemula total, asumsikan audiens belum pernah lihat materi ini sebelumnya. Gunakan analogi sehari-hari dan jangan terlalu teknis.",
      jenis_konten: "Edukasi Instagram",
      catatan_render_kode: "TIDAK BOLEH generate teks sintaks kode presisi (<p>, <a>, dll) sebagai teks asli dalam gambar. AI cukup membuat ilustrasi visual yang menyerupai blok kode dengan syntax highlighting (tanpa teks presisi) untuk diedit manual nantinya.",
      bahasa_teks_overlay: "Non-formal, santai, dan asik. Bicara seperti kakak/teman yang berbagi ilmu, BUKAN seperti buku pelajaran atau artikel jurnal.",
      prinsip_visual_vs_caption: "GAMBAR = POIN INTI & VISUAL ARTWORK DOMINAN. CAPTION = PENJELASAN LENGKAP & MENDALAM. DILARANG KERAS menjejalkan teks panjang di dalam gambar carousel!",
      batas_karakter_ideal_per_slide: {
        headline: "30–60 karakter (singkat, padat, punchy)",
        subheadline: "40–80 karakter",
        isi_utama_detail: "250–500 karakter total per slide",
        bullet_point: "3–5 poin (tiap bullet 20–50 karakter)",
        total_karakter_satu_slide: "350–700 karakter (maksimal 40–70 kata per slide agar nyaman dibaca di layar HP)",
        hook_slide_1_cover: "300–500 karakter (Headline memikat + subtext ringkas)",
        slide_isi_2_sampai_5: "400–700 karakter per slide",
        slide_penutup_cta: "250–500 karakter"
      },
      batas_teks: "Maksimal 350-700 karakter (sekitar 40-70 kata) total per slide. Ringkas, padat, cepat dibaca di layar HP.",
      satu_poin_per_slide: "Satu slide = satu insight/tips/fakta yang disampaikan jelas dan mudah dicerna.",
      terminologi_wajib_diselipkan: [
        "fakta menarik",
        "tahukah kamu",
        "tips praktis",
        "jangan sampai salah",
        "insight penting",
        "studi menunjukkan",
        "cara mudah",
        "langkah simpel",
        "bukti nyata",
        "ternyata begini",
        "coba deh",
        "bisa langsung dipraktekin"
      ],
      larangan: "DILARANG KERAS menyebut harga, diskon, promo produk, atau jualan apapun dalam konten edukasi ini.",
      call_to_action_variatif: fullFormState.callToAction || fullFormState.cta || 'Selain save/share/follow, variasikan ajakan: misal ajak komentar ("Tag temanmu"), atau praktik agar lebih interaktif.'
    },
    gaya_visual_global: {
      gaya_visual_wajib: styleTemplate || payload.visualBlueprint?.coreVisualStyle || "Create a premium minimalist branding presentation background...",
      gaya_dominan: `${fullFormState.style || 'Minimalist visual style'} dengan perpaduan elemen profesional.`,
      rasio_komposisi: "70% area ilustrasi/kode visual, 30% area teks (whitespace luas) agar AI tidak menginterpretasi bebas proporsi tiap slide.",
      tata_letak_hierarki: payload.designSystem?.gridStructure || "Struktur grid yang rapi, rapi, dan teratur. Whitespace luas, margin seimbang, penataan informasi yang efisien.",
      elemen_pendukung: "Garis tipis pembatas, ikon pendukung minimalis, elemen visual yang sesuai dengan gaya visual utama.",
      gaya_ikon_konsisten: "Flat line icon, duotone, stroke 2px, sudut membulat. Konsisten satu sistem di seluruh slide.",
      palet_warna: {
        dasar_netral: [
          dropdownSpecs || payload.designSystem?.colorPalette || "Deep Navy Blue (#0F2D52), Charcoal Gray (#4B5563), Off-White (#FAFAFA), Putih Bersih"
        ],
        aksen: [
          "Steel Blue (#3B82F6)",
          "Subtle Silver (#E5E7EB)"
        ]
      },
      tipografi: "Sans-serif premium. Headline bold ukuran besar, subtext/detail teks rapi dan teratur dengan kontras tinggi.",
      tipografi_kode: "Font khusus untuk elemen menyerupai kode program: Fira Code / JetBrains Mono, monospace, dengan warna syntax-highlight (keyword biru, string hijau, tag oranye).",
      variasi_wajib_per_slide: "Harus memiliki variasi angle kamera, rotasi posisi ilustrasi (kiri/kanan), dan variasi warna aksen dominan per slide untuk menghindari kebosanan.",
      referensi_visual_brand: "Desain harus memiliki identitas visual \"Series Edukasi\" yang ajeg, sehingga konten-konten lain selanjutnya memiliki benang merah yang sama.",
      pencahayaan_kamera: "Clean studio lighting, pencahayaan merata dan netral, sudut kamera lurus (eye-level) atau top-down datar.",
      kedalaman_visual: "Layering berlapis tipis, margin bersih, bayangan drop-shadow yang sangat halus.",
      dimensi_canvas: `Canvas 1080x1440px, Aspect Ratio ${fullFormState.aspectRatio || '3:4'} (--ar ${fullFormState.aspectRatio || '3:4'})`,
      negative_prompt: payload.renderingBlueprint?.negativePrompt || "watermark, blur, teks berantakan, kualitas buruk, anatomi aneh, font aneh, terlalu ramai"
    },
    layout_media_sosial_global: {
      pojok_kiri_atas: `ATURAN WAJIB NOMOR SLIDE: Pada SLIDE 1 (COVER/HOOK), DILARANG KERAS MENAMPILKAN NOMOR SLIDE APA PUN ('1/${slidesCount}', '1/5', dsb). Area pojok kiri atas pada Slide 1 WAJIB KOSONG BERSIH. Nomor slide BARU WAJIB DITAMPILKAN MULAI SLIDE 2 DENGAN FORMAT '2/${slidesCount}', '3/${slidesCount}', dst. hingga '${slidesCount}/${slidesCount}'.`,
      pojok_kanan_atas: "Overlay warna konsisten berisi teks ajakan follow: 'Jangan lupa follow!'.",
      tengah_atas_footer: "Ikon atau teks navigasi swipe ('Swipe right' / panah kanan) untuk ajak audiens geser slide.",
      footer_bawah: watermarkInstruction || "Terpusat, minimalis, tanpa label teks pengantar (ikon langsung diikuti teks)"
    },
    daftar_slide: slides.map((slide: any, idx: number) => {
      const num = slide.slideNumber || (idx + 1);
      let role = `POIN EDUKASI #${num - 1}`;
      let urutan = `Step ${num} dari ${slidesCount}: Penjelasan Materi (Tampilkan Overlay Nomor Slide '${num}/${slidesCount}' di Pojok Kiri Atas)`;
      let overlayNomorSlide = `Pojok Kiri Atas: Tampilkan overlay badge nomor slide '${num}/${slidesCount}'.`;

      if (num === 1) {
        role = "HOOK & COVER EDUKASI (Slide Pembuka)";
        urutan = `Step 1 dari ${slidesCount}: Pengenalan & Hook (COVER - ATURAN KETAT: DILARANG MENAMPILKAN NOMOR SLIDE '1/${slidesCount}')`;
        overlayNomorSlide = `Pojok Kiri Atas: WAJIB KOSONG BERSIH TANPA NOMOR SLIDE APA PUN (DILARANG KERAS MENULIS '1/${slidesCount}' ATAU NOMOR SLIDE PADA SLIDE 1 COVER)!`;
      } else if (num === slidesCount) {
        role = "PENUTUP & AJAK INTERAKSI (Slide Terakhir)";
        urutan = `Step ${slidesCount} dari ${slidesCount}: Kesimpulan & CTA (Tampilkan Overlay Nomor Slide '${slidesCount}/${slidesCount}' di Pojok Kiri Atas)`;
      }

      let visualObj = slide.subject || '';
      if (slide.sceneDescription) {
        visualObj += visualObj ? `, ${slide.sceneDescription}` : slide.sceneDescription;
      }
      if (characterFocusPrompt) {
        visualObj += ` [Visual Character Consistency: ${characterFocusPrompt}]`;
      }

      return {
        slideNumber: num,
        role,
        urutan_alur_belajar: urutan,
        aturan_overlay_nomor_slide: overlayNomorSlide,
        objek_visual: visualObj,
        teks_dalam_gambar: {
          headline: slide.headline || "",
          subtext: slide.description || "",
          detail: (slide.keyPoints && slide.keyPoints.length > 0) ? slide.keyPoints.join('. ') : (slide.educationalObjective || ""),
          microTip: (slide.calloutSuggestions && slide.calloutSuggestions.length > 0) ? slide.calloutSuggestions[0] : ""
        }
      };
    })
  };

  return JSON.stringify(masterPromptObj, null, 2);
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

