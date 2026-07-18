"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.developerApiKeys = exports.visualStyles = exports.contentIdeas = exports.logs = exports.appSettings = exports.geminiApiKeys = exports.contentIdeaCategories = exports.hookPatterns = exports.promptTemplates = exports.dropdownOptions = exports.prompts = exports.licenseKeys = exports.users = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
exports.users = (0, pg_core_1.pgTable)('User', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    email: (0, pg_core_1.text)('email').notNull().unique(),
    passwordHash: (0, pg_core_1.text)('passwordHash').notNull(),
    role: (0, pg_core_1.text)('role').$type().default('USER').notNull(),
    subscriptionStatus: (0, pg_core_1.text)('subscriptionStatus').default('FREE').notNull(),
    subscriptionExpiresAt: (0, pg_core_1.timestamp)('subscriptionExpiresAt', { precision: 3 }),
    credits: (0, pg_core_1.integer)('credits').default(10).notNull(),
    createdAt: (0, pg_core_1.timestamp)('createdAt', { precision: 3 }).defaultNow().notNull(),
});
exports.licenseKeys = (0, pg_core_1.pgTable)('LicenseKey', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    key: (0, pg_core_1.text)('key').notNull().unique(),
    days: (0, pg_core_1.integer)('days').default(30).notNull(),
    credits: (0, pg_core_1.integer)('credits').default(300).notNull(),
    isUsed: (0, pg_core_1.boolean)('isUsed').default(false).notNull(),
    usedBy: (0, pg_core_1.text)('usedBy'),
    usedAt: (0, pg_core_1.timestamp)('usedAt', { precision: 3 }),
    createdAt: (0, pg_core_1.timestamp)('createdAt', { precision: 3 }).defaultNow().notNull(),
});
exports.prompts = (0, pg_core_1.pgTable)('Prompt', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    userId: (0, pg_core_1.text)('userId').notNull(),
    mode: (0, pg_core_1.text)('mode').notNull(),
    topic: (0, pg_core_1.text)('topic').notNull(),
    payloadJson: (0, pg_core_1.jsonb)('payloadJson').notNull(),
    promptFinal: (0, pg_core_1.text)('promptFinal').notNull(),
    referenceImageUrl: (0, pg_core_1.text)('referenceImageUrl'),
    category: (0, pg_core_1.text)('category'),
    hooks: (0, pg_core_1.text)('hooks').array(),
    viralScore: (0, pg_core_1.integer)('viralScore'),
    isFavorite: (0, pg_core_1.boolean)('isFavorite').default(false).notNull(),
    isShared: (0, pg_core_1.boolean)('isShared').default(false).notNull(),
    createdAt: (0, pg_core_1.timestamp)('createdAt', { precision: 3 }).defaultNow().notNull(),
});
exports.dropdownOptions = (0, pg_core_1.pgTable)('DropdownOption', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    groupKey: (0, pg_core_1.text)('groupKey').notNull(),
    label: (0, pg_core_1.text)('label').notNull(),
    value: (0, pg_core_1.text)('value').notNull(),
    helperText: (0, pg_core_1.text)('helperText'),
    icon: (0, pg_core_1.text)('icon'),
    isActive: (0, pg_core_1.boolean)('isActive').default(true).notNull(),
    sortOrder: (0, pg_core_1.integer)('sortOrder').default(0).notNull(),
});
exports.promptTemplates = (0, pg_core_1.pgTable)('PromptTemplate', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    category: (0, pg_core_1.text)('category').notNull(),
    template: (0, pg_core_1.text)('template').notNull(),
    isActive: (0, pg_core_1.boolean)('isActive').default(true).notNull(),
});
exports.hookPatterns = (0, pg_core_1.pgTable)('HookPattern', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    pattern: (0, pg_core_1.text)('pattern').notNull(),
    category: (0, pg_core_1.text)('category').notNull(),
    isActive: (0, pg_core_1.boolean)('isActive').default(true).notNull(),
});
exports.contentIdeaCategories = (0, pg_core_1.pgTable)('ContentIdeaCategory', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    name: (0, pg_core_1.text)('name').notNull(),
    isActive: (0, pg_core_1.boolean)('isActive').default(true).notNull(),
});
exports.geminiApiKeys = (0, pg_core_1.pgTable)('GeminiApiKey', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    keyEncrypted: (0, pg_core_1.text)('keyEncrypted').notNull(),
    isActive: (0, pg_core_1.boolean)('isActive').default(true).notNull(),
    priority: (0, pg_core_1.integer)('priority').default(0).notNull(),
    usageCount: (0, pg_core_1.integer)('usageCount').default(0).notNull(),
    lastUsedAt: (0, pg_core_1.timestamp)('lastUsedAt', { precision: 3 }),
    healthStatus: (0, pg_core_1.text)('healthStatus').default('healthy').notNull(),
    provider: (0, pg_core_1.text)('provider').default('gemini').notNull(),
});
exports.appSettings = (0, pg_core_1.pgTable)('AppSetting', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    key: (0, pg_core_1.text)('key').notNull().unique(),
    value: (0, pg_core_1.jsonb)('value').notNull(),
});
exports.logs = (0, pg_core_1.pgTable)('Log', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    userId: (0, pg_core_1.text)('userId'),
    action: (0, pg_core_1.text)('action').notNull(),
    detail: (0, pg_core_1.jsonb)('detail').notNull(),
    createdAt: (0, pg_core_1.timestamp)('createdAt', { precision: 3 }).defaultNow().notNull(),
});
exports.contentIdeas = (0, pg_core_1.pgTable)('ContentIdea', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    userId: (0, pg_core_1.text)('userId').notNull(),
    category: (0, pg_core_1.text)('category').notNull(),
    idea: (0, pg_core_1.text)('idea').notNull(),
    createdAt: (0, pg_core_1.timestamp)('createdAt', { precision: 3 }).defaultNow().notNull(),
});
exports.visualStyles = (0, pg_core_1.pgTable)('VisualStyle', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    name: (0, pg_core_1.text)('name').notNull(),
    promptTemplate: (0, pg_core_1.text)('promptTemplate').notNull(),
    previewImageUrl: (0, pg_core_1.text)('previewImageUrl'),
    isActive: (0, pg_core_1.boolean)('isActive').default(true).notNull(),
    createdAt: (0, pg_core_1.timestamp)('createdAt', { precision: 3 }).defaultNow().notNull(),
});
exports.developerApiKeys = (0, pg_core_1.pgTable)('DeveloperApiKey', {
    id: (0, pg_core_1.text)('id').primaryKey(),
    userId: (0, pg_core_1.text)('userId').notNull(),
    name: (0, pg_core_1.text)('name').default('Default Key').notNull(),
    apiKey: (0, pg_core_1.text)('apiKey').notNull().unique(),
    isActive: (0, pg_core_1.boolean)('isActive').default(true).notNull(),
    createdAt: (0, pg_core_1.timestamp)('createdAt', { precision: 3 }).defaultNow().notNull(),
});
