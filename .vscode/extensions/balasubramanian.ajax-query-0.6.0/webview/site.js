
var QueryDet = {Rows : 2400, Cols : 24, panelName : '', ColNames: [], QueryID : 0, Partial : true, Error : 'No Errors', ServerDur : 24};
var pnlData = {QuerySql : 'select cldr_rpt_ky, cldr_dt, cldr_dt_yyyymmdd_cd, cldr_dt_dd_mon_yyyy_cd, cldr_dt_dd_mm_yyyy_cd, cldr_dt_mm_dd_yyyy_cd, cldr_dt_yyyy_mm_dd_cd, cldr_day_cd, cldr_day_nm, cldr_iso_yr_week_cd, cldr_iso_week_strt_dt from ea_common_r2_2itg.clndr_rpt limit 100;'
, Status : 'comp', Det : Object.assign({}, QueryDet), ExtractAll: '', ClientDur : 0, QueryStart : 0};
var curObj = Object.assign({}, QueryDet);
var qTxt = "describe ea_common_r2_2itg.chnlptnr_inv_fact;";
var env = "ITG";
var prevStatus = "";
var prevPnl = "";
var qryResults = [[]];
var pgno = 0;
var filtereddata = [[]];

var vscode;

function DownloadCSV() {
    vscode.postMessage({command : 'DownloadCSV', "pnlnme" : pnlnme});
}

function onld(){
    vscode = acquireVsCodeApi();
    vscode.postMessage({command : 'ready', "pnlnme" : pnlnme});
    if(usrname == '') fetchUserName();
    // showStatus();
    resize();
}

function hdrcolapse(){
    if(document.getElementById('hdrcolapse').innerHTML.indexOf('fa-eye-slash') == -1) {
        showStatus('exp');
    }
    else{
        showStatus('collap');
    }
    resize();
}

function resize() {
        
    var resdiv = document.getElementById('divresult');
    var hdr = document.getElementById('divhdr');
    
    resdiv.style.height = "calc(100% - " + (hdr.offsetHeight + 12) + "px)";
    resdiv.style.maxHeight = "calc(100% - " + (hdr.offsetHeight + 12) + "px)";
    
    document.getElementById('ResultTable').style.height = (document.getElementById('divresult').offsetHeight - 32) + 'px';
    
    var elem = document.querySelectorAll('#tbldata > tbody')[0];
    if(elem){
        if(elem.getAttribute('widthChecked')==null){
            var hcols = document.getElementsByTagName('th');
            var rcols = document.querySelectorAll('#tbldata > tbody > tr > td');
            for(var i=0;i<hcols.length;i++){
                var val = Math.min(350, Math.max(hcols[i].offsetWidth, rcols[i].offsetWidth));
                rcols[i].style['min-width'] =  val + 'px';
                rcols[i].style.width = val + 'px';
                rcols[i].style.maxWidth = val + 'px';

                hcols[i].style['min-width'] = val + 'px';
                hcols[i].style.width = val + 'px';
                hcols[i].style.maxWidth = val + 'px';
            }
            elem.setAttribute('widthChecked', "checked");
        }
        window.setTimeout(function () {
            document.getElementById('ResultTable').style.width = (document.getElementById('tbldata').offsetWidth + 10) + 'px';
        }, 100);
    }
}

function showStatus(hdrstat) {
    var qstatus = pnlData.Status;
    document.getElementById('datastat').innerText = '(Cols : ' + (pnlData.Det.Cols == 0? "-": pnlData.Det.Cols) + ', Rows : ' + (pnlData.Det.Cols ==0?"-" : pnlData.Det.Rows) + ', Dur : ' + pnlData.ClientDur + 'secs )'
    applyStyle([document.getElementById('message')
                ,document.getElementById('loginstatus')
                ,document.getElementById('expbtn')
                , document.getElementById('tablefooter')
                ,document.getElementById('tableopt')
                ,document.getElementById('divresult') ]
            , 'display', 'none');
    
    applyStyle([document.getElementById('querydetails')
                , document.getElementById('divTable')]
            ,'display','block');

    document.getElementById('etxt').style.display = (qstatus=="comp"?'block':'none');
    applyStyle([document.getElementById('hdrcolapse')
                    ,document.getElementById('datastat')]
                ,'display',(pnlData.Det.Rows > 0?'block':'none'));

    document.getElementById('querytxt').innerText = pnlData.QuerySql;
    document.getElementById('querytxt').title = pnlData.QuerySql;
    document.getElementById('errortxt').innerText = pnlData.Det.Error;
    document.getElementById('hdrstat').innerHTML = "Status : " + (qstatus == "exec"? "Executing": (qstatus == "down"? "Downloading": "Completed"));
    document.getElementById('loadinganim').style.display= (qstatus!="comp"?'block':'none');

    if(qstatus != 'comp') return false;
    
    if((pnlData.Det.Error == 'No Errors' || pnlData.Det.Error == '') && pnlData.Det.Partial){
        document.getElementById('errortxt').innerText = 'Result set is partial data for the query (due to time constraints).'
        //hdrstat = 'exp';
    }
    else if(pnlData.Det.Error == 'No Errors' || pnlData.Det.Error == ''){
        document.getElementById('errortxt').innerText = 'No Errors';
    }
    else if(pnlData.Det.Error != '') {
        return false;
    }

    if(pnlData.Det.Cols > 200 && pnlData.Det.Rows > 0){
        document.getElementById('errortxt').innerHTML += '<br />Sample Data cannot be loaded (Col Cnt > 200).'
        document.getElementById('expbtn').style.display = 'block';
        hdrstat = 'exp';
        return false;
    }
    if(hdrstat == null) hdrstat = (qstatus == "exec"?"exp":"collap");
        
    document.getElementById('hdrcolapse').innerHTML = (hdrstat=="exp" ?'<i class="fas fa-eye-slash"></i>':'<i class="fas fa-info-circle"></i>');

    document.getElementById('tablefooter').style.display = 'block';
    document.getElementById('querydetails').style.display = (hdrstat=="exp"?'block':'none');
    applyStyle([document.getElementById('tableopt'),document.getElementById('divresult'),document.getElementById('tablefooter')]
            , 'display', (pnlData.Det.Rows > 0?'block':'none'));

    resize();
}

