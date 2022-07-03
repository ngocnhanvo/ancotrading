<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-hoadontiento.aspx.cs" Inherits="inc_hoadontiento" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script>
	
</script>

<uc1:jqGrid  ID="grid_ds_hoadontiento" 
            Caption="Tiền tố"
            FilterToolbar="true"
            SortName="hd.tiento" 
            SortOrder="desc"
            UrlFileAction="Controllers/HoaDonTienToController.ashx"
            RowNumbers="true"
            OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid, { 
                                            beforeShowForm: function (formid) {
                                                formid.closest('div.ui-jqdialog').dialogCenter(); 
                                            }
                                            , afterSubmit: function(rs, postdata){
                                                return showMsgDialog(rs);
                                            }
                                        } 
                            ); }"
            ColModel = "[
            {
                fixed: true, name: 'c_hoadontiento_id'
                , label: 'c_hoadontiento_id'
                , index: 'hd.c_hoadontiento_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                fixed: true, name: 'tiento'
                , label: 'Tiền tố'
                , index: 'hd.tiento'
                , width: 60
                , edittype: 'text'
                , editable:true
                , align: 'center'
                , editrules: { required:true }
            },
            {
                fixed: true, name: 'ten_tiento'
                , label: 'Tên tiền tố'
                , index: 'hd.ten_tiento'
                , width: 200
                , edittype: 'text'
                , editable:true
                , align: 'left'
            },
            {
                fixed: true, name: 'ngaytao'
                , label: 'Ngày Tạo'
                , index: 'hd.ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'nguoitao'
                , label: 'Người Tạo'
                , index: 'hd.nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , label: 'Ngày Cập Nhật'
                , index: 'hd.ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , label: 'Người Cập Nhật'
                , index: 'hd.nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'mota'
                , label: 'Ghi Chú'
                , index: 'hd.mota'
                , width: 200
                , editable:true
                , edittype: 'textarea'
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , label: 'Hoạt Động'
                , index: 'hd.hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            }
            ]"
            Height = "100"
            GridComplete = "let o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()- 90);"
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            AddFormOptions ="beforeShowForm: function (formid) {
                                formid.closest('div.ui-jqdialog').dialogCenter(); 
                            }
                            , afterSubmit: function(rs, postdata){
                                return showMsgDialog(rs);
                            }
                            "
            EditFormOptions="beforeShowForm: function (formid) {
                                formid.closest('div.ui-jqdialog').dialogCenter(); 
                            }
                            , afterSubmit: function(rs, postdata){
                                return showMsgDialog(rs);
                            }
                            "
            DelFormOptions="beforeShowForm: function (formid) {
                                formid.closest('div.ui-jqdialog').dialogCenter(); 
                            }"
            ViewFormOptions="width: 500
                            ,beforeShowForm: function (formid) {
                                formid.closest('div.ui-jqdialog').dialogCenter(); 
                            }"
            runat="server" />
			

<script>
	createRightPanel('grid_ds_hoadontiento');
</script>