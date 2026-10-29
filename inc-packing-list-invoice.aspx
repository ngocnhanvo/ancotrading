<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-packing-list-invoice.aspx.cs" Inherits="inc_packing_list_invoice" %>

<%@ Register Src="jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<script>
    $(function () {
        $('#lay-center-pklivn').parent().layout({
            south: {
                size: "50%"
                , minSize: "0%"
                , maxSize: "100%"
                , onresize_end: function() {
                    var h = $("#lay-south-pklivn-detail").height();
                    // sett height
                    $("#grid_ds_chitietplivn").setGridHeight(h + 4 - 80);
                    $("#grid_ds_chitietphanboplivn").setGridHeight(h + 4 - 80);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#lay-center-pklivn").height();
                    $("#grid_ds_plivn").setGridHeight(h - 90);
                }
            }
        });

        $('#lay-south-pklivn-detail').layout({
            center: {
                onresize_end: function() {
                    var w = $("#tab-pklivn-detail").width();
                    //set width
                    $("#grid_ds_chitietplivn").setGridWidth(w);
                    $("#grid_ds_chitietphanboplivn").setGridWidth(w);
                }
            },
            east: {
                size: 200
                , maxSize: "100%"
                , minSize: 0
            }
        });

        $('#tab-pklivn-detail').tabs();
    });

    function phanBoCocInvoice() {
        var id = $("#grid_ds_chitietphanboplivn").jqGrid('getGridParam', 'selrow');
        if (id != null) {
            $.ajax({
                url: "inc-phanbococinvoice.aspx?chitietphaithuid=" + id,
                type: "POST",
                data: {},
                error: function(rs) { },
                success: function(rs) {
                    var div = $("<div></div>");
                    div.appendTo($(document.body));
                    div.html(rs);
                    div.dialog({
                        title: "Phân bổ tiền cọc cho Invoice",
                        resizable: false,
                        modal: true,
                        width: 530, 
                        close: function(event, ui) { $(this).dialog('destroy').remove(); }
                    });
                }
            });
        } else {
            alert("Chưa chọn dòng cần phân bổ!");
        }
    }

    function activePackingListInvoie() {
        var msg = "";
        var id = $('#grid_ds_plivn').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            msg = "Bạn hãy chọn 1 Packing List - Invoice mà bạn muốn hiệu lực.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-active-packinglist\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-active-packinglist').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            msg = "Có phải bạn muốn hiệu lực Packing List - Invoice này.?";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-active-packinglist\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-active-packinglist').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                    [
                        {
                            id: "btn-active-packinglist",
                            text: "Có",
                            click: function () {
                                $("#dialog-caution").ajaxStart(function () {
                                    $("#wait").css("display", "block");
                                    $("#btn-active-packinglist").button("disable");
                                    $("#btn-close").button("disable");
                                });

                                $("#dialog-caution").ajaxComplete(function () {
                                    $("#wait").css("display", "none");
                                    $("#btn-close span").text("Thoát");
                                    $("#btn-close").button("enable");
                                });

                                $.get("Controllers/PackingInvoiceController.ashx?action=activepacking&pakId=" + id, function (result) {
                                    //$('#dialog-caution').css({ 'color': 'green' });
                                    $('#dialog-active-packinglist').find('#dialog-caution').html(result);
                                    $('#grid_ds_plivn').jqGrid().trigger('reloadGrid');
                                });
                            }
                        },
                        {
                            id: "btn-close",
                            text: "Không",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
            });
        }
    }

    function funcPrintPKLI() {
        $.get('Controllers/PartnerController.ashx?action=getoption&isncc=1', function (result) {
            var pId = $('#grid_ds_plivn').jqGrid('getGridParam', 'selrow');
            var name = 'dialog-print-pkli';
            var title = 'Trích xuất dữ liệu';
            var content = '<table style="width:100%">' +
                '<tr>' +
                '<td>' +
                '<input id="printPkliList" type="radio" name="rdoPrintType" value="printPkliList" />' +
                '<label for="printPkliList">In Sale Contract</label>' +
                '</td>' +

                '<td>' +
                '<input id="printPackingList" type="radio" name="rdoPrintType" value="printPackingList" checked="checked" />' +
                '<label for="printPackingList">In Packing List</label>' +
                '</td>' +
                '</tr>' +
                '<tr>' +
                '<td>' +
                '<input id="printInvoice" type="radio" name="rdoPrintType" value="printInvoice" />' +
                '<label for="printInvoice">In Invoice</label>' +
                '</td>' +

                '<td>' +
                '<input id="printHQ" type="radio" name="rdoPrintType" value="printHQ" />' +
                '<label for="printHQ">In Tờ Khai Hải Quan</label>' +
                '</td>' +
                '</tr>' +
                '<tr>' +
                '<td>' +
                '<input id="printKhaiHQ" type="radio" name="rdoPrintType" value="printKhaiHQ" />' +
                '<label for="printKhaiHQ">In Danh Mục Khai Hải Quan (Mẫu 1)</label>' +
                '</td>' +
                '<td>' +
                '<input id="printPaymentRequest" type="radio" name="rdoPrintType" value="printPaymentRequest" />' +
                '<label for="printPaymentRequest">In mẫu payment request</label>' +
                '</td>' +
                '</tr>' +

                '<tr>' +
                '<td>' +
                '<input id="printKhaiHQ02" type="radio" name="rdoPrintType" value="printKhaiHQ02" />' +
                '<label for="printKhaiHQ02">In Danh Mục Khai Hải Quan (Mẫu 2)</label>' +
                '</td>' +
                '<td>' +
                '<input id="printBL" type="radio" name="rdoPrintType" value="printBL" />' +
                '<label for="printBL">In Mẫu BL</label>' +
                '<div id="md_ncu_id" style="display:none">' + result + '</div>' +
                '</td>' +
                '</tr>' +

                '<tr>' +
                '<td>' +
                '<input id="printKhaiHQ03" type="radio" name="rdoPrintType" value="printKhaiHQ03" />' +
                '<label for="printKhaiHQ03">In Danh Mục Khai Hải Quan (HScode)</label>' +
                '</td>' +
                '<td>' +

                '</td>' +
                '</tr>' +
                '</table>' + '<script>$(function(){ $("[name=\'rdoPrintType\']").bind("click", function () { if($(this).attr("value") == "printBL"){ $("#md_ncu_id").css("display","block");  }else{  $("#md_ncu_id").css("display","none");  }  }); });<\/script>';

            $('body').append('<div title="' + title + '" id="' + name + '">' + content + '</div>');
            $('#' + name).dialog({
                width: 500
                , modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: [
                    {
                        id: "btn-print-ok",
                        text: "In",
                        click: function () {
                            var printType = $('input[name=rdoPrintType]:checked', '#dialog-print-pkli').val();

                            var printURL = "PrintControllers/";
                            var windowSize = "width=700,height=700,scrollbars=yes";
                            if (typeof printType != 'undefined') {
                                if (printType == "printPackingList") {
                                    if (pId != null) {
                                        printURL += "InPackingList/";
                                        window.open(printURL + "?c_packinglist_id=" + pId, "In Phiếu Packing List", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu packing list');
                                    }
                                } else if (printType == 'printInvoice') {
                                    if (pId != null) {
                                        printURL += "InInvoice/";
                                        window.open(printURL + "?c_packinglist_id=" + pId, "In Phiếu Invoice", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu invoice');
                                    }
                                } else if (printType == 'printHQ') {
                                    if (pId != null) {
                                        printURL += "InToKhaiHQ/";
                                        window.open(printURL + "?c_packinglist_id=" + pId, "In Tờ Khai Hải Quan", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu tờ khai hải quan');
                                    }
                                } else if (printType == 'printKhaiHQ') {
                                    if (pId != null) {
                                        printURL += "InDanhMucKhaiHQ/";
                                        window.open(printURL + "?c_packinglist_id=" + pId, "In Danh Mục Khai Hải Quan", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu tờ khai hải quan');
                                    }
                                } else if (printType == 'printKhaiHQ02') {
                                    if (pId != null) {
                                        printURL += "InDanhMucKhaiHQ02/";
                                        window.open(printURL + "?c_packinglist_id=" + pId, "In Danh Mục Khai Hải Quan", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu tờ khai hải quan');
                                    }
                                } else if (printType == 'printBL') {
                                    if (pId != null) {
                                        printURL += "InBL/";
                                        window.open(printURL + "?c_packinglist_id=" + pId + "&md_doitackinhdoanh_id=" + $('#md_ncu_id').find('select').val(), "In Mẫu BL", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu book container');
                                    }
                                } else if (printType == 'printPaymentRequest') {
                                    if (pId != null) {
                                        printURL += "InPaymentRequest/";
                                        window.open("SendMail/PaymentRequest.aspx?pklId=" + pId, "In Mẫu PaymentRequest", windowSize);
                                        //window.open(printURL + "?c_packinglist_id=" + pId, "In Mẫu PaymentRequest", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu payment request');
                                    }
                                } else if (printType == 'printKhaiHQ03') {
                                    if (pId != null) {
                                        printURL += "InDanhMucKhaiHQ03/";
                                        window.open(printURL + "?c_packinglist_id=" + pId, "In Danh Mục Khai Hải Quan (HScode)", windowSize);
                                        //window.open(printURL + "?c_packinglist_id=" + pId, "In Mẫu PaymentRequest", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu tờ khai hải quan');
                                    }
                                }
                                else {
                                    if (pId != null) {
                                        printURL += "InSaleContact/";
                                        window.open(printURL + "?c_packinglist_id=" + pId, "In Sale Contract", windowSize);
                                    } else {
                                        alert('Bạn chưa chọn packing lsit - invoice cần in phiếu tờ khai hải quan');
                                    }
                                }
                            } else {
                                alert('Hãy chọn cách in.!');
                            }
                        }
                    }
                    , {
                        id: "btn-print-close",
                        text: "Thoát",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        });
    }

    function sendMailPKLINV() {
        var pklId = $('#grid_ds_plivn').jqGrid('getGridParam', 'selrow');
        if (pklId == null) {
            alert('Hãy chọn một Packing List - Invoice mà bạn muốn gửi email!');
        } else {
            window.open("SendMail/PaymentRequest.aspx?pklId=" + pklId, "Gửi email");
        }
    }
</script>
<div class="ui-layout-center ui-widget-content" id="lay-center-pklivn">
    <uc1:jqGrid ID="grid_ds_plivn"
        Caption="Packing List - Invoice"
        SortName="pi.ngaytao"
        BtnPrint="funcPrintPKLI"
        FuncActive="activePackingListInvoie"
        FuncSendMail="sendMailPKLINV"
        FuncTaoPKLCungKH="function(){ add_tab('Tạo Packing List - Invoice Cùng Khách Hàng', 'inc-tao-chungtuxuathang-cungkh.aspx')}"
        FuncTaoPKLCungPO="function(){ add_tab('Tạo Packing List - Invoice Cùng PO', 'inc-tao-chungtuxuathang-cungpo.aspx')}"
        UrlFileAction="Controllers/PackingInvoiceController.ashx"
        RowNumbers="true"
        OndblClickRow="function(rowid) { $(this).jqGrid('editGridRow', rowid, {
                
                width:900
                , beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                },
                errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs); 
                }
                
            }); }"
        ColModel="[
            {
                fixed: true, name: 'c_packinginvoice_id'
                , label: 'c_packinginvoice_id'
                , index: 'c_packinginvoice_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                 fixed: true, name: 'md_trangthai_id'
                 , label: 'TT'
                 , index: 'md_trangthai_id'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
                 , align: 'center'
                 , formatter: 'imagestatus'
            },
            {
                 fixed: true, name: 'so_pkl'
                 , label: 'Số Packing List'
                 , index: 'so_pkl'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 1 }
            },
            {
                 fixed: true, name: 'so_inv'
                 , label: 'Số Invoice'
                 , index: 'so_inv'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 2 }
            },
            {
                 fixed: true, name: 'sodh'
                 , label: 'Đơn Hàng'
                 , index: 'dh.sodh'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 2 }
            },
			{
                fixed: true, name: 'nguoitao', hidden: true
                , index: 'nguoitao1'
                , label: 'Người Tạo'
                , width: 100
                , editable:true
                , edittype: 'text'
                , editrules:{ edithidden : true }
				, editoptions: { readonly: 'readonly' }
				, formoptions: { colpos: 1, rowpos: 3 }
            },
            {
                 fixed: true, name: 'ngaylap'
                 , index: 'ngaylap'
                 , label: 'Ngày Lập'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , formoptions: { colpos: 1, rowpos: 4 }
            },
            {
                 fixed: true, name: 'nguoilap', hidden: true
                 , index: 'nguoilap'
                 , label: 'Người Lập'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 5 }
            },
            {
                 fixed: true, name: 'consignee', hidden: true
                 , label: 'Consignee'
                 , index: 'consignee'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 6 }
            },
            {
                 fixed: true, name: 'notifparty', hidden: true
                 , label: 'Notifparty'
                 , index: 'notifparty'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 7 }
            },
            {
                 fixed: true, name: 'alsonotifyparty', hidden: true
                 , label: 'Alsonotifyparty'
                 , index: 'alsonotifyparty'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 8 }
            },
            {
                 fixed: true, name: 'mv'
                 , label: 'Mv'
                 , index: 'mv'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 9 }
            },
            {
                 fixed: true, name: 'etd'
                 , label: 'Ngày Vận Đơn'
                 , index: 'etd'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , formoptions: { colpos: 1, rowpos: 10 }
            },
            {
                 fixed: true, name: 'noidi'
                 , label: 'Nơi Đi'
                 , index: 'noidi'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/PortController.ashx?action=getoptionAll' }
                 , formoptions: { colpos: 1, rowpos: 11 }
            },
            {
                 fixed: true, name: 'noiden'
                 , label: 'Nơi Đến'
                 , index: 'noiden'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 12 }
            },
            {
                 fixed: true, name: 'blno'
                 , label: 'BLNo'
                 , index: 'blno'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 2, rowpos: 1 }
            },
            {
                 fixed: true, name: 'commodity'
                 , label: 'Commodity'
                 , index: 'commodity'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 2, rowpos: 2 }
            },
            {
                 fixed: true, name: 'discount'
                 , label: 'Discount'
                 , index: 'discount'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules: { number:true, minValue:0 }
                 , editoptions:{ defaultValue:'0', readonly: 'readonly' }
                 , formoptions: { colpos: 2, rowpos: 3 }
            },
            {
                 fixed: true, name: 'handling_fee'
                 , index: 'handling_fee'
                 , label: 'Handling Fee'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules: { number:true, minValue:0 }
                 , editoptions:{ defaultValue:'0' }
                 , formoptions: { colpos: 2, rowpos: 4 }
            },
            {
                 fixed: true, name: 'diengiai_cong'
                 , label: 'Diễn Giải Cộng'
                 , index: 'diengiai_cong'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 2, rowpos: 5 }
            },
            {
                 fixed: true, name: 'giatri_cong'
                 , label: 'Giá Trị Cộng'
                 , index: 'giatri_cong'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules: { number:true, minValue:0 }
                 , editoptions:{ defaultValue:'0' }
                 , formoptions: { colpos: 2, rowpos: 6 }
            },
            {
                 fixed: true, name: 'diengiai_tru'
                 , label: 'Diễn Giải Trừ'
                 , index: 'diengiai_tru'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 2, rowpos: 7 }
            },
            {
                 fixed: true, name: 'giatri_tru'
                 , index: 'giatri_tru'
                 , label: 'Giá Trị Trừ'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules: { number:true, minValue:0 }
                 , editoptions:{ defaultValue:'0' }
                 , formoptions: { colpos: 2, rowpos: 8 }
            },
            {
                 fixed: true, name: 'diengiaicong_po'
                 , index: 'diengiaicong_po'
                 , label: 'Diễn Giải Cộng PO'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 3, rowpos: 5 }
                 , editoptions:{ readonly: 'readonly' }
            },
            {
                 fixed: true, name: 'giatricong_po'
                 , index: 'giatricong_po'
                 , label: 'Giá Trị Cộng PO'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules: { number:true, minValue:0 }
                 , editoptions:{ defaultValue:'0' }
                 , formoptions: { colpos: 3, rowpos: 6 }
            },
            {
                 fixed: true, name: 'diengiaitru_po'
                 , label: 'Diễn Giải Trừ PO'
                 , index: 'diengiaitru_po'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions:{ readonly: 'readonly' }
                 , formoptions: { colpos: 3, rowpos: 7 }
            },
            {
                 fixed: true, name: 'giatritru_po'
                 , index: 'giatritru_po'
                 , label: 'Giá Trị Trừ PO'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules: { number:true, minValue:0 }
                 , editoptions:{ defaultValue:'0' }
                 , formoptions: { colpos:3, rowpos: 8 }
            },
            {
                 fixed: true, name: 'commodityvn'
                 , label: 'Comoodity VN'
                 , index: 'commodityvn'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 2, rowpos: 9 }
            },
            {
                 fixed: true, name: 'ngay_motokhai'
                 , label: 'Ngày Mở Tờ Khai'
                 , index: 'ngay_motokhai'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , formoptions: { colpos: 2, rowpos: 10 }
            },
            {
                 fixed: true, name: 'ngay_phaitt'
                 , index: 'ngay_phaitt'
                 , label: 'Ngày Phải TT'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , formoptions: { colpos: 2, rowpos: 11 }
            },
            {
                 fixed: true, name: 'totaldis'
                 , label: 'Total Dis'
                 , index: 'totaldis'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions:{ readonly: 'readonly' }
                 , formoptions: { colpos: 2, rowpos: 12 }
            },
            {
                 fixed: true, name: 'totalnet'
                 , label: 'Total Net'
                 , index: 'totalnet'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions:{ readonly: 'readonly' }
                 , formoptions: { colpos: 2, rowpos: 13 }
            },            
            {
                 fixed: true, name: 'totalgross'
                 , label: 'Total Gross'
                 , index: 'totalgross'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions:{ readonly: 'readonly' }
                 , formoptions: { colpos: 2, rowpos: 14 }
            },
			{
                 fixed: true, name: 'tiendatcoc'
                 , label: 'Tiền đặt cọc'
                 , index: 'tiendatcoc'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions:{ readonly: 'readonly' }
                 , formoptions: { colpos: 2, rowpos: 15 }
            },
			{
                 fixed: true, name: 'tiendatra'
                 , label: 'Tiền đã trả'
                 , index: 'tiendatra'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions:{ readonly: 'readonly' }
                 , formoptions: { colpos: 2, rowpos: 16 }
            },
			{
                 fixed: true, name: 'tienconlai'
                 , index: 'tienconlai'
                 , label: 'Tiền còn lại'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions:{ readonly: 'readonly' }
                 , formoptions: { colpos: 2, rowpos: 17 }
            },
            {
                fixed: true, name: 'ngaytao'
                , index: 'ngaytao'
                , label: 'Ngày Tạo'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoitao'
                , index: 'nguoitao'
                , label: 'Người Tạo'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , label: 'Ngày Cập Nhật'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , label: 'Người Cập Nhật'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'mota'
                , label: 'Mô tả'
                , index: 'mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
                , formoptions: { colpos: 2, rowpos: 18 }
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , index: 'hoatdong'
                , label: 'Hoạt động'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            },
            {
                fixed: true, name: 'tygiaUSD_VND', hidden: false
                , label: 'Tỷ Giá USD-VND'
                , index: 'tygiaUSD_VND'
                , width: 100
                , editable:false
                , align: 'center'
            }
            ]"
        GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 90);"
        FilterToolbar="true"
        Height="420"
        MultiSelect="false"
        ShowEdit="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
        ShowDel="<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
        EditFormOptions=" 
                width:900
                , beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                },
                errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs); 
                }
            "
        ViewFormOptions="
                width:900
                , beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                },
                errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs); 
                }
            "
        DelFormOptions="
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                },
                errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs); 
                }
            "
        OnSelectRow="
            function(ids) {
		        if(ids == null) {
			        ids=0;
				} 
                else {
					$.ajax({
                        url: 'Controllers/PackingInvoiceController.ashx?action=getinvoiceinformation&pakId='+ids,
                        beforeSend:function(){
                            $('#grid_ds_plivn').jqGrid('setCaption','đang tải...');
                        },
                        success: function(data){
                            $('#grid_ds_plivn').jqGrid('setCaption', data);	
                        }
                    }); 			
		        }

                $('#grid_ds_chitietplivn').jqGrid('getGridParam', 'postData').pklId = ids;
				$('#grid_ds_chitietplivn')[0].triggerToolbar();
                $('#grid_ds_chitietphanboplivn').jqGrid('getGridParam', 'postData').pklId = ids;
				$('#grid_ds_chitietphanboplivn')[0].triggerToolbar();
                if (window.ancoPbPoPreview) window.ancoPbPoPreview.selectInvoice(ids);
            }
        "
        runat="server" />
