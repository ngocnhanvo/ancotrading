<%@ WebHandler Language="C#" Class="PhiDatHangController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;

public class PhiDatHangController : IHttpHandler, IDisposable
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void Dispose()
    {
        if (db != null)
        {
            db.Dispose();
            db = null;
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.DisposeOnPipelineCompleted(this);
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "getoption":
                this.getSelectOption(context);
                break;
            default:
                switch (oper)
                {
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
                break;
        }
    }

    public void getSelectOption(HttpContext context)
    {
        //String sql = "select md_bocai_id, code_bc from md_bocai where hoatdong = 1 order by code_bc desc";
        //SelectHtmlControl s = new SelectHtmlControl(sql);
        //context.Response.Write(s.ToString());
    }


    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;

        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        String phitang = context.Request.Form["isphicong"].ToLower();
        if (phitang.Equals("on") || phitang.Equals("true"))
        {
            phitang = "true";
        }
        else
        {
            phitang = "false";
        }

        c_phidathang m = db.c_phidathangs.FirstOrDefault(p => p.c_phidathang_id == context.Request.Form["id"]);
        c_danhsachdathang dsdh = db.c_danhsachdathangs.FirstOrDefault(ddh => ddh.c_danhsachdathang_id.Equals(m.c_danhsachdathang_id));
        if (dsdh != null)
        {
			if(dsdh.md_trangthai_id=="SOANTHAO")
			{
				m.sotien = decimal.Parse(context.Request.Form["sotien"]);
				m.isphicong = bool.Parse(phitang);

				m.mota = context.Request.Form["mota"];
				m.hoatdong = hd;
				m.ngaycapnhat = DateTime.Now;
				m.nguoicapnhat = UserUtils.getUser(context);

				db.SubmitChanges();
			}else{
				jqGridHelper.Utils.writeResult(0,"Không được chỉnh sửa vì đơn đặt hàng đã hiệu lực!");
			}
        }
        else
        {
            jqGridHelper.Utils.writeResult(0,"Không tìm thấy đơn đặt hàng, có thể đã được xóa trước đó!");
        }
    }

    public void add(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        String phitang = context.Request.Form["isphicong"].ToLower();
        if (phitang.Equals("on") || phitang.Equals("true"))
        {
            phitang = "true";
        }
        else
        {
            phitang = "false";
        }

        String c_donhang_id = context.Request.Form["c_danhsachdathang_id"];
        
        c_danhsachdathang dh = db.c_danhsachdathangs.FirstOrDefault(p => p.c_danhsachdathang_id.Equals(c_donhang_id));
        if (dh != null)
        {
			if(dh.md_trangthai_id=="SOANTHAO")
			{
				c_phidathang mnu = new c_phidathang
				{
					c_phidathang_id = Security.EncodeMd5Hash(DateTime.Now.ToString("yyyyMMddddhhmmss")),
					c_danhsachdathang_id = context.Request.Form["c_danhsachdathang_id"],
					sotien = decimal.Parse(context.Request.Form["sotien"]),
					isphicong = bool.Parse(phitang),

					mota = context.Request.Form["mota"],
					hoatdong = hd,
					ngaytao = DateTime.Now,
					ngaycapnhat = DateTime.Now,
					nguoitao = UserUtils.getUser(context),
					nguoicapnhat = UserUtils.getUser(context)
				};

				db.c_phidathangs.InsertOnSubmit(mnu);
				db.SubmitChanges();
			}else
			{
				jqGridHelper.Utils.writeResult(0,"Không được thêm phí vì đơn đặt hàng đã hiệu lực!");
			}
        }
        else
        {
            jqGridHelper.Utils.writeResult(0,"Không tìm thấy đơn đặt hàng, có thể đã được xóa trước đó!");
        }
    }


    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"];
        c_phidathang pdh = db.c_phidathangs.FirstOrDefault(p => p.c_phidathang_id.Equals(id));
        c_danhsachdathang dsdh = db.c_danhsachdathangs.FirstOrDefault(c => c.c_danhsachdathang_id.Equals(pdh.c_danhsachdathang_id));
		if	(dsdh.md_trangthai_id =="SOANTHAO")
		{
			db.c_phidathangs.DeleteOnSubmit(pdh);
			db.SubmitChanges();
		}
		else
		{
			jqGridHelper.Utils.writeResult(0,"Không được xóa vì đơn đặt hàng đã hiệu lực!");
		}
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        String poId = context.Request.QueryString["poId"];
        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        string sqlCount = $@"SELECT COUNT(1) AS count FROM c_phidathang WHERE 1=1 {filter} and c_danhsachdathang_id ='{poId}'";
        
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
            sidx = "bc.md_bocai_id";
        }

        string strsql = $@"
        select * from (
            select bc.*, 
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM 
                c_phidathang bc WHERE 1=1 {filter} and c_danhsachdathang_id = '{poId}'
        )P 
        where 
        P.RowNum > @start AND P.RowNum < @end";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["c_phidathang_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["c_danhsachdathang_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["sotien"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["isphicong"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["trangthai"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaytao"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaycapnhat"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoicapnhat"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["mota"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hoatdong"] + "]]></cell>";
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
