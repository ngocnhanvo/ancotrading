<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-po.aspx.cs" Inherits="inc_po" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script>
    function updateMoTaGiaPO_CallBack(c_donhang_id, md_sanpham_id) {
        var frm = "#FrmGrid_grid_ds_chitietpo";
        $.ajax({
            url: "Controllers/DongDonHangController.ashx?action=getmotagia&c_donhang_id=" + c_donhang_id + "&md_sanpham_id=" + md_sanpham_id,
            type: "GET",
            success: function (data) {
                $("#ma_sanpham_khach", frm).val(data);
                // var check_docquyen = $('#docquyen','#FrmGrid_grid_ds_chitietpo').val();
                // if(check_docquyen.length > 0) {
                // $("#ma_sanpham_khach", frm).val("");
                // }
                // else {
                // $("#ma_sanpham_khach", frm).val(data);
                // }
            }
        });
    }

    function updateGiaSanPhamPO_CallBack(c_donhang_id, md_sanpham_id) {
        let frm = "#FrmGrid_grid_ds_chitietpo";
        let giafob = $('#giafob', frm);
        let phifob = $('#phi', frm);
        let docquyen = $('#docquyen', frm);
        giafob.val('Đang tải...');
        $.ajax({
            url: "Controllers/DongDonHangController.ashx?action=getgiasanpham&c_donhang_id=" + c_donhang_id + "&md_sanpham_id=" + md_sanpham_id,
            type: "GET",
            success: function (data) {
                data = JSON.parse(data);
                giafob.val(data.gia[0]);
                phifob.val(data.phi[0]);
                updateMoTaGiaPO_CallBack(c_donhang_id, md_sanpham_id);
            }
        });
    }

    function updateNhaCungUngPO_CallBack(md_sanpham_id) {
        var frm = "#FrmGrid_grid_ds_chitietpo";
        var c_dongdonhang_id = $("#c_dongdonhang_id", frm).val();

        $("#nhacungungid", frm)
                    .html("<option value=''>Đang tải nhà cung ứng...</option>")
                    .attr("disabled", "disabled");

        $.ajax({
            url: "Controllers/NhaCungUngMacDinhController.ashx?action=getoptionselected&c_dongdonhang_id=" + c_dongdonhang_id + "&md_sanpham_id=" + md_sanpham_id,
            type: "GET",
            success: function (packingHtml) {
                if (packingHtml != 'null') {
                    $("#nhacungungid", frm).removeAttr("disabled").html(packingHtml);
                } else {
                    $("#nhacungungid", frm).html("<option value=''>Không tìm thấy nhà cung ứng!</option>");
                }
            }
        });
    }

    function updatePackingPO_CallBack(md_sanpham_id) {
        var frm = "#FrmGrid_grid_ds_chitietpo";
        var c_dongdonhang_id = $("#c_dongdonhang_id", frm).val();
        var c_donhang_id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        $("#md_donggoi_id", frm).html("<option value=''>Đang tải đóng gói...</option>").attr("disabled", "disabled");
        $.ajax({
            url: "Controllers/PackingController.ashx?action=getoptionselected&c_dongdonhang_id=" + c_dongdonhang_id + "&md_sanpham_id=" + md_sanpham_id +
            "&c_donhang_id=" + c_donhang_id,
            type: "GET",
            success: function (packingHtml) {
                var arr_pkl = packingHtml.split('(##)');

                if (packingHtml != 'null') {
                    $("#md_donggoi_id", frm).removeAttr("disabled").html(arr_pkl[0]);
                    $("#docquyen", frm).val(arr_pkl[1]);
                } else {
                    $("#md_donggoi_id", frm).html("<option value=''>Không tìm thấy đóng gói!</option>");
                }
            }
        });
    }

    // This function gets called whenever an edit dialog is opened
    function populatePackingPO() {
        let frm = "#FrmGrid_grid_ds_chitietpo";
        // first of all update the city based on the country
        updatePackingPO_CallBack($("#sanpham_id", frm).val());
        updateNhaCungUngPO_CallBack($("#sanpham_id", frm).val());

        let id_sel = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        celgia_db = $('#grid_ds_po').jqGrid('getCell', id_sel, 'gia_db');
        //--
        let giafob = $('#giafob', frm);
        let phifob = $('#phi', frm);
        let docquyen = $('#tr_docquyen', frm);
        if (celgia_db == 'True') {
            giafob.prop('disabled', true);
            phifob.prop('disabled', true);
        }
        else {
            if (vnnIsAdmin == 'True') {
                giafob.prop('disabled', false);
                phifob.prop('disabled', false);
            }
            else {
                giafob.prop('disabled', true);
                phifob.prop('disabled', true);
            }
        }
        docquyen.hide();
        //$("#md_donggoi_id").bind("change", function(e) { updatePackingPO_CallBack($("#sanpham_id").val()); });
        //$("#nhacungungid").bind("change", function(e) { updateNhaCungUngPO_CallBack($("#sanpham_id").val()); });  
    }

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

                    $("#grid_ds_chitietpo").setGridHeight(o.height() - 97);
                    $("#grid_khoanphi").setGridHeight(o.height() - 97);
                }
            }
        });

        // $('#lay-center-po').parent().layout({
        // north: {
        // size: "50%"
        // , minSize: "0%"
        // , maxSize: "100%"
        // , onresize_end: function() {
        // var o = $("#layout-north-po").height();
        // $("#grid_ds_po").setGridHeight(o - 90);

        // }
        // },
        // center: {
        // onresize_end: function() {
        // var o = $("#lay-center-po").height();
        // $("#grid_ds_chitietpo").setGridHeight(o - 98);
        // $("#grid_khoanphi").setGridHeight(o - 98);
        // }
        // }
        // });

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
            msg = "Có phải bạn muốn hiệu lực PO '" + sochungtu + "'.?";
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

                            $.get("Controllers/DonHangController.ashx?action=activepo&poId=" + id, function (result) {
                                //$('#dialog-caution').css({ 'color': 'green' });
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

                            $.get("Controllers/DonHangController.ashx?action=createpi&poId=" + id, function (result) {
                                //$('#dialog-caution').css({ 'color': 'green' });
                                $('#dialog-create-pi').find('#dialog-caution').html(result);
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
                    if (typeof printType != 'undefined') {
                        if (printType == "printRequired") {
                            if (poId != null) {
                                printURL += "InYeuCauXuatHang/";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Phiếu Xuất", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPoDetails') {
                            if (poId != null) {
                                printURL += "InDonHang/";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Chiết Xuất Đơn Hàng", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPo') {
                            if (poId != null) {
                                printURL += "InDonHangTool/";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Đơn Hàng", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printxbb') {
                            if (poId != null) {
                                printURL += "InXacNhanBaoBi/";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Bao Bì", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPoTinhHinhXuLyPI') {
                            if (poId != null) {
                                printURL += "InTinhHinhXuLyPI/";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Tình Hình Xử Lý PI", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printPoTem') {
                            if (poId != null) {
                                printURL += "InDonHangTem/";
                                window.open(printURL + "?donhang_id=" + poId, "In Đơn Hàng Tem", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        } else if (printType == 'printBook') {
                            if (poId != null) {
                                printURL += "InBookcontainer/";
                                window.open(printURL + "?donhang_id=" + poId, "In Bookcontainer", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printToKhai') {
                            if (poId != null) {
                                printURL += "InPO/ToKhaiHQ.aspx";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Ctờ khai hải quan", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printDanhMuc') {
                            if (poId != null) {
                                printURL += "InPO/DanhMucHQ.aspx";
                                window.open(printURL + "?c_donhang_id=" + poId, "In danh mục khai hải quan", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printsale') {
                            if (poId != null) {
                                printURL += "InPO/SaleContract.aspx";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Sale Contract", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printInvoice') {
                            if (poId != null) {
                                printURL += "InPO/Invoice.aspx";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Invoice", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printPacking') {
                            if (poId != null) {
                                printURL += "InPO/PackingList.aspx";
                                window.open(printURL + "?c_donhang_id=" + poId, "In Packing List", windowSize);
                            } else {
                                alert('Bạn chưa chọn đơn hàng cần in.!');
                            }
                        }
                        else if (printType == 'printST_PO') {
                            printURL += "InPO/printST_PO.aspx";
                            window.open(printURL, "Chiết xuất tất cả các PO đang \"Soạn Thảo\"", windowSize);
                        }
                        else {
                            printURL += "InDSYeuCauXuatHang/";
                            window.open(printURL, "In Danh Sách Phiếu Xuất", windowSize);
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
        var ShowPBGCu = function () {
            var chkPBGCu = $('#chkPBGCu', frmID);
            var tr_phienbangiacu = $('#tr_phienbangiacu', frmID);
            if (chkPBGCu.prop('checked') == true) {
                tr_phienbangiacu.show();
            }
            else {
                tr_phienbangiacu.hide();
            }
        }

        var chkPBGCu_ = $('#chkPBGCu', frmID);
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
                $.get("Controllers/SelectOption/ApDungDisCountHeHang.ashx",
                    { "action": "DiscountHH", "c_donhang_id": c_donhang_id },
                    function (result) {
                        discount_hehang_val(result);
                    });
            }
            else {
                $('.tbl_discount_hehang_value').remove();
            }
        });

        let idDH = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
        let ttDH = $('#grid_ds_po').jqGrid('getCell', idDH, 'md_trangthai_id') + '';
        
        if (ttDH.lastIndexOf('SOANTHAO') > -1)
            $('#discount_hehang').prop('disabled', false);
        else
            $('#discount_hehang').prop('disabled', true);

        $('#discount_hehang').change();
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
            ColNames="['c_donhang_id', '', 'Khách Hàng', 'Số Chứng Từ', 'Customer Order No', 'Cảng Biển'
                , 'Shipment Time', 'Total CBM', 'Amount', 'Discount(%)'
                , 'Paymentterm', 'Thông tin ngân hàng', 'Hoa hồng(%)', 'Người hưởng HH','Ngày Lập', 'Người Lập'
                , 'Shipment Date', 'Ngày điều chỉnh', 'ĐH Mẫu SR', 'ĐH Mẫu TI'
                , 'Tr.Lượng', 'Đồng Tiền', 'Kích Thước', 'Payer', 'PortDischarge'
                , 'Total CBF', 'Cont 20', 'Cont 40', 'Cont 40HC', 'Cont 45HC', 'Cont lẻ' 
				, 'Đã Gửi Mail', 'Make PI'
				, 'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật'
                , 'Consingnee', 'Hoạt động', 'Giá đặc biệt'
                , 'Giá FOB phiên bản cũ', 'Phiên bản giá cũ'
                , 'Ghi chú', 'Discount Hệ Hàng', 'discount_hehang_value']"
            RowNumbers="true"
            OndblClickRow = "function(rowid) { 
				/*$(this).jqGrid('editGridRow', rowid, {
					width: 700
					, afterSubmit: function(rs, postdata){
						return showMsgDialog(rs);
					}
					, beforeShowForm: function (formid) {
						checkbox_khoanphilq();
						$('#gia_db','#' + formid.attr('id')).prop('disabled', true);
						$('#donhang_mau','#' + formid.attr('id')).prop('disabled', true);
						$('#md_cangbien_id','#' + formid.attr('id')).prop('disabled', true);
						formid.closest('div.ui-jqdialog').dialogCenter();
					}
					, errorTextFormat:function(data) { 
						return 'Lỗi: ' + data.responseText 
					}
					, afterShowForm: createOnchange
				});*/
                $('#edit_grid_ds_po').click();
			}"
            ColModel = "[
            {
                name: 'c_donhang_id'
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
                 name: 'md_doitackinhdoanh_id'
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
                 , index: 'sochungtu'
                 , editable: true
                 , fixed:true 
                 , width: 130
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 2 }
            },
            {
                 name: 'customer_order_no'
                 , index: 'customer_order_no'
                 , editable: true
                 , fixed:true 
                 , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 3 }
            },
			{
                 name: 'md_cangbien_id'
                 , index: 'cbien.ten_cangbien'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { style: 'max-width:160px', dataUrl: 'Controllers/QuotationController.ashx?action=getSelectOption_cb' }
                 , formoptions: { label:'Cảng Biển ' + ip_fd(), colpos: 1, rowpos: 6 }
            },
			{
                 name: 'shipmenttime'
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
                 , index: 'totalcbm'
                 , editable: false
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , align: 'right'
            },
			{
                 name: 'amount'
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
                 , index: 'discount'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 7 }
                 , editoptions:{ defaultValue: '0' }
                 , editrules: { required:true, number:true, minValue: 0 }
                 , align: 'right'
            },
			{
                 name: 'md_paymentterm_id'
                 , index: 'pmt.ten_paymentterm'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { style: 'max-width:160px', dataUrl: 'Controllers/PaymentTermController.ashx?action=getoption' }
                 , formoptions: { label:'Paymentterm ' + ip_fd(), colpos: 1, rowpos: 11 }
            },
            {
                 name: 'md_nganhang_id'
                 , index: 'ngh.ma_nganhang'
                 , editable: true
                 , fixed:true , width: 50
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/NganHangController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 12 }
            },
			{
                 name: 'hoahong'
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
                 , index: 'dh.nguoilap'
                 , editable: false
                 , fixed:true , width: 50
                 , edittype: 'text'
            },
            {
                 name: 'shipmentdate'
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
                name: 'ngaytao'
                , index: 'ngaytao'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
                
            },
            {
                name: 'nguoitao'
                , index: 'nguoitao'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , fixed:true , width: 50
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                name: 'mota'
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
                 name: 'gia_db'   
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
                , name: 'chkPBGCu'
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
                , index: 'ghichu'
                , width: 100
                , editable:true
                , edittype: 'textarea'
                , hidden: false 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'discount_hehang'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editable: true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions: { value:'True:False', defaultValue: 'False' }
                , formatter: 'checkbox'
                , formoptions: { colpos: 2, rowpos: 11 }
            },
            {
                fixed: true, name: 'discount_hehang_value'
                , hidden: true
                , editrules:{
                    edithidden:true
                }
                , editable: true
                , align: 'center'
                , formoptions: { colpos: 2, rowpos: 12 }
            }
            ]"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()-90);"
            FilterToolbar = "true"
            Height = "420"
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            OnSelectRow = "function(ids) {
				var chk_box = $('#jqg_grid_ds_po_' + ids);
				setTimeout(function() {
					if(!chk_box.prop('checked')) { ids = null; }
					if(ids == null) {
						ids=0;
						if($('#grid_ds_chitietpo').jqGrid('getGridParam','records') &gt; 0 )
						{
							$('#grid_ds_po').jqGrid('setCaption', 'Đơn Hàng');
							// $.ajax({
								// url: 'Controllers/DonHangController.ashx?action=getpoinformation&poId='+ids,
								// beforeSend:function(){
									// $('#grid_ds_po').jqGrid('setCaption','đang tải...');
								// },
								// success: function(data){
									 // $('#grid_ds_po').jqGrid('setCaption', data);
								// }
							// });
							
							$('#grid_ds_chitietpo').jqGrid('setGridParam',{url:'Controllers/DongDonHangController.ashx?&poId='+ids,page:1});
							$('#grid_ds_chitietpo').jqGrid().trigger('reloadGrid');
							
							$('#grid_khoanphi').jqGrid('setGridParam',{url:'Controllers/PhiDonHangController.ashx?&poId='+ids,page:1});
							$('#grid_khoanphi').jqGrid().trigger('reloadGrid');			
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
				
						$('#grid_ds_chitietpo').jqGrid('setGridParam',{url:'Controllers/DongDonHangController.ashx?&poId='+ids,page:1});
						$('#grid_ds_chitietpo').jqGrid().trigger('reloadGrid');	
						$('#grid_khoanphi').jqGrid('setGridParam',{url:'Controllers/PhiDonHangController.ashx?&poId='+ids,page:1});
						$('#grid_khoanphi').jqGrid().trigger('reloadGrid');			
					} 
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
					$('#chkPBGCu', frmID).prop('disabled', true);
                    ShowPBGCu_grid_ds_po(frmID);
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

	    });
    </script>
	
	
</DIV>

<DIV class="ui-layout-south ui-widget-content" id="layout-south-po"> 
	<div class="ui-layout-center" id="tabs-donhang-details">
        <ul>
            <li><a href="#donhang-details">Các dòng P/O</a></li>
            <li><a href="#khoanphi-details">Các khoản phí liên quan</a></li>
        </ul>
        <div id="donhang-details">
            <uc1:jqGrid  ID="grid_ds_chitietpo" 
            SortName="ddh.sothutu" 
            SortOrder="desc"
            UrlFileAction="Controllers/DongDonHangController.ashx" 
            RowNumbers="true"
            OndblClickRow = "function(rowid) { 
												/*$(this).jqGrid('editGridRow', rowid,
                                                    {
                                                        afterSubmit: function(rs, postdata){
                                                            return showMsgDialog(rs);
                                                        }
                                                        , beforeShowForm: function (formid) {
                                                            $('#ma_sanpham', formid).mask('**-*****-**-**');
                                                            $('#tr_giafob', formid).show();
                                                            $('#tr_sothutu', formid).show();
                                                            $('#tr_nhacungungid', formid).show();
                                                            $('#tr_md_donggoi_id', formid).show();
                                                            formid.closest('div.ui-jqdialog').dialogCenter(); 
                                                        }
                                                        , errorTextFormat:function(data) { 
                                                            return 'Lỗi: ' + data.responseText 
                                                        }
                                                        , afterShowForm:populatePackingPO
                                                        , afterclickPgButtons:populatePackingPO
                                                    }
                                                ); }*/
								$('#edit_grid_ds_chitietpo').click();
							}"
            ColModel = "[
            {
                name: 'c_dongdonhang_id'
				, label: 'c_dongdonhang_id'
                , index: 'c_dongdonhang_id'
                , fixed:true , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                name: 'c_donhang_id'
				, label: 'Đơn Hàng'
                , index: 'dh.c_donhang_id'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:true
                , hidden: true
            },
            {
                 fixed: true
				 , name: 'trangthai'
				 , label: 'TT'
                 , index: 'sp.trangthai'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
                 , align:'center'
                 , formatter:'imagestatus'
                 , search : true
                 , stype : 'select'
                 , searchoptions:{ value:':[ALL];MOI:MỚI;DHD:ĐANG HOẠT ĐỘNG;NHD:NGƯNG HOẠT ĐỘNG'}
            },
			{
                 fixed: true, name: 'trangthai_ddh'
				 , label: 'Trạng Thái'
                 , index: 'ddh.trangthai'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
                 , align:'center'
                 , formatter:'imagestatus'
                 , search : true
                 , stype : 'select'
                 , searchoptions:{ value:':[ALL];DGDG:Đổi giá theo đóng gói;BT:Giá bình thường;DQ:HH Độc quyền'}
            },
            {
                name: 'sothutu'
				, label: 'STT'
                , index: 'ddh.sothutu'
                , fixed:true , width: 50
                , edittype: 'text'
                , editable: true
                , editrules: { required:true, number: true }
                , editoptions:{ defaultValue: '0' }
                , align: 'right'
            },
            {
                name: 'sanpham_id'
				, label: 'Mã SP'
                , index: 'sp.sanpham_id'
                , fixed:true , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
            },
            {
                name: 'ma_sanpham'
				, label: 'Mã SP'
                , index: 'sp.ma_sanpham'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:true
                , editoptions: { 
                    dataInit : function (elem) { 
                        $(elem).combogrid({
                            searchIcon: true,
                            width: '480px',
                            url: 'Controllers/ProductController.ashx?action=getcombogrid&soanthao=1',
                            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden:true }
                              , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã SP', 'align':'left'}
                              , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả TV' , 'align':'left'}],
                              select: function(event, ui) {
                                    $(elem).val(ui.item.ma_sanpham);
                                    $('#sanpham_id').val(ui.item.md_sanpham_id);
                                    var c_donhang_id = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
                                    
                                    updateGiaSanPhamPO_CallBack(c_donhang_id, ui.item.md_sanpham_id)                    
                                    updatePackingPO_CallBack(ui.item.md_sanpham_id);
                                    updateNhaCungUngPO_CallBack(ui.item.md_sanpham_id);
									
                                    return false;
                              }
                        });
                    } 
                }
            },
            {
                name: 'ma_sanpham_khach'
				, label: 'Mã SP Khách'
                , index: 'ddh.ma_sanpham_khach'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:true
            },
			{
				name: 'giafob'
				, label: 'Giá'
				, index: 'ddh.giafob'
				, fixed:true , width: 100
				, edittype: 'text'
				, editable: true
				, editrules: { required:true, number: true }
				, editoptions:{ defaultValue: '0' }
				, align: 'right'
				, formatter:'currency'
				, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
			},
                {
				name: 'phi'
				, label: 'Phí'
				, index: 'ddh.phi'
				, fixed:true , width: 100
				, edittype: 'text'
				, editable: true
				, editrules: { required:true, number: true }
				, editoptions:{ defaultValue: '0' }
				, align: 'right'
				, formatter:'currency'
				, formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
			},
            {
                name: 'soluong'
				, label: 'Số Lượng'
                , index: 'ddh.soluong'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:true
                , editoptions:{ defaultValue: '1' }
                , align: 'right'
                , formatter:'number'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            
            {
                name: 'md_donggoi_id'
				, label: 'Đóng Gói'
                , index: 'dg.ten_donggoi'
                , fixed:true , width: 100
                , edittype: 'select'
                , editable: true
                , editoptions: { 'value' : 'Chọn đóng gói' }
				, hidden:true 
				, editrules: { edithidden:true }
            },
            {
                name: 'sl_inner'
				, label: 'Đóng Gói Inner'
                , index: 'ddh.sl_inner'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
            },
            {
                name: 'l1'
				, label: 'L1'
                , index: 'ddh.l1'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
				, hidden:true
            },
            {
                name: 'w1'
				, label: 'W1'
                , index: 'ddh.w1'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
				, hidden:true
            },
            {
                name: 'h1'
				, label: 'H1'
                , index: 'ddh.h1'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
				, hidden:true
            },
            {
                name: 'sl_outer'
				, label: 'Đóng Gói Outer'
                , index: 'ddh.sl_outer'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
            },
            {
                name: 'l2'
				, label: 'L2'
                , index: 'ddh.l2'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
				, hidden:true
            },
            {
                name: 'w2'
				, label: 'W2'
                , index: 'ddh.w2'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
				, hidden:true
            },
            {
                name: 'h2'
				, label: 'H2'
                , index: 'ddh.h2'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
				, hidden:true
            },
			{
                name: 'sl_cont'
				, label: 'SL Cont'
                , index: 'ddh.sl_cont'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
                , formatter:'number'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                name: 'v2'
				, label: 'V2'
                , index: 'ddh.v2'
                , fixed:true , width: 100
                , edittype: 'text'
                , editable:false
                , align: 'right'
            },
			{
                 name: 'nhacungungid'
				 , label: 'Nhà cung ứng'
                 , index: 'dtkd.ma_dtkd'
                 , editable: true
                 , fixed:true 
                 , width: 120
                 , edittype: 'select'
                 , editoptions: { 'value' : 'Chọn nhà cung ứng'}
            },
            
            {
                name: 'ngaytao'
				, label: 'Ngày Tạo'
                , index: 'ddh.ngaytao'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                name: 'nguoitao'
				, label: 'Người Tạo'
                , index: 'ddh.nguoitao'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                name: 'ngaycapnhat'
				, label: 'Ngày Cập Nhật'
                , index: 'ddh.ngaycapnhat'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                name: 'nguoicapnhat'
				, label: 'Người Cập Nhật'
                , index: 'ddh.nguoicapnhat'
                , fixed:true , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                name: 'mota'
				, label: 'Mô tả'
                , index: 'ddh.mota'
                , fixed:true , width: 100
                , editable:true
                , edittype: 'textarea'
				, hidden: true
				, editrules: { edithidden:true }
            },
            {
                name: 'hoatdong', hidden: true
				, label: 'Hoạt động'
                , index: 'ddh.hoatdong'
                , width: 30
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            },
			{
                name: 'docquyen'
				, label: 'Độc quyền'
                , index: 'ddh.docquyen'
                , fixed:true , width: 100
                , editable:true
                , edittype: 'textarea'
				, hidden: false
				, editrules: { edithidden:true }
            },
			{
                name: 'barcode'
				, label: 'Barcode'
                , index: 'ddh.barcode'
                , fixed:true 
				, width: 100
				, hidden: true
            }
            ]"
            GridComplete = "let o = $('#tabs-donhang-details'); $(this).setGridHeight($(o).height() - 97);$(this).setGridWidth($(o).width())"
            FilterToolbar="true"
            Height = "150"
            MultiSelect = "false" 
            ShowAdd ="<%$ Code: DaoRules.GetRuleAdd(Context).ToString().ToLower() %>"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
			OnSelectRow = "
				function(ids) {
					let cellMSP = $('#grid_ds_chitietpo').jqGrid('getCell', ids, 'ma_sanpham') + '';
					let hinhanh = cellMSP.lastIndexOf('F') > -1 ? cellMSP.substr(0, 11) : cellMSP.substr(0, 8) + '.jpg';
					$('#product-view-po').attr('src','images/products/fullsize/' + hinhanh);
				}
			"
            AddFormOptions=" 
                width: 450,
                beforeShowForm: function (formid) {
                        var masterId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
                        var forId = 'c_donhang_id';
                        if(masterId == null)
                        {
                            $(formid).parent().parent().parent().dialog('destroy').remove();
                            alert('Hãy chọn một đơn hàng mới có thể tạo chi tiết.!');
                        }else{
                            $('#tr_' + forId + ' td.DataTD input#' + forId, formid).val(masterId);
							
							$('#ma_sanpham', formid).mask('99-*****-**-**');
                            $('#ma_sanpham', formid).prop('disabled', false);
                            $('#tr_giafob', formid).show();
                            $('#tr_sothutu', formid).hide();
                            $('#tr_nhacungungid', formid).show();
                            $('#tr_md_donggoi_id', formid).show();
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
                    }else{
                        postdata.c_donhang_id = masterId;
						var check_thaydoi = $('#md_donggoi_id > option:selected').attr('other');
						var check_docquyen = $('#docquyen','#FrmGrid_grid_ds_chitietpo').val();
						if(check_thaydoi.toUpperCase() == 'TRUE')
						{
							if(confirm('Lưu ý: Kiểu đóng gói bạn chọn có thể thay đổi giá !') == true) {
								if(check_docquyen != '') {
									if(confirm(check_docquyen) == true) {
										return [true];
									}
									else {
										return [false];
									}
								}
								else {
									return [true];
								}
							}
							else {
								return [false];
							}
						}
						else{
							if(check_docquyen != '') {
								if(confirm(check_docquyen) == true) {
									return [true];
								}
								else {
									return [false];
								}
							}
							else {
								return [true];
							}
						}
                    }
                }
                , afterSubmit: function(rs, postdata){
                   return showMsgDialog(rs);
                }
                , afterShowForm:populatePackingPO
                , afterclickPgButtons:populatePackingPO
                "
            EditFormOptions ="
                width: 450,
                beforeShowForm: function (formid) {
                    $('#ma_sanpham', formid).mask('**-*****-**-**');
                    $('#ma_sanpham', formid).prop('disabled', true);
                    $('#tr_giafob', formid).show();
                    $('#tr_sothutu', formid).show();
                    $('#tr_md_donggoi_id', formid).show();
                    $('#tr_nhacungungid', formid).show();
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
				, beforeSubmit:function(postdata, formid){
                    var masterId = $('#grid_ds_po').jqGrid('getGridParam', 'selrow');
                    var forId = 'c_donhang_id';
                    if(masterId == null)
                    {
                        $(formid).parent().parent().parent().dialog('destroy').remove();
                        return [false,'Hãy chọn một đơn hàng có thể sửa chi tiết.!!'];
                    }else{
                        postdata.c_donhang_id = masterId;
						var check_thaydoi = $('#md_donggoi_id > option:selected').attr('other');
						var check_docquyen = $('#docquyen','#FrmGrid_grid_ds_chitietpo').val();
						if(check_thaydoi.toUpperCase() == 'TRUE')
						{
							if(confirm('Mã hàng đã thay đổi giá theo đóng gói') == true) {
								if(check_docquyen != '') {
									if(confirm(check_docquyen) == true) {
										return [true];
									}
									else {
										return [false];
									}
								}
								else {
									return [true];
								}
							}
							else {
								return [false];
							}
						}
						else{
							if(check_docquyen != '') {
								if(confirm(check_docquyen) == true) {
									return [true];
								}
								else {
									return [false];
								}
							}
							else {
								return [true];
							}
						}
                    }
                },
                errorTextFormat:function(data) { 
                    return 'Lỗi: ' + data.responseText 
                }
                , afterShowForm:populatePackingPO
                , afterclickPgButtons:populatePackingPO"
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
        
        <div id="khoanphi-details">
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
                 , searchoptions:{ sopt:['eq'], dataUrl: 'Controllers/PartnerController.ashx?action=getsearchoption&isncc=1' }
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
    </div>
	
		<div class="ui-layout-east" style="text-align:center; background:#f4f0ec">
			<table style="width:100%; height:100%">
				<tr>
					<td>
						<img id="product-view-po" style="width:200px; height:150px" src="images/products/fullsize/default.jpg" />
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
	    }
	</script>
</DIV>
    