<%@ WebHandler Language="C#" Class="UnitProductController" %>

using System;
using System.Web;
using System.Linq;

public class UnitProductController : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
        case "getsearchoption":
                this.getSearchOption(context);
                break;
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
        String sql = "select md_donvitinhsanpham_id, ten_dvt from md_donvitinhsanpham where hoatdong = 1 order by ten_dvt asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }

    public void getSearchOption(HttpContext context)
    {
        String sql = "select ten_dvt as ma_dvt, ten_dvt from md_donvitinhsanpham where hoatdong = 1  order by ten_dvt asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToOptionSearch());
    }
    
    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        md_donvitinhsanpham obj = db.md_donvitinhsanphams.Single(p => p.md_donvitinhsanpham_id == context.Request.Form["id"]);
        var mnu = new md_donvitinhsanpham();
        obj.CopyPropertiesTo(mnu);
        obj.ma_edi = context.Request.Form["ma_edi"];
        obj.ten_dvt = context.Request.Form["ten_dvt"];
        obj.ten_dvt_tv = context.Request.Form["ten_dvt_tv"];
        obj.ten_dvt_tv2 = context.Request.Form["ten_dvt_tv2"];
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
                    id_lienket = obj.md_donvitinhsanpham_id
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

        md_donvitinhsanpham obj = new md_donvitinhsanpham
        {
            md_donvitinhsanpham_id = Helper.getNewId(),
            ma_edi = context.Request.Form["ma_edi"],
            ten_dvt = context.Request.Form["ten_dvt"],
            ten_dvt_tv = context.Request.Form["ten_dvt_tv"],
            ten_dvt_tv2 = context.Request.Form["ten_dvt_tv2"],
            mota = context.Request.Form["mota"],
            hoatdong = hd,
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.md_donvitinhsanphams.InsertOnSubmit(obj);
        VoNgocNhan.API_Data.themLichSuHoatDong(
               db,
               context,
               new ad_log
               {
                   nexxdecor_check = false,
                   hanhdong = VoNgocNhan.API_Data.add,
                   table = obj.GetType().Name,
                   id_lienket = obj.md_donvitinhsanpham_id
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
            var mnu = db.md_donvitinhsanphams.Where(s => s.md_donvitinhsanpham_id == id).FirstOrDefault();
            if (mnu == null)
            {
                msg = "Không tìm thấy đvt sản phẩm đã chọn";
                goto EndEventHandler;
            }

            db.md_donvitinhsanphams.DeleteOnSubmit(mnu);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.del,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_donvitinhsanpham_id
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
            jqGridHelper.Utils.writeResult(1, "Xóa dvt sản phẩm thành công");
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

        String sqlCount = "SELECT COUNT(*) AS count from md_donvitinhsanpham";
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

        string strsql = $@"
            select * 
            from ( 
                select 
                    dvt.*, ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum 
                from md_donvitinhsanpham dvt
            )P 
            where 
                RowNum > @start AND RowNum < @end
        ";

        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["md_donvitinhsanpham_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_edi"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_dvt"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_dvt_tv"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_dvt_tv2"] + "]]></cell>";
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