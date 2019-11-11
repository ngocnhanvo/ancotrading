using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraReports.UI;
using System.IO;

public partial class PrintControllers_InBL_Default : System.Web.UI.Page
{
    LinqDBDataContext db = new LinqDBDataContext();

    protected void Page_Load(object sender, EventArgs e)
    {
        String c_packinglist_id = Request.QueryString["c_packinglist_id"];
		String md_doitackinhdoanh_id = Request.QueryString["md_doitackinhdoanh_id"];
        rptBL report = new rptBL();
        this.viewReport(report, getSql(c_packinglist_id, md_doitackinhdoanh_id));
    }

    public string getSql(string c_packinglist_id, string md_doitackinhdoanh_id)
    {
		String selDH = @"select distinct dh.sochungtu from c_dongpklinv dpkl, c_donhang dh where dpkl.c_donhang_id = dh.c_donhang_id AND dpkl.c_packinginvoice_id = @c_packinginvoice_id";
        DataTable dtDonHang = mdbc.GetData(selDH, "@c_packinginvoice_id", c_packinglist_id);
        String dsDonHang = "";
        foreach (DataRow item in dtDonHang.Rows)
        {
            dsDonHang += String.Format(", {0}", item[0].ToString());
        }
        
        dsDonHang = dsDonHang.Substring(2);
		
        String select = "select *, N'"+ dsDonHang + @"' as dsdonhang from dbo.f_taobanginbl('" + c_packinglist_id + "','" + md_doitackinhdoanh_id + "')";
        return select;
    }

    public void viewReport(XtraReport report, String SqlQuery)
    {
        SqlDataAdapter da = new SqlDataAdapter(SqlQuery, mdbc.GetConnection);
        DataSet ds = new DataSet();
        da.Fill(ds);
        report.DataSource = ds;
        report.DataAdapter = da;

        MemoryStream exportData = new MemoryStream();
        report.ExportToXls(exportData);

        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", "BL-" + DateTime.Now.ToString("ddMMyyyy") + ".xls"));
        Response.Clear();
        Response.BinaryWrite(exportData.GetBuffer());
        Response.End();
    }
}