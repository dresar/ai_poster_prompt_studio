"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const env_1 = require("./config/env");
const logger_1 = require("./config/logger");
const errorHandler_1 = require("./middlewares/errorHandler");
const db_1 = require("./config/db");
const drizzle_orm_1 = require("drizzle-orm");
const auth_routes_1 = __importDefault(require("./modules/auth/auth.routes"));
const poster_routes_1 = __importDefault(require("./modules/poster/poster.routes"));
const history_routes_1 = __importDefault(require("./modules/history/history.routes"));
const dropdown_routes_1 = __importDefault(require("./modules/dropdown/dropdown.routes"));
const admin_routes_1 = __importDefault(require("./modules/admin/admin.routes"));
const developer_routes_1 = __importDefault(require("./modules/developer/developer.routes"));
const sync_routes_1 = __importDefault(require("./modules/sync/sync.routes"));
const app = (0, express_1.default)();
// Middlewares
const ALLOWED_ORIGINS = [
    'https://porto.apprentice.cyou',
    'https://full-feature-showcase.vercel.app', // admin panel di vercel
    'http://localhost:5173', // admin dev
    'http://localhost:4173', // admin preview
    'http://localhost:8080', // flutter web dev
];
app.use((0, cors_1.default)({
    origin: (origin, callback) => {
        // Allow requests with no origin (e.g. mobile apps, Postman)
        if (!origin)
            return callback(null, true);
        if (ALLOWED_ORIGINS.includes(origin) || origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
            return callback(null, true);
        }
        return callback(new Error('Not allowed by CORS'));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-api-key'],
}));
// Strict HTTP Security Headers
app.use((req, res, next) => {
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Referrer-Policy', 'no-referrer');
    next();
});
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Request logging middleware
app.use((req, res, next) => {
    logger_1.logger.http(`${req.method} ${req.originalUrl} - IP: ${req.ip}`);
    next();
});
// Health check
app.get('/health', (req, res) => {
    res.status(200).json({ success: true, status: 'OK', timestamp: new Date() });
});
// DB Health check — diagnosa koneksi database dari server
app.get('/health/db', async (req, res) => {
    try {
        const result = await db_1.db.execute((0, drizzle_orm_1.sql) `SELECT 1 AS ok`);
        const dbUrl = process.env.DATABASE_URL || '';
        const host = dbUrl ? new URL(dbUrl.replace(/[&?]channel_binding=\w+/g, '')).hostname : 'unknown';
        res.status(200).json({
            success: true,
            status: 'DB Connected',
            host,
            timestamp: new Date(),
        });
    }
    catch (e) {
        const cause = e?.cause;
        res.status(500).json({
            success: false,
            status: 'DB Failed',
            error: e?.message?.split('\n')[0] || 'Unknown error',
            cause: cause?.message || null,
            pgCode: cause?.code || null,
            detail: cause?.detail || null,
            hint: cause?.hint || null,
            dbUrlSet: !!process.env.DATABASE_URL,
            timestamp: new Date(),
        });
    }
});
// API Routes
app.use('/api/auth', auth_routes_1.default);
app.use('/api/poster', poster_routes_1.default);
app.use('/api/history', history_routes_1.default);
app.use('/api/dropdown-options', dropdown_routes_1.default);
app.use('/api/admin', admin_routes_1.default);
app.use('/api/v1', developer_routes_1.default);
app.use('/api/sync', sync_routes_1.default);
// 404 Route handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'API route not found',
        code: 'NOT_FOUND',
    });
});
// Global Error Handler
app.use(errorHandler_1.errorHandler);
// Start server
app.listen(env_1.env.PORT, () => {
    logger_1.logger.info(`Server is running in ${env_1.env.NODE_ENV} mode on port ${env_1.env.PORT}`);
});
