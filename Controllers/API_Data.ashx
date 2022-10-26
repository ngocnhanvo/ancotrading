<%@ WebHandler Language="C#" Class="API_Data" %>

using System;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using Newtonsoft.Json;

public class API_Data : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.Params["oper"];
        switch (oper)
        {
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
            case "getList":
                this.getList(context);
                break;
        }
    }

    public void getList(HttpContext context)
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
                var user = db.nhanviens.Where(s => s.email == a["email"] + "").FirstOrDefault();
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

                    var sp = db.md_sanphams.Where(s => s.ma_sanpham == b.md_sanpham_id).FirstOrDefault();
                    var qcdg = db.md_donggoisanphams.Where(s => s.md_sanpham_id == sp.md_sanpham_id & s.macdinh == true).FirstOrDefault();
                    var donggoi = db.md_donggois.Where(s => s.md_donggoi_id == qcdg.md_donggoi_id).FirstOrDefault();
                    var ncumd = db.md_nhacungungmacdinhs.Where(s => s.md_sanpham_id == sp.md_sanpham_id & s.macdinh == true).FirstOrDefault();
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
        var ma_sanphams = context.Request.Form["ma_sanphams"];
        try
        {
            var lstMSP = ma_sanphams.Split(',');
            var sps = db.md_sanphams.Where(s => lstMSP.Contains(s.ma_sanpham)).ToList();
            foreach(var sp in sps)
            {
                sp.hinhanh = ExcuteSignalRStatic.getImageProduct(sp.ma_sanpham);
                sp.hinhanhWeb = ExcuteSignalRStatic.getImageProductWeb(sp.ma_sanpham);
            }
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_chungloai(HttpContext context)
    {
        var msg = "";
        var chungloais = context.Request.Form["chungloais"];
        try
        {
            var lstMSP = chungloais.Split(',');
            var sps = db.md_chungloais.Where(s => lstMSP.Contains(s.md_chungloai_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_chucnang(HttpContext context)
    {
        var msg = "";
        var chucnangs = context.Request.Form["chucnangs"];
        try
        {
            var lstMSP = chucnangs.Split(',');
            var sps = db.md_chucnangs.Where(s => lstMSP.Contains(s.md_chucnang_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
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
        catch(Exception ex)
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
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_hscode(HttpContext context)
    {
        var msg = "";
        var hscodes = context.Request.Form["hscodes"];
        try
        {
            var lstMSP = hscodes.Split(',');
            var sps = db.md_hscodes.Where(s => lstMSP.Contains(s.md_hscode_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_kieudang(HttpContext context)
    {
        var msg = "";
        var kieudangs = context.Request.Form["kieudangs"];
        try
        {
            var lstMSP = kieudangs.Split(',');
            var sps = db.md_kieudangs.Where(s => lstMSP.Contains(s.md_kieudang_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_nhomnangluc(HttpContext context)
    {
        var msg = "";
        var nhomnanglucs = context.Request.Form["nhomnanglucs"];
        try
        {
            var lstMSP = nhomnanglucs.Split(',');
            var sps = db.md_nhomnanglucs.Where(s => lstMSP.Contains(s.md_nhomnangluc_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
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
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_donggoisanpham(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"];
        var chuan = context.Request.Form["chuan"] == "true";
        try
        {
            var lstMSP = sanphams.Split(',');
            var sps = db.md_donggoisanphams.Where(s => lstMSP.Contains(s.md_sanpham_id));
            if (chuan)
                sps.Where(s => s.macdinh == true);
            msg = "1" + JsonConvert.SerializeObject(sps.ToList());
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_donggoi(HttpContext context)
    {
        var msg = "";
        var donggois = context.Request.Form["donggois"];
        try
        {
            var lstMSP = donggois.Split(',');
            var sps = db.md_donggois.Where(s => lstMSP.Contains(s.md_donggoi_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_hanghoadocquyen(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"];
        try
        {
            var lstMSP = sanphams.Split(',');
            var sps = db.md_hanghoadocquyens.Where(s => lstMSP.Contains(s.md_sanpham_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_doitackinhdoanh(HttpContext context)
    {
        var msg = "";
        var doitackinhdoanhs = context.Request.Form["doitackinhdoanhs"];
        try
        {
            var lstMSP = doitackinhdoanhs.Split(',');
            var sps = db.md_doitackinhdoanhs.Where(s => lstMSP.Contains(s.md_doitackinhdoanh_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
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
        catch(Exception ex)
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
        catch(Exception ex)
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
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_giasanpham(HttpContext context)
    {
        var msg = "";
        var sanphams = context.Request.Form["sanphams"];
        try
        {
            var lstMSP = sanphams.Split(',');
            var bgBans = db.md_banggias.Where(s => s.banggiaban == true & s.ten_banggia.StartsWith("FOB") & s.hoatdong == true).ToList();
            var bgIds = bgBans.Select(s => s.md_banggia_id).ToList();
            var pbgBan = db.md_phienbangias.Where(s => bgIds.Contains(s.md_banggia_id) & s.md_trangthai_id == "HIEULUC" & s.hoatdong == true).OrderByDescending(s=>s.ngay_hieuluc).FirstOrDefault();
            var pbgId = pbgBan == null ? "" : pbgBan.md_phienbangia_id;
            var sps = db.md_giasanphams.Where(s => lstMSP.Contains(s.md_sanpham_id) & s.md_phienbangia_id == pbgId).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_phienbangia(HttpContext context)
    {
        var msg = "";
        var phienbangias = context.Request.Form["phienbangias"];
        try
        {
            var lstMSP = phienbangias.Split(',');
            var sps = db.md_phienbangias.Where(s => lstMSP.Contains(s.md_phienbangia_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_banggia(HttpContext context)
    {
        var msg = "";
        var banggias = context.Request.Form["banggias"];
        try
        {
            var lstMSP = banggias.Split(',');
            var sps = db.md_banggias.Where(s => lstMSP.Contains(s.md_banggia_id)).ToList();
            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_detai(HttpContext context)
    {
        var msg = "";
        var detais = context.Request.Form["detais"];
        try
        {
            var sps = new List<md_detai>();
            var lstMSP = detais.Split(',');
            foreach(var msp in lstMSP)
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

            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void md_mausac(HttpContext context)
    {
        var msg = "";
        var mausacs = context.Request.Form["mausacs"];
        try
        {
            var sps = new List<md_mausac>();
            var lstMSP = mausacs.Split(',');
            foreach(var msp in lstMSP)
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

            msg = "1" + JsonConvert.SerializeObject(sps);
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }
        context.Response.Write(msg);
    }

    public void imageDeTai(HttpContext context)
    {
        var name = context.Request.Form["name"];
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
        var name = context.Request.Form["name"];
        var url = ExcuteSignalRStatic.mapPathSignalR("~/" + Public.imgColor + name);
        var lastIndex = url.LastIndexOf(".");
        var mimeType = url.Substring(lastIndex + 1).ToLower();

        if (System.IO.File.Exists(url))
        {
            context.Response.ContentType = mimeType == "jpg" ? "image/jpeg" : (mimeType == "png" ? "image/png" : "image/gif");
            context.Response.TransmitFile(url);
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}