function applyStyle(obj, styprop, val){
    for(var i=0;i<obj.length;i++) {
        var o = obj[i];
        o.style[styprop] = val;
    };
}

function fetchUserName() {
    document.getElementById('loginstatus').style.display = 'block';
    var xuser = new XMLHttpRequest();			
    xuser.withCredentials = true;
    xuser.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            vscode.postMessage({command : 'userdata', data : this.responseText, "pnlnme" : pnlnme});
        }
        else if(this.status >= 400){
            document.getElementById('userstatus').innerText = 'Unauthorized';
            document.getElementById('loginstatus').style.display = 'none';
            vscode.postMessage({command : 'userdata', data : '\"Error\"', "pnlnme" : pnlnme});
        }
    }
    xuser.open("POST", "https://hc4w01461.itcs.hpecorp.net/HiveExec/Home/CheckUserAccount?SesID=" + sesid, true);
    xuser.send();
}

window.addEventListener('message', event => {

    const message = event.data; // The JSON data our extension sent
    if(prevPnl != message.pnlnme)
        prevStatus = '';
    
    pnlnme = message.pnlnme;
    prevPnl = pnlnme;
    pnlData = message.querydet;
    if(message.command == ''){
        document.getElementById('message').style.display = 'block';
        applyStyle([document.getElementById('loginstatus')
                ,document.getElementById('divTable')], 'display', 'none');
    }
    else if(message.command == 'exec'){
        showStatus('exp');
    }
    else if(message.command == 'down'){
        showStatus('exp');
    }
    else if(message.command == 'comp' && prevStatus != 'comp'){
        var html = '<tr>';
        for(var i=0;i<pnlData.Det.ColNames.length;i++){
            html += '<th>' + pnlData.Det.ColNames[i] + '</th>'
        }
        html += '</tr>';
        document.getElementById('divresult').style.display = 'block';
        document.getElementById('tblhdr').innerHTML = html;
        qryResults = message.data;
        filtereddata = message.data;
        pgno = 1
        fetchData();
        window.setTimeout(function() {
            showStatus('collap');
        }, 100);
    }
    prevStatus = message.command;

});
var tmrhndlr = 0;
function applyfilter() {
    // if(tmrhndlr != 0)
    //     window.clearTimeout(tmrhndlr);
    // tmrhndlr = window.setTimeout(filterdata, 500);
    if(this.event.which == 13)
        filterdata();
}

function filterdata(){
    var filterkey = document.getElementById('searchKey').value;
    var shtml = '';
    var lncnt = 0;
    filtereddata = [];
    var cno = qryResults[0].length-1;
    for(var i=0;i<qryResults.length;i++){   
        if(qryResults[i][cno].indexOf(filterkey.toLowerCase())!=-1){
            filtereddata.push(qryResults[i]);
        }
    }
    pgno = 1;
    fetchData();
    resize();
}
function changepg(chng){
    var totpg = Math.ceil(filtereddata.length/50);
    if(pgno == 1 && chng == -1)
        return ;
    if(pgno == totpg && chng == 1)
        return ;

    pgno += chng;
    fetchData();
    resize();
}
function fetchData(){
    var shtml = '';
    var lnstart = (pgno-1) * 50;
    var lnend = (pgno * 50);
    lnend = (lnend>filtereddata.length?filtereddata.length:lnend);
    if(lnstart > lnend) return ;
    for(var i=lnstart;i<lnend;i++){   
        shtml += '<tr>';
        for(var j=0;j<filtereddata[i].length-1;j++){
            shtml += '<td>' + filtereddata[i][j] + '</td>';
        }
        shtml += '</tr>';
    }
    document.getElementById('tbldata').innerHTML = shtml;
    document.getElementById('pagingtext').innerHTML = '<span class="pgtxt">' + (lnstart + 1) + '</span> to <span class="pgtxt">' 
                                + lnend + '</span> of ' + filtereddata.length + ' (Total Recs : ' + pnlData.Det.Rows 
                                + ', Downloaded : ' + qryResults.length + ')';
    var hcols = document.getElementsByTagName('th');
    for(var i=0;i<hcols.length;i++){
        hcols[i].style['min-width'] = '50px';
        hcols[i].style.width = 'auto';
        hcols[i].style.maxWidth = '350px';
    }
    
}