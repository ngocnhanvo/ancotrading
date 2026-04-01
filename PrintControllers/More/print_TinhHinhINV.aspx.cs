using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_More_print_TinhHinhINV : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(CT) Tình hình INV.xls";
        string nameRpt = "Báo cáo Tình hình INV";
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
        string id = context.Request.QueryString["id"];

        string sql = @"	 
            select 
	            dtkd.ma_dtkd as maKH,
	            inv.so_inv as soINV,
	            inv.ngay_motokhai as ngayMTK,
	            dh.sodh as po,
	            inv.totalgross as tt_inv,
	            inv.tiendatcoc as datcoc,
	            inv.tiendatra as datra,
	            chi.tienchi as dachi
            from c_packinginvoice inv
	            left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = inv.md_doitackinhdoanh_id
	            OUTER APPLY dbo.LayChungTuDonHang_table(inv.c_packinginvoice_id) dh
                CROSS APPLY (
                    SELECT COALESCE(SUM(cttc.sotien), 0) AS tienchi
                    FROM c_chitietthuchi cttc
		            left join c_thuchi tc on tc.c_thuchi_id = cttc.c_thuchi_id
                    WHERE c_packinginvoice_id = inv.c_packinginvoice_id and tc.ispaymentin = 0 and tc.md_trangthai_id = 'HIEULUC'
                ) chi
            where inv.tienconlai > 0
             and inv.md_trangthai_id = 'HIEULUC'
            order by inv.ngay_motokhai asc
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}