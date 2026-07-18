import { Router } from 'express';
import {
  getHistory,
  toggleFavorite,
  duplicatePrompt,
  deletePrompt,
  toggleSharePrompt,
  getSharedPrompts,
  updatePromptImage,
  updatePromptImages,
} from './history.controller';
import { authenticate } from '../../middlewares/auth';
import { spamBlocker } from '../../middlewares/spamBlocker';

const router = Router();

// All history routes require authentication
router.use(authenticate);
router.use(spamBlocker);

router.get('/shared', getSharedPrompts);
router.get('/', getHistory);
router.patch('/:id/favorite', toggleFavorite);
router.patch('/:id/share', toggleSharePrompt);
router.patch('/:id/image', updatePromptImage);
router.patch('/:id/images', updatePromptImages);
router.post('/:id/duplicate', duplicatePrompt);
router.delete('/:id', deletePrompt);

export default router;
