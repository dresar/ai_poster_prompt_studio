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
      ? `Topik yang pernah dibuat sebelumnya (HINDARI ide yang mirip): ${historyTopics.join(', ')}`
      : 'User belum pernah membuat topik untuk kategori ini.';

    let slideInstructions = '';
    if (slideCount && slideCount > 1) {
      const contentSlides = slideCount - 1;
      slideInstructions = `\nTopik harus dirancang khusus untuk format carousel dengan TEPAT ${slideCount} slide, di mana slide pertama didedikasikan untuk Cover & Hook utama. Oleh karena itu, buatlah ide topik yang memiliki tepat ${contentSlides} cara / langkah / tips / fakta penting (misalnya: "5 Cara...", "5 Langkah...", "5 Tips...").`;
    }

    const prompt = `Kamu adalah Content Strategist media sosial profesional. Hasilkan tepat 5 ide topik konten yang sangat menarik, kreatif, spesifik, dan siap pakai untuk kategori "${category}".
Aturan Wajib:
1. Setiap topik harus sangat relevan dengan kategori "${category}".
2. ${historyContext}
3. ${slideInstructions}
4. Kembalikan respons HANYA berupa array JSON of string berisi 5 judul topik pendek, misalnya: ["Judul 1", "Judul 2", "Judul 3", "Judul 4", "Judul 5"].
5. Jangan sertakan teks penjelasan atau markdown di luar JSON array.`;

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

  async generateResponse(messages: Array<{ role: string; content: string }>, systemInstruction?: string): Promise<string> {
    const sys = systemInstruction || `Kamu adalah asisten AI dari PROMTING STUDIO.`;
    return this.geminiClient.generateChatCompletion([
      { role: 'system', content: sys },
      ...messages
    ]);
  }
}
