"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GeminiGatewayService = void 0;
const generative_ai_1 = require("@google/generative-ai");
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const env_1 = require("../../config/env");
const logger_1 = require("../../config/logger");
const errorHandler_1 = require("../../middlewares/errorHandler");
const errorFormatter_1 = require("../../utils/errorFormatter");
const http_1 = __importDefault(require("http"));
const https_1 = __importDefault(require("https"));
const crypto_1 = __importDefault(require("crypto"));
class GeminiGatewayService {
    // Helper to get active keys ordered by priority (desc) and usageCount (asc)
    async getHealthyKeys() {
        return await db_1.db.select()
            .from(schema_1.geminiApiKeys)
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.isActive, true), (0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.healthStatus, 'healthy')))
            .orderBy((0, drizzle_orm_1.desc)(schema_1.geminiApiKeys.priority), (0, drizzle_orm_1.asc)(schema_1.geminiApiKeys.usageCount));
    }
    // Wrapper to execute a Gemini API call with auto-rotation key pool
    async executeWithKey(fn) {
        const keys = await this.getHealthyKeys();
        // Add env fallback if pool is empty
        const keyPool = [...keys];
        if (keyPool.length === 0 && env_1.env.GEMINI_API_KEY) {
            keyPool.push({
                id: 'env_fallback',
                keyEncrypted: env_1.env.GEMINI_API_KEY,
                priority: 0,
                usageCount: 0,
            });
        }
        if (keyPool.length === 0) {
            throw new errorHandler_1.AppError('No healthy Gemini API keys available in pool', 500, 'NO_API_KEYS');
        }
        let lastError = null;
        for (const keyObj of keyPool) {
            try {
                const apiKey = keyObj.keyEncrypted; // assuming it is plaintext or already decrypted for now
                const genAI = new generative_ai_1.GoogleGenerativeAI(apiKey);
                const result = await fn(genAI);
                // Success: increment usage count if it's from DB
                if (keyObj.id !== 'env_fallback') {
                    await db_1.db.update(schema_1.geminiApiKeys).set({
                        usageCount: (keyObj.usageCount || 0) + 1,
                        lastUsedAt: new Date(),
                    }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, keyObj.id));
                }
                return result;
            }
            catch (error) {
                lastError = error;
                const errorMessage = error?.message || String(error);
                logger_1.logger.warn(`Gemini call failed with key ID ${keyObj.id}. Error: ${errorMessage}`);
                // Rotate on 429, timeout, or 5xx network errors
                const isQuotaError = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('Quota');
                const isNetworkOrTimeout = errorMessage.includes('timeout') || errorMessage.includes('FETCH_ERROR') || errorMessage.includes('500') || errorMessage.includes('503');
                if ((isQuotaError || isNetworkOrTimeout) && keyObj.id !== 'env_fallback') {
                    const newStatus = isQuotaError ? 'limited' : 'error';
                    await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: newStatus }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, keyObj.id));
                    await db_1.db.insert(schema_1.logs).values({
                        id: crypto_1.default.randomUUID(),
                        action: 'key_rotation',
                        detail: {
                            keyId: keyObj.id,
                            reason: isQuotaError ? 'API Rate Limit (429)' : 'API Error/Timeout',
                            error: errorMessage,
                            newStatus,
                        },
                    });
                }
            }
        }
        const cleanErr = lastError?.message || String(lastError);
        throw new errorHandler_1.AppError(`Seluruh API Key Gemini gagal digunakan. Kendala: ${(0, errorFormatter_1.formatGeminiError)(cleanErr)}`, 502, 'AI_SERVICE_ERROR');
    }
    // Fetch remote image and convert to Generative Part
    async fetchImageAsBase64Part(imageUrl) {
        return new Promise((resolve, reject) => {
            const client = imageUrl.startsWith('https') ? https_1.default : http_1.default;
            client.get(imageUrl, (res) => {
                const data = [];
                res.on('data', (chunk) => {
                    data.push(chunk);
                });
                res.on('end', () => {
                    const buffer = Buffer.concat(data);
                    const contentType = res.headers['content-type'] || 'image/jpeg';
                    resolve({
                        inlineData: {
                            data: buffer.toString('base64'),
                            mimeType: contentType,
                        },
                    });
                });
                res.on('error', (err) => {
                    reject(err);
                });
            }).on('error', (err) => {
                reject(err);
            });
        });
    }
    async analyzeReferenceImage(imageUrl) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite-preview' });
            let imagePart;
            try {
                imagePart = await this.fetchImageAsBase64Part(imageUrl);
            }
            catch (err) {
                logger_1.logger.error(`Error fetching reference image: ${err?.message}`);
                return 'Gagal memuat gambar referensi. Silakan cek URL gambar.';
            }
            const prompt = `Analisis gambar referensi ini secara mendalam untuk pembuatan poster.
Ekstrak elemen berikut:
1. Palet warna dominan (dan kode heksadesimal jika memungkinkan).
2. Tata letak / komposisi visual (posisi subjek, teks, whitespace).
3. Gaya seni/visual (ilustrasi modern, neubrutalism, 3D render, foto produk, retro, dll).
4. Tipografi (gaya font: sans-serif bold, serif klasik, dekoratif).
5. Nuansa / Mood (ceria, misterius, profesional, elegan).

Tulis dalam format teks terstruktur yang padat namun sangat informatif dalam bahasa Indonesia.`;
            const response = await model.generateContent([prompt, imagePart]);
            return response.response.text();
        });
    }
    async analyzeTopic(topic) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({
                model: 'gemini-3.1-flash-lite-preview',
                generationConfig: { responseMimeType: 'application/json' }
            });
            const prompt = `Berikan analisis mendalam dan ide konten untuk topik poster berikut: "${topic}".
Output harus berformat JSON dengan struktur berikut:
{
  "description": "Deskripsi lengkap isi infografis/poster yang menarik untuk audiens",
  "keyPoints": ["Poin penting 1", "Poin penting 2", "Poin penting 3 (maksimal 5 poin)"],
  "visualRecommendation": "Rekomendasi gaya gambar, tata letak, dan mood visual yang paling cocok untuk topik ini"
}
Tulis respons hanya dalam format JSON yang valid, gunakan bahasa Indonesia.`;
            const response = await model.generateContent(prompt);
            const text = response.response.text();
            return JSON.parse(text);
        });
    }
    async generatePrompt(fullFormState) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({
                model: 'gemini-3.1-flash-lite-preview',
                generationConfig: { responseMimeType: 'application/json' }
            });
            const parts = [];
            const prompt = `Anda adalah pakar AI Prompt Engineer khusus untuk pembuatan gambar/poster.
Tugas Anda adalah memproses konfigurasi poster dari user dan merumuskan prompt terstruktur final yang super detail untuk generator gambar (Midjourney/Flux/DALL-E 3/Gemini).

Berikut adalah data konfigurasi dari user:
${JSON.stringify(fullFormState, null, 2)}

Sebelum mengeluarkan hasil akhir, Anda WAJIB menganalisis terlebih dahulu apa saja kekurangan dari data input/konfigurasi JSON payload yang diberikan (misal: kurangnya detail visual, kontras warna kurang kuat, mood kurang dramatis, teks kurang memikat, dll). Tuliskan hasil analisis kekurangan tersebut pada field "analysisShortcomings".

Setelah menganalisis kekurangannya, tingkatkan kualitas parameter visual dan buatlah respons JSON dengan struktur wajib sebagai berikut:
{
  "payloadJson": {
    "meta": { "mode": "poster", "category": "KATEGORI_POSTER", "language": "BAHASA_OUTPUT", "createdAt": "ISO_DATE" },
    "topic": { "title": "JUDUL_TOPIK", "description": "DESKRIPSI_KONTEN", "keyPoints": ["POIN_KONTEN"] },
    "visual": {
      "style": "GAYA_GAMBAR", "layout": "TATA_LETAK", "aspectRatio": "PROP_RASIO",
      "colorPalette": "PALET_WARNA", "mood": "NUANSA_MOOD", "typography": "GAYA_FONT",
      "illustrationStyle": "GAYA_ILUSTRASI", "renderingStyle": "RENDERING", "lighting": "PENGCAHAYAAN",
      "compositionRule": "ATURAN_KOMPOSISI", "visualDensity": "KEPADATAN_VISUAL", "iconStyle": "GAYA_IKON"
    },
    "content": { "textRule": "ATURAN_TEKS", "characterFocus": "FOKUS_KARAKTER", "cta": "CTA", "brandTone": "TONE_BRAND", "targetAudience": "TARGET_AUDIENS" },
    "constraints": { "negativePrompt": "NEGATIVE_PROMPT", "watermark": "WATERMARK", "complexity": "KOMPLEKSITAS" },
    "referenceImage": { "url": "URL_REFERENSI_BILA_ADA", "aiAnalysis": "ANALISIS_REFERENSI_BILA_ADA" },
    "output": { 
      "promptFinal": "PROMPT_FINAL_BAHASA_INGGRIS_SUPER_DETAIL", 
      "logoExplanation": "FILOSOFI_DAN_PENJELASAN_LOGO_DALAM_BAHASA_INDONESIA_BILA_FITUR_ADALAH_LOGO", 
      "analysisShortcomings": "ANALISIS_MENDALAM_TENTANG_KEKURANGAN_KONFIGURASI_PAYLOAD_AWAL_DAN_CARA_MEMPERBAIKINYA_DALAM_BAHASA_INDONESIA",
      "viralScore": 0, 
      "hooks": ["HOOK_SUPER_VIRAL_1", "HOOK_SUPER_VIRAL_2", "HOOK_SUPER_VIRAL_3", "HOOK_SUPER_VIRAL_4"],
      "slides": [
        { "slideNumber": 1, "textContent": "Teks slide 1", "visualPrompt": "Visual prompt slide 1 dalam bahasa Inggris" }
      ]
    }
  },
  "promptFinal": "PROMPT_FINAL_BAHASA_INGGRIS_SUPER_DETAIL"
}

PANDUAN MENYUSUN PROMPT FINAL (promptFinal) & KONSISTENSI VISUAL:
- Selalu tulis promptFinal dan visualPrompt dalam BAHASA INGGRIS.
- Jika data 'styleTemplate' berisi deskripsi gaya visual, Anda WAJIB menggabungkan deskripsi gaya visual tersebut ke dalam promptFinal (dan visualPrompt masing-masing slide) agar menghasilkan output visual yang konsisten sesuai gaya yang diinginkan.
- Mulai dengan deskripsi tipe visual utama (misal: "A Neubrutalism style educational poster...", "A professional commercial product photo...").
- Gabungkan semua parameter visual (layout, ratio, color palette, lighting, typography style, render style, negative constraints) ke dalam paragraf deskriptif yang mengalir dan penuh kata sifat berkualitas tinggi.
- Jika ada teks/isi poster, tuliskan instruksi teks dengan tanda kutip ganda, misalnya: 'with text "5 Tips Sehat" written in bold sans-serif'.
- Pastikan prompt final sangat spesifik dan mudah dipahami oleh Midjourney, Stable Diffusion, DALL-E, atau Flux.
- Khusus jika field 'feature' bernilai 'logo', buatlah prompt gambar logo yang sangat presisi di promptFinal (misalnya: logo vector minimalis dengan background putih bersih, dsb). Dan tuliskan penjelasan filosofi logo, makna warna, simbolik elemen, serta panduan penggunaannya secara detail dalam bahasa Indonesia pada field 'logoExplanation' di dalam payloadJson.output.
- WAJIB buat minimal 4 hook copywriting yang SUPER VIRAL, memikat, dan kontroversial secara positif untuk menarik perhatian audiens, letakkan di field 'hooks' di dalam payloadJson.output.
- Jika field 'slideCount' bernilai lebih dari 1 (misal: 2 hingga 10), rancanglah narrative content dan visual prompts secara bertahap dan koheren dari slide 1 hingga slideCount. Tuliskan hasilnya pada field 'slides' di dalam payloadJson.output. Pastikan semua slide memiliki gaya visual yang serasi dan konsisten.
- Nilai viralScore akan diproses oleh fungsi tersendiri, isi 0 dahulu di payloadJson.`;
            parts.push(prompt);
            // If reference image URL is available, include the image directly for multimodal analysis
            if (fullFormState.referenceImage?.url) {
                try {
                    const imagePart = await this.fetchImageAsBase64Part(fullFormState.referenceImage.url);
                    parts.push(imagePart);
                }
                catch (err) {
                    logger_1.logger.warn(`Could not fetch reference image for multimodal prompt generation: ${err?.message}`);
                }
            }
            const response = await model.generateContent(parts);
            const text = response.response.text();
            const parsed = JSON.parse(text);
            // Auto fallback structure
            if (!parsed.payloadJson) {
                parsed.payloadJson = parsed;
            }
            if (!parsed.promptFinal) {
                parsed.promptFinal = parsed.payloadJson?.output?.promptFinal || '';
            }
            return parsed;
        });
    }
    /**
     * Generate a super-detailed photo enhancement/retouch prompt.
     * Gemini Vision first deeply analyzes the uploaded photo (face, skin, lighting, composition),
     * then produces a structured JSON payload with a professional retouch prompt.
     */
    async generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({
                model: 'gemini-3.1-flash-lite-preview',
                generationConfig: { responseMimeType: 'application/json' }
            });
            let imagePart;
            try {
                imagePart = await this.fetchImageAsBase64Part(imageUrl);
            }
            catch (err) {
                logger_1.logger.error(`Error fetching enhance image: ${err?.message}`);
                throw new Error('Gagal mengakses gambar yang diupload. Silakan coba lagi.');
            }
            const styleMap = {
                kpop_aesthetic: 'K-pop / Korean Aesthetic — smooth glass skin, bright dewy complexion, soft pink blush, puppy eyes, gradient lips, light natural makeup over flawless porcelain skin',
                professional_headshot: 'Professional Headshot — corporate clean look, neutral background, sharp focus on face, natural skin with minimal retouching, confident expression',
                cinematic_portrait: 'Cinematic Portrait — dramatic Rembrandt lighting, deep shadows, film grain, moody color grading, editorial magazine quality',
                cyberpunk_mech: 'Cyberpunk Mech — neon holographic overlays, circuit tattoos, mechanical implants on face, electric blue and magenta glow, dystopian high-tech aesthetic',
            };
            const changeLevelMap = {
                natural: 'natural — subtle enhancements only, preserve identity and likeness, no dramatic changes',
                medium: 'medium — noticeable improvements while keeping realistic look, enhance features meaningfully',
            };
            const styleDescription = styleMap[enhanceStyle] || enhanceStyle;
            const changeLevelDescription = changeLevelMap[changeLevel] || changeLevel;
            const prompt = `You are an expert AI photo retouching and enhancement prompt engineer.
You are given a real photo to deeply analyze. Your job is to produce a highly detailed, professional AI image generation prompt that will transform this photo according to the requested style.

ANALYZE THE PHOTO CAREFULLY:
- Subject: identify gender, approximate age, skin tone, facial features, hair style, expression
- Current lighting: type, direction, quality
- Current background: what is it, its condition
- Current clothing/outfit: what is visible
- Current image quality: resolution hints, any issues

ENHANCEMENT REQUEST:
- Style: ${styleDescription}
- Change Level: ${changeLevelDescription}
- Additional Notes from user: ${notes || 'none'}

Based on your deep visual analysis of the photo, generate the following JSON output:
{
  "payloadJson": {
    "meta": { "mode": "photo_enhance", "language": "id", "createdAt": "${new Date().toISOString()}" },
    "input": {
      "imageUrl": "${imageUrl}",
      "enhanceStyle": "${enhanceStyle}",
      "changeLevel": "${changeLevel}",
      "notes": "${notes}"
    },
    "analysis": {
      "subjectDescription": "Detailed description of the person in the photo",
      "currentLighting": "Description of current lighting",
      "currentBackground": "Description of current background",
      "currentOutfit": "What they are wearing",
      "skinTone": "Skin tone description",
      "facialFeatures": "Key facial feature observations",
      "enhancementOpportunities": "What can be improved or transformed"
    },
    "output": {
      "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT",
      "analysisShortcomings": "Penjelasan mendalam tentang kondisi foto asli dan transformasi apa yang akan dilakukan dalam bahasa Indonesia",
      "viralScore": 0,
      "hooks": ["HOOK_1", "HOOK_2", "HOOK_3", "HOOK_4"]
    }
  },
  "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT"
}

PROMPT WRITING GUIDELINES for promptFinal:
- Write in English, start with: "Professional photo retouching of [subject description]..."
- Include: exact style transformation, skin enhancement details, lighting transformation, background treatment, color grading style
- Specify: what stays the same (identity, likeness if natural level) vs what changes
- End with technical specs: "photorealistic, 8K, sharp focus, professional studio quality"
- Make 4 viral Indonesian hooks for sharing this transformation on social media

Output ONLY valid JSON.`;
            const response = await model.generateContent([prompt, imagePart]);
            const text = response.response.text();
            const parsed = JSON.parse(text);
            if (!parsed.payloadJson) {
                parsed.payloadJson = parsed;
            }
            if (!parsed.promptFinal) {
                parsed.promptFinal = parsed.payloadJson?.output?.promptFinal || '';
            }
            return parsed;
        });
    }
    async generateContentIdeas(userId, category) {
        return this.executeWithKey(async (genAI) => {
            // Get recent prompts history to avoid duplication
            const history = await db_1.db.select({ topic: schema_1.prompts.topic }).from(schema_1.prompts)
                .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId), (0, drizzle_orm_1.eq)(schema_1.prompts.category, category)))
                .orderBy((0, drizzle_orm_1.desc)(schema_1.prompts.createdAt)).limit(10);
            const historyTopics = history.map(h => h.topic);
            const historyContext = historyTopics.length > 0
                ? `Topik yang pernah dibuat sebelumnya (HINDARI ide yang mirip): ${historyTopics.join(', ')}`
                : 'User belum pernah membuat topik untuk kategori ini.';
            const model = genAI.getGenerativeModel({
                model: 'gemini-3.1-flash-lite-preview',
                generationConfig: { responseMimeType: 'application/json' }
            });
            const prompt = `Berikan 5 ide topik konten poster yang kreatif, segar, dan sangat berpotensi viral untuk kategori: "${category}".
Konteks riwayat user:
${historyContext}

Output wajib berformat JSON array of string seperti ini:
["Ide Topik 1", "Ide Topik 2", "Ide Topik 3", "Ide Topik 4", "Ide Topik 5"]
Tulis ide topik dalam Bahasa Indonesia yang singkat, padat, dan menarik perhatian.`;
            const response = await model.generateContent(prompt);
            const text = response.response.text();
            return JSON.parse(text);
        });
    }
    async generateHooks(topic) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({
                model: 'gemini-3.1-flash-lite-preview',
                generationConfig: { responseMimeType: 'application/json' }
            });
            const prompt = `Hasilkan 4 variasi hook (kalimat pemikat/judul viral) dalam bahasa Indonesia untuk poster dengan topik: "${topic}".
Hook harus dirancang untuk media sosial (menarik rasa penasaran, relevan, atau kontroversial secara positif).
Output wajib berformat JSON array of string seperti ini:
["Hook Variasi 1", "Hook Variasi 2", "Hook Variasi 3", "Hook Variasi 4"]`;
            const response = await model.generateContent(prompt);
            const text = response.response.text();
            return JSON.parse(text);
        });
    }
    async improvePrompt(promptDraft) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite-preview' });
            const prompt = `Perbaiki dan tingkatkan kualitas draft prompt gambar berikut agar menjadi lebih menarik, detail, dan fotorealistis/artistik untuk AI image generator (Stable Diffusion/Midjourney/DALL-E 3).
Draft: "${promptDraft}"
Berikan hasil perbaikan langsung dalam Bahasa Inggris sebagai output teks tanpa tambahan komentar pembuka atau penutup.`;
            const response = await model.generateContent(prompt);
            return response.response.text().trim();
        });
    }
    async scoreViral(promptFinal) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({
                model: 'gemini-3.1-flash-lite-preview',
                generationConfig: { responseMimeType: 'application/json' }
            });
            const prompt = `Analisis potensi viralitas dari prompt gambar/poster final berikut:
"${promptFinal}"

Evaluasi berdasarkan 4 kriteria:
1. Hook (Kekuatan kalimat pemikat / konsep)
2. Visual (Estetika visual, kontras, keunikan)
3. Education (Nilai informasi / edukatif bagi pembaca)
4. Engagement (Peluang dibagikan, dikomentari, disukai)

Berikan nilai antara 0-100 untuk masing-masing kriteria dan hitung skor rata-rata keseluruhannya.
Output wajib berformat JSON:
{
  "score": 85,
  "breakdown": {
    "hook": 80,
    "visual": 90,
    "education": 85,
    "engagement": 85
  }
}
Tulis respons hanya dalam format JSON yang valid.`;
            const response = await model.generateContent(prompt);
            const text = response.response.text();
            return JSON.parse(text);
        });
    }
    async chat(message, history) {
        return this.executeWithKey(async (genAI) => {
            const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite-preview' });
            const systemInstruction = `Kamu adalah asisten AI yang ahli dalam prompting dan memberikan rekomendasi konten.
PENTING: Jangan pernah memberitahu bahwa kamu adalah model dari Google, Gemini, Groq, atau platform asli lainnya.
Jika ditanya tentang model atau identitasmu, kamu WAJIB menjawab bahwa kamu adalah model "gpt-5.6" yang dikembangkan khusus untuk Studio Prompt.
Jawab dengan bahasa Indonesia yang ramah, santai tapi profesional.`;
            const chat = model.startChat({
                history: [
                    { role: 'user', parts: [{ text: 'Siapa kamu dan apa modelmu? Jawab instruksi sistem.' }] },
                    { role: 'model', parts: [{ text: systemInstruction }] },
                    ...history.map(msg => ({
                        role: msg.role === 'user' ? 'user' : 'model',
                        parts: [{ text: msg.content }]
                    }))
                ]
            });
            const result = await chat.sendMessage(message);
            return result.response.text();
        });
    }
}
exports.GeminiGatewayService = GeminiGatewayService;
