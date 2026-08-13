using System;
using System.Data;
using System.Web;
using System.Text;

public partial class PrintControllers_InBangKeUyNhiemChiAnCoBinhDuong_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string id = Request.QueryString["id"];

        if (string.IsNullOrEmpty(id))
        {
            Response.Write("Thiếu id phiếu chi.");
            return;
        }

        DataTable dt = GetData(id);
        ExportExcel(dt);
    }

    private DataTable GetData(string c_thuchi_id)
    {
        string sql = @"
            SELECT 
                ROW_NUMBER() OVER (ORDER BY cttc.ngaytao, cttc.ngaychi) AS STT,
                cttc.ngaytao AS TuNgay,
                cttc.ngaychi AS DenNgay,
                ISNULL(cttc.ngaychi, tc.ngaylapphieu) AS NgayDNTT,
                dtkd.ten_dtkd AS TenCongTy,
                dtkd.so_taikhoan AS SoTK,
                dtkd.nganhang AS NganHang,
                ROUND(
                    ISNULL(cttc.sotien, 0) 
                    + (ISNULL(cttc.sotien, 0) * ISNULL(cttc.thue, 0) / 100)
                    + ISNULL(cttc.sotiencong, 0), 0
                ) AS SoTien,
                cttc.diengiai AS NoiDung,
                cttc.mota AS GhiChu,
                tc.ngaylapphieu AS NgayUNC
            FROM c_chitietthuchi cttc
            LEFT JOIN c_thuchi tc 
                ON tc.c_thuchi_id = cttc.c_thuchi_id
            LEFT JOIN md_doitackinhdoanh dtkd 
                ON dtkd.md_doitackinhdoanh_id = cttc.md_doitackinhdoanh_id
            WHERE cttc.c_thuchi_id = @id
            ORDER BY cttc.ngaytao, cttc.ngaychi
        ";

        return mdbc.GetData(sql, "@id", c_thuchi_id);
    }

    private void ExportExcel(DataTable dt)
    {
        string tuNgay = "";
        string denNgay = "";
        decimal tongTien = 0;

        if (dt.Rows.Count > 0)
        {
            tuNgay = FormatDate(dt.Rows[0]["TuNgay"]);
            denNgay = FormatDate(dt.Rows[0]["DenNgay"]);
        }

        foreach (DataRow r in dt.Rows)
        {
            if (r["SoTien"] != DBNull.Value)
                tongTien += Convert.ToDecimal(r["SoTien"]);
        }

        string nguoiLap = UserUtils.getUser(Context);

        Response.Clear();
        Response.Buffer = true;
        Response.Charset = "utf-8";
        Response.ContentEncoding = Encoding.UTF8;
        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader(
            "content-disposition",
            "attachment;filename=BangKeUyNhiemChi_AnCoBinhDuong.xls"
        );

        Response.Write("<html><head><meta charset='utf-8' />");
        Response.Write("<style>");
        Response.Write("table{border-collapse:collapse;font-family:Arial;font-size:11pt;}");
        Response.Write("td,th{border:1px solid #000;padding:10px 5px;height:50px;}");
        Response.Write(".title{font-size:16pt;font-weight:bold;text-align:center;}");
        Response.Write(".center{text-align:center;}");
        Response.Write(".right{text-align:right;}");
        Response.Write(".bold{font-weight:bold;}");
        Response.Write(".noborder{border:none !important;}");

        Response.Write(".title{font-size:16pt;font-weight:bold;text-align:center;}");
        Response.Write(".noborder{border:0px !important;}");
        Response.Write(".center{text-align:center;}");
        //Response.Write(".sotk{text-align:right;mso-number-format:'\\@';}");
        Response.Write(".sotk{mso-number-format:\"\\@\";text-align:left;}");

        Response.Write("</style></head><body>");

        Response.Write("<table>");

        // Bỏ 1 hàng trước tiêu đề
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");

        // Tiêu đề
        Response.Write("<tr>");
        Response.Write("<td colspan='9' style='border:none;text-align:center;font-size:16pt;font-weight:bold;'>");
        Response.Write("BẢNG KÊ UỶ NHIỆM CHI CÔNG TY TNHH AN CƠ BÌNH DƯƠNG");
        Response.Write("</td>");
        Response.Write("</tr>");

        // Bỏ 1 hàng sau tiêu đề
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");


        // Từ ngày - đến ngày
        Response.Write("<tr>");
        Response.Write("<td colspan='9' style='border:none;text-align:center;font-weight:bold;'>");
        Response.Write("Từ ngày " + tuNgay + " đến ngày " + denNgay);
        Response.Write("</td>");
        Response.Write("</tr>");

        // Bỏ 1 hàng sau từ ngày - đến ngày
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");

        // Header danh sách
        Response.Write("<tr>");
        Response.Write("<th>STT</th>");
        Response.Write("<th>Ngày DNTT</th>");
        Response.Write("<th>Tên Công ty</th>");
        Response.Write("<th>Số TK</th>");
        Response.Write("<th>Ngân Hàng</th>");
        Response.Write("<th>Số tiền</th>");
        Response.Write("<th>Nội dung</th>");
        Response.Write("<th>Ghi chú</th>");
        //Response.Write("<th>NGÀY UNC</th>");
        Response.Write("</tr>");

        foreach (DataRow r in dt.Rows)
        {
            Response.Write("<tr>");
            Response.Write("<td class='center'>" + r["STT"] + "</td>");
            Response.Write("<td class='center'>" + FormatDate(r["NgayDNTT"]) + "</td>");
            Response.Write("<td>" + Server.HtmlEncode(r["TenCongTy"].ToString()) + "</td>");
            //Response.Write("<td>" + Server.HtmlEncode(r["SoTK"].ToString()) + "</td>");
            //Response.Write("<td class='sotk' style=\"mso-number-format:'\\@';text-align:right;\">" + Server.HtmlEncode(FormatSoTK(r["SoTK"])) + "</td>");
            string soTK = FormatSoTK(r["SoTK"]);
            Response.Write("<td class='sotk'>" + Server.HtmlEncode(soTK) + "</td>");
            Response.Write("<td>" + Server.HtmlEncode(r["NganHang"].ToString()) + "</td>");
            Response.Write("<td class='right'>" + FormatMoney(r["SoTien"]) + "</td>");
            Response.Write("<td>" + Server.HtmlEncode(r["NoiDung"].ToString()) + "</td>");
            Response.Write("<td>" + Server.HtmlEncode(r["GhiChu"].ToString()) + "</td>");
            //Response.Write("<td class='center'>" + FormatDate(r["NgayUNC"]) + "</td>");
            Response.Write("</tr>");
        }

        // Dòng tổng tiền
        Response.Write("<tr>");
        Response.Write("<td colspan='5' class='center bold'>TỔNG CỘNG</td>");
        Response.Write("<td class='right bold'>" + FormatMoney(tongTien) + "</td>");
        Response.Write("<td colspan='2'></td>");
        Response.Write("</tr>");

        // Khoảng trắng trước chữ ký
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");

        // Chỉ còn Người lập, bỏ Kế toán trưởng và Giám đốc
        // Dời gần giữa bảng bằng cách để trống 3 cột đầu và 3 cột cuối
        Response.Write("<tr>");
        Response.Write("<td colspan='3' style='border-top:none;border-bottom:none;border-left:none;border-right:none'></td>");
        Response.Write("<td colspan='3' style='border-top:none;border-bottom:none;border-left:none;border-right:none;text-align:left;font-weight:bold'>Người lập</td>");
        Response.Write("<td colspan='3' style='border-top:none;border-bottom:none;border-left:none;border-right:none'></td>");
        Response.Write("</tr>");

        Response.Write("<tr>");
        Response.Write("<td colspan='3' style='border-top:none;border-bottom:none;border-left:none;border-right:none'></td>");
        Response.Write("<td colspan='3' style='border-top:none;border-bottom:none;border-left:none;border-right:none;text-align:left'>(Ký, họ tên)</td>");
        Response.Write("<td colspan='3' style='border-top:none;border-bottom:none;border-left:none;border-right:none'></td>");
        Response.Write("</tr>");

        // Khoảng cách ký tên
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");
        Response.Write("<tr><td colspan='9' class='noborder'>&nbsp;</td></tr>");

        // Tên người lập
        Response.Write("<tr>");
        Response.Write("<td colspan='3' style='border:none'></td>");
        Response.Write("<td colspan='3' style='border:none;text-align:left;font-weight:bold'>" + Server.HtmlEncode(nguoiLap) + "</td>");
        Response.Write("<td colspan='3' style='border:none'></td>");
        Response.Write("</tr>");

        Response.Write("</table>");
        Response.Write("</body></html>");
        Response.End();
    }

    private string FormatDate(object value)
    {
        if (value == null || value == DBNull.Value) return "";
        return Convert.ToDateTime(value).ToString("dd/MM/yyyy");
    }

    private string FormatMoney(object value)
    {
        if (value == null || value == DBNull.Value) return "0";
        return Convert.ToDecimal(value).ToString("#,##0");
    }
    private string FormatSoTK(object value)
    {
        if (value == null || value == DBNull.Value) return "";

        // Không ép kiểu số, giữ nguyên chuỗi để không mất số 0 đầu
        return value.ToString().Trim();
    }
    //private string FormatSoTK(object value)
    //{
    //    if (value == null || value == DBNull.Value) return "";

    //    string s = value.ToString().Trim();

    //    decimal d;
    //    if (decimal.TryParse(
    //        s,
    //        System.Globalization.NumberStyles.Any,
    //        System.Globalization.CultureInfo.InvariantCulture,
    //        out d))
    //    {
    //        return d.ToString("0");
    //    }

    //    return s;
    //}
}
