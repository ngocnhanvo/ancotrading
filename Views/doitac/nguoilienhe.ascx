<%@ Control Language="C#" AutoEventWireup="true" CodeFile="nguoilienhe.ascx.cs" Inherits="Views_doitac_nguoilienhe" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<div id="dtkd-details-1">
    <uc1:jqGrid  ID="grid_ds_nguoilienhe" 
        SortName="cl.ten" 
        UrlFileAction="Controllers/NguoiLienHeController.ashx"
        FilterToolbar="true"
        GridBeforeRequest = "$('#grid_ds_nguoilienhe').jqGrid('getGridParam', 'postData').id = id_inc_dtkd;"
        GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
        ColNames="['lh.md_nguoilienhe_id', 'Đối tác kinh doanh', 'Đối tác liên quan', 'Mức hoa hồng','Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
        RowNumbers="true"
        OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid); }"
        ColModel = "[
        {
            fixed: true, name: 'md_nguoilienhe_id'
            , index: 'cl.md_nguoilienhe_id'
            , width: 100
            , hidden: true 
            , editable:true
            , edittype: 'text'
            , key: true
        },
        {
                fixed: true, name: 'ma_dtkd'
                , index: 'dt.md_doitackinhdoanh_id'
                , editable: true
                , width: 100
                , edittype: 'select'
                , hidden: true
                , editoptions: { dataUrl: 'Controllers/PartnerController.ashx?action=getoption&isncc=0' }
        },
        {
                fixed: true, name: 'doitaclienquan'
                , index: 'doitaclienquan'
                , editable: true
                , width: 100
                , edittype: 'select'
                , editoptions: { dataUrl: 'Controllers/PartnerController.ashx?action=getoptionhh' }
        },
        {
            fixed: true, name: 'muchoahong'
            , index: 'cl.muchoahong'
            , width: 100
            , editable:true
            , edittype: 'text'
            , editoptions:{ defaultValue: '0' }
        },
        {
            fixed: true, name: 'ngaytao'
            , index: 'cl.ngaytao'
            , width: 100
            , editable:false
            , edittype: 'text'
        },
        {
            fixed: true, name: 'nguoitao'
            , index: 'cl.nguoitao'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true
        },
        {
            fixed: true, name: 'ngaycapnhat'
            , index: 'cl.ngaycapnhat'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true
        },
        {
            fixed: true, name: 'nguoicapnhat'
            , index: 'cl.nguoicapnhat'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true
        },
        {
            fixed: true, name: 'mota'
            , index: 'cl.mota'
            , width: 100
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
        Height = "420"
        ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
        ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
        ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
        AddFormOptions=" 
            beforeShowForm: function (formid) {
                    var masterId = $('#grid_ds_doitackinhdoanh').jqGrid('getGridParam', 'selrow');
                    var forId = 'md_doitackinhdoanh_id';
                    if(masterId == null)
                    {
                        $(formid).parent().parent().parent().dialog('destroy').remove();
                        alert('Hãy chọn một đơn hàng mới có thể tạo chi tiết.!');
                    }else{
                        formid.closest('div.ui-jqdialog').dialogCenter();
                    }
            }
            , beforeSubmit:function(postdata, formid){
                var masterId = $('#grid_ds_doitackinhdoanh').jqGrid('getGridParam', 'selrow');
                var forId = 'md_doitackinhdoanh_id';
                if(masterId == null)
                {
                    $(formid).parent().parent().parent().dialog('destroy').remove();
                    return [false,'Hãy chọn một đơn hàng mới có thể tạo chi tiết.!!'];
                }else{
                    postdata.md_doitackinhdoanh_id = masterId;
                    return [true,'']; 
                }
            }
            , afterSubmit: function(rs, postdata){
                return showMsgDialog(rs);
            }
            "
        EditFormOptions ="
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