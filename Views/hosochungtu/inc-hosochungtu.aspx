<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-hosochungtu.aspx.cs" Inherits="Views_hosochungtu_inc_hosochungtu" %>

<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<%@ Register Src="master.ascx" TagName="hosochungtu" TagPrefix="master" %>
<%@ Register Src="cacdonghsct.ascx" TagName="ddh" TagPrefix="detail" %>
<%@ Register Src="taptindinhkem.ascx" TagName="ttdk" TagPrefix="detail" %>

<script type="text/javascript">
    var id_inc_hosochungtu = "";
    $(document).ready(function () {
        $('#layout-center-hosochungtu').parent().layout({
            south: {
                size: "50%"
                , onresize_end: function () {
                    var h = $("#layout-south-hosochungtu").height();
                    $("#grid_ds_hosochungtu").setGridHeight(h - 95);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#layout-center-hosochungtu").height();
                    $("#grid_ds_hosochungtu").setGridHeight(h - 90);
                }
            }
        });

        $('#layout-south-hosochungtu').layout({
            center: {
                onresize: function () {
                    var o = $("#tabs-hosochungtu-details")
                    $("#grid_ds_chitiethsct").setGridWidth(o.width());
                    $("#grid_ds_chitiethsct").setGridHeight(o.height() - 97);
                    $("#grid_dinhkemhsct").setGridWidth(o.width());
                    $("#grid_dinhkemhsct").setGridHeight(o.height() - 97);
                }
            }
        });

        $('#tabs-hosochungtu-details').tabs();
    });
</script>
<div class="ui-layout-south ui-widget-content" id="layout-south-hosochungtu">
    <div class="ui-layout-center" id="tabs-hosochungtu-details">
         <ul>
            <li><a href="#hosochungtu-details-1">Các dòng hàng</a></li>
            <li><a href="#hosochungtu-details-2">Tập tin đính kèm</a></li>
        </ul>

        <detail:ddh runat="server" />
        <detail:ttdk runat="server" />
    </div>
    <div class="ui-layout-east" style="text-align:center; background:#f4f0ec">
		<table style="width:100%; height:100%">
			<tr>
				<td>
					<img id="product-view-hsct" class="loadingIMG" style="max-width:100%; margin: 0px auto; min-width: 40px;" src="Controllers/API_System.ashx?oper=loadImageProduct&msp=default" />
				</td>
			</tr>
		</table>
	</div>
</div>

<div class="ui-layout-center ui-widget-content" id="layout-center-hosochungtu">
    <master:hosochungtu runat="server" />
</div>

<script type="text/javascript">
    createRightPanel('grid_ds_hosochungtu');
</script>
