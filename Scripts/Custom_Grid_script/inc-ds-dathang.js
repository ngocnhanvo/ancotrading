function UploadTapTingrid_huongdanlamhang() {
    let data_js = new FormData();
    let $div, $frmGHDLH;
    $div = $(`
            <form  enctype="multipart/form-data" id="frm_File_grid_huongdanlamhang">
                <div class="mess"></div>
                <input type="button" onclick="$(this).next().click();" value="Chọn tập tin" />
                <input type="file" style="display:none" multiple accept=".jpg,.png,.xls,.xlsx,.doc,.docx,.pdf,.ppt" />
            </form>
        `);

    $div.dialog({
        title: `Tải lên "hướng dẫn làm hàng"`,
        resizeable: false,
        modal: true,
        width: 400,
        height: 300,
        open: function (event, ui) {
            $frmGHDLH = $('#frm_File_grid_huongdanlamhang');
            let $fileInput = $frmGHDLH.find('input[type="file"]');
            let $mess = $frmGHDLH.find('.mess');
            let $table;

            $fileInput.change(function () {
                let files = $(this)[0].files;
                let messFile = '';
                for (let i = 0; i < files.length; i++) {
                    let file = files[i];
                    let spanRemove = $(`span.btnVNN[fileN="${file.name}"]`);
                    if (spanRemove.attr('fileN') != null) {
                        spanRemove.click();
                    }

                    messFile += `
                            <tr class="rowFile" style="height: 25px;">
                                <td>${file.name} (${file.size} Byte)</td>
                                <td style="text-align:center"><span class="btnVNN" fileI="${i}" fileN="${file.name}">X</span></td>
                            </tr>`;

                    data_js.append('hinhanh' + i, file);
                }

                $table = $frmGHDLH.find('table');
                if ($table.prop('tagName') == null) {
                    messFile = `
                            <table style="width:100%">
                                <tr style="height: 25px;">
                                    <td style="font-weight:bold">Tên</td>
                                    <td style="font-weight:bold; text-align:center;"><a class="btnVNN">Xóa</a></td>
                                </tr>
                                ${messFile}
                            </table>
                        `;
                    $mess.html(messFile);
                    $table = $frmGHDLH.find('table');
                }
                else {
                    $table.append(messFile);
                }

                $('span.btnVNN').off('click');
                $('span.btnVNN').click(function () {
                    let index = $(this).attr('fileI');
                    $(this).parent().parent().remove();
                    data_js.delete('hinhanh' + index);
                    if ($('tr.rowFile').length <= 0) {
                        $table.remove();
                    }
                });

                $('a.btnVNN').off('click');
                $('a.btnVNN').click(function () {
                    let index = $(this).attr('fileI');
                    $(this).parent().parent().remove();
                    $('span.btnVNN').click();
                });

                $(this).val('');
            });
        },
        close: function (event, ui) {
            $(this).dialog('destroy').remove();
        },
        buttons: [
            {
                text: "Tải lên",
                id: "upload_File_grid_huongdanlamhang",
                click: function () {
                    let $mess = $div.find('.mess');
                    let $btnUpload = $('#upload_File_grid_huongdanlamhang');
                    let id_parent = $('#grid_ds_dathang').jqGrid('getGridParam', 'selrow');
                    data_js.append("id_parent", id_parent);
                    $mess.html('<img style="width:30px; height:30px" src="iconcollection/loading.gif"/>');
                    $btnUpload.prop('disabled', true);
                    $.ajax({
                        url: 'Controllers/DSDH_HuongDanLamHang_Controller.ashx?action=Upload',
                        type: 'POST',
                        data: data_js,
                        processData: false,
                        contentType: false,
                        success: function (data) {
                            $mess.html(data);
                            data_js = new FormData();
                            $btnUpload.prop('disabled', false);

                            if (data.lastIndexOf('error') <= -1) {
                                $('#grid_huongdanlamhang')[0].triggerToolbar();
                                $div.dialog("destroy").remove();
                            }
                        }
                    });
                }
            },
            {
                text: "Đóng",
                click: function () {
                    $(this).dialog("destroy").remove();
                }
            }
        ]
    });
}

$("#grid_huongdanlamhang").jqGrid('navButtonAdd', '#grid_huongdanlamhang-pager',
    {
        caption: "Tải lên HDLH",
        title: `Tải lên "hướng dẫn làm hàng"`,
        onClickButton: function () {
            UploadTapTingrid_huongdanlamhang();
        }
    }
);

