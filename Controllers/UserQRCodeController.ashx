<%@ WebHandler Language="C#" Class="UserQRCodeController" %>

using System;
using System.Web;
using System.Linq;

public class UserQRCodeController : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];

        switch (oper)
        {
            case "createLoginWebsite":
                this.createLoginWebsite(context);
                break;
            case "checkLoginWebsite":
                this.checkLoginWebsite(context);
                break;
            case "sendMail":
                this.SendMail(context);
                break;
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
    }

    public void createLoginWebsite(HttpContext context)
    {
        string msg = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var contactPass = context.Request.Form["contactPass"];
            var companyName = context.Request.Form["companyName"];
            var contactPerson = context.Request.Form["contactPerson"];
            var contactMessage = context.Request.Form["contactMessage"];

            var user = db.userQRCodes.Where(s => s.contactEmail == contactEmail).FirstOrDefault();
            if(user != null)
            {
                if(!user.hoatdong.GetValueOrDefault(false))
                    msg = "Email is inactive.";
                else
                    msg = "Email already exist, please check your email to get password (at least 1 day)";
            }
            else if(string.IsNullOrWhiteSpace(companyName))
            {
                msg = "Company Name is not empty";
            }
            else if(string.IsNullOrWhiteSpace(contactPerson))
            {
                msg = "Contact Person is not empty";
            }
            else if(string.IsNullOrWhiteSpace(contactEmail))
            {
                msg = "Email is not empty";
            }
            else if(string.IsNullOrWhiteSpace(contactMessage))
            {
                msg = "Message is not empty";
            }
            else
            {
                user = new userQRCode();
                user.userQRCode_id = Helper.getNewId();
                user.contactEmail = contactEmail;
                user.companyName = companyName;
                user.contactPerson = contactPerson;
                user.contactMessage = contactMessage;
                user.sendMail = false;
                user.type = 0;
                user.hoatdong = true;
                user.ngaytao = DateTime.Now;
                user.ngaycapnhat = DateTime.Now;
                user.nguoitao = "system";
                user.nguoicapnhat = "system";
                db.userQRCodes.InsertOnSubmit(user);
                db.SubmitChanges();
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if (msg.Length > 0)
            msg = "0" + msg;
        else
            msg = "1Successful registration, please check your email to get the password (at least 1 day)";

        context.Response.Write(msg);
    }

    public void checkLoginWebsite(HttpContext context)
    {
        string msg = "", token = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var contactPass = context.Request.Form["contactPass"];

            var user = db.userQRCodes.Where(s => s.contactEmail == contactEmail
                & (s.contactPass == contactPass | contactPass == "contactPassWillautoDetect")).FirstOrDefault();
            if(user == null)
            {
                msg = "Email or password is incorrect.";
            }
            else if(!user.hoatdong.GetValueOrDefault(false))
            {
                msg = "Email is inactive.";
            }
            else
            {
                var json = new System.Collections.Generic.Dictionary<string, string>();
                json["user"] = user.contactEmail;
                json["ngaytao"] = user.ngaytao.Value.ToString("dd/MM/yyyy");
                token = Newtonsoft.Json.JsonConvert.SerializeObject(json);
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if (msg.Length > 0)
            msg = "0" + msg;
        else
            msg = "1" + token;

        context.Response.Write(msg);
    }

    public void SendMail(HttpContext context)
    {
        string msg = "";
        try
        {
            var manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            var smtp = db.md_smtps.FirstOrDefault(p => p.macdinh.Equals(true));
            var mail = new GoogleMail(nv.email, nv.email_pass, smtp.smtpserver, smtp.port.Value, smtp.use_ssl.GetValueOrDefault(false));
            var temp = ExcuteSignalRStatic.mapPathSignalR("~/App_Data/MailTemp/QRCode-SendPass.html");
            temp = System.IO.File.ReadAllText(temp);
            var ids = context.Request.Form["ids"].Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();

            foreach (var id in ids)
            {
                var kh = db.userQRCodes.Where(s => s.userQRCode_id == id).FirstOrDefault();

                if (kh == null)
                {
                    msg = "Dòng đang chọn không tồn tại, hãy làm mới dữ liệu.";
                }
                else
                {
                    var pass = System.Web.Security.Membership.GeneratePassword(6, 1);
                    pass = pass.Replace("&", "VA");
                    pass = pass.Replace("+", "CO");
                    pass = pass.Replace("%", "PT");
                    pass = pass.Replace("?", "HO");
                    pass = "12" + pass + "21";
                    var tempCP = temp;
                    var lst = tempCP.Split(new string[] { "\n", "\r" }, StringSplitOptions.None).ToList();
                    var sb = lst[0];
                    sb = sb.Replace("<!--", "").Replace("-->", "");

                    lst.RemoveAt(0);
                    var bd = string.Join("\n", lst);
                    bd = bd.Replace("@[NAME]", kh.companyName);
                    bd = bd.Replace("@[PASS]", pass);
                    mail.Send(
                        kh.contactEmail
                        , sb
                        , bd
                    );

                    kh.contactPass = pass;
                    kh.sendMail = true;
                }
            }

            if(msg.Length <= 0)
                db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            msg =  "0" + msg;
        else
            msg =  "1Gửi mail thành công.";

        context.Response.Write(msg);
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var hoatdong = context.Request.Form["hoatdong"].ToLower() == "true";
            var nv = db.userQRCodes.Where(s => s.contactEmail == contactEmail).FirstOrDefault();
            if (nv == null)
            {
                msg = "Email không tồn tại, hãy làm mới dữ liệu.!";
            }
            else
            {
                nv.hoatdong = hoatdong;
            }
            db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Sửa thành công");
    }

    public void add(HttpContext context)
    {
        string msg = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var companyName = context.Request.Form["companyName"];
            var contactPerson = context.Request.Form["contactPerson"];
            var contactMessage = context.Request.Form["contactMessage"];
            var type = int.Parse(context.Request.Form["type"]);
            var hoatdong = context.Request.Form["hoatdong"].ToLower() == "true";

            var nv = db.userQRCodes.Where(s => s.contactEmail == contactEmail).FirstOrDefault();
            if (nv == null)
            {
                nv = new userQRCode();
                nv.userQRCode_id = Helper.getNewId();
                nv.contactEmail = contactEmail;
                nv.companyName = companyName;
                nv.contactPerson = contactPerson;
                nv.contactMessage = contactMessage;
                nv.sendMail = false;
                nv.type = type;
                nv.hoatdong = hoatdong;
                nv.ngaytao = DateTime.Now;
                nv.ngaycapnhat = DateTime.Now;
                nv.nguoitao = UserUtils.getUser(context);
                nv.nguoicapnhat = UserUtils.getUser(context);
                nv.hoatdong = hoatdong;
                db.userQRCodes.InsertOnSubmit(nv);
                db.SubmitChanges();
            }
            else
            {
                msg = "Email đã tồn tại.!";
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Thêm thành công");
    }


    public void del(HttpContext context)
    {
        string msg = "";
        try
        {
            var ids = context.Request.Form["id"].Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();

            foreach (var id_del_ in ids)
            {
                var nv = db.userQRCodes.Where(s => s.userQRCode_id == id_del_).FirstOrDefault();

                if (nv == null)
                {
                    msg = "Dòng đang chọn không tồn tại, hãy làm mới dữ liệu.";
                }
                else
                {
                    db.userQRCodes.DeleteOnSubmit(nv);
                }
            }

            if(msg.Length <= 0)
                db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Xóa thành công");
    }

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

        String sqlCount = "SELECT COUNT(1) AS count from userQRCode nv where 1=1 " + filter;
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
            sidx = "nv.ngaytao";
        }

        string strsql = string.Format(@"
            select 
                P.userQRCode_id,
                P.contactEmail,
                P.contactPass,
                P.companyName,
                P.contactPerson,
                P.contactMessage,
                P.sendMail,
                P.type,
                P.ngaytao,
                P.nguoitao,
                P.ngaycapnhat,
                P.nguoicapnhat,
                P.mota,
                P.hoatdong
            from( 
                select nv.*, 
                ROW_NUMBER() OVER (ORDER BY {0} {1}) as RowNum 
                from userQRCode nv 
                where 1=1 {2}  
            )P 
            where RowNum > @start AND RowNum < @end
        ",
        sidx,
        sord,
        filter
        );

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn col in dt.Columns)
            {
                if (new string[] { "ngaytao", "ngaycapnhat" }.Contains(col.ColumnName))
                {
                    var colDate = row[col.ColumnName] + "";
                    if(!string.IsNullOrEmpty(colDate))
                        xml += "<cell><![CDATA[" + DateTime.Parse(colDate.ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
                }
                else
                {
                    xml += "<cell><![CDATA[" + row[col.ColumnName] + "]]></cell>";
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