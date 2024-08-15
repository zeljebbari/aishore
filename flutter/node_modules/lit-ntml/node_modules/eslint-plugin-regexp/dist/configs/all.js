"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.rules = exports.plugins = void 0;
const recommended_1 = require("./recommended");
const rules_1 = require("../utils/rules");
const all = {};
for (const rule of rules_1.rules) {
    all[rule.meta.docs.ruleId] = "error";
}
exports.plugins = ["regexp"];
exports.rules = Object.assign(Object.assign({}, all), recommended_1.rules);
