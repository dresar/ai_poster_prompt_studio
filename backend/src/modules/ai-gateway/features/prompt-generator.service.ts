import { SchemaType, Schema } from '@google/generative-ai';
import { GeminiClient } from '../core/gemini-client';
import { GroqClient } from '../core/groq-client';
import { env } from '../../../config/env';
import { logger } from '../../../config/logger';
import { ImageAnalyzerService } from './image-analyzer.service';
import { compileFinalPrompt, compileFinalVideoPrompt, compileEdukasiMasterPrompt } from '../../poster/dslRenderer';

export class PromptGeneratorService {
  constructor(
    private geminiClient: GeminiClient,
    private imageAnalyzer: ImageAnalyzerService
  ) {}

  private buildPromptVariables(fullFormState: any) {
    const slideCount = fullFormState.slideCount || 1;
    const useManualLogo = fullFormState.useManualLogo === true;
    const watermarkText = (fullFormState.watermark || '').trim();

    const brandingInstruction = useManualLogo
      ? 'Gambarkan logo minimalis bulat kecil di sudut kiri atas.'
      : 'DILARANG KERAS memvisualisasikan, menggambarkan, atau menyisipkan logo/placeholder logo di manapun pada gambar.';

    const watermarkInstruction = watermarkText
      ? `Tuliskan watermark teks "${watermarkText}" secara bersih dan minimalis di bagian footer gambar.`
      : 'DILARANG KERAS menggambarkan atau menyebutkan teks watermark, username, hashtag, atau teks footer di manapun pada gambar.';

    return { slideCount, brandingInstruction, watermarkInstruction };
  }

  // Helper to deeply convert UPPER_CASE/snake_case keys from AI prompt to camelCase
  private deepCamelizeKeys(obj: any): any {
    if (Array.isArray(obj)) {
      return obj.map(v => this.deepCamelizeKeys(v));
    } else if (obj !== null && typeof obj === 'object') {
      return Object.keys(obj).reduce((result, key) => {
        let camelKey = key;
        if (key.includes('_') || key === key.toUpperCase()) {
          camelKey = key.toLowerCase().replace(/_([a-z0-9])/g, (g) => g[1].toUpperCase());
        }
        result[camelKey] = this.deepCamelizeKeys(obj[key]);
        return result;
      }, {} as any);
    }
    return obj;
  }

  /**
   * Content Intelligence Engine:
   * Menentukan strategi penyampaian konten berdasarkan slideCount dan jenis media.
   * Mengatur Kepadatan Informasi (Information Density), Alur Baca (Reading Flow),
   * dan Struktur Narasi secara deterministic.
   */
  private buildContentIntelligenceInstructions(fullFormState: any): string {
    const slideCount = Number(fullFormState.slideCount || 1);
    const mediaType = fullFormState.feature || 'poster';

    let strategy = '';
    if (slideCount === 1) {
      strategy = `
[STRATEGI KONTEN: SINGLE POSTER/ARTWORK (HIGH INFORMATION DENSITY)]
- Output adalah satu poster/artwork tunggal. Anda hanya memiliki satu kesempatan menyampaikan materi.
- Kepadatan Informasi (Information Density): Sangat Tinggi (High Density).
- Struktur Informasi: Wajib memuat Hero Headline, Subheadline yang informatif, 2-3 blok informasi penjelas/fakta pendukung, callout/highlight penting, dan alur baca (reading flow) editorial yang rapi.
- Konten dilarang terlalu kosong atau hanya berisi satu gambar besar dengan teks minimalis. Masukkan poin-poin edukasi yang lengkap.
`;
    } else {
      strategy = `
[STRATEGI KONTEN: CAROUSEL STORYTELLING (DISTRIBUTED INFORMATION DENSITY)]
- Output adalah carousel/seri gambar sebanyak ${slideCount} slide.
- Kepadatan Informasi (Information Density): Terdistribusi (Distributed/Lower per slide). Setiap slide harus fokus pada SATU ide utama saja agar nyaman dibaca secara cepat (scanning).
- Alur Cerita (Storytelling Flow):
  * Slide 1 (Hook Slide): Fokus menarik perhatian audiens dengan headline pemantik rasa penasaran, subheadline penggugah, dan visual hero yang dominan. JANGAN merangkum seluruh isi materi di sini.
  * Slide 2 s.d Slide ${slideCount - 1} (Body Slides): Penjelasan materi secara bertahap, runut, dan logis.
  * Slide Terakhir (Slide ${slideCount}): Berfungsi sebagai Rangkuman Kesimpulan atau Call to Action (CTA) yang jelas.
`;
    }

    strategy += `\n[STRATEGI JENIS MEDIA: ${mediaType.toUpperCase()}]\nSesuaikan format penulisan, gaya copywriting, dan pendekatan ilustrasi agar sesuai dengan kaidah media ${mediaType} (edukatif, komunikatif, profesional).`;

    if (fullFormState.characterFocusObj) {
      const charObj = fullFormState.characterFocusObj;
      strategy += `\n\n[ATURAN KARAKTER WAJIB: ${charObj.name}]
- Kamu DILARANG KERAS membuat atau men-generate deskripsi karakter sendiri!
- Kamu WAJIB menggunakan karakter ini sebagai subjek di setiap slide yang membutuhkan karakter.
- Kolom 'subject' pada slide harus berfokus pada NAMA karakter beserta POSE atau AKSI yang spesifik.
- SANGAT PENTING: Karakter HARUS terlihat HIDUP! Buatlah pose, aksi, ekspresi wajah, dan interaksi (misal: memegang barang/equipment) yang BERBEDA-BEDA di setiap slide sesuai konteks ceritanya. Jangan gunakan pose yang monoton atau berulang!
- Dilarang menyebutkan deskripsi warna, fisik, atau pakaian secara mendetail pada subject (karena wujud fisiknya sudah dikunci oleh Database Blueprint). Cukup panggil nama karakter dan posenya saja (contoh: "${charObj.name} sedang berlari kaget memegang laptop" atau "${charObj.name} tersenyum lebar menunjuk ke papan tulis").`;
    } else if (!fullFormState.characterFocus || ['bebas', 'auto', 'random'].includes(fullFormState.characterFocus.toLowerCase())) {
      strategy += `\n\n[ATURAN KARAKTER: BEBAS/AUTO]
- Silakan ciptakan karakter pendukung atau subjek (orang/hewan/benda) yang cocok dengan topik konten ini secara bebas dan kreatif.
- Deskripsikan penampilan fisik, pakaian, ekspresi, dan aksi subjek secara spesifik di kolom 'subject' agar prompt generator visual bisa merender subjek dengan baik.`;
    }

    return strategy;
  }

  /**
   * Programmatically inject visual design blueprints from database sources (Single Source of Truth)
   * into the payload object, replacing any AI generated visual styling configurations.
   */
  private injectDatabaseBlueprints(
    payload: any,
    fullFormState: any,
    styleTemplate: string,
    brandingInstruction: string,
    watermarkInstruction: string
  ): void {
    payload.designSystem = {
      gridStructure: "Strict professional asymmetric Swiss column-grid layout",
      whitespaceRatio: "Minimum 40% empty negative space used as a compositional layout element",
      colorPalette: fullFormState.dropdownSpecs || "Clean minimalist HSL color harmony",
      typographyHierarchy: "Strict typography hierarchy using clear contrast scale (large headings, medium copy)"
    };
    payload.visualBlueprint = {
      coreVisualStyle: styleTemplate || "Minimalist professional graphic artwork style",
      compositionRules: "Hierarchy of scale, strong focal point alignment, geometric cleanliness",
      illustrationIconography: "Clean vector iconography and line art graphics"
    };
    payload.renderingBlueprint = {
      renderStyle: "Crisp vector and high-end digital illustration style",
      qualityParameters: "Ultra sharp rendering, crisp vector path edges, high resolution, zero compression artifacts",
      negativePrompt: "blurry layout, low quality elements, bad text rendering, overlapping boxes, split screens, collage frames, multi-image preview"
    };
    payload.brandingEngine = {
      logoPlacement: brandingInstruction,
      watermarkFooter: watermarkInstruction
    };
  }

