$("#grid_ds_banve_thietke").jqGrid('navButtonAdd', '#grid_ds_banve_thietke-pager',
    {
        caption: "Upload File con",
        title: `Upload File COn`,
        id: "updateBtn", // Đặt tên id cho nút

    }
);


//function downloadFile() {
//    // Lấy ID của bản vẽ được chọn
//    var xkId = $('#grid_ds_sanphamtaptin').jqGrid('getGridParam', 'selrow');
//    if (!xkId) {
//        alert("Bạn chưa chọn bản vẽ.");
//        return;
//    }

//    // AJAX để lấy file từ bảng md_BanVe và md_BanVeCon
//    $.ajax({
//        url: 'Controllers/BanVesController.ashx?action=taicacfiledownload', // Đường dẫn tới file ashx
//        type: 'GET',
//        data: { banveId: xkId }, // Gửi ID của bản vẽ hiện tại
//        dataType: 'json',
//        success: function (response) {
//            if (response.success) {
//                // Danh sách các file để tải về
//                var files = [
//                    response.FileBanVeConMot,
//                    response.FileBanVeConHai,
//                    response.FileBanVeConBa,
//                    response.FileBanVeConBon
//                ];

//                var fileCodes = [
//                    response.FileBanVeConMotCode,
//                    response.FileBanVeConHaiCode,
//                    response.FileBanVeConBaCode,
//                    response.FileBanVeConBonCode
//                ];

//                // Hiển thị popup với các file download
//                showDownloadPopup(response.FileBanVe, response.TenBanVe_TiengViet, files, fileCodes);
//            } else {
//                alert(response.message || "Lỗi khi lấy dữ liệu file.");
//            }
//        },
//        error: function (xhr, status, error) {
//            alert("Lỗi khi lấy dữ liệu file: " + error);
//        }
//    });
//}

//function showDownloadPopup(fileBanVe, tenBanVe, files, fileCodes) {
//    var name = 'dialog-download-files';
//    var title = 'Chọn file để tải xuống';

//    // Xây dựng nội dung popup
//    var content = `<div title="${title}" id="${name}">
//        <p>Bạn muốn tải các file nào?</p>
//        <ul>`;

//    // Thêm file chính từ md_BanVe
//    if (fileBanVe) {
//        content += `<li style='margin:7px;'><a href="FileUpload/${fileBanVe}" target="_blank">Tải File Chính: ${tenBanVe}</a></li>`;
//    }

//    // Thêm các file bổ sung từ md_BanVeCon
//    files.forEach(function (file, index) {
//        if (file && fileCodes[index]) {
//            content += `<li style='margin:7px;'><a href="FileUpload/${fileCodes[index]}" target="_blank">Tải File 0${index + 1}: ${file}</a></li>`;
//        }
//    });

//    content += `</ul></div>`;

//    // Thêm popup vào DOM và hiển thị
//    $('body').append(content);

//    $('#' + name).dialog({
//        modal: true,
//        open: function (event, ui) {
//            $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
//        },
//        buttons: [
//            {
//                id: "btn-close",
//                text: "Đóng",
//                click: function () {
//                    $(this).dialog("destroy").remove();
//                }
//            }
//        ]
//    });
//}




