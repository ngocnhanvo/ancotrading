<%@ Control Language="C#" AutoEventWireup="true" CodeFile="solanxuat.ascx.cs" Inherits="Views_hosochungtu_solanxuat" %>




<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script type="text/javascript">
    function solanxuat_DaHoanThanh(rowid) {
        if (!rowid) {
            return false;
        }

        var v = $('#grid_solanxuat').jqGrid('getCell', rowid, 'dahonthanh') + '';

        if (v.indexOf('checked') >= 0) {
            return true;
        }

        v = $('<div/>').html(v).text();
        v = $.trim(v).toLowerCase();

        return v == 'true' || v == '1' || v == 'yes';
    }
    function solanxuat_CapNhatOptionNVCT() {
        if (typeof nvcts_hosochungtu != 'undefined' && nvcts_hosochungtu) {
            $('#grid_solanxuat').jqGrid('setColProp', 'nhanvienCT', {
                editoptions: {
                    value: nvcts_hosochungtu
                }
            });
        }
    }
    //function solanxuat_LayTrangThai(rowid) {
    //    var v = $('#grid_solanxuat').jqGrid('getCell', rowid, 'trangthai') + '';

    //    v = $('<div/>').html(v).text();
    //    v = $.trim(v);

    //    return v;
    //}
    function solanxuat_LayTrangThai(rowid) {
        var v = '';

        // Ưu tiên lấy trạng thái hiện tại của hồ sơ chứng từ chính
        var hsctRowId = $('#grid_ds_hosochungtu').jqGrid('getGridParam', 'selrow');

        if (hsctRowId) {
            var hsctRow = $('#grid_ds_hosochungtu').jqGrid('getRowData', hsctRowId);
            v = hsctRow.trangthai || '';
        }

        // Nếu không lấy được từ grid_ds_hosochungtu thì mới lấy từ grid_solanxuat
        if (!v && rowid) {
            v = $('#grid_solanxuat').jqGrid('getCell', rowid, 'trangthai') + '';
        }

        v = $('<div/>').html(v).text();
        v = $.trim(v);

        return v;
    }

    //function solanxuat_LaHieuLuc(rowid) {
    //    var v = solanxuat_LayTrangThai(rowid);

    //    return v == 'HIEULUC' || v == 'Hiệu lực' || v == 'Hieu luc';
    //}
    function solanxuat_TrangThaiKhongDuocSua(rowid) {
        var v = solanxuat_LayTrangThai(rowid);

        var t = $.trim(v).toUpperCase();

        return t == 'SOANTHAO'
            || t == 'SOẠN THẢO'
            || t == 'SOAN THAO'
            || t == 'KETTHUC'
            || t == 'KẾT THÚC'
            || t == 'KET THUC'
            || t == 'DAHOANTHANH'
            || t == 'ĐÃ HOÀN THÀNH'
            || t == 'DA HOAN THANH';
    }

    function solanxuat_ChiDuocXem(rowid) {
        return solanxuat_DaHoanThanh(rowid) || solanxuat_TrangThaiKhongDuocSua(rowid);
    }

    function solanxuat_SetFormChiXem(formid, chiXem) {
        var $form = $(formid);
        var $dialog = $form.closest('div.ui-jqdialog');

        $('#solanxuat_canhbao_chixem', $form).remove();

        $form.find('[data-solanxuat-chixem="1"]')
            .prop('disabled', false)
            .removeAttr('data-solanxuat-chixem');

        $('#sData', $dialog).show().button('enable');
        $('#cData span', $dialog).text('Hủy');

        if (!chiXem) {
            return;
        }

        $form.prepend(
            '<div id="solanxuat_canhbao_chixem" ' +
            'style="margin-bottom:10px;padding:8px;background:#fff3cd;border:1px solid #ffeeba;color:#856404;font-weight:bold;">' +
            'Dòng này chỉ được xem, không được phép chỉnh sửa và không được phép lưu.' +
            '</div>'
        );

        $form.find('input, textarea, select').each(function () {
            var $el = $(this);

            if (!$el.prop('disabled')) {
                $el.attr('data-solanxuat-chixem', '1');
                $el.prop('disabled', true);
            }
        });

        $('#sData', $dialog).hide();
        $('#cData span', $dialog).text('Thoát');
    }




</script>

<div id="hosochungtu-details-4">
    <uc1:jqGrid ID="grid_solanxuat"
        Caption="Lịch sử chuyển xuất"
        SortName="log.sothutu"
        SortOrder="DESC"
        UrlFileAction="Views/hosochungtu/Controller_HoSoChungTu_SoLanXuat.ashx"
        RowNumbers="true"
OndblClickRow="
    function(rowid) {
        if (!rowid) {
            return;
        }

        $('#grid_solanxuat').jqGrid('setSelection', rowid);

        solanxuat_CapNhatOptionNVCT();

        $('#edit_grid_solanxuat').click();

    }
