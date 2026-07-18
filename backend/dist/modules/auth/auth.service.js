"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const crypto_1 = __importDefault(require("crypto"));
const env_1 = require("../../config/env");
const errorHandler_1 = require("../../middlewares/errorHandler");
class AuthService {
    generateAccessToken(user) {
        return jsonwebtoken_1.default.sign({ id: user.id, email: user.email, role: user.role }, env_1.env.JWT_SECRET, { expiresIn: '1h' });
    }
    generateRefreshToken(user) {
        return jsonwebtoken_1.default.sign({ id: user.id, email: user.email, role: user.role }, env_1.env.JWT_REFRESH_SECRET, { expiresIn: '7d' });
    }
    async register(email, passwordHash, role = 'ADMIN') {
        const existingUsers = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.email, email)).limit(1);
        const existingUser = existingUsers[0];
        if (existingUser) {
            throw new errorHandler_1.AppError('Email already registered', 400, 'EMAIL_EXISTS');
        }
        const salt = await bcryptjs_1.default.genSalt(10);
        const hashedPassword = await bcryptjs_1.default.hash(passwordHash, salt);
        const userId = crypto_1.default.randomUUID();
        const [user] = await db_1.db.insert(schema_1.users).values({
            id: userId,
            email,
            passwordHash: hashedPassword,
            role,
        }).returning();
        // Log the registration event
        await db_1.db.insert(schema_1.logs).values({
            id: crypto_1.default.randomUUID(),
            userId: user.id,
            action: 'register',
            detail: { email: user.email, role: user.role },
        });
        const accessToken = this.generateAccessToken(user);
        const refreshToken = this.generateRefreshToken(user);
        return {
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
                createdAt: user.createdAt,
            },
            accessToken,
            refreshToken,
        };
    }
    async login(email, passwordHash) {
        const foundUsers = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.email, email)).limit(1);
        const user = foundUsers[0];
        if (!user) {
            throw new errorHandler_1.AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
        }
        const isMatch = await bcryptjs_1.default.compare(passwordHash, user.passwordHash);
        if (!isMatch) {
            throw new errorHandler_1.AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
        }
        // Log the login event
        await db_1.db.insert(schema_1.logs).values({
            id: crypto_1.default.randomUUID(),
            userId: user.id,
            action: 'login',
            detail: { email: user.email },
        });
        const accessToken = this.generateAccessToken(user);
        const refreshToken = this.generateRefreshToken(user);
        return {
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
                createdAt: user.createdAt,
            },
            accessToken,
            refreshToken,
        };
    }
    async refresh(token) {
        try {
            const decoded = jsonwebtoken_1.default.verify(token, env_1.env.JWT_REFRESH_SECRET);
            const foundUsers = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, decoded.id)).limit(1);
            const user = foundUsers[0];
            if (!user) {
                throw new errorHandler_1.AppError('User not found', 401, 'UNAUTHORIZED');
            }
            const accessToken = this.generateAccessToken(user);
            const newRefreshToken = this.generateRefreshToken(user);
            return {
                accessToken,
                refreshToken: newRefreshToken,
            };
        }
        catch (error) {
            throw new errorHandler_1.AppError('Invalid or expired refresh token', 401, 'INVALID_REFRESH_TOKEN');
        }
    }
    async changePassword(userId, oldPasswordHash, newPasswordHash) {
        const foundUsers = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, userId)).limit(1);
        const user = foundUsers[0];
        if (!user) {
            throw new errorHandler_1.AppError('User not found', 404, 'USER_NOT_FOUND');
        }
        const isMatch = await bcryptjs_1.default.compare(oldPasswordHash, user.passwordHash);
        if (!isMatch) {
            throw new errorHandler_1.AppError('Incorrect old password', 400, 'INCORRECT_OLD_PASSWORD');
        }
        const salt = await bcryptjs_1.default.genSalt(10);
        const hashedPassword = await bcryptjs_1.default.hash(newPasswordHash, salt);
        await db_1.db.update(schema_1.users).set({ passwordHash: hashedPassword }).where((0, drizzle_orm_1.eq)(schema_1.users.id, userId));
        await db_1.db.insert(schema_1.logs).values({
            id: crypto_1.default.randomUUID(),
            userId: user.id,
            action: 'change_password',
            detail: {},
        });
    }
}
exports.AuthService = AuthService;
