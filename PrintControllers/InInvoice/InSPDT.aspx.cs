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
                N'{Public.diaChiNo}' as cp_add_vn,
	            N'{Public.masothueNo}' as mst,
                null as so_cont,
                null as so_kien,
                null as dvt_kien,
                null as so_kg,
                null as so_cbm,
                null as hscode_cont,
                dinv.c_dongpklinv_id
            from c_packinginvoice inv
                left join c_dongpklinv dinv on dinv.c_packinginvoice_id = inv.c_packinginvoice_id
            where
	            inv.c_packinginvoice_id in ('{id}')
		";

        return sql;
    }
}
