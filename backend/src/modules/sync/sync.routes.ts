import { Router } from 'express';
import { getSyncChecksum } from './sync.controller';

const router = Router();

// Public endpoint — no auth needed, just returns a lightweight hash
router.get('/checksum', getSyncChecksum);

export default router;
