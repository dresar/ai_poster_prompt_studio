import { GeminiClient } from '../core/gemini-client';
import { GroqClient } from '../core/groq-client';

export class TopicAnalyzerService {
  constructor(private geminiClient: GeminiClient, private groqClient: GroqClient) {}

  async analyzeTopic(topic: string, category: string | undefined, provider: 'gemini' | 'groq'): Promise<{
    description: string;
    keyPoints: string[];
    visualRecommendation: string;
    hook?: string;
    cta?: string;
  }> {
    const isEdukasi = category === 'edukasi';
    const isVideo = category === 'video';

    let typeName = "poster/infografis";
    if (isEdukasi) typeName = "carousel edukasi";
    else if (isVideo) typeName = "video";
    else if (category) typeName = category;

    const prompt = `Berikan analisis mendalam dan ide konten untuk topik ${typeName} berikut: "${topic}".
Output harus berformat JSON dengan struktur berikut:
{
  "description": "Penjelasan dan ringkasan materi secara SANGAT mendalam, komprehensif, panjang, dan detail (berupa deskripsi detail yang komprehensif, minimal 3 paragraf panjang atau 150-250 kata). Uraikan latar belakang topik, masalah utama yang dibahas, urgensi dari topik tersebut, serta rangkuman lengkap solusinya. DILARANG keras menggunakan kata 'poster' atau 'infografis' jika kategori bukan poster.",
  "keyPoints": [
    "Poin penting 1: Tuliskan nama poin/sub-topik diikuti dengan penjelasan konsep yang SANGAT mendalam, detail, dan komprehensif (minimal 50-80 kata per poin). Jelaskan secara gamblang latar belakang poin ini, bagaimana cara kerjanya, contoh konkret penerapannya, serta apa manfaat/dampaknya bagi pembaca. Uraikan sedetail mungkin.",
    "Poin penting 2: (lakukan penjelasan mendalam yang sama seperti poin 1)",
    "Poin penting 3: (lakukan penjelasan mendalam yang sama seperti poin 1)",
    "Poin penting 4 (jika ada, lakukan penjelasan mendalam)",
    "Poin penting 5 (jika ada, lakukan penjelasan mendalam)"
  ],
  "visualRecommendation": "Rekomendasi konsep visual, tata letak, mood, pencahayaan, objek utama, dan palet warna yang paling cocok secara detail (minimal 2-3 kalimat lengkap)",
  "hook": "Satu kalimat Hook / Kalimat Pemikat yang sangat menarik perhatian, relevan, memicu rasa penasaran, atau viral untuk topik ini",
  "cta": "Satu kalimat Call to Action (CTA) / ajakan yang kuat dan persuasif yang relevan dengan topik ini"
}
Aturan Penting:
1. Bagian 'description' harus berupa penjelasan ringkasan materi secara SANGAT mendalam, detail, dan lengkap (minimal 3 paragraf atau 150-250 kata). Dilarang menulis penjelasan singkat atau sekadar ringkasan ringkas. Dilarang menyebut kata 'poster' atau 'infografis' di dalamnya (kecuali jika tipe/kategori adalah poster).
2. Bagian 'keyPoints' harus berupa penjelasan detail untuk masing-masing poin (bukan hanya judul singkat saja, melainkan judul diikuti penjelasan rinci, contoh konkret, dan dampak informatif yang sangat detail, minimal 50-80 kata per poin).
3. Hasilkan juga 'hook' (kalimat pemikat yang menarik minat pembaca) dan 'cta' (kalimat ajakan bertindak) yang sesuai dengan materi/topik.
Tulis respons hanya dalam format JSON yang valid, gunakan bahasa Indonesia.`;

    const cleanAnalysis = (data: any) => {
      console.log('cleanAnalysis called. category:', category, 'description type:', typeof data?.description);
      if (data && typeof data.description === 'string' && category && category !== 'poster') {
        const oldDesc = data.description;
        data.description = data.description
          .replace(/\bposter\b/gi, 'materi')
          .replace(/\binfografis\b/gi, 'materi');
        console.log('cleanAnalysis regex replacement. Old:', oldDesc, 'New:', data.description);
      }
      return data;
    };

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const response = await this.groqClient.post(apiKey, {
          model: 'llama-3.3-70b-versatile',
          response_format: { type: 'json_object' },
          messages: [
            {
              role: 'system',
              content: 'Kamu adalah analis konten media sosial dan content strategist profesional. Kembalikan respons HANYA dalam format JSON valid sesuai skema yang diminta, tanpa komentar atau teks tambahan.'
            },
            { role: 'user', content: prompt }
          ],
        });
        const text = response.choices[0]?.message?.content || '{}';
        const parsed = JSON.parse(this.groqClient.sanitizeJson(text));
        return cleanAnalysis(parsed);
      });
    } else {
      return this.geminiClient.executeWithKey(async (genAI) => {
        const model = genAI.getGenerativeModel({
          model: 'gemini-1.5-pro',
          generationConfig: { responseMimeType: 'application/json' }
        });
        const response = await model.generateContent(prompt);
        const parsed = JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
        return cleanAnalysis(parsed);
      });
    }
  }

  async generateHooks(topic: string, provider: 'gemini' | 'groq'): Promise<string[]> {
    const prompt = `Hasilkan 4 variasi hook (kalimat pemikat/judul viral) dalam bahasa Indonesia untuk poster dengan topik: "${topic}".
Hook harus dirancang untuk media sosial (menarik rasa penasaran, relevan, atau kontroversial secara positif).
Output wajib berformat JSON array of string seperti ini:
["Hook Variasi 1", "Hook Variasi 2", "Hook Variasi 3", "Hook Variasi 4"]`;

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const wrappedPrompt = `Hasilkan 4 variasi hook (kalimat pemikat/judul viral) dalam bahasa Indonesia untuk poster dengan topik: "${topic}".
Hook harus dirancang untuk media sosial (menarik rasa penasaran, relevan, atau kontroversial secara positif).
Output wajib berformat JSON object dengan key "hooks" berisi array string:
{"hooks": ["Hook Variasi 1", "Hook Variasi 2", "Hook Variasi 3", "Hook Variasi 4"]}`;
        const response = await this.groqClient.post(apiKey, {
          model: 'llama-3.3-70b-versatile',
          response_format: { type: 'json_object' },
          messages: [
            {
              role: 'system',
              content: 'Kamu adalah copywriter viral media sosial profesional. Kembalikan respons HANYA dalam format JSON valid dengan key "hooks" berisi array string hook yang menarik.'
            },
            { role: 'user', content: wrappedPrompt }
          ],
        });
        const text = response.choices[0]?.message?.content || '{}';
        const parsed = JSON.parse(this.groqClient.sanitizeJson(text));
        if (Array.isArray(parsed)) return parsed;
        if (Array.isArray(parsed.hooks)) return parsed.hooks;
        for (const val of Object.values(parsed)) {
          if (Array.isArray(val)) return val as string[];
        }
        return [];
      });
    } else {
      return this.geminiClient.executeWithKey(async (genAI) => {
        const model = genAI.getGenerativeModel({
          model: 'gemini-3.1-flash-lite-preview',
          generationConfig: { responseMimeType: 'application/json' }
        });
        const response = await model.generateContent(prompt);
        const parsed = JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
        if (Array.isArray(parsed)) return parsed;
        for (const val of Object.values(parsed)) {
          if (Array.isArray(val)) return val;
        }
        return [];
      });
    }
  }

  async generateStoryboard(topic: string, duration: number, provider: 'gemini' | 'groq'): Promise<any> {
    const segmentCount = Math.ceil((duration || 30) / 10);
    const prompt = `Buatkan storyboard video sinematik profesional yang utuh dan terperinci untuk topik/ide berikut: "${topic}".
Video ini berdurasi ${duration} detik dan dibagi menjadi ${segmentCount} segmen masing-masing tepat 10 detik.

Kembalikan respons HANYA dalam format JSON yang valid dengan struktur data berikut (Gunakan Bahasa Indonesia):
{
  "projectSummary": {
    "title": "Judul Storyboard Video",
    "totalDuration": ${duration},
    "description": "Deskripsi alur cerita video secara keseluruhan."
  },
  "storyBible": {
    "storyType": "Narrative / Edukasi / Commercial / dll",
    "narrative": "Penjelasan narasi video...",
    "conflict": "Konflik utama cerita...",
    "resolution": "Resolusi konflik...",
    "ending": "Ending...",
    "emotionalArc": "Perkembangan emosi (misal: penasaran -> tegang -> lega)"
  },
  "characterBible": [
    {
      "name": "Karakter Utama (misal: Alex)",
      "age": "Umur",
      "height": "Tinggi badan",
      "face": "Deskripsi wajah",
      "skin": "Warna kulit",
      "eyes": "Warna/bentuk mata",
      "hair": "Gaya rambut",
      "clothes": "Pakaian permanen sepanjang scene",
      "accessories": "Aksesoris",
      "expressionDefault": "Ekspresi utama",
      "walkStyle": "Cara berjalan",
      "gesture": "Gestur khas",
      "habits": "Kebiasaan",
      "personality": "Kepribadian",
      "voiceTone": "Tone suara"
    }
  ],
  "environmentBible": [
    {
      "location": "Nama Lokasi Utama",
      "season": "Musim",
      "weather": "Cuaca",
      "time": "Waktu (Siang/Malam/dll)",
      "colors": "Skema warna dominan",
      "materials": "Material dominan",
      "atmosphere": "Atmosfer/suasana",
      "objectDensity": "Kepadatan objek",
      "fog": "Ada/tidak",
      "rain": "Ada/tidak",
      "wind": "Ada/tidak",
      "lighting": "Pencahayaan"
    }
  ],
  "cameraBible": {
    "shotSize": "Medium Shot / Close Up / dll",
    "movement": "Pan / Tilt / Orbit / dll",
    "focalLength": "35mm / 50mm / dll",
    "lens": "Anamorphic / Prime / dll",
    "depthOfField": "Shallow / Deep",
    "cameraSpeed": "Normal / Slow-motion / Fast",
    "stabilization": "Gimbal / Handheld",
    "cameraDirection": "Horizontal panning"
  },
  "motionBible": {
    "characterMovement": "Gerakan karakter utama",
    "objectMovement": "Gerakan objek di sekitar",
    "gazeDirection": "Arah pandang karakter",
    "speedRhythm": "Kecepatan dan ritme"
  },
  "sceneBreakdown": [
    {
      "sceneNumber": 1,
      "title": "Judul Scene 1 (00:00 - 00:10)",
      "goal": "Tujuan dramatis scene ini",
      "duration": 10,
      "mainSubject": "Karakter Utama",
      "action": "Aksi detail subjek utama",
      "emotion": "Emosi subjek",
      "camera": "Pengaturan kamera khusus scene ini",
      "lighting": "Pencahayaan khusus scene ini",
      "environment": "Latar lokasi scene ini",
      "transition": "Transisi visual ke scene berikutnya",
      "dialogue": "Dialog atau Voice-Over (jika ada)",
      "soundEffect": "Efek suara",
      "musicMood": "Nuansa musik pengiring",
      "timelineBreakdown": [
        { "timeRange": "0-3 detik", "action": "Aksi di detik awal" },
        { "timeRange": "3-7 detik", "action": "Aksi di pertengahan" },
        { "timeRange": "7-10 detik", "action": "Aksi di akhir" }
      ],
      "continuity": {
        "startingState": "Kondisi fisik/posisi awal subjek",
        "endingState": "Kondisi fisik/posisi akhir subjek",
        "rules": "Aturan konsistensi (posisi, pakaian, lighting)"
      }
    }
  ],
  "continuityRules": "Aturan konsistensi antar-segmen (misalnya: pakaian dan lighting tidak boleh berubah mendadak)",
  "negativePrompt": "flicker, character morphing, clothing color change, sudden lighting shifts, bad anatomy, double heads, text watermarks"
}
Tulis respons HANYA berupa JSON valid. Jangan beri penjelasan lain.`;

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const response = await this.groqClient.post(apiKey, {
          model: 'llama-3.3-70b-versatile',
          response_format: { type: 'json_object' },
          messages: [{ role: 'user', content: prompt }],
        });
        const text = response.choices[0]?.message?.content || '{}';
        return JSON.parse(this.groqClient.sanitizeJson(text));
      });
    } else {
      return this.geminiClient.executeWithKey(async (genAI) => {
        const model = genAI.getGenerativeModel({
          model: 'gemini-1.5-pro',
          generationConfig: { responseMimeType: 'application/json' }
        });
        const response = await model.generateContent(prompt);
        return JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
      });
    }
  }
}
