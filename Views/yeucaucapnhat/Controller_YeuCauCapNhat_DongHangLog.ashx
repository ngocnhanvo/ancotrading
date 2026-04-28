<%@ WebHandler Language="C#" Class="Controller_YeuCauCapNhat_DongHangLog" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_YeuCauCapNhat_DongHangLog : IHttpHandler, IDisposable
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
        String id = context.Request.QueryString["id"];
        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM md_phieuthongtinsanpham_log lg
            WHERE lg.md_phieuthongtinsanpham_id = '{id}' {filter}
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
            sidx = "lg.[table]";
            sord = "asc";
        }

        string strsql = $@"
        select * from (
            select 
                min(lg.md_phieuthongtinsanpham_log_id) as md_phieuthongtinsanpham_log_id,
                case
                    when lg.[table] = 'md_chungloai' then N'Chủng loại'
                    when lg.[table] = 'md_kieudang' then N'Kiểu dáng'
                    when lg.[table] = 'md_chucnang' then N'Chức năng'
                    when lg.[table] = 'md_nhomnangluc' then N'Nhóm năng lực'
                    when lg.[table] = 'md_hscode' then N'HSCode'
                    when lg.[table] = 'md_detai' then N'Đề tài'
                    when lg.[table] = 'md_mausac' then N'Màu sắc'
                    when lg.[table] = 'md_banggia' then N'Bảng giá'
                    when lg.[table] = 'md_phienbangia' then N'Phiên bản giá'
                    when lg.[table] = 'md_giasanpham' then N'Giá sản phẩm'
                    when lg.[table] = 'md_sanpham' then N'Sản phẩm'
                    when lg.[table] = 'md_donggoi' then N'Đóng gói'
                    when lg.[table] = 'md_donggoisanpham' then N'Đóng gói SP'
                    else lg.[table]
                end ten,
                lg.ma_lienket as ma, 
                lg.hanhdong,
                max(lg.ngaytao) as ngaytao, 
                null as nguoitao, 
                null as ngaycapnhat, 
                null as nguoicapnhat, 
                null as mota,
                1 as hoatdong,
                ROW_NUMBER() OVER (ORDER BY lg.[table] asc, max(lg.ngaytao) desc) as RowNum
            FROM md_phieuthongtinsanpham_log lg
            WHERE lg.md_phieuthongtinsanpham_id = '{id}' {filter}
            group by lg.[table], lg.ma_lienket, lg.hanhdong
        )P WHERE RowNum > @start AND RowNum < @end";

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
                else if (column.DataType == Type.GetType("System.Decimal"))
                {
                    if (row[column.ColumnName] != null)
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
                    else
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                }
                else
                {
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
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
