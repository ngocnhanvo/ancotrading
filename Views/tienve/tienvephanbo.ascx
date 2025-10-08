<%@ Control Language="C#" AutoEventWireup="true" CodeFile="tienvephanbo.ascx.cs" Inherits="Views_tienve_tienvephanbo" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script type="text/javascript">
    var tienvephanbo_tinhphi = function ($this, type) {
        if (type == 0) {
            let style = `cursor: pointer;`;
            style += `user-select: none;`;
            style += `display: inline;`;
            style += `text-decoration: underline;`;
            style += `color: blue;`;
            style += `margin-left: 10px;`;
            return `<div style="${style}" onclick="tienvephanbo_tinhphi(this, 1)">Tính phí</div>`;
        }
        else {
            let $frm = $('#FrmGrid_grid_ds_tienvephanbo');
            let $tctt = $frm.find('#sotien');
            let $phi = $frm.find('#phi');
            $phi.val('Loading...');
            $.post(`Views/tienve/Controller_TienVe_PhanBo.ashx?action=layPhi`, { id: id_inc_tienve, tctt: $tctt.val() }, function (rs) {
                rs = JSON.parse(rs);
                $phi.val(rs.phi);
            });
        }
    };
</script>
<div id="tienve-details-1">
<uc1:jqGrid  ID="grid_ds_tienvephanbo" 
    FilterToolbar="true"
    UrlFileAction="Views/tienve/Controller_TienVe_PhanBo.ashx"
    RowNumbers="true"
    OndblClickRow = "function(){ $('#edit_grid_ds_tienvephanbo').click(); }"
    ColModel = "[
    {
        fixed: true
        , name: 'kt_tienve_phanbo_id'
        , index: 'cttv.kt_tienve_phanbo_id'
        , width: 100
        , hidden: true 
        , editable: false
        , edittype: 'text'
        , key: true
    },
    {
        fixed: true
        , name: 'kt_tienve_id'
        , index: 'cttv.kt_tienve_id'
        , editable: false
        , width: 100
        , edittype: 'text'
        , hidden:true
    },
    {
        name: 'trangthai'
        , index: 'tv.trangthai'
        , label: 'Trạng thái'
        , editable: false
        , fixed:true , width: 100
        , edittype: 'text'
        , align:'center'
        , formatter:'imagestatus'
        , search : true
        , stype : 'select'
        , searchoptions:{sopt:['eq'], value:':[ALL];SOANTHAO:SOẠN THẢO;HIEULUC:HIỆU LỰC;KETTHUC: KẾT THÚC' }
    },
	{
        fixed: true
        , name: 'phieuthu_id'
        , index: 'cttv.phieuthu_id'
        , label: 'Phiếu thu'
        , width: 100
        , hidden: false 
        , editable:false
        , edittype: 'text'
        , key: true
    },
    {
        fixed: true
        , name: 'loaihd'
        , index: 'cttv.loaihd'
        , label: 'Kiểu hồ sơ'
        , width: 100
        , edittype: 'text'
        , editable:true
        , edittype: 'select'
        , editoptions: { value:':;PO:Hợp đồng;IN:Packing list - Invoice;CK:Chi INV' }
        , stype : 'select'
        , searchoptions: { value:':;PO:Hợp đồng;IN:Packing list - Invoice;CK:Chi INV' }
    },
    {
        fixed: true
        , name: 'sctlienquan'
        , label: 'SCT liên quan'
        , index: 'sctlienquan'
        , width: 100
        , editable: true
        , edittype: 'text'
        , editoptions:{ dataInit: function (elem) { format_tienvephanbo_sctlienquan.create(elem); } }
        , hidden: false 
        , editrules:{ edithidden : true }
    },
    {
        fixed: true, name: 'sotien'
        , index: 'cttv.sotien'
        , label: 'Tiền cọc/Tiền thanh toán'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
    },
    {
        fixed: true, name: 'phi'
        , index: 'cttv.phi'
        , label: 'Phí'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions:{ defaultValue: '0' }
        , formoptions: { label: 'Phí' + tienvephanbo_tinhphi(null, 0) }
    }, 
    {
        fixed: true, name: 'tpb_inv'
        , index: 'cttv.tpb_inv'
        , label: 'Tiền phân bổ cọc INV'
        , editable: false
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions:{ defaultValue: '0' }
        , hidden: true
    }, 
    {
        fixed: true, name: 'tcl'
        , index: 'cttv.tcl'
        , label: 'Tiền còn lại'
        , editable: false
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions:{ defaultValue: '0' }
        , hidden: true
    }, 
    {
        fixed: true, name: 'ngaytao'
        , index: 'cttc.ngaytao'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        fixed: true, name: 'nguoitao'
        , label: 'Người phân bổ'
        , index: 'cttc.nguoitao'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: false
        , editrules:{ edithidden : true }
    },
    {
        fixed: true, name: 'ngaycapnhat'
        , index: 'cttc.ngaycapnhat'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        fixed: true, name: 'nguoicapnhat'
        , index: 'cttc.nguoicapnhat'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        fixed: true, name: 'mota'
        , index: 'cttc.mota'
        , width: 100
        , editable: true
        , edittype: 'textarea'
        , hidden: true
    },
    {
        fixed: true, name: 'hoatdong', hidden: true
        , index: 'cttc.hoatdong'
        , width: 100
        , editable:false
        , edittype: 'checkbox'
        , editoptions:{ defaultValue: 'True' }
        , editrules:{ edithidden : true }
    }
    ]"
    GridBeforeRequest = "$('#grid_ds_tienvephanbo').jqGrid('getGridParam', 'postData').id = id_inc_tienve;"
    GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
    Height = "150"
    MultiSelect = "false" 
    ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
    ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
    ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
    AddFormOptions=" 
    width: 400,
    beforeShowForm: function (formid) {
        formid.closest('div.ui-jqdialog').dialogCenter(); 
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    },
    beforeSubmit:function(postdata, formid) {
        postdata.tvid = id_inc_tienve;
        return [true,''];
    },
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_tienve')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    EditFormOptions ="
    width: 400,
    beforeShowForm: function (formid) {
        formid.closest('div.ui-jqdialog').dialogCenter(); 
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    },
    beforeSubmit:function(postdata, formid) {
        postdata.tvid = id_inc_tienve;
        return [true,''];
    },
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_tienve')[0].triggerToolbar();
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
        $('#grid_ds_tienve')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    runat="server" />
