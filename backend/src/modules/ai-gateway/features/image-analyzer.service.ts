import { GeminiClient } from '../core/gemini-client';
import { GroqClient } from '../core/groq-client';
import { logger } from '../../../config/logger';
import http from 'http';
import https from 'https';

export class ImageAnalyzerService {
  constructor(private geminiClient: GeminiClient, private groqClient: GroqClient) {}

  public async fetchImageAsBase64(imageUrl: string): Promise<{ base64Data: string; mimeType: string }> {
    return new Promise((resolve, reject) => {
      const client = imageUrl.startsWith('https') ? https : http;
      
      client.get(imageUrl, (res) => {
        const data: Buffer[] = [];
        
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

  public async fetchImageAsBase64Part(imageUrl: string): Promise<{ inlineData: { data: string; mimeType: string } }> {
    const { base64Data, mimeType } = await this.fetchImageAsBase64(imageUrl);
    return {
      inlineData: {
        data: base64Data,
        mimeType: mimeType,
      },
    };
  }

  async analyzeReferenceImage(imageUrl: string, provider: 'gemini' | 'groq'): Promise<string> {
    try {
      if (provider === 'groq') {
        return await this.groqClient.executeWithKey(async (apiKey) => {
          const imageInfo = await this.fetchImageAsBase64(imageUrl);
          const prompt = `Analisis gambar referensi ini secara mendalam untuk pembuatan poster.
Ekstrak elemen berikut:
1. Palet warna dominan (dan kode heksadesimal jika memungkinkan).
2. Tata letak / komposisi visual (posisi subjek, teks, whitespace).
3. Gaya seni/visual (ilustrasi modern, neubrutalism, 3D render, foto produk, retro, dll).
4. Tipografi (gaya font: sans-serif bold, serif klasik, dekoratif).
5. Nuansa / Mood (ceria, misterius, profesional, elegan).

Tulis dalam format teks terstruktur yang padat namun sangat informatif dalam bahasa Indonesia.`;

          const response = await this.groqClient.post(apiKey, {
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
      } else {
        return await this.geminiClient.executeWithKey(async (genAI) => {
          const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite-preview' });
          const imagePart = await this.fetchImageAsBase64Part(imageUrl);
          
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
    } catch (err: any) {
      logger.error(`Error analyzing reference image with ${provider}: ${err?.message}`);
      throw err;
    }
  }
}
