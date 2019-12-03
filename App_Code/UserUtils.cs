using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;

public static class UserUtils
{
    public static String getUser(HttpContext context)
    {
        String ur = context.User.Identity.Name;
        return ur;
    }

    //Mail KCS
    public static string mailKCS = "quality@ancopottery.com";
    //Mail Ke Toan NCU
    public static string mailKeToanNCU = "ketoanTEST@ancometal.com";

    public static decimal get_gianhap(HttpContext context, string ma_dtkd_select, decimal gia_fob, decimal discount, decimal discount_vinhgia)
    {
        //Tinh % theo nha cung ung

        int getptr = 0;
        //lay % gia mua
        if (gia_fob == -1 & discount == -1 & discount_vinhgia == -1)
            getptr = 1;
        //lay ty gia mua
        else if (gia_fob == -2 & discount == -2 & discount_vinhgia == -2)
            getptr = 2;

        decimal gianhap = -1;
        string[] arr1 = new string[] { "ANBINH", "ANCO1", "ANCO2" };
        //Neu doi tac la VINHGIA
        if (("VINHGIA").Contains(ma_dtkd_select))
        {
            decimal tygia = /*23300*/1;
            decimal discountVNN = decimal.Parse("0.82");
            decimal gianhaptam = gia_fob - (gia_fob * discount_vinhgia) / 100;
            gianhap = gianhaptam * discountVNN;
            gianhap = gianhap * tygia;

            if (getptr == 1)
            {
                gianhap = 1;
                gianhap = gianhap * discountVNN;
            }
            else if (getptr == 2)
            {
                gianhap = tygia;
            }
            else
            {
                if (tygia > 1)
                {
                    gianhap = jqGridHelper.Utils.Round3(gianhap, -2);
                }
            }
        }
        //Neu doi tac la ANBINH, ANCO1, ANCO2 tỷ giá mua theo ngay tạo
        else if (arr1.Contains(ma_dtkd_select))
        {
            decimal tygia = 23000;
            decimal discountVNN = decimal.Parse("0.80");
            decimal gianhaptam = gia_fob - (gia_fob * discount) / 100;
            gianhap = gianhaptam * discountVNN;
            gianhap = gianhap * tygia;
            if (getptr == 1)
            {
                gianhap = 1;
                gianhap = gianhap * discountVNN;
            }
            else if (getptr == 2)
            {
                //var db = new LinqDBDataContext();
                //var tgm = db.md_tygiamuas.Where(s => s.ngayapdung <= DateTime.Now & s.ngayketthuc >= DateTime.Now).FirstOrDefault();
                //tygia = (decimal)tgm.nhan_voi.Value;
                gianhap = tygia;
            }
            else
            {
                if (ma_dtkd_select == "ANCO1")
                {
                    if (tygia > 1)
                    {
                        gianhap = jqGridHelper.Utils.Round3(gianhap, -2);
                    }
                }
                else
                {
                    gianhap = -1;
                }
            }
        }
        //Neu doi tac la TITAN
        else if (ma_dtkd_select == "TITAN")
        {
            decimal tygia = 22200;
            decimal discountVNN = decimal.Parse("0.95");
            decimal gianhaptam = gia_fob - (gia_fob * discount) / 100;
            gianhap = gianhaptam * discountVNN;
            gianhap = gianhap * tygia;
            if (getptr == 1)
            {
                gianhap = 1;
                gianhap = gianhap * discountVNN;
            }
            else if (getptr == 2)
            {
                gianhap = tygia;
            }
            else
            {
                if (tygia > 1)
                {
                    gianhap = jqGridHelper.Utils.Round3(gianhap, -2);
                }
            }
        }
        return gianhap;
    }

    public static Dictionary<string, object> get_giasanpham(HttpContext context, string c_baogia_id, string md_sanpham_id, LinqDBDataContext db)
    {
        var itemJS = new Dictionary<string, object>();
        itemJS["gia"] = "-1";
        itemJS["barcode"] = "";

        var baogia = db.c_baogias.Where(d => d.c_baogia_id.Equals(c_baogia_id)).
            Select(s => new { s.md_doitackinhdoanh_id, s.phienbangiacu, s.chkPBGCu, s.gia_db, ngaybaogia = s.ngaybaogia }).FirstOrDefault();
        if (baogia == null)
        {
            baogia = db.c_donhangs.Where(d => d.c_donhang_id.Equals(c_baogia_id)).
            Select(s => new { s.md_doitackinhdoanh_id, s.phienbangiacu, s.chkPBGCu, s.gia_db, ngaybaogia = s.ngaylap }).FirstOrDefault(); ;
        }
        var sp = db.md_sanphams.FirstOrDefault(s => s.md_sanpham_id.Equals(md_sanpham_id));
        if (baogia != null)
        {
            if (sp != null)
            {
                //Lấy theo phiên bảng giá cũ
                if (!String.IsNullOrEmpty(baogia.phienbangiacu) & baogia.chkPBGCu == true)
                {
                    md_phienbangia pbg = db.md_phienbangias.Where(s => s.md_phienbangia_id == baogia.phienbangiacu).FirstOrDefault();
                    md_giasanpham gsp = db.md_giasanphams.Where(s => s.md_phienbangia_id == pbg.md_phienbangia_id & s.md_sanpham_id == md_sanpham_id).FirstOrDefault();
                    decimal gia_sp = -1;
                    if (gsp != null)
                    {
                        gia_sp = gsp.gia.GetValueOrDefault(-1);
                    }
                    itemJS["gia"] = gia_sp + "";
                    itemJS["barcode"] = "";
                }
                //Lấy theo bảng giá đặc biệt
                else if (baogia.gia_db == true)
                {
                    string md_doitackinhdoanh_id = baogia.md_doitackinhdoanh_id;
                    var items = mdbc.GetDataFromProcedure("getGiaMuaSp_Dacbiet", "@md_sanpham_id", md_sanpham_id, "@md_doitackinhdoanh_id", md_doitackinhdoanh_id, "@ngaytinhgia", baogia.ngaybaogia);
                    itemJS["gia"] = items.Rows[0]["gia"].ToString();
                    itemJS["barcode"] = items.Rows[0]["barcode"].ToString();
                }
                //Lấy theo giá chuẩn
                else
                {
                    decimal gia_sp = (decimal)mdbc.ExecuteScalarProcedure("getGiaMuaSp", "@md_sanpham_id", md_sanpham_id, "@md_doitackinhdoanh_id", baogia.md_doitackinhdoanh_id, "@loai_bg", true, "@ngaytinhgia", baogia.ngaybaogia);
                    itemJS["gia"] = gia_sp + "";
                    itemJS["barcode"] = "";
                }
            }
        }

        return itemJS;
    }

