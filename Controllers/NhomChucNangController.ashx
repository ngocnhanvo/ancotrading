<%@ WebHandler Language="C#" Class="NhomChucNangController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;

public class NhomChucNangController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
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
    
	public void getSelectOption(HttpContext context)
    {
        String sql = "select md_nhomchungloai_id, code_ncl from md_nhomchungloai where hoatdong = 1 order by code_ncl desc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }
	
    public void edit(HttpContext context)
    {
        String nhomchungloai_id = context.Request.Form["id"];
        String code_ncl = context.Request.Form["code_ncl"];
        
        var lst = (from o in db.md_nhomchungloais
                  where o.code_ncl.Equals(code_ncl) && !o.md_nhomchungloai_id.Equals(nhomchungloai_id)
                  select new { o.md_nhomchungloai_id });
        
        if (lst.Count() != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Đã có nhóm chức năng này!");
        }
        else
        {
            md_nhomchungloai m = db.md_nhomchungloais.Where(p => p.md_nhomchungloai_id.Equals(nhomchungloai_id)).FirstOrDefault();
            var mnu = new md_nhomchungloai();
            m.CopyPropertiesTo(mnu);
            m.code_ncl = code_ncl;
            m.sapxep = context.Request.Form["sapxep"];
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
                        id_lienket = m.md_nhomchungloai_id
                    }
                );
            }
            db.SubmitChanges();
        }
    }

    public void add(HttpContext context)
    {      
        String code_ncl = context.Request.Form["code_ncl"];
        var lst = from o in db.md_nhomchungloais where o.code_ncl.Equals(code_ncl) select o;
        if (lst.Count() != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Đã có nhóm chức năng này!");
        }
        else
        {
            md_nhomchungloai mnu = new md_nhomchungloai
            {
                md_nhomchungloai_id = Helper.getNewId(),
                code_ncl = code_ncl,
                sapxep = context.Request.Form["sapxep"]
            };

            db.md_nhomchungloais.InsertOnSubmit(mnu);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.add,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_nhomchungloai_id
                }
            );
            db.SubmitChanges();
        }
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var mnu = db.md_nhomchungloais.Where(s => s.md_nhomchungloai_id == id).FirstOrDefault();
            if (mnu == null)
            {
                msg = "Không tìm thấy nhóm chức năng đã chọn";
                goto EndEventHandler;
            }

            db.md_nhomchungloais.DeleteOnSubmit(mnu);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.del,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_nhomchungloai_id
                }
            );
            db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if(msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Xóa nhóm chức năng thành công");
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
        
        String sqlCount = "SELECT COUNT(*) AS count FROM md_nhomchungloai cl where 1=1 {0} ";
        sqlCount = string.Format(sqlCount, filter);
        
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
            sidx = "cl.md_nhomchungloai_id";
        }

        string strsql = "select * from( " +
            " select ncl.md_nhomchungloai_id, ncl.code_ncl, ncl.sapxep "+
            " , ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum " +
            " FROM md_nhomchungloai ncl where 1=1 {0}" +
            " )P where RowNum > @start AND RowNum < @end";
        strsql = string.Format(strsql, filter);
        
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
