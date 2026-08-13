<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_hosochungtu_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<script type="text/javascript">
    var nvcts_hosochungtu = <%=nvctsStr%>;
    function printhosochungtu() {
        let piId = $('#grid_ds_hosochungtu').jqGrid('getGridParam', 'selrow');
        let name = 'dialog-print-hosochungtu-pi';
        let title = 'Trích xuất dữ liệu';
        let content = `
            <table style="width:100%">
            <tr>
                <td>
                    <div>
                        <input id="printHSCT_BookCont" type="radio" name="rdoPrintType" />
                        <label for="printHSCT_BookCont">In Book Container</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div>
                        <input id="printHSCT_All" type="radio" name="rdoPrintType" />
                        <label for="printHSCT_All">Chiết xuất excel theo "shippment time"</label>
                    </div>
                    <div style="display:flex; width:99%; padding:5px; background-color:#FFF; margin-top:5px;">
                        <div>
                            <label for="printHSCT_tungay">Từ ngày</label>
                            <input id="printHSCT_tungay" autocomplete="off" type="text" style="width:97%"/>
                        </div>
                        <div style="width:14px;"></div>
                        <div>
                            <label for="printHSCT_denngay">Đến ngày</label>
                            <input id="printHSCT_denngay" autocomplete="off" type="text" style="width:97%"/>
                        </div>
                    </div>
                </td>
            </tr>
            </table>
        `;

        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);
        let $chks = $('input[name=rdoPrintType]', `#${name}`);

        $(`#${name}`).dialog({
            width: 300,
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                $('#printHSCT_tungay').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
                $('#printHSCT_denngay').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });

                $chks.change(function () {
                    let printType = $chks.filter(':checked').attr('id');
                    if (printType == 'printHSCT_All') {
                        $('#printHSCT_tungay').prop("disabled", false);
                        $('#printHSCT_denngay').prop("disabled", false);
                    }
                    else {
                        $('#printHSCT_tungay').prop("disabled", true);
                        $('#printHSCT_denngay').prop("disabled", true);
                    }
                });
                $('#printHSCT_BookCont').click();
            }
            , buttons: [
                {
                    id: `btn-print-ok-${name}`,
                    text: "In",
                    click: function () {
                        let printType = $chks.filter(':checked').attr('id');
                        let printName = $chks.filter(':checked').next().text();
                        let printURL = "Views/hosochungtu/";
                        let windowSize = "width=700,height=700,scrollbars=yes";
                        if (typeof printType == 'undefined') {
                            alert(`Chưa chọn kiểu in`);
                            return;
                        }

                        let tungay = $('#printHSCT_tungay').val();
                        let denngay = $('#printHSCT_denngay').val();
                        if (printType == 'printHSCT_All') {
                            if (!tungay) {
                                alert(`Chưa chọn từ ngày`);
                                return;
                            }

                            if (!denngay) {
                                alert(`Chưa chọn đến ngày`);
                                return;
                            }
                        }

                        printURL += `${printType}.aspx?id=${piId}&download=0&tungay=${tungay}&denngay=${denngay}`;
                        let newWindow = window.open(printURL, printName, windowSize);

                        if (newWindow) {
                            let inter = setInterval(function () {
                                if (newWindow.document.title !== undefined) {
                                    newWindow.document.title = printName;
                                    clearInterval(inter);
                                }
                            }, 500);
                        }
                    }
                },
                {
                    id: `btn-print-close-${name}`,
                    text: "Thoát",
                    click: function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            ]
        });
    }

    function funcCapNhatNBHXNhosochungtu() {
        let id = $("#grid_ds_hosochungtu").jqGrid('getGridParam', 'selrow');
        if (id == null) {
            alert('Chưa chọn hồ sơ muốn cập nhật.!');
            return;
        }

        let name = 'dialog-capnhatnbhxn-hosochungtu-pi';
        let title = 'Cập nhật ngày bán hàng xác nhận xuất hàng';
        let content = `
            <div>
                <div style="display:none" id="wait">
                    <img style="width:30px; height:30px" src="iconcollection/loading.gif"/>
                </div>
                <div id="dialog-caution">
                    <label for="hsct_ngayBHXN" style="display: inline-block;">Ngày BHXNXH: </label>
                    <input id="hsct_ngayBHXN" autocomplete="off" type="text" style="padding:3px; display:inline-block;">
                </div>
            </div>
        `;
        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);

        // create new dialog
        $(`#${name}`).dialog({
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                $('#hsct_ngayBHXN').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
                $('#hsct_ngayBHXN').blur();
            }
            , buttons:
                [
                    {
                        id: `btn-yes-${name}`,
                        text: "Có",
                        click: function () {
                            let ngayBHXN = $('#hsct_ngayBHXN').val();
                            if (!ngayBHXN) {
                                alert(`Chưa chọn ngày bán hàng xác nhận xuất hàng`);
                                return;
                            }

                            let ajaxStart = function () {
                                $("#wait").css("display", "block");
                                $(`#btn-yes-${name}`).button("disable");
                                $(`#btn-close-${name}`).button("disable");
                            };

                            let ajaxComplete = function () {
                                $("#wait").css("display", "none");
                                $(`#btn-close-${name} span`).text("Thoát");
                                $(`#btn-close-${name}`).button("enable");
                            };

                            ajaxStart();
                            $.post(`Views/hosochungtu/Controller_hosochungtu.ashx?action=ngayBHXN`, { id: id, ngayBHXN: ngayBHXN }, function (result) {
                                ajaxComplete();
                                let $xmlObject = $(result);
                                let ok = $xmlObject.find('type').text() == '1';
                                let msg = $xmlObject.find('message').text();
                                $(`#${name}`).find('#dialog-caution').html(msg);
                                if (ok)
                                    $('#grid_ds_hosochungtu')[0].triggerToolbar();
                            });
                        }
                    },
                    {
                        id: `btn-close-${name}`,
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
        });
    }
    function utf8ToBase64(str) {
        str = str || '';
        return btoa(unescape(encodeURIComponent(str)));
    }
    function mailhosochungtu(funcEnd) {

        let piIds = $('#grid_ds_hosochungtu').jqGrid('getGridParam', 'selarrrow');
        if (piIds.length <= 0) {
            alert('Chưa chọn dòng cần gửi mail');
            return;
        }

        let nvbhs = [], nccs = <%=nccsStr%>;
        for (let i in piIds) {
            let id = piIds[i];
            let row = $('#grid_ds_hosochungtu').getRowData(id);
            if(nvbhs.lastIndexOf(row.nguoilap) <= -1)
                nvbhs.push(row.nguoilap);
        }
        nvbhs.sort();

        let name = 'dialog-mail-hosochungtu';
        let title = 'Gửi mail';
        let content = `
            <div style="display:none" id="wait">
                <img style="width:30px; height:30px" src="iconcollection/loading.gif"/>
            </div>
            <div id="dialog-caution">
                <table style="width:100%; background-color:#FFF">
                <tr>
                    <td>
                        <div>
                            <label for="mailHSCT_nvbh" style="font-weight:bold;">Nhân viên bán hàng</label>
                            <table id="mailHSCT_nvbh" style="margin-top:2px; border-spacing:6px; user-select: none;"></table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div>
                            <label for="mailHSCT_ncc" style="font-weight:bold;">Nhà cung cấp</label>
                            <table id="mailHSCT_ncc" style="margin-top:2px; border-spacing:6px; user-select: none;"></table>
                        </div>
                    </td>
                </tr>
                </table>
            </div>
        `;
        
        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);
        let $chks = $('input[name=rdoPrintType]', `#${name}`);

        $(`#${name}`).dialog({
            width: 300,
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                $.each(nvbhs, function (index, value) {
                    let id = `chk_hsct_${value}`;
                    $('#mailHSCT_nvbh').append(`<tr><td><input id="${id}" type="checkbox"/></td><td><label for="${id}">${value}</label></td></tr>`);
                });

                $.each(nccs, function (index, value) {
                    let id = `chk_hsct_${value}`;
                    $('#mailHSCT_ncc').append(`<tr><td><input id="${id}" type="checkbox"/></td><td><label for="${id}">${value}</label></td></tr>`);
                });

                $(`#${name}`).closest('div.ui-dialog').dialogCenter(); 
            }
            , buttons: [
                {
                    id: `btn-ok-${name}`,
                    text: "Gửi mail",
                    click: function () {
                        let nvbhIDs = [], nccIDs = [];
                        $("#mailHSCT_nvbh input[type='checkbox']:checked").each(function () {
                            let id = $(this).attr('id').replace('chk_hsct_', '');
                            nvbhIDs.push(id);
                        });

                        $("#mailHSCT_ncc input[type='checkbox']:checked").each(function () {
                            let id = $(this).attr('id').replace('chk_hsct_', '');
                            nccIDs.push(id);
                        });

                        let ajaxStart = function () {
                            $("#wait").css("display", "block");
                            $(`#btn-ok-${name}`).button("disable");
                            $(`#btn-close-${name}`).button("disable");
                        };

                        let ajaxComplete = function () {
                            $("#wait").css("display", "none");
                            $(`#btn-close-${name}`).button("enable");
                        };

                        //ajaxStart();
                        //$.post(`Views/hosochungtu/printHSCT_All.aspx`, {ids: piIds.toString() }).done(function (rs1) {
                        //    $.post(`Views/hosochungtu/Controller_HoSoChungTu.ashx?action=sendMail`, {
                        //        ids: piIds.toString(),
                        //        nvbhs: nvbhIDs.toString(),
                        //        nccs: nccIDs.toString(),
                        //        tt: rs1
                        //    }, function (result) {
                        //        ajaxComplete();
                        //        let $xmlObject = $(result); 
                        //        let ok = $xmlObject.find('type').text() == '1';
                        //        let msg = $xmlObject.find('message').text();
                        //        $(`#${name}`).find('#dialog-caution').html(msg);
                        //    });
                        //})
                        //.fail(function (jqXHR, textStatus, errorThrown) {
                        //    ajaxComplete();
                        //    alert(errorThrown);
                        //});


                        if (nvbhIDs.length <= 0 && nccIDs.length <= 0) {
                            alert('Anh chưa chọn người nhận mail.');
                            return;
                        }

                        // Lấy đúng ID hồ sơ chứng từ từ grid
                        let hsctIds = [];
                        let selectedRows = $('#grid_ds_hosochungtu').jqGrid('getGridParam', 'selarrrow');

                        for (let i = 0; i < selectedRows.length; i++) {
                            let rowid = selectedRows[i];
                            let row = $('#grid_ds_hosochungtu').jqGrid('getRowData', rowid);

                            let hsctId = row.c_donhangchungtu_id;

                            if (!hsctId) {
                                hsctId = rowid;
                            }

                            if (hsctId) {
                                hsctIds.push(hsctId);
                            }
                        }

                        if (hsctIds.length <= 0) {
                            alert('Không lấy được ID hồ sơ chứng từ.');
                            return;
                        }

                        let hsctId = hsctIds[0];

                        ajaxStart();

                        console.clear();
                        console.log('===== DEBUG GỬI MAIL HỒ SƠ CHỨNG TỪ =====');
                        console.log('selectedRows:', selectedRows);
                        console.log('hsctId:', hsctId);
                        console.log('hsctIds:', hsctIds);
                        console.log('hsctIds string:', hsctIds.join(','));
                        console.log('nvbhIDs:', nvbhIDs);
                        console.log('nccIDs:', nccIDs);

                        // Bước 1: tạo nội dung hồ sơ, không gọi OfficeToPDF
                        $.ajax({
                            url: 'Views/hosochungtu/printHSCT_All.aspx?mail=1&download=0',
                            type: 'POST',
                            data: {
                                id: hsctId,
                                ids: hsctIds.join(',')
                            },
                            success: function (rs1, textStatus, jqXHR) {
                                console.log('===== printHSCT_All.aspx SUCCESS =====');
                                console.log('Status:', jqXHR.status);
                                console.log('Response length:', rs1 ? rs1.length : 0);
                                console.log('Response preview:', rs1 ? rs1.substring(0, 1000) : '');

                                if (!rs1 || rs1.indexOf('Không có dữ liệu') >= 0) {
                                    ajaxComplete();

                                    $(`#${name}`).find('#dialog-caution').html(
                                        `<div style="color:red; white-space:pre-wrap">
                    Không chiết xuất được dữ liệu hồ sơ chứng từ.<br/>
                    id: ${hsctId}<br/>
                    ids: ${hsctIds.join(',')}<br/><br/>
                    ${rs1 || ''}
                </div>`
                                    );
                                    return;
                                }

                                // Bước 2: gửi mail
                                $.ajax({
                                    url: 'Views/hosochungtu/Controller_HoSoChungTu.ashx?action=sendMail',
                                    type: 'POST',
                                    data: {
                                        id: hsctId,
                                        ids: hsctIds.join(','),
                                        nvbhs: nvbhIDs.toString(),
                                        nccs: nccIDs.toString(),
                                        tt: utf8ToBase64(rs1),
                                        tt_base64: '1'
                                    },
                                    success: function (result, textStatus2, jqXHR2) {
                                        ajaxComplete();

                                        console.log('===== sendMail SUCCESS =====');
                                        console.log('Status:', jqXHR2.status);
                                        console.log('Result:', result);

                                        let $xmlObject = $(result);
                                        let ok = $xmlObject.find('type').text() == '1';
                                        let msg = $xmlObject.find('message').text();

                                        if (!msg) {
                                            msg = result;
                                        }

                                        $(`#${name}`).find('#dialog-caution').html(msg);

                                        //if (ok && typeof funcEnd === 'function') {
                                        //    funcEnd();
                                        //}
                                        if (ok) {
                                            $('#grid_ds_hosochungtu')[0].triggerToolbar();
                                        }

                                        if (ok && typeof funcEnd === 'function') {
                                            funcEnd();
                                        }
                                    },
                                    error: function (jqXHR2, textStatus2, errorThrown2) {
                                        ajaxComplete();

                                        console.error('===== sendMail ERROR =====');
                                        console.error('Status:', jqXHR2.status);
                                        console.error('textStatus:', textStatus2);
                                        console.error('errorThrown:', errorThrown2);
                                        console.error('responseText:', jqXHR2.responseText);

                                        $(`#${name}`).find('#dialog-caution').html(
                                            `<div style="color:red; white-space:pre-wrap">
                        Lỗi khi gửi mail:<br/>
                        Status: ${jqXHR2.status}<br/>
                        id: ${hsctId}<br/>
                        ids: ${hsctIds.join(',')}<br/><br/>
                        ${jqXHR2.responseText || errorThrown2 || textStatus2}
                    </div>`
                                        );
                                    }
                                });
                            },
                            error: function (jqXHR, textStatus, errorThrown) {
                                ajaxComplete();

                                console.error('===== printHSCT_All.aspx ERROR =====');
                                console.error('Status:', jqXHR.status);
                                console.error('textStatus:', textStatus);
                                console.error('errorThrown:', errorThrown);
                                console.error('id:', hsctId);
                                console.error('ids:', hsctIds.join(','));
                                console.error('responseText:', jqXHR.responseText);

                                $(`#${name}`).find('#dialog-caution').html(
                                    `<div style="color:red; white-space:pre-wrap">
                Lỗi tạo dữ liệu gửi mail từ printHSCT_All.aspx<br/>
                Status: ${jqXHR.status}<br/>
                id: ${hsctId}<br/>
                ids: ${hsctIds.join(',')}<br/><br/>
                ${jqXHR.responseText || errorThrown || textStatus}
            </div>`
                                );
                            }
                        });









                    }
                },
                {
                    id: `btn-close-${name}`,
                    text: "Thoát",
                    click: function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            ]
        });
    }

    function funcKetThuchosochungtu() {
        let id = $("#grid_ds_hosochungtu").jqGrid('getGridParam', 'selrow');
        if (id == null) {
            alert('Chưa chọn hồ sơ muốn kết thúc.!');
            return;
        }

        let name = 'dialog-ketthuc-hosochungtu-pi';
        let title = 'Kết thúc hồ sơ';
        let content = `
            <div>
                <h3 style="padding: 10px" class="ui-state-highlight ui-corner-all" id="dialog-caution">Có phải bạn muốn kết thúc hồ sơ này?</h3>
                <div style="display:none" id="wait">
                    <img style="width:30px; height:30px" src="iconcollection/loading.gif"/>
                </div>
            </div>
        `;
        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);

        // create new dialog
        $(`#${name}`).dialog({
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            }
            , buttons:
                [
                    {
                        id: `btn-yes-${name}`,
                        text: "Có",
                        click: function () {
                            let ajaxStart = function () {
                                $("#wait").css("display", "block");
                                $(`#btn-yes-${name}`).button("disable");
                                $(`#btn-close-${name}`).button("disable");
                            };

                            let ajaxComplete = function () {
                                $("#wait").css("display", "none");
                                $(`#btn-close-${name} span`).text("Thoát");
                                $(`#btn-close-${name}`).button("enable");
                            };

                            ajaxStart();
                            $.post(`Views/hosochungtu/Controller_hosochungtu.ashx?action=ketthuc`, {id: id }, function (result) {
                                ajaxComplete();
                                let $xmlObject = $(result); 
                                let ok = $xmlObject.find('type').text() == '1';
                                let msg = $xmlObject.find('message').text();
                                $(`#${name}`).find('#dialog-caution').html(msg);
                                if (ok)
                                    $('#grid_ds_hosochungtu')[0].triggerToolbar();
                            });
                        }
                    },
                    {
                        id: `btn-close-${name}`,
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
        });
    }

    function funcHieuLuchosochungtu() {
        let id = $("#grid_ds_hosochungtu").jqGrid('getGridParam', 'selrow');
        if (id == null) {
            alert('Chưa chọn hồ sơ muốn Hiệu Lực.!');
            return;
        }

        let name = 'dialog-hieuluc-hosochungtu-pi';
        let title = 'Hiệu lực hồ sơ';
        let content = `
            <div>
                <h3 style="padding: 10px" class="ui-state-highlight ui-corner-all" id="dialog-caution">Có phải bạn muốn hiệu lực hồ sơ này?</h3>
                <div style="display:none" id="wait">
                    <img style="width:30px; height:30px" src="iconcollection/loading.gif"/>
                </div>
            </div>
        `;
        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);

        // create new dialog
        $(`#${name}`).dialog({
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            }
            , buttons:
                [
                    {
                        id: `btn-yes-${name}`,
                        text: "Có",
                        click: function () {
                            let ajaxStart = function () {
                                $("#wait").css("display", "block");
                                $(`#btn-yes-${name}`).button("disable");
                                $(`#btn-close-${name}`).button("disable");
                            };

                            let ajaxComplete = function () {
                                $("#wait").css("display", "none");
                                $(`#btn-close-${name} span`).text("Thoát");
                                $(`#btn-close-${name}`).button("enable");
                            };

                            ajaxStart();
                            //$.post(`Views/hosochungtu/Controller_hosochungtu.ashx?action=hieuluc`, {id: id }, function (result) {
                            //    ajaxComplete();
                            //    let $xmlObject = $(result); 
                            //    let ok = $xmlObject.find('type').text() == '1';
                            //    let msg = $xmlObject.find('message').text();
                            //    $(`#${name}`).find('#dialog-caution').html(msg);
                            //    if (ok)
                            //        $('#grid_ds_hosochungtu')[0].triggerToolbar();
                            //});
                            $.post(`Views/hosochungtu/Controller_hosochungtu.ashx?action=hieuluc`, { id: id }, function (result) {
                                ajaxComplete();

                                let $xmlObject = $(result);
                                let ok = $xmlObject.find('type').text() == '1';
                                let msg = $xmlObject.find('message').text();

                                $(`#${name}`).find('#dialog-caution').html(msg);

                                if (ok) {
                                    let row = $('#grid_ds_hosochungtu').jqGrid('getRowData', id);
                                    let poId = row.c_donhang_id;

                                    $('#grid_ds_hosochungtu')[0].triggerToolbar();

                                    if ($('#grid_solanxuat').attr('id') != null && poId) {
                                        $('#grid_solanxuat').jqGrid('getGridParam', 'postData').poId = poId;
                                        $('#grid_solanxuat')[0].triggerToolbar();
                                    }

                                    if ($('#grid_ds_po').attr('id') != null) {
                                        $('#grid_ds_po').trigger('reloadGrid');
                                    }
                                }
                            });



                        }
                    },
                    {
                        id: `btn-close-${name}`,
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
        });
    }

    function format_hosochungtu_dongghep(cellvalue, options, rowObject) {
        //let type = options.colModel.editoptions.typeLoad;
        cellvalue = !cellvalue ? "" : cellvalue;
        setTimeout(function () {
            let uutien = cellvalue.length <= 0;
            let id = $(rowObject).find('cell').eq(0).text();
            if (uutien) {
                //$(`#${id}`).css('box-shadow', 'rgb(223 248 243) 6px 5px 9px 11px inset');
                //$(`#${id}`).css('box-shadow', 'rgb(200 240 220) 6px 5px 9px 11px inset');
                $(`#${id}`).css('box-shadow', 'rgb(150 225 210) 6px 5px 9px 11px inset');
            }
            else {
                $(`#${id}`).css('box-shadow', '');
            }
        }, 100);

        return `<span title="${cellvalue}">${cellvalue}</span>`;
    };

    function format_hosochungtu_trangthai2(cellvalue, options, rowObject) {
        cellvalue = !cellvalue ? "" : cellvalue;
        setTimeout(function () {
            let bosung = cellvalue == '<%=Helper.Bosung%>';
            let id = $(rowObject).find('cell').eq(0).text();
            if (bosung) {
                $(`#${id} td`).css({ 'color': 'red', 'font-weight': 'bold' });
            }
            else {
                $(`#${id} td`).css({ 'color': '', 'font-weight': '' });
            }
        }, 100);

        return `<span title="${cellvalue}">${cellvalue}</span>`;
    };
    // 
    function format_hosochungtu_trangthaigui(cellvalue, options, rowObject) {
        cellvalue = cellvalue || 'Chưa gửi mail';

        if (cellvalue === 'Đã gửi mail') {
            return `<span style="color:green;font-weight:bold">${cellvalue}</span>`;
        }

        return `<span style="color:red;font-weight:bold">Chưa gửi mail</span>`;
    }
    function resetGrid_hosochungtu($grid) {
        var o = $grid.parent().parent().parent().parent().parent();
        $grid.jqGrid('setGridWidth', o.width(), true);
        $grid.setGridHeight($(o).height() - 87); 
    }