    public static string get_sapxep_qodetail(HttpContext context, string c_baogia_id, string spstr, string default_od, LinqDBDataContext db)
    {
        string orderby = "";
        bool ghepbo = false;
        c_baogia bg = db.c_baogias.FirstOrDefault(s => s.c_baogia_id == c_baogia_id);
        if (bg != null)
        {
            if (bg.ghepbo == true)
            {
                ghepbo = true;
            }
        }

        if (ghepbo == true)
        {
            orderby = "order by substring(" + spstr + ",0, 8) asc, substring(" + spstr + ",13, 2) asc, substring(" + spstr + ",10, 2) asc";
        }
        else
        {
            orderby = default_od;
        }
        return orderby;
    }

    public static string[] get_DQ_DG_ALL(HttpContext context, string md_donggoi_id, string md_doitackinhdoanh_id, string md_sanpham_id, LinqDBDataContext db)
    {
        string[] arr_dqdg = new string[2];
        md_donggoi donggoi = db.md_donggois.FirstOrDefault(p => p.md_donggoi_id.Equals(md_donggoi_id));
        //kiem tra hang hoa doc quyen
        int count_dq = (from hdq in db.md_hanghoadocquyens
                        where !hdq.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id) && hdq.md_sanpham_id.Equals(md_sanpham_id)
                        select new { hdq.md_hanghoadocquyen_id }).Count();
        int count_dqdt = (from hdq in db.md_hanghoadocquyens
                          where hdq.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id) && hdq.md_sanpham_id.Equals(md_sanpham_id)
                          select new { hdq.md_hanghoadocquyen_id }).Count();

        if (count_dq > 0 && count_dqdt == 0 && donggoi.doigia_donggoi == true)
        {
            arr_dqdg[0] = "DGDGDQ";
            arr_dqdg[1] = "DGDG & DQ";
        }
        else if (count_dq > 0 && count_dqdt == 0)
        {
            arr_dqdg[0] = "DQ";
            arr_dqdg[1] = "DGDG & DQ";
        }
        else if (donggoi.doigia_donggoi == true)
        {
            arr_dqdg[0] = "DGDG";
            arr_dqdg[1] = "";
        }
        else
        {
            arr_dqdg[0] = "BT";
            arr_dqdg[1] = "";
        }
        return arr_dqdg;
    }

    public static string checkHieuLucProduct(HttpContext context, md_sanpham sp, LinqDBDataContext db)
    {
        string msg = "";
        int countDG = (from a in db.md_sanphams
                       join b in db.md_donggoisanphams on a.md_sanpham_id equals b.md_sanpham_id
                       join c in db.md_donggois on b.md_donggoi_id equals c.md_donggoi_id
                       where a.md_sanpham_id == sp.md_sanpham_id
                       select new { a.md_sanpham_id }).Count();

        int countGia = (from a in db.md_banggias
                        join b in db.md_phienbangias on a.md_banggia_id equals b.md_banggia_id
                        join c in db.md_giasanphams on b.md_phienbangia_id equals c.md_phienbangia_id
                        where c.md_sanpham_id == sp.md_sanpham_id
                        select new { c.md_sanpham_id }).Count();

        var HinhAnh = System.IO.File.Exists(
            context.Server.MapPath(string.Format(@"~/images/products/fullsize/{0}.jpg", sp.ma_sanpham.Contains("F") ? sp.ma_sanpham.Substring(0, 11) : sp.ma_sanpham.Substring(0, 8)))
            );

        if (countDG <= 0)
            msg += "Thiếu đóng gói,";
        if (countGia <= 0)
            msg += "Thiếu giá,";
        if (HinhAnh == false)
            msg += "Thiếu hình ảnh,";

        if (!string.IsNullOrEmpty(msg))
            msg = msg.Substring(0, msg.Length - 1);
        return msg;
    }

    public static void SetFormValue(string key, string value)
    {
        var collection = System.Web.HttpContext.Current.Request.Form;

        // Get the "IsReadOnly" protected instance property.
        var propInfo = collection.GetType().GetProperty("IsReadOnly", BindingFlags.Instance | BindingFlags.NonPublic);

        // Mark the collection as NOT "IsReadOnly"
        propInfo.SetValue(collection, false, new object[] { });

        // Change the value of the key.
        collection[key] = value;

        // Mark the collection back as "IsReadOnly"     
        propInfo.SetValue(collection, true, new object[] { });
    }
}
