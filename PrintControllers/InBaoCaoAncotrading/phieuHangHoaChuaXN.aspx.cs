using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_InBaoCaoAncotrading_phieuHangHoaChuaXN : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        string nameTemp = "(KH) Phiếu hàng hóa chưa xác nhận.xls";
        string nameRpt = "(KH) Phiếu hàng hóa chưa xác nhận";
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
	            sp.ma_sanpham,
                sp.mota_tiengviet,
                sp.mota_tienganh,
                kd.ten_tv as tenkd,
                cn.ten_tv as tencn,
                kd.ma_kieudang,
                cn.ma_chucnang,
                (select dvtsp.ten_dvt from md_donvitinhsanpham dvtsp where dvtsp.md_donvitinhsanpham_id = sp.md_donvitinhsanpham_id) as dvt,
                l_cm as l, 
                w_cm as w, 
                h_cm as h,
                sp.trongluong, 
                sp.dientich, 
                sp.thetich,
                (select nhom from md_nhomnangluc nnl where nnl.md_nhomnangluc_id = sp.md_nhomnangluc_id) as nnl,
                cb.ma_cangbien,
                dtkd.ma_dtkd as ncc,
                hscode.ma_hscode,
                sp.chucnangsp,
                sp.ngayxacnhan,
                sp.hinhthucban
            from c_dongdsdh dh
                left join md_sanpham sp on sp.md_sanpham_id = dh.md_sanpham_id
                left join md_doitackinhdoanh dtkd on sp.nhacungung = dtkd.md_doitackinhdoanh_id
                left join md_donggoisanpham dgsp on dgsp.md_sanpham_id = sp.md_sanpham_id
				left join md_donggoi dg on dg.md_donggoi_id = dgsp.md_donggoi_id
				left join md_cangbien cb on sp.md_cangbien_id = cb.md_cangbien_id
                left join md_kieudang kd on sp.md_kieudang_id = kd.md_kieudang_id
				left join md_chucnang cn on sp.md_chucnang_id = cn.md_chucnang_id
				left join md_hscode hscode on sp.md_hscode_id = hscode.md_hscode_id
            where 
	            dh.c_danhsachdathang_id = @dsdhid
	            and sp.ngayxacnhan is null
            order by
	            sp.ma_sanpham
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}