<%@ WebHandler Language="C#" Class="LichTiepKhachController" %>


using System;
using System.Web;
using System.Data.Linq;
using System.Linq;

public class LichTiepKhachController : IHttpHandler
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

    public void edit(HttpContext context)
    {
        string msg = "";
        var user = UserUtils.getUser(context);
        String id = context.Request.Form["id"];

        try
        {
            var ltk = db.md_lichtiepkhaches.Where(s => s.md_lichtiepkhach_id == id).FirstOrDefault();
            if (ltk == null)
                msg = @"Không tìm thấy đối tượng cần sửa";
            else if (ltk.nguoitao != user)
                msg = string.Format(@"Chỉ người tạo ""{0}"" mới có thể sửa.", ltk.nguoitao);
            else
            {
                ltk.khachhang = context.Request.Form["khachhang"];
                ltk.quocgia = context.Request.Form["khachhang"];
                ltk.soluong = context.Request.Form["soluong"];
                ltk.thoigian = context.Request.Form["thoigian"];
                ltk.ngay = DateTime.ParseExact(context.Request.Form["ngay"], "dd/MM/yyyy", null);
                ltk.noidon = context.Request.Form["noidon"];
                ltk.noiduave = context.Request.Form["noiduave"];
                ltk.sosuat = context.Request.Form["sosuat"];
                ltk.thucan = context.Request.Form["thucan"];
                ltk.nguoilienhe = context.Request.Form["nguoilienhe"];
                ltk.mota = context.Request.Form["mota"];
                ltk.nguoicapnhat = UserUtils.getUser(context);
                ltk.ngaycapnhat = DateTime.Now;
                db.SubmitChanges();
            }
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

        context.Response.Write(msg);
    }

    public void add(HttpContext context)
    {
        string msg = "";
        try
        {
            var ltk = new md_lichtiepkhach();
            ltk.md_lichtiepkhach_id = Helper.getNewId();
            ltk.khachhang = context.Request.Form["khachhang"];
            ltk.quocgia = context.Request.Form["khachhang"];
            ltk.soluong = context.Request.Form["soluong"];
            ltk.thoigian = context.Request.Form["thoigian"];
            ltk.ngay = DateTime.ParseExact(context.Request.Form["ngay"], "dd/MM/yyyy", null);
            ltk.noidon = context.Request.Form["noidon"];
            ltk.noiduave = context.Request.Form["noiduave"];
            ltk.sosuat = context.Request.Form["sosuat"];
            ltk.thucan = context.Request.Form["thucan"];
            ltk.nguoilienhe = context.Request.Form["nguoilienhe"];
            ltk.mota = context.Request.Form["mota"];
            ltk.nguoitao = UserUtils.getUser(context);
            ltk.nguoicapnhat = UserUtils.getUser(context);
            ltk.ngaytao = DateTime.Now;
            ltk.ngaycapnhat = DateTime.Now;
            ltk.hoatdong = true;
            db.md_lichtiepkhaches.InsertOnSubmit(ltk);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

        context.Response.Write(msg);
    }


    public void del(HttpContext context)
    {
        string msg = "";
        var user = UserUtils.getUser(context);
        String id = context.Request.Form["id"];
        try
        {
            var ltk = db.md_lichtiepkhaches.Where(s => s.md_lichtiepkhach_id == id).FirstOrDefault();
            if (ltk == null)
                msg = @"Không tìm thấy đối tượng cần xóa";
            else if (ltk.nguoitao != user)
                msg = string.Format(@"Chỉ người tạo ""{0}"" mới có thể xóa.", ltk.nguoitao);
            else
            {
                db.md_lichtiepkhaches.DeleteOnSubmit(ltk);
                db.SubmitChanges();
            }
        }
        catch(Exception ex)
        {
            msg = ex.ToString();
        }

        context.Response.Write(msg);
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        String sqlCount = "SELECT COUNT(*) AS count FROM md_lichtiepkhach";
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
            sidx = "ngay";
        }

        string strsql = "select * from( select pt.*,  ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum from md_lichtiepkhach pt)P where RowNum > @start AND RowNum < @end";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
            }
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
