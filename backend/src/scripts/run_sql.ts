import fs from 'fs';
import postgres from 'postgres';
import path from 'path';
import * as dotenv from 'dotenv';

dotenv.config({ path: path.join(__dirname, '../../.env') });

const DATABASE_URL = process.env.DATABASE_URL || "postgresql://neondb_owner:npg_5NI8UiELsJGf@ep-holy-flower-aol5j8zd-pooler.c-2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require";

async function run() {
  console.log('Connecting to database...');
  const sql = postgres(DATABASE_URL);
  
  try {
    const filePath = path.resolve(__dirname, '../../../character_bible_inserts copy.sql');
    console.log(`Reading file: ${filePath}`);
    const query = fs.readFileSync(filePath, 'utf-8');
    
    console.log('Executing query...');
    // unsafe enables running raw strings, including multiple statements.
    await sql.unsafe(query);
    console.log('Successfully inserted data into the database!');
  } catch (err) {
    console.error('Error executing query:', err);
  } finally {
    await sql.end();
  }
}

run();
