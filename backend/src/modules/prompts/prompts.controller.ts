import { Request, Response, NextFunction } from 'express';
import path from 'path';
import fs from 'fs';
import { db } from '../../config/db';
import { visualStyles, characters } from '../../db/schema';
import { eq, or, ilike } from 'drizzle-orm';
import { logger } from '../../config/logger';

const basePromptsDir = path.join(process.cwd(), 'prompts');
const stylesDir = path.join(basePromptsDir, 'styles');
const charactersDir = path.join(basePromptsDir, 'characters');

// Additional public cPanel static directories
const cpanelPublicDirs = [
  path.join(process.cwd(), 'public', 'txt'),
  path.join(process.cwd(), 'public_html', 'txt'),
  path.join(process.cwd(), 'uploads', 'txt'),
];

// Helper to write file safely to all possible cPanel directories
function writeTxtToAllLocations(subPath: string, content: string) {
  const targetDirs = [
    basePromptsDir,
    path.join(process.cwd(), 'public', 'txt'),
    path.join(process.cwd(), 'public_html', 'txt'),
    path.join(process.cwd(), 'uploads', 'txt'),
  ];

  targetDirs.forEach((dir) => {
    try {
      const fullFilePath = path.join(dir, subPath);
      const parentDir = path.dirname(fullFilePath);
      if (!fs.existsSync(parentDir)) {
        fs.mkdirSync(parentDir, { recursive: true });
      }
      fs.writeFileSync(fullFilePath, content, 'utf8');
    } catch (e) {
      // Ignore individual directory creation errors (e.g. if public_html is read-only)
    }
  });
}

// Ensure prompt directories exist
[basePromptsDir, stylesDir, charactersDir, ...cpanelPublicDirs].forEach((dir) => {
  try {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  } catch (e) {}
});

// Helper to set maximal permissive headers for AI crawlers & web fetchers
function setAiCrawlerHeaders(res: Response) {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');
  res.setHeader('Cache-Control', 'public, max-age=86400, s-maxage=86400');
  res.setHeader('X-Robots-Tag', 'all');
}

// Helper to convert string to safe slug
export function slugify(str: string): string {
  return str
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Initialize default static prompt files on server startup
 */
export async function syncPromptFilesToDisk() {
  try {
    // 1. Sync visual styles
    const activeStyles = await db.select().from(visualStyles).where(eq(visualStyles.isActive, true));
    for (const style of activeStyles) {
      const styleSlug = slugify(style.name) || style.id;
      const fileName = `${styleSlug}.txt`;
      const content = `GAYA VISUAL REFERENSI: ${style.name}\n` +
        `ID: ${style.id}\n` +
        `TEMA WARNA & ESTETIKA: Tema Terang Putih & Abu-Abu Muda Clean minimalis\n\n` +
        `PANDUAN PROMPTING LENGKAP:\n${style.promptTemplate}\n`;
      writeTxtToAllLocations(`styles/${fileName}`, content);
      writeTxtToAllLocations(fileName, content);
    }

    // Default style fallback
    const defaultStyleContent = `GAYA VISUAL OTOMATIS: Lively Clean Light Theme\n` +
      `TEMA WARNA BASE: Putih Bersih (Clean White), Off-White, Abu-Abu Muda (Light Grey). DILARANG TEMA GELAP / DARK MODE!\n` +
      `WARNA AKSEN SEGAR: Wajib padukan 1-2 sentuhan warna aksen segar yang selaras (misal: soft pastel accent, warm highlight, sentuhan gradient lembut) agar gambar terasa HIDUP, BERDIKARI, DAN DINAMIS.\n` +
      `ESTETIKA: Sederhana, bersih, tidak norak, jangan banyak warna yang bertabrakan, tanpa embel-embel ornamen menumpuk.\n` +
      `KETERBACAAN: Tipografi Swiss grid modern, kontras tinggi, sangat profesional dan berkelas.\n`;
    writeTxtToAllLocations('styles/auto.txt', defaultStyleContent);
    writeTxtToAllLocations('auto.txt', defaultStyleContent);

    // 2. Sync characters
    const activeChars = await db.select().from(characters).where(eq(characters.isActive, true));
    for (const char of activeChars) {
      const charSlug = slugify(char.name) || char.id;
      const fileName = `${charSlug}.txt`;
      const content = `KARAKTER REFERENSI BIBLE: ${char.name}\n` +
        `ID: ${char.id}\n` +
        `DESKRIPSI: ${char.description}\n\n` +
        `KONSISTENSI VISUAL:\n${char.promptConsistency}\n\n` +
        `MASTER PROMPT:\n${char.masterPrompt || char.positivePrompt || ''}\n\n` +
        `POSITIVE PROMPT:\n${char.positivePrompt || ''}\n\n` +
        `NEGATIVE PROMPT:\n${char.negativePrompt || ''}\n`;
      writeTxtToAllLocations(`characters/${fileName}`, content);
    }

    // Default character fallback
    const defaultCharContent = `KARAKTER OTOMATIS: 3D Friendly Professional Mascot\n` +
      `DESKRIPSI: Karakter 3D modern ramah dengan proporsi seimbang, ekspresi hangat, busana kasual profesional.\n` +
      `KONSISTENSI VISUAL: Pertahankan warna baju, gaya rambut, ciri fisik, dan lighting studio konsisten di semua slide.\n`;
    writeTxtToAllLocations('characters/auto.txt', defaultCharContent);

    logger.info(`[PromptsSync] Synced ${activeStyles.length} styles & ${activeChars.length} characters to disk as plain text files.`);
  } catch (error) {
    logger.error('[PromptsSync] Error syncing prompt files to disk:', error);
  }
}

/**
 * Endpoint GET /txt/styles/:slug.txt or GET /prompts/styles/:slug.txt
 */
export const getStylePromptFile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    let rawSlug = req.params.slug || '';
    rawSlug = rawSlug.replace(/\.txt$/i, '');
    const safeSlug = slugify(rawSlug);

    setAiCrawlerHeaders(res);

    const filePath = path.join(stylesDir, `${safeSlug}.txt`);
    if (fs.existsSync(filePath)) {
      return res.status(200).send(fs.readFileSync(filePath, 'utf8'));
    }

    // Fallback search DB
    const [style] = await db
      .select()
      .from(visualStyles)
      .where(or(eq(visualStyles.id, rawSlug), ilike(visualStyles.name, `%${rawSlug.replace(/-/g, ' ')}%`)));

    if (style) {
      const content = `GAYA VISUAL REFERENSI: ${style.name}\n` +
        `ID: ${style.id}\n` +
        `PANDUAN PROMPTING LENGKAP:\n${style.promptTemplate}\n`;
      writeTxtToAllLocations(`styles/${safeSlug}.txt`, content);
      writeTxtToAllLocations(`${safeSlug}.txt`, content);
      return res.status(200).send(content);
    }

    // Generic fallback for any style slug
    const fallbackText = `GAYA VISUAL REFERENSI: ${rawSlug}\n` +
      `ESTETIKA: Clean Minimalist Light Theme (Putih & Abu-abu), simpel, profesional, tanpa ornamen menumpuk.\n`;
    writeTxtToAllLocations(`styles/${safeSlug}.txt`, fallbackText);
    return res.status(200).send(fallbackText);
  } catch (error) {
    next(error);
  }
};

