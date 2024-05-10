function download(e, t, n) {
    if (e == "err") { return "-"; }

    if (e != "-") {
        console.log(t);
        let aStyle = `display: block;width: fit-content;margin: 0px auto;`;
        let spanStyle = `top: -2px;position: relative;`;
        let link = `Controllers/API_System.ashx?oper=downloadFile&id=${e}`;
        return `<a style="${aStyle}" href="#" onclick="modify_code('${link}')"><span style="${spanStyle}" class="ui-icon ui-icon-document"></span></a>`;
    }
    return e;
}

function formatBytes(e, t) {
    if (e == null | typeof (e) == 'undefined') return "err";
    if (0 == e) return "0 Byte";
    let n = 1024, a = 2, i = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"],
        r = Math.floor(Math.log(e) / Math.log(n));
    return (e / Math.pow(n, r)).toFixed(a) + " " + i[r];
}

function disable_formatter(e, t, n) {
    let a = $(n).html(), i = $(a).prop("tagName"); return $(i, n).attr("title")
}

function modify_code(url) {
    reload_page = "no";
    window.location.href = url;
}