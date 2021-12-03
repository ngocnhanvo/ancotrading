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

public partial class PrintControllers_0BaoCaoNCU_rpt_DoanhSoNCUTheoTungThang : System.Web.UI.Page
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

        string nameTemp = "(GD) Báo cáo doanh số ncu theo từng tháng.xls";
        string nameRpt = "Báo cáo doanh số ncu theo từng tháng ("+ baocaotheo +")";
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

        tbl.Columns.Add("homnay", Type.GetType("System.String"));
        tbl.Columns.Add("tungay", Type.GetType("System.String"));
        tbl.Columns.Add("denngay", Type.GetType("System.String"));

        int lastRow = tbl.Rows.Count - 1;

        foreach (DataRow row in tbl.Rows)
        {
            row["homnay"] = DateTime.Now.ToString("dd/MM/yyyy");
            row["tungay"] = tungay;
            row["denngay"] = denngay;
        }
    }

    public string CreateSql(HttpContext context)
    {
        string sql = string.Format(@"	 
            declare @tungay datetime = convert(datetime, N'{0} 00:00:00', 103)
            declare @denngay datetime = convert(datetime, N'{1} 23:59:59', 103)

            declare @tbl table (codeCL nvarchar(32), khId nvarchar(32), tien decimal(18,2), nccId nvarchar(32), nccVal nvarchar(32), thang int)

            insert into @tbl
            select 
	            cl.code_cl, 
	            civ.md_doitackinhdoanh_id,
	            sum(isnull(cdiv.thanhtien, 0)) as thanhtien,
	            cdiv.nhacungungid,
	            ncc.ma_dtkd,
                DATEPART(MONTH, civ.ngay_motokhai) as thang
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
	            group by cl.code_cl, civ.md_doitackinhdoanh_id, cdiv.nhacungungid, ncc.ma_dtkd, civ.ngay_motokhai
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

                declare @tbl table (codeCL nvarchar(32), khId nvarchar(32), tien decimal(18,2), nccId nvarchar(32), nccVal nvarchar(32), thang int)

                insert into @tbl
                select 
	                cl.code_cl, 
	                civ.md_doitackinhdoanh_id,
	                sum(cdiv.giafob * cdiv.soluong - cdiv.giafob * cdiv.soluong * isnull(civ.discount, 0) / 100) as thanhtien,
	                cdiv.nhacungungid,
	                ncc.ma_dtkd,
                    DATEPART(MONTH, civ.shipmenttime) as thang
	            from c_donhang civ, c_dongdonhang cdiv, md_sanpham sp, md_chungloai cl, md_doitackinhdoanh ncc
	                where civ.c_donhang_id = cdiv.c_donhang_id
			                and cdiv.md_sanpham_id = sp.md_sanpham_id
			                and sp.md_chungloai_id = cl.md_chungloai_id
			                and cdiv.nhacungungid = ncc.md_doitackinhdoanh_id
			                and civ.md_trangthai_id = 'HIEULUC'
			                and civ.shipmenttime >= @tungay
			                and civ.shipmenttime <= @denngay
                            and civ.md_doitackinhdoanh_id like N'%{2}%'
	                group by cl.code_cl, civ.md_doitackinhdoanh_id, cdiv.nhacungungid, ncc.ma_dtkd, civ.shipmenttime
		    "
            , tungay
            , denngay
            , string.IsNullOrWhiteSpace(khachhang) ? "%" : khachhang
            );
        }

        sql += @"
            select
	            (select sum(tien) from @tbl where thang = 1 and nccVal = 'ANCO1') as [anco1_t1], 
	            (select sum(tien) from @tbl where thang = 2 and nccVal = 'ANCO1') as [anco1_t2], 
	            (select sum(tien) from @tbl where thang = 3 and nccVal = 'ANCO1') as [anco1_t3], 
	            (select sum(tien) from @tbl where thang = 4 and nccVal = 'ANCO1') as [anco1_t4], 
	            (select sum(tien) from @tbl where thang = 5 and nccVal = 'ANCO1') as [anco1_t5], 
                (select sum(tien) from @tbl where thang = 6 and nccVal = 'ANCO1') as [anco1_t6],
                (select sum(tien) from @tbl where thang = 7 and nccVal = 'ANCO1') as [anco1_t7],
                (select sum(tien) from @tbl where thang = 8 and nccVal = 'ANCO1') as [anco1_t8],
                (select sum(tien) from @tbl where thang = 9 and nccVal = 'ANCO1') as [anco1_t9],
                (select sum(tien) from @tbl where thang = 10 and nccVal = 'ANCO1') as [anco1_t10],
                (select sum(tien) from @tbl where thang = 11 and nccVal = 'ANCO1') as [anco1_t11],
                (select sum(tien) from @tbl where thang = 12 and nccVal = 'ANCO1') as [anco1_t12],

	            (select sum(tien) from @tbl where thang = 1 and nccVal = 'ANCO2') as [anco2_t1], 
	            (select sum(tien) from @tbl where thang = 2 and nccVal = 'ANCO2') as [anco2_t2], 
	            (select sum(tien) from @tbl where thang = 3 and nccVal = 'ANCO2') as [anco2_t3], 
	            (select sum(tien) from @tbl where thang = 4 and nccVal = 'ANCO2') as [anco2_t4], 
	            (select sum(tien) from @tbl where thang = 5 and nccVal = 'ANCO2') as [anco2_t5], 
                (select sum(tien) from @tbl where thang = 6 and nccVal = 'ANCO2') as [anco2_t6],
                (select sum(tien) from @tbl where thang = 7 and nccVal = 'ANCO2') as [anco2_t7],
                (select sum(tien) from @tbl where thang = 8 and nccVal = 'ANCO2') as [anco2_t8],
                (select sum(tien) from @tbl where thang = 9 and nccVal = 'ANCO2') as [anco2_t9],
                (select sum(tien) from @tbl where thang = 10 and nccVal = 'ANCO2') as [anco2_t10],
                (select sum(tien) from @tbl where thang = 11 and nccVal = 'ANCO2') as [anco2_t11],
                (select sum(tien) from @tbl where thang = 12 and nccVal = 'ANCO2') as [anco2_t12],

	            (select sum(tien) from @tbl where thang = 1 and nccVal = 'ANBINH') as [anbinh_t1], 
	            (select sum(tien) from @tbl where thang = 2 and nccVal = 'ANBINH') as [anbinh_t2], 
	            (select sum(tien) from @tbl where thang = 3 and nccVal = 'ANBINH') as [anbinh_t3], 
	            (select sum(tien) from @tbl where thang = 4 and nccVal = 'ANBINH') as [anbinh_t4], 
	            (select sum(tien) from @tbl where thang = 5 and nccVal = 'ANBINH') as [anbinh_t5], 
                (select sum(tien) from @tbl where thang = 6 and nccVal = 'ANBINH') as [anbinh_t6],
                (select sum(tien) from @tbl where thang = 7 and nccVal = 'ANBINH') as [anbinh_t7],
                (select sum(tien) from @tbl where thang = 8 and nccVal = 'ANBINH') as [anbinh_t8],
                (select sum(tien) from @tbl where thang = 9 and nccVal = 'ANBINH') as [anbinh_t9],
                (select sum(tien) from @tbl where thang = 10 and nccVal = 'ANBINH') as [anbinh_t10],
                (select sum(tien) from @tbl where thang = 11 and nccVal = 'ANBINH') as [anbinh_t11],
                (select sum(tien) from @tbl where thang = 12 and nccVal = 'ANBINH') as [anbinh_t12],

	            (select sum(tien) from @tbl where thang = 1 and nccVal = 'VINHGIA') as [vinhgia_t1], 
	            (select sum(tien) from @tbl where thang = 2 and nccVal = 'VINHGIA') as [vinhgia_t2], 
	            (select sum(tien) from @tbl where thang = 3 and nccVal = 'VINHGIA') as [vinhgia_t3], 
	            (select sum(tien) from @tbl where thang = 4 and nccVal = 'VINHGIA') as [vinhgia_t4], 
	            (select sum(tien) from @tbl where thang = 5 and nccVal = 'VINHGIA') as [vinhgia_t5], 
                (select sum(tien) from @tbl where thang = 6 and nccVal = 'VINHGIA') as [vinhgia_t6],
                (select sum(tien) from @tbl where thang = 7 and nccVal = 'VINHGIA') as [vinhgia_t7],
                (select sum(tien) from @tbl where thang = 8 and nccVal = 'VINHGIA') as [vinhgia_t8],
                (select sum(tien) from @tbl where thang = 9 and nccVal = 'VINHGIA') as [vinhgia_t9],
                (select sum(tien) from @tbl where thang = 10 and nccVal = 'VINHGIA') as [vinhgia_t10],
                (select sum(tien) from @tbl where thang = 11 and nccVal = 'VINHGIA') as [vinhgia_t11],
                (select sum(tien) from @tbl where thang = 12 and nccVal = 'VINHGIA') as [vinhgia_t12],

	            (select sum(tien) from @tbl where thang = 1 and nccVal = 'NAMAN') as [naman_t1], 
	            (select sum(tien) from @tbl where thang = 2 and nccVal = 'NAMAN') as [naman_t2], 
	            (select sum(tien) from @tbl where thang = 3 and nccVal = 'NAMAN') as [naman_t3], 
	            (select sum(tien) from @tbl where thang = 4 and nccVal = 'NAMAN') as [naman_t4], 
	            (select sum(tien) from @tbl where thang = 5 and nccVal = 'NAMAN') as [naman_t5], 
                (select sum(tien) from @tbl where thang = 6 and nccVal = 'NAMAN') as [naman_t6],
                (select sum(tien) from @tbl where thang = 7 and nccVal = 'NAMAN') as [naman_t7],
                (select sum(tien) from @tbl where thang = 8 and nccVal = 'NAMAN') as [naman_t8],
                (select sum(tien) from @tbl where thang = 9 and nccVal = 'NAMAN') as [naman_t9],
                (select sum(tien) from @tbl where thang = 10 and nccVal = 'NAMAN') as [naman_t10],
                (select sum(tien) from @tbl where thang = 11 and nccVal = 'NAMAN') as [naman_t11],
                (select sum(tien) from @tbl where thang = 12 and nccVal = 'NAMAN') as [naman_t12]
        ";
        //throw new ArgumentNullException(sql);
        return sql;
    }
}
