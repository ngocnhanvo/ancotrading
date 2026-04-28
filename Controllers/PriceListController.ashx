<%@ WebHandler Language="C#" Class="PriceListController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;

public class PriceListController : IHttpHandler
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
            case "getoptionpricesale":
                this.getSelectOptionPriceSale(context);
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
        String sql = "select md_banggia_id, ten_banggia from md_banggia where hoatdong = 1 order by ten_banggia asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }

    public void getSelectOptionPriceSale(HttpContext context)
    {
        String sql = "select md_banggia_id, ten_banggia from md_banggia where hoatdong = 1  order by ten_banggia asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToOptionNullFirst());
    }


    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        String b = context.Request.Form["banggiaban"].ToLower();
        String isstandar = context.Request.Form["isstandar"].ToLower();
        bool hd, bgb;
        hd = bgb = false;

        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        if (b.Equals("on") || b.Equals("true"))
        { bgb = true; }

        if (isstandar.Equals("on") || isstandar.Equals("true"))
        { isstandar = "true"; }
        else { isstandar = "false"; }

        md_banggia m = db.md_banggias.Single(p => p.md_banggia_id == context.Request.Form["id"]);
        var mnu = new md_banggia();
        m.CopyPropertiesTo(mnu);
        m.ten_banggia = context.Request.Form["ten_banggia"];
        m.md_dongtien_id = context.Request.Form["tendt"];
        m.banggiaban = bgb;
        m.mota = context.Request.Form["mota"];
        m.hoatdong = hd;
        m.isstandar = bool.Parse(isstandar);
        m.nguoicapnhat = UserUtils.getUser(context);
        m.ngaycapnhat = DateTime.Now;
        var diffs = VoNgocNhan.API_Data.GetDifferences(m, mnu);
        if (diffs.Count > 0)
        {
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                HttpContext.Current,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.edit,
                    table = m.GetType().Name,
                    id_lienket = m.md_banggia_id,
                    ma_lienket = m.ten_banggia
                }
            );
        }
        db.SubmitChanges();
    }

    public void add(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        String b = context.Request.Form["banggiaban"].ToLower();
        String isstandar = context.Request.Form["isstandar"].ToLower();

        bool hd, bgb;
        hd = bgb = false;

        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        if (b.Equals("on") || b.Equals("true"))
        { bgb = true; }

        if (isstandar.Equals("on") || isstandar.Equals("true"))
        { isstandar = "true"; }
        else { isstandar = "false"; }

        md_banggia mnu = new md_banggia
        {
            md_banggia_id = Helper.getNewId(),
            ten_banggia = context.Request.Form["ten_banggia"],
            md_dongtien_id = context.Request.Form["tendt"],
            banggiaban = bgb,
            mota = context.Request.Form["mota"],
            hoatdong = hd,
            isstandar = bool.Parse(isstandar),
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.md_banggias.InsertOnSubmit(mnu);
        VoNgocNhan.API_Data.themLichSuHoatDong(
            db,
            context,
            new ad_log
            {
                nexxdecor_check = false,
                hanhdong = VoNgocNhan.API_Data.add,
                table = mnu.GetType().Name,
                id_lienket = mnu.md_banggia_id,
                ma_lienket = mnu.ten_banggia
            }
        );
        db.SubmitChanges();
    }


    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"], msg = "";
        try
        {
            var bg = db.md_banggias.Where(s => s.md_banggia_id == id).FirstOrDefault();
            if (bg == null)
            {
                msg = "Không tìm thấy bảng giá đã chọn";
                goto EndEventHandler;
            }

            var pbgs = db.md_phienbangias.Where(s => s.md_banggia_id == id).ToList();
            if (pbgs.Count > 0)
            {
                msg = "Bảng giá có chứa phiên bản giá!";
                goto EndEventHandler;
            }

            db.md_banggias.DeleteOnSubmit(bg);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.del,
                    table = bg.GetType().Name,
                    id_lienket = bg.md_banggia_id,
                    ma_lienket = bg.ten_banggia
                }
            );
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Xóa bảng giá thành công");
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = "SELECT COUNT(*) AS count FROM md_banggia bg JOIN md_dongtien dt ON bg.md_dongtien_id = dt.md_dongtien_id where 1=1 " + filter;
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
            sidx = "bg.ten_banggia";
        }

        string strsql = "select * from( " +
            " select bg.*, dt.ma_iso as tendt, " +
            "  ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum " +
            " from md_banggia bg JOIN md_dongtien dt ON bg.md_dongtien_id = dt.md_dongtien_id where 1=1 " +
            filter +
            ")P where RowNum > @start AND RowNum < @end";

        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["md_banggia_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_banggia"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["tendt"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["banggiaban"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["isstandar"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaytao"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaycapnhat"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoicapnhat"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["mota"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hoatdong"] + "]]></cell>";
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
