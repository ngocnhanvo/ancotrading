<%@ WebHandler Language="C#" Class="ChiaTachPOController" %>

using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json.Linq;
using NetServ.Net.Json;
using System.Collections.Generic;
using Newtonsoft.Json;

public class ChiaTachPOController : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        string action = context.Request.Form["action"].ToString();
        if (action.Equals("SaveDatHang"))
        {
            saveDatHang(context);
        }
    }

    /*public void saveDatHang(HttpContext context)
    {
        try
        {
            String result = "";
            LinqDBDataContext db = new LinqDBDataContext();
            string jsondata = context.Request.Form["grid_form"].ToString();
            IList<JToken> tokenList = JToken.Parse(jsondata).ToList();

            List<dongDatHang> dsSanPham = new List<dongDatHang>();

            foreach (JToken token in tokenList)
            {
                dsSanPham.Add(Newtonsoft.Json.JsonConvert.DeserializeObject<dongDatHang>(token.ToString()));
            }

            // Có danh sách sản phẩm mới thực hiện tạo DSDH
            if (dsSanPham.Count > 0)
            {
                // distinct danh sách khách hàng của các sản phẩm 
                var dsPartner = dsSanPham.Select(p => p.md_doitackinhdoanh_id).Distinct().ToList();
                int countPartner = dsPartner.Count();
                c_donhang donhang = db.c_donhangs.FirstOrDefault(p => p.c_donhang_id.Equals(dsSanPham[0].c_donhang_id));

                if (donhang != null)
                {
                    if (donhang.ismakepi.Equals(true))
                    {
                        result += String.Format("Đơn hàng {0} đã tạo PI từ trước đó.!", donhang.sochungtu);
                    }
                    else if (donhang.md_trangthai_id.Equals("SOANTHAO"))
                    {
                        result += String.Format("Bạn phải chuyển trạng thái PO {0} thành hiệu lực mới tạo được PI.!", donhang.sochungtu);
                    }
                    else if (donhang.md_trangthai_id.Equals("KETTHUC"))
                    {
                        result += String.Format("Không thể tạo đơn đặt hàng vì đơn hàng đã kết thúc.!", donhang.sochungtu);
                    }
                    else if (donhang.md_trangthai_id.Equals("HIEULUC"))
                    {
                        if (countPartner > 1)
                        {
                            result += String.Format("Không thể tạo đơn đặt hàng vì đơn hàng có nhiều hơn một nhà cung ứng.!", donhang.sochungtu);
                        }
                        else
                        {
                            String selSCT = @"SELECT (sct.tiento + '/' + CAST(sct.so_duocgan as nvarchar(32)) + '/' + hauto) as sochungtu 
                          FROM md_sochungtu sct, md_loaichungtu lct 
                          WHERE sct.md_loaichungtu_id = lct.md_loaichungtu_id AND lct.kieu_doituong = N'PI'";

                            String sochungtu = (String)mdbc.ExecuteScalar(selSCT);
                            //mdbc.ExcuteNonProcedure("PoToPi", "@c_donhang_id", poId, "@sochungtu", sochungtu);

                            // lấy nha cung ung
                            String md_doitackinhdoanh_id = (from p in db.md_doitackinhdoanhs 
                                                            where p.ma_dtkd.Equals(dsPartner[0].ToString()) 
                                                            select p.md_doitackinhdoanh_id).FirstOrDefault();

                            String c_dondathang_id = ImportUtils.getNEWID();

                            c_danhsachdathang dondathang = new c_danhsachdathang();
                            dondathang.c_danhsachdathang_id = c_dondathang_id;
                            dondathang.sochungtu = sochungtu;
                            dondathang.so_po = donhang.sochungtu;
                            dondathang.c_donhang_id = donhang.c_donhang_id;
                            dondathang.md_doitackinhdoanh_id = md_doitackinhdoanh_id;
                            dondathang.ngaylap = DateTime.Now;
                            dondathang.hangiaohang_po = donhang.shipmenttime;
                            dondathang.nguoi_phutrach = "";
                            dondathang.nguoi_dathang = "";
                            dondathang.md_trangthai_id = "SOANTHAO";
                            dondathang.ngaytao = DateTime.Now;
                            dondathang.ngaycapnhat = DateTime.Now;
                            dondathang.nguoitao = UserUtils.getUser(context);
                            dondathang.nguoicapnhat = UserUtils.getUser(context);
                            dondathang.hoatdong = true;
                            dondathang.isgui_hdlh = false;


                            // Lay cac dong don hang
                            System.Collections.Generic.List<c_dongdsdh> lstDongDonDatHang = new System.Collections.Generic.List<c_dongdsdh>();

                            foreach (var item in dsSanPham)
                            {
                                md_sanpham sp = db.md_sanphams.FirstOrDefault(p => p.md_sanpham_id.Equals(item.sanpham_id));
                                c_dongdonhang ddonhang = db.c_dongdonhangs.FirstOrDefault(p => p.c_dongdonhang_id.Equals(item.c_dongdonhang_id));

                                //String nhacungung = (from p in db.md_sanphams where p.md_sanpham_id.Equals(item.sanpham_id) select p.nhacungung).FirstOrDefault();
                                String nhacungung = ddonhang.nhacungungid;
                                decimal gianhap = (decimal)mdbc.ExecuteScalarProcedure("getGiaMuaSp", "@md_sanpham_id", item.sanpham_id, "@md_doitackinhdoanh_id", nhacungung, "@loai_bg", 0, "@ngaytinhgia", DateTime.Now);

                                c_dongdsdh ddsdh = new c_dongdsdh();
                                ddsdh.c_dongdsdh_id = ImportUtils.getNEWID();
                                ddsdh.sothutu = ddonhang.sothutu;
                                ddsdh.c_danhsachdathang_id = dondathang.c_danhsachdathang_id;
                                ddsdh.c_dongdonhang_id = item.c_dongdonhang_id;
                                ddsdh.md_sanpham_id = item.sanpham_id;
                                ddsdh.mota_tiengviet = sp.mota_tiengviet;
                                ddsdh.mota_tienganh = sp.mota_tienganh;
                                ddsdh.md_doitackinhdoanh_id = ddonhang.nhacungungid;
                                ddsdh.huongdan_dathang = "";
                                ddsdh.han_giaohang = DateTime.Now;
                                ddsdh.tem_dan = "Tem dáng";
                                ddsdh.sl_dathang = item.soluong_dadat;
                                ddsdh.sl_dagiao = 0;
                                ddsdh.sl_conlai = item.soluong_dadat;
                                ddsdh.gianhap = gianhap;
                                ddsdh.ma_sanpham_khach = item.ma_sanpham_khach;
                                ddsdh.md_donggoi_id = ddonhang.md_donggoi_id;
                                ddsdh.sl_inner = ddonhang.sl_inner;
                                ddsdh.l1 = ddonhang.l1;
                                ddsdh.w1 = ddonhang.w1;
                                ddsdh.h1 = ddonhang.h1;
                                ddsdh.sl_outer = ddonhang.sl_outer;
                                ddsdh.l2 = ddonhang.l2;
                                ddsdh.w2 = ddonhang.w2;
                                ddsdh.h2 = ddonhang.h2;
                                ddsdh.v2 =  ddonhang.sl_outer.Value == 0 ? 0 : Math.Round((((ddonhang.l2.Value * ddonhang.h2.Value * ddonhang.w2.Value) * item.soluong_dadat / ddonhang.sl_outer.Value) / 1000000), 3);
                                ddsdh.sl_cont = ddonhang.sl_cont;
                                ddsdh.vd = ddonhang.vd;
                                ddsdh.vn = ddonhang.vn;
                                ddsdh.vl = ddonhang.vl;
                                ddsdh.ghichu_vachngan = ddonhang.ghichu_vachngan;
                                ddsdh.ngaytao = DateTime.Now;
                                ddsdh.ngaycapnhat = DateTime.Now;
                                ddsdh.nguoitao = UserUtils.getUser(context);
                                ddsdh.nguoicapnhat = UserUtils.getUser(context);
                                ddsdh.hoatdong = true;

                                lstDongDonDatHang.Add(ddsdh);
                            }

                            donhang.ismakepi = false;
                            db.c_danhsachdathangs.InsertOnSubmit(dondathang);
                            db.c_dongdsdhs.InsertAllOnSubmit(lstDongDonDatHang);
                            db.SubmitChanges();
                            result += String.Format("Đã tạo đơn đặt hàng thành công với số chứng từ {0}.!", sochungtu);
                        }
                    }
                }
                jqGridHelper.Utils.writeResult(1, result);
            }
            else
            {
                jqGridHelper.Utils.writeResult(0, "Không thể tạo danh sách đặt hàng không có sản phẩm!");
            }
        }
        catch (Exception e)
        {
            jqGridHelper.Utils.writeResult(0, e.Message);
        } 
    }*/

    public void saveDatHang(HttpContext context)
    {
        try
        {
            String result = "";
            LinqDBDataContext db = new LinqDBDataContext();
            string jsondata = context.Request.Form["grid_form"].ToString();
            IList<JToken> tokenList = JToken.Parse(jsondata).ToList();

            List<dongDatHang> dsSanPham = new List<dongDatHang>();

            foreach (JToken token in tokenList)
            {
                dsSanPham.Add(Newtonsoft.Json.JsonConvert.DeserializeObject<dongDatHang>(token.ToString()));
            }

            // Có danh sách sản phẩm mới thực hiện tạo DSDH
            if (dsSanPham.Count > 0)
            {
                // distinct danh sách khách hàng của các sản phẩm 
                var dsPartner = dsSanPham.Select(p => p.md_doitackinhdoanh_id).Distinct().ToList();
                int countPartner = dsPartner.Count();
                c_donhang donhang = db.c_donhangs.FirstOrDefault(p => p.c_donhang_id.Equals(dsSanPham[0].c_donhang_id));

                if (donhang != null)
                {
                    if (donhang.ismakepi.Equals(true))
                    {
                        result += String.Format("Đơn hàng {0} đã tạo PI từ trước đó.!", donhang.sochungtu);
                    }
                    else if (donhang.md_trangthai_id.Equals("SOANTHAO"))
                    {
                        result += String.Format("Bạn phải chuyển trạng thái PO {0} thành hiệu lực mới tạo được PI.!", donhang.sochungtu);
                    }
                    else if (donhang.md_trangthai_id.Equals("KETTHUC"))
                    {
                        result += String.Format("Không thể tạo đơn đặt hàng vì đơn hàng đã kết thúc.!", donhang.sochungtu);
                    }
                    else if (donhang.md_trangthai_id.Equals("HIEULUC"))
                    {
                        if (countPartner > 1)
                        {
                            result += String.Format("Không thể tạo đơn đặt hàng vì đơn hàng có nhiều hơn một nhà cung ứng.!", donhang.sochungtu);
                        }
                        else
                        {
                            String selSCT = @"SELECT (sct.tiento + '/' + CAST(sct.so_duocgan as nvarchar(32)) + '/' + hauto) as sochungtu 
											 FROM md_sochungtu sct, md_loaichungtu lct 
											 WHERE sct.md_loaichungtu_id = lct.md_loaichungtu_id AND lct.kieu_doituong = N'PI'";

                            String sochungtu = (String)mdbc.ExecuteScalar(selSCT);
                            //mdbc.ExcuteNonProcedure("PoToPi", "@c_donhang_id", poId, "@sochungtu", sochungtu);

                            // lấy nha cung ung
                            String md_doitackinhdoanh_id = (from p in db.md_doitackinhdoanhs
                                                            where p.ma_dtkd.Equals(dsPartner[0].ToString())
                                                            select p.md_doitackinhdoanh_id).FirstOrDefault();

                            String c_dondathang_id = ImportUtils.getNEWID();
                            string ncc = md_doitackinhdoanh_id;
                            md_tygia tg = db.md_tygias.ToList().OrderByDescending(p=>p.hieuluc_tungay).FirstOrDefault();
                            c_danhsachdathang dondathang = new c_danhsachdathang();
                            decimal discount_vinhgia = 0;
                            string ma_dtkd_select = db.md_doitackinhdoanhs.SingleOrDefault(p => p.md_doitackinhdoanh_id == md_doitackinhdoanh_id).ma_dtkd;
                            if (ma_dtkd_select == "VINHGIA")
                            {
                                discount_vinhgia = donhang.discount.Value;
                                dondathang.discount = 0;
                            }
                            else if(new string[]{ "ANCO2", "ANBINH" }.Contains(ma_dtkd_select)) {
                                if(donhang.donhang_mau.GetValueOrDefault(false) == true) {
                                    if(donhang.discount.GetValueOrDefault(0) == 100)
                                        dondathang.discount = donhang.discount;
                                }
                            }
                            dondathang.c_danhsachdathang_id = c_dondathang_id;
                            dondathang.sochungtu = sochungtu;
                            dondathang.so_po = donhang.sochungtu;
                            dondathang.c_donhang_id = donhang.c_donhang_id;
                            dondathang.md_doitackinhdoanh_id = md_doitackinhdoanh_id;
                            dondathang.ngaylap = DateTime.Now;
                            dondathang.hangiaohang_po = donhang.shipmenttime.Value.AddDays(-7);
                            dondathang.nguoi_phutrach = "";
                            dondathang.nguoi_dathang = "";
                            dondathang.diachigiaohang = ncc;
                            dondathang.md_trangthai_id = "SOANTHAO";
                            dondathang.ngaytao = DateTime.Now;
                            dondathang.ngaycapnhat = DateTime.Now;
                            dondathang.nguoitao = UserUtils.getUser(context);
                            dondathang.nguoicapnhat = UserUtils.getUser(context);
                            dondathang.hoatdong = true;
                            dondathang.isgui_hdlh = false;

                            string mota_diengiai = "";
                            foreach(c_phidonhang pdh in db.c_phidonhangs.Where(s => s.c_donhang_id == donhang.c_donhang_id))
                            {
                                md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id == md_doitackinhdoanh_id);
                                if((bool)pdh.phitang)
                                    mota_diengiai += pdh.diengiai_kh + " " + pdh.phi + " USD \n";
                                else
                                    mota_diengiai += pdh.diengiai_kh + " " + pdh.phi + " USD \n";

                            }
                            ////Clone Toan
                            //foreach (c_phidonhang pdonh in db.c_phidonhangs.ToList().Where(s => s.c_donhang_id == donhang.c_donhang_id))
                            //{
                            //	//md_doitackinhdoanh kd = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id == md_doitackinhdoanh_id);
                            //	if(pdonh.check_ptrCBM == true) 
                            //	{
                            //		// tinh CBM
                            //		System.Data.DataTable dt = mdbc.GetDataFromProcedure("tinhNangLucCungUng_group", "@donhang_id", donhang.c_donhang_id);
                            //		int rowCount = dt.Rows.Count;
                            //		string nangluc = "";
                            //		if (rowCount > 0)
                            //		{
                            //			foreach (System.Data.DataRow row in dt.Rows)
                            //			{
                            //				nangluc += row["ma_dtkd"] + ":" + row["cbm"] + ",";
                            //			}
                            //		}

                            //		decimal cbm = 0;
                            //		string[] nangluc_split = nangluc.Split(',');
                            //		for(int i = 0; i < nangluc_split.Count(); i++)
                            //		{
                            //			string[] cbm_ncc = nangluc_split[i].Split(':');
                            //			try {
                            //				cbm = decimal.Parse(cbm_ncc[1]);
                            //				decimal vnn = Math.Round((cbm * 100) / donhang.totalcbm.Value, 0);
                            //				decimal vnn1 = Math.Round(pdonh.phi.Value * vnn / 100, 0);
                            //				decimal vnn_sotien = jqGridHelper.Utils.Round3((vnn1 * tg.chia_cho.Value), -2);
                            //				decimal sotien = 0;
                            //				sotien = vnn_sotien;
                            //				mota_diengiai += cbm_ncc[0] + ":" + vnn_sotien + " VND\n";
                            //			}
                            //			catch{ }
                            //		}
                            //	}
                            //}
                            dondathang.mota = mota_diengiai;

                            // Lay cac dong don hang
                            System.Collections.Generic.List<c_dongdsdh> lstDongDonDatHang = new System.Collections.Generic.List<c_dongdsdh>();

                            foreach (var item in dsSanPham)
                            {
                                md_sanpham sp = db.md_sanphams.FirstOrDefault(p => p.md_sanpham_id.Equals(item.sanpham_id));
                                c_dongdonhang ddonhang = db.c_dongdonhangs.FirstOrDefault(p => p.c_dongdonhang_id.Equals(item.c_dongdonhang_id));

                                //String nhacungung = (from p in db.md_sanphams where p.md_sanpham_id.Equals(item.sanpham_id) select p.nhacungung).FirstOrDefault();
                                String nhacungung = ddonhang.nhacungungid;
                                decimal gianhap = (decimal)mdbc.ExecuteScalarProcedure("getGiaMuaSp", "@md_sanpham_id", item.sanpham_id, "@md_doitackinhdoanh_id", nhacungung, "@loai_bg", 0, "@ngaytinhgia", DateTime.Now);
                                decimal gianhap2 = UserUtils.get_gianhap(context, ma_dtkd_select, ddonhang.giafob.Value, donhang.discount.Value, discount_vinhgia);
                                if(gianhap2 > -1) {
                                    gianhap = gianhap2;
                                }
                                c_dongdsdh ddsdh = new c_dongdsdh();

                                ddsdh.c_dongdsdh_id = ImportUtils.getNEWID();
                                ddsdh.sothutu = ddonhang.sothutu;
                                ddsdh.c_danhsachdathang_id = dondathang.c_danhsachdathang_id;
                                ddsdh.c_dongdonhang_id = item.c_dongdonhang_id;
                                ddsdh.md_sanpham_id = item.sanpham_id;
                                ddsdh.mota_tiengviet = sp.mota_tiengviet;
                                ddsdh.mota_tienganh = sp.mota_tienganh;
                                ddsdh.md_doitackinhdoanh_id = ddonhang.nhacungungid;
                                ddsdh.huongdan_dathang = "";
                                ddsdh.han_giaohang = DateTime.Now;
                                ddsdh.tem_dan = "Tem dáng";
                                ddsdh.sl_dathang = item.soluong_dadat;
                                ddsdh.sl_dagiao = 0;
                                ddsdh.sl_conlai = item.soluong_dadat;
                                ddsdh.gianhap = gianhap;
                                ddsdh.ma_sanpham_khach = item.ma_sanpham_khach;
                                ddsdh.md_donggoi_id = ddonhang.md_donggoi_id;
                                ddsdh.sl_inner = ddonhang.sl_inner;
                                ddsdh.l1 = ddonhang.l1;
                                ddsdh.w1 = ddonhang.w1;
                                ddsdh.h1 = ddonhang.h1;
                                ddsdh.sl_outer = ddonhang.sl_outer;
                                ddsdh.l2 = ddonhang.l2;
                                ddsdh.w2 = ddonhang.w2;
                                ddsdh.h2 = ddonhang.h2;
                                ddsdh.v2 =  ddonhang.sl_outer.Value == 0 ? 0 : Math.Round((((ddonhang.l2.Value * ddonhang.h2.Value * ddonhang.w2.Value) * item.soluong_dadat / ddonhang.sl_outer.Value) / 1000000), 3);
                                ddsdh.sl_cont = ddonhang.sl_cont;
                                ddsdh.vd = ddonhang.vd;
                                ddsdh.vn = ddonhang.vn;
                                ddsdh.vl = ddonhang.vl;
                                ddsdh.ghichu_vachngan = ddonhang.ghichu_vachngan;
                                ddsdh.ngaytao = DateTime.Now;
                                ddsdh.ngaycapnhat = DateTime.Now;
                                ddsdh.nguoitao = UserUtils.getUser(context);
                                ddsdh.nguoicapnhat = UserUtils.getUser(context);
                                ddsdh.hoatdong = true;

                                lstDongDonDatHang.Add(ddsdh);
                            }

                            int count_pdh = 0;
                            foreach (c_phidonhang pdonh in db.c_phidonhangs.Where(s => s.c_donhang_id == donhang.c_donhang_id).OrderByDescending(s=>s.phitang_kh))
                            {
                                if(pdonh.tracho_ncc.GetValueOrDefault(false) == true)
                                {
                                    #region phan tram CBM
                                    if(pdonh.check_ptrCBM == true)
                                    {
                                        // tinh CBM
                                        System.Data.DataTable dt = mdbc.GetDataFromProcedure("tinhNangLucCungUng_group", "@donhang_id", donhang.c_donhang_id);
                                        int rowCount = dt.Rows.Count;
                                        string nangluc = "";
                                        if (rowCount > 0)
                                        {
                                            foreach (System.Data.DataRow row in dt.Rows)
                                            {
                                                nangluc += row["ma_dtkd"] + ":" + row["cbm"] + ",";
                                            }
                                        }

                                        decimal cbm = 0;
                                        string[] nangluc_split = nangluc.Split(',');
                                        for(int i = 0; i < nangluc_split.Count(); i++)
                                        {
                                            string[] cbm_ncc = nangluc_split[i].Split(':');
                                            try {
                                                cbm = decimal.Parse(cbm_ncc[1]);
                                                decimal vnn = Math.Round((cbm * 100) / donhang.totalcbm.Value, 0);
                                                decimal vnn1 = pdonh.phi.Value * vnn / 100;

                                                decimal get_giaPB = UserUtils.get_gianhap(context, cbm_ncc[0], -2, -2, -2);
                                                decimal tienVND = 0;
                                                if(get_giaPB > 1) {
                                                    tienVND = jqGridHelper.Utils.Round3(vnn1 * get_giaPB, -2);
                                                }
                                                else {
                                                    tienVND = vnn1;
                                                }

                                                if(tienVND > 0) {
                                                    string am_vnd = pdonh.phitang_kh == false ? "-" : "";
                                                    string dongtien = cbm_ncc[0] == "VINHGIA" ? "USD" : "VND";
                                                    dondathang.mota += "\n" + cbm_ncc[0] + ": " + am_vnd + tienVND + " " + dongtien +".";
                                                    if (ma_dtkd_select == cbm_ncc[0])
                                                    {
                                                        c_phidathang pdath = new c_phidathang
                                                        {
                                                            c_phidathang_id = ImportUtils.getNEWID(),
                                                            c_danhsachdathang_id = c_dondathang_id,
                                                            sotien = tienVND,
                                                            isphicong = pdonh.phitang,

                                                            mota = pdonh.diengiai_kh + "\n",
                                                            hoatdong = true,
                                                            ngaytao = DateTime.Now,
                                                            ngaycapnhat = DateTime.Now,
                                                            nguoitao = UserUtils.getUser(context),
                                                            nguoicapnhat = UserUtils.getUser(context)
                                                        };
                                                        db.c_phidathangs.InsertOnSubmit(pdath);
                                                    }
                                                }
                                            }
                                            catch{ }
                                        }
                                    }
                                    #endregion

                                    #region Chuyen Het NCC
                                    else if(pdonh.check_chhet == true) {
                                        var d = JsonConvert.DeserializeObject<List<dsncc_ptr>>(pdonh.dsncc_check_chhet);
                                        try {
                                            if(count_pdh == 0) {
                                                dondathang.mota = pdonh.mota + ": " + pdonh.phi.Value + " USD.";
                                                count_pdh = 1;
                                            }
                                            foreach (var row in d) {
                                                decimal tien = decimal.Parse((row.tien.ToString()).ToString());
                                                decimal get_giaPB = UserUtils.get_gianhap(context, row.ma_dtkd, -2, -2, -2);
                                                decimal tienVND = 0;
                                                if(get_giaPB > 1) {
                                                    tienVND = jqGridHelper.Utils.Round3(tien * get_giaPB, -2);
                                                }
                                                else {
                                                    tienVND = tien;
                                                }

                                                if(tienVND > 0) {
                                                    string am_vnd = pdonh.phitang_kh == false ? "-" : "";
                                                    string dongtien = row.ma_dtkd == "VINHGIA" ? "USD" : "VND";
                                                    dondathang.mota += "\n" + row.ma_dtkd + ": " + am_vnd + tienVND + " " + dongtien +".";
                                                }

                                                if(md_doitackinhdoanh_id == row.id.ToString()) {

                                                    if(tien > 0) {
                                                        string mota_dsdh = "";
                                                        if(pdonh.tracho_ncc == true) {
                                                            mota_dsdh = pdonh.diengiai_kh;
                                                        }
                                                        else {
                                                            mota_dsdh = pdonh.mota;
                                                        }

                                                        c_phidathang pdath = new c_phidathang
                                                        {
                                                            c_phidathang_id = ImportUtils.getNEWID(),
                                                            c_danhsachdathang_id = c_dondathang_id,
                                                            sotien = tienVND,
                                                            isphicong = pdonh.phitang,

                                                            mota = mota_dsdh,
                                                            hoatdong = true,
                                                            ngaytao = DateTime.Now,
                                                            ngaycapnhat = DateTime.Now,
                                                            nguoitao = UserUtils.getUser(context),
                                                            nguoicapnhat = UserUtils.getUser(context)
                                                        };
                                                        db.c_phidathangs.InsertOnSubmit(pdath);
                                                    }
                                                }
                                            }
                                        }
                                        catch { }
                                    }
                                    #endregion

                                    #region Chuyen Theo Cong Thuc Gia Mua
                                    else if(pdonh.check_ptr == true) {
                                        var d = JsonConvert.DeserializeObject<List<dsncc_ptr>>(pdonh.dsncc_check_ptr);
                                        try {
                                            if(count_pdh == 0) {
                                                dondathang.mota = pdonh.mota + ": " + pdonh.phi.Value + " USD.";
                                                count_pdh = 1;
                                            }
                                            foreach (var row in d) {
                                                decimal tien = decimal.Parse((row.tien.ToString()).ToString());
                                                decimal get_giaPB = UserUtils.get_gianhap(context, row.ma_dtkd, tien, 0, 0);
                                                decimal tienVND = 0;
                                                if(get_giaPB > 0) {
                                                    tienVND = get_giaPB;
                                                }
                                                else {
                                                    tienVND = tien;
                                                }

                                                if(tienVND > 0) {
                                                    string am_vnd = pdonh.phitang_kh == false ? "-" : "";
                                                    string dongtien = row.ma_dtkd == "VINHGIA" ? "USD" : "VND";
                                                    dondathang.mota += "\n" + row.ma_dtkd + ": " + am_vnd + tienVND + " " + dongtien +".";
                                                }
                                                if(md_doitackinhdoanh_id == row.id.ToString()) {
                                                    if(tien > 0) {
                                                        string mota_dsdh = "";
                                                        if(pdonh.tracho_ncc == true) {
                                                            mota_dsdh = pdonh.diengiai_kh;
                                                        }
                                                        else {
                                                            mota_dsdh = pdonh.mota;
                                                        }

                                                        c_phidathang pdath = new c_phidathang
                                                        {
                                                            c_phidathang_id = ImportUtils.getNEWID(),
                                                            c_danhsachdathang_id = c_dondathang_id,
                                                            sotien = tienVND,
                                                            isphicong = pdonh.phitang,

                                                            mota = mota_dsdh,
                                                            hoatdong = true,
                                                            ngaytao = DateTime.Now,
                                                            ngaycapnhat = DateTime.Now,
                                                            nguoitao = UserUtils.getUser(context),
                                                            nguoicapnhat = UserUtils.getUser(context)
                                                        };
                                                        db.c_phidathangs.InsertOnSubmit(pdath);
                                                    }
                                                }
                                            }
                                        }
                                        catch { }
                                    }
                                    #endregion

                                    #region Chuyen Binh Thuong
                                    else {
                                        string mota_dsdh = "";
                                        if(pdonh.tracho_ncc == true) {
                                            mota_dsdh = pdonh.diengiai_kh;
                                        }
                                        else {
                                            mota_dsdh = pdonh.mota;
                                        }

                                        c_phidathang pdath = new c_phidathang
                                        {
                                            c_phidathang_id = ImportUtils.getNEWID(),
                                            c_danhsachdathang_id = c_dondathang_id,
                                            sotien = pdonh.phi,
                                            isphicong = pdonh.phitang,

                                            mota = mota_dsdh,
                                            hoatdong = true,
                                            ngaytao = DateTime.Now,
                                            ngaycapnhat = DateTime.Now,
                                            nguoitao = UserUtils.getUser(context),
                                            nguoicapnhat = UserUtils.getUser(context)
                                        };
                                        db.c_phidathangs.InsertOnSubmit(pdath);
                                    }
                                    #endregion
                                    count_pdh++;
                                }
                            }

                            donhang.ismakepi = false;
                            if(dondathang.discount == null)
                                dondathang.discount = 0;

                            dondathang.mota = donhang.ghichu + "\n" + dondathang.mota;
                            db.c_danhsachdathangs.InsertOnSubmit(dondathang);
                            db.c_dongdsdhs.InsertAllOnSubmit(lstDongDonDatHang);
                            db.SubmitChanges();
                            result += String.Format("Đã tạo đơn đặt hàng thành công với số chứng từ {0}.!", sochungtu);
                        }
                    }
                }
                jqGridHelper.Utils.writeResult(1, result);
            }
            else
            {
                jqGridHelper.Utils.writeResult(0, "Không thể tạo danh sách đặt hàng không có sản phẩm!");
            }
        }
        catch (Exception e)
        {
            jqGridHelper.Utils.writeResult(0, e.Message);
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}

public class dsncc_ptr {
    public string id;
    public string ma_dtkd;
    public string tien;
}
