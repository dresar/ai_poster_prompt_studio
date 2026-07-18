"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("./auth.controller");
const auth_schema_1 = require("./auth.schema");
const validator_1 = require("../../middlewares/validator");
const auth_1 = require("../../middlewares/auth");
const router = (0, express_1.Router)();
router.post('/register', (0, validator_1.validate)({ body: auth_schema_1.registerSchema }), auth_controller_1.register);
router.post('/login', (0, validator_1.validate)({ body: auth_schema_1.loginSchema }), auth_controller_1.login);
router.post('/refresh', (0, validator_1.validate)({ body: auth_schema_1.refreshTokenSchema }), auth_controller_1.refresh);
// Protected routes
router.post('/change-password', auth_1.authenticate, (0, validator_1.validate)({ body: auth_schema_1.changePasswordSchema }), auth_controller_1.changePassword);
router.get('/profile', auth_1.authenticate, auth_controller_1.getProfile);
exports.default = router;
