<%@ WebHandler Language="C#" Class="QuyCachDongGoiController" %>

using System;
using System.Web;
using System.Linq;

public class QuyCachDongGoiController : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        this.load(context);
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        String productId = context.Request.QueryString["productId"];
        
        String sqlCount = "SELECT COUNT(*) AS count " +
            " FROM md_sanpham sp, md_donggoisanpham dgsp, md_donggoi dg " +
            " WHERE sp.md_sanpham_id = dgsp.md_sanpham_id " +
            " AND dgsp.md_donggoi_id = dg.md_donggoi_id" +
            " AND dgsp.md_sanpham_id = N'{0}'";

        if (productId != null)
        {
            sqlCount = string.Format(sqlCount, productId);
        }
        else
        {
            sqlCount = string.Format(sqlCount, 0);
        }
        
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
            sidx = "dgsp.md_donggoisanpham_id";
        }
        
        string strsql = "select * from( " +
            " select dgsp.md_donggoisanpham_id, dg.ten_donggoi, sp.ma_sanpham" +
            " , dg.sl_inner, (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_inner) as dvtinner" +
            " , dg.l1, dg.w1, dg.h1 " +
            " , dg.sl_outer, (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_outer) as dvtouter " +
            " , dg.l2_mix, dg.w2_mix, dg.h2_mix, dg.v2 " +
            " , dg.soluonggoi_ctn, dg.vd, dg.vn, dg.vl, dg.ghichu_vachngan  " +
            " , dgsp.soluong, dgsp.macdinh " +
            " , dgsp.ngaytao, dgsp.nguoitao, dgsp.ngaycapnhat, dgsp.nguoicapnhat, dgsp.mota, dgsp.hoatdong ," +
            " ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum " +
            " FROM md_sanpham sp, md_donggoisanpham dgsp, md_donggoi dg " +
            " WHERE sp.md_sanpham_id = dgsp.md_sanpham_id " +
            " AND dgsp.md_donggoi_id = dg.md_donggoi_id " +
            " AND dgsp.md_sanpham_id = N'{0}' " +
            " )P where RowNum > @start AND RowNum < @end";

        if (productId != null)
        {
            strsql = string.Format(strsql, productId);
        }
        else
        {
            strsql = string.Format(strsql, 0);
        }
        
        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
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
            xml += "<cell><![CDATA[" + row[4] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[5] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[6] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[7] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[8] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[9] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[10] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[11] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[12] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[13] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[14] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[15] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[16] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[17] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[18] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[19] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[20] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[21].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[22] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[23].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[24] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[25] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[26] + "]]></cell>";
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
