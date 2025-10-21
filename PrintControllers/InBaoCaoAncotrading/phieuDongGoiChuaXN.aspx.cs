using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_InBaoCaoAncotrading_phieuDongGoiChuaXN : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        string nameTemp = "(KH) Phiếu đóng gói chưa xác nhận.xls";
        string nameRpt = "(KH) Phiếu đóng gói chưa xác nhận";
        string sql = CreateSql(context);

        inPDF = "2";
        var task = new System.Threading.Tasks.Task(() =>
        {
            viewReport(sql);
        });

        var download = Request.QueryString["download"].removeAllSpaceOrTrimText(true);
        ReportViewer1.Attributes["download"] = string.IsNullOrWhiteSpace(download) ? "1" : download;
        PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, true);
    }

    public void viewReport(String SqlQuery)
    {

    }

    public string CreateSql(HttpContext context)
    {
        string id = context.Request.QueryString["id"];
        string manv = context.User.Identity.Name.removeAllSpaceOrTrimText(true);
        string companyName = Public.tenTaiKhoanNoTA;
        string companyAdd = Public.diaChiNoTA;
        string tel = Public.sdtTaiKhoanNo;
        string fax = Public.faxTaiKhoanNo;
        string email = Public.emailTaiKhoanNo;
        string sql = $@"	 
            declare @dsdhid varchar(32) = '{id}'; 
            select distinct
	            dg.ma_donggoi, 
                dg.sl_inner, 
			    (select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_inner) as [DVTInner], 
			    dg.l1,
                dg.w1,
                dg.h1, 
                dg.sl_outer, 
			    (select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_outer) as [DVTOuter], 
			    dg.l2_mix, 
                dg.w2_mix, 
                dg.h2_mix,
                dg.v2,
			    dg.soluonggoi_ctn_20, 
                dg.soluonggoi_ctn, 
                dg.soluonggoi_ctn_40hc,
			    null as ngayxacnhan,
                dg.mota, 
                dg.tldg, 
                dg.cpdg
            from c_dongdsdh dh
            left join md_donggoi dg on dg.md_donggoi_id = dh.md_donggoi_id
            where 
	            dh.c_danhsachdathang_id = @dsdhid
	            and dg.ngayxacnhan is null
            order by
	            dg.ma_donggoi
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}