<%@ Control Language="C#" AutoEventWireup="true" CodeFile="donghangLog.ascx.cs" Inherits="Views_yeucaucapnhat_donghangLog" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<div id="yeucaucapnhat-details-2">
<uc1:jqGrid  ID="grid_ds_yeucaucapnhatDH2" 
    FilterToolbar="true"
    UrlFileAction="Views/yeucaucapnhat/Controller_YeuCauCapNhat_DongHangLog.ashx"
    RowNumbers="true"
    OndblClickRow = "function(){ $('#edit_grid_ds_yeucaucapnhatDH2').click(); }"
    ColModel="
        [
            {
                name: 'md_phieuthongtinsanpham_log_id'
                , label: 'md_phieuthongtinsanpham_log_id'
                , index: 'md_phieuthongtinsanpham_log_id'
                , fixed:true 
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                name: 'ten'
                , label: 'Tên table'
                , index: 'lg.table'
                , fixed:true 
                , width: 140
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'center'
            },
            {
                name: 'ma'
                , label: 'Mã nhận diện'
                , index: 'lg.ma_lienket'
                , fixed:true 
                , width: 120
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'center'
            },
            {
                fixed: true, name: 'hanhdong'
                , label: 'Hành động'
                , index: 'lg.hanhdong'
                , width: 80
                , editable:true
                , edittype: 'text'
                , align: 'center'
                , hidden: false
            },
            {
                name: 'ngaytao'
                , label: 'Ngày tạo'
                , index: 'lg.ngaytao'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'nguoitao'
                , label: 'Người thao tác'
                , index: 'lg.nguoitao'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'ngaycapnhat'
                , label: 'Ngày cập nhật'
                , index: 'lg.ngaycapnhat'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'nguoicapnhat'
                , label: 'Người cập nhật'
                , index: 'lg.nguoicapnhat'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                fixed: true, name: 'mota'
                , label: 'Mô tả'
                , index: 'lg.mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
				, hidden: false
				, editrules:{ edithidden: true }
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , label: 'Hoạt động'
                , index: 'lg.hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
            }
        ]"
    GridBeforeRequest = "$('#grid_ds_yeucaucapnhatDH2').jqGrid('getGridParam', 'postData').id = id_inc_yeucaucapnhat;"
    GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
    Height = "150"
    MultiSelect = "false" 
    ShowAdd ="false"
    ShowEdit ="false"
    ShowDel = "false"
    AddFormOptions=" 
    width: 400,
    beforeShowForm: function (formid) {
        formid.closest('div.ui-jqdialog').dialogCenter(); 
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    },
    beforeSubmit:function(postdata, formid) {
        postdata.idpr = id_inc_yeucaucapnhat;
        return [true,''];
    },
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_yeucaucapnhatDH2')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    EditFormOptions ="
    width: 300,
    beforeShowForm: function (formid) {
        formid.closest('div.ui-jqdialog').dialogCenter(); 
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    },
    beforeSubmit:function(postdata, formid) {
        postdata.idpr = id_inc_yeucaucapnhat;
        return [true,''];
    },
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_yeucaucapnhatDH2')[0].triggerToolbar();
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
    }, 
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_yeucaucapnhatDH2')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    runat="server" />

    <script>
        let $gridYCCNDH2 = $("#grid_ds_yeucaucapnhatDH2");
        $gridYCCNDH2.jqGrid('navButtonAdd', `#${$gridYCCNDH2.attr('id')}-pager`, {
        caption: "Tạo tự động",
        title: `Tạo tự động`,
        onClickButton: function () {
            taotudongChiTietLog($gridYCCNDH2);
        }
    });
    </script>
</div>