<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Outlook.aspx.cs" Inherits="Outlook" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="en">
<head>
    <meta content="" charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Outlook-style Email Compose</title>
    <script type="text/javascript" src="Scripts/NgocNhan/ckeditor/ckeditor.js?v=12345766"></script>
    <script type="text/javascript" src="Scripts/NgocNhan/ckeditor/samples/js/sample.js?v=12345766"></script>
    <link type="text/css" rel="stylesheet" href="Scripts/NgocNhan/ckeditor/samples/css/samples.css" />
    <link type="text/css" rel="stylesheet" href="Scripts/NgocNhan/ckeditor/samples/toolbarconfigurator/lib/codemirror/neo.css" />
    <link type="text/css" rel="stylesheet" href="Scripts/NgocNhan/ckeditor/samples/font-awesome-4.7.0/css/font-awesome.min.css" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .compose-container {
            width: 600px;
            margin: 20px auto;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .compose-header {
            background: #0078D4;
            color: white;
            padding: 3px 10px 3px 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 4px 4px 0 0;
        }

            .compose-header button {
                background: none;
                border: none;
                color: white;
                padding: 8px 15px;
                cursor: pointer;
                border-radius: 4px;
            }

                .compose-header button:hover {
                    background: rgba(255,255,255,0.2);
                }

        .compose-options {
            display: flex;
            gap: 10px;
        }

        .compose-body {
            padding: 15px;
            background: white;
        }

        .input-group {
            margin-bottom: 10px;
            display: flex;
            align-items: center;
        }

            .input-group label {
                font-size: 80%;
                width: 74px;
                color: #666;
                text-align: center;
                right: 10px;
                position: relative;
                background-color: #f3f7f7;
                padding: 2px;
                margin-left: 10px;
                border: 1px solid #CCC;
                border-radius: 7px;
            }

        input, .subject-input {
            width: 100%;
            padding: 4px 8px 4px 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            outline: none;
        }

        .email-editor {
            min-height: 300px;
            border: 1px solid #ccc;
            padding: 10px;
            margin-top: 10px;
            outline: none;
        }

        .formatting-toolbar {
            display: flex;
            gap: 10px;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }

            .formatting-toolbar button {
                background: none;
                border: none;
                cursor: pointer;
                color: #666;
                padding: 5px;
            }

                .formatting-toolbar button:hover {
                    background: #eee;
                }

        .attachment-area {
            margin-top: 10px;
        }

        .attachment-input {
            display: none;
        }

        .attachment-label {
            color: #0078D4;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        /* Thêm style mới cho file đính kèm */
        .file-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 5px;
            margin: 3px 0;
            background: #f5f5f5;
            border-radius: 4px;
        }

        .file-name {
            color: #0078D4;
            text-decoration: none;
            cursor: pointer;
        }

            .file-name:hover {
                text-decoration: underline;
            }

        .delete-btn {
            background: none;
            border: none;
            color: #666;
            cursor: pointer;
            padding: 2px 5px;
            margin-left: auto;
        }

            .delete-btn:hover {
                color: #ff4444;
            }

        span#from {
            font-weight: bold;
            font-size: 82%;
        }

            span#from::before {
                content: 'Người gửi: ';
            }

        #btnSendMail > button > i {
            margin-right: 8px;
        }

        /* Container màn hình chờ */
        .loading-screen {
            position: fixed;
            width: 100%;
            height: 100%;
            background-color: rgb(204 204 204 / 56%);
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            z-index: 9999;
        }

        /* Vòng tròn xoay */
        .loader {
            width: 50px;
            height: 50px;
            border: 5px solid #f3f3f3;
            border-top: 5px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 15px;
        }

        /* Hiệu ứng quay */
        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        /* Text loading */
        .loading-text {
            margin-top: 15px;
            color: #333;
            font-family: Arial, sans-serif;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="loading-screen" id="loadingMain">
        <div class="loader"></div>
        <div class="loading-text">Loading...</div>
    </div>
    <div class="overlay-dark"></div>
    <div class="compose-container">
        <div class="compose-header">
            <span id="from">Đang tải...</span>
            <div id="btnSendMail" class="compose-options">
                <button onclick="sendEmail()"><i class="fa fa-paper-plane"></i>Gửi Mail</button>
            </div>
        </div>
        <div class="compose-body">
            <div class="input-group">
                <label>Đến</label>
                <input type="email" id="toInput" required>
            </div>
            <div class="input-group">
                <label>Cc</label>
                <input type="email" id="ccInput">
            </div>
            <div class="input-group">
                <label>Bcc</label>
                <input type="email" id="bccInput">
            </div>
            <div class="input-group">
                <label>Tiêu đề</label>
                <input type="text" id="subjectInput" class="subject-input">
            </div>

            <div id="editor">
            </div>

            <div class="attachment-area">
                <input type="file" class="attachment-input" id="attachment" multiple accept=".xls,.xlsx,.doc,.docx,.pdf,.png,.jpg">
                <label for="attachment" class="attachment-label">
                    <i class="fa fa-paperclip"></i>
                    Tập tin đính kèm
                </label>
                <div id="file-list"></div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        let c_baogia_id = "";
        initSample();

        var encodeHTML = function (a) {
            if (a) {
                a = a.replace(/</g, '0ψ0');
                a = a.replace(/>/g, '1Ψ1');
            }
            return a;
        };

        function distinctJsonArrayByProperties(jsonArray, properties) {
            const keyMap = new Map(); // Sử dụng Map để theo dõi các khóa đã gặp (khóa bây giờ có thể dựa trên nhiều thuộc tính)
            const distinctArray = jsonArray.filter(obj => {
                // Tạo một khóa tổng hợp từ các giá trị của các thuộc tính được chỉ định
                const compositeKey = properties.map(prop => obj[prop]).join(','); // Nối các giá trị bằng dấu phẩy

                if (!keyMap.has(compositeKey)) {
                    keyMap.set(compositeKey, true); // Đánh dấu khóa này đã gặp
                    return true; // Giữ lại object này trong mảng kết quả
                }
                return false; // Loại bỏ object trùng lặp (cùng khóa)
            });
            return distinctArray;
        }

        function sendEmail() {
            showLockScreen(true);
            let files = [], errors = [];
            let count = 0, ataFLen = attachedFiles.length;
            const distinctFilesArr = distinctJsonArrayByProperties(attachedFiles, ['name']);
            if (ataFLen > distinctFilesArr.length) {
                showLockScreen(false);
                alert(`Có tập tin đang bị trùng tên với nhau`);
                return;
            }

            const afterAction = function () {
                count++;
                if (count < ataFLen)
                    return;

                if (errors.length > 0) {
                    alert(errors.join('\n'));
                    showLockScreen(false);
                    return;
                }

                let data = {
                    c_baogia_id: c_baogia_id,
                    from: document.getElementById('from').innerHTML,
                    to: document.getElementById('toInput').value,
                    cc: document.getElementById('ccInput').value,
                    bcc: document.getElementById('bccInput').value,
                    title: document.getElementById('subjectInput').value,
                    body: encodeHTML(CKEDITOR.instances.editor.getData()),
                    files
                };
                const formData = new FormData();
                formData.append('data', JSON.stringify(data));

                const xhr = new XMLHttpRequest();
                const url = `Controllers/QuotationQRController.ashx?action=sendEmail`;

                xhr.open('POST', url);
                //xhr.setRequestHeader('Content-Type', 'application/json');
                xhr.onload = function () {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        let rs = xhr.responseText;
                        showLockScreen(false);
                        rs = JSON.parse(rs);
                        alert(rs.msg);
                        if (rs.status) {
                            let origin = window.location.origin;
                            window.parent.postMessage({
                                closeOutLook: true,
                                origin
                            }, origin);
                        }
                    }
                    else {
                        showLockScreen(false);
                        alert(`Lỗi HTTP (XHR): ${xhr.status} ${xhr.statusText}`);
                    }
                };

                xhr.onerror = function () {
                    alert('Lỗi mạng (XHR)');
                    showLockScreen(false);
                };

                xhr.send(formData);
            };

            if (attachedFiles.length > 0) {

                for (let i = 0; i < ataFLen; i++) {
                    let file = attachedFiles[i];
                    if (file.data) {
                        files.push(file);
                        afterAction();
                    }
                    else {
                        const reader = new FileReader();

                        reader.onload = function (event) {
                            const base64String = event.target.result.split(',')[1];
                            files.push({
                                name: file.name,
                                size: file.size,
                                data: base64String
                            });

                            afterAction();
                        };

                        reader.onerror = function (error) {
                            errors.push(`Không đọc được tập tin ${file.name}`);
                            afterAction();
                        };

                        reader.readAsDataURL(file);
                    }
                }
            }
        }

        // Handle file attachments
        document.getElementById('attachment').addEventListener('change', function (e) {
            const files = e.target.files;
            const fileList = document.getElementById('file-list');
            fileList.innerHTML = '';

            for (let file of files) {
                const div = document.createElement('div');
                div.innerHTML = `<i class="fa fa-paperclip"></i> ${file.name}`;
                fileList.appendChild(div);
            }
        });

        let attachedFiles = []; // Mảng lưu trữ các file đính kèm

        // ... Các hàm cũ giữ nguyên ...

        // Cập nhật hàm xử lý file đính kèm
        document.getElementById('attachment').addEventListener('change', function (e) {
            const newFiles = Array.from(e.target.files);
            attachedFiles = [...attachedFiles, ...newFiles];
            updateAttachmentInput();
            renderFileList();
        });

        // Hàm hiển thị danh sách file
        function renderFileList() {
            const fileList = document.getElementById('file-list');
            fileList.innerHTML = '';

            attachedFiles.forEach((file, index) => {
                let indexOf = file.name ? file.name.lastIndexOf('.') : 0;
                let mime = file.name.substr(indexOf).toLowerCase();
                let isXls = [".xls", ".xlsx"].lastIndexOf(mime) > -1;
                let isDoc = [".doc", ".docx"].lastIndexOf(mime) > -1;
                let isPDF = [".pdf"].lastIndexOf(mime) > -1;
                let isIMG = [".png", ".jpg"].lastIndexOf(mime) > -1;
                let icon =
                    isXls ? "fa-file-excel-o" :
                        isDoc ? "fa-file-word-o" :
                            isPDF ? "fa-file-pdf-o" :
                                isIMG ? "fa-file-image-o" : "fa-paperclip";
                const div = document.createElement('div');
                div.className = 'file-item';
                div.innerHTML = `
                    <i class="fa ${icon}"></i>
                    <a class="file-name" onclick="openFile(${index})">${file.name}</a>
                    <button class="delete-btn" onclick="deleteFile(${index})">&times;</button>
                `;
                fileList.appendChild(div);
            });
        }

        // Hàm xóa file
        function deleteFile(index) {
            attachedFiles.splice(index, 1);
            updateAttachmentInput();
            renderFileList();
        }

        // Hàm mở file
        function downloadBase64File(base64String, fileName, mimeType) {
            // 1. Giải mã Base64 string thành chuỗi binary
            const binaryString = atob(base64String);

            // 2. Tạo mảng byte từ chuỗi binary
            const byteArray = new Uint8Array(binaryString.length);
            for (let i = 0; i < binaryString.length; i++) {
                byteArray[i] = binaryString.charCodeAt(i);
            }

            // 3. Tạo Blob object từ mảng byte, có MIME type
            const blob = new Blob([byteArray], { type: mimeType });

            // 4. Tạo URL tạm thời cho Blob
            const blobUrl = URL.createObjectURL(blob);

            // 5. Tạo thẻ <a> một cách lập trình
            const downloadLink = document.createElement('a');
            downloadLink.href = blobUrl;
            downloadLink.download = fileName; // Tên tập tin khi tải xuống
            // 7. Kích hoạt tải xuống bằng cách click vào liên kết
            downloadLink.click();
            downloadLink.remove();
            URL.revokeObjectURL(blobUrl);
        }
        function openFile(index) {
            const file = attachedFiles[index];
            if (file.data) {
                downloadBase64File(file.data, file.name, file.mime);
            }
            else {
                let url = URL.createObjectURL(file);
                // Tạo link tải xuống
                const a = document.createElement('a');
                a.href = url;
                a.download = file.name;
                a.click();
                a.remove();
                // Dọn dẹp bộ nhớ
                URL.revokeObjectURL(url);
            }
        }

        // Cập nhật input file
        function updateAttachmentInput() {
            const dataTransfer = new DataTransfer();
            attachedFiles.forEach(file => {
                if (!file.data)
                    dataTransfer.items.add(file)
            });
            document.getElementById('attachment').files = dataTransfer.files;
        }

        let funcMess = function (event) {
            let json = event.data;
            let orgin = window.location.origin;
            if (orgin == json.origin) {
                c_baogia_id = json.c_baogia_id;
                document.getElementById('from').innerHTML = json.from;
                document.getElementById('toInput').value = json.to;
                document.getElementById('ccInput').value = json.cc;
                document.getElementById('bccInput').value = json.bcc;
                document.getElementById('subjectInput').value = json.subject;
                CKEDITOR.instances.editor.setData(json.body);
                if (json.file) {
                    attachedFiles.push({
                        name: json.file.name,
                        size: json.file.size,
                        data: json.file.data
                    });
                    renderFileList();
                }
                showLockScreen(false);
            }
        };

        function showLockScreen(type) {
            document.getElementById('loadingMain').style.display = type ? '' : 'none';
        }
        window.removeEventListener('message', funcMess);
        window.addEventListener('message', funcMess, false);
    </script>
</body>
</html>
