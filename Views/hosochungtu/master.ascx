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
                        <input id="printHSCT_BookCont" type="radio" name="rdoPrintType" checked="checked" />
                        <label for="printHSCT_BookCont">In Book Container</label>
                    </div>
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
                        let printURL = "Views/hosochungtu/";
                        let windowSize = "width=700,height=700,scrollbars=yes";
                        if (typeof printType == 'undefined') {
                            alert(`Chưa chọn kiểu in`);
                            return;
                        }
                        printURL += `${printType}.aspx?id=${piId}&download=0`;
                        window.open(printURL, "Chiết xuất Book Container", windowSize);
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
                            $.post(`Views/hosochungtu/Controller_hosochungtu.ashx?action=hieuluc`, {id: id }, function (result) {
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
        , index: 'kh.ma_dtkd'
        , label: 'Mã số khách'
        , width: 100
        , editable: true
        , edittype: 'text'
        , hidden: false
        , align:'center'
        , editoptions: { disabled: true }
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
        , index: 'dh.ngaypass'
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
        , index: 'dh.cont40HC'
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
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#ngayBookCont', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#ngayBookCont').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
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
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#ngayETD', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#ngayETD').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
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
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#ngayETA', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#ngayETA').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
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
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#ngayBHXN', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#ngayBHXN').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
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
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#shipmentdate', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#shipmentdate').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
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
        , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#shipmentdate', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#shipmentdate').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
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
    
</script>
