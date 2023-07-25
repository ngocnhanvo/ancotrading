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
        var sophieu = "";
        foreach (DataRow row in tbl.Rows)
        {
            if (sophieu == row["sophieu"].ToString())
            {
                row["tuongduongVND"] = DBNull.Value;
                row["tuongduongUSD"] = DBNull.Value;
            }
            else
                sophieu = row["sophieu"].ToString();

            var giamgia = tbl.AsEnumerable().Select(s=> new { sophieu = s.Field<string>("sophieu"), gghd = s.Field<decimal>("gghd") }).Distinct().Sum(s => s.gghd);
            row["giamgia"] = giamgia;

            var philamhang = tbl.AsEnumerable().Select(s => new { sophieu = s.Field<string>("sophieu"), plhhd = s.Field<decimal>("plhhd") }).Distinct().Sum(s => s.plhhd);
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
	            hd.email_khachhang,
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
                hd.philamhang,
                nx.container, 
	            dh.sochungtu
            from c_hoadon_ct ct
                left join c_hoadon hd on hd.c_hoadon_id = ct.c_hoadon_id
                left join c_packinginvoice inv on inv.so_inv = hd.so_inv
                left join c_dongpklinv div on div.c_packinginvoice_id = inv.c_packinginvoice_id
                left join c_nhapxuat nx on div.c_nhapxuat_id = nx.c_nhapxuat_id
                left join c_donhang dh on div.c_donhang_id = dh.c_donhang_id
            where 
                hd.c_hoadon_id in ('{0}')
                and ct.md_sanpham_id = div.md_sanpham_id
                and ct.sothutu = div.line
            order by 
                hd.sophieu, nx.container, dh.sochungtu, ct.ma_sanpham
		"
        , string.Join("','", ids)
        );

        //throw new ArgumentNullException(sql);
        return sql;
    }
}