<%@ WebHandler Language="C#" Class="API_Data" %>

using System;
using System.Linq;
using System.Web;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using Newtonsoft.Json;

public class API_Data : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    private LinqDBDataContext db = new LinqDBDataContext();
    public class ThongTinSP
    {
        public string dateStr { get; set; }
        public string itemNo { get; set; }
        public string description { get; set; }
        public string colorName { get; set; }
        public string packing { get; set; }
        public string palletSize { get; set; }
        public string qtyCont { get; set; }
        public string price { get; set; }
        public string amount { get; set; }
        public string cbm { get; set; }
        public string image { get; set; }
        public string size { get; set; }
        public List<ThongTinSP> sizes { get; set; }
        public List<ThongTinSP> colors { get; set; }
    }

    public class ThongTinKhachHang
    {
        public string dateStr { get; set; }
        public string customerCode { get; set; }
        public string companyName { get; set; }
        public string contactPerson { get; set; }
        public string eMail { get; set; }
        public string Phone { get; set; }
        public string address { get; set; }
    }

    public class ThongTin
    {
        public DateTime date { get; set; }
        public string dateStr { get; set; }
        public int slSP { get; set; }
        public int slKH { get; set; }
        public int tongSLSP { get; set; }
        public int tongSLKH { get; set; }
        public int slGet { get; set; }
        public bool @continue { get; set; }
        public List<ThongTinSP> sps { get; set; }
        public List<ThongTinKhachHang> khs { get; set; }
    }

    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.Params["oper"];
        switch (oper)
        {
            case "xemthaydoi":
                this.xemthaydoi(context);
                break;
            case "logs":
                this.logs(context);
                break;
            case "logs_detail":
                this.logs_detail(context);
                break;
            case "sanphams":
                this.sanphams(context);
                break;
            case "md_sanpham":
                this.md_sanpham(context);
                break;
            case "md_chungloai":
                this.md_chungloai(context);
                break;
            case "md_chucnang":
                this.md_chucnang(context);
                break;
            case "md_cangbien":
                this.md_cangbien(context);
                break;
            case "md_donvitinh":
                this.md_donvitinh(context);
                break;
            case "md_donvitinhsanpham":
                this.md_donvitinhsanpham(context);
                break;
            case "md_hscode":
                this.md_hscode(context);
                break;
            case "md_kieudang":
                this.md_kieudang(context);
                break;
            case "md_nhomnangluc":
                this.md_nhomnangluc(context);
                break;
            case "md_phanloaihh":
                this.md_phanloaihh(context);
                break;
            case "md_donggoisanpham":
                this.md_donggoisanpham(context);
                break;
            case "md_donggoi":
                this.md_donggoi(context);
                break;
            case "md_hanghoadocquyen":
                this.md_hanghoadocquyen(context);
                break;
            case "md_doitackinhdoanh":
                this.md_doitackinhdoanh(context);
                break;
            case "md_cangxuathang":
                this.md_cangxuathang(context);
                break;
            case "md_bientau":
                this.md_bientau(context);
                break;
            case "md_nhacungungmacdinh":
                this.md_nhacungungmacdinh(context);
                break;
            case "md_giasanpham":
                this.md_giasanpham(context);
                break;
            case "md_phienbangia":
                this.md_phienbangia(context);
                break;
            case "md_banggia":
                this.md_banggia(context);
                break;
            case "md_detai":
                this.md_detai(context);
                break;
            case "md_mausac":
                this.md_mausac(context);
                break;
            case "imageDeTai":
                this.imageDeTai(context);
                break;
            case "imageMauSac":
                this.imageMauSac(context);
                break;
            case "NhanDonHang":
                this.NhanDonHang(context);
                break;
            case "getListDSDH":
                this.getListDSDH(context);
                break;
        }
    }

    public void xemthaydoi(HttpContext context)
    {
        string msp = context.Request.Form["msp"];
        string ncc = context.Request.Form["ncc"];
        string giamua = $"{ncc}-GIAMUA";
        try
        {
            var sp = db.md_sanphams.Where(s => s.ma_sanpham == msp).FirstOrDefault();
            var gia = (from a in db.md_banggias
                       join b in db.md_phienbangias on a.md_banggia_id equals b.md_banggia_id
                       join c in db.md_giasanphams on b.md_phienbangia_id equals c.md_phienbangia_id
                       where
                         c.md_sanpham_id == sp.md_sanpham_id &&
                         a.ten_banggia == giamua &&
                         b.ngay_hieuluc <= DateTime.Now
                       orderby b.ngay_hieuluc descending
                       select c).FirstOrDefault();
            var giaSP = gia == null ? -1 : gia.gia.GetValueOrDefault(0);
            var dgid = db.md_donggoisanphams.Where(s => s.md_sanpham_id == sp.md_sanpham_id & s.macdinh == true).Select(s => s.md_donggoi_id).FirstOrDefault();
            var dg = db.md_donggois.Where(s => s.md_donggoi_id == dgid).FirstOrDefault();
            if (dg == null)
                dg = new md_donggoi();
            var dvt1 = db.md_donvitinhs.Where(s => s.md_donvitinh_id == dg.dvt_inner).FirstOrDefault();
            var dvt2 = db.md_donvitinhs.Where(s => s.md_donvitinh_id == dg.dvt_outer).FirstOrDefault();
            var kd = db.md_kieudangs.Where(s => s.md_kieudang_id == sp.md_kieudang_id).FirstOrDefault();
            string ma_kd = kd == null ? "" : kd.ma_kieudang;
            string ten_kd = kd == null ? "" : kd.ten_tv;
            var cn = db.md_chucnangs.Where(s => s.md_chucnang_id == sp.md_chucnang_id).FirstOrDefault();
            string ma_cn = cn == null ? "" : cn.ma_chucnang;
            string ten_cn = cn == null ? "" : cn.ten_tv;
            var nnl = db.md_nhomnanglucs.Where(s => s.md_nhomnangluc_id == sp.md_nhomnangluc_id).FirstOrDefault();
            string ten_nnl = nnl == null ? "" : $"{nnl.hehang}({nnl.nhom})";
            var hsc = db.md_hscodes.Where(s => s.md_hscode_id == sp.md_hscode_id).FirstOrDefault();
            string ten_hsc = hsc == null ? "" : hsc.hscode;
            dynamic result1 = new
            {
                sp.ma_sanpham,
                ten_kd,
                ma_kd,
                ten_cn,
                ma_cn,
                sp.mota_tiengviet,
                sp.mota_tienganh,
                sp.l_cm,
                sp.w_cm,
                sp.h_cm,
                sp.trongluong,
                sp.dientich,
                sp.thetich,
                ten_nnl,
                ten_hsc,
                sp.chucnangsp,
                sp.ngayxacnhan,
                sp.hinhthucban,
                giaSP = giaSP.DropTrailingZeros()
            };

            dynamic result2 = new
            {
                dg.ma_donggoi,
                dg.sl_inner,
                inner = dvt1.ten_dvt,
                dg.l1,
                dg.w1,
                dg.h1,
                dg.sl_outer,
                outer = dvt2.ten_dvt,
                dg.l2_mix,
                dg.w2_mix,
                dg.h2_mix,
                dg.soluonggoi_ctn_20,
                dg.soluonggoi_ctn,
                dg.soluonggoi_ctn_40hc,
                nxn_dg = dg.ngayxacnhan,
                dg.mota,
                dg.doigia_donggoi,
                tldg = dg.tldg.GetValueOrDefault(0).DropTrailingZeros(),
                cpdg = dg.cpdg.GetValueOrDefault(0).DropTrailingZeros()
            };


            var data = new
            {
                sp = result1,
                dg = result2
            };

            context.Response.Write("1" + Newtonsoft.Json.JsonConvert.SerializeObject(data));
        }
        catch (Exception ex)
        {
            context.Response.Write("0" + ex.ToString());
        }
    }

    public void logs(HttpContext context)
    {
        string ncc = context.Request.Params["ncc"].removeAllSpaceOrTrimText(true).ToLower();
        var logs = new List<ad_log>();
        bool ok = true;
        var result = new List<ad_log>();
        string msg = "";
        try
        {
            if (ncc == "nexxdecor")
            {
                logs = db.ad_logs.Where(s => s.nexxdecor_check == false).ToList();
                result = logs.Select(s => new ad_log
                {
                    ad_log_id = s.ad_log_id,
                    table = s.table,
                    id_lienket = s.id_lienket,
                    hanhdong = s.hanhdong,
                    nexxdecor_check = s.nexxdecor_check
                }).ToList();
                foreach (var log in logs)
                {
                    log.nexxdecor_check = true;
                }
                db.SubmitChanges();
                msg = "Lấy logs thành công";
            }

            else if (ncc == "anco1")
            {
                logs = db.ad_logs.Where(s => s.anco1_check == false).ToList();
                result = logs.Select(s => new ad_log
                {
                    ad_log_id = s.ad_log_id,
                    table = s.table,
                    id_lienket = s.id_lienket,
                    hanhdong = s.hanhdong,
                    anco1_check = s.anco1_check
                }).ToList();
                foreach (var log in logs)
                {
                    log.anco1_check = true;
                }
                db.SubmitChanges();
                msg = "Lấy logs thành công";
            }
        }
        catch (Exception ex)
        {
            ok = false;
            msg = ex.Message;
        }

        var rs = new { ok, result, msg };
        context.Response.Write(JsonConvert.SerializeObject(rs));
    }

    public void logs_detail(HttpContext context)
    {
        string logid = context.Request.Params["logid"].removeAllSpaceOrTrimText(true);
        var logs = new List<ad_log>();
        bool ok = true;
        var result = new System.Data.DataTable();
        string msg = "";
        try
        {
            var log = db.ad_logs.Where(s => s.ad_log_id == logid).FirstOrDefault();
            if (log == null)
            {
                ok = false;
                msg = "Không tìm thấy log bạn gửi";
                goto EndEventHandler;
            }

            result = VoNgocNhan.API_Data.layThongTinChiTiet(log.table, log.id_lienket);
            msg = "Lấy logs chi tiết thành công";
        }
        catch (Exception ex)
        {
            ok = false;
            msg = ex.Message;
        }

    EndEventHandler:;

        var rs = new { ok, result, msg };
        context.Response.Write(JsonConvert.SerializeObject(rs));
    }

    public void sanphams(HttpContext context)
    {
        var msg = "";
        var result = new ThongTin();
        try
        {
            string msp = context.Request.Params["msp"];
            int skip = context.Request.Params["skip"].removeAllSpaceOrTrimText(true).ToNullableInt().GetValueOrDefault(0);
            int take = context.Request.Params["take"].removeAllSpaceOrTrimText(true).ToNullableInt().GetValueOrDefault(0);
            string dateStr = context.Request.Params["dateStr"].removeAllSpaceOrTrimText(true);
            result.date = DateTime.Now;
            result.dateStr = string.IsNullOrWhiteSpace(dateStr) ? result.date.ToString("dd/MM/yyyy") : dateStr;

            var rsps = new List<ThongTinSP>();
            List<md_sanpham> sps = null;
            List<md_kieudang> kds = null;
            foreach (var key in context.Session.Keys)
            {
                if (key.ToString() == "sps")
                {
                    sps = context.Session["sps"] as List<md_sanpham>;
                }
                else if (key.ToString() == "kds")
                {
                    kds = context.Session["kds"] as List<md_kieudang>;
                }
            }

            if (sps == null | skip == 0)
            {
                var spsP = db.md_sanphams.Where(s => s.trangthai == "DHD" & (s.laMacon ?? false) == false);
                if (!string.IsNullOrWhiteSpace(msp))
                    spsP = spsP.Where(s => s.ma_sanpham == msp);
                sps = spsP.OrderBy(s => s.ma_sanpham).ToList();
                context.Session["sps"] = sps;
            }

            if (kds == null | skip == 0)
            {
                kds = db.md_kieudangs.Where(s => s.trangthai == Helper.HIEULUC).ToList();
                context.Session["kds"] = kds;
            }

            var continueStep = sps.Count > skip + take;

            foreach (var sp in sps.Skip(skip).Take(take))
            {
                var item = dequyTTSP(sp, sps, true, true, true, result.dateStr, db, kds);
                var mabo = sp.ma_sanpham.Substring(9, 2).ToString();
                var mabo_0 = mabo.Substring(0, 1).ToString();
                bool isNexx = Regex.IsMatch(mabo, @"^[a-zA-Z]{2}$");
                var ma09 = sp.ma_sanpham.Substring(0, 9);
                var ma113 = sp.ma_sanpham.Substring(11, 3);
                var bientaus1 = new string[] { "0" };
                var bientaus2 = new string[] { "B", "L", "X", "S" };
                var bientaus = bientaus1.Concat(bientaus2).ToArray();
                var mas = new List<string>();
                if (isNexx)
                {
                    mas.Add(sp.ma_sanpham);
                }
                else
                {
                    foreach (var bientau in bientaus)
                    {
                        for (var i = 0; i < 10; i++)
                        {
                            mas.Add($"{ma09}{bientau}{i}{ma113}");
                        }
                    }
                }

                var spsCai = sps.Where(s => mas.Contains(s.ma_sanpham)).ToList();

                var boS = spsCai.Where(s => s.ma_sanpham.Substring(9, 1) == "S").Select(s => s.ma_sanpham.Substring(9, 2)).FirstOrDefault();

                foreach (var spCai in spsCai)
                {
                    var itemCai = dequyTTSP(spCai, sps, false, true, false, result.dateStr, db, kds);
                    if (!isNexx)
                    {
                        var maBT = spCai.ma_sanpham.Substring(9, 2);
                        if (bientaus2.Contains(maBT.Substring(0, 1)))
                        {
                            var boId = db.md_bos.Where(s => s.ma_bo_cha == boS & s.ma_bo == maBT).Select(s => s.md_bo_id).FirstOrDefault();
                            var boCTs = db.md_bo_chitiets.Where(s => s.md_bo_id == boId).OrderBy(s => s.md_bo_detail).ToList();
                            foreach (var boCT in boCTs)
                            {
                                var caiCT = spsCai.Where(s => s.ma_sanpham.Substring(9, 2) == boCT.md_bo_detail).Select(s => s.ma_sanpham).FirstOrDefault();
                                if (!string.IsNullOrWhiteSpace(caiCT))
                                {
                                    itemCai.sizes.Add(new ThongTinSP()
                                    {
                                        dateStr = dateStr,
                                        itemNo = caiCT
                                    });
                                }
                            }
                        }
                    }
                    item.sizes.Add(itemCai);
                }
                item.sizes = item.sizes.OrderBy(s => s.itemNo.Substring(10, 2)).ToList();
                rsps.Add(item);
            }
            result.sps = rsps;

            if (skip == 0)
            {
                var rkhs = (from a in db.md_doitackinhdoanhs
                            join b in db.md_loaidtkds on a.md_loaidtkd_id equals b.md_loaidtkd_id
                            where b.ma_loaidtkd == "KH"
                            select new ThongTinKhachHang
                            {
                                dateStr = result.dateStr,
                                customerCode = a.ma_dtkd,
                                companyName = a.ten_dtkd,
                                contactPerson = a.daidien,
                                eMail = a.email,
                                Phone = a.tel,
                                address = a.diachi
                            })
                           .OrderBy(s => s.customerCode)
                           .ToList();
                result.khs = rkhs;
            }
            else
            {
                result.khs = new List<ThongTinKhachHang>();
            }

            result.@continue = continueStep;
            result.tongSLSP = sps.Count;
            result.slSP = result.sps.Count;
            result.slKH = result.khs.Count;
            msg = "1" + JsonConvert.SerializeObject(result);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public ThongTinSP dequyTTSP(md_sanpham sp, List<md_sanpham> sps, bool themDongGoi, bool themMau, bool themAnh, string dateStr, LinqDBDataContext db, List<md_kieudang> kds)
    {
        string packing = "-", palletSize = "-", qtyCont = "-", cbm = "", price = "";
        ExcuteSignalRStatic.getDongGoiResult ttdg = null;
        if (themDongGoi)
        {
            ttdg = ExcuteSignalRStatic.getDongGoi(sp.md_sanpham_id, db);
            if (ttdg != null)
            {
                var dDVT = ExcuteSignalRStatic.getTextFromInner(ttdg.dvtinner, ttdg.dvtouter, ttdg.sl_inner.ToString(), ttdg.sl_outer.ToString());
                var inner = dDVT.inner;
                var outer = dDVT.outer;
                if (!string.IsNullOrWhiteSpace(inner.Replace(" ", "")))
                {
                    packing = $@"{inner}, {outer}";
                }

                palletSize = $@"L{ttdg.l2_mix}xW{ttdg.w2_mix}xH{ttdg.h2_mix} cm";

                if (ttdg.soluonggoi_ctn_40hc.GetValueOrDefault(0) != 0)
                {
                    qtyCont = $@"{ttdg.soluonggoi_ctn_40hc} {dDVT.quantity}/40HC'";
                }

                cbm = ttdg.cbm.GetValueOrDefault(0).ToString();
            }


            var ttgsp = ExcuteSignalRStatic.getPrice(sp.md_sanpham_id, db);
            if (ttgsp != null)
                price = ttgsp.GetValueOrDefault(0).ToString();
        }
        var item = new ThongTinSP();
        item.dateStr = dateStr;
        item.itemNo = sp.ma_sanpham;
        item.description = sp.mota_tienganh;
        item.packing = packing;
        item.palletSize = palletSize;
        item.qtyCont = qtyCont;
        item.price = price;
        item.amount = "1";
        item.cbm = cbm;
        string kt = $"{sp.l_cm}x{sp.w_cm}xH{sp.h_cm}cm";
        item.size = ExcuteSignalRStatic.getSizeRectOrRound(db, sp, kt, kds);
        if (themAnh)
        {
            var imagePath = ExcuteSignalRStatic.mapPathSignalR($"~/{ExcuteSignalRStatic.getImageProduct(sp.ma_sanpham)}");
            byte[] imageBytes = System.IO.File.ReadAllBytes(imagePath);
            string base64String = Convert.ToBase64String(imageBytes);
            item.image = base64String;
        }
        item.sizes = new List<ThongTinSP>();
        item.colors = new List<ThongTinSP>();
        if (themMau)
        {
            string cl = item.itemNo.Substring(0, 2), dt = item.itemNo.Substring(6, 2), ms = item.itemNo.Substring(12, 2);
            var mausac = db.md_mausacs.Where(s => s.code_cl == cl & s.code_dt == dt & s.code_mau == ms).FirstOrDefault();
            string mau = mausac == null ? "" : mausac.ta_ngan;
            item.colorName = mau;

            var maTho = sp.ma_sanpham.Substring(0, 12);
            var spsMau = sps.Where(s => s.ma_sanpham.StartsWith(maTho)).OrderBy(s => s.ma_sanpham).ToList();
            foreach (var spMau in spsMau)
            {
                var itemMau = dequyTTSP(spMau, sps, false, false, false, dateStr, db, kds);
                item.colors.Add(itemMau);
            }
        }
        return item;
    }

    public void getListDSDH(HttpContext context)
    {
        string msg = "";
        try
        {
            string strdata = context.Request.Form["data"];
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(strdata);
            var result = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(data["result"] + "");
            var lst = new List<Dictionary<string, object>>();
            foreach (var a in result)
            {
                string po_lienket = a["po_lienket"] + "";
                var dsdh = db.c_donhangs.Where(s => s.sochungtu == po_lienket).FirstOrDefault();
                if (dsdh != null)
                {
                    var item = new Dictionary<string, object>();
                    item["c_danhsachdathang_id"] = dsdh.c_danhsachdathang_id;
                    item["trangthai"] = dsdh.md_trangthai_id == "HIEULUC" ? "DAHIEULUC" : "DAGUI";
                    lst.Add(item);
                }
            }
            msg = JsonConvert.SerializeObject(lst);
        }
        catch (Exception ex)
        {
            msg = "false##" + ex.Message;
        }
        context.Response.Write(msg);
    }

    public void NhanDonHang(HttpContext context)
    {
        string msg = "";

        string strdata = context.Request.Form["data"];
        try
        {
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(strdata);
            var result = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(data["result"] + "");
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.ma_dtkd == "NEXX DECOR").FirstOrDefault();
            var cangbien = db.md_cangbiens.Where(s => s.ma_cangbien == "HCMP").FirstOrDefault();
            var lstPO = new List<Dictionary<string, string>>();

            foreach (var a in result)
            {
                string emailUser = a["email"] + "";
                var user = db.nhanviens.Where(s => s.email == emailUser).FirstOrDefault();
                if (user == null)
                {
                    throw new Exception(string.Format(@"Ancotrading: nhân viên có email {0} không tồn tại", emailUser));
                }

                var item = JsonConvert.DeserializeObject<c_danhsachdathang>(a["c_danhsachdathang"] + "");
                var lstItem = JsonConvert.DeserializeObject<List<c_dongdsdh>>(a["c_dongdsdh"] + "");
                //var lstItem2 = JsonConvert.DeserializeObject<List<c_phidathang>>(a["c_phidathang"] + "");

                var mnu = new c_donhang();
                mnu.c_donhang_id = Helper.getNewId();
                mnu.md_trangthai_id = "SOANTHAO";
                mnu.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id;
                mnu.c_danhsachdathang_id = item.c_danhsachdathang_id;
                mnu.sct_dsdh = item.sochungtu;
                mnu.ngaylap = DateTime.Now;
                mnu.nguoilap = user.manv;
                mnu.shipmenttime = item.hangiaohang_po;
                mnu.shipmentdate = mnu.shipmenttime.Value.AddDays(7);
                mnu.cont20 = 0;
                mnu.cont40 = 0;
                mnu.cont40hc = 0;
                mnu.cont45 = 0;
                mnu.contle = 0;
                mnu.hoahong = 0;
                mnu.discount = item.discount;
                mnu.md_cangbien_id = cangbien.md_cangbien_id;
                mnu.sochungtu = jqGridHelper.Utils.taoChungTuPO(dtkd.md_doitackinhdoanh_id, 0, mnu.ngaylap.Value.Year.ToString());
                mnu.ngaytao = DateTime.Now;
                mnu.ngaycapnhat = DateTime.Now;
                mnu.nguoitao = user.manv;
                mnu.nguoicapnhat = user.manv;
                mnu.hoatdong = true;
                mnu.ghichu = item.so_po;
                db.c_donhangs.InsertOnSubmit(mnu);

                int stt = 0;
                foreach (var b in lstItem)
                {
                    stt++;
                    //Kiem tra SP
                    var sp = db.md_sanphams.Where(s => s.ma_sanpham == b.md_sanpham_id).FirstOrDefault();
                    if (sp == null)
                    {
                        throw new Exception(string.Format(@"Ancotrading: {0} không tồn tại", sp.ma_sanpham));
                    }
                    //Kiem tra ĐGSP mặc định
                    var qcdg = db.md_donggoisanphams.Where(s => s.md_sanpham_id == sp.md_sanpham_id & s.macdinh == true).FirstOrDefault();
                    if (qcdg == null)
                    {
                        throw new Exception(string.Format(@"Ancotrading: {0} không có đóng gói mặc định", sp.ma_sanpham));
                    }
                    //Kiem tra ĐG
                    var donggoi = db.md_donggois.Where(s => s.md_donggoi_id == qcdg.md_donggoi_id).FirstOrDefault();
                    if (donggoi == null)
                    {
                        throw new Exception(string.Format(@"Ancotrading: {0} không có đóng gói mặc định", sp.ma_sanpham));
                    }
                    //Kiem tra NCU mặc định
                    var ncumd = db.md_nhacungungmacdinhs.Where(s => s.md_sanpham_id == sp.md_sanpham_id & s.macdinh == true).FirstOrDefault();
                    if (ncumd == null)
                    {
                        throw new Exception(string.Format(@"Ancotrading: {0} không có nhà cung ứng mặc định", sp.ma_sanpham));
                    }

                    var mnu1 = new c_dongdonhang();
                    mnu1.c_dongdonhang_id = Helper.getNewId();
                    mnu1.c_donhang_id = mnu.c_donhang_id;
                    mnu1.sothutu = stt * 10;
                    mnu1.md_sanpham_id = sp.md_sanpham_id;
                    mnu1.ma_sanpham_khach = b.ma_sanpham_khach;
                    mnu1.giafob = b.gianhap;
                    mnu1.giachuan = null;
                    mnu1.discount = 0;
                    mnu1.phi = 0;
                    mnu1.barcode = "";
                    mnu1.mota_tiengviet = sp.mota_tiengviet;
                    mnu1.mota_tienganh = sp.mota_tienganh;
                    mnu1.soluong = b.sl_dathang;
                    mnu1.soluong_conlai = b.sl_dathang;
                    mnu1.soluong_daxuat = 0;
                    mnu1.soluong_dathang = 0;
                    mnu1.nhacungungid = ncumd.md_doitackinhdoanh_id;

                    // Thành phần đóng gói
                    mnu1.md_donggoi_id = donggoi.md_donggoi_id;
                    mnu1.sl_inner = donggoi.sl_inner;
                    mnu1.l1 = donggoi.l1;
                    mnu1.w1 = donggoi.w1;
                    mnu1.h1 = donggoi.h1;
                    mnu1.sl_outer = donggoi.sl_outer;
                    mnu1.l2 = donggoi.l2_mix;
                    mnu1.w2 = donggoi.w2_mix;
                    mnu1.h2 = donggoi.h2_mix;
                    mnu1.v2 = donggoi.v2;
                    mnu1.vd = donggoi.vd;
                    mnu1.vn = donggoi.vn;
                    mnu1.vl = donggoi.vl;
                    mnu1.ghichu_vachngan = donggoi.ghichu_vachngan;
                    mnu1.sl_cont = donggoi.soluonggoi_ctn;

                    mnu1.ngaytao = DateTime.Now;
                    mnu1.ngaycapnhat = DateTime.Now;
                    mnu1.nguoitao = user.manv;
                    mnu1.nguoicapnhat = user.manv;
                    mnu1.hoatdong = true;

                    //kiem tra hang hoa doc quyen
                    int count_dq = (from hdq in db.md_hanghoadocquyens
                                    where !hdq.md_doitackinhdoanh_id.Equals(mnu.md_doitackinhdoanh_id) && hdq.md_sanpham_id.Equals(sp.md_sanpham_id)
                                    select new { hdq.md_hanghoadocquyen_id }).Count();
                    int count_dqdt = (from hdq in db.md_hanghoadocquyens
                                      where hdq.md_doitackinhdoanh_id.Equals(mnu.md_doitackinhdoanh_id) && hdq.md_sanpham_id.Equals(sp.md_sanpham_id)
                                      select new { hdq.md_hanghoadocquyen_id }).Count();

                    if (count_dq > 0 && count_dqdt == 0 && donggoi.doigia_donggoi == true)
                    {
                        mnu1.trangthai = "DGDGDQ";
                    }
                    else if (count_dq > 0 && count_dqdt == 0)
                    {
                        mnu1.trangthai = "DQ";
                    }
                    else if (donggoi.doigia_donggoi == true)
                    {
                        mnu1.trangthai = "DGDG";
                    }
                    else
                    {
                        mnu1.trangthai = "BT";
                    }

                    db.c_dongdonhangs.InsertOnSubmit(mnu1);
                }

                var itemPO = new Dictionary<string, string>();
                itemPO["c_danhsachdathang_id"] = item.c_danhsachdathang_id;
                itemPO["soPO"] = mnu.sochungtu;
                lstPO.Add(itemPO);
            }

            db.SubmitChanges();

            msg += JsonConvert.SerializeObject(lstPO);
        }
        catch (Exception ex)
        {
            msg += string.Format(@"
                    <div class='error' style='color:red'>Có lỗi xảy ra: {0}</div>
                    <div style='display:none'>{1}</div>
					<div style='display:none'>{2}</div>
                    ", ex.Message, strdata, ex + "");
        }

        context.Response.Write(msg);
    }

    public void md_sanpham(HttpContext context)
    {
        var msg = "";
        var ma_sanphams = context.Request.Form["ma_sanphams"].removeAllSpaceOrTrimText(true);
        var ncc = context.Request.Form["ncc"];
        try
        {
            var lstMSP = ma_sanphams.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
            //throw new Exception(lstMSP.Count.ToString());
            var sps = new List<md_sanpham>();
            if (lstMSP.Count > 0)
            {
                sps = db.md_sanphams.Where(s => lstMSP.Contains(s.ma_sanpham)).ToList();
                foreach (var sp in sps)
                {
                    var hinhanh = ExcuteSignalRStatic.getImageProduct(sp.ma_sanpham);
                    if (!hinhanh.EndsWith(Public.imgNotFound))
                        sp.hinhanh = string.Format("Controllers/API_System.ashx?oper=loadImageProduct&msp={0}&ver={1}", sp.ma_sanpham, Helper.getNewId());
                    else
                        sp.hinhanh = "";

                    var hinhanhWeb = ExcuteSignalRStatic.getImageProductWeb(sp.ma_sanpham);
                    if (!hinhanhWeb.EndsWith(Public.imgNotFound))
                        sp.hinhanhWeb = string.Format("Controllers/API_System.ashx?oper=loadImageProductWeb&msp={0}&ver={1}", sp.ma_sanpham, Helper.getNewId());
                    else
                        sp.hinhanhWeb = "";
                }
            }
            else if (!string.IsNullOrWhiteSpace(ncc))
            {
                var dtkd = db.md_doitackinhdoanhs.Where(s => s.ma_dtkd == ncc & (s.api_xuongsx ?? "") != "").FirstOrDefault();
                if (dtkd != null)
                {
                    var spids = db.md_nhacungungmacdinhs.Where(s => s.md_doitackinhdoanh_id == dtkd.md_doitackinhdoanh_id & s.macdinh == true).Select(s => s.md_sanpham_id).Distinct().ToList();
                    int chunkSize = 2000; // Chia mỗi đợt 2000 id
                    for (int i = 0; i < spids.Count; i += chunkSize)
                    {
                        var chunk = spids.Skip(i).Take(chunkSize).ToList();
                        var result = db.md_sanphams
                                       .Where(s => chunk.Contains(s.md_sanpham_id) && s.trangthai == "DHD")
                                       .ToList();
                        sps.AddRange(result);
                    }
                }
            }

            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_chungloai(HttpContext context)
    {
        var msg = "";
        var chungloais = context.Request.Form["chungloais"].removeAllSpaceOrTrimText(true);
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_chungloai>();
            if (layhet)
            {
                sps = db.md_chungloais.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                var lstMSP = chungloais.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
                if (lstMSP.Count > 0)
                    sps = db.md_chungloais.Where(s => lstMSP.Contains(s.code_cl)).ToList();
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_chucnang(HttpContext context)
    {
        var msg = "";
        var chucnangs = context.Request.Form["chucnangs"];
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_chucnang>();
            if (layhet)
            {
                sps = db.md_chucnangs.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                var lstMSP = chucnangs.Split(',');
                sps = db.md_chucnangs.Where(s => lstMSP.Contains(s.md_chucnang_id)).ToList();
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_cangbien(HttpContext context)
    {
        var msg = "";
        var cangbiens = context.Request.Form["cangbiens"];
        try
        {
            var lstMSP = cangbiens.Split(',');
            var sps = db.md_cangbiens.Where(s => lstMSP.Contains(s.md_cangbien_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_donvitinh(HttpContext context)
    {
        var msg = "";
        var donvitinhs = context.Request.Form["donvitinhs"];
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_donvitinh>();
            if (layhet)
            {
                sps = db.md_donvitinhs.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                var lstMSP = donvitinhs.Split(',');
                sps = db.md_donvitinhs.Where(s => lstMSP.Contains(s.md_donvitinh_id)).ToList();
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }
    public void md_donvitinhsanpham(HttpContext context)
    {
        var msg = "";
        var donvitinhsanphams = context.Request.Form["donvitinhsanphams"];
        try
        {
            var lstMSP = donvitinhsanphams.Split(',');
            var sps = db.md_donvitinhsanphams.Where(s => lstMSP.Contains(s.md_donvitinhsanpham_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_hscode(HttpContext context)
    {
        var msg = "";
        var hscodes = context.Request.Form["hscodes"];
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_hscode>();
            if (layhet)
            {
                sps = db.md_hscodes.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                var lstMSP = hscodes.Split(',');
                sps = db.md_hscodes.Where(s => lstMSP.Contains(s.md_hscode_id)).ToList();
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_kieudang(HttpContext context)
    {
        var msg = "";
        var kieudangs = context.Request.Form["kieudangs"];
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_kieudang>();
            if (layhet)
            {
                sps = db.md_kieudangs.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                var lstMSP = kieudangs.Split(',');
                sps = db.md_kieudangs.Where(s => lstMSP.Contains(s.md_kieudang_id)).ToList();
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_nhomnangluc(HttpContext context)
    {
        var msg = "";
        var nhomnanglucs = context.Request.Form["nhomnanglucs"];
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_nhomnangluc>();
            if (layhet)
            {
                sps = db.md_nhomnanglucs.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                var lstMSP = nhomnanglucs.Split(',');
                sps = db.md_nhomnanglucs.Where(s => lstMSP.Contains(s.md_nhomnangluc_id)).ToList();
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_phanloaihh(HttpContext context)
    {
        var msg = "";
        var phanloaihhs = context.Request.Form["phanloaihhs"];
        try
        {
            var lstMSP = phanloaihhs.Split(',');
            var sps = db.md_phanloaihhs.Where(s => lstMSP.Contains(s.md_phanloaihh_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_donggoisanpham(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"].removeAllSpaceOrTrimText(true);
        var chuan = context.Request.Form["chuan"] == "true";
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_donggoisanpham>();
            var lstMSP = sanphams.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
            int chunkSize = 2000; // Chia mỗi đợt 2000 id
            for (int i = 0; i < lstMSP.Count; i += chunkSize)
            {
                var chunk = lstMSP.Skip(i).Take(chunkSize).ToList();
                var result = db.md_donggoisanphams
                               .Where(s => chunk.Contains(s.md_sanpham_id));
                if (chuan)
                    result = result.Where(s => s.macdinh == true);

                sps.AddRange(result.ToList());
            }

            msg = "1" + JsonConvert.SerializeObject(sps.ToList());
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_donggoi(HttpContext context)
    {
        var msg = "";
        var donggois = context.Request.Form["donggois"].removeAllSpaceOrTrimText(true);
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_donggoi>();
            if (layhet)
            {
                sps = db.md_donggois.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                var lstMSP = donggois.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
                int chunkSize = 2000; // Chia mỗi đợt 2000 id
                for (int i = 0; i < lstMSP.Count; i += chunkSize)
                {
                    var chunk = lstMSP.Skip(i).Take(chunkSize).ToList();
                    var result = db.md_donggois
                                   .Where(s => chunk.Contains(s.md_donggoi_id));
                    sps.AddRange(result.ToList());
                }
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_hanghoadocquyen(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"].removeAllSpaceOrTrimText(true);
        try
        {
            var sps = new List<md_hanghoadocquyen>();
            var lstMSP = sanphams.Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();
            int chunkSize = 2000; // Chia mỗi đợt 2000 id
            for (int i = 0; i < lstMSP.Count; i += chunkSize)
            {
                var chunk = lstMSP.Skip(i).Take(chunkSize).ToList();
                var result = db.md_hanghoadocquyens
                               .Where(s => chunk.Contains(s.md_sanpham_id));
                sps.AddRange(result.ToList());
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_doitackinhdoanh(HttpContext context)
    {
        var msg = "";
        var doitackinhdoanhs = context.Request.Form["doitackinhdoanhs"].removeAllSpaceOrTrimText(true);
        try
        {
            var sps = new List<md_doitackinhdoanh>();
            var lstMSP = doitackinhdoanhs.Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();
            if (lstMSP.Count > 0)
            {
                int chunkSize = 2000; // Chia mỗi đợt 2000 id
                for (int i = 0; i < lstMSP.Count; i += chunkSize)
                {
                    var chunk = lstMSP.Skip(i).Take(chunkSize).ToList();
                    var result = db.md_doitackinhdoanhs
                                   .Where(s => chunk.Contains(s.md_doitackinhdoanh_id));
                    sps.AddRange(result.ToList());
                }
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_cangxuathang(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"];
        try
        {
            var lstMSP = sanphams.Split(',');
            var sps = db.md_cangxuathangs.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_bientau(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"];
        try
        {
            var lstMSP = sanphams.Split(',');
            var sps = db.md_bientaus.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_nhacungungmacdinh(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"];
        try
        {
            var lstMSP = sanphams.Split(',');
            var sps = db.md_nhacungungmacdinhs.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_giasanpham(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"].removeAllSpaceOrTrimText(true);
        var phienbangias = context.Request.Params["phienbangias"].removeAllSpaceOrTrimText(true);
        try
        {
            var sps = new List<md_giasanpham>();
            var lstMSP = sanphams.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
            if (lstMSP.Count > 0)
            {
                var bgBans = db.md_banggias.Where(s => s.banggiaban == true & s.ten_banggia.StartsWith("FOB") & s.hoatdong == true).ToList();
                var bgIds = bgBans.Select(s => s.md_banggia_id).ToList();
                var pbgBan = db.md_phienbangias.Where(s => bgIds.Contains(s.md_banggia_id) & s.md_trangthai_id == "HIEULUC" & s.hoatdong == true).OrderByDescending(s => s.ngay_hieuluc).FirstOrDefault();
                var pbgId = pbgBan == null ? "" : pbgBan.md_phienbangia_id;
                sps = db.md_giasanphams.Where(s => lstMSP.Contains(s.md_sanpham_id) & s.md_phienbangia_id == pbgId).ToList();
            }
            else
            {
                lstMSP = phienbangias.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
                if (lstMSP.Count > 0)
                {
                    sps = db.md_giasanphams.Where(s => lstMSP.Contains(s.md_phienbangia_id)).ToList();
                }
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_phienbangia(HttpContext context)
    {
        var msg = "";
        var phienbangias = context.Request.Form["phienbangias"].removeAllSpaceOrTrimText(true);
        var banggias = context.Request.Params["banggias"].removeAllSpaceOrTrimText(true);
        try
        {
            var sps = new List<md_phienbangia>();
            var lstMSP = phienbangias.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
            if (lstMSP.Count > 0)
                sps = db.md_phienbangias.Where(s => lstMSP.Contains(s.md_phienbangia_id) & s.hoatdong == true).ToList();
            else
            {
                lstMSP = banggias.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
                if (lstMSP.Count > 0)
                    sps = db.md_phienbangias.Where(s => lstMSP.Contains(s.md_banggia_id) & s.hoatdong == true).ToList();
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_banggia(HttpContext context)
    {
        var msg = "";
        var banggias = context.Request.Form["banggias"].removeAllSpaceOrTrimText(true);
        var ncc = context.Request.Params["ncc"].removeAllSpaceOrTrimText(true);
        try
        {
            var sps = new List<md_banggia>();
            var lstMSP = banggias.Split(',').Where(s => !string.IsNullOrEmpty(s)).ToList();
            if (lstMSP.Count > 0)
                sps = db.md_banggias.Where(s => lstMSP.Contains(s.md_banggia_id)).ToList();
            else if (!string.IsNullOrWhiteSpace(ncc))
                sps = db.md_banggias.Where(s => s.ten_banggia == $"{ncc}-GIAMUA").ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_detai(HttpContext context)
    {
        var msg = "";
        var detais = context.Request.Form["detais"].removeAllSpaceOrTrimText(true);
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_detai>();
            var lstMSP = detais.Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();
            if (layhet)
            {
                sps = db.md_detais.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                if (lstMSP.Count > 0)
                {
                    foreach (var msp in lstMSP)
                    {
                        var cldt = msp.Split('-');
                        var cl = cldt[0];
                        var dt = cldt[1];
                        var sp = db.md_detais.Where(s => s.code_cl == cl & s.code_dt == dt).FirstOrDefault();
                        if (sp != null)
                        {
                            sps.Add(sp);
                        }
                    }
                }
            }

            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_mausac(HttpContext context)
    {
        var msg = "";
        var mausacs = context.Request.Form["mausacs"].removeAllSpaceOrTrimText(true);
        var layhet = context.Request.Params["layhet"] == "1";
        try
        {
            var sps = new List<md_mausac>();
            var lstMSP = mausacs.Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();
            if (layhet)
            {
                sps = db.md_mausacs.Where(s => s.hoatdong == true).ToList();
            }
            else
            {
                foreach (var msp in lstMSP)
                {
                    var cldt = msp.Split('-');
                    var cl = cldt[0];
                    var dt = cldt[1];
                    var ms = cldt[2];
                    var sp = db.md_mausacs.Where(s => s.code_cl == cl & s.code_dt == dt & s.code_mau == ms).FirstOrDefault();
                    if (sp != null)
                    {
                        sps.Add(sp);
                    }
                }
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void imageDeTai(HttpContext context)
    {
        var name = context.Request.Params["name"];
        var url = ExcuteSignalRStatic.mapPathSignalR("~/" + Public.imgPattern + name);
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (System.IO.File.Exists(url))
        {
            context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
            context.Response.TransmitFile(url);
        }
        else
            context.Response.Write(url);
    }

    public void imageMauSac(HttpContext context)
    {
        var name = context.Request.Params["name"];
        var url = ExcuteSignalRStatic.mapPathSignalR("~/" + Public.imgColor + name);
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (System.IO.File.Exists(url))
        {
            context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
            context.Response.TransmitFile(url);
        }
        else
            context.Response.Write(url);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}