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

        var nccVals = tbl.AsEnumerable().Select(s => s.Field<string>("nccVal")).Distinct().ToList();

        for (int i = 1; i <= 12; i++)
        {
            tbl.Columns.Add("tien_t" + i, Type.GetType("System.Decimal"));
        }

        var tblCopy = tbl.Copy();
        var lstTbl = tblCopy.AsEnumerable().ToList();
        nccVals = lstTbl.Select(s => s.Field<string>("nccVal")).Distinct().ToList();

        tbl.Rows.Clear();

        foreach (var nccVal in nccVals)
        {
            var rowTBL = tbl.NewRow();
            rowTBL["nccVal"] = nccVal;

            for (int i = 1; i <= 12; i++)
            {
                var tien = lstTbl.Where(s =>
                    s.Field<string>("nccVal") == nccVal & s.Field<int>("thang") == i).Sum(s => s.Field<decimal?>("tien").GetValueOrDefault(0));

                rowTBL["tien_t" + i] = tien;
            }

            tbl.Rows.Add(rowTBL);
        }

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
				a.code_cl,
				a.md_doitackinhdoanh_id,
				sum(a.thanhtien - a.thanhtien * a.discount / 100) as thanhtien,
				a.nhacungungid,
				a.ma_dtkd,
				a.thang
			from (
				select 
					cl.code_cl, 
					civ.md_doitackinhdoanh_id,
					isnull(cdiv.thanhtien, 0) as thanhtien,
					isnull((select top 1 dh.discount from c_donhang dh where dh.c_donhang_id = cdiv.c_donhang_id), 0) as discount,
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
			) a
			group by a.code_cl, a.md_doitackinhdoanh_id, a.nhacungungid, a.ma_dtkd, a.thang
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
                declare @tblOrder table(val nvarchar(MAX), ord int)

                insert @tblOrder
                select 'ANCO1', 1
                union select 'ANCO2', 2
                union select 'ANBINH', 3
                union select 'VINHGIA', 4
                union select 'NAMAN', 5

                select * from @tbl a
                order by isnull((select top 1 ord from @tblOrder where a.nccVal = val), 6)
            ";
        return sql;
    }
}
