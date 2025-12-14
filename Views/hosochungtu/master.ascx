<%@ Control Language="C#" AutoEventWireup="true" CodeFile="master.ascx.cs" Inherits="Views_hosochungtu_master" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>

<script type="text/javascript">

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
                            $.post(`Views/hosochungtu/Controller_hosochungtu.ashx?action=ngayBHXN`, { id:id, ngayBHXN:ngayBHXN }, function (result) {
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

    function format_hosochungtu_dongghep(cellvalue, options, rowObject) {
        //let type = options.colModel.editoptions.typeLoad;
        cellvalue = !cellvalue ? "" : cellvalue;
        setTimeout(function () {
            let uutien = cellvalue.length <= 0;
            let id = $(rowObject).find('cell').eq(0).text();
            if (uutien) {
                //$(`#${id}`).css('background', 'beige');
                $(`#${id}`).css('box-shadow', 'rgb(223 248 243) 6px 5px 9px 11px inset');
            }
            else {
                //$(`#${id}`).css('background', '');
                $(`#${id}`).css('box-shadow', '');
            }
        }, 100);

        return `<span title="${cellvalue}">${cellvalue}</span>`;
    };
</script>

<uc1:jqGrid ID="grid_ds_hosochungtu"
    Caption="Hồ sơ chứng từ"
    UrlFileAction="Views/hosochungtu/Controller_HoSoChungTu.ashx"
    FilterToolbar="true"
    RowNumbers="true"
    BtnPrint="printhosochungtu"
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
        , editoptions:{value:'SOANTHAO:Soạn Thảo;HIEULUC:Hiệu lực;DAGUIBC:Đã gửi book container;DACOLT:Đã có lịch tàu;DAKEOC:Đã kéo cont/xuất hàng;KETTHUC: Kết thúc' }
        , searchoptions:{sopt:['eq'], value:':[ALL];SOANTHAO:Soạn Thảo;HIEULUC:Hiệu lực;DAGUIBC:Đã gửi book container;DACOLT:Đã có lịch tàu;DAKEOC:Đã kéo cont/xuất hàng;KETTHUC: Kết thúc' }
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
        , name: 'POD'
        , index: 'spd.POD'
        , label: 'Port of discharge'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
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
        , editoptions: { dataUrl: 'Views/hosochungtu/Controller_HoSoChungTu.ashx?action=selectnhanvienCT' }
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
    },
    {
        fixed: true
        , name: 'bookingNo'
        , index: 'dh.bookingNo'
        , label: 'Booking no'
        , editable: true
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true }
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
    },
    {
        name: 'ngayBHXN'
        , label: 'Ngày bán hàng XNXH'
        , index: 'dh.ngayBHXN'
        , editable: true
        , fixed: true 
        , width: 100
        , edittype: 'text'
        , editoptions: { disabled: true, dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altFormat: 'dd/mm/yy'  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
        , search: true
        , stype: 'text'
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
    },
    {
        name: 'mota'
        , label: 'Ghi chú'
        , index: 'dh.mota'
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
    GridComplete="var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 87); if($('#md_doitackinhdoanh_id').attr('id') == null) { $('#grid_ds_hosochungtu-pager_left .ui-icon-plus').click(); $.jgrid.hideModal('#editmodgrid_ds_hosochungtu', { gbox: '#gbox_grid_ds_hosochungtu'}); }; id_inc_hosochungtu ?  $(this).setSelection(id_inc_hosochungtu, false) : null"
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
            formid.css('height', window.innerHeight/2 + window.innerHeight/3); 
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
		id_inc_hosochungtu = ids;
        let row = $('#grid_ds_hosochungtu').getRowData(ids);
        $('#grid_ds_chitiethsct').jqGrid('getGridParam', 'postData').poId = row.c_donhang_id;
        $('#grid_ds_chitiethsct')[0].triggerToolbar();
        $('#grid_dinhkemhsct').jqGrid('getGridParam', 'postData').poId = id_inc_hosochungtu;
        $('#grid_dinhkemhsct')[0].triggerToolbar();
    }"
    runat="server" />

<script type="text/javascript">
    $("#grid_ds_hosochungtu").jqGrid('navButtonAdd', '#grid_ds_hosochungtu-pager',
        {
            caption: "",
            buttonicon: "ui-icon-lightbulb",
            title: "Cập nhật ngày bán hàng xác nhận xuất hàng",
            onClickButton: funcCapNhatNBHXNhosochungtu
        });
</script>
