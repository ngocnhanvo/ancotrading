<%@ WebHandler Language="C#" Class="DongDSDHTaoPhieuXuatController" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

public class DongDSDHTaoPhieuXuatController : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Params["oper"];
        switch (action)
        {
            default:
                switch (oper)
                {
                    case "loadPXK":
                        this.loadPXK(context);
                        break;
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public void loadPXK(HttpContext context)
    {
        string msg = "";
        string poId = context.Request.QueryString["poId"];
        var item = new Dictionary<string, object>();
        string madtkd = "ANCO1";
        try
        {
            if (string.IsNullOrWhiteSpace(poId))
                msg = "[]";
            else
            {
                item["md_xuatban_id"] = poId;

                msg = Extension.GetModule(
                    Extension.API_ALL(madtkd) + "?oper=getPhieuXKsCDH",
                                    item
                                );
            }

            var datas = JsonConvert.DeserializeObject<List<DataAcess.md_xuatban_cdh>>(msg);
            var dsdhId = datas.Select(s => s.c_danhsachdathang_id).FirstOrDefault();
            var xbId = datas.Select(s => s.md_xuatban_id).FirstOrDefault();
            var dhId = db.c_danhsachdathangs.Where(s => s.c_danhsachdathang_id == dsdhId).Select(s=>s.c_donhang_id).FirstOrDefault();
            string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
            xml += "<rows>";
            xml += "<page>" + 1 + "</page>";
            xml += "<total>" + 1 + "</total>";
            xml += "<records>" + datas.Count + "</records>";
            foreach (var row in datas)
            {
                var spid = db.md_sanphams.Where(s => s.ma_sanpham == row.md_sanpham_id).Select(s => s.md_sanpham_id).FirstOrDefault();
                var ddh = db.c_dongdonhangs.Where(s => s.c_donhang_id == dhId & s.md_sanpham_id == spid).FirstOrDefault();
                var ddsdh = db.c_dongdsdhs.Where(s => s.c_danhsachdathang_id == dsdhId & s.md_sanpham_id == spid).FirstOrDefault();
                string c_dongdonhang_id = "", ma_sanpham_khach = "", ddsdhId = "";
                decimal? soluong = null, soluong_dathang = null, soluong_conlai = null;
                if(ddh != null)
                {
                    c_dongdonhang_id = ddh.c_dongdonhang_id;
                    ma_sanpham_khach = ddh.ma_sanpham_khach;
                }

                if (ddsdh != null)
                {
                    ddsdhId = ddsdh.c_dongdsdh_id;
                    soluong = ddsdh.sl_dathang;
                    soluong_dathang = ddsdh.sl_dathang;
                    soluong_conlai = ddsdh.sl_conlai;
                }

                xml += "<row>";
                xml += "<cell><![CDATA[" + xbId + "]]></cell>";
                xml += "<cell><![CDATA[" + dhId + "]]></cell>";
                xml += "<cell><![CDATA[" + dsdhId + "]]></cell>";
                xml += "<cell><![CDATA[" + c_dongdonhang_id + "]]></cell>";
                xml += "<cell><![CDATA[" + ddsdhId + "]]></cell>";
                xml += "<cell><![CDATA[" + spid + "]]></cell>";
                xml += "<cell><![CDATA[" + row.md_sanpham_id + "]]></cell>";
                xml += "<cell><![CDATA[" + ma_sanpham_khach + "]]></cell>";
                xml += "<cell><![CDATA[" + soluong + "]]></cell>";
                xml += "<cell><![CDATA[" + row.sl_nhapthucte.DropTrailingZeros() + "]]></cell>";
                xml += "<cell><![CDATA[" + soluong_dathang + "]]></cell>";
                xml += "<cell><![CDATA[" + soluong_conlai + "]]></cell>";
                xml += "<cell><![CDATA[" + row.sl_inner + "]]></cell>";
                xml += "<cell><![CDATA[" + row.dvt_inner + "]]></cell>";
                xml += "<cell><![CDATA[" + row.sl_outer + "]]></cell>";
                xml += "<cell><![CDATA[" + row.dvt_outer + "]]></cell>";
                xml += "<cell><![CDATA[" + row.tenkien + "]]></cell>";
                xml += "<cell><![CDATA[" + row.sokien + "]]></cell>";
                xml += "</row>";
            }
            xml += "</rows>";
            msg = xml;
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

        context.Response.Write(msg);
    }

    public void load(HttpContext context)
    {

        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        String poId = context.Request.QueryString["poId"];

        String sqlCount = "SELECT COUNT(*) AS count " +
            " FROM c_dongdsdh ddsdh, c_danhsachdathang dsdh, c_dongdonhang ddh, " +
            " md_sanpham sp, md_doitackinhdoanh dtkd " +
            " WHERE ddsdh.c_danhsachdathang_id = dsdh.c_danhsachdathang_id " +
            " AND ddsdh.c_dongdonhang_id = ddh.c_dongdonhang_id " +
            " AND ddsdh.md_sanpham_id = sp.md_sanpham_id " +
            " AND ddsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id " +
            " AND ddsdh.c_danhsachdathang_id = N'{0}'";

        if (poId != null)
        {
            sqlCount = string.Format(sqlCount, poId);
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
            sidx = "c_dongdsdh_id";
        }

        string strsql = "select * from( " +
               " select " +
               " dsdh.c_donhang_id, dsdh.c_danhsachdathang_id, ddsdh.c_dongdonhang_id, ddsdh.c_dongdsdh_id, ddsdh.md_sanpham_id, sp.ma_sanpham " +
               " , ddsdh.ma_sanpham_khach, ddsdh.sl_dathang as sl_po, ddsdh.sl_dathang, ddsdh.sl_conlai " + // chu y: chua co cot so luong po
               "     , ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum " +
               " FROM " +
               "     c_dongdsdh ddsdh, c_danhsachdathang dsdh " +
               "     , c_dongdonhang ddh, md_sanpham sp " +
               "     , md_doitackinhdoanh dtkd " +
               " WHERE " +
               "     ddsdh.c_danhsachdathang_id = dsdh.c_danhsachdathang_id " +
               "     AND ddsdh.c_dongdonhang_id = ddh.c_dongdonhang_id " +
               "     AND ddsdh.md_sanpham_id = sp.md_sanpham_id " +
               "     AND ddsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id " +
               "     AND ddsdh.c_danhsachdathang_id = N'{0}'" +
               " )P  WHERE RowNum > @start AND RowNum < @end";

        if (poId != null)
        {
            strsql = string.Format(strsql, poId);
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