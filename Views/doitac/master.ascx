<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_doitac_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<uc1:jqGrid  ID="grid_ds_doitackinhdoanh" 
    SortName="ma_dtkd" 
    UrlFileAction="Controllers/PartnerController.ashx" 
    Caption="Đối tác kinh doanh"
    FilterToolbar="true"
	BtnPrint="funcPrint"
    GridComplete="var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 87); id_inc_dtkd ?  $(this).setSelection(id_inc_dtkd, false) : null"
    RowNumbers="true"
    OndblClickRow = "
		function(rowid) { 
			$('#edit_grid_ds_doitackinhdoanh').click();
		}
	"
    OnSelectRow = "function(ids) {
	    if(ids == null)
			ids=0;
		id_inc_dtkd = ids;
        $('#grid_ds_nguoilienhe')[0].triggerToolbar();
        $('#grid_ds_dtkd_spdt')[0].triggerToolbar();
    }"
    ColModel = "[
    {
        fixed: true, name: 'md_doitackinhdoanh_id'
        , label: 'dtkd.md_doitackinhdoanh_id'
        , index: 'dtkd.md_doitackinhdoanh_id'
        , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
        , key: true
    },
    {
        fixed: true, name: 'tenloai'
        , label: 'Loại Đối Tác'
        , index: 'ldt.ten_loaidtkd'
        , editable: true
        , width: 100
        , edittype: 'select'
        , editoptions: { dataUrl: 'Controllers/CategoryPartnerController.ashx?action=getoption' }
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'ma_dtkd'
        , label: 'Mã Đối Tác'
        , index: 'dtkd.ma_dtkd'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
        fixed: true, name: 'ten_dtkd'
        , label: 'Tên Đối Tác'
        , index: 'dtkd.ten_dtkd'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
    fixed: true, name: 'payer'
    , label: 'Payer'
    , index: 'dtkd.payer'
    , width: 100
    , edittype: 'text'
    , editable: true
    , hidden: false
    },
    {
        fixed: true, name: 'daidien'
        , label: 'Đại Diện'
        , index: 'dtkd.daidien'
        , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'chucvu'
        , label: 'Chức Vụ'
        , index: 'dtkd.chucvu'
        , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'tel'
        , label: 'Điện Thoại'
        , index: 'dtkd.tel'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
        fixed: true, name: 'fax'
        , label: 'Fax'
        , index: 'dtkd.fax'
        , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'email'
        , label: 'Email'
        , index: 'dtkd.email'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
        fixed: true, name: 'emailkt'
        , label: 'Email (không giá FOB)'
        , index: 'dtkd.emailkt'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
    fixed: true, name: 'email_nhandulieugoc', hidden: true
        , label: 'Email (nhận DLG)'
        , index: 'dtkd.email_nhandulieugoc'
        , width: 100
        , edittype: 'text'
        , editable: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'url'
        , label: 'Website'
        , index: 'dtkd.url'
        , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
            
    {
        fixed: true, name: 'diachi'
        , label: 'Địa Chỉ'
        , index: 'dtkd.diachi'
        , width: 100
        , edittype: 'text'
        , editable:true
    },
    {
        fixed: true, name: 'tenqg'
        , label: 'Quốc Gia'
        , index: 'qg.ten_quocgia'
        , editable: true
        , width: 100
        , edittype: 'select'
        , editoptions: { dataUrl: 'Controllers/CountryController.ashx?action=getoption' }
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'tenkv'
        , label: 'Khu Vực'
        , index: 'kv.ten_khuvuc'
        , width: 100
        , edittype: 'select'
		, editoptions: { dataUrl: 'Controllers/SaleRegionController.ashx?action=getoption' }
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'banggia'
        , label: 'Bảng giá mặc định'
        , index: 'banggia'
        , width: 100
        , edittype: 'select'
        , editable:true
        , editoptions: { dataUrl: 'Controllers/PriceListController.ashx?action=getoptionpricesale' }
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'so_taikhoan'
        , label: 'Số Tài Khoản'
        , index: 'dtkd.so_taikhoan'
        , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'nganhang'
        , label: 'Ngân Hàng'
        , index: 'dtkd.nganhang'
        , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'masothue'
        , label: 'Mã Số Thuế'
        , index: 'dtkd.masothue'
        , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
        , editrules:{ edithidden:true }
    },
    {
        fixed: true, name: 'tong_congno'
        , label: 'Tổng Công Nợ'
        , index: 'dtkd.tong_congno'
        , width: 100
        , edittype: 'text'
        , editable:true
        , editoptions:{ defaultValue: '0' }
        , editrules:{ required: true, number: true }
    },
    {
        fixed: true, name: 'isncc'
        , label: 'Là Nhà Cung Cấp'
        , index: 'dtkd.isncc'
        , width: 100
        , edittype: 'checkbox'
        , editable:true
        , formatter : 'checkbox'
        , align: 'center'
		, editoptions:{ value:'True:False', defaultValue: 'False' }
    },
    {
        fixed: true, name: 'md_cangbien_id'
        , label: 'Thuộc cảng biển'
        , index: 'cangbien'
        , editable: true
        , width: 100
        , edittype: 'select'
        , editoptions: { dataUrl: 'Controllers/PortController.ashx?action=getoption' }
        , hidden: false
        , editrules:{ edithidden:true }
    },
	{
        fixed: true, name: 'md_nguondtkd_id'
        , label: 'Nguồn đối tác'
        , index: 'ndt.ten_nguondtkd'
        , editable: true
        , width: 100
        , edittype: 'select'
        , editoptions: { dataUrl: 'Controllers/NguonDoiTacController.ashx?action=getoption' }
        , hidden: false
        , editrules:{ edithidden:true }
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
        fixed: true, name: 'hoatdong', hidden: true
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
            chosen_qgkv(formid.attr('id'));
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
            chosen_qgkv(formid.attr('id'));
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
