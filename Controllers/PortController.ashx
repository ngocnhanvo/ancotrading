<%@ WebHandler Language="C#" Class="PortController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;

public class PortController : IHttpHandler
{
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
            case "getoptionAll":
                this.getSelectOptionAllActive(context);
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
        String sql = "select md_cangbien_id, ten_cangbien from md_cangbien where hoatdong = 1 order by ten_cangbien asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToOptionNullFirst());
    }

    public void getSelectOptionAllActive(HttpContext context)
    {
        String sql = "select md_cangbien_id, ten_cangbien from md_cangbien order by ten_cangbien asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToOptionNullFirst());
    }

    public void getSearchOption(HttpContext context)
    {
        String sql = "select ten_cangbien as id, ten_cangbien from md_cangbien where hoatdong = 1 order by ten_cangbien asc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToOptionSearch());
    }


    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        String ma_cangbien = context.Request.Form["ma_cangbien"];
        String md_cangbien_id = context.Request.Form["id"];
        String selCount = "select COUNT(*) as count from md_cangbien where ma_cangbien = @ma_cangbien AND md_cangbien_id != @md_cangbien_id";
        int count = (int)mdbc.ExecuteScalar(selCount, "@ma_cangbien", ma_cangbien, "@md_cangbien_id", md_cangbien_id);

        if (count != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Mã cảng biển đã tồn tại!");
        }
        else
        {
            md_cangbien m = db.md_cangbiens.Single(p => p.md_cangbien_id == md_cangbien_id);
            var mnu = new md_cangbien();
            m.CopyPropertiesTo(mnu);
            m.ma_cangbien = context.Request.Form["ma_cangbien"];
            m.ten_cangbien = context.Request.Form["ten_cangbien"];
            m.mota = context.Request.Form["mota"];
            m.hoatdong = hd;
            m.nguoicapnhat = UserUtils.getUser(context);
            m.ngaycapnhat = DateTime.Now;
            var diffs = VoNgocNhan.API_Data.GetDifferences(m, mnu);
            if (diffs.Count > 0)
            {
                VoNgocNhan.API_Data.themLichSuHoatDong(
                    db,
                    context,
                    new ad_log
                    {
                        nexxdecor_check = false,
                        hanhdong = VoNgocNhan.API_Data.edit,
                        table = m.GetType().Name,
                        id_lienket = m.md_cangbien_id,
                        ma_lienket = m.ma_cangbien
                    }
                );
            }
            db.SubmitChanges();
        }
    }

    public void add(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        String ma_cangbien = context.Request.Form["ma_cangbien"];
        int c = (from cb in db.md_cangbiens where cb.ma_cangbien.Equals(ma_cangbien) select new { cb.ma_cangbien }).Count();
        String selCount = "select COUNT(*) as count from md_cangbien where ma_cangbien = @ma_cangbien";
        int count = (int)mdbc.ExecuteScalar(selCount, "@ma_cangbien", ma_cangbien);

        if (count != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Mã cảng biển đã tồn tại!");
        }
        else
        {
            md_cangbien obj = new md_cangbien
            {
                md_cangbien_id = Helper.getNewId(),
                ma_cangbien = ma_cangbien,
                ten_cangbien = context.Request.Form["ten_cangbien"],
                mota = context.Request.Form["mota"],
                hoatdong = hd,
                nguoitao = UserUtils.getUser(context),
                nguoicapnhat = UserUtils.getUser(context),
                ngaytao = DateTime.Now,
                ngaycapnhat = DateTime.Now
            };

            db.md_cangbiens.InsertOnSubmit(obj);
            VoNgocNhan.API_Data.themLichSuHoatDong(
               db,
               context,
               new ad_log
               {
                   nexxdecor_check = false,
                   hanhdong = VoNgocNhan.API_Data.add,
                   table = obj.GetType().Name,
                   id_lienket = obj.md_cangbien_id,
                   ma_lienket = obj.ma_cangbien
               }
           );
            db.SubmitChanges();
            jqGridHelper.Utils.writeResult(1, "Đã tạo cảng biển thành công!");
        }
    }


    public void del(HttpContext context)
    {
        String id = context.Request.Form["id"];
        string msg = "";
        try
        {
            var mnu = db.md_cangbiens.Where(s => s.md_cangbien_id == id).FirstOrDefault();
            if (mnu == null)
            {
                msg = "Không tìm thấy cảng biển đã chọn";
                goto EndEventHandler;
            }

            var cosp = db.md_sanphams.Where(s => s.md_cangbien_id == mnu.md_cangbien_id).Take(1).Count();
            if (cosp > 0)
            {
                msg = "Cảng biển có chứa sản phẩm";
                goto EndEventHandler;
            }

            db.md_cangbiens.DeleteOnSubmit(mnu);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.del,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_cangbien_id,
                    ma_lienket = mnu.ma_cangbien
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
            jqGridHelper.Utils.writeResult(1, "Xóa cảng biển thành công");
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

        String sqlCount = "SELECT COUNT(*) AS count FROM md_cangbien";
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

        if (sidx.Equals("cb.ma_cangbien") || sidx == null)
        {
            sidx = "";
        }

        string strsql = "select * from( select cb.*,  ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum from md_cangbien cb)P where RowNum > @start AND RowNum < @end";

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
            xml += "<cell><![CDATA[" + DateTime.Parse(row[3].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[4] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[5].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[6] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[7] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[8] + "]]></cell>";
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
