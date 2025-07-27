<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TuyChinhMauIn.aspx.cs" Inherits="Tool_TuyChinhMauIn" %>
<% if(!send) { %>
<style type="text/css">
    .frmMauIn table {
        max-width: 500px;
        border-collapse: collapse;
    }

    .frmMauIn {
        margin-top: 15px;
        margin-left: 15px;
    }

    .frmMauIn h1 {
        margin-bottom: 10px;
        font-size: 160%;
    }

    .frmMauIn label {
        font-weight: bold;
    }

    .frmMauIn input, .frmMauIn select {
        width: 99%;
    }
    .frmMauIn fieldset {
        padding: 15px;
        width: 100%;
    }

    .frmMauIn .spaceTr {
        width: 20px;
        height: 15px;
    }

    #ktcExcel, #ktcPDF {
        width: 50px;
    }

    #LuuChinhSua, #selectRpt {
        max-width: 120px;
    }

    #selectRpt2 {
        display:none;
    }
</style>
<div class="frmMauIn">
    <h1>Tùy chỉnh mẫu in đơn hàng, DSDH</h1>

    <table>
         <tr>
            <td>
                <label>Chọn mẫu in: </label>
                <%=optionsMauIn %>
                <select id="selectRpt2"></select>
            </td>
        </tr>
        
        <tr><td><div class="spaceTr"></div></td></tr>

        <tr>
            <td>
                <label>Kích thước chữ Excel: </label>
                <input id="ktcExcel" type="number" />
            </td>
            <td><div class="spaceTr"></div></td>
            <td>
                <label>Kích thước chữ PDF: </label>
                <input id="ktcPDF" type="number" />
            </td>
        </tr>

        <tr><td><div class="spaceTr"></div></td></tr>

        <tr>
            <td colspan="3">
                <fieldset>
                    <legend><b>Định dạng số thập phân</b></legend>
                    <div class="selectNCC">
                        <label>Chọn NCC</label><br>
                        <select id="selNCCStp"></select>
                    </div>
                    <div class="selectNCC" style="height:15px;"></div>
                    <div style="display:table">
                        <div style="display:table-row">
                            <div style="display:table-cell">
                                <label>Số lượng</label><br>
                                <input id="fmtSoLuong" type="text" />
                            </div>
                            <div style="display:table-cell;width:20px"></div>
                            <div style="display:table-cell">
                                <label>CBM</label><br>
                                <input id="fmtCBM" type="text" />
                            </div>
                            <div style="display:table-cell;width:20px"></div>
                            <div style="display:table-cell">
                                <label>Discount</label><br>
                                <input id="fmtDiscount" type="text" />
                            </div>
                            <div style="display:table-cell;width:20px"></div>
                            <div style="display:table-cell">
                                <label>Đơn giá, Thành Tiền</label><br>
                                <input id="fmtAmount" type="text" />
                            </div>
                        </div>
                    </div>
                </fieldset>
            </td>
        </tr>

        <tr><td><div class="spaceTr"></div></td></tr>

       <tr>
            <td style="text-align:center" colspan="3">
                <input type="button" value="Lưu chỉnh sửa" id="LuuChinhSua" />
            </td>
        </tr>

    </table>

    <script type="text/javascript">
        let selectRpt = document.getElementById('selectRpt');
        selectRpt.onchange = function (e) {
            let optionSel = selectRpt.options[selectRpt.selectedIndex];
            let jsonKTC = JSON.parse(optionSel.getAttribute('ktc'))[0];
            let selectNCC = document.getElementsByClassName('selectNCC');
            document.getElementById('ktcExcel').value = jsonKTC.excel;
            document.getElementById('ktcPDF').value = jsonKTC.pdf;

            let jsonSTP = JSON.parse(optionSel.getAttribute('stps'))[0];
            let jsonDTKDs = jsonSTP.dtkd;
            let selNCCStp = document.getElementById('selNCCStp');
            selNCCStp.innerHTML = '';
            if (jsonDTKDs) {
                Array.prototype.forEach.call(selectNCC, function (item) { item.style.display = 'block'; });
                let node = document.createElement("option");
                selNCCStp.appendChild(node);
                for (let i = 0; i < jsonDTKDs.length; i++)
                {
                    let row = jsonDTKDs[i];
                    let node = document.createElement("option");
                    node.value = row.name;
                    node.text = row.name;
                    node.setAttribute("cbm", row.cbm ? row.cbm : jsonSTP.cbm);
                    node.setAttribute("soluong", row.soluong ? row.soluong : jsonSTP.soluong);
                    node.setAttribute("discount", row.discount ? row.discount : jsonSTP.discount);
                    node.setAttribute("amount", row.amount ? row.amount : jsonSTP.amount);
                    selNCCStp.appendChild(node);
                }

                selNCCStp.onchange = function () {
                    let optionSel = selNCCStp.options[selNCCStp.selectedIndex];
                    document.getElementById('fmtSoLuong').value = optionSel.getAttribute("soluong");
                    document.getElementById('fmtCBM').value = optionSel.getAttribute("cbm");
                    document.getElementById('fmtDiscount').value = optionSel.getAttribute("discount");
                    document.getElementById('fmtAmount').value = optionSel.getAttribute("amount");
                };

                selNCCStp.onchange();
            }
            else {
                Array.prototype.forEach.call(selectNCC, function (item) { item.style.display = 'none'; });
                document.getElementById('fmtSoLuong').value = jsonSTP.soluong;
                document.getElementById('fmtCBM').value = jsonSTP.cbm;
                document.getElementById('fmtDiscount').value = jsonSTP.discount;
                document.getElementById('fmtAmount').value = jsonSTP.amount;
            }
        };

        document.getElementById('LuuChinhSua').onclick = function () {
            if (!document.getElementById('selectRpt').value) {
                alert('Phải chọn mẫu in');
                return;
            }

            if (confirm('Thực hiện lưu chỉnh sửa của bạn???'))
            {
                const XHR = new XMLHttpRequest();

                let urlEncodedData = "",
                    urlEncodedDataPairs = [],
                    name;

                // Turn the data object into an array of URL-encoded key/value pairs.
                let dtkd = document.getElementById('selNCCStp').value;
                let stps = {
                    "soluong": document.getElementById('fmtSoLuong').value,
                    "cbm": document.getElementById('fmtCBM').value,
                    "discount": document.getElementById('fmtDiscount').value,
                    "amount": document.getElementById('fmtAmount').value
                };

                let data =
                {
                    "fontSize": JSON.stringify([
                        {
                            "excel": document.getElementById('ktcExcel').value,
                            "pdf": document.getElementById('ktcPDF').value
                        }
                    ]),
                    "name": document.getElementById("selectRpt").value,
                    "dtkd": dtkd,
                    "soThapPhan": JSON.stringify(stps),
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
                    //console.log(event.currentTarget.response);
                    let selectRpt = document.getElementById('selectRpt');
                    let selectRpt2 = document.getElementById('selectRpt2');
                    selectRpt2.innerHTML = event.currentTarget.response;

                    let options = selectRpt.options;
                    for (let i = 0; i < options.length; i++)
                    {
                        let option = options[i];
                        let option2 = selectRpt2.options[i];

                        option.setAttribute("ktc", option2.getAttribute("ktc"));
                        option.setAttribute("stps", option2.getAttribute("stps"));
                    }

                    let valSel = document.getElementById('selNCCStp').value;
                    selectRpt.onchange();
                    document.getElementById('selNCCStp').value = valSel;
                    document.getElementById('selNCCStp').onchange();

                    alert('Lưu thành công');
                });

                // Define what happens in case of error
                XHR.addEventListener('error', function (event) {
                    alert('Oops! Something went wrong.');
                });

                // Set up our request
                XHR.open('POST', 'Tool/TuyChinhMauIn.aspx');

                // Add the required HTTP header for form data POST requests
                XHR.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

                // Finally, send our data.
                XHR.send(urlEncodedData);
            }
        }
    </script>
</div>

<%} %>