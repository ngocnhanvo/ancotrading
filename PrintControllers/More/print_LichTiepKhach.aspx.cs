using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_More_print_LichTiepKhach : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(NV) Lịch Tiếp Khách.xls";
        string nameRpt = "Lịch Tiếp Khách";
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
        
    }

    public string CreateSql(HttpContext context)
    {
        string tungay = context.Request.QueryString["tungay"];
        string denngay = context.Request.QueryString["denngay"];

        string sql = string.Format(@"	 
            declare @tungay datetime = convert(datetime, N'{0}', 103)
            declare @denngay datetime = convert(datetime, N'{1}', 103)

            select 
                N'{0}' as tungay,
                N'{1}' as denngay,
                nv.hoten as nguoidenghi,
	            ltk.*
            from md_lichtiepkhach ltk
            left join nhanvien nv on ltk.nguoitao = nv.manv
            where ltk.ngay between @tungay and @denngay
            order by ltk.ngay
		"
        , tungay
        , denngay
        );

        return sql;
    }
}