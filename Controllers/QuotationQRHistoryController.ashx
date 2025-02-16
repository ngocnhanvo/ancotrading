<%@ WebHandler Language="C#" Class="QuotationQRHistoryController" %>

using System;
using System.Web;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Data;
using Newtonsoft.Json;

public class QuotationQRHistoryController : IHttpHandler
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
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        string quotationId = context.Request.QueryString["quotationId"];
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

        string sqlCount = $@"
            SELECT COUNT(1) AS count
            FROM c_baogiaqr_lichsu
            WHERE 1=1 and c_baogiaqr_id = '{quotationId}' {filter}";

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
            sidx = "ls.ngaytao";
            sord = "desc";
        }


        string strsql = $@"select * from ( 
            select 
                ls.c_baogiaqr_lichsu_id, 
                ls.c_baogiaqr_id,
                ls.[from],
                ls.[to],
                ls.cc,
                ls.bcc,
                ls.title,
                ls.body,
                ls.ngaytao,
                ls.nguoitao,
                ls.ngaycapnhat,
                ls.nguoicapnhat,
                ls.mota,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum 
            FROM 
                c_baogiaqr_lichsu ls 
            WHERE 1=1 and ls.c_baogiaqr_id = '{quotationId}'
            {filter}
        )P 
        where RowNum > @start AND RowNum < @end
        order by P.RowNum
        ";

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
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy (HH:mm)"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else
                {
                    string body = row[column.ColumnName].ToString();
                    if (column.ColumnName == nameof(body))
                        body = Security.DecodeHTML(body);
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", body);
                }
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
