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
                $("#grid_ds_chitiethoadon").setGridHeight(o - 90);
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
                fixed: true, name: 'c_hoadon_id'
                , index: 'c_hoadon_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                 fixed: true, name: 'md_trangthai_id'
                 , label: 'Trạng thái'
                 , index: 'nx.md_trangthai_id'
                 , editable: false
                 , width: 60
                 , edittype: 'text'
                 , align: 'center'
                 , formatter:'imagestatus'
            },
            {
                 fixed: true, name: 'tiento'
                 , label: 'Tiền tố'
                 , index: 'tiento'
                 , editable: true
                 , width: 40
                 , align: 'center'
                 , edittype: 'select'
                 , editoptions: { dataUrl: 'Controllers/HoaDonController.ashx?action=getoption' }
            },
            {
                 fixed: true, name: 'sophieu'
                 , label: 'Số phiếu'
                 , index: 'sophieu'
                 , editable: true
                 , width: 60
                 , align: 'center'
                 , edittype: 'text'
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'ma_khachhang'
                 , label: 'Mã KH'
                 , index: 'ma_khachhang'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'ten_khachhang'
                 , label: 'Tên KH'
                 , index: 'ma_khachhang'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'diachi_khachhang'
                 , label: 'Địa chỉ'
                 , index: 'ma_khachhang'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'email_khachhang'
                 , label: 'Email'
                 , index: 'email_khachhang'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'hinhthucthanhtoan'
                 , label: 'Hình thức TT'
                 , index: 'hinhthucthanhtoan'
                 , editable: true
                 , width: 90
                 , align: 'center'
                 , edittype: 'select'
                 , editoptions: { value:'CK:CK;TM:TM;CK/TM:CK/TM' }
            },
            {
                 fixed: true, name: 'thue_vat'
                 , label: 'VAT'
                 , index: 'thue_vat'
                 , editable: true
                 , width: 90
                 , edittype: 'text'
                 , align: 'right'
                 , formatter:'currency'
                 , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 'auto', prefix: ''}
            },
            {
                 fixed: true, name: 'tienthue'
                 , label: 'Tiền thuế'
                 , index: 'tienthue'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , align: 'right'
                 , formatter:'currency'
                 , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 'auto', prefix: ''}
            },
            {
                 fixed: true, name: 'tygia'
                 , label: 'Tỷ giá'
                 , index: 'tygia'
                 , editable: true
                 , width: 60
                 , edittype: 'text'
                 , align: 'right'
                 , formatter:'currency'
                 , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 'auto', prefix: ''}
            },
            {
                 fixed: true, name: 'giamgia'
                 , label: 'Giảm giá'
                 , index: 'giamgia'
                 , editable: true
                 , width: 80
                 , edittype: 'text'
                 , align: 'right'
                 , formatter:'currency'
                 , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 'auto', prefix: ''}
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'philamhang'
                 , label: 'Phí làm hàng'
                 , index: 'philamhang'
                 , editable: true
                 , width: 80
                 , edittype: 'text'
                 , align: 'right'
                 , formatter:'currency'
                 , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 'auto', prefix: ''}
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'tuongduongUSD'
                 , label: 'Tương đương USD'
                 , index: 'tuongduongUSD'
                 , editable: true
                 , width: 110
                 , edittype: 'text'
                 , align: 'right'
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'ngayhoadon'
                 , label: 'Ngày hóa đơn'
                 , index: 'ngayhoadon'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , align: 'center'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'mauso'
                 , label: 'Mẫu số'
                 , index: 'mauso'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , align: 'center'
            },
            {
                 fixed: true, name: 'kyhieu'
                 , label: 'Ký hiệu'
                 , index: 'kyhieu'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , align: 'center'
            },
            {
                 fixed: true, name: 'sohoadon'
                 , label: 'Số hóa đơn'
                 , index: 'sohoadon'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , align: 'center'
            },
            {
                 fixed: true, name: 'ngayphathanh'
                 , label: 'Ngày phát hành'
                 , index: 'ngayphathanh'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , align: 'center'
                 , editoptions: { dataInit : function (elem) { $(elem).datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' }); }, defaultValue: function(){ var currentTime = new Date(); var month = parseInt(currentTime.getMonth() + 1);     month = month &lt;= 9 ? '0' + month : month; var day = currentTime.getDate(); day = day &lt;= 9 ? '0'+ day : day; var year = currentTime.getFullYear(); return day + '/' + month + '/' + year; } }
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'ghichu'
                 , label: 'Ghi chú'
                 , index: 'ghichu'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
            {
                 fixed: true, name: 'so_inv'
                 , label: 'Số INV'
                 , index: 'so_inv'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , editoptions: { readonly:'readonly' }
            },
            {
                 fixed: true, name: 'sotokhai_inv'
                 , label: 'Số tờ khai HQ'
                 , index: 'sotokhai_inv'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
            },
			{
                fixed: true, name: 'ngaytao'
                , label: 'Ngày tạo'
                , index: 'ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoitao'
                , label: 'Người tạo'
                , index: 'nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , label: 'Ngày cập nhật'
                , index: 'ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , label: 'Người cập nhật'
                , index: 'nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'mota'
                , label: 'Mô tả'
                , index: 'mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , label: 'Hoạt động'
                , index: 'hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , editoptions:{ defaultValue: 'True' }
                , editrules:{ edithidden : true }
            }
            ]"
            GridComplete = "let o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()-90);"
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
			                if($('#grid_ds_chitiethoadon').jqGrid('getGridParam','records') &gt; 0 )
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
							
				                $('#grid_ds_chitiethoadon').jqGrid('setGridParam',{url:'Controllers/DongNhapXuatController.ashx?&whId='+ids,page:1});
				                $('#grid_ds_chitiethoadon').jqGrid().trigger('reloadGrid');
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
							
			                $('#grid_ds_chitiethoadon').jqGrid('setGridParam',{url:'Controllers/HoaDonChiTietController.ashx?&whId='+ids,page:1});
			                $('#grid_ds_chitiethoadon').jqGrid().trigger('reloadGrid');			
		                } }"
            runat="server" />
