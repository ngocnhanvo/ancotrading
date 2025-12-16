using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Views_hosochungtu_printHSCT_All : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        string nameTemp = "(CT) Chiết xuất hồ sơ.xls";
        string nameRpt = "Hồ sơ chứng từ";
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
        var tungay = Request.QueryString["tungay"];
        var denngay = Request.QueryString["denngay"];
        var ids = Request.Form["ids"].removeAllSpaceOrTrimText(false).Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
        string whereEX = "";
        string avaEX = "";
        if(ids.Count > 0)
        {
            tungay = "        ";
            denngay = "        ";
            whereEX = $"and dh.c_donhangchungtu_id in ('{string.Join("','", ids)}')";
        }
        else
        {
            avaEX = $@"
            declare @tungay datetime = convert(datetime, '{tungay} 00:00:00', 103)
            declare @denngay datetime = convert(datetime, '{denngay} 23:59:59', 103)
            ";
            whereEX = $"and dh2.shipmenttime between @tungay and @denngay";
        }

        string sql = $@"
            {avaEX}
            select
                '{tungay}' as tungay
                , '{denngay}' as denngay
                , (
                    case 
                        when dh.trangthai = 'SOANTHAO' then N'Soạn Thảo'
                        when dh.trangthai = 'HIEULUC' then N'Hiệu lực'
                        when dh.trangthai = 'DAGUIBC' then N'Đã gửi book container'
                        when dh.trangthai = 'DACOLT' then N'Đã có lịch tàu'
                        when dh.trangthai = 'DAKEOC' then N'Đã kéo cont/xuất hàng'
                        when dh.trangthai = 'KETTHUC' then N'Kết thúc'
                        else '' 
                    end
                ) as trangthai
                , kh.ma_dtkd
                , dh2.sochungtu
                , dh2.customer_order_no
                , spd.POD
                , dh2.shipmenttime
                , DATEADD(day, -7, dh2.shipmenttime) as hangiaohang_po
                , dh.ngaydieuchinh
                , dh2.ngaypass
                , dh.ngaychuyenhoso
                , dh2.nguoilap
                , dh.nhanvienCT
                , dh.cont20
                , dh.cont40
                , dh.cont40hc
                , dh.cont45
                , dh.contLCL
                , dh.dongghep
                , spd.Forwarder
                , dh.ngayBookCont
                , dh.bookingNo
                , dh.ngayETD
                , dh.ngayETA
                , dh.ngayBHXN
                , dh.ngayXuong
                , dh.ngayCutOff
                , dh.mota
            FROM c_donhangchungtu dh
                left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
                left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
                outer apply (select top 1 POD, Forwarder from c_donhang_spd where c_donhang_id = dh2.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
            WHERE 1=1
                {whereEX}
            order by dh.ngaytao desc
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}