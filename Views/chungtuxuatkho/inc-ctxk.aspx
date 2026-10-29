<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-ctxk.aspx.cs" Inherits="Views_chungtuxuatkho_inc_ctxk" %>

<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<%@ Register Src="master.ascx" TagName="ctxk" TagPrefix="master" %>
<%@ Register Src="cacdonghang.ascx" TagName="cdh" TagPrefix="detail" %>
<%@ Register Src="cackhoanphi.ascx" TagName="ckp" TagPrefix="detail" %>
<%@ Register Src="~/Views/phanbococpo/phanbococpo.ascx" TagName="phanbococpo" TagPrefix="pb" %>
<script type="text/javascript">
    var id_inc_ctxk = "";
    $(document).ready(function () {
        $('#layout-center-ctxk').parent().layout({
            south: {
                size: "50%"
                , onresize_end: function () {
                    var h = $("#layout-south-ctxk").height();
                    $("#grid_ds_ctxk").setGridHeight(h - 95);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#layout-center-ctxk").height();
                    $("#grid_ds_ctxk").setGridHeight(h - 90);
                }
            }
        });

        $('#layout-south-ctxk').layout({
            center: {
                onresize: function () {
                    var o = $("#tabs-ctxk-details")
                    $("#grid_ds_chitietctxk").setGridWidth(o.width());
                    $("#grid_ds_chitietctxk").setGridHeight(o.height() - 97);
                    if (window.ancoPhanBoCocPO) window.ancoPhanBoCocPO.resize();
                }
            }
        });

        // Enable the preview tab before initializing jQuery UI Tabs, so it is registered as a tab.
        if (/(?:\?|&)phanbococ_preview=1(?:&|$)/.test(window.location.search)) {
            $('#tabs-ctxk-details .anco-pb-preview-tab').show();
        }
        $('#tabs-ctxk-details').tabs();
        if (window.ancoPhanBoCocPO) window.ancoPhanBoCocPO.init();
    });
</script>
<div class="ui-layout-south ui-widget-content" id="layout-south-ctxk">
    <div class="ui-layout-center" id="tabs-ctxk-details">
         <ul>
            <li><a href="#ctxk-details-1">Các dòng hàng</a></li>
            <li class="anco-pb-preview-tab" style="display:none"><a href="#nav-tabs-pklivn-pb">Phân bổ cọc</a></li>
            <li><a href="#ctxk-details-2">Chi tiết các khoản</a></li>
        </ul>

        <detail:cdh runat="server" />
        <pb:phanbococpo runat="server" />
        <detail:ckp runat="server" />
    </div>
    <div class="ui-layout-east" style="text-align:center; background:#f4f0ec">
		<table style="width:100%; height:100%">
			<tr>
				<td>
					<img id="product-view-ctxk" class="loadingIMG" style="max-width:100%; margin: 0px auto; min-width: 40px;" src="Controllers/API_System.ashx?oper=loadImageProduct&msp=default" />
				</td>
			</tr>
		</table>
	</div>
</div>

<div class="ui-layout-center ui-widget-content" id="layout-center-ctxk">
    <master:ctxk runat="server" />
</div>

<script type="text/javascript">
    createRightPanel('grid_ds_ctxk');
</script>
