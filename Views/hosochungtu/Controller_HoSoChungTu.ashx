<%@ WebHandler Language="C#" Class="Controller_HoSoChungTu" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_HoSoChungTu : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "selectnhanvienCT":
                this.selectnhanvienCT(context);
                break;
            case "ngayBHXN":
                this.ngayBHXN(context);
                break;
            case "sendMail":
                this.sendMail(context);
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

    public void sendMail(HttpContext context)
    {
        string msg = "";
        var ids = context.Request.Form["ids"].removeAllSpaceOrTrimText(false).Split(',').Where(s=> !string.IsNullOrEmpty(s)).ToList();
        var nvbhs = context.Request.Form["nvbhs"].removeAllSpaceOrTrimText(false).Split(',').Where(s=> !string.IsNullOrEmpty(s)).ToList();
        var nccs = context.Request.Form["nccs"].removeAllSpaceOrTrimText(false).Split(',').Where(s=> !string.IsNullOrEmpty(s)).ToList();
        var tt = context.Request.Form["tt"].removeAllSpaceOrTrimText(true);
        try
        {
            var hscts = db.c_donhangchungtus.Where(s => ids.Contains(s.c_donhangchungtu_id)).ToList();
            if (hscts.Count <= 0)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            var nvbhs2 = db.nhanviens.Where(s => nvbhs.Contains(s.manv)).OrderBy(s => s.email).ToList();
            var nccs2 = db.md_doitackinhdoanhs.Where(s => nccs.Contains(s.ma_dtkd)).OrderBy(s => s.email).ToList();
            if(nvbhs2.Count <= 0 & nccs2.Count <= 0)
            {
                msg = $@"Phải chọn nhân viên hoặc nhà cung cấp để gửi mail";
                goto EndEventHandler;
            }

            var arrDHs = new List<string>();
            foreach(var hsct in hscts)
            {
                var dh = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
                if (dh != null)
                    arrDHs.Add(dh.sochungtu);
            }

            if(!File.Exists(tt))
            {
                msg = $@"Không chiết xuất được tập tin theo hồ sơ đã chọn";
                goto EndEventHandler;
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
            string title = $@"Hồ sơ chứng từ của đơn hàng ""{string.Join(", ", arrDHs.OrderBy(s=>s).ToList())}""", body = $@"Chi tiết vui lòng xem ở tập tin đính kèm";
            var atts = new List<System.Net.Mail.Attachment>();
            var att = new System.Net.Mail.Attachment(tt);
            var name = "Chiết xuất hồ sơ.xls";
            att.Name = name;
            atts.Add(att);
            var emails = nvbhs2.Select(s => s.email).ToList().Concat(nccs2.Select(s => s.email).ToList());
            mail.Send(
                nv.email
                , string.Join(",", emails)
                , nv.email
                , ""
                , title
                , body
                , atts
            );
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Gửi mail thành công");
    }

    public void selectnhanvienCT(HttpContext context)
    {
        string str = "";
        str += "<select><option value=\"\"></option>";
        foreach (var nhanvien in db.nhanviens.Where(s => s.hoatdong == true).OrderBy(s => s.manv))
        {
            str += string.Format("<option value=\"{0}\">{1}</option>", nhanvien.manv, nhanvien.manv);
        }
        str += "</select>";
        context.Response.Write(str);
    }

    public void ngayBHXN(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
            if (hsct == null)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (!string.IsNullOrWhiteSpace(hsct.dongghep))
            {
                msg = $@"Hồ sơ này thuộc đơn hàng được ghép. Bạn Hãy điều chỉnh hồ sơ của đơn hàng ưu tiên ""{hsct.dongghep}""";
                goto EndEventHandler;
            }

            var dh = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
            if(dh == null)
            {
                msg = $@"Không tìm thấy đơn hàng gốc đang liên kết với hồ sơ";
                goto EndEventHandler;
            }

            var nvbh = db.nhanviens.Where(s => s.manv == dh.nguoilap).FirstOrDefault();
            if(nvbh == null)
            {
                msg = $@"Không tìm thấy nhân viên bán hàng ""{dh.nguoilap}"" trong danh sách nhân viên";
                goto EndEventHandler;
            }

            var ngayBHXN = context.Request.Form["ngayBHXN"].removeAllSpaceOrTrimText(true).ToNullableDate();
            if(ngayBHXN == null)
            {
                msg = $@"Ngày đã chọn không đúng định dạng (dd/MM/yyyy) hoặc đang bị bỏ trống";
                goto EndEventHandler;
            }

            hsct.ngayBHXN = ngayBHXN;
            dh.ngayBHXN = ngayBHXN;
            var arrDHCLs = new List<string>();
            var hsct2s = db.c_donhangchungtus.Where(s => s.dongghep == dh.sochungtu).OrderBy(s => s.dongghep).ToList();
            foreach(var hsct2 in hsct2s)
            {
                var dh2 = db.c_donhangs.Where(s => s.c_donhang_id == hsct2.c_donhang_id).FirstOrDefault();
                if (dh2 != null)
                {
                    dh2.ngayBHXN = ngayBHXN;
                    arrDHCLs.Add(dh2.sochungtu);
                }
            }
            hsct.ngaycapnhat = DateTime.Now;
            hsct.nguoicapnhat = UserUtils.getUser(context);
            db.SubmitChanges();

            try
            {
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
                string title = $@"Cập nhật ngày NHXNXH cho đơn hàng ""{dh.sochungtu}""", body = $@"Đơn hàng ưu tiên: ""{dh.sochungtu}""";
                body += $"<br><br>Đơn hàng còn lại: {string.Join(", ", arrDHCLs)}";
                body += $"<br><br>Ngày BHXNXH: {ngayBHXN.Value.ToString(Extension.fmtDate)}";
                var attachments = new List<System.Net.Mail.Attachment>();

                mail.Send(
                    nv.email
                    , nvbh.email
                    , nv.email
                    , ""
                    , title
                    , body
                    , attachments
                );
            }
            catch (Exception ex)
            {
                msg = ex.ToString();
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Cập nhật ngày bán hàng xác nhận xuất hàng thành công");
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        string ngaydieuchinh = context.Request.Form["ngaydieuchinh"].removeAllSpaceOrTrimText(true);
        string ngaypass = context.Request.Form["ngaypass"].removeAllSpaceOrTrimText(true);
        string ngaychuyenhoso = context.Request.Form["ngaychuyenhoso"].removeAllSpaceOrTrimText(true);
        string nhanvienCT = context.Request.Form["nhanvienCT"].removeAllSpaceOrTrimText(true);
        string ngayBookCont = context.Request.Form["ngayBookCont"].removeAllSpaceOrTrimText(true);
        string bookingNo = context.Request.Form["bookingNo"].removeAllSpaceOrTrimText(true);
        string ngayETD = context.Request.Form["ngayETD"].removeAllSpaceOrTrimText(true);
        string ngayETA = context.Request.Form["ngayETA"].removeAllSpaceOrTrimText(true);
        string ngayXuong = context.Request.Form["ngayXuong"].removeAllSpaceOrTrimText(true);
        string ngayCutOff = context.Request.Form["ngayCutOff"].removeAllSpaceOrTrimText(true);
        string ngayBHXN = context.Request.Form["ngayBHXN"].removeAllSpaceOrTrimText(true);
        string mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
        string trangthai = context.Request.Form["trangthai"].removeAllSpaceOrTrimText(true);
        try
        {
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
            if (hsct == null)
            {
                msg = $@"Không tìm thấy dòng ""Hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (hsct.trangthai == Helper.KETTHUC)
            {
                msg = $@"Hồ sơ đã Kết Thúc";
                goto EndEventHandler;
            }

            if (hsct.trangthai != Helper.SOANTHAO & trangthai == Helper.SOANTHAO)
            {
                msg = $@"Hồ sơ đã Hiệu lực trước đó";
                goto EndEventHandler;
            }

            var donhang = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
            if (hsct.trangthai == Helper.SOANTHAO & trangthai != Helper.SOANTHAO)
            {
                if (donhang != null)
                {
                    donhang.trangthaict = Helper.DAHIEULUC;
                }
            }

            if(trangthai != hsct.trangthai)
            {
                if(!string.IsNullOrWhiteSpace(hsct.dongghep) & donhang.sochungtu != hsct.dongghep)
                {
                    msg = $@"Hồ sơ có đơn hàng được ghép với đơn hàng ""{hsct.dongghep}""";
                    goto EndEventHandler;
                }
                else
                {
                    foreach(var hsctk in db.c_donhangchungtus.Where(s=>s.dongghep == donhang.sochungtu & s.c_donhangchungtu_id != hsct.c_donhangchungtu_id))
                    {
                        var donhangk = db.c_donhangs.Where(s => s.c_donhang_id == hsctk.c_donhang_id).FirstOrDefault();
                        if (hsctk.trangthai == Helper.SOANTHAO & trangthai != Helper.SOANTHAO)
                        {
                            if (donhangk != null)
                            {
                                donhangk.trangthaict =  Helper.DAHIEULUC;
                            }
                        }
                        hsctk.trangthai = trangthai;
                    }
                }
            }

            hsct.trangthai = trangthai;
            hsct.ngaydieuchinh = ngaydieuchinh.ToNullableDate();
            hsct.ngaypass = ngaypass.ToNullableDate();
            hsct.ngaychuyenhoso = ngaychuyenhoso.ToNullableDate();
            hsct.nhanvienCT = nhanvienCT;

            //ngayBookCont
            var date_ngayBookCont = ngayBookCont.ToNullableDate();
            if (date_ngayBookCont != null & hsct.ngayBookCont == null)
            {

            }
            hsct.ngayBookCont = date_ngayBookCont;

            //bookingNo
            if(string.IsNullOrEmpty(bookingNo) & string.IsNullOrEmpty(hsct.bookingNo))
            {

            }
            hsct.bookingNo = bookingNo;

            hsct.ngayETA = ngayETA.ToNullableDate();
            hsct.ngayETD = ngayETD.ToNullableDate();
            hsct.ngayBHXN = ngayBHXN.ToNullableDate();
            if (hsct.ngayETD != null & hsct.ngayBHXN == null)
                hsct.ngayBHXN = hsct.ngayETD.Value.AddDays(-7);

            hsct.ngayCutOff = ngayCutOff.ToNullableDate();
            hsct.ngayXuong = ngayXuong.ToNullableDate();
            if (hsct.ngayCutOff != null & hsct.ngayXuong == null)
                hsct.ngayXuong = hsct.ngayCutOff.Value.AddDays(-2);

            hsct.mota = mota;
            hsct.ngaycapnhat = DateTime.Now;
            hsct.nguoicapnhat = UserUtils.getUser(context);
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

    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var hsct = db.c_donhangchungtus.Where(s => s.c_donhangchungtu_id == id).FirstOrDefault();
            if (hsct == null)
            {
                msg = $@"Không tìm thấy dòng ""hồ sơ"" đã chọn";
                goto EndEventHandler;
            }

            if (hsct.trangthai != Helper.SOANTHAO)
            {
                msg = $@"Dòng ""hồ sơ"" không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var dh = db.c_donhangs.Where(s => s.c_donhang_id == hsct.c_donhang_id).FirstOrDefault();
            if (dh != null)
            {
                if (dh.md_trangthai_id == Helper.SOANTHAO)
                    dh.trangthaict = Helper.CHUAGUI;
                else
                    dh.trangthaict = Helper.TUCHOI;
            }

            foreach (var spd in db.c_donhang_spds.Where(s => s.c_donhang_id == dh.c_donhang_id & s.trangthai == Helper.DAGUI))
            {
                spd.trangthai = Helper.CHUAGUI;
            }

            var tts = db.md_taptins.Where(s => s.lienket == hsct.c_donhangchungtu_id).ToList();
            var links = new List<string>();
            foreach (var taptin in tts)
            {
                db.md_taptins.DeleteOnSubmit(taptin);
                links.Add(ExcuteSignalRStatic.mapPathSignalR($@"~/{taptin.path}"));
            }

            db.c_donhangchungtus.DeleteOnSubmit(hsct);
            db.SubmitChanges();

            foreach (var link in links)
            {
                if (File.Exists(link))
                    File.Delete(link);
            }
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

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM c_donhangchungtu dh
                left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
                left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
                outer apply (select top 1 POD, Forwarder from c_donhang_spd where c_donhang_id = dh2.c_donhang_id order by ngaytao desc) spd
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
            sidx = "dh.ngaytao";
            sord = "desc";
        }

        string strsql = $@"
        select * from(
            select
                dh.c_donhangchungtu_id
                , dh.c_donhang_id
                , dh.trangthai
                , kh.ma_dtkd
                , dh2.sochungtu
                , dh2.customer_order_no
                , dh.cont20
                , dh.cont40
                , dh.cont40hc
                , dh.cont45
                , dh.contLCL
                , dh.dongghep
                , dh.mota
                , dh.bookingNo
                , dh.ngayETD
                , dh.ngayETA
                , dh.ngayBHXN
                , dh.ngayXuong
                , dh.ngayCutOff
                , dh2.ngaypass
                , dh2.shipmenttime
                , DATEADD(day, -7, dh2.shipmenttime) as hangiaohang_po
                , dh.ngaydieuchinh
                , dh.ngaychuyenhoso
                , dh2.nguoilap
                , dh.nhanvienCT
                , spd.Forwarder
                , dh.ngayBookCont
                , spd.POD
                , dh.ngaytao
                , dh.nguoitao
                , dh.ngaycapnhat
                , dh.nguoicapnhat
                , dh.hoatdong
                , ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM c_donhangchungtu dh
                left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
                left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
                outer apply (select top 1 POD, Forwarder from c_donhang_spd where c_donhang_id = dh2.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
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
