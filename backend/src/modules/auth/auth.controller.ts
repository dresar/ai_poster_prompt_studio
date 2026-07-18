import { Request, Response, NextFunction } from 'express';
import { db } from '../../config/db';
import { users } from '../../db/schema';
import { eq } from 'drizzle-orm';
import { AuthService } from './auth.service';
import { AppError } from '../../middlewares/errorHandler';

const authService = new AuthService();

export const register = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;
    const result = await authService.register(email, password, 'USER');
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const refresh = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = req.body;
    const result = await authService.refresh(refreshToken);
    res.status(200).json({
      success: true,
      message: 'Token refreshed successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const changePassword = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const userId = req.user!.id;
    await authService.changePassword(userId, oldPassword, newPassword);
    res.status(200).json({
      success: true,
      message: 'Password changed successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const getProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const foundUsers = await db.select({
      id: users.id,
      email: users.email,
      role: users.role,
      subscriptionStatus: users.subscriptionStatus,
      subscriptionExpiresAt: users.subscriptionExpiresAt,
      credits: users.credits,
      createdAt: users.createdAt,
      imagekitPublicKey: users.imagekitPublicKey,
      imagekitUrlEndpoint: users.imagekitUrlEndpoint,
      hasImagekit: users.imagekitPrivateKey, // used to check if set, not exposed
    }).from(users).where(eq(users.id, req.user!.id)).limit(1);
    const user = foundUsers[0];

    res.status(200).json({
      success: true,
      data: {
        user: {
          ...user,
          hasImagekit: !!user?.hasImagekit,
          hasImagekitConfigured: !!(user?.imagekitPublicKey && user?.hasImagekit && user?.imagekitUrlEndpoint),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /auth/imagekit — get user's imagekit settings (private key masked)
export const getImagekitSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userArr = await db.select({
      imagekitPublicKey: users.imagekitPublicKey,
      imagekitPrivateKey: users.imagekitPrivateKey,
      imagekitUrlEndpoint: users.imagekitUrlEndpoint,
    }).from(users).where(eq(users.id, req.user!.id)).limit(1);
    const user = userArr[0];

    res.status(200).json({
      success: true,
      data: {
        publicKey: user?.imagekitPublicKey || '',
        privateKey: user?.imagekitPrivateKey ? '••••••••••••••••' : '', // masked
        urlEndpoint: user?.imagekitUrlEndpoint || '',
        isConfigured: !!(user?.imagekitPublicKey && user?.imagekitPrivateKey && user?.imagekitUrlEndpoint),
      },
    });
  } catch (error) {
    next(error);
  }
};

// PUT /auth/imagekit — save user's imagekit settings
export const saveImagekitSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { publicKey, privateKey, urlEndpoint } = req.body;
    if (!publicKey || !privateKey || !urlEndpoint) {
      throw new AppError('Semua field ImageKit wajib diisi (publicKey, privateKey, urlEndpoint)', 400, 'BAD_REQUEST');
    }

    // Encrypt private key before storing
    let encryptedPrivKey = privateKey;
    try {
      const { encrypt } = await import('../../core/utils/encryption');
      encryptedPrivKey = encrypt(privateKey);
    } catch (_) { /* store as-is if encryption unavailable */ }

    await db.update(users).set({
      imagekitPublicKey: publicKey.trim(),
      imagekitPrivateKey: encryptedPrivKey,
      imagekitUrlEndpoint: urlEndpoint.trim(),
    }).where(eq(users.id, req.user!.id));

    res.status(200).json({
      success: true,
      message: 'Kredensial ImageKit berhasil disimpan! Foto Anda sekarang akan tersimpan di akun ImageKit pribadi Anda.',
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /auth/imagekit — remove user's imagekit settings
export const deleteImagekitSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await db.update(users).set({
      imagekitPublicKey: null,
      imagekitPrivateKey: null,
      imagekitUrlEndpoint: null,
    }).where(eq(users.id, req.user!.id));

    res.status(200).json({
      success: true,
      message: 'Kredensial ImageKit berhasil dihapus.',
    });
  } catch (error) {
    next(error);
  }
};

// POST /auth/imagekit/test — test imagekit credentials
export const testImagekitSettings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { publicKey, privateKey, urlEndpoint } = req.body;
    if (!publicKey || !privateKey || !urlEndpoint) {
      throw new AppError('Semua field wajib diisi', 400, 'BAD_REQUEST');
    }

    // Upload a tiny test pixel image to ImageKit
    const tinyBase64Png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    const postData = JSON.stringify({ file: tinyBase64Png, fileName: `test-${Date.now()}.png` });
    const https = (await import('https')).default;

    const result = await new Promise<{ ok: boolean; message: string }>((resolve) => {
      const options = {
        hostname: 'upload.imagekit.io',
        port: 443,
        path: '/api/v1/files/upload',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
          'Authorization': 'Basic ' + Buffer.from(privateKey + ':').toString('base64'),
        },
      };
      const r = https.request(options, (resp) => {
        let body = '';
        resp.on('data', (c) => body += c);
        resp.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            if (resp.statusCode && resp.statusCode >= 200 && resp.statusCode < 300 && parsed.url) {
              resolve({ ok: true, message: `✅ Koneksi berhasil! URL: ${parsed.url}` });
            } else {
              resolve({ ok: false, message: `❌ Gagal: ${parsed.message || 'Unknown error'}` });
            }
          } catch {
            resolve({ ok: false, message: '❌ Respons tidak valid dari ImageKit' });
          }
        });
      });
      r.on('error', (e) => resolve({ ok: false, message: `❌ Error jaringan: ${e.message}` }));
      r.write(postData);
      r.end();
    });

    res.status(200).json({ success: result.ok, message: result.message });
  } catch (error) {
    next(error);
  }
};
