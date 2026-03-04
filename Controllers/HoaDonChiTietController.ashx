<%@ WebHandler Language="C#" Class="HoaDonChiTietController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data.SqlClient;
using System.Data;
using System.Collections.Generic;

public class HoaDonChiTietController : IHttpHandler, IDisposable
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
        String whId = context.Request.QueryString["whId"];
        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = string.Format(@"
            SELECT COUNT(1) AS count
			FROM c_hoadon_ct hd
            WHERE 1 = 1 and hd.c_hoadon_id = N'{0}' {1}
            ", whId, filter);

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
            sidx = "hd.c_hoadon_ct_id";
        }

        string strsql = string.Format(@"
            select 
                P.* 
            from (
                select 
                    hd.c_hoadon_ct_id,
                    hd.c_hoadon_id,
                    hd.ma_sanpham,
                    hd.ten_sanpham,
                    hd.ten_dvt,
                    hd.soluong,
                    hd.dongia,
                    hd.thanhtien,
                    hd.ngaytao,
                    hd.nguoitao,
                    hd.ngaycapnhat,
                    hd.nguoicapnhat,
                    hd.mota,
                    hd.hoatdong,
                    ROW_NUMBER() OVER (ORDER BY {0} {1}) as RowNum
                FROM 
                    c_hoadon_ct hd
                WHERE 
                    1=1
                    and hd.c_hoadon_id = N'{2}'
                    {3}
            )P 
            where RowNum > @start AND RowNum < @end",
            sidx,
            sord,
            whId,
            filter
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