<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TinhGiaBoTheoPhanTram.aspx.cs" Inherits="Tool_TinhGiaBoTheoPhanTram" %>
<% if(!send) { %>
<style type="text/css">
    table.editTableCTLTBTPT {
        margin: 20px auto;
        min-width: 400px;
        padding: 10px;
        border: 1px solid #000;
        background-color: #fff;
    }

    input.txtTBTPT {
        width: 96%;
    }

    h1.titleTBTPT {
        width:100%;
        text-align:center;
        font-size: 160%;
    }

    .spaceTrTBTPT {
        height: 10px;
    }

    .btnPrintTBTPT {
        padding: 5px;
        font-weight: bold;
    }
</style>
<div id="formTBTPT" class="frmMauIn">
    
    <table class="editTableCTLTBTPT">
        <tr>
            <td colspan="3">
                <h1 class="titleTBTPT">Tính giá bộ theo phần trăm</h1>
            </td>
        </tr>

        <tr><td colspan="3"><div class="spaceTrTBTPT"></div></td></tr>

         <tr>
            <td>
                <label>Chọn phiên bản giá cũ: </label>
            </td>

             <td><div class="spaceTrTBTPT"></div></td>
             
             <td>
                <input id="pbgCuTBTPT" class="txtTBTPT" type="text"/>
            </td>
        </tr>
        
        <tr><td colspan="3"><div class="spaceTrTBTPT"></div></td></tr>

        <tr>
            <td>
                <label>Chọn phiên bản giá mới: </label>
            </td>

             <td><div class="spaceTrTBTPT"></div></td>
             
             <td>
                <input id="pbgMoiTBTPT" type="text" class="txtTBTPT"/>
            </td>
        </tr>
        
        <tr><td colspan="3"><div class="spaceTrTBTPT"></div></td></tr>

        <tr>
            <td>
                <label>Tìm kiếm hàng hóa: </label>
            </td>
            <td><div class="spaceTrTBTPT"></div></td>
            <td>
                <input id="hangHoaTBTPT" type="text" class="txtTBTPT"/>
            </td>
        </tr>

        <tr><td colspan="3"><div class="spaceTrTBTPT"></div></td></tr>

        <tr>
            <td>
                <label>Phần trăm (%): </label>
            </td>
            <td><div class="spaceTrTBTPT"></div></td>
            <td>
                <input id="phanTramTBTPT" type="number" class="txtTBTPT"/>
            </td>
        </tr>

        <tr><td colspan="3"><div class="spaceTrTBTPT"></div></td></tr>

       <tr>
            <td style="text-align:center" colspan="3">
                <input class="btnPrintTBTPT" type="button" value="Ghép giá" id="ghepGiaTBTPT" />
            </td>
        </tr>

    </table>

    <script type="text/javascript">
        let pbgCuTBTPT = $('#pbgCuTBTPT'), pbgMoiTBTPT = $('#pbgMoiTBTPT'), hangHoaTBTPT = $('#hangHoaTBTPT'), phanTramTBTPT = $('#phanTramTBTPT');

        format_tool_taogiabo_phienbangia.create(pbgCuTBTPT);
        format_tool_taogiabo_phienbangia.create(pbgMoiTBTPT, pbgCuTBTPT.attr('id'));
        format_tool_taogiabo_giasanpham.create(hangHoaTBTPT, pbgCuTBTPT.attr('id'), pbgMoiTBTPT.attr('id'));

        phanTramTBTPT.css({ 'padding': '2px', 'border': '1px solid #000' });

        pbgCuTBTPT.change(function () {
            pbgMoiTBTPT.val('');
            pbgMoiTBTPT.prev().val('');
        });

        document.getElementById('ghepGiaTBTPT').onclick = function () {
            
            let pbgCuTBTPTVal = pbgCuTBTPT.val();
            let pbgMoiTBTPTVal = pbgMoiTBTPT.val();
            let phanTramTBTPTVal = phanTramTBTPT.val();
            let hangHoaTBTPTVal = hangHoaTBTPT.val();

            if (!pbgCuTBTPTVal) {
                alert('Phải chọn phiên bản giá cũ');
                return;
            }

            if (!pbgMoiTBTPTVal) {
                alert('Phải chọn phiên bản giá mới');
                return;
            }

            if (!hangHoaTBTPTVal) {
                alert('Phải điền tìm kiếm');
                return;
            }

            if (!phanTramTBTPTVal) {
                alert('Phải điền phần trăm');
                return;
            }

            if (confirm('Thực hiện ghép giá???'))
            {
                $('#ghepGiaTBTPT').prop('disabled', true);

                const XHR = new XMLHttpRequest();

                let urlEncodedData = "",
                    urlEncodedDataPairs = [],
                    name;

                // Turn the data object into an array of URL-encoded key/value pairs.
                let data = {
                    "pbgcu": pbgCuTBTPTVal,
                    "pbgmoi": pbgMoiTBTPTVal,
                    "search": hangHoaTBTPTVal,
                    "phantram": phanTramTBTPTVal,
                    "send": "true"
                };

                for (name in data) {
                    urlEncodedDataPairs.push(encodeURIComponent(name) + '=' + encodeURIComponent(data[name]));
                }

                // Combine the pairs into a single string and replace all %-encoded spaces to 
                // the '+' character; matches the behaviour of browser form submissions.
                urlEncodedData = urlEncodedDataPairs.join('&').replace(/%20/g, '+');

                // Define what happens on successful data submission
                XHR.addEventListener('load', function (event) {
                    alert('Ghép giá thành công');
                    $('#ghepGiaTBTPT').prop('disabled', false);
                });

                // Define what happens in case of error
                XHR.addEventListener('error', function (event) {
                    alert('Oops! Something went wrong.');
                    $('#ghepGiaTBTPT').prop('disabled', false);
                });

                // Set up our request
                XHR.open('POST', 'Tool/TinhGiaBoTheoPhanTram.aspx');

                // Add the required HTTP header for form data POST requests
                XHR.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

                // Finally, send our data.
                XHR.send(urlEncodedData);
            }
        }
    </script>
</div>

<%} %>