<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-chiatachpo-taopi.aspx.cs" Inherits="inc_chiatachpo_taopi" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script>
    $(document).ready(function() {
        $('#layout-center-chiatachpo').parent().layout({
            north: {
                size: "50%"
                , minSize: "0%"
                , maxSize: "100%"
                , onresize_end: function() {
                    var o = $("#layout-north-chiatachpo").height();
                    $("#grid_ds_po_chiatach").setGridHeight(o - 90);
                }
            }
        });


        // Soan Thao
        $('#layout-center-chiatachpo').layout({
            west: {
                size: "48.5%"
                , onresize_end: function() {
                    var h = $("#layout-west-soanthao").height();
                    var w = $("#layout-west-soanthao").width();
                    $("#grid_ds_chitietpo_chiatachpo").setGridHeight(h - 70);
                    $("#grid_ds_chitietpo_chiatachpo").setGridWidth(w - 2);
                }
            }
            , east: {
                size: "48.5%"
                , onresize_end: function() {
                    var h = $("#layout-east-soanthao").height();
                    var w = $("#layout-east-soanthao").width();
                    $("#grid_ds_dachon_chiatachpo").setGridHeight(h - 70);
                    $("#grid_ds_dachon_chiatachpo").setGridWidth(w - 2);
                }
            }
        });

        $(".btn-active").button().css({ 'width': '100%', 'height': '25%' });

        $('#add-all-chiatachpo').click(function() {
            var idExist = jQuery("#grid_ds_dachon_chiatachpo").jqGrid('getDataIDs');
            var gridData = jQuery("#grid_ds_chitietpo_chiatachpo");
            var ids = gridData.jqGrid('getDataIDs');

            for (var i = 0, il = ids.length; i < il; i++) {
                var ret = gridData.jqGrid('getRowData', ids[i], true);


                    var datarow = {
                        c_dongdonhang_id: ret.c_dongdonhang_id
                        , c_donhang_id: ret.c_donhang_id
                        , sanpham_id: ret.sanpham_id
                        , ma_sanpham: ret.ma_sanpham
                        , ma_sanpham_khach: ret.ma_sanpham_khach
                        , md_doitackinhdoanh_id: ret.md_doitackinhdoanh_id
                        , soluong: ret.soluong
                        , soluong_dadat_old: ret.soluong_dadat
                        , soluong_dadat: ret.soluong_conlai
                        , soluong_conlai: ret.soluong_conlai
                    };
                    $("#grid_ds_dachon_chiatachpo").jqGrid('addRowData', ids[i], datarow);
                    gridData.jqGrid('delRowData', ids[i]);
                
            }
        });

        $('#add-chiatachpo').click(function() {
            var idExist = jQuery("#grid_ds_dachon_chiatachpo").jqGrid('getDataIDs');
            var id = jQuery("#grid_ds_chitietpo_chiatachpo").jqGrid('getGridParam', 'selrow');
            if (id) {
                var ret = jQuery("#grid_ds_chitietpo_chiatachpo").jqGrid('getRowData', id);

               
                
                    var datarow = {
                        c_dongdonhang_id: ret.c_dongdonhang_id
                        , c_donhang_id: ret.c_donhang_id
                        , sanpham_id: ret.sanpham_id
                        , ma_sanpham: ret.ma_sanpham
                        , ma_sanpham_khach: ret.ma_sanpham_khach
                        , md_doitackinhdoanh_id: ret.md_doitackinhdoanh_id
                        , soluong: ret.soluong
                        , soluong_dadat_old: ret.soluong_dadat
                        , soluong_dadat: ret.soluong_conlai
                        , soluong_conlai: ret.soluong_conlai
                    };
                    jQuery("#grid_ds_chitietpo_chiatachpo").jqGrid('delRowData', id);
                    jQuery("#grid_ds_dachon_chiatachpo").jqGrid('addRowData', id, datarow);

            } else { alert("Please select row"); }
        });

        $('#back-all-chiatachpo').click(function() {

            var gridData = jQuery("#grid_ds_dachon_chiatachpo")
            var ids = gridData.jqGrid('getDataIDs');

            for (var i = 0, il = ids.length; i < il; i++) {
                var ret = gridData.jqGrid('getRowData', ids[i], true);

                var datarow = {
                    c_dongdonhang_id: ret.c_dongdonhang_id
                        , c_donhang_id: ret.c_donhang_id
                        , sanpham_id: ret.sanpham_id
                        , ma_sanpham: ret.ma_sanpham
                        , ma_sanpham_khach: ret.ma_sanpham_khach
                        , md_doitackinhdoanh_id: ret.md_doitackinhdoanh_id
                        , soluong: ret.soluong
                        , soluong_dadat_old: ret.soluong_dadat
                        , soluong_dadat: ret.soluong_conlai
                        , soluong_conlai: ret.soluong_conlai
                };
                $("#grid_ds_chitietpo_chiatachpo").jqGrid('addRowData', ids[i], datarow);
                gridData.jqGrid('delRowData', ids[i]);
            }
        });

        $('#back-chiatachpo').click(function () {

            var gridData = jQuery("#grid_ds_dachon_chiatachpo");
            var id = gridData.jqGrid('getGridParam', 'selrow');
            if (id) {
                var ret = gridData.jqGrid('getRowData', id);

                var datarow = {
                    c_dongdonhang_id: ret.c_dongdonhang_id
                        , c_donhang_id: ret.c_donhang_id
                        , sanpham_id: ret.sanpham_id
                        , ma_sanpham: ret.ma_sanpham
                        , ma_sanpham_khach: ret.ma_sanpham_khach
                        , md_doitackinhdoanh_id: ret.md_doitackinhdoanh_id
                        , soluong: ret.soluong
                        , soluong_dadat_old: ret.soluong_dadat
                        , soluong_dadat: ret.soluong_conlai
                        , soluong_conlai: ret.soluong_conlai
                };

                jQuery("#grid_ds_chitietpo_chiatachpo").jqGrid('addRowData', id, datarow);
                gridData.jqGrid('delRowData', id);

            } else { alert("Please select row"); }
        });
    });


    function funcCreatePI(postData) {
        var msg = "";
        var gridData = jQuery("#grid_ds_dachon_chiatachpo")
        var ids = gridData.jqGrid('getDataIDs');

        if (ids.length == 0) {
            msg = "Hãy chọn danh sách sản phẩm mà bạn muốn tạo PI.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-create-pi\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-create-pi').dialog({
                modal: true
                , open: function(event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons: {
                    'Thoát': function() {
                        $(this).dialog("destroy").remove();
                    }
                }
            });
        } else {
            msg = "Có phải bạn muốn PI từ danh sách sản phẩm này.?";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-create-pi\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-create-pi').dialog({
                modal: true
                , open: function(event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                [
                    {
                        id: "btn-create-pi",
                        text: "Có",
                        click: function() {
                            $("#dialog-caution").ajaxStart(function() {
                                $("#wait").css("display", "block");
                                $("#btn-create-pi").button("disable");
                                $("#btn-close").button("disable");
                            });

                            $("#dialog-caution").ajaxComplete(function() {
                                $("#wait").css("display", "none");
                                $("#btn-close span").text("Thoát");
                                $("#btn-close").button("enable");
                            });

                            // $.get("Controllers/ChiaTachPOController.ashx?action=activepo&poId=" + id, function(result) {
                            //     //$('#dialog-caution').css({ 'color': 'green' });
                            //     $('#dialog-active-po').find('#dialog-caution').html(result);
                            //     $('#grid_ds_po').jqGrid().trigger('reloadGrid');
                            // });
                            $.ajax({
                                url: "Controllers/ChiaTachPOController.ashx",
                                type: "POST",
                                datetype: "json",
                                data: { grid_form: postData, action: "SaveDatHang" },
                                error: function(rs) {
                                    Popup("Error", 500, 400, rs.responseText);
                                },
                                success: function(rs) {
									var type = eval($(rs).find("type").text());
									var message = $(rs).find("message").text();
                                    $('#dialog-create-pi').find('#dialog-caution').html(message);
									var ids = gridData.jqGrid('getDataIDs');

									for (var i = 0, il = ids.length; i < il; i++) {
										jQuery("#grid_ds_dachon_chiatachpo").jqGrid('delRowData', ids[i]);
									}
                                }
                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function() {
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }
    
</script>


<DIV class="ui-layout-north ui-widget-content" id="layout-north-chiatachpo">
    <uc1:jqGrid  ID="grid_ds_po_chiatach" 
            Caption="Đơn Hàng"
            SortName="c_donhang_id" 
            UrlFileAction="Controllers/DonHangChiaTachController.ashx" 
            AfterRefresh = "function(){ 
                var gridData = jQuery('#grid_ds_dachon_chiatachpo')
                var ids = gridData.jqGrid('getDataIDs');
                for (var i = 0, il = ids.length; i &lt; il; i++) {
                    gridData.jqGrid('delRowData', ids[i]);
                }
                jQuery('#grid_ds_chitietpo_chiatachpo').jqGrid().trigger('reloadGrid');
            }"
            PostData = "'status' : 'hieuluc'"
            ColNames="['c_donhang_id', '', 'Đơn Hàng Mẫu', 'Số Chứng Từ','Khách Hàng'
                , 'Ngày Lập', 'Người Lập', 'Cảng Biển'
                , 'Discount', 'Shipment Date'
                , 'Shipment Time', 'Paymentterm'
                , 'Tr.Lượng', 'Đồng Tiền', 'Kích Thước', 'Payer'
                , 'PortDischarge', 'Amount', 'Total CBM', 'Total CBF'
                , 'Make PI', 'Bảng Giá', 'Ngày Tạo'
                , 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật'
                , 'Mô tả', 'Hoạt động']"
            RowNumbers="true"
            ColModel = "[
            {
                fixed: true, name: 'c_donhang_id'
                , index: 'c_donhang_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
                , formoptions: { colpos: 1, rowpos: 1 }
            },
            {
                 fixed: true, name: 'md_trangthai_id'
                 , index: 'md_trangthai_id'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
                 , align:'center'
                 , formatter:'status'
            },
            {
                 fixed: true, name: 'donhang_mau'
                 , index: 'donhang_mau'
                 , editable: true
                 , width: 100
                 , edittype: 'checkbox'
                 , align:'center'
                 , formatter: 'checkbox'
                 , formoptions: { colpos: 1, rowpos: 19 }
            },
            {
                 fixed: true, name: 'sochungtu'
                 , index: 'sochungtu'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 2 }
            },
            {
                 fixed: true, name: 'md_doitackinhdoanh_id'
                 , index: 'dtkd.ma_dtkd'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/PartnerController.ashx?action=getoption&isncc=0' }
                 , formoptions: { colpos: 1, rowpos: 3 }
            },
            {
                 fixed: true, name: 'ngaylap'
                 , index: 'ngaylap'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editrules: { required:true}
                 , formoptions: { colpos: 1, rowpos: 4 }
            },
            {
                 fixed: true, name: 'nguoilap'
                 , index: 'nguoilap'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 5 }
            },
            {
                 fixed: true, name: 'md_cangbien_id'
                 , index: 'cbien.ten_cangbien'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/PortController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 6 }
            },
            {
                 fixed: true, name: 'discount'
                 , index: 'discount'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 7 }
            },
            {
                 fixed: true, name: 'shipmentdate'
                 , index: 'shipmentdate'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editrules: { required:true}
                 , formoptions: { colpos: 1, rowpos: 8 }
                 , hidden: true
            },
            {
                 fixed: true, name: 'shipmenttime'
                 , index: 'shipmenttime'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editrules: { required:true}
                 , formoptions: { colpos: 1, rowpos: 9 }
            },
            {
                 fixed: true, name: 'md_paymentterm_id'
                 , index: 'pmt.ten_paymentterm'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/PaymentTermController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 11 }
            },
            {
                 fixed: true, name: 'md_trongluong_id'
                 , index: 'tl.ten_trongluong'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/TrongLuongController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 12 }
            },
            {
                 fixed: true, name: 'md_dongtien_id'
                 , index: 'dtien.ma_iso'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/CurrencyController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 13 }
            },
            {
                 fixed: true, name: 'md_kichthuoc_id'
                 , index: 'kt.ten_kichthuoc'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/KichThuocController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 14 }
            },
            {
                 fixed: true, name: 'payer'
                 , index: 'payer'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 15 }
            },
            {
                 fixed: true, name: 'portdischarge'
                 , index: 'portdischarge'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , formoptions: { colpos: 1, rowpos: 16 }
            },
            {
                 fixed: true, name: 'amount'
                 , index: 'amount'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'totalcbm'
                 , index: 'totalcbm'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'totalcbf'
                 , index: 'totalcbf'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'ismakepi'
                 , index: 'ismakepi'
                 , editable: true
                 , width: 100
                 , edittype: 'checkbox'
                 , formoptions: { colpos: 1, rowpos: 17 }
                 , editoptions:{ value:'True:False', defaultValue: 'True' }
                 , formatter: 'checkbox'
                 , hidden: true
            },
            {
                 fixed: true, name: 'md_banggia_id'
                 , index: 'bgia.md_banggia_id'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/PriceListController.ashx?action=getoption' }
                 , formoptions: { colpos: 1, rowpos: 10 }
            },
            {
                fixed: true, name: 'ngaytao'
                , index: 'ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
                
            },
            {
                fixed: true, name: 'nguoitao'
                , index: 'nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'mota'
                , index: 'mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
                , hidden: true
                , formoptions: { colpos: 1, rowpos: 18 }
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , index: 'hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
                , formoptions: { colpos: 1, rowpos: 20 }
            }
            ]"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()-90);"
            OnSelectRow = "function(ids) {
                        
                        
		                if(ids == null) {
			                ids=0;
			                if($('#grid_ds_chitietpo_chiatachpo').jqGrid('getGridParam','records') &gt; 0 )
			                {
				                $('#grid_ds_chitietpo_chiatachpo').jqGrid('setGridParam',{url:'Controllers/DongDonHangChiaTachController.ashx?&poId='+ids,page:1});
				                $('#grid_ds_chitietpo_chiatachpo').jqGrid().trigger('reloadGrid');
				                
				                var gridData = jQuery('#grid_ds_dachon_chiatachpo')
                                var ids = gridData.jqGrid('getDataIDs');
                                for (var i = 0, il = ids.length; i &lt; il; i++) {
                                    gridData.jqGrid('delRowData', ids[i]);
                                }
				            } 
				        } else {
			                $('#grid_ds_chitietpo_chiatachpo').jqGrid('setGridParam',{url:'Controllers/DongDonHangChiaTachController.ashx?&poId='+ids,page:1});
			                $('#grid_ds_chitietpo_chiatachpo').jqGrid().trigger('reloadGrid');	
			                
			                var gridData = jQuery('#grid_ds_dachon_chiatachpo')
                            var ids = gridData.jqGrid('getDataIDs');
                            for (var i = 0, il = ids.length; i &lt; il; i++) {
                                gridData.jqGrid('delRowData', ids[i]);
                            }		
		                } }"
            FilterToolbar = "true"
            Height = "420"
            runat="server" />
