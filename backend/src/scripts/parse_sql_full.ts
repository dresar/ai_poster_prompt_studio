import fs from 'fs';
import path from 'path';

const inputPath = path.resolve(__dirname, '../../../character_bible_inserts copy.sql');
const content = fs.readFileSync(inputPath, 'utf8');

// The SQL file contains multiple INSERT INTO characters (...) VALUES (...)
// We can split by "INSERT INTO characters"
const inserts = content.split('INSERT INTO characters').filter(s => s.trim().length > 0);

console.log(`Found ${inserts.length} characters to insert.`);
let newSql = '';

inserts.forEach((insert, idx) => {
    // Extract name, category, description, prompt_consistency
    // The format is VALUES (\n'Name',\n'Category',\n'Desc',\n'Prompt',...
    
    // We can just use a regex to match the first 4 string literals
    const matches = [...insert.matchAll(/'((?:[^'\\]|\\.)*)'/g)];
    
    if (matches.length >= 8) {
        const name = matches[0][1];
        const category = matches[1][1];
        const description = matches[2][1];
        // Use positive_prompt (index 5) instead of the short prompt_consistency (index 3)
        const promptConsistency = matches[5][1]; 
        newSql += `INSERT INTO "Character" (id, name, category, description, "promptConsistency") VALUES (gen_random_uuid(), '${name.replace(/'/g, "''")}', '${category.replace(/'/g, "''")}', '${description.replace(/'/g, "''")}', '${promptConsistency.replace(/'/g, "''")}');\n`;
    }
});

const cleanupSql = `DELETE FROM "Character" WHERE name IN ('Si Piko', 'Bubu si Beruang', 'Nino si Ninja', 'Astro-Bot', 'Profesor Hoot');\n`;
fs.writeFileSync(inputPath, cleanupSql + newSql);
console.log('Successfully updated character_bible_inserts copy.sql with 5 characters (using positive prompt).');
