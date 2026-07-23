// Groq provider has been completely removed. System uses 100% Native Google Gemini SDK Key Rotation.
export class GroqClient {
  public async executeWithKey<T>(fn: any): Promise<T> {
    throw new Error('Groq provider is disabled. Use Gemini provider.');
  }
}
