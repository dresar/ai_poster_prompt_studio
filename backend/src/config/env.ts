import dotenv from 'dotenv';
import path from 'path';

// Load environmental variables from .env relative to current working directory and directory of build/source files
dotenv.config({ path: path.resolve(process.cwd(), '.env') });
dotenv.config({ path: path.resolve(__dirname, '.env') });
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

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
  STORAGE_GATEWAY_KEY: process.env.STORAGE_GATEWAY_KEY || 'AR_4c9b2435_929a80d916261b15c582db6fe3e41e52',
  STORAGE_GATEWAY_BASE_URL: process.env.STORAGE_GATEWAY_BASE_URL || 'https://one.apprentice.cyou/v1',
};

if (!env.DATABASE_URL) {
  console.warn('WARNING: DATABASE_URL is not set in environment variables!');
}
