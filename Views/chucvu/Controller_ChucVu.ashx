<%@ WebHandler Language="C#" Class="Controller_ChucVu" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_ChucVu : IHttpHandler
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
        var cvs = db.vaitro2s.Where(s => s.hoatdong == true).OrderBy(s => s.ma_vt2).ToList();
        var options = cvs.Select(s => $@"<option value=""{s.vaitro2_id}"">{s.ten_vt2}</option>");
        string str = $@"<select><option value=""""></option>{string.Join("", options)}</select>";
        context.Response.Write(str);
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var cv = db.vaitro2s.Where(s => s.vaitro2_id == id).FirstOrDefault();
            if (cv == null)
            {
                msg = "Không tìm thấy chức vụ đã chọn";
                goto EndEventHandler;
            }

            cv.ma_vt2 = context.Request.Form["ma_vt2"].removeAllSpaceOrTrimText(true);
            cv.ten_vt2 = context.Request.Form["ten_vt2"].removeAllSpaceOrTrimText(true);
            cv.mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
            cv.ngaycapnhat = DateTime.Now;
            cv.nguoicapnhat = UserUtils.getUser(context);
            cv.hoatdong = context.Request.Form["hoatdong"].removeAllSpaceOrTrimText(true).ToNullableBool();
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Cập nhật thành công");
    }

    public void add(HttpContext context)
    {
        string msg = "";
        try
        {
            var cv = new vaitro2();
            cv.vaitro2_id = Helper.getNewId();
            cv.ma_vt2 = context.Request.Form["ma_vt2"].removeAllSpaceOrTrimText(true);
            cv.ten_vt2 = context.Request.Form["ten_vt2"].removeAllSpaceOrTrimText(true);
            cv.mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
            cv.ngaytao = DateTime.Now;
            cv.nguoitao = UserUtils.getUser(context);
            cv.ngaycapnhat = DateTime.Now;
            cv.nguoicapnhat = UserUtils.getUser(context);
            cv.hoatdong = context.Request.Form["hoatdong"].removeAllSpaceOrTrimText(true).ToNullableBool();
            db.vaitro2s.InsertOnSubmit(cv);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Thêm thành công");
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var cv = db.vaitro2s.Where(s => s.vaitro2_id == id).FirstOrDefault();
            if (cv == null)
            {
                msg = "Không tìm thấy chức vụ đã chọn";
                goto EndEventHandler;
            }

            db.vaitro2s.DeleteOnSubmit(cv);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Xóa thành công");
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.Params["_search"]);
        if (_search)
        {
            String _filters = context.Request.Params["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM vaitro2 cv
            WHERE 1=1 {filter}";
        int page = int.Parse(context.Request.Params["page"]);
        int limit = int.Parse(context.Request.Params["rows"]);
        String sidx = context.Request.Params["sidx"];
        String sord = context.Request.Params["sord"];
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
            sidx = "cv.ma_vt2";
            sord = "asc";
        }

        string strsql = $@"
        select * from(
            select 
                cv.vaitro2_id,
                cv.ma_vt2,
                cv.ten_vt2,
                cv.ngaytao, 
                cv.nguoitao, 
                cv.ngaycapnhat, 
                cv.nguoicapnhat, 
                cv.mota,
                cv.hoatdong,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM vaitro2 cv
            WHERE 1=1 {filter}
        )P WHERE RowNum > @start AND RowNum < @end";

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
                        string fmt = Extension.fmtDate;
                        if (new string[] { "ngaytao", "ngaycapnhat" }.Contains(column.ColumnName))
                            fmt = "dd/MM/yyyy HH:mm:ss";
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString(fmt));
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
