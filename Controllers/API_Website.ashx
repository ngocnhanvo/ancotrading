<%@ WebHandler Language="C#" Class="API_Website" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using Newtonsoft.Json;

public class API_Website : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.Params["oper"];
        switch (oper)
        {
            case "sendContact":
                this.sendContact(context);
                break;
        }
    }

    public void sendContact(HttpContext context)
    {
        string msg = "";
        try
        {
            string from = "admin@email";
            string to = context.Request.Form["to"];
            string cc = context.Request.Form["cc"];
            string bcc = context.Request.Form["bcc"];
            string subject = Extension.DecodeHTML(context.Request.Form["subject"].removeAllSpaceOrTrimText(true));
            string body = Extension.DecodeHTML(context.Request.Form["body"].removeAllSpaceOrTrimText(true));

            var nv = db.nhanviens.Where(s => s.manv == from).FirstOrDefault();
            if (nv == null)
            {
                msg = "0Automated email account not found";
            }
            else
            {
                var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
                if(!string.IsNullOrWhiteSpace(nv.smtp))
                    smtp = db.md_smtps.Where(s => s.md_smtp_id == nv.smtp).FirstOrDefault();
                var mail = new GoogleMail();
                mail.Email = nv.email;
                mail.Password = nv.email_pass;
                mail.Smtp = smtp.smtpserver;
                mail.Port = smtp.port.Value;
                mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);
                mail.Send2(from, to, cc, bcc, subject, body, "");
                msg = "1Email sent successfully";
            }
        }
        catch(Exception ex)
        {
            msg = "0" + ex.ToString();
        }

        context.Response.Write(msg);
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}