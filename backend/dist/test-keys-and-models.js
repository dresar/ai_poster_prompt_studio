"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const db_1 = require("./config/db");
const schema_1 = require("./db/schema");
const generative_ai_1 = require("@google/generative-ai");
const dotenv = __importStar(require("dotenv"));
dotenv.config();
const modelsToTest = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash-exp',
    'gemini-2.5-flash',
    'gemini-3.1-flash-lite',
    'gemini-3.1-flash',
    'gemini-3.1-pro',
    'gemini-3.5-flash',
];
async function run() {
    console.log('=== GEMINI KEYS AND MODELS TESTING TOOL ===');
    console.log('Connecting to database...');
    const keys = await db_1.db.select().from(schema_1.geminiApiKeys);
    if (keys.length === 0) {
        console.log('No Gemini API keys found in the database.');
        return;
    }
    console.log(`Found ${keys.length} keys in database.\n`);
    for (let idx = 0; idx < keys.length; idx++) {
        const k = keys[idx];
        const masked = k.keyEncrypted.length > 8
            ? `${k.keyEncrypted.substring(0, 4)}••••${k.keyEncrypted.substring(k.keyEncrypted.length - 4)}`
            : k.keyEncrypted;
        console.log(`===============================================`);
        console.log(`Key #${idx + 1} | ID: ${k.id} | Status: ${k.healthStatus} | Active: ${k.isActive}`);
        console.log(`Masked Key: ${masked}`);
        console.log(`===============================================`);
        const genAI = new generative_ai_1.GoogleGenerativeAI(k.keyEncrypted);
        for (const modelName of modelsToTest) {
            try {
                const model = genAI.getGenerativeModel({ model: modelName });
                const response = await model.generateContent({
                    contents: [{ role: 'user', parts: [{ text: 'say OK' }] }],
                    generationConfig: { maxOutputTokens: 5 }
                });
                const text = response.response.text().trim();
                console.log(`  ✓ ${modelName.padEnd(23)} : [SUCCESS] Response: "${text}"`);
            }
            catch (err) {
                const errorMsg = err?.message || String(err);
                let reason = errorMsg;
                if (errorMsg.includes('404')) {
                    reason = 'Model not found / Not available';
                }
                else if (errorMsg.includes('403')) {
                    reason = 'Forbidden / Invalid API Key / Geo-blocked';
                }
                else if (errorMsg.includes('429')) {
                    reason = 'Rate limit exceeded';
                }
                console.log(`  ✗ ${modelName.padEnd(23)} : [FAILED] ${reason}`);
            }
        }
        console.log('\n');
    }
    console.log('Done.');
    process.exit(0);
}
run().catch((err) => {
    console.error('Fatal execution error:', err);
    process.exit(1);
});
