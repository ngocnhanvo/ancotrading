<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_tienve_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<script type="text/javascript">
    var tienve_value_dtkd = `<%=tienve_value_dtkd%>`;

    function printTienVe() {
        let piId = $('#grid_ds_tienve').jqGrid('getGridParam', 'selrow');
        let name = 'dialog-print-tienve-pi';
        let title = 'Trích xuất dữ liệu';
        let content = `
            <table style="width:100%">
            <tr>
                <td>
                    <input id="printTienVe" type="radio" name="rdoPrintType" checked="checked" />
                    <label for="printTienVe">Chiết xuất tiền về</label>
                </td>
            </tr>
            </table>
        `;

        $('body').append(`<div title="${title}" id="${name}">${content}</div>`);
        $(`#${name}`).dialog({
            width: 300,
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            }
            , buttons: [
                {
                    id: `btn-print-ok-${name}`,
                    text: "In",
                    click: function () {
                        let printType = $('input[name=rdoPrintType]:checked', `#${name}`).attr('id');
                        let printURL = "Views/tienve/";
                        let windowSize = "width=700,height=700,scrollbars=yes";
                        if (typeof printType == 'undefined') {
                            alert(`Chưa chọn kiểu in`);
                            return;
                        }
                        
                        printURL += `${printType}.aspx?id=${piId}&download=0`;
                        window.open(printURL, "Chiết xuất tiền về", windowSize);
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

    function funcActiveTienVe() {
        let id = $("#grid_ds_tienve").jqGrid('getGridParam', 'selrow');
        if (id == null) {
            alert('Chưa chọn phiếu muốn hiệu lực.!');
            return;
        }

        let msg = "Có phải bạn muốn hiệu lực phiếu thu này.?";
        let p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
        let h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

        // append dialog-taoky to body
        $('body').append('<div title="Thông Báo" id=\"dialog-active-phieuthu\">' + h3 + '</div>');

        // create new dialog
        $('#dialog-active-phieuthu').dialog({
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            }
            , buttons:
                [
                    {
                        id: "btn-active-phieuthu",
                        text: "Có",
                        click: function () {
                            $("#dialog-caution").ajaxStart(function () {
                                $("#wait").css("display", "block");
                                $("#btn-active-phieuthu").button("disable");
                                $("#btn-close").button("disable");
                            });

                            $("#dialog-caution").ajaxComplete(function () {
                                $("#wait").css("display", "none");
                                $("#btn-close span").text("Thoát");
                                $("#btn-close").button("enable");
                            });

                            $.get("Controllers/ThuChiController.ashx?action=activephieuthu&id=" + id, function (result) {
                                //$('#dialog-caution').css({ 'color': 'green' });
                                $('#dialog-active-phieuthu').find('#dialog-caution').html(result);
                                $('#grid_ds_tienve').jqGrid().trigger('reloadGrid');
                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
        });
    }
</script>

<uc1:jqGrid ID="grid_ds_tienve"
    Caption="Tiền về"
    UrlFileAction="Views/tienve/Controller_TienVe.ashx"
    FilterToolbar="true"
    RowNumbers="true"
    BtnPrint="printTienVe"
    OndblClickRow="
        function(rowid) { 
            $(`#edit_grid_ds_tienve`).click();     
        }
    "
    ColModel="[
    {
        fixed: true, name: 'kt_tienve_id'
        , index: 'tv.kt_tienve_id'
        , width: 100
        , hidden: true 
        , editable:true
        , edittype: 'text'
        , key: true
    },
    {
        name: 'trangthai'
        , index: 'tv.trangthai'
        , label: 'Trạng thái'
        , editable: false
        , fixed:true , width: 100
        , edittype: 'text'
        , align:'center'
        , formatter:'imagestatus'
        , search : true
        , stype : 'select'
        , searchoptions:{sopt:['eq'], value:':[ALL];SOANTHAO:SOẠN THẢO;HIEULUC:HIỆU LỰC;KETTHUC: KẾT THÚC' }
    },
    {
        fixed: true
        , name: 'ngaygd'
        , index: 'tv.ngaygd'
        , label: 'Ngày GD'
        , width: 100
        , editable: true
        , edittype: 'text'
        , hidden: false
        , align:'center'
        , editoptions: { disabled: true }
    },
    {
        fixed: true
        , name: 'sothamchieu'
        , index: 'tv.sothamchieu'
        , label: 'Số tham chiếu'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
    },
    {
        fixed: true
        , name: 'sotienghino'
        , index: 'tv.sotienghino'
        , label: 'Số tiền ghi nợ'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions: { disabled: true }
    },
    {
        fixed: true
        , name: 'sotienghico'
        , index: 'tv.sotienghico'
        , label: 'Số tiền ghi có'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions: { disabled: true }
    }, 
    {
        fixed: true, name: 'mota'
        , index: 'tv.mota'
        , label: 'Mô tả/Diễn giải'
        , width: 100
        , editable:true
        , edittype: 'textarea'
        , editoptions: { readonly: true }
    },
    {
        fixed: true
        , name: 'tienkhach'
        , index: 'tv.tienkhach'
        , label: 'Tiền khách'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
    }, 
    {
        fixed: true, name: 'phi'
        , index: 'tv.phi'
        , label: 'Phí'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions: { disabled: true }
    }, 
    {
        fixed: true, name: 'tongtienphanbo'
        , index: 'tv.tongtienphanbo'
        , label: 'Tổng tiền phân bổ'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions: { disabled: true }
    }, 
    {
        fixed: true, name: 'conlai'
        , index: 'tv.conlai'
        , label: 'Còn lại'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editrules: {number:true, required:true, defaultValue: '0'}
        , align:'right'
        , formatter:'currency'
        , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
        , editoptions: { disabled: true }
    }, 
    {
        fixed: true, name: 'dtkd_id'
        , index: 'dtkd.ma_dtkd'
        , label: 'Khách hàng'
        , editable: true
        , width: 100
        , edittype: 'select'
        , editoptions: { style: 'width:200px', value: tienve_value_dtkd }
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
    GridComplete="var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 90); if($('#md_doitackinhdoanh_id').attr('id') == null) { $('#grid_ds_tienve-pager_left .ui-icon-plus').click(); $.jgrid.hideModal('#editmodgrid_ds_tienve', { gbox: '#gbox_grid_ds_tienve'}); }; id_inc_tienve ?  $(this).setSelection(id_inc_tienve, false) : null"
    Height="170"
    MultiSelect="false"
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
            return showMsgDialog(rs);
        }
	"
    OnSelectRow="function(ids) {
		if(ids == null)
			ids=0;
		id_inc_tienve = ids;
        $('#grid_ds_tienvephanbo')[0].triggerToolbar();
    }"
    runat="server" />

<script type="text/javascript">
    $("#grid_ds_tienve").jqGrid('navButtonAdd', '#grid_ds_tienve-pager', {
        caption: "Tạo phiếu từ Excel",
        title: "Tạo phiếu từ Excel",
        onClickButton: function () {
            let iddl = "dialog-taophieutienve-tuexcel";
            $('body').append(`
                    <div title="Tạo phiếu tiền về từ excel" id="${iddl}">
                        <div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                        <div id="dialog-caution">
                            <input type="file" id="fileTienVe" accept=".xls,.xlsx" />
                        </div>
                    </div>
                `);
            let $dlg = $(`#${iddl}`); 
            $dlg.dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                    [
                        {
                            id: `btn-ok-${iddl}`,
                            text: "Có",
                            click: function () {
                                let ajaxStart = function () {
                                    $("#wait").css("display", "block");
                                    $(`#btn-ok-${iddl}`).button("disable");
                                    $(`#btn-close-${iddl}`).button("disable");
                                };

                                let ajaxComplete = function () {
                                    $("#wait").css("display", "none");
                                    $(`#btn-close-${iddl} span`).text("Thoát");
                                    $(`#btn-close-${iddl}`).button("enable");
                                    $('#grid_ds_tienve').jqGrid().trigger('reloadGrid');
                                };

                                ajaxStart();
                                let formData = new FormData();
                                formData.append('oper', 'add');
                                formData.append('file', $('#fileTienVe')[0].files[0]);
                                $.ajax({
                                    url: "Views/tienve/Controller_TienVe.ashx",
                                    type: "POST",
                                    data: formData,
                                    processData: false,
                                    contentType: false,
                                    error: function (rs) {
                                        ajaxComplete();
                                        Popup("Error", 500, 400, rs.responseText);
                                    },
                                    success: function (rs) {
                                        if (rs.substr(0, 6) == 'false#')
                                            rs = `<div style='color:red'>${rs.substr(6)}</div>`;

                                        $dlg.find('#dialog-caution').html(rs);
                                        ajaxComplete();
                                    }
                                });
                            }
                        },
                        {
                            id: `btn-close-${iddl}`,
                            text: "Không",
                            click: function () {
                                $(this).dialog("destroy").remove();
                            }
                        }
                    ]
            });
        }
    });
</script>
