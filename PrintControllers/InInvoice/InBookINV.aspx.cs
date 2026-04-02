using System;
using System.Collections.Generic;
using System.Web;
using System.Linq;
using System.Data;
using NPOI.HSSF.Record.Chart;
using DevExpress.XtraRichEdit.Fields;

public partial class PrintControllers_InInvoice_InBookINV : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "", tungay = "", denngay = "", khachhang = "", baocaotheo = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        tungay = context.Request.QueryString["startdate"];
        denngay = context.Request.QueryString["enddate"];
        khachhang = context.Request.QueryString["doitackinhdoanh_id"];
        baocaotheo = context.Request.QueryString["baocaotheo"];
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

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

        }
    }

    public string CreateSql(HttpContext context)
    {
        var id = context.Request.QueryString["c_packinglist_id"];
        string sql = "";
        var soPIs = new List<string>();
        var hscodes = new List<string>();
        string conts = "";
        using (LinqDBDataContext db = new LinqDBDataContext())
        {
            var inv = db.c_packinginvoices.Where(s => s.c_packinginvoice_id == id).FirstOrDefault();
            var dhids = db.c_dongpklinvs.Where(s => s.c_packinginvoice_id == id).Select(s => s.c_donhang_id).ToList();
            var dhs = db.c_donhangs.Where(s => dhids.Contains(s.c_donhang_id)).OrderBy(s => s.sochungtu).ToList();
            soPIs = dhs.Select(s => s.sochungtu).ToList();

            hscodes = (
                from a in db.c_dongdonhangs
                join b in db.md_sanphams on a.md_sanpham_id equals b.md_sanpham_id
                join c in db.md_hscodes on b.md_hscode_id equals c.md_hscode_id
                where dhids.Contains(a.c_donhang_id)
                orderby c.hscode
                select c.hscode
            ).ToList();

            var dhcts = db.c_donhangchungtus.Where(s => dhids.Contains(s.c_donhang_id) & s.trangthai != Helper.SOANTHAO).ToList();
            var cont20 = dhcts.Select(s => s.cont20.GetValueOrDefault(0)).Sum();
            var cont40 = dhcts.Select(s => s.cont40.GetValueOrDefault(0)).Sum();
            var cont40hc = dhcts.Select(s => s.cont40hc.GetValueOrDefault(0)).Sum();
            var cont45 = dhcts.Select(s => s.cont45.GetValueOrDefault(0)).Sum();
            var contLCL = dhcts.Select(s => s.contLCL.GetValueOrDefault(0)).Sum();
            var arr = new List<string>();
            if (cont20 > 0)
                arr.Add($"{cont20}x20");
            if (cont40 > 0)
                arr.Add($"{cont40}x40DC");
            if (cont40hc > 0)
                arr.Add($"{cont40hc}x40HC");
            if (cont45 > 0)
                arr.Add($"{cont45}x45");
            if (contLCL > 0)
                arr.Add($"{contLCL}xLCL");
            conts = string.Join(", ", arr);

            string selChungTuDH = $@"
            select top (1) 
                spd.Consignee, 
                spd.Notify, 
                spd.AlsoNotify, 
                cb.ten_cangbien, 
                spd.POD, 
                dh.customer_order_no, 
                dbo.get_commodity(dh.c_donhang_id) as commodity,
                gw.gw,
                CONVERT(VARCHAR(10), isnull(dh.ngaydieuchinh, DATEADD(day, -7, dh.shipmenttime)), 103) as NXH
            from 
                c_donhang dh
                left join md_cangbien cb on cb.md_cangbien_id = dh.md_cangbien_id
                outer apply (select top 1 Consignee, Notify, AlsoNotify, POD from c_donhang_spd where c_donhang_id = dh.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
                outer apply (
                    SELECT sum(ddh.g_w_master) as gw
                    FROM c_dongdonhang ddh
                    WHERE ddh.c_donhang_id = dh.c_donhang_id  
                ) gw
            where 
                1=1
                AND dh.sochungtu in ('{string.Join("','", soPIs)}')
            order by 
                dh.ngaytao asc
            ";

            var dtChungTuDH = mdbc.GetData(selChungTuDH);
            string Consignee = dtChungTuDH.Rows[0][0].ToString();
            string Notify = dtChungTuDH.Rows[0][1].ToString();
            string AlsoNotify = dtChungTuDH.Rows[0][2].ToString();
            string POL = dtChungTuDH.Rows[0][3].ToString();
            string POD = dtChungTuDH.Rows[0][4].ToString();
            string Order = dtChungTuDH.Rows[0][5].ToString();
            string Goods = dtChungTuDH.Rows[0][6].ToString();
            string GW = dtChungTuDH.Rows[0][7].ToString();
            string NXH = dtChungTuDH.Rows[0][8].ToString();
            string PI = string.Join(", ", soPIs);
            string HSCode = string.Join(", ", hscodes);
            sql = $@"
                select
                    N'{Public.tenTaiKhoanNo}' as ten_ct_tv,
                    N'{Public.tenTaiKhoanNoTA}' as ten_ct_ta,
                    N'{Public.diaChiNo}' as dc_ct_tv,
                    N'{Public.diaChiNoTA}' as dc_ct_ta,
                    N'{Public.masothueNo}' as mst,
                    N'{Consignee}' as Consignee,
                    N'{Notify}' as Notify,
                    N'{AlsoNotify}' as AlsoNotify,
                    N'{POL}' as POL,
                    N'{POD}' as POD,
                    N'{Order}' as [Order],
                    N'{Goods}' as Goods,
                    N'{PI}' as PI,
                    N'{HSCode}' as HSCode,
                    cast(N'{GW}' as numeric(18, 2)) as GW,
                    N'{NXH}' as NXH,
                    N'{conts}' as loaiCont
		    ";
        }

        return sql;
    }
}
