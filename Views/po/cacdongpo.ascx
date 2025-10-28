<%@ Control Language="C#" AutoEventWireup="true" CodeFile="cacdongpo.ascx.cs" Inherits="Views_po_cacdongpo" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script type="text/javascript">
    function updateMoTaGiaPO_CallBack(c_donhang_id, md_sanpham_id) {
        var frm = "#FrmGrid_grid_ds_chitietpo";
        $.ajax({
            url: "Controllers/DongDonHangController.ashx?action=getmotagia&c_donhang_id=" + c_donhang_id + "&md_sanpham_id=" + md_sanpham_id,
            type: "GET",
            success: function (data) {
                $("#ma_sanpham_khach", frm).val(data);
                // var check_docquyen = $('#docquyen','#FrmGrid_grid_ds_chitietpo').val();
                // if(check_docquyen.length > 0) {
                // $("#ma_sanpham_khach", frm).val("");
                // }
                // else {
                // $("#ma_sanpham_khach", frm).val(data);
                // }
            }
        });
    }

    function updateGiaSanPhamPO_CallBack(c_donhang_id, md_sanpham_id) {
        let frm = "#FrmGrid_grid_ds_chitietpo";
        let giafobGoc = $('#giafobGoc', frm);
        let giafob = $('#giafob', frm);
        let phifob = $('#phi', frm);
        let docquyen = $('#docquyen', frm);
        let editPhiFOB = $('#editphi', frm);
        giafobGoc.val('Đang tải...');
        giafob.val('Đang tải...');
        $.ajax({
            url: "Controllers/DongDonHangController.ashx?action=getgiasanpham&c_donhang_id=" + c_donhang_id + "&md_sanpham_id=" + md_sanpham_id,
            type: "GET",
            success: function (data) {
                data = JSON.parse(data);
                giafobGoc.val(data.gia[0]);
                giafob.val(data.gia[0]);
                phifob.val(data.phi[0]);
                updateMoTaGiaPO_CallBack(c_donhang_id, md_sanpham_id);

                if (phifob.val() == 0) {
                    editPhiFOB.prop('checked', true).change();
                }
            }
        });
    }

    function updateNhaCungUngPO_CallBack(md_sanpham_id) {
        let frm = "#FrmGrid_grid_ds_chitietpo";
        let c_dongdonhang_id = $("#c_dongdonhang_id", frm).val();

        $("#nhacungungid", frm)
                    .html("<option value=''>Đang tải nhà cung ứng...</option>")
                    .attr("disabled", "disabled");

        $.ajax({
            url: "Controllers/NhaCungUngMacDinhController.ashx?action=getoptionselected&c_dongdonhang_id=" + c_dongdonhang_id + "&md_sanpham_id=" + md_sanpham_id,
            type: "GET",
            success: function (packingHtml) {
                if (packingHtml != 'null') {
                    $("#nhacungungid", frm).removeAttr("disabled").html($(packingHtml).html());
                } else {
                    $("#nhacungungid", frm).html("<option value=''>Không tìm thấy nhà cung ứng!</option>");
                }
            }
        });
    }

    function updatePackingPO_CallBack(md_sanpham_id) {
        let frm = "#FrmGrid_grid_ds_chitietpo";
        let c_dongdonhang_id = $("#c_dongdonhang_id", frm).val();
        let c_donhang_id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        $("#md_donggoi_id", frm).html("<option value=''>Đang tải đóng gói...</option>").attr("disabled", "disabled");
        $.ajax({
            url: "Controllers/PackingController.ashx?action=getoptionselected&c_dongdonhang_id=" + c_dongdonhang_id + "&md_sanpham_id=" + md_sanpham_id +
            "&c_donhang_id=" + c_donhang_id,
            type: "GET",
            success: function (packingHtml) {
                var arr_pkl = packingHtml.split('(##)');

                if (packingHtml != 'null') {
                    $("#md_donggoi_id", frm).removeAttr("disabled").html($(arr_pkl[0]).html());
                    $("#docquyen", frm).val(arr_pkl[1]);
                    $("#md_donggoi_id", frm).off('change');
                    let action = $('#edithdgrid_ds_chitietpo').text();
                    $("#md_donggoi_id", frm).change(function () {
                        let $sel = $(this).find('option:selected');
                        let cpdg = $sel.attr('cpdg');
                        $("#cpdg", frm).val(cpdg);
                        let mtdg = $sel.attr('mtdg');
                        $("#motadonggoi", frm).val(mtdg);
                    });
                    if (action.lastIndexOf('Thêm') > -1)
                        $("#md_donggoi_id", frm).change();
                }
                else {
                    $("#md_donggoi_id", frm).html("<option value=''>Không tìm thấy đóng gói!</option>");
                }
            }
        });
    }

    // This function gets called whenever an edit dialog is opened
    function populatePackingPO() {
        let frm = "#FrmGrid_grid_ds_chitietpo";
        // first of all update the city based on the country
        updatePackingPO_CallBack($("#sanpham_id", frm).val());
        updateNhaCungUngPO_CallBack($("#sanpham_id", frm).val());

        let id_sel = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        celgia_db = $('#grid_ds_po').jqGrid('getCell', id_sel, 'gia_db');
        //--
        let giafob = $('#giafob', frm);
        let phifob = $('#phi', frm);
        let docquyen = $('#tr_docquyen', frm);
        let editphiTr = $('#tr_editphi', frm);
        let editphi = $('#editphi', frm);
        if (celgia_db == 'True') {
            giafob.prop('disabled', true);
            editphi.off('change');
            editphi.change(function () {
                phifob.prop('disabled', !editphi.prop('checked'));
            });
            editphi.change();
        }
        else {
            if (vnnIsAdmin == 'True') {
                giafob.prop('disabled', false);
                phifob.prop('disabled', false);
            }
            else {
                giafob.prop('disabled', suaGiaPO != 'True');
                phifob.prop('disabled', false);
            }
        }
        docquyen.hide();
        editphiTr.hide(); 
    }
