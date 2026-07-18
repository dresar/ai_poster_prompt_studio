import { Request, Response, NextFunction } from 'express';
import { AppError } from './errorHandler';
import { db } from '../config/db';
import { developerApiKeys, users } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const authenticateDeveloperKey = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const apiKey = req.headers['x-api-key'] || req.query.apiKey;

    if (!apiKey || typeof apiKey !== 'string') {
      throw new AppError('Developer API Key missing (x-api-key header or apiKey query parameter required)', 401, 'UNAUTHORIZED');
    }

    const keyRecords = await db.select({
      key: developerApiKeys,
      user: users
    })
    .from(developerApiKeys)
    .innerJoin(users, eq(developerApiKeys.userId, users.id))
    .where(and(eq(developerApiKeys.apiKey, apiKey), eq(developerApiKeys.isActive, true)))
    .limit(1);

    const record = keyRecords[0];

    if (!record) {
      throw new AppError('Invalid or inactive Developer API Key', 401, 'UNAUTHORIZED');
    }

    // Bind user context to request
    req.user = {
      id: record.user.id,
      email: record.user.email,
      role: record.user.role,
    };

    next();
  } catch (error) {
    next(error);
  }
};
