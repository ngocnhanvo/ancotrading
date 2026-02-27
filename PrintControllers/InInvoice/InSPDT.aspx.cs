using System;
using System.Collections.Generic;
using System.Web;
using System.Linq;
using System.Data;

public partial class PrintControllers_InInvoice_InSPDT : System.Web.UI.Page
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

        string nameTemp = "(CT) Shipping details.xls";
        string nameRpt = "Shipping details";
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
        using (LinqDBDataContext db = new LinqDBDataContext())
        {
            var inv = db.c_packinginvoices.Where(s => s.c_packinginvoice_id == id).FirstOrDefault();
            var dhids = db.c_dongpklinvs.Where(s => s.c_packinginvoice_id == id).Select(s => s.c_donhang_id).ToList();
            soPIs = db.c_donhangs.Where(s => dhids.Contains(s.c_donhang_id)).Select(s => s.sochungtu).OrderBy(s => s).ToList();

            hscodes = (
                from a in db.c_dongdonhangs
                join b in db.md_sanphams on a.md_sanpham_id equals b.md_sanpham_id
                join c in db.md_hscodes on b.md_hscode_id equals c.md_hscode_id
                where dhids.Contains(a.c_donhang_id)
                orderby c.hscode
                select c.hscode
            ).ToList();


            var chitiet_conts = (
                from a in db.c_dongpklinvs
                join b in db.c_dongnhapxuats on a.c_dongnhapxuat_id equals b.c_dongnhapxuat_id
                join c in db.c_nhapxuats on b.c_nhapxuat_id equals c.c_nhapxuat_id
                join d in db.c_dongdonhangs on b.c_dongdonhang_id equals d.c_dongdonhang_id
                join e in db.md_donggois on d.md_donggoi_id equals e.md_donggoi_id
                join f in db.md_donvitinhs on e.dvt_outer equals f.md_donvitinh_id
                join g in db.md_donvitinhs on e.dvt_inner equals g.md_donvitinh_id
                join h in db.md_sanphams on d.md_sanpham_id equals h.md_sanpham_id
                join i in db.md_hscodes on h.md_hscode_id equals i.md_hscode_id
                where a.c_packinginvoice_id == id
                select new
                {
                    c.container,
                    c.soseal,
                    soluong = a.soluong ?? 0,
                    sl_inner = d.sl_inner ?? 0,
                    sl_outer = d.sl_outer ?? 0,
                    sl_outer_dg = e.sl_outer ?? 0,
                    l1 = d.l1 ?? 0,
                    h1 = d.h1 ?? 0,
                    w1 = d.w1 ?? 0,
                    l2 = d.l2 ?? 0,
                    h2 = d.h2 ?? 0,
                    w2 = d.w2 ?? 0,
                    trongluong = h.trongluong ?? 0,
                    c.loaicont,
                    dvt_outer = f.ten_dvt,
                    nkg = (h.trongluong ?? 0) * (a.soluong ?? 0),
                    noofpack = Math.Round((d.sl_outer ?? 0) == 0 ? 0 : (a.soluong ?? 0) / (d.sl_outer ?? 0), 1, MidpointRounding.AwayFromZero),
                    i.hscode
                }
            ).ToList();

            var groupheaders = chitiet_conts.GroupBy(s => new { s.container, s.soseal, s.loaicont, s.dvt_outer }).Select(s => new
            {
                so_cont = $"{s.Key.container}/{s.Key.soseal} {Public.getLoaiCont(s.Key.loaicont, true)}",
                so_kien = s.Sum(t => t.sl_outer_dg > 0 ? t.soluong / t.sl_outer_dg : 0),
                dvt_kien = s.Key.dvt_outer,
                gkg = Math.Round(s.Sum(t => t.sl_inner > 1 ? ((t.l1 + t.w1) * (t.w1 + t.h1) / 5400 * t.sl_outer / t.sl_inner) * t.noofpack + t.nkg : (t.l2 + t.w2) * (t.w2 + t.h2) / 5400 * t.noofpack + t.nkg), 2, MidpointRounding.AwayFromZero),
                cbm = Math.Round(s.Sum(t => t.sl_outer == 0 ? 0 : t.l2 * t.h2 * t.w2 / 1000000 * t.soluong / t.sl_outer), 3, MidpointRounding.AwayFromZero),
                hscode = string.Join(", ", s.Select(t => t.hscode).Where(t => !string.IsNullOrEmpty(t)).Distinct().OrderBy(t => t))
            }).OrderBy(s => s.so_cont).ThenBy(s => s.dvt_kien);

            string selChungTuDH = $@"
            select top (1) 
                spd.Consignee, spd.Notify, spd.AlsoNotify, cb.ten_cangbien, spd.POD, dh.customer_order_no, dbo.get_commodity(dh.c_donhang_id) as commodity
            from 
                c_donhang dh
                left join md_cangbien cb on cb.md_cangbien_id = dh.md_cangbien_id
                outer apply (select top 1 Consignee, Notify, AlsoNotify, POD from c_donhang_spd where c_donhang_id = dh.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
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
            string PI = string.Join(", ", soPIs);
            string HSCode = string.Join(", ", hscodes);

            sql = $@"	 
            select
	            N'{Public.tenTaiKhoanNoTA}' as cp_name,
	            N'{Public.diaChiNoTA}' as cp_add,
                N'{Public.tenTaiKhoanNo}' as cp_name_vn,
                N'{Public.diaChiNo}' as cp_add_vn,
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
                N'1' as so_cont,
                null as so_kien,
                null as dvt_kien,
                null as so_kg,
                null as so_cbm,
                null as hscode_cont
		    ";
            var lst = new List<string>();
            foreach(var item in groupheaders)
            {
                lst.Add($@"	 
                select
	                N'{Public.tenTaiKhoanNoTA}' as cp_name,
	                N'{Public.diaChiNoTA}' as cp_add,
                    N'{Public.tenTaiKhoanNo}' as cp_name_vn,
                    N'{Public.diaChiNo}' as cp_add_vn,
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
                    N'{item.so_cont}' as so_cont,
                    N'{item.so_kien}' as so_kien,
                    N'{item.dvt_kien}' as dvt_kien,
                    N'{item.gkg}' as so_kg,
                    N'{item.cbm}' as so_cbm,
                    N'{item.hscode}' as hscode_cont
		        ");
            }

            sql = string.Join(" union ", lst);
        }
        
        return sql;
    }
}