</script>

<div id="donhang-details-1">
    <uc1:jqGrid  ID="grid_ds_chitietpo" 
    SortName="ddh.sothutu" 
    SortOrder="desc"
    UrlFileAction="Controllers/DongDonHangController.ashx" 
    RowNumbers="true"
    OndblClickRow = "function(rowid) { 
						$('#edit_grid_ds_chitietpo').click();
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
    GridComplete = "let o = $('#tabs-donhang-details'); $(this).setGridHeight($(o).height() - 97);$(this).setGridWidth($(o).width())"
    FilterToolbar="true"
    Height = "150"
    MultiSelect = "false" 
    ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
    ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
    ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
	OnSelectRow = "
		function(ids) {
			let ma_sanpham = $('#grid_ds_chitietpo').jqGrid('getCell', ids, 'ma_sanpham') + '';
			$('#product-view-po').attr('src', '');
            $('#product-view-po').attr('src', 'Controllers/API_System.ashx?oper=loadImageProduct&msp=' + ma_sanpham + '&ver=' + uuidv4());
		}
	"
    AddFormOptions=" 
        width: 450,
        beforeShowForm: function (formid) {
                var masterId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
                var forId = 'c_donhang_id';
                if(masterId == null)
                {
                    $(formid).parent().parent().parent().dialog('destroy').remove();
                    alert('Hãy chọn một đơn hàng mới có thể tạo chi tiết.!');
                }else{
                    phiTheoPhanTramDonHang(formid);
                    $('#tr_' + forId + ' td.DataTD input#' + forId, formid).val(masterId);
							
					$('#ma_sanpham', formid).mask('99-*****-**-**');
                    $('#ma_sanpham', formid).prop('disabled', false);
                    $('#tr_giafob', formid).show();
                    $('#tr_sothutu', formid).hide();
                    $('#tr_nhacungungid', formid).show();
                    $('#tr_md_donggoi_id', formid).show();
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
        }
        , beforeSubmit:function(postdata, formid){
            var masterId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
            var forId = 'c_donhang_id';
            if(masterId == null)
            {
                $(formid).parent().parent().parent().dialog('destroy').remove();
                return [false,'Hãy chọn một đơn hàng mới có thể tạo chi tiết.!!'];
            }else{
                postdata.c_donhang_id = masterId;
				var check_thaydoi = $('#md_donggoi_id option:selected').attr('other');
				var check_docquyen = $('#docquyen','#FrmGrid_grid_ds_chitietpo').val();
				if(check_thaydoi.toUpperCase() == 'TRUE')
				{
					if(confirm('Lưu ý: Kiểu đóng gói bạn chọn có thể thay đổi giá !') == true) {
						if(check_docquyen != '') {
							if(confirm(check_docquyen) == true) {
								return [true];
							}
							else {
								return [false];
							}
						}
						else {
							return [true];
						}
					}
					else {
						return [false];
					}
				}
				else{
					if(check_docquyen != '') {
						if(confirm(check_docquyen) == true) {
							return [true];
						}
						else {
							return [false];
						}
					}
					else {
						return [true];
					}
				}
            }
        }
        , afterSubmit: function(rs, postdata){
            return showMsgDialog(rs);
        }
        , afterShowForm:populatePackingPO
        , afterclickPgButtons:populatePackingPO
        "
    EditFormOptions ="
        width: 450,
        beforeShowForm: function (formid) {
            phiTheoPhanTramDonHang(formid);
            $('#ma_sanpham', formid).mask('**-*****-**-**');
            $('#ma_sanpham', formid).prop('disabled', true);
            $('#tr_giafob', formid).show();
            $('#tr_sothutu', formid).show();
            $('#tr_md_donggoi_id', formid).show();
            $('#tr_nhacungungid', formid).show();
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        }
		, beforeSubmit:function(postdata, formid){
            var masterId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
            var forId = 'c_donhang_id';
            if(masterId == null)
            {
                $(formid).parent().parent().parent().dialog('destroy').remove();
                return [false,'Hãy chọn một đơn hàng có thể sửa chi tiết.!!'];
            }else{
                postdata.c_donhang_id = masterId;
				var check_thaydoi = $('#md_donggoi_id option:selected').attr('other');
				var check_docquyen = $('#docquyen','#FrmGrid_grid_ds_chitietpo').val();
				if(check_thaydoi.toUpperCase() == 'TRUE')
				{
					if(confirm('Mã hàng đã thay đổi giá theo đóng gói') == true) {
						if(check_docquyen != '') {
							if(confirm(check_docquyen) == true) {
								return [true];
							}
							else {
								return [false];
							}
						}
						else {
							return [true];
						}
					}
					else {
						return [false];
					}
				}
				else{
					if(check_docquyen != '') {
						if(confirm(check_docquyen) == true) {
							return [true];
						}
						else {
							return [false];
						}
					}
					else {
						return [true];
					}
				}
            }
        },
        errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
        }
        , afterShowForm:populatePackingPO
        , afterclickPgButtons:populatePackingPO"
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
        afterSubmit: function(rs, postdata) { 
            return showMsgDialog(rs); 
    }"
    runat="server" />
