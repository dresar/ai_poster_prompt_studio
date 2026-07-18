import dotenv from 'dotenv';
import path from 'path';

// Load environmental variables from .env relative to current working directory
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

export const env = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '3000', 10),
  DATABASE_URL: process.env.DATABASE_URL || '',
  JWT_SECRET: process.env.JWT_SECRET || 'secret',
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'refresh-secret',
  GEMINI_API_KEY: process.env.GEMINI_API_KEY || '',
  IMAGEKIT_PUBLIC_KEY: process.env.IMAGEKIT_PUBLIC_KEY || '',
  IMAGEKIT_PRIVATE_KEY: process.env.IMAGEKIT_PRIVATE_KEY || '',
  IMAGEKIT_URL_ENDPOINT: process.env.IMAGEKIT_URL_ENDPOINT || '',
  USE_STRICT_PAYLOAD_SCHEMA: process.env.USE_STRICT_PAYLOAD_SCHEMA || 'false',
};

if (!env.DATABASE_URL) {
  console.warn('WARNING: DATABASE_URL is not set in environment variables!');
}
