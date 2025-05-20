<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-taophieunhapxuat-tupi2.aspx.cs" Inherits="inc_taophieunhapxuat_tupi2" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script>
    $(document).ready(function () {
        let createLayout = function () {
            let o = Number($("#layout-northcenter-taophieunhapxuat-pi2").height()) - 90;
            let w = window.innerWidth / 2 - 2;
            $('#layout-northwest-soanthao-taophieunhapxuat-pi2').width(w);
            $('#layout-northeast-soanthao-taophieunhapxuat-pi2').width(w);;
            $("#grid_ds_dathang_taophieunhapxuat2").setGridHeight(o);
            $("#grid_ds_dathang_taophieunhapxuat2").setGridWidth(w);
            $("#grid_ds_dathang_taophieunhapxuat3").setGridHeight(o);
            $("#grid_ds_dathang_taophieunhapxuat3").setGridWidth(w);
        };
        $('#layout-center-taophieunhapxuat-pi2').parent().layout({
            north: {
                size: "50%"
                , minSize: "0%"
                , maxSize: "100%"
                , onresize_end: function() {
                    createLayout();
                }
            }
        });
        
        // Soan Thao
        $('#layout-center-taophieunhapxuat-pi2').layout({
            west: {
                size: "49.5%"
                , onresize_end: function() {
                    var h = $("#layout-west-soanthao-taophieunhapxuat-pi2").height();
                    var w = $("#layout-west-soanthao-taophieunhapxuat-pi2").width();
                    $("#grid_ds_chitietdathang_taophieunhapxuat2").setGridHeight(h - 70);
                    $("#grid_ds_chitietdathang_taophieunhapxuat2").setGridWidth(w - 2);
                }
            },
            east: {
                size: "49.5%"
                , onresize_end: function() {
                    var h = $("#layout-east-soanthao-taophieunhapxuat-pi2").height();
                    var w = $("#layout-east-soanthao-taophieunhapxuat-pi2").width();
                    $("#grid_ds_dachon_taophieunhapxuat2").setGridHeight(h - 70);
                    $("#grid_ds_dachon_taophieunhapxuat2").setGridWidth(w - 2);
                }
            }
        });

        setTimeout(function () {
            createLayout();
        }, 100);

        $(".btn-active").button().css({ 'width': '100%', 'height': '25%' });

    });


    function funcCreatePNKfromPI2(postData) {
        var msg = "";
        var gridData = jQuery("#grid_ds_dachon_taophieunhapxuat2");
        var ids = gridData.jqGrid('getDataIDs');

        if (ids.length == 0) {
            msg = "Hãy chọn danh sách sản phẩm mà bạn muốn tạo phiếu nhập.!";
            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-taophieunhapxuat-tupi\"><h3>' + msg + '</h3></div>');

            // create new dialog
            $('#dialog-taophieunhapxuat-tupi').dialog({
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
            let idpr = $('#grid_ds_dathang_taophieunhapxuat3').jqGrid('getGridParam', 'selrow');
            let rowDTPR = $('#grid_ds_dathang_taophieunhapxuat3').getRowData(idpr);

            msg = "Có phải bạn muốn tạo phiếu nhập từ danh sách sản phẩm này.?";
            var p = '<p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span><span id="dialog-caution">' + msg + '</span></p>';
            var h3 = '<h3 style="padding: 10px" class="ui-state-highlight ui-corner-all">' + p + '<div style="display:none" id="wait"><img style="width:30px; height:30px" src="iconcollection/loading.gif"/></div></h3>';

            // append dialog-taoky to body
            $('body').append('<div title="Thông Báo" id=\"dialog-taophieunhapxuat-tupi\">' + h3 + '</div>');

            // create new dialog
            $('#dialog-taophieunhapxuat-tupi').dialog({
                modal: true
                , open: function(event, ui) {
                    //hide close button.
                    $(this).parent().children().children('.ui-dialog-titlebar-close').hide();
                }
                , buttons:
                [
                    {
                        id: "btn-dialog-taophieunhapxuat-tupi",
                        text: "Có",
                        click: function() {
                            $("#wait").css("display", "block");
                            $("#btn-dialog-taophieunhapxuat-tupi").button("disable");
                            $("#btn-close").button("disable");

                            $.ajax({
                                url: "Controllers/TaoPhieuNhapKho.ashx",
                                type: "POST",
                                datetype: "json",
                                data: { grid_form: postData, action: "TaoPhieuNhap", so_cont: rowDTPR.so_cont, so_seal: rowDTPR.so_seal, loai_cont: rowDTPR.loai_cont },
                                error: function (rs) {
                                    $("#wait").css("display", "none");
                                    $("#btn-close span").text("Thoát");
                                    $("#btn-close").button("enable");
                                    Popup("Error", 500, 400, rs.responseText);
                                },
                                success: function (rs) {
                                    $("#wait").css("display", "none");
                                    $("#btn-close span").text("Thoát");
                                    $("#btn-close").button("enable");
                                    $('#dialog-taophieunhapxuat-tupi').find('#dialog-caution').html(rs);
                                }

                            });
                        }
                    },
                    {
                        id: "btn-close",
                        text: "Không",
                        click: function () {
                            if ($("#btn-close span").text() == "Không") {
                                let ids = $('#grid_ds_dachon_taophieunhapxuat2').jqGrid('getDataIDs');
                                for (let i in ids) {
                                    $('#grid_ds_dachon_taophieunhapxuat2').jqGrid('editRow', ids[i]);
                                    $(`#${ids[i]}_sl_nhapthucte`).css({ 'text-align': 'right', 'padding': '4px', 'width': '90%' });
                                }
                            }
                            $(this).dialog("destroy").remove();
                        }
                    }
                ]
            });
        }
    }

    setTimeout(() => {
        $("#grid_ds_dachon_taophieunhapxuat2").jqGrid('navButtonAdd', '#grid_ds_dachon_taophieunhapxuat2-pager', {
            caption: "",
            title: "Tạo phiếu nhập",
            buttonicon: "icon-pi",
            onClickButton: function () {
			    let rowids = $("#grid_ds_dachon_taophieunhapxuat2").jqGrid('getDataIDs');
                for(var i in rowids) {
				    $("#grid_ds_dachon_taophieunhapxuat2").jqGrid('saveRow', rowids[i], true, 'clientArray', null, null);
			    }
			    var gridData = $("#grid_ds_dachon_taophieunhapxuat2").getRowData();
                var postData = JSON.stringify(gridData);

                funcCreatePNKfromPI2(postData);
            }
        });
    }, 1000);
</script>

<DIV class="ui-layout-north ui-widget-content" id="layout-northcenter-taophieunhapxuat-pi2">
    <DIV class="ui-layout-west ui-widget-content" id="layout-northwest-soanthao-taophieunhapxuat-pi2" style="float:left">
        <uc1:jqGrid  ID="grid_ds_dathang_taophieunhapxuat2" 
            Caption="Danh Sách Đặt Hàng"
            SortName="dsdh.c_danhsachdathang_id" 
            UrlFileAction="Controllers/DanhSachDatHangTaoPhieuXuatController.ashx" 
            PostData="laAB:1"       
			AfterRefresh = "function(){ 
                var gridData = jQuery('#grid_ds_dachon_chiatachpo')
                var ids = gridData.jqGrid('getDataIDs');
                for (var i = 0, il = ids.length; i &lt; il; i++) {
                    gridData.jqGrid('delRowData', ids[i]);
                }
                jQuery('#grid_ds_chitietpo_chiatachpo').jqGrid().trigger('reloadGrid');
            }"			
			ColNames="['c_danhsachdathang_id','Số Chứng Từ', 'Ngày Lập', 'Hạn Giao Hàng PO', 'Người Phụ Trách', 'Người Đặt Hàng', 'Đơn Hàng', 'Hướng Dẫn Làm Hàng', 'Trạng Thái', 'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
            RowNumbers="true"
            ColModel = "[
            {
                fixed: true, name: 'c_danhsachdathang_id'
                , index: 'dsdh.c_danhsachdathang_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                    fixed: true, name: 'sochungtu'
                    , index: 'dsdh.sochungtu'
                    , editable: true
                    , width: 100
                    , edittype: 'text'
            },
            {
                    fixed: true, name: 'ngaylap'
                    , index: 'dsdh.ngaylap'
                    , editable: true
                    , width: 100
                    , edittype: 'text'
                    , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            },
            {
                    fixed: true, name: 'hangiaohang_po'
                    , index: 'dsdh.hangiaohang_po'
                    , editable: true
                    , width: 100
                    , edittype: 'text'
                    , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            },
            {
                fixed: true, name: 'nguoi_phutrach'
                , index: 'dsdh.nguoi_phutrach'
                , width: 100
                , edittype: 'text'
                , editable:true
            },
            {
                    fixed: true, name: 'nguoi_dathang'
                    , index: 'dsdh.nguoi_dathang'
                    , editable: true
                    , width: 100
                    , edittype: 'text'
            },
            {
                    fixed: true, name: 'c_donhang_id'
                    , index: 'dh.sochungtu'
                    , editable: true
                    , width: 100
                    , edittype: 'select'
                    , editoptions: { dataUrl: 'Controllers/DonHangController.ashx?action=getoption' }
            },
            {
                    fixed: true, name: 'md_trangthai_id'
                    , index: 'dsdh.md_trangthai_id'
                    , editable: true
                    , width: 100
                    , edittype: 'text'
            },
            {
                fixed: true, name: 'ngaytao'
                , index: 'dsdh.ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'nguoitao'
                , index: 'dsdh.nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'dsdh.ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'dsdh.nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
            },
            {
                fixed: true, name: 'huongdanhlamhang'
                , index: 'dsdh.huongdanhlamhang'
                , width: 100
                , editable:true
                , edittype: 'textarea'
                , hidden: true
            },
            {
                fixed: true, name: 'mota'
                , index: 'dsdh.mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
                , hidden: true
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , index: 'dsdh.hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            }
            ]"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 90);"
            FilterToolbar = "true"
            Height = "420"
            OnSelectRow = "function(ids) {
		        if(ids == null) {
			        ids=0;
			        if($('#grid_ds_chitietdathang').jqGrid('getGridParam','records') &gt; 0 )
			        {
				        $('#grid_ds_dathang_taophieunhapxuat3').jqGrid('setGridParam',{url:'Controllers/DanhSachDatHangTaoPhieuXuatController.ashx?&poId='+ids,page:1});
				        $('#grid_ds_dathang_taophieunhapxuat3').jqGrid().trigger('reloadGrid');
				                
                        $('#grid_ds_chitietdathang_taophieunhapxuat2').jqGrid('setGridParam',{url:'Controllers/DongDSDHTaoPhieuXuatController.ashx?&poId='+ids,page:1});
				        $('#grid_ds_chitietdathang_taophieunhapxuat2').jqGrid().trigger('reloadGrid');

				        let gridData = $('#grid_ds_dachon_taophieunhapxuat2')
                        let idAlls = gridData.jqGrid('getDataIDs');
                        for (let i = 0, il = idAlls.length; i &lt; il; i++) {
                            gridData.jqGrid('delRowData', idAlls[i]);
                        }
				    } 
				} 
                else {
			        $('#grid_ds_dathang_taophieunhapxuat3').jqGrid('setGridParam',{url:'Controllers/DanhSachDatHangTaoPhieuXuatController.ashx?&poId='+ids,page:1});
			        $('#grid_ds_dathang_taophieunhapxuat3').jqGrid().trigger('reloadGrid');
			                
                    $('#grid_ds_chitietdathang_taophieunhapxuat2').jqGrid('setGridParam',{url:'Controllers/DongDSDHTaoPhieuXuatController.ashx?&poId='+ids,page:1});
			        $('#grid_ds_chitietdathang_taophieunhapxuat2').jqGrid().trigger('reloadGrid');

			        let gridData = $('#grid_ds_dachon_taophieunhapxuat2')
                    let idAlls = gridData.jqGrid('getDataIDs');
                    for (var i = 0, il = idAlls.length; i &lt; il; i++) {
                        gridData.jqGrid('delRowData', idAlls[i]);
                    }
		        } 
            }"
            runat="server" />
    </DIV>

    <DIV class="ui-layout-east ui-widget-content" id="layout-northeast-soanthao-taophieunhapxuat-pi2" style="float:left">
        <uc1:jqGrid  ID="grid_ds_dathang_taophieunhapxuat3" 
            Caption="Phiếu xuất kho"
            SortName="dsdh.c_danhsachdathang_id" 
            UrlFileAction="Controllers/DanhSachDatHangTaoPhieuXuatController.ashx" 
            PostData="oper:'loadPXK'"
			AfterRefresh = "function(){ 
                var gridData = jQuery('#grid_ds_dachon_chiatachpo')
                var ids = gridData.jqGrid('getDataIDs');
                for (var i = 0, il = ids.length; i &lt; il; i++) {
                    gridData.jqGrid('delRowData', ids[i]);
                }
                jQuery('#grid_ds_chitietpo_chiatachpo').jqGrid().trigger('reloadGrid');
            }"
            RowNumbers="true"
            ColModel = "[
            {
                fixed: true, name: 'md_xuatban_id', hidden: true
                , index: 'dsdh.md_xuatban_id'
                , editable: true
                , width: 100
                , edittype: 'text'
                , label: 'phiếu XK ID'
                , key: true
                , search: false
            },
            {
                fixed: true, name: 'sochungtu'
                , index: 'dsdh.sochungtu'
                , editable: true
                , width: 100
                , edittype: 'text'
                , label: 'Số phiếu XK'
                , search: false
            },
            {
                fixed: true, name: 'ngaychuyen'
                , index: 'dsdh.ngaychuyen'
                , editable: true
                , width: 100
                , edittype: 'text'
                , label: 'Ngày xuất'
                , search: false
            },
            {
                fixed: true, name: 'so_cont'
                , index: 'dsdh.so_cont'
                , editable: true
                , width: 100
                , edittype: 'text'
                , label: 'Số cont'
                , search: false
            },
            {
                fixed: true, name: 'so_seal'
                , index: 'dsdh.so_seal'
                , editable: true
                , width: 100
                , edittype: 'text'
                , label: 'Số seal'
                , search: false
            },
            {
                fixed: true, name: 'loai_cont'
                , index: 'dsdh.loai_cont'
                , editable: true
                , width: 100
                , edittype: 'text'
                , label: 'Loại cont'
                , search: false
            }
            ]"
            GridComplete = ""
            FilterToolbar = "true"
            Height = "420"
            OnSelectRow = "function(ids) {
		        if(ids == null) {
			        ids=0;
			        if($('#grid_ds_chitietdathang').jqGrid('getGridParam','records') &gt; 0 )
			        {
				        $('#grid_ds_dachon_taophieunhapxuat2').jqGrid('setGridParam',{url:'Controllers/DongDSDHTaoPhieuXuatController.ashx?&poId='+ids,page:1});
				        $('#grid_ds_dachon_taophieunhapxuat2').jqGrid().trigger('reloadGrid');
				                
				        var gridData = jQuery('#grid_ds_dachon_taophieunhapxuat2')
                        var ids = gridData.jqGrid('getDataIDs');
                        for (var i = 0, il = ids.length; i &lt; il; i++) {
                            gridData.jqGrid('delRowData', ids[i]);
                        }
				    } 
				} else {
			        $('#grid_ds_dachon_taophieunhapxuat2').jqGrid('setGridParam',{url:'Controllers/DongDSDHTaoPhieuXuatController.ashx?&poId='+ids,page:1});
			        $('#grid_ds_dachon_taophieunhapxuat2').jqGrid().trigger('reloadGrid');
			                
			            var gridData = jQuery('#grid_ds_dachon_taophieunhapxuat2')
                        var ids = gridData.jqGrid('getDataIDs');
                        for (var i = 0, il = ids.length; i &lt; il; i++) {
                            gridData.jqGrid('delRowData', ids[i]);
                        }			
		        } 
            }"
            runat="server" />
    </DIV>
