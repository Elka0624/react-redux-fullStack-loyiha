"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const path = require("path");
const fs = require("fs");
const xhttp = require("http");
const queryParam = require("querystring");
const vscode_1 = require("vscode");
let showcolCommand = false;
let pnlID = {};
let pnlURI = {};
let pnl;
let queryData = {};
let sql = '';
let locSet = { locSesId: '', commentbreak: false, newlinebreak: true, multilinebreak: true, userName: '', accessLevel: '', userData: {}, "mssql.connections": [], userSesID: '' };
var blnkQry = { QuerySql: '', Status: '', Det: { Rows: 0, Cols: 0, panelName: '', ColNames: [], QueryID: 0, Partial: '', Error: 'No Errors', ServerDur: 0, Data: '' }, ExtractAll: '', QueryStart: Date.now(), pnlTitle: '', pnlPath: '', ClientDur: 0, notified: true, doc: undefined };
let env = "ITG";
let pnlrefreshed = true;
let pnlalive = false;
let extinit = true;
let curPnlName = '';
let qryStat = {};
let actedit = vscode.window.activeTextEditor;
var pnlData = {};
var extrctMax = '';
var locSetPath = '';
function activate(context) {
    let sql = require('vscode');
    let edr = vscode.window.activeTextEditor;
    // console.log('Congratulations, your extension "ajax-query" is now active!');
    let jsonstr = '';
    let webfldr = '';
    try {
        webfldr = vscode.Uri.file(path.join(context.extensionPath, 'webview')).with({ scheme: 'vscode-resource' }).toString();
        locSetPath = path.join(context.extensionPath, 'webview', 'locSet.json');
        jsonstr = fs.readFileSync(locSetPath).toString();
        locSet = JSON.parse(jsonstr);
        locSet["userName"] = '';
        locSet.locSesId = Date.now().toString();
        const configuration = vscode_1.workspace.getConfiguration();
        if (!configuration.get("mssql.connections")) {
            configuration.update("mssql.connections", locSet["mssql.connections"], vscode_1.ConfigurationTarget.Global).then(() => {
            });
        }
    }
    catch (e) {
        vscode.window.showErrorMessage("Error (start): " + e.message);
        return "";
    }
    let disposable = vscode.commands.registerCommand('extension.execquery', () => {
        try {
            if (!vscode.window.activeTextEditor && !actedit) {
                vscode.window.setStatusBarMessage("No Query String available", 2000);
                return;
            }
            actedit = (actedit && extinit ? actedit : (!vscode.window.activeTextEditor ? actedit : vscode.window.activeTextEditor));
            extinit = false;
            var edtrname = (actedit ? actedit.document.fileName : "");
            if (edtrname === '') {
                return;
            }
            if (!pnlID[edtrname] && actedit) {
                pnlID[edtrname] = Date.now().toString();
                curPnlName = pnlID[edtrname];
                pnlURI[curPnlName] = actedit.document.uri;
            }
            else if (!actedit) {
                return;
            }
            curPnlName = pnlID[edtrname];
            if (pnlData[curPnlName]) {
                if (pnlData[curPnlName].Status !== 'comp' && pnlData[curPnlName].Status !== '') {
                    // vscode.window.setStatusBarMessage("Please wait for the current query to finish", 2000);
                    actedit = vscode.window.activeTextEditor;
                    vscode.window.showErrorMessage("Query Execution for the previous command is in progress. Do you want to cancel the old query?", ...["Yes", "No"])
                        .then(sel => {
                        if (sel === "Yes") {
                            delete pnlData[curPnlName];
                            delete pnlID[edtrname];
                            vscode.commands.executeCommand("extension.execquery");
                            return;
                        }
                        else {
                            return;
                        }
                    });
                    return;
                }
            }
            sql = getSQL(actedit);
            if (sql.length === 0) {
                vscode.window.setStatusBarMessage("No Query String available", 2000);
                return false;
            }
            if (!pnlalive) {
                pnl = vscode.window.createWebviewPanel("Results", "Query Results", vscode.ViewColumn.Beside, {
                    enableScripts: true
                });
                pnlrefreshed = true;
                pnlalive = true;
            }
            pnlData[curPnlName] = Object.assign({}, blnkQry);
            pnlData[curPnlName].pnlTitle = edtrname.split('\\')[edtrname.split('\\').length - 1];
            pnlData[curPnlName].pnlPath = edtrname;
            pnlData[curPnlName].doc = actedit;
            pnlData[curPnlName].QuerySql = sql;
            pnlData[curPnlName].Status = '';
            if (!pnlrefreshed) {
                execQuery(curPnlName);
                if (!pnl.visible) {
                    pnl.reveal();
                }
            }
            else {
                pnl.webview.onDidReceiveMessage(message => {
                    pnlrefreshed = false;
                    processIncoming(message);
                }, undefined, context.subscriptions);
                pnl.webview.html = getHTML(path.join(context.extensionPath, 'webview', 'results.html'), webfldr);
            }
            pnl.onDidDispose(() => { pnlrefreshed = false; pnlalive = false; }, null, context.subscriptions);
        }
        catch (e) {
            vscode.window.showErrorMessage("Error (panel): " + e.message);
        }
        //vscode.window.showInformationMessage("Success");
    });
    context.subscriptions.push(disposable);
    context.subscriptions.push(vscode.commands.registerCommand('extension.chngenv', () => {
        getEnvName();
    }));
    context.subscriptions.push(vscode.commands.registerCommand('extension.showcols', () => {
        getColNames();
    }));
    context.subscriptions.push(vscode.commands.registerCommand('extension.signout', () => {
        locSet.userName = '';
        locSet.locSesId = Date.now().toString();
        pnl.dispose();
    }));
    context.subscriptions.push(vscode.commands.registerCommand('extension.hidepnl', () => {
        if (pnlalive) {
            pnl.dispose();
        }
        else {
            pnl = vscode.window.createWebviewPanel("Results", "Query Results", vscode.ViewColumn.Beside, {
                enableScripts: true
            });
            pnlrefreshed = true;
            pnlalive = true;
            pnl.webview.onDidReceiveMessage(message => {
                pnlrefreshed = false;
                processIncoming(message);
            }, undefined, context.subscriptions);
            pnl.webview.html = getHTML(path.join(context.extensionPath, 'webview', 'results.html'), webfldr);
            pnl.onDidDispose(() => { pnlrefreshed = false; pnlalive = false; }, null, context.subscriptions);
        }
    }));
    vscode.window.onDidChangeActiveTextEditor(cureditor => {
        if (!vscode.window.activeTextEditor) {
            return;
        }
        try {
            Object.keys(pnlData).forEach((pNme) => {
                var element = pnlData[pNme].doc;
                if (element) {
                    if (element.document.isClosed) {
                        try {
                            delete pnlData[pNme];
                            delete pnlID[element.document.fileName];
                            delete queryData[pNme];
                        }
                        catch (e) { }
                    }
                }
            });
            var edtrname = vscode.window.activeTextEditor.document.fileName;
            if (!pnlID[edtrname]) {
                pnlID[edtrname] = Date.now().toString();
            }
            if (curPnlName === pnlID[edtrname]) {
                return;
            }
            curPnlName = pnlID[edtrname];
            if (!pnlData[curPnlName]) {
                pnlData[curPnlName] = Object.assign({}, blnkQry);
            }
            if (pnlData[curPnlName].pnlTitle === '') {
                pnlData[curPnlName].pnlTitle = edtrname.split('\\')[edtrname.split('\\').length - 1];
                pnlData[curPnlName].pnlPath = edtrname;
                pnlURI[curPnlName] = vscode.window.activeTextEditor.document.uri;
                pnlData[curPnlName].doc = vscode.window.activeTextEditor;
            }
            updatePanelStatus(curPnlName);
        }
        catch (e) { }
    });
}
exports.activate = activate;
function getColNames() {
    showcolCommand = true;
    vscode.commands.executeCommand("extension.execquery");
}
function getEnvName() {
    vscode.window.showQuickPick(["ITG", "PVT", "PVL"], {
        canPickMany: false,
        placeHolder: "Current : " + env
    }).then(value => {
        env = (value ? value : 'ITG');
    });
}
function getHTML(htmlpath, urlpath) {
    let html = fs.readFileSync(htmlpath).toString();
    html = html.replace(/=\".\//g, '="' + urlpath + '/').replace('<pnlnme>', curPnlName).replace('<usrnme>', locSet.userName).replace('<sesid>', locSet.locSesId);
    return html;
}
function processIncoming(message) {
    if (!pnlData[message.pnlnme]) {
        pnlData[message.pnlnme] = Object.assign({}, blnkQry);
    }
    if (message.command === "ready") {
    }
    else if (message.command === "userdata") {
        var data = JSON.parse(message.data);
        if (message.data !== '\"Error\"') {
            locSet.userData = data;
            locSet.userName = data.NTLogin;
            locSet.userSesID = data.sessionid;
            //fs.writeFileSync(locSetPath,JSON.stringify(locSet));
        }
    }
    else if (message.command === "DownloadCSV") {
        if (pnlData[message.pnlnme].Det.QueryID > 0) {
            vscode.commands.executeCommand('vscode.open', vscode.Uri.parse('http://hc4w01461.itcs.hpecorp.net/HiveExec/Home/GetData?QueryID=' + pnlData[message.pnlnme].Det.QueryID + '&Format=CSV'));
        }
    }
    if (locSet.userName !== '') {
        if (pnlData[message.pnlnme].Status === '') {
            execQuery(message.pnlnme);
        }
        else {
            updatePanelStatus(message.pnlnme);
        }
    }
}
function execQuery(pnlnme) {
    if (locSet.userName === '') {
        vscode.window.showErrorMessage("User Unauthorized. Query Execution not triggered");
        pnl.dispose();
        return;
    }
    pnlData[pnlnme].notified = false;
    pnlData[pnlnme].Status = 'exec';
    pnlData[pnlnme].QueryStart = Date.now();
    pnlData[pnlnme].ClientDur = 0;
    updatePanelStatus(pnlnme);
    var url;
    var qstring = "";
    if (showcolCommand) {
        downQuery(pnlnme);
        return;
    }
    else {
        url = require('url').parse("http://hc4w01461.itcs.hpecorp.net/HiveExec/" + env + "/RunQuery");
        qstring = queryParam.stringify({ SQL: pnlData[pnlnme].QuerySql, panelName: pnlnme, UserName: locSet.userName, Extracts: extrctMax, SesID: locSet.userSesID });
    }
    var options = {
        host: url.hostname,
        port: 80,
        path: url.path,
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': Buffer.byteLength(qstring)
        }
    };
    let hndler = xhttp.request(options, (res) => {
        if (res.statusCode) {
            if (res.statusCode >= 400) {
                pnlData[pnlnme].Status = "comp";
                pnlData[pnlnme].Det.Error = (res.statusMessage ? res.statusMessage : "Error occured while downloading");
                updatePanelStatus(pnlnme);
                return;
            }
        }
        res.setEncoding('utf8');
        let resdata = '';
        let errpnlnme = pnlnme.toString();
        res.on('data', (chunk) => {
            resdata += chunk;
        });
        res.on('end', () => {
            try {
                var qdata = JSON.parse(resdata);
                pnlData[qdata.panelName].Det = qdata;
                if (qdata.Error === "" && qdata.Rows !== 0) {
                    downQuery(qdata.panelName);
                }
                else {
                    if (qdata.Rows === 0 && qdata.Error === '') {
                        qdata.Error = "No Data returned by Query";
                    }
                    pnlData[qdata.panelName].Status = 'comp';
                    updatePanelStatus(pnlnme);
                }
            }
            catch (e) {
                pnlData[errpnlnme].Status = 'comp';
                pnlData[errpnlnme].Det.Error = e.message;
                updatePanelStatus(pnlnme);
            }
        });
    });
    hndler.write(qstring);
    hndler.end();
}
function downQuery(pnlnme) {
    pnlData[pnlnme].Status = 'down';
    updatePanelStatus(pnlnme);
    let errpnlnme = pnlnme.toString();
    queryData[errpnlnme] = [[]];
    const fetch = require('node-fetch');
    var qryURL = '';
    if (showcolCommand) {
        qryURL = "http://hc4w01461.itcs.hpecorp.net/HiveExec/" + env + "/GetColNames?TableName="
            + pnlData[pnlnme].QuerySql + "&panelName=" + pnlnme;
        showcolCommand = false;
    }
    else {
        qryURL = "http://hc4w01461.itcs.hpecorp.net/HiveExec/" + env + "/GetData?QueryID="
            + pnlData[pnlnme].Det.QueryID + "&panelName=" + pnlnme;
    }
    fetch(qryURL)
        .then((res) => {
        if (!res.ok) {
            pnlData[pnlnme].Status = "comp";
            pnlData[pnlnme].Det.Error = res.statusText;
            updatePanelStatus(pnlnme);
        }
        else {
            return res.json();
        }
    })
        .then((qdata) => {
        try {
            if (qdata.QueryID !== -1) {
                pnlData[qdata.panelName].Det = qdata;
            }
            var tbldata = parseCSV(qdata.Data);
            tbldata.forEach((d, i) => {
                var concstr = '';
                d.forEach((s) => {
                    if (s !== '') {
                        concstr += s.toLowerCase() + ' ';
                    }
                });
                d.push(concstr);
            });
            queryData[qdata.panelName] = tbldata;
            pnlData[pnlnme].Status = 'comp';
            updatePanelStatus(pnlnme);
        }
        catch (e) {
            pnlData[pnlnme].Status = "comp";
            pnlData[errpnlnme].Det.Error = e.message;
            updatePanelStatus(pnlnme);
        }
    });
}
function checkPnlActive(pnlnme) {
    var active = false;
    vscode.window.visibleTextEditors.forEach((v, i, a) => {
        active = (v.document.fileName === pnlData[pnlnme].pnlPath);
        if (active) {
            return;
        }
    });
    return active;
}
function updatePanelStatus(pnlnme) {
    if (pnlData[pnlnme].Status === 'comp' && pnlData[pnlnme].ClientDur === 0) {
        pnlData[pnlnme].ClientDur = Math.ceil((Date.now() - pnlData[pnlnme].QueryStart) / 1000);
    }
    if (!queryData[pnlnme]) {
        queryData[pnlnme] = [[]];
    }
    if ((pnlnme !== curPnlName || !checkPnlActive(pnlnme)) && !pnlData[pnlnme].notified) {
        if (pnlData[pnlnme].Status === 'comp') {
            if (pnlData[pnlnme].doc) {
                if (!pnlData[pnlnme].doc.document.isClosed) {
                    vscode.window
                        .showInformationMessage("Query Execution Completed for Window - " + pnlData[pnlnme].pnlTitle, ...["Ignore"])
                        .then(sel => {
                        if (sel === "Open") {
                            vscode.window.showTextDocument(pnlData[pnlnme].doc.document, pnlData[pnlnme].doc.ViewColumn);
                            pnl.reveal();
                        }
                    });
                }
            }
            pnlData[pnlnme].notified = true;
        }
        return;
    }
    if (pnlData[pnlnme].Status === 'comp') {
        pnlData[pnlnme].notified = true;
    }
    pnl.webview.postMessage({
        command: pnlData[pnlnme].Status,
        pnlnme: pnlnme,
        querydet: pnlData[pnlnme],
        data: (pnlData[pnlnme].Status === 'comp' ? queryData[pnlnme] : '')
    });
}
function getSQL(editor) {
    if (!editor) {
        return '';
    }
    var multibrk = false;
    let sql = '';
    var selection = editor.selection;
    try {
        sql = editor.document.getText(selection);
    }
    catch (e) { }
    if (sql === '' && showcolCommand) {
        var ltxt = editor.document.lineAt(editor.selection.active.line).text;
        var chrpos = editor.selection.active.character - 1;
        var stxt = "";
        for (var ci = chrpos; ci >= 0; ci--) {
            if (ltxt[ci] !== ' ') {
                stxt = ltxt[ci] + stxt;
            }
            else {
                break;
            }
        }
        for (ci = chrpos + 1; ci < ltxt.length; ci++) {
            if (ltxt[ci] !== ' ') {
                stxt += ltxt[ci];
            }
            else {
                break;
            }
        }
        sql = stxt;
        return sql.replace(/\u00a0/g, " ");
    }
    if (sql === '') {
        let lne = editor.selection.active.line;
        //Get cur line + prev lines value
        //break for new lines or if last char is ;
        for (var i = lne; i >= 0; i--) {
            var txt = editor.document.lineAt(i).text;
            if (txt.trimRight().substr(txt.trimRight().length - 1, 1) === ";" && sql !== '') {
                break;
            }
            if (txt.trimLeft().substr(0, 2) === "--" && locSet.commentbreak && sql !== '') {
                break;
            }
            if (txt === '' && locSet.newlinebreak && sql !== '') {
                break;
            }
            if (txt === '' && multibrk && locSet.newlinebreak && sql !== '') {
                break;
            }
            if (txt === '') {
                multibrk = true;
            }
            else {
                multibrk = false;
                var qtxt = txt.split("'");
                var linetxt = '';
                for (var j = 0; j < qtxt.length; j++) {
                    if (qtxt[j].indexOf('--') === -1 || (j % 2) !== 0) {
                        linetxt += (j === 0 ? "" : "'") + qtxt[j];
                    }
                    else {
                        linetxt += (j === 0 ? "" : "'") + qtxt[j].substr(0, qtxt[j].indexOf('--'));
                        break;
                    }
                }
                sql = linetxt + ' ' + sql;
            }
        }
        var totlines = editor.document.lineCount;
        //if current is last line or cur lines last char = ;
        if (totlines === lne + 1 || sql.trimRight().substr(sql.trimRight().length - 1, 1) === ";") {
            return sql;
        }
        //Get next lines value 
        for (i = lne + 1; i < totlines; i++) {
            txt = editor.document.lineAt(i).text;
            if (txt.trimLeft().substr(0, 2) === "--" && locSet.commentbreak) {
                break;
            }
            if (txt === '' && locSet.newlinebreak) {
                break;
            }
            if (txt === '' && multibrk && locSet.newlinebreak) {
                break;
            }
            if (txt === '') {
                multibrk = true;
            }
            else {
                multibrk = false;
                qtxt = txt.split("'");
                linetxt = '';
                for (j = 0; j < qtxt.length; j++) {
                    if ((qtxt[j].indexOf('--') === -1 && qtxt[j].indexOf(';') === -1) || (j % 2) !== 0) {
                        linetxt += (j === 0 ? "" : "'") + qtxt[j];
                    }
                    else {
                        var pos1 = qtxt[j].indexOf('--');
                        var pos2 = qtxt[j].indexOf(';');
                        var pos = ((pos1 === -1 || pos2 < pos1) ? pos2 : pos1);
                        linetxt += (j === 0 ? "" : "'") + qtxt[j].substr(0, pos);
                        break;
                    }
                }
                sql += linetxt + ' ';
            }
        }
    }
    return sql.replace(/\u00a0/g, " ");
}
// this method is called when your extension is deactivated
function deactivate() { }
exports.deactivate = deactivate;
function parseCSV(str) {
    var arr = [[]];
    var quote = false; // true means we're inside a quoted field
    // iterate over each character, keep track of current row and column (of the returned array)
    for (var row = 0, col = 0, c = 0; c < str.length; c++) {
        var cc = str[c], nc = str[c + 1]; // current character, next character
        arr[row] = arr[row] || []; // create a new row if necessary
        arr[row][col] = arr[row][col] || ''; // create a new column (start with empty string) if necessary
        // If the current character is a quotation mark, and we're inside a
        // quoted field, and the next character is also a quotation mark,
        // add a quotation mark to the current column and skip the next character
        if (cc === '"' && quote && nc === '"') {
            arr[row][col] += cc;
            ++c;
            continue;
        }
        // If it's just one quotation mark, begin/end quoted field
        if (cc === '"') {
            quote = !quote;
            continue;
        }
        // If it's a comma and we're not in a quoted field, move on to the next column
        if (cc === ',' && !quote) {
            ++col;
            continue;
        }
        // If it's a newline (CRLF) and we're not in a quoted field, skip the next character
        // and move on to the next row and move to column 0 of that new row
        if (cc === '\r' && nc === '\n' && !quote) {
            ++row;
            col = 0;
            ++c;
            continue;
        }
        // If it's a newline (LF or CR) and we're not in a quoted field,
        // move on to the next row and move to column 0 of that new row
        if (cc === '\n' && !quote) {
            ++row;
            col = 0;
            continue;
        }
        if (cc === '\r' && !quote) {
            ++row;
            col = 0;
            continue;
        }
        // Otherwise, append the current character to the current column
        arr[row][col] += cc;
    }
    return arr;
}
//# sourceMappingURL=extension.js.map