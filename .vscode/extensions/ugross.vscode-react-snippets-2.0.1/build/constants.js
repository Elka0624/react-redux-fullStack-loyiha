"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = __importDefault(require("path"));
exports.ROOT_DIR = path_1.default.resolve(__dirname, '../');
exports.GENERAL_SNIPPETS_DIR = path_1.default.resolve(exports.ROOT_DIR, './snippets/general');
exports.JS_SNIPPETS_DIR = path_1.default.resolve(exports.ROOT_DIR, './snippets/javascript');
exports.TS_SNIPPETS_DIR = path_1.default.resolve(exports.ROOT_DIR, './snippets/typescript');
exports.OUTPUT_DIR = path_1.default.resolve(exports.ROOT_DIR, './build/snippets');
exports.JS_REACT_LANGUAGES = ['javascript', 'javascriptreact'];
exports.TS_REACT_LANGUAGES = ['typescript', 'typescriptreact'];
exports.ALL_REACT_LANGUAGES = [...exports.JS_REACT_LANGUAGES, ...exports.TS_REACT_LANGUAGES];
exports.JSON_FILE_REGEX = /\.json$/;
