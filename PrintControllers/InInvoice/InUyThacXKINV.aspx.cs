using System;
using System.Collections.Generic;
using System.Web;
using System.Linq;
using System.Data;
using NPOI.HSSF.Record.Chart;
using DevExpress.XtraRichEdit.Fields;

public partial class PrintControllers_InInvoice_InUyThacXKINV : System.Web.UI.Page
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

        string nameTemp = "(CT) Hợp đồng ủy thác xuất khẩu.xls";
        string nameRpt = "Hợp đồng ủy thác xuất khẩu";
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
        var tongtien = tbl.AsEnumerable().Select(s => s.Field<decimal>("thanhtien")).Sum();
        var tienbangchu = VNN_ConvertMoney.convert((double)tongtien, "VND");
        foreach (DataRow row in tbl.Rows)
        {
            row["tienbangchu"] = tienbangchu;
        }
    }

    public string CreateSql(HttpContext context)
    {
        var id = context.Request.QueryString["c_packinglist_id"];
        string sql = "";
        var soPIs = new List<string>();
        var hscodes = new List<string>();
        using (var db = new LinqDBDataContext())
        {
            var inv = db.c_packinginvoices.Where(s => s.c_packinginvoice_id == id).FirstOrDefault();
            var dhids = db.c_dongpklinvs.Where(s => s.c_packinginvoice_id == id).Select(s => s.c_donhang_id).ToList();
            var dhs = db.c_donhangs.Where(s => dhids.Contains(s.c_donhang_id)).OrderBy(s => s.sochungtu).ToList();
            soPIs = dhs.Select(s => s.sochungtu).Distinct().OrderBy(s => s).ToList();
            string benA = UnicodeToVNIConverter.Convert("CÔNG TY TNHH SẢN XUẤT THƯƠNG MẠI VÀ DỊCH VỤ AN BÌNH BP");
            string diachiA = UnicodeToVNIConverter.Convert("Khu Phố 6, Phường Minh Hưng, Tỉnh Đồng Nai, Việt Nam");
            string daidienA = "Bùi Văn Hải";
            string benB = UnicodeToVNIConverter.Convert(Public.tenTaiKhoanNo.ToUpper());
            string diachiB = UnicodeToVNIConverter.Convert(Public.diaChiNo);
            string daidienB = UnicodeToVNIConverter.Convert("Trần Thị Ngân Hà");
            sql = $@"
                select 
                    N'--' as so,
                    format(getdate(), 'dd/MM/yyyy') as ngay,
                    '{benA}' as benA,
                    '3 8 0 1 0 6 8 8 9 4' as mstA,
                    '{diachiA}' as diachiA,
                    N'{daidienA}' as daidienA,
                    '{benB}' as benB,
                    '{string.Join(" ", Public.masothueNo.ToCharArray())}' as mstB,
                    '{diachiB}' as diachiB,
                    '{daidienB}' as daidienB,
                    sp.ma_sanpham as mahang,
                    sp.mota_tiengviet as tenhang, 
					dpk.soluong as sl, 
                    dvtsp.ten_dvt_tv as dvt,
                    dpk.gia as dongia, 
                    dpk.gia * dpk.soluong as thanhtien,
                    N'' as tienbangchu,
                    0 as philamhang,
                    format(DATEADD(DAY, 20, cpk.ngaylap), 'dd/MM/yyyy') as ngaytrenhat
				from c_dongpklinv dpk 
                    left join md_sanpham sp on dpk.md_sanpham_id = sp.md_sanpham_id
                    left join md_donvitinhsanpham dvtsp on dvtsp.md_donvitinhsanpham_id = sp.md_donvitinhsanpham_id
                    left join c_packinginvoice cpk on cpk.c_packinginvoice_id = dpk.c_packinginvoice_id
				where 
                    dpk.c_packinginvoice_id = '{id}'
                order by
                    sp.ma_sanpham
            ";
        }

        //throw new Exception(sql);
        return sql;
    }
}
