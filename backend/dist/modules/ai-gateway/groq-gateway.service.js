"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GroqGatewayService = void 0;
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const logger_1 = require("../../config/logger");
const errorHandler_1 = require("../../middlewares/errorHandler");
const http_1 = __importDefault(require("http"));
const https_1 = __importDefault(require("https"));
const crypto_1 = __importDefault(require("crypto"));
class GroqGatewayService {
    // Get active Groq keys ordered by priority (desc) and usageCount (asc)
    async getHealthyKeys() {
        return await db_1.db.select()
            .from(schema_1.geminiApiKeys)
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.provider, 'groq'), (0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.isActive, true), (0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.healthStatus, 'healthy')))
            .orderBy((0, drizzle_orm_1.desc)(schema_1.geminiApiKeys.priority), (0, drizzle_orm_1.asc)(schema_1.geminiApiKeys.usageCount));
    }
    // Wrapper to execute a Groq API call with auto-rotation key pool
    async executeWithKey(fn) {
        const keyPool = await this.getHealthyKeys();
        if (keyPool.length === 0) {
            throw new errorHandler_1.AppError('Tidak ada API Key Groq yang sehat/aktif saat ini.', 500, 'NO_API_KEYS');
        }
        let lastError = null;
        for (const keyObj of keyPool) {
            try {
                const apiKey = keyObj.keyEncrypted;
                const result = await fn(apiKey);
                // Success: increment usage count
                await db_1.db.update(schema_1.geminiApiKeys).set({
                    usageCount: (keyObj.usageCount || 0) + 1,
                    lastUsedAt: new Date(),
                }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, keyObj.id));
                return result;
            }
            catch (error) {
                lastError = error;
                const errorMessage = error?.message || String(error);
                logger_1.logger.warn(`Groq call failed with key ID ${keyObj.id}. Error: ${errorMessage}`);
                // Rotate on rate-limit (429), unauthorized (401), or server errors (5xx)
                const isQuotaError = errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('rate limit') || errorMessage.includes('limit exceeded');
                const isAuthError = errorMessage.includes('401') || errorMessage.includes('invalid') || errorMessage.includes('api key');
                const isNetworkOrTimeout = errorMessage.includes('timeout') || errorMessage.includes('500') || errorMessage.includes('503') || errorMessage.includes('502');
                if (isQuotaError || isAuthError || isNetworkOrTimeout) {
                    const newStatus = isQuotaError ? 'limited' : 'error';
                    await db_1.db.update(schema_1.geminiApiKeys).set({ healthStatus: newStatus }).where((0, drizzle_orm_1.eq)(schema_1.geminiApiKeys.id, keyObj.id));
                    await db_1.db.insert(schema_1.logs).values({
                        id: crypto_1.default.randomUUID(),
                        action: 'key_rotation',
                        detail: {
                            provider: 'groq',
                            keyId: keyObj.id,
                            reason: isQuotaError ? 'API Rate Limit (429)' : (isAuthError ? 'Invalid API Key (401)' : 'API Error/Timeout'),
                            error: errorMessage,
                            newStatus,
                        },
                    });
                }
            }
        }
        throw new errorHandler_1.AppError(`Seluruh API Key Groq gagal digunakan. Kendala: ${lastError?.message || lastError}`, 502, 'AI_SERVICE_ERROR');
    }
    // Fetch remote image and convert to Base64 data URI
    async fetchImageAsBase64(imageUrl) {
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
                        base64Data: buffer.toString('base64'),
                        mimeType: contentType,
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
    // Base HTTP helper for Groq POST requests
    async groqPost(apiKey, body) {
        const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
        });
        const resJson = await response.json();
        if (!response.ok) {
            const errMsg = resJson.error?.message || `Groq API Error: ${response.status} ${response.statusText}`;
            throw new Error(errMsg);
        }
        return resJson;
    }
    async analyzeReferenceImage(imageUrl) {
        return this.executeWithKey(async (apiKey) => {
            let imageInfo;
            try {
                imageInfo = await this.fetchImageAsBase64(imageUrl);
            }
            catch (err) {
                logger_1.logger.error(`Error fetching reference image for Groq: ${err?.message}`);
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
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.2-11b-vision-preview',
                messages: [
                    {
                        role: 'user',
                        content: [
                            { type: 'text', text: prompt },
                            {
                                type: 'image_url',
                                image_url: {
                                    url: `data:${imageInfo.mimeType};base64,${imageInfo.base64Data}`,
                                },
                            },
                        ],
                    },
                ],
            });
            return response.choices[0]?.message?.content || '';
        });
    }
    async analyzeTopic(topic) {
        return this.executeWithKey(async (apiKey) => {
            const prompt = `Berikan analisis mendalam dan ide konten untuk topik poster berikut: "${topic}".
Output harus berformat JSON dengan struktur berikut:
{
  "description": "Deskripsi lengkap isi infografis/poster yang menarik untuk audiens",
  "keyPoints": ["Poin penting 1", "Poin penting 2", "Poin penting 3 (maksimal 5 poin)"],
  "visualRecommendation": "Rekomendasi gaya gambar, tata letak, dan mood visual yang paling cocok untuk topik ini"
}
Tulis respons hanya dalam format JSON yang valid, gunakan bahasa Indonesia.`;
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.3-70b-versatile',
                response_format: { type: 'json_object' },
                messages: [
                    { role: 'user', content: prompt }
                ],
            });
            const text = response.choices[0]?.message?.content || '{}';
            return JSON.parse(text);
        });
    }
    async generatePrompt(fullFormState) {
        return this.executeWithKey(async (apiKey) => {
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
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.3-70b-versatile',
                response_format: { type: 'json_object' },
                messages: [
                    { role: 'user', content: prompt }
                ],
            });
            const text = response.choices[0]?.message?.content || '{}';
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
     * Generate a super-detailed photo enhancement/retouch prompt using Groq vision.
     * llama-3.2-11b-vision-preview analyzes the uploaded photo before crafting a retouch prompt.
     */
    async generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes) {
        return this.executeWithKey(async (apiKey) => {
            let imageInfo;
            try {
                imageInfo = await this.fetchImageAsBase64(imageUrl);
            }
            catch (err) {
                logger_1.logger.error(`Error fetching enhance image for Groq: ${err?.message}`);
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
            const visionPrompt = `You are an expert AI photo retouching prompt engineer.
Analyze this photo and produce a super-detailed AI image generation prompt in JSON format.

ANALYZE:
- Subject: gender, age, skin tone, facial features, hair, expression
- Lighting: type, direction, quality
- Background: what it is
- Outfit: visible clothing

ENHANCEMENT REQUEST:
- Style: ${styleDescription}
- Change Level: ${changeLevelDescription}
- Notes: ${notes || 'none'}

Return ONLY valid JSON:
{
  "payloadJson": {
    "meta": { "mode": "photo_enhance", "language": "id", "createdAt": "${new Date().toISOString()}" },
    "input": { "imageUrl": "${imageUrl}", "enhanceStyle": "${enhanceStyle}", "changeLevel": "${changeLevel}", "notes": "${notes}" },
    "analysis": {
      "subjectDescription": "...", "currentLighting": "...", "currentBackground": "...",
      "currentOutfit": "...", "skinTone": "...", "facialFeatures": "...", "enhancementOpportunities": "..."
    },
    "output": {
      "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT",
      "analysisShortcomings": "Penjelasan kondisi foto dan transformasi yang dilakukan (Bahasa Indonesia)",
      "viralScore": 0,
      "hooks": ["HOOK_1", "HOOK_2", "HOOK_3", "HOOK_4"]
    }
  },
  "promptFinal": "SUPER_DETAILED_ENGLISH_RETOUCH_PROMPT"
}

For promptFinal: Start with "Professional photo retouching of [subject]...", include style, skin, lighting, background, end with "photorealistic, 8K, sharp focus".
For hooks: Write 4 viral Indonesian captions for social media sharing.`;
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.2-11b-vision-preview',
                messages: [
                    {
                        role: 'user',
                        content: [
                            { type: 'text', text: visionPrompt },
                            { type: 'image_url', image_url: { url: `data:${imageInfo.mimeType};base64,${imageInfo.base64Data}` } },
                        ],
                    },
                ],
            });
            let text = response.choices[0]?.message?.content || '{}';
            // Strip markdown code blocks if present
            text = text.replace(/^```json\s*/i, '').replace(/```\s*$/, '').trim();
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
        return this.executeWithKey(async (apiKey) => {
            // Get recent prompts history to avoid duplication
            const history = await db_1.db.select({ topic: schema_1.prompts.topic }).from(schema_1.prompts)
                .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.prompts.userId, userId), (0, drizzle_orm_1.eq)(schema_1.prompts.category, category)))
                .orderBy((0, drizzle_orm_1.desc)(schema_1.prompts.createdAt)).limit(10);
            const historyTopics = history.map(h => h.topic);
            const historyContext = historyTopics.length > 0
                ? `Topik yang pernah dibuat sebelumnya (HINDARI ide yang mirip): ${historyTopics.join(', ')}`
                : 'User belum pernah membuat topik untuk kategori ini.';
            const prompt = `Berikan 5 ide topik konten poster yang kreatif, segar, dan sangat berpotensi viral untuk kategori: "${category}".
Konteks riwayat user:
${historyContext}

Output wajib berformat JSON array of string seperti ini:
["Ide Topik 1", "Ide Topik 2", "Ide Topik 3", "Ide Topik 4", "Ide Topik 5"]
Tulis ide topik dalam Bahasa Indonesia yang singkat, padat, dan menarik perhatian.`;
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.3-70b-versatile',
                response_format: { type: 'json_object' },
                messages: [
                    { role: 'user', content: prompt }
                ],
            });
            const text = response.choices[0]?.message?.content || '[]';
            // In Groq, sometimes Llama puts JSON inside a key or returns directly
            const parsed = JSON.parse(text);
            return Array.isArray(parsed) ? parsed : (parsed.ideas || Object.values(parsed));
        });
    }
    async generateHooks(topic) {
        return this.executeWithKey(async (apiKey) => {
            const prompt = `Hasilkan 4 variasi hook (kalimat pemikat/judul viral) dalam bahasa Indonesia untuk poster dengan topik: "${topic}".
Hook harus dirancang untuk media sosial (menarik rasa penasaran, relevan, atau kontroversial secara positif).
Output wajib berformat JSON array of string seperti ini:
["Hook Variasi 1", "Hook Variasi 2", "Hook Variasi 3", "Hook Variasi 4"]`;
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.3-70b-versatile',
                response_format: { type: 'json_object' },
                messages: [
                    { role: 'user', content: prompt }
                ],
            });
            const text = response.choices[0]?.message?.content || '[]';
            const parsed = JSON.parse(text);
            return Array.isArray(parsed) ? parsed : (parsed.hooks || Object.values(parsed));
        });
    }
    async improvePrompt(promptDraft) {
        return this.executeWithKey(async (apiKey) => {
            const prompt = `Perbaiki dan tingkatkan kualitas draft prompt gambar berikut agar menjadi lebih menarik, detail, dan fotorealistis/artistik untuk AI image generator (Stable Diffusion/Midjourney/DALL-E 3).
Draft: "${promptDraft}"
Berikan hasil perbaikan langsung dalam Bahasa Inggris sebagai output teks tanpa tambahan komentar pembuka atau penutup.`;
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.3-70b-versatile',
                messages: [
                    { role: 'user', content: prompt }
                ],
            });
            return (response.choices[0]?.message?.content || '').trim();
        });
    }
    async scoreViral(promptFinal) {
        return this.executeWithKey(async (apiKey) => {
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
  "score": 85, // rata-rata dari kriteria di bawah
  "breakdown": {
    "hook": 80,
    "visual": 90,
    "education": 85,
    "engagement": 85
  }
}
Tulis respons hanya dalam format JSON yang valid.`;
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.3-70b-versatile',
                response_format: { type: 'json_object' },
                messages: [
                    { role: 'user', content: prompt }
                ],
            });
            const text = response.choices[0]?.message?.content || '{}';
            return JSON.parse(text);
        });
    }
    async chat(message, history) {
        return this.executeWithKey(async (apiKey) => {
            const systemInstruction = `Kamu adalah asisten AI yang ahli dalam prompting dan memberikan rekomendasi konten.
PENTING: Jangan pernah memberitahu bahwa kamu adalah model dari Google, Gemini, Groq, atau platform asli lainnya.
Jika ditanya tentang model atau identitasmu, kamu WAJIB menjawab bahwa kamu adalah model "gpt-5.6" yang dikembangkan khusus untuk Studio Prompt.
Jawab dengan bahasa Indonesia yang ramah, santai tapi profesional.`;
            const messages = [
                { role: 'system', content: systemInstruction },
                ...history.map(msg => ({
                    role: msg.role === 'user' ? 'user' : 'assistant',
                    content: msg.content
                })),
                { role: 'user', content: message }
            ];
            const response = await this.groqPost(apiKey, {
                model: 'llama-3.3-70b-versatile',
                messages: messages,
            });
            return response.choices[0]?.message?.content || '';
        });
    }
}
exports.GroqGatewayService = GroqGatewayService;
