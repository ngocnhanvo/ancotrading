//Start
var format_donhang_phienbangiadacbiet = {
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
                <i onclick="format_donhang_phienbangiadacbiet.search(this)"
                class="span_format_donhang_phienbangiadacbiet fab fa-accusoft" 
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
                title="Chọn color ref cần báo khách"
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
            id_elem.val(cell.ten_phienbangia);
            id_elemCP.val(cell.md_phienbangia_id);
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
                    height: window.innerHeight - 206,
                    url: `Controllers/SelectOption/PhienBanGiaCu.ashx?action=PhienBanGiaDB`,
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
                        madtkd: $("#md_doitackinhdoanh_id option:selected").text(),
                        ngaytg: $('#ngaylap').val()
                    },
                    colModel: [
                        {
                            fixed: true, name: 'md_phienbangia_id'
                            , index: 'pbg.md_phienbangia_id'
                            , width: 100
                            , hidden: true
                            , editable: true
                            , edittype: 'text'
                            , key: true
                        },
                        {
                            fixed: true, name: 'md_trangthai_id'
                            , index: 'pbg.md_trangthai_id'
                            , editable: false
                            , width: 50
                            , edittype: 'text'
                            , sortable: false
                            , align: 'center'
                            , formatter: 'imagestatus'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'ten_phienbangia'
                            , label: 'Tên Phiên Bản'
                            , index: 'pbg.ten_phienbangia'
                            , editable: true
                            , width: 250
                            , edittype: 'text'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'md_banggia_id'
                            , index: 'bg.md_banggia_id'
                            , width: 100
                            , edittype: 'text'
                            , editrules: { required: true }
                            , editable: true
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'ngay_hieuluc'
                            , label: 'Ngày Hiệu Lực'
                            , index: 'pbg.ngay_hieuluc'
                            , width: 100
                            , editable: true
                            , edittype: 'text'
                            , align: 'center'
                            , editrules: { required: true }
                        },
                        {
                            fixed: true, name: 'ngaytao'
                            , index: 'pbg.ngaytao'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'nguoitao'
                            , index: 'pbg.nguoitao'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'ngaycapnhat'
                            , index: 'pbg.ngaycapnhat'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'nguoicapnhat'
                            , index: 'pbg.nguoicapnhat'
                            , width: 100
                            , editable: false
                            , edittype: 'text'
                            , hidden: true
                        },
                        {
                            fixed: true, name: 'mota'
                            , label: 'Mô tả'
                            , index: 'pbg.mota'
                            , width: 120
                            , editable: true
                            , edittype: 'textarea'
                        },
                        {
                            fixed: true, name: 'hoatdong', hidden: false
                            , label: 'Hoạt Động'
                            , index: 'pbg.hoatdong'
                            , width: 80
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
                    caption: 'Phiên bản giá đặc biệt'
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