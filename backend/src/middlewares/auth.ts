import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { AppError } from './errorHandler';
import { db } from '../config/db';
import { users } from '../db/schema';
import { eq } from 'drizzle-orm';

export interface UserPayload {
  id: string;
  email: string;
  role: 'USER' | 'ADMIN';
}

declare global {
  namespace Express {
    interface Request {
      user?: UserPayload;
    }
  }
}

export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('Authentication token missing or invalid', 401, 'UNAUTHORIZED');
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, env.JWT_SECRET) as UserPayload;

    // Check if user still exists
    const userRecords = await db.select({
      id: users.id,
      email: users.email,
      role: users.role,
      subscriptionStatus: users.subscriptionStatus,
    }).from(users).where(eq(users.id, decoded.id)).limit(1);
    
    const user = userRecords[0];

    if (!user) {
      throw new AppError('User no longer exists', 401, 'UNAUTHORIZED');
    }

    if (user.subscriptionStatus === 'BLOCKED') {
      throw new AppError('Akun Anda telah ditangguhkan/diblokir oleh sistem karena aktivitas mencurigakan atau spam API.', 403, 'BLOCKED');
    }

    req.user = {
      id: user.id,
      email: user.email,
      role: user.role,
    };

    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      next(new AppError('Token has expired', 401, 'TOKEN_EXPIRED'));
    } else if (error instanceof jwt.JsonWebTokenError) {
      next(new AppError('Invalid token', 401, 'INVALID_TOKEN'));
    } else {
      next(error);
    }
  }
};

export const requireRole = (roles: Array<'USER' | 'ADMIN'>) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401, 'UNAUTHORIZED'));
    }

    if (!roles.includes(req.user.role)) {
      return next(new AppError('Forbidden: Insufficient privileges', 403, 'FORBIDDEN'));
    }

    next();
  };
};
