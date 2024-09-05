using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using DevExpress.XtraReports.UI;

public partial class PrintControllers_InYeuCauXuatHang_ycxh220524 : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public string c_kehoachxuathang_id = "", c_donhang_id = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        c_kehoachxuathang_id = context.Request.QueryString["c_kehoachxuathang_id"];
        c_donhang_id = Context.Request.QueryString["c_donhang_id"];

        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        inPDF = "2";
        string nameTemp = "[CT] Phiếu yêu cầu và xác nhận xuất hàng.repx";
        string nameRpt = "Phiếu yêu cầu và xác nhận xuất hàng";
        string sql = CreateSql(context);

        var task = new System.Threading.Tasks.Task(() =>
        {
            viewReport(sql);
        });

        PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, true);
    }

    public void viewReport(String SqlQuery)
    {
        var tbl = ((DataSet)ReportViewer1.Report.DataSource).Tables[0];
    }

    public String CreateSql(HttpContext context)
    {
        string where_ = "";
        if (c_kehoachxuathang_id != null && c_kehoachxuathang_id != "")
        {
            where_ = "AND kh.c_kehoachxuathang_id = N'" + c_kehoachxuathang_id + "'";
        }

        if (c_donhang_id != null && c_donhang_id != "")
        {
            where_ = "AND dh.c_donhang_id = N'" + c_donhang_id + "' ";
        }

        string str = $@"
            select 
	            dh.c_donhang_id
                , N'{DateTime.Now.ToString("dd/MM/yyyy")}' as homnay
	            , dsdh.c_danhsachdathang_id
	            , dh.sochungtu as ct_dh
	            , dsdh.sochungtu as ct_dsdh
                , null as socont
                , null as soseal
                , null as cont
                , null as ngayxuat
	            , dtkd.ten_dtkd
	            , dh.ngaylap
                , dsdh.huongdanlamhang as dacdiemhanghoa
                , dsdh.huongdanlamhangchung as huongdankhac
                , gh.ten_dtkd as noigiaohang
                , (select hoten from nhanvien where manv = dsdh.nguoitao) as nguoitao
                , sp.ma_sanpham
                , ddsdh.mota_tienganh
                , dongdh.ma_sanpham_khach
                , ddsdh.sl_dathang
                , dg.sl_outer as sl
                , dvtdg.ten_dvt as dvtdg
                , dongdh.soluong as sl_po
                , dongdh.soluong_daxuat as sldx
                , null as sl_thucxuat
                , null as sokien
                , null as ghichu
                , null as nw1
                , null as gw1
                , dongdh.v2
                , null as gw
                , null as cbm
                , null as vgm
                , null as tare
                , null as mg
            from 
	            c_donhang dh
				left join c_danhsachdathang dsdh  on dh.c_donhang_id = dsdh.c_donhang_id
				left join md_doitackinhdoanh dtkd on dsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
				left join c_kehoachxuathang	kh on kh.c_donhang_id = dh.c_donhang_id
				left join md_doitackinhdoanh gh on gh.md_doitackinhdoanh_id = dsdh.diachigiaohang
                left join c_dongdsdh ddsdh on ddsdh.c_danhsachdathang_id = dsdh.c_danhsachdathang_id
                left join md_sanpham sp on ddsdh.md_sanpham_id = sp.md_sanpham_id
                left join c_dongdonhang dongdh on dongdh.c_dongdonhang_id = ddsdh.c_dongdonhang_id
                left join md_donggoi dg on dongdh.md_donggoi_id = dg.md_donggoi_id
                left join md_donvitinh dvtdg on dvtdg.md_donvitinh_id = dg.dvt_outer
            where
                dsdh.md_trangthai_id = '{Helper.HIEULUC}'
                {where_}
                AND dh.hoatdong = 1
				AND kh.c_danhsachdathang_id = dsdh.sochungtu
		";

        return str;
    }
}
