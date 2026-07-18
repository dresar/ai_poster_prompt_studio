"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const dropdown_controller_1 = require("./dropdown.controller");
const dropdown_schema_1 = require("./dropdown.schema");
const validator_1 = require("../../middlewares/validator");
const auth_1 = require("../../middlewares/auth");
const router = (0, express_1.Router)();
// Publicly available (or auth-only depending on project, let's allow authenticated users)
router.get('/', auth_1.authenticate, (0, validator_1.validate)({ query: dropdown_schema_1.queryDropdownSchema }), dropdown_controller_1.getDropdownOptions);
// Admin-only CRUD operations
router.post('/', auth_1.authenticate, (0, auth_1.requireRole)(['ADMIN']), (0, validator_1.validate)({ body: dropdown_schema_1.createDropdownOptionSchema }), dropdown_controller_1.createDropdownOption);
router.patch('/:id', auth_1.authenticate, (0, auth_1.requireRole)(['ADMIN']), (0, validator_1.validate)({ body: dropdown_schema_1.updateDropdownOptionSchema }), dropdown_controller_1.updateDropdownOption);
router.delete('/:id', auth_1.authenticate, (0, auth_1.requireRole)(['ADMIN']), dropdown_controller_1.deleteDropdownOption);
exports.default = router;
