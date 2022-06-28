<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-hoadon.aspx.cs" Inherits="inc_hoadon" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<script>
    $(function() {
        $('#lay-center-hoadon').parent().layout({
            north: {
                size: "50%"
                , minSize: "0%"
                , maxSize: "100%"
                , onresize_end: function() {
                var o = $("#layout-north-hoadon").height();
                $("#grid_ds_hoadon").setGridHeight(o - 90);
                }
            },
            center: {
                onresize_end: function() {
                var o = $("#lay-center-hoadon").height();
                $("#grid_ds_chitietxuatkho").setGridHeight(o - 90);
                }
            }
        })
    });

</script>
<DIV class="ui-layout-north ui-widget-content" id="layout-north-hoadon">
<uc1:jqGrid  ID="grid_ds_hoadon"
            Caption="Hóa đơn" 
            SortName="hd.ngaytao"
            UrlFileAction="Controllers/HoaDonController.ashx"
            RowNumbers="true"
            FilterToolbar="true"
            OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid,{ 
                                beforeShowForm: function (formid) {
                                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                                }
                                , afterSubmit: function(rs, postdata) {
                                    return showMsgDialog(rs);
                                }
                  }); }"
            ColModel = "[
            {
                fixed: true, name: 'c_nhapxuat_id'
                , index: 'c_nhapxuat_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                 fixed: true, name: 'md_trangthai_id'
                 , index: 'nx.md_trangthai_id'
                 , editable: false
                 , width: 100
                 , edittype: 'text'
                 , align: 'center'
                 , formatter:'imagestatus'
            },
            {
                 fixed: true, name: 'sophieunx'
                 , index: 'sophieunx'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'sophieu'
                 , index: 'sophieu'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
			{
                 fixed: true, name: 'soseal'
                 , index: 'soseal'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules:{ required:true }
				 , formoptions: { label:'Số Seal' + ip_fd()}
            },
            {
                 fixed: true, name: 'container'
                 , index: 'container'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editrules:{ required:true }
				 , formoptions: { label:'Số Container' + ip_fd()}
            },
            {
                 fixed: true, name: 'loaicont'
                 , index: 'loaicont'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { value:'CONT20:Cont 20;CONT40:Cont 40;CONT45:Cont 45;40HC:40HC;LE:Cont Lẻ' }
				 , formoptions: { label:'Loại Cont' + ip_fd()}
            },
			{
                fixed: true, name: 'ngaytao'
                , index: 'ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
			{
                fixed: true, name: 'nguoitao'
                , index: 'nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , editrules:{ edithidden : true }
            },
            {
                 fixed: true, name: 'ngay_giaonhan'
                 , index: 'ngay_giaonhan'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            },
            {
                 fixed: true, name: 'md_doitackinhdoanh_id'
                 , index: 'dtkd.ma_dtkd'
                 , editable: true
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/PartnerController.ashx?action=getoption&isncc=0', readonly:'readonly' }
                 
            },
            {
                 fixed: true, name: 'nguoigiao'
                 , index: 'nguoigiao'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'nguoinhan'
                 , index: 'nguoinhan'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'sophieukhach'
                 , index: 'sophieukhach'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'ngay_phieu'
                 , index: 'ngay_phieu'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
            },
            {
                 fixed: true, name: 'nhapxuat_kho_id'
                 , index: 'nhapxuat_kho_id'
                 , editable: false
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/WarehouseController.ashx?action=getoption', readonly:'readonly' }
            },
            
            {
                 fixed: true, name: 'md_loaichungtu_id'
                 , index: 'md_loaichungtu_id'
                 , editable: false
                 , width: 100
                 , edittype: 'select'
                 , editoptions: { value:'NK:Nhập Kho;XK:Xuất Kho' }
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'mota'
                , index: 'mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
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
            }
            ]"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()-90);"
            Height = "170"
            MultiSelect = "false"
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            EditFormOptions="
                                beforeShowForm: function (formid) {
                                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                                }
                                , afterSubmit: function(rs, postdata) {
                                    return showMsgDialog(rs);
                                }
            "
            ViewFormOptions="   beforeShowForm: function (formid) {
                                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                                }
                                , afterSubmit: function(rs, postdata) {
                                    return showMsgDialog(rs);
                                }"
            DelFormOptions="beforeShowForm: function (formid) {
                                formid.closest('div.ui-jqdialog').dialogCenter(); 
                            }
                            , afterSubmit: function(rs, postdata) {
                                return showMsgDialog(rs);
                            }"
            OnSelectRow = "function(ids) {
		                if(ids == null) {
			                ids=0;
			                if($('#grid_ds_chitietxuatkho').jqGrid('getGridParam','records') &gt; 0 )
			                {
							
								$.ajax({
									url: 'Controllers/NhapXuatCalTotalController.ashx?c_nhapxuat_id='+ids,
									beforeSend:function(){
										$('#grid_ds_hoadon').jqGrid('setCaption','Xuất kho: đang tải...');
									},
									success: function(data){
										 $('#grid_ds_hoadon').jqGrid('setCaption','Xuất kho: ' +  data);
									}
								});
							
				                $('#grid_ds_chitietxuatkho').jqGrid('setGridParam',{url:'Controllers/DongNhapXuatController.ashx?&whId='+ids,page:1});
				                $('#grid_ds_chitietxuatkho').jqGrid().trigger('reloadGrid');
				            } 
				        } else {
						
							$.ajax({
								url: 'Controllers/NhapXuatCalTotalController.ashx?c_nhapxuat_id='+ids,
								beforeSend:function(){
									$('#grid_ds_hoadon').jqGrid('setCaption','Xuất kho: đang tải...');
								},
								success: function(data){
									 $('#grid_ds_hoadon').jqGrid('setCaption','Xuất kho: ' +  data);
								}
							});
							
			                $('#grid_ds_chitietxuatkho').jqGrid('setGridParam',{url:'Controllers/DongNhapXuatController.ashx?&whId='+ids,page:1});
			                $('#grid_ds_chitietxuatkho').jqGrid().trigger('reloadGrid');			
		                } }"
            runat="server" />