  // --- GROQ ---
  async generatePromptGroq(fullFormState: any, previousError?: string): Promise<{ payloadJson: any; promptFinal: string; }> {
    return this.groqClient.executeWithKey(async (apiKey) => {
      const { slideCount, brandingInstruction, watermarkInstruction } = this.buildPromptVariables(fullFormState);
      const contentIntelligence = this.buildContentIntelligenceInstructions(fullFormState);

      const prompt = `Kamu adalah Content Strategist, Art Director & Prompt Compiler Engine profesional.
Tugasmu adalah menganalisis input form user dan menyusun arsitektur data konten poster/carousel yang solid ke dalam format JSON yang bersih dan representatif.
JANGAN membuat atau memasukkan aturan layout, aturan grid, aturan tipografi, aturan warna, lighting, kamera, rendering, atau aturan negatif apa pun. Seluruh hal visual tersebut sudah memiliki Blueprint tersendiri.

Fokuskan tugasmu HANYA pada penyusunan pesan komunikasi, topik utama, copywriting teks slide (headline & description), serta data konten terstruktur pendukung lainnya.

STRATEGI KONTEN DARI CONTENT INTELLIGENCE ENGINE:
${contentIntelligence}

INPUT USER:
${JSON.stringify(fullFormState, null, 2)}

DESAIN SISTEM KONTEN YANG WAJIB DIATUR:
1. System Mission & Content Payload -> Analisis topik, misi pembuatan poster, target audiens, dan pemicu emosi audiens.
2. Slides Content -> TEPAT ${slideCount} slide dengan data terpisah (slideNumber, headline, description, subject, sceneDescription, visualEmphasis, communicationGoal, educationalObjective, keyPoints, supportingFacts, calloutSuggestions, storytellingSequence).
   - JANGAN menulis field 'prompt' di dalam slide. Compiler akan merakit prompt secara otomatis dari data Anda.
   - subject: Deskripsi karakter/subjek utama pada slide ini secara singkat dan jelas.
   - sceneDescription: Deskripsi latar belakang, aksi, dan suasana khusus pada slide ini.
   - visualEmphasis: Elemen fokus utama atau penekanan visual pada slide ini.
   - keyPoints: Array poin penting yang dibahas di slide ini (jika ada).
   - supportingFacts: Array data/fakta pendukung di slide ini (jika ada).
   - calloutSuggestions: Kalimat singkat penjelas/highlight visual.

OUTPUT WAJIB BERUPA SINGLE JSON DENGAN STRUKTUR BERIKUT:
{
  "SYSTEM_INIT": {
    "MISSION": "Deskripsi misi pembuatan materi visual poster/carousel"
  },
  "RULE_ENGINE": {
    "RULE_1": "Aturan konsistensi pesan komunikasi",
    "RULE_2": "Aturan whitespace untuk fokus copywriting",
    "RULE_3": "Aturan perataan teks untuk keterbacaan"
  },
  "CONTENT_PAYLOAD": {
    "TOPIC": "Topik utama",
    "TARGET_AUDIENCE": "Target audiens",
    "EMOTIONAL_TRIGGER": "Pemicu emosi audiens"
  },
  "SLIDES_CONTENT": [
    {
      "slideNumber": 1,
      "headline": "Headline slide 1",
      "description": "Copywriting slide 1",
      "subject": "Deskripsi karakter/subjek utama slide 1 secara singkat dan jelas",
      "sceneDescription": "Deskripsi latar belakang, aksi, dan suasana slide 1",
      "visualEmphasis": "Fokus visual utama slide 1",
      "communicationGoal": "Tujuan komunikasi spesifik slide 1",
      "educationalObjective": "Poin edukasi utama slide 1",
      "keyPoints": ["Poin penting A", "Poin penting B"],
      "supportingFacts": ["Fakta pendukung 1"],
      "calloutSuggestions": ["Saran highlight teks"],
      "storytellingSequence": "Urutan cerita slide 1"
    }
  ],
  "output": {
    "viralScore": 85,
    "analysisShortcomings": "Analisis singkat kelemahan visual",
    "hooks": ["hook 1", "hook 2"],
    "logoExplanation": "Penjelasan peletakan logo/branding",
    "socialMediaCaption": "Caption media sosial lengkap untuk carousel ini",
    "promptScore": 85,
    "detailScore": 80,
    "creativityScore": 90,
    "compositionScore": 85,
    "promptImprovement": "Saran perbaikan copywriting dan penempatan elemen agar lebih balance",
    "aiSuggestions": ["Tambahkan watermark kontras", "Gunakan warna komplemen dominan"]
  }
}

OUTPUT HANYA BLOK JSON VALID. JANGAN TULIS PENJELASAN LAIN.`;

      let finalPrompt = prompt;
      if (previousError) {
        finalPrompt += `\n\n=======================================================\n🔥 WARNING: SCHEMA ERROR PREVIOUSLY 🔥\n${previousError}\n=======================================================`;
      }

      const response = await this.groqClient.post(apiKey, {
        model: 'llama-3.3-70b-versatile',
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content: 'Kamu adalah Content Strategist dan Art Director profesional. Selalu kembalikan respons dalam format JSON valid yang lengkap dan terstruktur sesuai skema yang diminta. Jangan tambahkan komentar atau penjelasan di luar JSON.'
          },
          { role: 'user', content: finalPrompt }
        ],
      });

      const text = response.choices[0]?.message?.content || '{}';
      const finalPayloadRaw = JSON.parse(this.groqClient.sanitizeJson(text));
      const finalPayloadJson = this.deepCamelizeKeys(finalPayloadRaw);

      const styleTemplate = fullFormState.styleTemplate || '';
      const characterFocusPrompt = fullFormState.characterFocusPrompt || '';
      const dropdownSpecs = fullFormState.dropdownSpecs || '';
      const targetModel = fullFormState.imageGenerator || fullFormState.targetModel || 'flux';

      // Suntikkan Blueprint Desain dari Database secara langsung (Single Source of Truth)
      this.injectDatabaseBlueprints(finalPayloadJson, fullFormState, styleTemplate, brandingInstruction, watermarkInstruction);

      // Kompilasi prompt akhir secara deterministik menggunakan compiler backend
      const isEdukasi = fullFormState.feature === 'edukasi' || fullFormState.mode === 'edukasi' || fullFormState.category === 'edukasi';
      const finalPromptFinal = isEdukasi
        ? compileEdukasiMasterPrompt(finalPayloadJson, fullFormState, styleTemplate, characterFocusPrompt, dropdownSpecs, watermarkInstruction)
        : compileFinalPrompt(finalPayloadJson, 1, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel);

      // Isi nilai prompt pada slidesContent secara dinamis
      if (finalPayloadJson.slidesContent) {
        finalPayloadJson.slidesContent = finalPayloadJson.slidesContent.map((s: any) => ({
          ...s,
          prompt: compileFinalPrompt(finalPayloadJson, s.slideNumber, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel)
        }));
      }

      // Sinkronisasi data slides output
      if (finalPayloadJson.slidesContent) {
        if (!finalPayloadJson.output) finalPayloadJson.output = {};
        finalPayloadJson.output.slides = finalPayloadJson.slidesContent.map((s: any) => ({
          slideNumber: s.slideNumber,
          prompt: s.prompt
        }));
      }

      return { payloadJson: finalPayloadJson, promptFinal: finalPromptFinal };
    });
  }

  // --- GEMINI ---
  async generatePromptGemini(fullFormState: any, previousError?: string): Promise<{ payloadJson: any; promptFinal: string; }> {
    return this.geminiClient.executeWithKey(async (genAI) => {
      const { slideCount, brandingInstruction, watermarkInstruction } = this.buildPromptVariables(fullFormState);
      const contentIntelligence = this.buildContentIntelligenceInstructions(fullFormState);
      const isStrict = env.USE_STRICT_PAYLOAD_SCHEMA === 'true';

      const strictSchema: Schema = {
        type: SchemaType.OBJECT,
        properties: {
          SYSTEM_INIT: {
            type: SchemaType.OBJECT,
            properties: {
              MISSION: { type: SchemaType.STRING }
            },
            required: ["MISSION"]
          },
          RULE_ENGINE: { type: SchemaType.OBJECT },
          CONTENT_PAYLOAD: {
            type: SchemaType.OBJECT,
            properties: {
              TOPIC: { type: SchemaType.STRING },
              TARGET_AUDIENCE: { type: SchemaType.STRING },
              EMOTIONAL_TRIGGER: { type: SchemaType.STRING }
            },
            required: ["TOPIC", "TARGET_AUDIENCE", "EMOTIONAL_TRIGGER"]
          },
          SLIDES_CONTENT: {
            type: SchemaType.ARRAY,
            items: {
              type: SchemaType.OBJECT,
              properties: {
                slideNumber: { type: SchemaType.INTEGER },
                headline: { type: SchemaType.STRING },
                description: { type: SchemaType.STRING },
                subject: { type: SchemaType.STRING },
                sceneDescription: { type: SchemaType.STRING },
                visualEmphasis: { type: SchemaType.STRING },
                communicationGoal: { type: SchemaType.STRING },
                educationalObjective: { type: SchemaType.STRING },
                keyPoints: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
                supportingFacts: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
                calloutSuggestions: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
                storytellingSequence: { type: SchemaType.STRING }
              },
              required: ["slideNumber", "headline", "description", "subject", "sceneDescription", "visualEmphasis"]
            }
          },
          output: {
            type: SchemaType.OBJECT,
            properties: {
              viralScore: { type: SchemaType.INTEGER },
              analysisShortcomings: { type: SchemaType.STRING },
              hooks: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
              logoExplanation: { type: SchemaType.STRING },
              socialMediaCaption: { type: SchemaType.STRING },
              promptScore: { type: SchemaType.INTEGER },
              detailScore: { type: SchemaType.INTEGER },
              creativityScore: { type: SchemaType.INTEGER },
              compositionScore: { type: SchemaType.INTEGER },
              promptImprovement: { type: SchemaType.STRING },
              aiSuggestions: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } }
            },
            required: ["viralScore", "analysisShortcomings", "hooks", "logoExplanation", "socialMediaCaption", "promptScore", "detailScore", "creativityScore", "compositionScore", "promptImprovement", "aiSuggestions"]
          }
        },
        required: [
          "SYSTEM_INIT",
          "RULE_ENGINE",
          "CONTENT_PAYLOAD",
          "SLIDES_CONTENT",
          "output"
        ]
      };

      const generationConfig: any = { responseMimeType: 'application/json', maxOutputTokens: 8192 };
      if (isStrict) generationConfig.responseSchema = strictSchema;

      const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite', generationConfig });
      const parts: any[] = [];

      const prompt = `Kamu adalah Content Strategist, Art Director & Prompt Compiler Engine profesional.
Tugasmu adalah menganalisis input form user dan menyusun arsitektur data konten poster/carousel yang solid ke dalam format JSON yang bersih dan representatif.
JANGAN membuat atau memasukkan aturan layout, aturan grid, aturan tipografi, aturan warna, lighting, kamera, rendering, atau aturan negatif apa pun. Seluruh hal visual tersebut sudah memiliki Blueprint tersendiri.

Fokuskan tugasmu HANYA pada penyusunan pesan komunikasi, topik utama, copywriting teks slide (headline & description), serta data konten terstruktur pendukung lainnya.

STRATEGI KONTEN DARI CONTENT INTELLIGENCE ENGINE:
${contentIntelligence}

INPUT USER:
${JSON.stringify(fullFormState, null, 2)}

DESAIN SISTEM KONTEN YANG WAJIB DIATUR:
1. System Mission & Content Payload -> Analisis topik, misi pembuatan poster, target audiens, dan pemicu emosi audiens.
2. Slides Content -> TEPAT ${slideCount} slide dengan data terpisah (slideNumber, headline, description, subject, sceneDescription, visualEmphasis, communicationGoal, educationalObjective, keyPoints, supportingFacts, calloutSuggestions, storytellingSequence).
   - JANGAN menulis field 'prompt' di dalam slide. Compiler akan merakit prompt secara otomatis dari data Anda.
   - subject: Deskripsi karakter/subjek utama pada slide ini secara singkat dan jelas.
   - sceneDescription: Deskripsi latar belakang, aksi, dan suasana khusus pada slide ini.
   - visualEmphasis: Elemen fokus utama atau penekanan visual pada slide ini.
3. Quality Evaluation -> Analisis kualitas draf input dan berikan nilai numeric:
   - promptScore (0-100)
   - detailScore (0-100)
   - creativityScore (0-100)
   - compositionScore (0-100)
   - promptImprovement: Deskripsi singkat perbaikan visual yang Anda sarankan.
   - aiSuggestions: Array 3 rekomendasi draf visual tambahan.

OUTPUT HANYA BLOK JSON VALID SESUAI SKEMA.`;

      let finalPrompt = prompt;
      if (previousError) {
        finalPrompt += `\n\n=======================================================\n🔥 WARNING: SCHEMA ERROR PREVIOUSLY 🔥\n${previousError}\n=======================================================`;
      }
      parts.push(finalPrompt);

      if (fullFormState.referenceImage?.url) {
        try {
          const imagePart = await this.imageAnalyzer.fetchImageAsBase64Part(fullFormState.referenceImage.url);
          parts.push(imagePart);
        } catch (err: any) {
          logger.warn(`Could not fetch reference image for multimodal prompt generation: ${err?.message}`);
        }
      }

      const response = await model.generateContent(parts);
      const text = response.response.text();
      const finalPayloadRaw = JSON.parse(this.geminiClient.sanitizeJson(text));
      const finalPayloadJson = this.deepCamelizeKeys(finalPayloadRaw);

      const styleTemplate = fullFormState.styleTemplate || '';
      const characterFocusPrompt = fullFormState.characterFocusPrompt || '';
      const dropdownSpecs = fullFormState.dropdownSpecs || '';
      const targetModel = fullFormState.imageGenerator || fullFormState.targetModel || 'flux';

      // Suntikkan Blueprint Desain dari Database secara langsung (Single Source of Truth)
      this.injectDatabaseBlueprints(finalPayloadJson, fullFormState, styleTemplate, brandingInstruction, watermarkInstruction);

      // Kompilasi prompt akhir secara deterministik menggunakan compiler backend
      const isEdukasi = fullFormState.feature === 'edukasi' || fullFormState.mode === 'edukasi' || fullFormState.category === 'edukasi';
      const finalPromptFinal = isEdukasi
        ? compileEdukasiMasterPrompt(finalPayloadJson, fullFormState, styleTemplate, characterFocusPrompt, dropdownSpecs, watermarkInstruction)
        : compileFinalPrompt(finalPayloadJson, 1, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel);

      // Isi nilai prompt pada slidesContent secara dinamis
      if (finalPayloadJson.slidesContent) {
        finalPayloadJson.slidesContent = finalPayloadJson.slidesContent.map((s: any) => ({
          ...s,
          prompt: compileFinalPrompt(finalPayloadJson, s.slideNumber, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel)
        }));
      }

      // Sinkronisasi data slides output
      if (finalPayloadJson.slidesContent) {
        if (!finalPayloadJson.output) finalPayloadJson.output = {};
        finalPayloadJson.output.slides = finalPayloadJson.slidesContent.map((s: any) => ({
          slideNumber: s.slideNumber,
          prompt: s.prompt
        }));
      }

      return { payloadJson: finalPayloadJson, promptFinal: finalPromptFinal };
    });
  }

  async generatePrompt(fullFormState: any, previousError?: string): Promise<{ payloadJson: any; promptFinal: string; }> {
    if (fullFormState.feature === 'video') {
      return this.generateVideoPromptGemini(fullFormState, previousError);
    }
    if (fullFormState.feature === 'advanced_video') {
      return this.generateAdvancedVideoPromptGemini(fullFormState, previousError);
    }
    return this.generatePromptGemini(fullFormState, previousError);
  }

  // --- VIDEO CONTENT INTELLIGENCE ---
  private buildVideoContentIntelligence(fullFormState: any): string {
    const duration = Number(fullFormState.duration || 10);
    const segmentCount = Math.ceil(duration / 10);
    
    let strategy = `
[STRATEGI KONTEN VIDEO: ${duration} DETIK (${segmentCount} SEGMEN @10 DETIK)]
- Output adalah video berdurasi ${duration} detik yang dibagi menjadi ${segmentCount} segmen masing-masing tepat 10 detik.
- Setiap segmen harus memiliki transisi yang mulus ke segmen berikutnya agar menjaga kesinambungan visual (visual continuity).
- Alur Cerita (Storytelling Flow):
  * Segmen 1 (00:00 - 00:10): Hook pembuka yang sangat menarik secara visual untuk menahan audiens dalam 3 detik pertama.
  * Segmen 2 s.d ${segmentCount - 1} (jika ada): Pengembangan materi, demonstrasi, atau penjelasan alur cerita utama secara logis.
  * Segmen Terakhir: Rangkuman, klimaks cerita, atau Call to Action (CTA) yang jelas.
`;

    if (fullFormState.characterFocusObj) {
      const charObj = fullFormState.characterFocusObj;
      strategy += `\n\n[ATURAN KARAKTER WAJIB: ${charObj.name}]
- Gunakan karakter ini sebagai subjek di setiap segmen video.
- Karakter harus terlihat hidup dan bergerak secara dinamis di setiap segmen.
- Deskripsi Konsistensi Visual: ${fullFormState.characterFocusPrompt || ''}
- Dilarang menyebutkan deskripsi warna, fisik, atau pakaian secara mendetail pada subject. Cukup panggil nama karakter dan posenya saja (contoh: "${charObj.name} sedang berlari kaget" atau "${charObj.name} tersenyum lebar").`;
    }

    return strategy;
  }

  // --- GEMINI VIDEO PROMPT GENERATOR ---
  async generateVideoPromptGemini(fullFormState: any, previousError?: string): Promise<{ payloadJson: any; promptFinal: string; }> {
    return this.geminiClient.executeWithKey(async (genAI) => {
      const duration = Number(fullFormState.duration || 10);
      const segmentCount = Math.ceil(duration / 10);
      const { watermarkInstruction } = this.buildPromptVariables(fullFormState);
      const contentIntelligence = this.buildVideoContentIntelligence(fullFormState);
      const isStrict = env.USE_STRICT_PAYLOAD_SCHEMA === 'true';

      const strictVideoSchema: Schema = {
        type: SchemaType.OBJECT,
        properties: {
          SYSTEM_INIT: {
            type: SchemaType.OBJECT,
            properties: {
              MISSION: { type: SchemaType.STRING }
            },
            required: ["MISSION"]
          },
          RULE_ENGINE: { type: SchemaType.OBJECT },
          CONTENT_PAYLOAD: {
            type: SchemaType.OBJECT,
            properties: {
              TOPIC: { type: SchemaType.STRING },
              TARGET_AUDIENCE: { type: SchemaType.STRING },
              EMOTIONAL_TRIGGER: { type: SchemaType.STRING }
            },
            required: ["TOPIC", "TARGET_AUDIENCE", "EMOTIONAL_TRIGGER"]
          },
          videoStyle: {
            type: SchemaType.OBJECT,
            properties: {
              coreVisualStyle: { type: SchemaType.STRING },
              colorPalette: { type: SchemaType.STRING },
              cameraMovementStyle: { type: SchemaType.STRING }
            },
            required: ["coreVisualStyle", "colorPalette", "cameraMovementStyle"]
          },
          renderingBlueprint: {
            type: SchemaType.OBJECT,
            properties: {
              renderStyle: { type: SchemaType.STRING },
              qualityParameters: { type: SchemaType.STRING },
              negativePrompt: { type: SchemaType.STRING }
            },
            required: ["renderStyle", "qualityParameters", "negativePrompt"]
          },
          brandingEngine: {
            type: SchemaType.OBJECT,
            properties: {
              watermarkFooter: { type: SchemaType.STRING }
            },
            required: ["watermarkFooter"]
          },
          segmentsContent: {
            type: SchemaType.ARRAY,
            items: {
              type: SchemaType.OBJECT,
              properties: {
                segmentNumber: { type: SchemaType.INTEGER },
                timestamp: { type: SchemaType.STRING },
                headline: { type: SchemaType.STRING },
                description: { type: SchemaType.STRING },
                visualPrompt: { type: SchemaType.STRING },
                motionPrompt: { type: SchemaType.STRING },
                transitionPrompt: { type: SchemaType.STRING },
                textOverlay: { type: SchemaType.STRING },
                audioSuggestion: { type: SchemaType.STRING }
              },
              required: ["segmentNumber", "timestamp", "visualPrompt", "motionPrompt", "transitionPrompt"]
            }
          },
          output: {
            type: SchemaType.OBJECT,
            properties: {
              viralScore: { type: SchemaType.INTEGER },
              analysisShortcomings: { type: SchemaType.STRING },
              hooks: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
              socialMediaCaption: { type: SchemaType.STRING }
            },
            required: ["viralScore", "analysisShortcomings", "hooks", "socialMediaCaption"]
          }
        },
        required: [
          "SYSTEM_INIT",
          "RULE_ENGINE",
          "CONTENT_PAYLOAD",
          "videoStyle",
          "renderingBlueprint",
          "brandingEngine",
          "segmentsContent",
          "output"
        ]
      };

      const generationConfig: any = { responseMimeType: 'application/json', maxOutputTokens: 8192 };
      if (isStrict) generationConfig.responseSchema = strictVideoSchema;

      const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite', generationConfig });
      const parts: any[] = [];

      const prompt = `Kamu adalah Video Content Strategist, Art Director & AI Video Prompt Architect profesional.
Tugasmu adalah menganalisis input form user dan menyusun arsitektur data konten video berdurasi ${duration} detik ke dalam format JSON yang bersih dan representatif.

Kamu WAJIB membagi video ini menjadi tepat ${segmentCount} segmen, masing-masing berdurasi 10 detik.
Untuk setiap segmen, kamu harus merinci:
1. segmentNumber (1, 2, dst)
2. timestamp (misalnya "00:00 - 00:10", "00:10 - 00:20", dst)
3. visualPrompt: Deskripsi visual yang sangat detail dalam Bahasa Inggris untuk generator video AI (seperti Google Veo/Runway). Sebutkan aksi subjek, pencahayaan, detail scene, dan pastikan konsistensi visual dengan segmen lain.
4. motionPrompt: Pergerakan kamera dan dinamika aksi subjek secara detail dalam Bahasa Inggris (misal: "A slow dramatic zoom in on the subject's expression...").
5. transitionPrompt: Deskripsi transisi visual ke segmen berikutnya agar video terlihat kontinu tanpa patahan kasar dalam Bahasa Inggris (misal: "Match cut of the hand movement...", "Seamless pan transition...").
6. textOverlay: Kalimat teks/subtitles bahasa Indonesia yang muncul di layar untuk segmen ini (opsional).
7. audioSuggestion: Rekomendasi efek suara atau suasana musik untuk segmen ini (opsional).

STRATEGI KONTEN VIDEO DARI CONTENT INTELLIGENCE ENGINE:
${contentIntelligence}

INPUT USER:
${JSON.stringify(fullFormState, null, 2)}

OUTPUT HANYA BLOK JSON VALID SESUAI SKEMA.`;

      let finalPrompt = prompt;
      if (previousError) {
        finalPrompt += `\n\n=======================================================\n🔥 WARNING: SCHEMA ERROR PREVIOUSLY 🔥\n${previousError}\n=======================================================`;
      }
      parts.push(finalPrompt);

      if (fullFormState.referenceImage?.url) {
        try {
          const imagePart = await this.imageAnalyzer.fetchImageAsBase64Part(fullFormState.referenceImage.url);
          parts.push(imagePart);
        } catch (err: any) {
          logger.warn(`Could not fetch reference image for video prompt generation: ${err?.message}`);
        }
      }

      const response = await model.generateContent(parts);
      const text = response.response.text();
      const finalPayloadRaw = JSON.parse(this.geminiClient.sanitizeJson(text));
      const finalPayloadJson = this.deepCamelizeKeys(finalPayloadRaw);

      const styleTemplate = fullFormState.styleTemplate || '';
      const characterFocusPrompt = fullFormState.characterFocusPrompt || '';
      const dropdownSpecs = fullFormState.dropdownSpecs || '';
      const targetModel = fullFormState.videoGenerator || fullFormState.targetModel || 'veo';

      // Inject configurations
      finalPayloadJson.brandingEngine = {
        watermarkFooter: watermarkInstruction
      };

      // Compile final prompts for each segment
      if (finalPayloadJson.segmentsContent) {
        finalPayloadJson.segmentsContent = finalPayloadJson.segmentsContent.map((s: any) => ({
          ...s,
          prompt: compileFinalVideoPrompt(finalPayloadJson, s.segmentNumber, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel)
        }));
      }

      if (finalPayloadJson.segmentsContent) {
        if (!finalPayloadJson.output) finalPayloadJson.output = {};
        finalPayloadJson.output.segments = finalPayloadJson.segmentsContent.map((s: any) => ({
          segmentNumber: s.segmentNumber,
          prompt: s.prompt
        }));
      }

      const promptFinal = compileFinalVideoPrompt(finalPayloadJson, 1, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel);

      return { payloadJson: finalPayloadJson, promptFinal };
    });
  }

  // --- GROQ VIDEO PROMPT GENERATOR ---
  async generateVideoPromptGroq(fullFormState: any, previousError?: string): Promise<{ payloadJson: any; promptFinal: string; }> {
    return this.groqClient.executeWithKey(async (apiKey) => {
      const duration = Number(fullFormState.duration || 10);
      const segmentCount = Math.ceil(duration / 10);
      const { watermarkInstruction } = this.buildPromptVariables(fullFormState);
      const contentIntelligence = this.buildVideoContentIntelligence(fullFormState);

      const prompt = `Kamu adalah Video Content Strategist, Art Director & AI Video Prompt Architect profesional.
Tugasmu adalah menganalisis input form user dan menyusun arsitektur data konten video berdurasi ${duration} detik ke dalam format JSON yang bersih dan representatif.

Kamu WAJIB membagi video ini menjadi tepat ${segmentCount} segmen, masing-masing berdurasi 10 detik.
Untuk setiap segmen, kamu harus merinci:
1. segmentNumber (1, 2, dst)
2. timestamp (misalnya "00:00 - 00:10", "00:10 - 00:20", dst)
3. visualPrompt: Deskripsi visual yang sangat detail dalam Bahasa Inggris untuk generator video AI (seperti Google Veo/Runway). Sebutkan aksi subjek, pencahayaan, detail scene, dan pastikan konsistensi visual dengan segmen lain.
4. motionPrompt: Pergerakan kamera dan dinamika aksi subjek secara detail dalam Bahasa Inggris (misal: "A slow dramatic zoom in on the subject's expression...").
5. transitionPrompt: Deskripsi transisi visual ke segmen berikutnya agar video terlihat kontinu tanpa patahan kasar dalam Bahasa Inggris (misal: "Match cut of the hand movement...", "Seamless pan transition...").
6. textOverlay: Kalimat teks/subtitles bahasa Indonesia yang muncul di layar untuk segmen ini (opsional).
7. audioSuggestion: Rekomendasi efek suara atau suasana musik untuk segmen ini (opsional).

STRATEGI KONTEN VIDEO DARI CONTENT INTELLIGENCE ENGINE:
${contentIntelligence}

INPUT USER:
${JSON.stringify(fullFormState, null, 2)}

OUTPUT WAJIB BERUPA SINGLE JSON DENGAN STRUKTUR BERIKUT:
{
  "SYSTEM_INIT": {
    "MISSION": "Deskripsi misi pembuatan materi video"
  },
  "RULE_ENGINE": {
    "RULE_1": "Aturan konsistensi visual",
    "RULE_2": "Aturan kesinambungan cerita"
  },
  "CONTENT_PAYLOAD": {
    "TOPIC": "Topik utama",
    "TARGET_AUDIENCE": "Target audiens",
    "EMOTIONAL_TRIGGER": "Pemicu emosi"
  },
  "videoStyle": {
    "coreVisualStyle": "Gaya visual video",
    "colorPalette": "Skema warna",
    "cameraMovementStyle": "Gaya gerakan kamera"
  },
  "renderingBlueprint": {
    "renderStyle": "Gaya render video",
    "qualityParameters": "Parameter kualitas",
    "negativePrompt": "Hal yang dihindari"
  },
  "brandingEngine": {
    "watermarkFooter": "Instruksi watermark"
  },
  "segmentsContent": [
    {
      "segmentNumber": 1,
      "timestamp": "00:00 - 00:10",
      "headline": "Headline segmen 1 (opsional)",
      "description": "Rincian segmen 1 (opsional)",
      "visualPrompt": "Visual prompt detail segmen 1 dalam Bahasa Inggris",
      "motionPrompt": "Motion prompt detail segmen 1 dalam Bahasa Inggris",
      "transitionPrompt": "Transition prompt detail segmen 1 dalam Bahasa Inggris",
      "textOverlay": "Teks subtitle Indonesia segmen 1",
      "audioSuggestion": "Audio suggestion segmen 1"
    }
  ],
  "output": {
    "viralScore": 85,
    "analysisShortcomings": "Analisis kekurangan video",
    "hooks": ["hook 1", "hook 2"],
    "socialMediaCaption": "Caption media sosial untuk video ini"
  }
}

OUTPUT HANYA BLOK JSON VALID. JANGAN TULIS PENJELASAN LAIN.`;

      let finalPrompt = prompt;
      if (previousError) {
        finalPrompt += `\n\n=======================================================\n🔥 WARNING: SCHEMA ERROR PREVIOUSLY 🔥\n${previousError}\n=======================================================`;
      }

      const response = await this.groqClient.post(apiKey, {
        model: 'llama-3.3-70b-versatile',
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content: 'Kamu adalah Video Content Strategist dan AI Video Prompt Architect profesional. Selalu kembalikan respons dalam format JSON valid yang lengkap sesuai skema yang diminta. Jangan tambahkan komentar di luar JSON.'
          },
          { role: 'user', content: finalPrompt }
        ],
      });

      const text = response.choices[0]?.message?.content || '{}';
      const finalPayloadRaw = JSON.parse(this.groqClient.sanitizeJson(text));
      const finalPayloadJson = this.deepCamelizeKeys(finalPayloadRaw);

      const styleTemplate = fullFormState.styleTemplate || '';
      const characterFocusPrompt = fullFormState.characterFocusPrompt || '';
      const dropdownSpecs = fullFormState.dropdownSpecs || '';
      const targetModel = fullFormState.videoGenerator || fullFormState.targetModel || 'veo';

      // Inject configurations
      finalPayloadJson.brandingEngine = {
        watermarkFooter: watermarkInstruction
      };

      // Compile final prompts for each segment
      if (finalPayloadJson.segmentsContent) {
        finalPayloadJson.segmentsContent = finalPayloadJson.segmentsContent.map((s: any) => ({
          ...s,
          prompt: compileFinalVideoPrompt(finalPayloadJson, s.segmentNumber, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel)
        }));
      }

      if (finalPayloadJson.segmentsContent) {
        if (!finalPayloadJson.output) finalPayloadJson.output = {};
        finalPayloadJson.output.segments = finalPayloadJson.segmentsContent.map((s: any) => ({
          segmentNumber: s.segmentNumber,
          prompt: s.prompt
        }));
      }

      const promptFinal = compileFinalVideoPrompt(finalPayloadJson, 1, styleTemplate, characterFocusPrompt, dropdownSpecs, targetModel);

      return { payloadJson: finalPayloadJson, promptFinal };
    });
  }

  // --- ENHANCE PROMPT ---
  async generateEnhancePrompt(imageUrl: string, enhanceStyle: string, changeLevel: string, notes: string, provider: 'gemini' | 'groq'): Promise<{ payloadJson: any; promptFinal: string; }> {
    const styleMap: Record<string, string> = {
      kpop_aesthetic: 'K-pop / Korean Aesthetic — smooth glass skin, bright dewy complexion, soft pink blush, puppy eyes, gradient lips, light natural makeup over flawless porcelain skin',
      professional_headshot: 'Professional Headshot — corporate clean look, neutral background, sharp focus on face, natural skin with minimal retouching, confident expression',
      cinematic_portrait: 'Cinematic Portrait — dramatic Rembrandt lighting, deep shadows, film grain, moody color grading, editorial magazine quality',
      cyberpunk_mech: 'Cyberpunk Mech — neon holographic overlays, circuit tattoos, mechanical implants on face, electric blue and magenta glow, dystopian high-tech aesthetic',
    };
    const changeLevelMap: Record<string, string> = {
      natural: 'natural — subtle enhancements only, preserve identity and likeness, no dramatic changes',
      medium: 'medium — noticeable improvements while keeping realistic look, enhance features meaningfully',
    };
    const styleDescription = styleMap[enhanceStyle] || enhanceStyle;
    const changeLevelDescription = changeLevelMap[changeLevel] || changeLevel;

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const imageInfo = await this.imageAnalyzer.fetchImageAsBase64(imageUrl);
        const visionPrompt = `You are an expert AI photo retouching prompt engineer.\nAnalyze this photo and produce a super-detailed AI image generation prompt in JSON format.\n\nANALYZE:\n- Subject, Lighting, Background, Outfit\n\nENHANCEMENT REQUEST:\n- Style: ${styleDescription}\n- Change Level: ${changeLevelDescription}\n- Notes: ${notes || 'none'}\n\nReturn ONLY valid JSON:\n{\n  "payloadJson": {\n    "meta": { "mode": "photo_enhance", "language": "id", "createdAt": "${new Date().toISOString()}" },\n    "input": { "imageUrl": "${imageUrl}", "enhanceStyle": "${enhanceStyle}", "changeLevel": "${changeLevel}", "notes": "${notes}" },\n    "analysis": {},\n    "output": {\n      "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT",\n      "analysisShortcomings": "Penjelasan kondisi foto dan transformasi yang dilakukan (Bahasa Indonesia)",\n      "viralScore": 0,\n      "hooks": ["HOOK_1", "HOOK_2", "HOOK_3", "HOOK_4"]\n    }\n  },\n  "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT"\n}`;
        const response = await this.groqClient.post(apiKey, {
          model: 'llama-3.2-11b-vision-preview',
          messages: [{ role: 'user', content: [{ type: 'text', text: visionPrompt }, { type: 'image_url', image_url: { url: `data:${imageInfo.mimeType};base64,${imageInfo.base64Data}` } }] }],
        });
        const parsed = JSON.parse(this.groqClient.sanitizeJson(response.choices[0]?.message?.content || '{}'));
        if (!parsed.payloadJson) parsed.payloadJson = parsed;
        if (!parsed.promptFinal) parsed.promptFinal = parsed.payloadJson?.output?.promptFinal || '';
        return parsed;
      });
    } else {
      return this.geminiClient.executeWithKey(async (genAI) => {
        const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite', generationConfig: { responseMimeType: 'application/json' } });
        const imagePart = await this.imageAnalyzer.fetchImageAsBase64Part(imageUrl);
        const prompt = `You are an expert AI photo retouching and enhancement prompt engineer.\nYou are given a real photo to deeply analyze. Your job is to produce a highly detailed, professional AI image generation prompt that will transform this photo according to the requested style.\n\nENHANCEMENT REQUEST:\n- Style: ${styleDescription}\n- Change Level: ${changeLevelDescription}\n- Additional Notes from user: ${notes || 'none'}\n\nBased on your deep visual analysis of the photo, generate the following JSON output:\n{\n  "payloadJson": {\n    "meta": { "mode": "photo_enhance", "language": "id", "createdAt": "${new Date().toISOString()}" },\n    "input": {\n      "imageUrl": "${imageUrl}",\n      "enhanceStyle": "${enhanceStyle}",\n      "changeLevel": "${changeLevel}",\n      "notes": "${notes}"\n    },\n    "analysis": {},\n    "output": {\n      "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT",\n      "analysisShortcomings": "Penjelasan mendalam tentang kondisi foto asli dan transformasi apa yang akan dilakukan dalam bahasa Indonesia",\n      "viralScore": 0,\n      "hooks": ["HOOK_1", "HOOK_2", "HOOK_3", "HOOK_4"]\n    }\n  },\n  "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT"\n}\n\nOutput ONLY valid JSON.`;
        const response = await model.generateContent([prompt, imagePart]);
        const parsed = JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
        if (!parsed.payloadJson) parsed.payloadJson = parsed;
        if (!parsed.promptFinal) parsed.promptFinal = parsed.payloadJson?.output?.promptFinal || '';
        return parsed;
      });
    }
  }

  // --- PROMPT TEMPLATE ---
  async generatePromptTemplate(category: string, idea: string, provider: 'gemini' | 'groq') {
    const prompt = `Kamu adalah seorang prompt engineer AI profesional. Tugasmu adalah membuat sebuah template prompt generatif (DSL) dan detail pelengkapnya untuk kategori "${category}" berdasarkan ide dasar: "${idea}".

Template ini akan digunakan oleh pengguna aplikasi untuk membuat konten secara dinamis. Oleh karena itu, template harus menyertakan token parameter dalam tanda kurung kurawal ganda seperti {{topic}}, {{description}}, {{keyPoints}}, {{style}}, {{colorPalette}}, {{mood}}, {{cta}}, dll., yang nantinya akan digantikan oleh input formulir pengguna.

Output harus berformat JSON dengan struktur persis seperti berikut:
{
  "template": "Tulis template prompt DSL lengkap di sini, yang sangat detail untuk menghasilkan gambar/konten visual berkualitas tinggi menggunakan generator gambar AI. Masukkan token parameter {{topic}}, {{description}}, {{keyPoints}}, {{style}}, {{colorPalette}}, {{mood}}, dll. di tempat yang sesuai.",
  "analysis": "Penjelasan singkat (1-2 kalimat) mengapa struktur template ini optimal secara visual dan pemasaran.",
  "hooks": [
    "Copywriting Hook 1 (mengandung parameter seperti {{topic}} atau $category)",
    "Copywriting Hook 2 (mengandung parameter seperti {{topic}} atau $category)",
    "Copywriting Hook 3 (mengandung parameter seperti {{topic}} atau $category)"
  ],
  "payloadJson": {
    "topic": "Topik Utama Contoh",
    "description": "Deskripsi Contoh",
    "style": "Gaya Desain Contoh",
    "colorPalette": "Palet Warna Contoh",
    "mood": "Nuansa Contoh",
    "cta": "CTA Contoh"
  },
  "viralScore": 92,
  "viralBreakdown": {
    "hook": 90,
    "visual": 95,
    "education": 85,
    "engagement": 92
  }
}
Tulis respons HANYA dalam format JSON yang valid, gunakan bahasa Indonesia.`;

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const response = await this.groqClient.post(apiKey, {
          model: 'llama-3.3-70b-versatile',
          response_format: { type: 'json_object' },
          messages: [{ role: 'user', content: prompt }],
        });
        return JSON.parse(this.groqClient.sanitizeJson(response.choices[0]?.message?.content || '{}'));
      });
    } else {
      return this.geminiClient.executeWithKey(async (genAI) => {
        const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite', generationConfig: { responseMimeType: 'application/json' } });
        const response = await model.generateContent(prompt);
        return JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
      });
    }
  }

  // --- IMPROVE PROMPT ---
  async improvePrompt(promptDraft: string, provider: 'gemini' | 'groq'): Promise<string> {
    const systemInstruction = 'You are a professional AI image prompt engineer. Your ONLY job is to rewrite and enhance image prompts. ALWAYS output ONLY the improved prompt text in English — no introduction, no explanation, no markdown, just the raw improved prompt text.';
    const userPrompt = `Improve and enhance the following image prompt draft to be more detailed, photorealistic/artistic, and effective for AI image generators (Stable Diffusion, Midjourney, DALL-E 3, Flux, Imagen):\n\n"${promptDraft}"\n\nOutput ONLY the improved English prompt text directly.`;

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const response = await this.groqClient.post(apiKey, {
          model: 'llama-3.3-70b-versatile',
          messages: [
            { role: 'system', content: systemInstruction },
            { role: 'user', content: userPrompt }
          ]
        });
        return (response.choices[0]?.message?.content || '').trim();
      });
    } else {
      return this.geminiClient.executeWithKey(async (genAI) => {
        const model = genAI.getGenerativeModel({
          model: 'gemini-3.1-flash-lite',
          systemInstruction: systemInstruction
        });
        const response = await model.generateContent(userPrompt);
        return response.response.text().trim();
      });
    }
  }

  // --- ADVANCED VIDEO PROMPT GENERATOR (GEMINI) ---
  async generateAdvancedVideoPromptGemini(fullFormState: any, previousError?: string): Promise<{ payloadJson: any; promptFinal: string; }> {
    return this.geminiClient.executeWithKey(async (genAI) => {
      const isStrict = env.USE_STRICT_PAYLOAD_SCHEMA === 'true';
      const strictSchema: Schema = {
        type: SchemaType.OBJECT,
        properties: {
          projectSummary: {
            type: SchemaType.OBJECT,
            properties: {
              title: { type: SchemaType.STRING },
              totalDuration: { type: SchemaType.INTEGER },
              description: { type: SchemaType.STRING }
            },
            required: ["title", "totalDuration", "description"]
          },
          storyBible: {
            type: SchemaType.OBJECT,
            properties: {
              storyType: { type: SchemaType.STRING },
              narrative: { type: SchemaType.STRING },
              conflict: { type: SchemaType.STRING },
              resolution: { type: SchemaType.STRING },
              ending: { type: SchemaType.STRING },
              emotionalArc: { type: SchemaType.STRING }
            },
            required: ["storyType", "narrative", "conflict", "resolution", "ending", "emotionalArc"]
          },
          characterBible: {
            type: SchemaType.ARRAY,
            items: {
              type: SchemaType.OBJECT,
              properties: {
                name: { type: SchemaType.STRING },
                age: { type: SchemaType.STRING },
                height: { type: SchemaType.STRING },
                face: { type: SchemaType.STRING },
                skin: { type: SchemaType.STRING },
                eyes: { type: SchemaType.STRING },
                hair: { type: SchemaType.STRING },
                clothes: { type: SchemaType.STRING },
                accessories: { type: SchemaType.STRING },
                expressionDefault: { type: SchemaType.STRING },
                walkStyle: { type: SchemaType.STRING },
                gesture: { type: SchemaType.STRING },
                habits: { type: SchemaType.STRING },
                personality: { type: SchemaType.STRING },
                voiceTone: { type: SchemaType.STRING }
              },
              required: ["name"]
            }
          },
          environmentBible: {
            type: SchemaType.ARRAY,
            items: {
              type: SchemaType.OBJECT,
              properties: {
                location: { type: SchemaType.STRING },
                season: { type: SchemaType.STRING },
                weather: { type: SchemaType.STRING },
                time: { type: SchemaType.STRING },
                colors: { type: SchemaType.STRING },
                materials: { type: SchemaType.STRING },
                atmosphere: { type: SchemaType.STRING },
                objectDensity: { type: SchemaType.STRING },
                fog: { type: SchemaType.STRING },
                rain: { type: SchemaType.STRING },
                wind: { type: SchemaType.STRING },
                lighting: { type: SchemaType.STRING }
              },
              required: ["location"]
            }
          },
          cameraBible: {
            type: SchemaType.OBJECT,
            properties: {
              shotSize: { type: SchemaType.STRING },
              movement: { type: SchemaType.STRING },
              focalLength: { type: SchemaType.STRING },
              lens: { type: SchemaType.STRING },
              depthOfField: { type: SchemaType.STRING },
              cameraSpeed: { type: SchemaType.STRING },
              stabilization: { type: SchemaType.STRING },
              cameraDirection: { type: SchemaType.STRING }
            },
            required: ["shotSize", "movement"]
          },
          motionBible: {
            type: SchemaType.OBJECT,
            properties: {
              characterMovement: { type: SchemaType.STRING },
              objectMovement: { type: SchemaType.STRING },
              gazeDirection: { type: SchemaType.STRING },
              speedRhythm: { type: SchemaType.STRING }
            },
            required: ["characterMovement", "objectMovement"]
          },
          sceneBreakdown: {
            type: SchemaType.ARRAY,
            items: {
              type: SchemaType.OBJECT,
              properties: {
                sceneNumber: { type: SchemaType.INTEGER },
                title: { type: SchemaType.STRING },
                goal: { type: SchemaType.STRING },
                duration: { type: SchemaType.INTEGER },
                mainSubject: { type: SchemaType.STRING },
                action: { type: SchemaType.STRING },
                emotion: { type: SchemaType.STRING },
                camera: { type: SchemaType.STRING },
                lighting: { type: SchemaType.STRING },
                environment: { type: SchemaType.STRING },
                transition: { type: SchemaType.STRING },
                dialogue: { type: SchemaType.STRING },
                soundEffect: { type: SchemaType.STRING },
                musicMood: { type: SchemaType.STRING },
                timelineBreakdown: {
                  type: SchemaType.ARRAY,
                  items: {
                    type: SchemaType.OBJECT,
                    properties: {
                      timeRange: { type: SchemaType.STRING },
                      action: { type: SchemaType.STRING }
                    },
                    required: ["timeRange", "action"]
                  }
                },
                continuity: {
                  type: SchemaType.OBJECT,
                  properties: {
                    startingState: { type: SchemaType.STRING },
                    endingState: { type: SchemaType.STRING },
                    rules: { type: SchemaType.STRING }
                  },
                  required: ["startingState", "endingState", "rules"]
                }
              },
              required: ["sceneNumber", "title", "goal", "duration", "mainSubject", "action", "camera", "transition"]
            }
          },
          continuityRules: { type: SchemaType.STRING },
          negativePrompt: { type: SchemaType.STRING },
          finalMasterPrompt: { type: SchemaType.STRING },
          optimizedPrompts: {
            type: SchemaType.OBJECT,
            properties: {
              geminiVeo: { type: SchemaType.STRING },
              kling: { type: SchemaType.STRING },
              runway: { type: SchemaType.STRING },
              pika: { type: SchemaType.STRING },
              hailuo: { type: SchemaType.STRING }
            },
            required: ["geminiVeo", "kling", "runway", "pika", "hailuo"]
          },
          analyzerReport: {
            type: SchemaType.OBJECT,
            properties: {
              characterConsistency: { type: SchemaType.STRING },
              storyLogic: { type: SchemaType.STRING },
              cameraFlow: { type: SchemaType.STRING },
              lightingConsistency: { type: SchemaType.STRING },
              continuityEvaluation: { type: SchemaType.STRING },
              instructionConflicts: { type: SchemaType.STRING },
              qualityGrade: { type: SchemaType.STRING },
              recommendations: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } }
            },
            required: ["characterConsistency", "storyLogic", "cameraFlow", "lightingConsistency", "continuityEvaluation", "qualityGrade", "recommendations"]
          }
        },
        required: ["projectSummary", "storyBible", "characterBible", "environmentBible", "cameraBible", "motionBible", "sceneBreakdown", "continuityRules", "negativePrompt", "finalMasterPrompt", "optimizedPrompts", "analyzerReport"]
      };

      const generationConfig: any = { responseMimeType: 'application/json', maxOutputTokens: 8192 };
      if (isStrict) generationConfig.responseSchema = strictSchema;

      const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite', generationConfig });
      const prompt = `Kamu adalah Production Director, Storyboard Supervisor, dan AI Video Prompt Engineer profesional.
Tugasmu adalah menganalisis input data proyek video, mengauditnya menggunakan Smart AI Analyzer, merumuskan final prompts untuk generator video AI (Kling, Runway, Pika, Hailuo, Gemini Veo), serta merapikan kesinambungan (continuity) visual antarsegmen.

Silakan audit dan optimalkan data proyek storyboard berikut menjadi JSON yang lengkap dan valid.
Pastikan:
1. 'sceneBreakdown.visualPrompt' ditulis dalam Bahasa Inggris sinematik detail (gaya artistik, lighting, background, subjek).
2. 'sceneBreakdown.motionPrompt' berisi instruksi gerakan kamera dan gerakan karakter detail dalam Bahasa Inggris.
3. 'sceneBreakdown.transitionPrompt' berisi transisi mulus ke scene berikutnya dalam Bahasa Inggris.
4. 'sceneBreakdown.timelineBreakdown' merinci pembagian detik aksi per scene secara presisi.
5. 'optimizedPrompts' berisi prompt siap salin khusus untuk masing-masing platform:
   - geminiVeo: Format detail sinematik tinggi.
   - kling: Kalimat naratif visual dengan penekanan aksi.
   - runway: Kalimat kompresi visual dengan petunjuk kamera spesifik.
   - pika: Prompt dengan struktur parameter yang disukai Pika.
   - hailuo: Fokus pada deskripsi alur dramatis.
6. 'analyzerReport' merinci audit logis atas konsistensi karakter, perpindahan kamera, kecocokan lighting, evaluasi kontinuitas fisik, konflik instruksi, dan saran peningkatan.

INPUT DATA PROYEK STORYBOARD:
${JSON.stringify(fullFormState, null, 2)}

OUTPUT HANYA BLOK JSON VALID SESUAI SKEMA.`;

      const response = await model.generateContent(prompt);
      const text = response.response.text();
      const finalPayloadRaw = JSON.parse(this.geminiClient.sanitizeJson(text));
      const finalPayloadJson = this.deepCamelizeKeys(finalPayloadRaw);

      if (!finalPayloadJson.meta) finalPayloadJson.meta = {};
      finalPayloadJson.meta.mode = 'advanced_video';
      finalPayloadJson.meta.duration = Number(fullFormState.duration || 30);

      // Return the compiled master prompt as the main preview prompt
      const promptFinal = finalPayloadJson.finalMasterPrompt || '';

      return { payloadJson: finalPayloadJson, promptFinal };
    });
  }

  // --- ADVANCED VIDEO PROMPT GENERATOR (GROQ) ---
  async generateAdvancedVideoPromptGroq(fullFormState: any, previousError?: string): Promise<{ payloadJson: any; promptFinal: string; }> {
    return this.groqClient.executeWithKey(async (apiKey) => {
      const prompt = `Kamu adalah Production Director, Storyboard Supervisor, dan AI Video Prompt Engineer profesional.
Tugasmu adalah menganalisis input data proyek video, mengauditnya menggunakan Smart AI Analyzer, merumuskan final prompts untuk generator video AI (Kling, Runway, Pika, Hailuo, Gemini Veo), serta merapikan kesinambungan (continuity) visual antarsegmen.

Silakan audit dan optimalkan data proyek storyboard berikut menjadi JSON yang lengkap dan valid.
Pastikan:
1. 'sceneBreakdown.visualPrompt' ditulis dalam Bahasa Inggris sinematik detail (gaya artistik, lighting, background, subjek).
2. 'sceneBreakdown.motionPrompt' berisi instruksi gerakan kamera dan gerakan karakter detail dalam Bahasa Inggris.
3. 'sceneBreakdown.transitionPrompt' berisi transisi mulus ke scene berikutnya dalam Bahasa Inggris.
4. 'sceneBreakdown.timelineBreakdown' merinci pembagian detik aksi per scene secara presisi.
5. 'optimizedPrompts' berisi prompt siap salin khusus untuk masing-masing platform (geminiVeo, kling, runway, pika, hailuo).
6. 'analyzerReport' merinci audit logis atas konsistensi karakter, perpindahan kamera, kecocokan lighting, evaluasi kontinuitas fisik, konflik instruksi, dan saran peningkatan.

INPUT DATA PROYEK STORYBOARD:
${JSON.stringify(fullFormState, null, 2)}

Kembalikan respons HANYA berupa JSON valid dengan struktur:
{
  "projectSummary": { "title": "...", "totalDuration": 30, "description": "..." },
  "storyBible": { "storyType": "...", "narrative": "...", "conflict": "...", "resolution": "...", "ending": "...", "emotionalArc": "..." },
  "characterBible": [{ "name": "...", "age": "..." }],
  "environmentBible": [{ "location": "...", "atmosphere": "..." }],
  "cameraBible": { "shotSize": "...", "movement": "..." },
  "motionBible": { "characterMovement": "...", "objectMovement": "..." },
  "sceneBreakdown": [{
    "sceneNumber": 1,
    "title": "...",
    "goal": "...",
    "duration": 10,
    "mainSubject": "...",
    "action": "...",
    "camera": "...",
    "lighting": "...",
    "environment": "...",
    "transition": "...",
    "dialogue": "...",
    "soundEffect": "...",
    "musicMood": "...",
    "timelineBreakdown": [{ "timeRange": "0-3 seconds", "action": "..." }],
    "continuity": { "startingState": "...", "endingState": "...", "rules": "..." }
  }],
  "continuityRules": "...",
  "negativePrompt": "...",
  "finalMasterPrompt": "...",
  "optimizedPrompts": { "geminiVeo": "...", "kling": "...", "runway": "...", "pika": "...", "hailuo": "..." },
  "analyzerReport": { "characterConsistency": "...", "storyLogic": "...", "cameraFlow": "...", "lightingConsistency": "...", "continuityEvaluation": "...", "instructionConflicts": "...", "qualityGrade": "A", "recommendations": [] }
}
Tulis respons HANYA berupa JSON valid tanpa komentar lain.`;

      const response = await this.groqClient.post(apiKey, {
        model: 'llama-3.3-70b-versatile',
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content: 'Kamu adalah Production Director, Storyboard Supervisor, dan AI Video Prompt Engineer profesional. Kembalikan respons HANYA dalam format JSON valid sesuai skema yang diminta. Tidak ada komentar atau teks di luar JSON.'
          },
          { role: 'user', content: prompt }
        ]
      });
      const text = response.choices[0]?.message?.content || '{}';
      const finalPayloadJson = JSON.parse(this.groqClient.sanitizeJson(text));

      if (!finalPayloadJson.meta) finalPayloadJson.meta = {};
      finalPayloadJson.meta.mode = 'advanced_video';
      finalPayloadJson.meta.duration = Number(fullFormState.duration || 30);

      const promptFinal = finalPayloadJson.finalMasterPrompt || '';
      return { payloadJson: finalPayloadJson, promptFinal };
    });
  }
}
