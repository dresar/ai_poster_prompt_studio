"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.queryDropdownSchema = exports.updateDropdownOptionSchema = exports.createDropdownOptionSchema = void 0;
const zod_1 = require("zod");
exports.createDropdownOptionSchema = zod_1.z.object({
    groupKey: zod_1.z.string().min(1, 'Group key is required'),
    label: zod_1.z.string().min(1, 'Label is required'),
    value: zod_1.z.string().min(1, 'Value is required'),
    helperText: zod_1.z.string().optional(),
    icon: zod_1.z.string().optional(),
    isActive: zod_1.z.boolean().optional(),
    sortOrder: zod_1.z.number().int().optional(),
});
exports.updateDropdownOptionSchema = zod_1.z.object({
    groupKey: zod_1.z.string().min(1).optional(),
    label: zod_1.z.string().min(1).optional(),
    value: zod_1.z.string().min(1).optional(),
    helperText: zod_1.z.string().optional(),
    icon: zod_1.z.string().optional(),
    isActive: zod_1.z.boolean().optional(),
    sortOrder: zod_1.z.number().int().optional(),
});
exports.queryDropdownSchema = zod_1.z.object({
    groupKey: zod_1.z.string().optional(),
});