</div>

<div class="ui-layout-south" id="lay-south-pklivn-detail">
    <div class="ui-layout-center" id="tab-pklivn-detail">
        <ul>
            <li><a href="#nav-tabs-pklivn1">Chi Tiết Packing List - Invoice</a></li>
            <li class="anco-pb-preview-tab"><a href="#nav-tabs-pklivn-pb">Phân bổ cọc</a></li>
            <li><a href="#nav-tabs-pklivn2">Chi tiết các khoản</a></li>
        </ul>
        <div id="nav-tabs-pklivn1">
            <uc1:jqGrid ID="grid_ds_chitietplivn"
                SortName="ma_sanpham"
                SortOrder="asc"
                UrlFileAction="Controllers/DongPackingListInvoiceController.ashx"
                ColNames="['c_dongpklinv_id', 'Packing List Invoice', 'TT', 'STT', 'Mã Sản Phẩm', 'Mã Sản Phẩm', 'Mô Tả Tiếng Anh', 'Mã Sản Phẩm Khách', 'Số Lượng', 'Giá', 'Thành Tiền',  'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
                RowNumbers="true"
                ColModel="[
                    {
                        fixed: true, name: 'c_dongpklinv_id'
                        , index: 'c_dongpklinv_id'
                        , width: 100
                        , hidden: true 
                        , editable:true
                        , edittype: 'text'
                        , key: true
                    },
                    {
                            fixed: true, name: 'c_packinginvoice_id'
                            , index: 'c_packinginvoice_id'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                            , hidden: true
                    },
                    {
                        fixed: true, name: 'trangthai'
                        , index: 'sp.trangthai'
                        , width: 100
                        , editable:false
                        , formatter:'imagestatus'
                        , align: 'center'
                        , search: false
                        , viewable: false
                        , sortable: false
                    },
                    {
                        fixed: true, name: 'line'
                        , index: 'line'
                        , width: 50
                        , edittype: 'text'
                        , editable:true
                        , align:'right'
                    },
                    {
                        fixed: true, name: 'sanpham_id'
                        , index: 'sanpham_id'
                        , width: 100
                        , hidden: true 
                        , editable:true
                        , edittype: 'text'
                    },
                    {
                        fixed: true, name: 'ma_sanpham'
                        , index: 'ma_sanpham'
                        , width: 100
                        , edittype: 'text'
                        , editable:true
                        , editoptions: { 
                            dataInit : function (elem) { 
                                $(elem).combogrid({
                                    searchIcon: true,
                                    width: '480px',
                                    url: 'Controllers/ProductController.ashx?action=getcombogrid',
                                    colModel: [
                                        { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden:true }
                                        , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã Sản Phẩm', 'align':'left'}
                                        , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả Tiếng Việt' , 'align':'left'}],
                                        select: function(event, ui) {
                                            $(elem).val(ui.item.ma_sanpham);
                                            $('#sanpham_id').val(ui.item.md_sanpham_id);
                                            return false;
                                        }
                                });
                            } 
                        }
                    },
                    {
                        fixed: true, name: 'mota_tienganh'
                        , index: 'mota_tienganh'
                        , width: 200
                        , edittype: 'text'
                        , editable:true
                    },
                    {
                        fixed: true, name: 'ma_sanpham_khach'
                        , index: 'dpk.ma_sanpham_khach'
                        , width: 100
                        , edittype: 'text'
                        , editable:true
                    },
                    {
                        fixed: true, name: 'soluong'
                        , index: 'soluong'
                        , width: 100
                        , edittype: 'text'
                        , editable:true
                        , editrules: { required:true, number:true, minValue:0 }
                        , editoptions:{ defaultValue:'0' }
                        , align:'right'
                        , formatter:'numberic'
                        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
                    },
                    {
                        fixed: true, name: 'gia'
                        , index: 'gia'
                        , width: 100
                        , edittype: 'text'
                        , editable:true
                        , editrules: { required:true, number:true, minValue:0 }
                        , editoptions:{ defaultValue:'0' }
                        , align:'right'
                        , formatter:'currency'
                        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
                    },
                    {
                        fixed: true, name: 'thanhtien'
                        , index: 'thanhtien'
                        , width: 100
                        , edittype: 'text'
                        , editable:false
                        , align:'right'
                        , formatter:'currency'
                        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
                    },
                    {
                        fixed: true, name: 'ngaytao'
                        , index: 'ngaytao'
                        , width: 100
                        , editable:false
                        , edittype: 'text'
                        , hidden: true 
                        , editrules:{ edithidden : true }
                    },
                    {
                        fixed: true, name: 'nguoitao'
                        , index: 'nguoitao'
                        , width: 100
                        , editable:false
                        , edittype: 'text'
                        , hidden: true 
                        , editrules:{ edithidden : true }
                    },
                    {
                        fixed: true, name: 'ngaycapnhat'
                        , index: 'ngaycapnhat'
                        , width: 100
                        , editable:false
                        , edittype: 'text'
                        , hidden: true 
                        , editrules:{ edithidden : true }
                    },
                    {
                        fixed: true, name: 'nguoicapnhat'
                        , index: 'nguoicapnhat'
                        , width: 100
                        , editable:false
                        , edittype: 'text'
                        , hidden: true 
                        , editrules:{ edithidden : true }
                    },
                    {
                        fixed: true, name: 'mota'
                        , index: 'mota'
                        , width: 500
                        , editable:true
                        , edittype: 'textarea'
                    },
                    {
                        fixed: true, name: 'hoatdong', hidden: true
                        , index: 'hoatdong'
                        , width: 100
                        , editable:true
                        , edittype: 'checkbox'
                        , align: 'center'
                        , editoptions:{ value:'True:False', defaultValue: 'True' }
                        , formatter: 'checkbox'
                    }
                    ]"
                        GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
                        FilterToolbar="true"
                        Height="420"
                        MultiSelect="false"
                        ViewFormOptions="
                    beforeShowForm: function (formid) {
                        formid.closest('div.ui-jqdialog').dialogCenter(); 
                    },
                    errorTextFormat:function(data) { 
                        return 'Lỗi: ' + data.responseText 
                    }
                "
                runat="server" />
        </div>


        <%-- UI preview only. Live PO deposit allocation requires a separate data and validation phase. --%>
        <div id="nav-tabs-pklivn-pb" class="anco-pb-preview-panel">
            <div class="anco-pb-head">
                <strong>Phân bổ tiền đặt cọc từ PO vào Invoice</strong>
                <span id="anco-pb-invoice-name">Chọn Invoice ở danh sách phía trên</span>
                <label class="anco-pb-demo-state">Xem thử trạng thái:
                    <select id="anco-pb-demo-status"><option value="draft">Soạn thảo</option><option value="active">Hiệu lực</option></select>
                </label>
            </div>
            <div class="anco-pb-demo-note"><strong>GIAO DIỆN XEM TRƯỚC</strong> — Các PO và số tiền bên dưới là dữ liệu minh họa. Chưa kết nối dữ liệu thật và chưa có chức năng lưu vào hệ thống.</div>
            <div class="anco-pb-columns">
                <section class="anco-pb-left" aria-label="Danh sách PO của Invoice">
                    <div class="anco-pb-section-title">PO thuộc Invoice <small>(chọn một PO)</small></div>
                    <div class="anco-pb-table-scroll">
                        <table class="anco-pb-grid"><thead><tr><th>PO</th><th>Cọc gốc</th><th>Đã PB</th><th>Cọc còn</th></tr></thead><tbody id="anco-pb-po-body"></tbody></table>
                    </div>
                </section>
                <section class="anco-pb-right" aria-label="Chi tiết phân bổ tiền cọc">
                    <div class="anco-pb-section-title"><span id="anco-pb-selected-po">Chi tiết phân bổ</span>
                        <button type="button" id="anco-pb-add-row">+ Thêm dòng phân bổ</button>
                    </div>
                    <div class="anco-pb-table-scroll">
                        <table class="anco-pb-grid"><thead><tr><th>STT</th><th>Tiền cọc trước PB</th><th>Tiền phân bổ</th><th>Tiền cọc sau PB</th><th>Thao tác</th></tr></thead><tbody id="anco-pb-detail-body"></tbody></table>
                    </div>
                    <div id="anco-pb-error" role="alert"></div>
                </section>
            </div>
            <div class="anco-pb-footer">
                <span>Tổng tiền phân bổ vào Invoice (dự kiến): <strong id="anco-pb-total">0.00</strong></span>
                <button type="button" id="anco-pb-save" disabled="disabled" title="Chức năng lưu sẽ được kết nối ở giai đoạn xử lý dữ liệu">Lưu (PB) — chưa kết nối</button>
            </div>
        </div>

        <div id="nav-tabs-pklivn2">
            <uc1:jqGrid  ID="grid_ds_chitietphanboplivn" 
            FilterToolbar="true"
            SortName="cttc.c_chitietthuchi_id" 
            UrlFileAction="Controllers/ChiTietThuChiPhanBoController.ashx" 
            ColNames="['c_chitietthuchi_id', 'Thu Chi', 'TK Nợ', 'TK Có', 'Số Tiền', 'Số Tiền Bao Gồm Phí', 'Quy Đổi', 'Diễn Giải',  'P/O', 'Packing list/Invoice', 'Là tiền cọc', 'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
            RowNumbers="true"
            FuncPhanBoCocInv="phanBoCocInvoice"
            ColModel = "[
            {
                fixed: true, name: 'c_chitietthuchi_id'
                , index: 'cttc.c_chitietthuchi_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                 fixed: true, name: 'c_thuchi_id'
                 , index: 'cttc.c_thuchi_id'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/ThuChiController.ashx?action=getoption' }
                 , editrules:{ edithidden : true }
                 , hidden:true
            },
            {
                fixed: true, name: 'tk_no'
                , index: 'cttc.tk_no'
                , width: 100
                , edittype: 'text'
                , editable:true
            },
            {
                fixed: true, name: 'tk_co'
                , index: 'cttc.tk_co'
                , width: 100
                , edittype: 'text'
                , editable:true
            },
            {
                fixed: true, name: 'sotien'
                , index: 'cttc.sotien'
                , width: 100
                , edittype: 'text'
                , editable:true
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
            },
            {
                fixed: true, name: 'tien'
                , index: 'cttc.tien'
                , width: 100
                , edittype: 'text'
                , editable:true
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
            },
            {
                fixed: true, name: 'quydoi'
                , index: 'cttc.quydoi'
                , width: 100
                , edittype: 'text'
                , editable:true
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
            },
            {
                fixed: true, name: 'diengiai'
                , index: 'cttc.diengiai'
                , width: 100
                , edittype: 'text'
                , editable:true
            },
            {
                fixed: true, name: 'c_donhang_id'
                , index: 'cttc.c_donhang_id'
                , width: 100
                , edittype: 'text'
                
            },
            {
                fixed: true, name: 'c_packinginvoice_id'
                , index: 'cttc.c_packinginvoice_id'
                , width: 100
                , edittype: 'text'
                
            },
            {
                fixed: true, name: 'isdatcoc'
                , index: 'cttc.isdatcoc'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , formatter: 'checkbox'
                , align: 'center'
            },
            {
                fixed: true, name: 'ngaytao'
                , index: 'cttc.ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoitao'
                , index: 'cttc.nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'cttc.ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'cttc.nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'mota'
                , index: 'cttc.mota'
                , width: 100
                , editable: true
                , edittype: 'textarea'
                , hidden: true
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , index: 'cttc.hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , editoptions:{ defaultValue: 'True' }
                , editrules:{ edithidden : true }
            }
            ]"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95); $(this).setGridWidth($(o).width()); "
            Height = "420"
            MultiSelect = "false" 
            ShowAdd ="false"
            ShowEdit ="false"
            ShowDel = "false"
            AddFormOptions=" 
            beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
            },
            errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
            }
            , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs);
                }
            "
            EditFormOptions ="
            beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
            },
            errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
            }
            , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs);
                }
            "
            ViewFormOptions="
            beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
            },
            errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
            }"
            DelFormOptions="
            beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
            },
            errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
            }
            , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs);
                }
            "
            runat="server" />
        </div>
    </div>
