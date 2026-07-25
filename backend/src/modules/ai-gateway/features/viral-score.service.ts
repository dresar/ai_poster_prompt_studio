import { GeminiClient } from '../core/gemini-client';

export class ViralScoreService {
  constructor(private geminiClient: GeminiClient) {}

  async evaluateScore(promptFinal: string): Promise<{
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
