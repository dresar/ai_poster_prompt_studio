"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProfile = exports.changePassword = exports.refresh = exports.login = exports.register = void 0;
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const auth_service_1 = require("./auth.service");
const authService = new auth_service_1.AuthService();
const register = async (req, res, next) => {
    try {
        const { email, password } = req.body;
        const result = await authService.register(email, password);
        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: result,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.register = register;
const login = async (req, res, next) => {
    try {
        const { email, password } = req.body;
        const result = await authService.login(email, password);
        res.status(200).json({
            success: true,
            message: 'Login successful',
            data: result,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.login = login;
const refresh = async (req, res, next) => {
    try {
        const { refreshToken } = req.body;
        const result = await authService.refresh(refreshToken);
        res.status(200).json({
            success: true,
            message: 'Token refreshed successfully',
            data: result,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.refresh = refresh;
const changePassword = async (req, res, next) => {
    try {
        const { oldPassword, newPassword } = req.body;
        const userId = req.user.id;
        await authService.changePassword(userId, oldPassword, newPassword);
        res.status(200).json({
            success: true,
            message: 'Password changed successfully',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.changePassword = changePassword;
const getProfile = async (req, res, next) => {
    try {
        const foundUsers = await db_1.db.select({
            id: schema_1.users.id,
            email: schema_1.users.email,
            role: schema_1.users.role,
            subscriptionStatus: schema_1.users.subscriptionStatus,
            subscriptionExpiresAt: schema_1.users.subscriptionExpiresAt,
            credits: schema_1.users.credits,
            createdAt: schema_1.users.createdAt,
        }).from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.user.id)).limit(1);
        const user = foundUsers[0];
        res.status(200).json({
            success: true,
            data: {
                user,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getProfile = getProfile;
