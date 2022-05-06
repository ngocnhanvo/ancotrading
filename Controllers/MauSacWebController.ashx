<%@ WebHandler Language="C#" Class="MauSacWebController" %>

using System;
using System.Web;
using System.Collections.Generic;
using jqGridHelper;
using System.Data;

public class MauSacWebController : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (oper)
        {
            case "edit":
                this.edit(context);
                break;
            default:
                this.load(context);
                break;
        }
    }

    public void edit(HttpContext context)
    {

    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        string md_sanpham_id = context.Request.QueryString["productId"];

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            Filter f = Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }


        String sqlCount = string.Format(@"
            SELECT COUNT(1) AS count 
            FROM 
	            md_sanpham msw
            WHERE 
	            1=1
                AND msw.md_sanpham_id != '{0}'
                AND substring(msw.ma_sanpham, 0, 12) = (select substring(sp2.ma_sanpham, 0, 12) from md_sanpham sp2 where sp2.md_sanpham_id = N'{0}')
                AND msw.hoatdong = 1
                AND msw.trangthai in ('DHD')
                {1}
            "
            , md_sanpham_id
            , filter
        );

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
            sidx = "msw.ma_sanpham";
        }

        string strsql = string.Format(@"
            select * from( 
                SELECT
	                msw.md_sanpham_id
                    , msw.ma_sanpham
                    , msw.hoatdongWeb
	                , ROW_NUMBER() OVER (ORDER BY {0} {1} ) as RowNum 
                FROM 
	                md_sanpham msw           
                WHERE 
	                1=1
                    AND msw.md_sanpham_id != '{2}'
                    AND substring(msw.ma_sanpham, 0, 12) = (select substring(sp2.ma_sanpham, 0, 12) from md_sanpham sp2 where sp2.md_sanpham_id = N'{2}')
                    AND msw.hoatdong = 1
                    AND msw.trangthai in ('DHD')
                    {3}
            )P WHERE RowNum > @start AND RowNum < @end"
            , sidx
            , sord
            , md_sanpham_id
            , filter
        );

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["md_sanpham_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_sanpham"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hoatdongWeb"] + "]]></cell>";
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}