import { GeminiClient } from '../core/gemini-client';
import { GroqClient } from '../core/groq-client';
import { db } from '../../../config/db';
import { prompts } from '../../../db/schema';
import { eq, and, desc } from 'drizzle-orm';

export class ChatAssistantService {
  constructor(private geminiClient: GeminiClient, private groqClient: GroqClient) {}

  async generateContentIdeas(userId: string, category: string, provider: 'gemini' | 'groq', slideCount?: number): Promise<string[]> {
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

    const prompt = `Berikan 5 ide topik konten poster/carousel yang kreatif, segar, dan sangat berpotensi viral untuk kategori: "${category}".${slideInstructions}
Konteks riwayat user:
${historyContext}

Output wajib berformat JSON array of string seperti ini:
["Ide Topik 1", "Ide Topik 2", "Ide Topik 3", "Ide Topik 4", "Ide Topik 5"]
Tulis ide topik dalam Bahasa Indonesia yang singkat, padat, dan menarik perhatian.`;

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const response = await this.groqClient.post(apiKey, {
          model: 'llama-3.3-70b-versatile',
          response_format: { type: 'json_object' },
          messages: [{ role: 'user', content: prompt }],
        });
        const text = response.choices[0]?.message?.content || '{}';
        const parsed = JSON.parse(this.groqClient.sanitizeJson(text));
        if (Array.isArray(parsed)) return parsed;
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
          if (Array.isArray(val)) return val as string[];
        }
        return [];
      });
    }
  }

  async chat(message: string, history: any[], provider: 'gemini' | 'groq'): Promise<string> {
    const systemInstruction = `Kamu adalah asisten AI yang ahli dalam prompting dan memberikan rekomendasi konten.
PENTING: Jangan pernah memberitahu bahwa kamu adalah model dari Google, Gemini, Groq, atau platform asli lainnya.
Jika ditanya tentang model atau identitasmu, kamu WAJIB menjawab bahwa kamu adalah model "gpt-5.6" yang dikembangkan khusus untuk PROMTING STUDIO.
Jawab dengan bahasa Indonesia yang ramah, santai tapi profesional.`;

    if (provider === 'groq') {
      return this.groqClient.executeWithKey(async (apiKey) => {
        const messages = [
          { role: 'system', content: systemInstruction },
          ...history.map(msg => ({ role: msg.role === 'user' ? 'user' : 'assistant', content: msg.content })),
          { role: 'user', content: message }
        ];
        const response = await this.groqClient.post(apiKey, { model: 'llama-3.3-70b-versatile', messages });
        return response.choices[0]?.message?.content || '';
      });
    } else {
      return this.geminiClient.executeWithKey(async (genAI) => {
        const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite-preview' });
        const chat = model.startChat({
          history: [
            { role: 'user', parts: [{ text: 'Siapa kamu dan apa modelmu? Jawab instruksi sistem.' }] },
            { role: 'model', parts: [{ text: systemInstruction }] },
            ...history.map(msg => ({ role: msg.role === 'user' ? 'user' : 'model', parts: [{ text: msg.content }] }))
          ]
        });
        const result = await chat.sendMessage(message);
        return result.response.text();
      });
    }
  }
}
