using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_InBaoCaoAncotrading_phieuXNXH : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        string nameTemp = "(KH) Phiếu xác nhận xuất hàng.xls";
        string nameRpt = "Phiếu xác nhận xuất hàng";
        string sql = CreateSql(context);

        inPDF = "2";
        var task = new System.Threading.Tasks.Task(() =>
        {
            viewReport(sql);
        });

        ReportViewer1.Attributes["download"] = "1";
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
            declare @dsdh table (id nvarchar(32), sct nvarchar(100), ncuid nvarchar(32), dhid nvarchar(32), nghid nvarchar(32), ddhh nvarchar(MAX), chdk nvarchar(MAX))
            insert into @dsdh
            select c_danhsachdathang_id, sochungtu, md_doitackinhdoanh_id, c_donhang_id, diachigiaohang, huongdanlamhang, huongdanlamhangchung
            from c_danhsachdathang 
            where c_danhsachdathang_id = @dsdhid

            declare @dh table (id nvarchar(32), soPO nvarchar(150), shiptime datetime)
            insert into @dh
            select c_donhang_id, sochungtu, shipmenttime 
            from c_donhang 
            where c_donhang_id = (select top 1 dhid from @dsdh)

            declare @gcvncu nvarchar(MAX) = (SELECT STUFF(
                (
                    SELECT distinct ',' + dtkd.ma_dtkd
                    FROM c_dongdonhang ddh
                    LEFT JOIN md_doitackinhdoanh dtkd ON ddh.nhacungungid = dtkd.md_doitackinhdoanh_id
                    WHERE c_donhang_id = (SELECT TOP 1 id FROM @dh)
                          and dtkd.md_doitackinhdoanh_id != (SELECT TOP 1 ncuid FROM @dsdh)
                    FOR XML PATH('')
                ), 1, 1, ''
            ));

            select 
                N'{companyName}' as companyName,
                N'{companyAdd}' as companyAdd,
                N'{tel}' as tel,
                N'{fax}' as fax,
                N'{email}' as email,
                CONVERT(VARCHAR(10), dh.shiptime, 103) as shiptime,
                dh.soPO,
                ncu.ma_dtkd as ncu,
                dsdh.sct as dsdhso,
                ngh.ma_dtkd as noigiaohang,
                null as tare,
                null as mg,
                null as vgm,
                @gcvncu as ncugc,
                null as soctn,
                null as soseal,
                null as loaicont,
                sp.ma_sanpham as maHHVT,
                dds.sl_dathang as sl,
                ddh.ma_sanpham_khach as makhach,
                sp.mota_tienganh as mota,
                dg.sl_inner as pkin1,
                dvti.ten_dvt as pkin2,
                (case when dg.sl_outer > 0 then round(dds.sl_dathang/dg.sl_outer, 2) else 0 end) as nop,
                sp.trongluong * dds.sl_dathang as nw,
                sp.trongluong * dds.sl_dathang as gw,
                ddh.v2 as cbm,
                dg.l1 as li,
                dg.w1 as wi,
                dg.h1 as hi,
                dg.l2_mix as lm,
                dg.w2_mix as wm,
                dg.h2_mix as hm,
                dsdh.ddhh,
                dsdh.chdk,
                dg.sl_outer as pkmt1,
                dvtm.ten_dvt as pkmt2
            from @dsdh dsdh
                left join @dh dh on dsdh.dhid = dh.id
                left join c_dongdsdh dds on dds.c_danhsachdathang_id = dsdh.id
                left join c_dongdonhang ddh on ddh.c_donhang_id = dh.id and dds.md_sanpham_id = ddh.md_sanpham_id
                left join md_sanpham sp on sp.md_sanpham_id = ddh.md_sanpham_id
	            left join md_doitackinhdoanh ncu on dsdh.ncuid = ncu.md_doitackinhdoanh_id
	            left join md_doitackinhdoanh ngh on dsdh.nghid = ngh.md_doitackinhdoanh_id
                left join md_donggoi dg on dg.md_donggoi_id = ddh.md_donggoi_id
	            left join md_donvitinh dvti on dg.dvt_inner = dvti.md_donvitinh_id
	            left join md_donvitinh dvtm on dg.dvt_outer = dvtm.md_donvitinh_id
            where
                1=1
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}