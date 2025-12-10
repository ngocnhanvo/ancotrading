<%@ Control Language="C#" AutoEventWireup="true" CodeFile="cackhoanphi.ascx.cs" Inherits="Views_chungtuxuatkho_cackhoanphi" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script type="text/javascript">
    function phanBoCocInvoiceCTXK() {
        var id = $("#grid_ds_ctxkPhi").jqGrid('getGridParam', 'selrow');
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
</script>

<div id="ctxk-details-2">
    <uc1:jqGrid  ID="grid_ds_ctxkPhi" 
        FilterToolbar="true"
        SortName="cttc.c_chitietthuchi_id" 
        UrlFileAction="Controllers/ChiTietThuChiPhanBoController.ashx" 
        ColNames="['c_chitietthuchi_id', 'Thu Chi', 'TK Nợ', 'TK Có', 'Số Tiền', 'Số Tiền Bao Gồm Phí', 'Quy Đổi', 'Diễn Giải',  'P/O', 'Packing list/Invoice', 'Là tiền cọc', 'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
        RowNumbers="true"
        FuncPhanBoCocInv="phanBoCocInvoiceCTXK"
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

<script type="text/javascript">
    
</script>

