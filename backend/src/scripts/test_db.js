const postgres = require('postgres');
const sql = postgres(process.env.DATABASE_URL || "postgresql://neondb_owner:npg_5NI8UiELsJGf@ep-holy-flower-aol5j8zd-pooler.c-2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require");
sql`SELECT name, "masterPrompt" FROM "Character" LIMIT 1`
  .then(console.log)
  .finally(() => sql.end());
