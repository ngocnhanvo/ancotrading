<%@ WebHandler Language="C#" Class="Controller_DTKD_SPDT" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_DTKD_SPDT : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "ketthuc":
                this.ketthuc(context);
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

    public void ketthuc(HttpContext context)
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

            if(tv.trangthai != Helper.HIEULUC)
            {
                msg = $@"Dòng ""tiền về"" không ở trạng thái Hiệu Lực";
                goto EndEventHandler;
            }

            tv.trangthai = Helper.KETTHUC;
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
            jqGridHelper.Utils.writeResult(1, "Kêt thúc thành công");
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var spd = db.md_doitackinhdoanh_spds.Where(s => s.md_doitackinhdoanh_spd_id == id).FirstOrDefault();
            if (spd == null)
            {
                msg = $@"Không tìm thấy đối tượng cần sửa";
                goto EndEventHandler;
            }

            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == spd.md_doitackinhdoanh_id).FirstOrDefault();
            if (dtkd == null)
            {
                msg = $@"Không tìm thấy đối tác";
                goto EndEventHandler;
            }

            spd.Forwarder = context.Request.Form["Forwarder"].removeAllSpaceOrTrimText(true);
            spd.Shipper = context.Request.Form["Shipper"].removeAllSpaceOrTrimText(true);
            spd.Consignee = context.Request.Form["Consignee"].removeAllSpaceOrTrimText(true);
            spd.Notify = context.Request.Form["Notify"].removeAllSpaceOrTrimText(true);
            spd.AlsoNotify = context.Request.Form["AlsoNotify"].removeAllSpaceOrTrimText(true);
            spd.POD = context.Request.Form["POD"].removeAllSpaceOrTrimText(true);
            spd.PlaceOfDelivery = context.Request.Form["PlaceOfDelivery"].removeAllSpaceOrTrimText(true);
            spd.AddressForSendingOriginalDocs = context.Request.Form["AddressForSendingOriginalDocs"].removeAllSpaceOrTrimText(true);
            spd.EmailSendPaymentRequest = context.Request.Form["EmailSendPaymentRequest"].removeAllSpaceOrTrimText(true);
            spd.CacLoaiCTYC = context.Request.Form["CacLoaiCTYC"].removeAllSpaceOrTrimText(true);
            spd.mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
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
        string dtkdid = context.Request.Form["id"];
        try
        {
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dtkdid).FirstOrDefault();
            if (dtkd == null)
            {
                msg = $@"Không tìm thấy đối tác";
                goto EndEventHandler;
            }

            var spd = new md_doitackinhdoanh_spd();
            spd.md_doitackinhdoanh_spd_id = Helper.getNewId();
            spd.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id;
            spd.Forwarder = context.Request.Form["Forwarder"].removeAllSpaceOrTrimText(true);
            spd.Shipper = context.Request.Form["Shipper"].removeAllSpaceOrTrimText(true);
            spd.Consignee = context.Request.Form["Consignee"].removeAllSpaceOrTrimText(true);
            spd.Notify = context.Request.Form["Notify"].removeAllSpaceOrTrimText(true);
            spd.AlsoNotify = context.Request.Form["AlsoNotify"].removeAllSpaceOrTrimText(true);
            spd.POD = context.Request.Form["POD"].removeAllSpaceOrTrimText(true);
            spd.PlaceOfDelivery = context.Request.Form["PlaceOfDelivery"].removeAllSpaceOrTrimText(true);
            spd.AddressForSendingOriginalDocs = context.Request.Form["AddressForSendingOriginalDocs"].removeAllSpaceOrTrimText(true);
            spd.EmailSendPaymentRequest = context.Request.Form["EmailSendPaymentRequest"].removeAllSpaceOrTrimText(true);
            spd.CacLoaiCTYC = context.Request.Form["CacLoaiCTYC"].removeAllSpaceOrTrimText(true);
            spd.mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
            spd.ngaytao = DateTime.Now;
            spd.nguoitao = UserUtils.getUser(context);
            spd.ngaycapnhat = DateTime.Now;
            spd.nguoicapnhat = UserUtils.getUser(context);
            spd.hoatdong = true;
            db.md_doitackinhdoanh_spds.InsertOnSubmit(spd);
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
            var spd = db.md_doitackinhdoanh_spds.Where(s => s.md_doitackinhdoanh_spd_id == id).FirstOrDefault();
            if (spd == null)
            {
                msg = $@"Không tìm thấy dòng đã chọn";
                goto EndEventHandler;
            }

            db.md_doitackinhdoanh_spds.DeleteOnSubmit(spd);
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

        string id = context.Request.QueryString["id"];
        string whereSQL = $"and spd.md_doitackinhdoanh_id = '{id}'";
        string madtkd = context.Request.Params["madtkd"];
        if(!string.IsNullOrWhiteSpace(madtkd))
        {
            whereSQL = $"and spd.md_doitackinhdoanh_id in (select md_doitackinhdoanh_id from md_doitackinhdoanh where ma_dtkd = '{madtkd}')";
        }

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM md_doitackinhdoanh_spd spd
            WHERE 1=1 {whereSQL} {filter}";
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
                spd.md_doitackinhdoanh_spd_id, 
                spd.md_doitackinhdoanh_id, 
                spd.Forwarder, 
                spd.Shipper,
                spd.Consignee,
                spd.Notify,
                spd.AlsoNotify,
                spd.POD,
                spd.PlaceOfDelivery,
                spd.AddressForSendingOriginalDocs,
                spd.EmailSendPaymentRequest,
                spd.CacLoaiCTYC,
                spd.ngaytao, 
                spd.nguoitao, 
                spd.ngaycapnhat, 
                spd.nguoicapnhat, 
                spd.mota,
                spd.hoatdong,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM md_doitackinhdoanh_spd spd
            WHERE 1=1 {whereSQL} {filter}
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
                        string fmt = "dd/MM/yyyy";
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
