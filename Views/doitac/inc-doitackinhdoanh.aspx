<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-doitackinhdoanh.aspx.cs" Inherits="Views_doitac_inc_doitackinhdoanh" %>
<%@ Register Src="~/jqGrid.ascx" TagName="jqGrid" TagPrefix="uc1" %>
<%@ Register Src="master.ascx" TagName="doitac" TagPrefix="master" %>
<%@ Register Src="nguoilienhe.ascx" TagName="nlh" TagPrefix="detail" %>
<script type="text/javascript">
    var id_inc_dtkd = "";
    $(document).ready(function () {
        $('#layout-center-dtkd').parent().layout({
            south: {
                size: "50%"
                , onresize_end: function () {
                    var h = $("#layout-south-dtkd").height();
                    $("#grid_ds_doitackinhdoanh").setGridHeight(h - 95);
                    $("#grid_ds_nguoilienhe").setGridHeight(h - 95);
                }
            },
            center: {
                onresize_end: function () {
                    var h = $("#layout-center-dtkd").height();
                    $("#grid_ds_doitackinhdoanh").setGridHeight(h - 90);
                }
            }
        });

        $('#tabs-dtkd-details').tabs();
    });
</script>

<script type="text/javascript">

	function funcPrint() {
        //var poId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
		var poId = "";
        var name = 'dialog-print-po';
        var title = 'Trích xuất dữ liệu';
        var content = '<table style="width:100%">' +
							'<tr>' +
                                '<td>' +
                                    '<input id="printdtkd" type="radio" name="rdoPrintType" value="printdtkd" checked="checked" />' +
                                    '<label for="printdtkd">Chiết xuất thông tin</label>' +
                                '</td>' +
                            '</tr>' +
                      '</table>';

        $('body').append('<div title="' + title + '" id="' + name + '">' + content + '</div>');
        $('#' + name).dialog({
            modal: true
            , open: function(event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            }
            , buttons: [
            {
                id: "btn-print-ok",
                text: "In",
                click: function() {
                    var printType = $('input[name=rdoPrintType]:checked', '#dialog-print-po').val();
                    var printURL = "PrintControllers/";
                    var windowSize = "width=700,height=700,scrollbars=yes";
                    if (typeof printType != 'undefined') {
                        if (printType == 'printdtkd') {
							printURL += "InDoiTacKinhDoanh/";
							window.open(printURL + "?c_donhang_id=" + poId, "In Chiết Xuất Thông Tin Đối Tác Kinh Doanh", windowSize);
                        }
                    } else {
                        alert('Hãy chọn cách in.!');
                    }
                }
            }
            , {
                id: "btn-print-close",
                text: "Thoát",
                click: function() {
                    $(this).dialog("destroy").remove();
                }
            }
            ]
        });
    }
	
	function chosen_qgkv(id) {
		var quocgia = $('#tenqg','#' + id);
		var khuvuc = $('#tenkv','#' + id);
		if(quocgia.attr('id') != null & khuvuc.attr('id') != null) {
			quocgia.off('change');
			khuvuc.prop('disabled', true);
			quocgia.change(function() {
				var val_kv = $(this).children('option:selected').attr('kv');
				if(val_kv != '') {
					khuvuc.val(val_kv);
				}
			});
			quocgia.change();
		}
		else {
			setTimeout(function(){ chosen_qgkv(id); }, 10);
		}
	}
	
	function loading() {
		$('#DelTbl_grid_ds_doitackinhdoanh').prepend('<div style="display:block" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>');
	}
	
	function end_loading() {
		 $("#wait").css("display", "none");
	}
</script>
    
<div class="ui-layout-south ui-widget-content" id="layout-south-dtkd">
    <div class="ui-layout-center" id="tabs-dtkd-details">
        <ul>
            <li><a href="#dtkd-details-1">Người liên hệ</a></li>
        </ul>
        <detail:nlh runat="server" />
    </div>
 </div>
            
<div class="ui-layout-center ui-widget-content" id="layout-center-dtkd">
    <master:doitac runat="server" />     
</div>

<script type="text/javascript">
    createRightPanel('grid_ds_doitackinhdoanh');
    createRightPanel('grid_ds_nguoilienhe');
</script>