using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_InBaoCaoTongHopDoanhThu_rptDoanhThuChiPhiXuongTheoNam : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(KT) Báo cáo tổng hợp doanh thu - chi phí theo năm của xưởng " + maXuong + ".xls";
        string nameRpt = "Báo cáo tổng hợp doanh thu - chi phí theo năm của xưởng " + maXuong;
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
        var maXuong = context.Request.QueryString["maXuong"];
        string manv = context.User.Identity.Name.removeAllSpaceOrTrimText(true);
        if (new string[] { "quangtrung", "thuyhan" }.Contains(manv))
        {
            if (maXuong != "ANCO1")
            {
                throw new Exception("Chỉ có thể xem Anco1");
            }
        }

        string sql = string.Format(@"	 
            declare @tungay datetime = convert(datetime, N'01/01/{0} 00:00:00', 103)
            declare @denngay datetime = convert(datetime, N'31/12/{0} 23:59:59', 103)
            declare @nam int = {0};
            declare @xuongId nvarchar(32) = N'{1}'
			-----------------------------------
            declare @tblINV table (id varchar(32), tienhoahong decimal(18,2), ngay_motokhai datetime)
            insert into @tblINV
            select 
                civ.c_packinginvoice_id, 
                isnull(civ.hoahongdatra, 0),
                civ.ngay_motokhai
            from c_packinginvoice civ
            where 
                civ.ngay_motokhai between @tungay and @denngay
                and civ.md_trangthai_id = 'HIEULUC'
            -----------------------------------
            declare @tbl table (tien decimal(18,2), phicong decimal(18,2), phitru decimal(18,2), nxid nvarchar(32), thang int)
            insert into @tbl
	            select
		            (cdnx.slthuc_nhapxuat * cdnx.dongia) - (cdnx.slthuc_nhapxuat * cdnx.dongia) * isnull(cnx.discount, 0) / 100 as tien,
		            phicong,
		            cnx.phitru,
		            cnx.c_nhapxuat_id,
		            MONTH(civ.ngay_motokhai) as thang
	            from 
		            c_dongnhapxuat cdnx 
		            inner join c_nhapxuat cnx on cnx.c_nhapxuat_id = cdnx.c_nhapxuat_id
		            inner join c_dongnhapxuat cdnx2 on cdnx.c_dongnhapxuat_id = cdnx2.dongnhapxuat_ref
		            inner join c_dongpklinv cdiv on cdnx2.c_dongnhapxuat_id = cdiv.c_dongnhapxuat_id
		            inner join @tblINV civ on civ.id = cdiv.c_packinginvoice_id
	            where 
		            1=1
		            and cnx.md_doitackinhdoanh_id = @xuongId
		            and cnx.md_loaichungtu_id = 'NK'
            -----------------------------------
            declare @tblTienDSBH table (tien decimal(18,2), thang int)
            insert into @tblTienDSBH
            select
	            (select sum(tien) from @tbl where thang = a.thang) + 
	            (select sum(a.phicong - a.phitru) from (select distinct phicong, phitru, nxid from @tbl where thang = a.thang)a),
	            thang
	            from @tbl a
	            group by a.thang
            -----------------------------------
            declare @tblDongINV_HoaHong table (c_packinginvoice_id nvarchar(32))
            insert into @tblDongINV_HoaHong
            select distinct cdiv.c_packinginvoice_id
            from c_dongpklinv (nolock) cdiv
            where 
                cdiv.nhacungungid = @xuongId
                and cdiv.c_packinginvoice_id in (select id from @tblINV)

            declare @tblHoaHong table (tien decimal(18,2), thang int)
            insert into @tblHoaHong
            select civ.tienhoahong, MONTH(civ.ngay_motokhai) as thang
            from @tblINV civ
            where civ.id in 
            (
                select cdiv.c_packinginvoice_id
                from @tblDongINV_HoaHong cdiv
            )
            -----------------------------------
            declare @tblPhieuChi table (
                thang int,
                chenhLechTyGiaDSBH decimal(18,2), 
                dsoVTXuatChoBPCtyKhac decimal(18,2), 
                tienBHXHBHLDNghiViec decimal(18,2),
                dienNuocRacCtyHaca decimal(18,2), 
                nopTamUng decimal(18,2),
                tienPheLieu decimal(18,2), 
                VTBBPLTNK decimal(18,2),
                chiPhiXuatKhau decimal(18,2), 
                chiPhiHCNS decimal(18,2),
                luongNV decimal(18,2), 
                luongCN decimal(18,2),
                phiCDBHXHNV decimal(18,2), 
                phiCDBHXHCN decimal(18,2),
                thuongLeTetNV decimal(18,2), 
                thuongLeTetCN decimal(18,2),
                tamUngLuongCN decimal(18,2), 
                chiTienMatKhac decimal(18,2),
                trich20PheLieu decimal(18,2), 
                khieuNai decimal(18,2),
                cuocGuiMauKiemDinh decimal(18,2)
            )
            insert into @tblPhieuChi
            select 
                MONTH(tc.ngay_giaonop) as thang,
                (case when dtc.loaiphieu2 = 'chenhLechTyGiaDSBH' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'dsoVTXuatChoBPCtyKhac' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'tienBHXHBHLDNghiViec' then dtc.sotien else 0 end), 
                (case when dtc.loaiphieu2 = 'dienNuocRacCtyHaca' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'nopTamUng' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'tienPheLieu' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'VTBBPLTNK' then dtc.sotien else 0 end), 
                (case when dtc.loaiphieu2 = 'chiPhiXuatKhau' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'chiPhiHCNS' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'luongNV' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'luongCN' then dtc.sotien else 0 end), 
                (case when dtc.loaiphieu2 = 'phiCDBHXHNV' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'phiCDBHXHCN' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'thuongLeTetNV' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'thuongLeTetCN' then dtc.sotien else 0 end), 
                (case when dtc.loaiphieu2 = 'tamUngLuongCN' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'chiTienMatKhac' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'trich20PheLieu' then dtc.sotien else 0 end),
                (case when dtc.loaiphieu2 = 'KhieuNai' then dtc.sotien else 0 end), 
                (case when dtc.loaiphieu2 = 'cuocGuiMauKiemDinh' then dtc.sotien else 0 end)
            from c_chitietthuchi dtc
	            left join c_thuchi tc on tc.c_thuchi_id = dtc.c_thuchi_id
            where 
                tc.ngay_giaonop between @tungay and @denngay
                and dtc.dtkd_id_ThuChi = @xuongId
	            --and tc.md_trangthai_id = 'HIEULUC'

            declare @tblNhapLieu table (
                thang int, 
                noDauNam decimal(18,2)
            )
            insert into @tblNhapLieu
            select 
                tc.thang,
                tc.noDauNam
            from rpt_tonghopdoanhthuchiphi tc
            where 
                tc.nam = @nam
                and tc.xuongId = @xuongId

            begin --#bien toan cuc @tblThuChi
            declare @a_1BS1_1 decimal(18,2), 
	            @a_1BS1_2 decimal(18,2), 
	            @a_1BS1_3 decimal(18,2),
	            @a_1BS1_4 decimal(18,2),
	            @a_1BS1_5 decimal(18,2),
	            @a_1BS1_6 decimal(18,2),
	            @a_1BS1_7 decimal(18,2),
	            @a_1BS1_8 decimal(18,2),
	            @a_1BS1_9 decimal(18,2),
	            @a_1BS1_10 decimal(18,2),
	            @a_1BS1_11 decimal(18,2),
	            @a_1BS1_12 decimal(18,2);

            declare @a_2_1 decimal(18,2), 
	            @a_2_2 decimal(18,2), 
	            @a_2_3 decimal(18,2),
	            @a_2_4 decimal(18,2),
	            @a_2_5 decimal(18,2),
	            @a_2_6 decimal(18,2),
	            @a_2_7 decimal(18,2),
	            @a_2_8 decimal(18,2),
	            @a_2_9 decimal(18,2),
	            @a_2_10 decimal(18,2),
	            @a_2_11 decimal(18,2),
	            @a_2_12 decimal(18,2);

            declare @a_2BS1_1 decimal(18,2), 
	            @a_2BS1_2 decimal(18,2), 
	            @a_2BS1_3 decimal(18,2),
	            @a_2BS1_4 decimal(18,2),
	            @a_2BS1_5 decimal(18,2),
	            @a_2BS1_6 decimal(18,2),
	            @a_2BS1_7 decimal(18,2),
	            @a_2BS1_8 decimal(18,2),
	            @a_2BS1_9 decimal(18,2),
	            @a_2BS1_10 decimal(18,2),
	            @a_2BS1_11 decimal(18,2),
	            @a_2BS1_12 decimal(18,2);

            declare @a_2BS2_1 decimal(18,2), 
	            @a_2BS2_2 decimal(18,2), 
	            @a_2BS2_3 decimal(18,2),
	            @a_2BS2_4 decimal(18,2),
	            @a_2BS2_5 decimal(18,2),
	            @a_2BS2_6 decimal(18,2),
	            @a_2BS2_7 decimal(18,2),
	            @a_2BS2_8 decimal(18,2),
	            @a_2BS2_9 decimal(18,2),
	            @a_2BS2_10 decimal(18,2),
	            @a_2BS2_11 decimal(18,2),
	            @a_2BS2_12 decimal(18,2);

            declare @a_2BS3_1 decimal(18,2), 
	            @a_2BS3_2 decimal(18,2), 
	            @a_2BS3_3 decimal(18,2),
	            @a_2BS3_4 decimal(18,2),
	            @a_2BS3_5 decimal(18,2),
	            @a_2BS3_6 decimal(18,2),
	            @a_2BS3_7 decimal(18,2),
	            @a_2BS3_8 decimal(18,2),
	            @a_2BS3_9 decimal(18,2),
	            @a_2BS3_10 decimal(18,2),
	            @a_2BS3_11 decimal(18,2),
	            @a_2BS3_12 decimal(18,2);

            declare @a_3_1 decimal(18,2), 
	            @a_3_2 decimal(18,2), 
	            @a_3_3 decimal(18,2),
	            @a_3_4 decimal(18,2),
	            @a_3_5 decimal(18,2),
	            @a_3_6 decimal(18,2),
	            @a_3_7 decimal(18,2),
	            @a_3_8 decimal(18,2),
	            @a_3_9 decimal(18,2),
	            @a_3_10 decimal(18,2),
	            @a_3_11 decimal(18,2),
	            @a_3_12 decimal(18,2);

            declare @b_1_1 decimal(18,2), 
	            @b_1_2 decimal(18,2), 
	            @b_1_3 decimal(18,2),
	            @b_1_4 decimal(18,2),
	            @b_1_5 decimal(18,2),
	            @b_1_6 decimal(18,2),
	            @b_1_7 decimal(18,2),
	            @b_1_8 decimal(18,2),
	            @b_1_9 decimal(18,2),
	            @b_1_10 decimal(18,2),
	            @b_1_11 decimal(18,2),
	            @b_1_12 decimal(18,2);

            declare @b_2_1 decimal(18,2), 
	            @b_2_2 decimal(18,2), 
	            @b_2_3 decimal(18,2),
	            @b_2_4 decimal(18,2),
	            @b_2_5 decimal(18,2),
	            @b_2_6 decimal(18,2),
	            @b_2_7 decimal(18,2),
	            @b_2_8 decimal(18,2),
	            @b_2_9 decimal(18,2),
	            @b_2_10 decimal(18,2),
	            @b_2_11 decimal(18,2),
	            @b_2_12 decimal(18,2);

            declare @b_3_1 decimal(18,2), 
	            @b_3_2 decimal(18,2), 
	            @b_3_3 decimal(18,2),
	            @b_3_4 decimal(18,2),
	            @b_3_5 decimal(18,2),
	            @b_3_6 decimal(18,2),
	            @b_3_7 decimal(18,2),
	            @b_3_8 decimal(18,2),
	            @b_3_9 decimal(18,2),
	            @b_3_10 decimal(18,2),
	            @b_3_11 decimal(18,2),
	            @b_3_12 decimal(18,2);

            declare @b_4_1 decimal(18,2), 
	            @b_4_2 decimal(18,2), 
	            @b_4_3 decimal(18,2),
	            @b_4_4 decimal(18,2),
	            @b_4_5 decimal(18,2),
	            @b_4_6 decimal(18,2),
	            @b_4_7 decimal(18,2),
	            @b_4_8 decimal(18,2),
	            @b_4_9 decimal(18,2),
	            @b_4_10 decimal(18,2),
	            @b_4_11 decimal(18,2),
	            @b_4_12 decimal(18,2);

            declare @b_5_1 decimal(18,2), 
	            @b_5_2 decimal(18,2), 
	            @b_5_3 decimal(18,2),
	            @b_5_4 decimal(18,2),
	            @b_5_5 decimal(18,2),
	            @b_5_6 decimal(18,2),
	            @b_5_7 decimal(18,2),
	            @b_5_8 decimal(18,2),
	            @b_5_9 decimal(18,2),
	            @b_5_10 decimal(18,2),
	            @b_5_11 decimal(18,2),
	            @b_5_12 decimal(18,2);

            declare @b_6_1 decimal(18,2), 
	            @b_6_2 decimal(18,2), 
	            @b_6_3 decimal(18,2),
	            @b_6_4 decimal(18,2),
	            @b_6_5 decimal(18,2),
	            @b_6_6 decimal(18,2),
	            @b_6_7 decimal(18,2),
	            @b_6_8 decimal(18,2),
	            @b_6_9 decimal(18,2),
	            @b_6_10 decimal(18,2),
	            @b_6_11 decimal(18,2),
	            @b_6_12 decimal(18,2);

            declare @b_7_1 decimal(18,2), 
	            @b_7_2 decimal(18,2), 
	            @b_7_3 decimal(18,2),
	            @b_7_4 decimal(18,2),
	            @b_7_5 decimal(18,2),
	            @b_7_6 decimal(18,2),
	            @b_7_7 decimal(18,2),
	            @b_7_8 decimal(18,2),
	            @b_7_9 decimal(18,2),
	            @b_7_10 decimal(18,2),
	            @b_7_11 decimal(18,2),
	            @b_7_12 decimal(18,2);

            declare @b_8_1 decimal(18,2), 
	            @b_8_2 decimal(18,2), 
	            @b_8_3 decimal(18,2),
	            @b_8_4 decimal(18,2),
	            @b_8_5 decimal(18,2),
	            @b_8_6 decimal(18,2),
	            @b_8_7 decimal(18,2),
	            @b_8_8 decimal(18,2),
	            @b_8_9 decimal(18,2),
	            @b_8_10 decimal(18,2),
	            @b_8_11 decimal(18,2),
	            @b_8_12 decimal(18,2);

            declare @b_9_1 decimal(18,2), 
	            @b_9_2 decimal(18,2), 
	            @b_9_3 decimal(18,2),
	            @b_9_4 decimal(18,2),
	            @b_9_5 decimal(18,2),
	            @b_9_6 decimal(18,2),
	            @b_9_7 decimal(18,2),
	            @b_9_8 decimal(18,2),
	            @b_9_9 decimal(18,2),
	            @b_9_10 decimal(18,2),
	            @b_9_11 decimal(18,2),
	            @b_9_12 decimal(18,2);

            declare @b_9BS1_1 decimal(18,2), 
	            @b_9BS1_2 decimal(18,2), 
	            @b_9BS1_3 decimal(18,2),
	            @b_9BS1_4 decimal(18,2),
	            @b_9BS1_5 decimal(18,2),
	            @b_9BS1_6 decimal(18,2),
	            @b_9BS1_7 decimal(18,2),
	            @b_9BS1_8 decimal(18,2),
	            @b_9BS1_9 decimal(18,2),
	            @b_9BS1_10 decimal(18,2),
	            @b_9BS1_11 decimal(18,2),
	            @b_9BS1_12 decimal(18,2);

            declare @b_10_1 decimal(18,2), 
	            @b_10_2 decimal(18,2), 
	            @b_10_3 decimal(18,2),
	            @b_10_4 decimal(18,2),
	            @b_10_5 decimal(18,2),
	            @b_10_6 decimal(18,2),
	            @b_10_7 decimal(18,2),
	            @b_10_8 decimal(18,2),
	            @b_10_9 decimal(18,2),
	            @b_10_10 decimal(18,2),
	            @b_10_11 decimal(18,2),
	            @b_10_12 decimal(18,2);

            declare @b_10BS1_1 decimal(18,2), 
	            @b_10BS1_2 decimal(18,2), 
	            @b_10BS1_3 decimal(18,2),
	            @b_10BS1_4 decimal(18,2),
	            @b_10BS1_5 decimal(18,2),
	            @b_10BS1_6 decimal(18,2),
	            @b_10BS1_7 decimal(18,2),
	            @b_10BS1_8 decimal(18,2),
	            @b_10BS1_9 decimal(18,2),
	            @b_10BS1_10 decimal(18,2),
	            @b_10BS1_11 decimal(18,2),
	            @b_10BS1_12 decimal(18,2);

            declare @b_11_1 decimal(18,2), 
	            @b_11_2 decimal(18,2), 
	            @b_11_3 decimal(18,2),
	            @b_11_4 decimal(18,2),
	            @b_11_5 decimal(18,2),
	            @b_11_6 decimal(18,2),
	            @b_11_7 decimal(18,2),
	            @b_11_8 decimal(18,2),
	            @b_11_9 decimal(18,2),
	            @b_11_10 decimal(18,2),
	            @b_11_11 decimal(18,2),
	            @b_11_12 decimal(18,2);

            declare @b_12_1 decimal(18,2), 
	            @b_12_2 decimal(18,2), 
	            @b_12_3 decimal(18,2),
	            @b_12_4 decimal(18,2),
	            @b_12_5 decimal(18,2),
	            @b_12_6 decimal(18,2),
	            @b_12_7 decimal(18,2),
	            @b_12_8 decimal(18,2),
	            @b_12_9 decimal(18,2),
	            @b_12_10 decimal(18,2),
	            @b_12_11 decimal(18,2),
	            @b_12_12 decimal(18,2);

            declare @b_13_1 decimal(18,2), 
	            @b_13_2 decimal(18,2), 
	            @b_13_3 decimal(18,2),
	            @b_13_4 decimal(18,2),
	            @b_13_5 decimal(18,2),
	            @b_13_6 decimal(18,2),
	            @b_13_7 decimal(18,2),
	            @b_13_8 decimal(18,2),
	            @b_13_9 decimal(18,2),
	            @b_13_10 decimal(18,2),
	            @b_13_11 decimal(18,2),
	            @b_13_12 decimal(18,2);
            end

            begin --#gan gia tri toan cuc @tblThuChi
            select 
	            @a_1BS1_1 = sum(chenhLechTyGiaDSBH),
	            @a_2_1 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_1 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_1 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_1 = sum(nopTamUng),
	            @a_3_1 = sum(tienPheLieu),
	            @b_1_1 = sum(VTBBPLTNK),
	            @b_2_1 = sum(chiPhiXuatKhau),
	            @b_3_1 = sum(chiPhiHCNS),
	            @b_4_1 = sum(luongNV),
	            @b_5_1 = sum(luongCN),
	            @b_6_1 = sum(phiCDBHXHNV),
	            @b_7_1 = sum(phiCDBHXHCN),
	            @b_8_1 = sum(thuongLeTetNV),
	            @b_9_1 = sum(thuongLeTetCN),
	            @b_9BS1_1 = sum(tamUngLuongCN),
	            @b_10_1 = sum(chiTienMatKhac),
	            @b_10BS1_1 = sum(trich20PheLieu),
	            @b_12_1 = sum(khieuNai),
	            @b_13_1 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 1

            select 
	            @a_1BS1_2 = sum(chenhLechTyGiaDSBH),
	            @a_2_2 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_2 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_2 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_2 = sum(nopTamUng),
	            @a_3_2 = sum(tienPheLieu),
	            @b_1_2 = sum(VTBBPLTNK),
	            @b_2_2 = sum(chiPhiXuatKhau),
	            @b_3_2 = sum(chiPhiHCNS),
	            @b_4_2 = sum(luongNV),
	            @b_5_2 = sum(luongCN),
	            @b_6_2 = sum(phiCDBHXHNV),
	            @b_7_2 = sum(phiCDBHXHCN),
	            @b_8_2 = sum(thuongLeTetNV),
	            @b_9_2 = sum(thuongLeTetCN),
	            @b_9BS1_2 = sum(tamUngLuongCN),
	            @b_10_2 = sum(chiTienMatKhac),
	            @b_10BS1_2 = sum(trich20PheLieu),
	            @b_12_2 = sum(khieuNai),
	            @b_13_2 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 2

            select 
	            @a_1BS1_3 = sum(chenhLechTyGiaDSBH),
	            @a_2_3 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_3 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_3 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_3 = sum(nopTamUng),
	            @a_3_3 = sum(tienPheLieu),
	            @b_1_3 = sum(VTBBPLTNK),
	            @b_2_3 = sum(chiPhiXuatKhau),
	            @b_3_3 = sum(chiPhiHCNS),
	            @b_4_3 = sum(luongNV),
	            @b_5_3 = sum(luongCN),
	            @b_6_3 = sum(phiCDBHXHNV),
	            @b_7_3 = sum(phiCDBHXHCN),
	            @b_8_3 = sum(thuongLeTetNV),
	            @b_9_3 = sum(thuongLeTetCN),
	            @b_9BS1_3 = sum(tamUngLuongCN),
	            @b_10_3 = sum(chiTienMatKhac),
	            @b_10BS1_3 = sum(trich20PheLieu),
	            @b_12_3 = sum(khieuNai),
	            @b_13_3 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 3

            select 
	            @a_1BS1_4 = sum(chenhLechTyGiaDSBH),
	            @a_2_4 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_4 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_4 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_4 = sum(nopTamUng),
	            @a_3_4 = sum(tienPheLieu),
	            @b_1_4 = sum(VTBBPLTNK),
	            @b_2_4 = sum(chiPhiXuatKhau),
	            @b_3_4 = sum(chiPhiHCNS),
	            @b_4_4 = sum(luongNV),
	            @b_5_4 = sum(luongCN),
	            @b_6_4 = sum(phiCDBHXHNV),
	            @b_7_4 = sum(phiCDBHXHCN),
	            @b_8_4 = sum(thuongLeTetNV),
	            @b_9_4 = sum(thuongLeTetCN),
	            @b_9BS1_4 = sum(tamUngLuongCN),
	            @b_10_4 = sum(chiTienMatKhac),
	            @b_10BS1_4 = sum(trich20PheLieu),
	            @b_12_4 = sum(khieuNai),
	            @b_13_4 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 4

            select 
	            @a_1BS1_5 = sum(chenhLechTyGiaDSBH),
	            @a_2_5 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_5 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_5 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_5 = sum(nopTamUng),
	            @a_3_5 = sum(tienPheLieu),
	            @b_1_5 = sum(VTBBPLTNK),
	            @b_2_5 = sum(chiPhiXuatKhau),
	            @b_3_5 = sum(chiPhiHCNS),
	            @b_4_5 = sum(luongNV),
	            @b_5_5 = sum(luongCN),
	            @b_6_5 = sum(phiCDBHXHNV),
	            @b_7_5 = sum(phiCDBHXHCN),
	            @b_8_5 = sum(thuongLeTetNV),
	            @b_9_5 = sum(thuongLeTetCN),
	            @b_9BS1_5 = sum(tamUngLuongCN),
	            @b_10_5 = sum(chiTienMatKhac),
	            @b_10BS1_5 = sum(trich20PheLieu),
	            @b_12_5 = sum(khieuNai),
	            @b_13_5 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 5

            select 
	            @a_1BS1_6 = sum(chenhLechTyGiaDSBH),
	            @a_2_6 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_6 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_6 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_6 = sum(nopTamUng),
	            @a_3_6 = sum(tienPheLieu),
	            @b_1_6 = sum(VTBBPLTNK),
	            @b_2_6 = sum(chiPhiXuatKhau),
	            @b_3_6 = sum(chiPhiHCNS),
	            @b_4_6 = sum(luongNV),
	            @b_5_6 = sum(luongCN),
	            @b_6_6 = sum(phiCDBHXHNV),
	            @b_7_6 = sum(phiCDBHXHCN),
	            @b_8_6 = sum(thuongLeTetNV),
	            @b_9_6 = sum(thuongLeTetCN),
	            @b_9BS1_6 = sum(tamUngLuongCN),
	            @b_10_6 = sum(chiTienMatKhac),
	            @b_10BS1_6 = sum(trich20PheLieu),
	            @b_12_6 = sum(khieuNai),
	            @b_13_6 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 6

            select 
	            @a_1BS1_7 = sum(chenhLechTyGiaDSBH),
	            @a_2_7 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_7 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_7 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_7 = sum(nopTamUng),
	            @a_3_7 = sum(tienPheLieu),
	            @b_1_7 = sum(VTBBPLTNK),
	            @b_2_7 = sum(chiPhiXuatKhau),
	            @b_3_7 = sum(chiPhiHCNS),
	            @b_4_7 = sum(luongNV),
	            @b_5_7 = sum(luongCN),
	            @b_6_7 = sum(phiCDBHXHNV),
	            @b_7_7 = sum(phiCDBHXHCN),
	            @b_8_7 = sum(thuongLeTetNV),
	            @b_9_7 = sum(thuongLeTetCN),
	            @b_9BS1_7 = sum(tamUngLuongCN),
	            @b_10_7 = sum(chiTienMatKhac),
	            @b_10BS1_7 = sum(trich20PheLieu),
	            @b_12_7 = sum(khieuNai),
	            @b_13_7 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 7

            select 
	            @a_1BS1_8 = sum(chenhLechTyGiaDSBH),
	            @a_2_8 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_8 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_8 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_8 = sum(nopTamUng),
	            @a_3_8 = sum(tienPheLieu),
	            @b_1_8 = sum(VTBBPLTNK),
	            @b_2_8 = sum(chiPhiXuatKhau),
	            @b_3_8 = sum(chiPhiHCNS),
	            @b_4_8 = sum(luongNV),
	            @b_5_8 = sum(luongCN),
	            @b_6_8 = sum(phiCDBHXHNV),
	            @b_7_8 = sum(phiCDBHXHCN),
	            @b_8_8 = sum(thuongLeTetNV),
	            @b_9_8 = sum(thuongLeTetCN),
	            @b_9BS1_8 = sum(tamUngLuongCN),
	            @b_10_8 = sum(chiTienMatKhac),
	            @b_10BS1_8 = sum(trich20PheLieu),
	            @b_12_8 = sum(khieuNai),
	            @b_13_8 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 8

            select 
	            @a_1BS1_9 = sum(chenhLechTyGiaDSBH),
	            @a_2_9 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_9 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_9 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_9 = sum(nopTamUng),
	            @a_3_9 = sum(tienPheLieu),
	            @b_1_9 = sum(VTBBPLTNK),
	            @b_2_9 = sum(chiPhiXuatKhau),
	            @b_3_9 = sum(chiPhiHCNS),
	            @b_4_9 = sum(luongNV),
	            @b_5_9 = sum(luongCN),
	            @b_6_9 = sum(phiCDBHXHNV),
	            @b_7_9 = sum(phiCDBHXHCN),
	            @b_8_9 = sum(thuongLeTetNV),
	            @b_9_9 = sum(thuongLeTetCN),
	            @b_9BS1_9 = sum(tamUngLuongCN),
	            @b_10_9 = sum(chiTienMatKhac),
	            @b_10BS1_9 = sum(trich20PheLieu),
	            @b_12_9 = sum(khieuNai),
	            @b_13_9 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 9
	
            select 
	            @a_1BS1_10 = sum(chenhLechTyGiaDSBH),
	            @a_2_10 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_10 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_10 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_10 = sum(nopTamUng),
	            @a_3_10 = sum(tienPheLieu),
	            @b_1_10 = sum(VTBBPLTNK),
	            @b_2_10 = sum(chiPhiXuatKhau),
	            @b_3_10 = sum(chiPhiHCNS),
	            @b_4_10 = sum(luongNV),
	            @b_5_10 = sum(luongCN),
	            @b_6_10 = sum(phiCDBHXHNV),
	            @b_7_10 = sum(phiCDBHXHCN),
	            @b_8_10 = sum(thuongLeTetNV),
	            @b_9_10 = sum(thuongLeTetCN),
	            @b_9BS1_10 = sum(tamUngLuongCN),
	            @b_10_10 = sum(chiTienMatKhac),
	            @b_10BS1_10 = sum(trich20PheLieu),
	            @b_12_10 = sum(khieuNai),
	            @b_13_10 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 10

            select 
	            @a_1BS1_11 = sum(chenhLechTyGiaDSBH),
	            @a_2_11 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_11 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_11 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_11 = sum(nopTamUng),
	            @a_3_11 = sum(tienPheLieu),
	            @b_1_11 = sum(VTBBPLTNK),
	            @b_2_11 = sum(chiPhiXuatKhau),
	            @b_3_11 = sum(chiPhiHCNS),
	            @b_4_11 = sum(luongNV),
	            @b_5_11 = sum(luongCN),
	            @b_6_11 = sum(phiCDBHXHNV),
	            @b_7_11 = sum(phiCDBHXHCN),
	            @b_8_11 = sum(thuongLeTetNV),
	            @b_9_11 = sum(thuongLeTetCN),
	            @b_9BS1_11 = sum(tamUngLuongCN),
	            @b_10_11 = sum(chiTienMatKhac),
	            @b_10BS1_11 = sum(trich20PheLieu),
	            @b_12_11 = sum(khieuNai),
	            @b_13_11 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 11

            select 
	            @a_1BS1_12 = sum(chenhLechTyGiaDSBH),
	            @a_2_12 = sum(dsoVTXuatChoBPCtyKhac),
	            @a_2BS1_12 = sum(tienBHXHBHLDNghiViec),
	            @a_2BS2_12 = sum(dienNuocRacCtyHaca),
	            @a_2BS3_12 = sum(nopTamUng),
	            @a_3_12 = sum(tienPheLieu),
	            @b_1_12 = sum(VTBBPLTNK),
	            @b_2_12 = sum(chiPhiXuatKhau),
	            @b_3_12 = sum(chiPhiHCNS),
	            @b_4_12 = sum(luongNV),
	            @b_5_12 = sum(luongCN),
	            @b_6_12 = sum(phiCDBHXHNV),
	            @b_7_12 = sum(phiCDBHXHCN),
	            @b_8_12 = sum(thuongLeTetNV),
	            @b_9_12 = sum(thuongLeTetCN),
	            @b_9BS1_12 = sum(tamUngLuongCN),
	            @b_10_12 = sum(chiTienMatKhac),
	            @b_10BS1_12 = sum(trich20PheLieu),
	            @b_12_12 = sum(khieuNai),
	            @b_13_12 = sum(cuocGuiMauKiemDinh)
            from 
	            @tblPhieuChi where thang = 12
            end

            select 
                @nam as nam,
                (select top 1 noDauNam from @tblNhapLieu where thang = 1) as noDauNam,
                (select sum(tien) from @tblTienDSBH where thang = 1) as a_1_1,
                (select sum(tien) from @tblTienDSBH where thang = 2) as a_1_2,
                (select sum(tien) from @tblTienDSBH where thang = 3) as a_1_3,
                (select sum(tien) from @tblTienDSBH where thang = 4) as a_1_4,
                (select sum(tien) from @tblTienDSBH where thang = 5) as a_1_5,
                (select sum(tien) from @tblTienDSBH where thang = 6) as a_1_6,
                (select sum(tien) from @tblTienDSBH where thang = 7) as a_1_7,
                (select sum(tien) from @tblTienDSBH where thang = 8) as a_1_8,
                (select sum(tien) from @tblTienDSBH where thang = 9) as a_1_9,
                (select sum(tien) from @tblTienDSBH where thang = 10) as a_1_10,
                (select sum(tien) from @tblTienDSBH where thang = 11) as a_1_11,
                (select sum(tien) from @tblTienDSBH where thang = 12) as a_1_12,
	            @a_1BS1_1 AS a_1BS1_1,
                @a_2_1 AS a_2_1,
                @a_2BS1_1 AS a_2BS1_1,
                @a_2BS2_1 AS a_2BS2_1,
                @a_2BS3_1 AS a_2BS3_1,
                @a_3_1 AS a_3_1,
                @b_1_1 AS b_1_1,
                @b_2_1 AS b_2_1,
                @b_3_1 AS b_3_1,
                @b_4_1 AS b_4_1,
                @b_5_1 AS b_5_1,
                @b_6_1 AS b_6_1,
                @b_7_1 AS b_7_1,
                @b_8_1 AS b_8_1,
                @b_9_1 AS b_9_1,
                @b_9BS1_1 AS b_9BS1_1,
                @b_10_1 AS b_10_1,
                @b_10BS1_1 AS b_10BS1_1,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 1) AS b_11_1,
                @b_12_1 AS b_12_1,
                @b_13_1 AS b_13_1,
                @a_1BS1_2 AS a_1BS1_2,
                @a_2_2 AS a_2_2,
                @a_2BS1_2 AS a_2BS1_2,
                @a_2BS2_2 AS a_2BS2_2,
                @a_2BS3_2 AS a_2BS3_2,
                @a_3_2 AS a_3_2,
                @b_1_2 AS b_1_2,
                @b_2_2 AS b_2_2,
                @b_3_2 AS b_3_2,
                @b_4_2 AS b_4_2,
                @b_5_2 AS b_5_2,
                @b_6_2 AS b_6_2,
                @b_7_2 AS b_7_2,
                @b_8_2 AS b_8_2,
                @b_9_2 AS b_9_2,
                @b_9BS1_2 AS b_9BS1_2,
                @b_10_2 AS b_10_2,
                @b_10BS1_2 AS b_10BS1_2,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 2) AS b_11_2,
                @b_12_2 AS b_12_2,
                @b_13_2 AS b_13_2,
                @a_1BS1_3 AS a_1BS1_3,
                @a_2_3 AS a_2_3,
                @a_2BS1_3 AS a_2BS1_3,
                @a_2BS2_3 AS a_2BS2_3,
                @a_2BS3_3 AS a_2BS3_3,
                @a_3_3 AS a_3_3,
                @b_1_3 AS b_1_3,
                @b_2_3 AS b_2_3,
                @b_3_3 AS b_3_3,
                @b_4_3 AS b_4_3,
                @b_5_3 AS b_5_3,
                @b_6_3 AS b_6_3,
                @b_7_3 AS b_7_3,
                @b_8_3 AS b_8_3,
                @b_9_3 AS b_9_3,
                @b_9BS1_3 AS b_9BS1_3,
                @b_10_3 AS b_10_3,
                @b_10BS1_3 AS b_10BS1_3,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 3) AS b_11_3,
                @b_12_3 AS b_12_3,
                @b_13_3 AS b_13_3,
                @a_1BS1_4 AS a_1BS1_4,
                @a_2_4 AS a_2_4,
                @a_2BS1_4 AS a_2BS1_4,
                @a_2BS2_4 AS a_2BS2_4,
                @a_2BS3_4 AS a_2BS3_4,
                @a_3_4 AS a_3_4,
                @b_1_4 AS b_1_4,
                @b_2_4 AS b_2_4,
                @b_3_4 AS b_3_4,
                @b_4_4 AS b_4_4,
                @b_5_4 AS b_5_4,
                @b_6_4 AS b_6_4,
                @b_7_4 AS b_7_4,
                @b_8_4 AS b_8_4,
                @b_9_4 AS b_9_4,
                @b_9BS1_4 AS b_9BS1_4,
                @b_10_4 AS b_10_4,
                @b_10BS1_4 AS b_10BS1_4,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 4) AS b_11_4,
                @b_12_4 AS b_12_4,
                @b_13_4 AS b_13_4,
                @a_1BS1_5 AS a_1BS1_5,
                @a_2_5 AS a_2_5,
                @a_2BS1_5 AS a_2BS1_5,
                @a_2BS2_5 AS a_2BS2_5,
                @a_2BS3_5 AS a_2BS3_5,
                @a_3_5 AS a_3_5,
                @b_1_5 AS b_1_5,
                @b_2_5 AS b_2_5,
                @b_3_5 AS b_3_5,
                @b_4_5 AS b_4_5,
                @b_5_5 AS b_5_5,
                @b_6_5 AS b_6_5,
                @b_7_5 AS b_7_5,
                @b_8_5 AS b_8_5,
                @b_9_5 AS b_9_5,
                @b_9BS1_5 AS b_9BS1_5,
                @b_10_5 AS b_10_5,
                @b_10BS1_5 AS b_10BS1_5,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 5) AS b_11_5,
                @b_12_5 AS b_12_5,
                @b_13_5 AS b_13_5,

	            @a_1BS1_6 AS a_1BS1_6,
                @a_2_6 AS a_2_6,
                @a_2BS1_6 AS a_2BS1_6,
                @a_2BS2_6 AS a_2BS2_6,
                @a_2BS3_6 AS a_2BS3_6,
                @a_3_6 AS a_3_6,
                @b_1_6 AS b_1_6,
                @b_2_6 AS b_2_6,
                @b_3_6 AS b_3_6,
                @b_4_6 AS b_4_6,
                @b_5_6 AS b_5_6,
                @b_6_6 AS b_6_6,
                @b_7_6 AS b_7_6,
                @b_8_6 AS b_8_6,
                @b_9_6 AS b_9_6,
                @b_9BS1_6 AS b_9BS1_6,
                @b_10_6 AS b_10_6,
                @b_10BS1_6 AS b_10BS1_6,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 6) AS b_11_6,
                @b_12_6 AS b_12_6,
                @b_13_6 AS b_13_6,
                @a_1BS1_7 AS a_1BS1_7,
                @a_2_7 AS a_2_7,
                @a_2BS1_7 AS a_2BS1_7,
                @a_2BS2_7 AS a_2BS2_7,
                @a_2BS3_7 AS a_2BS3_7,
                @a_3_7 AS a_3_7,
                @b_1_7 AS b_1_7,
                @b_2_7 AS b_2_7,
                @b_3_7 AS b_3_7,
                @b_4_7 AS b_4_7,
                @b_5_7 AS b_5_7,
                @b_6_7 AS b_6_7,
                @b_7_7 AS b_7_7,
                @b_8_7 AS b_8_7,
                @b_9_7 AS b_9_7,
                @b_9BS1_7 AS b_9BS1_7,
                @b_10_7 AS b_10_7,
                @b_10BS1_7 AS b_10BS1_7,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 7) AS b_11_7,
                @b_12_7 AS b_12_7,
                @b_13_7 AS b_13_7,
                @a_1BS1_8 AS a_1BS1_8,
                @a_2_8 AS a_2_8,
                @a_2BS1_8 AS a_2BS1_8,
                @a_2BS2_8 AS a_2BS2_8,
                @a_2BS3_8 AS a_2BS3_8,
                @a_3_8 AS a_3_8,
                @b_1_8 AS b_1_8,
                @b_2_8 AS b_2_8,
                @b_3_8 AS b_3_8,
                @b_4_8 AS b_4_8,
                @b_5_8 AS b_5_8,
                @b_6_8 AS b_6_8,
                @b_7_8 AS b_7_8,
                @b_8_8 AS b_8_8,
                @b_9_8 AS b_9_8,
                @b_9BS1_8 AS b_9BS1_8,
                @b_10_8 AS b_10_8,
                @b_10BS1_8 AS b_10BS1_8,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 8) AS b_11_8,
                @b_12_8 AS b_12_8,
                @b_13_8 AS b_13_8,
                @a_1BS1_9 AS a_1BS1_9,
                @a_2_9 AS a_2_9,
                @a_2BS1_9 AS a_2BS1_9,
                @a_2BS2_9 AS a_2BS2_9,
                @a_2BS3_9 AS a_2BS3_9,
                @a_3_9 AS a_3_9,
                @b_1_9 AS b_1_9,
                @b_2_9 AS b_2_9,
                @b_3_9 AS b_3_9,
                @b_4_9 AS b_4_9,
                @b_5_9 AS b_5_9,
                @b_6_9 AS b_6_9,
                @b_7_9 AS b_7_9,
                @b_8_9 AS b_8_9,
                @b_9_9 AS b_9_9,
                @b_9BS1_9 AS b_9BS1_9,
                @b_10_9 AS b_10_9,
                @b_10BS1_9 AS b_10BS1_9,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 9) AS b_11_9,
                @b_12_9 AS b_12_9,
                @b_13_9 AS b_13_9,
                @a_1BS1_10 AS a_1BS1_10,
                @a_2_10 AS a_2_10,
                @a_2BS1_10 AS a_2BS1_10,
                @a_2BS2_10 AS a_2BS2_10,
                @a_2BS3_10 AS a_2BS3_10,
                @a_3_10 AS a_3_10,
                @b_1_10 AS b_1_10,
                @b_2_10 AS b_2_10,
                @b_3_10 AS b_3_10,
                @b_4_10 AS b_4_10,
                @b_5_10 AS b_5_10,
                @b_6_10 AS b_6_10,
                @b_7_10 AS b_7_10,
                @b_8_10 AS b_8_10,
                @b_9_10 AS b_9_10,
                @b_9BS1_10 AS b_9BS1_10,
                @b_10_10 AS b_10_10,
                @b_10BS1_10 AS b_10BS1_10,
                (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 10) AS b_11_10,
                @b_12_10 AS b_12_10,
	            @b_13_10 AS b_13_10,
	            @a_1BS1_11 AS a_1BS1_11,
	            @a_2_11 AS a_2_11,
	            @a_2BS1_11 AS a_2BS1_11,
	            @a_2BS2_11 AS a_2BS2_11,
	            @a_2BS3_11 AS a_2BS3_11,
	            @a_3_11 AS a_3_11,
	            @b_1_11 AS b_1_11,
	            @b_2_11 AS b_2_11,
	            @b_3_11 AS b_3_11,
	            @b_4_11 AS b_4_11,
	            @b_5_11 AS b_5_11,
	            @b_6_11 AS b_6_11,
	            @b_7_11 AS b_7_11,
	            @b_8_11 AS b_8_11,
	            @b_9_11 AS b_9_11,
	            @b_9BS1_11 AS b_9BS1_11,
	            @b_10_11 AS b_10_11,
	            @b_10BS1_11 AS b_10BS1_11,
	            (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 11) AS b_11_11,
	            @b_12_11 AS b_12_11,
	            @b_13_11 AS b_13_11,
	            @a_1BS1_12 AS a_1BS1_12,
	            @a_2_12 AS a_2_12,
	            @a_2BS1_12 AS a_2BS1_12,
	            @a_2BS2_12 AS a_2BS2_12,
	            @a_2BS3_12 AS a_2BS3_12,
	            @a_3_12 AS a_3_12,
	            @b_1_12 AS b_1_12,
	            @b_2_12 AS b_2_12,
	            @b_3_12 AS b_3_12,
	            @b_4_12 AS b_4_12,
	            @b_5_12 AS b_5_12,
	            @b_6_12 AS b_6_12,
	            @b_7_12 AS b_7_12,
	            @b_8_12 AS b_8_12,
	            @b_9_12 AS b_9_12,
	            @b_9BS1_12 AS b_9BS1_12,
	            @b_10_12 AS b_10_12,
	            @b_10BS1_12 AS b_10BS1_12,
	            (SELECT SUM(tien) FROM @tblHoaHong WHERE thang = 12) AS b_11_12,
	            @b_12_12 AS b_12_12,
	            @b_13_12 AS b_13_12
		"
        , nam
        , xuong
        );

        //throw new ArgumentNullException(sql);
        return sql;
    }
}