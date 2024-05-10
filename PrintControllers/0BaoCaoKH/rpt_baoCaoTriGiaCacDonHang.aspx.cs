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

public partial class PrintControllers_0BaoCaoKH_rpt_baoCaoTriGiaCacDonHang : System.Web.UI.Page
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

        string nameTemp = "(GD) Báo cáo trị giá các đơn hàng.xls";
        string nameRpt = "Báo cáo trị giá các đơn hàng";
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
        
        foreach (DataRow row in tbl.Rows)
        {
            row["homnay"] = DateTime.Now.ToString("dd/MM/yyyy");
            row["tungay"] = tungay;
            row["denngay"] = denngay;
        }
    }

    public string CreateSql(HttpContext context)
    {
        var sql = string.Format(@"	 
            declare @tungay datetime = convert(datetime, N'{0} 00:00:00', 103)
            declare @denngay datetime = convert(datetime, N'{1} 23:59:59', 103)

            select
	            dh.sochungtu as donhang,
	            dh.shipmenttime as ngayxuat,
	            dh.amount as trigia,
	            pay.ten_paymentterm as hinhthucthanhtoan
            from c_donhang dh
	            left join md_paymentterm pay on pay.md_paymentterm_id = dh.md_paymentterm_id 
            where
	            dh.shipmenttime between @tungay and @denngay
                and dh.md_trangthai_id != 'SOANTHAO'
            order by
	            dh.shipmenttime, dh.sochungtu
		"
        , tungay
        , denngay
        );

        return sql;
    }
}
