"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = exports.AppError = void 0;
const logger_1 = require("../config/logger");
class AppError extends Error {
    statusCode;
    code;
    data;
    constructor(message, statusCode = 500, code, data) {
        super(message);
        this.statusCode = statusCode;
        this.code = code;
        this.data = data;
        Object.setPrototypeOf(this, new.target.prototype);
    }
}
exports.AppError = AppError;
const errorHandler = (err, req, res, next) => {
    // Drizzle ORM query errors — jangan leak SQL query ke client
    const isDrizzleQueryError = err?.constructor?.name === 'DrizzleQueryError' ||
        (err?.message && err.message.startsWith('Failed query:'));
    if (isDrizzleQueryError) {
        const cause = err?.cause;
        const causeMsg = cause?.message || '';
        logger_1.logger.error(`[DB Error] ${req.method} ${req.originalUrl} - Query failed`);
        logger_1.logger.error(`Query: ${err.query || '(unknown)'}`);
        logger_1.logger.error(`Cause: ${causeMsg}`);
        logger_1.logger.error(err.stack || '');
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
    logger_1.logger.error(`${req.method} ${req.originalUrl} - ${statusCode} - ${message}`);
    if (statusCode === 500) {
        logger_1.logger.error(err.stack || '');
    }
    res.status(statusCode).json({
        success: false,
        message,
        code,
        data,
    });
};
exports.errorHandler = errorHandler;
