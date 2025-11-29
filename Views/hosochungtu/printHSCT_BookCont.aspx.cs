using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Views_hosochungtu_printHSCT_BookCont : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(CT) Book Container.xls";
        string nameRpt = "Book Container";
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

        string sql = $@"
            select
                spd.Consignee
                , spd.Notify
                , spd.AlsoNotify
                , null as POL
                , spd.POD
                , null as Goods
                , null as [Order]
                , dh2.sochungtu as PI
                , null as HSCode
                , null as GW
                , CONVERT(VARCHAR(10), isnull(dh.ngaydieuchinh, DATEADD(day, -7, dh2.shipmenttime)), 103) as NXH
                , (
                    case 
                        when dh.loaicont = 'CONT20' then CONCAT(dh.slcont, 'x20')
                        when dh.loaicont = 'CONT40' then CONCAT(dh.slcont, 'x40DC')
                        when dh.loaicont = '40HC' then CONCAT(dh.slcont, 'x40HC')
                        when dh.loaicont = 'CONT45' then CONCAT(dh.slcont, 'x45')
                        when dh.loaicont = 'LE' then CONCAT(dh.slcont, 'xLCL')
                        else ''
                    end
                ) as loaiCont
            FROM c_donhangchungtu dh
                left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
                left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
                outer apply (select top 1 Consignee, Notify, AlsoNotify, POD from c_donhang_spd where c_donhang_id = dh2.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
            WHERE
                dh.c_donhangchungtu_id = '{id}'
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}