</div>

<script type="text/javascript">
    $("#grid_ds_chitietpo").jqGrid('navButtonAdd', '#grid_ds_chitietpo-pager', {
        caption: "Tất cả CPĐG bằng 0",
        title: "Tất cả các phí đóng gói bằng 0",
        onClickButton: function () {
            let iddl = "dialog-ds_chitietpo-cpdg0";
            $('body').append(`
                    <div title="Tất cả các chi phí đóng gói bằng 0" id="${iddl}">
                        <div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                        <div id="dialog-caution">
                            Bạn muốn thực hiện chức năng này?
                        </div>
                    </div>
                `);
            let $dlg = $(`#${iddl}`); 
            $dlg.dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                    [
                        {
                            id: `btn-ok-${iddl}`,
                            text: "Có",
                            click: function () {
                                let ajaxStart = function () {
                                    $("#wait").css("display", "block");
                                    $(`btn-ok-${iddl}`).button("disable");
                                    $("#btn-close").button("disable");
                                };

                                let ajaxComplete = function () {
                                    $("#wait").css("display", "none");
                                    $("#btn-close span").text("Thoát");
                                    $("#btn-close").button("enable");
                                };

                                ajaxStart();
                                $.post(`Controllers/DongDonHangController.ashx?action=tatcacpdg0`, {id: id_inc_po }, function (result) {
                                    ajaxComplete();
                                    let $xmlObject = $(result); 
                                    let ok = $xmlObject.find('type').text() == '1';
                                    let msg = $xmlObject.find('message').text();
                                    $(`#${name}`).find('#dialog-caution').html(msg);
                                    if (ok)
                                        $('#grid_ds_chitietpo')[0].triggerToolbar();
                                });
                            }
                        },
                        {
                            id: `btn-close-${iddl}`,
                            text: "Không",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
            });
        }
    });
</script>