</script>

<uc1:jqGrid ID="grid_ds_hosochungtu"
    Caption="Hồ sơ chứng từ"
    UrlFileAction="Views/hosochungtu/Controller_HoSoChungTu.ashx"
    FilterToolbar="true"
    RowNumbers="true"
    RowNum="100"
    RowList="[100, 200, 500, 1000]"
    BtnPrint="printhosochungtu"
    FuncActive="funcHieuLuchosochungtu"
    FuncKetThuc="funcKetThuchosochungtu"
    OndblClickRow="
        function(rowid) { 
            $(`#edit_grid_ds_hosochungtu`).click();     
        }
    "
    ColModel="[
    {
        fixed: true, name: 'c_donhangchungtu_id'
        , index: 'dh.c_donhangchungtu_id'
        , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
        , key: true
    },
    {
        fixed: true, name: 'c_donhang_id'
        , index: 'dh.c_donhang_id'
        , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
    },
    {
        name: 'trangthai'
        , index: 'dh.trangthai'
        , label: 'Trạng thái'
        , editable: true
        , fixed:true , width: 120
        , edittype: 'select'
        , align:'center'
        , formatter:'trangthai'
        , search : true
        , stype : 'select'
        , editoptions:{disabled:true, value:'SOANTHAO:Soạn Thảo;HIEULUC:Hiệu lực;DAGUIBC:Đã gửi book container;DACOLT:Đã có lịch tàu;DAKEOC:Đã kéo cont/xuất hàng;KETTHUC: Kết thúc' }
        , searchoptions:{sopt:['eq'], value:':[ALL];SOANTHAO:Soạn Thảo;HIEULUC:Hiệu lực;DAGUIBC:Đã gửi book container;DACOLT:Đã có lịch tàu;DAKEOC:Đã kéo cont/xuất hàng;KETTHUC: Kết thúc' }
    },
    {
        name: 'trangthai2'
        , index: 'dh.trangthai2'
        , label: 'Trạng thái BS'
        , editable: true
        , fixed:true , width: 90
        , edittype: 'select'
        , align:'center'
        , formatter:'trangthai'
        , search : true
        , stype : 'select'
        , editoptions:{value:'Moi:-;Bosung:Bổ sung;DAHIEULUC:Đã nhận' }
        , searchoptions:{sopt:['eq'], value:':[ALL];Moi:-;Bosung:Bổ sung;DAHIEULUC:Đã nhận' }
    },
    {
        name: 'trangthai2CP'
        , index: 'dh.trangthai2'
        , label: 'Trạng thái BS'
        , editable: false
        , hidden: true
        , formatter: format_hosochungtu_trangthai2
        , unformat: disable_formatter
    },
    
    {
        fixed: true
        , name: 'ma_dtkd'
        , index: 'kh.md_doitackinhdoanh_id'
        , label: 'Mã số khách'
        , width: 100
        , editable: true
        , edittype: 'text'
        , hidden: false
        , align:'center'
        , editoptions: { disabled: true }
        , stype: 'select'
        , searchoptions:{ sopt:['eq'], dataUrl: 'Controllers/PartnerController.ashx?action=getsearchoption&isncc=0' } 
    },
    {
        fixed: true
        , name: 'sochungtu'
        , index: 'dh2.sochungtu'
        , label: 'Số PO'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
    },
    {
        fixed: true
        , name: 'customer_order_no'
        , index: 'dh2.customer_order_no'
        , label: 'Số order no'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
    },
    {
        fixed: true
        , name: 'cont20'
        , index: 'dh.cont20'
        , label: 'Cont 20'
        , editable: true
        , width: 50
        , edittype: 'text'
        , editoptions: { disabled: true }
        , align:'right'
    },
    {
        fixed: true
        , name: 'cont40'
        , index: 'dh.cont40'
        , label: '40DC'
        , editable: true
        , width: 50
        , edittype: 'text'
        , editoptions: { disabled: true }
        , align:'right'
    },
    {
        fixed: true
        , name: 'cont40HC'
        , index: 'dh.cont40hc'
        , label: '40HC'
        , editable: true
        , width: 50
        , edittype: 'text'
        , editoptions: { disabled: true }
        , align:'right'
    },
    {
        fixed: true
        , name: 'cont45'
        , index: 'dh.cont45'
        , label: '45'
        , editable: true
        , width: 50
        , edittype: 'text'
        , editoptions: { disabled: true }
        , align:'right'
    },
    {
        fixed: true
        , name: 'contLCL'
        , index: 'dh.contLCL'
        , label: 'LCL'
        , editable: true
        , width: 50
        , edittype: 'text'
        , editoptions: { disabled: true }
    },
    {
        fixed: true
        , name: 'dongghep'
        , index: 'dh.dongghep'
        , label: 'Đóng ghép ĐH'
        , editable: true
        , width: 50
        , edittype: 'text'
        , editoptions: { disabled: true }
        , formatter: format_hosochungtu_dongghep
        , unformat: disable_formatter
    },
    {
        name: 'mota'
        , label: 'Mô tả'
        , index: 'dh.mota'
        , fixed:true
        , width: 100
        , editable:true
        , edittype: 'textarea'
    },
    {
        fixed: true
        , name: 'bookingNo'
        , index: 'dh.bookingNo'
        , label: 'Booking no'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: false }
    },
    {
        name: 'ngayETD'
        , label: 'Ngày ETD'
        , index: 'dh.ngayETD'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        name: 'ngayETA'
        , label: 'Ngày ETA'
        , index: 'dh.ngayETA'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        name: 'ngayBHXN'
        , label: 'Ngày bán hàng XNXH'
        , index: 'dh.ngayBHXN'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: {  dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        name: 'ngayXuong'
        , label: 'Ngày xưởng cung cấp chi tiết'
        , index: 'dh.ngayXuong'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        name: 'ngayCutOff'
        , label: 'Ngày cut off SI của htau'
        , index: 'dh.ngayCutOff'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        name: 'ngaypass'
        , label: 'Ngày pass kiểm hóa'
        , index: 'dh2.ngaypass'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        fixed: true
        , name: 'shipmenttime'
        , index: 'dh2.shipmenttime'
        , label: 'Shipment time'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
        , align:'center'
    },
    {
        fixed: true
        , name: 'hangiaohang_po'
        , index: 'dh2.hangiaohang_po'
        , label: 'NXH của xưởng'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
        , align:'center'
    },
    {
        name: 'ngaydieuchinh'
        , label: 'Ngày điều chỉnh'
        , index: 'dh.ngaydieuchinh'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#ngaydieuchinh', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        name: 'ngaychuyenhoso'
        , label: 'Ngày chuyển hồ sơ'
        , index: 'dh.ngaychuyenhoso'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        fixed: true
        , name: 'nguoilap'
        , index: 'dh2.nguoilap'
        , label: 'NV bán hàng'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
    },
    {
        fixed: true
        , name: 'nhanvienCT'
        , index: 'dh2.nhanvienCT'
        , label: 'NV chứng từ'
        , editable: true
        , width: 100
        , edittype: 'select'
        , editoptions: { value: nvcts_hosochungtu }
    },
    {
        fixed: true
        , name: 'Forwarder'
        , index: 'spd.Forwarder'
        , label: 'Forwarder'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
    },
    {
        name: 'ngayBookCont'
        , label: 'Ngày book container'
        , index: 'dh.ngayBookCont'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        fixed: true
        , name: 'POD'
        , index: 'spd.POD'
        , label: 'Port of discharge'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
    },
    {
        name: 'ngayKeoCont'
        , label: 'Ngày kéo cont/xuất hàng'
        , index: 'dh.ngayKeoCont'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
        , align:'center'
    },
    {
        name: 'ghichusau'
        , label: 'Ghi chú sau'
        , index: 'dh.ghichusau'
        , fixed:true
        , width: 100
        , editable:true
        , edittype: 'textarea'
    },
    {
        fixed: true, name: 'ngaytao'
        , index: 'ngaytao'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
        , align:'center'
    },
    {
        fixed: true, name: 'nguoitao'
        , label: 'Người import'
        , index: 'nguoitao'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: false
        , editrules:{ edithidden : true }
    },
    {
        fixed: true, name: 'ngaycapnhat'
        , index: 'ngaycapnhat'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
        , align:'center'
    },
    {
        fixed: true, name: 'nguoicapnhat'
        , index: 'nguoicapnhat'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true 
        , editrules:{ edithidden : true }
    },
    {
        fixed: true, name: 'hoatdong', hidden: true
        , index: 'hoatdong'
        , width: 100
        , editable: false
        , edittype: 'checkbox'
        , editoptions:{ defaultValue: 'True' }
        , editrules:{ edithidden : true }
        , align:'center'
    },
    {
    fixed: true
    , name: 'nhacungung'
    , index: 'nhacungung'
    , label: 'Nhà Cung Ứng'
    , width: 120
    , editable: false
    , edittype: 'text'
    , align: 'center'
    , search: false
    , sortable: false
},
    {
    fixed: true
    , name: 'trangthaigui_mail'
    , index: 'trangthaigui_mail'
    , label: 'Trạng thái gửi mail'
    , width: 130
    , editable: false
    , edittype: 'text'
    , align: 'center'
    , formatter: format_hosochungtu_trangthaigui
    , search: true
    , stype: 'select'
    , searchoptions:{ sopt:['eq'], value:':[ALL];Đã gửi mail:Đã gửi mail;Chưa gửi mail:Chưa gửi mail' }
},
    {
    fixed: true
    , name: 'ngaykiemhangpass'
    , index: 'dh.ngaykiemhangpass'
    , label: 'Ngày kiểm hàng pass'
    , width: 120
    , editable: true
    , edittype: 'text'
    , align: 'center'
    , editoptions: { 
        dataInit : function (elem) { 
            $(elem).datepicker({ 
                changeMonth: true, 
                changeYear: true, 
                dateFormat: 'dd/mm/yy' 
            }); 
        } 
    }
    , search: true
    , stype: 'text'
    , searchoptions: { 
        sopt: ['eq', 'ne']
        , dataInit: function (elem) { 
            $(elem).datepicker({ 
                changeYear: true,
                changeMonth: true,
                dateFormat:'dd/mm/yy',
                onSelect: function(dateText, inst) {
                    if (this.id.substr(0, 3) === 'gs_') {
                        setTimeout(function () {
                            $('#grid_ds_hosochungtu')[0].triggerToolbar();
                        }, 100);
                    }
                }
            });
        } 
    }
},
{
    fixed: true
    , name: 'ketquakiemhang'
    , index: 'dh.ketquakiemhang'
    , label: 'Kết quả kiểm hàng'
    , width: 130
    , editable: true
    , edittype: 'select'
    , formatter: 'select'
    , align: 'center'
    , editoptions: { value: ':;Dat:Đạt;KhongDat:Không đạt;ChoKiem:Chờ kiểm' }
    , search: true
    , stype: 'select'
    , searchoptions:{ sopt:['eq'], value:':[ALL];Dat:Đạt;KhongDat:Không đạt;ChoKiem:Chờ kiểm' }
}
    ]"
    GridComplete=" 
        $(this).jqGrid('showCol', 'cb'); 
        resetGrid_hosochungtu($(this));
        if($('#md_doitackinhdoanh_id').attr('id') == null) { $('#grid_ds_hosochungtu-pager_left .ui-icon-plus').click(); 
        $.jgrid.hideModal('#editmodgrid_ds_hosochungtu', { gbox: '#gbox_grid_ds_hosochungtu'}); }; 
        id_inc_hosochungtu ?  $(this).setSelection(id_inc_hosochungtu, false) : null;
    "
    Height="170"
    MultiSelect="true"
    ShowAdd="false"
    ShowEdit="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
    ShowDel="<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
    AddFormOptions=" 
        width:350,
        beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
        errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
	    },
	    afterSubmit: function(rs, postdata){
            return showMsgDialog(rs);
        }, 
        afterShowForm: function(){
        } 
	"
    EditFormOptions="
	    width:350,
	    beforeShowForm: function (formid) {
            formid.css('height', window.innerHeight/2 + window.innerHeight/3); 
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        }, 
		errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
	    },
        afterSubmit: function(rs, postdata){
            var result = showMsgDialog(rs);

            setTimeout(function(){
                $('#grid_ds_hosochungtu').trigger('reloadGrid');

                if ($('#grid_ds_po').attr('id') != null) {
                    $('#grid_ds_po').trigger('reloadGrid');
                }
            }, 300);

            return result;
        },
        afterShowForm: function(){
        
        } 
    "
    ViewFormOptions="
        width:350,
	    beforeShowForm: function (formid) {
            formid.css('height', window.innerHeight/2 + window.innerHeight/3); 
            formid.find('table.EditTable').css('table-layout', 'auto');
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
	    errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
	}"
