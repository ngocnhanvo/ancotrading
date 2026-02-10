using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class SendMail_PaymentRequest : System.Web.UI.Page
{
    public LinqDBDataContext db = new LinqDBDataContext();
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        string nameTemp = "(CT) Payment Request.xls";
        string nameRpt = "Payment Request";
        string sql = CreateSql(context);

        inPDF = "2";
        var task = new System.Threading.Tasks.Task(() =>
        {
            viewReport(sql);
        });

        var compineF = Request.QueryString["compineF"];
        nameRpt = string.IsNullOrWhiteSpace(compineF) ? nameRpt + "-" + DateTime.Now.ToString("ddMMyy") : nameRpt;
        PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, string.IsNullOrWhiteSpace(compineF), !string.IsNullOrWhiteSpace(compineF));
    }

    public void viewReport(String SqlQuery)
    {

    }

    public string CreateSql(HttpContext context)
    {
        String pklId = context.Request.QueryString["pklId"];
        var pdkInvoice = db.c_packinginvoices.Where(s => s.c_packinginvoice_id == pklId).FirstOrDefault();

        // Lấy packing list - invoice
        var info = (from pkl in db.c_packinginvoices
                    join cb in db.md_cangbiens on pkl.noidi equals cb.md_cangbien_id
                    where pkl.c_packinginvoice_id.Equals(pklId)
                    select new { pkl, cb }).Single();

        // Lấy số lượng sản phẩm Packing List Invoice
        var totalQuantity = (from p in db.c_dongpklinvs where p.c_packinginvoice_id.Equals(pklId) select p.soluong).Sum();
        totalQuantity = totalQuantity.GetValueOrDefault(0);


        // Lấy thông tin khách hàng
        var dtkd = (from pkl in db.c_packinginvoices
                    join dt in db.md_doitackinhdoanhs on pkl.md_doitackinhdoanh_id equals dt.md_doitackinhdoanh_id
                    where pkl.c_packinginvoice_id.Equals(pklId)
                    select dt).Single();

        // Lấy danh sách đơn hàng thuộc invoice đang chọn
        var dsDonHang = from p in db.c_packinginvoices
                        join dp in db.c_dongpklinvs on p.c_packinginvoice_id equals dp.c_packinginvoice_id
                        join dh in db.c_donhangs on dp.c_donhang_id equals dh.c_donhang_id
                        where p.c_packinginvoice_id.Equals(pklId)
                        select new { dh };

        // Lấy danh sách số chứng từ đơn hàng
        var chungTuDonHang = (from dh in dsDonHang select new { dh.dh.sochungtu }).Distinct();

        // Lấy thông tin ngân hàng
        var nganhang = db.md_nganhangs.Single(
                    p => p.md_nganhang_id.Equals(dsDonHang.Take(1).Single().dh.md_nganhang_id)
                );

        //Chuyển danh sách đơn hàng sang chuỗi
        string dhStr = string.Join(", ", chungTuDonHang.Select(s => s.sochungtu).ToList());

        // Lấy tổng số kiện
        var soKien = (from nxk in db.c_nhapxuats
                      join dnxk in db.c_dongnhapxuats on nxk.c_nhapxuat_id equals dnxk.c_nhapxuat_id
                      where nxk.c_donhang_id.Equals(dsDonHang.Take(1).Single().dh.c_donhang_id)
                      select new { dnxk.sokien_thucte });

        var toSoKien = soKien.Sum(p => p.sokien_thucte.GetValueOrDefault(0));
        info.pkl.totalgross = info.pkl.totalgross.GetValueOrDefault(0);
        info.pkl.tiendatcoc = info.pkl.tiendatcoc.GetValueOrDefault(0);
        info.pkl.tienconlai = info.pkl.tienconlai.GetValueOrDefault(0);
        string sql = $@"
            select 
                N'155/POTTERYPOT-21, 203/POTTERYPOT-21, 205/POTTERYPOT-21, 208/POTTERYPOT-21, 231/POTTERYPOT-21, 311/POTTERYPOT-21, 312/POTTERYPOT-21, 313/POTTERYPOT-21, 315/POTTERYPOT-21, 348/POTTERYPOT-21, 348A/POTTERYPOT-21, 351/POTTERYPOT-21, 491/POTTERYPOT-21, 511/POTTERYPOT-21' as sopo, 
                N'{DateTime.Now.ToString("dd/MMM/yyyy")}' as ngayguimail, 
                N'{dtkd.ten_dtkd.Replace("'", "''")}' as tenkh, 
                N'{info.pkl.commodity}' as chungloai, 
                N'{info.pkl.mv}' as tentau, 
                N'{info.cb.ten_cangbien.Replace("'", "''")}' as noidi, 
                N'{info.pkl.noiden.Replace("'", "''")}' as noiden, 
                N'{info.pkl.etd.Value.ToString("dd/MMM/yyyy")}' as shipmenttime, 
                N'{info.pkl.blno}' as sobil, 
                N'{totalQuantity.ToString()}' as slinvoice, 
                N'{toSoKien.ToString()}' as sokien, 
                {info.pkl.totalgross.ToString()} as tongtieninvoice, 
                N'{info.pkl.so_inv}' as soinvoice, 
                {info.pkl.tiendatcoc.Value} as datcoc, 
                {info.pkl.tienconlai.Value} as giatriconlai, 
                N'{nganhang.thongtin.Replace("'", "''")}' as nganhang,
                N'{Public.tenTaiKhoanNoTA}' as cp_name,
                N'{Public.diaChiNoTA}' as cp_add
        ";

        //throw new ArgumentNullException(sql);
        return sql;
    }
}