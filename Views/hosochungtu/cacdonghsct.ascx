<%@ Control Language="C#" AutoEventWireup="true" CodeFile="cacdonghsct.ascx.cs" Inherits="Views_hosochungtu_cacdonghsct" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script type="text/javascript">
    
</script>

<div id="hosochungtu-details-1">
    <uc1:jqGrid  ID="grid_ds_chitiethsct" 
    SortName="ddh.sothutu" 
    SortOrder="desc"
    UrlFileAction="Controllers/DongDonHangController.ashx" 
    RowNumbers="true"
    OndblClickRow = "function(rowid) { 
						$('#edit_grid_ds_chitiethsct').click();
					}"
    ColModel = "[
    {
        name: 'c_dongdonhang_id'
		, label: 'c_dongdonhang_id'
        , index: 'c_dongdonhang_id'
        , fixed:true , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
        , key: true
    },
    {
        name: 'c_donhang_id'
		, label: 'Đơn Hàng'
        , index: 'dh.c_donhang_id'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:true
        , hidden: true
    },
    {
        fixed: true
		, name: 'trangthai'
		, label: 'TT'
        , index: 'sp.trangthai'
        , editable: false
        , width: 100
        , edittype: 'text'
        , align:'center'
        , formatter:'imagestatus'
        , search : true
        , stype : 'select'
        , searchoptions:{ value:':[ALL];MOI:MỚI;DHD:ĐANG HOẠT ĐỘNG;NHD:NGƯNG HOẠT ĐỘNG'}
    },
	{
        fixed: true, name: 'trangthai_ddh'
		, label: 'Trạng Thái'
        , index: 'ddh.trangthai'
        , editable: false
        , width: 100
        , edittype: 'text'
        , align:'center'
        , formatter:'imagestatus'
        , search : true
        , stype : 'select'
        , searchoptions:{ value:':[ALL];DGDG:Đổi giá theo đóng gói;BT:Giá bình thường;DQ:HH Độc quyền'}
    },
    {
        name: 'sothutu'
		, label: 'STT'
        , index: 'ddh.sothutu'
        , fixed:true , width: 50
        , edittype: 'text'
        , editable: true
        , editrules: { required:true, number: true }
        , editoptions:{ defaultValue: '0' }
        , align: 'right'
    },
    {
        name: 'sanpham_id'
		, label: 'Mã SP'
        , index: 'sp.sanpham_id'
        , fixed:true , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
    },
    {
        name: 'ma_sanpham'
		, label: 'Mã SP'
        , index: 'sp.ma_sanpham'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:true
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
                            $('#sanpham_id').val(ui.item.md_sanpham_id);
                            var c_donhang_id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
                                    
                            updateGiaSanPhamPO_CallBack(c_donhang_id, ui.item.md_sanpham_id)                    
                            updatePackingPO_CallBack(ui.item.md_sanpham_id);
                            updateNhaCungUngPO_CallBack(ui.item.md_sanpham_id);
									
                            return false;
                        }
                });
            } 
        }
    },
    {
        name: 'ma_sanpham_khach'
		, label: 'Mã SP Khách'
        , index: 'ddh.ma_sanpham_khach'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:true
    },
	{
		name: 'giafobGoc'
		, label: 'Giá FOB gốc'
		, index: 'ddh.giafobGoc'
		, fixed:true , width: 100
		, edittype: 'text'
		, editable: true
		, editrules: { required:true, number: true }
        , editoptions:{ defaultValue: '0' }
		, align: 'right'
		, formatter:'currency'
		, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
	},
    {
		name: 'giafob'
		, label: 'Giá FOB'
		, index: 'ddh.giafob'
		, fixed:true , width: 100
		, edittype: 'text'
		, editable: true
		, editrules: { required:true, number: true }
		, editoptions:{ defaultValue: '0' }
		, align: 'right'
		, formatter:'currency'
		, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
	},
    {
		name: 'phi'
		, label: 'Phí'
		, index: 'ddh.phi'
		, fixed:true , width: 100
		, edittype: 'text'
		, editable: true
		, editrules: { required:true, number: true }
		, editoptions:{ defaultValue: '0' }
		, align: 'right'
		, formatter:'currency'
		, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
	},
    {
		name: 'cpdg'
		, label: 'CPĐG'
		, index: 'ddh.cpdg'
		, fixed:true , width: 100
		, edittype: 'text'
		, editable: true
		, editrules: { required:true, number: true }
		, editoptions:{ defaultValue: '0' }
		, align: 'right'
		, formatter:'currency'
		, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
	},
    {
		name: 'apdung_cpdg'
		, label: 'Áp dụng CPĐG'
		, index: 'ddh.apdung_cpdg'
		, fixed:true 
        , width: 70
        , editable:true
        , edittype: 'checkbox'
        , align: 'center'
        , editoptions:{ value:'True:False', defaultValue: 'False' }
        , formatter: 'checkbox'
	},
    {
		name: 'discount'
		, label: 'Discount(%)'
		, index: 'ddh.discount'
		, fixed:true , width: 100
		, edittype: 'text'
		, editable: false
		, editrules: { required:true, number: true }
		, editoptions:{ defaultValue: '0' }
		, align: 'right'
		, formatter:'currency'
		, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
	},
    {
		name: 'tanggia'
		, label: 'Tăng giá (%)'
		, index: 'ddh.tanggia'
		, fixed:true , width: 100
		, edittype: 'text'
		, editable: false
		, editrules: { required:true, number: true }
		, editoptions:{ defaultValue: '0' }
		, align: 'right'
		, formatter:'currency'
		, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
	},
    {
		name: 'giahopdong'
		, label: 'Giá H.Đồng'
		, index: 'ddh.giahopdong'
		, fixed:true , width: 100
		, edittype: 'text'
		, editable: false
		, editrules: { required:true, number: true }
		, editoptions:{ defaultValue: '0' }
		, align: 'right'
		, formatter:'currency'
		, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
	},
    {
		name: 'phanbodiscount'
        , hidden: false
        , fixed:true
		, label: 'Phân bổ discount'
		, index: 'dh.phanbodiscount'
        , width: 100
        , editable: false
        , edittype: 'checkbox'
        , align: 'center'
        , editoptions:{ value:'True:False', defaultValue: 'True' }
        , formatter: 'checkbox'
	},
    {
        name: 'soluong'
		, label: 'Số Lượng'
        , index: 'ddh.soluong'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:true
        , editoptions:{ defaultValue: '1' }
        , align: 'right'
        , formatter:'number'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
    },        
    {
        name: 'md_donggoi_id'
		, label: 'Đóng Gói'
        , index: 'dg.ten_donggoi'
        , fixed:true , width: 100
        , edittype: 'select'
        , editable: true
        , editoptions: { 'value' : 'Chọn đóng gói' }
		, hidden:true 
		, editrules: { edithidden:true }
    },
    {
        name: 'motadonggoi'
		, label: 'Mô tả ĐG'
        , index: 'dg.mota'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable: true
		, hidden:true 
		, editrules: {edithidden:true}
        , editoptions: {disabled: true, style: 'width:80%; opacity:0.85; font-weight:bold'}
    },
    {
        name: 'sl_inner'
		, label: 'Đóng Gói Inner'
        , index: 'ddh.sl_inner'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
    },
    {
        name: 'l1'
		, label: 'L1'
        , index: 'ddh.l1'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
		, hidden:true
    },
    {
        name: 'w1'
		, label: 'W1'
        , index: 'ddh.w1'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
		, hidden:true
    },
    {
        name: 'h1'
		, label: 'H1'
        , index: 'ddh.h1'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
		, hidden:true
    },
    {
        name: 'sl_outer'
		, label: 'Đóng Gói Outer'
        , index: 'ddh.sl_outer'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
    },
    {
        name: 'l2'
		, label: 'L2'
        , index: 'ddh.l2'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
		, hidden:true
    },
    {
        name: 'w2'
		, label: 'W2'
        , index: 'ddh.w2'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
		, hidden:true
    },
    {
        name: 'h2'
		, label: 'H2'
        , index: 'ddh.h2'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
		, hidden:true
    },
	{
        name: 'sl_cont'
		, label: 'SL Cont'
        , index: 'ddh.sl_cont'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
        , formatter:'number'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
    },
    {
        name: 'v2'
		, label: 'V2'
        , index: 'ddh.v2'
        , fixed:true , width: 100
        , edittype: 'text'
        , editable:false
        , align: 'right'
    },
	{
        name: 'nhacungungid'
		, label: 'Nhà cung ứng'
        , index: 'dtkd.ma_dtkd'
        , editable: true
        , fixed:true 
        , width: 120
        , edittype: 'select'
        , editoptions: { 'value' : 'Chọn nhà cung ứng'}
    },
    {
        name: 'ngaytao'
		, label: 'Ngày Tạo'
        , index: 'ddh.ngaytao'
        , fixed:true , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        name: 'nguoitao'
		, label: 'Người Tạo'
        , index: 'ddh.nguoitao'
        , fixed:true , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        name: 'ngaycapnhat'
		, label: 'Ngày Cập Nhật'
        , index: 'ddh.ngaycapnhat'
        , fixed:true , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        name: 'nguoicapnhat'
		, label: 'Người Cập Nhật'
        , index: 'ddh.nguoicapnhat'
        , fixed:true , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        name: 'mota'
		, label: 'Mô tả'
        , index: 'ddh.mota'
        , fixed:true , width: 100
        , editable:true
        , edittype: 'textarea'
		, hidden: true
		, editrules: { edithidden:true }
    },
    {
        name: 'hoatdong', hidden: true
		, label: 'Hoạt động'
        , index: 'ddh.hoatdong'
        , width: 30
        , editable:true
        , edittype: 'checkbox'
        , align: 'center'
        , editoptions:{ value:'True:False', defaultValue: 'True' }
        , formatter: 'checkbox'
    },
	{
        name: 'docquyen'
		, label: 'Độc quyền'
        , index: 'ddh.docquyen'
        , fixed:true , width: 100
        , editable:true
        , edittype: 'textarea'
		, hidden: false
		, editrules: { edithidden:true }
    },
	{
        name: 'barcode'
		, label: 'Barcode'
        , index: 'ddh.barcode'
        , fixed:true 
		, width: 100
		, hidden: true
    },
    {
        name: 'editphi'
		, label: 'Cho phép sửa phí'
        , index: 'ddh.editphi'
        , edittype: 'checkbox'
        , editoptions:{ value:'True:False', defaultValue: 'False' }
        , fixed:true 
		, width: 100
        , editable:true
		, hidden: true
        , editrules: { edithidden:true }
    }
    ]"
    GridComplete = "let o = $('#tabs-hosochungtu-details'); $(this).setGridHeight($(o).height() - 97);$(this).setGridWidth($(o).width())"
    FilterToolbar="true"
    Height = "150"
    MultiSelect = "false" 
    ShowAdd ="false"
    ShowEdit ="false"
    ShowDel = "false"
	OnSelectRow = "
		function(ids) {
			let ma_sanpham = $('#grid_ds_chitiethsct').jqGrid('getCell', ids, 'ma_sanpham') + '';
			$('#product-view-hsct').attr('src', '');
            $('#product-view-hsct').attr('src', 'Controllers/API_System.ashx?oper=loadImageProduct&msp=' + ma_sanpham + '&ver=' + uuidv4());
		}
	"
    ViewFormOptions="
        beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
        errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
    }"
    runat="server" />
</div>

<script type="text/javascript">
    
</script>

