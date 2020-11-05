<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-users.aspx.cs" Inherits="inc_users" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script>
    /*$(window).bind('resize', function () {
        $("#grid_ds_nhanvien").setGridHeight($(window).height() - 220);
    }).trigger('resize');*/
</script>

    <uc1:jqGrid ID="grid_ds_nhanvien" 
            SortName="manv" 
            UrlFileAction="Controllers/UserController.ashx" 
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 65);"
            ColNames="['Mã Nhân Viên', 'Mật Khẩu', 'Vai Trò', 'Họ Tên', 'Email', 'Email Password', 'Email CC', 'Điện Thoại', 'Địa Chỉ', 'Admin', 'Remote', 'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
            RowNumbers="true"
            FilterToolbar="true"
            OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid,{ 
                        afterSubmit: function(rs, postdata) {
                            return showMsgDialog(rs);
                        },
                        beforeShowForm: function (formid) {
                                               formid.closest('div.ui-jqdialog').dialogCenter(); 
                        }}); }"
            ColModel = "[
            {
                fixed: true, name: 'manv'
                , index: 'manv'
                , width: 100 
                , editable:true
                , edittype: 'text'
                , key: true
                , editrules: { readyonly: 'readyonly' }
            },
            {
                fixed: true, name: 'matkhau'
                , index: 'matkhau'
                , width: 100 
                , editable:true
                , edittype: 'password'
                , hidden: true
                , editrules: { edithidden:true }
            },
            {
                fixed: true, name: 'tenvt'
                , index: 'tenvt'
                , width: 100 
                , editable:true
                , edittype: 'select'
                , editoptions: { dataUrl: 'Controllers/RoleController.ashx?action=getoption' }
            },
            {
                fixed: true, name: 'hoten'
                , index: 'hoten'
                , width: 100 
                , editable:true
                , edittype: 'text'
            },
            {
                fixed: true, name: 'email'
                , index: 'email'
                , width: 100 
                , editable:true
                , edittype: 'text'
                , editrules:{ required:true, email:true }
            },
            {
                fixed: true, name: 'email_pass'
                , index: 'email_pass'
                , width: 100 
                , editable: true
                , edittype: 'password'
                , hidden: true
                , editrules:{ edithidden:true }
            },
            {
                fixed: true, name: 'email_cc'
                , index: 'email_cc'
                , width: 100 
                , editable:true
                , edittype: 'text'
                , editrules:{ required:true, email:true }
            },
            {
                fixed: true, name: 'dienthoai'
                , index: 'dienthoai'
                , width: 100 
                , editable:true
                , edittype: 'text'
            },
            {
                fixed: true, name: 'diachi'
                , index: 'diachi'
                , width: 100 
                , editable:true
                , edittype: 'text'
            },
            {
                fixed: true, name: 'isadmin'
                , index: 'isadmin'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            },
			{
                fixed: true, name: 'remote'
                , index: 'remote'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            },
            {
                fixed: true, name: 'ngaytao'
                , index: 'ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'nguoitao'
                , index: 'nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'mota'
                , index: 'mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
            },
            {
                fixed: true, name: 'hoatdong'
                , index: 'hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            }
            ]"
            AddFormOptions=" 
            afterSubmit: function(rs, postdata) {
                            return showMsgDialog(rs);
                        },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            EditFormOptions=" 
            afterSubmit: function(rs, postdata) {
                return showMsgDialog(rs);
            },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            ViewFormOptions=" beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            DelFormOptions="
            afterSubmit: function(rs, postdata) {
                            return showMsgDialog(rs);
                        },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            runat="server" />

<script type="text/javascript">
    createRightPanel('grid_ds_nhanvien');
</script>
