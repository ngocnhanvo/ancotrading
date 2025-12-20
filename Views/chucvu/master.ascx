<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_chucvu_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<uc1:jqGrid  ID="grid_ds_chucvu" 
    SortName="ma_vt2" 
    UrlFileAction="Views/chucvu/Controller_ChucVu.ashx" 
    Caption="Chức vụ"
    FilterToolbar="true"
    GridComplete="var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 87); id_inc_chucvu ?  $(this).setSelection(id_inc_chucvu, false) : null"
    RowNumbers="true"
    OndblClickRow = "
		function(rowid) { 
			$('#edit_grid_ds_chucvu').click();
		}
	"
    OnSelectRow = "function(ids) {
	    if(ids == null)
			ids=0;
		id_inc_chucvu = ids;
    }"
    ColModel = "[
    {
        fixed: true, name: 'vaitro2_id'
        , label: 'cv.vaitro2_id'
        , index: 'cv.vaitro2_id'
        , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
        , key: true
    },
    {
        fixed: true, name: 'ma_vt2'
        , label: 'Mã chức vụ'
        , index: 'cv.ma_vt2'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
        fixed: true, name: 'ten_vt2'
        , label: 'Tên chức vụ'
        , index: 'cv.ten_vt2'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
        fixed: true, name: 'ngaytao'
        , label: 'Ngày Tạo'
        , index: 'dtkd.ngaytao'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true
    },
    {
        fixed: true, name: 'nguoitao'
        , label: 'Người Tạo'
        , index: 'dtkd.nguoitao'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true
    },
    {
        fixed: true, name: 'ngaycapnhat'
        , label: 'Ngày Cập Nhật'
        , index: 'dtkd.ngaycapnhat'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true
    },
    {
        fixed: true, name: 'nguoicapnhat'
        , label: 'Người Cập Nhật'
        , index: 'dtkd.nguoicapnhat'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true
    },
    {
        fixed: true, name: 'mota'
        , label: 'Mô tả'
        , index: 'dtkd.mota'
        , width: 100
        , editable:true
        , edittype: 'textarea'
    },
    {
        fixed: true, name: 'hoatdong', hidden: false
        , label: 'Hoạt động'
        , index: 'hoatdong'
        , width: 100
        , editable:true
        , edittype: 'checkbox'
        , align: 'center'
        , editoptions:{ value:'True:False', defaultValue: 'True' }
        , formatter: 'checkbox'
        , editrules:{ edithidden:true }
    }
    ]"
    Height="170"
    ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
    ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
    ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
    AddFormOptions="
        width:450,
        beforeShowForm: function (formid) {
			formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
		errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
        }, 
		afterSubmit: function(rs, postdata){
            return showMsgDialog(rs);
        }
    "
    EditFormOptions ="
        width:450,
        beforeShowForm: function (formid) {
			formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
        errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
        },
		afterSubmit: function(rs, postdata){
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
        ,beforeSubmit: function(rs, postdata) {
            loading();
			return [true];
        },
        afterSubmit: function(rs, postdata){
			end_loading();
            return showMsgDialog(rs);
        }
    "
    runat="server"
/>

<script type="text/javascript">
    
</script>
