//Start
var format_donhang_spd_forwarder = {
    create: function (elem) {
        setTimeout(function () {
            let id_elem = $(elem);
            let clone = id_elem.clone();
            clone.attr('id', `${id_elem.attr('id')}CP`);
            clone.attr('type', 'hidden');
            clone.insertBefore(id_elem);

            id_elem.css({ 'padding': '2.5px', 'border': '1px solid #000', width: '150px' });
            id_elem.attr('readonly', true);
            id_elem.parent().append(`
                <i onclick="format_donhang_spd_forwarder.search(this)"
                class="span_format_donhang_spd_forwarder fab fa-accusoft" 
                style="position: absolute; margin: 1px 0 0 -23px; background-color: rgb(248, 249, 243); padding: 3px; cursor: pointer;border-left: 1px solid rgba(204, 204, 204, 0.63)"
                />
            `);
        }, 100);
    },
    search: function (id_elem, type) {
        id_elem = $(id_elem).prev();
        id_elemCP = id_elem.prev();
        if (id_elem.prop('disabled')) {
            alert('Trường dữ liệu đã bị khóa');
            return;
        }
        // Grid
        $('body').append(`
            <div id="dlg_gridSmal_2"
                style="margin: 4px 0 0 0; background-color: rgba(165, 121, 255, 0.07);"
                title="Chọn shipping detail"
            >
                <table style="width:100%;">
                <tr>
                    <td>
                        <table id="gridMaster"></table>
                        <div id="papergridMaster"></div>
                    </td>
                </tr>
                </table>
            </div>
        `);
        
        let gridMaster = $('#gridMaster');
        let $dh = $('#grid_ds_po').getRowData(id_inc_po);
        let madtkd = $dh ? $dh.md_doitackinhdoanh_id : '';
        let frmid = '#FrmGrid_grid_ds_donhang_spdt';
        let selRowMaster = function (rowid) {
            if (!rowid)
                rowid = gridMaster.jqGrid('getGridParam', 'selrow');
            let cell = gridMaster.getRowData(rowid);
            id_elem.val(cell.Forwarder);
            $('#Shipper', frmid).val(cell.Shipper);
            $('#Consignee', frmid).val(cell.Consignee);
            $('#Notify', frmid).val(cell.Notify);
            $('#AlsoNotify', frmid).val(cell.AlsoNotify);
            $('#POD', frmid).val(cell.POD);
            $('#PlaceOfDelivery', frmid).val(cell.PlaceOfDelivery);
            $('#AddressForSendingOriginalDocs', frmid).val(cell.AddressForSendingOriginalDocs);
            $('#EmailSendPaymentRequest', frmid).val(cell.EmailSendPaymentRequest);
            $('#CacLoaiCTYC', frmid).val(cell.CacLoaiCTYC);
            $('#dlg_gridSmal_2').dialog("destroy").remove();
        };
        let widthDialog = 800;
        $('#dlg_gridSmal_2').dialog({
            modal: true,
            dialogClass: "dialog_index",
            width: widthDialog,
            height: window.innerHeight - 10,
            open: function (event, ui) {
                //Luoi 1
                gridMaster.jqGrid({
                    height: window.innerHeight - 216,
                    url: `Views/doitac/Controller_DTKD_SPDT.ashx`,
                    mtype: 'POST',
                    autowidth: true,
                    shrinkToFit: true,
                    rownumbers: true,
                    viewrecords: true,
                    scroll: false,
                    rowNum: 500,
                    multiselect: false,
                    multiboxonly: false,
                    rowList: [500],
                    pager: '#papergridMaster',
                    jsonReader: {
                        repeatitems: false,
                        id: "md_phienbangia_id"
                    },
                    postData: {
                        madtkd: madtkd
                    },
                    colModel: [
                        {
                            fixed: true, name: 'md_doitackinhdoanh_spd_id'
                            , index: 'spd.md_doitackinhdoanh_spd_id'
                            , width: 100
                            , hidden: true
                            , editable: true
                            , edittype: 'text'
                            , key: true
                        },
                        {
                            fixed: true, name: 'md_donhang_id'
                            , index: 'spd.md_donhang_id'
                            , editable: false
                            , width: 100
                            , edittype: 'select'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'Forwarder'
                            , label: 'Forwarder'
                            , index: 'spd.Forwarder'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'Shipper'
                            , label: 'Shipper'
                            , index: 'spd.Shipper'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'Consignee'
                            , label: 'Consignee'
                            , index: 'spd.Consignee'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'Notify'
                            , label: 'Notify'
                            , index: 'spd.Notify'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'AlsoNotify'
                            , label: 'AlsoNotify'
                            , index: 'spd.AlsoNotify'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'POD'
                            , label: 'POD'
                            , index: 'spd.POD'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'PlaceOfDelivery'
                            , label: 'Place Of Delivery'
                            , index: 'spd.PlaceOfDelivery'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'AddressForSendingOriginalDocs'
                            , label: 'Address for sending original docs'
                            , index: 'spd.AddressForSendingOriginalDocs'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'EmailSendPaymentRequest'
                            , label: 'Email send payment request'
                            , index: 'spd.EmailSendPaymentRequest'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'CacLoaiCTYC'
                            , label: 'Các loại CT yêu cầu'
                            , index: 'spd.CacLoaiCTYC'
                            , editable: true
                            , width: 100
                            , edittype: 'text'
                        },
                        {
                            fixed: true, name: 'ngaytao'
                            , label: 'Ngày tạo'
                            , index: 'cl.ngaytao'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , align: ' center'
                        },
                        {
                            fixed: true, name: 'nguoitao'
                            , label: 'Người tạo'
                            , index: 'cl.nguoitao'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'ngaycapnhat'
                            , label: 'Ngày cập nhật'
                            , index: 'cl.ngaycapnhat'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , hidden: true
                            , align: ' center'
                        },
                        {
                            fixed: true, name: 'nguoicapnhat'
                            , label: 'Người cập nhật'
                            , index: 'cl.nguoicapnhat'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'mota'
                            , label: 'Mô tả'
                            , index: 'cl.mota'
                            , width: 100
                            , editable: true
                            , edittype: 'textarea'
                        },
                        {
                            fixed: true, name: 'hoatdong', hidden: true
                            , label: 'Hoạt động'
                            , index: 'hoatdong'
                            , width: 100
                            , editable: true
                            , edittype: 'checkbox'
                            , align: 'center'
                            , editoptions: { value: 'True:False', defaultValue: 'True' }
                            , formatter: 'checkbox'
                        }
                    ],
                    ondblClickRow: function (rowid) {
                        selRowMaster(rowid);
                    },
                    onSelectRow: function (ids) {
                        
                    },
                    gridComplete: function () {

                    },
                    loadComplete: function (data) {

                    },
                    beforeRequest: function () {

                    },
                    beforeProcessing: function (data) {

                    },
                    caption: 'Shipping Detail'
                });

                gridMaster.jqGrid('filterToolbar', { searchOnEnter: false, stringResult: true });
            },
            close: function () {
                $(this).dialog('destroy').remove();
            },
            buttons:
                [{
                    id: 'btn-ok_',
                    text: 'Đồng ý',
                    click: function () {
                        selRowMaster();
                    }
                },
                {
                    id: 'btn-close_',
                    text: 'Thoát',
                    click: function () {
                        $(this).dialog("destroy").remove();
                    }
                }]
        });
    }
};
//End