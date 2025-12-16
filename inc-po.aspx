<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-po.aspx.cs" Inherits="inc_po" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<%@ Register Src="~/Views/po/shippingdetail.ascx" TagName="spdt" TagPrefix="detail" %>
<%@ Register Src="~/Views/po/cacdongpo.ascx" TagName="ddh" TagPrefix="detail" %>
<script>
    var id_inc_po = '';
    $(function () {
        $('#lay-center-po').parent().layout({
            south: {
                size: "50%"
            }
            , center: {
                onresize: function () {
                    var h = $("#lay-center-po").height();
                    $("#grid_ds_po").setGridHeight(h - 90);
                }
            }
        });

        // Layout nho duoi
        $('#layout-south-po').layout({
            center: {
                onresize: function () {
                    var o = $("#tabs-donhang-details")
                    $("#grid_ds_chitietpo").setGridWidth(o.width());
                    $("#grid_khoanphi").setGridWidth(o.width());
                    $("#grid_ds_donhang_spdt").setGridWidth(o.width());

                    $("#grid_ds_chitietpo").setGridHeight(o.height() - 97);
                    $("#grid_khoanphi").setGridHeight(o.height() - 97);
                    $("#grid_ds_donhang_spdt").setGridHeight(o.height() - 97);
                }
            }
        });

        $('#tabs-donhang-details').tabs();
    });

    function createOnchange() {
        var frm = "#FrmGrid_grid_ds_po";
        var md_doitackinhdoanh_id = $("#md_doitackinhdoanh_id", frm);
        var sct_dh = $("#sochungtu", frm).val();
        if (md_doitackinhdoanh_id.attr('id') != null) {
            md_doitackinhdoanh_id.off('change');
            md_doitackinhdoanh_id.change(function () {
                var dtkd = $(this).val();
                $.ajax({
                    url: "Controllers/PartnerController.ashx?action=getHoaHong",
                    type: "POST",
                    datatype: "xml",
                    data: { md_doitackinhdoanh_id: dtkd, sct_dh: '' },
                    error: function (rs) {

                    },
                    success: function (rs) {
                        var madtkd = $(rs).find("madtkd").text();
                        var tendtkd = $(rs).find("tendtkd").text();
                        var hoahong = $(rs).find("hoahong").text();
                        $("#md_nguoilienhe_id", frm).val(madtkd);
                        $("#hoahong", frm).val(hoahong);
                    }
                });
            });
            //md_doitackinhdoanh_id.change();
        }
        else {
            setTimeout(function () {
                createOnchange();
            }, 100);
        }
    }

    function funcActivePO() {
        var msg = "";
        var id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            msg = "Bạn hãy chọn 1 đơn hàng mà bạn muốn hiệu lực.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-active-po\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-active-po').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            var sochungtu = $('#grid_ds_po').jqGrid('getCell', id, 'sochungtu');
            msg = `Có phải bạn muốn hiệu lực PO ${sochungtu}.?`;
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-active-po\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-active-po').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                [
                    {
                        id: "btn-active",
                        text: "Có",
                        click: function () {
                            $("#wait").css("display", "block");
                            $("#btn-active").button("disable");
                            $("#btn-close").button("disable");

                            $.post("Controllers/DonHangController.ashx?action=activepo", { poId: id}, function (result) {
                                $("#wait").css("display", "none");
                                $("#btn-close span").text("Thoát");
                                $("#btn-close").button("enable");
                                $('#dialog-active-po').find('#dialog-caution').html(result);
                                $('#grid_ds_po').jqGrid().trigger('reloadGrid');
                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }

    function HuyDonHang() {
        var msg = "";
        var id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            msg = "Bạn hãy chọn 1 đơn hàng cần hủy.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-huypo\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-huypo').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            var sochungtu = $('#grid_ds_po').jqGrid('getCell', id, 'sochungtu');
            msg = "Có phải bạn muốn hủy đơn hàng '" + sochungtu + "'.?";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-huypo\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-huypo').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                [
                    {
                        id: "btn-active",
                        text: "Có",
                        click: function () {
                            $("#dialog-caution").ajaxStart(function () {
                                $("#wait").css("display", "block");
                                $("#btn-active").button("disable");
                                $("#btn-close").button("disable");
                            });

                            $("#dialog-caution").ajaxComplete(function () {
                                $("#wait").css("display", "none");
                                $("#btn-close span").text("Thoát");
                                $("#btn-close").button("enable");
                            });

                            $.get("Controllers/DonHangController.ashx?action=huypo&poId=" + id, function (result) {
                                //$('#dialog-caution').css({ 'color': 'green' });
                                $('#dialog-huypo').find('#dialog-caution').html(result);
                                $('#grid_ds_po').jqGrid().trigger('reloadGrid');
                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }


    function funcPI() {
        var msg = "";
        var id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            msg = "Bạn hãy chọn 1 đơn hàng mà bạn muốn tạo PI.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-create-pi\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-create-pi').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            var sochungtu = $('#grid_ds_po').jqGrid('getCell', id, 'sochungtu');
            msg = "Có phải bạn muốn tạo PI từ đơn hàng '" + sochungtu + "'.?";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-create-pi\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-create-pi').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                [
                    {
                        id: "btn-active",
                        text: "Có",
                        click: function () {
                            $("#wait").css("display", "block");
                            $("#btn-active").button("disable");
                            $("#btn-close").button("disable");

                            $.get("Controllers/DonHangController.ashx?action=createpi&poId=" + id, function (result) {
                                //$('#dialog-caution').css({ 'color': 'green' });
                                $('#dialog-create-pi').find('#dialog-caution').html(result);
                                $('#grid_ds_po').jqGrid().trigger('reloadGrid');
                                $("#wait").css("display", "none");
                                $("#btn-close span").text("Thoát");
                                $("#btn-close").button("enable");
                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }


    function viewCapacity() {
        var msg = "";
        var id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            msg = "Bạn hãy chọn 1 đơn hàng để xem năng lực.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-view-capacity\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-view-capacity').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            $.get("Controllers/DonHangController.ashx?action=viewcapacity&poId=" + id, function (result) {
                // append dialog-taoky to body
                $('body').append('<div title="Xem Năng Lực" id=\"dialog-view-capacity\">' + result + '</div>');

                // create new dialog
                $('#dialog-view-capacity').dialog({
                    modal: true
                        , width: 800
                        , open: function (event, ui) {
                            //hide close button.
                            $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                        }
                        , buttons:
                        [
                            {
                                id: "btn-close",
                                text: "Thoát",
                                click: function () {
                                    $(this).dialog("destroy").remove();
                                }
                            }
                        ]
                });

            });
        }
    }

    function funcPrint() {
        var poId = $('#grid_ds_po').jqGrid('getGridParam', 'selarrrow');
        var name = 'dialog-print-po';
        var title = 'Trích xuất dữ liệu';
        var content = '<table style="width:100%">' +
						'<tr>' +
							'<td>' +
								'<input id="printPoDetails" type="radio" name="rdoPrintType" value="printPoDetails" checked="checked" />' +
								'<label for="printPoDetails">Chiết xuất đơn hàng</label>' +
							'</td>' +


							'<td>' +
								'<input id="printPacking" type="radio" name="rdoPrintType" value="printPacking" />' +
								'<label for="printPacking">In packing list</label>' +
							'</td>' +
						'</tr>' +

						'<tr>' +
							'<td>' +
								'<input id="printST_PO" type="radio" name="rdoPrintType" value="printST_PO" />' +
								'<label for="printST_PO">Chiết xuất tất cả đơn hàng</label>' +
							'</td>' +


							'<td>' +
								'<input id="printDanhMuc" type="radio" name="rdoPrintType" value="printDanhMuc" />' +
								'<label for="printDanhMuc">In danh mục khai hải quan</label>' +
							'</td>' +
						'</tr>' +

						'<tr>' +
							'<td>' +
								'<input id="printPo" type="radio" name="rdoPrintType" value="printPo" />' +
								'<label for="printPo">In đơn hàng</label>' +
							'</td>' +


							'<td>' +
								'<input id="printToKhai" type="radio" name="rdoPrintType" value="printToKhai" />' +
								'<label for="printToKhai">In tờ khai hải quan</label>' +
							'</td>' +
						'</tr>' +

						'<tr>' +
							'<td>' +
								'<input id="printRequired" type="radio" name="rdoPrintType" value="printRequired" />' +
								'<label for="printRequired">In yêu cầu xuất hàng</label>' +
							'</td>' +


							'<td>' +
								'<input id="printPoTinhHinhXuLyPI" type="radio" name="rdoPrintType" value="printPoTinhHinhXuLyPI" />' +
								 '<label for="printPoTinhHinhXuLyPI">In tình hình xử lý PI</label>' +
							'</td>' +
						'</tr>' +

						'<tr>' +
							'<td>' +
								'<input id="printBook" type="radio" name="rdoPrintType" value="printBook" />' +
								'<label for="printBook">In Bookcontainer</label>' +
							'</td>' +

							'<td>' +
								'<input id="printInvoice" type="radio" name="rdoPrintType" value="printInvoice" />' +
								'<label for="printInvoice">In Invoice</label>' +
							'</td>' +

							'<td style="display: none">' +
								'<input id="printPoTem" type="radio" name="rdoPrintType" value="printPoTem" />' +
								'<label for="printPoTem" style="display: none">In đơn hàng tem</label>' +
							'</td>' +
						'</tr>' +

						'<tr>' +
							'<td>' +
								'<input id="printsale" type="radio" name="rdoPrintType" value="printsale" />' +
								'<label for="printsale">In sales contract</label>' +
							'</td>' +

							'<td>' +
								'<input id="printxbb" type="radio" name="rdoPrintType" value="printxbb" style="display: none" />' +
								 '<label for="printxbb" style="display: none" >In xác nhận bao bì</label>' +
							'</td>' +
						'</tr>' +
				  '</table>';

        $('body').append('<div title="' + title + '" id="' + name + '">' + content + '</div>');
        $('#' + name).dialog({
            width: 500,
            modal: true
            , open: function (event, ui) {
                //hide close button.
                $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
            }
            , buttons: [
            {
                id: "btn-print-ok",
                text: "In",
                click: function () {
                    var printType = $('input[name=rdoPrintType]:checked', '#dialog-print-po').val();
                    var printURL = "PrintControllers/";
                    var windowSize = "width=700,height=700,scrollbars=yes";
                    var win = null;
                    let closeWin = function () {
                        if (win != null)
                            win.close();
                    };

                    if (typeof printType != 'undefined') {
                        if (printType == "printRequired") {
                            if (poId != null) {
                                closeWin();
                                printURL += "InYeuCauXuatHang/";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In Phiếu Xuất", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPoDetails') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InDonHang/";
                                win = window.open(printURL + "?c_donhang_id=" + poId + "&type=xls", "In Chiết Xuất Đơn Hàng", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPo') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InDonHang/";
                                windowSize = "top=0, left=0, width=" + window.outerWidth + ", height=" + window.outerHeight;
                                win = window.open(printURL + "?c_donhang_id=" + poId + "&type=pdf", "In Đơn Hàng PDF", windowSize);
                                //printURL += "InDonHangTool/";
                                //window.open(printURL + "?c_donhang_id=" + poId, "In Đơn Hàng", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printxbb') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InXacNhanBaoBi/";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In Bao Bì", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPoTinhHinhXuLyPI') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InTinhHinhXuLyPI/";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In Tình Hình Xử Lý PI", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPoTem') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InDonHangTem/";
                                win = window.open(printURL + "?donhang_id=" + poId, "In Đơn Hàng Tem", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printBook') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InBookcontainer/";
                                win = window.open(printURL + "?donhang_id=" + poId, "In Bookcontainer", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printToKhai') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InPO/ToKhaiHQ.aspx";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In Ctờ khai hải quan", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printDanhMuc') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InPO/DanhMucHQ.aspx";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In danh mục khai hải quan", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printsale') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InPO/SaleContract.aspx";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In Sale Contract", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printInvoice') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InPO/Invoice.aspx";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In Invoice", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printPacking') {
                            if (poId != null) {
                                closeWin();
                                printURL += "InPO/PackingList.aspx";
                                win = window.open(printURL + "?c_donhang_id=" + poId, "In Packing List", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printST_PO') {
                            closeWin();
                            printURL += "InPO/printST_PO.aspx";
                            win = window.open(printURL, "Chiết xuất tất cả các PO đang \"Soạn Thảo\"", windowSize);
                        }
                        else {
                            closeWin();
                            printURL += "InDSYeuCauXuatHang/";
                            win = window.open(printURL, "In Danh Sách Phiếu Xuất", windowSize);
                        }
                    } else {
                        alert('Hãy chọn cách in.!');
                    }
                }
            }
            , {
                id: "btn-print-close",
                text: "Thoát",
                click: function () {
                    $(this).dialog("destroy").remove();
                }
            }
            ]
        });
    }

    function sendMailPO() {
        var poId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        if (poId == null) {
            alert('Hãy chọn một đơn hàng mà bạn muốn gửi email!');
        } else {
            $.get("Controllers/DonHangController.ashx?action=sendmail&poId=" + poId, function (result) {
                window.open(result, "Gửi email");
            });
        }
    }

    function KetThucDonHang() {
        var msg = "";
        var id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            msg = "Hãy chọn 1 đơn hàng mà bạn muốn kết thúc.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-ketthuc-donhang\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-ketthuc-donhang').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            msg = "Có phải bạn muốn kết thúc đơn hàng này.?";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-ketthuc-donhang\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-ketthuc-donhang').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                [
                    {
                        id: "btn-active",
                        text: "Có",
                        click: function () {
                            $("#dialog-caution").ajaxStart(function () {
                                $("#wait").css("display", "block");
                                $("#btn-active").button("disable");
                                $("#btn-close").button("disable");
                            });

                            $("#dialog-caution").ajaxComplete(function () {
                                $("#wait").css("display", "none");
                                $("#btn-close span").text("Thoát");
                                $("#btn-close").button("enable");
                            });

                            $.get("Controllers/DonHangController.ashx?action=stoppo&poId=" + id, function (result) {
                                //$('#dialog-caution').css({ 'color': 'green' });
                                $('#dialog-ketthuc-donhang').find('#dialog-caution').html(result);
                                $('#grid_ds_po').jqGrid().trigger('reloadGrid');
                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }

    function CopyDonHang() {
        var msg = "";
        var id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');

        if (id == null) {
            msg = "Hãy chọn 1 đơn hàng mà bạn muốn sao chép.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-saochep-donhang\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-saochep-donhang').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            msg = "Có phải bạn muốn sao chép đơn hàng này.?";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-saochep-donhang\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-saochep-donhang').dialog({
                modal: true
                , open: function (event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                [
                    {
                        id: "btn-active",
                        text: "Có",
                        click: function () {
                            $("#dialog-caution").ajaxStart(function () {
                                $("#wait").css("display", "block");
                                $("#btn-active").button("disable");
                                $("#btn-close").button("disable");
                            });

                            $("#dialog-caution").ajaxComplete(function () {
                                $("#wait").css("display", "none");
                                $("#btn-close span").text("Thoát");
                                $("#btn-close").button("enable");
                            });

                            $.get("Controllers/DonHangController.ashx?action=CopyDonHang&poId=" + id, function (result) {
                                //$('#dialog-caution').css({ 'color': 'green' });
                                $('#dialog-saochep-donhang').find('#dialog-caution').html(result);
                                $('#grid_ds_po').jqGrid().trigger('reloadGrid');
                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function () {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }

    function ShowPBGCu_grid_ds_po(frmID, action) {
        let ShowPBGCu = function () {
            let chkPBGCu = $('#chkPBGCu', frmID);
            let tr_phienbangiacu = $('#tr_phienbangiacu', frmID);
            if (chkPBGCu.prop('checked') == true) {
                tr_phienbangiacu.show();
            }
            else {
                tr_phienbangiacu.hide();
            }
        }

        let chkPBGCu_ = $('#chkPBGCu', frmID);
        chkPBGCu_.off('change');
        chkPBGCu_.change(function () {
            ShowPBGCu();
        });
        ShowPBGCu();

        let discount_hehang_val = function (result, type) {
            let json = JSON.parse(result);
            let table = '';
            for (let i in json) {
                let row = json[i];
                table += `
                <tr>
                    <td style="color: blue">${row['hehang']}</td>
                    <td style="width:20px"></td>
                    <td><input type="number" ${type == 1 ? "disabled" : ""} value="${row['giatri']}"></td>
                </tr>`;
            }
            table = `
            <table class="tbl_discount_hehang_value" style="display: inline;">
                ${table}
            </table>
            `;

            $('.tbl_discount_hehang_value').remove();
            $('#discount_hehang_value').parent().append(table);
        };

        if ($('#discount_hehang_value').parent().attr('colspan') != '2') {
            $('#discount_hehang_value').parent().prev().remove();
            $('#discount_hehang_value').parent().attr('colspan', '2').attr('rowspan', '10');
        }
        $('#discount_hehang_value').hide();
        let c_donhang_id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        $('#discount_hehang').off('change');
        $('#discount_hehang').change(function () {
            let val = $('#discount_hehang_value').val();
            if ($(this).prop('checked') == true) {
                $('#discount').val('0').prop('disabled', true);
                //$('#phanbodiscount').prop('disabled', true);
                //$('#phanbodiscount').prop('checked', false);
                $.get("Controllers/SelectOption/ApDungDisCountHeHang.ashx",
                    { "action": "DiscountHH", "c_donhang_id": c_donhang_id },
                    function (result) {
                        discount_hehang_val(result);
                    });
            }
            else {
                $('#discount').prop('disabled', false);
                //$('#phanbodiscount').prop('disabled', false);
                $('.tbl_discount_hehang_value').remove();
            }

            $('#phanbodiscount').change(function () {
                if ($(this).prop('checked') == true) {
                    //$('#discount_hehang').prop('disabled', true);
                    //$('#discount_hehang').prop('checked', false).change();
                }
                else {
                    //$('#discount_hehang').prop('disabled', false);
                }
            });
        });

        let idDH = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        let ttDH = $('#grid_ds_po').jqGrid('getCell', idDH, 'md_trangthai_id') + '';
        
        if (ttDH.lastIndexOf('SOANTHAO') > -1)
            $('#discount_hehang').prop('disabled', false);
        else
            $('#discount_hehang').prop('disabled', true);

        $('#discount_hehang').change();

        let ShowPBGDB = function () {
            let $gia_db = $('#gia_db', frmID);
            let $phienbangiadacbiet = $('#phienbangiadacbiet', frmID);
            if (action == 'edit') {
                $phienbangiadacbiet.prop('disabled', true);
            }
            else {
                if ($gia_db.prop('checked') == true) {
                    $phienbangiadacbiet.prop('disabled', false);
                    $phienbangiadacbiet.css('background', '#FFF');
                }
                else {
                    $phienbangiadacbiet.prop('disabled', true);
                    $phienbangiadacbiet.css('background', '');
                    $phienbangiadacbiet.val('');
                    $phienbangiadacbiet.prev().val('');
                }
            }
        }

        let $gia_db = $('#gia_db', frmID);
        $gia_db.off('click');
        $gia_db.click(function () {
            ShowPBGDB();
        });
        ShowPBGDB();

        let $prtghh = $('#tanggiahehang_value').parent();

        let tanggiahehangClick = function () {
            let tghh = $('#tanggiahehang').prop('checked');
            let $tghhv = $('#tanggiahehang_value');
            let $tg = $('#tanggia');
            if (tghh == true) {
                $tg.prop('disabled', true);
                $tg.val(0);
                $prtghh.show();
                $prtghh.prev().show();
                $prtghh.prev().hide();
                $prtghh.attr('colspan', 2);
                $tghhv.css('width', '80%');
            }
            else {
                $tg.prop('disabled', false);
                $tghhv.val('');
                $prtghh.hide();
                $prtghh.prev().hide();
            }
        };
        $('#tanggiahehang').off('change');
        $('#tanggiahehang').change(function () {
            tanggiahehangClick();
        });
        tanggiahehangClick();

        if (action == 'edit') {
            $('#tanggiahehang').prop('disabled', false);
        }
        else {
            $('#tanggiahehang').prop('disabled', true);
        }
    }
</script>
<DIV class="ui-layout-center ui-widget-content" id="lay-center-po" style="padding:0;">
<uc1:jqGrid  ID="grid_ds_po"
            FuncViewCapacity = "viewCapacity"
            FuncActivePO ="funcActivePO"
            FuncSendMail="sendMailPO"
            FuncPI = "funcPI"
            BtnPrint="funcPrint"
            Caption="Đơn Hàng"
            SortName="dh.ngaytao" 
            SortOrder="desc"
            UrlFileAction="Controllers/DonHangController.ashx" 
            PostData = "'status' : 'all'"
            FuncKetThuc = "KetThucDonHang"
			FuncCopyDonHang="CopyDonHang"
			MultiSelect="true"
           
            RowNumbers="true"
            OndblClickRow = "function(rowid) {
                $('#edit_grid_ds_po').click();
			}"
            ColModel = "[
            {
                name: 'c_donhang_id'
                , label: 'c_donhang_id'
                , index: 'c_donhang_id'
                , fixed:true , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
                , formoptions: { colpos: 1, rowpos: 1 }
            },
            {
                 name: 'md_trangthai_id'
                 , label: 'TT'
                 , index: 'md_trangthai_id'
                 , editable: false
                 , fixed:true , width: 100
                 , edittype: 'text'
                 , align:'center'
                 , formatter:'imagestatus'
                 , search : true
                 , stype : 'select'
                 , searchoptions:{sopt:['eq'], value:':[ALL];SOANTHAO:SOẠN THẢO;HIEULUC:HIỆU LỰC;KETTHUC:KẾT THÚC' }
            },
            {
                 name: 'trangthaict'
                 , label: 'TT Chứng từ'
                 , index: 'trangthaict'
                 , editable: false
                 , fixed:true , width: 100
                 , edittype: 'text'
                 , align:'center'
                 , formatter: 'trangthai'
                 , search : true
                 , stype : 'select'
                 , searchoptions:{sopt:['eq'], value:':[ALL];CHUAGUI:Chưa gửi;DAGUI:Đã gửi;DAHIEULUC:Đã nhận;TUCHOI:Từ chối' }
            },
			{
                 name: 'md_doitackinhdoanh_id'
                 , label: 'Khách Hàng'
                 , index: 'dtkd.md_doitackinhdoanh_id'
                 , editable: true
                 , fixed:true 
                 , width: 120
                 , edittype: 'select'
                 , editoptions: { style: 'max-width:160px', dataUrl: 'Controllers/PartnerController.ashx?action=getoption&isncc=0' }
                 , formoptions: { label:'Khách Hàng ' + ip_fd(), colpos: 1, rowpos: 4 }
                 , search: true
                 , stype: 'select'
                 , searchoptions:{ sopt:['eq'], dataUrl: 'Controllers/PartnerController.ashx?action=getsearchoption&isncc=0' } 
            },
            {
                 name: 'sochungtu'
                 , label: 'Số chứng từ'
                 , index: 'sochungtu'
                 , editable: true
                 , fixed:true 
                 , width: 130
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 2 }
            },
            {
                 name: 'customer_order_no'
                 , label: 'Customer Order No'
                 , index: 'customer_order_no'
                 , editable: true
                 , fixed:true 
                 , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 3 }
            },
			{
                 name: 'md_cangbien_id'
                 , label: 'Cảng biển'
                 , index: 'cbien.ten_cangbien'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { style: 'max-width:160px', dataUrl: 'Controllers/QuotationController.ashx?action=getSelectOption_cb' }
                 , formoptions: { label:'Cảng Biển ' + ip_fd(), colpos: 1, rowpos: 6 }
            },
			{
                 name: 'shipmenttime'
                 , label: 'Shipment Time'
                 , index: 'shipmenttime'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy', altField: '#shipmentdate', altFormat: 'dd/mm/yy', onSelect: function(){ var date = $(this).datepicker('getDate');  if (date) {  date.setDate(date.getDate() + 7);  $('#shipmentdate').datepicker('setDate', date);  }   }  }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editrules: { required:true}
                 , formoptions: { label:'Shipment Time ' + ip_fd(), colpos: 1, rowpos: 8 }
                 , search: true
                 , stype: 'text'
                 , searchoptions: { 
                    sopt: ['eq', 'ne']
                    , dataInit: function (elem) { 
                        $(elem).datepicker({ 
                            changeYear: true
                            , changeMonth: true
                            , dateFormat:'dd/mm/yy'
                            , onSelect: function(dateText, inst) {
                               if (this.id.substr(0, 3) === 'gs_') {
                                    // call triggerToolbar only in case of searching toolbar
                                    setTimeout(function () {
                                        // Kiểm tra ngày nếu thuộc 'dd/MM/yyyy' mới cho lộc
                                        var regex = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
                                        if(regex.test(dateText)){
                                            $('#grid_ds_po')[0].triggerToolbar();
                                        }
                                    }, 100);
                                }
                            }
                        });
                    } 
                 }
            },
			{
                 name: 'totalcbm'
                 , label: 'Total CBM'
                 , index: 'totalcbm'
                 , editable: false
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , align: 'right'
            },
			{
                 name: 'amount'
                 , label: 'Amount'
                 , index: 'amount'
                 , editable: false
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , align: 'right'
				 , formatter:'number'
                 , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
            },
			{
                 name: 'discount'
                 , hidden: true
                 , label: 'Discount(%)'
                 , index: 'discount'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 7 }
                 , editoptions:{ defaultValue: '0'}
                 , editrules: { required:true, number:true, minValue: 0, edithidden: true }
                 , align: 'right'
            },
			{
                 name: 'md_paymentterm_id'
                 , label: 'Paymentterm'
                 , index: 'pmt.ten_paymentterm'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { style: 'max-width:160px', dataUrl: 'Controllers/PaymentTermController.ashx?action=getoption' }
                 , formoptions: { label:'Paymentterm ' + ip_fd(), colpos: 1, rowpos: 11 }
            },
            {
                 name: 'md_nganhang_id'
                 , label: 'Thông tin ngân hàng'
                 , index: 'ngh.ma_nganhang'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/NganHangController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 12 }
            },
			{
                 name: 'hoahong'
                 , label: 'Hoa hồng(%)'
                 , index: 'hoahong'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 18 }
                 , editoptions:{ defaultValue: '0' }
                 , editrules: { required:true, number:true, minValue: 0 }
            },
            {
                 name: 'md_nguoilienhe_id'
                 , label: 'Người hưởng HH'
                 , index: 'md_nguoilienhe_id'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/NguoiLienHeController.ashx?action=getoptionNullFirst' }
                 , formoptions: { colpos: 1, rowpos: 17 }
				 , hidden: true
				 , editrules: { edithidden:true }
            },
            {
                 name: 'ngaylap'
                 , label: 'Ngày lập'
                 , index: 'ngaylap'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editrules: { required:true}
                 , formoptions: { colpos: 1, rowpos: 5 }
                 , search: true
                 , stype: 'text'
                 , searchoptions: { 
                    sopt: ['eq', 'ne']
                    , dataInit: function (elem) { 
                        $(elem).datepicker({ 
                            changeYear: true
                            , changeMonth: true
                            , dateFormat:'dd/mm/yy'
                            , onSelect: function(dateText, inst) {
                               if (this.id.substr(0, 3) === 'gs_') {
                                    // call triggerToolbar only in case of searching toolbar
                                    setTimeout(function () {
                                        // Kiểm tra ngày nếu thuộc 'dd/MM/yyyy' mới cho lộc
                                        var regex = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
                                        if(regex.test(dateText)){
                                            $('#grid_ds_po')[0].triggerToolbar();
                                        }
                                    }, 50);
                                }
                            }
                        });
                    } 
                 }
            },
            {
                 name: 'nguoilap'
                 , label: 'Người lập'
                 , index: 'dh.nguoilap'
                 , editable: false
                 , fixed:true , width: 50
                 , edittype: 'text'
            },
            {
                 name: 'shipmentdate'
                 , label: 'Shipment Date'
                 , index: 'shipmentdate'
                 , editable: true
                 , hidden: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); if (currentTime) {  currentTime.setDate(currentTime.getDate() + 7) }; var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editrules: { required:true}
                 , formoptions: { colpos: 1, rowpos: 9 }
                 , search: true
                 , stype: 'text'
                 , searchoptions: { 
                    sopt: ['eq', 'ne']
                    , dataInit: function (elem) { 
                        $(elem).datepicker({ 
                            changeYear: true
                            , changeMonth: true
                            , dateFormat:'dd/mm/yy'
                            , onSelect: function(dateText, inst) {
                               if (this.id.substr(0, 3) === 'gs_') {
                                    // call triggerToolbar only in case of searching toolbar
                                    setTimeout(function () {
                                        // Kiểm tra ngày nếu thuộc 'dd/MM/yyyy' mới cho lộc
                                        var regex = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
                                        if(regex.test(dateText)){
                                            $('#grid_ds_po')[0].triggerToolbar();
                                        }
                                    }, 100);
                                }
                            }
                        });
                    } 
                 }
            },
            {
                 name: 'ngaydieuchinh'
                 , label: 'Ngày điều chỉnh'
                 , index: 'ngaydieuchinh'
                 , editable: true
                 , hidden:true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 10 }
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); if (currentTime) {  currentTime.setDate(currentTime.getDate() + 7) }; var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            },
            
			{
                 name: 'donhang_mau'
                 , label: 'ĐH Mẫu SR'
                 , index: 'donhang_mau'
                 , editable: true
                 , fixed:true 
                 , width: 50
                 , edittype: 'checkbox'
                 , align:'center'
                 , formatter: 'checkbox'
				 , editoptions:{ value:'True:False', defaultValue: 'False' }
                 , formoptions: { colpos: 1, rowpos: 24 }
            },
            {
                 name: 'isdonhangtmp'   
                 , label: 'ĐH Mẫu TI'
                 , align: 'center'
                 , index: 'isdonhangtmp'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'checkbox'
                 , formatter: 'checkbox'
				 , hidden: true
                 , editoptions:{ value:'True:False', defaultValue: 'False' }
                 , formoptions: { colpos: 1, rowpos: 25 }
            },
			{
                 name: 'md_trongluong_id'
                 , label: 'Tr.Lượng'
                 , index: 'tl.ten_trongluong'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/TrongLuongController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 13 }
                 , hidden: true
                 , editrules:{ edithidden: true }
                 , align: 'right'
            },
            {
                 name: 'md_dongtien_id'
                 , label: 'Đồng Tiền'
                 , index: 'dtien.ma_iso'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/CurrencyController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 14 }
                 , hidden: true
                 , editrules:{ edithidden: true }
                 , align: 'center'
            },
            {
                 name: 'md_kichthuoc_id'
                 , label: 'Kích Thước'
                 , index: 'kt.ten_kichthuoc'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/KichThuocController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 15 }
                 , hidden: true
                 , editrules:{ edithidden: true }
                 , align: 'center'
            },
            {
                 name: 'payer'
                 , label: 'Payer'
                 , index: 'payer'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 16 }
				 , hidden: true
				 , editrules: { edithidden: true }
            },
            {
                 name: 'portdischarge'
                 , label: 'PortDischarge'
                 , index: 'portdischarge'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 19 }
				 , hidden: true
				 , editrules: { edithidden: true }
            },
            {
                 name: 'totalcbf'
                 , label: 'Total CBF'
                 , index: 'totalcbf'
                 , editable: false
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , align: 'right'
				 , hidden: true
            },
            {
                 fixed:true
                 , name: 'cont20'
                 , label: 'Cont 20'
                 , index: 'cont20'
                 , editable: true
                 , width: 50
                 , edittype: 'text'
                 , align: 'right'
                 , editrules:{ required:true, number:true }
                 , editoptions:{ defaultValue: '0' }
                 , formoptions: { label:'Cont 20 ' + ip_fd(),colpos: 2, rowpos: 3 }
				 , hidden: true
				 , editrules: { edithidden: true }
            },
            {
                 fixed:true
                 , name: 'cont40'
                 , label: 'Cont 40'
                 , index: 'cont40'
                 , editable: true
                 , width: 50
                 , edittype: 'text'
                 , align: 'right'
                 , editrules:{ required:true, number:true }
                 , editoptions:{ defaultValue: '0' }
                 , formoptions: { label:'Cont 40 ' + ip_fd(),colpos: 2, rowpos: 4 }
				 , hidden: true
				 , editrules: { edithidden: true }
            },
            {
                 fixed:true
                 , name: 'cont40hc'
                 , label: 'Cont 40HC'
                 , index: 'cont40hc'
                 , editable: true
                 , width: 50
                 , edittype: 'text'
                 , align: 'right'
                 , editrules:{ required:true, number:true }
                 , editoptions:{ defaultValue: '0' }
                 , formoptions: { label:'Cont 40hc ' + ip_fd(),colpos: 2, rowpos: 5 }
				 , hidden: true
				 , editrules: { edithidden: true }
            },
			{
                 fixed:true
                 , name: 'cont45'
                 , label: 'Cont 45'
                 , index: 'cont45'
                 , editable: true
                 , width: 50
                 , edittype: 'text'
                 , align: 'right'
                 , editrules:{ required:true, number:true }
                 , editoptions:{ defaultValue: '0' }
                 , formoptions: { label:'Cont 45 ' + ip_fd(),colpos: 2, rowpos: 6}
				 , hidden: true
				 , editrules: { edithidden: true }
            },
            {
                 fixed:true
                 , name: 'contle'
                 , label: 'Cont lẻ'
                 , index: 'contle'
                 , editable: true
                 , width: 50
                 , edittype: 'text'
                 , align: 'right'
                 , editrules:{ required:true, number:true }
                 , editoptions:{ defaultValue: '0' }
                 , formoptions: { label:'Cont lẻ ' + ip_fd(),colpos: 2, rowpos: 7 }
				 , hidden: true
				 , editrules: { edithidden: true }
            },
            {
                 name: 'dagui_mail'   
                 , label: 'Đã Gửi Mail'
                 , index: 'dagui_mail'
                 , align: 'center'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'checkbox'
                 , formatter: 'checkbox'
                 , editoptions:{ value:'True:False', defaultValue: 'False' }
                 , formoptions: { colpos: 1, rowpos: 22 }
				 , hidden: true
				 , editrules: { edithidden: true }
            },
            {
                 name: 'ismakepi'   
                 , label: 'Make PI'
                 , align: 'center'
                 , index: 'ismakepi'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'checkbox'
                 , formatter: 'checkbox'
                 , editoptions:{ value:'True:False', defaultValue: 'False', readonly: 'readonly' }
                 , formoptions: { colpos: 1, rowpos: 23 }
                 , hidden: true
            },
             {
                 name: 'loai'   
                 , label: 'Loại ĐH'
                 , align: 'center'
                 , index: 'loai'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , align: 'center'
                 , editoptions: {style:'width:150px', value: ':Bình thường;PTSP:Phát triển sản phẩm' }
                 , formoptions: { colpos: 1, rowpos: 30 }
                 , hidden: true
                 , editrules: { edithidden: true }
            },
            {
                name: 'ngaytao'
                , label: 'Ngày tạo'
                , index: 'ngaytao'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
                
            },
            {
                name: 'nguoitao'
                , label: 'Người tạo'
                , index: 'nguoitao'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                name: 'ngaycapnhat'
                , label: 'Ngày cập nhật'
                , index: 'ngaycapnhat'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                name: 'nguoicapnhat'
                , label: 'Người cập nhật'
                , index: 'nguoicapnhat'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                name: 'mota'
                , label: 'Mô tả'
                , index: 'mota'
                , fixed:true , width: 50
                , editable:true
                , edittype: 'text'
                , hidden: true
				, edirules:{ edithidden: true }
                , formoptions: { colpos: 2, rowpos: 8 }
            },
            {
                name: 'hoatdong'
                , label: 'Hoạt động'
                , hidden: true
                , index: 'hoatdong'
                , width: 30
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , formatter: 'checkbox'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formoptions: { colpos: 1, rowpos: 27 }
            },
            {
                 name: 'tanggia'
                 , hidden: true
                 , label: 'Tăng giá (%)'
                 , index: 'tanggia'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 2, rowpos: 11 }
                 , editoptions:{ defaultValue: '0'}
                 , editrules: { number:true, minValue: 0, edithidden: true }
                 , align: 'right'
            },
            {
                fixed: true, name: 'tanggiahehang'
                , label: 'Tăng giá theo Hệ Hàng'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editable: true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions: { value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , formoptions: { colpos: 2, rowpos: 12 }
            },
            {
                fixed: true, name: 'tanggiahehang_value'
                , label: 'tanggiahehang_value'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editoptions:{ dataInit: function (elem) { format_donhang_tanggiahehangvalue.create(elem); } }
                , editable: true
                , align: 'center'
                , formoptions: { colpos: 2, rowpos: 13 }
            },
			{
                 name: 'gia_db'   
                 , label: 'Giá ĐB'
                 , align: 'center'
                 , index: 'gia_db'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'checkbox'
                 , formatter: 'checkbox'
                 , editoptions:{ value:'True:False', defaultValue: 'False' }
                 , formoptions: { colpos: 1, rowpos: 28 }
            },
            {
                fixed: true
                , name: 'phienbangiadacbiet'
                , label: 'PBG đặc biệt'
                , index: 'phienbangiadacbiet'
                , width: 100
                , editable: true
                , edittype: 'text'
                , editoptions:{ dataInit: function (elem) { format_donhang_phienbangiadacbiet.create(elem); } }
                , hidden: false 
                , editrules:{ edithidden : true }
                , formoptions: { colpos: 1, rowpos: 29 }
            },
            {
                fixed: true
                , name: 'chkPBGCu'
                , label: 'Giá FOB phiên bản cũ'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , index: 'dh.chkPBGCu'
                , width: 100
                , editable: showPBGCforEveryOne
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions: { value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
            },
			{
                fixed: true
                , name: 'phienbangiacu'
                 , label: 'Phiên bản giá cũ'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , index: 'dh.phienbangiacu'
                , width: 100
                , editable:true
                , edittype: 'select'
                , align: 'center'
                , editoptions: {style:'width:98%', dataUrl: 'Controllers/SelectOption/PhienBanGiaCu.ashx?action=PhienBanGiaCu' }
                , formoptions:{label:'Phiên bản giá cũ ' + ip_fd()}
            },
			{
                fixed: true, name: 'ghichu'
                , label: 'Ghi chú'
                , index: 'ghichu'
                , width: 100
                , editable:true
                , edittype: 'textarea'
                , hidden: false 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'phanbodiscount'
                , label: 'Đưa discount vào giá H.Đồng'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editable: true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions: { value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , formoptions: { colpos: 2, rowpos: 15 }
            },
            {
                fixed: true, name: 'chuyenphiDSDH'
                , label: 'Chuyển phí sang DSDH'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editable: true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions: { value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
                , formoptions: { colpos: 2, rowpos: 16 }
            },
            {
                fixed: true, name: 'discount_hehang'
                , label: 'Discount Hệ Hàng'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editable: true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions: { value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , formoptions: { colpos: 2, rowpos: 17 }
            },
            {
                fixed: true, name: 'discount_hehang_value'
                , label: 'discount_hehang_value'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editable: true
                , align: 'center'
                , formoptions: { colpos: 2, rowpos: 18 }
            },
            {
                fixed: true, name: 'ngaypass'
                , label: 'Ngày pass kiểm hóa'
                , width: 110
                , hidden: false
                , editable: true
                , align: 'center'
                , formoptions: { colpos: 1, rowpos: 31 }
                , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); if (currentTime) {  currentTime.setDate(currentTime.getDate() + 7) }; var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            },
            {
                fixed: true, name: 'ngayBHXN'
                , label: 'Ngày BHXNXH'
                , width: 110
                , hidden: false
                , editable: false
                , align: 'center'
                , formoptions: { colpos: 1, rowpos: 32 }
                , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); if (currentTime) {  currentTime.setDate(currentTime.getDate() + 7) }; var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            }
            ]"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()-90);"
            FilterToolbar = "true"
            Height = "420"
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            OnSelectRow = "function(ids) {
                id_inc_po = ids;
				var chk_box = $('#jqg_grid_ds_po_' + ids);
				setTimeout(function() {
					if(!chk_box.prop('checked')) { ids = null; }
					if(ids == null) {
						ids=0;
						if($('#grid_ds_chitietpo').jqGrid('getGridParam','records') &gt; 0 )
						{
							$('#grid_ds_po').jqGrid('setCaption', 'Đơn Hàng');	
						} 
					} else {
						$.ajax({
							url: 'Controllers/DonHangController.ashx?action=getpoinformation&poId='+ids,
							beforeSend:function(){
								$('#grid_ds_po').jqGrid('setCaption','đang tải...');
							},
							success: function(data){
									$('#grid_ds_po').jqGrid('setCaption', data);
							}
						});		
					}

                    $('#grid_ds_chitietpo').jqGrid('getGridParam', 'postData').poId = ids;
                    $('#grid_khoanphi').jqGrid('getGridParam', 'postData').poId = ids;
					$('#grid_ds_chitietpo')[0].triggerToolbar();
                    $('#grid_khoanphi')[0].triggerToolbar();
                    $('#grid_ds_donhang_spdt')[0].triggerToolbar();
				},10);
			}"
		    AddFormOptions=" 
		        width: 700
                , afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs);
                }
                , beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter();
                    var frmID = '#' + formid.attr('id');
					$('#gia_db', frmID).prop('disabled', false);
					$('#donhang_mau', frmID).prop('disabled', false);
                    $('#loai', frmID).prop('disabled', false);
					$('#chkPBGCu', frmID).prop('disabled', false);
                    ShowPBGCu_grid_ds_po(frmID);
                    disableSelOption('#md_cangbien_id', frmID, false);
                    disableSelOption('#phienbangiacu', frmID, false);
                    $('#discount_hehang').prop('disabled', true);
                }
                , errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterShowForm: createOnchange
                "
            EditFormOptions ="
		        width: 700, 
                afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs);
                }, 
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter();
					var frmID = '#' + formid.attr('id');
                    $('#gia_db', frmID).prop('disabled', true);
					$('#donhang_mau', frmID).prop('disabled', true);
                    $('#loai', frmID).prop('disabled', true);
					$('#chkPBGCu', frmID).prop('disabled', true);
                    ShowPBGCu_grid_ds_po(frmID, 'edit');
                    disableSelOption('#md_cangbien_id', frmID, true);
                    disableSelOption('#phienbangiacu', frmID, true);
                }, 
                beforeSubmit:function(postdata, formid) {
                    let json = [];
                    $('.tbl_discount_hehang_value tr').each(function(){
                        let td0 = $(this).find('td:eq(0)').text();
                        let td2 = $(this).find('td:eq(2)').children('input').val();
                        json.push({ 'hehang': td0, 'giatri': td2 });
                    });
                    postdata.discount_hehang_value = JSON.stringify(json);
                    return [true,''];
                }, 
                errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterShowForm: createOnchange
                "
            ViewFormOptions="
                width: 700,
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
            }"
            runat="server" />
			
	<script type="text/javascript">
	    $(function () {
	        $("#grid_ds_po").jqGrid('navButtonAdd', '#grid_ds_po-pager',
		    {
		        caption: "",
		        buttonicon: "ui-icon-cancel",
		        title: "Hủy đơn hàng",
		        onClickButton: HuyDonHang
            });

            if (vnnIsAdmin == 'True') {
                $("#grid_ds_po").jqGrid('navButtonAdd', '#grid_ds_po-pager',
                    {
                        caption: "",
                        buttonicon: "ui-icon-star",
                        title: "Chuyển đơn hàng",
                        onClickButton: function () {
                            $('body').append(`<div title="Chuyển đơn hàng" id="dialog-chuyendonhang">
                        <div style="display:none" id="waitChuyenDonHang"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                        <div style="margin-top:5px;">
                            <label>Chuyển đơn hàng tới tài khoản:</label>
                            <input id="txtChuyenDonHangUser" type="text" style="margin-top: 5px; padding: 4px;" />
                        </div>
                    </div>`);

                            // create new dialog
                            $('#dialog-chuyendonhang').dialog({
                                modal: true
                                , open: function (event, ui) {
                                    //hide close button.
                                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                                }
                                , buttons: {
                                    'Đồng ý': function () {
                                        let ids = $("#grid_ds_po").jqGrid('getGridParam', 'selarrrow');
                                        let user = $('#txtChuyenDonHangUser').val();
                                        let wait = $('#waitChuyenDonHang');
                                        wait.css('display', '');
                                        let page = $('#grid_ds_po').getGridParam("page");
                                        $.post('Controllers/DonHangController.ashx', { action: 'ChuyenDonHang', id: ids.toString(), user: user }, function (result) {
                                            if (!result) {
                                                $('#grid_ds_po').trigger("reloadGrid", [{ current: true, page: page }]);
                                                $('#dialog-chuyendonhang').dialog("destroy").remove();
                                            }
                                            else {
                                                alert(result);
                                                wait.css('display', 'none');
                                            }
                                        }).fail(function () {
                                            alert('Lỗi');
                                            wait.css('display', 'none');
                                        });
                                    },
                                    'Thoát': function () {
                                        $(this).dialog("destroy").remove();
                                    }
                                }
                            });
                        }
                    });
            }

            $("#grid_ds_po").jqGrid('navButtonAdd', '#grid_ds_po-pager',
            {
                caption: "",
                buttonicon: "ui-icon-lightbulb",
                title: "Gửi chứng từ",
                onClickButton: function () {
                    let ids = $("#grid_ds_po").jqGrid('getGridParam', 'selarrrow');
                    let options = '';
                    for (let i in ids) {
                        let id = ids[i];
                        let row = $("#grid_ds_po").getRowData(id);
                        options += `<option value="${id}">${row.sochungtu}</option>`;
                    }

                    let iddlg = 'dialog-chuyenchungtu';
                    $('body').append(`<div title="Gửi đến chứng từ" id="${iddlg}">
                        <div style="display:none" id="waitChuyenChungTu"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div>
                        <div style="margin-top:5px;">
                            <table style="width:100%">
                                <tr>
                                    <td>Loại chuyển</td>
                                    <td>
                                        <select id="loaichuyen_po">
                                            <option value="Moi">Mới</option>
                                            <option value="Bosung">Bổ sung</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Đơn hàng ưu tiên</td>
                                    <td><select id="dhut_po">${options}</select></td>
                                </tr>
                                <tr>
                                    <td>Cont 20</td>
                                    <td><input id="slcont20_po" type="number"/></td>
                                </tr>
                                <tr>
                                    <td>Cont 40DC</td>
                                    <td><input id="slcont40_po" type="number"/></td>
                                </tr>
                                <tr>
                                    <td>Cont 40HC</td>
                                    <td><input id="slcont40hc_po" type="number"/></td>
                                </tr>
                                <tr>
                                    <td>Cont 45</td>
                                    <td><input id="slcont45_po" type="number"/></td>
                                </tr>
                                <tr>
                                    <td>Cont LCL</td>
                                    <td><input id="slcontLCL_po" type="number"/></td>
                                </tr>
                                <tr>
                                    <td>NXH điều chỉnh</td>
                                    <td><input id="nxhdc_po" style="width:100px" type="text"/></td>
                                </tr>
                                <tr>
                                    <td>Ghi chú</td>
                                    <td><textarea id="ghichu_po"></textarea></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <label>Tập tin đính kèm</label><br>
                                        <input style="margin-top: 7px;" type="file" multiple id="ttdk1_po" accept=".xls,.xlsx,.doc,.docx,.pdf" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>`);

                    // create new dialog
                    $(`#${iddlg}`).dialog({
                        modal: true
                        , open: function (event, ui) {
                            //hide close button.
                            $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                            $('#nxhdc_po').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
                        }
                        , buttons: {
                            'Đồng ý': function () {
                                let slcont20 = Number($('#slcont20_po').val());
                                let slcont40 = Number($('#slcont40_po').val());
                                let slcont40hc = Number($('#slcont40hc_po').val());
                                let slcont45 = Number($('#slcont45_po').val());
                                let slcontLCL = Number($('#slcontLCL_po').val());
                                let slcontLCL = Number($('#slcontLCL_po').val());

                                let $wait = $('#waitChuyenChungTu');
                                $wait.css('display', '');
                                let page = $('#grid_ds_po').getGridParam("page");
                                let data = new FormData();
                                data.append('action', 'ChuyenChungTu');
                                data.append('id', ids.toString());
                                data.append('dhut_po', $('#dhut_po').val());
                                data.append('slcont20', slcont20);
                                data.append('slcont40', slcont40);
                                data.append('slcont40hc', slcont40hc);
                                data.append('slcont45', slcont45);
                                data.append('slcontLCL', slcontLCL);
                                data.append('nxhdc_po', $('#nxhdc_po').val());
                                data.append('ghichu_po', $('#ghichu_po').val());
                                let fileList = $('#ttdk1_po')[0].files;
                                for (let i = 0; i < fileList.length; i++) {
                                    data.append('ttdk1_po', fileList[i]);
                                }
                                $.ajax({
                                    url: 'Controllers/DonHangController.ashx',
                                    data: data,
                                    type: 'POST',
                                    processData: false,
                                    contentType: false,
                                    success: function (result) {
                                        if (!result) {
                                            $('#grid_ds_po').trigger("reloadGrid", [{ current: true, page: page }]);
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
	    });
    </script>
	
	
</DIV>

<DIV class="ui-layout-south ui-widget-content" id="layout-south-po"> 
	<div class="ui-layout-center" id="tabs-donhang-details">
        <ul>
            <li><a href="#donhang-details-1">Các dòng P/O</a></li>
            <li><a href="#donhang-details-2">Các khoản phí liên quan</a></li>
            <li><a href="#donhang-details-3">Shipping Detail</a></li>
        </ul>
        

        <detail:ddh runat="server" />
        
        <div id="donhang-details-2">
            <uc1:jqGrid  ID="grid_khoanphi" 
            SortName="bc.ngaytao" 
            SortOrder="ASC"
            UrlFileAction="Controllers/PhiDonHangController.ashx" 
            ColNames="['c_phidonhang_id', 'Đơn Hàng', 
					'Khách hàng', 'Phí', 'Là Phí Tăng', 'Diễn giải', 'Phân bổ NCU',
					'Nhà cung ứng', 'NCU', 'Là Phí Tăng NCC'
					, 'Ngày tạo' 
                    , 'Người Tạo', 'Ngày Cập Nhật'
                    , 'Người Cập Nhật', 'Diễn giải'
					, 'Chuyển cho nhà cung ứng' 
					, 'Chuyển theo % CBM (P/O)' 
					, 'Chuyển theo công thức giá mua' 
					, 'dsncc_check_ptr'
					, 'dsncc_check_chhet'
					, 'Phí VNĐ' , 'Hoạt động']"
            RowNumbers="true"
            OndblClickRow = "
				function(rowid) { 
					// $(this).jqGrid('editGridRow', rowid,
						// {
							// afterSubmit: function(rs, postdata){
								// return showMsgDialog(rs);
							// }
							// , beforeShowForm: function (formid) {
								// checkbox_khoanphilq();
								// header_phidongpo();
								// formid.closest('div.ui-jqdialog').dialogCenter(); 
							// }
							// , errorTextFormat:function(data) { 
								// return 'Lỗi: ' + data.responseText 
							// }
							// ,afterShowForm:populatePackingPO
						// }
					// ); 
					$('#edit_grid_khoanphi').click();
				}
			"
            ColModel = "[
            {
                name: 'c_phidonhang_id'
                , index: 'c_phidonhang_id'
                , fixed:true , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                name: 'c_donhang_id'
                , index: 'dh.c_donhang_id'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:true
                , hidden: true
            },
			//Là Khách
			{
                 name: 'header_kh'
                 , index: '0'
                 , editable: true
				 , hidden: true
                 , fixed:true 
                 , width: 100
                 , edittype: 'text'
            },
			{
                 name: 'phi'
                 , index: 'phi'
                 , editable: true
                 , fixed:true , width: 100
                 , edittype: 'text'
                 , editoptions:{ defaultValue: '0' }
                 , editrules: { required:true, number:true, minValue: 0 }
                 , align: 'right'
            },
			 {
                 name: 'phitang'
                 , index: 'phitang'
                 , editable: true
                 , fixed:true , width: 100
                 , edittype: 'checkbox'
                 , align: 'center'
                 , editoptions:{ value:'True:False', defaultValue: 'True' }
                 , formatter: 'checkbox'
            },
			{
                name: 'mota'
                , index: 'mota'
                , fixed:true , width: 200
                , editable:true
                , edittype: 'textarea'
            },
			{
                name: 'tracho_ncc'
                , index: 'tracho_ncc'
                , editable: true
                , fixed:true , width: 100
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
            },
			//Là NCU
			{
                 name: 'header_ncc'
                 , index: '0'
                 , editable: true
				 , hidden: true
                 , fixed:true 
                 , width: 100
                 , edittype: 'text'
            },
			{
                 name: 'md_doitackinhdoanh_id'
                 , index: 'dtkd.ma_dtkd'
                 , editable: true
                 , fixed:true 
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/PartnerController.ashx?action=getoption&isncc=1&c_donhang_id=' }
                 , search: true
                 , stype: 'select'
				 , hidden: true
			},
			{
                 name: 'phitang_kh'
                 , index: 'phitang_kh'
                 , editable: true
                 , fixed:true , width: 100
                 , edittype: 'checkbox'
                 , align: 'center'
                 , editoptions:{ value:'True:False', defaultValue: 'True' }
                 , formatter: 'checkbox'
            },
            {
                name: 'ngaytao'
                , index: 'ngaytao'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                name: 'nguoitao'
                , index: 'nguoitao'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
			{
                name: 'diengiai_kh'
                , index: 'diengiai_kh'
                , fixed:true , width: 200
                , editable:true
                , edittype: 'textarea'
            },
            {
                 name: 'check_chhet'
                 , index: 'check_chhet'
                 , editable: true
                 , fixed:true , width: 100
                 , edittype: 'checkbox'
                 , align: 'center'
                 , editoptions:{ value:'True:False', defaultValue: 'False' }
                 , formatter: 'checkbox'
				 , hidden: true
				 , editrules: { edithidden: true }
            },
			
			{
                 name: 'check_ptrCBM'
                 , index: 'check_ptrCBM'
                 , editable: true
                 , fixed:true , width: 100
                 , edittype: 'checkbox'
                 , align: 'center'
                 , editoptions:{ value:'True:False', defaultValue: 'False' }
                 , formatter: 'checkbox'
				 , hidden: true
				 , editrules: { edithidden: true }
            },
			
			{
                 name: 'check_ptr'
                 , index: 'check_ptr'
                 , editable: true
                 , fixed:true , width: 100
                 , edittype: 'checkbox'
                 , align: 'center'
                 , editoptions:{ value:'True:False', defaultValue: 'False' }
                 , formatter: 'checkbox'
				 , hidden: true
				 , editrules: { edithidden: true }
            },
			
			{
                 name: 'dsncc_check_ptr'
                 , index: '0'
                 , editable: true
                 , fixed:true , width: 100
                 , align: 'center'
				 , hidden: true
				 , editrules: { edithidden: true }
            },
			{
                 name: 'dsncc_check_chhet'
                 , index: '0'
                 , editable: true
                 , fixed:true , width: 100
                 , align: 'center'
				 , hidden: true
				 , editrules: { edithidden: true }
            },
			{
                 name: 'phi_vnd' , hidden: true
                 , index: 'phi_vnd'
                 , editable: true
                 , fixed:true , width: 100
                 , edittype: 'text'
                 , editoptions:{ defaultValue: '0' }
                 , editrules: { number:true }
                 , align: 'right'
            },
            {
                name: 'hoatdong', hidden: true
                , index: 'hoatdong'
                , width: 30
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            }
            ]"
            GridComplete = "let o = $('#tabs-donhang-details'); $(this).setGridHeight($(o).height() - 97);$(this).setGridWidth($(o).width())"
            FilterToolbar="true"
            Height = "150"
            Width = "150"
            MultiSelect = "false" 
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            AddFormOptions=" 
                
                beforeShowForm: function (formid) {
					checkbox_khoanphilq();
					header_phidongpo();
					var masterId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
					var forId = 'c_donhang_id';
					if(masterId == null)
					{
						$(formid).parent().parent().parent().dialog('destroy').remove();
						alert('Hãy chọn một đơn hàng mới có thể tạo chi tiết.!');
					}else{
						formid.closest('div.ui-jqdialog').dialogCenter();
					}
                }
                , beforeSubmit:function(postdata, formid){
                    var masterId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
                    var forId = 'c_donhang_id';
                    if(masterId == null)
                    {
                        $(formid).parent().parent().parent().dialog('destroy').remove();
                        return [false,'Hãy chọn một đơn hàng mới có thể tạo chi tiết.!!'];
                    } 
					else 
					{
						var res = get_dsncc_check_ptr();
						var res1 = get_dsncc_check_chhet();
						if(res == 'error' | res1 == 'error') {
							return [false,'Tổng tiền NCC vượt mức quy định.'];
						}
						else {
							postdata.c_donhang_id = masterId;
							postdata.dsncc_check_ptr = res;
							postdata.dsncc_check_chhet = res1;
							return [true,'']; 
						}
                    }
                }
                , afterSubmit: function(rs, postdata){
					$.jgrid.hideModal('#editmodgrid_khoanphi', { gbox: '#gbox_grid_khoanphi'});
					return showMsgDialog(rs);
                }
                "
            EditFormOptions ="
                beforeShowForm: function (formid) {
					checkbox_khoanphilq();
					header_phidongpo();
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                },
                errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterShowForm:populatePackingPO
				, beforeSubmit:function(postdata, formid){
					var res = get_dsncc_check_ptr();
					var res1 = get_dsncc_check_chhet();
					if(res == 'error' | res1 == 'error') {
						return [false,'Tổng tiền NCC vượt mức quy định.'];
					}
					else {
						postdata.dsncc_check_ptr = res;
						postdata.dsncc_check_chhet = res1;
						return [true,'']; 
					}
				}"
            ViewFormOptions="
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
                afterSubmit: function(rs, postdata) { 
                    return showMsgDialog(rs); 
            }"
            runat="server" />
        </div>

        <detail:spdt runat="server" />
    </div>
	
		<div class="ui-layout-east" style="text-align:center; background:#f4f0ec">
			<table style="width:100%; height:100%">
				<tr>
					<td>
						<img id="product-view-po" class="loadingIMG" style="max-width:100%; margin: 0px auto; min-width: 40px;" src="Controllers/API_System.ashx?oper=loadImageProduct&msp=default" />
					</td>
				</tr>
			</table>
		</div> 
	<script>
	    var hide_dtkd_philqpo = function (frm) {
	        $('#tr_md_doitackinhdoanh_id', frm).hide();
	        $('#tr_phitang_kh', frm).hide();
	        $('#tr_diengiai_kh', frm).hide();
	        $('#tbl_dsncc_check_ptr', frm).hide();
	        $('#tbl_dsncc_check_chhet', frm).hide();
	    }

	    var hide_dtkd_philqpo1 = function (frm) {
	        $('#tr_md_doitackinhdoanh_id', frm).hide();
	        $('#tr_phitang_kh', frm).show();
	        $('#tr_diengiai_kh', frm).show();
	        $('#tbl_dsncc_check_ptr', frm).hide();
	        $('#tbl_dsncc_check_chhet', frm).hide();
	    }

	    var show_dtkd_philqpo = function (frm) {
	        $('#tr_phitang_kh', frm).show();
	        $('#tr_diengiai_kh', frm).show();
	        $('#tbl_dsncc_check_ptr', frm).hide();
	    }

	    var checkbox_khoanphilq = function () {
	        var frm = '#FrmGrid_grid_khoanphi';
	        $('#check_chhet', frm).off('change');
	        $('#check_chhet', frm).change(function () {
	            var chk_ptr = $('#check_ptr', frm);
	            var chk_ptrCBM = $('#check_ptrCBM', frm);
	            if ($(this).prop('checked')) {
	                chk_ptr.prop('checked', false);
	                chk_ptrCBM.prop('checked', false);
	                hide_dtkd_philqpo1(frm);
	                $('#tbl_dsncc_check_chhet', frm).show();
	            }
	            else if (chk_ptr.prop('checked') == false & chk_ptrCBM.prop('checked') == false) {
	                hide_dtkd_philqpo(frm);
	            }
	        });

	        $('#check_ptr', frm).off('change');
	        $('#check_ptr', frm).change(function () {
	            var chk_het = $('#check_chhet', frm);
	            var chk_ptrCBM = $('#check_ptrCBM', frm);
	            if ($(this).prop('checked')) {
	                chk_het.prop('checked', false);
	                chk_ptrCBM.prop('checked', false);
	                hide_dtkd_philqpo1(frm);
	                $('#tbl_dsncc_check_ptr', frm).show();
	            }
	            else if (chk_het.prop('checked') == false & chk_ptrCBM.prop('checked') == false) {
	                hide_dtkd_philqpo(frm);
	            }
	        });

	        $('#check_ptrCBM', frm).off('change');
	        $('#check_ptrCBM', frm).change(function () {
	            var chk_ptr = $('#check_ptr', frm);
	            var chk_het = $('#check_chhet', frm);
	            if ($(this).prop('checked')) {
	                chk_ptr.prop('checked', false);
	                chk_het.prop('checked', false);
	                hide_dtkd_philqpo1(frm);
	            }
	            else if (chk_ptr.prop('checked') == false & chk_het.prop('checked') == false) {
	                hide_dtkd_philqpo(frm);
	            }
	        });

	        $('#tracho_ncc', frm).off('change');
	        $('#tracho_ncc', frm).change(function () {
	            var chk_ptr = $('#check_ptr', frm);
	            var chk_het = $('#check_chhet', frm);
	            var chk_ptrCBM = $('#check_ptrCBM', frm);
	            if ($(this).prop('checked')) {
	                if (chk_het.prop('checked')) {
	                    hide_dtkd_philqpo1();
	                }
	                else if (chk_ptr.prop('checked') | chk_ptrCBM.prop('checked')) {
	                    hide_dtkd_philqpo1();
	                }
	                else {
	                    hide_dtkd_philqpo();
	                }
	                $('#tr_header_ncc', frm).show();
	                $('#tr_check_chhet', frm).show();
	                $('#tr_check_ptr', frm).show();
	                $('#tr_check_ptrCBM', frm).show();
	                $('.row_detail', frm).show();
	                //$('#editmodgrid_khoanphi').css('width', '410px');
	            }
	            else {
	                $('#tr_header_ncc', frm).hide();
	                $('#tr_phitang_kh', frm).hide();
	                $('#tr_diengiai_kh', frm).hide();
	                $('#tr_check_chhet', frm).hide();
	                $('#tr_check_ptr', frm).hide();
	                $('#tr_check_ptrCBM', frm).hide();
	                $('#tr_header_ncc', frm).hide();
	                $('#check_chhet', frm).prop('checked', false);
	                $('#check_ptrCBM', frm).prop('checked', false);
	                $('#check_ptr', frm).prop('checked', false);
	                $('.row_detail', frm).hide();

	                //$('#editmodgrid_khoanphi').css('width', '300px');
	            }
	        });

	        $('#phitang', frm).off('change');
	        $('#phitang', frm).change(function () {
	            var phitang_kh = $('#phitang_kh', frm);
	            phitang_kh.prop('checked', $(this).prop('checked'));
	        });
	    };

	    var header_phidongpo = function () {
	        var frm = '#FrmGrid_grid_khoanphi';
	        $('#tr_header_kh', frm).show();
	        $('#tr_header_kh .CaptionTD', frm).attr('colspan', 2).css({ 'font-size': '20px', 'background-color': '#FFF' });
	        $('#tr_header_kh .DataTD', frm).remove();
	        $('#tr_header_ncc', frm).show();
	        $('#tr_header_ncc .CaptionTD', frm).attr('colspan', 2).css({ 'font-size': '20px', 'border-top': '6px solid #383838', 'background-color': '#FFF' });
	        $('#tr_header_ncc .DataTD', frm).remove();

	        $('#tr_dsncc_check_ptr', frm).hide();
	        $('#tr_dsncc_check_chhet', frm).hide();
	        $('#tr_md_doitackinhdoanh_id', frm).hide();

	        $('#check_ptrCBM', frm).change();
	        $('#check_chhet', frm).change();
	        $('#tracho_ncc', frm).change();

	        show_selectoption_dsphi();
	        show_congthuc_giamua();
	        show_chuyenhetNCC();
	        //'<tr rowpos="3" class="FormData"><td colspan=2></td>Khách hàng</tr>'.insertBefore($('#tr_phi'));
        };

        var phiTheoPhanTramDonHang = function (frm) {
            let phiFOB = $('#phi', frm);
            let giafobGoc = $('#giafobGoc', frm);
            let giafob = $('#giafob', frm);
            giafobGoc.prop('disabled', true);

            if (!phiFOB[0].changePT) {
                phiFOB[0].changePT = 1;
                 phiFOB.keydown(function (e) {
                    if (!e.shiftKey) return;

                    let thisSav = $(this);
                    let giaCongTy = giafob.val();
                    giaCongTy = giaCongTy.replace(/ /g, '');

                    let code = e.which || e.keyCode;
                    if (e.shiftKey) {
                        switch (code) {
                            case 53:
                                let valVC = Number(thisSav.val());
                                if (giaCongTy == '')
                                    alert('giá FOB không được bỏ trống');
                                else if (isNaN(valVC))
                                    alert('trường đang nhập chưa có giá trị');
                                else {
                                    let val = Number(giaCongTy);
                                    val = (val * valVC / 100).toFixed(2);
                                    thisSav.val(val);
                                }
                                e.stopPropagation();
                                e.preventDefault();
                        }
                    }
                });
            }

            if (!giafob[0].changePT) {
                giafob[0].changePT = 1;
                giafob.keydown(function (e) {
                    if (!e.shiftKey) return;

                    let thisSav = $(this);
                    let giaCongTy = giafobGoc.val();
                    giaCongTy = giaCongTy.replace(/ /g, '');

                    let code = e.which || e.keyCode;
                    if (e.shiftKey) {
                        switch (code) {
                            case 53:
                                let valVC = Number(thisSav.val());
                                if (giaCongTy == '')
                                    alert('giá FOB gốc không được bỏ trống');
                                else if (isNaN(valVC))
                                    alert('trường đang nhập chưa có giá trị');
                                else {
                                    let val = Number(giaCongTy);
                                    val = (val * valVC / 100).toFixed(2);
                                    thisSav.val(val);
                                }
                                e.stopPropagation();
                                e.preventDefault();
                        }
                    }
                });
            }
        };

	    var show_selectoption_dsphi = function () {
	        var frm = '#FrmGrid_grid_khoanphi';
	        var myVar = setInterval(function () {
	            var options = $('#md_doitackinhdoanh_id', frm).children('option');
	            if (options.length > 0) {
	                clearInterval(myVar);
	                var c_donhang_id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
	                var allow = '';
	                var txt_sel = $('#md_doitackinhdoanh_id', frm).children('option:selected').text();
	                $.getJSON('Controllers/DonHangController.ashx?action=get_dsncc&c_donhang_id=' + c_donhang_id, function (result) {
	                    for (var i in result) {
	                        var row = result[i];
	                        allow += row['ma_dtkd'] + ',';
	                    }
	                    allow = allow.split(',');
	                    var ii = 0;
	                    options.each(function () {
	                        if (allow.indexOf($(this).text()) > -1) {
	                            $(this).show();
	                            if (allow.indexOf(txt_sel) <= -1) {
	                                if (ii == 0) { $(this).prop('selected', true); }
	                                ii++;
	                            }
	                        }
	                        else {
	                            $(this).hide();
	                        }
	                    });
	                });
	            }
	        }, 1000);
	    }
	    var show_chuyenhetNCC = function () {
	        show_congthuc_giamua('chncc');
	    };

	    var show_congthuc_giamua = function (chncc) {
	        var frm = '#FrmGrid_grid_khoanphi';
	        var ava_chk = 'check_ptr';
	        if (chncc != null & chncc != '') {
	            ava_chk = 'check_chhet';
	        }
	        var dsncc_check_ptr = $('#dsncc_' + ava_chk, frm);

	        var c_donhang_id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
	        var tbl_edit_dsncc = JSON.parse('[{"id":"","ma_dtkd":"","tien":"0"}]');
	        try {
	            tbl_edit_dsncc = JSON.parse(dsncc_check_ptr.val());
	        }
	        catch (r) {
	            //alert(r);
	        }

	        $('#tbl_dsncc_' + ava_chk, frm).remove();
	        $.getJSON('Controllers/DonHangController.ashx?action=get_dsncc&c_donhang_id=' + c_donhang_id, function (result) {
	            var tbl = '<tr id="tbl_dsncc_' + ava_chk + '"><td style="padding-top: 6px;" colspan="2"><table>';
	            for (var i in result) {
	                var row = result[i];
	                tbl +=
					`<tr class="row_detail">
						<td style="display:none">`+ row['id'] + `</td>
						<td style="color: blue">`+ row['ma_dtkd'] + `</td>
						<td style="width:20px"></td>
						<td><input type="text" value="`  + row['tien'] + `"/></td>
					</tr>`;
	            }
	            tbl += '</table></tr>';

	            $(tbl).insertAfter(dsncc_check_ptr.parent().parent());
	            var chk_ptr = $('#' + ava_chk, frm);
	            if (chk_ptr.prop('checked') != true) {
	                $('#tbl_dsncc_' + ava_chk, frm).hide();
	            }

	            for (var i in tbl_edit_dsncc) {
	                var row = tbl_edit_dsncc[i];
	                $('#tbl_dsncc_' + ava_chk, frm).children('td').find('.row_detail').each(function () {
	                    var id = $(this).children('td:eq(0)').html();
	                    if (row['id'] == id) {
	                        $(this).children('td:eq(3)').find('input').val(row['tien']);
	                    }
	                });
	            }
	        });
	    }

	    var get_dsncc_check_chhet = function () {
	        return get_dsncc_check_ptr('chncc');
	    };
	    var get_dsncc_check_ptr = function (chncc) {
	        var frm = '#FrmGrid_grid_khoanphi';
	        var ava_chk = 'dsncc_check_ptr';
	        if (chncc != null & chncc != '') {
	            ava_chk = 'dsncc_check_chhet';
	        }

	        var dsncc_check_ptr = $('#' + ava_chk, frm);
	        var check_ptr = $('#check_ptr', frm);
	        var check_chhet = $('#check_chhet', frm);
	        var phi = $('#phi', frm);
	        var result = '', tongtien = 0, tongphi = 0;
	        try { tongphi = Number(phi.val()); } catch (r) { }
	        $('#tbl_' + ava_chk, frm).children('td').find('.row_detail').each(function () {
	            var tien = $(this).children('td:eq(3)').find('input').val();
	            result += "{";
	            result += '"id":"' + $(this).children('td:eq(0)').html() + '",';
	            result += '"ma_dtkd":"' + $(this).children('td:eq(1)').html() + '",';
	            result += '"tien":"' + tien + '"';
	            result += "},";

	            tongtien += Number(tien);

	        });
	        if (result != '') {
	            result = '[' + result.substring(0, result.length - 1) + ']';
	        }

	        var msg = '';
	        if (check_ptr.prop('checked') | check_chhet.prop('checked')) {
	            if (tongtien <= tongphi) {
	                dsncc_check_ptr.val(result);
	                msg = dsncc_check_ptr.val();
	            }
	            else {
	                msg = 'error';
	            }
	        }
	        else {
	            dsncc_check_ptr.val('');
	            msg = dsncc_check_ptr.val();
	        }
	        return msg;
	    };

	    createRightPanel('grid_ds_po');
	    createRightPanel('grid_ds_chitietpo');
	    createRightPanel('grid_khoanphi');
	</script>
</DIV>
    