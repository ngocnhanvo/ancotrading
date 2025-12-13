<%@ Control Language="C#" AutoEventWireup="true" CodeFile="cacdonghangNV.ascx.cs" Inherits="Views_chungtuxuatkhoNV_cacdonghangNV" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script type="text/javascript">
    
</script>

<div id="ctxkNV-details-1">
    <uc1:jqGrid ID="grid_ds_ctxkDHNV"
        SortName="ma_sanpham"
        SortOrder="asc"
        UrlFileAction="Controllers/DongPackingListInvoiceController.ashx"
        ColNames="['c_dongpklinv_id', 'Packing List Invoice', 'TT', 'STT', 'Mã Sản Phẩm', 'Mã Sản Phẩm', 'Mô Tả Tiếng Anh', 'Mã Sản Phẩm Khách', 'Số Lượng', 'Giá', 'Thành Tiền',  'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
        RowNumbers="true"
        ColModel="[
            {
                fixed: true, name: 'c_dongpklinv_id'
                , index: 'c_dongpklinv_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                fixed: true, name: 'c_packinginvoice_id'
                , index: 'c_packinginvoice_id'
                , editable: true
                , width: 100
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'trangthai'
                , index: 'sp.trangthai'
                , width: 100
                , editable:false
                , formatter:'imagestatus'
                , align: 'center'
                , search: false
                , viewable: false
                , sortable: false
            },
            {
                fixed: true, name: 'line'
                , index: 'line'
                , width: 50
                , edittype: 'text'
                , editable:true
                , align:'right'
            },
            {
                fixed: true, name: 'sanpham_id'
                , index: 'sanpham_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
            },
            {
                fixed: true, name: 'ma_sanpham'
                , index: 'ma_sanpham'
                , width: 100
                , edittype: 'text'
                , editable:true
                , editoptions: { 
                    dataInit : function (elem) { 
                        $(elem).combogrid({
                            searchIcon: true,
                            width: '480px',
                            url: 'Controllers/ProductController.ashx?action=getcombogrid',
                            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden:true }
                                , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã Sản Phẩm', 'align':'left'}
                                , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả Tiếng Việt' , 'align':'left'}],
                                select: function(event, ui) {
                                    $(elem).val(ui.item.ma_sanpham);
                                    $('#sanpham_id').val(ui.item.md_sanpham_id);
                                    return false;
                                }
                        });
                    } 
                }
            },
            {
                fixed: true, name: 'mota_tienganh'
                , index: 'mota_tienganh'
                , width: 200
                , edittype: 'text'
                , editable:true
            },
            {
                fixed: true, name: 'ma_sanpham_khach'
                , index: 'dpk.ma_sanpham_khach'
                , width: 100
                , edittype: 'text'
                , editable:true
            },
            {
                fixed: true, name: 'soluong'
                , index: 'soluong'
                , width: 100
                , edittype: 'text'
                , editable:true
                , editrules: { required:true, number:true, minValue:0 }
                , editoptions:{ defaultValue:'0' }
                , align:'right'
                , formatter:'numberic'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true, name: 'gia'
                , index: 'gia'
                , width: 100
                , edittype: 'text'
                , editable:true
                , editrules: { required:true, number:true, minValue:0 }
                , editoptions:{ defaultValue:'0' }
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
            },
            {
                fixed: true, name: 'thanhtien'
                , index: 'thanhtien'
                , width: 100
                , edittype: 'text'
                , editable:false
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
            },
            {
                fixed: true, name: 'ngaytao'
                , index: 'ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoitao'
                , index: 'nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'mota'
                , index: 'mota'
                , width: 500
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
                GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
                FilterToolbar="true"
                Height="420"
                MultiSelect="false"
                ViewFormOptions="
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            },
            errorTextFormat:function(data) { 
                return 'Lỗi: ' + data.responseText 
            }
        "
        OnSelectRow = "
		    function(ids) {
			    let ma_sanpham = $('#grid_ds_ctxkDHNV').jqGrid('getCell', ids, 'ma_sanpham') + '';
			    $('#product-view-ctxkNV').attr('src', '');
                $('#product-view-ctxkNV').attr('src', 'Controllers/API_System.ashx?oper=loadImageProduct&msp=' + ma_sanpham + '&ver=' + uuidv4());
		    }
	    "
        runat="server" />
</div>

<script type="text/javascript">
    
</script>

