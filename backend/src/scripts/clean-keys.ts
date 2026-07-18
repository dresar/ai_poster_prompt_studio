import dotenv from 'dotenv';
import path from 'path';
dotenv.config({ path: path.join(__dirname, '../../../.env') });
dotenv.config();

import { db } from '../config/db';
import { geminiApiKeys } from '../db/schema';
import { eq, asc, and } from 'drizzle-orm';
import { decrypt } from '../core/utils/encryption';

async function cleanAndReorder() {
  console.log('--- Memulai Pembersihan dan Penataan Ulang Database API Key ---');
  
  // 1. Fetch all keys
  const allKeys = await db.select().from(geminiApiKeys);
  console.log(`Ditemukan total ${allKeys.length} kunci di database.`);
  
  let deletedCount = 0;
  const validKeys = [];

  // 2. Validate keys and delete invalid ones
  for (const k of allKeys) {
    let rawKey = k.keyEncrypted;
    if (k.isEncrypted) {
      try {
        rawKey = decrypt(rawKey);
      } catch (e) {
        console.log(`[HAPUS] Kunci ID ${k.id} gagal di-decrypt. Dihapus.`);
        await db.delete(geminiApiKeys).where(eq(geminiApiKeys.id, k.id));
        deletedCount++;
        continue;
      }
    }

    const provider = (k.provider || 'gemini').toLowerCase();
    let isValid = false;

    if (provider === 'groq') {
      isValid = rawKey.startsWith('gsk_');
    } else if (provider === 'gemini') {
      isValid = rawKey.startsWith('AIza');
    }

    if (!isValid) {
      console.log(`[HAPUS] Kunci ID ${k.id} (${provider}) tidak valid (awalan salah). Dihapus.`);
      await db.delete(geminiApiKeys).where(eq(geminiApiKeys.id, k.id));
      deletedCount++;
    } else {
      validKeys.push(k);
    }
  }

  console.log(`Berhasil menghapus ${deletedCount} kunci tidak valid/dummy.`);
  console.log(`Sisa kunci valid: ${validKeys.length}. Mulai mengurutkan ulang prioritas...`);

  // 3. Group by provider and sort by current priority ascending
  const groqKeys = validKeys.filter(k => k.provider === 'groq').sort((a, b) => (a.priority || 0) - (b.priority || 0));
  const geminiKeys = validKeys.filter(k => (k.provider || 'gemini') === 'gemini').sort((a, b) => (a.priority || 0) - (b.priority || 0));

  // 4. Update priorities to be sequential starting from 1
  async function reassign(keys: any[], providerName: string) {
    console.log(`\nMenata ulang urutan untuk ${providerName.toUpperCase()} (${keys.length} kunci):`);
    let newPriority = 1;
    for (const k of keys) {
      if (k.priority !== newPriority) {
        await db.update(geminiApiKeys).set({ priority: newPriority }).where(eq(geminiApiKeys.id, k.id));
        console.log(`[UPDATE] ${providerName} Key ID ${k.id.substring(0,8)}... -> Prioritas Lama: ${k.priority} | Prioritas Baru: ${newPriority}`);
      } else {
        console.log(`[SKIP] ${providerName} Key ID ${k.id.substring(0,8)}... -> Sudah di Prioritas ${newPriority}`);
      }
      newPriority++;
    }
  }

  await reassign(groqKeys, 'groq');
  await reassign(geminiKeys, 'gemini');

  console.log('\n--- Selesai! Database kini bersih dan urutan telah merapat! ---');
  process.exit(0);
}

cleanAndReorder().catch(e => {
  console.error('Fatal Error:', e);
  process.exit(1);
});
