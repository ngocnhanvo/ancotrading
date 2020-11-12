<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TuyChinhMauIn.aspx.cs" Inherits="Tool_TuyChinhMauIn" %>
<% if(!send) { %>
<style type="text/css">
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
        width: 100%;
    }

</style>
<div class="frmMauIn">
    <h1>Tùy chỉnh mẫu in đơn hàng, DSDH</h1>

    <div style="display:table">
         <div style="display:table-row">
            <div style="display:table-cell">
                <label>Chọn mẫu in</label><br>
                <%=optionsMauIn %>
            </div>
        </div>
        <div style="height:15px;"></div>
        <div style="display:table-row">
            <div style="display:table-cell">
                <label>Kích thước chữ Excel</label><br>
                <input id="ktcExcel" type="number" />
            </div>
            <div style="display:table-cell;width:20px">
            </div>
            <div style="display:table-cell">
                <label>Kích thước chữ PDF</label><br>
                <input id="ktcPDF" type="number" />
            </div>
        </div>
        <div style="height:15px;"></div>
        <div style="display:table-row">
            <div style="display:table-cell">
                <input type="button" value="Lưu chỉnh sửa" id="LuuChinhSua" />
            </div>
        </div>
    </div>

    <script type="text/javascript">
        let selectRpt = document.getElementById('selectRpt');
        selectRpt.onchange = function (e) {
            let optionSel = selectRpt.options[selectRpt.selectedIndex];

            let jsonKTC = JSON.parse(optionSel.getAttribute('ktc'))[0];

            document.getElementById('ktcExcel').value = jsonKTC.excel;
            document.getElementById('ktcPDF').value = jsonKTC.pdf;
        };

        document.getElementById('LuuChinhSua').onclick = function() {
            if (confirm('Thực hiện lưu chỉnh sửa của bạn???')) {
                const XHR = new XMLHttpRequest();

                let urlEncodedData = "",
                    urlEncodedDataPairs = [],
                    name;

                // Turn the data object into an array of URL-encoded key/value pairs.
                let data =
                {
                    "fontSize": JSON.stringify([
                        {
                            "excel": document.getElementById('ktcExcel').value,
                            "pdf": document.getElementById('ktcPDF').value
                        }
                    ]),
                    "name": document.getElementById("selectRpt").value,
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
                    console.log(event);
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