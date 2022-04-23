<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-collection.aspx.cs" Inherits="inc_collection" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<uc1:jqGrid  ID="grid_ds_collection" 
            Caption="Collection (Website)"
            FilterToolbar="true"
            SortName="clt.ten_collection" 
            SortOrder="asc"
            UrlFileAction="Controllers/CollectionController.ashx"
            RowNumbers="true"
            ColModel = "[
            {
                fixed: true, name: 'md_collection_id'
                , label: 'md_collection_id'
                , index: 'clt.collection_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                fixed: true, name: 'ten_collection'
                , index: 'clt.code_ncl'
                , label: 'Tên Collection'
                , width: 210
                , edittype: 'text'
                , editable:true
                , editrules: { required:true }
            },
            {
                 fixed: true, name: 'chungloai'
                 , index: 'clt.chungloai' 
                 , label: 'Chủng loại'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
		        , align: 'center'
            },
            {
                 fixed: true, name: 'kieudang'
                 , index: 'clt.kieudang' 
                 , label: 'Kiểu dáng'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
		        , align: 'center'
            },
            {
                 fixed: true, name: 'detai'
                 , index: 'clt.detai' 
                 , label: 'Đề tài'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
		        , align: 'center'
            },
            {
                 fixed: true, name: 'bocai'
                 , index: 'clt.bocai' 
                 , label: 'Bộ cái'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
		        , align: 'center'
            },
            {
                 fixed: true, name: 'mausac'
                 , index: 'clt.mausac' 
                 , label: 'Màu sắc'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
		        , align: 'center'
            }
            ]"
            Height = "100"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()- 90);"
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

<script type="text/javascript">
    createRightPanel('grid_ds_collection');
</script>