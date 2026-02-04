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

public partial class PrintControllers_InInvoice_InSPDT : System.Web.UI.Page
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

        string nameTemp = "(CT) Shipping details.xls";
        string nameRpt = "Shipping details";
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
        foreach (DataRow row in tbl.Rows)
        {

        }
    }

    public string CreateSql(HttpContext context)
    {
        var id = context.Request.QueryString["c_packinglist_id"];
        var sql = $@"	 
            select
	            N'{Public.tenTaiKhoanNoTA}' as cp_name,
	            N'{Public.diaChiNoTA}' as cp_add,
                N'{Public.tenTaiKhoanNo}' as cp_name_vn,
	            N'{Public.masothueNo}' as mst,
	            dh.amount as trigia,
	            pay.ten_paymentterm as hinhthucthanhtoan
            from c_packinginvoice dh
	            left join md_paymentterm pay on pay.md_paymentterm_id = dh.md_paymentterm_id 
            where
	            dh.shipmenttime between @tungay and @denngay
                and dh.md_trangthai_id != 'SOANTHAO'
            order by
	            dh.shipmenttime, dh.sochungtu
		";

        return sql;
    }
}
