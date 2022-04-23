<%@ WebHandler Language="C#" Class="CollectionController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;

public class CollectionController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
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

    public void edit(HttpContext context)
    {
        var id = context.Request.Form["id"];
        var ten_collection = context.Request.Form["ten_collection"];

        var lst = (from o in db.md_collections
                   where o.ten_collection.Equals(ten_collection) && !o.md_collection_id.Equals(id)
                   select new { o.md_collection_id });

        if (lst.Count() != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Đã có collection này!");
        }
        else
        {
            var m = db.md_collections.Where(p => p.md_collection_id.Equals(id)).FirstOrDefault();
            m.ten_collection = ten_collection;
            m.chungloai = context.Request.Form["chungloai"];
            m.kieudang = context.Request.Form["kieudang"];
            m.detai = context.Request.Form["detai"];
            m.bocai = context.Request.Form["bocai"];
            m.mausac = context.Request.Form["mausac"];
            db.SubmitChanges();
        }
    }

    public void add(HttpContext context)
    {
        var ten_collection = context.Request.Form["ten_collection"];
        var lst = from o in db.md_collections where o.ten_collection.Equals(ten_collection) select o;
        if (lst.Count() != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Đã có collection này!");
        }
        else
        {
            var m = new md_collection();
            m.md_collection_id = Helper.getNewId();
            m.ten_collection = ten_collection;
            m.chungloai = context.Request.Form["chungloai"];
            m.kieudang = context.Request.Form["kieudang"];
            m.detai = context.Request.Form["detai"];
            m.bocai = context.Request.Form["bocai"];
            m.mausac = context.Request.Form["mausac"];
            db.md_collections.InsertOnSubmit(m);
            db.SubmitChanges();
        }
    }

    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"];
        var m = db.md_collections.Where(p => p.md_collection_id.Equals(id)).FirstOrDefault();
        if(m == null)
        {
            jqGridHelper.Utils.writeResult(0, "Không tồn tại collection đã chọn!");
        }
        else
        {
            db.md_collections.DeleteOnSubmit(m);
            db.SubmitChanges();
        }
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = "SELECT COUNT(1) AS count FROM md_collection clt where 1=1 {0} ";
        sqlCount = string.Format(sqlCount, filter);

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
            sidx = "clt.md_collection_id";
        }

        string strsql = string.Format(@"
            select * from (
                SELECT clt.md_collection_id, clt.ten_collection, clt.chungloai, clt.kieudang, clt.detai, clt.bocai, clt.mausac,
                ROW_NUMBER() OVER (ORDER BY {1} {2}) as RowNum
                FROM md_collection clt 
                Where 1=1 {0}
            )P 
            where RowNum > @start AND RowNum < @end",
            filter,
            sidx,
            sord
        );
        strsql = string.Format(strsql, filter);

        DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row[0] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[1] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[2] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[3] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[4] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[5] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[6] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[7] + "]]></cell>";
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
