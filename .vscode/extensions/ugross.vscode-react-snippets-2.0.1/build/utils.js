"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs_1 = require("fs");
const rimraf_1 = __importDefault(require("rimraf"));
const path_1 = require("path");
const util_1 = require("util");
const constants_1 = require("./constants");
/** Promisified `fs` methods */
exports.readFileAsync = (filePath) => util_1.promisify(fs_1.readFile)(filePath, 'utf8');
exports.readdirAsync = (dirPath) => util_1.promisify(fs_1.readdir)(dirPath, 'utf8');
exports.rimrafAsync = (folderPath) => util_1.promisify(rimraf_1.default)(folderPath);
exports.mkdirAsync = (folderPath) => util_1.promisify(fs_1.mkdir)(folderPath);
exports.writeFileAsync = (filePath, data) => util_1.promisify(fs_1.writeFile)(filePath, data, { encoding: 'utf8' });
/**
 * Get list if files paths based on directory
 * @param {string} dirPath - path to directory
 *
 * @returns list of files paths inside directory
 */
exports.getAllFilesInDir = (dirPath) => __awaiter(void 0, void 0, void 0, function* () {
    const files = yield exports.readdirAsync(dirPath);
    return files.map((f) => path_1.join(dirPath, f));
});
/**
 * Get files content based on paths
 * @param {string[]} filesPaths - list of paths to files
 *
 * @returns list of content of each file
 */
exports.getFilesContent = (filesPaths) => __awaiter(void 0, void 0, void 0, function* () {
    return Promise.all(filesPaths.map((filePath) => __awaiter(void 0, void 0, void 0, function* () {
        const fileContent = yield exports.readFileAsync(filePath);
        return fileContent.toString();
    })));
});
/**
 * Get all snippets in object format collected from files in one folder
 * @param {string} folderPath - folder that contains snippets
 *
 *  @returns object with all snippets
 */
exports.getSnippetsFromFolder = (folderPath) => __awaiter(void 0, void 0, void 0, function* () {
    const filesPaths = yield exports.getAllFilesInDir(folderPath);
    const jsonFiles = filesPaths.filter((filePath) => constants_1.JSON_FILE_REGEX.test(filePath));
    const snippetsContent = yield exports.getFilesContent(jsonFiles);
    const snippetsObj = snippetsContent.reduce((acc, snippetContent) => (Object.assign(Object.assign({}, acc), JSON.parse(snippetContent))), {});
    return snippetsObj;
});
