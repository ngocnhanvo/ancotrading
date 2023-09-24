<%@ WebHandler Language="C#" Class="LichTiepKhachController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Collections.Generic;
using System.Data;

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
            case "khachhangs":
                this.khachhangs(context);
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

    public void khachhangs(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        String searchTerm = context.Request.QueryString["searchTerm"];
        if (searchTerm == "")
        {
            searchTerm = "%";
        }
        else
        {
            searchTerm = String.Format("{0}%", searchTerm);
        }

        String sqlCount = String.Format(@"
            SELECT COUNT(1) AS count 
            FROM md_doitackinhdoanh dtkd 
            LEFT JOIN md_quocgia qg ON dtkd.md_quocgia_id = qg.md_quocgia_id
            LEFT JOIN md_loaidtkd ldt ON dtkd.md_loaidtkd_id = ldt.md_loaidtkd_id
            WHERE dtkd.ma_dtkd like '{0}' and dtkd.hoatdong = 1 and ldt.ma_loaidtkd in ('NHH','KH')
        ", searchTerm);

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
            sidx = "ma_dtkd";
        }

        String sql = "";
        if (total_page != 0)
        {
            sql = String.Format(@"
                select * from ( 
                    SELECT dtkd.ma_dtkd, dtkd.ten_dtkd, qg.ten_quocgia, ROW_NUMBER() OVER (ORDER BY {0} {1}) as RowNum 
                    FROM md_doitackinhdoanh dtkd 
                    LEFT JOIN md_quocgia qg ON dtkd.md_quocgia_id = qg.md_quocgia_id
                    LEFT JOIN md_loaidtkd ldt ON dtkd.md_loaidtkd_id = ldt.md_loaidtkd_id
                    WHERE dtkd.ma_dtkd like '{2}' and dtkd.hoatdong = 1 and ldt.ma_loaidtkd in ('NHH','KH')
                )P where RowNum > @start AND RowNum < @end"
            , sidx, sord, searchTerm);
        }
        else
        {
            sql = String.Format(@"
                select * from ( 
                    SELECT dtkd.ma_dtkd, dtkd.ten_dtkd, qg.ten_quocgia, ROW_NUMBER() OVER (ORDER BY {0} {1}) as RowNum 
                    FROM md_doitackinhdoanh dtkd 
                    LEFT JOIN md_quocgia qg ON dtkd.md_quocgia_id = qg.md_quocgia_id
                    LEFT JOIN md_loaidtkd ldt ON dtkd.md_loaidtkd_id = ldt.md_loaidtkd_id
                    WHERE dtkd.ma_dtkd like '{2}' and dtkd.hoatdong = 1 and ldt.ma_loaidtkd in ('NHH','KH')
                )P"
            , sidx, sord, searchTerm);
        }

        var dt = mdbc.GetData(sql, "@start", start, "@end", end);
        var jsonNew = new Dictionary<string, object>();
        jsonNew["page"] = page;
        jsonNew["total"] = total_page;
        jsonNew["records"] = count;
        var items = new List<Dictionary<string, object>>();

        foreach (DataRow row in dt.Rows)
        {
            var item = new Dictionary<string, object>();
            item["ma_dtkd"] = row["ma_dtkd"];
            item["ten_dtkd"] = row["ten_dtkd"];
            item["ten_quocgia"] = row["ten_quocgia"];
            items.Add(item);
        }

        if (items.Count > 0)
            jsonNew["rows"] = items;
        else
            jsonNew["rows"] = null;

        context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(jsonNew));
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        var user = UserUtils.getUser(context);
        String id = context.Request.Form["id"];
        var trangthai = context.Request.Form["trangthai"];
        var baocao = context.Request.Form["baocao"];
        try
        {
            var ltk = db.md_lichtiepkhaches.Where(s => s.md_lichtiepkhach_id == id).FirstOrDefault();
            if (ltk == null)
                msg = @"Không tìm thấy đối tượng cần sửa";
            else if (ltk.nguoitao != user)
                msg = string.Format(@"Chỉ người tạo ""{0}"" mới có thể sửa.", ltk.nguoitao);
            else if (baocao != ltk.baocao & ltk.trangthai != Helper.HIEULUC)
                msg = "Không thể báo cáo khi chưa Hiệu Lực";
            else if (baocao != ltk.baocao & !string.IsNullOrWhiteSpace(ltk.baocao))
                msg = "Đã báo cáo trước đó";
            else if (new string[] { Helper.HIEULUC, Helper.HUY }.Contains(ltk.trangthai))
            {
                if (trangthai == Helper.SOANTHAO)
                {
                    msg = "Không thể chuyển trạng thái về Soạn Thảo";
                }
                else
                {
                    ltk.trangthai = trangthai;
                    if (baocao != ltk.baocao & string.IsNullOrWhiteSpace(ltk.baocao))
                        ltk.baocao = baocao;
                    db.SubmitChanges();
                    jqGridHelper.Utils.writeResult(1, "Cập nhật trạng thái thành công");
                }
            }
            else
            {
                ltk.trangthai = trangthai;
                ltk.khachhang = context.Request.Form["khachhang"];
                ltk.quocgia = context.Request.Form["quocgia"];
                ltk.soluong = context.Request.Form["soluong"];
                ltk.thoigian = context.Request.Form["thoigian"];
                ltk.ngay = DateTime.ParseExact(context.Request.Form["ngay"], "dd/MM/yyyy", null);

                ltk.noidon = context.Request.Form["noidon"];
                if (string.IsNullOrWhiteSpace(ltk.noidon))
                    ltk.noidon = "Tự đến";
                ltk.noiduave = context.Request.Form["noiduave"];
                if (string.IsNullOrWhiteSpace(ltk.noiduave))
                    ltk.noiduave = "Ko";
                ltk.sosuat = context.Request.Form["sosuat"];
                if (string.IsNullOrWhiteSpace(ltk.sosuat))
                    ltk.sosuat = "Ko";
                ltk.thucan = context.Request.Form["thucan"];
                if (string.IsNullOrWhiteSpace(ltk.thucan))
                    ltk.thucan = "Ko";

                ltk.nguoilienhe = context.Request.Form["nguoilienhe"];
                ltk.mota = context.Request.Form["mota"];
                ltk.nguoicapnhat = UserUtils.getUser(context);
                ltk.ngaycapnhat = DateTime.Now;
                db.SubmitChanges();
                jqGridHelper.Utils.writeResult(1, "Sửa thành công");
            }
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
    }

    public void add(HttpContext context)
    {
        string msg = "";
        try
        {
            var ltk = new md_lichtiepkhach();
            ltk.md_lichtiepkhach_id = Helper.getNewId();
            ltk.trangthai = Helper.SOANTHAO;
            ltk.khachhang = context.Request.Form["khachhang"];
            ltk.quocgia = context.Request.Form["quocgia"];
            ltk.soluong = context.Request.Form["soluong"];
            ltk.thoigian = context.Request.Form["thoigian"];
            ltk.ngay = DateTime.ParseExact(context.Request.Form["ngay"], "dd/MM/yyyy", null);

            ltk.noidon = context.Request.Form["noidon"];
            if (string.IsNullOrWhiteSpace(ltk.noidon))
                ltk.noidon = "Tự đến";
            ltk.noiduave = context.Request.Form["noiduave"];
            if (string.IsNullOrWhiteSpace(ltk.noiduave))
                ltk.noiduave = "Ko";
            ltk.sosuat = context.Request.Form["sosuat"];
            if (string.IsNullOrWhiteSpace(ltk.sosuat))
                ltk.sosuat = "Ko";
            ltk.thucan = context.Request.Form["thucan"];
            if (string.IsNullOrWhiteSpace(ltk.thucan))
                ltk.thucan = "Ko";

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

        if (msg.Length <= 0)
            jqGridHelper.Utils.writeResult(1, "Thêm thành công");
        else
            jqGridHelper.Utils.writeResult(0, msg);
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
            else if (ltk.trangthai == Helper.HIEULUC)
                msg = string.Format(@"Đã Hiệu Lực.");
            else if (ltk.trangthai == Helper.HUY)
                msg = string.Format(@"Đã Hủy.");
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

        if (msg.Length <= 0)
            jqGridHelper.Utils.writeResult(1, "Xóa thành công");
        else
            jqGridHelper.Utils.writeResult(0, msg);
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
