<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-yeucaucapnhat.aspx.cs" Inherits="Views_yeucaucapnhat_inc_yeucaucapnhat" %>

<%@ Register Src="master.ascx" TagName="phieuyc" TagPrefix="master" %>
<%@ Register Src="donghang.ascx" TagName="donghang" TagPrefix="detail" %>
<%@ Register Src="donghangLog.ascx" TagName="log" TagPrefix="detail" %>

<script type="text/javascript">
    var id_inc_yeucaucapnhat = "";
    $(document).ready(function () {
        $('#layout-center-yeucaucapnhat').parent().layout({
            south: {
                size: "50%"
                , onresize_end: function () {
                    var h = $("#layout-south-yeucaucapnhat").height();
                    $("#grid_ds_yeucaucapnhat").setGridHeight(h - 95);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#layout-center-yeucaucapnhat").height();
                    $("#grid_ds_yeucaucapnhat").setGridHeight(h - 90);
                }
            }
        });

        $('#tabs-yeucaucapnhat-details').tabs();
    });

    var taotudongChiTietLog = function ($grid) {
        let idpr = id_inc_yeucaucapnhat;
        if (!idpr) {
            alert('chưa chọn phiếu');
            return;
        }
        let data_js = new FormData();
        let $div, $frmGHDLH;
        $div = $(`
            <form  enctype="multipart/form-data" id="frm_File_grid_ds_yeucaucapnhatDH">
                <div class="mess"></div>
                <div>Thực hiện chức năng này?</div>
            </form>
        `);

        $div.dialog({
            title: `Tạo tự động sản phẩm`,
            resizeable: false,
            modal: true,
            width: 400,
            height: 300,
            open: function (event, ui) {

            },
            close: function (event, ui) {
                $(this).dialog('destroy').remove();
            },
            buttons: [
                {
                    text: "Đồng ý",
                    id: `btn-yes-${$grid.attr('id')}`,
                    click: function () {
                        let $mess = $div.find('.mess');
                        let $btnOK = $(`#btn-yes-${$grid.attr('id')}`);
                        data_js.append("idpr", idpr);
                        $mess.html('<img style="width:30px; height:30px" src="iconcollection/loading.gif"/>');
                        $btnOK.prop('disabled', true);
                        $.ajax({
                            url: 'Views/yeucaucapnhat/Controller_YeuCauCapNhat_DongHang.ashx?action=taotudong',
                            type: 'POST',
                            data: data_js,
                            processData: false,
                            contentType: false,
                            success: function (data) {
                                data = showMsgDialog(data, true);
                                $mess.html(data);
                                data_js = new FormData();
                                $btnOK.prop('disabled', false);

                                if (data.lastIndexOf('error') <= -1) {
                                    $("#grid_ds_yeucaucapnhatDH")[0].triggerToolbar();
                                    $("#grid_ds_yeucaucapnhatDH2")[0].triggerToolbar();
                                    $div.dialog("destroy").remove();
                                }
                            }
                        });
                    }
                },
                {
                    text: "Đóng",
                    click: function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            ]
        });
    };
</script>
<div class="ui-layout-south ui-widget-content" id="layout-south-yeucaucapnhat">
    <div class="ui-layout-center" id="tabs-yeucaucapnhat-details">
        <ul>
            <li><a href="#yeucaucapnhat-details-1">Sản phẩm đổi giá, đóng gói</a></li>
            <li><a href="#yeucaucapnhat-details-2">Các thay đổi khác</a></li>
        </ul>
        <detail:donghang runat="server" />
        <detail:log runat="server" />
    </div>
</div>

<div class="ui-layout-center ui-widget-content" id="layout-center-yeucaucapnhat">
    <master:phieuyc runat="server" />
</div>

<script type="text/javascript">
    createRightPanel('grid_ds_yeucaucapnhat');
    createRightPanel('grid_ds_yeucaucapnhatDH');
    createRightPanel('grid_ds_yeucaucapnhatDH2');
</script>
