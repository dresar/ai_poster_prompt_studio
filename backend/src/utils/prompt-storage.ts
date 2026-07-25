import path from 'path';
import fs from 'fs';
import { logger } from '../config/logger';

const storageBaseDir = path.join(process.cwd(), 'storage', 'prompts');

// Ensure storage directory exists with 0755 permissions
try {
  if (!fs.existsSync(storageBaseDir)) {
    fs.mkdirSync(storageBaseDir, { recursive: true });
  }
  try { fs.chmodSync(storageBaseDir, 0o755); } catch (_) {}
} catch (e) {
  logger.error(`Error initializing prompt storage directory: ${e}`);
}

/**
 * Save prompt JSON payload to disk storage (.json)
 */
export function savePromptJson(id: string, payload: any): string {
  try {
    if (!fs.existsSync(storageBaseDir)) {
      fs.mkdirSync(storageBaseDir, { recursive: true });
    }
    const filename = `${id}.json`;
    const fullPath = path.join(storageBaseDir, filename);
    const relativePath = path.join('storage', 'prompts', filename);

    const jsonString = typeof payload === 'string' ? payload : JSON.stringify(payload, null, 2);
    fs.writeFileSync(fullPath, jsonString, 'utf8');
    try { fs.chmodSync(fullPath, 0o644); } catch (_) {}

    return relativePath;
  } catch (err) {
    logger.error(`Failed to save prompt JSON to disk storage: ${err}`);
    return '';
  }
}

/**
 * Read prompt JSON payload from disk storage (.json)
 */
export function readPromptJson(id: string, storagePath?: string): any {
  try {
    let fullPath = path.join(storageBaseDir, `${id}.json`);
    if (storagePath && storagePath.trim().length > 0) {
      fullPath = path.isAbsolute(storagePath) ? storagePath : path.join(process.cwd(), storagePath);
    }

    if (fs.existsSync(fullPath)) {
      const raw = fs.readFileSync(fullPath, 'utf8');
      return JSON.parse(raw);
    }
  } catch (err) {
    logger.warn(`Failed to read prompt JSON from disk storage (${id}): ${err}`);
  }
  return null;
}

/**
 * Delete prompt JSON payload file from disk storage (.json)
 */
export function deletePromptJson(id: string, storagePath?: string): void {
  try {
    let fullPath = path.join(storageBaseDir, `${id}.json`);
    if (storagePath && storagePath.trim().length > 0) {
      fullPath = path.isAbsolute(storagePath) ? storagePath : path.join(process.cwd(), storagePath);
    }

    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
      logger.info(`Deleted prompt JSON storage file: ${fullPath}`);
    }
  } catch (err) {
    logger.warn(`Failed to delete prompt JSON storage file (${id}): ${err}`);
  }
}
