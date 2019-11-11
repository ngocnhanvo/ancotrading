<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-baocao-chodoitac.aspx.cs" Inherits="inc_baocao_chodoitac" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Xml.Linq" %>
<%@ Register src="jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>
<%@ Register Src="Invoice.ascx" TagName="Cbm" TagPrefix="uc2" %>
<%@ Register Src="cdm_doitackinhdoanh.ascx" TagName="Cbm" TagPrefix="uc3" %>
<%@ Register Src="cbm_hehang.ascx" TagName="Cbm" TagPrefix="uc4" %>
<%@ Register Src="cbm_phanloaihehang.ascx" TagName="Cbm" TagPrefix="uc5" %>
<link rel="stylesheet" type="text/css" href="jQuery/MutilSelect/jquery.multiselect.css" />
<script type="text/javascript" src="jQuery/MutilSelect/jquery.multiselect.js"></script>
<script language="javascript">
    $(function() {
        $('#tabs-donhang-details').tabs();

        $("#color").multiselect({
            header: "Chọn tối đa 6 color-ref!",
            click: function(e) {

                if ($(this).multiselect("widget").find("input:checked").length > 6) {
                    alert('chọn tối đa 6 mã màu');
                    return false;
                }
            }
        });

                $("#hinh1").mask('99-99999');
                $("#hinh2").mask('99-99999');
                $("#hinh3").mask('99-99999');
                $("#hinh4").mask('99-99999');
                $("#sp1").mask('99-99999-**-**');
                $("#sp2").mask('99-99999-**-**');
                $("#sp3").mask('99-99999-**-**');
                $("#sp4").mask('99-99999-**-**');

        $("#sp1").combogrid({
            searchIcon: true,
            width: '480px',
            url: 'Controllers/ProductController.ashx?action=getcombogrid',
            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden: true }
                              , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã SP', 'align': 'left' }
                              , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả TV', 'align': 'left'}],
            select: function(event, ui) {
                $("#sp1").val(ui.item.ma_sanpham);
                $.ajax({
                    url: "Controllers/ProductController.ashx?action=getdetail",
                    type: "POST",
                    data: { sanpham: ui.item.md_sanpham_id },
                    error: function(rs) { },
                    success: function(rs) {
                        $("#mota1").val($("#mota1").val() + rs);
                    }
                });
                return false;
            }
        });

        $("#sp2").combogrid({
            searchIcon: true,
            width: '480px',
            url: 'Controllers/ProductController.ashx?action=getcombogrid',
            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden: true }
                              , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã SP', 'align': 'left' }
                              , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả TV', 'align': 'left'}],
            select: function(event, ui) {
                $("#sp2").val(ui.item.ma_sanpham);
                $.ajax({
                    url: "Controllers/ProductController.ashx?action=getdetail",
                    type: "POST",
                    data: { sanpham: ui.item.md_sanpham_id },
                    error: function(rs) { },
                    success: function(rs) {
                        $("#mota2").val($("#mota2").val() + rs);
                    }
                });
                return false;
            }
        });

        $("#sp3").combogrid({
            searchIcon: true,
            width: '480px',
            url: 'Controllers/ProductController.ashx?action=getcombogrid',
            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden: true }
                              , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã SP', 'align': 'left' }
                              , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả TV', 'align': 'left'}],
            select: function(event, ui) {
                $("#sp3").val(ui.item.ma_sanpham);
                $.ajax({
                    url: "Controllers/ProductController.ashx?action=getdetail",
                    type: "POST",
                    data: { sanpham: ui.item.md_sanpham_id },
                    error: function(rs) { },
                    success: function(rs) {
                        $("#mota3").val($("#mota3").val() + rs);
                    }
                });
                return false;
            }
        });

        $("#sp4").combogrid({
            searchIcon: true,
            width: '480px',
            url: 'Controllers/ProductController.ashx?action=getcombogrid',
            colModel: [
                                { 'columnName': 'md_sanpham_id', 'width': '0', 'label': 'ID', hidden: true }
                              , { 'columnName': 'ma_sanpham', 'width': '50', 'label': 'Mã SP', 'align': 'left' }
                              , { 'columnName': 'mota_tiengviet', 'width': '50', 'label': 'Mô Tả TV', 'align': 'left'}],
            select: function(event, ui) {
                $("#sp4").val(ui.item.ma_sanpham);
                $.ajax({
                    url: "Controllers/ProductController.ashx?action=getdetail",
                    type: "POST",
                    data: { sanpham: ui.item.md_sanpham_id },
                    error: function(rs) { },
                    success: function(rs) {
                        $("#mota4").val($("#mota4").val() + rs);
                    }
                });
                return false;
            }
        });
    });

    function getAllColor(hehang) {
        var hehangid = $("#hehang").val();

        $.ajax({
            url: "Controllers/PhanloaiHHController.ashx?action=getcolorref",
            type: "POST",
            data: { hehang: hehangid },
            datatype: "html",
            error: function(rs) { },
            success: function(rs) {
                $("#color").html(rs);
                $("#color").multiselect('refresh');
            }
        });
    }

    function taoFile() {
        var hehangid = $("#hehang").val();
        window.open('ReportWizard/RptKhachHang/taoCatalogue.aspx?listcolor=' + $('#color').val() + '&hehangid=' + hehangid);
    }

    function gethinh(index) {
        if (index == 1) {
            $("#url1").html('<img src=\"images/catalogue/content/'+ $("#hinh1").val()+'.jpg'+'\" width=\"200px\" height=\"150px\"/>');
        }
        if (index == 2) {
            $("#url2").html('<img src=\"images/catalogue/content/' + $("#hinh2").val() + '.jpg' + '\" width=\"200px\" height=\"150px\"/>');
        }
        if (index == 3) {
            $("#url3").html('<img src=\"images/catalogue/content/' + $("#hinh3").val() + '.jpg' + '\" width=\"200px\" height=\"150px\"/>');
        }
        if (index == 4) {
            $("#url4").html('<img src=\"images/catalogue/content/' + $("#hinh4").val() + '.jpg' + '\" width=\"200px\" height=\"150px\"/>');
        }

    }

    function taotrangdetail() {
        var hinh1 = $("#hinh1").val().length <= 1 ? "" : $("#hinh1").val() + '.jpg';
        var hinh2 = $("#hinh2").val().length <= 1 ? "" : $("#hinh2").val() + '.jpg';
        var hinh3 = $("#hinh3").val().length <= 1 ? "" : $("#hinh3").val() + '.jpg';
        var hinh4 = $("#hinh4").val().length <= 1 ? "" : $("#hinh4").val() + '.jpg';
        var mota1 = $("#mota1").val();
        var mota2 = $("#mota2").val();
        var mota3 = $("#mota3").val();
        var mota4 = $("#mota4").val();
        if ($("#hinh2").val().length > 7 && $("#hinh1").val().length > 7 && $("#hinh3").val().length <= 1 && $("#hinh4").val().length <= 1) {
            window.open("ReportWizard/RptKhachHang/trangnoidungcatalog2items.aspx?hinh1=" + hinh1 + "&hinh2=" + hinh2 + "&hinh3=" + hinh3 + "&hinh4=" + hinh4 + "&mota1=" + mota1 + "&mota2=" + mota2 + "&mota3=" + mota3 + "&mota4=" + mota4);
        } else if ($("#hinh2").val().length > 7 && $("#hinh1").val().length > 7 && $("#hinh3").val().length > 7 && $("#hinh4").val().length <= 1) {
            window.open("ReportWizard/RptKhachHang/trangnoidungcatalog3items.aspx?hinh1=" + hinh1 + "&hinh2=" + hinh2 + "&hinh3=" + hinh3 + "&hinh4=" + hinh4 + "&mota1=" + mota1 + "&mota2=" + mota2 + "&mota3=" + mota3 + "&mota4=" + mota4);
        } else {
            window.open("ReportWizard/RptKhachHang/trangnoidungcatalog.aspx?hinh1=" + hinh1 + "&hinh2=" + hinh2 + "&hinh3=" + hinh3 + "&hinh4=" + hinh4 + "&mota1=" + mota1 + "&mota2=" + mota2 + "&mota3=" + mota3 + "&mota4=" + mota4);
        }
    }
    function reset() {
        $("#hinh1").val('');
        $("#hinh2").val('');
        $("#hinh3").val('');
        $("#hinh4").val('');
        $("#mota1").html('');
        $("#mota2").html('');
        $("#mota3").html('');
        $("#mota4").html('');
    }
