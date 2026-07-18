"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const history_controller_1 = require("./history.controller");
const auth_1 = require("../../middlewares/auth");
const spamBlocker_1 = require("../../middlewares/spamBlocker");
const router = (0, express_1.Router)();
// All history routes require authentication
router.use(auth_1.authenticate);
router.use(spamBlocker_1.spamBlocker);
router.get('/shared', history_controller_1.getSharedPrompts);
router.get('/', history_controller_1.getHistory);
router.patch('/:id/favorite', history_controller_1.toggleFavorite);
router.patch('/:id/share', history_controller_1.toggleSharePrompt);
router.post('/:id/duplicate', history_controller_1.duplicatePrompt);
router.delete('/:id', history_controller_1.deletePrompt);
exports.default = router;
