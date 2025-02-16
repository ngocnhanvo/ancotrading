using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for Objects
/// </summary>
public class ExcuteSignalR
{

    public ExcuteSignalR()
    {

    }

    public string createColorRefer(LinqDBDataContext db, List<md_sanpham> sps, string baogiaId, string manv = "")
    {
        string msg = "";
        var maThos = sps.Select(s => s.ma_sanpham.Substring(0, 12)).Distinct().ToList();
        var filters = sps.Select(s => s.ma_sanpham.Substring(0, 9) + s.ma_sanpham.Substring(12, 2)).Distinct().ToList();
        var colorRefs = db.md_color_references.Where(s => s.c_baogia_id == baogiaId).ToList();
        var colorRefsAdd = new List<md_color_reference>();

        //db.md_color_references.DeleteAllOnSubmit(db.md_color_references.Where(s => s.c_baogia_id == baogiaId));
        var spsMau = db.md_sanphams.Where(s => s.trangthai == "DHD" & (s.laMacon ?? false) == false & maThos.Contains(s.ma_sanpham.Substring(0, 12))).OrderBy(s => s.ma_sanpham).ToList();
        foreach (var spMau in spsMau)
        {
            string cl = spMau.ma_sanpham.Substring(0, 2), dt = spMau.ma_sanpham.Substring(6, 2), ms = spMau.ma_sanpham.Substring(12, 2);
            var filter = spMau.ma_sanpham.Substring(0, 9) + ms;
            if (!filters.Contains(filter))
            {
                var colorRef = colorRefs.Where(s => s.c_baogia_id == baogiaId & s.filter == filter).FirstOrDefault();
                if (colorRef == null)
                {
                    var mausac = db.md_mausacs.Where(s => s.code_cl == cl & s.code_dt == dt & s.code_mau == ms).FirstOrDefault();
                    string mau = mausac == null ? "" : mausac.ta_ngan;
                    colorRef = new md_color_reference();
                    colorRef.md_color_reference_id = Helper.getNewId();
                    colorRef.c_baogia_id = baogiaId;
                    colorRef.filter = filter;
                    colorRef.url = $"{filter}.jpg";
                    colorRef.mau = mau;
                    colorRef.nguoitao = manv;
                    colorRef.nguoicapnhat = manv;
                    colorRef.ngaytao = DateTime.Now;
                    colorRef.ngaycapnhat = DateTime.Now;
                    colorRef.mota = "";
                    colorRef.hoatdong = false;
                    colorRefsAdd.Add(colorRef);
                }
            }
        }

        if (colorRefsAdd.Count > 0)
        {
            db.md_color_references.InsertAllOnSubmit(colorRefsAdd);
            db.SubmitChanges();
        }

        return msg;
    }

    public md_doitackinhdoanh createDTKD(LinqDBDataContext db, string ma_dtkd, string ten_dtkd, string email, string phone, string address, string nguoilienhe, string note = "")
    {
        md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(s => s.ma_dtkd == ma_dtkd);
        string md_loaidtkd_id = "";
        md_loaidtkd ldt = db.md_loaidtkds.FirstOrDefault(s => s.ma_loaidtkd == "KH");
        if (ldt != null) { md_loaidtkd_id = ldt.md_loaidtkd_id; }
        if (dtkd == null)
        {
            dtkd = new md_doitackinhdoanh
            {
                md_doitackinhdoanh_id = ImportUtils.getNEWID(),
                ma_dtkd = ma_dtkd,
                ten_dtkd = ten_dtkd,
                email = email,
                tel = phone,
                diachi = address,
                daidien = nguoilienhe,
                md_loaidtkd_id = md_loaidtkd_id,
                isncc = false,
                hoatdong = true,
                ngaytao = DateTime.Now,
                ngaycapnhat = DateTime.Now,
                mota = note
            };
            db.md_doitackinhdoanhs.InsertOnSubmit(dtkd);
            db.SubmitChanges();
        }

        return dtkd;
    }

