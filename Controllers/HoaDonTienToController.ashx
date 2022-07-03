<%@ WebHandler Language="C#" Class="HoaDonTienToController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data.SqlClient;
using System.Data;
using System.Collections.Generic;

public class HoaDonTienToController : IHttpHandler
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

    }


    public void edit(HttpContext context)
    {
        String id = context.Request.Form["id"];
        var mnu = db.c_hoadontientos.Where(s => s.c_hoadontiento_id == id).FirstOrDefault();
        mnu.tiento = context.Request.Form["tiento"];
        mnu.ten_tiento = context.Request.Form["ten_tiento"];
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
        var mnu = new c_hoadontiento();
        mnu.c_hoadontiento_id = Helper.getNewId();
        mnu.tiento = context.Request.Form["tiento"];
        mnu.ten_tiento = context.Request.Form["ten_tiento"];
        mnu.mota = context.Request.Form["mota"];
        mnu.hoatdong = true;
        mnu.ngaytao = DateTime.Now;
        mnu.ngaycapnhat = DateTime.Now;
        mnu.nguoitao = UserUtils.getUser(context);
        mnu.nguoicapnhat = UserUtils.getUser(context);

        db.c_hoadontientos.InsertOnSubmit(mnu);
        db.SubmitChanges();
    }


    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"];
        var mnu = db.c_hoadontientos.FirstOrDefault(s=>s.c_hoadontiento_id == id);
		if(mnu != null) {
			db.c_hoadontientos.DeleteOnSubmit(mnu);
			db.SubmitChanges();
		}
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        bool isadmin = db.nhanviens.FirstOrDefault(p => p.manv.Equals(UserUtils.getUser(context))).isadmin.Value;

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        // phân quyền theo nhóm
        String manv = UserUtils.getUser(context);
        String strAccount = "";
        System.Collections.Generic.List<String> lstAccount = LinqUtils.GetUserListInGroup(manv);
        foreach (String item in lstAccount)
        {
            strAccount += String.Format(", '{0}'", item);
        }
        strAccount = String.Format("'{0}'{1}", manv, strAccount);


        String sqlCount = string.Format(@"
            SELECT COUNT(1) AS count
			FROM c_hoadontiento hd
            WHERE 1 = 1 {0}
            ", filter);

        sqlCount = String.Format(sqlCount, isadmin == true ? "" : " AND nx.nguoitao IN(" + strAccount + ") ");

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
            sidx = "hd.tiento";
        }

        string strsql = string.Format(@"
            select 
                P.* 
            from (
                select 
                    hd.c_hoadontiento_id,
                    hd.tiento,
                    hd.ten_tiento,
                    hd.ngaytao,
                    hd.nguoitao,
                    hd.ngaycapnhat,
                    hd.nguoicapnhat,
                    hd.mota,
                    hd.hoatdong,
                    ROW_NUMBER() OVER (ORDER BY {0} {1}) as RowNum
                FROM 
                    c_hoadontiento hd
                WHERE 
                    1=1
                    {2}
            )P 
            where RowNum > @start AND RowNum < @end",
            sidx,
            sord,
            filter
        );

        strsql = String.Format(strsql, isadmin == true ? "" : "AND nx.nguoitao IN(" + strAccount + ") ");

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