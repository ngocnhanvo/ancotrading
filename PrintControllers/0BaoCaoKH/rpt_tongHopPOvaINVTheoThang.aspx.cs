using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_0BaoCaoKH_rpt_tongHopPOvaINVTheoThang : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        string nameTemp = "(KT) Tổng hợp PO và INV theo tháng.xls";
        string nameRpt = "Tổng hợp PO và INV theo tháng";
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
        string nam = context.Request.QueryString["startdate"];
        string thang = context.Request.QueryString["enddate"];
        var baocaotheo = context.Request.QueryString["baocaotheo"] == "IN";
        var dtkd = context.Request.QueryString["doitackinhdoanh_id"];
        var whereEx = "and dh.shipmenttime between @ngayBD and @ngayKT";
        if (baocaotheo)
            whereEx = "and inv.ngay_motokhai between @ngayBD and @ngayKT";
        if (!string.IsNullOrWhiteSpace(dtkd))
            whereEx += string.Format(@" and kh.md_doitackinhdoanh_id = '{0}'", dtkd);

        string sql = string.Format(@"	 
            declare @nam int = {0}
            declare @thang int = {1}
            declare @ngayBD datetime = convert(datetime, '01/'+ cast(@thang as varchar(2)) +'/'+ cast(@nam as varchar(4)) +' 00:00:00', 103)
            declare @ngayKT datetime = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@ngayBD)+1,0))
            
            select 
	            kh.ma_dtkd as maKH,
	            kh.ten_dtkd as tenKH,
	            dh.sochungtu as donhang,
	            dh.shipmenttime as ngaydh,
	            dh.amount as trigiadh,
	            0 as daxuat,
	            0 as conlai,
	            inv.so_inv as inv,
	            inv.ngay_motokhai as ngayinv,
	            inv.totalgross as trigiainv,
	            inv.tiendatcoc as coc,
	            inv.tiendatra as thanhtoan,
	            pm.ten_paymentterm as payment,
	            @nam as nam,
                @thang as thang
            from c_donhang dh
            left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh.md_doitackinhdoanh_id
            left join c_packinginvoice inv on inv.c_packinginvoice_id in (select c_packinginvoice_id from c_dongpklinv where c_donhang_id = dh.c_donhang_id) and inv.md_trangthai_id = 'HIEULUC'
            left join md_paymentterm pm on pm.md_paymentterm_id = dh.md_paymentterm_id
            where 
	            dh.md_trangthai_id = 'HIEULUC'
	            {2}
            order by
                dh.sochungtu
		"
        , nam
        , thang
        , whereEx
        );

        //throw new ArgumentNullException(sql);
        return sql;
    }
}