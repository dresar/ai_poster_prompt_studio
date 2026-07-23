import { Router } from 'express';
import {
  getDashboardStats,
  getGeminiKeys,
  createGeminiKey,
  bulkImportGeminiKeys,
  updateGeminiKey,
  deleteGeminiKey,
  encryptOldKey,
  getSystemSettings,
  updateSystemSettings,
  getImageKitSettings,
  updateImageKitSettings,
  getVisualStyles,
  createVisualStyle,
  updateVisualStyle,
  deleteVisualStyle,
  getLicenses,
  generateLicenses,
  deleteLicense,
  getUsers,
  updateUserRole,
  updateUserSubscription,
  getAuditLogs,
  testGeminiKey,
  testAllGeminiKeys,
  getDeveloperKeys,
  createDeveloperKey,
  deleteDeveloperKey,
  transferCreditsDirectly,
  // Character CRUD
  getCharacters,
  createCharacter,
  updateCharacter,
  deleteCharacter,
  // Prompt Template CRUD
  getPromptTemplates,
  createPromptTemplate,
  updatePromptTemplate,
  deletePromptTemplate,
  generateSuggestedTemplate,
} from './admin.controller';
import { authenticate, requireRole } from '../../middlewares/auth';

const router = Router();

// Protect all admin routes (Token Verification + ADMIN role check)
router.use(authenticate, requireRole(['ADMIN']));

router.get('/stats', getDashboardStats);

router.get('/keys', getGeminiKeys);
router.post('/keys', createGeminiKey);
router.post('/keys/bulk-import', bulkImportGeminiKeys);
router.post('/keys/test-all', testAllGeminiKeys);
router.post('/keys/:id/test', testGeminiKey);
router.patch('/keys/:id', updateGeminiKey);
router.delete('/keys/:id', deleteGeminiKey);
router.post('/keys/:id/encrypt', encryptOldKey); // Feature 1: Manual encryption endpoint

router.get('/developer-keys', getDeveloperKeys);
router.post('/developer-keys', createDeveloperKey);
router.delete('/developer-keys/:id', deleteDeveloperKey);

router.get('/settings', getSystemSettings);
router.post('/settings', updateSystemSettings);

router.get('/imagekit-settings', getImageKitSettings);
router.post('/imagekit-settings', updateImageKitSettings);

router.get('/visual-styles', getVisualStyles);
router.post('/visual-styles', createVisualStyle);
router.patch('/visual-styles/:id', updateVisualStyle);
router.delete('/visual-styles/:id', deleteVisualStyle);

router.get('/licenses', getLicenses);
router.post('/licenses', generateLicenses);
router.delete('/licenses/:id', deleteLicense);
router.post('/credits/transfer', transferCreditsDirectly);

router.get('/users', getUsers);
router.patch('/users/:id/role', updateUserRole);
router.patch('/users/:id/subscription', updateUserSubscription);

router.get('/logs', getAuditLogs);

// Character CRUD
router.get('/characters', getCharacters);
router.post('/characters', createCharacter);
router.patch('/characters/:id', updateCharacter);
router.delete('/characters/:id', deleteCharacter);

// Prompt Template CRUD
router.get('/templates', getPromptTemplates);
router.post('/templates', createPromptTemplate);
router.patch('/templates/:id', updatePromptTemplate);
router.delete('/templates/:id', deletePromptTemplate);
router.post('/templates/generate-suggested', generateSuggestedTemplate);

export default router;
