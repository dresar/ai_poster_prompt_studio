import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import postgres from 'postgres';

async function seed() {
  const inputPath = path.resolve(__dirname, '../../../character_bible_inserts copy.sql');
  const content = fs.readFileSync(inputPath, 'utf8');
  
  let sqlToExecute = content
    .replace(/INSERT INTO characters \(name, category, description, prompt_consistency, character_bible, positive_prompt, negative_prompt, master_prompt\) VALUES/g, 
             'INSERT INTO "Character" ("id", "name", "category", "description", "promptConsistency", "characterBible", "positivePrompt", "negativePrompt", "masterPrompt") VALUES')
    .replace(/\(\n'/g, "(gen_random_uuid(), \n'");
    
  try {
    const client = postgres(process.env.DATABASE_URL as string, { ssl: 'require' });
    
    await client.unsafe(`DELETE FROM "Character" WHERE "name" IN ('Si Piko', 'Bubu si Beruang', 'Nino si Ninja', 'Astro-Bot', 'Profesor Hoot');`);
    
    await client.unsafe(sqlToExecute);
    await client.end();
    
    console.log('Successfully seeded character bible characters.');
  } catch (err) {
    console.error('Failed to seed characters:', err);
  }
}

seed();