    public void add_ctdonhang(string ma_sanpham, string soluong, int maxOrder, decimal gia_fob, string c_donhang_id,
    string tk, string md_doitackinhdoanh_id, LinqDBDataContext db, params object[] args)
    {
        md_sanpham pro = db.md_sanphams.FirstOrDefault(s => s.ma_sanpham == ma_sanpham);
        if (pro != null)
        {
            md_nhacungungmacdinh ncumd = db.md_nhacungungmacdinhs.FirstOrDefault(s => s.md_sanpham_id == pro.md_sanpham_id & s.macdinh == true);
            if (gia_fob < 0)
            {
                var itemJS = UserUtils.get_giasanpham(null, c_donhang_id, pro.md_sanpham_id, db);
                try { gia_fob = decimal.Parse(itemJS["gia"].ToString()); } catch { gia_fob = 0; }
            }
            String dvt_inner = "", dvt_outer = "", ghichu_vachngan = "", trangthai = "BT", md_donggoi_id = "";
            bool? doigia_donggoi = false;
            System.Nullable<decimal> sl_inner = 0, soluonggoi_ctn = 0, sl_outer = 0, l1 = 0, w1 = 0, h1 = 0, l2_mix = 0, w2_mix = 0, h2_mix = 0, v2 = 0, vd = 0, vn = 0, vl = 0;
            md_donggoisanpham dgsp = db.md_donggoisanphams.FirstOrDefault(s => s.md_sanpham_id == pro.md_sanpham_id & s.macdinh == true);
            if (dgsp != null)
            {
                md_donggoi dg_sel = db.md_donggois.FirstOrDefault(s => s.md_donggoi_id == dgsp.md_donggoi_id);
                if (dg_sel != null)
                {
                    dvt_inner = dg_sel.dvt_inner;
                    dvt_outer = dg_sel.dvt_outer;
                    ghichu_vachngan = dg_sel.ghichu_vachngan;

                    sl_inner = dg_sel.sl_inner;
                    soluonggoi_ctn = dg_sel.soluonggoi_ctn;
                    sl_outer = dg_sel.sl_outer;
                    l1 = dg_sel.l1;
                    w1 = dg_sel.w1;
                    h1 = dg_sel.h1;
                    l2_mix = dg_sel.l2_mix;
                    w2_mix = dg_sel.w2_mix;
                    h2_mix = dg_sel.h2_mix;
                    v2 = dg_sel.v2;
                    vd = dg_sel.vd;
                    vn = dg_sel.vn;
                    vl = dg_sel.vl;
                    md_donggoi_id = dg_sel.md_donggoi_id;
                    doigia_donggoi = dg_sel.doigia_donggoi;
                }
            }

            trangthai = UserUtils.get_DQ_DG_ALL(null, dgsp.md_donggoi_id, md_doitackinhdoanh_id, pro.md_sanpham_id, db)[0];
            c_dongdonhangqr mnu = new c_dongdonhangqr();
            mnu.c_dongdonhangqr_id = Guid.NewGuid().ToString().Replace("-", "");
            mnu.c_donhangqr_id = c_donhang_id;
            mnu.md_sanpham_id = pro.md_sanpham_id;
            mnu.ma_sanpham_khach = "";
            mnu.sothutu = maxOrder + 10;
            mnu.giafob = gia_fob;
            mnu.soluong = decimal.Parse(soluong);
            mnu.soluong_conlai = decimal.Parse(soluong);
            mnu.soluong_daxuat = 0;
            mnu.soluong_dathang = 0;

            mnu.mota_tiengviet = pro.mota_tiengviet;
            mnu.mota_tienganh = pro.mota_tienganh;
            // mnu.nhacungungid = ncu_line;
            mnu.nhacungungid = ncumd.md_doitackinhdoanh_id;

            // Thành phần đóng gói
            mnu.md_donggoi_id = md_donggoi_id;
            mnu.sl_inner = sl_inner;
            mnu.l1 = l1;
            mnu.w1 = w1;
            mnu.h1 = h1;
            mnu.sl_outer = sl_outer;
            mnu.l2 = l2_mix;
            mnu.w2 = w2_mix;
            mnu.h2 = h2_mix;
            mnu.v2 = v2;
            mnu.vd = vd;
            mnu.vn = vn;
            mnu.vl = vl;
            mnu.ghichu_vachngan = ghichu_vachngan;
            mnu.sl_cont = soluonggoi_ctn;
            mnu.ghichu = "";

            //kiem tra hang hoa doc quyen
            int count_dq = (from hdq in db.md_hanghoadocquyens
                            where !hdq.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id) && hdq.md_sanpham_id.Equals(pro.md_sanpham_id)
                            select new { hdq.md_hanghoadocquyen_id }).Count();

            int count_dqdt = (from hdq in db.md_hanghoadocquyens
                              where hdq.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id) && hdq.md_sanpham_id.Equals(pro.md_sanpham_id)
                              select new { hdq.md_hanghoadocquyen_id }).Count();

            if (count_dq > 0 && count_dqdt == 0 && doigia_donggoi == true)
            {
                mnu.trangthai = "DGDGDQ";
            }
            else if (count_dq > 0 && count_dqdt == 0)
            {
                mnu.trangthai = "DQ";
            }
            else if (doigia_donggoi == true)
            {
                mnu.trangthai = "DGDG";
            }
            else
            {
                mnu.trangthai = "BT";
            }

