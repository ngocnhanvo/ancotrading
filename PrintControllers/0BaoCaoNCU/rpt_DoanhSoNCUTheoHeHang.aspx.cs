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

public partial class PrintControllers_0BaoCaoNCU_rpt_DoanhSoNCUTheoHeHang : System.Web.UI.Page
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

        string nameTemp = "(GD) Báo cáo doanh số ncu theo hệ hàng.xls";
        string nameRpt = "Báo cáo doanh số ncu theo hệ hàng ("+ baocaotheo +")";
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

            declare @tbl table (codeCL nvarchar(32), khId nvarchar(32), tien decimal(18,2), nccId nvarchar(32), nccVal nvarchar(32))

            insert into @tbl
            select 
	            cl.code_cl, 
	            civ.md_doitackinhdoanh_id,
	            sum(isnull(cdiv.thanhtien, 0)) as thanhtien,
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
	            group by cl.code_cl, civ.md_doitackinhdoanh_id, cdiv.nhacungungid, ncc.ma_dtkd
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
	                sum(cdiv.giafob * cdiv.soluong - cdiv.giafob * cdiv.soluong * isnull(civ.discount, 0) / 100) as thanhtien,
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
                            and cl.code_cl in (51,52,62,66,65,74)
	                group by cl.code_cl, civ.md_doitackinhdoanh_id, cdiv.nhacungungid, ncc.ma_dtkd
		    "
            , tungay
            , denngay
            , string.IsNullOrWhiteSpace(khachhang) ? "%" : khachhang
            );
        }

        sql += @"
            select
	            (select sum(tien) from @tbl where codeCL = '51' and nccVal = 'ANCO1') as [anco1_51], 
	            (select sum(tien) from @tbl where codeCL = '52' and nccVal = 'ANCO1') as [anco1_52], 
	            (select sum(tien) from @tbl where codeCL = '62' and nccVal = 'ANCO1') as [anco1_62], 
	            (select sum(tien) from @tbl where codeCL = '66' and nccVal = 'ANCO1') as [anco1_66], 
	            (select sum(tien) from @tbl where codeCL = '65' and nccVal = 'ANCO1') as [anco1_65], 
                (select sum(tien) from @tbl where codeCL = '74' and nccVal = 'ANCO1') as [anco1_74],

	            (select sum(tien) from @tbl where codeCL = '51' and nccVal = 'ANCO2') as [anco2_51], 
	            (select sum(tien) from @tbl where codeCL = '52' and nccVal = 'ANCO2') as [anco2_52], 
	            (select sum(tien) from @tbl where codeCL = '62' and nccVal = 'ANCO2') as [anco2_62], 
	            (select sum(tien) from @tbl where codeCL = '66' and nccVal = 'ANCO2') as [anco2_66], 
	            (select sum(tien) from @tbl where codeCL = '65' and nccVal = 'ANCO2') as [anco2_65], 
                (select sum(tien) from @tbl where codeCL = '74' and nccVal = 'ANCO2') as [anco2_74],

	            (select sum(tien) from @tbl where codeCL = '51' and nccVal = 'ANBINH') as [anbinh_51], 
	            (select sum(tien) from @tbl where codeCL = '52' and nccVal = 'ANBINH') as [anbinh_52], 
	            (select sum(tien) from @tbl where codeCL = '62' and nccVal = 'ANBINH') as [anbinh_62], 
	            (select sum(tien) from @tbl where codeCL = '66' and nccVal = 'ANBINH') as [anbinh_66], 
	            (select sum(tien) from @tbl where codeCL = '65' and nccVal = 'ANBINH') as [anbinh_65], 
                (select sum(tien) from @tbl where codeCL = '74' and nccVal = 'ANBINH') as [anbinh_74],

	            (select sum(tien) from @tbl where codeCL = '51' and nccVal = 'VINHGIA') as [vinhgia_51], 
	            (select sum(tien) from @tbl where codeCL = '52' and nccVal = 'VINHGIA') as [vinhgia_52], 
	            (select sum(tien) from @tbl where codeCL = '62' and nccVal = 'VINHGIA') as [vinhgia_62], 
	            (select sum(tien) from @tbl where codeCL = '66' and nccVal = 'VINHGIA') as [vinhgia_66], 
	            (select sum(tien) from @tbl where codeCL = '65' and nccVal = 'VINHGIA') as [vinhgia_65], 
                (select sum(tien) from @tbl where codeCL = '74' and nccVal = 'VINHGIA') as [vinhgia_74],

	            (select sum(tien) from @tbl where codeCL = '51' and nccVal = 'NAMAN') as [naman_51], 
	            (select sum(tien) from @tbl where codeCL = '52' and nccVal = 'NAMAN') as [naman_52], 
	            (select sum(tien) from @tbl where codeCL = '62' and nccVal = 'NAMAN') as [naman_62], 
	            (select sum(tien) from @tbl where codeCL = '66' and nccVal = 'NAMAN') as [naman_66], 
	            (select sum(tien) from @tbl where codeCL = '65' and nccVal = 'NAMAN') as [naman_65], 
                (select sum(tien) from @tbl where codeCL = '74' and nccVal = 'NAMAN') as [naman_74]
        ";
        //throw new ArgumentNullException(sql);
        return sql;
    }
}
