import { Router } from 'express';
import { checkAppUpdate, downloadApk } from './update.controller';

const router = Router();

router.get('/check', checkAppUpdate);
router.get('/version.json', checkAppUpdate);
router.get('/download', downloadApk);
router.get('/app-release.apk', downloadApk);

export default router;
