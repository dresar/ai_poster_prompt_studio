import { Router } from 'express';
import {
  analyzeTopic,
  generatePoster,
  generateEnhance,
  getContentIdeas,
  getHooks,
  improvePrompt,
} from '../poster/poster.controller';
import {
  analyzeTopicSchema,
  generatePosterSchema,
  generateEnhanceSchema,
  getIdeasSchema,
  getHooksSchema,
  improvePromptSchema,
} from '../poster/poster.schema';
import { validate } from '../../middlewares/validator';
import { authenticateDeveloperKey } from '../../middlewares/developerKey';
import { spamBlocker } from '../../middlewares/spamBlocker';

const router = Router();

// Secure all programmatic v1 endpoints with developer API Key
router.use(authenticateDeveloperKey);
router.use(spamBlocker);

router.post('/analyze-topic', validate({ body: analyzeTopicSchema }), analyzeTopic);
router.post('/generate-prompt', validate({ body: generatePosterSchema }), generatePoster);
router.post('/improve-prompt', validate({ body: improvePromptSchema }), improvePrompt);
router.post('/analyze-image', validate({ body: generateEnhanceSchema }), generateEnhance);
router.get('/content-ideas', validate({ query: getIdeasSchema }), getContentIdeas);
router.get('/generate-hooks', validate({ query: getHooksSchema }), getHooks);

export default router;
