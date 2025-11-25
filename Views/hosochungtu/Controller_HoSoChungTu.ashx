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

    public void ketthuc(HttpContext context)
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

            if (hsct.trangthai != Helper.HIEULUC)
            {
                msg = $@"Hồ sơ không ở trạng thái Hiệu Lực";
                goto EndEventHandler;
            }

            hsct.trangthai = Helper.KETTHUC;
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
            jqGridHelper.Utils.writeResult(1, "Kết thúc thành công");
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
                    donhang.trangthaict = "DAHIEULUC";
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
                        hsctk.trangthai = trangthai;
                    }
                }
            }

            hsct.trangthai = trangthai;
            hsct.ngaydieuchinh = ngaydieuchinh.ToNullableDate();
            hsct.ngaypass = ngaypass.ToNullableDate();
            hsct.ngaychuyenhoso = ngaychuyenhoso.ToNullableDate();
            hsct.nhanvienCT = nhanvienCT;
            hsct.ngayBookCont = ngayBookCont.ToNullableDate();
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
                , spd.POD
                , dh2.shipmenttime
                , DATEADD(day, -7, dh2.shipmenttime) as hangiaohang_po
                , dh.ngaydieuchinh
                , dh2.ngaypass
                , dh.ngaychuyenhoso
                , dh2.nguoilap
                , dh.nhanvienCT
                , (case when dh.loaicont = 'CONT20' then dh.slcont else 0 end) as cont20
                , (case when dh.loaicont = 'CONT40' then dh.slcont else 0 end) as cont40
                , (case when dh.loaicont = '40HC' then dh.slcont else 0 end) as cont40HC
                , (case when dh.loaicont = 'CONT45' then dh.slcont else 0 end) as cont45
                , (case when dh.loaicont = 'LE' then dh.slcont else 0 end) as contLCL
                , dh.dongghep
                , spd.Forwarder
                , dh.ngayBookCont
                , dh.bookingNo
                , dh.ngayETD
                , dh.ngayETA
                , dh.ngayBHXN
                , dh.ngayXuong
                , dh.ngayCutOff
                , dh.mota
                , dh.ngaytao
                , dh.nguoitao
                , dh.ngaycapnhat
                , dh.nguoicapnhat
                , dh.hoatdong
                , ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM c_donhangchungtu dh
                left join c_donhang dh2 on dh2.c_donhang_id = dh.c_donhang_id
                left join md_doitackinhdoanh kh on kh.md_doitackinhdoanh_id = dh2.md_doitackinhdoanh_id
                outer apply (select top 1 POD, Forwarder from c_donhang_spd where c_donhang_id = dh2.c_donhang_id order by ngaytao desc) spd
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
