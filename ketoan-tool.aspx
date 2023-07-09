<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ketoan-tool.aspx.cs" Inherits="ketoan_tool" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Xml.Linq" %>
<script>
    $(document).ready(function () {
        $('#lay-center-ketoan_tool').parent().layout({
            west: {
                size: "20%"
            }
        });
        $('#lay-west-ketoan_tool button').button().css({ 'width': '95%' });
    });



    function getQueryString() {
        var frmID = '#frmketoan_tool';
        var queryString = "";
        return queryString;
    }

    function createKeToanTool(a, stt) {
        var frmID = '#frmketoan_tool';
        var frmEl = $("#frmketoan_tool");
        var divRptEl = $("#reportviewer");
        var chuThich = frmEl.find('.chuthich');
        var thaotac2 = frmEl.find('.thaotac2');
        frmEl.attr('stt', stt);
        $('#lblReportNameketoan_tool').html($(a).text());
        frmEl.show();
        divRptEl.html('');
        
        switch (stt) {
            case 1:
                chuThich.html('Nhập liệu ủy nhiệm chi');
                thaotac2.attr('onclick', 'submitRptTool(1)');
                break;
        }
    }

    function submitRptTool(type) {
        let $frmEl = $("#frmketoan_tool");
        var stt = $frmEl.attr('stt');
        var title = "", url = "";
        switch (stt) {
            case '1':
                title = "Nhập liệu ủy nhiệm chi";
                url = "ToolKeToan/NhapLieuUNC.aspx";
                break;
        }
		
        if (type == 1) {
            $frmEl.attr('action', url);
            $frmEl.submit();
        }
    }
 
    function actionRptTool(title, url, startdate, enddate, type) {
        var rptURL = url + "?startdate=" + startdate + "&enddate=" + enddate;
        if (type != "NULL") {
            rptURL += "&type=" + type;
        }

        window.open(rptURL);
    }
</script>

<div style="background:#F4F0EC" class="ui-layout-center ui-widget-content" id="lay-center-ketoan_tool">
    <form 
        enctype="multipart/form-data" 
        target="exportEXKT_popup"
        method="post" 
        id="frmketoan_tool"
        onsubmit="window.open('about:blank','exportEX_popup','width=700,height=700,scrollbars=yes');"
        style="display:none; user-select: none">
        <table>
            <tr>
                <td colspan="2"><h3 style="font-size:18px; padding:5px" id="lblReportNameketoan_tool"></h3></td>
            </tr>
            <tr style="height:10px">
                <td colspan=2>

                </td>
            </tr>
            <tr>
                <td colspan=2>
                    <input style="user-select: none" type="file" id="fileExcelKT" name="fileExcelKT" accept=".xls,.xlsx"/>
                </td>
            </tr>
            <tr style="height:10px">
                <td colspan=2>

                </td>
            </tr>
            <tr>
                <td colspan=2 style="vertical-align: middle;text-align: center;">
                    <input class="thaotac2" type="button" style="padding:3px 6px 3px 6px; user-select: none;" onclick="submitRptTool(1)" value="Thực hiện"/>
                </td>
            </tr>
        </table>
    </form>

    <div id="reportviewer">

    </div>
</div>

<div style="background:#F4F0EC;" class="ui-layout-west" id="lay-west-ketoan_tool">
    <div class="ui-widget-content" style="height:100%; overflow:auto; text-align:center">
        <button style="text-align:left;" onclick="createKeToanTool(this, 1)">Nhập liệu ủy nhiệm chi</button>
    </div>
</div>

