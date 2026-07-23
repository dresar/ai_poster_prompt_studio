import { Router } from 'express';
import {
  analyzeTopic,
  generatePoster,
  generateEnhance,
  getContentIdeas,
  getHooks,
  improvePrompt,
  uploadImage,
  uploadMultiImages,
  getPublicVisualStyles,
  getPublicCharacters,
  activateLicense,
  chat,
  analyzeStoryboard,
  importExternalPrompt,
  saveExternalDraft,
  suggestCharacter,
  suggestVisualStyle,
} from './poster.controller';
import {
  analyzeTopicSchema,
  generatePosterSchema,
  generateEnhanceSchema,
  getIdeasSchema,
  getHooksSchema,
  improvePromptSchema,
  analyzeStoryboardSchema,
  importExternalPromptSchema,
  saveExternalDraftSchema,
} from './poster.schema';
import { validate } from '../../middlewares/validator';
import { authenticate } from '../../middlewares/auth';
import { spamBlocker } from '../../middlewares/spamBlocker';

const router = Router();

// All poster routes require authentication
router.use(authenticate);
router.use(spamBlocker);

router.post('/analyze-topic', validate({ body: analyzeTopicSchema }), analyzeTopic);
router.post('/analyze-storyboard', validate({ body: analyzeStoryboardSchema }), analyzeStoryboard);
router.post('/generate', validate({ body: generatePosterSchema }), generatePoster);
router.post('/enhance', validate({ body: generateEnhanceSchema }), generateEnhance);
router.post('/upload', uploadImage);
router.post('/upload-multi', uploadMultiImages);
router.get('/visual-styles', getPublicVisualStyles);
router.get('/characters', getPublicCharacters);
router.post('/activate-license', activateLicense);
router.post('/chat', chat);

router.get('/ideas', validate({ query: getIdeasSchema }), getContentIdeas);
router.get('/hooks', validate({ query: getHooksSchema }), getHooks);
router.post('/improve', validate({ body: improvePromptSchema }), improvePrompt);
router.post('/import-external', validate({ body: importExternalPromptSchema }), importExternalPrompt);
router.post('/save-external-draft', validate({ body: saveExternalDraftSchema }), saveExternalDraft);

router.get('/suggest-character', suggestCharacter);
router.get('/suggest-visual-style', suggestVisualStyle);

export default router;
