<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-baocao-chodoitac.aspx.cs" Inherits="inc_baocao_chodoitac" %>

<style type="text/css">
    table.editTableCTL {        
        margin: 20px auto;
        min-width: 480px;
        padding: 10px;
        border: 1px solid #000;
        background-color: #f4f2ef;
    }

    table.editTableCTL td {
        padding: 3px;
    }

    table.editTableCTL .btnPrint {
        padding: 5px;
        font-weight: bold;
        margin-top: 10px;
    }

    table.editTableCTL input.btnClick {
        padding: 1px 5px 1px 5px;
    }

    .clickNextPrevPresent {
        text-align: center;
        padding: 5px;
        background-color: #CCC;
        border: 1px solid #000;
        color: #FFF;
        cursor: pointer;
        font-weight: bold;
        user-select: none;
    }

    .clickNextPrevPresent > span {
        font-size: 156% !important;
        user-select: none;
    }

    .width100percent {
        width: 100%;
    }
</style>

<div style="overflow:auto;">
    <table class="editTableCTL">
        <tr>
            <td colspan="2">
                <b>I. Bước 1</b>
            </td>
        </tr>

        <tr>
            <td>
                <label>Chọn layout hiển thị số lượng "sản phẩm" trên "1 trang"</label>
            </td>
            <td>
                <select class="width100percent" id="layoutHangHoa">
                    <option print="1" value="3">3 sản phẩm trên 1 trang</option>
                    <option print="2" value="4">4 sản phẩm trên 1 trang</option>
                    <option print="2" value="6">6 sản phẩm trên 1 trang</option>
                </select>
            </td>
        </tr>

        <tr>
            <td>
                <label>Chọn layout hiển thị số lượng "color ref" trên "1 trang"</label>
            </td>
            <td>
                <select class="width100percent" id="layoutMauSac">
                    <option value="4">4 màu sắc trên 1 trang</option>
                    <option selected value="6">6 màu sắc trên 1 trang</option>
                </select>
            </td>
        </tr>

        <tr>
            <td>
                <label>Chọn layout hiển thị số lượng "pattern" trên "1 trang"</label>
            </td>
            <td>
                <select class="width100percent" id="layoutDetai">
                    <option value="4">4 đề tài trên 1 trang</option>
                    <option selected value="6">6 đề tài trên 1 trang</option>
                </select>
            </td>
        </tr>

        <tr>
            <td>
                <label>Hướng in tự động theo số lượng "sản phẩm" trên 1 trang</label>
            </td>
            <td>
                <select id="layoutPrint" disabled style="color:#000; font-weight:bold;">
                    <option value="1">In dọc</option>
                    <option value="2">In ngang</option>
                </select>
            </td>
        </tr>

        <tr>
            <td>
                <label>Chọn đơn vị tính</label>
            </td>
            <td>
                <select id="layoutDVT">
                    <option value="1">Cm</option>
                    <option value="2">Inch</option>
                    <option selected value="3">Cả hai đơn vị trên</option>
                </select>
            </td>
        </tr>

        <tr>
            <td colspan="2">
                <b>II. Bước 2</b>
            </td>
        </tr>

        <tr>
            <td>
                <label>Lọc sản phẩm cần báo khách</label>
            </td>
            <td>
                <input id="presentSelectProducts" type="text" placeholder="Chọn sản phẩm"/>
            </td>
        </tr>

        <tr>
            <td>
                <label>Lọc "Color ref" theo hệ hàng</label>
            </td>
            <td>
                <input id="presentSelectColors" type="text" placeholder="Chọn color ref" />
            </td>
        </tr>

        <tr>
            <td>
                <label>Lọc "Pattern" theo hệ hàng</label>
            </td>
            <td>
                <input id="presentSelectPatterns" type="text" placeholder="Chọn pattern" />
            </td>
        </tr>

        <tr>
            <td>
                <label>Chọn loại tập tin cần xuất</label>
            </td>
            <td>
                <select id="layoutFileType">
                    <option value="1">PDF</option>
                    <option value="2">Excel</option>
                </select>
            </td>
        </tr>

        <tr>
             <td colspan="2" style="text-align:center">
                <input class="btnPrint" id="xuatTapTinPresent" type="button" value="Xuất tập tin" />
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">
    format_taocatalog_sanpham.create($('#presentSelectProducts'));

    format_taocatalog_mausac.create($('#presentSelectColors'));

    format_taocatalog_kieudang.create($('#presentSelectPatterns'));

    $('#layoutHangHoa').change(function () {
        let print = $(this).find('option:selected').attr('print');
        $('#layoutPrint').val(print);
    });

    $('#xuatTapTinPresent').click(function () {
        let getZoomValues = function() {
            var zoom = detectZoom.zoom();
            var device = detectZoom.device();
            var newZoomVal = parseFloat(zoom, 10).toFixed(2);
            var newDeviceVal = parseFloat(device, 10).toFixed(2);
            return {
                newZoomVal,
                newDeviceVal
            };
        }

        let addFormData = function (mapForm, name, data) {
            let mapInput = document.createElement("input");
            mapInput.type = "text";
            mapInput.name = name;
            mapInput.value = data;
            mapForm.appendChild(mapInput);
        };

        let width = window.innerWidth > 1024 ? 1024 : window.innerWidth;
        let height = window.innerHeight > 500 ? 500 : window.innerHeight;
        let left = (window.innerWidth - width) / 2;
        let top = (window.innerHeight - height) / 2;

        let checkZ = getZoomValues();
        let zoomVal = checkZ.newZoomVal;
        width = (width - 5) * zoomVal;
        height = height * zoomVal;
        left = left * zoomVal;
        top = top * zoomVal;

        let mapForm = document.createElement("form");
        mapForm.target = "Map";
        mapForm.method = "POST";
        mapForm.action = "PrintControllers/More/rpt_taoCatalogue.aspx";

        addFormData(mapForm, "sps", $('#presentSelectProductsCP').val());
        addFormData(mapForm, "dts", $('#presentSelectPatternsCP').val());
        addFormData(mapForm, "mss", $('#presentSelectColorsCP').val());
        addFormData(mapForm, "kieuIn", $('#layoutFileType').val());
        addFormData(mapForm, "huongIn", $('#layoutPrint').val());
        addFormData(mapForm, "layoutHangHoa", $('#layoutHangHoa').val());
        addFormData(mapForm, "layoutMauSac", $('#layoutMauSac').val());
        addFormData(mapForm, "layoutDetai", $('#layoutDetai').val());
        addFormData(mapForm, "layoutDVT", $('#layoutDVT').val());

        document.body.appendChild(mapForm);

        map = window.open("", "Map", `top=${top}, left=${left}, width=${width}, height=${height}`);
            
        if (map) {
            mapForm.submit();
        } else {
            alert('You must allow popups for this map to work.');
        }

        mapForm.remove();
    });
</script>
