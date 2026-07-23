import express from 'express';
import cors from 'cors';
import path from 'path';
import fs from 'fs';
import { env } from './config/env';
import { logger } from './config/logger';
import { errorHandler } from './middlewares/errorHandler';
import { db } from './config/db';
import { sql } from 'drizzle-orm';

import authRoutes from './modules/auth/auth.routes';
import posterRoutes from './modules/poster/poster.routes';
import historyRoutes from './modules/history/history.routes';
import dropdownRoutes from './modules/dropdown/dropdown.routes';
import adminRoutes from './modules/admin/admin.routes';
import developerRoutes from './modules/developer/developer.routes';
import syncRoutes from './modules/sync/sync.routes';
import templatesRoutes from './modules/templates/templates.routes';
import formInfoRoutes from './modules/formInfo/formInfo.routes';
import promptsRoutes from './modules/prompts/prompts.routes';
import { syncPromptFilesToDisk } from './modules/prompts/prompts.controller';

const app = express();

// 🌐 UNRESTRICTED PUBLIC ACCESS FOR AI BOTS & CRAWLERS (ChatGPT, Claude, Midjourney, DALL-E, etc.)
app.use((req, res, next) => {
  if (req.path.startsWith('/txt') || req.path.startsWith('/prompts') || req.path === '/robots.txt') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', '*');
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Cache-Control', 'public, max-age=86400, s-maxage=86400');
    res.setHeader('X-Robots-Tag', 'all');
    if (req.method === 'OPTIONS') {
      return res.status(200).end();
    }
  }
  next();
});

// Serve robots.txt for AI Crawlers (GPTBot, ClaudeBot, PerplexityBot, etc.)
app.get('/robots.txt', (req, res) => {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).send(`User-agent: *\nAllow: /\nAllow: /txt/\nAllow: /prompts/\nSitemap: https://porto.apprentice.cyou/sitemap.xml\n`);
});

// Dynamic sitemap.xml for AI Search Crawlers & Bingbot
app.get('/sitemap.xml', (req, res) => {
  res.setHeader('Content-Type', 'application/xml; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://porto.apprentice.cyou/</loc><priority>1.0</priority></url>
  <url><loc>https://porto.apprentice.cyou/txt/styles/auto.txt</loc><priority>0.8</priority></url>
  <url><loc>https://porto.apprentice.cyou/txt/characters/auto.txt</loc><priority>0.8</priority></url>
  <url><loc>https://porto.apprentice.cyou/txt/styles/teknologi-modern.txt</loc><priority>0.8</priority></url>
</urlset>`;
  res.status(200).send(xml);
});

// Root homepage 200 OK for Web Search Crawlers
app.get('/', (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).send(`<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="robots" content="index, follow">
  <title>AI Poster Prompt Studio Server</title>
</head>
<body style="font-family:sans-serif;padding:40px;background:#fafafa;">
  <h1>AI Poster Prompt Studio API & Public Prompts</h1>
  <p>Server is running active. Public prompt references available under <code>/txt/styles/</code> and <code>/txt/characters/</code>.</p>
</body>
</html>`);
});

// Serve static text files directly via express.static at root /txt and /prompts
const basePromptsDir = path.join(process.cwd(), 'prompts');
const publicTxtDir = path.join(process.cwd(), 'public', 'txt');
const uploadsTxtDir = path.join(process.cwd(), 'uploads', 'txt');

[basePromptsDir, publicTxtDir, uploadsTxtDir].forEach((dir) => {
  if (!fs.existsSync(dir)) {
    try { fs.mkdirSync(dir, { recursive: true }); } catch (e) {}
  }
});

const staticTextOptions = {
  setHeaders: (res: any) => {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Cache-Control', 'public, max-age=86400');
    res.setHeader('X-Robots-Tag', 'all');
  }
};

app.use('/txt', express.static(publicTxtDir, staticTextOptions));
app.use('/txt', express.static(basePromptsDir, staticTextOptions));
app.use('/txt', express.static(uploadsTxtDir, staticTextOptions));

app.use('/prompts', express.static(publicTxtDir, staticTextOptions));
app.use('/prompts', express.static(basePromptsDir, staticTextOptions));
app.use('/prompts', express.static(uploadsTxtDir, staticTextOptions));

// Mount dynamic prompt routes before restrictive CORS
app.use('/txt', promptsRoutes);
app.use('/prompts', promptsRoutes);
app.use('/api/txt', promptsRoutes);
app.use('/api/prompts', promptsRoutes);

// Middlewares
const ALLOWED_ORIGINS = [
  'https://porto.apprentice.cyou',
  'https://full-feature-showcase.vercel.app', // admin panel di vercel
  'https://promtingfrontend.vercel.app',
  'http://localhost:5173',  // admin dev
  'http://localhost:4173',  // admin preview
  'http://localhost:8080',  // flutter web dev
];

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (e.g. mobile apps, Postman, AI Crawlers)
    if (!origin) return callback(null, true);
    if (ALLOWED_ORIGINS.includes(origin) || origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
      return callback(null, true);
    }
    // Allow external requests for public prompt files
    return callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-api-key'],
}));

// Strict HTTP Security Headers
app.use((req, res, next) => {
  if (req.path.startsWith('/txt') || req.path.startsWith('/prompts') || req.path === '/robots.txt') {
    return next();
  }
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'no-referrer');
  next();
});

// Configure base64 limits for larger reference images
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Local Uploads Folder setup for backend fallback storage
const uploadsDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}
app.use('/uploads', express.static(uploadsDir));

// Request logging middleware
app.use((req, res, next) => {
  logger.http(`${req.method} ${req.originalUrl} - IP: ${req.ip}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ success: true, status: 'OK', timestamp: new Date() });
});