</script>
<%
    this.hehang.Name = "hehang";
    this.hehang.OnChange = "getAllColor(hehang)";
    this.hehang.NullFirstItem = true;
     %>
<div id="tabs-donhang-details" style="overflow:auto;">
        <ul>
            <li><a href="#trangbia">Tạo trang bìa</a></li>
            <li><a href="#trangnoidung">Tạo trang sản phẩm</a></li>
        </ul>
        
        <div id="trangbia" style="width:auto; height:auto;">
            <table>
                <tr>
                    <td>Chọn hệ hàng</td>   
                    <td><uc5:Cbm id="hehang" runat="server"/></td>
                    <td style="width:20px;"></td>
                    <td>
                        <select multiple="multiple" id="color">
	                    </select>        
                    </td>
                    <td style="width:20px;"></td>
                    <td><input type="button" value="Tạo file" onclick="taoFile();"/></td>
                </tr>
                <tr>
                    
                </tr>
            </table>
           
        </div>
        <div id="trangnoidung">
            <table style="width:100%; height:100%" border="1">
                <tr style="width:100%; height:10%;">
                    <td style="width:25%; background:green;" align="center"><span style="font-weight:bold; color:White;">Chọn ví trí 1</span> </td>
                    <td style="width:25%; background:green;" align="center"><span style="font-weight:bold; color:White;">Chọn ví trí 2</span></td>
                    <td style="width:25%; background:green;" align="center"><span style="font-weight:bold; color:White;">Chọn ví trí 3</span></td>
                    <td style="width:25%; background:green;" align="center"><span style="font-weight:bold; color:White;">Chọn ví trí 4</span></td>
                </tr>
                <tr style="width:100%; height:90%;">
                    <td style="width:25%; height:90%;">
                        <table>
                            <tr>
                                <td>Chọn ảnh :</td>
                                <td><input type="text" id="hinh1" /> <input type="button" id="bt1" value="Xem hình" onclick="gethinh(1);"/></td>
                            </tr>
                            <tr><p id="url1" style="text-align:center;"></p></tr>
                            <tr>
                                <td>Chọn mã hàng : </td>
                                <td><input type="text" id="sp1"/></td>
                            </tr>
                        </table>
                        <p>Nội dung : <textarea id="mota1" style="width:330px;height:200px;"></textarea></p>
                    </td>
                    <td style="width:25%; height:90%;">
                        <table>
                            <tr>
                                <td>Chọn ảnh :</td>
                                <td><input type="text" id="hinh2" /> <input type="button" id="bt2" value="Xem hình" onclick="gethinh(2);"/></td>
                            </tr>
                            <tr> <p id="url2" style="text-align:center;"></p></tr>
                            <tr>
                                <td>Chọn mã hàng : </td>
                                <td><input type="text" id="sp2"/></td>
                            </tr>
                        </table>
                        <p>Nội dung : <textarea id="mota2" style="width:330px;height:200px;"></textarea></p>
                    </td>
                    <td style="width:25%; height:90%;">
                         <table>
                                <tr>
                                    <td>Chọn ảnh :</td>
                                    <td><input type="text" id="hinh3" /> <input type="button" id="bt3" value="Xem hình" onclick="gethinh(3);"/></td>
                                </tr>
                                <tr> <p id="url3" style="text-align:center;"></p></tr>
                                <tr>
                                    <td>Chọn mã hàng : </td>
                                    <td><input type="text" id="sp3"/></td>
                                </tr>
                            </table>
                        <p>Nội dung : <textarea id="mota3" style="width:330px;height:200px;"></textarea></p>
                    </td>
                    <td style="width:25%; height:90%;">
                        <table>
                                <tr>
                                    <td>Chọn ảnh :</td>
                                    <td><input type="text" id="hinh4" /> <input type="button" id="bt4" value="Xem hình" onclick="gethinh(4);"/></td>
                                </tr>
                                <tr> <p id="url4" style="text-align:center;"></p></tr>
                                <tr>
                                    <td>Chọn mã hàng : </td>
                                    <td><input type="text" id="sp4"/></td>
                                </tr>
                            </table>
                        <p>Nội dung : <textarea id="mota4" style="width:330px;height:200px;"></textarea></p>
                    </td>
                </tr>
                <tr align="center">
                    <td colspan="4">
                        <input type="button" value="Reset" id="reset" onclick="reset()"/>
                        <span style="width:20px"></span>
                        <input type="button" value="Tạo file" id="taotrangdetail" onclick="taotrangdetail()"/>
                    </td>
                    </tr>
            </table>
        </div>
</div>
