<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-tienve.aspx.cs" Inherits="Views_tienve_inc_tienve" %>

<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<%@ Register Src="master.ascx" TagName="tienve" TagPrefix="master" %>
<%@ Register Src="tienvephanbo.ascx" TagName="phanbo" TagPrefix="detail" %>
<%@ Register Src="tienvenganhang.ascx" TagName="nganhang" TagPrefix="detail" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Xml.Linq" %>

<script type="text/javascript">
    var id_inc_tienve = "";
    $(document).ready(function () {
        $('#layout-center-tienve').parent().layout({
            south: {
                size: "50%"
                , onresize_end: function () {
                    var h = $("#layout-south-tienve").height();
                    $("#grid_ds_tienve").setGridHeight(h - 95);
                    $("#grid_ds_tienvephanbo").setGridHeight(h - 95);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#layout-center-tienve").height();
                    $("#grid_ds_tienve").setGridHeight(h - 90);
                }
            }
        });

        $('#tabs-tienve-details').tabs();
    });
</script>
<div class="ui-layout-south ui-widget-content" id="layout-south-tienve">
    <div class="ui-layout-center" id="tabs-tienve-details">
        <ul>
            <li><a href="#tienve-details-1">Chi tiết tiền về</a></li>
            <li><a href="#tienve-details-2">Bank receipt</a></li>
        </ul>
        <detail:phanbo runat="server" />
        <detail:nganhang runat="server" />
    </div>
</div>

<div class="ui-layout-center ui-widget-content" id="layout-center-tienve">
    <master:tienve runat="server" />
</div>

<script type="text/javascript">
    createRightPanel('grid_ds_tienve');
    createRightPanel('grid_ds_tienvephanbo');
    createRightPanel('grid_ds_tienvenganhang');
</script>