createRightPanel('grid_ds_banve_thietke');
if (themBanVe) {
    $("#grid_ds_banve_thietke").jqGrid('navButtonAdd', '#grid_ds_banve_thietke-pager',
        {
            caption: "Tải lên",
            title: `Tải lên "tập tin"`,
            onClickButton: function () {
                //add_tab('THÊM BẢN VẼ', 'inc-banvedemo.aspx');
                let name = 'dialog-print-tlttbanVe';
                let title = 'Tải lên "tập tin';
                $('body').append(`
                <div title="${title}" id="${name}">
                    <h5>UPLOAD FILE BẢN VẼ VÀ FILE ĐÓNG GÓI</h5>
                    <br />
                    <form id="uploadForm" enctype="multipart/form-data">

                        <label for="ma_sanphamBanVe" class="form-label">Nhập ID Sản Phẩm:</label>
                        <input type="text" id="ma_sanphamBanVe" class="form-control"><br>
                        <br>
                        <label for="IDLoaiBanVe" class="form-label">Chọn Loại Bản Vẽ</label>
                        <select id="IDLoaiBanVe" class="form-select">
                            <option value="">đang tải...</option>
                        </select>
                        <br/><br />
                        <label for="FileBanVe" class="form-label">Chọn File Bản Vẽ (image, pdf):</label>
                        <br/><br />
                        <input type="file" id="FileBanVe" name="FileBanVe" accept=".png,.jpg,.pdf" class="form-control"><br>
                        <br/>
                        <label for="mota" class="form-label">Ghi Chú:</label>
                        <textarea id="txtMoTa" name="txtMoTa" rows="4" cols="38"/>
                        <br>
                        <input type="hidden" id="IDBanVe" name="IDBanVe" value="">
                    </form>
                </div>`);

                $('#' + name).dialog({
                    modal: true
                    , open: function (event, ui) {
                        $('#ma_sanphamBanVe').combogrid({
                            searchIcon: true,
                            width: '480px',
                            url: 'Controllers/ProductController.ashx?action=getcombogrid&soanthao=1',
                            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden: true }
                                , { 'columnName': 'ma_sanpham', 'width': '33', 'label': 'Mã SP', 'align': 'left' }
                                , { 'columnName': 'ma_sanphamNexxDecor', 'width': '33', 'label': 'Mã SP NexxDecor', 'align': 'left' }
                                , { 'columnName': 'mota_tiengviet', 'width': '34', 'label': 'Mô Tả TV', 'align': 'left' }],
                            select: function (event, ui) {
                                $('#ma_sanphamBanVe').val(ui.item.ma_sanpham);
                                return false;
                            }
                        });

                        $.get(`Controllers/BanVesController.ashx?action=getoptionLBV`, function (rs) {
                            rs = JSON.parse(rs);
                            $('#IDLoaiBanVe').html('');
                            for (let i in rs) {
                                $('#IDLoaiBanVe').append(`<option value="${rs[i].IDLoaiBanVe}">${rs[i].TenLoaiBanVe}</option>`);
                            }
                        });
                        //hide close button.
                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    }
                    , buttons: [
                        {
                            id: "btn-print-ok",
                            text: "Có",
                            click: function () {

                                let formData = new FormData();

                                formData.append("FileBanVe", $("#FileBanVe")[0].files[0]);
                                formData.append("IDLoaiBanVe", $("#IDLoaiBanVe").val());
                                formData.append("ma_sanpham", $("#ma_sanphamBanVe").val());
                                formData.append("mota", $("#txtMoTa").val());
                                let maSanPham = $("#ma_sanphamBanVe").val();
                                // Kiểm tra nếu mã sản phẩm rỗng
                                if (!maSanPham) {
                                    alert("Vui lòng chọn mã sản phẩm");
                                    return;
                                }
                                let fileInput = $("#FileBanVe")[0].files[0];
                                if (!fileInput) {
                                    alert("Vui lòng chọn file Upload");
                                    return;
                                }
                                $.ajax({

                                    url: 'Controllers/BanVeDemoController.ashx',  // Trang xử lý upload file
                                    type: 'POST',
                                    data: formData,
                                    contentType: false,
                                    processData: false,
                                    success: function (response) {
                                        let result = JSON.parse(response);
                                        if (result.status === 0) {
                                            alert(result.message);
                                        }
                                        else {
                                            alert("Upload successful");
                                            $('#grid_ds_banve_thietke')[0].triggerToolbar();
                                            setTimeout(function () { $('#grid_ds_banve_thietke').setSelection(response, false); }, 5000);

                                            $(`#${name}`).dialog("destroy").remove();
                                            //$('#grid_ds_banve_thietke').trigger('reloadGrid');
                                        }
                                    },
                                    error: function () {
                                        alert("File upload failed!");
                                    }
                                });
                            }
                        }
                        , {
                            id: "btn-print-close",
                            text: "Không",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
                });
            }
        }
    );
}



