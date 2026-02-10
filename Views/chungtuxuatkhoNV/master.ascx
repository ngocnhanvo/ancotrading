<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_chungtuxuatkhoNV_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<script type="text/javascript">
    function funcPrintPKLI_CTXKNV() {
        
            var pId = $('#grid_ds_ctxkNV').jqGrid('getGridParam', 'selrow');
            var name = 'dialog-print-pkli-ctxk';
            var title = 'Trích xuất dữ liệu';
            var content = `
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td>
                        <input id="printPkliList" type="radio" name="rdoPrintType" value="printPkliList" />
                        <label for="printPkliList">In Sale Contract</label>
                    </td>
                    <td>
                        <input id="printPackingList" type="radio" name="rdoPrintType" value="printPackingList" checked="checked" />
                        <label for="printPackingList">In Packing List</label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input id="printInvoice" type="radio" name="rdoPrintType" value="printInvoice" />
                        <label for="printInvoice">In Invoice</label>
                    </td>
                    <td>
                        <input id="printHQ" type="radio" name="rdoPrintType" value="printHQ" />
                        <label for="printHQ">In Tờ Khai Hải Quan</label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input id="printKhaiHQ" type="radio" name="rdoPrintType" value="printKhaiHQ" />
                        <label for="printKhaiHQ">In Danh Mục Khai Hải Quan (Mẫu 1)</label>
                    </td>
                    <td>
                        <input id="printPaymentRequest" type="radio" name="rdoPrintType" value="printPaymentRequest" />
                        <label for="printPaymentRequest">In mẫu payment request</label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input id="printKhaiHQ02" type="radio" name="rdoPrintType" value="printKhaiHQ02" />
                        <label for="printKhaiHQ02">In Danh Mục Khai Hải Quan (Mẫu 2)</label>
                    </td>
                    <td>
                        <input id="printBL" type="radio" name="rdoPrintType" value="printBL" />
                        <label for="printBL">In Mẫu BL</label>
                        <div id="md_ncu_id" style="display:none">Đang tải...</div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input id="printKhaiHQ03" type="radio" name="rdoPrintType" value="printKhaiHQ03" />
                        <label for="printKhaiHQ03">In Danh Mục Khai Hải Quan (HScode)</label>
                    </td>
                    <td>
                        <input id="printSPDT" type="radio" name="rdoPrintType" value="printSPDT" />
                        <label for="printSPDT">In Shipping Details</label>
                    </td>
                </tr>
            </table>`;

            $('body').append('<div title="' + title + '" id="' + name + '">' + content + '</div>');
            $('#' + name).dialog({
                width: 500
                , modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    $.get('Controllers/PartnerController.ashx?action=getoption&isncc=1', function (result) {
                        $('#md_ncu_id').html(result);
                    });

                    $("[name='rdoPrintType']").bind("click", function () {
                            if ($(this).attr("value") == "printBL") {
                                $("#md_ncu_id").css("display", "block");
                            }
                            else {
                                $("#md_ncu_id").css("display", "none");
                            }
                        });
                }
                , buttons: [
                    {
                        id: "btn-print-ok",
                        text: "In",
                        click: function () {
                            var printType = $('input[name=rdoPrintType]:checked', `#${name}`).val();

                            var printURL = "PrintControllers/";
                            var windowSize = "width=700,height=700,scrollbars=yes";
                            if (typeof printType == 'undefined') {
                                alert('Hãy chọn cách in.!');
                                return;
                            }

                            let kiemtra_packingINVDaChon = function () {
                                if (!pId) {
                                    alert('Bạn chưa chọn packing lsit - invoice cần in phiếu packing list');
                                    throw new Error("Chưa chọn packing list");
                                }
                            };
                            kiemtra_packingINVDaChon();

                            if (printType == "printPackingList") {
                                printURL += "InPackingList/";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Phiếu Packing List", windowSize);    
                            }
                            else if (printType == 'printInvoice') {
                                printURL += "InInvoice/";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Phiếu Invoice", windowSize);
                            }
                            else if (printType == 'printHQ') {
                                printURL += "InToKhaiHQ/";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Tờ Khai Hải Quan", windowSize);
                            }
                            else if (printType == 'printKhaiHQ') {
                                printURL += "InDanhMucKhaiHQ/";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Danh Mục Khai Hải Quan", windowSize);   
                            }
                            else if (printType == 'printKhaiHQ02') {
                                printURL += "InDanhMucKhaiHQ02/";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Danh Mục Khai Hải Quan", windowSize);
                            }
                            else if (printType == 'printBL') {
                                printURL += "InBL/";
                                window.open(printURL + "?c_packinglist_id=" + pId + "&md_doitackinhdoanh_id=" + $('#md_ncu_id').find('select').val(), "In Mẫu BL", windowSize);
                            }
                            else if (printType == 'printPaymentRequest') {
                                printURL += "InPaymentRequest/";
                                window.open("SendMail/PaymentRequest.aspx?pklId=" + pId, "In Mẫu PaymentRequest", windowSize);
                            }
                            else if (printType == 'printKhaiHQ03') {
                                printURL += "InDanhMucKhaiHQ03/";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Danh Mục Khai Hải Quan (HScode)", windowSize);
                            }
                            else if (printType == 'printSPDT') {
                                printURL += "InInvoice/InSPDT.aspx";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Shipping Details", windowSize);
                            }
                            else {
                                printURL += "InSaleContact/";
                                window.open(printURL + "?c_packinglist_id=" + pId, "In Sale Contract", windowSize);
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
    }

    function activePackingListInvoieNV() {
        var msg = "";
        var id = $('#grid_ds_ctxkNV').jqGrid('getGridParam', 'selrow');

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
                                    $('#grid_ds_ctxkNV').jqGrid().trigger('reloadGrid');
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

    function sendMailPKLINV() {
        var pklId = $('#grid_ds_ctxkNV').jqGrid('getGridParam', 'selrow');
        if (pklId == null) {
            alert('Hãy chọn một Packing List - Invoice mà bạn muốn gửi email!');
        } else {
            window.open("SendMail/PaymentRequest.aspx?pklId=" + pklId, "Gửi email");
        }
    }
</script>

<uc1:jqGrid ID="grid_ds_ctxkNV"
    Caption="Packing List - Invoice"
    SortName="pi.ngaytao"
    BtnPrint="funcPrintPKLI_CTXKNV"
    FuncActive="activePackingListInvoieNV"
    FuncSendMail="sendMailPKLINV"
    FuncTaoPKLCungKH="function(){ add_tab('Tạo Packing List - Invoice Cùng Khách Hàng', 'inc-tao-chungtuxuathang-cungkh.aspx')}"
    FuncTaoPKLCungPO="function(){ add_tab('Tạo Packing List - Invoice Cùng PO', 'inc-tao-chungtuxuathang-cungpo.aspx')}"
    UrlFileAction="Controllers/PackingInvoiceController.ashx"
    RowNumbers="true"
    OndblClickRow="function(rowid) { $('#edit_grid_ds_ctxkNV').click(); }"
    ColModel="[
        {
            fixed: true, name: 'c_packinginvoice_id'
            , label: 'c_packinginvoice_id'
            , index: 'c_packinginvoice_id'
            , width: 100
            , hidden: true 
            , editable:false
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
            , editrules: { edithidden: false }
            , viewable: false
        },
        {
            fixed: true, name: 'ma_khachhang'
            , label: 'Mã KH'
            , index: 'dtkd.ma_dtkd'
            , editable: false
            , width: 100
            , edittype: 'text'
            , editrules: { edithidden: false }
            , viewable: false
        },
        {
            fixed: true, name: 'so_inv'
            , label: 'Số Invoice'
            , index: 'so_inv'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { disabled: false }
            , formoptions: { colpos: 1, rowpos: 1 }
        },
        {
            fixed: true, name: 'sodh'
            , label: 'Đơn Hàng'
            , index: 'dbo.LayChungTuDonHang(pi.c_packinginvoice_id)'
            , editable: false
            , width: 100
            , edittype: 'text'
            , viewable: false
        },
		{
            fixed: true, name: 'nguoitao', hidden: false
            , index: 'nguoitao1'
            , label: 'Người Tạo'
            , width: 100
            , editable:true
            , edittype: 'text'
            , editrules:{ edithidden : true }
			, editoptions: { disabled: true }
			, formoptions: { colpos: 1, rowpos: 2 }
        },
        {
            fixed: true, name: 'ngaylap'
            , index: 'ngaylap'
            , label: 'Ngày Lập'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 3 }
            , align: 'center'
        },
        {
            fixed: true, name: 'mv', hidden: false
            , index: 'mv'
            , label: 'Tên tàu'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 4 }
        },
        {
            fixed: true, name: 'etd'
            , label: 'Ngày Vận Đơn'
            , index: 'etd'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 5 }
            , align: 'center'
        },
        {
            fixed: true, name: 'etd2'
            , label: 'Ngày ETD'
            , index: 'etd2'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 6 }
            , align: 'center'
        },
        {
            fixed: true, name: 'POL'
            , label: 'Port of loading'
            , index: 'POL'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 7 }
            , editoptions: { disabled: true }
        },
        {
            fixed: true, name: 'POD', hidden: false
            , label: 'Port of discharge'
            , index: 'POD'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 8 }
            , editoptions: { disabled: true }
        },
        {
            fixed: true, name: 'importCountry', hidden: false
            , label: 'Import Country'
            , index: 'importCountry'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 9 }
        },
        {
            fixed: true, name: 'blno'
            , label: 'BLNo'
            , index: 'blno'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 10 }
        },
        {
            fixed: true, name: 'Forwarder'
            , label: 'Forwarder'
            , index: 'Forwarder'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 11 }
            , editoptions: { disabled: true }
        },
        {
            fixed: true, name: 'ngay_motokhai'
            , label: 'Ngày Mở Tờ Khai'
            , index: 'ngay_motokhai'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 2, rowpos: 9 }
            , align: 'center'
        },
        {
            fixed: true, name: 'totalgross'
            , label: 'Total Gross'
            , index: 'totalgross'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ readonly: 'readonly' }
            , formoptions: { colpos: 2, rowpos: 13 }
            , align: 'right'
        },
		{
            fixed: true, name: 'tiendatcoc'
            , label: 'Tiền đặt cọc'
            , index: 'tiendatcoc'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ readonly: 'readonly' }
            , formoptions: { colpos: 2, rowpos: 14 }
            , align: 'right'
        },
		{
            fixed: true, name: 'tiendatra'
            , label: 'Tiền đã trả'
            , index: 'tiendatra'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ readonly: 'readonly' }
            , formoptions: { colpos: 2, rowpos: 15 }
            , align: 'right'
        },
		{
            fixed: true, name: 'tienconlai'
            , index: 'tienconlai'
            , label: 'Tiền còn lại'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ readonly: 'readonly' }
            , formoptions: { colpos: 2, rowpos: 16 }
            , align: 'right'
        },
        {
            fixed: true, name: 'ngay_phaitt'
            , index: 'ngay_phaitt'
            , label: 'Ngày Phải TT'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { disabled: true, dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 2, rowpos: 10 }
            , align: 'center'
        },
        {
            fixed: true, name: 'khutrung', hidden: false
            , label: 'Khử trùng'
            , index: 'khutrung'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 12 }
        },
        {
            fixed: true, name: 'ngayCutOff', hidden: false
            , label: 'Ngày cut off SI của htau'
            , index: 'ngayCutOff'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 13 }
            , align: 'center'
        },
        {
            fixed: true, name: 'checkBL', hidden: false
            , label: 'Check B/L'
            , index: 'checkBL'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 14 }
            , align: 'center'
        },
        {
            fixed: true, name: 'LocalCharge', hidden: false
            , label: 'Local charge'
            , index: 'LocalCharge'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 15 }
        },
        {
            fixed: true, name: 'co', hidden: false
            , label: 'CO'
            , index: 'co'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 16 }
            , align: 'center'
        },
        {
            fixed: true, name: 'ngayPayMent', hidden: false
            , label: 'Ngày gửi PAYMENT REQUEST'
            , index: 'ngayPayMent'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 17 }
            , align: 'center'
        },
        {
            fixed: true, name: 'ngayTelLex', hidden: false
            , label: 'Ngày gửi chứng từ Khách/TELEX'
            , index: 'ngayTelLex'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            , formoptions: { colpos: 1, rowpos: 18 }
            , align: 'center'
        },
        {
            fixed: true, name: 'ghichuCT', hidden: false
            , label: 'Ghi chú (CT)'
            , index: 'ghichuCT'
            , editable: true
            , width: 100
            , edittype: 'textarea'
        },
        {
            fixed: true, name: 'so_pkl'
            , label: 'Số Packing List'
            , index: 'so_pkl'
            , editable: false
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'nguoilap', hidden: true
            , index: 'nguoilap'
            , label: 'Người Lập'
            , editable: false
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
            , formoptions: { colpos: 1, rowpos: 19 }
            , editrules:{ edithidden : true }
        },
        {
            fixed: true, name: 'notifparty', hidden: true
            , label: 'Notifparty'
            , index: 'notifparty'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 20 }
            , editrules:{ edithidden : true }
        },
        {
            fixed: true, name: 'alsonotifyparty', hidden: true
            , label: 'Alsonotifyparty'
            , index: 'alsonotifyparty'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 21 }
            , editrules:{ edithidden : true }
        },
        {
            fixed: true, name: 'noidi'
            , label: 'Nơi Đi'
            , index: 'noidi'
            , editable: true
            , width: 100
            , edittype: 'select'
            , editoptions: { dataUrl: 'Controllers/PortController.ashx?action=getoptionAll' }
            , formoptions: { colpos: 1, rowpos: 22 }
        },
        {
            fixed: true, name: 'noiden'
            , label: 'Nơi Đến'
            , index: 'noiden'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 1, rowpos: 23 }
        },
        {
            fixed: true, name: 'commodity'
            , label: 'Commodity'
            , index: 'commodity'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 2, rowpos: 1 }
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
            , formoptions: { colpos: 2, rowpos: 2 }
            , align: 'right'
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
            , formoptions: { colpos: 2, rowpos: 3 }
            , align: 'right'
        },
        {
            fixed: true, name: 'diengiai_cong'
            , label: 'Diễn Giải Cộng'
            , index: 'diengiai_cong'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 2, rowpos: 4 }
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
            , formoptions: { colpos: 2, rowpos: 5 }
            , align: 'right'
        },
        {
            fixed: true, name: 'diengiai_tru'
            , label: 'Diễn Giải Trừ'
            , index: 'diengiai_tru'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 2, rowpos: 6 }
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
            , formoptions: { colpos: 2, rowpos: 7 }
            , align: 'right'
        },
        {
            fixed: true, name: 'diengiaicong_po'
            , index: 'diengiaicong_po'
            , label: 'Diễn Giải Cộng PO'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 3, rowpos: 4 }
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
            , formoptions: { colpos: 3, rowpos: 5 }
            , align: 'right'
        },
        {
            fixed: true, name: 'diengiaitru_po'
            , label: 'Diễn Giải Trừ PO'
            , index: 'diengiaitru_po'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ readonly: 'readonly' }
            , formoptions: { colpos: 3, rowpos: 6 }
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
            , formoptions: { colpos:3, rowpos: 7 }
            , align: 'right'
        },
        {
            fixed: true, name: 'totaldis'
            , label: 'Total Dis'
            , index: 'totaldis'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ readonly: 'readonly' }
            , formoptions: { colpos: 2, rowpos: 11 }
            , align: 'right'
        },
        {
            fixed: true, name: 'totalnet'
            , label: 'Total Net'
            , index: 'totalnet'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ readonly: 'readonly' }
            , formoptions: { colpos: 2, rowpos: 12 }
            , align: 'right'
        }, 
        {
            fixed: true, name: 'commodityvn'
            , label: 'Comoodity VN'
            , index: 'commodityvn'
            , editable: true
            , width: 100
            , edittype: 'text'
            , formoptions: { colpos: 2, rowpos: 8 }
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
            , align: 'center'
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
            , align: 'center'
        },
        {
            fixed: true, name: 'nguoicapnhat'
            , index: 'nguoicapnhat'
            , label: 'Người Cập Nhật'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true 
        },
        {
            fixed: true, name: 'mota'
            , label: 'Mô tả'
            , index: 'mota'
            , width: 100
            , editable:true
            , edittype: 'textarea'
            , formoptions: { colpos: 2, rowpos: 17 }
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
        }
        ]"
    GridComplete="var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 90);"
    FilterToolbar="true"
    Height="420"
    MultiSelect="false"
    ShowEdit="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
    ShowDel="<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
    EditFormOptions=" 
            width:900
            , beforeShowForm: function (formid) {
                formid.css('height', window.innerHeight/2 + window.innerHeight/3); 
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
                        $('#grid_ds_ctxkNV').jqGrid('setCaption','đang tải...');
                    },
                    success: function(data){
                        $('#grid_ds_ctxkNV').jqGrid('setCaption', data);	
                    }
                }); 			
		    }

            $('#grid_ds_ctxkDHNV').jqGrid('getGridParam', 'postData').pklId = ids;
			$('#grid_ds_ctxkDHNV')[0].triggerToolbar();
            $('#grid_ds_ctxkPhiNV').jqGrid('getGridParam', 'postData').pklId = ids;
			$('#grid_ds_ctxkPhiNV')[0].triggerToolbar();
        }
    "
    runat="server" />

