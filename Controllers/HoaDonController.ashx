<%@ WebHandler Language="C#" Class="HoaDonController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data.SqlClient;
using System.Data;
using System.Collections.Generic;

public class HoaDonController : IHttpHandler, IDisposable
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
            case "active":
                this.active(context);
                break;
            case "getoption":
                this.getSelectOption(context);
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

    public void getSelectOption(HttpContext context)
    {
        String sql = "select tiento as id, tiento as name from c_hoadontiento where hoatdong = 1 order by tiento";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToOptionNullFirst());
    }

    public void active(HttpContext context)
    {
        string msg = "";
        try
        {
            String id = context.Request.Form["id"];
            var hoadon = db.c_hoadons.Where(s => s.c_hoadon_id == id).FirstOrDefault();
            if (hoadon == null)
                msg = "Không tìm thấy đối tượng cần sửa";
            else
            {
                hoadon.md_trangthai_id = "HIEULUC";
                db.SubmitChanges();
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length <= 0)
            msg = string.Format("1{0}.", "Hiệu lực thành công");
        else
            msg = string.Format("0{0}.", msg);

        context.Response.Write(msg);
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        try
        {
            String id = context.Request.Form["id"];
            string sophieu = context.Request.Form["sophieu"].Trim();
            var hoadon = db.c_hoadons.Where(s => s.c_hoadon_id == id).FirstOrDefault();
            if (hoadon == null)
                msg = "Không tìm thấy đối tượng cần sửa";
            else if (db.c_hoadons.Where(s => s.c_hoadon_id != hoadon.c_hoadon_id & s.sophieu == sophieu).Count() > 0)
                msg = "Số phiếu đã tồn tại";
            else
            {
                hoadon.sophieu = sophieu;
                hoadon.tiento = context.Request.Form["tiento"];
                hoadon.thue_vat = decimal.Parse(context.Request.Form["thue_vat"]);
                hoadon.tienthue = Math.Round(hoadon.tuongduongVND.GetValueOrDefault(0) * hoadon.thue_vat.GetValueOrDefault(0) / 100, 0, MidpointRounding.AwayFromZero);
                hoadon.hinhthucthanhtoan = context.Request.Form["hinhthucthanhtoan"];
                hoadon.tygia = decimal.Parse(context.Request.Form["tygia"]);
                hoadon.tuongduongVND = hoadon.tuongduongUSD.GetValueOrDefault(0) * hoadon.tygia.GetValueOrDefault(0);
                hoadon.ma_khachhang = context.Request.Form["ma_khachhang"];
                hoadon.ten_khachhang = context.Request.Form["ten_khachhang"];
                hoadon.nhacungung = context.Request.Form["nhacungung"];
                hoadon.diachi_khachhang = context.Request.Form["diachi_khachhang"];
                hoadon.email_khachhang = context.Request.Form["email_khachhang"];
                hoadon.nganhang = context.Request.Form["nganhang"];
                hoadon.daidien_khachhang = context.Request.Form["daidien_khachhang"];
                hoadon.sotaikhoan_khachhang = context.Request.Form["sotaikhoan_khachhang"];
                hoadon.masothue_khachhang = context.Request.Form["masothue_khachhang"];
                hoadon.sotokhai_inv = context.Request.Form["sotokhai_inv"];
                hoadon.mota = context.Request.Form["mota"];
                db.SubmitChanges();
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length <= 0)
            jqGridHelper.Utils.writeResult(1, "Sửa thành công.");
        else
            jqGridHelper.Utils.writeResult(0, msg);
    }

    public void add(HttpContext context)
    {

    }

    public void del(HttpContext context)
    {
        string msg = "";
        try
        {
            String id = context.Request.Form["id"];
            var hoadon = db.c_hoadons.Where(s => s.c_hoadon_id == id).FirstOrDefault();
            if (hoadon == null)
                msg = "Không tìm thấy đối tượng cần xóa";
            else if (hoadon.md_trangthai_id != "SOANTHAO")
                msg = "Hóa đơn đã hiệu lực";
            else
            {
                var inv = db.c_packinginvoices.Where(s => s.c_packinginvoice_id == hoadon.c_packinginvoice_id).FirstOrDefault();
                if(inv != null)
                {
                    if(inv.md_trangthai_id != "SOANTHAO")
                        msg = "INV liên kết với hóa đơn đã hiệu lực";
                    else
                    {
                        var dongHDs = db.c_hoadon_cts.Where(s => s.c_hoadon_id == hoadon.c_hoadon_id).ToList();
                        var dongINVs = db.c_dongpklinvs.Where(s => s.c_packinginvoice_id == inv.c_packinginvoice_id).ToList();

                        db.c_hoadons.DeleteOnSubmit(hoadon);
                        db.c_hoadon_cts.DeleteAllOnSubmit(dongHDs);
                        db.c_packinginvoices.DeleteOnSubmit(inv);
                        db.c_dongpklinvs.DeleteAllOnSubmit(dongINVs);
                        db.SubmitChanges();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length <= 0)
            jqGridHelper.Utils.writeResult(1, "Xóa thành công.");
        else
            jqGridHelper.Utils.writeResult(0, msg);
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        bool isadmin = db.nhanviens.FirstOrDefault(p => p.manv.Equals(UserUtils.getUser(context))).isadmin.Value;

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        // phân quyền theo nhóm
        String manv = UserUtils.getUser(context);
        String strAccount = "";
        System.Collections.Generic.List<String> lstAccount = LinqUtils.GetUserListInGroup(manv);
        foreach (String item in lstAccount)
        {
            strAccount += String.Format(", '{0}'", item);
        }
        strAccount = String.Format("'{0}'{1}", manv, strAccount);


        String sqlCount = string.Format(@"
            SELECT 
                COUNT(1) AS count
			FROM 
                c_hoadon hd
                left join md_nganhang nh on nh.md_nganhang_id = hd.nganhang
                left join c_packinginvoice inv on inv.so_inv = hd.so_inv
                left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = hd.nhacungung
                left join md_doitackinhdoanh dtkd2 on dtkd2.ma_dtkd = hd.ma_khachhang
                left join md_quocgia qg on qg.md_quocgia_id = dtkd2.md_quocgia_id
            WHERE 
                1 = 1 {0}
            ", filter);

        sqlCount = String.Format(sqlCount, isadmin == true ? "" : " AND nx.nguoitao IN(" + strAccount + ") ");

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
            sidx = "hd.sophieu";
        }

        string strsql = string.Format(@"
            select 
                P.* 
            from (
                select 
                    hd.c_hoadon_id,
                    hd.md_trangthai_id,
                    hd.tiento,
                    hd.sophieu,
                    hd.so_inv,
                    dbo.LayChungTuDonHang(inv.c_packinginvoice_id) as sodh,
                    hd.nhacungung,
                    dtkd.ten_dtkd as ten_nhacungung,
                    hd.ma_khachhang,
                    hd.ten_khachhang,
                    hd.diachi_khachhang,
                    qg.ten_quocgia,
                    hd.email_khachhang,
                    hd.daidien_khachhang,
                    hd.sotaikhoan_khachhang,
                    hd.masothue_khachhang,
                    nh.ten_nganhang,
                    hd.hinhthucthanhtoan,
                    hd.thue_vat,
                    hd.tienthue,
                    hd.tygia,
                    hd.giamgia,
                    hd.philamhang,
                    hd.tuongduongUSD,
                    hd.ngayhoadon,
                    hd.mauso,
                    hd.kyhieu,
                    hd.sohoadon,
                    hd.ngayphathanh,
                    hd.ghichu,
                    hd.sotokhai_inv,
                    hd.ngaytao,
                    hd.nguoitao,
                    hd.ngaycapnhat,
                    hd.nguoicapnhat,
                    hd.mota,
                    hd.hoatdong,
                    ROW_NUMBER() OVER (ORDER BY {0} {1}) as RowNum
                FROM 
                    c_hoadon hd
                    left join md_nganhang nh on nh.md_nganhang_id = hd.nganhang
                    left join c_packinginvoice inv on inv.so_inv = hd.so_inv
                    left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = hd.nhacungung
                    left join md_doitackinhdoanh dtkd2 on dtkd2.ma_dtkd = hd.ma_khachhang
                    left join md_quocgia qg on qg.md_quocgia_id = dtkd2.md_quocgia_id
                WHERE 
                    1=1
                    {2}
            )P 
            where RowNum > @start AND RowNum < @end",
            sidx,
            sord,
            filter
        );

        strsql = String.Format(strsql, isadmin == true ? "" : "AND nx.nguoitao IN(" + strAccount + ") ");

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