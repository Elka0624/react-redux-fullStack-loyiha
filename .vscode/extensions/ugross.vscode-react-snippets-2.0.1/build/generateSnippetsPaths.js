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
Object.defineProperty(exports, "__esModule", { value: true });
const utils_1 = require("./utils");
const constants_1 = require("./constants");
const init = () => __awaiter(void 0, void 0, void 0, function* () {
    yield utils_1.rimrafAsync(constants_1.OUTPUT_DIR);
    yield utils_1.mkdirAsync(constants_1.OUTPUT_DIR);
    const generalSnippetsObj = yield utils_1.getSnippetsFromFolder(constants_1.GENERAL_SNIPPETS_DIR);
    const jsSnippetsObj = yield utils_1.getSnippetsFromFolder(constants_1.JS_SNIPPETS_DIR);
    const tsSnippetsObj = yield utils_1.getSnippetsFromFolder(constants_1.TS_SNIPPETS_DIR);
    utils_1.writeFileAsync(constants_1.OUTPUT_DIR + '/javascript.json', JSON.stringify(Object.assign(Object.assign({}, generalSnippetsObj), jsSnippetsObj)));
    utils_1.writeFileAsync(constants_1.OUTPUT_DIR + '/typescript.json', JSON.stringify(Object.assign(Object.assign({}, generalSnippetsObj), tsSnippetsObj)));
});
init();
