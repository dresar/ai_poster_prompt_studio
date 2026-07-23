const { GoogleGenerativeAI } = require('@google/generative-ai');

const apiKey = 'AQ.Ab8RN6JFKOVwExD8FXAM-4cdJ29HeXmm08iz1AuVLT8nlQNQpg';
const models = ['gemini-3.1-flash-lite', 'gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash'];

async function run() {
  console.log('🧪 Testing model speeds and availability on Google Gemini API...');
  const genAI = new GoogleGenerativeAI(apiKey);

  for (const m of models) {
    const start = Date.now();
    try {
      const model = genAI.getGenerativeModel({ model: m });
      const res = await model.generateContent('Jelaskan 1 kata.');
      const elapsed = Date.now() - start;
      console.log(`✅ Model ${m}: ${elapsed}ms -> "${res.response.text().trim()}"`);
    } catch (err) {
      const elapsed = Date.now() - start;
      console.error(`❌ Model ${m}: ${elapsed}ms -> FAILED: ${err?.message || err}`);
    }
  }
}

run();
