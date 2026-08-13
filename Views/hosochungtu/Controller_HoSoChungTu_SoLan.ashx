<%@ WebHandler Language="C#" Class="Controller_HoSoChungTu_SoLan" %>

using System;
using System.Web;
using System.Data;

//public class Controller_HoSoChungTu_SoLan : IHttpHandler, IDisposable
public class Controller_HoSoChungTu_SoLan : IHttpHandler,IDisposable  {

    //public void ProcessRequest (HttpContext context) {
    //    context.Response.ContentType = "text/plain";
    //    context.Response.Write("Hello World");
    //}

    //public bool IsReusable {
    //    get {
    //        return false;
    //    }
    //}
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
        this.load(context);
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        string poId = context.Request.QueryString["poId"];

        string filter = "";
        bool _search = false;
        bool.TryParse(context.Request.QueryString["_search"], out _search);

        if (_search)
        {
            string _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        string sqlCount = $@"
            SELECT COUNT(1) AS count
            FROM c_donhangchungtu_bosung_log log
            WHERE 1=1 {filter}
            AND log.c_donhangchungtu_id = '{poId}'
        ";

        int page = int.Parse(context.Request.QueryString["page"]);
        int limit = int.Parse(context.Request.QueryString["rows"]);
        string sidx = context.Request.QueryString["sidx"];
        string sord = context.Request.QueryString["sord"];

        if (string.IsNullOrWhiteSpace(sidx))
            sidx = "log.sothutu";

        int count = (int)mdbc.ExecuteScalar(sqlCount);
        int total_page = count > 0 ? (int)Math.Ceiling(1.0 * count / limit) : 0;

        if (page > total_page) page = total_page;

        int start = limit * page - limit;
        int end = (page * limit) + 1;

        string strsql = $@"
            SELECT * FROM
            (
                SELECT
                    log.id,
                    log.sothutu,
                    log.sochungtu,
                    log.ngaydieuchinh,
                    log.cont20,
                    log.cont40,
                    log.cont40hc,
                    log.cont45,
                    log.contLCL,
                    log.mota,
                    log.ngaygui,
                    log.nguoigui,
                    ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) AS RowNum
                FROM c_donhangchungtu_bosung_log log
                WHERE 1=1 {filter}
                AND log.c_donhangchungtu_id = '{poId}'
            ) P
            WHERE RowNum > @start AND RowNum < @end
        ";

        DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);

        string xml = @"<?xml version=""1.0"" encoding=""UTF-8"" ?>";
        xml += "<rows>";
        xml += $"<page>{page}</page>";
        xml += $"<total>{total_page}</total>";
        xml += $"<records>{count}</records>";

        foreach (DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (DataColumn column in dt.Columns)
            {
                if (column.DataType == typeof(DateTime))
                {
                    try
                    {
                        xml += $"<cell><![CDATA[{((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy HH:mm")}]]></cell>";
                    }
                    catch
                    {
                        xml += "<cell><![CDATA[]]></cell>";
                    }
                }
                else
                {
                    xml += $"<cell><![CDATA[{row[column.ColumnName]}]]></cell>";
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



