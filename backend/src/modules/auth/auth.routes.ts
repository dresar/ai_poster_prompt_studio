import { Router } from 'express';
import {
  register, login, refresh, changePassword, getProfile,
  getImagekitSettings, saveImagekitSettings, deleteImagekitSettings, testImagekitSettings,
} from './auth.controller';
import { registerSchema, loginSchema, refreshTokenSchema, changePasswordSchema } from './auth.schema';
import { validate } from '../../middlewares/validator';
import { authenticate } from '../../middlewares/auth';

const router = Router();

router.post('/register', validate({ body: registerSchema }), register);
router.post('/login', validate({ body: loginSchema }), login);
router.post('/refresh', validate({ body: refreshTokenSchema }), refresh);

// Protected routes
router.post('/change-password', authenticate, validate({ body: changePasswordSchema }), changePassword);
router.get('/profile', authenticate, getProfile);

// Per-user ImageKit storage settings
router.get('/imagekit', authenticate, getImagekitSettings);
router.put('/imagekit', authenticate, saveImagekitSettings);
router.delete('/imagekit', authenticate, deleteImagekitSettings);
router.post('/imagekit/test', authenticate, testImagekitSettings);

export default router;
