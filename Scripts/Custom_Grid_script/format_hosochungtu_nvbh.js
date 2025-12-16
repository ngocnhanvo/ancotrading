//Start
var format_hosochungtu_nvbh = {
    create: function (elem) {
        setTimeout(function () {
            let id_elem = $(elem);
            let clone = id_elem.clone();
            clone.attr('id', `${id_elem.attr('id')}CP`);
            clone.attr('type', 'hidden');
            clone.insertBefore(id_elem);

            id_elem.css({ 'padding': '2.5px', 'border': '1px solid #000', width: '150px' });
            //id_elem.attr('readonly', true);
            id_elem.parent().append(`
                <i onclick="format_hosochungtu_nvbh.search(this)"
                class="span_format_hosochungtu_nvbh fab fa-accusoft" 
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
                title="Chọn nhân viên bán hàng"
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
        let $dh = $('#grid_ds_hosochungtu').getRowData(id_inc_hosochungtu);
        let frmid = '#FrmGrid_grid_ds_hosochungtu';
        let selRowMaster = function (rowid) {
            if (!rowid)
                rowid = gridMaster.jqGrid('getGridParam', 'selrow');
            let cell = gridMaster.getRowData(rowid);
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
                    url: `Controllers/UserController.ashx?action=loadNVBH`,
                    mtype: 'POST',
                    autowidth: true,
                    shrinkToFit: true,
                    rownumbers: true,
                    viewrecords: true,
                    scroll: false,
                    rowNum: 500,
                    multiselect: true,
                    multiboxonly: true,
                    rowList: [500],
                    pager: '#papergridMaster',
                    jsonReader: {
                        repeatitems: false,
                        id: "manv"
                    },
                    colModel: [
                        {
                            fixed: true, name: 'manv'
                            , index: 'manv'
                            , width: 100
                            , hidden: false
                            , editable: true
                            , edittype: 'text'
                            , key: true
                        },
                        {
                            fixed: true, name: 'hoten'
                            , index: 'hoten'
                            , editable: false
                            , width: 150
                            , hidden: false
                        },
                        {
                            fixed: true, name: 'email'
                            , index: 'email'
                            , editable: false
                            , width: 150
                            , hidden: false
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
                    caption: 'Nhân viên bán hàng'
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