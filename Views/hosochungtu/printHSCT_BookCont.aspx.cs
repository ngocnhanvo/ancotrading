using System;
using System.Web;
using System.Data;
using System.Collections.Generic;

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
        var tbl = ((DataSet)ReportViewer1.Report.DataSource).Tables[0];
        foreach (DataRow row in tbl.Rows)
        {
            var cont20 = row["cont20"].ToString().ToNullableDecimal();
            var cont40 = row["cont40"].ToString().ToNullableDecimal();
            var cont40hc = row["cont40hc"].ToString().ToNullableDecimal();
            var cont45 = row["cont45"].ToString().ToNullableDecimal();
            var contLCL = row["contLCL"].ToString().ToNullableDecimal();

            var arr = new List<string>();
            if(cont20 != null)
            {
                if(cont20 > 0)
                    arr.Add($"{cont20}x20");
            }
            if (cont40 != null)
            {
                if (cont40 > 0)
                    arr.Add($"{cont40}x40DC");
            }
            if (cont40hc != null)
            {
                if (cont40hc > 0)
                    arr.Add($"{cont40hc}x40HC");
            }
            if (cont45 != null)
            {
                if (cont45 > 0)
                    arr.Add($"{cont45}x45");
            }
            if (contLCL != null)
            {
                if (contLCL > 0)
                    arr.Add($"{contLCL}xLCL");
            }
            row["loaiCont"] = string.Join(", ", arr);
        }
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
                , '' loaiCont
                , dh.cont20
                , dh.cont40
                , dh.cont40hc
                , dh.cont45
                , dh.contLCL
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