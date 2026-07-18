"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateDeveloperKey = void 0;
const errorHandler_1 = require("./errorHandler");
const db_1 = require("../config/db");
const schema_1 = require("../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const authenticateDeveloperKey = async (req, res, next) => {
    try {
        const apiKey = req.headers['x-api-key'] || req.query.apiKey;
        if (!apiKey || typeof apiKey !== 'string') {
            throw new errorHandler_1.AppError('Developer API Key missing (x-api-key header or apiKey query parameter required)', 401, 'UNAUTHORIZED');
        }
        const keyRecords = await db_1.db.select({
            key: schema_1.developerApiKeys,
            user: schema_1.users
        })
            .from(schema_1.developerApiKeys)
            .innerJoin(schema_1.users, (0, drizzle_orm_1.eq)(schema_1.developerApiKeys.userId, schema_1.users.id))
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.developerApiKeys.apiKey, apiKey), (0, drizzle_orm_1.eq)(schema_1.developerApiKeys.isActive, true)))
            .limit(1);
        const record = keyRecords[0];
        if (!record) {
            throw new errorHandler_1.AppError('Invalid or inactive Developer API Key', 401, 'UNAUTHORIZED');
        }
        // Bind user context to request
        req.user = {
            id: record.user.id,
            email: record.user.email,
            role: record.user.role,
        };
        next();
    }
    catch (error) {
        next(error);
    }
};
exports.authenticateDeveloperKey = authenticateDeveloperKey;
