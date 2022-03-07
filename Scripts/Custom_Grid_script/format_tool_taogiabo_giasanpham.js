//Start
var format_tool_taogiabo_giasanpham = {
    create: function (elem, type, type2) {
        let id_elem = $(elem);

        if (type)
            id_elem.attr('typeVN', type);

        if (type2)
            id_elem.attr('typeVN2', type2);

        let clone = id_elem.clone();
        clone.attr('id', `${id_elem.attr('id')}CP`);
        clone.attr('type', 'hidden');
        clone.insertBefore(id_elem);

        id_elem.css({ 'padding': '2px', 'border': '1px solid #000' });
        id_elem.parent().append(`
            <i onclick="format_tool_taogiabo_giasanpham.search(this)"
            class="span_format_tool_taogiabo_giasanpham fab fa-accusoft" 
            style="position: absolute; margin: 1px 0 0 -23px; background-color: rgb(248, 249, 243); padding: 3px; cursor: pointer;border-left: 1px solid rgba(204, 204, 204, 0.63)"
            />
        `);

        id_elem.keypress(function (e) {
            if (e.which == '13') {
                id_elem.next().click();
            }
        });
    },
    search: function (id_elem) {
        id_elem = $(id_elem).prev();
        let type = id_elem.attr('typeVN');
        let type2 = id_elem.attr('typeVN2');
        let dcghDangChon = $('#' + type).prev().val();
        dcghDangChon = dcghDangChon ? JSON.parse(dcghDangChon) : {};
        dcghDangChon = dcghDangChon.id;

        if (!dcghDangChon) {
            alert('Chưa chọn phiên bản giá cũ');
            return;
        }

        let dcghDangChon2 = $('#' + type2).prev().val();
        dcghDangChon2 = dcghDangChon2 ? JSON.parse(dcghDangChon2) : {};
        dcghDangChon2 = dcghDangChon2.id;

        if (!dcghDangChon2) {
            alert('Chưa chọn phiên bản giá mới');
            return;
        }

        // Grid
        let load_sp = 0;
        $('body').append(`
            <div id="dlg_gridSmal_2"
                style="margin: 4px 0 0 0; background-color: rgba(165, 121, 255, 0.07);"
                title="Sản phẩm trong phiên bảng giá"
            >
                <table id="gridMaster"></table>
                <div id="papergridMaster"></div>
                <table id="gridMaster2"></table>
                <div id="papergridMaster2"></div>
            </div>
        `);

        let gridMaster = $("#gridMaster"), gridMaster2 = $("#gridMaster2");
        
        let where_ex = '';

        let widthDialog = 800;
        $('#dlg_gridSmal_2').dialog({
            modal: true,
            dialogClass: "dialog_index",
            width: widthDialog,
            height: window.innerHeight - 10,
            open: function (event, ui) {
                //Luoi 1
                gridMaster.jqGrid({
                    height: (window.innerHeight - 275) / 2,
                    url: `Controllers/JqGridCustom/format_tool_taogiabo_giasanpham.ashx?pbgId=${dcghDangChon}&searchTemp=${encodeURI(id_elem.val())}`,
                    datatype: 'json',
                    width: widthDialog - 25,
                    shrinkToFit: true,
                    rownumbers: true,
                    viewrecords: true,
                    search: true,
                    scroll: false,
                    scrollrows: true,
                    ignoreCase: true,
                    rowNum: 200,
                    multiselect: false,
                    multiboxonly: false,
                    rowList: [200],
                    pager: '#papergridMaster',
                    jsonReader: {
                        repeatitems: false,
                        id: "md_giasanpham_id"
                    },
                    ondblClickRow: function () {

                    },
                    onSelectRow: function (ids) {

                    },
                    colModel: [
                        //Hide
                        { key: true, fixed: true, label: 'SP Id', name: 'md_giasanpham_id', hidden: true, align: 'left' },
                        { key: true, fixed: true, label: 'PBG Id', name: 'md_phienbangia_id', hidden: true, align: 'left' },
                        //Show
                        { key: false, fixed: true, label: 'Mã sản phẩm', name: 'ma_sanpham', index: 'ma_sanpham', width: 110, editable: false, align: 'center' },
                        { key: false, fixed: true, label: 'Giá', name: 'gia', width: 100, editable: false, align: 'right', formatter: 'currency' },
                        { key: false, fixed: true, label: 'Phí', name: 'phi', width: 100, editable: false, align: 'right', formatter: 'currency' },
                        { key: false, fixed: true, label: 'Tổng giá', name: 'tongGia', width: 120, editable: false, align: 'right', formatter: 'currency' },
                        { key: false, fixed: true, label: 'Mã số khách', name: 'mota', width: 120, editable: false }
                    ],
                    gridComplete: function () {

                    },
                    loadComplete: function (data) {
                        data = data.rows;
                        if (data.length <= 0)
                            alert('Không có dữ liệu');
                        else if (!gridMaster[0].loadedVNN) {
                            gridMaster[0].loadedVNN = 1;
                        }
                    },
                    beforeProcessing: function (data) {

                    },
                    caption: 'Giá sản phẩm của phiên bản giá cũ (theo tìm kiếm)'
                });

                //Luoi 2
                gridMaster2.jqGrid({
                    height: (window.innerHeight - 265) / 2,
                    url: `Controllers/JqGridCustom/format_tool_taogiabo_giasanpham.ashx?pbgId=${dcghDangChon2}&searchTemp=`,
                    datatype: 'json',
                    width: widthDialog - 25,
                    shrinkToFit: true,
                    rownumbers: true,
                    viewrecords: true,
                    search: true,
                    scroll: false,
                    scrollrows: true,
                    ignoreCase: true,
                    rowNum: 200,
                    multiselect: false,
                    multiboxonly: false,
                    rowList: [200],
                    pager: '#papergridMaster2',
                    jsonReader: {
                        repeatitems: false,
                        id: "md_giasanpham_id"
                    },
                    ondblClickRow: function () {

                    },
                    onSelectRow: function (ids) {

                    },
                    colModel: [
                        //Hide
                        { key: true, fixed: true, label: 'SP Id', name: 'md_giasanpham_id', hidden: true, align: 'left' },
                        { key: true, fixed: true, label: 'PBG Id', name: 'md_phienbangia_id', hidden: true, align: 'left' },
                        //Show
                        { key: false, fixed: true, label: 'Mã sản phẩm', name: 'ma_sanpham', width: 110, editable: false, align: 'center' },
                        { key: false, fixed: true, label: 'Giá', name: 'gia', width: 100, editable: false, align: 'right', formatter: 'currency' },
                        { key: false, fixed: true, label: 'Phí', name: 'phi', width: 100, editable: false, align: 'right', formatter: 'currency' },
                        { key: false, fixed: true, label: 'Tổng giá', name: 'tongGia', width: 120, editable: false, align: 'right', formatter: 'currency' },
                        { key: false, fixed: true, label: 'Mã số khách', name: 'mota', width: 120, editable: false }
                    ],
                    gridComplete: function () {

                    },
                    loadComplete: function (data) {
                        data = data.rows;
                        if (data.length <= 0)
                            alert('Không có dữ liệu');
                        else if (!gridMaster2[0].loadedVNN) {
                            gridMaster2[0].loadedVNN = 1;
                        }
                    },
                    beforeProcessing: function (data) {

                    },
                    caption: 'Giá sản phẩm của phiên bản giá mới (Tất cả)'
                });
                gridMaster2.jqGrid('filterToolbar', { searchOnEnter: false, stringResult: true });
            },
            close: function () {
                $(this).dialog('destroy').remove();
                id_elem.focus();
            },
            buttons:
                [{
                    id: 'btn-close_',
                    text: 'Thoát',
                    click: function () {
                        $(this).dialog("destroy").remove();
                        id_elem.focus();
                    }
                }]
        });
    }
};
//End