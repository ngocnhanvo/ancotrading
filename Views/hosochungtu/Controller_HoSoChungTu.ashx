<%@ WebHandler Language="C#" Class="Controller_HoSoChungTu" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
using System.Text;
public class Controller_HoSoChungTu : IHttpHandler, IDisposable
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
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "hieuluc":
                this.hieuluc(context);
                break;
            case "ketthuc":
                this.ketthuc(context);
                break;
            case "ngayBHXN":
                this.ngayBHXN(context);
                break;
            case "sendMail":
                this.sendMail(context);
                break;
            default:
                switch (oper)
                {
                    case "del":
                        this.del(context);
                        break;
                    case "edit":
                        this.edit(context);
                        break;
                    case "add":
                        this.add(context);
                        break;
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    private void tudong_CapNhatTrangThaiChoCacHoSoGhep(LinqDBDataContext dblc, c_donhangchungtu hsct, c_donhang donhang)
    {
        foreach (var hsctk in dblc.c_donhangchungtus.Where(s => s.dongghep == donhang.sochungtu & s.c_donhangchungtu_id != hsct.c_donhangchungtu_id))
        {
            hsctk.trangthai = hsct.trangthai;
            var donhangk = dblc.c_donhangs.Where(s => s.c_donhang_id == hsctk.c_donhang_id & s.trangthaict != Helper.DAHIEULUC).FirstOrDefault();
            if (donhangk != null)
            {
                if (hsctk.trangthai != Helper.SOANTHAO)
                {
                    donhangk.trangthaict = Helper.DAHIEULUC;
                }
            }
        }
    }

    public void hieuluc(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
            if (hsct == null)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (!string.IsNullOrWhiteSpace(hsct.dongghep))
            {
                msg = $@"Hồ sơ thuộc đơn hàng được ghép, vui lòng hiệu lực hồ sơ có đơn hàng ưu tiên ""{hsct.dongghep}""";
                goto EndEventHandler;
            }

            if (hsct.trangthai != Helper.SOANTHAO)
            {
                msg = $@"Hồ sơ không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
            if (donhang == null)
            {
                msg = $@"Hồ sơ chứa đơn hàng không tồn tại trong hệ thống";
                goto EndEventHandler;
            }

            hsct.trangthai = Helper.HIEULUC;
            hsct.ngaycapnhat = DateTime.Now;
            hsct.nguoicapnhat = UserUtils.getUser(context);
            donhang.trangthaict = Helper.DAHIEULUC;
            tudong_CapNhatTrangThaiChoCacHoSoGhep(db, hsct, donhang);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Hiệu lực thành công");
    }

    public void ketthuc(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
            if (hsct == null)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (!string.IsNullOrWhiteSpace(hsct.dongghep))
            {
                msg = $@"Hồ sơ thuộc đơn hàng được ghép, vui lòng kết thúc hồ sơ có đơn hàng ưu tiên ""{hsct.dongghep}""";
                goto EndEventHandler;
            }

            if (hsct.trangthai == Helper.SOANTHAO)
            {
                msg = $@"Hồ sơ vẫn còn đang Soạn Thảo";
                goto EndEventHandler;
            }

            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
            if (donhang == null)
            {
                msg = $@"Hồ sơ chứa đơn hàng không tồn tại trong hệ thống";
                goto EndEventHandler;
            }

            hsct.trangthai = Helper.KETTHUC;
            hsct.ngaycapnhat = DateTime.Now;
            hsct.nguoicapnhat = UserUtils.getUser(context);
            tudong_CapNhatTrangThaiChoCacHoSoGhep(db, hsct, donhang);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Kết thúc thành công");
    }
    public void sendMail(HttpContext context)
    {
        string msg = "";

        var ids = (context.Request.Form["ids"] ?? "")
            .removeAllSpaceOrTrimText(false)
            .Split(',')
            .Where(s => !string.IsNullOrEmpty(s))
            .ToList();

        var nvbhs = (context.Request.Form["nvbhs"] ?? "")
            .removeAllSpaceOrTrimText(false)
            .Split(',')
            .Where(s => !string.IsNullOrEmpty(s))
            .ToList();

        var nccs = (context.Request.Form["nccs"] ?? "")
            .removeAllSpaceOrTrimText(false)
            .Split(',')
            .Where(s => !string.IsNullOrEmpty(s))
            .ToList();

        string tt = context.Request.Form["tt"] ?? "";
        string ttBase64 = context.Request.Form["tt_base64"] ?? "";

        // Nếu JS gửi tt dạng Base64 thì giải mã lại thành HTML
        if (ttBase64 == "1" && !string.IsNullOrWhiteSpace(tt))
        {
            try
            {
                byte[] bytes = Convert.FromBase64String(tt);
                tt = Encoding.UTF8.GetString(bytes);
            }
            catch
            {
                tt = "";
            }
        }
        else
        {
            tt = tt.removeAllSpaceOrTrimText(true);
        }

        try
        {
            var hscts = db.c_donhangchungtus
                .Where(s => ids.Contains(s.c_donhangchungtu_id))
                .ToList();

            if (hscts.Count <= 0)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            var nvbhs2 = db.nhanviens
                .Where(s => nvbhs.Contains(s.manv))
                .OrderBy(s => s.email)
                .ToList();

            var nccs2 = db.md_doitackinhdoanhs
                .Where(s => nccs.Contains(s.ma_dtkd))
                .OrderBy(s => s.email)
                .ToList();

            if (nvbhs2.Count <= 0 && nccs2.Count <= 0)
            {
                msg = $@"Phải chọn nhân viên hoặc nhà cung cấp để gửi mail";
                goto EndEventHandler;
            }

            var arrDHs = new List<string>();

            foreach (var hsct in hscts)
            {
                var dh = db.c_donhangs
                    .Where(s => s.c_donhang_id == hsct.c_donhang_id)
                    .FirstOrDefault();

                if (dh != null)
                {
                    arrDHs.Add(dh.sochungtu);
                }
            }

            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));

            if (nv == null)
            {
                msg = "Không tìm thấy nhân viên đang đăng nhập.";
                goto EndEventHandler;
            }

            var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();

            if (!string.IsNullOrWhiteSpace(nv.smtp))
            {
                smtp = db.md_smtps.Where(s => s.md_smtp_id == nv.smtp).FirstOrDefault();
            }

            if (smtp == null)
            {
                msg = "Không tìm thấy cấu hình SMTP.";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(nv.email))
            {
                msg = "Nhân viên đang đăng nhập chưa cấu hình email gửi.";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(nv.email_pass))
            {
                msg = "Nhân viên đang đăng nhập chưa cấu hình mật khẩu email/app password.";
                goto EndEventHandler;
            }

            var mail = new GoogleMail();
            mail.Email = nv.email;
            mail.Password = nv.email_pass;
            mail.Smtp = smtp.smtpserver;
            mail.Port = smtp.port.Value;
            mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);

            string title = $@"Hồ sơ chứng từ của đơn hàng ""{string.Join(", ", arrDHs.OrderBy(s => s).ToList())}""";

            string body = "";
            var atts = new List<System.Net.Mail.Attachment>();

            // Trường hợp mới: tt là HTML nội dung mail
            bool ttIsHtml = !string.IsNullOrWhiteSpace(tt)
                && (
                    tt.IndexOf("<table", StringComparison.OrdinalIgnoreCase) >= 0
                    || tt.IndexOf("<div", StringComparison.OrdinalIgnoreCase) >= 0
                    || tt.IndexOf("<html", StringComparison.OrdinalIgnoreCase) >= 0
                );

            if (ttIsHtml)
            {
                body = tt;
            }
            else
            {
                // Trường hợp cũ: tt là đường dẫn file Excel
                if (!File.Exists(tt))
                {
                    msg = $@"Không chiết xuất được tập tin theo hồ sơ đã chọn";
                    goto EndEventHandler;
                }

                body = $@"Chi tiết vui lòng xem ở tập tin đính kèm";

                var att = new System.Net.Mail.Attachment(tt);
                att.Name = "Chiết xuất hồ sơ.xls";
                atts.Add(att);
            }

            var emails = nvbhs2
                .Select(s => s.email)
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .ToList()
                .Concat(
                    nccs2
                        .Select(s => s.email)
                        .Where(s => !string.IsNullOrWhiteSpace(s))
                        .ToList()
                );

            string toEmails = string.Join(",", emails);

            if (string.IsNullOrWhiteSpace(toEmails))
            {
                msg = "Không tìm thấy email người nhận.";
                goto EndEventHandler;
            }

            mail.Send(
                nv.email,
                toEmails,
                nv.email,
                "",
                title,
                body,
                atts
            );
            foreach (var hsct in hscts)
            {
                db.ExecuteCommand(
                    @"UPDATE c_donhangchungtu
                  SET daguimail = 1
                  WHERE c_donhangchungtu_id = {0}",
                    hsct.c_donhangchungtu_id
                );
            }
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
            jqGridHelper.Utils.writeResult(1, "Gửi mail thành công");
        }
    }
    public void sendMailGoc(HttpContext context)
    {
        string msg = "";
        var ids = context.Request.Form["ids"].removeAllSpaceOrTrimText(false).Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
        var nvbhs = context.Request.Form["nvbhs"].removeAllSpaceOrTrimText(false).Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
        var nccs = context.Request.Form["nccs"].removeAllSpaceOrTrimText(false).Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
        var tt = context.Request.Form["tt"].removeAllSpaceOrTrimText(true);
        try
        {
            var hscts = db.c_donhangchungtus.Where(s => ids.Contains(s.c_donhangchungtu_id)).ToList();
            if (hscts.Count <= 0)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            var nvbhs2 = db.nhanviens.Where(s => nvbhs.Contains(s.manv)).OrderBy(s => s.email).ToList();
            var nccs2 = db.md_doitackinhdoanhs.Where(s => nccs.Contains(s.ma_dtkd)).OrderBy(s => s.email).ToList();
            if (nvbhs2.Count <= 0 & nccs2.Count <= 0)
            {
                msg = $@"Phải chọn nhân viên hoặc nhà cung cấp để gửi mail";
                goto EndEventHandler;
            }

            var arrDHs = new List<string>();
            foreach (var hsct in hscts)
            {
                var dh = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
                if (dh != null)
                    arrDHs.Add(dh.sochungtu);
            }

            if (!File.Exists(tt))
            {
                msg = $@"Không chiết xuất được tập tin theo hồ sơ đã chọn";
                goto EndEventHandler;
            }

            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
            if (!string.IsNullOrWhiteSpace(nv.smtp))
            {
                smtp = db.md_smtps.Where(s => s.md_smtp_id == nv.smtp).FirstOrDefault();
            }
            var mail = new GoogleMail();
            mail.Email = nv.email;
            mail.Password = nv.email_pass;
            mail.Smtp = smtp.smtpserver;
            mail.Port = smtp.port.Value;
            mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);
            string title = $@"Hồ sơ chứng từ của đơn hàng ""{string.Join(", ", arrDHs.OrderBy(s => s).ToList())}""", body = $@"Chi tiết vui lòng xem ở tập tin đính kèm";
            var atts = new List<System.Net.Mail.Attachment>();
            var att = new System.Net.Mail.Attachment(tt);
            var name = "Chiết xuất hồ sơ.xls";
            att.Name = name;
            atts.Add(att);
            var emails = nvbhs2.Select(s => s.email).ToList().Concat(nccs2.Select(s => s.email).ToList());
            mail.Send(
                nv.email
                , string.Join(",", emails)
                , nv.email
                , ""
                , title
                , body
                , atts
            );
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Gửi mail thành công");
    }

    public void ngayBHXN(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
            if (hsct == null)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (!string.IsNullOrWhiteSpace(hsct.dongghep))
            {
                msg = $@"Hồ sơ này thuộc đơn hàng được ghép. Bạn Hãy điều chỉnh hồ sơ của đơn hàng ưu tiên ""{hsct.dongghep}""";
                goto EndEventHandler;
            }

            var dh = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
            if (dh == null)
            {
                msg = $@"Không tìm thấy đơn hàng gốc đang liên kết với hồ sơ";
                goto EndEventHandler;
            }

            var nvbh = db.nhanviens.Where(s => s.manv == dh.nguoilap).FirstOrDefault();
            if (nvbh == null)
            {
                msg = $@"Không tìm thấy nhân viên bán hàng ""{dh.nguoilap}"" trong danh sách nhân viên";
                goto EndEventHandler;
            }

            var ngayBHXN = context.Request.Form["ngayBHXN"].removeAllSpaceOrTrimText(true).ToNullableDate();
            if (ngayBHXN == null)
            {
                msg = $@"Ngày đã chọn không đúng định dạng (dd/MM/yyyy) hoặc đang bị bỏ trống";
                goto EndEventHandler;
            }

            hsct.ngayBHXN = ngayBHXN;
            dh.ngayBHXN = ngayBHXN;
            var arrDHCLs = new List<string>();
            var hsct2s = db.c_donhangchungtus.Where(s => s.dongghep == dh.sochungtu).OrderBy(s => s.dongghep).ToList();
            foreach (var hsct2 in hsct2s)
            {
                var dh2 = db.c_donhangs.Where(s => s.c_donhang_id == hsct2.c_donhang_id).FirstOrDefault();
                if (dh2 != null)
                {
                    dh2.ngayBHXN = ngayBHXN;
                    arrDHCLs.Add(dh2.sochungtu);
                }
            }
            hsct.ngaycapnhat = DateTime.Now;
            hsct.nguoicapnhat = UserUtils.getUser(context);
            db.SubmitChanges();

            try
            {
                string manv = UserUtils.getUser(context);
                var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
                var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
                if (!string.IsNullOrWhiteSpace(nv.smtp))
                {
                    smtp = db.md_smtps.Where(s => s.md_smtp_id == nv.smtp).FirstOrDefault();
                }
                var mail = new GoogleMail();
                mail.Email = nv.email;
                mail.Password = nv.email_pass;
                mail.Smtp = smtp.smtpserver;
                mail.Port = smtp.port.Value;
                mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);
                string title = $@"Cập nhật ngày NHXNXH cho đơn hàng ""{dh.sochungtu}""", body = $@"Đơn hàng ưu tiên: ""{dh.sochungtu}""";
                body += $"<br><br>Đơn hàng còn lại: {string.Join(", ", arrDHCLs)}";
                body += $"<br><br>Ngày BHXNXH: {ngayBHXN.Value.ToString(Extension.fmtDate)}";
                var attachments = new List<System.Net.Mail.Attachment>();

                mail.Send(
                    nv.email
                    , nvbh.email
                    , nv.email
                    , ""
                    , title
                    , body
                    , attachments
                );
            }
            catch (Exception ex)
            {
                msg = ex.ToString();
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Cập nhật ngày bán hàng xác nhận xuất hàng thành công");
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        string ngaydieuchinh = context.Request.Form["ngaydieuchinh"].removeAllSpaceOrTrimText(true);
        string ngaypass = context.Request.Form["ngaypass"].removeAllSpaceOrTrimText(true);
        string ngaychuyenhoso = context.Request.Form["ngaychuyenhoso"].removeAllSpaceOrTrimText(true);
        string nhanvienCT = context.Request.Form["nhanvienCT"].removeAllSpaceOrTrimText(true);
        string ngayBookCont = context.Request.Form["ngayBookCont"].removeAllSpaceOrTrimText(true);
        string bookingNo = context.Request.Form["bookingNo"].removeAllSpaceOrTrimText(true);
        string ngayETD = context.Request.Form["ngayETD"].removeAllSpaceOrTrimText(true);
        string ngayETA = context.Request.Form["ngayETA"].removeAllSpaceOrTrimText(true);
        string ngayXuong = context.Request.Form["ngayXuong"].removeAllSpaceOrTrimText(true);
        string ngayCutOff = context.Request.Form["ngayCutOff"].removeAllSpaceOrTrimText(true);
        string ngayBHXN = context.Request.Form["ngayBHXN"].removeAllSpaceOrTrimText(true);
        string mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
        string trangthai = context.Request.Form["trangthai"].removeAllSpaceOrTrimText(true);
        string trangthai2 = context.Request.Form["trangthai2"].removeAllSpaceOrTrimText(true);
        string ngayKeoCont = context.Request.Form["ngayKeoCont"].removeAllSpaceOrTrimText(true);
        string ghichusau = context.Request.Form["ghichusau"].removeAllSpaceOrTrimText(true);
        string ngaykiemhangpass = (context.Request.Form["ngaykiemhangpass"] ?? "").removeAllSpaceOrTrimText(true);
        string ketquakiemhang = (context.Request.Form["ketquakiemhang"] ?? "").removeAllSpaceOrTrimText(true);
        try
        {
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
            if (hsct == null)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (!string.IsNullOrWhiteSpace(hsct.dongghep))
            {
                msg = $@"Hồ sơ thuộc đơn hàng được ghép, vui lòng sửa hồ sơ có đơn hàng ưu tiên ""{hsct.dongghep}""";
                goto EndEventHandler;
            }

            if (hsct.trangthai == Helper.KETTHUC)
            {
                msg = $@"Hồ sơ đã Kết Thúc";
                goto EndEventHandler;
            }

            if (hsct.trangthai != Helper.SOANTHAO & trangthai == Helper.SOANTHAO)
            {
                msg = $@"Hồ sơ đã Hiệu lực trước đó";
                goto EndEventHandler;
            }

            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
            if (hsct.trangthai == Helper.SOANTHAO & trangthai != Helper.SOANTHAO)
            {
                if (donhang != null)
                {
                    donhang.trangthaict = Helper.DAHIEULUC;
                }
            }

            //ngayBookCont
            var date_ngayBookCont = ngayBookCont.ToNullableDate();
            if (date_ngayBookCont != null & hsct.ngayBookCont == null)
            {
                if (hsct.trangthai != Helper.HIEULUC)
                {
                    msg = $@"Cần hiệu lực trước khi điền ngày book container";
                    goto EndEventHandler;
                }
                hsct.trangthai = Helper.DAGUIBC;
            }
            if (hsct.ngayBookCont != null & date_ngayBookCont == null)
            {
                msg = $@"Ngày book container không thể bỏ trống khi đã có giá trị";
                goto EndEventHandler;
            }
            hsct.ngayBookCont = date_ngayBookCont;

            //bookingNo
            var chkValue_bookingNo = string.IsNullOrWhiteSpace(bookingNo);
            if (!chkValue_bookingNo & string.IsNullOrEmpty(hsct.bookingNo))
            {
                if (hsct.trangthai != Helper.DAGUIBC)
                {
                    msg = $@"Cần điền ngày book container trước khi điền Booking No";
                    goto EndEventHandler;
                }
                hsct.trangthai = Helper.DACOLT;
            }
            if (hsct.bookingNo.removeAllSpaceOrTrimText(true).Length > 0 & chkValue_bookingNo)
            {
                msg = $@"Booking No không thể bỏ trống khi đã có giá trị";
                goto EndEventHandler;
            }
            hsct.bookingNo = bookingNo;

            //ngayKeoCont
            var date_ngayKeoCont = ngayKeoCont.ToNullableDate();
            if (date_ngayKeoCont != null & hsct.ngayKeoCont == null)
            {
                if (hsct.trangthai != Helper.DACOLT)
                {
                    msg = $@"Cần điền Booking no trước khi điền ngày kéo cont / xuất hàng";
                    goto EndEventHandler;
                }
                hsct.trangthai = Helper.DAKEOC;
            }
            if (hsct.ngayKeoCont != null & date_ngayKeoCont == null)
            {
                msg = $@"Ngày kéo cont / xuất hàng không thể bỏ trống khi đã có giá trị";
                goto EndEventHandler;
            }
            hsct.ngayKeoCont = date_ngayKeoCont;
            hsct.trangthai2 = trangthai2;
            hsct.ngaydieuchinh = ngaydieuchinh.ToNullableDate();
            hsct.ngaypass = ngaypass.ToNullableDate();
            hsct.ngaychuyenhoso = ngaychuyenhoso.ToNullableDate();
            hsct.nhanvienCT = nhanvienCT;
            //hsct.ngayETA = ngayETA.ToNullableDate();
            //hsct.ngayETD = ngayETD.ToNullableDate();
            //hsct.ngayBHXN = ngayBHXN.ToNullableDate();
            //if (hsct.ngayETD != null & hsct.ngayBHXN == null)
            //    hsct.ngayBHXN = hsct.ngayETD.Value.AddDays(-7);
            hsct.ngayETA = ngayETA.ToNullableDate();
            hsct.ngayETD = ngayETD.ToNullableDate();

            DateTime? dateNgayBHXN = ngayBHXN.ToNullableDate();

            hsct.ngayBHXN = dateNgayBHXN;

            if (hsct.ngayETD != null && hsct.ngayBHXN == null)
            {
                hsct.ngayBHXN = hsct.ngayETD.Value.AddDays(-7);
            }

            // Cập nhật ngược về PO gốc để grid_ds_po load lên đúng
            if (donhang != null)
            {
                donhang.ngayBHXN = hsct.ngayBHXN;
                donhang.ngaycapnhat = DateTime.Now;
                donhang.nguoicapnhat = UserUtils.getUser(context);
            }




            hsct.ngayCutOff = ngayCutOff.ToNullableDate();
            hsct.ngayXuong = ngayXuong.ToNullableDate();
            if (hsct.ngayCutOff != null & hsct.ngayXuong == null)
                hsct.ngayXuong = hsct.ngayCutOff.Value.AddDays(-2);

            hsct.mota = mota;
            hsct.ghichusau = ghichusau;
            hsct.ngaycapnhat = DateTime.Now;
            hsct.ketquakiemhang = ketquakiemhang;
            hsct.ngaycapnhat = DateTime.Now;
            hsct.nguoicapnhat = UserUtils.getUser(context);

            foreach (var hsctk in db.c_donhangchungtus.Where(s => s.dongghep == donhang.sochungtu & s.c_donhangchungtu_id != hsct.c_donhangchungtu_id))
            {
                //var donhangk = db.c_donhangs.Where(s => s.c_donhang_id == hsctk.c_donhang_id & s.trangthaict != Helper.DAHIEULUC).FirstOrDefault();
                //if (donhangk != null)
                //{
                //    if (hsctk.trangthai != Helper.SOANTHAO)
                //    {
                //        donhangk.trangthaict = Helper.DAHIEULUC;
                //    }
                var donhangk = db.c_donhangs.Where(s => s.c_donhang_id == hsctk.c_donhang_id).FirstOrDefault();

                if (donhangk != null)
                {
                    if (hsctk.trangthai != Helper.SOANTHAO && donhangk.trangthaict != Helper.DAHIEULUC)
                    {
                        donhangk.trangthaict = Helper.DAHIEULUC;
                    }
                }


                hsctk.trangthai = hsct.trangthai;
                hsctk.ngayBookCont = hsct.ngayBookCont;
                hsctk.bookingNo = hsct.bookingNo;
                hsctk.ngayKeoCont = hsct.ngayKeoCont;
                hsctk.trangthai2 = hsct.trangthai2;
                hsctk.ngaydieuchinh = hsct.ngaydieuchinh;
                hsctk.ngaypass = hsct.ngaypass;
                hsctk.ngaychuyenhoso = hsct.ngaychuyenhoso;
                hsctk.nhanvienCT = hsct.nhanvienCT;
                hsctk.ngayETA = hsct.ngayETA;
                hsctk.ngayETD = hsct.ngayETD;
                hsctk.ngayBHXN = hsct.ngayBHXN;

                donhangk.ngayBHXN = hsct.ngayBHXN;
                donhangk.ngaycapnhat = DateTime.Now;
                donhangk.nguoicapnhat = UserUtils.getUser(context);

                hsctk.ngayCutOff = hsct.ngayCutOff;
                hsctk.ngayXuong = hsct.ngayXuong;
                hsctk.mota = hsct.mota;
                hsctk.ngaykiemhangpass = hsct.ngaykiemhangpass;
                hsctk.ketquakiemhang = hsct.ketquakiemhang;
            }
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Cập nhật thành công");
    }

    public void add(HttpContext context)
    {

    }
    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        string lydoXoa = (context.Request.Form["lydoxoa_hsct"] ?? "").Trim();

        try
        {
            if (string.IsNullOrWhiteSpace(lydoXoa))
            {
                msg = "Vui lòng nhập lý do xóa hồ sơ chứng từ.";
                goto EndEventHandler;
            }

            var hsct = db.c_donhangchungtus
                .Where(s => s.c_donhangchungtu_id == id)
                .FirstOrDefault();

            if (hsct == null)
            {
                msg = @"Không tìm thấy dòng ""hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (hsct.trangthai != Helper.SOANTHAO)
            {
                msg = @"Dòng ""hồ sơ"" không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var dh = db.c_donhangs
                .Where(s => s.c_donhang_id == hsct.c_donhang_id)
                .FirstOrDefault();

            if (dh == null)
            {
                msg = "Không tìm thấy đơn hàng liên kết với hồ sơ chứng từ.";
                goto EndEventHandler;
            }
            // Lấy danh sách PO phụ / các dòng còn lại được ghép theo PO ưu tiên
            var hsctks = db.c_donhangchungtus
                .Where(s => s.dongghep == dh.sochungtu)
                .ToList();

            var soPOPhus = new List<string>();

            foreach (var hsctk in hsctks)
            {
                var dhPhu = db.c_donhangs
                    .Where(s => s.c_donhang_id == hsctk.c_donhang_id)
                    .FirstOrDefault();

                if (dhPhu != null && !string.IsNullOrWhiteSpace(dhPhu.sochungtu))
                {
                    soPOPhus.Add(dhPhu.sochungtu);
                }
            }

            soPOPhus = soPOPhus
                .Distinct()
                .OrderBy(s => s)
                .ToList();

            string soPOHtml = HttpUtility.HtmlEncode(dh.sochungtu);

            if (soPOPhus.Count > 0)
            {
                soPOHtml += "<br/><b></b><br/>"
                    + string.Join("<br/>", soPOPhus.Select(s => HttpUtility.HtmlEncode(s)));
            }

            // Nhân viên chịu trách nhiệm hồ sơ chứng từ
            //string manvNhanTrachNhiem = hsct.nhanvienCT;

            //if (string.IsNullOrWhiteSpace(manvNhanTrachNhiem))
            //{
            //    manvNhanTrachNhiem = dh.nhanvienCT;
            //}
            string manvNhanTrachNhiem = dh.nguoilap;

            var nvNhanTrachNhiem = db.nhanviens
                .Where(s => s.manv == manvNhanTrachNhiem)
                .FirstOrDefault();

            if (nvNhanTrachNhiem == null)
            {
                msg = @"Không tìm thấy nhân viên chịu trách nhiệm hồ sơ chứng từ.";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(nvNhanTrachNhiem.email))
            {
                msg = @"Nhân viên chịu trách nhiệm hồ sơ chứng từ chưa có email.";
                goto EndEventHandler;
            }

            // Nhân viên đang đăng nhập để gửi mail
            string manvDangNhap = UserUtils.getUser(context);

            var nvGui = db.nhanviens
                .FirstOrDefault(p => p.manv.Equals(manvDangNhap));

            if (nvGui == null)
            {
                msg = "Không tìm thấy nhân viên đang đăng nhập.";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(nvGui.email))
            {
                msg = "Nhân viên đang đăng nhập chưa cấu hình email gửi.";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(nvGui.email_pass))
            {
                msg = "Nhân viên đang đăng nhập chưa cấu hình mật khẩu email/app password.";
                goto EndEventHandler;
            }

            var smtp = db.md_smtps
                .Where(p => p.macdinh.Equals(true))
                .FirstOrDefault();

            if (!string.IsNullOrWhiteSpace(nvGui.smtp))
            {
                smtp = db.md_smtps
                    .Where(s => s.md_smtp_id == nvGui.smtp)
                    .FirstOrDefault();
            }

            if (smtp == null)
            {
                msg = "Không tìm thấy cấu hình SMTP.";
                goto EndEventHandler;
            }

            // Gửi mail thông báo trước khi xóa
            try
            {
                var mail = new GoogleMail();
                mail.Email = nvGui.email;
                mail.Password = nvGui.email_pass;
                mail.Smtp = smtp.smtpserver;
                mail.Port = smtp.port.Value;
                mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);

                string title = $@"Thông báo xóa hồ sơ chứng từ - PO ""{dh.sochungtu}""";

                string body = $@"
                <div style='font-family:Arial;font-size:14px'>
                    <p>Xin chào <b>{HttpUtility.HtmlEncode(nvNhanTrachNhiem.hoten ?? nvNhanTrachNhiem.manv)}</b>,</p>

                    <p>Hồ sơ chứng từ sau đã được yêu cầu xóa khỏi hệ thống:</p>

                    <table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse;font-size:13px'>
 
                        <tr>
                            <td><b>Số PO</b></td>
                            <td>{soPOHtml}</td>
                        </tr>
                        <tr>
                            <td><b>Customer Order No</b></td>
                            <td>{HttpUtility.HtmlEncode(dh.customer_order_no ?? "")}</td>
                        </tr>
                        <tr>
                            <td><b>Người xóa</b></td>
                            <td>{HttpUtility.HtmlEncode(manvDangNhap)}</td>
                        </tr>
                        <tr>
                            <td><b>Thời gian xóa</b></td>
                            <td>{DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss")}</td>
                        </tr>
                        <tr>
                            <td><b>Lý do xóa</b></td>
                            <td>{HttpUtility.HtmlEncode(lydoXoa)}</td>
                        </tr>
                    </table>

                    <p style='margin-top:12px;color:#666'>
                        Email này được gửi tự động từ hệ thống AncoTrading.
                    </p>
                </div>";

                var attachments = new List<System.Net.Mail.Attachment>();

                mail.Send(
                    nvGui.email,
                    nvNhanTrachNhiem.email,
                    nvGui.email_cc,
                    "",
                    title,
                    body,
                    attachments
                );
            }
            catch (Exception exMail)
            {
                msg = "Không gửi được email thông báo xóa hồ sơ chứng từ: " + exMail.Message;
                goto EndEventHandler;
            }

            // Cập nhật trạng thái đơn hàng liên kết
            if (dh.md_trangthai_id == Helper.SOANTHAO)
            {
                dh.trangthaict = Helper.CHUAGUI;
            }
            else
            {
                dh.trangthaict = Helper.TUCHOI;
            }

            foreach (var spd in db.c_donhang_spds
                .Where(s => s.c_donhang_id == dh.c_donhang_id && s.trangthai == Helper.DAGUI))
            {
                spd.trangthai = Helper.CHUAGUI;
            }


            // Danh sách hồ sơ chứng từ sẽ xóa: hồ sơ chính + hồ sơ ghép
var hsctIdsCanXoa = new List<string>();
var donHangIdsCanXoa = new List<string>();

hsctIdsCanXoa.Add(hsct.c_donhangchungtu_id);
donHangIdsCanXoa.Add(hsct.c_donhang_id);

foreach (var hsctk in hsctks)
{
    if (!string.IsNullOrWhiteSpace(hsctk.c_donhangchungtu_id)
        && !hsctIdsCanXoa.Contains(hsctk.c_donhangchungtu_id))
    {
        hsctIdsCanXoa.Add(hsctk.c_donhangchungtu_id);
    }

    if (!string.IsNullOrWhiteSpace(hsctk.c_donhang_id)
        && !donHangIdsCanXoa.Contains(hsctk.c_donhang_id))
    {
        donHangIdsCanXoa.Add(hsctk.c_donhang_id);
    }
}

// Xóa log bổ sung theo hồ sơ chứng từ
foreach (var hsctIdCanXoa in hsctIdsCanXoa)
{
    db.ExecuteCommand(@"
        DELETE FROM c_donhangchungtu_bosung_log
        WHERE c_donhangchungtu_id = {0}
    ", hsctIdCanXoa);
}

// Xóa log chuyển xuất theo hồ sơ chứng từ
foreach (var hsctIdCanXoa in hsctIdsCanXoa)
{
    db.ExecuteCommand(@"
        DELETE FROM c_donhangchungtu_xuat_log
        WHERE c_donhangchungtu_id = {0}
    ", hsctIdCanXoa);
}

// Xóa log chuyển xuất theo đơn hàng
// Vì grid_solanxuat đang load theo log.c_donhang_id
foreach (var donHangIdCanXoa in donHangIdsCanXoa)
{
    db.ExecuteCommand(@"
        DELETE FROM c_donhangchungtu_xuat_log
        WHERE c_donhang_id = {0}
    ", donHangIdCanXoa);
}


            // Xóa tập tin đính kèm của hồ sơ chính
            var tts = db.md_taptins
                .Where(s => s.lienket == hsct.c_donhangchungtu_id)
                .ToList();

            var links = new List<string>();

            foreach (var taptin in tts)
            {
                db.md_taptins.DeleteOnSubmit(taptin);
                links.Add(ExcuteSignalRStatic.mapPathSignalR($@"~/{taptin.path}"));
            }

            // Xóa các hồ sơ chứng từ ghép theo PO ưu tiên
            //var hsctks = db.c_donhangchungtus
            //    .Where(s => s.dongghep == dh.sochungtu)
            //    .ToList();

            foreach (var hsctk in hsctks)
            {
                var dhk = db.c_donhangs
                    .Where(s => s.c_donhang_id == hsctk.c_donhang_id)
                    .FirstOrDefault();

                if (dhk != null)
                {
                    if (dhk.md_trangthai_id == Helper.SOANTHAO)
                    {
                        dhk.trangthaict = Helper.CHUAGUI;
                    }
                    else
                    {
                        dhk.trangthaict = Helper.TUCHOI;
                    }

                    foreach (var spdk in db.c_donhang_spds
                        .Where(s => s.c_donhang_id == dhk.c_donhang_id && s.trangthai == Helper.DAGUI))
                    {
                        spdk.trangthai = Helper.CHUAGUI;
                    }
                }

                // Xóa tập tin đính kèm của hồ sơ ghép nếu có
                var ttsGhep = db.md_taptins
                    .Where(s => s.lienket == hsctk.c_donhangchungtu_id)
                    .ToList();

                foreach (var taptinGhep in ttsGhep)
                {
                    db.md_taptins.DeleteOnSubmit(taptinGhep);
                    links.Add(ExcuteSignalRStatic.mapPathSignalR($@"~/{taptinGhep.path}"));
                }

                db.c_donhangchungtus.DeleteOnSubmit(hsctk);
            }

            db.c_donhangchungtus.DeleteOnSubmit(hsct);

            db.SubmitChanges();

            // Xóa file vật lý sau khi DB đã xóa thành công
            foreach (var link in links)
            {
                if (File.Exists(link))
                {
                    File.Delete(link);
                }
            }
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
            jqGridHelper.Utils.writeResult(1, "Xóa thành công và đã gửi email thông báo.");
        }
    }

    //public void del(HttpContext context)
    //{
    //    string msg = "";
    //    string id = context.Request.Form["id"];
    //    try
    //    {
    //        var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
    //        if (hsct == null)
    //        {
    //            msg = $@"Không tìm thấy dòng ""hồ sơ"" đã chọn";
    //            goto EndEventHandler;
    //        }

    //        if (hsct.trangthai != Helper.SOANTHAO)
    //        {
    //            msg = $@"Dòng ""hồ sơ"" không ở trạng thái Soạn Thảo";
    //            goto EndEventHandler;
    //        }

    //        var dh = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
    //        if (dh != null)
    //        {
    //            if (dh.md_trangthai_id == Helper.SOANTHAO)
    //                dh.trangthaict = Helper.CHUAGUI;
    //            else
    //                dh.trangthaict = Helper.TUCHOI;
    //        }

    //        foreach (var spd in db.c_donhang_spds.Where(s => s.c_donhang_id == dh.c_donhang_id & s.trangthai == Helper.DAGUI))
    //        {
    //            spd.trangthai = Helper.CHUAGUI;
    //        }

    //        var tts = db.md_taptins.Where(s => s.lienket == hsct.c_donhangchungtu_id).ToList();
    //        var links = new List<string>();
    //        foreach (var taptin in tts)
    //        {
    //            db.md_taptins.DeleteOnSubmit(taptin);
    //            links.Add(ExcuteSignalRStatic.mapPathSignalR($@"~/{taptin.path}"));
    //        }

    //        var hsctks = db.c_donhangchungtus.Where(s => s.dongghep == dh.sochungtu).ToList();
    //        foreach (var hsctk in hsctks)
    //        {
    //            var dhk = db.c_donhangs.Where(s => s.c_donhang_id == hsctk.c_donhang_id).FirstOrDefault();
    //            if (dhk != null)
    //            {
    //                if (dhk.md_trangthai_id == Helper.SOANTHAO)
    //                    dhk.trangthaict = Helper.CHUAGUI;
    //                else
    //                    dhk.trangthaict = Helper.TUCHOI;

    //                foreach (var spdk in db.c_donhang_spds.Where(s => s.c_donhang_id == dhk.c_donhang_id & s.trangthai == Helper.DAGUI))
    //                {
    //                    spdk.trangthai = Helper.CHUAGUI;
    //                }
    //            }
    //            db.c_donhangchungtus.DeleteOnSubmit(hsctk);
    //        }
    //        db.c_donhangchungtus.DeleteOnSubmit(hsct);
    //        db.SubmitChanges();

    //        foreach (var link in links)
    //        {
    //            if (File.Exists(link))
    //                File.Delete(link);
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        msg = ex.Message;
    //    }

    //    EndEventHandler:;

    //    if (msg.Length > 0)
    //        jqGridHelper.Utils.writeResult(0, msg);
    //    else
    //        jqGridHelper.Utils.writeResult(1, "Xóa thành công");
    //}

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM c_donhangchungtu dh
                left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
                left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
                outer apply (select top 1 POD, Forwarder from c_donhang_spd where c_donhang_id = dh2.c_donhang_id order by ngaytao desc) spd
            WHERE 1=1 {filter}";
        int page = int.Parse(context.Request.QueryString["page"]);
        int limit = int.Parse(context.Request.QueryString["rows"]);
        String sidx = context.Request.QueryString["sidx"];
        String sord = context.Request.QueryString["sord"];
        int total_page;
        int count = (int)mdbc.ExecuteScalar(sqlCount);
        int start, end;

        if (count > 0)
        {
            total_page = (int)Math.Ceiling(1.0 * count / limit);
        }
        else
        {
            total_page = 0;
        }

        if (page > total_page) page = total_page;
        start = limit * page - limit;
        end = (page * limit) + 1;

        if (sidx.Equals("") || sidx == null)
        {
            sidx = "dh.ngaytao";
            sord = "desc";
        }

        string strsql = $@"
        select * from(
            select
                dh.c_donhangchungtu_id
                , dh.c_donhang_id
                , dh.trangthai
                , dh.trangthai2
                , dh.trangthai2 as trangthai2CP
                , kh.ma_dtkd
                , dh2.sochungtu
                , dh2.customer_order_no
                , dh.cont20
                , dh.cont40
                , dh.cont40hc
                , dh.cont45
                , dh.contLCL
                , dh.dongghep
                , dh.mota
                , dh.bookingNo
                , dh.ngayETD
                , dh.ngayETA
                , dh.ngayBHXN
                , dh.ngayXuong
                , dh.ngayCutOff
                , dh2.ngaypass
                , dh2.shipmenttime
                , DATEADD(day, -7, dh2.shipmenttime) as hangiaohang_po
                , dh.ngaydieuchinh
                , dh.ngaychuyenhoso
                , dh2.nguoilap
                , dh.nhanvienCT
                , spd.Forwarder
                , dh.ngayBookCont
                , spd.POD
                , dh.ngayKeoCont
                , dh.ghichusau
                , dh.ngaytao
                , dh.nguoitao
                , dh.ngaycapnhat
                , dh.nguoicapnhat
, dh.hoatdong
                , ncc.nhacungung
                


, (
    case 
        when isnull(dh.daguimail, 0) = 1 then N'Đã gửi mail'
        else N'Chưa gửi mail'
    end
) as trangthaigui_mail
, dh.ngaykiemhangpass
, dh.ketquakiemhang
, ROW_NUMBER() OVER (ORDER BY (CASE WHEN dh.trangthai = 'KETTHUC' THEN 1 ELSE 0 END) ASC, {sidx} {sord}) as RowNum


FROM c_donhangchungtu dh
    left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
    left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
    outer apply (
        select top 1 POD, Forwarder 
        from c_donhang_spd 
        where c_donhang_id = dh2.c_donhang_id 
            and trangthai = 'DAGUI' 
        order by ngaytao desc
    ) spd
    outer apply (
        select nhacungung = STUFF((
            select distinct '<br/>' + ncc2.ma_dtkd
            from c_dongdonhang ddh
                left join md_doitackinhdoanh ncc2 
                    on ncc2.md_doitackinhdoanh_id = ddh.nhacungungid
            where ddh.c_donhang_id = dh2.c_donhang_id
                and isnull(ncc2.ma_dtkd, '') <> ''
            for xml path(''), type
        ).value('.', 'nvarchar(max)'), 1, 5, '')
    ) ncc
WHERE 1=1 {filter}


        )P WHERE RowNum > @start AND RowNum < @end";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else if (column.DataType == Type.GetType("System.Decimal"))
                {
                    if (row[column.ColumnName] != null)
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
                    else
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                }
                else
                {
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
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


