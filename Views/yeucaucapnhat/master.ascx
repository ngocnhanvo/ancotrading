<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_yeucaucapnhat_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<script type="text/javascript">
    var yeucaucapnhat_value_dtkd = `<%=yeucaucapnhat_value_dtkd%>`;

    function guiphieu_yeucaucapnhatHangHoa() {
        
        let idsel = $('#grid_ds_yeucaucapnhat').jqGrid('getGridParam', 'selrow');

        if (!idsel) {
            alert('Hãy chọn một phiếu mà bạn muốn gửi!');
            return;
        }

        let name = 'dialog-guiphieu-yeucaucapnhat-pi';
        let title = 'Gửi phiếu yêu cầu NCC cập nhật thông tin SP';
        let content = `
            <div>
                <h3 style="padding: 10px" class="ui-state-highlight ui-corner-all" id="dialog-caution">Thực hiện chức năng này?</h3>
                <div style="display:none" id="wait">
                    <img style="width:30px; height:30px" src="iconcollection/loading.gif"/>
                </div>
            </div>
        `;
        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);

        $(`#${name}`).dialog({
            modal: true
            , width: 300
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            }
            , buttons: [
                {
                    id: `btn-yes-${name}`,
                    text: "Gửi đi",
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
                        $.post(`Views/yeucaucapnhat/Controller_YeuCauCapNhat.ashx?action=guiphieu`, { id: idsel }, function (result) {
                            ajaxComplete();
                            let $xmlObject = $(result);
                            let ok = $xmlObject.find('type').text() == '1';
                            let msg = $xmlObject.find('message').text();
                            $(`#${name}`).find('#dialog-caution').html(msg);
                            if (ok)
                                $('#grid_ds_yeucaucapnhat')[0].triggerToolbar();
                        })
                            .fail(function (xhr, status, error) {
                                ajaxComplete();
                                let errorMessage = "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại đường truyền.";
                                if (xhr.status === 404) errorMessage = "Đường dẫn (URL) không tồn tại.";
                                if (xhr.status === 500) errorMessage = "Lỗi hệ thống từ phía Server (Internal Server Error).";
                                $(`#${name}`).find('#dialog-caution').html(errorMessage);
                            });
                    }
                }
                , {
                    id: `#btn-close-${name}`,
                    text: "Thoát",
                    click: function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            ]
        });
    }

    function funcHieuLucYCCapNhat() {
        let id = $("#grid_ds_yeucaucapnhat").jqGrid('getGridParam', 'selrow');
        if (id == null) {
            alert('Chưa chọn phiếu muốn Hiệu Lực.!');
            return;
        }

        let name = 'dialog-hieuluc-yeucaucapnhat-pi';
        let title = 'Hiệu lực phiếu yêu cầu NCC cập nhật thông tin SP';
        let content = `
            <div>
                <h3 style="padding: 10px" class="ui-state-highlight ui-corner-all" id="dialog-caution">Thực hiện chức năng này?</h3>
                <div style="display:none" id="wait">
                    <img style="width:30px; height:30px" src="iconcollection/loading.gif"/>
                </div>
            </div>
        `;
        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);

        // create new dialog
        $(`#${name}`).dialog({
            modal: true
            , width: 310
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
                            $.post(`Views/yeucaucapnhat/Controller_YeuCauCapNhat.ashx?action=hieuluc`, { id: id }, function (result) {
                                let $xmlObject = $(result);
                                let ok = $xmlObject.find('type').text() == '1';
                                let msg = $xmlObject.find('message').text();
                                $(`#${name}`).find('#dialog-caution').html(msg);
                                if (ok) {
                                    $('#grid_ds_yeucaucapnhat')[0].triggerToolbar();
                                    setTimeout(() => {
                                        $(`#btn-close-${name}`).click();
                                        guiphieu_yeucaucapnhatHangHoa();
                                        ajaxComplete();
                                    }, 2000);
                                }
                                else {
                                    ajaxComplete();
                                }
                            })
                                .fail(function (xhr, status, error) {
                                    ajaxComplete();
                                    let errorMessage = "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại đường truyền.";
                                    if (xhr.status === 404) errorMessage = "Đường dẫn (URL) không tồn tại.";
                                    if (xhr.status === 500) errorMessage = "Lỗi hệ thống từ phía Server (Internal Server Error).";
                                    $(`#${name}`).find('#dialog-caution').html(errorMessage);
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

    function in_yeucaucapnhatHangHoa() {
        let windowSize = "width=700,height=700,scrollbars=yes";
        let poId = $('#grid_ds_yeucaucapnhat').jqGrid('getGridParam', 'selrow');
        if (!poId) {
            alert('Không tìm thấy dòng đã chọn');
            return;
        }

        let name = 'dialog-print-yeucaucapnhat';
        let title = 'Trích xuất dữ liệu';
        let content = `
        <div style="width: 100%; height: 100%; max-width: 500px; padding-bottom: 10px; background-color: #ffffff; overflow: hidden;box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-radius: 8px;">
            <table style="width: 100%; border-collapse: collapse; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
                <tr>
                    <td style="padding: 14px 16px; width: 90px; vertical-align: middle;">
                        <label style="font-weight: 600; color: #4a5568; font-size: 14px;">Tên table</label>
                    </td>
                    <td style="padding: 14px 16px; vertical-align: middle;">
                        <select id="sel_table_yeucaucapnhat" style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; color: #334155; background-color: #fff; outline: none; box-sizing: border-box;">
                            <option>Đang tải...</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td style="padding: 14px 16px; vertical-align: middle;">
                        <label style="font-weight: 600; color: #4a5568; font-size: 14px;">Mã nhận diện</label>
                    </td>
                    <td style="padding: 14px 16px; vertical-align: middle;">
                        <input type="text" id="inp_manhandien_yeucaucapnhat" placeholder="Nhập mã nhận diện..." style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; color: #334155; outline: none; box-sizing: border-box;"/>
                    </td>
                </tr>
            </table>
        </div>
        `;
        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);
        let $select = $('#sel_table_yeucaucapnhat');
        let $manhandien = $('#inp_manhandien_yeucaucapnhat');
        let nameParent = '#' + name;
        $(nameParent).dialog({
            modal: true,
            width: 420,
            open: function (event, ui) {
                const url = $('#grid_ds_yeucaucapnhat').jqGrid('getGridParam', 'url');
                $select.empty();
                $.post(url, { oper: 'loadDT', id: poId }, function (rs) {
                    const data = JSON.parse(rs);
                    $.each(data, function (index, item) {
                        console.log(item);
                        $select.append(`<option value="${item.table}">${item.ten}</option>`);
                    });
                });
            },
            close: function () {
                $('#btn-print-close').click();
            },
            buttons: [
                {
                    id: "btn-print-ok",
                    text: "In",
                    click: function () {
                        const windowSize = "width=700,height=700,scrollbars=yes";
                        let printURL = `Views/yeucaucapnhat/in/phieuYCcapnhatHH.aspx?id=${poId}&loai=${$select.val()}&mnd=${$manhandien.val()}`;
                        window.open(printURL, `In Thông Tin ${$select.val()}`, windowSize);
                    }
                }
                , {
                    id: "btn-print-close",
                    text: "Thoát",
                    click: function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            ]
        });
    }
</script>

<uc1:jqGrid ID="grid_ds_yeucaucapnhat"
    Caption="Phiếu yêu cầu cập nhật hàng hóa gửi NCC"
    UrlFileAction="Views/yeucaucapnhat/Controller_YeuCauCapNhat.ashx"
    FilterToolbar="true"
    RowNumbers="true"
    FuncActive="funcHieuLucYCCapNhat"
    GuiDonHang="guiphieu_yeucaucapnhatHangHoa"
    BtnPrint="in_yeucaucapnhatHangHoa"
    OndblClickRow="
        function(rowid) { 
            $(`#edit_grid_ds_yeucaucapnhat`).click();     
        }
    "
    ColModel="[
    {
        fixed: true, name: 'md_phieuthongtinsanpham_id'
        , index: 'tt.md_phieuthongtinsanpham_id'
        , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
        , key: true
    },
    {
        name: 'trangthai1'
        , index: 'tt.trangthai1'
        , label: 'Trạng thái'
        , editable: false
        , fixed:true , width: 100
        , edittype: 'text'
        , align:'center'
        , formatter:'imagestatus'
        , search : true
        , stype : 'select'
        , searchoptions:{sopt:['eq'], value:':[ALL];SOANTHAO:SOẠN THẢO;HIEULUC:HIỆU LỰC' }
    },
    {
         fixed: true, name: 'trangthai2'
         , label: 'TT NCC'
         , index: 'tt.trangthai2'
         , editable: false
         , width: 100
         , edittype: 'text'
         , align:'center'
         , formatter: 'trangthai'
	     , search : true
         , stype : 'select'
	     , formoptions: { colpos: 1, rowpos: 2 }
         , searchoptions:{sopt:['eq'], value:':[ALL];CHUAGUI:Chưa gửi;TUCHOI:Từ chối;DAGUI:Đã gửi;DANHAN:Đã xem;DAHIEULUC:Đã nhận' }
    },
    {
        fixed: true
        , name: 'tieude'
        , index: 'tt.tieude'
        , label: 'Tiêu đề'
        , width: 100
        , editable: true
        , edittype: 'text'
        , hidden: false
        , align:'left'
    },
    {
        fixed: true
        , name: 'noidung'
        , index: 'tt.noidung'
        , label: 'Nội dung'
        , editable: true
        , width: 100
        , edittype: 'textarea'
    },
    {
        fixed: true, name: 'dtkd_id'
        , index: 'dtkd.ma_dtkd'
        , label: 'NCC'
        , editable: true
        , width: 100
        , edittype: 'select'
        , editoptions: { style: 'width:200px', value: yeucaucapnhat_value_dtkd }
    },
    {
        fixed: true, name: 'ngaylap'
        , index: 'ngaylap'
        , label: 'Ngày lập'
        , width: 100
        , editable: false
        , edittype: 'text'
        , hidden: false 
        , editrules: { edithidden : true }
        , align: 'center'
    },
    {
        fixed: true, name: 'ngaygui'
        , index: 'ngaygui'
        , label: 'Ngày gửi'
        , width: 100
        , editable: false
        , edittype: 'text'
        , hidden: false 
        , editrules: { edithidden : true }
        , align: 'center'
    },
    {
        fixed: true, name: 'ngaynhan'
        , index: 'ngaynhan'
        , label: 'Ngày nhận'
        , width: 100
        , editable: false
        , edittype: 'text'
        , hidden: false 
        , editrules: { edithidden : true }
        , align: 'center'
    },
    {
        fixed: true, name: 'ngayapdung'
        , index: 'ngayapdung'
        , label: 'Ngày áp dụng'
        , width: 100
        , editable: false
        , edittype: 'text'
        , hidden: false 
        , editrules: { edithidden : true }
        , align: 'center'
    },
    {
        fixed: true, name: 'mota'
        , index: 'tv.mota'
        , label: 'Mô tả/Diễn giải'
        , width: 300
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
    },
    {
        fixed: true, name: 'nguoitao'
        , label: 'Người tạo'
        , index: 'nguoitao'
        , width: 100
        , editable:false
        , edittype: 'text'
        , hidden: true
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
    }
    ]"
    GridComplete="var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 87); $(this).jqGrid('setSelection', id_inc_yeucaucapnhat);"
    Height="170"
    MultiSelect="false"
    ShowAdd="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
    ShowEdit="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
    ShowDel="<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
    AddFormOptions=" 
        width:350,
        beforeShowForm: function (formid) {
            formid.find('#dtkd_id').prop('disabled', false);
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
        errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
	    },
	    afterSubmit: function(rs, postdata) {
            const msg = showMsgDialog(rs);
            const ok = msg[0];
            if(ok) {
                const idnew = msg[1].split('#')[1];
                id_inc_yeucaucapnhat = idnew;
                $('#cData').click();
                setTimeout(()=>{ taotudongChiTietLog($('#grid_ds_yeucaucapnhatDH')); }, 200);
            }
            return msg;
        }, 
        afterShowForm: function(){
        } 
	"
    EditFormOptions="
	    width:350,
	    beforeShowForm: function (formid) {
            formid.find('#dtkd_id').prop('disabled', true);
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
    ViewFormOptions="
	    beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
	    errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
	}"
    DelFormOptions="
	    beforeShowForm: function (formid) {
            formid.closest('div.ui-jqdialog').dialogCenter(); 
        },
	    errorTextFormat:function(data) { 
            return 'Lỗi: ' + data.responseText 
	    }, 
        afterSubmit: function(rs, postdata){
            const msg = showMsgDialog(rs);
            const ok = msg[0];
            if(ok) {
                id_inc_yeucaucapnhat = null;
            }
            return msg;
        }
	"
    OnSelectRow="function(ids) {
		if(ids == null)
			ids=0;
		id_inc_yeucaucapnhat = ids;
        $('#grid_ds_yeucaucapnhatDH')[0].triggerToolbar();
        $('#grid_ds_yeucaucapnhatDH2')[0].triggerToolbar();
    }"
    runat="server" />

<script>
    $("#grid_ds_yeucaucapnhat").jqGrid('navGrid', "#grid_ds_yeucaucapnhat-pager").jqGrid('navButtonAdd', "#grid_ds_yeucaucapnhat-pager",
        {
            caption: "",
            buttonicon: "ui-icon-refresh",
            onClickButton: function () {
                const name = `lammoitrangthai_yeucaucapnhat`;
                $('body').append(`
	                <div title='Kiểm tra trạng thái NCC' id='${name}'>
		                <div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
		                <div id='dialog-caution'>Thực hiện chức năng này?</div>
	                </div>
                `);
                $(`#${name}`).dialog({
                    modal: true
                    , width: 500
                    , open: function (event, ui) {
                        //hide close button.
                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    }
                    , buttons: [
                        {
                            id: `btn-yes-${name}`,
                            text: "Đồng ý",
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
                                $.post(`Views/yeucaucapnhat/Controller_YeuCauCapNhat.ashx?action=kiemtraTTGui`, { id: '' }, function (result) {
                                    let $xmlObject = $(result);
                                    let ok = $xmlObject.find('type').text() == '1';
                                    let msg = $xmlObject.find('message').text();
                                    $(`#${name}`).find('#dialog-caution').html(msg);
                                    if (ok) {
                                        $('#grid_ds_yeucaucapnhat')[0].triggerToolbar();
                                    }
                                    ajaxComplete();
                                })
                                    .fail(function (xhr, status, error) {
                                        ajaxComplete();
                                        let errorMessage = "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại đường truyền.";
                                        if (xhr.status === 404) errorMessage = "Đường dẫn (URL) không tồn tại.";
                                        if (xhr.status === 500) errorMessage = "Lỗi hệ thống từ phía Server (Internal Server Error).";
                                        $(`#${name}`).find('#dialog-caution').html(errorMessage);
                                    });
                            }
                        }
                        , {
                            id: `btn-close-${name}`,
                            text: "Thoát",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
                });
            },
            title: "Kiểm tra trạng thái NCC",
            cursor: "pointer"
        });
</script>
