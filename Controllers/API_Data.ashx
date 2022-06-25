<%@ WebHandler Language="C#" Class="API_Data" %>

using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using Newtonsoft.Json;

public class API_Data : IHttpHandler {
    public JavaScriptSerializer js = new JavaScriptSerializer();
    private LinqDBDataContext db = new LinqDBDataContext();
    public string emailcc = "anco@ancopottery.com,info@ancopottery.com";
    //public string emailcc = "ngocnhan@esc.vn";
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.QueryString["oper"];
        switch (oper)
        {
            case "md_sanpham":
                this.md_sanpham(context);
                break;
        }
    }

    public void md_sanpham(HttpContext context)
    {
		var msg = "";
        var ma_sanphams = context.Request.Form["ma_sanphams"];
		try {
			var lstMSP = ma_sanphams.Split(',');
			var sps = db.md_sanphams.Where(s => lstMSP.Contains(s.ma_sanpham)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}