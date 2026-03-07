using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text.RegularExpressions;
using System.IO;

public class GoogleMail
{
    private int _port;
    private String _email, _password, _smtp;
    private bool _ssl;
    public String Smtp
    {
        get { return _smtp; }
        set { _smtp = value; }
    }

    public String Password
    {
        get { return _password; }
        set { _password = value; }
    }

    public String Email
    {
        get { return _email; }
        set { _email = value; }
    }

    public int Port
    {
        get { return _port; }
        set { _port = value; }
    }

    public bool Ssl
    {
        get { return _ssl; }
        set { _ssl = value; }
    }

    public List<Attachment> Attachments { get; set; }

    public GoogleMail()
    { 
    
    }

    public GoogleMail(String email, String password, String smtp, int port)
    {
        this._email = email;
        this._password = password;
        this._smtp = smtp;
        this._port = port;
        this._ssl = false;
    }

    public GoogleMail(String email, String password, String smtp, int port, bool ssl)
    {
        this._email = email;
        this._password = password;
        this._smtp = smtp;
        this._port = port;
        this._ssl = ssl;
    }

    public void Send(String to, String subject, String body, params object[] args)
    {
        String from = _email;
        this.Send(from, to, "", "", subject, body, "", args);
    }

    public void Send(String from, String to, String subject, String body, params object[] args)
    {
        this.Send(from, to, "", "", subject, body, "", args);
    }

    public void Send(String from, String to, String cc, String subject, String body, String attachments, params object[] args)
    {
        this.Send(from, to, cc, "", subject, body, attachments, args);
    }

    public void Send(String from, String to, String cc, String bcc, String subject, String body, String attachments, params object[] args)
    {
        Send2(from, to, cc, bcc, subject, body, attachments);
    }

    public void Send(String from, String to, String cc, String bcc, String subject, String body, List<Attachment> attachments, params object[] args)
    {
        if (Attachments == null)
            Attachments = new List<Attachment>();
        Attachments.AddRange(attachments);
        this.Send2(from, to, cc, bcc, subject, body, "");
    }

    public void Send2(String from, String to, String cc, String bcc, String subject, String body, String attachments, params object[] args)
    {
        if (Attachments == null)
            Attachments = new List<Attachment>();

        if (Regex.IsMatch(body, "^([cCdDeEfFgGhHiIjI]:).+"))
        {
            body = File.ReadAllText(body);
        }
        body = String.Format(body, args);

        MailMessage mail = new MailMessage();
        mail.From = new MailAddress(from);

        if (!String.IsNullOrEmpty(attachments))
        {
            String[] fileNames = attachments.Split(";,".ToCharArray());
            foreach (String fileName in fileNames)
            {
                if (fileName.Trim().Length > 0)
                {
                    Attachments.Add(new Attachment(fileName.Trim()));
                }
            }
        }

        foreach (var attachment in Attachments)
        {
            mail.Attachments.Add(attachment);
        }

        to = to.Replace(" ", "");
        string[] tos = to.Split(";,".ToArray());
        foreach (string item in tos)
        {
            mail.To.Add(new MailAddress(item));
        }

        mail.Subject = subject;
        mail.Body = body;
        mail.IsBodyHtml = true;

        if (!String.IsNullOrEmpty(cc))
        {
            mail.CC.Add(cc);
        }

        if (!String.IsNullOrEmpty(bcc))
        {
            mail.Bcc.Add(bcc);
        }

        if (_smtp.Contains("smtp.office365.com"))
        {
            var m365 = new M365Mail();
            m365.email = _email;
            m365.pass = _password;
            m365.to = to;
            m365.cc = cc;
            m365.bcc = bcc;
            m365.subject = subject;
            m365.attachments = Attachments;
            m365.body = body;
            m365.SendEmailOAuth2Sync();
        }
        else
        {
            //ServicePointManager.ServerCertificateValidationCallback += (o, c, ch, er) => true;
            if(Ssl)
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            SmtpClient client = new SmtpClient(_smtp, _port);
            //client.Timeout = 1000;
            client.EnableSsl = Ssl;
            client.UseDefaultCredentials = false;
            client.Credentials = new NetworkCredential(_email, _password);
            client.Send(mail);
            client.Dispose();
        }

        foreach (var attachment in Attachments)
        {
            attachment.Dispose();
        }

        mail.Dispose();
    }
}
