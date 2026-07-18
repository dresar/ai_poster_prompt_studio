"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSyncChecksum = void 0;
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const crypto_1 = __importDefault(require("crypto"));
/**
 * GET /api/sync/checksum
 * Returns a lightweight MD5 hash of all active dropdown + visual style data.
 * The Flutter app calls this on startup to detect if a sync is needed.
 * No auth required � intentionally public and lightweight.
 */
const getSyncChecksum = async (req, res, next) => {
    try {
        const dropdowns = await db_1.db
            .select({ id: schema_1.dropdownOptions.id, value: schema_1.dropdownOptions.value })
            .from(schema_1.dropdownOptions)
            .where((0, drizzle_orm_1.eq)(schema_1.dropdownOptions.isActive, true))
            .orderBy((0, drizzle_orm_1.asc)(schema_1.dropdownOptions.id));
        const styles = await db_1.db
            .select({ id: schema_1.visualStyles.id, name: schema_1.visualStyles.name })
            .from(schema_1.visualStyles)
            .where((0, drizzle_orm_1.eq)(schema_1.visualStyles.isActive, true))
            .orderBy((0, drizzle_orm_1.asc)(schema_1.visualStyles.id));
        const dataString = JSON.stringify({ dropdowns, styles });
        const checksum = crypto_1.default.createHash('md5').update(dataString).digest('hex');
        res.status(200).json({
            success: true,
            checksum,
            counts: {
                dropdownOptions: dropdowns.length,
                visualStyles: styles.length,
            },
            checkedAt: new Date().toISOString(),
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getSyncChecksum = getSyncChecksum;