</DIV>

<DIV class="ui-layout-center ui-widget-content" id="layout-center-taophieunhapxuat-pi2">
    <DIV class="ui-layout-west ui-widget-content" id="layout-west-soanthao-taophieunhapxuat-pi2">
        <uc1:jqGrid  ID="grid_ds_chitietdathang_taophieunhapxuat2" 
            SortOrder="asc"
            SortName="sp.ma_sanpham"  
            UrlFileAction="Controllers/DongDSDHTaoPhieuXuatController.ashx" 
            ColNames="['c_donhang_id', 'Danh Sách Đặt Hàng', 'Dòng Đơn Hàng', 'Dòng Danh Sách Đặt Hàng', 'Mã SP', 'Mã SP', 'Mã SP Khách', 'Số Lượng PO', 'Số Lượng Đặt Hàng', 'Số Lượng Còn Lại']"
            RowNumbers="true"
            ColModel = "[
                {
                    fixed: true, name: 'c_donhang_id'
                    , index: 'ddsdh.c_donhang_id'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                    , hidden:true
                },
                {
                    fixed: true, name: 'c_danhsachdathang_id'
                    , index: 'dsdh.c_danhsachdathang_id'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                    , hidden:true
                },
                {
                    fixed: true, name: 'c_dongdonhang_id'
                    , index: 'ddsdh.c_dongdonhang_id'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                    , hidden:true
                },
                {
                    fixed: true, name: 'c_dongdsdh_id'
                    , index: 'dsdh.c_dongdsdh_id'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                    , hidden:true
                },
                {
                    fixed: true, name: 'md_sanpham_id'
                    , index: 'ddsdh.md_sanpham_id'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                    , hidden:true
                },
                {
                    fixed: true, name: 'ma_sanpham'
                    , index: 'sp.ma_sanpham'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                },
                {
                    fixed: true, name: 'ma_sanpham_khach'
                    , index: 'ddsdh.ma_sanpham_khach'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                },
                {
                    fixed: true, name: 'sl_po'
                    , index: 'ddsdh.sl_po'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                },
                {
                    fixed: true, name: 'sl_dathang'
                    , index: 'ddsdh.sl_dathang'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                },
                {
                    fixed: true, name: 'sl_conlai'
                    , index: 'ddsdh.sl_conlai'
                    , width: 100
                    , editable:true
                    , edittype: 'text'
                    , sortable: false
                } 
            ]"
			RowNum="200"
            Caption = "Danh sách sản phẩm"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()- 70);"
            Height = "150"
            MultiSelect = "false" 
            runat="server" />
    </DIV>
    
    <DIV class="ui-layout-east ui-widget-content" id="layout-east-soanthao-taophieunhapxuat-pi2">
        <uc1:jqGrid  ID="grid_ds_dachon_taophieunhapxuat2" 
            SortOrder="asc"
            SortName="sp.ma_sanpham"  
            UrlFileAction="Controllers/DongDSDHTaoPhieuXuatController.ashx" 
            PostData="oper:'loadPXK'"
            RowNumbers="true"
            ColModel = "[
                {
                    fixed: true, name: 'md_xuatban_id'
                    , index: 'md_xuatban_id'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , hidden: true
                    , label: 'Xuất bán ID'
                },
                {
                    fixed: true, name: 'c_donhang_id'
                    , index: 'c_donhang_id'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , hidden: true
                    , label: 'Đơn hàng ID'
                },
                {
                    fixed: true, name: 'c_danhsachdathang_id'
                    , index: 'c_danhsachdathang_id'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , hidden: true
                    , label: 'DSDH ID'
                },
                {
                    fixed: true, name: 'c_dongdonhang_id'
                    , index: 'c_dongdonhang_id'
                    , width: 100
                    , editable: true
                    , edittype: 'text'
                    , sortable: false
                    , hidden: true
                    , label: 'Dòng ĐH ID'
                },
                {
                    fixed: true, name: 'c_dongdsdh_id'
                    , index: 'c_dongdsdh_id'
                    , width: 100
                    , editable: true
                    , edittype: 'text'
                    , sortable: false
                    , hidden: true
                    , label: 'Dòng DSDH ID'
                },
                {
                    fixed: true, name: 'md_sanpham_id'
                    , index: 'md_sanpham_id'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , hidden: true
                    , label: 'SP ID'
                    , key: true
                },
                {
                    fixed: true, name: 'ma_sanpham'
                    , index: 'sp.ma_sanpham'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , label: 'Mã SP'
                },
                {
                    fixed: true, name: 'ma_sanpham_khach'
                    , index: 'ma_sanpham_khach'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , label: 'Mã SP khách'
                },
                {
                    fixed: true, name: 'sl_po'
                    , index: 'sl_po'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'right'
                    , label: 'SL PO'
                },
				{
                    fixed: true, name: 'sl_nhapthucte'
                    , index: 'sl_nhapthucte'
                    , width: 100
                    , editable: true
                    , edittype: 'text'
                    , sortable: false
                    , align: 'right'
                    , label: 'SL nhập thực tế'
                },
                {
                    fixed: true, name: 'sl_dathang'
                    , index: 'sl_dathang'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'right'
                    , label: 'SL đặt hàng'
                },
                {
                    fixed: true, name: 'sl_conlai'
                    , index: 'sl_conlai'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'right'
                    , label: 'SL còn lại'
                },
                {
                    fixed: true, name: 'sl_inner'
                    , index: 'sl_inner'
                    , width: 80
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'right'
                    , label: 'SL inner'
                },
                {
                    fixed: true, name: 'dvt_inner'
                    , index: 'dvt_inner'
                    , width: 80
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'center'
                    , label: 'Đvt inner'
                },
                {
                    fixed: true, name: 'sl_outer'
                    , index: 'sl_outer'
                    , width: 80
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'right'
                    , label: 'SL outer'
                },
                {
                    fixed: true, name: 'dvt_outer'
                    , index: 'dvt_inner'
                    , width: 80
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'center'
                    , label: 'Đvt outer'
                },
                {
                    fixed: true, name: 'tenkien'
                    , index: 'tenkien'
                    , width: 100
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'center'
                    , label: 'Tên kiện'
                },
                {
                    fixed: true, name: 'sokien'
                    , index: 'sokien'
                    , width: 80
                    , editable: false
                    , edittype: 'text'
                    , sortable: false
                    , align: 'right'
                    , label: 'Số kiện'
                }
            ]"
            ShowRefresh="false"
            ShowSearch="false"
            ShowView="false"
            ShowReorder="false"
			RowNum="200"
            Caption = "Danh sách sản phẩm trong phiếu xuất"
            GridComplete = "
                let o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()- 70);
                let ids = $(this).jqGrid('getDataIDs');
                for(let i in ids) {
                    $('#grid_ds_dachon_taophieunhapxuat2').jqGrid('editRow', ids[i]);
                    $(`#${ids[i]}_sl_nhapthucte`).css({'text-align':'right', 'padding':'4px', 'width':'90%'});
                }
            "
            Height = "150"
            MultiSelect = "false" 
            runat="server" />
    </DIV>
    
    <DIV class="ui-layout-center ui-widget-content" id="layout-center-soanthao-taophieunhapxuat-pi2" style="background: #E0CFC2">
    </DIV>
</DIV>

