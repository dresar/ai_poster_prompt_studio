import { Request, Response, NextFunction } from 'express';
import { db } from '../config/db';
import { users, logs } from '../db/schema';
import { eq } from 'drizzle-orm';
import { AppError } from './errorHandler';
import crypto from 'crypto';

// In-memory tracker for request timestamps: userId -> timestamp[]
const requestTracker: Record<string, number[]> = {};

export const spamBlocker = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  // If request is not authenticated yet, wait or proceed (spam blocker is applied after authenticate)
  if (!req.user) {
    return next();
  }

  const userId = req.user.id;
  const userRole = req.user.role;

  // Admin accounts are exempt from spam blocking to prevent admin lockout
  if (userRole === 'ADMIN') {
    return next();
  }

  const now = Date.now();
  const windowMs = 30000; // 30 seconds sliding window
  const softLimit = 12;   // Warning trigger
  const hardLimit = 22;   // Automatic ban trigger

  if (!requestTracker[userId]) {
    requestTracker[userId] = [];
  }

  // Filter out timestamps older than windowMs
  requestTracker[userId] = requestTracker[userId].filter(
    (timestamp) => now - timestamp < windowMs
  );

  // Record current request timestamp
  requestTracker[userId].push(now);

  const requestCount = requestTracker[userId].length;

  // Case 1: Hard Limit Exceeded -> AUTO BAN
  if (requestCount >= hardLimit) {
    // Flag user as BLOCKED in database immediately
    await db.update(users).set({ subscriptionStatus: 'BLOCKED' }).where(eq(users.id, userId));

    // Write security audit log
    await db.insert(logs).values({
      id: crypto.randomUUID(),
      userId,
      action: 'auto_block_user_spam',
      detail: {
        reason: 'Excessive API requests (Spamming)',
        requestCountIn30Seconds: requestCount,
        timeWindowMs: windowMs,
      },
    });

    // Clear tracker memory
    delete requestTracker[userId];

    throw new AppError(
      'Akun Anda telah DIBLOKIR otomatis oleh sistem karena terdeteksi melakukan spamming API secara intensif.',
      403,
      'USER_BLOCKED'
    );
  }

  // Case 2: Soft Limit Exceeded -> Rate limit warning
  if (requestCount >= softLimit) {
    throw new AppError(
      'Aktivitas Anda terlalu cepat. Silakan tunggu 30 detik untuk menghindari pemblokiran akun otomatis.',
      429,
      'TOO_MANY_REQUESTS'
    );
  }

  next();
};
