const { GoogleGenerativeAI } = require('@google/generative-ai');

async function testNativeGeminiSDK() {
  console.log('🚀 Testing Native @google/generative-ai SDK Key Rotation & Models...');

  const apiKey = process.env.GEMINI_API_KEY || 'AIzaSyA_sample_or_env_key';
  const models = ['gemini-3.1-flash-lite', 'gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'];

  if (!process.env.GEMINI_API_KEY) {
    console.warn('⚠️ No GEMINI_API_KEY set in process.env, testing SDK initialization.');
  }

  for (const modelName of models) {
    console.log(`\n🧪 Testing SDK model: ${modelName}...`);
    try {
      const genAI = new GoogleGenerativeAI(apiKey);
      const model = genAI.getGenerativeModel({ model: modelName });
      console.log(`  ✅ Model ${modelName} initialized via SDK successfully!`);
    } catch (err) {
      console.error(`  ❌ SDK model ${modelName} error:`, err?.message || err);
    }
  }
}

testNativeGeminiSDK();
