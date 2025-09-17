<%@ WebHandler Language="C#" Class="Controller_TienVe" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using NPOI.SS.UserModel;
using NPOI.XSSF.UserModel;
using NPOI.HSSF.UserModel;
public class Controller_TienVe : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public string upload(HttpContext context)
    {
        string msg = "";
        HttpFileCollection files = context.Request.Files;
        string path = ExcuteSignalRStatic.mapPathSignalR("~/FileUpload");
        if (files.Count > 0)
        {
            if (System.IO.Directory.Exists(path))
            {
                int j = files[0].FileName.LastIndexOf(".");
                string mime = files[0].FileName.Substring(j);
                msg = $"{path}/{Helper.getNewId()}{mime}";
                files[0].SaveAs(msg);

                if (mime != ".xls")
                {
                    ConvertXLSXToXLS.ConvertWorkbookXSSFToHSSF(msg);
                    System.IO.File.Delete(msg);
                    msg = msg.Replace(".xlsx", ".xls");
                }
            }
            else
            {
                msg = "false";
            }
        }
        else
        {
            msg = "false#2";
        }
        return msg;
    }

    public object getValue(Cell cell, string type = "")
    {
        object kq = "";
        if (type == "date")
        {
            if (cell != null)
            {
                if (!cell.IsEmpty)
                    kq = cell.DateTimeValue;
                else
                    kq = null;
            }
            else
                kq = null;
        }
        else if(type == "number")
        {
            if (cell != null)
            {
                if (!cell.IsEmpty)
                    kq = cell.Value;
                else
                    kq = null;
            }
            else
                kq = null;
        }
        else
        {
            if (cell != null)
            {
                if (!cell.IsEmpty)
                    kq = cell.Value;
                else
                    kq = "";
            }
            else
                kq = "";
        }
        return kq;
    }

    public void taoTuExcel(HttpContext context, string file)
    {
        string msg = "";
        var db = new LinqDBDataContext();
        var tvs = new List<kt_tienve>();
        var wb = Workbook.Load(file);
        var ws = wb.Worksheets[0];
        var rows = ws.Cells;
        for(var i = 0; i < rows.Rows.Count; i++)
        {
            var row = rows.Rows[i];
            int cell = 0;
            var stt = getValue(row.GetCell(cell));
            cell++;
            var ngay = getValue(row.GetCell(cell), "date");
            cell++;
            var stc = getValue(row.GetCell(cell)).ToString().removeAllSpaceOrTrimText(true);
            cell++;
            var sgn = getValue(row.GetCell(cell)).ToString().ToNullableDecimal();
            cell++;
            var sgc = getValue(row.GetCell(cell)).ToString().ToNullableDecimal();
            cell++;
            var mota = getValue(row.GetCell(cell)).ToString().removeAllSpaceOrTrimText(true);

            var tv = db.kt_tienves.Where(s => s.sothamchieu == stc).FirstOrDefault();
            if (tv == null)
            {
                tv = new kt_tienve();
                tv.kt_tienve_id = Helper.getNewId();
                tv.trangthai = Helper.SOANTHAO;
                tv.sothamchieu = stc;
                tv.ngaygd = (DateTime?)ngay;
                tv.sotienghino = sgn;
                tv.sotienghico = sgc;
                tv.mota = mota.ToString();
                tv.ngaytao = DateTime.Now;
                tv.ngaycapnhat = DateTime.Now;
                tv.nguoitao = UserUtils.getUser(context);
                tv.nguoicapnhat = UserUtils.getUser(context);
                tv.hoatdong = true;
                tvs.Add(tv);
            }
        }

        if(tvs.Count > 0)
        {
            db.kt_tienves.InsertAllOnSubmit(tvs);
            db.SubmitChanges();
        }

        EndEventHandler:;

        context.Response.Write(msg);
    }

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
        string tvid = context.Request.Form["id"];
        try
        {
            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == tvid).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai != Helper.SOANTHAO)
            {
                msg = $@"Dòng ""tiền về"" không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            string dtkdId = context.Request.Form["dtkd_id"].removeAllSpaceOrTrimText(true);
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dtkdId).FirstOrDefault();
            if(dtkd == null)
            {
                msg = $@"Không tìm thấy khách hàng đã chọn";
                goto EndEventHandler;
            }
            else if(string.IsNullOrWhiteSpace(dtkd.ma_dtkd))
            {
                msg = $@"Không tìm thấy khách hàng đã chọn";
                goto EndEventHandler;
            }

            tv.mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
            tv.tienkhach = context.Request.Form["tienkhach"].removeAllSpaceOrTrimText(true).ToNullableDecimal();
            tv.phi = tv.tienkhach.GetValueOrDefault(0) - tv.sotienghico.GetValueOrDefault(0);
            tv.conlai = tv.tienkhach.GetValueOrDefault(0) - tv.tongtienphanbo.GetValueOrDefault(0);
            tv.dtkd_id = dtkd.md_doitackinhdoanh_id;
            tv.ngaycapnhat = DateTime.Now;
            tv.nguoicapnhat = UserUtils.getUser(context);
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
        string file = upload(context);
        if (file.Substring(0, 4) != "false")
        {
            taoTuExcel(context, file);
        }
        else
        {
            context.Response.Write(file);
        }
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string tvid = context.Request.Form["id"];
        try
        {
            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == tvid).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai != Helper.SOANTHAO)
            {
                msg = $@"Dòng ""tiền về"" không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var cttvs = db.kt_tienve_phanbos.Where(s => s.kt_tienve_id == tv.kt_tienve_id).ToList();
            foreach (var cttv in cttvs)
                db.kt_tienve_phanbos.DeleteOnSubmit(cttv);
            db.kt_tienves.DeleteOnSubmit(tv);
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
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM kt_tienve tv
            left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = tv.dtkd_id
            WHERE 1=1 {filter}";
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
            sidx = "tv.ngaygd";
            sord = "desc";
        }

        string strsql = $@"
        select * from(
            select 
                tv.kt_tienve_id, 
                tv.trangthai,
                tv.ngaygd,
                tv.sothamchieu,
                tv.sotienghino,
	            tv.sotienghico,
	            tv.mota,
	            tv.tienkhach,
	            tv.phi,
	            tv.tongtienphanbo,
	            tv.conlai,
	            dtkd.ma_dtkd,
                tv.ngaytao, 
                tv.nguoitao, 
                tv.ngaycapnhat, 
                tv.nguoicapnhat, 
                tv.hoatdong,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM kt_tienve tv
                left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = tv.dtkd_id 
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
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else if (column.DataType == Type.GetType("System.Decimal"))
                {
                    if (row[column.ColumnName] != null)
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
                    else
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                }
                else
                {
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
                }
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
