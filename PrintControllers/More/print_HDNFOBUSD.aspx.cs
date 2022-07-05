using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class PrintControllers_More_print_HDNFOBUSD : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

        var maXuong = context.Request.QueryString["maXuong"];
        string nameTemp = "(KT) Hóa đơn nhập FOB - USD.xls";
        string nameRpt = "Hóa đơn nhập FOB - USD";
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
        foreach(DataRow row in tbl.Rows)
        {
            var tongtien = (decimal)row["tongtien"];
            row["tongtien_bangchu"] = MoneyToWord.ConvertMoneyToTextVND(tongtien);
        }
    }

    public string CreateSql(HttpContext context)
    {
        string id = context.Request.QueryString["id"];

        string sql = string.Format(@"	 
            declare @id nvarchar(32) = N'{0}'
            select 
	            hd.tiento + '/' + hd.sophieu as sophieu,
	            hd.ma_khachhang,
	            hd.ten_khachhang,
	            hd.diachi_khachhang,
	            hd.email_khachhang,
                hd.daidien_khachhang,
                hd.sotaikhoan_khachhang,
                hd.masothue_khachhang,
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
                hd.tuongduongVND + hd.tienthue as tongtien,
	            '' as tongtien_bangchu,
                '' as taikhoan_thanhtoan,
                '' as ghichu,
                hd.giamgia,
                hd.philamhang
            from c_hoadon hd
            left join c_hoadon_ct ct on hd.c_hoadon_id = ct.c_hoadon_id
            where hd.c_hoadon_id = @id
		"
        , id
        );

        //throw new ArgumentNullException(sql);
        return sql;
    }
}