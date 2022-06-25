<%@ WebHandler Language="C#" Class="API_Data" %>

using System;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using Newtonsoft.Json;

public class API_Data : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.Params["oper"];
        switch (oper)
        {
            case "md_sanpham":
                this.md_sanpham(context);
                break;
			case "md_chungloai":
                this.md_chungloai(context);
                break;
			case "md_chucnang":
                this.md_chucnang(context);
                break;
			case "md_cangbien":
                this.md_cangbien(context);
                break;
			case "md_donvitinhsanpham":
                this.md_donvitinhsanpham(context);
                break;
			case "md_hscode":
                this.md_hscode(context);
                break;
			case "md_kieudang":
                this.md_kieudang(context);
                break;
			case "md_nhomnangluc":
                this.md_nhomnangluc(context);
                break;
			case "md_phanloaihh":
                this.md_phanloaihh(context);
                break;
			case "md_donggoisanpham":
                this.md_donggoisanpham(context);
                break;
			case "md_donggoi":
                this.md_donggoi(context);
                break;
			case "md_hanghoadocquyen":
                this.md_hanghoadocquyen(context);
                break;
			case "md_doitackinhdoanh":
                this.md_doitackinhdoanh(context);
                break;
			case "md_cangxuathang":
                this.md_cangxuathang(context);
                break;
			case "md_bientau":
                this.md_bientau(context);
                break;
			case "md_nhacungungmacdinh":
                this.md_nhacungungmacdinh(context);
                break;
        }
    }

    public void md_sanpham(HttpContext context)
    {
		var msg = "";
        var ma_sanphams = context.Request.Form["ma_sanphams"];
		try 
		{
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
	
	public void md_chungloai(HttpContext context)
    {
		var msg = "";
        var chungloais = context.Request.Form["chungloais"];
		try 
		{
			var lstMSP = chungloais.Split(',');
			var sps = db.md_chungloais.Where(s => lstMSP.Contains(s.md_chungloai_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_chucnang(HttpContext context)
    {
		var msg = "";
        var chucnangs = context.Request.Form["chucnangs"];
		try 
		{
			var lstMSP = chucnangs.Split(',');
			var sps = db.md_chucnangs.Where(s => lstMSP.Contains(s.md_chucnang_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_cangbien(HttpContext context)
    {
		var msg = "";
        var cangbiens = context.Request.Form["cangbiens"];
		try 
		{
			var lstMSP = cangbiens.Split(',');
			var sps = db.md_cangbiens.Where(s => lstMSP.Contains(s.md_cangbien_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_donvitinhsanpham(HttpContext context)
    {
		var msg = "";
        var donvitinhsanphams = context.Request.Form["donvitinhsanphams"];
		try 
		{
			var lstMSP = donvitinhsanphams.Split(',');
			var sps = db.md_donvitinhsanphams.Where(s => lstMSP.Contains(s.md_donvitinhsanpham_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_hscode(HttpContext context)
    {
		var msg = "";
        var hscodes = context.Request.Form["hscodes"];
		try 
		{
			var lstMSP = hscodes.Split(',');
			var sps = db.md_hscodes.Where(s => lstMSP.Contains(s.md_hscode_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_kieudang(HttpContext context)
    {
		var msg = "";
        var kieudangs = context.Request.Form["kieudangs"];
		try 
		{
			var lstMSP = kieudangs.Split(',');
			var sps = db.md_kieudangs.Where(s => lstMSP.Contains(s.md_kieudang_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_nhomnangluc(HttpContext context)
    {
		var msg = "";
        var nhomnanglucs = context.Request.Form["nhomnanglucs"];
		try 
		{
			var lstMSP = nhomnanglucs.Split(',');
			var sps = db.md_nhomnanglucs.Where(s => lstMSP.Contains(s.md_nhomnangluc_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_phanloaihh(HttpContext context)
    {
		var msg = "";
        var phanloaihhs = context.Request.Form["phanloaihhs"];
		try 
		{
			var lstMSP = phanloaihhs.Split(',');
			var sps = db.md_phanloaihhs.Where(s => lstMSP.Contains(s.md_phanloaihh_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_donggoisanpham(HttpContext context)
    {
		var msg = "";
        var sanphams = context.Request.Form["sanphams"];
		try 
		{
			var lstMSP = sanphams.Split(',');
			var sps = db.md_donggoisanphams.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_donggoi(HttpContext context)
    {
		var msg = "";
        var donggois = context.Request.Form["donggois"];
		try 
		{
			var lstMSP = donggois.Split(',');
			var sps = db.md_donggois.Where(s => lstMSP.Contains(s.md_donggoi_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_hanghoadocquyen(HttpContext context)
    {
		var msg = "";
        var sanphams = context.Request.Form["sanphams"];
		try 
		{
			var lstMSP = sanphams.Split(',');
			var sps = db.md_hanghoadocquyens.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_doitackinhdoanh(HttpContext context)
    {
		var msg = "";
        var doitackinhdoanhs = context.Request.Form["doitackinhdoanhs"];
		try 
		{
			var lstMSP = doitackinhdoanhs.Split(',');
			var sps = db.md_doitackinhdoanhs.Where(s => lstMSP.Contains(s.md_doitackinhdoanh_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_cangxuathang(HttpContext context)
    {
		var msg = "";
        var sanphams = context.Request.Form["sanphams"];
		try 
		{
			var lstMSP = sanphams.Split(',');
			var sps = db.md_cangxuathangs.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_bientau(HttpContext context)
    {
		var msg = "";
        var sanphams = context.Request.Form["sanphams"];
		try 
		{
			var lstMSP = sanphams.Split(',');
			var sps = db.md_bientaus.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
			msg = "1" + JsonConvert.SerializeObject(sps);
		}
		catch(Exception ex) 
		{
			msg = "0" + ex;
		}
		context.Response.Write(msg);
    }
	
	public void md_nhacungungmacdinh(HttpContext context)
    {
		var msg = "";
        var sanphams = context.Request.Form["sanphams"];
		try 
		{
			var lstMSP = sanphams.Split(',');
			var sps = db.md_nhacungungmacdinhs.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
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