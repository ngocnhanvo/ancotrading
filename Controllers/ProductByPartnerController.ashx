<%@ WebHandler Language="C#" Class="ProductByPartnerController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;

public class ProductByPartnerController : IHttpHandler
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
        String sql = "select md_hanghoadocquyen_id, md_hanghoadocquyen_id from md_hanghoadocquyen hhdq JOIN md_sanpham sp ON hhdq.md_sanpham_id = sp.md_sanpham_id where hhdq.hoatdong = 1";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }


    public void edit(HttpContext context)
    {
        try
        {
            String h = context.Request.Form["hoatdong"].ToLower();
            // bool hd = false;
            // if (h.Equals("on") || h.Equals("true"))
            // { hd = true; }

            md_hanghoadocquyen m = db.md_hanghoadocquyens.Single(p => p.md_hanghoadocquyen_id == context.Request.Form["md_hanghoadocquyen_id"]);
            var mnu = new md_hanghoadocquyen();
            m.CopyPropertiesTo(mnu);
            m.md_sanpham_id = context.Request.Form["sanpham_id"];

            m.mota = context.Request.Form["mota"];
            // m.hoatdong = hd;
            m.ngaycapnhat = DateTime.Now;
            m.nguoicapnhat = UserUtils.getUser(context);


            int check = (from dq in db.md_hanghoadocquyens
                         where !dq.md_hanghoadocquyen_id.Equals(m.md_hanghoadocquyen_id) && dq.md_sanpham_id.Equals(context.Request.Form["sanpham_id"]) && dq.md_doitackinhdoanh_id.Equals(m.md_doitackinhdoanh_id)
                         select new { dq.md_hanghoadocquyen_id}).Count();
            if (check == 0)
            {
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
                            id_lienket = m.md_hanghoadocquyen_id
                        }
                    );
                }
                db.SubmitChanges();
                jqGridHelper.Utils.writeResult(1,"Cập nhật thành công!");
            }
            else {
                jqGridHelper.Utils.writeResult(0, "Đã tồn tại mã hàng này trong danh sách hàng độc quyền của khách hàng!");
            }

        }catch(Exception ex){
            jqGridHelper.Utils.writeResult(0, ex.Message);
        }
    }

    public void add(HttpContext context)
    {
        try
        {
            String h = context.Request.Form["hoatdong"].ToLower();
            bool hd = false;
            if (h.Equals("on") || h.Equals("true"))
            { hd = true; }

            md_hanghoadocquyen mnu = new md_hanghoadocquyen
            {
                md_hanghoadocquyen_id = Helper.getNewId(),
                md_doitackinhdoanh_id = context.Request.Form["md_doitackinhdoanh_id"],
                md_sanpham_id = context.Request.Form["sanpham_id"],
                mota = context.Request.Form["mota"],
                hoatdong = hd,
                nguoitao = UserUtils.getUser(context),
                nguoicapnhat = UserUtils.getUser(context),
                ngaytao = DateTime.Now,
                ngaycapnhat = DateTime.Now
            };

            int check = (from dq in db.md_hanghoadocquyens
                         where dq.md_sanpham_id.Equals(context.Request.Form["sanpham_id"]) && dq.md_doitackinhdoanh_id.Equals(context.Request.Form["md_doitackinhdoanh_id"])
                         select new { dq.md_hanghoadocquyen_id}).Count();
            if (check == 0)
            {
                db.md_hanghoadocquyens.InsertOnSubmit(mnu);
                VoNgocNhan.API_Data.themLichSuHoatDong(
                    db,
                    HttpContext.Current,
                    new ad_log
                    {
                        nexxdecor_check = false,
                        hanhdong = VoNgocNhan.API_Data.add,
                        table = mnu.GetType().Name,
                        id_lienket = mnu.md_hanghoadocquyen_id
                    }
                );
                db.SubmitChanges();
                jqGridHelper.Utils.writeResult(1,"Thêm mới thành công!");
            }
            else {
                jqGridHelper.Utils.writeResult(0, "Đã tồn tại mã hàng này trong danh sách hàng độc quyền của khách hàng!");
            }


        }catch(Exception ex){
            jqGridHelper.Utils.writeResult(0, ex.Message);
        }
    }


    public void del(HttpContext context)
    {
        string id = context.Request.Form["id"], msg = "";
        try
        {
            var cxhang = db.md_hanghoadocquyens.Single(cx => cx.md_hanghoadocquyen_id.Equals(id));

            if (cxhang == null)
            {
                msg = "Không tìm thấy hàng hóa độc quyền đã chọn";
                goto EndEventHandler;
            }
            db.md_hanghoadocquyens.DeleteOnSubmit(cxhang);
            VoNgocNhan.API_Data.themLichSuHoatDong(
               db,
               context,
               new ad_log
               {
                   nexxdecor_check = false,
                   hanhdong = VoNgocNhan.API_Data.del,
                   table = cxhang.GetType().Name,
                   id_lienket = cxhang.md_hanghoadocquyen_id
               }
            );
            db.SubmitChanges();

        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Xóa hàng hóa độc quyền thành công");
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
    }

    public void load(HttpContext context)
    {
        String partnerId = context.Request.QueryString["partnerId"];

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

        String sqlCount = "SELECT COUNT(*) AS count " +
            " FROM md_hanghoadocquyen hhdq " +
            " left join md_sanpham sp on hhdq.md_sanpham_id = sp.md_sanpham_id " +
            " left join md_doitackinhdoanh dtkd on hhdq.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id " +
            " WHERE hhdq.md_doitackinhdoanh_id = @md_doitackinhdoanh_id " + filter;



        int page = int.Parse(context.Request.QueryString["page"]);
        int limit = int.Parse(context.Request.QueryString["rows"]);
        String sidx = context.Request.QueryString["sidx"];
        String sord = context.Request.QueryString["sord"];
        int total_page;
        int count = (int)mdbc.ExecuteScalar(sqlCount, "@md_doitackinhdoanh_id", partnerId != null ? partnerId : "0");
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
            sidx = "md_hanghoadocquyen_id";
        }

        string strsql = "select * from( " +
            " SELECT hhdq.md_hanghoadocquyen_id, dtkd.md_doitackinhdoanh_id, sp.md_sanpham_id as sanpham_id, sp.ma_sanpham as tensp, " +
            " hhdq.ngaytao, hhdq.nguoitao, hhdq.ngaycapnhat, hhdq.nguoicapnhat, hhdq.mota, hhdq.hoatdong, " +
            " ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum " +
            " FROM md_hanghoadocquyen hhdq " +
            " left join md_sanpham sp on hhdq.md_sanpham_id = sp.md_sanpham_id " +
            " left join md_doitackinhdoanh dtkd on hhdq.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id " +
            " where hhdq.md_doitackinhdoanh_id =  @md_doitackinhdoanh_id " + filter +
            ")P WHERE RowNum > @start AND RowNum < @end";

        if (partnerId != null)
        {
            strsql = String.Format(strsql, partnerId);
        }
        else
        {
            strsql = String.Format(strsql, 0);
        }

        System.Data.DataTable dt = mdbc.GetData(strsql, "@md_doitackinhdoanh_id", partnerId != null ? partnerId : "0", "@start", start, "@end", end);
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
            xml += "<cell><![CDATA[" + row[5] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[6].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[7] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[8] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[9] + "]]></cell>";
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
