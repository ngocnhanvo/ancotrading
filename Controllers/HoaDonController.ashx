<%@ WebHandler Language="C#" Class="HoaDonController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data.SqlClient;
using System.Data;
using System.Collections.Generic;

public class HoaDonController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
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
        String sql = "select c_nhapxuat_id, sophieu from c_nhapxuat where hoatdong = 1 AND md_loaichungtu_id = N'XK'";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }

    public void edit(HttpContext context)
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
                var cthds = db.c_hoadon_cts.Where(s => s.c_hoadon_id == hoadon.c_hoadon_id).ToList();
                var tongTien = cthds.Sum(s => s.dongia * s.soluong);
                hoadon.md_trangthai_id = context.Request.Form["md_trangthai_id"];
                hoadon.tiento = context.Request.Form["tiento"];
                hoadon.thue_vat = decimal.Parse(context.Request.Form["thue_vat"]);
                hoadon.tienthue = Math.Round(tongTien.GetValueOrDefault(0) * hoadon.thue_vat.GetValueOrDefault(0) / 100, 0, MidpointRounding.AwayFromZero);
                hoadon.hinhthucthanhtoan = context.Request.Form["hinhthucthanhtoan"];
                hoadon.tygia = decimal.Parse(context.Request.Form["tygia"]);
                hoadon.ten_khachhang = context.Request.Form["ten_khachhang"];
                hoadon.diachi_khachhang = context.Request.Form["diachi_khachhang"];
                hoadon.email_khachhang = context.Request.Form["email_khachhang"];
                hoadon.sotokhai_inv = context.Request.Form["sotokhai_inv"];
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
            else if (hoadon.md_trangthai_id == "HIEULUC")
                msg = "Hóa đơn đã hiệu lực";
            else
            {
                var inv = db.c_packinginvoices.Where(s => s.c_packinginvoice_id == hoadon.c_packinginvoice_id).FirstOrDefault();
                if(inv != null)
                {
                    if(inv.md_trangthai_id == "HIEULUC")
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
            SELECT COUNT(1) AS count
			FROM c_hoadon hd
            WHERE 1 = 1 {0}
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
            sidx = "nx.c_nhapxuat_id";
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
                    hd.ma_khachhang,
                    hd.ten_khachhang,
                    hd.diachi_khachhang,
                    hd.email_khachhang,
                    hd.hinhthucthanhtoan,
                    hd.thue_vat,
                    hd.tienthue,
                    hd.tygia,
                    hd.phicong,
                    hd.phitru,
                    hd.tuongduongUSD,
                    hd.ngayhoadon,
                    hd.mauso,
                    hd.kyhieu,
                    hd.sohoadon,
                    hd.ngayphathanh,
                    hd.ghichu,
                    hd.so_inv,
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
                    var date = (DateTime?)row[column.ColumnName];
                    if(date == null)
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    else
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", date.Value.ToString("dd/MM/yyyy"));
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