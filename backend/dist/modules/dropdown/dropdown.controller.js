"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteDropdownOption = exports.updateDropdownOption = exports.createDropdownOption = exports.getDropdownOptions = void 0;
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
const errorHandler_1 = require("../../middlewares/errorHandler");
const crypto_1 = __importDefault(require("crypto"));
const getDropdownOptions = async (req, res, next) => {
    try {
        const { groupKey } = req.query;
        const conditions = [(0, drizzle_orm_1.eq)(schema_1.dropdownOptions.isActive, true)];
        if (groupKey) {
            conditions.push((0, drizzle_orm_1.eq)(schema_1.dropdownOptions.groupKey, String(groupKey)));
        }
        const options = await db_1.db.select()
            .from(schema_1.dropdownOptions)
            .where((0, drizzle_orm_1.and)(...conditions))
            .orderBy((0, drizzle_orm_1.asc)(schema_1.dropdownOptions.sortOrder));
        res.status(200).json({
            success: true,
            data: options,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getDropdownOptions = getDropdownOptions;
const createDropdownOption = async (req, res, next) => {
    try {
        const { groupKey, label, value, helperText, icon, isActive, sortOrder } = req.body;
        const [option] = await db_1.db.insert(schema_1.dropdownOptions).values({
            id: crypto_1.default.randomUUID(),
            groupKey,
            label,
            value,
            helperText,
            icon,
            isActive: isActive !== undefined ? isActive : true,
            sortOrder: sortOrder || 0,
        }).returning();
        // Log admin action
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({
                id: crypto_1.default.randomUUID(),
                userId: req.user.id,
                action: 'create_dropdown_option',
                detail: { optionId: option.id, groupKey, label },
            });
        }
        res.status(201).json({
            success: true,
            message: 'Dropdown option created successfully',
            data: option,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.createDropdownOption = createDropdownOption;
const updateDropdownOption = async (req, res, next) => {
    try {
        const { id } = req.params;
        const updateData = req.body;
        const optionsArr = await db_1.db.select().from(schema_1.dropdownOptions).where((0, drizzle_orm_1.eq)(schema_1.dropdownOptions.id, id)).limit(1);
        const option = optionsArr[0];
        if (!option) {
            throw new errorHandler_1.AppError('Dropdown option not found', 404, 'NOT_FOUND');
        }
        const [updated] = await db_1.db.update(schema_1.dropdownOptions)
            .set(updateData)
            .where((0, drizzle_orm_1.eq)(schema_1.dropdownOptions.id, id))
            .returning();
        // Log admin action
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({
                id: crypto_1.default.randomUUID(),
                userId: req.user.id,
                action: 'update_dropdown_option',
                detail: { optionId: id, updateData },
            });
        }
        res.status(200).json({
            success: true,
            message: 'Dropdown option updated successfully',
            data: updated,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.updateDropdownOption = updateDropdownOption;
const deleteDropdownOption = async (req, res, next) => {
    try {
        const { id } = req.params;
        const optionsArr = await db_1.db.select().from(schema_1.dropdownOptions).where((0, drizzle_orm_1.eq)(schema_1.dropdownOptions.id, id)).limit(1);
        const option = optionsArr[0];
        if (!option) {
            throw new errorHandler_1.AppError('Dropdown option not found', 404, 'NOT_FOUND');
        }
        await db_1.db.delete(schema_1.dropdownOptions).where((0, drizzle_orm_1.eq)(schema_1.dropdownOptions.id, id));
        // Log admin action
        if (req.user?.id) {
            await db_1.db.insert(schema_1.logs).values({
                id: crypto_1.default.randomUUID(),
                userId: req.user.id,
                action: 'delete_dropdown_option',
                detail: { optionId: id, groupKey: option.groupKey, label: option.label },
            });
        }
        res.status(200).json({
            success: true,
            message: 'Dropdown option deleted successfully',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.deleteDropdownOption = deleteDropdownOption;