            // Thông tin chung
            mnu.mota = "";
            mnu.hoatdong = true;
            mnu.nguoitao = tk;
            mnu.nguoicapnhat = tk;
            mnu.ngaytao = DateTime.Now;
            mnu.ngaycapnhat = DateTime.Now;
            mnu.docquyen = "";
            db.c_dongdonhangqrs.InsertOnSubmit(mnu);
        }
    }

    public md_sanpham add_ctbg(string ma_sanpham, int maxOrder, decimal gia_fob, string c_baogia_id,
    string tk, string md_doitackinhdoanh_id, LinqDBDataContext db, params object[] args)
    {
        //Qr
        string object0 = "";
        try { object0 = args[0].ToString(); } catch { }
        //So luong
        string object1 = "1";
        try { object1 = args[1].ToString(); } catch { }
        //Ghi chu
        string object2 = "";
        try { object2 = args[2].ToString(); } catch { }
        //Dong goi
        string object3 = "";
        try { object3 = args[3].ToString(); } catch { }

        md_sanpham pro = db.md_sanphams.FirstOrDefault(s => s.ma_sanpham == ma_sanpham);
        if (pro != null)
        {
            if (gia_fob < 0)
            {
                var itemJS = UserUtils.get_giasanpham(null, c_baogia_id, pro.md_sanpham_id, db);
                try { gia_fob = decimal.Parse(itemJS["gia"].ToString()); } catch { gia_fob = 0; }
            }
            String dvt_inner = "", dvt_outer = "", ghichu_vachngan = "", trangthai = "BT", md_donggoi_id = "";

            System.Nullable<decimal> sl_inner = 0, soluonggoi_ctn = 0, sl_outer = 0, l1 = 0, w1 = 0, h1 = 0, l2_mix = 0, w2_mix = 0, h2_mix = 0, v2 = 0, vd = 0, vn = 0, vl = 0;
            md_donggoisanpham dgsp = null;
            if (!string.IsNullOrWhiteSpace(object3))
                dgsp = db.md_donggoisanphams.Where(s => s.md_donggoi_id == object3 & s.md_sanpham_id == pro.md_sanpham_id).FirstOrDefault();
            if(dgsp == null)
                dgsp = db.md_donggoisanphams.Where(s => s.md_sanpham_id == pro.md_sanpham_id & s.macdinh == true).FirstOrDefault();

            if (dgsp != null)
            {
                md_donggoi dg_sel = db.md_donggois.FirstOrDefault(s => s.md_donggoi_id == dgsp.md_donggoi_id);
                if (dg_sel != null)
                {
                    dvt_inner = dg_sel.dvt_inner;
                    dvt_outer = dg_sel.dvt_outer;
                    ghichu_vachngan = dg_sel.ghichu_vachngan;

                    sl_inner = dg_sel.sl_inner;
                    soluonggoi_ctn = dg_sel.soluonggoi_ctn;
                    sl_outer = dg_sel.sl_outer;
                    l1 = dg_sel.l1;
                    w1 = dg_sel.w1;
                    h1 = dg_sel.h1;
                    l2_mix = dg_sel.l2_mix;
                    w2_mix = dg_sel.w2_mix;
                    h2_mix = dg_sel.h2_mix;
                    v2 = dg_sel.v2;
                    vd = dg_sel.vd;
                    vn = dg_sel.vn;
                    vl = dg_sel.vl;
                    md_donggoi_id = dg_sel.md_donggoi_id;
                }
            }

            trangthai = UserUtils.get_DQ_DG_ALL(null, dgsp.md_donggoi_id, md_doitackinhdoanh_id, pro.md_sanpham_id, db)[0];
            

            c_chitietbaogia ctbg = new c_chitietbaogia
            {
                c_chitietbaogia_id = ImportUtils.getNEWID(),
                c_baogia_id = c_baogia_id,
                trangthai = trangthai,
                md_sanpham_id = pro.md_sanpham_id,
                ma_sanpham_khach = "",
                md_cangbien_id = pro.md_cangbien_id,
                mota_tienganh = pro.mota_tienganh,
                mota_tiengviet = pro.mota_tiengviet,
                ghichu_vachngan = "",
                sothutu = maxOrder + 10,
                giafob = gia_fob,
                soluong = int.Parse(object1),
                ghichu = object2,
                md_donggoi_id = md_donggoi_id,
                sl_inner = sl_inner,
                l1 = l1,
                w1 = w1,
                h1 = h1,
                sl_outer = sl_outer,
                l2 = l2_mix,
                w2 = w2_mix,
                h2 = h2_mix,
                v2 = v2,
                vd = vd,
                vn = vn,
                vl = vl,
                sl_cont = soluonggoi_ctn,
                docquyen = "",
                mota = "",
                hoatdong = true,
                ngaytao = DateTime.Now,
                ngaycapnhat = DateTime.Now,
                nguoitao = tk,
                nguoicapnhat = tk
            };

            if (object0 == "qr")
            {
                c_chitietbaogiaqr ctbgqr = new c_chitietbaogiaqr();
                ctbg.CopyPropertiesTo(ctbgqr);
                ctbgqr.c_chitietbaogiaqr_id = ctbg.c_chitietbaogia_id;
                ctbgqr.c_baogiaqr_id = c_baogia_id;
                db.c_chitietbaogiaqrs.InsertOnSubmit(ctbgqr);
            }
            else
            {
                db.c_chitietbaogias.InsertOnSubmit(ctbg);
            }
        }

        return pro;
    }
}