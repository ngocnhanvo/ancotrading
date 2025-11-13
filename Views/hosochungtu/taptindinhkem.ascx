<%@ Control Language="C#" AutoEventWireup="true" CodeFile="taptindinhkem.ascx.cs" Inherits="Views_hosochungtu_cacdonghsct" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script type="text/javascript">
    
</script>

<div id="hosochungtu-details-2">
    <uc1:jqGrid ID="grid_dinhkemhsct"
        SortName="ngaytao"
        SortOrder="ASC"
        UrlFileAction="Views/hosochungtu/Controller_HoSoChungTu_Taptin.ashx"
        RowNumbers="true"
        OndblClickRow="
        function(rowid) {
            $('#edit_grid_dinhkemhsct').click();
        }
        "
        ColModel="
        [
            {
                name: 'md_taptin_id'
                , label: 'md_taptin_id'
                , index: 'md_taptin_id'
                , fixed:true 
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                name: 'tentaptin'
                , label: 'Tên tập tin'
                , index: 'tt.tentaptin'
                , fixed:true 
                , width: 140
                , edittype: 'text'
                , editable: false
                , hidden: false
            },
            {
                name: 'mota'
                , label: 'ghi chú Ancotrading'
                , index: 'tt.mota'
                , fixed: true 
                , width: 140
                , edittype: 'text'
                , editable: true
                , hidden: true
                , edittype: 'textarea'
            },
            {
                name: 'mimetype'
                , label: 'Loại'
                , index: 'tt.mimetype'
                , editable: false
                , fixed:true 
                , width: 60
                , edittype: 'text'
                , align: 'center'
            },
            {
                name: 'size'
                , label: 'Kích thước'
                , index: 'tt.size'
                , editable: false
                , fixed:true 
                , width: 80
                , edittype: 'text'
                , editoptions:{ defaultValue: '0' }
                , editrules: { required:true, number:true, minValue: 0 }
                , align: 'right'
                , formatter: formatBytes
                , unformat: disable_formatter
            },
            {
                name: 'path'
                , label: 'Tải về'
                , index: 'tt.path'
                , editable: false
                , fixed:true 
                , width: 50
                , edittype: 'text'
                , align: 'center'
                , formatter: download
                , unformat: disable_formatter
            },
            {
                name: 'ngaytao'
                , label: 'Ngày tạo'
                , index: 'tt.ngaytao'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: false 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'nguoitao'
                , label: 'Người tạo'
                , index: 'tt.nguoitao'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: false 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'ngaycapnhat'
                , label: 'Ngày cập nhật'
                , index: 'tt.ngaycapnhat'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: false
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'nguoicapnhat'
                , label: 'Người cập nhật'
                , index: 'tt.nguoicapnhat'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
                , align: 'center'
            }
        ]"
        GridComplete="let o = $(this).parent().parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 97);$(this).setGridWidth($(o).width())"
        FilterToolbar="true"
        Height="150"
        MultiSelect="false"
        ShowAdd="false"
        ShowEdit="false"
        ShowDel="false"
        
        runat="server" />
</div>

<script type="text/javascript">
    
</script>

