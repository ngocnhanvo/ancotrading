//Start
var format_taocatalog_mausac = {
    create: function (elem) {
        let id_elem = $(elem);
        let clone = id_elem.clone();
        clone.attr('id', `${id_elem.attr('id')}CP`);
        clone.attr('type', 'hidden');
        clone.insertBefore(id_elem);

        id_elem.css({ 'padding': '2px', 'border': '1px solid #000' });
        id_elem.attr('readonly', true);
        id_elem.parent().append(`
            <i onclick="format_taocatalog_mausac.search(this)"
            class="span_format_taocatalog_mausac fab fa-accusoft" 
            style="position: absolute; margin: 1px 0 0 -23px; background-color: rgb(248, 249, 243); padding: 3px; cursor: pointer;border-left: 1px solid rgba(204, 204, 204, 0.63)"
            />
        `);
    },
    search: function (id_elem, type) {
        // Grid
        let load_sp = 0;
        $('body').append(`
            <div id="dlg_gridSmal_2"
                style="margin: 4px 0 0 0; background-color: rgba(165, 121, 255, 0.07);"
                title="Chọn color ref cần báo khách"
            >
                <table style="width:100%;">
                <tr>
                    <td style="width:45%">
                        <table id="gridMaster"></table>
                        <div id="papergridMaster"></div>
                    </td>
                    <td style="width:10%">
                        <div id="nextProductPresent" class="clickNextPrevPresent">
                            <span>></span>
                        </div>
                        <div style="height:20px; width:20px;"></div>
                        <div id="prevProductPresent" class="clickNextPrevPresent">
                            <span><</span>
                        </div>
                    </td>
                    <td style="width:45%">
                        <table id="gridMasterSel"></table>
                    </td>
                </tr>
                </table>
            </div>
        `);

        id_elem = $(id_elem).prev();
        let gridMaster = $('#gridMaster');
        let gridMasterSel = $('#gridMasterSel');

        let widthDialog = 800;
        $('#dlg_gridSmal_2').dialog({
            modal: true,
            dialogClass: "dialog_index",
            width: widthDialog,
            height: window.innerHeight - 10,
            open: function (event, ui) {
                $('#nextProductPresent').click(function () {
                    let grid2Data = gridMasterSel.getGridParam('data');
                    let grid1SelR = gridMaster.jqGrid('getGridParam', 'selarrrow');
                    let grid1Data = [];
                    for (let i = 0; i < grid1SelR.length; i++) {
                        let row = gridMaster.getRowData(grid1SelR[i]);
                        grid1Data.push(row);
                    }

                    for (let i = 0; i < grid1Data.length; i++) {
                        let row = grid1Data[i];
                        let chkExist = grid2Data.filter(function (a) { return a.md_mausac_id === row.md_mausac_id });
                        if (chkExist.length <= 0)
                            gridMasterSel.jqGrid('addRowData', row.md_mausac_id, row);
                    }

                    gridMasterSel.trigger('reloadGrid');
                });

                $('#prevProductPresent').click(function () {
                    let grid2SelR = gridMasterSel.jqGrid('getGridParam', 'selarrrow');
                    for (let i = grid2SelR.length - 1; i >= 0; i--) {
                        gridMasterSel.jqGrid('delRowData', grid2SelR[i]);
                    }
                });

                //Luoi 1
                gridMaster.jqGrid({
                    height: window.innerHeight - 206,
                    url: `Controllers/JqGridCustom/format_taocatalog_mausac.ashx`,
                    datatype: 'json',
                    mtype: 'POST',
                    autowidth: true,
                    shrinkToFit: true,
                    rownumbers: true,
                    viewrecords: true,
                    scroll: false,
                    rowNum: 500,
                    multiselect: true,
                    multiboxonly: false,
                    rowList: [500],
                    pager: '#papergridMaster',
                    jsonReader: {
                        repeatitems: false,
                        id: "md_mausac_id"
                    },
                    postData: {
                        sps: $('#presentSelectProductsCP').val()
                    },
                    colModel: [
                        {
                            fixed: true, name: 'md_mausac_id'
                            , label: 'md_mausac_id'
                            , index: 'sp.md_mausac_id'
                            , width: 100
                            , hidden: true
                            , editable: true
                            , edittype: 'text'
                            , key: true
                        },
                        {
                            fixed: true, name: 'code_cl'
                            , label: 'C.loại'
                            , index: 'ms.code_cl'
                            , width: 50
                            , edittype: 'text'
                            , editable: true
                            , align: 'center'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'code_dt'
                            , label: 'Đề tài'
                            , index: 'ms.code_dt'
                            , width: 50
                            , edittype: 'text'
                            , editable: true
                            , align: 'center'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'code_mau'
                            , label: 'Màu sắc'
                            , index: 'ms.code_mau'
                            , width: 50
                            , edittype: 'text'
                            , editable: true
                            , align: 'center'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'tv_ngan'
                            , label: 'Tên màu'
                            , index: 'ms.tv_ngan'
                            , width: 100
                            , edittype: 'text'
                            , editable: false
                        },
                        {
                            fixed: true, name: 'ta_ngan'
                            , label: 'Tên màu'
                            , index: 'ms.tv_ngan'
                            , width: 100
                            , edittype: 'textarea'
                            , editable: false
                            , hidden: true
                        }
                    ],
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
                    caption: 'D/S Color Ref'
                });

                gridMaster.jqGrid('filterToolbar', { searchOnEnter: false, stringResult: true });

                //Luoi 2
                gridMasterSel.jqGrid({
                    height: window.innerHeight - 170,
                    datatype: 'local',
                    autowidth: true,
                    shrinkToFit: false,
                    rownumbers: true,
                    viewrecords: true,
                    scroll: false,
                    rowNum: 999999999,
                    multiselect: true,
                    multiboxonly: false,
                    ignoreCase: true,
                    rowList: [999999999],
                    colModel: [
                        {
                            fixed: true, name: 'md_mausac_id'
                            , label: 'md_mausac_id'
                            , index: 'sp.md_mausac_id'
                            , width: 100
                            , hidden: true
                            , editable: true
                            , edittype: 'text'
                            , key: true
                        },
                        {
                            fixed: true, name: 'code_cl'
                            , label: 'C.loại'
                            , index: 'code_cl'
                            , width: 50
                            , edittype: 'text'
                            , editable: true
                            , align: 'center'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'code_dt'
                            , label: 'Đề tài'
                            , index: 'code_dt'
                            , width: 50
                            , edittype: 'text'
                            , editable: true
                            , align: 'center'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'code_mau'
                            , label: 'Màu sắc'
                            , index: 'code_mau'
                            , width: 50
                            , edittype: 'text'
                            , editable: true
                            , align: 'center'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'tv_ngan'
                            , label: 'Tên màu'
                            , index: 'tv_ngan'
                            , width: 100
                            , edittype: 'textarea'
                            , editable: false
                        },
                        {
                            fixed: true, name: 'ta_ngan'
                            , label: 'Tên màu'
                            , index: 'ta_ngan'
                            , width: 100
                            , edittype: 'textarea'
                            , editable: false
                            , hidden: true
                        }
                    ],
                    onSelectRow: function (ids) {

                    },
                    gridComplete: function () {
                        gridMaster[0].loadedVNN = 1;
                    },
                    loadComplete: function (data) {

                    },
                    beforeRequest: function () {

                    },
                    beforeProcessing: function (data) {

                    },
                    caption: ' '
                });

                gridMasterSel.jqGrid('filterToolbar', { searchOnEnter: false, stringResult: true });

                let dataCP = id_elem.prev().val();
                dataCP = dataCP.length > 0 ? JSON.parse(dataCP) : [];

                for (let i = 0; i < dataCP.length; i++) {
                    let row = dataCP[i];
                    gridMasterSel.jqGrid('addRowData', row.md_mausac_id, row);
                }
                gridMasterSel.trigger('reloadGrid');
            },
            close: function () {
                $(this).dialog('destroy').remove();
            },
            buttons:
                [{
                    id: 'btn-ok_',
                    text: 'Đồng ý',
                    click: function () {
                        let dataSel = gridMasterSel.getGridParam('data');
                        if (dataSel.length > 0) {
                            id_elem.val(`Đã chọn ${dataSel.length} màu sắc`);
                            id_elem.prev().val(JSON.stringify(dataSel));
                        }
                        else {
                            id_elem.val('');
                            id_elem.prev().val('');
                        }
                        $('#dlg_gridSmal_2').dialog("destroy").remove();
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