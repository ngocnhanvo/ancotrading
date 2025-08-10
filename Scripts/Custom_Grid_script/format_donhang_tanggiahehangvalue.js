//Start
var format_donhang_tanggiahehangvalue = {
    create: function (elem) {
        setTimeout(function () {
            let id_elem = $(elem);
            let clone = id_elem.clone();
            clone.attr('id', `${id_elem.attr('id')}CP`);
            clone.attr('type', 'hidden');
            clone.insertBefore(id_elem);

            id_elem.css({ 'padding': '2.5px', 'border': '1px solid #000', width: 'calc(100% - 26px)' });
            id_elem.attr('readonly', true);
            id_elem.parent().append(`
                <i onclick="format_donhang_tanggiahehangvalue.search(this)"
                class="span_format_donhang_tanggiahehangvalue fab fa-accusoft" 
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
                title="Tăng giá hệ hàng"
            >
                <table class="tbl_tanggia_hehang_value" style="display: inline;">
                </table>
            </div>
        `);
        
        let widthDialog = 300;
        $('#dlg_gridSmal_2').dialog({
            modal: true,
            dialogClass: "dialog_index",
            width: widthDialog,
            height: window.innerHeight/3 - 10,
            open: function (event, ui) {
                let iddl = id_elem.parent().parent().parent().parent().attr('id').replace('TblGrid_', '');
                iddh = $(`#${iddl}`).jqGrid('getGridParam', 'selrow');
                let tanggia_hehang_value = function (result, type) {
                    let json = JSON.parse(result);
                    let jsonSav = [];
                    if (id_elem.val())
                        jsonSav = JSON.parse(id_elem.val());
                    let table = '';
                    for (let i in json) {
                        let row = json[i];
                        let giatri = jsonSav.filter(function (a) { return a.hehang == row.hehang })[0];
                        giatri = giatri == null ? row.giatri : Number(giatri.giatri);
                        table += `
                            <tr class="tr_tanggiahehang">
                                <td class="hehang" style="color: blue">${row.hehang}</td>
                                <td style="width:20px"></td>
                                <td class="giatri"><input type="number"  value="${giatri}"></td>
                            </tr>`;
                    }
                               
                    $('.tbl_tanggia_hehang_value').html(table);
                };
                $.get("Controllers/SelectOption/ApDungDisCountHeHang.ashx", { action: "TangGiaHH", c_donhang_id: iddh },
                    function (result) {
                        tanggia_hehang_value(result);
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
                        let arr = [];
                        $('.tr_tanggiahehang').each(function () {
                            arr.push({ hehang: $(this).children('.hehang').text(), giatri: Number($(this).children('.giatri').children().val()) });
                        });
                        id_elem.val(JSON.stringify(arr));
                        $(this).dialog("destroy").remove();
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