</DIV>

<DIV class="ui-layout-center ui-widget-content" id="lay-center-hoadon" style="padding:0;"> 
			<uc1:jqGrid  ID="grid_ds_chitietxuatkho" 
			Caption = "Chi Tiết Xuất Kho"
            SortName="sp.ma_sanpham" 
            SortOrder="asc"
            UrlFileAction="Controllers/DongNhapXuatController.ashx" 
            ColNames="['c_dongnhapxuat_id', 'Nhập Xuất', 'Chi Tiết Đơn Hàng', 'STT', 'Mã SP', 'Mã SP', 'Mô Tả TV', 'Đơn Vị Tính', 'Số Lượng Phải Xuất', 'Số Lượng Thực Xuất', 'Đơn Giá', 'Số Kiện Thực Tế', 'Ngày Tạo', 'Người Tạo', 'Ngày Cập Nhật', 'Người Cập Nhật', 'Mô tả', 'Hoạt động']"
            RowNumbers="true"
            FilterToolbar="true"
            OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid); }"
            ColModel = "[
            {
                fixed: true, name: 'c_dongnhapxuat_id'
                , index: 'c_dongnhapxuat_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                 fixed: true, name: 'c_nhapxuat_id'
                 , index: 'c_nhapxuat_id'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , hidden : true
            },
            {
                fixed: true, name: 'c_dongdonhang_id'
                , index: 'c_dongdonhang_id'
                , width: 100
                , edittype: 'text'
                , editable:true
                , hidden: true
            },
            {
                fixed: true, name: 'line'
                , index: 'line'
                , width: 50
                , edittype: 'text'
                , editable:true
                , align:'right'
            },
            {
                fixed: true, name: 'sanpham_id'
                , index: 'sanpham_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
            },
            {
                fixed: true, name: 'ma_sanpham'
                , index: 'sp.ma_sanpham'
                , width: 100
                , edittype: 'text'
                , editable:true
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
                fixed: true, name: 'mota_tiengviet'
                , index: 'mota_tiengviet'
                , width: 200
                , edittype: 'textarea'
                , editable:true
            },
            {
                fixed: true, name: 'md_donvitinh_id'
                , index: 'md_donvitinh_id'
                , width: 100
                , edittype: 'select'
                , editable:true
                , editoptions: { dataUrl: 'Controllers/UnitProductController.ashx?action=getoption' }
                , align:'center'
            },
            {
                fixed: true, name: 'slphai_nhapxuat'
                , index: 'slphai_nhapxuat'
                , width: 100
                , edittype: 'text'
                , editable:true
                , align:'right'
                , formatter:'number'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true, name: 'slthuc_nhapxuat'
                , index: 'slthuc_nhapxuat'
                , width: 100
                , edittype: 'text'
                , editable:true
                , align:'right'
                , formatter:'number'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true, name: 'dongia'
                , index: 'dongia'
                , width: 100
                , edittype: 'text'
                , editable:true
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 2, prefix: ''}
            },
            {
                fixed: true, name: 'sokien_thucte'
                , index: 'sokien_thucte'
                , width: 100
                , edittype: 'text'
                , editable:true
                , editrules: { required: true, number:true, minValue: 0 }
                , align:'right'
                , formatter:'number'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true, name: 'ngaytao'
                , index: 'ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoitao'
                , index: 'nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , index: 'ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , index: 'nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'mota'
                , index: 'mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , index: 'hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , editoptions:{ defaultValue: 'True' }
                , editrules:{ edithidden : true }
            }
            ]"
            GridComplete = "var o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()-90);"
            Height = "150"
            MultiSelect = "false" 
            ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
            ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
            EditFormOptions="
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
                , afterSubmit: function(rs, postdata) {
                    return showMsgDialog(rs);
                }
            "
            ViewFormOptions="  
                 beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
                , afterSubmit: function(rs, postdata) {
                    return showMsgDialog(rs);
                }
            "
            DelFormOptions="
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
                , afterSubmit: function(rs, postdata) {
                    return showMsgDialog(rs);
                }
            "
            runat="server" />
	</DIV> 

<script type="text/javascript">
    createRightPanel('grid_ds_hoadon');
    createRightPanel('grid_ds_chitietxuatkho');
</script>