"
   EditFormOptions="
    width:580,

    beforeInitData: function(formid) {
        var rowid = $('#grid_solanxuat').jqGrid('getGridParam', 'selrow');

        if (!rowid) {
            alert('Chưa chọn dòng cần chỉnh sửa.');
            return false;
        }

        return true;
    },

    beforeShowForm: function (formid) {
        solanxuat_CapNhatOptionNVCT();

        formid.css('height', window.innerHeight/2 + window.innerHeight/3);
        formid.find('table.EditTable').css('table-layout', 'auto');
        formid.closest('div.ui-jqdialog').dialogCenter();
    },

    afterShowForm: function(formid) {
        var rowid = $('#grid_solanxuat').jqGrid('getGridParam', 'selrow');
        var row = $('#grid_solanxuat').jqGrid('getRowData', rowid);
        var chiXem = solanxuat_ChiDuocXem(rowid);

        setTimeout(function(){
            $('#nhanvienCT', formid).val(row.nhanvienCT);
            solanxuat_SetFormChiXem(formid, chiXem);
        }, 200);
    },
    beforeSubmit: function(postdata, formid) {
        var rowid = $('#grid_solanxuat').jqGrid('getGridParam', 'selrow');
        if (solanxuat_ChiDuocXem(rowid)) {
            return [false, 'Dòng này chỉ được xem, không được phép chỉnh sửa và không được phép lưu.'];
        }
        return [true, ''];
    },
    afterSubmit: function(rs, postdata){
        var result = showMsgDialog(rs);

        setTimeout(function(){
            $('#grid_solanxuat')[0].triggerToolbar();

            if ($('#grid_ds_hosochungtu').attr('id') != null) {
                $('#grid_ds_hosochungtu').trigger('reloadGrid');
            }

            if ($('#grid_ds_po').attr('id') != null) {
                $('#grid_ds_po').trigger('reloadGrid');
            }
        }, 300);

        return result;
    },

    errorTextFormat:function(data) {
        return 'Lỗi: ' + data.responseText;
    }
"
 ColModel="
