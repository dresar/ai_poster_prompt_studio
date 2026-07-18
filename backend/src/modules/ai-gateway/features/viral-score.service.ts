import { GeminiClient } from '../core/gemini-client';
import { GroqClient } from '../core/groq-client';

export class ViralScoreService {
  constructor(private geminiClient: GeminiClient, private groqClient: GroqClient) {}

  async scoreViral(promptFinal: string, provider: 'gemini' | 'groq'): Promise<{
    score: number;
    breakdown: { hook: number; visual: number; education: number; engagement: number; };
  }> {
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
        const model = genAI.getGenerativeModel({
          model: 'gemini-3.1-flash-lite-preview',
          generationConfig: { responseMimeType: 'application/json' }
        });
        const response = await model.generateContent(prompt);
        return JSON.parse(this.geminiClient.sanitizeJson(response.response.text()));
      });
    }
  }
}
