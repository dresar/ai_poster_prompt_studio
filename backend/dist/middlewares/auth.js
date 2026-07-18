"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireRole = exports.authenticate = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const env_1 = require("../config/env");
const errorHandler_1 = require("./errorHandler");
const db_1 = require("../config/db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new errorHandler_1.AppError('Authentication token missing or invalid', 401, 'UNAUTHORIZED');
        }
        const token = authHeader.split(' ')[1];
        const decoded = jsonwebtoken_1.default.verify(token, env_1.env.JWT_SECRET);
        // Check if user still exists
        const userRecords = await db_1.db.select({
            id: schema_1.users.id,
            email: schema_1.users.email,
            role: schema_1.users.role,
            subscriptionStatus: schema_1.users.subscriptionStatus,
        }).from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, decoded.id)).limit(1);
        const user = userRecords[0];
        if (!user) {
            throw new errorHandler_1.AppError('User no longer exists', 401, 'UNAUTHORIZED');
        }
        if (user.subscriptionStatus === 'BLOCKED') {
            throw new errorHandler_1.AppError('Akun Anda telah ditangguhkan/diblokir oleh sistem karena aktivitas mencurigakan atau spam API.', 403, 'BLOCKED');
        }
        req.user = {
            id: user.id,
            email: user.email,
            role: user.role,
        };
        next();
    }
    catch (error) {
        if (error instanceof jsonwebtoken_1.default.TokenExpiredError) {
            next(new errorHandler_1.AppError('Token has expired', 401, 'TOKEN_EXPIRED'));
        }
        else if (error instanceof jsonwebtoken_1.default.JsonWebTokenError) {
            next(new errorHandler_1.AppError('Invalid token', 401, 'INVALID_TOKEN'));
        }
        else {
            next(error);
        }
    }
};
exports.authenticate = authenticate;
const requireRole = (roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return next(new errorHandler_1.AppError('Authentication required', 401, 'UNAUTHORIZED'));
        }
        if (!roles.includes(req.user.role)) {
            return next(new errorHandler_1.AppError('Forbidden: Insufficient privileges', 403, 'FORBIDDEN'));
        }
        next();
    };
};
exports.requireRole = requireRole;
