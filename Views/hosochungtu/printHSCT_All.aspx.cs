
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Views_hosochungtu_printHSCT_All : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            var context = HttpContext.Current;

            string sql = CreateSql(context);

            // Nếu gọi từ chức năng gửi mail thì không chạy export Excel/PDF
            // để tránh lỗi OfficeToPDF 127.0.0.1:61892
            if (IsMailRequest())
            {
                Response.Clear();
                Response.ContentType = "text/html";
                Response.Charset = "UTF-8";

                DataTable dt = mdbc.GetData(sql);

                if (dt == null || dt.Rows.Count <= 0)
                {
                    Response.Write("Không có dữ liệu");
                    Response.End();
                    return;
                }

                string html = BuildMailHtml(dt);
                Response.Write(html);
                Response.End();
                return;
            }

            // Luồng cũ: dùng cho in / xuất Excel / PDF
            sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

            string nameTemp = "(CT) Chiết xuất hồ sơ.xls";
            string nameRpt = "Hồ sơ chứng từ";

            inPDF = "2";

            var task = new System.Threading.Tasks.Task(() =>
            {
                viewReport(sql);
            });

            var download = Request.QueryString["download"].removeAllSpaceOrTrimText(true);
            ReportViewer1.Attributes["download"] = string.IsNullOrWhiteSpace(download) ? "1" : download;

            PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, true);
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Response.End() sẽ phát sinh ThreadAbortException, bỏ qua lỗi này
        }
        catch (Exception ex)
        {
            Response.Clear();
            Response.StatusCode = 500;
            Response.ContentType = "text/plain";
            Response.Write(ex.ToString());
            Response.End();
        }
    }

    private bool IsMailRequest()
    {
        string idsForm = Request.Form["ids"];
        string idsQuery = Request.QueryString["ids"];
        string mail = Request.QueryString["mail"];

        return
            !string.IsNullOrWhiteSpace(idsForm)
            || !string.IsNullOrWhiteSpace(idsQuery)
            || mail == "1";
    }

    public void viewReport(string SqlQuery)
    {
        // Giữ lại để PrintAnco2.exportDataWithType dùng cho luồng in/xuất cũ
    }

    public string CreateSql(HttpContext context)
    {
        string tungay = Request.QueryString["tungay"];
        string denngay = Request.QueryString["denngay"];

        string idsRaw = Request.Form["ids"];

        if (string.IsNullOrWhiteSpace(idsRaw))
        {
            idsRaw = Request.QueryString["ids"];
        }

        string idSingle = Request.QueryString["id"];

        var ids = new List<string>();

        if (!string.IsNullOrWhiteSpace(idsRaw))
        {
            ids = idsRaw
                .Split(',')
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Select(s => s.Trim().Replace("'", "''"))
                .ToList();
        }

        if (ids.Count <= 0 && !string.IsNullOrWhiteSpace(idSingle))
        {
            ids.Add(idSingle.Trim().Replace("'", "''"));
        }

        string whereEX = "";
        string avaEX = "";

        if (ids.Count > 0)
        {
            tungay = "";
            denngay = "";
            whereEX = $"and dh.c_donhangchungtu_id in ('{string.Join("','", ids)}')";
        }
        else
        {
            if (string.IsNullOrWhiteSpace(tungay) || string.IsNullOrWhiteSpace(denngay))
            {
                throw new Exception("Không có ids hồ sơ chứng từ hoặc khoảng ngày để chiết xuất dữ liệu.");
            }

            avaEX = $@"
declare @tungay datetime = convert(datetime, '{tungay} 00:00:00', 103)
declare @denngay datetime = convert(datetime, '{denngay} 23:59:59', 103)
";

            whereEX = "and dh2.shipmenttime between @tungay and @denngay";
        }

        string sql = $@"
{avaEX}
select
    N'{tungay}' as tungay
    , N'{denngay}' as denngay
    , (
        case 
            when dh.trangthai = 'SOANTHAO' then N'Soạn Thảo'
            when dh.trangthai = 'HIEULUC' then N'Hiệu lực'
            when dh.trangthai = 'DAGUIBC' then N'Đã gửi book container'
            when dh.trangthai = 'DACOLT' then N'Đã có lịch tàu'
            when dh.trangthai = 'DAKEOC' then N'Đã kéo cont/xuất hàng'
            when dh.trangthai = 'KETTHUC' then N'Kết thúc'
            else '' 
        end
    ) as trangthai
    , kh.ma_dtkd
    , dh2.sochungtu
    , dh2.customer_order_no
    , spd.POD
    , dh2.shipmenttime
    , DATEADD(day, -7, dh2.shipmenttime) as hangiaohang_po
    , dh.ngaydieuchinh
    , dh2.ngaypass
    , dh.ngaychuyenhoso
    , dh2.nguoilap
    , dh.nhanvienCT
    , dh.cont20
    , dh.cont40
    , dh.cont40hc
    , dh.cont45
    , dh.contLCL
    , dh.dongghep
    , spd.Forwarder
    , dh.ngayBookCont
    , dh.bookingNo
    , dh.ngayETD
    , dh.ngayETA
    , dh.ngayBHXN
    , dh.ngayXuong
    , dh.ngayCutOff
    , dh.mota
FROM c_donhangchungtu dh
    left join c_donhang dh2 
        on dh2.c_donhang_id = dh.c_donhang_id
    left join md_doitackinhdoanh kh 
        on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
    outer apply (
        select top 1 
            POD, 
            Forwarder 
        from c_donhang_spd 
        where c_donhang_id = dh2.c_donhang_id 
            and trangthai = 'DAGUI' 
        order by ngaytao desc
    ) spd
WHERE 1=1
    {whereEX}
order by dh.ngaytao desc
";

        return sql;
    }

    private string BuildMailHtml(DataTable dt)
    {
        StringBuilder sb = new StringBuilder();

        sb.Append(@"
<div style='font-family:Arial;font-size:13px'>
    <p>Danh sách hồ sơ chứng từ:</p>
    <table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse;width:100%;font-size:13px'>
        <thead>
            <tr style='background:#f2f2f2;font-weight:bold;text-align:center'>
                <th>Trạng thái</th>
                <th>Mã khách</th>
                <th>Số PO</th>
                <th>Số order no</th>
                <th>POD</th>
                <th>Shipment time</th>
                <th>NXH của xưởng</th>
                <th>Ngày điều chỉnh</th>
                <th>Ngày pass</th>
                <th>Ngày chuyển hồ sơ</th>
                <th>NV bán hàng</th>
                <th>NV chứng từ</th>
                <th>Cont 20</th>
                <th>40DC</th>
                <th>40HC</th>
                <th>45</th>
                <th>LCL</th>
                <th>Đóng ghép</th>
                <th>Forwarder</th>
                <th>Booking no</th>
                <th>ETD</th>
                <th>ETA</th>
                <th>Ngày BHXN</th>
                <th>Ngày xưởng</th>
                <th>Cut off</th>
                <th>Ghi chú</th>
            </tr>
        </thead>
        <tbody>
");

        foreach (DataRow row in dt.Rows)
        {
            sb.Append("<tr>");
            sb.Append(Td(row, "trangthai"));
            sb.Append(Td(row, "ma_dtkd"));
            sb.Append(Td(row, "sochungtu"));
            sb.Append(Td(row, "customer_order_no"));
            sb.Append(Td(row, "POD"));
            sb.Append(TdDate(row, "shipmenttime"));
            sb.Append(TdDate(row, "hangiaohang_po"));
            sb.Append(TdDate(row, "ngaydieuchinh"));
            sb.Append(TdDate(row, "ngaypass"));
            sb.Append(TdDate(row, "ngaychuyenhoso"));
            sb.Append(Td(row, "nguoilap"));
            sb.Append(Td(row, "nhanvienCT"));
            sb.Append(TdNumber(row, "cont20"));
            sb.Append(TdNumber(row, "cont40"));
            sb.Append(TdNumber(row, "cont40hc"));
            sb.Append(TdNumber(row, "cont45"));
            sb.Append(TdNumber(row, "contLCL"));
            sb.Append(Td(row, "dongghep"));
            sb.Append(Td(row, "Forwarder"));
            sb.Append(Td(row, "bookingNo"));
            sb.Append(TdDate(row, "ngayETD"));
            sb.Append(TdDate(row, "ngayETA"));
            sb.Append(TdDate(row, "ngayBHXN"));
            sb.Append(TdDate(row, "ngayXuong"));
            sb.Append(TdDate(row, "ngayCutOff"));
            sb.Append(Td(row, "mota"));
            sb.Append("</tr>");
        }

        sb.Append(@"
        </tbody>
    </table>
</div>
");

        return sb.ToString();
    }

    private string Td(DataRow row, string columnName)
    {
        string value = GetValue(row, columnName);
        return $"<td>{HttpUtility.HtmlEncode(value)}</td>";
    }

    private string TdNumber(DataRow row, string columnName)
    {
        string value = GetValue(row, columnName);
        return $"<td style='text-align:right'>{HttpUtility.HtmlEncode(value)}</td>";
    }

    private string TdDate(DataRow row, string columnName)
    {
        string value = "";

        if (row.Table.Columns.Contains(columnName) && row[columnName] != DBNull.Value)
        {
            DateTime d;
            if (DateTime.TryParse(row[columnName].ToString(), out d))
            {
                value = d.ToString("dd/MM/yyyy");
            }
        }

        return $"<td style='text-align:center'>{HttpUtility.HtmlEncode(value)}</td>";
    }

    private string GetValue(DataRow row, string columnName)
    {
        if (!row.Table.Columns.Contains(columnName))
        {
            return "";
        }

        if (row[columnName] == null || row[columnName] == DBNull.Value)
        {
            return "";
        }

        return row[columnName].ToString();
    }
}











//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Web;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//public partial class Views_hosochungtu_printHSCT_All : System.Web.UI.Page
//{
//    public string logo = "", sothapphan = "", inPDF = "";
//    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
//    public HttpContext context = HttpContext.Current;
//    protected void Page_Load(object sender, EventArgs e)
//    {
//        try
//        {
//            var context = HttpContext.Current;
//            sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

//            string nameTemp = "(CT) Chiết xuất hồ sơ.xls";
//            string nameRpt = "Hồ sơ chứng từ";
//            string sql = CreateSql(context);

//            inPDF = "2";

//            var task = new System.Threading.Tasks.Task(() =>
//            {
//                viewReport(sql);
//            });

//            var download = Request.QueryString["download"].removeAllSpaceOrTrimText(true);
//            ReportViewer1.Attributes["download"] = string.IsNullOrWhiteSpace(download) ? "1" : download;

//            PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, true);
//        }
//        catch (Exception ex)
//        {
//            Response.StatusCode = 500;
//            Response.ContentType = "text/plain";
//            Response.Write(ex.ToString());
//            Response.End();
//        }
//    }
//    protected void Page_LoadGoc(object sender, EventArgs e)
//    {
//        var context = HttpContext.Current;
//        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);

//        string nameTemp = "(CT) Chiết xuất hồ sơ.xls";
//        string nameRpt = "Hồ sơ chứng từ";
//        string sql = CreateSql(context);

//        inPDF = "2";
//        var task = new System.Threading.Tasks.Task(() =>
//        {
//            viewReport(sql);
//        });

//        var download = Request.QueryString["download"].removeAllSpaceOrTrimText(true);
//        ReportViewer1.Attributes["download"] = string.IsNullOrWhiteSpace(download) ? "1" : download;
//        PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, true);
//    }

//    public void viewReport(String SqlQuery)
//    {

//    }
//    public string CreateSql(HttpContext context)
//    {
//        string tungay = Request.QueryString["tungay"];
//        string denngay = Request.QueryString["denngay"];

//        string idsRaw = Request.Form["ids"];

//        if (string.IsNullOrWhiteSpace(idsRaw))
//        {
//            idsRaw = Request.QueryString["ids"];
//        }

//        string idSingle = Request.QueryString["id"];

//        var ids = new List<string>();

//        if (!string.IsNullOrWhiteSpace(idsRaw))
//        {
//            ids = idsRaw
//                .Split(',')
//                .Where(s => !string.IsNullOrWhiteSpace(s))
//                .Select(s => s.Trim().Replace("'", "''"))
//                .ToList();
//        }

//        if (ids.Count <= 0 && !string.IsNullOrWhiteSpace(idSingle))
//        {
//            ids.Add(idSingle.Trim().Replace("'", "''"));
//        }

//        string whereEX = "";
//        string avaEX = "";

//        if (ids.Count > 0)
//        {
//            tungay = "";
//            denngay = "";
//            whereEX = $"and dh.c_donhangchungtu_id in ('{string.Join("','", ids)}')";
//        }
//        else
//        {
//            if (string.IsNullOrWhiteSpace(tungay) || string.IsNullOrWhiteSpace(denngay))
//            {
//                throw new Exception("Không có ids hồ sơ chứng từ hoặc khoảng ngày để chiết xuất dữ liệu.");
//            }

//            avaEX = $@"
//        declare @tungay datetime = convert(datetime, '{tungay} 00:00:00', 103)
//        declare @denngay datetime = convert(datetime, '{denngay} 23:59:59', 103)
//        ";

//            whereEX = "and dh2.shipmenttime between @tungay and @denngay";
//        }

//        string sql = $@"
//        {avaEX}
//        select
//            N'{tungay}' as tungay
//            , N'{denngay}' as denngay
//            , (
//                case 
//                    when dh.trangthai = 'SOANTHAO' then N'Soạn Thảo'
//                    when dh.trangthai = 'HIEULUC' then N'Hiệu lực'
//                    when dh.trangthai = 'DAGUIBC' then N'Đã gửi book container'
//                    when dh.trangthai = 'DACOLT' then N'Đã có lịch tàu'
//                    when dh.trangthai = 'DAKEOC' then N'Đã kéo cont/xuất hàng'
//                    when dh.trangthai = 'KETTHUC' then N'Kết thúc'
//                    else '' 
//                end
//            ) as trangthai
//            , kh.ma_dtkd
//            , dh2.sochungtu
//            , dh2.customer_order_no
//            , spd.POD
//            , dh2.shipmenttime
//            , DATEADD(day, -7, dh2.shipmenttime) as hangiaohang_po
//            , dh.ngaydieuchinh
//            , dh2.ngaypass
//            , dh.ngaychuyenhoso
//            , dh2.nguoilap
//            , dh.nhanvienCT
//            , dh.cont20
//            , dh.cont40
//            , dh.cont40hc
//            , dh.cont45
//            , dh.contLCL
//            , dh.dongghep
//            , spd.Forwarder
//            , dh.ngayBookCont
//            , dh.bookingNo
//            , dh.ngayETD
//            , dh.ngayETA
//            , dh.ngayBHXN
//            , dh.ngayXuong
//            , dh.ngayCutOff
//            , dh.mota
//        FROM c_donhangchungtu dh
//            left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
//            left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
//            outer apply (
//                select top 1 POD, Forwarder 
//                from c_donhang_spd 
//                where c_donhang_id = dh2.c_donhang_id 
//                    and trangthai = 'DAGUI' 
//                order by ngaytao desc
//            ) spd
//        WHERE 1=1
//            {whereEX}
//        order by dh.ngaytao desc
//    ";

//        return sql;
//    }
//    public string CreateSqlGoc(HttpContext context)
//    {
//        var tungay = Request.QueryString["tungay"];
//        var denngay = Request.QueryString["denngay"];
//        var ids = Request.Form["ids"].removeAllSpaceOrTrimText(false).Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
//        string whereEX = "";
//        string avaEX = "";
//        if(ids.Count > 0)
//        {
//            tungay = "        ";
//            denngay = "        ";
//            whereEX = $"and dh.c_donhangchungtu_id in ('{string.Join("','", ids)}')";
//        }
//        else
//        {
//            avaEX = $@"
//            declare @tungay datetime = convert(datetime, '{tungay} 00:00:00', 103)
//            declare @denngay datetime = convert(datetime, '{denngay} 23:59:59', 103)
//            ";
//            whereEX = $"and dh2.shipmenttime between @tungay and @denngay";
//        }

//        string sql = $@"
//            {avaEX}
//            select
//                '{tungay}' as tungay
//                , '{denngay}' as denngay
//                , (
//                    case 
//                        when dh.trangthai = 'SOANTHAO' then N'Soạn Thảo'
//                        when dh.trangthai = 'HIEULUC' then N'Hiệu lực'
//                        when dh.trangthai = 'DAGUIBC' then N'Đã gửi book container'
//                        when dh.trangthai = 'DACOLT' then N'Đã có lịch tàu'
//                        when dh.trangthai = 'DAKEOC' then N'Đã kéo cont/xuất hàng'
//                        when dh.trangthai = 'KETTHUC' then N'Kết thúc'
//                        else '' 
//                    end
//                ) as trangthai
//                , kh.ma_dtkd
//                , dh2.sochungtu
//                , dh2.customer_order_no
//                , spd.POD
//                , dh2.shipmenttime
//                , DATEADD(day, -7, dh2.shipmenttime) as hangiaohang_po
//                , dh.ngaydieuchinh
//                , dh2.ngaypass
//                , dh.ngaychuyenhoso
//                , dh2.nguoilap
//                , dh.nhanvienCT
//                , dh.cont20
//                , dh.cont40
//                , dh.cont40hc
//                , dh.cont45
//                , dh.contLCL
//                , dh.dongghep
//                , spd.Forwarder
//                , dh.ngayBookCont
//                , dh.bookingNo
//                , dh.ngayETD
//                , dh.ngayETA
//                , dh.ngayBHXN
//                , dh.ngayXuong
//                , dh.ngayCutOff
//                , dh.mota
//            FROM c_donhangchungtu dh
//                left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
//                left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
//                outer apply (select top 1 POD, Forwarder from c_donhang_spd where c_donhang_id = dh2.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
//            WHERE 1=1
//                {whereEX}
//            order by dh.ngaytao desc
//		";

//        //throw new ArgumentNullException(sql);
//        return sql;
//    }
//}