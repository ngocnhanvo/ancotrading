<%@ WebHandler Language="C#" Class="Md_boController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;

public class Md_boController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
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
        String sql = "select md_bocai_id, code_bc from md_bocai where hoatdong = 1 order by code_bc desc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }

    public void getSearchOption(HttpContext context)
    {
        String sql = "select code_bc as id, code_bc from md_bocai where hoatdong = 1  order by code_bc asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToOptionSearch());
    }
    
    public void edit(HttpContext context)
    {
        String id = context.Request.Form["id"];
        md_bo mnu = db.md_bos.FirstOrDefault(s=>s.md_bo_id == id);
        mnu.ma_bo = context.Request.Form["ma_bo"];
        mnu.ma_bo_cha = context.Request.Form["ma_bo_cha"];
        mnu.ten_bo = context.Request.Form["ten_bo"];
		mnu.mota = context.Request.Form["mota"];
		//mnu.hoatdong = true;
		//mnu.ngaytao = DateTime.Now;
		mnu.ngaycapnhat = DateTime.Now;
		//mnu.nguoitao = UserUtils.getUser(context);
		mnu.nguoicapnhat = UserUtils.getUser(context);
        
        db.SubmitChanges();
    }

    public void add(HttpContext context)
    {
        md_bo mnu = new md_bo();
        mnu.md_bo_id = Security.EncodeMd5Hash(DateTime.Now.ToString("yyyyMMddddhhmmss"));
        mnu.ma_bo = context.Request.Form["ma_bo"];
        mnu.ma_bo_cha = context.Request.Form["ma_bo_cha"];
        mnu.ten_bo = context.Request.Form["ten_bo"];
		mnu.mota = context.Request.Form["mota"];
		mnu.hoatdong = true;
		mnu.ngaytao = DateTime.Now;
		mnu.ngaycapnhat = DateTime.Now;
		mnu.nguoitao = UserUtils.getUser(context);
		mnu.nguoicapnhat = UserUtils.getUser(context);

        db.md_bos.InsertOnSubmit(mnu);
        db.SubmitChanges();
    }

    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"];
        md_bo mnu = db.md_bos.FirstOrDefault(s=>s.md_bo_id == id);
		if(mnu != null) {
			db.md_bos.DeleteOnSubmit(mnu);
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

        String sqlCount = "SELECT COUNT(*) AS count FROM md_bo WHERE 1=1 {0}";
        sqlCount = String.Format(sqlCount, filter);
        
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
		string orderby = "ORDER BY bc.ma_bo asc, bc.ma_bo_cha desc ";
        if (!sidx.Equals("") || sidx != null)
        {
            sidx = "bc.md_bo_id";
        }

        string strsql = @"
            select * 
            from (
                select 
                    bc.md_bo_id, 
                    bc.ma_bo,
                    bc.ma_bo_cha,
                    bc.ten_bo,
                    bc.ngaytao,
                    bc.nguoitao,
                    bc.ngaycapnhat,
                    bc.nguoicapnhat,
                    bc.mota,
                    bc.hoatdong,
                    ROW_NUMBER() OVER ({0}) as RowNum
                FROM md_bo bc WHERE 1=1 {1}
            ) P 
            where RowNum > @start AND RowNum < @end";
        strsql = string.Format(strsql, orderby, filter);

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
            }
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
