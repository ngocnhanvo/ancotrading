<%@ WebHandler Language="C#" Class="DSDH_HuongDanLamHang_Controller" %>

using System;
using System.Web;
using System.IO;
using System.Collections.Generic;
using System.Linq;

public class DSDH_HuongDanLamHang_Controller : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "Send":
                this.Send(context);
                break;
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

    public string guiMail(HttpContext context, List<md_taptin> tts, c_danhsachdathang dsdh)
    {
        string msg = "";
        try
        {
            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
            if(string.IsNullOrWhiteSpace(nv.smtp))
            {
                smtp = db.md_smtps.Where(s => s.smtpserver == nv.smtp).FirstOrDefault();
            }
            var mail = new GoogleMail(nv.email, nv.email_pass, smtp.smtpserver, smtp.port.Value, smtp.use_ssl.GetValueOrDefault(false));
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dsdh.md_doitackinhdoanh_id).FirstOrDefault();

            string title = $@"", body = $@"";
            var coDGbaBB = tts.Where(s => s.tentaptin.StartsWith(Helper.HDDG) & s.tentaptin.StartsWith(Helper.HDTEM_BAOBI)).Count() > 0;
            var coDG = tts.Where(s => s.tentaptin.StartsWith(Helper.HDDG) & !s.tentaptin.StartsWith(Helper.HDTEM_BAOBI)).Count() > 0;
            var coBB = tts.Where(s => !s.tentaptin.StartsWith(Helper.HDDG) & s.tentaptin.StartsWith(Helper.HDTEM_BAOBI)).Count() > 0;
            if (coDGbaBB)
            {
                title = $@"Hướng dẩn đóng gói/tem/bao bì cho đơn hàng {dsdh.so_po}";
                body = $@"<div>Tập tin đính kèm là phần hướng dẫn đóng gói/tem/bao bì cho đơn hàng số : {dsdh.so_po} của DSDH số {dsdh.sochungtu}.</div>";
            }
            else if (coDG)
            {
                title = $@"Hướng dẫn đóng gói cho đơn hàng {dsdh.so_po}";
                body = $@"<div>Tập tin đính kèm là phần hướng dẫn đóng gói cho đơn hàng số : {dsdh.so_po} của DSDH số {dsdh.sochungtu}.</div>";
            }
            else if (coBB)
            {
                title = $@"Hướng dẫn tem/bao bì cho đơn hàng {dsdh.so_po}";
                body = $@"<div>Tập tin đính kèm là phần hướng dẫn tem/bao bì cho đơn hàng số : {dsdh.so_po} của DSDH số {dsdh.sochungtu}.</div>";
            }

            var attachments = new List<System.Net.Mail.Attachment>();
            foreach (var tt in tts)
            {
                var attachment = new System.Net.Mail.Attachment(ExcuteSignalRStatic.mapPathSignalR($"~/{tt.path}"));
                attachment.Name = tt.tentaptin;
                attachments.Add(attachment);
                body += $"<div style='color:red; font-size:large'>{tt.mota}</div>";
            }

            mail.Send(
                nv.email
                , dtkd.email
                , nv.email
                , ""
                , title
                , body
                , attachments
            );
        }
        catch (Exception ex)
        {
            msg = $"Gửi mail thất bại: {ex.Message}";
        }

        return msg;
    }

    public void Send(HttpContext context)
    {
        var nccs = new string[] { "ANCO1" };
        var ids = context.Request.Form["id"].removeAllSpaceOrTrimText(false).Split(',').ToList();
        var taptins = db.md_taptins.Where(p => ids.Contains(p.md_taptin_id)).OrderBy(s => s.ngaytao).ToList();
        var dsdhId = taptins.Select(s => s.lienket).FirstOrDefault();
        var dsdh = db.c_danhsachdathangs.Where(c => c.c_danhsachdathang_id == dsdhId).FirstOrDefault();
        var msg = "";
        if (dsdh == null)
        {
            msg = $@"Không tìm thấy ""danh sách đăth hàng""";
            goto EndEventHandler;
        }

        if (dsdh.trangthai == Helper.CHUAGUI)
        {
            msg = $@"Chưa gửi ""danh sách đăth hàng""";
            goto EndEventHandler;
        }

        if (dsdh.trangthai == Helper.TUCHOI)
        {
            msg = $@"""Danh sách đăth hàng"" đã bị trả lại";
            goto EndEventHandler;
        }

        var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dsdh.md_doitackinhdoanh_id).FirstOrDefault();
        if (dtkd == null)
        {
            msg = $@"Không tìm thấy ""Nhà cung cấp""";
            goto EndEventHandler;
        }

        var msgErrs = new List<string>();
        var taptin2s = new List<md_taptin>();
        foreach (var taptin in taptins)
        {
            if (taptin.trangthai != Helper.CHUAGUI)
            {
                msgErrs.Add($@"""{taptin.tentaptin}"" đã được gửi NCC");
            }
            else
            {
                var taptin2 = new md_taptin();
                taptin.CopyPropertiesTo(taptin2);
                var link = ExcuteSignalRStatic.mapPathSignalR($@"~/{taptin2.path}");
                if (File.Exists(link))
                {
                    var bytes = File.ReadAllBytes(link);
                    taptin2.mota = Helper.EncodeHTML_VNN(Convert.ToBase64String(bytes));
                    taptin2s.Add(taptin2);

                    taptin.ngaycapnhat = DateTime.Now;
                    taptin.trangthai = Helper.DAGUI;
                }
            }
        }

        if (msgErrs.Count <= 0)
        {
            string msgDT = "";
            try
            {
                if (nccs.Contains(dtkd.ma_dtkd))
                {
                    string link = Extension.API_ALL(dtkd.ma_dtkd) + "?oper=guiHDLH";
                    var item = new Dictionary<string, object>();
                    item["result"] = taptin2s;
                    msgDT += Extension.GetModule(link, item);
                    msg += $@"<div style='color:red'>{guiMail(context, taptins, dsdh)}</div>";
                }
                else
                {
                    msgDT += $@"<div error style='color:red'>{guiMail(context, taptins, dsdh)}</div>";
                }

                if (!msgDT.Contains("error") & !msgDT.Contains("Có lỗi xảy ra"))
                {
                    dsdh.trangthaiHDLH = Helper.DAGUI;
                    db.SubmitChanges();
                }
                else
                {
                    msg = msgDT;
                }
            }
            catch (Exception ex)
            {
                msg = ex.Message;
            }
        }
        else
            msg = string.Join("<br>", msgErrs);

        EndEventHandler:;

        if (msg.Length <= 0)
        {
            msg = $@"<div style='color:blue'>Đã gửi HDLH</div>";
        }
        else
        {
            msg = $@"<div error style='color:red'>{msg}</div>";
        }

        context.Response.Write(msg);
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

        var dsdh = db.c_danhsachdathangs.Where(s => s.c_danhsachdathang_id == id_parent).FirstOrDefault();
        if (dsdh == null)
        {
            msg = $@"<div error style='color:red'>Không tìm thấy ""danh sách đăth hàng""</div>";
            goto EndEventHandler;
        }

        try
        {
            var fileTypes = new string[] { ".doc", ".docx", ".xls", ".xlsx" };
            var pathRoot = "taptin/hdlhAnco";
            for (int i = 1; i <= lengthF; i++)
            {
                string fileName = files[i - 1].FileName.removeAllSpaceOrTrimText(true);
                int mimeI = fileName.LastIndexOf(".");
                string mime = fileName.Substring(mimeI).ToLower();
                string name = fileName.Substring(0, mimeI);
                if (!fileTypes.Contains(mime))
                {
                    msg += $@"<div error style='color:red'>{fileName}: phải là word hoặc excel</div>";
                }
                else if (!name.StartsWith(Helper.HDBS) & !name.StartsWith(Helper.HDTEM_BAOBI))
                {
                    msg += $@"<div error style='color:red'>{fileName}: tên phải bắt đầu bằng {Helper.HDBS} hoặc {Helper.HDTEM_BAOBI}</div>";
                }
                else
                {
                    var taptin = db.md_taptins.Where(p => p.tentaptin == fileName & p.doituong_dinhkem == "HDLH" & p.lienket == dsdh.c_danhsachdathang_id).FirstOrDefault();
                    if (taptin == null)
                    {
                        var id = Helper.getNewId();
                        var path = $"{pathRoot}/{id}{mime}";
                        taptin = new md_taptin();
                        taptin.md_taptin_id = id;
                        taptin.lienket = id_parent;
                        taptin.trangthai = Helper.CHUAGUI;
                        taptin.doituong_dinhkem = "HDLH";
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
                    var taptin = db.md_taptins.Where(p => p.tentaptin == fileName & p.doituong_dinhkem == "HDLH" & p.lienket == dsdh.c_danhsachdathang_id).FirstOrDefault();
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
        var id = context.Request.Form["id"];
        var mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
        var object_ = db.md_taptins.Where(s => s.md_taptin_id == id).FirstOrDefault();
        if (object_ == null)
        {
            msg = "Không tìm thấy tập tin cần sửa";
            goto EndEventHandler;
        }

        object_.mota = mota;
        db.SubmitChanges();

    EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Sửa tập tin thành công");
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
    }

    public void add(HttpContext context)
    {

    }


    public void del(HttpContext context)
    {
        var ids = context.Request.Form["id"].removeAllSpaceOrTrimText(false).Split(',').ToList();
        var taptins = db.md_taptins.Where(p => ids.Contains(p.md_taptin_id)).ToList();
        var dsdhId = taptins.Select(s => s.lienket).FirstOrDefault();
        var dsdh = db.c_danhsachdathangs.Where(c => c.c_danhsachdathang_id == dsdhId).FirstOrDefault();
        var msg = "";
        if (dsdh == null)
        {
            msg = $@"Không tìm thấy ""danh sách đăth hàng""";
            goto EndEventHandler;
        }

        var msgErrs = new List<string>();
        var links = new List<string>();
        foreach (var taptin in taptins)
        {
            if (taptin.trangthai != "CHUAGUI")
            {
                msgErrs.Add($@"""{taptin.tentaptin}"" đã được gửi NCC");
            }
            else
            {
                db.md_taptins.DeleteOnSubmit(taptin);
                links.Add(ExcuteSignalRStatic.mapPathSignalR($@"~/{taptin.path}"));
            }
        }

        if (msgErrs.Count <= 0)
        {
            db.SubmitChanges();
            foreach (var link in links)
            {
                if (File.Exists(link))
                    File.Delete(link);
            }
        }
        else
            msg = string.Join(", ", msgErrs);

        EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Xóa tập tin thành công");
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
        String poId = context.Request.QueryString["poId"];
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
            and tt.lienket ='{poId}'
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
            sidx = "bc.md_bocai_id";
        }

        string strsql = $@"
            select * from(
                select 
                    tt.md_taptin_id 
                    , tt.tentaptin
                    , tt.mota
                    , tt.mimetype
                    , tt.size
                    , tt.md_taptin_id as path
                    , tt.ngaytao
                    , tt.nguoitao
                    , tt.ngaycapnhat
                    , tt.nguoicapnhat
                    , tt.ngayxacnhan
                    , tt.nguoixacnhan
                    , tt.lydotuchoi
                    , tt.trangthai
                    , ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
                FROM 
                    md_taptin tt 
                WHERE 
                    1=1 {filter} 
                    and tt.lienket = '{poId}'
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
