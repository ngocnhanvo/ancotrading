<%@ WebHandler Language="C#" Class="Controller_PO_SPDT" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_PO_SPDT : IHttpHandler, IDisposable
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        context.DisposeOnPipelineCompleted(this);
        String action, oper;
        action = context.Request.Params["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "guispd":
                this.guispd(context);
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

    public void guispd(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        string ghichu = context.Request.Form["ghichu"].removeAllSpaceOrTrimText(true);
        try
        {
            var spd = db.c_donhang_spds.Where(s => s.c_donhang_spd_id == id).FirstOrDefault();
            if (spd == null)
            {
                msg = $@"Không tìm thấy đối tượng cần gửi";
                goto EndEventHandler;
            }

            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == spd.c_donhang_id).FirstOrDefault();
            if (donhang == null)
            {
                msg = $@"Không tìm thấy đơn hàng";
                goto EndEventHandler;
            }

            if (spd.trangthai == Helper.DAGUI)
            {
                msg = $@"Shipping Detail đã được gửi trước đó";
                goto EndEventHandler;
            }

            if (donhang.trangthaict != Helper.DAHIEULUC)
            {
                msg = $@"Đơn hàng phải ở trạng thái chứng từ là ""Đã nhận"" để sử dụng chức năng này";
                goto EndEventHandler;
            }

            if (string.IsNullOrWhiteSpace(ghichu))
            {
                msg = "Không thể bỏ trống nội dụng của trường ghi chú";
                goto EndEventHandler;
            }

            var tbps = Public.layTruongBoPhan(db, Helper.TENBP_CHUNGTU).Select(s => s.email).ToList();
            if (tbps.Count <= 0)
            {
                msg = $@"Không tìm thấy trưởng bộ phận của bộ phận {Helper.TENBP_CHUNGTU}";
                goto EndEventHandler;
            }
            string emailTBPs = string.Join(";", tbps);
            string nvct = db.nhanviens.Where(s => s.manv == donhang.nhanvienCT).Select(s => s.email).FirstOrDefault();

            spd.trangthai = Helper.DAGUI;
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhang_id == donhang.c_donhang_id).FirstOrDefault();
            if (hsct != null)
            {
                hsct.ghichusau += $"\n{ghichu}";
            }
            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
            if (!string.IsNullOrWhiteSpace(nv.smtp))
            {
                smtp = db.md_smtps.Where(s => s.md_smtp_id == nv.smtp).FirstOrDefault();
            }
            var mail = new GoogleMail();
            mail.Email = nv.email;
            mail.Password = nv.email_pass;
            mail.Smtp = smtp.smtpserver;
            mail.Port = smtp.port.Value;
            mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);

            string title = $@"Gửi bổ sung / điều chinh shipping detail ({donhang.sochungtu})", body = $@"Nội dung: {ghichu}";
            var attachments = new List<System.Net.Mail.Attachment>();

            string cc = $"{nv.email},{emailTBPs}";
            mail.Send(
                nv.email
                , nvct
                , cc
                , ""
                , title
                , body
                , attachments
            );
            db.SubmitChanges();
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
            var spd = db.c_donhang_spds.Where(s => s.c_donhang_spd_id == id).FirstOrDefault();
            if (spd == null)
            {
                msg = $@"Không tìm thấy đối tượng cần sửa";
                goto EndEventHandler;
            }

            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == spd.c_donhang_id).FirstOrDefault();
            if (donhang == null)
            {
                msg = $@"Không tìm thấy đơn hàng";
                goto EndEventHandler;
            }

            if (spd.trangthai == Helper.DAGUI)
            {
                msg = $@"Shipping Detail đã được gửi trước đó";
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
        string dhid = context.Request.Form["id"];
        try
        {
            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == dhid).FirstOrDefault();
            if (donhang == null)
            {
                msg = $@"Không tìm thấy đơn hàng";
                goto EndEventHandler;
            }

            if (donhang.trangthaict == Helper.DAGUI)
            {
                msg = $@"Đơn hàng đã gửi, nếu cần sửa shipping detail thì hãy thu hồi bên chứng từ. Chỉ khi chứng từ đã nhận thì mới sử dụng phương pháp bổ sung này.";
                goto EndEventHandler;
            }

            var chuagui = db.c_donhang_spds.Where(s => s.c_donhang_id == donhang.c_donhang_id & s.trangthai != Helper.DAGUI).OrderByDescending(s => s.ngaytao).FirstOrDefault();
            if (chuagui != null)
            {
                msg = $@"Đơn hàng còn shipping detail ở trạng thái ""Chưa Gửi""";
                goto EndEventHandler;
            }

            var spd = new c_donhang_spd();
            spd.c_donhang_spd_id = Helper.getNewId();
            spd.trangthai = Helper.CHUAGUI;
            spd.c_donhang_id = donhang.c_donhang_id;
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
            db.c_donhang_spds.InsertOnSubmit(spd);
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
            var spd = db.c_donhang_spds.Where(s => s.c_donhang_spd_id == id).FirstOrDefault();
            if (spd == null)
            {
                msg = $@"Không tìm thấy dòng đã chọn";
                goto EndEventHandler;
            }

            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == spd.c_donhang_id).FirstOrDefault();
            if (donhang == null)
            {
                msg = $@"Không tìm thấy đơn hàng";
                goto EndEventHandler;
            }

            if (spd.trangthai == Helper.DAGUI)
            {
                msg = $@"Shipping detail đã được gửi trước đó";
                goto EndEventHandler;
            }

            db.c_donhang_spds.DeleteOnSubmit(spd);
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
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        string id = context.Request.QueryString["id"];
        string whereSQL = $"and spd.c_donhang_id = '{id}'";
        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM c_donhang_spd spd
            WHERE 1=1 {whereSQL} {filter}";
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
            sidx = "spd.ngaytao";
            sord = "desc";
        }

        string strsql = $@"
        select * from(
            select 
                spd.c_donhang_spd_id, 
                spd.c_donhang_id, 
                spd.trangthai,
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
            FROM c_donhang_spd spd
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

    public void Dispose()
    {
        if (db != null)
        {
            db.Dispose();
            db = null;
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
