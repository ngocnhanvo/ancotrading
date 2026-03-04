<%@ WebHandler Language="C#" Class="Controller_HoSoChungTu_Taptin" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_HoSoChungTu_Taptin : IHttpHandler, IDisposable
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
            case "ketthuc":
                this.ketthuc(context);
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

    public void ketthuc(HttpContext context)
    {

    }

    public void edit(HttpContext context)
    {
        
    }

    public void add(HttpContext context)
    {

    }


    public void del(HttpContext context)
    {
        
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

        var sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM md_taptin tt WHERE 1=1 {filter} 
            and tt.lienket ='{poId}'
        ";

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
            sidx = "tt.ngaytao";
        }

        string strsql = $@"
            select * from(
                select 
                    tt.md_taptin_id 
                    , tt.tentaptin
                    , tt.mota
                    , tt.mimetype
                    , tt.size
                    , tt.md_taptin_id as path
                    , tt.ngaytao
                    , tt.nguoitao
                    , tt.ngaycapnhat
                    , tt.nguoicapnhat
                    , tt.ngayxacnhan
                    , tt.nguoixacnhan
                    , tt.lydotuchoi
                    , tt.trangthai
                    , ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
                FROM 
                    md_taptin tt 
                WHERE 
                    1=1 {filter} 
                    and tt.lienket = '{poId}'
                )P 
            where RowNum > @start AND RowNum < @end
        ";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = $@"<?xml version=""1.0"" encoding=""UTF-8"" ?>";
        xml += $@"<rows>";
        xml += $@"<page>{page}</page>";
        xml += $@"<total>{total_page}</total>";
        xml += $@"<records>{count}</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy HH:mm"));
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
