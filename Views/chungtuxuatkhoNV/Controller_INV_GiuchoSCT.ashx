<%@ WebHandler Language="C#" Class="Controller_INV_GiuchoSCT" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_INV_GiuchoSCT : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "options":
                this.options(context);
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

    public void options(HttpContext context)
    {
        string sctgiucho = $@"<option value=""""></option>";
        var scts = db.md_sochungtugiuchos.Where(s => s.loai == "Invoice").OrderBy(s=>s.socangiu).ToList();
        foreach(var sct in scts)
        {
            sctgiucho += $@"<option value=""{sct.socangiu}"">{sct.socangiu}</option>";
        }
        context.Response.Write(sctgiucho);
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string socangiu = context.Request.Form["socangiu"].removeAllSpaceOrTrimText(true);
        string mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
        string id = context.Request.Form["id"].removeAllSpaceOrTrimText(true);
        try
        {
            var spd = db.md_sochungtugiuchos.Where(s => s.md_sochungtugiucho_id == id).FirstOrDefault();
            if(spd == null)
            {
                msg = "Không tìm thấy dòng đã chọn";
                goto EndEventHandler;
            }

            var chungtu = db.md_sochungtus.Where(ct => ct.ten_sochungtu.Equals("Invoice")).FirstOrDefault();
            var sctL = chungtu.so_duocgan.ToString().Length - 1;
            if (socangiu.Length < sctL)
                socangiu = jqGridHelper.Utils.genericNumberDoc(socangiu, sctL - socangiu.Length + 1, true);

            var sctgc = db.md_sochungtugiuchos.Where(s => s.socangiu == socangiu & s.loai == "Invoice" & s.md_sochungtugiucho_id != id).FirstOrDefault();
            if (sctgc != null)
            {
                msg = $@"Số ""{socangiu}"" đã được giữ chỗ trước đó";
                goto EndEventHandler;
            }

            spd.socangiu = socangiu;
            spd.mota = mota;
            spd.ngaycapnhat = DateTime.Now;
            spd.nguoicapnhat = UserUtils.getUser(context);
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
            jqGridHelper.Utils.writeResult(1, "Cập nhật thành công");
    }

    public void add(HttpContext context)
    {
        string msg = "";
        string socangiu = context.Request.Form["socangiu"].removeAllSpaceOrTrimText(true);
        string mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
        try
        {
            var sctgc = db.md_sochungtugiuchos.Where(s => s.socangiu == socangiu & s.loai == "Invoice").FirstOrDefault();
            if (sctgc != null)
            {
                msg = $@"Số ""{socangiu}"" đã được giữ chỗ trước đó";
                goto EndEventHandler;
            }

            var chungtu = db.md_sochungtus.Where(ct => ct.ten_sochungtu.Equals("Invoice")).FirstOrDefault();
            var sctL = chungtu.so_duocgan.ToString().Length - 1;
            if (socangiu.Length < sctL)
                socangiu = jqGridHelper.Utils.genericNumberDoc(socangiu, sctL - socangiu.Length + 1, true);

            var spd = new md_sochungtugiucho();
            spd.md_sochungtugiucho_id = Helper.getNewId();
            spd.socangiu = socangiu;
            spd.loai = "Invoice";
            spd.mota = mota;
            spd.ngaytao = DateTime.Now;
            spd.nguoitao = UserUtils.getUser(context);
            spd.ngaycapnhat = DateTime.Now;
            spd.nguoicapnhat = UserUtils.getUser(context);
            spd.hoatdong = true;
            db.md_sochungtugiuchos.InsertOnSubmit(spd);
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
            jqGridHelper.Utils.writeResult(1, "Thêm thành công");
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var spd = db.md_sochungtugiuchos.Where(s => s.md_sochungtugiucho_id == id).FirstOrDefault();
            if (spd == null)
            {
                msg = $@"Không tìm thấy dòng đã chọn";
                goto EndEventHandler;
            }

            db.md_sochungtugiuchos.DeleteOnSubmit(spd);
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
            FROM md_sochungtugiucho spd
            WHERE 1=1 and spd.loai = 'Invoice' {filter}";
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
            sidx = "spd.ngaytao";
            sord = "desc";
        }

        string strsql = $@"
        select * from(
            select 
                spd.md_sochungtugiucho_id, 
                spd.socangiu,
                spd.ngaytao,
                spd.nguoitao,
                spd.mota,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM md_sochungtugiucho spd
            WHERE 1=1 and spd.loai = 'Invoice' {filter}
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
                            fmt = Extension.fmtDateHHmmss;
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
