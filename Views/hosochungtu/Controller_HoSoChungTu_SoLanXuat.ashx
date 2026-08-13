<%@ WebHandler Language="C#" Class="Controller_HoSoChungTu_SoLanXuat" %>
using System;
using System.Web;
using System.Data;
using System.Linq;

public class Controller_HoSoChungTu_SoLanXuat : IHttpHandler, IDisposable
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void Dispose()
    {
        if (db != null)
        {
            db.Dispose();
            db = null;
        }
    }


    public void ProcessRequest(HttpContext context)
    {
        context.DisposeOnPipelineCompleted(this);

        string action = context.Request.QueryString["action"] ?? context.Request.Form["action"] ?? "";
        string oper = context.Request.Form["oper"] ?? "";

        switch (action)
        {
            case "getNvctOption":
                this.getNvctOption(context);
                break;

            default:
                switch (oper)
                {
                    case "edit":
                        this.edit(context);
                        break;

                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public void getNvctOption(HttpContext context)
    {
        context.Response.ContentType = "text/html";
        context.Response.Charset = "UTF-8";

        var nvs = db.nhanviens
            .OrderBy(s => s.manv)
            .ToList();

        string html = "<select>";

        html += "<option value=\"\"></option>";

        foreach (var nv in nvs)
        {
            string value = nv.manv ?? "";
            string text = nv.manv ?? "";

            if (!string.IsNullOrWhiteSpace(nv.hoten))
            {
                text = nv.manv + " - " + nv.hoten;
            }

            html += "<option value=\"" + HttpUtility.HtmlEncode(value) + "\">"
                 + HttpUtility.HtmlEncode(text)
                 + "</option>";
        }

        html += "</select>";

        context.Response.Write(html);
    }


    private DateTime? ToDateSafe(string value)
    {
        value = (value ?? "").removeAllSpaceOrTrimText(true);

        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        // jqGrid có thể gửi: 08/06/2026 00:00
        // Hệ thống chỉ nhận: dd/MM/yyyy
        if (value.Length >= 10)
        {
            value = value.Substring(0, 10);
        }

        try
        {
            return value.ToNullableDate();
        }
        catch
        {
            return null;
        }
    }

    private string DateToSqlText(DateTime? value)
    {
        if (value.HasValue)
        {
            return value.Value.ToString("dd/MM/yyyy");
        }

        return "";
    }

    public void edit(HttpContext context)
    {
        string msg = "";

        string id = context.Request.Form["id"] ?? "";

        decimal? cont20 = (context.Request.Form["cont20"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
        decimal? cont40 = (context.Request.Form["cont40"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
        decimal? cont40hc = (context.Request.Form["cont40hc"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
        decimal? cont45 = (context.Request.Form["cont45"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
        decimal? contLCL = (context.Request.Form["contLCL"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();

        string mota = (context.Request.Form["mota"] ?? "").removeAllSpaceOrTrimText(true);
        string bookingNo = (context.Request.Form["bookingNo"] ?? "").removeAllSpaceOrTrimText(true);
        string trangthai = (context.Request.Form["trangthai"] ?? "").removeAllSpaceOrTrimText(true);
        string trangthai2 = (context.Request.Form["trangthai2"] ?? "").removeAllSpaceOrTrimText(true);
        string nhanvienCT = (context.Request.Form["nhanvienCT"] ?? "").removeAllSpaceOrTrimText(true);
        string ghichusau = (context.Request.Form["ghichusau"] ?? "").removeAllSpaceOrTrimText(true);
        string ketquakiemhang = (context.Request.Form["ketquakiemhang"] ?? "").removeAllSpaceOrTrimText(true);

        DateTime? ngaydieuchinh = ToDateSafe(context.Request.Form["ngaydieuchinh"]);
        DateTime? ngayETD = ToDateSafe(context.Request.Form["ngayETD"]);
        DateTime? ngayETA = ToDateSafe(context.Request.Form["ngayETA"]);
        DateTime? ngayBHXN = ToDateSafe(context.Request.Form["ngayBHXN"]);
        DateTime? ngayXuong = ToDateSafe(context.Request.Form["ngayXuong"]);
        DateTime? ngayCutOff = ToDateSafe(context.Request.Form["ngayCutOff"]);
        DateTime? ngayBookCont = ToDateSafe(context.Request.Form["ngayBookCont"]);
        DateTime? ngayKeoCont = ToDateSafe(context.Request.Form["ngayKeoCont"]);
        DateTime? ngaykiemhangpass = ToDateSafe(context.Request.Form["ngaykiemhangpass"]);

        string dahonthanhStr = (context.Request.Form["dahonthanh"] ?? "").ToLower();
        bool dahonthanh = dahonthanhStr == "true" || dahonthanhStr == "on" || dahonthanhStr == "1";

        try
        {
            if (string.IsNullOrWhiteSpace(id))
            {
                msg = "Không tìm thấy dòng số lần xuất cần cập nhật.";
                goto EndEventHandler;
            }

            DataTable dtLog = mdbc.GetData(@"
    SELECT TOP 1
        id,
        c_donhangchungtu_id,
        c_donhang_id,
        ISNULL(dahonthanh, 0) AS dahonthanh,
        ISNULL(bookingNo, '') AS bookingNo,
        ngayBookCont,
        ngayKeoCont
    FROM c_donhangchungtu_xuat_log
    WHERE id = @id
", "@id", id);

            if (dtLog.Rows.Count <= 0)
            {
                msg = "Không tìm thấy dòng số lần xuất cần cập nhật.";
                goto EndEventHandler;
            }

            bool daHoanThanhCu = false;

            try
            {
                daHoanThanhCu = Convert.ToBoolean(dtLog.Rows[0]["dahonthanh"]);
            }
            catch
            {
                daHoanThanhCu = false;
            }

            // Lấy dữ liệu cũ của chính dòng log đang sửa
            string bookingNoCuCuaDongLog = "";

            try
            {
                bookingNoCuCuaDongLog = (dtLog.Rows[0]["bookingNo"] ?? "").ToString();
            }
            catch
            {
                bookingNoCuCuaDongLog = "";
            }

            DateTime? ngayBookContCuCuaDongLog = null;

            try
            {
                if (dtLog.Rows[0]["ngayBookCont"] != DBNull.Value)
                {
                    ngayBookContCuCuaDongLog = Convert.ToDateTime(dtLog.Rows[0]["ngayBookCont"]);
                }
            }
            catch
            {
                ngayBookContCuCuaDongLog = null;
            }

            DateTime? ngayKeoContCuCuaDongLog = null;

            try
            {
                if (dtLog.Rows[0]["ngayKeoCont"] != DBNull.Value)
                {
                    ngayKeoContCuCuaDongLog = Convert.ToDateTime(dtLog.Rows[0]["ngayKeoCont"]);
                }
            }
            catch
            {
                ngayKeoContCuCuaDongLog = null;
            }
            // Lấy Booking No cũ của chính dòng đang sửa trong c_donhangchungtu_xuat_log
            //string bookingNoCuCuaDongLog = "";

            //try
            //{
            //    bookingNoCuCuaDongLog = (dtLog.Rows[0]["bookingNo"] ?? "").ToString();
            //}
            //catch
            //{
            //    bookingNoCuCuaDongLog = "";
            //}

            // Lấy ngày book cont cũ của chính dòng log
            //DateTime? ngayBookContCuCuaDongLog = null;

            //try
            //{
            //    if (dtLog.Rows[0]["ngayBookCont"] != DBNull.Value)
            //    {
            //        ngayBookContCuCuaDongLog = Convert.ToDateTime(dtLog.Rows[0]["ngayBookCont"]);
            //    }
            //}
            //catch
            //{
            //    ngayBookContCuCuaDongLog = null;
            //}



            if (daHoanThanhCu)
            {
                msg = "Dòng này đã hoàn thành, không được phép chỉnh sửa nữa.";
                goto EndEventHandler;
            }

            string hsctId = dtLog.Rows[0]["c_donhangchungtu_id"].ToString();

            if (string.IsNullOrWhiteSpace(hsctId))
            {
                msg = "Dòng số lần xuất chưa có liên kết hồ sơ chứng từ.";
                goto EndEventHandler;
            }

            var hsct = db.c_donhangchungtus
                .Where(s => s.c_donhangchungtu_id == hsctId)
                .FirstOrDefault();

            if (hsct == null)
            {
                msg = "Không tìm thấy hồ sơ chứng từ liên kết.";
                goto EndEventHandler;
            }

            //if (hsct.trangthai == Helper.KETTHUC)
            //{
            //    msg = "Hồ sơ chứng từ đã Kết Thúc, không được cập nhật.";
            //    goto EndEventHandler;
            //}
            if (!string.IsNullOrWhiteSpace(hsct.dongghep))
            {
                msg = $@"Hồ sơ thuộc đơn hàng được ghép, vui lòng sửa hồ sơ có đơn hàng ưu tiên ""{hsct.dongghep}""";
                goto EndEventHandler;
            }

            //if (hsct.trangthai == Helper.KETTHUC)
            //{
            //    msg = "Hồ sơ chứng từ đã Kết Thúc, không được cập nhật.";
            //    goto EndEventHandler;
            //}

            //if (hsct.trangthai != Helper.HIEULUC)
            //{
            //    msg = "Chỉ được cập nhật số lần xuất khi hồ sơ chứng từ ở trạng thái Hiệu lực.";
            //    goto EndEventHandler;
            //}
            if (hsct.trangthai == Helper.SOANTHAO)
            {
                msg = "Hồ sơ chứng từ đang ở trạng thái Soạn Thảo, không được cập nhật số lần xuất.";
                goto EndEventHandler;
            }

            if (hsct.trangthai == Helper.KETTHUC)
            {
                msg = "Hồ sơ chứng từ đã Kết Thúc, không được cập nhật.";
                goto EndEventHandler;
            }

            //string user = UserUtils.getUser(context);
            string user = UserUtils.getUser(context) ?? "";

            string ngaydieuchinhSqlText = "";
            if (ngaydieuchinh.HasValue)
            {
                ngaydieuchinhSqlText = ngaydieuchinh.Value.ToString("dd/MM/yyyy");
            }



            // 2. Cập nhật đồng thời lên bảng c_donhangchungtu
            // 2. Cập nhật đồng thời lên bảng c_donhangchungtu
            hsct.cont20 = cont20;
            hsct.cont40 = cont40;
            hsct.cont40hc = cont40hc;
            hsct.cont45 = cont45;
            hsct.contLCL = contLCL;

            // Không cho quay lại Soạn Thảo giống grid_ds_hosochungtu

            //if (hsct.trangthai != Helper.SOANTHAO && trangthai == Helper.SOANTHAO)
            //{
            //    msg = "Hồ sơ đã Hiệu lực trước đó, không được chuyển về Soạn Thảo.";
            //    goto EndEventHandler;
            //}

            if (!string.IsNullOrWhiteSpace(trangthai2))
            {
                hsct.trangthai2 = trangthai2;
            }

            //hsct.bookingNo = bookingNo;
            //hsct.ngayETD = ngayETD;
            //hsct.ngayETA = ngayETA;
            //hsct.ngayBHXN = ngayBHXN;




            // Cập nhật trạng thái theo đúng trình tự cho từng dòng grid_solanxuat
            // Kiểm tra theo dữ liệu của c_donhangchungtu_xuat_log dòng hiện tại.
            // Nếu form có gửi field thì dùng giá trị người dùng vừa nhập.
            // Nếu form không gửi field thì fallback về dữ liệu cũ trong log.

            bool formCoNgayBookCont = context.Request.Form["ngayBookCont"] != null;
            bool formCoBookingNo = context.Request.Form["bookingNo"] != null;
            bool formCoNgayKeoCont = context.Request.Form["ngayKeoCont"] != null;

            DateTime? ngayBookContLogSauLuu = formCoNgayBookCont
                ? ngayBookCont
                : ngayBookContCuCuaDongLog;

            string bookingNoLogSauLuu = formCoBookingNo
                ? bookingNo
                : bookingNoCuCuaDongLog;

            DateTime? ngayKeoContLogSauLuu = formCoNgayKeoCont
                ? ngayKeoCont
                : ngayKeoContCuCuaDongLog;

            bool coNgayBookCont = ngayBookContLogSauLuu.HasValue;
            bool coBookingNo = !string.IsNullOrWhiteSpace(bookingNoLogSauLuu);
            bool coNgayKeoCont = ngayKeoContLogSauLuu.HasValue;

            // Bước 1: Có ngày book container
            // => cập nhật c_donhangchungtu.trangthai = Đã gửi book container
            if (coNgayBookCont)
            {
                hsct.trangthai = Helper.DAGUIBC;
            }

            // Bước 2: Có Booking No
            // => bắt buộc dòng log phải có ngày book container
            // => cập nhật c_donhangchungtu.trangthai = Đã có lịch tàu
            if (coBookingNo)
            {
                if (!coNgayBookCont)
                {
                    msg = "Cần điền ngày book container trước khi điền Booking No.";
                    goto EndEventHandler;
                }

                hsct.trangthai = Helper.DACOLT;
            }

            // Bước 3: Có ngày kéo cont / xuất hàng
            // => bắt buộc dòng log phải có ngày book container và Booking No
            // => cập nhật c_donhangchungtu.trangthai = Đã kéo cont/xuất hàng
            if (coNgayKeoCont)
            {
                if (!coNgayBookCont)
                {
                    msg = "Cần điền ngày book container trước khi điền ngày kéo cont / xuất hàng.";
                    goto EndEventHandler;
                }

                if (!coBookingNo)
                {
                    msg = "Cần điền Booking No trước khi điền ngày kéo cont / xuất hàng.";
                    goto EndEventHandler;
                }

                hsct.trangthai = Helper.DAKEOC;
            }

            // Cập nhật lại c_donhangchungtu theo dữ liệu sau lưu của dòng log
            hsct.ngayBookCont = ngayBookContLogSauLuu;
            hsct.bookingNo = bookingNoLogSauLuu;
            hsct.ngayKeoCont = ngayKeoContLogSauLuu;







            hsct.ngayETD = ngayETD;
            hsct.ngayETA = ngayETA;
            hsct.ngayBHXN = ngayBHXN;


            hsct.ngayXuong = ngayXuong;
            hsct.ngayCutOff = ngayCutOff;
            hsct.ngaydieuchinh = ngaydieuchinh;
            //hsct.ngayBookCont = ngayBookCont;
            //hsct.ngayKeoCont = ngayKeoCont;
            hsct.ngaykiemhangpass = ngaykiemhangpass;
            hsct.ketquakiemhang = ketquakiemhang;
            hsct.mota = mota;
            hsct.ghichusau = ghichusau;

            if (!string.IsNullOrWhiteSpace(nhanvienCT))
            {
                hsct.nhanvienCT = nhanvienCT;
            }
            // Nếu tick Đã hoàn thành ở grid_solanxuat
            // thì cập nhật trạng thái hồ sơ chứng từ về Hiệu lực
            if (dahonthanh)
            {
                hsct.trangthai = Helper.HIEULUC;
            }

            hsct.ngaycapnhat = DateTime.Now;
            hsct.nguoicapnhat = user;




            // Cập nhật đầy đủ dữ liệu vào bảng log số lần xuất
            string logNgayDieuChinhText = DateToSqlText(hsct.ngaydieuchinh);
            string logNgayETDText = DateToSqlText(hsct.ngayETD);
            string logNgayETAText = DateToSqlText(hsct.ngayETA);
            string logNgayBHXNText = DateToSqlText(hsct.ngayBHXN);
            string logNgayXuongText = DateToSqlText(hsct.ngayXuong);
            string logNgayCutOffText = DateToSqlText(hsct.ngayCutOff);
            string logNgayPassText = DateToSqlText(hsct.ngaypass);
            string logNgayChuyenHoSoText = DateToSqlText(hsct.ngaychuyenhoso);
            string logNgayBookContText = DateToSqlText(hsct.ngayBookCont);
            string logNgayKeoContText = DateToSqlText(hsct.ngayKeoCont);
            string logNgayKiemHangPassText = DateToSqlText(hsct.ngaykiemhangpass);

            db.ExecuteCommand(@"
                UPDATE c_donhangchungtu_xuat_log
                SET
                    cont20 = {0},
                    cont40 = {1},
                    cont40hc = {2},
                    cont45 = {3},
                    contLCL = {4},

                    ngaydieuchinh = CASE WHEN {5} = '' THEN NULL ELSE CONVERT(datetime, {5}, 103) END,
                    mota = {6},

                    dahonthanh = {7},
                    ngayhoanthanh = CASE WHEN {7} = 1 THEN GETDATE() ELSE ngayhoanthanh END,
                    nguoihoanthanh = CASE WHEN {7} = 1 THEN {8} ELSE nguoihoanthanh END,

                    trangthai = {9},
                    trangthai2 = {10},
                    bookingNo = {11},

                    ngayETD = CASE WHEN {12} = '' THEN NULL ELSE CONVERT(datetime, {12}, 103) END,
                    ngayETA = CASE WHEN {13} = '' THEN NULL ELSE CONVERT(datetime, {13}, 103) END,
                    ngayBHXN = CASE WHEN {14} = '' THEN NULL ELSE CONVERT(datetime, {14}, 103) END,
                    ngayXuong = CASE WHEN {15} = '' THEN NULL ELSE CONVERT(datetime, {15}, 103) END,
                    ngayCutOff = CASE WHEN {16} = '' THEN NULL ELSE CONVERT(datetime, {16}, 103) END,
                    ngaypass = CASE WHEN {17} = '' THEN NULL ELSE CONVERT(datetime, {17}, 103) END,
                    ngaychuyenhoso = CASE WHEN {18} = '' THEN NULL ELSE CONVERT(datetime, {18}, 103) END,

                    nhanvienCT = {19},

                    ngayBookCont = CASE WHEN {20} = '' THEN NULL ELSE CONVERT(datetime, {20}, 103) END,
                    ngayKeoCont = CASE WHEN {21} = '' THEN NULL ELSE CONVERT(datetime, {21}, 103) END,

                    ghichusau = {22},
                    ngaykiemhangpass = CASE WHEN {23} = '' THEN NULL ELSE CONVERT(datetime, {23}, 103) END,
                    ketquakiemhang = {24},
                    dongghep = {25},

                    ngaycapnhat = GETDATE(),
                    nguoicapnhat = {8}
                WHERE id = {26}
            ",
                cont20.GetValueOrDefault(0),
                cont40.GetValueOrDefault(0),
                cont40hc.GetValueOrDefault(0),
                cont45.GetValueOrDefault(0),
                contLCL.GetValueOrDefault(0),

                logNgayDieuChinhText,
                mota ?? "",

                dahonthanh ? 1 : 0,
                user,

                hsct.trangthai ?? "",
                hsct.trangthai2 ?? "",
                hsct.bookingNo ?? "",

                logNgayETDText,
                logNgayETAText,
                logNgayBHXNText,
                logNgayXuongText,
                logNgayCutOffText,
                logNgayPassText,
                logNgayChuyenHoSoText,

                hsct.nhanvienCT ?? "",

                logNgayBookContText,
                logNgayKeoContText,

                hsct.ghichusau ?? "",
                logNgayKiemHangPassText,
                hsct.ketquakiemhang ?? "",
                hsct.dongghep ?? "",

                id ?? ""
            );




            // 3. Nếu có ngày bán hàng XNXH thì cập nhật ngược về đơn hàng
            var donhang = db.c_donhangs
                .Where(s => s.c_donhang_id == hsct.c_donhang_id)
                .FirstOrDefault();


            if (donhang != null)
            {
                donhang.ngayBHXN = hsct.ngayBHXN;
                // Hồ sơ vẫn đang hiệu lực chứng từ
                if (dahonthanh)
                {
                    donhang.trangthaict = Helper.DAHIEULUC;
                }
                donhang.ngaycapnhat = DateTime.Now;
                donhang.nguoicapnhat = user;
            }

            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
        else
        {
            jqGridHelper.Utils.writeResult(1, "Cập nhật số lần xuất thành công.");
        }
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        string poId = context.Request.QueryString["poId"] ?? "";
        poId = poId.Replace("'", "''");

        string filter = "";
        bool _search = false;
        bool.TryParse(context.Request.QueryString["_search"], out _search);

        if (_search)
        {
            string _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        string sqlCount = $@"
            SELECT COUNT(1) AS count
            FROM c_donhangchungtu_xuat_log log
            WHERE 1=1 {filter}
            AND log.c_donhang_id = '{poId}'
        ";

        int page = int.Parse(context.Request.QueryString["page"]);
        int limit = int.Parse(context.Request.QueryString["rows"]);
        string sidx = context.Request.QueryString["sidx"];
        string sord = context.Request.QueryString["sord"];

        if (string.IsNullOrWhiteSpace(sidx))
            sidx = "log.sothutu";

        if (string.IsNullOrWhiteSpace(sord))
            sord = "DESC";

        int count = (int)mdbc.ExecuteScalar(sqlCount);
        int total_page = count > 0 ? (int)Math.Ceiling(1.0 * count / limit) : 0;

        if (page > total_page) page = total_page;

        int start = limit * page - limit;
        int end = (page * limit) + 1;

        string strsql = $@"
    SELECT
        id,
        c_donhangchungtu_id,
        c_donhang_id,
        dahonthanh,

        trangthai,
        trangthai2,
        ma_dtkd,

        sothutu,
        loaichuyen,
        sochungtu,
        customer_order_no,
        donhanguutien,

        cont20,
        cont40,
        cont40hc,
        cont45,
        contLCL,
        dongghep,
        mota,

        bookingNo,
        ngayETD,
        ngayETA,
        ngayBHXN,
        ngayXuong,
        ngayCutOff,
        ngaypass,
        shipmenttime,
        hangiaohang_po,
        ngaydieuchinh,
        ngaychuyenhoso,
        nguoilap,
        nhanvienCT,
        Forwarder,
        ngayBookCont,
        POD,
        ngayKeoCont,
        ghichusau,
        ngaykiemhangpass,
        ketquakiemhang,

        ngayhoanthanh,
        nguoihoanthanh,
        ngaygui,
        nguoigui
    FROM
    (
        SELECT
            log.id,
            log.c_donhangchungtu_id,
            log.c_donhang_id,
            ISNULL(log.dahonthanh, 0) AS dahonthanh,

            log.trangthai,
            log.trangthai2,
            kh.ma_dtkd,

            log.sothutu,
            log.loaichuyen,
            log.sochungtu,
            dh.customer_order_no,
            log.donhanguutien,

            log.cont20,
            log.cont40,
            log.cont40hc,
            log.cont45,
            log.contLCL,

            log.dongghep,
            log.mota,

            log.bookingNo,
            log.ngayETD,
            log.ngayETA,
            log.ngayBHXN,
            log.ngayXuong,
            log.ngayCutOff,
            log.ngaypass,
            dh.shipmenttime,
            DATEADD(day, -7, dh.shipmenttime) AS hangiaohang_po,
            log.ngaydieuchinh,
            log.ngaychuyenhoso,
            dh.nguoilap,
            log.nhanvienCT,
            spd.Forwarder,
            log.ngayBookCont,
            spd.POD,
            log.ngayKeoCont,
            log.ghichusau,
            log.ngaykiemhangpass,
            log.ketquakiemhang,

            log.ngayhoanthanh,
            log.nguoihoanthanh,
            log.ngaygui,
            log.nguoigui,

            ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) AS RowNum
        FROM c_donhangchungtu_xuat_log log
            LEFT JOIN c_donhangchungtu hsct 
                ON hsct.c_donhangchungtu_id = log.c_donhangchungtu_id
            LEFT JOIN c_donhang dh 
                ON dh.c_donhang_id = log.c_donhang_id
            LEFT JOIN md_doitackinhdoanh kh 
                ON kh.md_doitackinhdoanh_id = dh.md_doitackinhdoanh_id
            OUTER APPLY (
                SELECT TOP 1 POD, Forwarder
                FROM c_donhang_spd
                WHERE c_donhang_id = dh.c_donhang_id
                    AND trangthai = 'DAGUI'
                ORDER BY ngaytao DESC
            ) spd
        WHERE 1=1 {filter}
            AND log.c_donhang_id = '{poId}'
    ) P
    WHERE RowNum > @start AND RowNum < @end
";

        DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);

        string xml = @"<?xml version=""1.0"" encoding=""UTF-8"" ?>";
        xml += "<rows>";
        xml += $"<page>{page}</page>";
        xml += $"<total>{total_page}</total>";
        xml += $"<records>{count}</records>";

        foreach (DataRow row in dt.Rows)
        {
            xml += "<row>";

            foreach (DataColumn column in dt.Columns)
            {
                if (column.DataType == typeof(DateTime))
                {
                    try
                    {
                        string colName = column.ColumnName;

                        if (
                            colName == "ngayETD"
                            || colName == "ngayETA"
                            || colName == "ngayBHXN"
                            || colName == "ngayXuong"
                            || colName == "ngayCutOff"
                            || colName == "ngaypass"
                            || colName == "shipmenttime"
                            || colName == "hangiaohang_po"
                            || colName == "ngaydieuchinh"
                            || colName == "ngaychuyenhoso"
                            || colName == "ngayBookCont"
                            || colName == "ngayKeoCont"
                            || colName == "ngaykiemhangpass"
                        )
                        {
                            xml += $"<cell><![CDATA[{((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy")}]]></cell>";
                        }
                        else
                        {
                            xml += $"<cell><![CDATA[{((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy HH:mm")}]]></cell>";
                        }
                    }
                    catch
                    {
                        xml += "<cell><![CDATA[]]></cell>";
                    }
                }
                else
                {
                    xml += $"<cell><![CDATA[{row[column.ColumnName]}]]></cell>";
                }
            }

            xml += "</row>";
        }

        xml += "</rows>";
        context.Response.Write(xml);
    }

    public bool IsReusable
    {
        get { return false; }
    }
}