</div>


<%-- AncoTrading: mock-only preview for new PO -> Invoice deposit allocation UI.
     Keep hidden in normal production flow; enable with ?phanbococ_preview=1. --%>
<style type="text/css">
    .anco-pb-preview-tab { display: none; }
    #nav-tabs-pklivn-pb { padding: 5px 8px; box-sizing: border-box; font-size: 12px; height: 100%; min-height: 220px; }
    .anco-pb-head, .anco-pb-section-title, .anco-pb-footer { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
    .anco-pb-head { padding: 3px 0 7px; flex-wrap: wrap; }
    .anco-pb-head strong { font-size: 13px; }
    .anco-pb-demo-state { color: #555; }
    .anco-pb-demo-note { padding: 6px 9px; margin-bottom: 7px; border: 1px solid #e5c772; background: #fff8d9; color: #765109; }
    .anco-pb-columns { display: flex; gap: 8px; height: calc(100% - 115px); min-height: 130px; }
    .anco-pb-left, .anco-pb-right { min-width: 0; border: 1px solid #b9c4ce; display: flex; flex-direction: column; }
    .anco-pb-left { flex: 0 0 36%; } .anco-pb-right { flex: 1; }
    .anco-pb-section-title { background: #e6ecf1; padding: 5px 7px; font-weight: bold; border-bottom: 1px solid #b9c4ce; min-height: 24px; box-sizing: border-box; }
    .anco-pb-section-title small { font-weight: normal; color: #666; }
    .anco-pb-section-title button, .anco-pb-footer button { font-size: 12px; padding: 4px 9px; cursor: pointer; }
    .anco-pb-section-title button:disabled { cursor: not-allowed; }
    .anco-pb-table-scroll { overflow: auto; flex: 1; }
    table.anco-pb-grid { width: 100%; border-collapse: collapse; white-space: nowrap; }
    .anco-pb-grid th, .anco-pb-grid td { border: 1px solid #d4d9dd; padding: 5px 6px; text-align: right; }
    .anco-pb-grid th { background: #f2f3f4; position: sticky; top: 0; z-index: 1; }
    .anco-pb-grid th:first-child, .anco-pb-grid td:first-child { text-align: left; }
    .anco-pb-grid tr.anco-pb-po-row { cursor: pointer; }
    .anco-pb-grid tr.anco-pb-po-row:hover { background: #f4f9fc; }
    .anco-pb-grid tr.anco-pb-selected { background: #dceaf4; font-weight: bold; }
    .anco-pb-grid input.anco-pb-amount { box-sizing: border-box; width: 100%; min-width: 80px; max-width: 140px; text-align: right; padding: 3px; }
    .anco-pb-grid button.anco-pb-remove { font-size: 11px; color: #a02323; cursor: pointer; }
    #anco-pb-error { color: #a02323; padding: 3px 7px; min-height: 16px; }
    .anco-pb-footer { border-top: 1px solid #bdc6ce; margin-top: 7px; padding-top: 6px; font-size: 12px; }
    .anco-pb-footer strong { color: #176327; font-size: 14px; }
    .anco-pb-footer button:disabled { color: #777; cursor: not-allowed; }
</style>
<script type="text/javascript">
    window.ancoPbPoPreview = (function () {
        var enabled = /(?:\?|&)phanbococ_preview=1(?:&|$)/.test(window.location.search);
        var selected = 0, active = false;
        var po = [
            { code: "PO MẪU 001", original: 10000, allocated: 4000, rows: [1000, 1500] },
            { code: "PO MẪU 002", original: 8000, allocated: 1000, rows: [2000] },
            { code: "PO MẪU 003", original: 5000, allocated: 5000, rows: [] }
        ];
        function num(value) { return Math.round((Number(value) || 0) * 100) / 100; }
        function money(value) { return num(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
        function remaining(p) { return num(p.original - p.allocated); }
        function usedInDraft(p) { var n = 0; $.each(p.rows, function(i, v) { n += num(v); }); return num(n); }
        function render() {
            if (!enabled || !$("#anco-pb-po-body").length) return;
            var html = "", total = 0;
            $.each(po, function(i, p) {
                total += usedInDraft(p);
                html += '<tr class="anco-pb-po-row ' + (i === selected ? "anco-pb-selected" : "") + '" data-po="' + i + '"><td>' + p.code + '</td><td>' + money(p.original) + '</td><td>' + money(p.allocated) + '</td><td>' + money(remaining(p)) + '</td></tr>';
            });
            $("#anco-pb-po-body").html(html);
            var p = po[selected], before = remaining(p), detail = "";
            $("#anco-pb-selected-po").text("Chi tiết phân bổ — " + p.code);
            $.each(p.rows, function(i, value) {
                var after = num(before - num(value));
                detail += '<tr><td>' + (i + 1) + '</td><td>' + money(before) + '</td><td><input class="anco-pb-amount" type="number" min="0" step="0.01" data-row="' + i + '" value="' + num(value) + '"' + (active ? ' disabled="disabled"' : '') + '></td><td>' + money(after) + '</td><td><button type="button" class="anco-pb-remove" data-row="' + i + '"' + (active ? ' disabled="disabled"' : '') + '>Xóa</button></td></tr>';
                before = after;
            });
            $("#anco-pb-detail-body").html(detail || '<tr><td colspan="5" style="text-align:center;color:#777">PO chưa có dòng phân bổ trong Invoice này</td></tr>');
            $("#anco-pb-add-row").prop("disabled", active || remaining(p) <= usedInDraft(p));
            $("#anco-pb-total").text(money(total));
        }
        function selectInvoice(id) {
            if (!enabled) return;
            var value = "Chọn Invoice ở danh sách phía trên";
            if (id && id !== "0") {
                try {
                    var data = $("#grid_ds_plivn").jqGrid("getRowData", id);
                    value = "Invoice đang chọn: " + (data.so_inv || data.so_pkl || id);
                } catch (e) { value = "Invoice đang chọn"; }
            }
            $("#anco-pb-invoice-name").text(value);
        }
        function init() {
            if (!enabled || !$("#nav-tabs-pklivn-pb").length) return;
            $("#tab-pklivn-detail .anco-pb-preview-tab").show();
            $("#anco-pb-demo-status").on("change", function() {
                active = $(this).val() === "active";
                $("#anco-pb-error").text("");
                render();
            });
            $("#anco-pb-po-body").on("click", "tr[data-po]", function() {
                selected = Number($(this).attr("data-po"));
                $("#anco-pb-error").text("");
                render();
            });
            $("#anco-pb-add-row").on("click", function() {
                var p = po[selected];
                if (!active && remaining(p) > usedInDraft(p)) {
                    p.rows.push(0); render();
                    $("#anco-pb-detail-body input.anco-pb-amount").last().focus();
                }
            });
            $("#anco-pb-detail-body").on("change", "input.anco-pb-amount", function() {
                if (active) return;
                var index = Number($(this).attr("data-row")), p = po[selected], entered = Number($(this).val());
                var other = usedInDraft(p) - num(p.rows[index]);
                if (!isFinite(entered) || entered < 0 || num(entered) + other > remaining(p)) {
                    $("#anco-pb-error").text("Số phân bổ phải không âm và không vượt tiền cọc còn lại của PO.");
                    render(); return;
                }
                p.rows[index] = num(entered);
                $("#anco-pb-error").text("");
                render();
            });
            $("#anco-pb-detail-body").on("click", "button.anco-pb-remove", function() {
                if (active) return;
                po[selected].rows.splice(Number($(this).attr("data-row")), 1);
                $("#anco-pb-error").text("");
                render();
            });
            var currentInvoiceId = null;
            try {
                if ($("#grid_ds_plivn")[0] && $("#grid_ds_plivn")[0].grid) {
                    currentInvoiceId = $("#grid_ds_plivn").jqGrid("getGridParam", "selrow");
                }
            } catch (e) { currentInvoiceId = null; }
            selectInvoice(currentInvoiceId);
            render();
        }
        $(init);
        return { selectInvoice: selectInvoice };
    }());
</script>

<%-- VNN --%>
<script>
    function capnhatphicongphitru() {
        var msg = "";
        var id = $('#grid_ds_plivn').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            alert('Hãy chọn một Packing List - Invoice mà bạn muốn cập nhật!');
        } else {
            msg = "Cập nhật phí cộng, phí trừ.";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-capnhatinvoice\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-capnhatinvoice').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                    [
                        {
                            id: "btn-active",
                            text: "Có",
                            click: function () {
                                $("#wait").css("display", "block");
                                $("#btn-active").button("disable");
                                $("#btn-close").button("disable");


                                $.get("Controllers/PackingInvoiceController.ashx?action=updatephicongphitru&pakId=" + id, function (result) {
                                    //$('#dialog-caution').css({ 'color': 'green' });
                                    $('#dialog-capnhatinvoice').find('#dialog-caution').html(result.split(':')[1]);
                                    $('#grid_ds_plivn').jqGrid().trigger('reloadGrid');
                                    setTimeout(function () {
                                        $("#grid_ds_plivn").jqGrid('setSelection', result.split(':')[0]);
                                    }, 1000);
                                    $("#wait").css("display", "none");
                                    $("#btn-close span").text("Thoát");
                                    $("#btn-close").button("enable");
                                });
                            }
                        },
                        {
                            id: "btn-close",
                            text: "Không",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
            });
        }
    }

    setTimeout(function () {
        $('#grid_ds_plivn-pager_left table tr').append(
            '<td onclick="capnhatphicongphitru()" class="ui-pg-button ui-corner-all" title="Cập nhật phí cộng phí trừ" id="capnhat_grid_ds_plivn">' +
            '<div class="ui-pg-div"><span class="ui-icon ui-icon-gear"></span></div><td>')
            , 5000
    });

    createRightPanel('grid_ds_plivn');
    createRightPanel('grid_ds_chitietplivn');
    createRightPanel('grid_ds_chitietphanboplivn');
</script>

<style type="text/css">
    #capnhat_grid_ds_plivn:hover {
        border: 1px solid #f5ad66;
        background: #f5f0e5 url(images/ui-bg_glass_100_f5f0e5_1x400.png) 50% 50% repeat-x;
        font-weight: normal;
        color: #a46313;
        padding: 0
    }

    #capnhat_grid_ds_plivn:active {
        cursor: wait
    }
</style>

