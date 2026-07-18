import postgres from 'postgres';
import fs from 'fs';
import path from 'path';
import * as dotenv from 'dotenv';

dotenv.config({ path: path.join(__dirname, '../../.env') });

const DATABASE_URL = process.env.DATABASE_URL || "postgresql://neondb_owner:npg_5NI8UiELsJGf@ep-holy-flower-aol5j8zd-pooler.c-2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require";

async function cleanup() {
  const sql = postgres(DATABASE_URL);
  try {
    console.log('Cleaning up characters...');
    await sql`DELETE FROM "Character"`; // Delete everything
    
    console.log('Re-inserting from character_bible_inserts copy.sql...');
    const filePath = path.resolve(__dirname, '../../../character_bible_inserts copy.sql');
    const query = fs.readFileSync(filePath, 'utf-8');
    await sql.unsafe(query);
    
    console.log('Done!');
  } catch(e) {
    console.error(e);
  } finally {
    await sql.end();
  }
}
cleanup();
