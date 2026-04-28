<%@ Control Language="C#" AutoEventWireup="true" CodeFile="donghang.ascx.cs" Inherits="Views_yeucaucapnhat_donghang" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<div id="yeucaucapnhat-details-1">
<uc1:jqGrid  ID="grid_ds_yeucaucapnhatDH" 
    FilterToolbar="true"
    UrlFileAction="Views/yeucaucapnhat/Controller_YeuCauCapNhat_DongHang.ashx"
    RowNumbers="true"
    OndblClickRow = "function(){ $('#edit_grid_ds_yeucaucapnhatDH').click(); }"
    ColModel="
        [
            {
                name: 'md_phieuthongtinsanpham_sanpham_id'
                , label: 'md_phieuthongtinsanpham_sanpham_id'
                , index: 'md_phieuthongtinsanpham_sanpham_id'
                , fixed:true 
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                name: 'ma_sanpham'
                , label: 'Mã sản phẩm'
                , index: 'sp.ma_sanpham'
                , fixed:true 
                , width: 140
                , edittype: 'text'
                , editable: true
                , hidden: false
                , editoptions: { 
                    dataInit : function (elem) { 
                        $(elem).combogrid({
                            searchIcon: true,
                            width: '480px',
                            url: 'Controllers/ProductController.ashx?action=getcombogrid&soanthao=1',
                            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden:true }
                                , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã SP', 'align':'left'}
                                , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả TV' , 'align':'left'}],
                                select: function(event, ui) {
                                    $(elem).val(ui.item.ma_sanpham);
                                    return false;
                                }
                        });
                    } 
                }
            },
            {
                fixed: true, name: 'chungloai'
                , label: 'Chủng loại'
                , index: 'tt.chungloai'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'kieudang'
                , label: 'Kiểu dáng'
                , index: 'tt.kieudang'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'chucnang'
                , label: 'Chức năng'
                , index: 'tt.chucnang'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'detai'
                , label: 'Đề tài'
                , index: 'tt.detai'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'mausac'
                , label: 'Màu sắc'
                , index: 'tt.mausac'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'donggoi'
                , label: 'Đóng gói'
                , index: 'tt.donggoi'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
            },
            {
                fixed: true, name: 'gia'
                , label: 'Giá'
                , index: 'tt.gia'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
            },
            {
                fixed: true, name: 'hscode'
                , label: 'HSCode'
                , index: 'tt.hscode'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'nhomnangluc'
                , label: 'Nhóm NL'
                , index: 'tt.nhomnangluc'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'docquyen'
                , label: 'Độc quyền'
                , index: 'tt.docquyen'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , hidden: true
            },
            {
                fixed: true, name: 'thongtinkhac'
                , label: 'Thông tin SP'
                , index: 'tt.thongtinkhac'
                , width: 80
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
            },
            {
                name: 'ngaytao'
                , label: 'Ngày tạo'
                , index: 'tt.ngaytao'
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
                , label: 'Người thêm file'
                , index: 'tt.nguoitao'
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
                , index: 'tt.ngaycapnhat'
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
                , index: 'tt.nguoicapnhat'
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
                , index: 'tt.mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
				, hidden: false
				, editrules:{ edithidden: true }
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , label: 'Hoạt động'
                , index: 'tt.hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
            }
        ]"
    GridBeforeRequest = "$('#grid_ds_yeucaucapnhatDH').jqGrid('getGridParam', 'postData').id = id_inc_yeucaucapnhat;"
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
        $('#grid_ds_yeucaucapnhatDH')[0].triggerToolbar();
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
        $('#grid_ds_yeucaucapnhatDH')[0].triggerToolbar();
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
        $('#grid_ds_yeucaucapnhatDH')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    runat="server" />

    <script>
        let $gridYCCNDH = $("#grid_ds_yeucaucapnhatDH");
        $gridYCCNDH.jqGrid('navButtonAdd', `#${$gridYCCNDH.attr('id')}-pager`, {
            caption: "Tạo tự động",
            title: `Tạo tự động`,
            onClickButton: function () {
                taotudongChiTietLog($gridYCCNDH);
            }
        });
    </script>
</div>