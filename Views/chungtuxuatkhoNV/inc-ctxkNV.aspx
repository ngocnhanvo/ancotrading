<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-ctxkNV.aspx.cs" Inherits="Views_chungtuxuatkhoNV_inc_ctxkNV" %>

<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<%@ Register Src="master.ascx" TagName="ctxk" TagPrefix="master" %>
<%@ Register Src="cacdonghangNV.ascx" TagName="cdh" TagPrefix="detail" %>
<%@ Register Src="cackhoanphiNV.ascx" TagName="ckp" TagPrefix="detail" %>
<%@ Register Src="~/Views/phanbococpo/phanbococpo.ascx" TagName="phanbococpo" TagPrefix="pb" %>

<script type="text/javascript">
    var id_inc_ctxkNV = "";
    // This page is injected through the main jQuery UI AJAX tabs. Load the
    // allocation module explicitly; an external <script> inside ASCX markup
    // is not a reliable initialization boundary in that loading path.
    var ancoPbModuleRequestNV = null;
    window.ancoEnsurePhanBoCocPONV = function () {
        if (!/(?:\?|&)phanbococ_preview=1(?:&|$)/.test(window.location.search)) return;
        if (!$("#nav-tabs-pklivn-pb").length) return;

        function finish() {
            if (!window.ancoPhanBoCocPO) {
                $("#anco-pb-warning").text("Không thể khởi tạo module phân bổ cọc.");
                return;
            }
            window.ancoPhanBoCocPO.init();
            // Read the current grid selection at completion time. The user
            // might have selected a different Invoice while JS was loading.
            window.ancoPhanBoCocPO.syncInvoice();
            window.ancoPhanBoCocPO.resize();
        }

        if (window.ancoPhanBoCocPO) {
            finish();
            return;
        }
        if (!ancoPbModuleRequestNV) {
            ancoPbModuleRequestNV = $.getScript("Views/phanbococpo/phanbococpo.js?v=20261030f")
                .fail(function () {
                    $("#anco-pb-warning").text("Không tải được phanbococpo.js. Kiểm tra Network và tải lại trang.");
                    ancoPbModuleRequestNV = null;
                });
        }
        ancoPbModuleRequestNV.done(finish);
    };
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
            if (ui.panel && ui.panel.id === "nav-tabs-pklivn-pb") {
                window.ancoEnsurePhanBoCocPONV();
            }
        });

        // Feature-gated UI preview: no real allocation writes.
        if (/(?:\?|&)phanbococ_preview=1(?:&|$)/.test(window.location.search)) {
            $('#tabs-ctxkNV-details .anco-pb-preview-tab').css('display', 'list-item');
        }
        $('#tabs-ctxkNV-details').tabs();
        // The initial tab does not always fire tabsshow in jQuery UI 1.8.
        updateProductImagePane($('#tabs-ctxkNV-details > .ui-tabs-panel:visible')[0]);
        window.ancoEnsurePhanBoCocPONV();
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
