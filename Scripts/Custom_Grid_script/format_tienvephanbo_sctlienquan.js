//Start
var format_tienvephanbo_sctlienquan = {
    create: function (elem) {
        setTimeout(function () {
            let id_elem = $(elem);
            let clone = id_elem.clone();
            clone.attr('id', `${id_elem.attr('id')}CP`);
            clone.attr('type', 'hidden');
            clone.insertBefore(id_elem);

            id_elem.css({ 'padding': '2.5px', 'border': '1px solid #000', width: '200px' });
            id_elem.attr('readonly', true);
            id_elem.parent().append(`
                <i onclick="format_tienvephanbo_sctlienquan.search(this)"
                class="span_format_tienvephanbo_sctlienquan fab fa-accusoft" 
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
        let loai = $('#loaihd', '#FrmGrid_grid_ds_tienvephanbo').val();
        if (!loai) {
            alert('Chưa chọn kiểu hồ sơ');
            return;
        }
        // Grid
        $('body').append(`
            <div id="dlg_gridSmal_2"
                style="margin: 4px 0 0 0; background-color: rgba(165, 121, 255, 0.07);"
                title="Chọn hợp đồng hoặc invoice cần phân bổ"
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
        let selRowMaster = function (rowid) {
            if (!rowid)
                rowid = gridMaster.jqGrid('getGridParam', 'selrow');
            let cell = gridMaster.getRowData(rowid);
            id_elem.val(cell.sochungtu);
            id_elemCP.val(cell.sochungtu);
            $('#dlg_gridSmal_2').dialog("destroy").remove();
        };
        let widthDialog = 500;
        $('#dlg_gridSmal_2').dialog({
            modal: true,
            dialogClass: "dialog_index",
            width: widthDialog,
            height: window.innerHeight - 10,
            open: function (event, ui) {
                //Luoi 1
                gridMaster.jqGrid({
                    height: window.innerHeight - 206,
                    url: `Views/tienve/Controller_TienVe_PhanBo.ashx?action=loadGrid`,
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
                        id: "sochungtu"
                    },
                    postData: {
                        tvid: id_inc_tienve,
                        loai: loai
                    },
                    colModel: [
                        {
                            fixed: true, name: 'sochungtu'
                            , label: 'Số chứng từ'
                            , index: loai === 'IN' ? 'dh.so_pkl' : 'dh.sochungtu'
                            , editable: true
                            , width: loai === 'IN' ? 150 : 200
                            , edittype: 'text'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'gtcc'
                            , label: 'Giá trị'
                            , editable: true
                            , width: 80
                            , edittype: 'text'
                            , search: false
                            , align: 'right'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'dtt'
                            , label: 'Đã thanh toán'
                            , editable: true
                            , width: 80
                            , edittype: 'text'
                            , search: false
                            , align: 'right'
                            , editrules: { required: true }
                            , hidden: loai === 'PO'
                        },
                        {
                            fixed: true, name: 'conlai'
                            , label: 'Còn lại'
                            , editable: true
                            , width: 80
                            , edittype: 'text'
                            , search: false
                            , align: 'right'
                            , editrules: { required: true }
                            , hidden: loai === 'PO'
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
                    caption: 'Hợp đồng hoặc Invoice'
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