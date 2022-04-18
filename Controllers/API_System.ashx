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
            case "loadImageProductWeb":
                this.loadImageProductWeb(context);
                break;
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
            case "downloadFile":
                this.downloadFile(context);
                break;
        }
    }

    public void downloadFile(HttpContext context)
    {
        string name = context.Request.QueryString["name"];
        string type = context.Request.QueryString["type"];
        string path = context.Request.QueryString["path"];
        var remove = context.Request.QueryString["remove"] == "true";
        path = ExcuteSignalRStatic.mapPathSignalR("~/" + path);
        if (File.Exists(path))
        {
            context.Response.Clear();
            context.Response.Buffer = true;
            context.Response.AddHeader("Content-Disposition", "attachment;filename=" + name);
            context.Response.Charset = "";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.WriteFile(path);
            context.Response.Flush();
            if(remove)
                File.Delete(path);
            context.Response.End();
        }
        else
        {
            context.Response.Write(string.Format("Không tìm thấy đường dẫn<br>{0}", path));
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
                var array = memoryStream.ToArray();
                fileStream.Close();
                fileStream.Dispose();
                memoryStream.Close();
                memoryStream.Dispose();
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.BinaryWrite(array);
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
                var array = memoryStream.ToArray();
                fileStream.Close();
                fileStream.Dispose();
                memoryStream.Close();
                memoryStream.Dispose();
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.BinaryWrite(array);
            }
        }
    }

    public void loadImageProductWeb(HttpContext context)
    {
        var msp = context.Request.QueryString["msp"];
        var path = ExcuteSignalRStatic.getImageProductWeb(msp);
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
                var array = memoryStream.ToArray();
                fileStream.Close();
                fileStream.Dispose();
                memoryStream.Close();
                memoryStream.Dispose();
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.BinaryWrite(array);
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
                var array = memoryStream.ToArray();
                fileStream.Close();
                fileStream.Dispose();
                memoryStream.Close();
                memoryStream.Dispose();
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.BinaryWrite(array);
            }
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}