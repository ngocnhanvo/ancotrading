<%@ WebHandler Language="C#" Class="QuotationQRController" %>

using System;
using System.Web;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Data;
using Newtonsoft.Json;

public class QuotationQRController : IHttpHandler
{
    private class FileSave
    {
        public byte[] fileBytes { get; set; }
        public string filePath { get; set; }
    }

    private class FileMail
    {
        public string data { get; set; }
        public string name { get; set; }
        public int size { get; set; }
    }

    private class eMail
    {
        public string c_baogia_id { get; set; }
        public string from { get; set; }
        public string to { get; set; }
        public string cc { get; set; }
        public string bcc { get; set; }
        public string title { get; set; }
        public string body { get; set; }
        public List<FileMail> files { get; set; }
    }
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "sendEmail":
                this.sendEmail(context);
                break;
            case "createEmail":
                this.createEmail(context);
                break;
            case "chuyenThanhPO":
                this.chuyenThanhPO(context);
                break;
            case "chonMau":
                this.chonMau(context);
                break;
            default:
                switch (oper)
                {
                    case "edit":
                        this.edit(context);
                        break;
                    case "del":
                        this.del(context);
                        break;
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public void chonMau(HttpContext context)
    {
        var id = context.Request.Form["id"];
        var selIds = context.Request.Form["selIds"].removeAllSpaceOrTrimText(false).Split(',').Where(s => s != null).ToList();
        var hoatdong = context.Request.Form["hoatdong"].removeAllSpaceOrTrimText(false) == "1";
        string msg = "";
        bool status = false;
        try
        {
            var bg = db.c_baogiaqrs.Where(s => s.c_baogiaqr_id == id).FirstOrDefault();
            if (bg.md_trangthai_id != Helper.SOANTHAO)
            {
                msg = $@"Báo giá không ở trạng thái ""Soạn Thảo""";
                goto EndEventHandler;
            }

            var colors = db.md_color_references.Where(s => s.c_baogia_id == bg.c_baogiaqr_id & selIds.Contains(s.md_color_reference_id)).ToList();
            if (colors.Count <= 0)
            {
                msg = $@"Không có màu sắc nào được chọn";
                goto EndEventHandler;
            }

            foreach (var color in colors)
                color.hoatdong = hoatdong;
            db.SubmitChanges();
            status = true;
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        dynamic result = new
        {
            msg,
            status
        };

        context.Response.Write(JsonConvert.SerializeObject(result));
    }

    public void sendEmail(HttpContext context)
    {
        var id = context.Request.QueryString["id"];
        string msg = "", user = UserUtils.getUser(context);
        var data = context.Request.Params["data"];
        bool status = false;
        try
        {
            var json = JsonConvert.DeserializeObject<eMail>(data);
            var bg = db.c_baogiaqrs.Where(s => s.c_baogiaqr_id == json.c_baogia_id).FirstOrDefault();
            if (bg == null)
            {
                msg = "Không tìm thấy báo giá đã chọn";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(json.from))
            {
                msg = "Không tìm thấy email của người gửi";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(json.to))
            {
                msg = "Không tìm thấy email của người nhận";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(json.title))
            {
                msg = "Không tìm thấy tiêu đề";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(json.body))
            {
                msg = "Không tìm thấy nội dung";
                goto EndEventHandler;
            }

            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            if (nv.email.Trim() != json.from)
            {
                msg = $"Email của người dùng ({nv.email}) không khớp với email của người gửi ({json.from})";
                goto EndEventHandler;
            }

            var pathMain = ExcuteSignalRStatic.mapPathSignalR($"~/SendMail/quotation/{bg.c_baogiaqr_id}");
            var directoryMain = new DirectoryInfo(pathMain);
            if (!directoryMain.Exists)
            {
                msg = $"Thư mục gốc của báo giá đã bị xóa, vui lòng mở lại chức năng gửi mail";
                goto EndEventHandler;
            }

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
            mail.Attachments = new List<System.Net.Mail.Attachment>();

            var fileBytes = new List<FileSave>();
            foreach (var file in json.files)
            {
                var fileB = Convert.FromBase64String(file.data);
                fileBytes.Add(new FileSave() { fileBytes = fileB, filePath = file.name });
                var stream = new MemoryStream(fileB);
                var attachment = new System.Net.Mail.Attachment(stream, file.name);
                attachment.ContentDisposition.FileName = file.name;
                mail.Attachments.Add(attachment);
            }

            mail.Send2(
               mail.Email
               , json.to
               , json.cc
               , json.bcc
               , json.title
               , Security.DecodeHTML(json.body)
               , ""
            );

            msg = "Gửi mail thành công";
            status = true;
            bg.daguiMail = status;

            var ls = new c_baogiaqr_lichsu();
            ls.c_baogiaqr_lichsu_id = Helper.getNewId();
            ls.c_baogiaqr_id = bg.c_baogiaqr_id;
            ls.from = json.from;
            ls.to = json.to;
            ls.cc = json.cc;
            ls.bcc = json.bcc;
            ls.title = json.title;
            ls.body = json.body;
            ls.nguoitao = nv.manv;
            ls.ngaytao = DateTime.Now;
            ls.nguoicapnhat = nv.manv;
            ls.ngaycapnhat = DateTime.Now;
            ls.mota = "";
            db.c_baogiaqr_lichsus.InsertOnSubmit(ls);


            foreach (var fileByte in fileBytes)
            {
                var path = $"{pathMain}/{ls.c_baogiaqr_lichsu_id}";
                if (!Directory.Exists(path))
                    Directory.CreateDirectory(path);
                path = $"{path}/{fileByte.filePath}";
                File.WriteAllBytes(path, fileByte.fileBytes);
            }

            var files = directoryMain.GetFiles();
            foreach (FileInfo file in files)
            {
                try { file.Delete(); } catch { }
            }
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

    EndEventHandler:;

        dynamic result = new
        {
            msg,
            status
        };

        context.Response.Write(JsonConvert.SerializeObject(result));
    }

    public void createEmail(HttpContext context)
    {
        var id = context.Request.QueryString["id"];
        string msg = "", user = UserUtils.getUser(context);
        bool status = false;
        string from = "", to = "", cc = "", bcc = "", subject = "", body = "";

        try
        {
            var bg = db.c_baogiaqrs.Where(s => s.c_baogiaqr_id == id).FirstOrDefault();
            if (bg == null)
            {
                msg = "Không tìm thấy báo giá đã chọn";
                goto EndEventHandler;
            }

            var nv = db.nhanviens.Where(s => s.manv == user).FirstOrDefault();
            if (nv == null)
            {
                msg = "Không tìm thấy tài khoản, kiểm tra phiên đăng nhập";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(nv.email))
            {
                msg = "Không tìm thấy email được gán trong tài khoản, kiểm tra tài khoản của bạn";
                goto EndEventHandler;
            }

            var kh = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == bg.md_doitackinhdoanh_id).FirstOrDefault();
            if (kh == null)
            {
                msg = "Không tìm thấy khách hàng trong báo giá, kiểm tra danh mục đối tác kinh doanh";
                goto EndEventHandler;
            }

            var tmp = db.md_mailtemplates.FirstOrDefault(p => p.use_for.Equals("QRCode") && p.default_mail.Equals(true));
            if (tmp == null)
            {
                msg = "Không tìm thấy mẫu gửi mail, kiểm tra danh mục Mail Template";
                goto EndEventHandler;
            }


            from = nv.email;
            to = string.IsNullOrWhiteSpace(bg.emailKH) ? kh.email : bg.emailKH;
            cc = UserUtils.getEmailCompany(db);
            bcc = from;
            subject = tmp.subject_mail;
            body = tmp.content_mail.Replace("%0D", "<br/>").Replace("[ten_dtkd]", kh.ten_dtkd);
            var arrPrice = new string[] { "without price", "with price" };
            string strPrice = arrPrice[bg.loaiBG.GetValueOrDefault(false) ? 1 : 0];
            string name = $"{kh.ma_dtkd}-AncoQuotation-{DateTime.Now.ToString("yyyy-MM-dd")} ({strPrice}).xls", mime = "";
            long size = 0;
            string linkDic = ExcuteSignalRStatic.mapPathSignalR($"~/SendMail/quotation/{bg.c_baogiaqr_id}");
            if (!Directory.Exists(linkDic))
                Directory.CreateDirectory(linkDic);
            string link = $"{linkDic}/{name}", data = "";

            var rptBaoGia = new BaoGiaReport(bg.c_baogiaqr_id);
            msg = rptBaoGia.inBaoGia(db, context, name, "excel", true, link, name);
            if (msg.Length <= 0)
            {
                var fileBytes = File.ReadAllBytes(link);
                size = fileBytes.Length;
                data = Convert.ToBase64String(fileBytes);
                mime = "application/vnd.ms-excel";
                status = true;
            }

            var rs = new { c_baogia_id = bg.c_baogiaqr_id, from, to, cc, bcc, subject, body, file = new { link, name, size, data, mime } };
            msg = JsonConvert.SerializeObject(rs);
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        dynamic result = new
        {
            msg,
            status
        };

        context.Response.Write(JsonConvert.SerializeObject(result));
    }

    #region oper
    public void edit(HttpContext context)
    {
        string msg = "";
        try
        {
            var hoatdongs = new string[] { "true", "on" };
            var inCoGia = hoatdongs.Contains(context.Request.Form["loaiBG"].removeAllSpaceOrTrimText(false).ToLower());
            var hd = hoatdongs.Contains(context.Request.Form["hoatdong"].removeAllSpaceOrTrimText(false).ToLower());
            var gia_db = hoatdongs.Contains(context.Request.Form["gia_db"].removeAllSpaceOrTrimText(false).ToLower());

            string c_baogia_id = context.Request.Form["id"];
            var m = db.c_baogiaqrs.Where(p => p.c_baogiaqr_id == c_baogia_id).FirstOrDefault();
            if (m == null)
            {
                msg = "Không tìm thấy báo giá đã chọn";
                goto EndEventHandler;
            }

            if (m.md_trangthai_id.Equals(Helper.HIEULUC))
            {
                msg = "Không thể chỉnh sửa khi báo giá đã hiệu lực!";
                goto EndEventHandler;
            }

            m.ngaybaogia = DateTime.ParseExact(context.Request.Form["ngaybaogia"], "dd/MM/yyyy", null);
            m.ngayhethan = DateTime.ParseExact(context.Request.Form["ngayhethan"], "dd/MM/yyyy", null);

            if (m.ngaybaogia > m.ngayhethan)
            {
                msg = "Ngày báo giá không được lớn hơn ngày hết hạn!";
                goto EndEventHandler;
            }

            m.md_doitackinhdoanh_id = context.Request.Form["md_doitackinhdoanh_id"];
            m.shipmenttime = int.Parse(context.Request.Form["shipmenttime"]);
            m.md_trongluong_id = context.Request.Form["md_trongluong_id"];
            m.md_cangbien_id = context.Request.Form["md_cangbien_id"];
            m.md_kichthuoc_id = context.Request.Form["md_kichthuoc_id"];
            m.moq_item_color = context.Request.Form["moq_item_color"];
            m.mota = context.Request.Form["mota"];
            m.hoatdong = hd;
            m.gia_db = gia_db;
            m.loaiBG = inCoGia;
            m.ngaycapnhat = DateTime.Now;
            m.nguoicapnhat = UserUtils.getUser(context);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Cập nhật thành công");
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
    }

    public void del(HttpContext context)
    {
        string msg = "";
        String id = context.Request.Form["id"];
        var qo = db.c_baogiaqrs.Single(q => q.c_baogiaqr_id.Equals(id));
        if (qo == null)
        {
            msg = "Không tìm thấy báo giá đã chọn";
            goto EndEventHandler;
        }

        if (qo.daguiMail.GetValueOrDefault(false))
        {
            msg = "Báo giá đã được gửi mail và lưu trữ";
            goto EndEventHandler;
        }

        foreach (var ctbg in db.c_chitietbaogiaqrs.Where(s => s.c_baogiaqr_id == id))
        {
            db.c_chitietbaogiaqrs.DeleteOnSubmit(ctbg);
        }

        foreach (var colorRef in db.md_color_references.Where(s => s.c_baogia_id == id))
        {
            db.md_color_references.DeleteOnSubmit(colorRef);
        }
        db.SubmitChanges();

        var pathMain = ExcuteSignalRStatic.mapPathSignalR($"~/SendMail/quotation/{qo.c_baogiaqr_id}");
        if (Directory.Exists(pathMain))
            Directory.Delete(pathMain, true);
        db.c_baogiaqrs.DeleteOnSubmit(qo);
        db.SubmitChanges();

    EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
    }

    #region load
    public void chuyenThanhPO(HttpContext context)
    {
        string qoId = context.Request.QueryString["qoId"];
        string option = context.Request.QueryString["option"];
        string optionType = context.Request.QueryString["optionType"];
        string sct = "", msg = "";
        bool isform = true;

        var bg = db.c_baogiaqrs.FirstOrDefault(p => p.c_baogiaqr_id.Equals(qoId));
        if (bg == null)
        {
            msg = "Không tìm thấy báo giá";
            goto EndEventHandler;
        }

        if (bg.md_trangthai_id.Equals(Helper.SOANTHAO))
        {
            bg.md_trangthai_id = Helper.HIEULUC;
        }

        try
        {
            String md_paymentterm_id = db.md_paymentterms.Take(1).FirstOrDefault().md_paymentterm_id;
            int count_qotopo = (from c in db.c_donhangs where c.c_baogia_id.Equals(qoId) select new { c.sochungtu }).Count();
            if (count_qotopo > 0)
            {
                msg = $@"Không thể tạo vì P/O tươnng ứng đã được tạo truớc đó!";
                goto EndEventHandler;
            }

            if (bg.isform == true & option == "0")
            {
                msg = $@"Không thể tạo vì {bg.sobaogia} là Q/O mẫu!";
                goto EndEventHandler;
            }

            var cangbienIds = db.c_chitietbaogiaqrs.Where(s => s.c_baogiaqr_id == qoId).Select(s => s.md_cangbien_id).Distinct().ToList();
            var count = cangbienIds.Count;
            if ((option == "1" || option == "0") & count > 1)
            {
                msg = $@"Không thể tạo vì Q/O có hai cảng biển!";
                goto EndEventHandler;
            }

            //1. Q/O BT -> P/O BT , P/O SR
            //2. Q/O SR -> P/O BT , P/O SR
            //3. Q.O SR 2CB -> P/O SR hoac 2 P/O 2 CB
            switch (option)
            {
                case "0":
                    count = 1;
                    break;
                case "1":
                    count = 1;
                    break;
                case "2":
                    if (optionType == "po")
                        count = 2;
                    else
                        count = 1;
                    break;
                default:
                    count = 1;
                    break;
            }

            if (optionType == "po")
                isform = false;
            else
                isform = true;


            md_nganhang ng = db.md_nganhangs.Take(1).FirstOrDefault();
            decimal muchoahong = 0;

            md_nguoilienhe nguoilienhe = db.md_nguoilienhes.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(bg.md_doitackinhdoanh_id));
            if (nguoilienhe != null)
            {
                muchoahong = nguoilienhe.muchoahong == null ? 0 : nguoilienhe.muchoahong.Value;
            }

            foreach (var cangbienId in cangbienIds)
            {
                string id = ImportUtils.getNEWID();
                string sochungtu = jqGridHelper.Utils.taoChungTuPO(bg.md_doitackinhdoanh_id, isform == true ? 1 : 0, DateTime.Now.Year.ToString());
                //--
                var dh = new c_donhang();
                dh.c_donhang_id = id;
                dh.sochungtu = sochungtu;
                dh.c_baogia_id = bg.c_baogiaqr_id;

                dh.donhang_mau = isform;

                dh.md_doitackinhdoanh_id = bg.md_doitackinhdoanh_id;
                dh.ngaylap = DateTime.Now;
                dh.nguoilap = UserUtils.getUser(context);

                dh.md_cangbien_id = cangbienId;

                dh.discount = 0;
                dh.shipmentdate = DateTime.Now;
                dh.shipmenttime = DateTime.Now;
                dh.md_paymentterm_id = md_paymentterm_id;
                dh.md_trongluong_id = bg.md_trongluong_id;
                dh.md_kichthuoc_id = bg.md_kichthuoc_id;
                dh.payer = "";
                dh.isdonhangtmp = false;

                dh.cont20 = 0;
                dh.cont40 = 0;
                dh.cont40hc = 0;
                dh.cont45 = 0;
                dh.contle = 0;

                if (nguoilienhe != null)
                {
                    dh.md_nguoilienhe_id = nguoilienhe.doitaclienquan;
                }

                dh.hoahong = muchoahong;
                dh.portdischarge = "";
                dh.amount = bg.totalquo;
                dh.totalcbm = bg.totalcbm;
                dh.totalcbf = bg.totalcbf;
                dh.ismakepi = false;
                dh.md_trangthai_id = Helper.SOANTHAO;
                dh.md_dongtien_id = bg.md_dongtien_id;
                dh.md_nganhang_id = ng.md_nganhang_id;
                dh.ngaytao = DateTime.Now;
                dh.nguoitao = UserUtils.getUser(context);
                dh.ngaycapnhat = DateTime.Now;
                dh.nguoicapnhat = UserUtils.getUser(context);
                dh.hoatdong = true;
                dh.ghichu = bg.mota;

                int sothutu = 10;

                //--
                sct += sochungtu + ",";
                //Tạo dòng đơn hàng
                var lstQOD = (from p in db.c_chitietbaogiaqrs
                              where p.c_baogiaqr_id.Equals(bg.c_baogiaqr_id)
                              select p);
                //--2 cang bien
                if (count == 2)
                    lstQOD = (from p in db.c_chitietbaogiaqrs
                              where p.c_baogiaqr_id.Equals(bg.c_baogiaqr_id) && p.md_cangbien_id.Equals(cangbienId)
                              select p);

                var lstPOD = new List<c_dongdonhang>();

                // Chạy qua từng dòng QO tạo dòng PO
                foreach (var item in lstQOD)
                {
                    var ddh = new c_dongdonhang();
                    ddh.c_dongdonhang_id = ImportUtils.getNEWID();
                    ddh.c_donhang_id = id;
                    ddh.md_sanpham_id = item.md_sanpham_id;
                    ddh.ma_sanpham_khach = item.ma_sanpham_khach;
                    ddh.mota_tiengviet = item.mota_tiengviet;
                    ddh.mota_tienganh = item.mota_tienganh;
                    ddh.md_donggoi_id = item.md_donggoi_id;
                    ddh.giafob = item.giafob;
                    ddh.soluong = item.soluong;
                    // ddh.soluong_dathang = item.soluong;
                    ddh.soluong_dathang = 0;
                    ddh.soluong_conlai = item.soluong;
                    ddh.soluong_daxuat = 0;
                    ddh.sl_inner = item.sl_inner;
                    ddh.l1 = item.l1;
                    ddh.w1 = item.w1;
                    ddh.h1 = item.h1;
                    ddh.sl_outer = item.sl_outer;
                    ddh.l2 = item.l2;
                    ddh.w2 = item.w2;
                    ddh.h2 = item.h2;
                    ddh.v2 = item.v2;
                    ddh.sl_cont = item.sl_cont;
                    ddh.vd = item.vd;
                    ddh.vn = item.vn;
                    ddh.vl = item.vl;
                    ddh.ghichu_vachngan = item.ghichu_vachngan;
                    ddh.nhacungungid = db.md_sanphams.FirstOrDefault(sp => sp.md_sanpham_id.Equals(item.md_sanpham_id)).nhacungung;
                    ddh.ngaytao = DateTime.Now;
                    ddh.ngaycapnhat = DateTime.Now;
                    ddh.nguoitao = UserUtils.getUser(context);
                    ddh.nguoicapnhat = UserUtils.getUser(context);
                    ddh.hoatdong = true;
                    ddh.sothutu = sothutu;
                    ddh.trangthai = item.trangthai;
                    sothutu += 10;

                    //lstPOD.Add(ddh);
                    db.c_dongdonhangs.InsertOnSubmit(ddh);
                }
                db.c_donhangs.InsertOnSubmit(dh);
                db.SubmitChanges();

                string sql_update = $@"update c_dongdonhang set ngaycapnhat = getdate() where c_donhang_id = '${id}'";
                mdbc.ExcuteNonQuery(sql_update);
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;
        if(msg.Length <= 0)
        {
            sct = sct.Remove(sct.Length - 1);
            msg = $@"Ðã tạo PO thành công với số chứng từ {sct}.";
        }
        else
        {
            msg = $@"Lỗi: {msg}";
        }
        context.Response.Write(msg);
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        bool isadmin = db.nhanviens.FirstOrDefault(p => p.manv.Equals(UserUtils.getUser(context))).isadmin.Value;

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        // phân quy?n theo nhóm
        String manv = UserUtils.getUser(context);
        String strAccount = "";
        System.Collections.Generic.List<String> lstAccount = LinqUtils.GetUserListInGroup(manv);
        foreach (String item in lstAccount)
        {
            strAccount += String.Format(", '{0}'", item);
        }
        strAccount = String.Format("'{0}'{1}", manv, strAccount);

        String sqlCount = @"SELECT COUNT(1) AS count
            FROM c_baogiaqr baogia with (nolock)
			LEFT JOIN md_doitackinhdoanh dtkd with (nolock) on baogia.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id 
			LEFT JOIN md_cangbien cb with (nolock) on baogia.md_cangbien_id = cb.md_cangbien_id 
            LEFT JOIN md_dongtien dt with (nolock) on baogia.md_dongtien_id = dt.md_dongtien_id 
            LEFT JOIN md_trongluong tl with (nolock) on baogia.md_trongluong_id = tl.md_trongluong_id
            LEFT JOIN md_kichthuoc kt with (nolock) on baogia.md_kichthuoc_id = kt.md_kichthuoc_id
            WHERE 1=1
            {0}
            {1}";
        sqlCount = String.Format(sqlCount, isadmin == true ? "" : "AND baogia.nguoitao IN(" + strAccount + ")", filter);

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
            sidx = "baogia.ngaytao";
            sord = "desc";
        }


        string strsql = @"select * from( 
            select baogia.c_baogiaqr_id, baogia.md_trangthai_id, baogia.sobaogia, dtkd.ma_dtkd, 
            ngaybaogia, ngayhethan, cb.ten_cangbien, baogia.shipmenttime, baogia.moq_item_color,  tl.ten_trongluong, 
            baogia.totalcbm, baogia.totalcbf, baogia.totalquo, dt.ma_iso, kt.ten_kichthuoc, baogia.isform,  
            baogia.ngaytao, baogia.nguoitao, baogia.ngaycapnhat, baogia.nguoicapnhat, baogia.mota, baogia.hoatdong, 
            baogia.gia_db, baogia.daguiMail, baogia.loaiBG, baogia.chkPBGCu, baogia.phienbangiacu,
            ROW_NUMBER() OVER (ORDER BY {2} {3}) as RowNum 
            FROM c_baogiaqr baogia with (nolock) 
			LEFT JOIN md_doitackinhdoanh dtkd with (nolock) on baogia.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id 
			LEFT JOIN md_cangbien cb with (nolock) on baogia.md_cangbien_id = cb.md_cangbien_id 
            LEFT JOIN md_dongtien dt with (nolock) on baogia.md_dongtien_id = dt.md_dongtien_id 
            LEFT JOIN md_trongluong tl with (nolock) on baogia.md_trongluong_id = tl.md_trongluong_id
            LEFT JOIN md_kichthuoc kt with (nolock) on baogia.md_kichthuoc_id = kt.md_kichthuoc_id 
            WHERE 1=1
            {0}
            {1}
        )P where RowNum > @start AND RowNum < @end";

        strsql = String.Format(strsql, isadmin == true ? "" : "AND baogia.nguoitao IN(" + strAccount + ")", filter, sidx, sord);

        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["c_baogiaqr_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["md_trangthai_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["sobaogia"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_dtkd"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaybaogia"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngayhethan"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_cangbien"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["shipmenttime"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["moq_item_color"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_trongluong"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["totalcbm"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["totalquo"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_iso"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_kichthuoc"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["isform"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaytao"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaycapnhat"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoicapnhat"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["mota"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hoatdong"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["gia_db"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["chkPBGCu"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["phienbangiacu"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["daguiMail"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["loaiBG"] + "]]></cell>";
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }
    #endregion

    #endregion

    public bool IsReusable
    {
        get { return false; }
    }
}
