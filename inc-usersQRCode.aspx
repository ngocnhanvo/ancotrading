 <%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-usersQRCode.aspx.cs" Inherits="inc_usersQRCode" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script>
    var SendMailgrid_usersQRCode = function () {
        let idDL = 'dialog-SendMailgrid_usersQRCode';
        $('body').append(`
            <div title="Gửi email cho những tài khoản đã chọn" id="${idDL}">
                <div style='display:none' id='wait-SendMailgrid_usersQRCode'><img style='width:30px; height:30px' src='iconcollection/loading.gif'/></div>
                <div id="caution">
                    Mật khẩu truy cập website sẽ tự động sinh ra và đính kèm trong nội dung email. 
                </div>
            </div>
        `);

        let dialog = $(`#${idDL}`);
        dialog.dialog({
            width: 500
            , modal: true
            , open: function (event, ui) {

            }
            , close: function (event, ui) {
                dialog.dialog("destroy").remove();
            }
            , buttons: [
            {
                id: "btn-change",
                text: "Gửi",
                click: function() {
                    let ids = $('#grid_usersQRCode').jqGrid('getGridParam', 'selarrrow');
                    $("#wait-SendMailgrid_usersQRCode").css("display", "");

                    $.post('Controllers/UserQRCodeController.ashx',
                        { ids: ids.toString(), oper: 'sendMail' }, function (result) {
                            $("#wait-SendMailgrid_usersQRCode").css("display", "none");
                            let ok = result.substr(0, 1);
                            let mess = result.substr(1);

                            if (ok == 0)
                                mess = `<div style="color:red">${mess}</div>`;
                            else {
                                mess = `<div style="color:blue">${mess}</div>`;
                                $('#grid_usersQRCode')[0].triggerToolbar();
                            }

                            dialog.find("#caution").html(mess);
                            
                        });
                }
            }
            , {
                id: "btn-close",
                text: "Thoát",
                click: function() {
                    $(this).dialog("destroy").remove();
                }
            }
            ]
        });
    };
</script>

    <uc1:jqGrid ID="grid_usersQRCode" 
            SortName="ngaytao" 
            UrlFileAction="Controllers/UserQRCodeController.ashx" 
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 65);"
            RowNumbers="true"
            FilterToolbar="true"
            MultiSelect="true"
            OndblClickRow = "
                function(rowid) { 
                    $(this).jqGrid('editGridRow', rowid,{ 
                        afterSubmit: function(rs, postdata) {
                            return showMsgDialog(rs);
                        },
                        beforeShowForm: function (formid) {
                            formid.closest('div.ui-jqdialog').dialogCenter(); 
                        }
                    }); 
                }
            "
            ColModel = "
            [
                {
                    fixed: true
                    , name: 'userQRCode_id'
                    , label: 'Id'
                    , index: 'userQRCode_id'
                    , width: 100 
                    , editable: false
                    , edittype: 'text'
                    , key: true
                    , hidden: true
                    , editrules: { readyonly: 'readyonly' }
                },
                {
                    fixed: true
                    , name: 'contactEmail'
                    , label: 'Email'
                    , index: 'contactEmail'
                    , width: 100 
                    , editable: true
                    , edittype: 'text'
                    , hidden: false
                    , editrules: { edithidden:true, email: true, required: true }
                },
                {
                    fixed: true
                    , name: 'contactPass'
                    , label: 'Pass'
                    , index: 'contactPass'
                    , width: 100 
                    , editable: true
                    , edittype: 'text'
                    , hidden: true
                    , editoptions: { 
                        dataInit : function (elem) {
                            setTimeout(function () {
                                $(elem).prop('disabled', true);
                            }, 50);
                        },
                    }
                    , editrules: { edithidden:true }
                },
                {
                    fixed: true
                    , name: 'companyName'
                    , label: 'Company Name'
                    , index: 'companyName'
                    , width: 100 
                    , editable: true
                    , edittype: 'text'
                },
                {
                    fixed: true
                    , name: 'contactPerson'
                    , label: 'Contact Person'
                    , index: 'contactPerson'
                    , width: 100 
                    , editable: true
                    , edittype: 'text'
                },
                {
                    fixed: true
                    , name: 'contactMessage'
                    , label: 'Message'
                    , index: 'contactMessage'
                    , width: 100 
                    , editable: true
                    , edittype: 'textarea'
                    , hidden: false
                    , editrules: { edithidden:true }
                },
                {
                    fixed: true
                    , name: 'sendMail'
                    , label: 'send Mail'
                    , index: 'sendMail'
                    , width: 100 
                    , editable:true
                    , edittype: 'checkbox'
                    , align: 'center'
                    , editoptions: { value:'True:False', defaultValue: 'False', dataInit : function (elem) {
                            setTimeout(function () {
                                $(elem).prop('disabled', true);
                            }, 50);
                        }, 
                    }
                    , formatter: 'checkbox'
                },
                {
                    fixed: true
                    , name: 'type'
                    , label: 'Type'
                    , index: 'type'
                    , width: 60 
                    , align: 'center'
                    , editable: true
                    , edittype: 'select'
                    , editoptions: { value:'0:Khách hàng;1:Nhân viên', defaultValue: '0' }
                },
                {
                    fixed: true, name: 'ngaytao'
                    , label: 'Ngày Tạo'
                    , index: 'ngaytao'
                    , width: 100
                    , editable:false
                    , edittype: 'text'
                    , hidden: true
                },
                {
                    fixed: true, name: 'nguoitao'
                    , label: 'Người Tạo'
                    , index: 'nguoitao'
                    , width: 100
                    , editable:false
                    , edittype: 'text'
                    , hidden: true
                },
                {
                    fixed: true, name: 'ngaycapnhat'
                    , label: 'Ngày Cập Nhật'
                    , index: 'ngaycapnhat'
                    , width: 100
                    , editable:false
                    , edittype: 'text'
                    , hidden: true
                },
                {
                    fixed: true, name: 'nguoicapnhat'
                    , label: 'Người Cập Nhật'
                    , index: 'nguoicapnhat'
                    , width: 100
                    , editable:false
                    , edittype: 'text'
                    , hidden: true
                },
                {
                    fixed: true, name: 'mota'
                    , label: 'Mô tả'
                    , index: 'mota'
                    , width: 100
                    , editable:true
                    , edittype: 'textarea'
                    , hidden: true
                },
                {
                    fixed: true, name: 'hoatdong'
                    , label: 'Hoạt động'
                    , index: 'hoatdong'
                    , width: 100
                    , editable:true
                    , edittype: 'checkbox'
                    , align: 'center'
                    , editoptions:{ value:'True:False', defaultValue: 'True' }
                    , formatter: 'checkbox'
                }
            ]"
            AddFormOptions=" 
            afterSubmit: function(rs, postdata) {
                            return showMsgDialog(rs);
                        },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            EditFormOptions=" 
            afterSubmit: function(rs, postdata) {
                return showMsgDialog(rs);
            },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            ViewFormOptions=" beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            DelFormOptions="
            afterSubmit: function(rs, postdata) {
                            return showMsgDialog(rs);
                        },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            }"
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            runat="server" />

<script type="text/javascript">
    $("#grid_usersQRCode").jqGrid('navButtonAdd', '#grid_usersQRCode-pager', {
        caption: "Send Mail"
        , title: "Send Mail"
        , buttonicon: "ui-icon ui-icon-mail-closed"
        , onClickButton: SendMailgrid_usersQRCode
    });

    createRightPanel('grid_usersQRCode');
</script>
