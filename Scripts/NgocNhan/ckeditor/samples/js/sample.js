/**
 * Copyright (c) 2003-2020, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license
 */

/* exported initSample */
var uuidv4 = function () {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
};

if (CKEDITOR.env.ie && CKEDITOR.env.version < 9)
    CKEDITOR.tools.enableHtml5Elements(document);

// The trick to keep the editor in the sample quite small
// unless user specified own height.
CKEDITOR.config.height = '250px';
CKEDITOR.config.width = 'auto';
CKEDITOR.config.htmlEncodeOutput = false;
CKEDITOR.config.entities = false;
CKEDITOR.config.allowedContent = true;
CKEDITOR.config.extraPlugins = 'colordialog,colorbutton,find,image2,font';
CKEDITOR.config.extraAllowedContent = 'img[src,alt,width,height];a[file,excel,title];tr[repeat];div[style,align];td[data-t,data-a-h,data-b-a-s, data-f-bold];table[data-cols-width]';
var editorElement = null;
var editorElementReplace = null;
var titleEditor = null;
var closeEditor = null;
var filesEditor = [];
var overlayDark, overlayContent;
var elemCall = null;

var postDataFromIframeToServer = function (a) {
    let saveVal = CKEDITOR.instances.editor.getData();
    let length = filesEditor.length;
    for (let i = length - 1; i >= 0; i--) {
        if (saveVal.lastIndexOf(filesEditor[i].id) <= -1)
            delete filesEditor[i];
    }

    window.parent.postMessage({
        closeIframe: true,
        saveVal: saveVal,
        elem: elemCall,
        files: JSON.stringify(filesEditor)
    }, '*')
};

var displayAttachFile = function (show) {
    if (show) {
        overlayDark.style.display = 'block';
        overlayContent.style.display = 'block';
    }
    else {
        overlayDark.style.display = 'none';
        overlayContent.style.display = 'none';
    }
};

function fileOrImgInsert(a) {
    let fileOrImg = document.getElementById('fileOrImg');
    let text = document.getElementById('txtfileOrImg');
    let data = document.getElementById('txtfileOrImgData');
    let chkDisplayImage = document.getElementById('chkDisplayImage');
    let checked = chkDisplayImage.checked;
    let mimeType = data.getAttribute('mimeType').lastIndexOf('image/') > -1;

    let html = '';
    if (checked & mimeType) {
        html = `<img src='${JSON.parse(data.value).data}' alt="${text.value}" />`;
    }
    else {
        let id = uuidv4();
        html = `<a href='#' file='${id}'>${text.value}</a>`;
        filesEditor.push({ id: id, data: data.value });
    }

    CKEDITOR.instances.editor.insertHtml(html);
    text.value = '';
    data.value = '';
    fileOrImg.value = '';
    chkDisplayImage.checked = false;
    chkDisplayImage.disabled = true;
    displayAttachFile(false);
}

function fileOrImgChange(a) {
    readDataWhenChangeFile(a, function (rs) {
        !rs.ok ? alert(rs.mess) : (
            document.getElementById('txtfileOrImg').value = rs.name,
            txtfileOrImgData = document.getElementById('txtfileOrImgData'),
            txtfileOrImgData.value = JSON.stringify(rs),
            txtfileOrImgData.setAttribute('mimeType', rs.mimeType),
            image = rs.mimeType.lastIndexOf('image/') > -1,
            chkDisplayImage = document.getElementById('chkDisplayImage'),
            image ? chkDisplayImage.disabled = false : (chkDisplayImage.checked = false, chkDisplayImage.disabled = true)
        )
    })
}

function readDataWhenChangeFile(input, callback) {
    let imgJs = {
        ok: false,
        data: '',
        name: '',
        mess: '',
        size: 0,
        mimetype: ''
    };

    if (input.files && input.files[0]) {
        let reader = new FileReader();
        let fileSel = input.files[0];
        let accept = input.getAttribute('accept');
        reader.onload = function (e) {
            let indexMimeType = fileSel.name.lastIndexOf(".");
            let mimeType = fileSel.name.substring(indexMimeType).toLowerCase();
            if (accept.split(',').lastIndexOf(mimeType) <= -1 & accept != '*') {
                imgJs.ok = false;
                imgJs.mess = 'Chỉ chấp nhận tập tin có các định dạng sau: ' + accept.replace(/,/g, ', ');
            }
            else {
                imgJs.ok = true;
                imgJs.data = e.target.result;
                imgJs.name = fileSel.name;
                imgJs.size = fileSel.size;
                imgJs.mimeType = fileSel.type;
            }
            callback(imgJs);
        }

        reader.readAsDataURL(input.files[0]);
    }
    else {
        callback(imgJs);
    }
}

var initSample = (function () {
    var wysiwygareaAvailable = isWysiwygareaAvailable(),
        isBBCodeBuiltIn = !!CKEDITOR.plugins.get('bbcode');

    return function () {
        overlayDark = document.getElementsByClassName("overlay-dark")[0];
        overlayContent = document.getElementsByClassName("overlay-content")[0];

        if(overlayDark) {
            overlayDark.onclick = function () {
                displayAttachFile(false);
            };
        }

        editorElement = CKEDITOR.document.getById('editor');
        titleEditor = document.getElementById('titleEditor');
        closeEditor = document.getElementById('closeEditor');
        // :(((
        if (isBBCodeBuiltIn) {
            //editorElement.setHtml(
            //	'Hello world!\n\n' +
            //	'I\'m an instance of [url=https://ckeditor.com]CKEditor[/url].'
            //);
        }

        // Depending on the wysiwygarea plugin availability initialize classic or inline editor.
        if (wysiwygareaAvailable) {
            editorElementReplace = CKEDITOR.replace('editor',
                {
                    toolbar: [
                        { name: 'styles', items: ['Styles', 'Format', 'Font', 'FontSize'] },
                        { name: 'basicstyles', items: ['Bold', 'Italic', 'Strike'] },
                        { name: 'paragraph', items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-'] },
                        { name: 'links', items: ['Link', 'Unlink'] },
                        { name: 'insert', items: ['Table'] },
                        { name: 'editing', items: ['Source'] },
                        { name: 'colors', items : ['TextColor', 'BGColor']}
                    ],
                    enterMode: CKEDITOR.ENTER_BR,
                    shiftEnterMode: CKEDITOR.ENTER_P,
                    basicEntities: false
                }
            );
        } else {
            editorElement.setAttribute('contenteditable', 'true');
            CKEDITOR.inline('editor');

            // TODO we can consider displaying some info box that
            // without wysiwygarea the classic editor may not work.
        }
    };

    function isWysiwygareaAvailable() {
        // If in development mode, then the wysiwygarea must be available.
        // Split REV into two strings so builder does not replace it :D.
        if (CKEDITOR.revision == ('%RE' + 'V%')) {
            return true;
        }

        return !!CKEDITOR.plugins.get('wysiwygarea');
    }
})();