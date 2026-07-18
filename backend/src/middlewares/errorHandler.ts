import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger';

export class AppError extends Error {
  public statusCode: number;
  public code?: string;
  public data?: any;

  constructor(message: string, statusCode: number = 500, code?: string, data?: any) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.data = data;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Drizzle ORM query errors — jangan leak SQL query ke client
  const isDrizzleQueryError =
    err?.constructor?.name === 'DrizzleQueryError' ||
    (err?.message && err.message.startsWith('Failed query:'));

  if (isDrizzleQueryError) {
    const cause = err?.cause;
    const causeMsg = cause?.message || '';
    logger.error(`[DB Error] ${req.method} ${req.originalUrl} - Query failed`);
    logger.error(`Query: ${err.query || '(unknown)'}`);
    logger.error(`Cause: ${causeMsg}`);
    logger.error(err.stack || '');

    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada database. Silakan coba lagi.',
      code: 'DATABASE_ERROR',
      data: null,
    });
  }

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  const code = err.code || 'INTERNAL_ERROR';
  const data = err.data || null;

  // Log error
  logger.error(`${req.method} ${req.originalUrl} - ${statusCode} - ${message}`);
  if (statusCode === 500) {
    logger.error(err.stack || '');
  }

  res.status(statusCode).json({
    success: false,
    message,
    code,
    data,
  });
};