if (xacnhanBanVe) {
    $("#grid_ds_banve_thietke").jqGrid('navButtonAdd', '#grid_ds_banve_thietke-pager',
        {
            caption: "Xác nhận ",
            title: `Xác nhận kiểm hàng"`,
            onClickButton: function () {
                var xkId = $('#grid_ds_banve_thietke').jqGrid('getGridParam', 'selrow');
                var name = 'dialog-print-nk';
                var title = 'Trích xuất dữ liệu';
                if (!xkId) {
                    alert("Bạn chưa chọn bản vẽ");
                    return;
                }
                $('body').append(`
                <div title="${title}" id="${name}">
                    Bạn muốn xác nhận bản vẽ này?
                </div>`);

                $('#' + name).dialog({
                    modal: true
                    , open: function (event, ui) {
                        //hide close button.
                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    }
                    , buttons: [
                        {
                            id: "btn-print-ok",
                            text: "Có",
                            click: function () {
                                $.post(`Controllers/BanvesController.ashx`, { action: 'xacnhan', id: xkId }, function (response) {
                                    $('#grid_ds_banve_thietke').trigger('reloadGrid');
                                    alert(response);
                                    $(this).dialog("destroy").remove();
                                });
                                $(this).dialog("destroy").remove();
                            }
                        }
                        , {
                            id: "btn-print-close",
                            text: "Không",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
                });
            }
        }
    );
}


if (hieulucBanVe) {
    $("#grid_ds_banve_thietke").jqGrid('navButtonAdd', '#grid_ds_banve_thietke-pager',
        {
            caption: "Hiệu Lực",
            title: `"Hiệu Lực"`,
            onClickButton: function () {
                var xkId = $('#grid_ds_banve_thietke').jqGrid('getGridParam', 'selrow');
                var name = 'dialog-print-nk';
                var title = 'Trích xuất dữ liệu';
                if (!xkId) {
                    alert("Bạn chưa chọn bản vẽ");
                    return;
                }

                $('body').append(`
                <div title="${title}" id="${name}">
                    Bạn muốn xác nhận bản vẽ này?
                </div>`);

                $('#' + name).dialog({
                    modal: true
                    , open: function (event, ui) {
                        //hide close button.
                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    }
                    , buttons: [
                        {
                            id: "btn-print-ok",
                            text: "Có",
                            click: function () {
                                $.post(`Controllers/BanvesController.ashx`, { action: 'hieuluc', id: xkId }, function (response) {
                                    $('#grid_ds_banve_thietke').trigger('reloadGrid');
                                    alert(response);// hiển thị thông báo từ Server
                                    $(this).dialog("destroy").remove();
                                });
                                $(this).dialog("destroy").remove();
                            }
                        }
                        , {
                            id: "btn-print-close",
                            text: "Không",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
                });
            }
        }
    );
}
// Admin Download
//if (downloadBanVe) {
//    $("#grid_ds_banve_thietke").jqGrid('navButtonAdd', '#grid_ds_banve_thietke-pager', {
//        caption: "Tải Về",
//        title: "Tải Về",
//        onClickButton: function () {
//            var xkId = $('#grid_ds_banve_thietke').jqGrid('getGridParam', 'selrow');
//            if (!xkId) {
//                alert("Bạn chưa chọn bản vẽ");
//                return;
//            }


//            var rowData = $('#grid_ds_banve_thietke').jqGrid('getRowData', xkId);
//            var trangthai = rowData.trangthai;
//            var fileanh = rowData.FileBanVe;


//            $.ajax({
//                url: 'Controllers/UsersessionContrller.ashx', 
//                type: 'GET',
//                dataType: 'json',
//                success: function (response) {

//                    var manv = response.manv;
//                    downloadFile(fileanh);



//                },
//                error: function (xhr, status, error) {
//                    alert("Lỗi khi lấy mã nhân viên: " + error);
//                }
//            });


//            function downloadFile(fileanh) {

//                var name = 'dialog-print-nk';
//                var title = 'Trích xuất dữ liệu';
//                $('body').append(`
//                    <div title="${title}" id="${name}">
//                        Bạn muốn download bản vẽ này?
//                    </div>`);

//                $('#' + name).dialog({
//                    modal: true,
//                    open: function (event, ui) {
//                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
//                    },
//                    buttons: [
//                        {
//                            id: "btn-print-ok",
//                            text: "Có download",
//                            click: function () {


//                                window.open(`FileUpload/${fileanh}`, '_blank');
//                                $(this).dialog("destroy").remove();
//                            }
//                        },
//                        {
//                            id: "btn-print-close",
//                            text: "Không",
//                            click: function () {
//                                $(this).dialog("destroy").remove();
//                            }
//                        }
//                    ]
//                });
//            }
//        }
//    });
//}


 /*Download Bản vẽ Mẹ và Bản vẽ con*/
if (downloadBanVe) {
    $("#grid_ds_banve_thietke").jqGrid('navButtonAdd', '#grid_ds_banve_thietke-pager', {
        caption: "Tải Về",
        title: "Tải Về",
        onClickButton: function () {
            var xkId = $('#grid_ds_banve_thietke').jqGrid('getGridParam', 'selrow');
            if (!xkId) {
                alert("Bạn chưa chọn bản vẽ");
                return;
            }

            // Lấy dữ liệu của bản ghi được chọn
            var rowData = $('#grid_ds_banve_thietke').jqGrid('getRowData', xkId);
            var fileanh = rowData.FileBanVe;

            // AJAX để lấy file từ bảng md_BanveCon
            $.ajax({
                url: 'Controllers/BanVesController.ashx?action=taicacfiledownload', // Đường dẫn tới file ashx để lấy file
                type: 'GET',
                data: { banveId: xkId }, // Gửi ID của bản vẽ hiện tại
                dataType: 'json',
                success: function (response) {
                    if (response.success) {
                        var files = [
                            response.FileBanVeConMot,
                            response.FileBanVeConHai,
                            response.FileBanVeConBa,
                            response.FileBanVeConBon
                        ];

                        var fileCodes = [
                            response.FileBanVeConMotCode,
                            response.FileBanVeConHaiCode,
                            response.FileBanVeConBaCode,
                            response.FileBanVeConBonCode
                        ];

                        showDownloadPopup(response.FileBanVe, response.TenBanVe_TiengViet, files, fileCodes);
                    } else {
                        alert(response.message || "Lỗi khi lấy dữ liệu file.");
                    }
                },
                error: function (xhr, status, error) {
                    alert("Lỗi khi lấy dữ liệu file: " + error);
                }
            });

            // Hàm hiển thị popup với các file download
            function showDownloadPopup(fileBanVe, tenBanVe, files, fileCodes) {
                var name = 'dialog-download-files';
                var title = 'Chọn file để tải xuống';

                // Xây dựng nội dung popup
                var content = `<div title="${title}" id="${name}">
                    <p>Bạn muốn tải các file nào?</p>
                    <ul>`;

                // Thêm file chính từ md_BanVe
                if (fileBanVe) {
                    content += `<li style='margin:7px;'><a href="FileUpload/${fileBanVe}" target="_blank">Tải File Chính: ${tenBanVe}</a></li>`;
                }

                // Thêm các file bổ sung từ md_BanveCon nếu có

                files.forEach(function (file, index) {
                    if (file && fileCodes[index]) {
                        content += `<li  style='margin:7px;'><a href="FileUpload/${fileCodes[index]}" target="_blank">Tải File 0${index + 1}: ${file}</a></li>`;
                    }
                });

                //content += `<li><a href="/FileUpload/${fileCodes.FileBanVeConMotCode}" target="_blank">Tải File 01: ${files.FileBanVeConMot}</a></li>
                //<li><a href="/FileUpload/${fileCodes.FileBanVeConHaiCode}" target="_blank">Tải File 02: ${files.FileBanVeConHai}</a></li>
                //<li><a href="/FileUpload/${fileCodes.FileBanVeConBaCode}" target="_blank">Tải File 03: ${files.FileBanVeConBa}</a></li>
                //<li><a href="/FileUpload/${fileCodes.FileBanVeConBonCode}" target="_blank">Tải File 04: ${files.FileBanVeConBon}</a></li>
                //`;



                content += `</ul></div>`;

                // Thêm popup vào DOM và hiển thị
                $('body').append(content);

                $('#' + name).dialog({
                    modal: true,
                    open: function (event, ui) {
                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    },
                    buttons: [
                        {
                            id: "btn-close",
                            text: "Đóng",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
                });
            }
        }
    });
}

/*Download Bản vẽ Mẹ được check chọn*/
if (downloadBanVe) {
    $("#grid_ds_banve_thietke").jqGrid('navButtonAdd', '#grid_ds_banve_thietke-pager', {
        caption: "Tải Bản Vẽ đã chọn",
        title: "Tải Bản Vẽ đã chọn",
        onClickButton: function () {
            var selectedIds = $('#grid_ds_banve_thietke').jqGrid('getGridParam', 'selarrrow');
            if (selectedIds.length === 0) {
                alert('Vui lòng chọn ít nhất một bản vẽ.');
                return;
            }

            // Tạo một mảng để chứa các file cần tải về
            var filesToDownload = [];

            // Duyệt qua từng ID được chọn
            $.each(selectedIds, function (index, rowId) {
                var tenBanVe = $('#grid_ds_banve_thietke').jqGrid('getCell', rowId, 'TenBanVe_TiengViet');
                var fileBanVe = $('#grid_ds_banve_thietke').jqGrid('getCell', rowId, 'FileBanVe');

                // Thêm tên bản vẽ và file vào mảng
                if (fileBanVe) { // Kiểm tra fileBanVe có tồn tại hay không
                    filesToDownload.push({
                        tenBanVe: tenBanVe,
                        fileBanVe: fileBanVe
                    });
                }
            });

            // Kiểm tra nếu không có file nào để tải về
            if (filesToDownload.length === 0) {
                alert('Không có file nào để tải về.');
                return;
            }

            // Tạo một blob và tải về
            downloadFiles(filesToDownload);
        }
    });

    function downloadFiles(files) {
        // Duyệt qua từng file để tải về
        $.each(files, function (index, file) {
            var link = document.createElement('a');
            link.href = 'FileUpload/' + file.fileBanVe; // Thay đổi đường dẫn nếu cần
            link.download = file.tenBanVe; // Thay đổi định dạng file nếu cần
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
    }
}