DelFormOptions="
    width: 420,

    beforeShowForm: function (formid) {
        var dialog = formid.closest('div.ui-jqdialog');

        formid.css('overflow', 'hidden');

        var htmlLyDo = ''
            + '&lt;tr id=&quot;tr_lydoxoa_hsct&quot;&gt;'
            + '    &lt;td colspan=&quot;2&quot; style=&quot;padding-top:10px; width:100%;&quot;&gt;'
            + '        &lt;div id=&quot;box_lydoxoa_hsct&quot; style=&quot;display:block; width:100%; box-sizing:border-box; padding:8px; background:#fffbe6; border:1px solid #e0c36b;&quot;&gt;'
            + '            &lt;div style=&quot;display:block; width:100%; font-weight:bold; margin-bottom:8px; color:#8a5a00; white-space:nowrap;&quot;&gt;'
            + '                Lý do xóa hồ sơ chứng từ'
            + '            &lt;/div&gt;'
            + '            &lt;textarea id=&quot;lydoxoa_hsct&quot; '
            + '                style=&quot;width:100%; height:85px; resize:vertical; display:block; box-sizing:border-box;&quot; '
            + '                placeholder=&quot;Nhập lý do xóa hồ sơ chứng từ...&quot;&gt;&lt;/textarea&gt;'
            + '        &lt;/div&gt;'
            + '    &lt;/td&gt;'
            + '&lt;/tr&gt;';

        if ($('#tr_lydoxoa_hsct', formid).length &lt;= 0) {
            var trDelMsg = $('.delmsg', formid).closest('tr');

            if (trDelMsg.length &gt; 0) {
                trDelMsg.after(htmlLyDo);
            }
            else {
                $('table', formid).append(htmlLyDo);
            }
        }
        $('#lydoxoa_hsct', formid).val('');

        setTimeout(function () {
            var w = dialog.outerWidth();
            var left = ($(window).width() - w) / 2 + $(window).scrollLeft();
            left = Math.max(10, left);

            dialog.css({
                top: ($(window).scrollTop() + 50) + 'px',
                left: left + 'px'
            });
        }, 50);
    },

    beforeSubmit: function(postdata, formid) {
        var lydo = $('#lydoxoa_hsct', formid).val();

        if (lydo == null || $.trim(lydo).length &lt;= 0) {
            return [false, 'Vui lòng nhập lý do xóa hồ sơ chứng từ.'];
        }

        return [true, ''];
    },

    onclickSubmit: function(options, postdata) {
        var lydo = $('#lydoxoa_hsct').val();

        return {
            lydoxoa_hsct: $.trim(lydo)
        };
    },

    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText;
    }, 

    afterSubmit: function(rs, postdata){
        var result = showMsgDialog(rs);

        $('#lydoxoa_hsct').val('');

        setTimeout(function(){
            $('#grid_ds_hosochungtu').trigger('reloadGrid');
        }, 300);

        return result;
    }
