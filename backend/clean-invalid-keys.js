require('dotenv').config();

const { GoogleGenerativeAI } = require('@google/generative-ai');
const { db } = require('./src/config/db');
const { geminiApiKeys } = require('./src/db/schema');
const { decrypt } = require('./src/core/utils/encryption');
const { eq } = require('drizzle-orm');

async function cleanInvalidKeys() {
  console.log('🔍 Rigorous testing of all keys in database against Google Gemini API...');
  const keys = await db.select().from(geminiApiKeys).where(eq(geminiApiKeys.provider, 'gemini'));
  console.log(`📋 Found ${keys.length} total keys in database.`);

  let workingCount = 0;
  let deletedCount = 0;

  for (let i = 0; i < keys.length; i++) {
    const keyObj = keys[i];
    let apiKey = keyObj.keyEncrypted;
    if (keyObj.isEncrypted) {
      try {
        apiKey = decrypt(apiKey);
      } catch (err) {
        console.warn(`[${i+1}/${keys.length}] ❌ Decrypt failed for key ${keyObj.id}. Deleting.`);
        await db.delete(geminiApiKeys).where(eq(geminiApiKeys.id, keyObj.id));
        deletedCount++;
        continue;
      }
    }

    try {
      const genAI = new GoogleGenerativeAI(apiKey);
      const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });
      await model.generateContent('Hi');
      console.log(`[${i+1}/${keys.length}] ✅ Key ${keyObj.id} (${apiKey.substring(0, 10)}...): WORKING!`);
      
      // Update healthStatus to healthy and priority
      await db.update(geminiApiKeys)
        .set({ healthStatus: 'healthy', priority: workingCount })
        .where(eq(geminiApiKeys.id, keyObj.id));
      
      workingCount++;
    } catch (err) {
      const errMsg = err?.message || String(err);
      console.warn(`[${i+1}/${keys.length}] ❌ Key ${keyObj.id} (${apiKey.substring(0, 10)}...) FAILED: ${errMsg.substring(0, 80)} -> Deleting from DB.`);
      await db.delete(geminiApiKeys).where(eq(geminiApiKeys.id, keyObj.id));
      deletedCount++;
    }
  }

  console.log(`\n🎉 RIGOROUS CLEANUP FINISHED!`);
  console.log(`   Working Keys: ${workingCount}`);
  console.log(`   Deleted Keys: ${deletedCount}`);
  process.exit(0);
}

cleanInvalidKeys().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
