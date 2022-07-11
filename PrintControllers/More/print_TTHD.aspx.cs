using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_More_print_TTHD : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(KT) Bảng thông tin xuất hóa đơn.xls";
        string nameRpt = "Bảng thông tin xuất hóa đơn";
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
            var giamgia = tbl.AsEnumerable().Sum(s => s.Field<decimal>("gghd"));
            row["giamgia"] = giamgia;

            var philamhang = tbl.AsEnumerable().Sum(s => s.Field<decimal>("plhhd"));
            row["philamhang"] = philamhang;
        }
    }

    public string CreateSql(HttpContext context)
    {
        string id = context.Request.QueryString["id"];
        var ids = id.Split(',');

        string sql = string.Format(@"
            select 
	            hd.tiento + '/' + hd.sophieu as sophieu,
	            hd.ma_khachhang,
	            hd.ten_khachhang,
	            hd.diachi_khachhang,
	            '' as email_khachhang,
	            ct.ma_sanpham,
	            ct.ten_sanpham,
	            ct.ten_dvt,
	            ct.soluong,
	            ct.dongia,
	            ct.thanhtien,
	            hd.thue_vat,
	            hd.tienthue,
	            hd.tuongduongVND,
	            hd.hinhthucthanhtoan,
	            hd.tygia,
	            hd.tuongduongUSD,
	            hd.ngayhoadon,
	            hd.mauso,
	            hd.kyhieu,
	            hd.sohoadon,
	            hd.ngayphathanh,
	            hd.so_inv,
	            hd.sotokhai_inv,
	            '' as ghichu,
                hd.giamgia as gghd,
                hd.philamhang as plhhd,
                hd.giamgia,
                hd.philamhang
            from c_hoadon hd
            left join c_hoadon_ct ct on hd.c_hoadon_id = ct.c_hoadon_id
            where hd.c_hoadon_id in ('{0}')
		"
        , string.Join("','", ids)
        );

        //throw new ArgumentNullException(sql);
        return sql;
    }
}