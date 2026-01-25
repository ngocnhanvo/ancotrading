<%@ Control Language="C#" AutoEventWireup="true" CodeFile="shippingdetail.ascx.cs" Inherits="Views_po_shippingdetail" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<div id="donhang-details-3">
    <uc1:jqGrid  ID="grid_ds_donhang_spdt" 
        SortName="spd.ngaytao" 
        UrlFileAction="Views/po/Controller_PO_SPDT.ashx"
        FilterToolbar="true"
        GridBeforeRequest = "$('#grid_ds_donhang_spdt').jqGrid('getGridParam', 'postData').id = id_inc_po;"
        GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
        RowNumbers="true"
        OndblClickRow = "function(rowid) { $('#edit_grid_ds_donhang_spdt').click(); }"
        ColModel = "[
        {
            fixed: true, name: 'md_doitackinhdoanh_spd_id'
            , index: 'spd.md_doitackinhdoanh_spd_id'
            , width: 100
            , hidden: true 
            , editable:true
            , edittype: 'text'
            , key: true
        },
        {
            fixed: true, name: 'md_donhang_id'
            , index: 'spd.md_donhang_id'
            , editable: false
            , width: 100
            , edittype: 'select'
            , hidden: true
        },
        {
            name: 'trangthai'
            , label: 'TT'
            , index: 'trangthai'
            , editable: false
            , fixed:true , width: 100
            , edittype: 'text'
            , align:'center'
            , formatter: 'trangthai'
            , search : true
            , stype : 'select'
            , searchoptions:{sopt:['eq'], value:':[ALL];CHUAGUI:Chưa gửi;DAGUI:Đã gửi' }
        },
        {
            fixed: true, name: 'Forwarder'
            , label: 'Forwarder'
            , index: 'spd.Forwarder'
            , editable: true
            , width: 100
            , edittype: 'text'
            , editoptions:{ dataInit: function (elem) { format_donhang_spd_forwarder.create(elem); } }
        },
        {
            fixed: true, name: 'Shipper'
            , label: 'Shipper'
            , index: 'spd.Shipper'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'Consignee'
            , label: 'Consignee'
            , index: 'spd.Consignee'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'Notify'
            , label: 'Notify'
            , index: 'spd.Notify'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'AlsoNotify'
            , label: 'AlsoNotify'
            , index: 'spd.AlsoNotify'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'POD'
            , label: 'POD'
            , index: 'spd.POD'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'PlaceOfDelivery'
            , label: 'Place Of Delivery'
            , index: 'spd.PlaceOfDelivery'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'AddressForSendingOriginalDocs'
            , label: 'Address for sending original docs'
            , index: 'spd.AddressForSendingOriginalDocs'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'EmailSendPaymentRequest'
            , label: 'Email send payment request'
            , index: 'spd.EmailSendPaymentRequest'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'CacLoaiCTYC'
            , label: 'Các loại CT yêu cầu'
            , index: 'spd.CacLoaiCTYC'
            , editable: true
            , width: 100
            , edittype: 'text'
        },
        {
            fixed: true, name: 'ngaytao'
            , label: 'Ngày tạo'
            , index: 'cl.ngaytao'
            , width: 110
            , editable:false
            , edittype: 'text'
            , align: ' center'
        },
        {
            fixed: true, name: 'nguoitao'
            , label: 'Người tạo'
            , index: 'cl.nguoitao'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true
        },
        {
            fixed: true, name: 'ngaycapnhat'
            , label: 'Ngày cập nhật'
            , index: 'cl.ngaycapnhat'
            , width: 110
            , editable:false
            , edittype: 'text'
            , hidden: true
            , align: ' center'
        },
        {
            fixed: true, name: 'nguoicapnhat'
            , label: 'Người cập nhật'
            , index: 'cl.nguoicapnhat'
            , width: 100
            , editable:false
            , edittype: 'text'
            , hidden: true
        },
        {
            fixed: true, name: 'mota'
            , label: 'Mô tả'
            , index: 'cl.mota'
            , width: 100
            , editable:true
            , edittype: 'textarea'
        },
        {
            fixed: true, name: 'hoatdong', hidden: true
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
        Height = "420"
        ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
        ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
        ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
        AddFormOptions=" 
            width: 400,
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter();
            }
            , beforeSubmit:function(postdata, formid) { 
                postdata.id = id_inc_po;
                return [true,'']; 
            }
            , afterSubmit: function(rs, postdata){
                return showMsgDialog(rs);
            }
            "
        EditFormOptions ="
            width: 400,
            afterSubmit: function(rs, postdata){
                return showMsgDialog(rs);
            },
            beforeShowForm: function (formid) {
                formid.closest('div.ui-jqdialog').dialogCenter(); 
            },
            errorTextFormat:function(data) { 
                return 'Lỗi: ' + data.responseText 
        }"
        ViewFormOptions="
            width: 400,
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
            afterSubmit: function(rs, postdata){
                return showMsgDialog(rs);
            },
            errorTextFormat:function(data) { 
                return 'Lỗi: ' + data.responseText 
        }"
        runat="server" 
    />
</div>



<script type="text/javascript">
     $("#grid_ds_donhang_spdt").jqGrid('navButtonAdd', '#grid_ds_donhang_spdt-pager',
        {
            caption: "",
            buttonicon: "ui-icon-lightbulb",
            title: "Gửi chứng từ",
            onClickButton: function () {
                let id = $("#grid_ds_donhang_spdt").jqGrid('getGridParam', 'selrow');
                if (!id) {
                    alert(`Không tìm thấy shipping detail đã chọn`);
                    return;
                }

                let iddlg = 'dialog-chuyenchungtu-spd';
                $('body').append(`<div title="Gửi đến chứng từ" id="${iddlg}">
                    <div style="display:none" id="waitChuyenChungTuSPD"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                    <div style="margin-top:5px;">
                        Bạn muốn chuyển shipping detail đến chứng từ?
                    </div>
                    <div style="margin-top:5px;">
                        <label>Ghi chú</label>
                        <textarea id="po_spdt_ghichusau"></textarea>
                    </div>
                </div>`);

                // create new dialog
                $(`#${iddlg}`).dialog({
                    modal: true
                    , open: function (event, ui) {
                        //hide close button.
                        $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                    }
                    , buttons: {
                        'Đồng ý': function () {
                            let $wait = $('#waitChuyenChungTuSPD');
                            $wait.css('display', '');
                            let page = $('#grid_ds_donhang_spdt').getGridParam("page");
                            let data = new FormData();
                            data.append('action', 'guispd');
                            data.append('id', id.toString());
                            data.apeend('ghichu', $('#po_spdt_ghichusau').val());
                            $.ajax({
                                url: 'Views/po/Controller_PO_SPDT.ashx',
                                data: data,
                                type: 'POST',
                                processData: false,
                                contentType: false,
                                success: function (result) {
                                    if (!result) {
                                        $('#grid_ds_donhang_spdt').trigger("reloadGrid", [{ current: true, page: page }]);
                                        $(`#${iddlg}`).dialog("destroy").remove();
                                    }
                                    else {
                                        alert(result);
                                        $wait.css('display', 'none');
                                    }
                                }
                            });
                        },
                        'Thoát': function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                });
            }
        });
</script>