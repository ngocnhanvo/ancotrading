<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-ctxkNV.aspx.cs" Inherits="Views_chungtuxuatkhoNV_inc_ctxkNV" %>

<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<%@ Register Src="master.ascx" TagName="ctxk" TagPrefix="master" %>
<%@ Register Src="cacdonghangNV.ascx" TagName="cdh" TagPrefix="detail" %>
<%@ Register Src="cackhoanphiNV.ascx" TagName="ckp" TagPrefix="detail" %>
<%@ Register Src="~/Views/phanbococpo/phanbococpo.ascx" TagName="phanbococpo" TagPrefix="pb" %>

<script type="text/javascript">
    var id_inc_ctxkNV = "";
    $(document).ready(function () {
        $('#layout-center-ctxkNV').parent().layout({
            south: {
                size: "50%"
                , onresize_end: function () {
                    var h = $("#layout-south-ctxkNV").height();
                    $("#grid_ds_ctxkNV").setGridHeight(h - 95);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#layout-center-ctxkNV").height();
                    $("#grid_ds_ctxkNV").setGridHeight(h - 90);
                }
            }
        });

        // Keep a reference so the product image east pane can be hidden on non-product tabs.
        var detailLayout = $('#layout-south-ctxkNV').layout({
            center: {
                onresize: function () {
                    var o = $("#tabs-ctxkNV-details")
                    $("#grid_ds_chitietctxkNV").setGridWidth(o.width());
                    $("#grid_ds_chitietctxkNV").setGridHeight(o.height() - 97);
                    if (window.ancoPhanBoCocPO) window.ancoPhanBoCocPO.resize();
                }
            }
        });

        // The product image pane belongs only to the product lines tab.
        // Use jQuery Layout's hide/show (not CSS display:none) so the center
        // pane expands to full width and its grids receive resize events.
        function updateProductImagePane(panel) {
            if (!detailLayout || !detailLayout.state || !detailLayout.state.east) return;
            var showProductImage = panel && panel.id === "ctxkNV-details-1";
            if (showProductImage) {
                if (detailLayout.state.east.isHidden) {
                    detailLayout.show("east", true, true);
                }
            } else if (!detailLayout.state.east.isHidden) {
                detailLayout.hide("east", true);
            }
            if (window.ancoPhanBoCocPO) window.ancoPhanBoCocPO.resize();
        }

        $('#tabs-ctxkNV-details').bind('tabsshow.ancoProductImage', function (event, ui) {
            updateProductImagePane(ui.panel);
        });

        // Feature-gated UI preview: no real allocation writes.
        if (/(?:\?|&)phanbococ_preview=1(?:&|$)/.test(window.location.search)) {
            $('#tabs-ctxkNV-details .anco-pb-preview-tab').show();
        }
        $('#tabs-ctxkNV-details').tabs();
        // The initial tab does not always fire tabsshow in jQuery UI 1.8.
        updateProductImagePane($('#tabs-ctxkNV-details > .ui-tabs-panel:visible')[0]);
        if (window.ancoPhanBoCocPO) window.ancoPhanBoCocPO.init();
    });
</script>
<div class="ui-layout-south ui-widget-content" id="layout-south-ctxkNV">
    <div class="ui-layout-center" id="tabs-ctxkNV-details">
         <ul>
            <li><a href="#ctxkNV-details-1">Các dòng hàng</a></li>
            <li class="anco-pb-preview-tab" style="display:none"><a href="#nav-tabs-pklivn-pb">Phân bổ cọc</a></li>
            <li><a href="#ctxkNV-details-2">Chi tiết các khoản</a></li>
        </ul>

        <detail:cdh runat="server" />
        <pb:phanbococpo runat="server" />
        <detail:ckp runat="server" />
    </div>
    <div class="ui-layout-east" style="text-align:center; background:#f4f0ec">
		<table style="width:100%; height:100%">
			<tr>
				<td>
					<img id="product-view-ctxkNV" class="loadingIMG" style="max-width:100%; margin: 0px auto; min-width: 40px;" src="Controllers/API_System.ashx?oper=loadImageProduct&msp=default" />
				</td>
			</tr>
		</table>
	</div>
</div>

<div class="ui-layout-center ui-widget-content" id="layout-center-ctxkNV">
    <master:ctxk runat="server" />
</div>

<script type="text/javascript">
    createRightPanel('grid_ds_ctxkNV');
</script>
