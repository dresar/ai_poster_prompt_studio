import { GeminiClient } from '../core/gemini-client';
import http from 'http';
import https from 'https';

export class ImageAnalyzerService {
  constructor(private geminiClient: GeminiClient) {}

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

  async analyzeReferenceImage(imageUrl: string): Promise<string> {
    return await this.geminiClient.executeWithKey(async (genAI) => {
      const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });
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
}
