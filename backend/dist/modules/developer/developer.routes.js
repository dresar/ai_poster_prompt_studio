"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const poster_controller_1 = require("../poster/poster.controller");
const poster_schema_1 = require("../poster/poster.schema");
const validator_1 = require("../../middlewares/validator");
const developerKey_1 = require("../../middlewares/developerKey");
const spamBlocker_1 = require("../../middlewares/spamBlocker");
const router = (0, express_1.Router)();
// Secure all programmatic v1 endpoints with developer API Key
router.use(developerKey_1.authenticateDeveloperKey);
router.use(spamBlocker_1.spamBlocker);
router.post('/analyze-topic', (0, validator_1.validate)({ body: poster_schema_1.analyzeTopicSchema }), poster_controller_1.analyzeTopic);
router.post('/generate-prompt', (0, validator_1.validate)({ body: poster_schema_1.generatePosterSchema }), poster_controller_1.generatePoster);
router.post('/improve-prompt', (0, validator_1.validate)({ body: poster_schema_1.improvePromptSchema }), poster_controller_1.improvePrompt);
router.post('/analyze-image', (0, validator_1.validate)({ body: poster_schema_1.generateEnhanceSchema }), poster_controller_1.generateEnhance);
router.get('/content-ideas', (0, validator_1.validate)({ query: poster_schema_1.getIdeasSchema }), poster_controller_1.getContentIdeas);
router.get('/generate-hooks', (0, validator_1.validate)({ query: poster_schema_1.getHooksSchema }), poster_controller_1.getHooks);
exports.default = router;