"
 OnSelectRow="function(ids) {
		if(ids == null)
			ids=0;
		id_inc_hosochungtu = ids;
        let row = $('#grid_ds_hosochungtu').getRowData(ids);
        $('#grid_ds_chitiethsct').jqGrid('getGridParam', 'postData').poId = row.c_donhang_id;
        $('#grid_ds_chitiethsct')[0].triggerToolbar();
        $('#grid_dinhkemhsct').jqGrid('getGridParam', 'postData').poId = id_inc_hosochungtu;
        $('#grid_dinhkemhsct')[0].triggerToolbar();

        $('#grid_solanbosung').jqGrid('getGridParam', 'postData').poId = ids;
        $('#grid_solanbosung')[0].triggerToolbar();

        if ($('#grid_solanxuat').attr('id') != null) {
            $('#grid_solanxuat').jqGrid('getGridParam', 'postData').poId = row.c_donhang_id;
            $('#grid_solanxuat')[0].triggerToolbar();
        }

    }"
   

    runat="server" />

<script type="text/javascript">
    /*
        CHỨC NĂNG GỬI MAIL NHÀ CUNG ỨNG
        Yêu cầu:
        1. Checkbox trên jqGrid luôn hiển thị.
        2. Người dùng tick chọn các dòng hồ sơ chứng từ.
        3. Bấm nút gửi mail Nhà Cung Ứng.
        4. Hiện bảng xác nhận.
        5. Bấm Ok mới gửi mail.
        6. Không còn chức năng ẩn/hiện checkbox.
    */

    function hsct_TachNhaCungUng(value) {
        value = value || '';

        // Cột Nhà Cung Ứng có thể trả về dạng NCC1<br/>NCC2
        value = value.replace(/<br\s*\/?>/gi, ',');

        // Decode HTML nếu jqGrid trả về HTML
        value = $('<div/>').html(value).text();

        let arr = value
            .split(/[,\n;]+/)
            .map(function (x) { return $.trim(x); })
            .filter(function (x) { return x.length > 0; });

        // Loại trùng mã nhà cung ứng
        let rs = [];
        for (let i = 0; i < arr.length; i++) {
            if (rs.indexOf(arr[i]) < 0) {
                rs.push(arr[i]);
            }
        }

        return rs;
    }

    function hsct_LayNhomGuiMailTheoNCC() {
        let selectedRows = $('#grid_ds_hosochungtu').jqGrid('getGridParam', 'selarrrow') || [];

        let result = {
            selectedRows: selectedRows,
            nhomTheoNCC: {},
            dongKhongCoNCC: []
        };

        for (let i = 0; i < selectedRows.length; i++) {
            let rowid = selectedRows[i];
            let row = $('#grid_ds_hosochungtu').jqGrid('getRowData', rowid);

            let hsctId = row.c_donhangchungtu_id;
            if (!hsctId) {
                hsctId = rowid;
            }

            let nccs = hsct_TachNhaCungUng(row.nhacungung);

            if (nccs.length <= 0) {
                result.dongKhongCoNCC.push(row.sochungtu || hsctId);
                continue;
            }

            for (let j = 0; j < nccs.length; j++) {
                let ncc = nccs[j];

                if (!result.nhomTheoNCC[ncc]) {
                    result.nhomTheoNCC[ncc] = [];
                }

                if (result.nhomTheoNCC[ncc].indexOf(hsctId) < 0) {
                    result.nhomTheoNCC[ncc].push(hsctId);
                }
            }
        }

        return result;
    }

    function hsct_XacNhanGuiMailNCC(callback) {
        let data = hsct_LayNhomGuiMailTheoNCC();

        if (!data.selectedRows || data.selectedRows.length <= 0) {
            alert('Chưa chọn dòng cần gửi mail.');
            return;
        }

        if (data.dongKhongCoNCC.length > 0) {
            alert('Có dòng chưa có Nhà Cung Ứng: ' + data.dongKhongCoNCC.join(', '));
            return;
        }

        let dsNCC = Object.keys(data.nhomTheoNCC);

        if (dsNCC.length <= 0) {
            alert('Không tìm thấy Nhà Cung Ứng để gửi mail.');
            return;
        }

        let name = 'dialog-xacnhan-gui-mail-ncc-hsct';
        $('#' + name).remove();

        let content = `
            <div style="padding:10px;">
                <div style="font-weight:bold; margin-bottom:8px;">
                    Xác nhận gửi mail
                </div>

                <div>
                    Anh đã chọn <b>${data.selectedRows.length}</b> hồ sơ chứng từ.
                </div>

                <div style="margin-top:6px;">
                    Số Nhà Cung Ứng sẽ gửi: <b>${dsNCC.length}</b>
                </div>

                <div style="margin-top:8px;">
                    Anh có chắc muốn gửi mail cho <b>Nhà Cung Ứng</b> theo các dòng đã chọn không?
                </div>
            </div>
        `;

        $('body').append(`<div title="Xác nhận gửi mail" id="${name}">${content}</div>`);

        $('#' + name).dialog({
            width: 420,
            modal: true,
            open: function () {
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            },
            buttons: [
                {
                    id: 'btn-ok-' + name,
                    text: 'Ok',
                    click: function () {
                        $(this).dialog('destroy').remove();

                        if (typeof callback === 'function') {
                            callback();
                        }
                    }
                },
                {
                    id: 'btn-close-' + name,
                    text: 'Hủy',
                    click: function () {
                        $(this).dialog('destroy').remove();
                    }
                }
            ]
        });
    }

    function hsct_GuiMailTheoNCCTrenGrid(funcEnd) {
        let data = hsct_LayNhomGuiMailTheoNCC();

        if (!data.selectedRows || data.selectedRows.length <= 0) {
            alert('Chưa chọn dòng cần gửi mail.');
            return;
        }

        if (data.dongKhongCoNCC.length > 0) {
            alert('Có dòng chưa có Nhà Cung Ứng: ' + data.dongKhongCoNCC.join(', '));
            return;
        }

        let dsNCC = Object.keys(data.nhomTheoNCC);

        if (dsNCC.length <= 0) {
            alert('Không tìm thấy Nhà Cung Ứng để gửi mail.');
            return;
        }

        let btn = $('#mailncc_grid_ds_hosochungtu');
        btn.addClass('ui-state-disabled');

        let index = 0;
        let ketQua = [];

        function guiTiepTheo() {
            if (index >= dsNCC.length) {
                btn.removeClass('ui-state-disabled');

                $('#grid_ds_hosochungtu')[0].triggerToolbar();

                if (typeof funcEnd === 'function') {
                    funcEnd();
                }

                alert('Đã gửi mail xong:\n' + ketQua.join('\n'));
                return;
            }

            let ncc = dsNCC[index];
            let hsctIds = data.nhomTheoNCC[ncc];
            let hsctIdDauTien = hsctIds[0];

            // Bước 1: tạo nội dung hồ sơ chứng từ
            $.ajax({
                url: 'Views/hosochungtu/printHSCT_All.aspx?mail=1&download=0',
                type: 'POST',
                data: {
                    id: hsctIdDauTien,
                    ids: hsctIds.join(',')
                },
                success: function (rs1) {
                    if (!rs1 || rs1.indexOf('Không có dữ liệu') >= 0) {
                        ketQua.push('Lỗi ' + ncc + ': Không chiết xuất được dữ liệu.');
                        index++;
                        guiTiepTheo();
                        return;
                    }

                    // Bước 2: gửi mail cho đúng NCC
                    $.ajax({
                        url: 'Views/hosochungtu/Controller_HoSoChungTu.ashx?action=sendMail',
                        type: 'POST',
                        data: {
                            id: hsctIdDauTien,
                            ids: hsctIds.join(','),
                            nvbhs: '',
                            nccs: ncc,
                            tt: utf8ToBase64(rs1),
                            tt_base64: '1'
                        },
                        success: function (result) {
                            let $xmlObject = $(result);
                            let ok = $xmlObject.find('type').text() == '1';
                            let msg = $xmlObject.find('message').text();

                            if (ok) {
                                ketQua.push('OK ' + ncc + ': ' + hsctIds.length + ' hồ sơ');
                            } else {
                                ketQua.push('Lỗi ' + ncc + ': ' + (msg || result));
                            }

                            index++;
                            guiTiepTheo();
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            ketQua.push('Lỗi ' + ncc + ': ' + (jqXHR.responseText || errorThrown || textStatus));
                            index++;
                            guiTiepTheo();
                        }
                    });
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    ketQua.push('Lỗi tạo dữ liệu ' + ncc + ': ' + (jqXHR.responseText || errorThrown || textStatus));
                    index++;
                    guiTiepTheo();
                }
            });
        }

        guiTiepTheo();
    }

    $(document).ready(function () {
        var $gridHSCT = $('#grid_ds_hosochungtu');

        if ($gridHSCT.length <= 0) {
            return;
        }

        // Nút cập nhật ngày BHXN
        if ($('#capnhatnbhxn_grid_ds_hosochungtu').length <= 0) {
            $gridHSCT.jqGrid('navButtonAdd', '#grid_ds_hosochungtu-pager',
                {
                    id: 'capnhatnbhxn_grid_ds_hosochungtu',
                    caption: '',
                    buttonicon: 'ui-icon-lightbulb',
                    title: 'Cập nhật ngày bán hàng xác nhận xuất hàng',
                    onClickButton: funcCapNhatNBHXNhosochungtu
                });
        }

        // Nút gửi mail Nhà Cung Ứng
        if ($('#mailncc_grid_ds_hosochungtu').length <= 0) {
            $gridHSCT.jqGrid('navButtonAdd', '#grid_ds_hosochungtu-pager',
                {
                    id: 'mailncc_grid_ds_hosochungtu',
                    caption: '',
                    buttonicon: 'ui-icon-mail-closed',
                    title: 'Gửi mail cho Nhà Cung Ứng theo dòng đã chọn',
                    onClickButton: function () {
                        hsct_XacNhanGuiMailNCC(function () {
                            hsct_GuiMailTheoNCCTrenGrid(function () {
                                $gridHSCT.jqGrid('resetSelection');
                            });
                        });
                    }
                });
        }
    });
</script>

