<%@ WebHandler Language="C#" Class="PhienBanGiaCu" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Data.SqlClient;
using System.Web.Security;
using System.Data;


public class PhienBanGiaCu : IHttpHandler
{

    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.QueryString["action"];
        switch (oper)
        {
            case "PhienBanGiaCu":
                this.load(context);
                break;
            case "PhienBanGiaDB":
                this.PhienBanGiaDB(context);
                break;
        }
    }

    public void PhienBanGiaDB(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        string madtkd = context.Request.Params["madtkd"];
        if (string.IsNullOrWhiteSpace(madtkd))
            madtkd = "Not404";
        string ngaytg = context.Request.Params["ngaytg"];
        if (string.IsNullOrWhiteSpace(ngaytg))
            ngaytg = "01/01/1990";
        else
            ngaytg = context.Request.Params["ngaytg"];
          
        //// filter
        String filter = "";

        string fromSQL = $@"
            from md_phienbangia pbg
	        left join md_banggia bg on bg.md_banggia_id = pbg.md_banggia_id
	        where 
                bg.ten_banggia like N'%{madtkd}-FOB%'
                and bg.banggiaban = 1
	            and pbg.ngay_hieuluc <= convert(datetime, '{ngaytg}', 103)
	            and pbg.md_trangthai_id = 'HIEULUC'
                {filter}
        ";

        String sqlCount = $"SELECT COUNT(1) AS count {fromSQL}";
        int page = 1;
        int limit = 500;
        String sidx = "";
        String sord = "";
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
            sidx = "ngay_hieuluc";
        }

        if (sord.Equals("") || sord == null)
        {
            sord = "desc";
        }

        string strsql = $@"
        select P.* from (
            select 
                pbg.md_phienbangia_id, 
                pbg.md_trangthai_id, 
                pbg.ten_phienbangia, 
                bg.md_banggia_id, 
                pbg.ngay_hieuluc,
                pbg.ngaytao, 
                pbg.nguoitao, 
                pbg.ngaycapnhat, 
                pbg.nguoicapnhat, 
                pbg.mota, 
                pbg.hoatdong, 
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            {fromSQL}
        )P 
        where RowNum > @start AND RowNum < @end";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row[0] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[1] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[2] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[3] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[4].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[5].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[6] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[7].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[8] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[9] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[10] + "]]></cell>";
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }

    public void load(HttpContext context)
    {
        string select = @"<select>{0}</select>";
        string option = "<option value={0}>{1}</option>";
        string option_ = "";
        option_ += string.Format(option, "", "");
        foreach(md_phienbangia pbg in db.md_phienbangias.Where(s=>s.hoatdong == true).OrderBy(s=>s.ten_phienbangia)) {
            option_ += string.Format(option, pbg.md_phienbangia_id, pbg.ten_phienbangia);
        }

        select = string.Format(select, option_);
        context.Response.Write(select);
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
