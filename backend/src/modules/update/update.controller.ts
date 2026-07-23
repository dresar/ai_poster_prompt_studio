import { Request, Response, NextFunction } from 'express';
import path from 'path';
import fs from 'fs';

// Helper to locate APK file dynamically
function getApkFilePath(): { exists: boolean; path: string; sizeMb: string } {
  // 1. Try uploaded/copied APK in backend uploads folder
  const backendApkPath = path.join(process.cwd(), 'uploads', 'updates', 'app-release.apk');
  if (fs.existsSync(backendApkPath)) {
    const stats = fs.statSync(backendApkPath);
    const sizeMb = (stats.size / (1024 * 1024)).toFixed(1) + ' MB';
    return { exists: true, path: backendApkPath, sizeMb };
  }

  // 2. Try direct Flutter project build directory (when running backend on same machine)
  const localBuildApkPath = path.join(process.cwd(), '..', 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');
  if (fs.existsSync(localBuildApkPath)) {
    const stats = fs.statSync(localBuildApkPath);
    const sizeMb = (stats.size / (1024 * 1024)).toFixed(1) + ' MB';
    return { exists: true, path: localBuildApkPath, sizeMb };
  }

  return { exists: false, path: '', sizeMb: '67.8 MB' };
}

export const checkAppUpdate = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const currentAppVersion = (req.query.version as string) || '1.0.0';

    const protocol = (req.headers['x-forwarded-proto'] as string) || req.protocol || 'http';
    const host = req.get('host') || 'localhost:3000';
    const defaultApkUrl = `${protocol}://${host}/api/update/download`;

    const apkInfo = getApkFilePath();

    const updatePayload = {
      latestVersion: '1.1.0',
      buildNumber: 2,
      minRequiredVersion: '1.0.0',
      releaseDate: '2026-07-23',
      title: '🎉 Update Terbaru v1.1.0!',
      description: 'Pembaruan otomatis langsung dari Server Backend tanpa perlu upload manual ke cPanel!',
      apkUrl: process.env.APK_UPDATE_URL || defaultApkUrl,
      fileSizeMb: apkInfo.sizeMb,
      isMandatory: false,
      changelog: [
        '✨ Fitur Karakter & Maskot Bible Generator 16:9',
        '🎨 Fitur Gaya Visual Design System Blueprint',
        '🎯 Perbaikan Tempat Logo Canva (Badge Lingkaran LOGO)',
        '📱 Layout Form 1 Baris Ke Bawah (Rapi & Responsif)',
        '⚡ Saran AI Otomatis di Semua Field Form',
        '🚀 Auto Update Langsung dari Backend Server'
      ],
    };

    const hasUpdate = isVersionGreater(updatePayload.latestVersion, currentAppVersion);

    res.status(200).json({
      success: true,
      hasUpdate,
      currentAppVersion,
      data: updatePayload,
    });
  } catch (error) {
    next(error);
  }
};

export const downloadApk = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const apkInfo = getApkFilePath();

    if (!apkInfo.exists) {
      return res.status(404).json({
        success: false,
        message: 'File APK belum ditemukan di server backend. Silakan build APK terlebih dahulu.',
      });
    }

    res.setHeader('Content-Type', 'application/vnd.android.package-archive');
    res.setHeader('Content-Disposition', 'attachment; filename="app-release.apk"');

    res.sendFile(apkInfo.path);
  } catch (error) {
    next(error);
  }
};

function isVersionGreater(v1: string, v2: string): boolean {
  const p1 = v1.split('.').map(Number);
  const p2 = v2.split('.').map(Number);
  for (let i = 0; i < Math.max(p1.length, p2.length); i++) {
    const num1 = p1[i] || 0;
    const num2 = p2[i] || 0;
    if (num1 > num2) return true;
    if (num1 < num2) return false;
  }
  return false;
}
