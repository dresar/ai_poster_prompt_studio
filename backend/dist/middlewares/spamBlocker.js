"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.spamBlocker = void 0;
const db_1 = require("../config/db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const errorHandler_1 = require("./errorHandler");
const crypto_1 = __importDefault(require("crypto"));
// In-memory tracker for request timestamps: userId -> timestamp[]
const requestTracker = {};
const spamBlocker = async (req, res, next) => {
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
    const softLimit = 12; // Warning trigger
    const hardLimit = 22; // Automatic ban trigger
    if (!requestTracker[userId]) {
        requestTracker[userId] = [];
    }
    // Filter out timestamps older than windowMs
    requestTracker[userId] = requestTracker[userId].filter((timestamp) => now - timestamp < windowMs);
    // Record current request timestamp
    requestTracker[userId].push(now);
    const requestCount = requestTracker[userId].length;
    // Case 1: Hard Limit Exceeded -> AUTO BAN
    if (requestCount >= hardLimit) {
        // Flag user as BLOCKED in database immediately
        await db_1.db.update(schema_1.users).set({ subscriptionStatus: 'BLOCKED' }).where((0, drizzle_orm_1.eq)(schema_1.users.id, userId));
        // Write security audit log
        await db_1.db.insert(schema_1.logs).values({
            id: crypto_1.default.randomUUID(),
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
        throw new errorHandler_1.AppError('Akun Anda telah DIBLOKIR otomatis oleh sistem karena terdeteksi melakukan spamming API secara intensif.', 403, 'USER_BLOCKED');
    }
    // Case 2: Soft Limit Exceeded -> Rate limit warning
    if (requestCount >= softLimit) {
        throw new errorHandler_1.AppError('Aktivitas Anda terlalu cepat. Silakan tunggu 30 detik untuk menghindari pemblokiran akun otomatis.', 429, 'TOO_MANY_REQUESTS');
    }
    next();
};
exports.spamBlocker = spamBlocker;