<script type="text/javascript">
    $("#grid_ds_ctxkNV").jqGrid('navButtonAdd', '#grid_ds_ctxkNV-pager', {
        caption: "",
        buttonicon: "ui-icon-lightbulb",
        title: "Giữ chỗ số chứng từ",
        onClickButton: function () {
            $('body').append(`
            <div id="dlg_gridSmal_2"
                style="margin: 4px 0 0 0; background-color: rgba(165, 121, 255, 0.07);"
                title="Danh sách số chứng từ INV đang giữ chỗ"
            >
                <table style="width:100%;">
                <tr>
                    <td>
                        <table id="gridMaster"></table>
                        <div id="papergridMaster"></div>
                    </td>
                </tr>
                </table>
            </div>
        `);

            let gridMaster = $('#gridMaster');
            let widthDialog = 800;
            $('#dlg_gridSmal_2').dialog({
                modal: true,
                dialogClass: "dialog_index",
                width: widthDialog,
                height: window.innerHeight - 10,
                open: function (event, ui) {
                    gridMaster.jqGrid({
                        height: window.innerHeight - 200,
                        url: `Views/chungtuxuatkhoNV/Controller_INV_GiuchoSCT.ashx`,
                        editurl: `Views/chungtuxuatkhoNV/Controller_INV_GiuchoSCT.ashx`,
                        mtype: 'POST',
                        autowidth: true,
                        shrinkToFit: true,
                        rownumbers: true,
                        viewrecords: true,
                        scroll: false,
                        rowNum: 500,
                        multiselect: false,
                        multiboxonly: false,
                        rowList: [500],
                        pager: '#papergridMaster',
                        jsonReader: {
                            repeatitems: false,
                            id: "md_phienbangia_id"
                        },
                        colModel: [
                            {
                                fixed: true, name: 'md_sochungtugiucho_id'
                                , index: 'spd.md_sochungtugiucho_id'
                                , width: 100
                                , hidden: true
                                , editable: false
                                , edittype: 'text'
                                , key: true
                            },
                            {
                                fixed: true, name: 'socangiu'
                                , label: 'Số cần giữ'
                                , index: 'spd.socangiu'
                                , editable: true
                                , width: 100
                                , edittype: 'text'
                                , align: 'center'
                            },
                            {
                                fixed: true, name: 'ngaytao'
                                , label: 'Ngày tạo'
                                , index: 'cl.ngaytao'
                                , width: 110
                                , editable: false
                                , edittype: 'text'
                                , align: ' center'
                            },
                            {
                                fixed: true, name: 'nguoitao'
                                , label: 'Người tạo'
                                , index: 'cl.nguoitao'
                                , width: 100
                                , editable: false
                                , edittype: 'text'
                                , hidden: false
                                , align: 'center'
                            },
                            {
                                fixed: true, name: 'mota'
                                , label: 'Mô tả'
                                , index: 'cl.mota'
                                , width: 100
                                , editable: true
                                , edittype: 'textarea'
                            }
                        ],
                        ondblClickRow: function (rowid) {

                        },
                        onSelectRow: function (ids) {

                        },
                        gridComplete: function () {

                        },
                        loadComplete: function (data) {

                        },
                        beforeRequest: function () {

                        },
                        beforeProcessing: function (data) {

                        },
                        caption: ' '
                    });

                    let centerDG = function (formid, idg) {
                        let $dlg = formid.closest('div.ui-jqdialog');
                        let $gridWrapper = $("#gview_" + idg);
                        // Lấy thông số kích thước và vị trí của Grid
                        let gridPos = $gridWrapper.offset();
                        let gridW = $gridWrapper.outerWidth();
                        let gridH = $gridWrapper.outerHeight();

                        // Lấy kích thước của Dialog
                        let dlgW = $dlg.outerWidth();
                        let dlgH = $dlg.outerHeight();

                        // Công thức: Vị trí Grid + (Một nửa kích thước Grid - Một nửa kích thước Dialog)
                        let left = gridPos.left + (gridW - dlgW) / 2;
                        let top = gridPos.top + (gridH - dlgH) / 2;

                        // Đảm bảo không bị trôi lên trên quá màn hình (nếu grid dài)
                        if (top < 0) top = 10; 

                        $dlg.css({ 
                            "left": left + "px", 
                            "top": top + "px" 
                        });
                    };
                    gridMaster.jqGrid('filterToolbar', { searchOnEnter: false, stringResult: true });
                    gridMaster.jqGrid('navGrid', `#papergridMaster`,
                        {
                            del: false,
                            add: true,
                            edit: true,
                            search: false,
                            view: false,
                            refresh: false
                        },
                        {
                            beforeShowForm: function (formid) {
                                centerDG(formid, this.id);
                            },
                            afterSubmit: function(rs, postdata) {
                                return showMsgDialog(rs);
                            }
                        },
                        {
                            beforeShowForm: function (formid) {
                                centerDG(formid, this.id);
                            },
                            afterSubmit: function(rs, postdata) {
                                return showMsgDialog(rs);
                            }
                        },
                        {
                            
                        },
                        {

                        },
                        {

                        }
                    );

                    gridMaster.jqGrid('navButtonAdd', '#papergridMaster', {
                        caption: "",
                        buttonicon: "ui-icon-trash",
                        title: "Xóa dòng này",
                        onClickButton: function () {
                            var rowid = gridMaster.jqGrid('getGridParam', 'selrow');
        
                            if (!rowid) {
                                // Ở đây bạn có thể để trống để nó "im lặng" hoàn toàn
                                // Hoặc log ra console để kiểm tra
                                alert("Người dùng chưa chọn dòng cần xóa");
                                return;
                            }

                            // Nếu có chọn dòng, thì mới gọi lệnh xóa của jqGrid
                            gridMaster.jqGrid('delGridRow', rowid, {
                                // Cấu hình các tùy chọn xóa ở đây nếu cần
                                reloadAfterSubmit: true,
                                beforeShowForm: function (formid) {
                                    centerDG(formid, gridMaster.attr('id'));
                                },
                                afterSubmit: function(rs, postdata) {
                                    return showMsgDialog(rs);
                                }
                            });
                        }
                    });
                },
                close: function () {
                    $(this).dialog('destroy').remove();
                },
                buttons:
                    [{
                        id: 'btn-close_',
                        text: 'Thoát',
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }]
            });
        }
    });
</script>
