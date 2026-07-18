import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import * as schema from '../db/schema';
import { logger } from './logger';

const connectionString = process.env.DATABASE_URL!;

if (!connectionString) {
  logger.error('DATABASE_URL environment variable is missing!');
}

// Hapus channel_binding — tidak disuport oleh Neon HTTP driver
const cleanedUrl = connectionString?.replace(/[&?]channel_binding=\w+/g, '') ?? '';

// Neon HTTP driver: connect via HTTPS port 443, bukan TCP port 5432
// Solusi untuk cPanel/shared hosting yang blokir outbound port 5432
const sql = neon(cleanedUrl);

export const db = drizzle(sql, {
  schema,
  logger: {
    logQuery(query, params) {
      logger.debug(`Drizzle Query: ${query} - Params: ${JSON.stringify(params)}`);
    }
  }
});
