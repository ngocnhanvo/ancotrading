<%@ WebHandler Language="C#" Class="DSDH_HuongDanLamHang2_Controller" %>

using System;
using System.Web;
using System.IO;
using System.Collections.Generic;
using System.Linq;

public class DSDH_HuongDanLamHang2_Controller : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();
    string fmtDate = "dd/MM/yyyy HH:mm";
    string CHUAGUI = "CHUAGUI", DAGUI = "DAGUI";
    string DDHH = "Đặc điểm hàng hóa";
    string CHDK = "Các hướng dẫn khác";
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
            case "loadGhiChu":
                this.loadGhiChu(context);
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

    public string guiMail(HttpContext context, List<md_ghichuhdlh> gcs, c_danhsachdathang dsdh)
    {
        string msg = "";
        try
        {
            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
            if(!string.IsNullOrWhiteSpace(nv.smtp))
            {
                smtp = db.md_smtps.Where(s => s.smtpserver == nv.smtp).FirstOrDefault();
            }
            var mail = new GoogleMail(nv.email, nv.email_pass, smtp.smtpserver, smtp.port.Value, smtp.use_ssl.GetValueOrDefault(false));
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dsdh.md_doitackinhdoanh_id).FirstOrDefault();

            string title = $@"Hướng dẩn bổ sung cho đơn hàng {dsdh.so_po}";
            string body = $@"Là phần hướng dẩn bổ sung cho dơn hàng số {dsdh.so_po} của DSDH số {dsdh.sochungtu} chi tiết theo số lần như chương trinh";
            mail.Send(
                nv.email
                , dtkd.email
                , nv.email
                , ""
                , title
                , body
            );
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

        if (msg.Length > 0)
            msg = $@"<div error style='color:red'>Gửi mail thất bại: {msg}</div>";
        else
            msg = $@"<div style='color:blue'>Gửi mail thành công</div>";

        return msg;
    }

    public void Send(HttpContext context)
    {
        var nccs = new string[] { "ANCO1" };
        var guiChuongTrinh = false;
        var msg = "";
        var hdlh = context.Request.Form["hdlh"];
        var chdk = context.Request.Form["chdk"];
        var id = context.Request.Form["id_parent"].removeAllSpaceOrTrimText(false);
        var dsdh = db.c_danhsachdathangs.Where(c => c.c_danhsachdathang_id == id).FirstOrDefault();
        var ghichus = db.md_ghichuhdlhs.Where(p => p.lienket == id & p.trangthai == CHUAGUI).OrderBy(s => s.ngaytao).ToList();
        if (string.IsNullOrWhiteSpace(id))
        {
            msg = $@"Chưa chọn đơn đặt hàng";
            goto EndEventHandler;
        }

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
        var taptin2s = new List<md_ghichuhdlh>();
        foreach (var ghichu in ghichus)
        {
            if (ghichu.trangthai != CHUAGUI)
            {
                msgErrs.Add($@"""{ghichu.ghichu}"" đã được gửi NCC");
            }
            else
            {
                var ghichu2 = new md_ghichuhdlh();
                ghichu.CopyPropertiesTo(ghichu2);
                taptin2s.Add(ghichu2);

                ghichu.ngaycapnhat = DateTime.Now;
                ghichu.trangthai = DAGUI;
            }
        }

        dsdh.huongdanlamhang = hdlh;
        dsdh.huongdanlamhangchung = chdk;

        if (msgErrs.Count <= 0)
        {
            string msgDT = "";
            try
            {
                if (guiChuongTrinh)
                {
                    string link = Extension.API_ALL(dtkd.ma_dtkd) + "?oper=guiHDLH2";
                    var item = new Dictionary<string, object>();
                    item["result"] = taptin2s;
                    item["hdlh"] = hdlh;
                    item["chdk"] = chdk;
                    msgDT += Extension.GetModule(link, item);
                }
                else
                {
                    msgDT = guiMail(context, ghichus, dsdh);
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
            if (guiChuongTrinh)
                msg += guiMail(context, ghichus, dsdh);
        }
        else
        {
            msg = $@"<div error style='color:red'>{msg}</div>";
        }

        context.Response.Write(msg);
    }

    public void loadGhiChu(HttpContext context)
    {
        string msg = "", ddhh = "", chdk = "";
        var id = context.Request.Form["id"].removeAllSpaceOrTrimText(false);
        if (string.IsNullOrWhiteSpace(id))
        {
            msg = $@"Chưa chọn đơn đặt hàng";
            goto EndEventHandler;
        }
        var dsdh = db.c_danhsachdathangs.Where(c => c.c_danhsachdathang_id == id).FirstOrDefault();
        if (dsdh == null)
        {
            msg = $@"Không tìm thấy ""danh sách đăth hàng""";
            goto EndEventHandler;
        }

        ddhh = dsdh.huongdanlamhang;
        chdk = dsdh.huongdanlamhangchung;

        var ghichus = db.md_ghichuhdlhs.Where(p => p.lienket == dsdh.c_danhsachdathang_id & p.trangthai == CHUAGUI).OrderBy(s => s.ngaytao).ToList();
        if (ghichus.Count <= 0)
        {
            msg = $@"Không có ""Hướng dẫn làm hàng"" nào cần gửi";
            goto EndEventHandler;
        }

        foreach (var ghichu in ghichus)
        {
            var ngaytaoStr = ghichu.ngaytao.Value.ToString(fmtDate);
            if (ghichu.loai == DDHH)
            {
                ddhh += $"\n------{ngaytaoStr}-----";
                ddhh += $"\n{ghichu.ghichu}";
                ddhh += $"\n";
            }
            else
            {
                chdk += $"\n------{ngaytaoStr}-----";
                chdk += $"\n{ghichu.ghichu}";
                chdk += $"\n";
            }
        }

    EndEventHandler:;

        dynamic dicMSG = new { ddhh, chdk, msg };
        context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(dicMSG));
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        var gchdlhId = context.Request.Form["id"];
        var gcstr = context.Request.Form["ghichu"];
        var ghichu = db.md_ghichuhdlhs.Where(c => c.md_ghichuhdlh_id == gchdlhId).FirstOrDefault();
        if (ghichu == null)
        {
            msg = $@"Không tìm thấy ""Ghi chú""";
            goto EndEventHandler;
        }

        if (ghichu.trangthai != CHUAGUI)
        {
            msg = $@"Đã gửi NCC";
            goto EndEventHandler;
        }

        try
        {
            ghichu.ghichu = gcstr;
            ghichu.hoatdong = true;
            ghichu.ngaycapnhat = DateTime.Now;
            ghichu.nguoicapnhat = UserUtils.getUser(context);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Sửa ghi chú thành công");
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
    }

    public void add(HttpContext context)
    {
        string msg = "";
        var dsdhId = context.Request.Form["c_danhsachdathang_id"];
        var gcstr = context.Request.Form["ghichu"];
        var loai = context.Request.Form["loai"];
        var dsdh = db.c_danhsachdathangs.Where(c => c.c_danhsachdathang_id == dsdhId).FirstOrDefault();
        if (dsdh == null)
        {
            msg = $@"Không tìm thấy ""danh sách đăth hàng""";
            goto EndEventHandler;
        }

        try
        {
            var dateNow = DateTime.Now;
            var exist = db.md_ghichuhdlhs.Where(s => s.lienket == dsdh.c_danhsachdathang_id & s.loai == loai & s.trangthai == CHUAGUI).FirstOrDefault();
            if (exist != null)
            {
                msg = $@"Hãy gửi các HDLH đang có trước khi tạo HDLH mới ({loai})";
                goto EndEventHandler;
            }

            var ghichu = new md_ghichuhdlh();
            ghichu.md_ghichuhdlh_id = Helper.getNewId();
            ghichu.lienket = dsdh.c_danhsachdathang_id;
            ghichu.loai = loai;
            ghichu.ghichu = gcstr;
            ghichu.trangthai = CHUAGUI;
            ghichu.hoatdong = true;
            ghichu.ngaytao = dateNow;
            ghichu.nguoitao = UserUtils.getUser(context);
            db.md_ghichuhdlhs.InsertOnSubmit(ghichu);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Thêm ghi chú thành công");
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
    }

    public void del(HttpContext context)
    {
        var ids = context.Request.Form["id"].removeAllSpaceOrTrimText(false).Split(',').ToList();
        var ghichus = db.md_ghichuhdlhs.Where(p => ids.Contains(p.md_ghichuhdlh_id)).ToList();
        var dsdhId = ghichus.Select(s => s.lienket).FirstOrDefault();
        var dsdh = db.c_danhsachdathangs.Where(c => c.c_danhsachdathang_id == dsdhId).FirstOrDefault();
        var msg = "";
        if (dsdh == null)
        {
            msg = $@"Không tìm thấy ""danh sách đăth hàng""";
            goto EndEventHandler;
        }

        var msgErrs = new List<string>();
        var links = new List<string>();
        foreach (var ghichu in ghichus)
        {
            if (ghichu.trangthai != CHUAGUI)
            {
                msgErrs.Add($@"""{ghichu.ghichu}"" đã được gửi NCC");
            }
            else
            {
                db.md_ghichuhdlhs.DeleteOnSubmit(ghichu);
            }
        }

        if (msgErrs.Count <= 0)
        {
            db.SubmitChanges();
        }
        else
            msg = string.Join(", ", msgErrs);

        EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Xóa ghi chú thành công");
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
            FROM md_ghichuhdlh tt WHERE 1=1 {filter} 
            and lienket ='{poId}'
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
            sidx = "tt.md_ghichuhdlh_id";
        }

        string strsql = $@"
            select P.* 
                from (
                    select 
                        tt.md_ghichuhdlh_id 
                        , tt.loai
                        , tt.ghichu
                        , tt.ngaytao
                        , tt.nguoitao
                        , tt.ngaycapnhat
                        , tt.nguoicapnhat
                        , tt.ngayxacnhan
                        , tt.nguoixacnhan
                        , tt.mota
                        , tt.trangthai
                        , ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
                    FROM 
                        md_ghichuhdlh tt 
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
