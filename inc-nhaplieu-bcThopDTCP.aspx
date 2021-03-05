<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-nhaplieu-bcThopDTCP.aspx.cs" Inherits="inc_nhaplieu_bcThopDTCP" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script type="text/javascript">
    var nowYear = <%=DateTime.Now.Year %>;
    var nowMonth = <%=DateTime.Now.Month %>;

    var jsonYearEdit = "<%=jsonYear.Substring(2)%>";
    var jsonYearSearch = "<%=jsonYear%>";

    var jsonMonthEdit = "<%=jsonMonth.Substring(2)%>";
    var jsonMonthSearch = "<%=jsonMonth%>";

    var jsonXuongEdit = "<%=jsonXuong.Substring(2)%>";
    var jsonXuongSearch = "<%=jsonXuong%>";
</script>

<uc1:jqGrid  ID="grid_ds_rpt_tonghopdoanhthuchiphi" 
            Caption="Tổng hợp Doanh Thu, Chi Phí"
            FilterToolbar="true"
            UrlFileAction="Controllers/TongHopDoanhThuChiPhiController.ashx" 
            RowNumbers="true"
            ColModel = "[
            {
                fixed: true
                , name: 'rpt_tonghopdoanhthuchiphi_id'
                , label: 'rpt_tonghopdoanhthuchiphi_id'
                , index: 'cl.rpt_tonghopdoanhthuchiphi_id'
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                fixed: true
                , name: 'xuongId'
                , index: 'cl.xuongId'
                , label: 'Xưởng'
                , editable: true
                , width: 100
                , edittype: 'select'
                , editoptions: { value: jsonXuongEdit }
                , stype : 'select'
                , searchoptions:{ opt:['eq'], value: jsonXuongSearch }
                , editrules: { required:true }
            },
            {
                fixed: true
                , name: 'noDauNam'
                , index: 'cl.noDauNam'
                , label: 'Nợ đầu năm'
                , editable: true
                , width: 70
                , edittype: 'text'
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
			{
                fixed: true
                , name: 'nam'
                , index: 'cl.nam'
                , label: 'Năm'
                , width: 70
                , editable:true
                , align: 'center'
                , sortable: true
                , align: 'center'
                , edittype: 'select'
                , editoptions: { defaultValue: nowYear.toString(), value: jsonYearEdit }
                , stype: 'select'
                , searchoptions: { opt:['eq'], value: jsonYearSearch }
                , editrules: { required:true }
            },
            {
                fixed: true
                , name: 'thang'
                , index: 'cl.thang'
                , label: 'Tháng'
                , width: 70
                , edittype: 'text'
                , editable:true
                , align: 'center'
                , editrules: { required:true }
                , align: 'center'
                , edittype: 'select'
                , editoptions: { defaultValue: nowMonth.toString(), value: jsonMonthEdit }
                , stype: 'select'
                , searchoptions: { opt:['eq'], value: jsonMonthSearch }
                , editrules: { required:true }
            },
            {
                fixed: true
                , name: 'dsoVTXuatChoBPCtyKhac'
                , index: 'cl.dsoVTXuatChoBPCtyKhac'
                , label: 'D.Số Vật Tư xuất cho B.Phận hoặc C.Ty khác'
                , editable: true
                , width: 100
                , edittype: 'text'
                , editrules: { required:true } 
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'tienPheLieu'
                , label: 'Tiền Phế Liệu'
                , index: 'cl.ta_ngan'
                , width: 100
                , edittype: 'text'
                , editable: true
                , editrules: { required:true }
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'chiPhiXuatKhau'
                , index: 'cl.chiPhiXuatKhau'
                , label: 'Chi Phí Xuất Khẩu'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'chiPhiHCNS'
                , index: 'cl.chiPhiHCNS'
                , label: 'Chi Phí HCNS'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'luongNV'
                , index: 'cl.luongNV'
                , label: 'Lương N.Viên'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'luongCN'
                , index: 'cl.luongCN'
                , label: 'Lương C.Nhân'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'phiCDBHXHNV'
                , index: 'cl.phiCDBHXHNV'
                , label: 'Phí C.Đoàn, BHXH của N.Viên'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'phiCDBHXHCN'
                , index: 'cl.phiCDBHXHCN'
                , label: 'Phí C.Đoàn, BHXH của C.Nhân'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'thuongLeTetNV'
                , index: 'cl.thuongLeTetNV'
                , label: 'Thưởng Lễ Tết N.Viên'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'thuongLeTetCN'
                , index: 'cl.thuongLeTetCN'
                , label: 'Thưởng Lễ Tết C.Nhân'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'chiTienMatKhac'
                , index: 'cl.chiTienMatKhac'
                , label: 'Chi Tiền Mặt Khác'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'khieuNai'
                , index: 'cl.khieuNai'
                , label: 'Khiếu Nại'
                , width: 100
                , edittype: 'text'
                , editable: false
                , hidden: true
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'cuocGuiMauKiemDinh'
                , index: 'cl.cuocGuiMauKiemDinh'
                , label: 'Cước Gửi Mẫu, Kiểm Định'
                , width: 100
                , edittype: 'text'
                , editable: true
                , hidden: false
                , align: 'right'
                , formatter:'currency'
                , formatoptions:{decimalSeparator:'.', thousandsSeparator: ',', decimalPlaces: 0, prefix: ''}
            },
            {
                fixed: true
                , name: 'ngaytao'
                , label: 'Ngày Tạo'
                , index: 'cl.ngaytao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
                , align: 'center'
            },
            {
                fixed: true
                , name: 'nguoitao'
                , label: 'Người Tạo'
                , index: 'cl.nguoitao'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
                , align: 'center'
            },
            {
                fixed: true
                , name: 'ngaycapnhat'
                , label: 'Ngày Cập Nhật'
                , index: 'cl.ngaycapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
                , align: 'center'
            },
            {
                fixed: true
                , name: 'nguoicapnhat'
                , label: 'Người Cập Nhật'
                , index: 'cl.nguoicapnhat'
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true
                , align: 'center'
            },
            {
                fixed: true
                , name: 'mota'
                , index: 'cl.mota'
                , label: 'Mô Tả'
                , width: 100
                , editable:true
                , edittype: 'textarea'
            },
            {
                fixed: true
                , name: 'hoatdong'
                , label: 'Hoạt Động'
                , hidden: true
                , index: 'cl.hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            }
            ]"
            Height = "100"
            GridComplete = "let o = $(this).parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height()- 90);"
            ShowAdd ="true"
            ShowEdit ="true"
            ShowDel = "true"
            AddFormOptions ="
                width: 440,
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                },
                afterShowForm: function (formid) {
                    //let sel = formid.selector;
                    //$('#nam', sel).prop('disabled', false);
                    //$('#thang', sel).prop('disabled', false);
                },
                afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs);
                }
            "
            EditFormOptions="
                width: 440,
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                },
                afterShowForm: function (formid) {
                    //let sel = formid.selector;
                    //$('#nam', sel).prop('disabled', true);
                    //$('#thang', sel).prop('disabled', true); 
                },
                afterSubmit: function(rs, postdata){
                    return showMsgDialog(rs);
                }
            "
            DelFormOptions="
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
            "
            ViewFormOptions="
                width: 440,
                beforeShowForm: function (formid) {
                    formid.closest('div.ui-jqdialog').dialogCenter(); 
                }
            "
            runat="server" />
			

<script>
	if(chietxuatLHH.toLowerCase() == 'false') {
		var parent = $('#grid_ds_rpt_tonghopdoanhthuchiphi-pager_left');
		parent.find('.ui-icon.ui-icon-print').parent().parent().remove();
	}

	createRightPanel('grid_ds_rpt_tonghopdoanhthuchiphi');
</script>