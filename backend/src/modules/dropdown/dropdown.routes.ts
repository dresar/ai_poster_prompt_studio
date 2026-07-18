import { Router } from 'express';
import {
  getDropdownOptions,
  createDropdownOption,
  updateDropdownOption,
  deleteDropdownOption,
} from './dropdown.controller';
import {
  createDropdownOptionSchema,
  updateDropdownOptionSchema,
  queryDropdownSchema,
} from './dropdown.schema';
import { validate } from '../../middlewares/validator';
import { authenticate, requireRole } from '../../middlewares/auth';

const router = Router();

// Publicly available (or auth-only depending on project, let's allow authenticated users)
router.get('/', authenticate, validate({ query: queryDropdownSchema }), getDropdownOptions);

// Admin-only CRUD operations
router.post(
  '/',
  authenticate,
  requireRole(['ADMIN']),
  validate({ body: createDropdownOptionSchema }),
  createDropdownOption
);

router.patch(
  '/:id',
  authenticate,
  requireRole(['ADMIN']),
  validate({ body: updateDropdownOptionSchema }),
  updateDropdownOption
);

router.delete(
  '/:id',
  authenticate,
  requireRole(['ADMIN']),
  deleteDropdownOption
);

export default router;
