"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AIGatewayService = void 0;
const gemini_gateway_service_1 = require("./gemini-gateway.service");
const groq_gateway_service_1 = require("./groq-gateway.service");
const db_1 = require("../../config/db");
const schema_1 = require("../../db/schema");
const drizzle_orm_1 = require("drizzle-orm");
class AIGatewayService {
    gemini = new gemini_gateway_service_1.GeminiGatewayService();
    groq = new groq_gateway_service_1.GroqGatewayService();
    async getProvider() {
        try {
            const settingsArr = await db_1.db.select().from(schema_1.appSettings).where((0, drizzle_orm_1.eq)(schema_1.appSettings.key, 'system_settings')).limit(1);
            const settings = settingsArr[0];
            const val = settings?.value;
            // Default to gemini if not explicitly set to groq
            return val?.defaultAIProvider === 'groq' ? 'groq' : 'gemini';
        }
        catch {
            return 'gemini';
        }
    }
    async analyzeReferenceImage(imageUrl) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.analyzeReferenceImage(imageUrl);
        try {
            return await this.gemini.analyzeReferenceImage(imageUrl);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.analyzeReferenceImage(imageUrl);
        }
    }
    async analyzeTopic(topic) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.analyzeTopic(topic);
        try {
            return await this.gemini.analyzeTopic(topic);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.analyzeTopic(topic);
        }
    }
    async generatePrompt(fullFormState) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.generatePrompt(fullFormState);
        try {
            return await this.gemini.generatePrompt(fullFormState);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.generatePrompt(fullFormState);
        }
    }
    async generateContentIdeas(userId, category) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.generateContentIdeas(userId, category);
        try {
            return await this.gemini.generateContentIdeas(userId, category);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.generateContentIdeas(userId, category);
        }
    }
    async generateHooks(topic) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.generateHooks(topic);
        try {
            return await this.gemini.generateHooks(topic);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.generateHooks(topic);
        }
    }
    async improvePrompt(promptDraft) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.improvePrompt(promptDraft);
        try {
            return await this.gemini.improvePrompt(promptDraft);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.improvePrompt(promptDraft);
        }
    }
    async generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes);
        try {
            return await this.gemini.generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes);
        }
    }
    async scoreViral(promptFinal) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.scoreViral(promptFinal);
        try {
            return await this.gemini.scoreViral(promptFinal);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.scoreViral(promptFinal);
        }
    }
    async chat(message, history) {
        const provider = await this.getProvider();
        if (provider === 'groq')
            return this.groq.chat(message, history);
        try {
            return await this.gemini.chat(message, history);
        }
        catch (e) {
            console.error('Gemini failed, falling back to Groq:', e);
            return await this.groq.chat(message, history);
        }
    }
}
exports.AIGatewayService = AIGatewayService;
