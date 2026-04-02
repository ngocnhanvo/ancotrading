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
                N'{Public.tenTaiKhoanNo}' as ten_ct_tv
                , N'{Public.tenTaiKhoanNoTA}' as ten_ct_ta
                , N'{Public.diaChiNo}' as dc_ct_tv
                , N'{Public.diaChiNoTA}' as dc_ct_ta
                , N'{Public.masothueNo}' as mst
                , spd.Consignee
                , spd.Notify
                , spd.AlsoNotify
                , cb.ten_cangbien as POL
                , spd.POD
                , dbo.get_commodity(dh2.c_donhang_id) as Goods
                , dh2.customer_order_no as [Order]
                , dh2.sochungtu as PI
                , hs.hscode as HSCode
                , gw.gw as GW
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
                left join md_cangbien cb on cb.md_cangbien_id = dh2.md_cangbien_id
                outer apply (select top 1 Consignee, Notify, AlsoNotify, POD from c_donhang_spd where c_donhang_id = dh2.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
                outer apply (
                    SELECT STUFF((
                        SELECT ', ' + COALESCE(t.hscode, '')
                        FROM (
                            SELECT DISTINCT hsc.hscode
                            FROM c_dongdonhang ddh
                                LEFT JOIN md_sanpham sp ON sp.md_sanpham_id = ddh.md_sanpham_id
                                LEFT JOIN md_hscode hsc ON hsc.md_hscode_id = sp.md_hscode_id
                            WHERE ddh.c_donhang_id = dh2.c_donhang_id
                        ) t
                        ORDER BY t.hscode
                        FOR XML PATH(''), TYPE
                    ).value('.', 'nvarchar(max)'), 1, 2, '') AS hscode
                ) hs
                outer apply (
                    SELECT sum(ddh.g_w_master) as gw
                    FROM c_dongdonhang ddh
                    WHERE ddh.c_donhang_id = dh2.c_donhang_id  
                ) gw
            WHERE
                dh.c_donhangchungtu_id = '{id}'
		";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}