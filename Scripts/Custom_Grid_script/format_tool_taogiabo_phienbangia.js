//Start
var format_tool_taogiabo_phienbangia = {
    create: function (elem, type) {
        let id_elem = $(elem);

        if (type)
            id_elem.attr('typeVN', type);

        let clone = id_elem.clone();
        clone.attr('id', `${id_elem.attr('id')}CP`);
        clone.attr('type', 'hidden');
        clone.insertBefore(id_elem);

        id_elem.css({ 'padding': '2px', 'border': '1px solid #000' });
        id_elem.attr('readonly', true);
        id_elem.parent().append(`
            <i onclick="format_tool_taogiabo_phienbangia.search(this)"
            class="span_format_tool_taogiabo_phienbangia fab fa-accusoft" 
            style="position: absolute; margin: 1px 0 0 -23px; background-color: rgb(248, 249, 243); padding: 3px; cursor: pointer;border-left: 1px solid rgba(204, 204, 204, 0.63)"
            />
        `);
    },
    search: function (id_elem) {
        id_elem = $(id_elem).prev();
        let type = id_elem.attr('typeVN');
        let hasType = type !== undefined;
        let dcghDangChon = id_elem.prev().val();
        if (hasType)
            dcghDangChon = $('#' + type).prev().val();
        dcghDangChon = dcghDangChon ? JSON.parse(dcghDangChon) : {};
        dcghDangChon = dcghDangChon.idpr;

        if (hasType & !dcghDangChon) {
            alert('Chưa chọn phiên bản giá cũ');
            return;
        }
        // Grid
        let load_sp = 0;
        $('body').append(`
            <div id="dlg_gridSmal_2"
                style="margin: 4px 0 0 0; background-color: rgba(165, 121, 255, 0.07);"
                title="Chọn phiên bản giá"
            >
                <div>
                    <span id="btnXoaVal" style="position: ABSOLUTE;z-index: 9999;color: blue;margin-top: 7px;margin-left: 8px;text-decoration: underline;font-size: 110%;user-select: none;cursor: pointer;">Xóa phiếu đang chọn</span>
                </div>
                <table id="gridMaster"></table>

                <table id="gridDetail"></table>
                <div id="papergridDetail"></div>
            </div>
        `);

        let gridMaster = $("#gridMaster"), gridDetail = $("#gridDetail");

        let btnXoaVal = $('#btnXoaVal');

        let where_ex = '';

        let selectValueInForm = function () {

            let idSel = gridDetail.jqGrid('getGridParam', 'selrow');
            let cell = gridDetail.getRowData(idSel);

            id_elem.val(cell['ten_phienbangia']).change();

            let jsonVal = { id: idSel, idpr: cell['md_banggia_id'] };
            id_elem.prev().val(JSON.stringify(jsonVal));

            $('#dlg_gridSmal_2').dialog('destroy').remove();
        };

        let widthDialog = 800;
        $('#dlg_gridSmal_2').dialog({
            modal: true,
            dialogClass: "dialog_index",
            width: widthDialog,
            height: window.innerHeight - 10,
            open: function (event, ui) {
                btnXoaVal.off('click');
                btnXoaVal.click(function () {
                    $('#phienBangGiaID').val('');
                    $('#phienBangGiaID2').val('');
                    $('#dlg_gridSmal_2').dialog('destroy').remove();
                });

                //Luoi 1
                gridMaster.jqGrid({
                    height: window.innerHeight / 2 - 120,
                    url: `Controllers/JqGridCustom/format_tool_taogiabo_phienbangia.ashx?hasType=${hasType}`,
                    datatype: 'json',
                    width: widthDialog - 20,
                    autowidth: true,
                    shrinkToFit: true,
                    rownumbers: true,
                    viewrecords: true,
                    search: true,
                    scroll: false,
                    scrollrows: true,
                    ignoreCase: true,
                    loadonce: true,
                    rowNum: 100000,
                    multiselect: false,
                    multiboxonly: false,
                    rowList: [100000],
                    jsonReader: {
                        repeatitems: false,
                        id: "md_banggia_id"
                    },
                    ondblClickRow: function () {

                    },
                    onSelectRow: function (ids) {
                        let cell = gridMaster.getRowData(ids);

                        let jsonDH = JSON.parse(cell['dongHang'] + '');
                        
                        gridDetail.jqGrid('clearGridData');

                        for (let i = 0; i < jsonDH.length; i++) {
                            let row = jsonDH[i];
                            gridDetail.jqGrid('addRowData', row.id, row);
                        }
                    },
                    colModel: [
                        //Hide
                        { key: true, fixed: true, label: 'Bảng Giá Id', name: 'md_banggia_id', index: 'md_banggia_id', hidden: true, align: 'left' },
                        { key: false, fixed: true, label: 'Dòng', name: 'dongHang', index: 'dongHang', hidden: true },
                        //Show
                        { key: false, fixed: true, label: 'Tên bảng giá', name: 'ten_banggia', index: 'ten_banggia', width: 220, editable: false },
                        { key: false, fixed: true, label: 'Đồng tiền', name: 'dongtien', index: 'dongtien', width: 90, editable: false, align: 'center' },
                        { key: false, fixed: true, label: 'Bảng giá bán', name: 'banggiaban', index: 'banggiaban', width: 90, editable: false, align: 'center', formatter: 'checkbox' },
                        { key: false, fixed: true, label: 'Mô tả', name: 'mota', index: 'mota', width: 120, editable: false }
                    ],
                    gridComplete: function () {

                    },
                    loadComplete: function (data) {
                        data = data.rows;
                        if (data.length <= 0)
                            alert('Không có dữ liệu');
                        else if (!gridMaster[0].loadedVNN) {
                            let rows = data.filter(function (a) {
                                return a.md_banggia_id === dcghDangChon;
                            });

                            if (rows.length > 0) {
                                let row = rows[0];
                                gridMaster.jqGrid('setSelection', row.md_banggia_id, true);
                            }

                            if (hasType) {
                                let rowDels = data.filter(function (a) {
                                    return a.md_banggia_id !== dcghDangChon;
                                });

                                for (let i in rowDels)
                                    gridMaster.jqGrid('delRowData', rowDels[i].md_banggia_id);
                            }

                            gridMaster[0].loadedVNN = 1;
                        }
                    },
                    beforeProcessing: function (data) {
                        gridMaster.jqGrid('filterToolbar', { searchOnEnter: false, stringResult: true });
                    },
                    caption: '*'
                });

                //Luoi 2
                gridDetail.jqGrid({
                    height: window.innerHeight / 2 - 120,
                    datatype: 'local',
                    width: widthDialog - 20,
                    autowidth: true,
                    shrinkToFit: true,
                    rownumbers: true,
                    viewrecords: true,
                    search: true,
                    scroll: false,
                    rowNum: 100000,
                    multiselect: false,
                    multiboxonly: false,
                    rowList: [100000],
                    colModel: [
                        //Hide
                        { key: true, fixed: true, label: 'PBG Id', name: 'id', width: 0, editable: false, hidden: true },
                        { key: false, fixed: true, label: 'BG Id', name: 'md_banggia_id', width: 0, editable: false, hidden: true },
                        //Show
                        { key: false, fixed: true, label: 'Phiên bản giá', name: 'ten_phienbangia', index: 'ten_phienbangia', width: 220, editable: false, align: 'left' },
                        { key: false, fixed: true, label: 'Ngày hiệu lực', name: 'ngay_hieuluc', index: 'ngay_hieuluc', width: 100, editable: false, align: 'center' },
                        { key: false, fixed: true, label: 'Hoạt động', name: 'hoatdong', index: 'hoatdong', width: 90, editable: false, align: 'center', formatter: 'checkbox' }
                    ],
                    ondblClickRow: function () {
                        selectValueInForm();
                    },
                    onSelectRow: function (ids) {
                        
                    },
                    gridComplete: function () {
                        
                    },
                    loadComplete: function (data) {

                    },
                    beforeProcessing: function (data) {

                    },
                    caption: '*'
                });
            },
            close: function () {
                $(this).dialog('destroy').remove();
            },
            buttons:
                [{
                    id: 'btn-ok_',
                    text: 'Đồng ý',
                    click: function () {
                        selectValueInForm();
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