</div>



<script type="text/javascript">
    var tygia_tienvephanbo = <%=tygia%>;

    var tienvephanbo_taophieuthu = function (rowsel) {
        let iddl = "dialog-taophieuthutienve-tuexcel";
        $('body').append(`
                <div title="Tạo phiếu thu tiền về" id="${iddl}">
                    <div id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                    <div style="display:none" id="dialog-caution" class="ui-jqdialog-content ui-widget-content">
                        <form name="FormPost" id="FrmGrid_grid_ds_tienvephanbo2" class="FormGrid" onsubmit="return false;" style="width:100%;overflow:auto;position:relative;height:auto;">
                            <table id="TblGrid_grid_ds_tienvephanbo" class="EditTable" cellspacing="0" cellpadding="0" border="0">
                            <tbody>
                                <tr rowpos="2" class="FormData" id="tr_loai">
                                    <td class="CaptionTD">Loại</td>
                                    <td class="DataTD">&nbsp; 
                                        <select role="select" id="loai" name="loai" size="1" class="FormElement">
                                            <option role="option" value="KH">Thu Khách Hàng</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr rowpos="3" class="FormData" id="tr_md_doitackinhdoanh_id">
                                    <td class="CaptionTD">Mã khách hàng</td>
                                    <td class="DataTD">&nbsp; 
                                        <input type="text" id="ma_khachhang" readonly class="FormElement ui-widget-content ui-corner-all" role="textbox">
                                    </td>
                                </tr>
                                <tr rowpos="4" class="FormData" id="tr_ngaylapphieu">
                                    <td class="CaptionTD">Ngày lập phiếu</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="ngaylapphieu" name="ngaylapphieu" class="FormElement ui-widget-content ui-corner-all" role="textbox">
                                    </td>
                                </tr>
                                <tr rowpos="5" class="FormData" id="tr_nguoi_giaonop">
                                    <td class="CaptionTD">Người Giao Nộp</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="nguoi_giaonop" name="nguoi_giaonop" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="6" class="FormData" id="tr_ngay_giaonop">
                                    <td class="CaptionTD">Ngày Giao Nộp</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="ngay_giaonop" name="ngay_giaonop" class="FormElement ui-widget-content ui-corner-all" role="textbox">
                                    </td>
                                </tr>
                                <tr rowpos="7" class="FormData" id="tr_sotien">
                                    <td class="CaptionTD">Số Tiền</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="sotien" readonly role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="8" class="FormData" id="tr_md_dongtien_id">
                                    <td class="CaptionTD">Đồng Tiền</td>
                                    <td class="DataTD">&nbsp; <select role="select" class="FormElement" id="md_dongtien_id" name="md_dongtien_id">
                                        <option value="b30ed8e90474a082008bf12804834078" role="option">USD</option>
                                    </select>
                                    </td>
                                </tr>
                                <tr rowpos="9" class="FormData" id="tr_tygia">
                                    <td class="CaptionTD">Tỷ Giá</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="tygia" name="tygia" value="${tygia_tienvephanbo}" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="10" class="FormData" id="tr_lydo">
                                    <td class="CaptionTD">Mô tả</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="lydo" name="lydo" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="11" class="FormData" id="tr_sochungtu">
                                    <td class="CaptionTD">Số Chứng Từ</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="sochungtu" name="sochungtu" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="12" class="FormData" id="tr_quydoi_vnd">
                                    <td class="CaptionTD">Quy Đổi VND</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="quydoi_vnd" name="quydoi_vnd" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="13" class="FormData" id="tr_tk_quy">
                                    <td class="CaptionTD">TK Quỹ</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="tk_quy" name="tk_quy" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="18" class="FormData" id="tr_mota">
                                    <td class="CaptionTD">Mô tả</td>
                                    <td class="DataTD">&nbsp; <textarea id="mota" name="mota" cols="20" rows="2" role="textbox" multiline="true" class="FormElement ui-widget-content ui-corner-all"></textarea>
                                    </td>
                                </tr>
                            </tbody>
                            </table>
                        </form>
                    </div>
                </div>
            `);
        let $dlg = $(`#${iddl}`); 
        $dlg.dialog({
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $('#ma_khachhang', '#FrmGrid_grid_ds_tienvephanbo2').val(rowsel.dtkd_id);
                let currentTime = new Date();
                let month = parseInt(currentTime.getMonth() + 1);
                month = month <= 9 ? '0' + month : month;
                let day = currentTime.getDate();
                day = day <= 9 ? '0' + day : day;
                let year = currentTime.getFullYear();
                let kq = day + '/' + month + '/' + year;
                $('#ngaylapphieu', '#FrmGrid_grid_ds_tienvephanbo2').val(kq);
                $('#ngay_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').val(kq);
                $('#ngaylapphieu', '#FrmGrid_grid_ds_tienvephanbo2').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
                $('#ngay_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });

                $('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').change(() => {
                    let st = Number($('#sotien', '#FrmGrid_grid_ds_tienvephanbo2').val());
                    let tg = Number($('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').val());
                    $('#quydoi_vnd', '#FrmGrid_grid_ds_tienvephanbo2').val((st * tg).toFixed(0));
                });

                $.get(`Views/tienve/Controller_TienVe_PhanBo.ashx`, { action: 'getAmount', id: id_inc_tienve }, function (st) {
                    if (st <= 0) {
                        alert('Không có dòng "chi tiết tiền về" nào có thể tạo phiếu thu');
                        $(`#btn-close-${iddl}`).click();
                    }
                    else {
                        $("#wait").css("display", "none");
                        $dlg.find('#dialog-caution').css("display", "");
                        $('#sotien', '#FrmGrid_grid_ds_tienvephanbo2').val(st);
                        $('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').change();
                        $dlg.dialog("option", "position", "center");
                    }
                });
            },
            close: function () {
                $(`#btn-close-${iddl}`).click();
            },
            buttons:
                [
                    {
                        id: `btn-ok-${iddl}`,
                        text: "Có",
                        click: function () {
                            let ajaxStart = function () {
                                $("#wait").css("display", "block");
                                $(`#btn-ok-${iddl}`).button("disable");
                                $(`#btn-close-${iddl}`).button("disable");
                            };

                            let ajaxComplete = function () {
                                $("#wait").css("display", "none");
                                $(`#btn-close-${iddl} span`).text("Thoát");
                                $(`#btn-close-${iddl}`).button("enable");
                            };

                            ajaxStart();
                            let formData = new FormData();
                            formData.append('action', 'createReceipt');
                            formData.append('id', id_inc_tienve);
                            formData.append('loai', $('#loai', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('ngaylapphieu', $('#ngaylapphieu', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('nguoi_giaonop', $('#nguoi_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('ngay_giaonop', $('#ngay_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('md_dongtien_id', $('#md_dongtien_id', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('tygia', $('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('lydo', $('#lydo', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('sochungtu', $('#sochungtu', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('quydoi_vnd', $('#quydoi_vnd', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('tk_quy', $('#tk_quy', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('mota', $('#mota', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            $.ajax({
                                url: "Views/tienve/Controller_TienVe_PhanBo.ashx",
                                type: "POST",
                                data: formData,
                                processData: false,
                                contentType: false,
                                error: function (rs) {
                                    ajaxComplete();
                                    Popup("Error", 500, 400, rs.responseText);
                                },
                                success: function (rs) {
                                    $dlg.find('#dialog-caution').html(rs);
                                    ajaxComplete();

                                    if (rs.lastIndexOf('error') <= -1) {
                                        $('#grid_ds_tienve')[0].triggerToolbar();
                                        $('#grid_ds_tienvephanbo')[0].triggerToolbar();
                                    }
                                }
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
    };

    var tienvephanbo_taophieuchi = function (rowsel) {
        let iddl = "dialog-taophieuchitienve-tuexcel";
        $('body').append(`
                <div title="Tạo phiếu chi tiền về" id="${iddl}">
                    <div id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                    <div style="display:none" id="dialog-caution" class="ui-jqdialog-content ui-widget-content">
                        <form name="FormPost" id="FrmGrid_grid_ds_tienvephanbo2" class="FormGrid" onsubmit="return false;" style="width:100%;overflow:auto;position:relative;height:auto;">
                            <table id="TblGrid_grid_ds_tienvephanbo" class="EditTable" cellspacing="0" cellpadding="0" border="0">
                            <tbody>
                                <tr rowpos="3" class="FormData" id="tr_md_doitackinhdoanh_id">
                                    <td class="CaptionTD">Mã khách hàng</td>
                                    <td class="DataTD">&nbsp; 
                                        <input type="text" id="ma_khachhang" readonly class="FormElement ui-widget-content ui-corner-all" role="textbox">
                                    </td>
                                </tr>
                                <tr rowpos="4" class="FormData" id="tr_ngaylapphieu">
                                    <td class="CaptionTD">Ngày lập phiếu</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="ngaylapphieu" name="ngaylapphieu" class="FormElement ui-widget-content ui-corner-all" role="textbox">
                                    </td>
                                </tr>
                                <tr rowpos="5" class="FormData" id="tr_nguoi_giaonop">
                                    <td class="CaptionTD">Người Giao Nộp</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="nguoi_giaonop" name="nguoi_giaonop" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="6" class="FormData" id="tr_ngay_giaonop">
                                    <td class="CaptionTD">Ngày Giao Nộp</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="ngay_giaonop" name="ngay_giaonop" class="FormElement ui-widget-content ui-corner-all" role="textbox">
                                    </td>
                                </tr>
                                <tr rowpos="7" class="FormData" id="tr_sotien">
                                    <td class="CaptionTD">Số Tiền</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="sotien" readonly role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="8" class="FormData" id="tr_md_dongtien_id">
                                    <td class="CaptionTD">Đồng Tiền</td>
                                    <td class="DataTD">&nbsp; <select role="select" class="FormElement" id="md_dongtien_id" name="md_dongtien_id">
                                        <option value="b30ed8e90474a082008bf12804834078" role="option">USD</option>
                                    </select>
                                    </td>
                                </tr>
                                <tr rowpos="9" class="FormData" id="tr_tygia">
                                    <td class="CaptionTD">Tỷ Giá</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="tygia" name="tygia" value="${tygia_tienvephanbo}" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="10" class="FormData" id="tr_lydo">
                                    <td class="CaptionTD">Mô tả</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="lydo" name="lydo" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="11" class="FormData" id="tr_sochungtu">
                                    <td class="CaptionTD">Số Chứng Từ</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="sochungtu" name="sochungtu" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="12" class="FormData" id="tr_quydoi_vnd">
                                    <td class="CaptionTD">Quy Đổi VND</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="quydoi_vnd" name="quydoi_vnd" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="13" class="FormData" id="tr_tk_quy">
                                    <td class="CaptionTD">TK Quỹ</td>
                                    <td class="DataTD">&nbsp; <input type="text" id="tk_quy" name="tk_quy" role="textbox" class="FormElement ui-widget-content ui-corner-all">
                                    </td>
                                </tr>
                                <tr rowpos="18" class="FormData" id="tr_mota">
                                    <td class="CaptionTD">Mô tả</td>
                                    <td class="DataTD">&nbsp; <textarea id="mota" name="mota" cols="20" rows="2" role="textbox" multiline="true" class="FormElement ui-widget-content ui-corner-all"></textarea>
                                    </td>
                                </tr>
                            </tbody>
                            </table>
                        </form>
                    </div>
                </div>
            `);
        let $dlg = $(`#${iddl}`); 
        $dlg.dialog({
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $('#ma_khachhang', '#FrmGrid_grid_ds_tienvephanbo2').val(rowsel.dtkd_id);
                let currentTime = new Date();
                let month = parseInt(currentTime.getMonth() + 1);
                month = month <= 9 ? '0' + month : month;
                let day = currentTime.getDate();
                day = day <= 9 ? '0' + day : day;
                let year = currentTime.getFullYear();
                let kq = day + '/' + month + '/' + year;
                $('#ngaylapphieu', '#FrmGrid_grid_ds_tienvephanbo2').val(kq);
                $('#ngay_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').val(kq);
                $('#ngaylapphieu', '#FrmGrid_grid_ds_tienvephanbo2').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
                $('#ngay_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });

                $('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').change(() => {
                    let st = Number($('#sotien', '#FrmGrid_grid_ds_tienvephanbo2').val());
                    let tg = Number($('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').val());
                    $('#quydoi_vnd', '#FrmGrid_grid_ds_tienvephanbo2').val((st * tg).toFixed(0));
                });

                $.get(`Views/tienve/Controller_TienVe_PhanBo.ashx`, { action: 'getAmount', id: id_inc_tienve, tpc: true }, function (st) {
                    if (st <= 0) {
                        alert('Không có dòng "chi tiết tiền về" nào có thể tạo phiếu chi');
                        $(`#btn-close-${iddl}`).click();
                    }
                    else {
                        $("#wait").css("display", "none");
                        $dlg.find('#dialog-caution').css("display", "");
                        $('#sotien', '#FrmGrid_grid_ds_tienvephanbo2').val(st);
                        $('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').change();
                        $dlg.dialog("option", "position", "center");
                    }
                });
            },
            close: function () {
                $(`#btn-close-${iddl}`).click();
            },
            buttons:
                [
                    {
                        id: `btn-ok-${iddl}`,
                        text: "Có",
                        click: function () {
                            let ajaxStart = function () {
                                $("#wait").css("display", "block");
                                $(`#btn-ok-${iddl}`).button("disable");
                                $(`#btn-close-${iddl}`).button("disable");
                            };

                            let ajaxComplete = function () {
                                $("#wait").css("display", "none");
                                $(`#btn-close-${iddl} span`).text("Thoát");
                                $(`#btn-close-${iddl}`).button("enable");
                            };

                            ajaxStart();
                            let formData = new FormData();
                            formData.append('action', 'createPayment');
                            formData.append('id', id_inc_tienve);
                            formData.append('loai', $('#loai', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('ngaylapphieu', $('#ngaylapphieu', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('nguoi_giaonop', $('#nguoi_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('ngay_giaonop', $('#ngay_giaonop', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('md_dongtien_id', $('#md_dongtien_id', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('tygia', $('#tygia', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('lydo', $('#lydo', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('sochungtu', $('#sochungtu', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('quydoi_vnd', $('#quydoi_vnd', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('tk_quy', $('#tk_quy', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            formData.append('mota', $('#mota', '#FrmGrid_grid_ds_tienvephanbo2').val());
                            $.ajax({
                                url: "Views/tienve/Controller_TienVe_PhanBo.ashx",
                                type: "POST",
                                data: formData,
                                processData: false,
                                contentType: false,
                                error: function (rs) {
                                    ajaxComplete();
                                    Popup("Error", 500, 400, rs.responseText);
                                },
                                success: function (rs) {
                                    $dlg.find('#dialog-caution').html(rs);
                                    ajaxComplete();

                                    if (rs.lastIndexOf('error') <= -1) {
                                        $('#grid_ds_tienve')[0].triggerToolbar();
                                        $('#grid_ds_tienvephanbo')[0].triggerToolbar();
                                    }
                                }
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
    };

    $("#grid_ds_tienvephanbo").jqGrid('navButtonAdd', '#grid_ds_tienvephanbo-pager', {
        caption: "Tạo phiếu",
        title: "Tạo phiếu",
        onClickButton: function () {
            let rowsel = $('#grid_ds_tienve').getRowData(id_inc_tienve);
            if (!rowsel) {
                alert('Chưa chọn tiền về');
                return;
            }
            if(!rowsel.dtkd_id) {
                alert('Chưa chọn khách hàng');
                return;
            }

            let iddl = 'dlg_tienvephanbo_loaiphieu';
            $('body').append(`
                <div title="Chọn loại phiếu cần tạo" id="${iddl}">
                    Bạn muốn tạo phiếu thu hay phiếu chi?
                </div>
            `);

            let $dlg = $(`#${iddl}`);
            $dlg.dialog({
                modal: true,
                open: function (event, ui) {

                },
                close: function () {
                    $(`#btn-close-${iddl}`).click();
                },
                buttons:
                [
                    {
                        id: `btn-tpt-${iddl}`,
                        text: "Tạo phiếu thu",
                        click: function () {
                            $(this).dialog("destroy").remove();
                            tienvephanbo_taophieuthu(rowsel);
                        }
                    },
                    {
                        id: `btn-tpc-${iddl}`,
                        text: "Tạo phiếu chi",
                        click: function () {
                            $(this).dialog("destroy").remove();
                            tienvephanbo_taophieuchi(rowsel);
                        }
                    },
                ]
            });
        }
    });

    $("#grid_ds_tienvephanbo").jqGrid('navButtonAdd', '#grid_ds_tienvephanbo-pager', {
        caption: "Làm mới TPBINV",
        title: "Làm mới tiền phân bổ INV",
        onClickButton: function () {
            alert(`Chức năng đã được bảo trì, chờ chỉnh sửa`);
            return;

            let rowsel = $('#grid_ds_tienve').getRowData(id_inc_tienve);
            if (!rowsel) {
                alert('Chưa chọn tiền về');
                return;
            }

            let iddl = "dialog-tienvelammoiphanbo";
            $('body').append(`
                    <div title="Làm mới tiền phân bổ" id="${iddl}">
                        <div id="wait" style="display:none"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                        <div id="dialog-caution" class="ui-jqdialog-content ui-widget-content">
                            Thực hiện chức năng này?
                        </div>
                    </div>
                `);
            let $dlg = $(`#${iddl}`); 
            $dlg.dialog({
                modal: true
                , open: function (event, ui) {
                    
                },
                close: function () {
                    $(`#btn-close-${iddl}`).click();
                },
                buttons:
                    [
                        {
                            id: `btn-ok-${iddl}`,
                            text: "Có",
                            click: function () {
                                let ajaxStart = function () {
                                    $("#wait").css("display", "block");
                                    $(`#btn-ok-${iddl}`).button("disable");
                                    $(`#btn-close-${iddl}`).button("disable");
                                };

                                let ajaxComplete = function () {
                                    $("#wait").css("display", "none");
                                    $(`#btn-close-${iddl} span`).text("Thoát");
                                    $(`#btn-close-${iddl}`).button("enable");
                                };

                                ajaxStart();
                                let formData = new FormData();
                                formData.append('action', 'lammoiTienPhanBo');
                                formData.append('id', id_inc_tienve);
                                $.ajax({
                                    url: "Views/tienve/Controller_TienVe_PhanBo.ashx",
                                    type: "POST",
                                    data: formData,
                                    processData: false,
                                    contentType: false,
                                    error: function (rs) {
                                        ajaxComplete();
                                        Popup("Error", 500, 400, rs.responseText);
                                    },
                                    success: function (rs) {
                                        $dlg.find('#dialog-caution').html(rs);
                                        ajaxComplete();

                                        if (rs.lastIndexOf('error') <= -1) {
                                            $('#grid_ds_tienvephanbo')[0].triggerToolbar();
                                        }
                                    }
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