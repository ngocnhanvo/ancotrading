using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using NPOI.HSSF.Util;
using System.Linq;

public partial class PrintControllers_0BaoCaoKH_rpt_DoanhSoTungKHTheoNCCtrenHH : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "", tungay = "", denngay = "", khachhang = "", baocaotheo = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        tungay = context.Request.QueryString["startdate"];
        denngay = context.Request.QueryString["enddate"];
        khachhang = context.Request.QueryString["doitackinhdoanh_id"];
        baocaotheo = context.Request.QueryString["baocaotheo"];
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(GD) Báo cáo từng khách hàng theo ncu trên hệ hàng.xls";
        string nameRpt = "Báo cáo từng khách hàng theo ncu trên hệ hàng ("+ baocaotheo +")";
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
        var tbl = ((DataSet)ReportViewer1.Report.DataSource).Tables[0];

        tbl.Columns.Add("tongtien", Type.GetType("System.Decimal"));
        tbl.Columns.Add("homnay", Type.GetType("System.String"));
        tbl.Columns.Add("tungay", Type.GetType("System.String"));
        tbl.Columns.Add("denngay", Type.GetType("System.String"));

        int lastRow = tbl.Rows.Count - 1;
        string khPrev = "";
        int number = 1;
        foreach (DataRow row in tbl.Rows)
        {
            row["homnay"] = DateTime.Now.ToString("dd/MM/yyyy");
            row["tungay"] = tungay;
            row["denngay"] = denngay;

            var kh = row["kh"].ToString();
            var tongtien = (row["anco1"] as decimal?) + (row["anco2"] as decimal?) + (row["anbinh"] as decimal?) + (row["vinhgia"] as decimal?) + (row["naman"] as decimal?);
            if (kh != khPrev)
            {
                row["Number"] = number;
                number++;
                row["tongtien"] = tbl.AsEnumerable().Where(s=>s.Field<string>("kh") == kh).Sum(s => 
                    s.Field<decimal?>("anco1").GetValueOrDefault(0) + s.Field<decimal?>("anco2").GetValueOrDefault(0) + 
                    s.Field<decimal?>("anbinh").GetValueOrDefault(0) + s.Field<decimal?>("vinhgia").GetValueOrDefault(0) + 
                    s.Field<decimal?>("naman").GetValueOrDefault(0)
                    );

                khPrev = kh;
            }
        }
    }

    public string CreateSql(HttpContext context)
    {
        string sql = string.Format(@"	 
            declare @tungay datetime = convert(datetime, N'{0} 00:00:00', 103)
            declare @denngay datetime = convert(datetime, N'{1} 23:59:59', 103)

            declare @tbl table (codeCL nvarchar(32), khId nvarchar(32), tien decimal(18,2), nccId nvarchar(32), nccVal nvarchar(32))

            insert into @tbl
            select 
	            cl.code_cl, 
	            civ.md_doitackinhdoanh_id,
	            sum(cdiv.thanhtien) as thanhtien,
	            cdiv.nhacungungid,
	            ncc.ma_dtkd
	            from c_packinginvoice civ, c_dongpklinv cdiv, md_sanpham sp, md_chungloai cl, md_doitackinhdoanh ncc
	            where civ.c_packinginvoice_id = cdiv.c_packinginvoice_id
			            and cdiv.md_sanpham_id = sp.md_sanpham_id
			            and sp.md_chungloai_id = cl.md_chungloai_id
			            and cdiv.nhacungungid = ncc.md_doitackinhdoanh_id
			            and civ.md_trangthai_id = 'HIEULUC'
			            and civ.ngay_motokhai >= @tungay
			            and civ.ngay_motokhai <= @denngay
                        and civ.md_doitackinhdoanh_id like N'%{2}%'
                        and cl.code_cl in (51,52,62,66,65,74)
	            group by cl.code_cl, civ.md_doitackinhdoanh_id, cdiv.nhacungungid, ncc.ma_dtkd

            select a.*
            from (
                select 
	                1 as Number, a.codeCL, kh.ma_dtkd as kh, qg.ten_quocgia as qg, 
	                (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'ANCO1') as anco1, 
	                (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'ANCO2') as anco2,
	                (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'ANBINH') as anbinh, 
	                (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'VINHGIA') as vinhgia,
	                (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'NAMAN') as naman
                from @tbl a
                left join md_doitackinhdoanh kh on a.khId = kh.md_doitackinhdoanh_id
                left join md_quocgia qg on kh.md_quocgia_id = qg.md_quocgia_id
            )a
            order by a.kh, a.codeCL
		"
        , tungay
        , denngay
        , string.IsNullOrWhiteSpace(khachhang) ? "%" : khachhang
        );

        if(baocaotheo == "PO")
        {
            sql = string.Format(@"	 
                declare @tungay datetime = convert(datetime, N'{0} 00:00:00', 103)
                declare @denngay datetime = convert(datetime, N'{1} 23:59:59', 103)

                declare @tbl table (codeCL nvarchar(32), khId nvarchar(32), tien decimal(18,2), nccId nvarchar(32), nccVal nvarchar(32))

                insert into @tbl
                select 
	                cl.code_cl, 
	                civ.md_doitackinhdoanh_id,
	                sum(cdiv.giafob * cdiv.soluong - cdiv.giafob * cdiv.soluong * civ.discount / 100) as thanhtien,
	                cdiv.nhacungungid,
	                ncc.ma_dtkd
	                from c_donhang civ, c_dongdonhang cdiv, md_sanpham sp, md_chungloai cl, md_doitackinhdoanh ncc
	                where civ.c_donhang_id = cdiv.c_donhang_id
			                and cdiv.md_sanpham_id = sp.md_sanpham_id
			                and sp.md_chungloai_id = cl.md_chungloai_id
			                and cdiv.nhacungungid = ncc.md_doitackinhdoanh_id
			                and civ.md_trangthai_id = 'HIEULUC'
			                and civ.shipmenttime >= @tungay
			                and civ.shipmenttime <= @denngay
                            and civ.md_doitackinhdoanh_id like N'%{2}%'
	                group by cl.code_cl, civ.md_doitackinhdoanh_id, cdiv.nhacungungid, ncc.ma_dtkd

                select a.*
                from (
                    select 
	                    1 as Number, a.codeCL, kh.ma_dtkd as kh, qg.ten_quocgia as qg, 
	                    (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'ANCO1') as anco1, 
	                    (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'ANCO2') as anco2,
	                    (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'ANBINH') as anbinh, 
	                    (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'VINHGIA') as vinhgia,
	                    (select sum(tien) from @tbl where codeCL = a.codeCL and khId = a.khId and nccVal = 'NAMAN') as naman
                    from @tbl a
                    left join md_doitackinhdoanh kh on a.khId = kh.md_doitackinhdoanh_id
                    left join md_quocgia qg on kh.md_quocgia_id = qg.md_quocgia_id
                )a
                order by a.kh, a.codeCL
		    "
            , tungay
            , denngay
            , string.IsNullOrWhiteSpace(khachhang) ? "%" : khachhang
            );
        }
        //throw new ArgumentNullException(sql);
        return sql;
    }
}
