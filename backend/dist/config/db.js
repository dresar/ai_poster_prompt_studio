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
exports.db = void 0;
const neon_http_1 = require("drizzle-orm/neon-http");
const serverless_1 = require("@neondatabase/serverless");
const schema = __importStar(require("../db/schema"));
const logger_1 = require("./logger");
const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
    logger_1.logger.error('DATABASE_URL environment variable is missing!');
}
// Hapus channel_binding — tidak disuport oleh Neon HTTP driver
const cleanedUrl = connectionString?.replace(/[&?]channel_binding=\w+/g, '') ?? '';
// Neon HTTP driver: connect via HTTPS port 443, bukan TCP port 5432
// Solusi untuk cPanel/shared hosting yang blokir outbound port 5432
const sql = (0, serverless_1.neon)(cleanedUrl);
exports.db = (0, neon_http_1.drizzle)(sql, {
    schema,
    logger: {
        logQuery(query, params) {
            logger_1.logger.debug(`Drizzle Query: ${query} - Params: ${JSON.stringify(params)}`);
        }
    }
});
