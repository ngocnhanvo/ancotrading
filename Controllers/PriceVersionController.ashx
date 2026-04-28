<%@ WebHandler Language="C#" Class="PriceVersionController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;

public class PriceVersionController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "getPriceList":
                this.getPriceList(context);
                break;
            case "getoption":
                this.getSelectOption(context);
                break;
            case "copy":
                this.copyPriceListVersion(context);
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

    public void getPriceList(HttpContext context)
    {
        String id = context.Request.QueryString["filter"];
        String sql = "select md_phienbangia_id, ten_phienbangia from md_phienbangia where hoatdong = 1 AND md_phienbangia_id != @md_phienbangia_id";
        System.Data.SqlClient.SqlDataReader rd = mdbc.ExecuteReader(sql, "@md_phienbangia_id", id);
        String wr = "";
        if (rd.HasRows)
        {
            while (rd.Read())
            {
                wr += String.Format("<option value=\"{0}\">{1}</option>", rd[0], rd[1]);
            }
        }
        rd.Close();
        context.Response.Write(wr);
    }

    public void copyPriceListVersion(HttpContext context)
    {
        try
        {
            string p_id = context.Request.Form["price_version"].ToString();
            string id = context.Request.Form["id"].ToString();
            mdbc.ExcuteNonProcedure("copyPhienBanGia", "@phienban_cp", p_id, "@phienban", id);
            context.Response.Write("Copy phiên bản giá thành công!");
        }
        catch (Exception ex)
        {
            context.Response.Write(ex.Message);
        }
    }

    public void getSelectOption(HttpContext context)
    {
        String sql = "select md_phienbangia_id, ten_phienbangia from md_phienbangia where hoatdong = 1";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }


    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();

        string ten_phienbangia = context.Request.Form["ten_phienbangia"];
        string md_banggia_id = context.Request.Form["md_banggia_id"];
        string ngay_hieuluc = context.Request.Form["ngay_hieuluc"];

        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        md_phienbangia m = db.md_phienbangias.FirstOrDefault(p => p.md_phienbangia_id == context.Request.Form["id"]);
        var mnu = new md_phienbangia();
        m.CopyPropertiesTo(mnu);
        if (m.md_trangthai_id.Equals(Helper.HIEULUC))
        {
            m.hoatdong = hd;
        }
        else if (m.md_trangthai_id.Equals(Helper.SOANTHAO))
        {
            m.ten_phienbangia = ten_phienbangia;
            m.md_banggia_id = md_banggia_id;
            m.ngay_hieuluc = DateTime.ParseExact(ngay_hieuluc, "dd/MM/yyyy", null);
            m.mota = context.Request.Form["mota"];

            m.hoatdong = hd;
            m.ngaycapnhat = DateTime.Now;
            m.nguoicapnhat = UserUtils.getUser(context);
        }

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
                    id_lienket = m.md_phienbangia_id,
                    ma_lienket = m.ten_phienbangia
                }
            );
        }
        db.SubmitChanges();
    }

    public void add(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        md_phienbangia mnu = new md_phienbangia
        {
            md_phienbangia_id = Helper.getNewId(),
            ten_phienbangia = context.Request.Form["ten_phienbangia"],
            md_banggia_id = context.Request.Form["md_banggia_id"],
            ngay_hieuluc = DateTime.ParseExact(context.Request.Form["ngay_hieuluc"], "dd/MM/yyyy", null),
            md_trangthai_id = Helper.SOANTHAO,
            mota = context.Request.Form["mota"],
            hoatdong = hd,
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.md_phienbangias.InsertOnSubmit(mnu);
        VoNgocNhan.API_Data.themLichSuHoatDong(
            db,
            HttpContext.Current,
            new ad_log
            {
                nexxdecor_check = false,
                hanhdong = VoNgocNhan.API_Data.add,
                table = mnu.GetType().Name,
                id_lienket = mnu.md_phienbangia_id,
                ma_lienket = mnu.ten_phienbangia
            }
        );
        db.SubmitChanges();
    }


    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"], msg = "";
        try
        {
            md_phienbangia pbg = db.md_phienbangias.FirstOrDefault(p => p.md_phienbangia_id.Equals(id));
            if (pbg == null)
            {
                msg = "Không tìm thấy phiên bản giá đã chọn";
                goto EndEventHandler;
            }

            if (pbg.md_trangthai_id.Equals(Helper.HIEULUC))
            {
                msg = "Không thể xóa khi phiên bản giá đã hiệu lực";
                goto EndEventHandler;
            }

            var gias = db.md_giasanphams.Where(s => s.md_phienbangia_id == pbg.md_phienbangia_id).ToList();
            foreach (var gia in gias)
            {
                db.md_giasanphams.DeleteOnSubmit(gia);
            }

            db.md_phienbangias.DeleteOnSubmit(pbg);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                HttpContext.Current,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.del,
                    table = pbg.GetType().Name,
                    id_lienket = pbg.md_phienbangia_id,
                    ma_lienket = pbg.ten_phienbangia
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
            jqGridHelper.Utils.writeResult(1, "Xóa phiên bản giá thành công");
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


        String cateId = context.Request.QueryString["cateId"];
        String sqlCount = "SELECT COUNT(*) AS count FROM md_phienbangia pbg JOIN md_banggia bg ON pbg.md_banggia_id = bg.md_banggia_id WHERE pbg.md_banggia_id = N'{0}' " + filter;

        if (cateId != null)
        {
            sqlCount = string.Format(sqlCount, cateId);
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
            sidx = "ten_phienbangia";
        }

        string strsql = "select * from( " +
            " select pbg.md_phienbangia_id, pbg.md_trangthai_id, pbg.ten_phienbangia, bg.md_banggia_id, pbg.ngay_hieuluc, " +
            " pbg.ngaytao, pbg.nguoitao, pbg.ngaycapnhat, pbg.nguoicapnhat, pbg.mota, pbg.hoatdong " +
            " , ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum " +
            " FROM md_phienbangia pbg JOIN md_banggia bg ON pbg.md_banggia_id = bg.md_banggia_id " +
            " WHERE pbg.md_banggia_id = N'{0}' " + filter +
            " )P where RowNum > @start AND RowNum < @end";

        if (cateId != null)
        {
            strsql = string.Format(strsql, cateId);
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

    public bool IsReusable
    {
        get { return false; }
    }
}
