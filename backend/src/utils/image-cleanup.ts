import fs from 'fs';
import path from 'path';
import { db } from '../config/db';
import { prompts, characters, visualStyles, promptTemplates } from '../db/schema';
import { logger } from '../config/logger';

/**
 * Deletes a local file if the URL points to our local storage path (/uploads/).
 */
export function deleteLocalFileByUrl(url: string | null | undefined): void {
  if (!url) return;

  try {
    // Check if the URL points to our local server uploads path
    if (url.includes('/uploads/')) {
      const parts = url.split('/uploads/');
      const fileName = parts[parts.length - 1];
      if (fileName) {
        const localPath = path.join(process.cwd(), 'uploads', fileName);
        if (fs.existsSync(localPath)) {
          fs.unlinkSync(localPath);
          logger.info(`Automatically deleted replaced/unused local file: ${fileName}`);
        }
      }
    }
  } catch (err: any) {
    logger.error(`Error deleting local file by URL (${url}): ${err?.message}`);
  }
}

/**
 * Scans the local 'uploads' folder and deletes any file that is not referenced
 * in the database (prompts, characters, visual styles, prompt templates).
 */
export async function cleanupUnusedImages(): Promise<void> {
  try {
    const uploadsDir = path.join(process.cwd(), 'uploads');
    if (!fs.existsSync(uploadsDir)) {
      return;
    }

    // Read all files currently in the uploads folder
    const files = fs.readdirSync(uploadsDir);
    if (files.length === 0) {
      return;
    }

    logger.info(`Starting automatic image cleanup. Total files in uploads: ${files.length}`);

    // Query active image urls/filenames in the database
    // 1. Prompts
    const activePrompts = await db.select({
      refUrl: prompts.referenceImageUrl,
      refUrls: prompts.referenceImageUrls
    }).from(prompts);

    // 2. Characters
    const activeCharacters = await db.select({
      imageUrl: characters.imageUrl
    }).from(characters);

    // 3. Visual Styles
    const activeStyles = await db.select({
      previewUrl: visualStyles.previewImageUrl
    }).from(visualStyles);

    // 4. Prompt Templates
    const activeTemplates = await db.select({
      previewUrl: promptTemplates.previewImageUrl
    }).from(promptTemplates);

    // Set of all active filenames/URLs
    const activeFiles = new Set<string>();

    const addUrlToSet = (url: string | null | undefined) => {
      if (!url) return;
      if (url.includes('/uploads/')) {
        const parts = url.split('/uploads/');
        const fileName = parts[parts.length - 1];
        if (fileName) {
          activeFiles.add(fileName);
        }
      } else {
        // Fallback for raw filenames
        activeFiles.add(url);
      }
    };

    // Populate active file names
    activePrompts.forEach(p => {
      addUrlToSet(p.refUrl);
      if (Array.isArray(p.refUrls)) {
        p.refUrls.forEach(url => addUrlToSet(url));
      }
    });

    activeCharacters.forEach(c => addUrlToSet(c.imageUrl));
    activeStyles.forEach(s => addUrlToSet(s.previewUrl));
    activeTemplates.forEach(t => addUrlToSet(t.previewUrl));

    // Scan and delete unused files
    let deletedCount = 0;
    for (const file of files) {
      if (!activeFiles.has(file)) {
        const filePath = path.join(uploadsDir, file);
        try {
          if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
            deletedCount++;
          }
        } catch (e: any) {
          logger.error(`Failed to delete unused image ${file}: ${e?.message}`);
        }
      }
    }

    logger.info(`Image cleanup finished. Deleted ${deletedCount} unused local images.`);
  } catch (err: any) {
    logger.error(`Error during image cleanup: ${err?.message}`);
  }
}

/**
 * Registers a cron-like interval to run image cleanup every 24 hours automatically.
 */
export function scheduleImageCleanup(): void {
  // Run once on startup (delayed by 30 seconds to not block boot)
  setTimeout(() => {
    cleanupUnusedImages();
  }, 30000);

  // Run every 24 hours
  setInterval(() => {
    cleanupUnusedImages();
  }, 24 * 60 * 60 * 1000);
}