[
    {
        name: 'id',
        label: 'id',
        index: 'log.id',
        key: true,
        hidden: true
    },
    {
        name: 'c_donhangchungtu_id',
        label: 'c_donhangchungtu_id',
        index: 'log.c_donhangchungtu_id',
        hidden: true
    },
    {
        name: 'c_donhang_id',
        label: 'c_donhang_id',
        index: 'log.c_donhang_id',
        hidden: true
    },
    {
        name: 'dahonthanh',
        label: 'Đã hoàn thành',
        index: 'log.dahonthanh',
        width: 100,
        fixed: true,
        align: 'center',
        editable: true,
        edittype: 'checkbox',
        editoptions: { value: 'True:False', defaultValue: 'False' },
        formatter: 'checkbox',
        stype: 'select',
        search: true,
        searchoptions: { sopt:['eq'], value:':[ALL];1:Đã hoàn thành;0:Chưa hoàn thành' }
    },

    {
        name: 'trangthai',
        label: 'Trạng thái',
        index: 'dh.trangthai',
        hidden: true,
        editable: true,
        edittype: 'select',
        editrules:{ edithidden : true },
        editoptions:{
            disabled:true,
            value:'SOANTHAO:Soạn Thảo;HIEULUC:Hiệu lực;DAGUIBC:Đã gửi book container;DACOLT:Đã có lịch tàu;DAKEOC:Đã kéo cont/xuất hàng;KETTHUC:Kết thúc'
        }
    },
    {
        name: 'trangthai2',
        label: 'Trạng thái BS',
        index: 'dh.trangthai2',
        hidden: true,
        editable: true,
        edittype: 'select',
        editrules:{ edithidden : true },
        editoptions:{ value:'Moi:-;Bosung:Bổ sung;DAHIEULUC:Đã nhận' }
    },
    {
        name: 'ma_dtkd',
        label: 'Mã số khách',
        index: 'kh.ma_dtkd',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },

    {
        name: 'sothutu',
        label: 'Lần xuất',
        index: 'log.sothutu',
        width: 70,
        fixed: true,
        align: 'center'
    },
    {
        name: 'loaichuyen',
        label: 'Loại chuyển',
        index: 'log.loaichuyen',
        width: 130,
        fixed: true
    },
    {
        name: 'sochungtu',
        label: 'Số PO',
        index: 'log.sochungtu',
        width: 120,
        fixed: true,
        editable: true,
        edittype: 'text',
        editoptions:{ disabled:true }
    },
    {
        name: 'customer_order_no',
        label: 'Số order no',
        index: 'dh2.customer_order_no',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'donhanguutien',
        label: 'Đơn hàng ưu tiên',
        index: 'log.donhanguutien',
        width: 130,
        fixed: true
    },

    {
        name: 'cont20',
        label: 'Cont 20',
        index: 'log.cont20',
        width: 80,
        fixed: true,
        align: 'right',
        editable: true,
        edittype: 'text'
    },
    {
        name: 'cont40',
        label: '40DC',
        index: 'log.cont40',
        width: 80,
        fixed: true,
        align: 'right',
        editable: true,
        edittype: 'text'
    },
    {
        name: 'cont40hc',
        label: '40HC',
        index: 'log.cont40hc',
        width: 80,
        fixed: true,
        align: 'right',
        editable: true,
        edittype: 'text'
    },
    {
        name: 'cont45',
        label: '45',
        index: 'log.cont45',
        width: 70,
        fixed: true,
        align: 'right',
        editable: true,
        edittype: 'text'
    },
    {
        name: 'contLCL',
        label: 'LCL',
        index: 'log.contLCL',
        width: 70,
        fixed: true,
        align: 'right',
        editable: true,
        edittype: 'text'
    },
    {
        name: 'dongghep',
        label: 'Đóng ghép ĐH',
        index: 'dh.dongghep',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'mota',
        label: 'Mô tả',
        index: 'log.mota',
        width: 220,
        editable: true,
        edittype: 'textarea'
    },

    {
        name: 'bookingNo',
        label: 'Booking no',
        index: 'dh.bookingNo',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true }
    },
    {
        name: 'ngayETD',
        label: 'Ngày ETD',
        index: 'dh.ngayETD',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ngayETA',
        label: 'Ngày ETA',
        index: 'dh.ngayETA',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ngayBHXN',
        label: 'Ngày bán hàng XNXH',
        index: 'dh.ngayBHXN',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ngayXuong',
        label: 'Ngày xưởng cung cấp chi tiết',
        index: 'dh.ngayXuong',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ngayCutOff',
        label: 'Ngày cut off SI của htau',
        index: 'dh.ngayCutOff',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ngaypass',
        label: 'Ngày pass kiểm hóa',
        index: 'dh2.ngaypass',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'shipmenttime',
        label: 'Shipment time',
        index: 'dh2.shipmenttime',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'hangiaohang_po',
        label: 'NXH của xưởng',
        index: 'hangiaohang_po',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'ngaydieuchinh',
        label: 'Ngày điều chỉnh',
        index: 'log.ngaydieuchinh',
        width: 120,
        fixed: true,
        align: 'center',
        editable: true,
        edittype: 'text',
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ngaychuyenhoso',
        label: 'Ngày chuyển hồ sơ',
        index: 'dh.ngaychuyenhoso',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'nguoilap',
        label: 'NV bán hàng',
        index: 'dh2.nguoilap',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
{
    fixed: true,
    name: 'nhanvienCT',
    index: 'hsct.nhanvienCT',
    label: 'NV chứng từ',
    hidden: true,
    editable: true,
    width: 100,
    edittype: 'select',
    editrules:{ edithidden : true },
    editoptions: { value: typeof nvcts_hosochungtu == 'undefined' ? ':;' : nvcts_hosochungtu }
},
    {
        name: 'Forwarder',
        label: 'Forwarder',
        index: 'spd.Forwarder',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'ngayBookCont',
        label: 'Ngày book container',
        index: 'dh.ngayBookCont',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'POD',
        label: 'Port of discharge',
        index: 'spd.POD',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions:{ disabled:true }
    },
    {
        name: 'ngayKeoCont',
        label: 'Ngày kéo cont/xuất hàng',
        index: 'dh.ngayKeoCont',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ghichusau',
        label: 'Ghi chú sau',
        index: 'dh.ghichusau',
        hidden: true,
        editable: true,
        edittype: 'textarea',
        editrules:{ edithidden : true }
    },
    {
        name: 'ngaykiemhangpass',
        label: 'Ngày kiểm hàng pass',
        index: 'dh.ngaykiemhangpass',
        hidden: true,
        editable: true,
        edittype: 'text',
        editrules:{ edithidden : true },
        editoptions: {
            dataInit : function (elem) {
                $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
            }
        }
    },
    {
        name: 'ketquakiemhang',
        label: 'Kết quả kiểm hàng',
        index: 'dh.ketquakiemhang',
        hidden: true,
        editable: true,
        edittype: 'select',
        editrules:{ edithidden : true },
        editoptions: { value: ':;Dat:Đạt;KhongDat:Không đạt;ChoKiem:Chờ kiểm' }
    },

    {
        name: 'ngayhoanthanh',
        label: 'Ngày hoàn thành',
        index: 'log.ngayhoanthanh',
        width: 130,
        fixed: true,
        align: 'center',
        editable: false
    },
    {
        name: 'nguoihoanthanh',
        label: 'Người hoàn thành',
        index: 'log.nguoihoanthanh',
        width: 110,
        fixed: true,
        editable: false
    },
    {
        name: 'ngaygui',
        label: 'Ngày gửi',
        index: 'log.ngaygui',
        width: 130,
        fixed: true,
        align: 'center'
    },
    {
        name: 'nguoigui',
        label: 'Người gửi',
        index: 'log.nguoigui',
        width: 100,
        fixed: true
    }
]"
        GridComplete="let o = $('#tabs-hosochungtu-details'); $(this).setGridHeight($(o).height() - 97);$(this).setGridWidth($(o).width())"
        FilterToolbar="true"
        Height="150"
        MultiSelect="false"
        ShowAdd="false"
        ShowEdit="true"
        ShowDel="false"
        runat="server" />
</div>