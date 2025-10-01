using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Views_tienve_printTienVe : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(KT) Chiết xuất tiền về.xls";
        string nameRpt = "Chiết xuất tiền về";
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

    }

    public string CreateSql(HttpContext context)
    {
        string id = context.Request.QueryString["id"];
        string manv = context.User.Identity.Name.removeAllSpaceOrTrimText(true);
        string tungay = context.Request.QueryString["tungay"];
        string denngay = context.Request.QueryString["denngay"];
        string sql = $@"	 
            declare @tungay datetime = convert(datetime, '{tungay} 00:00:00', 103)
            declare @denngay datetime = convert(datetime, '{denngay} 23:59:59', 103)
            select 
	            tv.ngaygd,
	            tv.sothamchieu,
	            tv.sotienghino,
	            tv.sotienghico,
	            tv.mota,
                tv.mota2,
	            inv.tinv,
	            inv.sinv,
	            po.tpo,
	            po.sopo,
	            kh.ma_dtkd as khachhang
            from kt_tienve tv
            left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = tv.dtkd_id
            outer apply (
	            select 
		            sum(inv.st) as tinv, 
		            STUFF(
                    (SELECT ', ' + inv.sctlienquan
                     FROM kt_tienve_phanbo inv
                     WHERE inv.kt_tienve_id = tv.kt_tienve_id
                     AND inv.loaihd = 'IN'
                     FOR XML PATH('')), 1, 2, '') as sinv
	            from (
		            select inv.sotien + inv.phi as st, inv.sctlienquan
		            from kt_tienve_phanbo inv 
		            where inv.kt_tienve_id = tv.kt_tienve_id
		            and inv.loaihd = 'IN'
	            )inv
            ) inv
            outer apply (
	            select 
		            sum(po.st) as tpo,
		            STUFF((SELECT ', ' + po.sctlienquan
                     FROM kt_tienve_phanbo po
                     WHERE po.kt_tienve_id = tv.kt_tienve_id
                     AND po.loaihd = 'PO'
                     FOR XML PATH('')), 1, 2, '') AS sopo
	            from (
		            select po.sotien + po.phi as st, po.sctlienquan
		            from kt_tienve_phanbo po 
		            where po.kt_tienve_id = tv.kt_tienve_id
		            and po.loaihd = 'PO'
	            ) po
            ) po
            where
                1=1
                and tv.ngaygd between @tungay and @denngay
            order by
                tv.ngaygd desc, tv.sothamchieu
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}