import 'dotenv/config';
import postgres from 'postgres';

async function migrate() {
  const sql = postgres(process.env.DATABASE_URL as string, { ssl: 'require' });

  try {
    console.log('Altering Character table...');
    await sql.unsafe(`
      ALTER TABLE "Character" 
      ADD COLUMN IF NOT EXISTS "characterBible" jsonb,
      ADD COLUMN IF NOT EXISTS "positivePrompt" text,
      ADD COLUMN IF NOT EXISTS "negativePrompt" text,
      ADD COLUMN IF NOT EXISTS "masterPrompt" text;
    `);
    console.log('Migration completed successfully.');
  } catch (err) {
    console.error('Migration failed:', err);
  } finally {
    await sql.end();
  }
}

migrate();
