require('dotenv').config();

const { db } = require('./src/config/db');
const { geminiApiKeys } = require('./src/db/schema');
const { eq } = require('drizzle-orm');

async function resetAllKeys() {
  console.log('🔄 Resetting all Gemini API Keys healthStatus to "healthy"...');
  const result = await db.update(geminiApiKeys)
    .set({ healthStatus: 'healthy', priority: 0 })
    .where(eq(geminiApiKeys.provider, 'gemini'))
    .returning();

  console.log(`✅ Reset ${result.length} Gemini API Keys to healthy status!`);
  process.exit(0);
}

resetAllKeys().catch(err => {
  console.error('❌ Reset failed:', err);
  process.exit(1);
});