</DIV>

<DIV class="ui-layout-center ui-widget-content" id="lay-center-hoadon" style="padding:0;"> 
			<uc1:jqGrid  ID="grid_ds_chitiethoadon" 
			Caption = "Chi Tiết Hóa Đơn"
            SortName="hd.ma_sanpham" 
            SortOrder="asc"
            UrlFileAction="Controllers/HoaDonChiTietController.ashx" 
            RowNumbers="true"
            FilterToolbar="true"
            OndblClickRow = "function(rowid) { $(this).jqGrid('editGridRow', rowid); }"
            ColModel = "[
            {
                fixed: true, name: 'c_hoadon_ct_id'
                , index: 'hd.c_hoadon_ct_id'
                , label: 'ID'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                 fixed: true, name: 'c_hoadon_id'
                 , label: 'HĐ ID'
                 , index: 'hd.c_hoadon_id'
                 , editable: true
                 , width: 100
                 , edittype: 'text'
                 , hidden : true
            },
            {
                fixed: true, name: 'ma_sanpham'
                , label: 'Mã SP'
                , index: 'hd.ma_sanpham'
                , width: 100
                , edittype: 'text'
                , editable:true
                , editoptions: { readonly:'readonly' }
            },
            {
                fixed: true, name: 'ten_sanpham'
                , label: 'Tên SP'
                , index: 'hd.ten_sanpham'
                , width: 120
                , edittype: 'text'
                , editable:true
                , editoptions: { readonly:'readonly' }
            },
            {
                fixed: true, name: 'ten_dvt'
                , label: 'ĐVT'
                , index: 'hd.ten_dvt'
                , width: 50
                , edittype: 'text'
                , editable:true
                , align:'center'
                , editoptions: { readonly:'readonly' }
            },
            {
                fixed: true, name: 'soluong'
                , label: 'Số lượng'
                , index: 'hd.soluong'
                , width: 100
                , edittype: 'text'
                , editable:true
                , align:'right'
                , editoptions: { readonly:'readonly' }
            },
            {
                fixed: true, name: 'dongia'
                , label: 'Đơn giá'
                , index: 'hd.dongia'
                , width: 100
                , edittype: 'text'
                , editable: true
                , editoptions: { readonly:'readonly' }
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 'auto', prefix: ''}
            },
            {
                fixed: true, name: 'thanhtien'
                , label: 'Thành tiền'
                , index: 'hd.thanhtien'
                , width: 100
                , edittype: 'text'
                , editable: true
                , editoptions: { readonly:'readonly' }
                , align:'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 'auto', prefix: ''}
            },
            {
                fixed: true, name: 'ngaytao'
                , label: 'Ngày tạo'
                , index: 'ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoitao'
                , label: 'Người tạo'
                , index: 'nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'ngaycapnhat'
                , label: 'Ngày cập nhật'
                , index: 'ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'nguoicapnhat'
                , label: 'Người cập nhật'
                , index: 'nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
            },
            {
                fixed: true, name: 'mota'
                , label: 'Mô tả'
                , index: 'mota'
                , width: 120
                , editable:true
                , edittype: 'textarea'
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , label: 'Hoạt động'
                , index: 'hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , editoptions:{ defaultValue: 'True' }
            }
            ]"
            GridComplete = "let o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()-90);"
            Height = "150"
            MultiSelect = "false" 
            ShowEdit ="false"
            ShowDel = "false"
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
    createRightPanel('grid_ds_chitiethoadon');
</script>