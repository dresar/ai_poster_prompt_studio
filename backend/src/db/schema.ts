import { pgTable, text, timestamp, boolean, integer, jsonb } from 'drizzle-orm/pg-core';

export const users = pgTable('User', {
  id: text('id').primaryKey(),
  email: text('email').notNull().unique(),
  passwordHash: text('passwordHash').notNull(),
  role: text('role').$type<'USER' | 'ADMIN'>().default('USER').notNull(),
  subscriptionStatus: text('subscriptionStatus').default('FREE').notNull(),
  subscriptionExpiresAt: timestamp('subscriptionExpiresAt', { precision: 3 }),
  credits: integer('credits').default(10).notNull(),
  // Per-user ImageKit storage credentials (optional, stored encrypted)
  imagekitPublicKey: text('imagekitPublicKey'),
  imagekitPrivateKey: text('imagekitPrivateKey'),
  imagekitUrlEndpoint: text('imagekitUrlEndpoint'),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
});

export const licenseKeys = pgTable('LicenseKey', {
  id: text('id').primaryKey(),
  key: text('key').notNull().unique(),
  days: integer('days').default(30).notNull(),
  credits: integer('credits').default(300).notNull(),
  isUsed: boolean('isUsed').default(false).notNull(),
  usedBy: text('usedBy'),
  usedAt: timestamp('usedAt', { precision: 3 }),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
});

export const prompts = pgTable('Prompt', {
  id: text('id').primaryKey(),
  userId: text('userId').notNull(),
  mode: text('mode').notNull(),
  topic: text('topic').notNull(),
  payloadJson: jsonb('payloadJson').notNull(),
  promptFinal: text('promptFinal').notNull(),
  referenceImageUrl: text('referenceImageUrl'),
  referenceImageUrls: jsonb('referenceImageUrls').$type<string[]>().default([]),
  category: text('category'),
  hooks: text('hooks').array(),
  viralScore: integer('viralScore'),
  isFavorite: boolean('isFavorite').default(false).notNull(),
  isShared: boolean('isShared').default(false).notNull(),
  schemaVersion: text('schemaVersion').default('v1').notNull(),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
});

export const dropdownOptions = pgTable('DropdownOption', {
  id: text('id').primaryKey(),
  groupKey: text('groupKey').notNull(),
  label: text('label').notNull(),
  value: text('value').notNull(),
  helperText: text('helperText'),
  icon: text('icon'),
  isActive: boolean('isActive').default(true).notNull(),
  sortOrder: integer('sortOrder').default(0).notNull(),
});

export const promptTemplates = pgTable('PromptTemplate', {
  id: text('id').primaryKey(),
  category: text('category').notNull(),
  template: text('template').notNull(),
  isActive: boolean('isActive').default(true).notNull(),
  previewImageUrl: text('previewImageUrl'),
  viralScore: integer('viralScore'),
  viralBreakdown: jsonb('viralBreakdown'),
  payloadJson: jsonb('payloadJson'),
  hooks: text('hooks').array(),
  analysis: text('analysis'),
});

export const hookPatterns = pgTable('HookPattern', {
  id: text('id').primaryKey(),
  pattern: text('pattern').notNull(),
  category: text('category').notNull(),
  isActive: boolean('isActive').default(true).notNull(),
});

export const contentIdeaCategories = pgTable('ContentIdeaCategory', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  isActive: boolean('isActive').default(true).notNull(),
});

export const geminiApiKeys = pgTable('GeminiApiKey', {
  id: text('id').primaryKey(),
  keyEncrypted: text('keyEncrypted').notNull(),
  isEncrypted: boolean('isEncrypted').default(false).notNull(),
  isActive: boolean('isActive').default(true).notNull(),
  priority: integer('priority').default(0).notNull(),
  usageCount: integer('usageCount').default(0).notNull(),
  lastUsedAt: timestamp('lastUsedAt', { precision: 3 }),
  healthStatus: text('healthStatus').default('healthy').notNull(),
  provider: text('provider').default('gemini').notNull(),
});

export const appSettings = pgTable('AppSetting', {
  id: text('id').primaryKey(),
  key: text('key').notNull().unique(),
  value: jsonb('value').notNull(),
});

export const logs = pgTable('Log', {
  id: text('id').primaryKey(),
  userId: text('userId'),
  action: text('action').notNull(),
  detail: jsonb('detail').notNull(),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
});

export const contentIdeas = pgTable('ContentIdea', {
  id: text('id').primaryKey(),
  userId: text('userId').notNull(),
  category: text('category').notNull(),
  idea: text('idea').notNull(),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
});

export const visualStyles = pgTable('VisualStyle', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  promptTemplate: text('promptTemplate').notNull(),
  previewImageUrl: text('previewImageUrl'),
  isActive: boolean('isActive').default(true).notNull(),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
});

export const developerApiKeys = pgTable('DeveloperApiKey', {
  id: text('id').primaryKey(),
  userId: text('userId').notNull(),
  name: text('name').default('Default Key').notNull(),
  apiKey: text('apiKey').notNull().unique(),
  isActive: boolean('isActive').default(true).notNull(),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
});

export const characters = pgTable('Character', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  description: text('description').notNull(),
  imageUrl: text('imageUrl'),
  promptConsistency: text('promptConsistency').notNull(),
  characterBible: jsonb('characterBible'),
  positivePrompt: text('positivePrompt'),
  negativePrompt: text('negativePrompt'),
  masterPrompt: text('masterPrompt'),
  category: text('category').default('general').notNull(),
  isActive: boolean('isActive').default(true).notNull(),
  createdAt: timestamp('createdAt', { precision: 3 }).defaultNow().notNull(),
  updatedAt: timestamp('updatedAt', { precision: 3 }).defaultNow().notNull(),
});

export const formDescriptions = pgTable('FormDescription', {
  id: text('id').primaryKey(),
  featureKey: text('featureKey').notNull().unique(), // e.g., 'Poster', 'Banner'
  title: text('title').notNull(),
  description: text('description').notNull(),
  updatedAt: timestamp('updatedAt', { precision: 3 }).defaultNow().notNull(),
});