</DIV>


<DIV class="ui-layout-center ui-widget-content" id="layout-center-chiatachpo">
    
    <DIV class="ui-layout-west ui-widget-content" id="layout-west-soanthao">
                <uc1:jqGrid  ID="grid_ds_chitietpo_chiatachpo" 
            SortName="dtkd.ma_dtkd" 
            UrlFileAction="Controllers/DongDonHangChiaTachController.ashx" 
            ColNames="['c_dongdonhang_id', 'Đơn Hàng', 'Mã SP'
                    , 'Mã SP', 'Mã SP Khách', 'Đối Tác', 'Số Lượng Đơn Hàng'
                    , 'Số Lượng Đã Đặt', 'Số Lượng Còn Lại']"
            RowNumbers="true"
            OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid); }"
            ColModel = "[
            {
                fixed: true, name: 'c_dongdonhang_id'
                , index: 'c_dongdonhang_id'
                , width: 100
                , editable:true
                , edittype: 'text'
                , sortable: false
                , hidden: true
            },
            {
                fixed: true, name: 'c_donhang_id'
                , index: 'dh.c_donhang_id'
                , width: 100
                , edittype: 'text'
                , editable:true
                , sortable: false
                , hidden: true
            },
            {
                fixed: true, name: 'sanpham_id'
                , index: 'sp.sanpham_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , sortable: false
                , key: true
            },
            {
                fixed: true, name: 'ma_sanpham'
                , index: 'sp.ma_sanpham'
                , width: 100
                , edittype: 'text'
                , editable:true
                , sortable: false
                , editoptions: { 
                    dataInit : function (elem) { 
                        $(elem).combogrid({
                            searchIcon: true,
                            width: '480px',
                            url: 'Controllers/ProductController.ashx?action=getcombogrid',
                            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden:true }
                              , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã SP', 'align':'left'}
                              , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả TV' , 'align':'left'}],
                              select: function(event, ui) {
                                    $(elem).val(ui.item.ma_sanpham);
                                    $('#sanpham_id').val(ui.item.md_sanpham_id);
                                    return false;
                              }
                        });
                    } 
                }
            },
            {
                fixed: true, name: 'ma_sanpham_khach'
                , index: 'ddh.ma_sanpham_khach'
                , width: 100
                , edittype: 'text'
                , editable:true
                , sortable: false
            },
            {
                fixed: true, name: 'md_doitackinhdoanh_id'
                , index: 'dtkd.ma_dtkd'
                , width: 100
                , editable:true
                , edittype: 'text'
                , sortable: false
            },
            {
                fixed: true, name: 'soluong'
                , index: 'ddh.soluong'
                , width: 100
                , edittype: 'text'
                , editable:true
                , sortable: false
            },
            {
                fixed: true, name: 'soluong_dadat'
                , index: 'ddh.soluong_dadat'
                , width: 100
                , edittype: 'text'
                , editable:true
                , sortable: false
            },
            {
                fixed: true, name: 'soluong_conlai'
                , index: 'ddh.soluong_conlai'
                , width: 100
                , edittype: 'text'
                , editable:true
                , sortable: false
            }
            ]"
            RowNum = "200"
            Caption = "Danh sách sản phẩm"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 70);"
            ShowRefresh = "false"
            Height = "150"
            MultiSelect = "false" 
            runat="server" />
    </DIV>
    
    <DIV class="ui-layout-east ui-widget-content" id="layout-east-soanthao">
         <script>
             $(document).ready(function() {
                var lastSel = -1;
                 jQuery("#grid_ds_dachon_chiatachpo").jqGrid({
                     datatype: "local",
                     height: 250,
                     colNames: ['c_dongdonhang_id', 'Đơn Hàng', 'Mã SP'
                    , 'Mã SP', 'Mã SP Khách', 'Đối Tác', 'SL Đơn Hàng'
                    , 'SL Đặt Tiếp', 'SL Còn Lại'],
                     colModel: [
                                {
                                    fixed: true, name: 'c_dongdonhang_id'
                                    , index: 'c_dongdonhang_id'
                                    , width: 100
                                    , editable: false
                                    , edittype: 'text'
                                    , sortable: false
                                    , hidden: true
                                },
                                {
                                    fixed: true, name: 'c_donhang_id'
                                    , index: 'dh.c_donhang_id'
                                    , width: 100
                                    , edittype: 'select'
                                    , editable: false
                                    , editoptions: { dataUrl: 'Controllers/DonHangController.ashx?action=getoption' }
                                    , sortable: false
                                    , hidden: true
                                },
                                {
                                    fixed: true, name: 'sanpham_id'
                                    , index: 'sp.sanpham_id'
                                    , width: 100
                                    , hidden: true
                                    , editable: false
                                    , edittype: 'text'
                                    , sortable: false
                                },
                                {
                                    fixed: true, name: 'ma_sanpham'
                                    , index: 'sp.ma_sanpham'
                                    , width: 100
                                    , edittype: 'text'
                                    , editable: false
                                    , sortable: false
                                },
                                {
                                    fixed: true, name: 'ma_sanpham_khach'
                                    , index: 'ddh.ma_sanpham_khach'
                                    , width: 100
                                    , edittype: 'text'
                                    , editable: false
                                    , sortable: false
                                },
                                {
                                    fixed: true, name: 'md_doitackinhdoanh_id'
                                    , index: 'sp.md_doitackinhdoanh_id'
                                    , width: 100
                                    , editable: false
                                    , edittype: 'text'
                                    , sortable: false
                                },
                                {
                                    fixed: true, name: 'soluong'
                                    , index: 'ddh.soluong'
                                    , width: 100
                                    , edittype: 'text'
                                    , editable: false
                                    , sortable: false
                                    , align: 'right'
                                },
                                {
                                    fixed: true, name: 'soluong_dadat'
                                    , index: 'ddh.soluong_dadat'
                                    , width: 100
                                    , edittype: 'text'
                                    , editable: true
                                    , sortable: false
                                    , editrules: { required: true, number: true }
                                    , align: 'right'
                                },
                                {
                                    fixed: true, name: 'soluong_conlai'
                                    , index: 'ddh.soluong_conlai'
                                    , width: 100
                                    , edittype: 'text'
                                    , editable: false
                                    , sortable: false
                                    , hidden: true
                                    , align: 'right'
                                }
                                ],
                     autowidth: true,
                     multiselect: false,
                     caption: "Danh sách sản phẩm đã chọn",
                     gridComplete: function() { var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 70); },
                     showRefresh: false,
                     //rowNumbers: true,
                     viewrecords:true,
                     cellsubmit: 'clientArray',
                     onSelectRow: function(id) {
                         //if (id && id !== lastSel) {
                             jQuery("#grid_ds_dachon_chiatachpo").jqGrid('restoreRow', lastSel);
                             jQuery("#grid_ds_dachon_chiatachpo").jqGrid('editRow', id, true, null, null, 'clientArray');
                             lastSel = id;
                         //}
                     },
                     pager: $('#grid_ds_dachon_chiatachpo-pager')
                 });
                 $('#grid_ds_dachon_chiatachpo').jqGrid('navGrid', '#grid_ds_dachon_chiatachpo-pager', { add: false, edit: false, del: false, search: false, refresh: false }, { height: 280, reloadAfterSubmit: false }, { height: 280, reloadAfterSubmit: false }, { reloadAfterSubmit: false }, {});

                 $("#grid_ds_dachon_chiatachpo").jqGrid('navButtonAdd', '#grid_ds_dachon_chiatachpo-pager', {
                     caption: ""
                    , title: "Lưu đơn đặt hàng"
                    , buttonicon: "icon-pi"
                    , onClickButton: function() {
						//var id = jQuery("#grid_ds_dachon_chiatachpo").jqGrid('getGridParam', 'selrow');
						//jQuery("#grid_ds_dachon_chiatachpo").jqGrid('saveRow', id, true, 'clientArray', null, null);
						var rowids = $("#grid_ds_dachon_chiatachpo").jqGrid('getDataIDs');
                        for(var i in rowids) {
							$("#grid_ds_dachon_chiatachpo").jqGrid('saveRow', rowids[i], true, 'clientArray', null, null);
						}

                        var gridData = jQuery(this).getRowData();
                        var postData = JSON.stringify(gridData);
                        funcCreatePI(postData);
                    }
                 });
             });
        </script>
        <table class="ui-layout-center" id="grid_ds_dachon_chiatachpo"></table>
        <div id="grid_ds_dachon_chiatachpo-pager"></div>
    </DIV>
    
    <DIV class="ui-layout-center ui-widget-content" id="layout-center-soanthao" style="background: #E0CFC2">
        <button id="add-all-chiatachpo" class="btn-active">>></button>
        <button id="add-chiatachpo" class="btn-active">></button>
        <button id="back-all-chiatachpo" class="btn-active"><<</button>
        <button id="back-chiatachpo" class="btn-active"><</button>
    </DIV>
</DIV>

