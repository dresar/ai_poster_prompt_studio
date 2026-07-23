import { GeminiClient } from '../core/gemini-client';
import { db } from '../../../config/db';
import { prompts } from '../../../db/schema';
import { eq, and, desc } from 'drizzle-orm';

export class ChatAssistantService {
  constructor(private geminiClient: GeminiClient) {}

  async generateContentIdeas(userId: string, category: string, slideCount?: number): Promise<string[]> {
    const history = await db.select({ topic: prompts.topic }).from(prompts)
      .where(and(eq(prompts.userId, userId), eq(prompts.category, category)))
      .orderBy(desc(prompts.createdAt)).limit(10);

    const historyTopics = history.map(h => h.topic);
    const historyContext = historyTopics.length > 0
      ? `Topik yang pernah dibuat sebelumnya oleh pengguna (HINDARI ide yang mirip): ${historyTopics.join(', ')}`
      : 'User belum pernah membuat topik untuk kategori ini.';

    let slideInstructions = '';
    if (slideCount && slideCount > 1) {
      const contentSlides = slideCount - 1;
      slideInstructions = `Topik harus dirancang khusus untuk format carousel dengan TEPAT ${slideCount} slide, di mana slide pertama didedikasikan untuk Cover & Hook utama. Oleh karena itu, buatlah ide topik yang memiliki tepat ${contentSlides} cara / langkah / tips / fakta penting (misalnya: "5 Cara...", "5 Langkah...", "5 Tips...").`;
    }

    const prompt = `Kamu adalah Senior Content Strategist & Virality Specialist media sosial. Hasilkan tepat 5 ide topik konten nyata yang SANGAT MENARIK, VIRAL, EDUKATIF, DAN SIAP PAKAI untuk format media "${category}".

ATURAN WAJIB (STRICT RULES):
1. PERINTAH KRUSIAL: "${category}" adalah NAMA FORMAT/KATEGORI MEDIA, BUKAN SUBJEK ISI KONTEN! DILARANG KERAS menghasilkan ide topik tentang "cara membuat ${category}", "definisi ${category}", atau "sejarah ${category}".
2. Sebaliknya, buatlah 5 ide topik KONTEN NYATA berbobot dari berbagai bidang industri populer (misalnya: Finansial & Keuangan, Kesehatan & Medis, Bisnis & Digital Marketing, Psikologi & Karir, Sains & AI, Kuliner & Lifestyle, Pengembangan Diri, dsb.).
3. ${historyContext}
4. ${slideInstructions}
5. Kembalikan respons HANYA berupa array JSON of string berisi 5 judul topik pendek & menarik, contoh: ["5 Tips Mengatur Keuangan di Usia 20-an", "4 Cara Efektif Mengatasi Burnout Kerja", "5 Rahasia Sukses Bisnis Digital 2026", "4 Kebiasaan Kecil Meningkatkan Fokus Otak", "5 Mitos Kesehatan yang Masih Dipercaya"].
6. DILARANG SERTAKAN TEKS PENJELASAN ATAU MARKDOWN DI LUAR JSON ARRAY.`;

    return this.geminiClient.executeWithKey(async (genAI) => {
      const model = genAI.getGenerativeModel({
        model: 'gemini-3.1-flash-lite',
        generationConfig: { responseMimeType: 'application/json' }
      });
      const response = await model.generateContent(prompt);
      const parsed = JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
      if (Array.isArray(parsed)) return parsed;
      for (const val of Object.values(parsed)) {
        if (Array.isArray(val)) return val as string[];
      }
      return [];
    });
  }

  async chat(message: string, history: any[]): Promise<string> {
    const systemInstruction = `Kamu adalah asisten AI yang ahli dalam prompting dan memberikan rekomendasi konten.
PENTING: Jangan pernah memberitahu bahwa kamu adalah model dari Google, Gemini, atau platform asli lainnya.
Jika ditanya tentang model atau identitasmu, kamu WAJIB menjawab bahwa kamu adalah model "gpt-5.6" yang dikembangkan khusus untuk PROMTING STUDIO.
Jawab dengan bahasa Indonesia yang ramah, santai tapi profesional.`;

    return this.geminiClient.executeWithKey(async (genAI) => {
      const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });
      const chat = model.startChat({
        history: [
          { role: 'user', parts: [{ text: 'Siapa kamu dan apa modelmu? Jawab instruksi sistem.' }] },
          { role: 'model', parts: [{ text: systemInstruction }] },
          ...history.map(msg => ({ role: msg.role === 'user' ? 'user' : 'model', parts: [{ text: msg.content }] }))
        ]
      });
      const response = await chat.sendMessage(message);
      return response.response.text();
    });
  }
}
