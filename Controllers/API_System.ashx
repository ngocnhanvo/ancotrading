<%@ WebHandler Language="C#" Class="API_System" %>

using System;
using System.IO;
using System.Web;
using System.Linq;
using System.Web.Script.Serialization;

public class API_System : IHttpHandler
{
    public JavaScriptSerializer js = new JavaScriptSerializer();
    private LinqDBDataContext db = new LinqDBDataContext();
    public string emailcc = "anco@ancopottery.com,info@ancopottery.com";
    //public string emailcc = "ngocnhan@esc.vn";
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.QueryString["oper"];
        switch (oper)
        {
            case "loadImagePresent":
                this.loadImagePresent(context);
                break;
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
        var ttid = context.Request.QueryString["id"];
        string name = context.Request.QueryString["name"];
        string path = context.Request.QueryString["path"];
        string type = context.Request.QueryString["type"];
        var remove = false;

        if (string.IsNullOrWhiteSpace(ttid))
        {
            remove = context.Request.QueryString["remove"] == "true";
            path = ExcuteSignalRStatic.mapPathSignalR($@"~/{path}");
        }
        else
        {
            var tt = db.md_taptins.Where(s => s.md_taptin_id == ttid).FirstOrDefault();
            if (tt != null)
            {
                name = tt.tentaptin;
                path = ExcuteSignalRStatic.mapPathSignalR($@"~/{tt.path}");
            }
        }

        if (File.Exists(path))
        {
            string encodedFileName = Uri.EscapeDataString(name);
            context.Response.Clear();
            context.Response.Buffer = true;
            context.Response.AddHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName);
            context.Response.Charset = "";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.WriteFile(path);
            context.Response.Flush();
            if (remove)
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

        // using (var fileStream = new FileStream(url, FileMode.Open))
        // {
        // using (var memoryStream = new MemoryStream())
        // {
        // fileStream.CopyTo(memoryStream);
        // var array = memoryStream.ToArray();
        // fileStream.Close();
        // fileStream.Dispose();
        // memoryStream.Close();
        // memoryStream.Dispose();
        // context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
        // context.Response.BinaryWrite(array);
        // }
        // }

        context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
        context.Response.TransmitFile(url);
    }

    public void loadImageDetai(HttpContext context)
    {
        var msp = context.Request.QueryString["msp"];
        var url = context.Server.MapPath("../" + Public.imgPattern + msp + ".jpg");
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (!File.Exists(url))
            url = context.Server.MapPath("../" + Public.imgNotFound);

        // using (var fileStream = new FileStream(url, FileMode.Open))
        // {
        // using (var memoryStream = new MemoryStream())
        // {
        // fileStream.CopyTo(memoryStream);
        // var array = memoryStream.ToArray();
        // fileStream.Close();
        // fileStream.Dispose();
        // memoryStream.Close();
        // memoryStream.Dispose();
        // context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
        // context.Response.BinaryWrite(array);
        // }
        // }

        context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
        context.Response.TransmitFile(url);
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

        // using (var fileStream = new FileStream(url, FileMode.Open))
        // {
        // using (var memoryStream = new MemoryStream())
        // {
        // fileStream.CopyTo(memoryStream);
        // var array = memoryStream.ToArray();
        // fileStream.Close();
        // fileStream.Dispose();
        // memoryStream.Close();
        // memoryStream.Dispose();
        // context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
        // context.Response.BinaryWrite(array);
        // }
        // }

        context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
        context.Response.TransmitFile(url);
    }

    public void loadImageProduct(HttpContext context)
    {
        try
        {
            var msp = context.Request.QueryString["msp"];
			var notimg = context.Request.QueryString["notimg"] == "true";
            var showlink = context.Request.QueryString["showlink"] == "true";
            var path = ExcuteSignalRStatic.getImageProduct(msp, notimg);
            var url = ExcuteSignalRStatic.mapPathSignalR("~/" + path);
            var lastIndex = url.LastIndexOf(".");
            var mimeType = url.Substring(lastIndex + 1).ToLower();

            if (!File.Exists(url))
                url = context.Server.MapPath("../" + Public.imgNotFound);

            if (showlink)
                context.Response.Write(url);
            else
            {
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.TransmitFile(url);
            }
        }
        catch (Exception ex)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write(ex.Message);
            return;
        }

        context.Response.End();
    }

    public void loadImagePresent(HttpContext context)
    {
        try
        {
            var msp = context.Request.QueryString["msp"];
            var showlink = context.Request.QueryString["showlink"] == "true";
            var path = ExcuteSignalRStatic.getImage(msp, 0);
            var url = ExcuteSignalRStatic.mapPathSignalR("~/" + path);
            var lastIndex = url.LastIndexOf(".");
            var mimeType = url.Substring(lastIndex + 1).ToLower();

            if (!File.Exists(url))
                url = context.Server.MapPath("../" + Public.imgNotFound);

            if (showlink)
                context.Response.Write(url);
            else
            {
                context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
                context.Response.TransmitFile(url);
            }
        }
        catch (Exception ex)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write(ex.Message);
            return;
        }

        context.Response.End();
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}