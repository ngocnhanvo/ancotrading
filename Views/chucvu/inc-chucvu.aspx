<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-chucvu.aspx.cs" Inherits="Views_chucvu_inc_chucvu" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<%@ Register Src="master.ascx" TagName="chucvu" TagPrefix="master" %>
<script type="text/javascript">
    var id_inc_chucvu = "";
    $(document).ready(function () {
        $('#layout-center-chucvu').parent().layout({
            south: {
                size: "0%"
                , onresize_end: function () {
                    var h = $("#layout-south-chucvu").height();
                    $("#grid_ds_chucvu").setGridHeight(h - 95);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#layout-center-chucvu").height();
                    $("#grid_ds_chucvu").setGridHeight(h - 90);
                }
            }
        });

        $('#tabs-chucvu-details').tabs();
    });
</script>

<script type="text/javascript">
    
</script>
    
<div class="ui-layout-south ui-widget-content" id="layout-south-chucvu">
    <div class="ui-layout-center" id="tabs-chucvu-details">
        <ul>
        </ul>
    </div>
 </div>
            
<div class="ui-layout-center ui-widget-content" id="layout-center-chucvu">
    <master:chucvu runat="server" />     
</div>

<script type="text/javascript">
    createRightPanel('grid_ds_chucvu');
</script>