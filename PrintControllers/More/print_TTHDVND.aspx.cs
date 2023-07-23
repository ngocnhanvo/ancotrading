using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_More_print_TTHDVND : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(KT) Bảng thông tin xuất hóa đơn - VND.xls";
        string nameRpt = "Bảng thông tin xuất hóa đơn (VNĐ)";
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
        var sophieu = "";
        foreach (DataRow row in tbl.Rows)
        {
            var giamgia = tbl.AsEnumerable().Select(s=> new { sophieu = s.Field<string>("sophieu"), gghd = s.Field<decimal>("gghd") }).Distinct().Sum(s => s.gghd);
            row["giamgia"] = giamgia;

            var philamhang = tbl.AsEnumerable().Select(s => new { sophieu = s.Field<string>("sophieu"), plhhd = s.Field<decimal>("plhhd") }).Distinct().Sum(s => s.plhhd);
            row["philamhang"] = philamhang;

            if (sophieu == row["sophieu"].ToString())
            {
                row["tuongduongVND"] = DBNull.Value;
                row["tuongduongUSD"] = DBNull.Value;
            }
            else
            {
                sophieu = row["sophieu"].ToString();
                var giamgiaSP = tbl.AsEnumerable().Where(s=>s.Field<string>("sophieu") == sophieu).Select(s => new { gghd = s.Field<decimal>("gghd") }).Distinct().Sum(s => s.gghd);
                var philamhangSP = tbl.AsEnumerable().Where(s => s.Field<string>("sophieu") == sophieu).Select(s => new { plhhd = s.Field<decimal>("plhhd") }).Distinct().Sum(s => s.plhhd);
                var tuongduongVND = tbl.AsEnumerable().Where(s => s.Field<string>("sophieu") == sophieu).Select(s => new { msp = s.Field<string>("ma_sanpham"), thanhtien = s.Field<decimal>("thanhtien") }).Distinct().Sum(s => s.thanhtien);
                row["tuongduongVND"] = tuongduongVND - giamgiaSP + philamhangSP;
            }
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
	            hd.email_khachhang,
	            ct.ma_sanpham,
	            ct.ten_sanpham,
	            ct.ten_dvt,
	            ct.soluong,
	            round(ct.dongia * hd.tygia, 0) as dongia,
	            round(ct.dongia * hd.tygia, 0) * ct.soluong as thanhtien,
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
                round(hd.giamgia * hd.tygia, -2) as gghd,
                round(hd.philamhang * hd.tygia, -2) as plhhd,
                hd.giamgia,
                hd.philamhang
            from c_hoadon hd
            left join c_hoadon_ct ct on hd.c_hoadon_id = ct.c_hoadon_id
            where hd.c_hoadon_id in ('{0}')
            order by hd.sophieu 
		"
        , string.Join("','", ids)
        );

        //throw new ArgumentNullException(sql);
        return sql;
    }
}