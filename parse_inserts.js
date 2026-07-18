const fs = require('fs');

const inputPath = 'c:\\Users\\NCN0C\\Documents\\ai_poster_prompt_studio\\character_bible_inserts.sql';
let content = fs.readFileSync(inputPath, 'utf8');

// We have INSERT INTO characters (...) VALUES (\n 'Name',\n 'Cat',\n 'Desc',\n 'Prompt', ...
const matches = [...content.matchAll(/INSERT INTO characters [^\(]+\([^)]+\)\s*VALUES\s*\(\s*'([^']*)',\s*'([^']*)',\s*'([^']*)',\s*'([^']*)'/g)];

let newSql = '';

matches.forEach((match) => {
    const name = match[1];
    const category = match[2];
    const description = match[3];
    const promptConsistency = match[4];
    
    newSql += `INSERT INTO "Character" (id, name, category, description, "promptConsistency") VALUES (gen_random_uuid(), '${name}', '${category}', '${description}', '${promptConsistency}');\n`;
});

console.log(newSql);

fs.writeFileSync(inputPath, newSql);
console.log('Successfully updated the SQL file.');
