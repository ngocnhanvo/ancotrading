<%@ WebHandler Language="C#" Class="Controller_YeuCauCapNhat" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_YeuCauCapNhat : IHttpHandler, IDisposable
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
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "kiemtraTTGui":
                this.kiemtraTTGui(context);
                break;
            case "guiphieu":
                this.guiphieu(context);
                break;
            case "hieuluc":
                this.hieuluc(context);
                break;
            default:
                switch (oper)
                {
                    case "loadDT":
                        this.loadDT(context);
                        break;
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

    public void loadDT(HttpContext context)
    {
        var id = context.Request.Form["id"];
        var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == id).FirstOrDefault();
        if(pyc == null)
        {
            throw new Exception("Không tìm thấy phiếu đã chọn");
        }

        var tableNameMapping = new Dictionary<string, string>
        {
            { "md_chungloai", "Chủng loại" },
            { "md_kieudang", "Kiểu dáng" },
            { "md_chucnang", "Chức năng" },
            { "md_nhomnangluc", "Nhóm năng lực" },
            { "md_hscode", "HSCode" },
            { "md_detai", "Đề tài" },
            { "md_mausac", "Màu sắc" },
            { "md_banggia", "Bảng giá" },
            { "md_phienbangia", "Phiên bản giá" },
            { "md_giasanpham", "Giá sản phẩm" },
            { "md_sanpham", "Sản phẩm" },
            { "md_donggoi", "Đóng gói" },
            { "md_donggoisanpham", "Đóng gói SP" }
        };

        var tables = db.md_phieuthongtinsanpham_logs
            .Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id)
            .ToList();
        var result = tables.Select(s => new
        {
            table = s.table,
            ten = tableNameMapping.ContainsKey(s.table ?? "") ? tableNameMapping[s.table ?? ""] : ""
        }).Where(s => !string.IsNullOrWhiteSpace(s.ten)).Distinct().OrderBy(s => s.ten).ToList();
        context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(result));
    }

    public void kiemtraTTGui(HttpContext context)
    {
        string msg = "";
        var pycs = db.md_phieuthongtinsanphams.Where(s => s.trangthai2 != Helper.DAHIEULUC).ToList();
        var groups = pycs.GroupBy(s => s.md_doitackinhdoanh_id).Select(s => s).ToList();

        foreach (var group in groups)
        {
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == group.Key).FirstOrDefault();
            string link = dtkd == null ? "" : dtkd.api_xuongsx;
            if (string.IsNullOrWhiteSpace(link)) continue;
            link = $@"{link}?oper=kiemtraTT";
            try
            {
                var lst = group.Select(s => s).ToList();
                var item = new Dictionary<string, object>();
                item["lst"] = string.Join(",", lst.Select(s => s.md_phieuthongtinsanpham_id).ToList());
                string result = Extension.GetModule(link, item);
                var rs = Newtonsoft.Json.JsonConvert.DeserializeObject<dynamic>(result);
                if (rs == null)
                {
                    continue;
                }
                else if (rs.ok == false)
                {
                    continue;
                }
                else
                {
                    string rs_msg = rs.msg;
                    List<md_phieuthongtinsanpham> phieus = Newtonsoft.Json.JsonConvert.DeserializeObject<List<md_phieuthongtinsanpham>>(rs_msg);
                    bool updated = false;
                    foreach (var node in lst)
                    {
                        var exist = phieus.Where(s => s.md_phieuthongtinsanpham_id == node.md_phieuthongtinsanpham_id).FirstOrDefault();
                        if (exist == null)
                        {
                            node.trangthai1 = Helper.SOANTHAO;
                            node.trangthai2 = Helper.TUCHOI;
                            node.ngaynhan = null;
                            updated = true;
                        }
                        else if (node.trangthai2 != exist.trangthai1)
                        {
                            if (exist.trangthai1 == Helper.DANHAN)
                            {
                                node.trangthai2 = exist.trangthai1;
                            }
                            else if (exist.trangthai1 == Helper.HIEULUC)
                            {
                                node.trangthai2 = Helper.DAHIEULUC;
                            }
                            node.ngaynhan = exist.ngaynhan;
                            node.ngayapdung = exist.ngayapdung;
                            updated = true;
                        }
                    }

                    if (updated)
                        db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                msg = ex.ToString();
            }
        }

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Kiểm tra trạng thái gửi thành công");

        context.Response.Write(msg);
    }

    public void guiphieu(HttpContext context, string id = "", md_phieuthongtinsanpham pyc = null)
    {
        string msg = "";
        String manv = UserUtils.getUser(context);
        var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
        md_smtp smtp = db.md_smtps.FirstOrDefault(p => p.macdinh.Equals(true));
        if (nv != null)
        {
            if (!string.IsNullOrWhiteSpace(nv.smtp))
                smtp = db.md_smtps.FirstOrDefault(p => p.md_smtp_id.Equals(nv.smtp));
        }

        if (string.IsNullOrEmpty(id))
            id = context.Request.Form["id"];

        if (pyc == null)
            pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == id).FirstOrDefault();

        if (pyc == null)
        {
            msg = "Không tìm thấy phiếu";
            goto EndEventHandler;
        }

        if (pyc.trangthai1 != Helper.HIEULUC)
        {
            msg = "Phiếu không ở trạng thái Hiệu Lực";
            goto EndEventHandler;
        }

        if (!new string[] { Helper.CHUAGUI, Helper.TUCHOI }.Contains(pyc.trangthai2))
        {
            msg = "Phiếu đã gửi trước đó";
            goto EndEventHandler;
        }

        var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == pyc.md_doitackinhdoanh_id).FirstOrDefault();
        string link = dtkd == null ? "" : dtkd.api_xuongsx;
        if (string.IsNullOrWhiteSpace(link))
        {
            msg = "không tìm thấy đường dẫn kết nối với NCC";
            goto EndEventHandler;
        }

        var item = new Dictionary<string, object>();
        item["pyc"] = pyc;
        var dhs = db.md_phieuthongtinsanpham_sanphams.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
        foreach (var dh in dhs)
            dh.ma_sanpham = db.md_sanphams.Where(s => s.md_sanpham_id == dh.md_sanpham_id).Select(s => s.ma_sanpham).FirstOrDefault();
        item["dhs"] = dhs;
        var logs = db.md_phieuthongtinsanpham_logs.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
        item["logs"] = logs;

        try
        {
            link = $@"{link}?oper=guiphieu";
            string result = Extension.GetModule(link, item);
            var rs = Newtonsoft.Json.JsonConvert.DeserializeObject<dynamic>(result);
            if (rs == null)
            {
                msg = "Không kết nối được server";
            }
            else if (rs.ok == false)
            {
                msg = rs.msg;
            }
            else
            {
                pyc.ngaygui = DateTime.Now;
                pyc.trangthai2 = Helper.DAGUI;
                db.SubmitChanges();

                var mail = new GoogleMail();
                mail.Email = nv.email;
                mail.Password = nv.email_pass;
                mail.Smtp = smtp.smtpserver;
                mail.Port = smtp.port.Value;
                mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);
                string title = $@"[ANCOTRADING] {pyc.tieude}",
                        body = $@"{pyc.noidung}<br>";
                body += "Truy cập vào hệ thống để xem chi tiết thay đổi";
                mail.Send(
                    nv.email
                    , dtkd.email_nhandulieugoc
                    , nv.email_cc
                    , title
                    , body
                    , ""
                );
            }
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

    EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Gửi phiếu thành công");

        context.Response.Write(msg);
    }

    public void hieuluc(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"].removeAllSpaceOrTrimText(true);
        try
        {
            var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == id).FirstOrDefault();
            if (pyc == null)
            {
                msg = $@"Không tìm thấy phiếu yêu cầu";
                goto EndEventHandler;
            }

            if (pyc.trangthai1 != Helper.SOANTHAO)
            {
                msg = $@"Phiếu không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var dhs = db.md_phieuthongtinsanpham_sanphams.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
            var logs = db.md_phieuthongtinsanpham_logs.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
            if (dhs.Count <= 0 & logs.Count <= 0)
            {
                msg = $@"Phiếu chưa có tạo thông tin cần gửi để cập nhật";
                goto EndEventHandler;
            }

            pyc.trangthai1 = Helper.HIEULUC;
            pyc.trangthai2 = Helper.CHUAGUI;
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
            jqGridHelper.Utils.writeResult(1, "Hiệu lực thành công");
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"].removeAllSpaceOrTrimText(true);
        string tieude = context.Request.Form["tieude"].removeAllSpaceOrTrimText(true);
        string noidung = context.Request.Form["noidung"].removeAllSpaceOrTrimText(true);
        string mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
        string dtkdId = context.Request.Form["dtkd_id"].removeAllSpaceOrTrimText(true);
        try
        {
            var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == id).FirstOrDefault();
            if (pyc == null)
            {
                msg = $@"Không tìm thấy phiếu yêu cầu";
                goto EndEventHandler;
            }

            if (pyc.trangthai1 != Helper.SOANTHAO)
            {
                msg = $@"Phiếu không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dtkdId).FirstOrDefault();
            if (dtkd == null)
            {
                msg = $@"Không tìm thấy ""nhà cung cấp"" đã chọn";
                goto EndEventHandler;
            }

            if (dtkd.md_doitackinhdoanh_id != pyc.md_doitackinhdoanh_id)
            {
                var dhs = db.md_phieuthongtinsanpham_sanphams.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
                if (dhs.Count > 0)
                {
                    msg = $@"Không thể đổi nhà cung cấp khi đã có dòng hàng";
                    goto EndEventHandler;
                }
            }

            //pyc.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id;
            pyc.tieude = tieude;
            pyc.noidung = noidung;
            pyc.mota = mota;
            pyc.ngaytao = DateTime.Now;
            pyc.ngaycapnhat = DateTime.Now;
            pyc.nguoitao = UserUtils.getUser(context);
            pyc.nguoicapnhat = UserUtils.getUser(context);
            pyc.hoatdong = true;
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
            jqGridHelper.Utils.writeResult(1, "Sửa thành công");
    }

    public void add(HttpContext context)
    {
        string msg = "";
        string tieude = context.Request.Form["tieude"].removeAllSpaceOrTrimText(true);
        string noidung = context.Request.Form["noidung"].removeAllSpaceOrTrimText(true);
        string mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
        string dtkdId = context.Request.Form["dtkd_id"].removeAllSpaceOrTrimText(true);
        string idnew = Helper.getNewId();
        try
        {
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dtkdId).FirstOrDefault();
            if (dtkd == null)
            {
                msg = $@"Không tìm thấy ""nhà cung cấp"" đã chọn";
                goto EndEventHandler;
            }

            var pyc = new md_phieuthongtinsanpham();
            pyc.md_phieuthongtinsanpham_id = idnew;
            pyc.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id;
            pyc.trangthai1 = Helper.SOANTHAO;
            pyc.tieude = tieude;
            pyc.noidung = noidung;
            pyc.ngaylap = DateTime.Now;
            pyc.mota = mota;
            pyc.ngaytao = DateTime.Now;
            pyc.ngaycapnhat = DateTime.Now;
            pyc.nguoitao = UserUtils.getUser(context);
            pyc.nguoicapnhat = UserUtils.getUser(context);
            pyc.hoatdong = true;
            db.md_phieuthongtinsanphams.InsertOnSubmit(pyc);
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
            jqGridHelper.Utils.writeResult(1, $"Thêm thành công#{idnew}");
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"].removeAllSpaceOrTrimText(true);
        try
        {
            var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == id).FirstOrDefault();
            if (pyc == null)
            {
                msg = $@"Không tìm thấy phiếu yêu cầu";
                goto EndEventHandler;
            }

            if (pyc.trangthai1 != Helper.SOANTHAO)
            {
                msg = $@"Phiếu không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == pyc.md_doitackinhdoanh_id).Select(s => s.ma_dtkd).FirstOrDefault();

            var dhs = db.md_phieuthongtinsanpham_sanphams.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
            db.md_phieuthongtinsanpham_sanphams.DeleteAllOnSubmit(dhs);
            var dhlogs = db.md_phieuthongtinsanpham_logs.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
            var logids = dhlogs.Select(s => s.ad_log_id).Distinct().ToList();
            int batchSize = 1000; // Giới hạn 1,000 item mỗi đợt để an toàn dưới ngưỡng 2,100 tham số
            for (int i = 0; i < logids.Count; i += batchSize)
            {
                var batchIds = logids.Skip(i).Take(batchSize).ToList();
                var logs = db.ad_logs.Where(s => batchIds.Contains(s.ad_log_id)).ToList();

                foreach (var log in logs)
                {
                    if (dtkd == "ANCO1")
                    {
                        log.anco1_check = false;
                    }
                    else if (dtkd == "ANHIEPLUC")
                    {
                        log.anhiepluc_check = false;
                    }
                }
            }
            db.md_phieuthongtinsanpham_logs.DeleteAllOnSubmit(dhlogs);
            db.md_phieuthongtinsanphams.DeleteOnSubmit(pyc);
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

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM md_phieuthongtinsanpham tt
            left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = tt.md_doitackinhdoanh_id
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
            sidx = "tt.ngaylap";
            sord = "desc";
        }

        string strsql = $@"
        select * from(
            select 
                tt.md_phieuthongtinsanpham_id, 
                tt.trangthai1,
                tt.trangthai2,
                tt.tieude,
                tt.noidung,
                dtkd.ma_dtkd,
	            tt.ngaylap,
	            tt.ngaygui,
	            tt.ngaynhan,
	            tt.ngayapdung,
                tt.ngaytao, 
                tt.nguoitao, 
                tt.ngaycapnhat, 
                tt.nguoicapnhat, 
                tt.mota,
                tt.hoatdong,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM md_phieuthongtinsanpham tt
                left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = tt.md_doitackinhdoanh_id
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
