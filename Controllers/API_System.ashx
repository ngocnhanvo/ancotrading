<%@ WebHandler Language="C#" Class="API_System" %>

using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;

public class API_System : IHttpHandler {
    public JavaScriptSerializer js = new JavaScriptSerializer();
    private LinqDBDataContext db = new LinqDBDataContext();
    public string emailcc = "anco@ancopottery.com,info@ancopottery.com";
    //public string emailcc = "ngocnhan@esc.vn";
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.QueryString["oper"];
        switch (oper)
        {
            case "loadImageProduct":
                this.loadImageProduct(context);
                break;
            case "loadImageDetai":
                this.loadImageDetai(context);
                break;
            case "loadImageMauSac":
                this.loadImageMauSac(context);
                break;
            case "loadPDF":
                this.loadPDF(context);
                break;
        }
    }
    public void loadPDF(HttpContext context)
    {
        var urlPDF = context.Request.QueryString["urlPDF"];
        var removePDF = context.Request.QueryString["remove"];
        urlPDF = urlPDF.Substring(0, urlPDF.LastIndexOf("?") <= 0 ? urlPDF.Length : urlPDF.LastIndexOf("?"));
        var url = context.Server.MapPath(urlPDF);
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();
        lastIndex = url.LastIndexOf("/");
        var fileName = url.Substring(lastIndex + 1).ToLower();

        using (var fileStream = new FileStream(url, FileMode.Open))
        {
            using (var memoryStream = new MemoryStream())
            {
                fileStream.CopyTo(memoryStream);
                context.Response.ContentType = mimeType == "pdf" ? "application/pdf" : "image/jpeg";
                context.Response.BinaryWrite(memoryStream.ToArray());
            }
        }

        if (File.Exists(url) & removePDF == "true")
        {
            File.Delete(url);
        }
    }

    public void loadImageMauSac(HttpContext context)
    {
        var msp = context.Request.QueryString["msp"];
        var url = context.Server.MapPath("../" + Public.imgColor + msp + ".jpg");
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (!File.Exists(url))
            url = context.Server.MapPath("../" + Public.imgNotFound);

        using (var fileStream = new FileStream(url, FileMode.Open))
        {
            using (var memoryStream = new MemoryStream())
            {
                fileStream.CopyTo(memoryStream);
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.BinaryWrite(memoryStream.ToArray());
            }
        }
    }

    public void loadImageDetai(HttpContext context)
    {
        var msp = context.Request.QueryString["msp"];
        var url = context.Server.MapPath("../" + Public.imgPattern + msp + ".jpg");
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (!File.Exists(url))
            url = context.Server.MapPath("../" + Public.imgNotFound);

        using (var fileStream = new FileStream(url, FileMode.Open))
        {
            using (var memoryStream = new MemoryStream())
            {
                fileStream.CopyTo(memoryStream);
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.BinaryWrite(memoryStream.ToArray());
            }
        }
    }

    public void loadImageProduct(HttpContext context)
    {
        var msp = context.Request.QueryString["msp"];
        var path = ExcuteSignalRStatic.getImageProduct(msp);
        var url = ExcuteSignalRStatic.mapPathSignalR("~/" + path);
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (!File.Exists(url))
            url = context.Server.MapPath("../" + Public.imgNotFound);

        using (var fileStream = new FileStream(url, FileMode.Open))
        {
            using (var memoryStream = new MemoryStream())
            {
                fileStream.CopyTo(memoryStream);
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.BinaryWrite(memoryStream.ToArray());
            }
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}