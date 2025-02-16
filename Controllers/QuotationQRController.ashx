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
            case "chuyenThanhQO":
                this.chuyenThanhQO(context);
                break;
            default:
                switch (oper)
                {
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
            foreach(var file in json.files)
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


            foreach(var fileByte in fileBytes)
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
            //cc = nv.email_cc;
            bcc = from;
            subject = tmp.subject_mail;
            body = tmp.content_mail.Replace("%0D", "<br/>").Replace("[ten_dtkd]", kh.ten_dtkd);

            string name = $"{nv.manv}-Quotation-.xls", mime = "";
            long size = 0;
            string linkDic = ExcuteSignalRStatic.mapPathSignalR($"~/SendMail/quotation/{bg.c_baogiaqr_id}");
            if(!Directory.Exists(linkDic))
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
    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"];
        var qo = db.c_baogiaqrs.Single(q => q.c_baogiaqr_id.Equals(id));
        if (qo.md_trangthai_id.Equals("SOANTHAO"))
        {
            foreach (var ctbg in db.c_chitietbaogiaqrs.Where(s => s.c_baogiaqr_id == id))
            {
                db.c_chitietbaogiaqrs.DeleteOnSubmit(ctbg);
            }

            foreach (var colorRef in db.md_color_references.Where(s => s.c_baogia_id == id))
            {
                db.md_color_references.DeleteOnSubmit(colorRef);
            }
            db.SubmitChanges();

            db.c_baogiaqrs.DeleteOnSubmit(qo);
            db.SubmitChanges();
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, "Không thể xóa báo giá đã hiệu lực!");
        }
    }

    #region load
    public void chuyenThanhQO(HttpContext context)
    {
        string c_baogia_id = context.Request.Form["id"];
        c_baogiaqr bgqr = db.c_baogiaqrs.FirstOrDefault(s => s.c_baogiaqr_id == c_baogia_id);
        Dictionary<string, object> lstMsg = new Dictionary<string, object>();
        int status = 0;
        string mess = "";
        if (bgqr != null)
        {
            md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == bgqr.md_doitackinhdoanh_id).FirstOrDefault();

            if (string.IsNullOrEmpty(dtkd.ma_dtkd))
            {
                mess += "<br>Thiếu mã đối tác.";
            }
            if (string.IsNullOrEmpty(dtkd.ten_dtkd))
            {
                mess += "<br>Thiếu tên đối tác.";
            }
            if (string.IsNullOrEmpty(dtkd.tel))
            {
                mess += "<br>Thiếu số điện thoại của đối tác.";
            }
            if (string.IsNullOrEmpty(dtkd.fax))
            {
                mess += "<br>Thiếu số Fax.";
            }
            if (string.IsNullOrEmpty(dtkd.md_quocgia_id))
            {
                mess += "<br>Thiếu quốc gia.";
            }
            if (string.IsNullOrEmpty(dtkd.md_khuvuc_id))
            {
                mess += "<br>Thiếu khu vực.";
            }

            if (mess.Length > 0)
            {
                mess = mess.Substring(4);
            }
            else
            {
                try
                {
                    //string bgid = Guid.NewGuid().ToString().Replace("-", "");
                    string bgid = bgqr.c_baogiaqr_id;
                    String sochungtu = jqGridHelper.Utils.taoChungTuQO(bgqr.md_doitackinhdoanh_id, 1, DateTime.Now.Year.ToString());
                    c_baogia bg = bgqr.Cast<c_baogia>();
                    bg.c_baogia_id = bgid;
                    bg.sobaogia = sochungtu;
                    db.c_baogias.InsertOnSubmit(bg);

                    foreach (var ctbgqr in db.c_chitietbaogiaqrs.Where(s => s.c_baogiaqr_id == c_baogia_id))
                    {
                        c_chitietbaogia ctbg = ctbgqr.Cast<c_chitietbaogia>();
                        ctbg.c_chitietbaogia_id = ctbgqr.c_chitietbaogiaqr_id;
                        ctbg.c_baogia_id = bgid;
                        db.c_chitietbaogias.InsertOnSubmit(ctbg);
                        db.c_chitietbaogiaqrs.DeleteOnSubmit(ctbgqr);
                    }

                    db.c_baogiaqrs.DeleteOnSubmit(bgqr);
                    db.SubmitChanges();
                    status = 1;
                    mess = sochungtu;
                }
                catch (Exception ex)
                {
                    mess = ex.Message;
                }
            }
        }
        else
        {
            mess = "Không tìm thấy báo giá, hãy làm mới lại lưới dữ liệu.";
        }

        lstMsg.Add("status", status);
        lstMsg.Add("mess", mess);

        context.Response.Write(JsonConvert.SerializeObject(lstMsg));
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
            baogia.gia_db, baogia.daguiMail, baogia.chkPBGCu, baogia.phienbangiacu,
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
