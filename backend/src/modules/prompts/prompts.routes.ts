import { Router } from 'express';
import {
  getStylePromptFile,
  getCharacterPromptFile,
  getUniversalTextPromptFile,
} from './prompts.controller';

const router = Router();

// Routes for styles plain text prompts
router.get('/styles/:slug.txt', getStylePromptFile);
router.get('/styles/:slug', getStylePromptFile);

// Routes for characters plain text prompts
router.get('/characters/:slug.txt', getCharacterPromptFile);
router.get('/characters/:slug', getCharacterPromptFile);

// Universal fallback route /txt/:slug.txt or /txt/styles/:slug.txt
router.get('/:slug.txt', getUniversalTextPromptFile);
router.get('/:slug', getUniversalTextPromptFile);

export default router;
