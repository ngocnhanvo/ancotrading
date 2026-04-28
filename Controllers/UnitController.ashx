<%@ WebHandler Language="C#" Class="UnitController" %>

using System;
using System.Web;
using System.Linq;

public class UnitController : IHttpHandler
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
        String sql = "select md_donvitinh_id, ten_dvt from md_donvitinh where hoatdong = 1";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }

    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        md_donvitinh obj = db.md_donvitinhs.Single(p => p.md_donvitinh_id == context.Request.Form["id"]);
        var mnu = new md_donvitinh();
        obj.CopyPropertiesTo(mnu);
        obj.ma_edi = context.Request.Form["ma_edi"];
        obj.ten_dvt = context.Request.Form["ten_dvt"];
        obj.mota = context.Request.Form["mota"];
        obj.hoatdong = hd;
        obj.nguoicapnhat = UserUtils.getUser(context);
        obj.ngaycapnhat = DateTime.Now;
        var diffs = VoNgocNhan.API_Data.GetDifferences(obj, mnu);
        if (diffs.Count > 0)
        {
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.edit,
                    table = obj.GetType().Name,
                    id_lienket = obj.md_donvitinh_id,
                    ma_lienket = obj.ma_edi
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

        md_donvitinh obj = new md_donvitinh
        {
            md_donvitinh_id = Helper.getNewId(),
            ma_edi = context.Request.Form["ma_edi"],
            ten_dvt = context.Request.Form["ten_dvt"],
            mota = context.Request.Form["mota"],
            hoatdong = hd,
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.md_donvitinhs.InsertOnSubmit(obj);
        VoNgocNhan.API_Data.themLichSuHoatDong(
           db,
           context,
           new ad_log
           {
               nexxdecor_check = false,
               hanhdong = VoNgocNhan.API_Data.add,
               table = obj.GetType().Name,
               id_lienket = obj.md_donvitinh_id,
               ma_lienket = obj.ma_edi
           }
       );
        db.SubmitChanges();
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var mnu = db.md_donvitinhs.Where(s => s.md_donvitinh_id == id).FirstOrDefault();
            if (mnu == null)
            {
                msg = "Không tìm thấy đvt đóng gói đã chọn";
                goto EndEventHandler;
            }

            db.md_donvitinhs.DeleteOnSubmit(mnu);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.del,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_donvitinh_id,
                    ma_lienket = mnu.ma_edi
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
            jqGridHelper.Utils.writeResult(1, "Xóa dvt đóng gói thành công");
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

        String sqlCount = "SELECT COUNT(*) AS count from md_donvitinh where 1=1 " + filter;
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
            sidx = "dvt.ten_dvt";
        }

        string strsql = "select * from( select dvt.*, ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum from md_donvitinh dvt where 1=1 " + filter + " )P where RowNum > @start AND RowNum < @end";

        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["md_donvitinh_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_edi"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_dvt"] + "]]></cell>";
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