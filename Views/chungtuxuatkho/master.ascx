<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_chungtuxuatkho_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<script type="text/javascript">
    function funcPrintPKLI_CTXK() {
        $.get('Controllers/PartnerController.ashx?action=getoption&isncc=1', function (result) {
            var pId = $('#grid_ds_ctxk').jqGrid('getGridParam', 'selrow');
            var name = 'dialog-print-pkli-ctxk';
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
</script>

<uc1:jqGrid ID="grid_ds_ctxk"
    Caption="Packing List - Invoice"
    SortName="pi.ngaytao"
    BtnPrint="funcPrintPKLI_CTXK"
    UrlFileAction="Controllers/PackingInvoiceController.ashx"
    RowNumbers="true"
    OndblClickRow="function(rowid) { $('#edit_grid_ds_ctxk').click(); }"
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
            , index: 'dbo.LayChungTuDonHang(pi.c_packinginvoice_id)'
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
                        $('#grid_ds_ctxk').jqGrid('setCaption','đang tải...');
                    },
                    success: function(data){
                        $('#grid_ds_ctxk').jqGrid('setCaption', data);	
                    }
                }); 			
		    }

            $('#grid_ds_ctxkDH').jqGrid('getGridParam', 'postData').pklId = ids;
			$('#grid_ds_ctxkDH')[0].triggerToolbar();
            $('#grid_ds_ctxkPhi').jqGrid('getGridParam', 'postData').pklId = ids;
			$('#grid_ds_ctxkPhi')[0].triggerToolbar();
        }
    "
    runat="server" />

<script type="text/javascript">
    
</script>
