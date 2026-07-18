"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const sync_controller_1 = require("./sync.controller");
const router = (0, express_1.Router)();
// Public endpoint � no auth needed, just returns a lightweight hash
router.get('/checksum', sync_controller_1.getSyncChecksum);
exports.default = router;
