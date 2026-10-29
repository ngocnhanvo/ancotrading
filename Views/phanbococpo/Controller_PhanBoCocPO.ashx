<%@ WebHandler Language="C#" Class="Controller_PhanBoCocPO" %>
using System;
using System.Web;

public class Controller_PhanBoCocPO : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        // Intentionally no database operations in the interface-only phase.
        // Never accept allocation writes until authorization, draft status,
        // balance checks and atomic activation are implemented.
        context.Response.Clear();
        context.Response.ContentType = "application/json";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.StatusCode = 501;
        context.Response.TrySkipIisCustomErrors = true;
        context.Response.Write("{\"ok\":false,\"code\":\"not_implemented\",\"message\":\"Chức năng phân bổ cọc PO đang ở giai đoạn giao diện, chưa kết nối dữ liệu.\"}");
    }

    public bool IsReusable { get { return false; } }
}