// DB Health check — diagnosa koneksi database dari server
app.get('/health/db', async (req, res) => {
  try {
    const result = await db.execute(sql`SELECT 1 AS ok`);
    const dbUrl = process.env.DATABASE_URL || '';
    const host = dbUrl ? new URL(dbUrl.replace(/[&?]channel_binding=\w+/g, '')).hostname : 'unknown';
    res.status(200).json({
      success: true,
      status: 'DB Connected',
      host,
      timestamp: new Date(),
    });
  } catch (e: any) {
    const cause = e?.cause;
    res.status(500).json({
      success: false,
      status: 'DB Failed',
      error: e?.message?.split('\n')[0] || 'Unknown error',
      cause: cause?.message || null,
      pgCode: cause?.code || null,
      detail: cause?.detail || null,
      hint: cause?.hint || null,
      dbUrlSet: !!process.env.DATABASE_URL,
      timestamp: new Date(),
    });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/poster', posterRoutes);
app.use('/api/history', historyRoutes);
app.use('/api/dropdown-options', dropdownRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/v1', developerRoutes);
app.use('/api/sync', syncRoutes);
app.use('/api/templates', templatesRoutes);
app.use('/api/form-infos', formInfoRoutes);

// Public Plain Text Prompt SLUG Endpoints (e.g. https://porto.apprentice.cyou/txt/style.txt)
app.use('/txt', promptsRoutes);
app.use('/prompts', promptsRoutes);

// 404 Route handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'API route not found',
    code: 'NOT_FOUND',
  });
});

// Global Error Handler
app.use(errorHandler);

// Start server
import killPort from 'kill-port';

import { scheduleImageCleanup } from './utils/image-cleanup';

async function startServer() {
  try {
    // Try to kill the port if it's in use
    await killPort(env.PORT);
    logger.info(`Cleared port ${env.PORT}`);
  } catch (err) {
    // Port is probably not in use
  }

  app.listen(env.PORT, () => {
    logger.info(`Server is running in ${env.NODE_ENV} mode on port ${env.PORT}`);
    // Start automatic garbage collection of unused uploads/images
    scheduleImageCleanup();
    syncPromptFilesToDisk();
  });
}

startServer();
