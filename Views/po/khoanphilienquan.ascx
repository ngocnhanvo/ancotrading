<%@ Control Language="C#" AutoEventWireup="true" CodeFile="khoanphilienquan.ascx.cs" Inherits="Views_po_khoanphilienquan" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<script type="text/javascript">
    
</script>

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

    $("#grid_khoanphi").jqGrid('navButtonAdd', '#grid_khoanphi-pager', {
        caption: "",
        buttonicon: "ui-icon-lightbulb",
        title: "Phân bổ phí vào dòng hàng",
        onClickButton: function () {
            const iddlg = `dlg_grid_khoanphi`;
            const idPO = $("#grid_ds_po").jqGrid('getGridParam', 'selrow');
            $('body').append(`
                <div title="Phân bổ phí vào dòng hàng" id="${iddlg}">
                    <h3>Bạn muốn thực hiện chức năng này?</h3>
                    <div style="display:none" id="wait">
                        <img style="width:30px; height:30px" src="iconcollection/loading.gif"/>
                    </div>
                </div>
            `);

            $(`#${iddlg}`).dialog({
                modal: true,
                width: Math.min(300, $(window).width() - 30),
                height: 'auto',
                open: function (event, ui) {

                },
                close: function () {
                    $('#btn-close').click();
                },
                buttons: [
                    {
                        id: "btn-taophicongphitru",
                        text: "Có",
                        click: function () {
                            $("#wait").css("display", "block");
                            $.post(`Controllers/PhiDonHangController.ashx`, {
                                action: 'phanBoPhi',
                                id: idPO
                            }, function (rs) {
                                alert(rs.msg);
                                if (rs.ok) {
                                    $('#grid_ds_chitietpo')[0].triggerToolbar();
                                    $('#btn-close').click();
                                }
                                $("#wait").css("display", "none");
                            }).fail(function () {
                                alert('Lỗi');
                                $("#wait").css("display", "none");
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
    });
</script>