/**
 * Endpoint GET /txt/characters/:slug.txt or GET /prompts/characters/:slug.txt
 */
export const getCharacterPromptFile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    let rawSlug = req.params.slug || '';
    rawSlug = rawSlug.replace(/\.txt$/i, '');
    const safeSlug = slugify(rawSlug);

    setAiCrawlerHeaders(res);

    const filePath = path.join(charactersDir, `${safeSlug}.txt`);
    if (fs.existsSync(filePath)) {
      return res.status(200).send(fs.readFileSync(filePath, 'utf8'));
    }

    // Fallback search DB
    const [char] = await db
      .select()
      .from(characters)
      .where(or(eq(characters.id, rawSlug), ilike(characters.name, `%${rawSlug.replace(/-/g, ' ')}%`)));

    if (char) {
      const content = `KARAKTER REFERENSI BIBLE: ${char.name}\n` +
        `DESKRIPSI: ${char.description}\n\n` +
        `KONSISTENSI VISUAL:\n${char.promptConsistency}\n\n` +
        `MASTER PROMPT:\n${char.masterPrompt || char.positivePrompt || ''}\n`;
      writeTxtToAllLocations(`characters/${safeSlug}.txt`, content);
      return res.status(200).send(content);
    }

    // Generic fallback for any character slug
    const fallbackText = `KARAKTER REFERENSI BIBLE: ${rawSlug}\n` +
      `DESKRIPSI: Subjek karakter 3D modern ramah, konsisten dalam pose, ekspresi, dan pakaian.\n`;
    writeTxtToAllLocations(`characters/${safeSlug}.txt`, fallbackText);
    return res.status(200).send(fallbackText);
  } catch (error) {
    next(error);
  }
};

/**
 * Universal fallback endpoint GET /txt/:slug.txt
 */
export const getUniversalTextPromptFile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    let rawSlug = req.params.slug || '';
    rawSlug = rawSlug.replace(/\.txt$/i, '');
    const safeSlug = slugify(rawSlug);

    setAiCrawlerHeaders(res);

    // Check style first
    const stylePath = path.join(stylesDir, `${safeSlug}.txt`);
    if (fs.existsSync(stylePath)) {
      return res.status(200).send(fs.readFileSync(stylePath, 'utf8'));
    }

    // Check character next
    const charPath = path.join(charactersDir, `${safeSlug}.txt`);
    if (fs.existsSync(charPath)) {
      return res.status(200).send(fs.readFileSync(charPath, 'utf8'));
    }

    // Check root prompt dir next
    const rootPath = path.join(basePromptsDir, `${safeSlug}.txt`);
    if (fs.existsSync(rootPath)) {
      return res.status(200).send(fs.readFileSync(rootPath, 'utf8'));
    }

    // Return plain text prompt
    const content = `PANDUAN REFERENSI PROMPT TEXT: ${rawSlug}\n` +
      `URL: https://porto.apprentice.cyou/txt/${safeSlug}.txt\n` +
      `TIPE: Clean Light Theme Prompt Reference (Putih & Abu-abu Muda)\n`;
    return res.status(200).send(content);
  } catch (error) {
    next(error);
  }
};
