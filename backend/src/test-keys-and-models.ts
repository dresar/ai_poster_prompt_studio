import { db } from './config/db';
import { geminiApiKeys } from './db/schema';
import { GoogleGenerativeAI } from '@google/generative-ai';
import * as dotenv from 'dotenv';
dotenv.config();

const modelsToTest = [
  'gemini-1.5-flash',
  'gemini-1.5-pro',
  'gemini-2.0-flash-exp',
  'gemini-2.5-flash',
  'gemini-3.1-flash-lite',
  'gemini-3.1-flash',
  'gemini-3.1-pro',
  'gemini-3.5-flash',
];

async function run() {
  console.log('=== GEMINI KEYS AND MODELS TESTING TOOL ===');
  console.log('Connecting to database...');
  const keys = await db.select().from(geminiApiKeys);
  
  if (keys.length === 0) {
    console.log('No Gemini API keys found in the database.');
    return;
  }

  console.log(`Found ${keys.length} keys in database.\n`);

  for (let idx = 0; idx < keys.length; idx++) {
    const k = keys[idx];
    const masked = k.keyEncrypted.length > 8 
      ? `${k.keyEncrypted.substring(0, 4)}••••${k.keyEncrypted.substring(k.keyEncrypted.length - 4)}` 
      : k.keyEncrypted;

    console.log(`===============================================`);
    console.log(`Key #${idx + 1} | ID: ${k.id} | Status: ${k.healthStatus} | Active: ${k.isActive}`);
    console.log(`Masked Key: ${masked}`);
    console.log(`===============================================`);

    const genAI = new GoogleGenerativeAI(k.keyEncrypted);

    for (const modelName of modelsToTest) {
      try {
        const model = genAI.getGenerativeModel({ model: modelName });
        const response = await model.generateContent({
          contents: [{ role: 'user', parts: [{ text: 'say OK' }] }],
          generationConfig: { maxOutputTokens: 5 }
        });
        const text = response.response.text().trim();
        console.log(`  ✓ ${modelName.padEnd(23)} : [SUCCESS] Response: "${text}"`);
      } catch (err: any) {
        const errorMsg = err?.message || String(err);
        let reason = errorMsg;
        if (errorMsg.includes('404')) {
          reason = 'Model not found / Not available';
        } else if (errorMsg.includes('403')) {
          reason = 'Forbidden / Invalid API Key / Geo-blocked';
        } else if (errorMsg.includes('429')) {
          reason = 'Rate limit exceeded';
        }
        console.log(`  ✗ ${modelName.padEnd(23)} : [FAILED] ${reason}`);
      }
    }
    console.log('\n');
  }

  console.log('Done.');
  process.exit(0);
}

run().catch((err) => {
  console.error('Fatal execution error:', err);
  process.exit(1);
});
