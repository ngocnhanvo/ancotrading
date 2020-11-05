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
        var url = context.Server.MapPath("../" + ExcuteSignalRStatic.getImageProduct(msp));
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (!File.Exists(url))
            url = context.Server.MapPath("../" + Public.imgNotFound);

        using (var fileStream = new FileStream(url, FileMode.Open))
        {
            using (var memoryStream = new MemoryStream())
            {
                fileStream.CopyTo(memoryStream);
                context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                context.Response.Cache.SetExpires(DateTime.Now);
                context.Response.Cache.SetNoServerCaching();
                context.Response.Cache.SetNoStore();
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