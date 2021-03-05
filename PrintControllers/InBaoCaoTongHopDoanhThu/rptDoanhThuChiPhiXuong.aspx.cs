using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_InBaoCaoTongHopDoanhThu_rptDoanhThuChiPhiXuong : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        string nameTemp = "(KT) Báo cáo tổng hợp doanh thu - chi phí của xưởng.xls";
        string nameRpt = "Báo cáo tổng hợp doanh thu - chi phí của xưởng";
        string sql = CreateSql(context);

        inPDF = "2";
        var task = new System.Threading.Tasks.Task(() =>
        {
            viewReport(sql);
        });

        PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, true);
    }

    public void viewReport(String SqlQuery)
    {

    }

    public string CreateSql(HttpContext context)
    {
        string nam = context.Request.QueryString["nam"];
        string xuong = context.Request.QueryString["xuong"];

        string sql = string.Format(@"	 
            declare @tungay datetime = convert(datetime, N'01/01/{0} 00:00:00', 103)
            declare @denngay datetime = convert(datetime, N'31/12/{0} 23:59:59', 103)
            declare @nam int = {0};
            declare @xuongId nvarchar(32) = N'{1}' 
            declare @xuong nvarchar(32) = (select ma_dtkd from md_doitackinhdoanh where md_doitackinhdoanh_id = @xuongId) 

            declare @tbl table (tien decimal(18,2), thang int)

            insert into @tbl
            select nx.grandtotal as tien, MONTH(nx.ngay_giaonhan) as thang
            from c_nhapxuat (nolock) nx 
            where 
	            ngay_giaonhan between @tungay and @denngay
	            and nx.md_doitackinhdoanh_id = @xuongId
                and nx.md_trangthai_id = 'HIEULUC'
            
            declare @tblINV table (id varchar(32), tienhoahong decimal(18,2), ngay_motokhai datetime)
            insert into @tblINV
            select 
                civ.c_packinginvoice_id, 
                civ.totalgross * civ.phantramhoahong / 100 as tienhoahong,
                civ.ngay_motokhai
            from c_packinginvoice civ
            where civ.ngay_motokhai between @tungay and @denngay
            
            declare @tblHoaHong table (tien decimal(18,2), thang int)
            insert into @tblHoaHong
            select civ.tienhoahong, MONTH(civ.ngay_motokhai) as thang
            from @tblINV civ
            where
            (
                select count(1)
                from c_dongpklinv (nolock) cdiv
                where 
                    cdiv.nhacungungid = @xuongId
                    and cdiv.c_packinginvoice_id = civ.id
            ) > 0
            
            declare @tblPhieuChi table (vtbb decimal(18,2), khieuNai decimal(18,2), thang int)
            insert into @tblPhieuChi
            select 
                (case when tc.loaiphieu2 = 'VTBBPLTNK' then tc.sotien else 0 end), 
                (case when tc.loaiphieu2 = 'KhieuNai' then tc.sotien else 0 end), 
                MONTH(tc.ngaychi) as thang
            from c_chitietthuchi tc
            where 
                tc.ngaychi between @tungay and @denngay
                and tc.md_doitackinhdoanh_id = @xuongId

            declare @tblNhapLieu table (
                thang int,
                dsoVTXuatChoBPCtyKhac decimal(18,2), 
                tienPheLieu decimal(18,2), 
                chiPhiXuatKhau decimal(18,2), 
                chiPhiHCNS decimal(18,2), 
                luongNV decimal(18,2), 
                luongCN decimal(18,2), 
                phiCDBHXHNV decimal(18,2), 
                phiCDBHXHCN decimal(18,2), 
                thuongLeTetNV decimal(18,2), 
                thuongLeTetCN decimal(18,2), 
                chiTienMatKhac decimal(18,2), 
                khieuNai decimal(18,2), 
                cuocGuiMauKiemDinh decimal(18,2),
                noDauNam decimal(18,2)
            )
            insert into @tblNhapLieu
            select 
                tc.thang,
                tc.dsoVTXuatChoBPCtyKhac,
                tc.tienPheLieu,
                tc.chiPhiXuatKhau, 
                tc.chiPhiHCNS, 
                tc.luongNV, 
                tc.luongCN, 
                tc.phiCDBHXHNV, 
                tc.phiCDBHXHCN, 
                tc.thuongLeTetNV, 
                tc.thuongLeTetCN, 
                tc.chiTienMatKhac, 
                tc.khieuNai, 
                tc.cuocGuiMauKiemDinh,
                tc.noDauNam
            from rpt_tonghopdoanhthuchiphi tc
            where 
                tc.nam = @nam
                and tc.xuongId = @xuongId

            select 
                @nam as nam,
                @xuong as xuong,
                (select top 1 noDauNam from @tblNhapLieu where thang = 1) as noDauNam,
	            (select sum(tien) from @tbl where thang = 1) as a_1_1,
	            (select sum(tien) from @tbl where thang = 2) as a_1_2,
	            (select sum(tien) from @tbl where thang = 3) as a_1_3,
	            (select sum(tien) from @tbl where thang = 4) as a_1_4,
	            (select sum(tien) from @tbl where thang = 5) as a_1_5,
	            (select sum(tien) from @tbl where thang = 6) as a_1_6,
	            (select sum(tien) from @tbl where thang = 7) as a_1_7,
	            (select sum(tien) from @tbl where thang = 8) as a_1_8,
	            (select sum(tien) from @tbl where thang = 9) as a_1_9,
	            (select sum(tien) from @tbl where thang = 10) as a_1_10,
	            (select sum(tien) from @tbl where thang = 11) as a_1_11,
	            (select sum(tien) from @tbl where thang = 12) as a_1_12,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 1) as a_2_1,
	            (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 2) as a_2_2,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 3) as a_2_3,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 4) as a_2_4,
	            (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 5) as a_2_5,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 6) as a_2_6,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 7) as a_2_7,
	            (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 8) as a_2_8,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 9) as a_2_9,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 10) as a_2_10,
	            (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 11) as a_2_11,
                (select sum(dsoVTXuatChoBPCtyKhac) from @tblNhapLieu where thang = 12) as a_2_12,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 1) as a_3_1,
	            (select sum(tienPheLieu) from @tblNhapLieu where thang = 2) as a_3_2,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 3) as a_3_3,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 4) as a_3_4,
	            (select sum(tienPheLieu) from @tblNhapLieu where thang = 5) as a_3_5,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 6) as a_3_6,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 7) as a_3_7,
	            (select sum(tienPheLieu) from @tblNhapLieu where thang = 8) as a_3_8,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 9) as a_3_9,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 10) as a_3_10,
	            (select sum(tienPheLieu) from @tblNhapLieu where thang = 11) as a_3_11,
                (select sum(tienPheLieu) from @tblNhapLieu where thang = 12) as a_3_12,

                (select sum(vtbb) from @tblPhieuChi where thang = 1) as b_1_1,
	            (select sum(vtbb) from @tblPhieuChi where thang = 2) as b_1_2,
                (select sum(vtbb) from @tblPhieuChi where thang = 3) as b_1_3,
                (select sum(vtbb) from @tblPhieuChi where thang = 4) as b_1_4,
	            (select sum(vtbb) from @tblPhieuChi where thang = 5) as b_1_5,
                (select sum(vtbb) from @tblPhieuChi where thang = 6) as b_1_6,
                (select sum(vtbb) from @tblPhieuChi where thang = 7) as b_1_7,
	            (select sum(vtbb) from @tblPhieuChi where thang = 8) as b_1_8,
                (select sum(vtbb) from @tblPhieuChi where thang = 9) as b_1_9,
                (select sum(vtbb) from @tblPhieuChi where thang = 10) as b_1_10,
	            (select sum(vtbb) from @tblPhieuChi where thang = 11) as b_1_11,
                (select sum(vtbb) from @tblPhieuChi where thang = 12) as b_1_12,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 1) as b_2_1,
	            (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 2) as b_2_2,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 3) as b_2_3,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 4) as b_2_4,
	            (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 5) as b_2_5,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 6) as b_2_6,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 7) as b_2_7,
	            (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 8) as b_2_8,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 9) as b_2_9,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 10) as b_2_10,
	            (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 11) as b_2_11,
                (select sum(chiPhiXuatKhau) from @tblNhapLieu where thang = 12) as b_2_12,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 1) as b_3_1,
	            (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 2) as b_3_2,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 3) as b_3_3,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 4) as b_3_4,
	            (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 5) as b_3_5,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 6) as b_3_6,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 7) as b_3_7,
	            (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 8) as b_3_8,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 9) as b_3_9,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 10) as b_3_10,
	            (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 11) as b_3_11,
                (select sum(chiPhiHCNS) from @tblNhapLieu where thang = 12) as b_3_12,
                (select sum(luongNV) from @tblNhapLieu where thang = 1) as b_4_1,
	            (select sum(luongNV) from @tblNhapLieu where thang = 2) as b_4_2,
                (select sum(luongNV) from @tblNhapLieu where thang = 3) as b_4_3,
                (select sum(luongNV) from @tblNhapLieu where thang = 4) as b_4_4,
	            (select sum(luongNV) from @tblNhapLieu where thang = 5) as b_4_5,
                (select sum(luongNV) from @tblNhapLieu where thang = 6) as b_4_6,
                (select sum(luongNV) from @tblNhapLieu where thang = 7) as b_4_7,
	            (select sum(luongNV) from @tblNhapLieu where thang = 8) as b_4_8,
                (select sum(luongNV) from @tblNhapLieu where thang = 9) as b_4_9,
                (select sum(luongNV) from @tblNhapLieu where thang = 10) as b_4_10,
	            (select sum(luongNV) from @tblNhapLieu where thang = 11) as b_4_11,
                (select sum(luongNV) from @tblNhapLieu where thang = 12) as b_4_12,
                (select sum(luongCN) from @tblNhapLieu where thang = 1) as b_5_1,
	            (select sum(luongCN) from @tblNhapLieu where thang = 2) as b_5_2,
                (select sum(luongCN) from @tblNhapLieu where thang = 3) as b_5_3,
                (select sum(luongCN) from @tblNhapLieu where thang = 4) as b_5_4,
	            (select sum(luongCN) from @tblNhapLieu where thang = 5) as b_5_5,
                (select sum(luongCN) from @tblNhapLieu where thang = 6) as b_5_6,
                (select sum(luongCN) from @tblNhapLieu where thang = 7) as b_5_7,
	            (select sum(luongCN) from @tblNhapLieu where thang = 8) as b_5_8,
                (select sum(luongCN) from @tblNhapLieu where thang = 9) as b_5_9,
                (select sum(luongCN) from @tblNhapLieu where thang = 10) as b_5_10,
	            (select sum(luongCN) from @tblNhapLieu where thang = 11) as b_5_11,
                (select sum(luongCN) from @tblNhapLieu where thang = 12) as b_5_12,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 1) as b_6_1,
	            (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 2) as b_6_2,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 3) as b_6_3,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 4) as b_6_4,
	            (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 5) as b_6_5,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 6) as b_6_6,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 7) as b_6_7,
	            (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 8) as b_6_8,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 9) as b_6_9,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 10) as b_6_10,
	            (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 11) as b_6_11,
                (select sum(phiCDBHXHNV) from @tblNhapLieu where thang = 12) as b_6_12,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 1) as b_7_1,
	            (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 2) as b_7_2,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 3) as b_7_3,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 4) as b_7_4,
	            (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 5) as b_7_5,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 6) as b_7_6,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 7) as b_7_7,
	            (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 8) as b_7_8,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 9) as b_7_9,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 10) as b_7_10,
	            (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 11) as b_7_11,
                (select sum(phiCDBHXHCN) from @tblNhapLieu where thang = 12) as b_7_12,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 1) as b_8_1,
	            (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 2) as b_8_2,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 3) as b_8_3,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 4) as b_8_4,
	            (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 5) as b_8_5,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 6) as b_8_6,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 7) as b_8_7,
	            (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 8) as b_8_8,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 9) as b_8_9,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 10) as b_8_10,
	            (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 11) as b_8_11,
                (select sum(thuongLeTetNV) from @tblNhapLieu where thang = 12) as b_8_12,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 1) as b_9_1,
	            (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 2) as b_9_2,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 3) as b_9_3,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 4) as b_9_4,
	            (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 5) as b_9_5,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 6) as b_9_6,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 7) as b_9_7,
	            (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 8) as b_9_8,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 9) as b_9_9,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 10) as b_9_10,
	            (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 11) as b_9_11,
                (select sum(thuongLeTetCN) from @tblNhapLieu where thang = 12) as b_9_12,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_1,
	            (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_2,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_3,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_4,
	            (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_5,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_6,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_7,
	            (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_8,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_9,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_10,
	            (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_11,
                (select sum(chiTienMatKhac) from @tblNhapLieu where thang = 12) as b_10_12,
                (select sum(tien) from @tblHoaHong where thang = 1) as b_11_1,
	            (select sum(tien) from @tblHoaHong where thang = 2) as b_11_2,
                (select sum(tien) from @tblHoaHong where thang = 3) as b_11_3,
                (select sum(tien) from @tblHoaHong where thang = 4) as b_11_4,
	            (select sum(tien) from @tblHoaHong where thang = 5) as b_11_5,
                (select sum(tien) from @tblHoaHong where thang = 6) as b_11_6,
                (select sum(tien) from @tblHoaHong where thang = 7) as b_11_7,
	            (select sum(tien) from @tblHoaHong where thang = 8) as b_11_8,
                (select sum(tien) from @tblHoaHong where thang = 9) as b_11_9,
                (select sum(tien) from @tblHoaHong where thang = 10) as b_11_10,
	            (select sum(tien) from @tblHoaHong where thang = 11) as b_11_11,
                (select sum(tien) from @tblHoaHong where thang = 12) as b_11_12,
                (select sum(khieuNai) from @tblPhieuChi where thang = 1) as b_12_1,
	            (select sum(khieuNai) from @tblPhieuChi where thang = 2) as b_12_2,
                (select sum(khieuNai) from @tblPhieuChi where thang = 3) as b_12_3,
                (select sum(khieuNai) from @tblPhieuChi where thang = 4) as b_12_4,
	            (select sum(khieuNai) from @tblPhieuChi where thang = 5) as b_12_5,
                (select sum(khieuNai) from @tblPhieuChi where thang = 6) as b_12_6,
                (select sum(khieuNai) from @tblPhieuChi where thang = 7) as b_12_7,
	            (select sum(khieuNai) from @tblPhieuChi where thang = 8) as b_12_8,
                (select sum(khieuNai) from @tblPhieuChi where thang = 9) as b_12_9,
                (select sum(khieuNai) from @tblPhieuChi where thang = 10) as b_12_10,
	            (select sum(khieuNai) from @tblPhieuChi where thang = 11) as b_12_11,
                (select sum(khieuNai) from @tblPhieuChi where thang = 12) as b_12_12,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 1) as b_13_1,
	            (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 2) as b_13_2,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 3) as b_13_3,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 4) as b_13_4,
	            (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 5) as b_13_5,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 6) as b_13_6,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 7) as b_13_7,
	            (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 8) as b_13_8,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 9) as b_13_9,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 10) as b_13_10,
	            (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 11) as b_13_11,
                (select sum(cuocGuiMauKiemDinh) from @tblNhapLieu where thang = 12) as b_13_12
		"
        , nam
        , xuong
        );

        //throw new ArgumentNullException(sql);
        return sql;
    }
}