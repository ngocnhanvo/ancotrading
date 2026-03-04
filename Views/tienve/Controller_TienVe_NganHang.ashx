<%@ WebHandler Language="C#" Class="Controller_TienVe_NganHang" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;

public class Controller_TienVe_NganHang : IHttpHandler, IDisposable
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void Dispose()
    {
        if (db != null)
        {
            db.Dispose();
            db = null;
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.DisposeOnPipelineCompleted(this);
        String action, oper;
        action = context.Request.Params["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "Upload":
                this.Upload(context);
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
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public void Upload(HttpContext context)
    {
        string msg = "";
        var updated = false;
        string id_parent = context.Request.Form["id_parent"];
        HttpFileCollection files = context.Request.Files;
        var lengthF = files.Count;
        if (lengthF <= 0)
        {
            msg = $@"<div error style='color:red'>Hãy chọn ít nhất 1 tập tin để ""tải lên""</div>";
            goto EndEventHandler;
        }

        var dsdh = db.kt_tienves.Where(s => s.kt_tienve_id == id_parent).FirstOrDefault();
        if (dsdh == null)
        {
            msg = $@"<div error style='color:red'>Không tìm thấy ""tiền về""</div>";
            goto EndEventHandler;
        }

        if(dsdh.trangthai == Helper.KETTHUC)
        {
            msg = $@"<div error style='color:red'>Dòng ""tiền về"" đã Kết Thúc</div>";
            goto EndEventHandler;
        }

        try
        {
            string dtdk = "TV01";
            var fileTypes = new string[] { ".pdf" };
            var pathRoot = "taptin/tienve";
            for (int i = 1; i <= lengthF; i++)
            {
                string fileName = files[i - 1].FileName.removeAllSpaceOrTrimText(true);
                int mimeI = fileName.LastIndexOf(".");
                string mime = fileName.Substring(mimeI).ToLower();
                string name = fileName.Substring(0, mimeI);
                if (!fileTypes.Contains(mime))
                {
                    msg += $@"<div error style='color:red'>{fileName}: phải là pdf</div>";
                }
                else
                {
                    var taptin = db.md_taptins.Where(p => p.tentaptin == fileName & p.doituong_dinhkem == dtdk & p.lienket == dsdh.kt_tienve_id).FirstOrDefault();
                    if (taptin == null)
                    {
                        var id = Helper.getNewId();
                        var path = $"{pathRoot}/{id}{mime}";
                        taptin = new md_taptin();
                        taptin.md_taptin_id = id;
                        taptin.lienket = id_parent;
                        taptin.trangthai = Helper.CHUAGUI;
                        taptin.doituong_dinhkem = dtdk;
                        taptin.tentaptin = fileName;
                        taptin.path = path;
                        taptin.size = files[i - 1].ContentLength;
                        taptin.mimetype = mime;
                        taptin.hoatdong = true;
                        taptin.ngaytao = DateTime.Now;
                        taptin.nguoitao = UserUtils.getUser(context);
                        db.md_taptins.InsertOnSubmit(taptin);
                        updated = true;
                        msg += $@"<div style='color:blue'>{fileName}: đã tải lên thành công.</div>";
                    }
                    else
                    {
                        msg += $@"<div error style='color:red'>{fileName}: đã tồn tại tập tin có tên này.</div>";
                    }
                }
            }

            if (updated)
            {
                db.SubmitChanges();

                for (int i = 1; i <= lengthF; i++)
                {
                    string fileName = files[i - 1].FileName.removeAllSpaceOrTrimText(true);
                    var taptin = db.md_taptins.Where(p => p.tentaptin == fileName & p.doituong_dinhkem == dtdk & p.lienket == dsdh.kt_tienve_id).FirstOrDefault();
                    if (taptin != null)
                    {
                        var path = $"{pathRoot}/{taptin.md_taptin_id}{taptin.mimetype}";
                        path = ExcuteSignalRStatic.mapPathSignalR($"~/{path}");
                        files[i - 1].SaveAs(path);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        context.Response.Write(msg);
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var cttv = db.md_taptins.Where(s => s.md_taptin_id == id).FirstOrDefault();
            if (cttv == null)
            {
                msg = $@"Không tìm thấy dòng ""tập tin"" đã chọn";
                goto EndEventHandler;
            }

            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == cttv.lienket).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai == Helper.KETTHUC)
            {
                msg = $@"Dòng ""tiền về"" đã Kết Thúc";
                goto EndEventHandler;
            }


            cttv.mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
            cttv.nguoicapnhat = UserUtils.getUser(context);
            cttv.ngaycapnhat = DateTime.Now;
            db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Sửa thành công");
    }

    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var cttv = db.md_taptins.Where(s => s.md_taptin_id == id).FirstOrDefault();
            if (cttv == null)
            {
                msg = $@"Không tìm thấy dòng ""tập tin"" đã chọn";
                goto EndEventHandler;
            }

            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == cttv.lienket).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai == Helper.KETTHUC)
            {
                msg = $@"Dòng ""tiền về"" đã Kết Thúc";
                goto EndEventHandler;
            }

            db.md_taptins.DeleteOnSubmit(cttv);
            ExcuteSignalRStatic.mapPathSignalR($@"~/{cttv.path}");
            db.SubmitChanges();
        }
        catch(Exception ex)
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
        String id = context.Request.QueryString["id"];
        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        var sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM md_taptin tt WHERE 1=1 {filter} 
            and tt.lienket ='{id}'
        ";

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
            sidx = "tt.ngaytao";
        }

        string strsql = $@"
            select * from(
                select 
                    tt.md_taptin_id 
                    , tt.tentaptin
                    , tt.mimetype
                    , tt.size
                    , tt.md_taptin_id as path
                    , tt.ngaytao
                    , tt.nguoitao
                    , tt.ngaycapnhat
                    , tt.nguoicapnhat
                    , tt.mota
                    , tt.hoatdong
                    , ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
                FROM 
                    md_taptin tt 
                WHERE 
                    1=1 {filter} 
                    and tt.lienket = '{id}'
                )P 
            where RowNum > @start AND RowNum < @end
        ";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = $@"<?xml version=""1.0"" encoding=""UTF-8"" ?>";
        xml += $@"<rows>";
        xml += $@"<page>{page}</page>";
        xml += $@"<total>{total_page}</total>";
        xml += $@"<records>{count}</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy HH:mm"));
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
