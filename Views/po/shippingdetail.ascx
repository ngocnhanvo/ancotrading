<%@ Control Language="C#" AutoEventWireup="true" CodeFile="shippingdetail.ascx.cs" Inherits="Views_po_shippingdetail" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<div id="donhang-details-3">
    <uc1:jqGrid  ID="grid_ds_donhang_spdt" 
        SortName="spd.ngaytao" 
        UrlFileAction="Views/po/Controller_PO_SPDT.ashx"
        FilterToolbar="true"
        GridBeforeRequest = "$('#grid_ds_donhang_spdt').jqGrid('getGridParam', 'postData').id = id_inc_po;"
        GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
        RowNumbers="true"
        OndblClickRow = "function(rowid) { $('#edit_grid_ds_donhang_spdt').click(); }"
        ColModel = "[
        {
            fixed: true, name: 'md_doitackinhdoanh_spd_id'
            , index: 'spd.md_doitackinhdoanh_spd_id'
            , width: 100
            , hidden: true 
            , editable:true
            , edittype: 'text'
            , key: true
        },
        {
            fixed: true, name: 'md_donhang_id'
            , index: 'spd.md_donhang_id'
            , editable: false
            , width: 100
            , edittype: 'select'
            , hidden: true
        },
        {
            fixed: true, name: 'Forwarder'
            , label: 'Forwarder'
            , index: 'spd.Forwarder'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ dataInit: function (elem) { format_donhang_spd_forwarder.create(elem); } }
        },
        {
            fixed: true, name: 'Shipper'
            , label: 'Shipper'
            , index: 'spd.Shipper'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'Consignee'
            , label: 'Consignee'
            , index: 'spd.Consignee'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'Notify'
            , label: 'Notify'
            , index: 'spd.Notify'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'AlsoNotify'
            , label: 'AlsoNotify'
            , index: 'spd.AlsoNotify'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'POD'
            , label: 'POD'
            , index: 'spd.POD'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'PlaceOfDelivery'
            , label: 'Place Of Delivery'
            , index: 'spd.PlaceOfDelivery'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'AddressForSendingOriginalDocs'
            , label: 'Address for sending original docs'
            , index: 'spd.AddressForSendingOriginalDocs'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'EmailSendPaymentRequest'
            , label: 'Email send payment request'
            , index: 'spd.EmailSendPaymentRequest'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'CacLoaiCTYC'
            , label: 'Các loại CT yêu cầu'
            , index: 'spd.CacLoaiCTYC'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'ngaytao'
            , label: 'Ngày tạo'
            , index: 'cl.ngaytao'
            , width: 110
            , editable:false
            , edittype: 'text'
            , align: ' center'
        },
        {
            fixed: true, name: 'nguoitao'
            , label: 'Người tạo'
            , index: 'cl.nguoitao'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true
        },
        {
            fixed: true, name: 'ngaycapnhat'
            , label: 'Ngày cập nhật'
            , index: 'cl.ngaycapnhat'
            , width: 110
            , editable:false
            , edittype: 'text'
            , hidden: true
            , align: ' center'
        },
        {
            fixed: true, name: 'nguoicapnhat'
            , label: 'Người cập nhật'
            , index: 'cl.nguoicapnhat'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true
        },
        {
            fixed: true, name: 'mota'
            , label: 'Mô tả'
            , index: 'cl.mota'
            , width: 100
            , editable:true
            , edittype: 'textarea'
        },
        {
            fixed: true, name: 'hoatdong', hidden: true
            , label: 'Hoạt động'
            , index: 'hoatdong'
            , width: 100
            , editable:true
            , edittype: 'checkbox'
            , align: 'center'
            , editoptions:{ value:'True:False', defaultValue: 'True' }
            , formatter: 'checkbox'
        }
        ]"
        Height = "420"
        ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
        ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
        ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
        AddFormOptions=" 
            width: 400,
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter();
            }
            , beforeSubmit:function(postdata, formid) { 
                postdata.id = id_inc_po;
                return [true,'']; 
            }
            , afterSubmit: function(rs, postdata){
                return showMsgDialog(rs);
            }
            "
        EditFormOptions ="
            width: 400,
            afterSubmit: function(rs, postdata){
                return showMsgDialog(rs);
            },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            },
            errorTextFormat:function(data) { 
                return 'Lỗi: ' + data.responseText 
        }"
        ViewFormOptions="
            width: 400,
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
        }"
        runat="server" 
    />
</div>



<script type="text/javascript">
    
</script>