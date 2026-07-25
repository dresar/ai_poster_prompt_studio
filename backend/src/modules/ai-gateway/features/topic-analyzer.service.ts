import { GeminiClient } from '../core/gemini-client';

export class TopicAnalyzerService {
  constructor(private geminiClient: GeminiClient) {}

  async analyzeTopic(topic: string, category?: string): Promise<{
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

    const genericFormatKeywords = ['poster', 'poster edukasi', 'edukasi', 'banner', 'spanduk', 'baliho', 'berita', 'iklan', 'produk', 'logo', 'quotes', 'kata mutiara', 'video', 'karakter', 'gaya visual'];
    const cleanTopic = (topic || '').trim().toLowerCase();
    const isGenericTopic = genericFormatKeywords.includes(cleanTopic) || cleanTopic.length <= 3;

    let topicInstruction = `topik ${typeName} berikut: "${topic}"`;
    if (isGenericTopic) {
      topicInstruction = `kategori ${typeName}. PERINTAH UTAMA: Input user "${topic}" adalah NAMA FORMAT MEDIA, BUKAN TOPIK ISI MATERI! DILARANG KERAS menganalisis kata "${topic}" atau "poster" sebagai subjek materi utama. Sebaliknya, PILIHLAH 1 TOPIK KONTEN REAL YANG VIRAL, EDUKATIF/PROMOSI, DAN SANGAT SPESIFIK (misalnya tentang Finansial, Kesehatan, Bisnis Digital, Karir, Sains/AI, atau Lifestyle) dan hasilkan analisis komprehensif untuk topik konten tersebut!`;
    }

    const prompt = `Berikan analisis mendalam dan ide konten untuk ${topicInstruction}.
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
      if (data && typeof data.description === 'string' && category && category !== 'poster') {
        data.description = data.description
          .replace(/\bposter\b/gi, 'materi')
          .replace(/\binfografis\b/gi, 'materi');
      }
      return data;
    };

    return this.geminiClient.executeWithKey(async (genAI) => {
      const model = genAI.getGenerativeModel({
        model: 'gemini-3.1-flash-lite',
        generationConfig: { responseMimeType: 'application/json' }
      });
      const response = await model.generateContent(prompt);
      const parsed = JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
      return cleanAnalysis(parsed);
    });
  }

  async generateHooks(topic: string): Promise<string[]> {
    const prompt = `Hasilkan 4 variasi hook (kalimat pemikat/judul viral) dalam bahasa Indonesia untuk poster dengan topik: "${topic}".
Hook harus dirancang untuk media sosial (menarik rasa penasaran, relevan, atau kontroversial secara positif).
Output wajib berformat JSON array of string seperti ini:
["Hook Variasi 1", "Hook Variasi 2", "Hook Variasi 3", "Hook Variasi 4"]`;

    return this.geminiClient.executeWithKey(async (genAI) => {
      const model = genAI.getGenerativeModel({
        model: 'gemini-3.1-flash-lite',
        generationConfig: { responseMimeType: 'application/json' }
      });
      const response = await model.generateContent(prompt);
      return JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
    });
  }
}
