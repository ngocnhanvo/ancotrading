<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-lichtiepkhach.aspx.cs" Inherits="inc_lichtiepkhach" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
    <uc1:jqGrid  ID="grid_ds_lichtiepkhach" 
            SortName="ngay" 
            FilterToolbar="true"
            UrlFileAction="Controllers/LichTiepKhachController.ashx" 
            RowNumbers="true"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()- 64);"
            OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid, {
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
                , afterSubmit: function(rs, postdata) {
                  return showMsgDialog(rs);
                }
                , errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
            }); }"
            ColModel = "[
            {
                fixed: true, name: 'md_lichtiepkhach_id'
                , index: 'md_lichtiepkhach_id'
                , label: 'ID'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                 fixed: true, name: 'khachhang'
                 , index: 'khachhang'
                 , label: 'Khách hàng'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                fixed: true, name: 'quocgia'
                , index: 'quocgia'
                , label: 'Quốc gia'
                , width: 100
                , edittype: 'text'
                , editable:true
            },
            {
                fixed: true, name: 'soluong'
                , index: 'soluong'
                , label: 'Số lượng'
                , width: 100
                , edittype: 'text'
                , editable: true
            },
            {
                fixed: true, name: 'thoigian'
                , index: 'thoigian'
                , label: 'Thời gian'
                , width: 100
                , edittype: 'text'
                , editable: true
            },
            {
                fixed: true, name: 'ngay'
                , index: 'ngay'
                , label: 'Ngày'
                , width: 100
                , edittype: 'text'
                , editable: true
                , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#ngay', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#shipmentdate').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            },
            {
                fixed: true, name: 'noidon'
                , index: 'noidon'
                , label: 'Nơi đón'
                , width: 100
                , edittype: 'text'
                , editable: true
            },
            {
                fixed: true, name: 'noiduave'
                , index: 'noiduave'
                , label: 'Nơi đưa về'
                , width: 100
                , edittype: 'text'
                , editable: true
            },
            {
                fixed: true, name: 'sosuat'
                , index: 'sosuat'
                , label: 'Số suất'
                , width: 100
                , edittype: 'text'
                , editable: true
            },
            {
                fixed: true, name: 'thucan'
                , index: 'thucan'
                , label: 'Thức ăn'
                , width: 100
                , edittype: 'text'
                , editable: true
            },
            {
                fixed: true, name: 'nguoilienhe'
                , index: 'nguoilienhe'
                , label: 'Người liên hệ'
                , width: 100
                , edittype: 'text'
                , editable: true
            },
            {
                fixed: true, name: 'ngaytao', hidden: true
                , index: 'ngaytao'
                , label: 'Ngày tạo'
                , width: 100
                , editable:false
                , edittype: 'text'
            },
            {
                fixed: true, name: 'nguoitao', hidden: true
                , index: 'nguoitao'
                , label: 'Người tạo'
                , width: 100
                , editable:false
                , edittype: 'text'
            },
            {
                fixed: true, name: 'ngaycapnhat', hidden: true
                , index: 'ngaycapnhat'
                , label: 'Ngày cập nhật'
                , width: 100
                , editable:false
                , edittype: 'text'
            },
            {
                fixed: true, name: 'nguoicapnhat', hidden: true
                , index: 'nguoicapnhat'
                , label: 'Người cập nhật'
                , width: 100
                , editable:false
                , edittype: 'text'
            },
            {
                fixed: true, name: 'mota'
                , index: 'mota'
                , label: 'Ghi chú'
                , width: 100
                , editable:true
                , edittype: 'textarea'
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , index: 'hoatdong'
                , label: 'Hoạt động'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            }
            ]"
            Height = "420"
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            AddFormOptions=" 
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
                , afterSubmit: function(rs, postdata) {
                  return showMsgDialog(rs);
                }
                , errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                "
            EditFormOptions ="
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
                , afterSubmit: function(rs, postdata) {
                  return showMsgDialog(rs);
                }
                , errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
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
                }
                , afterSubmit: function(rs, postdata) {
                  return showMsgDialog(rs);
                }
                , errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
            "
            runat="server" />

<script type="text/javascript">

    $("#grid_ds_lichtiepkhach").jqGrid('navButtonAdd', '#grid_ds_lichtiepkhach-pager',
        {
            caption: "",
            buttonicon: "ui-icon-print",
            title: "In lịch tiếp khách",
            onClickButton: function () {
                $('body').append(`
                <div title="In lịch tiếp khách" id="dialog_inLichTiepKhach">
                    <table>
                    <tr>  
                        <td colspan="2"><input type="text" style="height:2px; opacity:0; cursor: default;" /></td>
                    </tr>
                    <tr>  
                        <td>Từ ngày:</td>
                        <td><input id="txtTuNgayLTK" autocomplete="off" type="text" style="margin-left: 5px; padding: 3px;" /></td>
                    </tr>
                    <tr>
                        <td colspan="2"><div style="width:100%; height:5px;"></div></td>
                    </tr>
                    <tr>
                        <td>Đến ngày:</td>
                        <td><input id="txtDenNgayLTK" autocomplete="off" type="text" style="margin-left: 5px; padding: 3px;" /></td>
                    </tr>
                    </table>
                </div>`);
                let tungayDT = $('#txtTuNgayLTK');
                let denngayDT = $('#txtDenNgayLTK');
                // create new dialog
                $('#dialog_inLichTiepKhach').dialog({
                    modal: true
                    , open: function (event, ui) {
                        tungayDT.datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
                        denngayDT.datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
                        //hide close button.
                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    }
                    , buttons: {
                        'In': function () {
                            let printURL = "PrintControllers/More/print_LichTiepKhach.aspx";
                            let windowSize = "width=700,height=700,scrollbars=yes";
                            window.open(`${printURL}?tungay=${tungayDT.val()}&denngay=${denngayDT.val()}`, "Chiết xuất lịch tiếp khách", windowSize);
                        },
                        'Thoát': function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                });
            }
        });

    createRightPanel('grid_ds_lichtiepkhach');
</script>