$("#grid_huongdanlamhang").jqGrid('navButtonAdd', '#grid_huongdanlamhang-pager',
    {
        caption: "Gửi HDLH",
        title: `Gửi "hướng dẫn làm hàng"`,
        onClickButton: function () {
            let data_js = new FormData();
            let $div, $frmGHDLH;
            let id_parent = $('#grid_ds_dathang').jqGrid('getGridParam', 'selrow');
            let ids = $('#grid_huongdanlamhang').jqGrid('getGridParam', 'selarrrow');
            let txt = ids.length > 1 ? 'những ' : '';
            $div = $(`
                    <form enctype="multipart/form-data" id="frm_Send_grid_huongdanlamhang">
                        <div class="mess">Bạn muốn gửi ${txt}tập tin này đến NCC?</div>
                    </form>
                `);

            $div.dialog({
                title: `Gửi "hướng dẫn làm hàng"`,
                resizeable: false,
                modal: true,
                width: 400,
                height: 300,
                open: function (event, ui) {
                    $frmGHDLH = $('#frm_Send_grid_huongdanlamhang');
                },
                close: function (event, ui) {
                    $(this).dialog('destroy').remove();
                },
                buttons: [
                    {
                        text: "Gửi NCC",
                        id: "send_HDLH_grid_huongdanlamhang",
                        click: function () {
                            let $mess = $div.find('.mess');
                            let $btnSend = $('#send_HDLH_grid_huongdanlamhang');
                            data_js.append("id_parent", id_parent);
                            data_js.append("id", ids.toString());
                            $mess.html('<img style="width:30px; height:30px" src="iconcollection/loading.gif"/>');
                            $btnSend.prop('disabled', true);
                            $.ajax({
                                url: 'Controllers/DSDH_HuongDanLamHang_Controller.ashx?action=Send',
                                type: 'POST',
                                data: data_js,
                                processData: false,
                                contentType: false,
                                success: function (data) {
                                    $mess.html(data);
                                    data_js = new FormData();
                                    $btnSend.prop('disabled', false);

                                    if (data.lastIndexOf('error') <= -1) {
                                        $('#grid_huongdanlamhang')[0].triggerToolbar();
                                        $div.dialog("destroy").remove();
                                    }
                                }
                            });
                        }
                    },
                    {
                        text: "Đóng",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }
);

$("#grid_huongdanlamhang2").jqGrid('navButtonAdd', '#grid_huongdanlamhang2-pager',
    {
        caption: "Gửi ghi chú",
        title: `Gửi ghi chú "hướng dẫn làm hàng"`,
        onClickButton: function () {
            let data_js = new FormData();
            let $div, $frmGHDLH;
            let id_parent = $('#grid_ds_dathang').jqGrid('getGridParam', 'selrow');
            let ids = $('#grid_huongdanlamhang2').jqGrid('getGridParam', 'selarrrow');
            let txt = ids.length > 1 ? 'những ' : '';
            $div = $(`
                    <form enctype="multipart/form-data" id="frm_Send_grid_huongdanlamhang2">
                        <div class="mess">Bạn muốn gửi ${txt}ghi chú này đến NCC?</div>
                        <div>
                            <textarea id="huongdanlamhang2" style="width: 97%;height: 180px;margin-top: 5px;padding: 5px;" multiline="true" readonly>Đang tải...</textarea>
                        </div>
                    </form>
                `);

            $div.dialog({
                title: `Gửi ghi chú "hướng dẫn làm hàng"`,
                resizeable: false,
                modal: true,
                width: 400,
                height: 300,
                open: function (event, ui) {
                    $.post('Controllers/DSDH_HuongDanLamHang2_Controller.ashx?action=loadGhiChu', { id: id_parent }, function (rs) {
                        $('#huongdanlamhang2').val(rs);
                    });
                    $frmGHDLH = $('#frm_Send_grid_huongdanlamhang2');
                },
                close: function (event, ui) {
                    $(this).dialog('destroy').remove();
                },
                buttons: [
                    {
                        text: "Gửi NCC",
                        id: "send_HDLH_grid_huongdanlamhang2",
                        click: function () {
                            let $mess = $div.find('.mess');
                            let $btnSend = $('#send_HDLH_grid_huongdanlamhang2');
                            data_js.append("id_parent", id_parent);
                            data_js.append("hdlh", $('#huongdanlamhang2').val());
                            $mess.html('<img style="width:30px; height:30px" src="iconcollection/loading.gif"/>');
                            $btnSend.prop('disabled', true);
                            $.ajax({
                                url: 'Controllers/DSDH_HuongDanLamHang2_Controller.ashx?action=Send',
                                type: 'POST',
                                data: data_js,
                                processData: false,
                                contentType: false,
                                success: function (data) {
                                    $mess.html(data);
                                    data_js = new FormData();
                                    $btnSend.prop('disabled', false);

                                    if (data.lastIndexOf('error') <= -1) {
                                        $('#grid_huongdanlamhang2')[0].triggerToolbar();
                                        $div.dialog("destroy").remove();
                                    }
                                }
                            });
                        }
                    },
                    {
                        text: "Đóng",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }
);