<%@ WebHandler Language="C#" Class="DanhSachDatHangController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Data;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;

public class DanhSachDatHangController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();
    public String path = HttpContext.Current.Server.MapPath("~/FileSendMail/");
    public String logoPath = HttpContext.Current.Server.MapPath("~/images/anco_logo_print.png");
    public String productImagePath = HttpContext.Current.Server.MapPath("~/images/products/fullsize/");
    public string CHUAGUI = "CHUAGUI", TUCHOI = "TUCHOI", DANHAN = "DANHAN", DAHIEULUC = "DAHIEULUC";
    public List<Dictionary<string, string>> msgPublics = new List<Dictionary<string, string>> {
        new Dictionary<string, string>()
        {
            { "ANCO1", "" },
        },
        new Dictionary<string, string>()
        {
            { "ANHIEPLUC", "" },
        }
    };

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "getpiinformation":
                this.getPiInformation(context);
                break;
            case "startsendmail":
                this.startSendMail(context);
                break;
            case "sendmail":
                this.sendMail(context);
                break;

            case "activepi":
                this.activePI(context);
                break;

            case "getoption":
                this.getSelectOption(context);
                break;

            case "guidonhang":
                this.guidonhang(context);
                break;
            case "danhsachdathang":
                this.danhsachdathang(context);
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

    public void danhsachdathang(HttpContext context)
    {
        var lst = new List<string>();
        lst.Add("");
        lst.Add(null);
        lst.Add(CHUAGUI);
        lst.Add(TUCHOI);
        lst.Add("DAGUI");
        lst.Add(DANHAN);
        lst.Add(DAHIEULUC);
        var msgs = new List<Dictionary<string, string>>(msgPublics);
        foreach (var msg in msgs)
        {
            var madtkd = msg.Keys.FirstOrDefault();
            string mdtkdId = db.md_doitackinhdoanhs.Where(s => s.ma_dtkd == madtkd).Select(s => s.md_doitackinhdoanh_id).FirstOrDefault();
            var dsdhs = db.c_danhsachdathangs.Where(s => lst.Contains(s.trangthai) & s.md_doitackinhdoanh_id == mdtkdId & s.md_trangthai_id != "KETTHUC");
            var item = new Dictionary<string, object>();

            try
            {
                item["result"] = dsdhs.Select(s => new { s.c_danhsachdathang_id }).ToList();

                msg[madtkd] = Extension.GetModule(
                    Extension.API_ALL(madtkd) + "?oper=getListDSDH",
                                    item
                                );
                if (!msg[madtkd].Contains("false##"))
                {
                    var data = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(msg[madtkd]);
                    foreach (var a in dsdhs)
                    {
                        var dsdhDic = data.Where(s => s["c_danhsachdathang_id"] + "" == a.c_danhsachdathang_id).FirstOrDefault();
                        string trangthai = "", hdlhsStr = "", ttsStr = "", huongdanlamhang = "", huongdanlamhangchung = "";
                        if (dsdhDic != null)
                        {
                            trangthai = dsdhDic["trangthai"].ToString();
                            hdlhsStr = dsdhDic["hdlhs"].ToString();
                            ttsStr = dsdhDic["tts"].ToString();
                            huongdanlamhang = dsdhDic["huongdanlamhang"].ToString();
                            huongdanlamhangchung = dsdhDic["huongdanlamhangchung"].ToString();
                        }

                        if (!string.IsNullOrEmpty(trangthai))
                        {
                            if (a.trangthai != DAHIEULUC)
                            {
                                if (trangthai == DANHAN)
                                    a.trangthai = DANHAN;
                                else if (trangthai == "DAGUI")
                                    a.trangthai = "DAGUI";
                                else
                                    a.trangthai = DAHIEULUC;

                                a.huongdanlamhang = huongdanlamhang;
                                a.huongdanlamhangchung = huongdanlamhangchung;
                            }

                            if (!string.IsNullOrWhiteSpace(hdlhsStr))
                            {
                                var hdlhs = JsonConvert.DeserializeObject<List<md_ghichuhdlh>>(hdlhsStr);
                                foreach (var hdlh in hdlhs)
                                {
                                    var hdlhMain = db.md_ghichuhdlhs.Where(s => s.md_ghichuhdlh_id == hdlh.md_ghichuhdlh_id).FirstOrDefault();
                                    if (hdlhMain != null)
                                    {
                                        hdlhMain.trangthai = hdlh.trangthai;
                                        hdlhMain.ngayxacnhan = hdlh.ngayxacnhan;
                                        hdlhMain.nguoixacnhan = hdlh.value_nguoicapnhat;
                                        //hdlhMain.mota = hdlh.mota;
                                    }
                                }
                            }

                            if (!string.IsNullOrWhiteSpace(ttsStr))
                            {
                                var tts = JsonConvert.DeserializeObject<List<md_taptin>>(ttsStr);
                                foreach (var tt in tts)
                                {
                                    var hdlhMain = db.md_taptins.Where(s => s.md_taptin_id == tt.md_taptin_id).FirstOrDefault();
                                    if (hdlhMain != null)
                                    {
                                        hdlhMain.trangthai = tt.trangthai;
                                        hdlhMain.ngayxacnhan = tt.ngayxacnhan;
                                        hdlhMain.nguoixacnhan = tt.value_nguoicapnhat;
                                        if(tt.trangthai == TUCHOI)
                                            hdlhMain.lydotuchoi = tt.mota;
                                    }
                                }
                            }
                        }
                        else if(a.trangthai != DAHIEULUC)
                        {
                            if (a.trangthai != CHUAGUI & !string.IsNullOrEmpty(a.trangthai))
                            {
                                a.trangthai = TUCHOI;
                                var taptins = db.md_taptins.Where(s => s.lienket == a.c_danhsachdathang_id & s.trangthai != CHUAGUI).ToList();
                                foreach (var taptin in taptins)
                                {
                                    taptin.trangthai = CHUAGUI;
                                    taptin.ngayxacnhan = null;
                                }

                                var hdlhs = db.md_ghichuhdlhs.Where(s => s.lienket == a.c_danhsachdathang_id & s.trangthai != CHUAGUI).ToList();
                                foreach (var hdlh in hdlhs)
                                {
                                    hdlh.trangthai = CHUAGUI;
                                    hdlh.ngayxacnhan = null;
                                }
                            }
                            else
                            {
                                a.trangthai = CHUAGUI;
                            }
                        }
                    }

                    mdbc.ExcuteNonQuery("ALTER TABLE c_danhsachdathang DISABLE TRIGGER updateSLDaDatTrenPO");
                    mdbc.ExcuteNonQuery("ALTER TABLE c_danhsachdathang DISABLE TRIGGER TrigUpdateSoPI");
                    mdbc.ExcuteNonQuery("ALTER TABLE c_danhsachdathang DISABLE TRIGGER updateGoiHDLH");
                    db.SubmitChanges();
                    mdbc.ExcuteNonQuery("ALTER TABLE c_danhsachdathang ENABLE  TRIGGER updateSLDaDatTrenPO");
                    mdbc.ExcuteNonQuery("ALTER TABLE c_danhsachdathang ENABLE  TRIGGER TrigUpdateSoPI");
                    mdbc.ExcuteNonQuery("ALTER TABLE c_danhsachdathang ENABLE  TRIGGER updateGoiHDLH");
                }
            }
            catch (Exception ex)
            {
                msg[madtkd] = ex.ToString();
            }
        }

        context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(msgs));
    }

    private void guidonhangSendMail(HttpContext context, List<Dictionary<string, object>> lstMail, nhanvien nv, GoogleMail mail, string madtkd, string mailNN)
    {
        foreach (var mailObj in lstMail.Where(s => s["ma_dtkd"].ToString() == madtkd))
        {
            string emailCC = "";

            if (string.IsNullOrEmpty(nv.email_cc) & string.IsNullOrEmpty(UserUtils.mailKCS))
            {
                emailCC = "";
            }
            else if (string.IsNullOrEmpty(nv.email_cc))
            {
                emailCC = UserUtils.mailKCS;
            }
            else if (string.IsNullOrEmpty(UserUtils.mailKCS))
            {
                emailCC = nv.email_cc;
            }
            else
            {
                emailCC = nv.email_cc + "," + UserUtils.mailKCS;
            }

            if (string.IsNullOrWhiteSpace(emailCC))
                emailCC = nv.email;
            else
                emailCC = emailCC + "," + nv.email;

            var dsdh = mailObj["dsdh"] as c_danhsachdathang;
            string fileTTSP = taoFileThongTinSanPham(context, nv.manv, dsdh);
            var fileDDHsKhongGia = taoFileDonDatHang(context, nv.manv, mailObj["ma_dtkd"].ToString(), dsdh, false);
            string fileXNBB = taoFileXacNhanBaoBi(context, nv.manv, dsdh);
            string emailkt = mailObj["email"] + "";
            if (!string.IsNullOrWhiteSpace(mailNN))
                emailkt = emailkt + "," + mailNN;

            string fileXNXH = context.Request.Form["xnxh"];
            if (!string.IsNullOrEmpty(emailkt))
            {
                var atts = new List<System.Net.Mail.Attachment>();
                var att = new System.Net.Mail.Attachment(fileXNXH);
                var name = "Phiếu XNXH.xls";
                att.Name = name;
                atts.Add(att);

                att = new System.Net.Mail.Attachment(fileTTSP);
                name = "Thông tin sản phẩm.xls";
                att.Name = name;
                atts.Add(att);

                att = new System.Net.Mail.Attachment(fileDDHsKhongGia[0]);
                name = "Đơn đặt hàng.xls";
                att.Name = name;
                atts.Add(att);

                att = new System.Net.Mail.Attachment(fileDDHsKhongGia[1]);
                name = "Đơn đặt hàng.pdf";
                att.Name = name;
                atts.Add(att);

                att = new System.Net.Mail.Attachment(fileXNBB);
                name = "Xác nhận bao bì.xls";
                att.Name = name;
                atts.Add(att);

                mail.Send(
                    nv.email
                    , emailkt
                    , emailCC
                    , ""
                    , mailObj["tieude"].ToString()
                    , mailObj["noidung"].ToString()
                    , atts
                );
            }
        }
    }

    public string EncodeHTML_DSDH(string a) {
        if(a == null) {
            a = "";
        }
        a = a.Replace("&", "%26");
        a = a.Replace("+", "%2B");
        a = a.Replace("&", "%26");
        a = a.Replace("+", "%2B");
        return a;
    }

    public void guidonhang(HttpContext context)
    {
        String manv = UserUtils.getUser(context);
        var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
        var smtp = db.md_smtps.FirstOrDefault(p => p.macdinh.Equals(true));
        var mail = new GoogleMail(nv.email, nv.email_pass, smtp.smtpserver, smtp.port.Value, smtp.use_ssl.GetValueOrDefault(false));
        var tmp = db.md_mailtemplates.FirstOrDefault(p => p.use_for.Equals("PI") && p.ten_template == "PI_VG");
        string msg = "", vnn_msg = "";
        string id = context.Request.Form["id"];
        var type = "1";
        var mailNN = context.Request.Form["mailNN"];
        string[] vnn = id.Split(',');
        var lstMail = new List<Dictionary<string, object>>();

        var lstDTKD = new List<Dictionary<string, Dictionary<string, object>>>();

        var lstPO = new List<Dictionary<string, string>>();

        var lstDSDH = db.c_danhsachdathangs.Where(s => vnn.Contains(s.c_danhsachdathang_id));
        //
        var arrGuiDonHangHeThong = new List<string>();
        foreach (var msgPL in msgPublics)
        {
            var madtkd = msgPL.Keys.FirstOrDefault();
            arrGuiDonHangHeThong.Add(madtkd);
        }

        foreach (var dsdh in lstDSDH)
        {
            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dsdh.md_doitackinhdoanh_id).FirstOrDefault();

            if (dsdh.md_trangthai_id != "SOANTHAO")
                msg += $@"Lỗi:Dòng ""{dsdh.sochungtu}"" đã hiệu lực.<br>";
            else if (dsdh.trangthai == "DAGUI")
                msg += $@"Lỗi:Dòng ""{dsdh.sochungtu}"" đã được gửi trước đó.<br>";
            else if(!arrGuiDonHangHeThong.Contains(dtkd.ma_dtkd))
                msg += $@"Lỗi:""{dtkd.ma_dtkd}"" chưa triển khai chức năng này.<br>";
            else
            {
                var dsdh2 = new c_danhsachdathang();
                dsdh.CopyPropertiesTo(dsdh2);
                dsdh2.trangthai = "DAGUI";
                dsdh2.md_doitackinhdoanh_id = "ANCOTRADING";
                dsdh2.sochungtu = EncodeHTML_DSDH(dsdh2.sochungtu);
                dsdh2.so_po = EncodeHTML_DSDH(dsdh2.so_po);
                dsdh2.mota = string.IsNullOrEmpty(dsdh2.mota) ? "" : EncodeHTML_DSDH(dsdh2.mota);
                if (string.IsNullOrEmpty(dsdh2.huongdanlamhang))
                    dsdh2.huongdanlamhang = "";
                dsdh2.huongdanlamhang = EncodeHTML_DSDH(dsdh2.huongdanlamhang);
                if (string.IsNullOrEmpty(dsdh2.huongdanlamhangchung))
                    dsdh2.huongdanlamhangchung = "";
                dsdh2.huongdanlamhangchung = EncodeHTML_DSDH(dsdh2.huongdanlamhangchung);

                if (string.IsNullOrEmpty(dsdh2.diachigiaohang))
                    dsdh2.diachigiaohang = "";
                dsdh2.diachigiaohang = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dsdh2.diachigiaohang).Select(s => s.ma_dtkd).FirstOrDefault();
                vnn_msg += string.Format(@"<div style='color:blue'>Gửi đơn hàng ""{0}"" thành công.</div>", dsdh.sochungtu);
                var item = new Dictionary<string, object>();
                item["c_danhsachdathang"] = dsdh2;

                var dongdsdh = db.c_dongdsdhs.
                        Where(s => s.c_danhsachdathang_id == dsdh2.c_danhsachdathang_id).
                        Select(x => new
                        {
                            x.w2,
                            x.w1,
                            x.vn,
                            x.vl,
                            x.vd,
                            x.v2,
                            tem_dan = EncodeHTML_DSDH(x.tem_dan),
                            x.sothutu,
                            x.sl_inner,
                            dvt_inner = db.md_donvitinhs.FirstOrDefault(t => t.md_donvitinh_id == db.md_donggois.FirstOrDefault(tt => tt.md_donggoi_id == x.md_donggoi_id).dvt_inner).ten_dvt,
                            x.sl_outer,
                            dvt_outer = db.md_donvitinhs.FirstOrDefault(t => t.md_donvitinh_id == db.md_donggois.FirstOrDefault(tt => tt.md_donggoi_id == x.md_donggoi_id).dvt_outer).ten_dvt,
                            x.sl_huy,
                            x.sl_dathang,
                            x.sl_dagiao,
                            x.sl_cont,
                            x.sl_conlai,
                            mota = EncodeHTML_DSDH(x.mota),
                            md_sanpham_id = db.md_sanphams.Where(t => t.md_sanpham_id == x.md_sanpham_id).Select(t => t.ma_sanpham).FirstOrDefault(),
                            x.md_donggoi_id,
                            x.md_doitackinhdoanh_id,
                            ma_sanpham_khach = EncodeHTML_DSDH(x.ma_sanpham_khach),
                            x.l2,
                            x.l1,
                            huongdan_dathang = EncodeHTML_DSDH(x.huongdan_dathang),
                            x.h2,
                            x.h1,
                            x.gianhap,
                            x.giachuan,
                            ghichu_vachngan = EncodeHTML_DSDH(x.ghichu_vachngan),
                            x.c_dongdsdh_id,
                            x.c_dongdonhang_id,
                            x.c_danhsachdathang_id
                        })
                        .ToList();

                var phidsdh = db.c_phidathangs.
                    Where(s => s.c_danhsachdathang_id == dsdh2.c_danhsachdathang_id).
                    Select(x => new
                    {
                        x.sotien,
                        x.isphicong,
                        mota = EncodeHTML_DSDH(x.mota),
                        x.c_phidathang_id,
                        x.c_danhsachdathang_id
                    })
                    .ToList();

                item["c_dongdsdh"] = dongdsdh;
                item["c_phidathang"] = phidsdh;
                item["email"] = mailNN;

                var itemDTKD = new Dictionary<string, Dictionary<string, object>>();
                itemDTKD[dtkd.ma_dtkd] = item;
                lstDTKD.Add(itemDTKD);

                var itemPO = new Dictionary<string, string>();
                itemPO["c_danhsachdathang_id"] = dsdh2.c_danhsachdathang_id;
                itemPO["soPO"] = "";
                lstPO.Add(itemPO);

                if (tmp != null)
                {
                    decimal? phicong = 0, phitru = 0, discount = 0;
                    decimal cong = 0, tru = 0;
                    phicong = phidsdh.Where(p => p.isphicong.Equals(true)).Select(p => p.sotien).Sum();
                    phitru = phidsdh.Where(p => p.isphicong.Equals(false)).Select(p => p.sotien).Sum();

                    cong = phicong == null ? 0 : phicong.Value;
                    tru = phitru == null ? 0 : phitru.Value;

                    decimal? giatridonhang = 0;
                    if (dsdh.total != null & dsdh.discount != 100)
                    {
                        if (dsdh.discount > 0)
                        {
                            discount = (dsdh.total.Value * dsdh.discount / 100);
                        }
                        giatridonhang = dsdh.total.Value - discount + cong - tru;
                    }

                    string noidung = tmp.content_mail
                        .Replace("%0D", "<br/>")
                        .Replace("[NGAYLAP]", dsdh.ngaylap.Value.ToString("dd/MM/yyyy"));

                    noidung = noidung.Replace("[CHUNGTUDATHANG]", dsdh.sochungtu);
                    noidung = noidung.Replace("[SOPO]", dsdh.so_po);
                    noidung = noidung.Replace("[NHACUNGUNG]", dtkd.ten_dtkd);
                    noidung = noidung.Replace("[NGAYGIAOHANG]", dsdh.hangiaohang_po.Value.ToString("dd/MM/yyyy"));
                    noidung = noidung.Replace("[SOLUONGMAHANG]", dongdsdh.Count().ToString());
                    noidung = noidung.Replace("[GIATRIDONHANG]", "đã ẩn");
                    noidung = Public.DecodeHTML(noidung);
                    string tieude = tmp.subject_mail;
                    tieude = tieude.Replace("[CHUNGTUDATHANG]", dsdh.sochungtu);
                    tieude = tieude.Replace("[SOPO]", dsdh.so_po);
                    tieude = tieude.Replace("[NGAYLAP]", dsdh.ngaylap == null ? "" : dsdh.ngaylap.Value.ToString("dd/MM/yyyy"));

                    var mailObj = new Dictionary<string, object>();
                    mailObj["tieude"] = tieude;
                    mailObj["noidung"] = noidung;
                    mailObj["ma_dtkd"] = dtkd.ma_dtkd;
                    mailObj["email"] = dtkd.email;
                    mailObj["emailkt"] = dtkd.emailkt;
                    mailObj["dsdh"] = dsdh;
                    lstMail.Add(mailObj);
                }
            }
        }

        if (lstDTKD.Count > 0)
        {
            foreach (var msgPL in msgPublics)
            {
                string msgDT = "", msgDTSuccess = "", msgDTFail = "";
                var madtkd = msgPL.Keys.FirstOrDefault();
                var sends = lstDTKD.Where(s => s.Keys.Contains(madtkd)).ToList();
                if (sends.Count > 0)
                {
                    var lstSend = new List<Dictionary<string, object>>();
                    foreach (var send in sends)
                    {
                        lstSend.Add(send[madtkd]);
                    }

                    if (type == "1")
                    {
                        var item = new Dictionary<string, object>();
                        item["result"] = lstSend;
                        try
                        {
                            string link = Extension.API_ALL(madtkd) + "?oper=NhanDonHang";
                            msgDT += Extension.GetModule(link, item);
                        }
                        catch (Exception ex)
                        {
                            msgDTFail += $"<div style='display:none'>{ex}</div>";
                            msgDTFail += $"err{madtkd}: {ex.Message}";
                        }
                    }

                    if (!msgDT.Contains("error") & !msgDT.Contains("Có lỗi xảy ra") & msgDTFail.Length <= 0)
                    {
                        try
                        {
                            if (type == "0" | msgDT.Length <= 0)
                            {
                                msgDT = JsonConvert.SerializeObject(lstPO);
                            }

                            var sctDonHangs = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(msgDT);
                            foreach (var sctDH in sctDonHangs)
                            {
                                var c_danhsachdathang_id = "";
                                if(sctDH.ContainsKey("c_danhsachdathang_id"))
                                    c_danhsachdathang_id = sctDH["c_danhsachdathang_id"];

                                var soPO = "";
                                if (sctDH.ContainsKey("soPO"))
                                    soPO = sctDH["soPO"];

                                var dsdh = db.c_danhsachdathangs.Where(s => s.c_danhsachdathang_id == c_danhsachdathang_id).FirstOrDefault();
                                if (dsdh != null)
                                {
                                    if (type == "1")
                                        dsdh.trangthai = "DAGUI";

                                    msgDTSuccess += $@"<div style='color:blue'>Gửi đơn hàng ""{dsdh.sochungtu}"" thành công.</div>";
                                }
                            }

                            if (msgDTSuccess.Length > 0)
                                db.SubmitChanges();
                        }
                        catch (Exception ex)
                        {
                            msgDT += $"<div style='color:red'>Lỗi: {ex.Message}.</div>";
                        }

                        if (msgDTSuccess.Length > 0)
                        {
                            msgDT = msgDTSuccess;
                            try
                            {
                                guidonhangSendMail(context, lstMail, nv, mail, madtkd, mailNN);
                            }
                            catch (Exception ex)
                            {
                                msgDT += $"<div style='color:red'>Gửi mail thất bại: {ex.Message}.</div>";
                            }
                        }
                    }
                    else if(msgDTFail.Length > 0)
                    {
                        msgDT = msgDTFail;
                    }
                }

                msg += msgDT;
            }
        }

        context.Response.Write(msg);
    }

    public string getSqlThongTinSP(string c_danhsachdathang_id)
    {
        String sql = "select * from dbo.f_ttsanpham_dsdh('" + c_danhsachdathang_id + "')";
        return sql;
    }

    public string getSqlDsdhPdf(string c_danhsachdathang_id, bool guiNCC)
    {
        string gianhap = "null", thanhtien = "null";
        if (guiNCC == false)
        {
            gianhap = "ddsdh.gianhap";
            thanhtien = "(ddsdh.sl_dathang * ddsdh.gianhap)";
        }

        string select = String.Format(@"
                        select 
	                        dsdh.sochungtu
							, dh.sochungtu as so_po
							, dh.customer_order_no
							, dsdh.ngaylap
							, dsdh.hangiaohang_po
							, dtkd.ma_dtkd
							, dtkd.ten_dtkd
							, dtkd.tel
							, dtkd.fax
	                        , sp.ma_sanpham
							, (case when  SUBSTRING(sp.ma_sanpham,10,1) != 'F' then SUBSTRING(sp.ma_sanpham,0,9) + '.jpg' else SUBSTRING(sp.ma_sanpham,0,12) + '.jpg' end) as pic
							, (case when  SUBSTRING(sp.ma_sanpham,10,1) != 'F' then SUBSTRING(sp.ma_sanpham,0,9) else SUBSTRING(sp.ma_sanpham,0,12) end) as pic
							, ddsdh.ma_sanpham_khach
							, ddsdh.mota_tiengviet
							, dvt.ma_edi
                            , ddsdh.sl_dathang
							, dsdh.huongdanlamhang
							, dsdh.huongdanlamhangchung
							, ddsdh.huongdan_dathang
	                        , gh.ma_dtkd as diachigiaohang
							, dh.sl_cont
							, dh.loai_cont
							, dsdh.discount as discountdecimal
							, ddsdh.v2
                            , (case ddsdh.sl_inner when 0 then ' ' else (cast(ddsdh.sl_inner as nvarchar) + ' ' + (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_inner)) end) as dginner
                            , (cast(ddsdh.sl_outer as nvarchar) + ' ' + (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_outer)) as dgouter
                            , (select hoten from nhanvien where manv = dsdh.nguoitao) as nguoitao
							, sp.trongluong
							, sp.mota as ghichu
							, dsdh.mota
							, {1} as gianhap
							, {2} as thanhtien
                        from 
	                        c_danhsachdathang dsdh
							left join md_doitackinhdoanh dtkd on dsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
							left join md_doitackinhdoanh gh on dsdh.diachigiaohang = gh.md_doitackinhdoanh_id
	                        left join c_dongdsdh ddsdh on dsdh.c_danhsachdathang_id = ddsdh.c_danhsachdathang_id
							left join md_sanpham sp on ddsdh.md_sanpham_id = sp.md_sanpham_id
							left join md_donvitinhsanpham dvt on sp.md_donvitinhsanpham_id = dvt.md_donvitinhsanpham_id
							left join c_donhang dh  on dsdh.c_donhang_id = dh.c_donhang_id
							left join md_donggoi dg on ddsdh.md_donggoi_id = dg.md_donggoi_id
                        where
	                        dsdh.c_danhsachdathang_id = N'{0}' order by sp.ma_sanpham asc",
                            c_danhsachdathang_id == null ? "" : c_danhsachdathang_id,
                            gianhap,
                            thanhtien
                        );
        return select;
    }

    public void getPiInformation(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        context.Response.Charset = "UTF-8";
        string c_danhsachdathang_id = context.Request.QueryString["poId"];
        string msg = "";
        try
        {
            decimal totalQuantity = 0, totalSalary = 0, totalCbm = 0;
            decimal? phicong = 0, phitru = 0, cbm = 0, quantity = 0;
            c_danhsachdathang dsdh = db.c_danhsachdathangs.FirstOrDefault(d => d.c_danhsachdathang_id.Equals(c_danhsachdathang_id));
            if (dsdh != null)
            {
                var ddsdh = from c in db.c_dongdsdhs where c.c_danhsachdathang_id.Equals(dsdh.c_danhsachdathang_id) select c;
                var phiDH = from phi in db.c_phidathangs where phi.c_danhsachdathang_id.Equals(dsdh.c_danhsachdathang_id) select phi;

                quantity = ddsdh.Sum(p => p.sl_dathang);
                cbm = ddsdh.Sum(p => p.v2);
                phicong = phiDH.Where(p => p.isphicong.Equals(true)).Select(p => p.sotien).Sum();
                phitru = phiDH.Where(p => p.isphicong.Equals(false)).Select(p => p.sotien).Sum();
                totalSalary = ddsdh.Sum(p => p.sl_dathang * p.gianhap).Value;
                totalSalary = (totalSalary - (totalSalary * (dsdh.discount == null ? 0 : dsdh.discount.Value) / 100)) + (phicong == null ? 0 : phicong.Value) - (phitru == null ? 0 : phitru.Value);
                totalCbm = cbm == null ? 0 : cbm.Value;
                totalQuantity = quantity == null ? 0 : quantity.Value;

                msg = string.Format("Đơn đặt hàng:{0}, CBM:{1:#,##0.000}, Amount:{2:#,##0.00}, Quantity:{3:#,##0}", dsdh.sochungtu, totalCbm, totalSalary, totalQuantity);
            }
            else
                msg = "Đơn đặt hàng này đã bị xóa, hãy làm mới dữ liệu";
        }
        catch (Exception e)
        {
            msg = e.Message;
        }
        context.Response.Write(msg);
    }

    public void startSendMail(HttpContext context)
    {
        try
        {
            string piId = context.Request.QueryString["piId"];
            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            //Lấy báo giá
            var dsdh = db.c_danhsachdathangs.FirstOrDefault(p => p.c_danhsachdathang_id.Equals(piId));
            // Lấy thông tin đối tác
            var doitac = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(dsdh.md_doitackinhdoanh_id));

            string str = @"
                <table style='width:100%'> 
			    <tr>
				    <td colspan='3'>
					    <input id='new' checked='checked' value='toAll' name='rdType' type='radio'/>
					    <label for='new'>Danh Sách Đặt Hàng mới:</label>
					    <!-- -->
					    <table class='t_new' style='width:100%; padding-left: 50px; border: 1px solid;'>
						    <tr class='hidden'> 
							    <td colspan='2'>
								    <input id='newKcs' value='newKcs' name='newKcs' type='checkbox' class='new_toAll' >
								    <label for='newKcs'>Gửi cho KCS</label>
							    </td>
						    </tr>
						    <tr class='hidden'>
							    <td>Gửi từ:</td>
							    <td>{0}</td>
						    </tr>
						    <tr class='hidden'>
							    <td>Gửi cho:</td>
							    <td>{3}</td>
						    </tr>
						    <tr class='hidden'>
							    <td>Cc:</td>
							    <td>{2}</td>
						    </tr>
						    <tr> 
							    <td colspan='2'>
								    <input id='newNcu' value='newNcu' name='newNcu' type='checkbox' class='new_toAll' >
								    <label for='newNcu'>Gửi cho Nhà cung ứng</label>
							    </td> 
						    </tr> 
						    <tr>
							    <td>Gửi từ:</td>
							    <td>{0}</td>
						    </tr>
						    <tr>
							    <td>Gửi cho:</td>
							    <td>{1}{4}</td>
						    </tr>
						    <tr>
							    <td>Cc:</td>
							    <td>{2}</td>
						    </tr>
                            <tr style='display:none'> 
							    <td colspan='2'>
								    <input id='newKTNCU' value='newKTNCU' name='newKTNCU' type='checkbox' class='new_toAll' >
								    <label for='newKTNCU'>Gửi cho Nhà cung ứng (không có giá FOB)</label>
							    </td> 
						    </tr> 
						    <tr style='display:none'>
							    <td>Gửi từ:</td>
							    <td>{0}</td>
						    </tr>
						    <tr style='display:none'>
							    <td>Gửi cho:</td>
							    <td>{4}</td>
						    </tr>
						    <tr style='display:none'>
							    <td>Cc:</td>
							    <td>{2}</td>
						    </tr>
					    </table>
				    </td>						
			    </tr>
			    <tr>
				    <td colspan='3'>
					    <input id='plus' value='toAllPlus' name='rdType' type='radio'/>
					    <label for='plus'>Bổ Sung Danh Sách Đặt Hàng:</label>
					    <table class='t_plus' style='width:100%; padding-left: 50px; border: 1px solid;'>
						    <tr class='hidden'> 
							    <td colspan='2'>
								    <input id='Kcs' value='Kcs' name='Kcs' type='checkbox' class='new_toAllPlus'>
								    <label for='Kcs'>Gửi cho KCS</label>
							    </td>
						    </tr>
						    <tr class='hidden'>
							    <td>Gửi từ:</td>
							    <td>{0}</td>
						    </tr>
						    <tr class='hidden'>
							    <td>Gửi cho:</td>
							    <td>{3}{4}</td>
						    </tr>
						    <tr class='hidden'>
							    <td>Cc:</td>
							    <td>{2}</td>
						    </tr>
						    <tr> 
							    <td colspan='2'>
								    <input id='Ncu' value='Ncu' name='Ncu' type='checkbox' class='new_toAllPlus'>
								    <label for='Ncu'>Gửi cho Nhà cung ứng</label>
							    </td> 
						    </tr> 
						    <tr>
							    <td>Gửi từ:</td>
							    <td>{0}</td>
						    </tr>
						    <tr>
							    <td>Gửi cho:</td>
							    <td>{1}{4}</td>
						    </tr>
						    <tr>
							    <td>Cc:</td>
							    <td>{2}</td>
						    </tr>
                            <tr style='display:none'> 
							    <td colspan='2'>
								    <input id='KTNCU' value='KTNCU' name='KTNCU' type='checkbox' class='new_toAllPlus'>
								    <label for='KTNCU'>Gửi cho Nhà cung ứng (không có giá FOB)</label>
							    </td> 
						    </tr> 
						    <tr style='display:none'>
							    <td>Gửi từ:</td>
							    <td>{0}</td>
						    </tr>
						    <tr style='display:none'>
							    <td>Gửi cho:</td>
							    <td>{4}</td>
						    </tr>
						    <tr style='display:none'>
							    <td>Cc:</td>
							    <td>{2}</td>
						    </tr>
					    </table>
				    </td>						
			    </tr>
			    </table>";

            context.Response.Write(string.Format(str, nv.email, doitac.email, nv.email_cc, UserUtils.mailKCS, string.IsNullOrEmpty(doitac.email) ? "" : "," + doitac.emailkt));
        }
        catch (Exception ex)
        {
            context.Response.Write(ex.Message);
        }
    }

    public void sendMail(HttpContext context)
    {
        string sendType = context.Request.QueryString["sendType"];
        //--
        string sendMailType = context.Request.QueryString["sendMailType"];
        //--
        string[] sendMail = sendMailType.Remove(sendMailType.Length - 1).Split(',');
        int count_mal = sendMail.Length;

        string manv = UserUtils.getUser(context);

        //--Tao hinh anh dinh kem

        //--
        nhanvien nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
        //-- Lấy thông tin tmp
        md_mailtemplate tmp = db.md_mailtemplates.FirstOrDefault(p => p.use_for.Equals(sendType.Equals("toAllPlus") ? "PIPLUS" : "PI") && p.default_mail.Equals(true));

        // Lấy thông tin smtp
        md_smtp smtp = db.md_smtps.FirstOrDefault(p => p.macdinh.Equals(true));
        //-- c_danhsachdathang_id
        String piId = context.Request.QueryString["piId"];
        //--
        c_danhsachdathang dsdh = db.c_danhsachdathangs.FirstOrDefault(p => p.c_danhsachdathang_id.Equals(piId));
        //--
        md_doitackinhdoanh doitac = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(dsdh.md_doitackinhdoanh_id));
        //--
        int countProduct = (from p in db.c_dongdsdhs where p.c_danhsachdathang_id.Equals(piId) select p.sl_dathang).Count();

        bool next = true;
        var lstGNCC = new List<string> { "newNcu", "Ncu", "newKTNCU", "KTNCU" };

        string msg = "";
        //-- Canh bao loi
        if (nv == null)
        {
            next = false;
            msg += "Không tìm thấy mã nhân viên!";
        }

        if (tmp == null)
        {
            next = false;
            msg += "Không tìm thấy Mail Template!";
        }

        if (dsdh == null)
        {
            next = false;
            msg += "Không tìm thấy Danh sách đặt hàng!";
        }

        if (doitac == null)
        {
            next = false;
            msg += "Không tìm thấy đối tác!";
        }

        String fileNameExcel = manv + "Thong-Tin-San-Pham-" + DateTime.Now.ToString("ssmmhh-dd-MM-yyyy") + ".xls";
        //-- Tao Excel
        try
        {
            rptThongTinSanPham report = new rptThongTinSanPham();
            report.Parameters["so_dsdh"].Value = dsdh.sochungtu;
            report.Parameters["so_donhang"].Value = dsdh.so_po;
            SqlDataAdapter da = new SqlDataAdapter(getSqlThongTinSP(piId), mdbc.GetConnection);
            DataSet ds = new DataSet();
            da.Fill(ds);
            var tbl = ds.Tables[0];
            foreach(DataRow row in tbl.Rows)
            {
                string msp = row["sanpham"].ToString();
                row["hinhanh"] = ExcuteSignalRStatic.getImageProduct(msp);
            }
            report.DataSource = ds;
            report.DataAdapter = da;

            report.ExportToXls(path + fileNameExcel);
        }
        catch (Exception ex)
        {
            next = false;
            context.Response.Write("Không tạo được file \""+ fileNameExcel +"\", " + ex.Message);
        }

        if (next)
        {
            try
            {
                decimal? phicong = 0, phitru = 0, discount = 0;
                decimal cong = 0, tru = 0;
                var phiDH = from phi in db.c_phidathangs where phi.c_danhsachdathang_id.Equals(dsdh.c_danhsachdathang_id) select phi;

                phicong = phiDH.Where(p => p.isphicong.Equals(true)).Select(p => p.sotien).Sum();
                phitru = phiDH.Where(p => p.isphicong.Equals(false)).Select(p => p.sotien).Sum();

                cong = phicong == null ? 0 : phicong.Value;
                tru = phitru == null ? 0 : phitru.Value;

                decimal? giatridonhang = 0;
                if (dsdh.total != null & dsdh.discount != 100)
                {
                    if (dsdh.discount > 0)
                    {
                        discount = (dsdh.total.Value * dsdh.discount / 100);
                    }
                    giatridonhang = dsdh.total.Value - discount + cong - tru;
                }

                tmp.subject_mail = tmp.subject_mail.Replace("[CHUNGTUDATHANG]", dsdh.sochungtu);
                tmp.subject_mail = tmp.subject_mail.Replace("[SOPO]", dsdh.so_po);
                tmp.subject_mail = tmp.subject_mail.Replace("[NGAYLAP]", dsdh.ngaylap == null ? "" : dsdh.ngaylap.Value.ToString("dd/MM/yyyy"));

                tmp.content_mail = tmp.content_mail.Replace("[NHACUNGUNG]", doitac.ten_dtkd);
                tmp.content_mail = tmp.content_mail.Replace("[CHUNGTUDATHANG]", dsdh.sochungtu);
                tmp.content_mail = tmp.content_mail.Replace("[NGAYGIAOHANG]", dsdh.hangiaohang_po.Value.ToString("dd/MM/yyyy"));
                tmp.content_mail = tmp.content_mail.Replace("[SOLUONGMAHANG]", countProduct.ToString());
                tmp.content_mail = tmp.content_mail.Replace("[SOPO]", dsdh.so_po);

                GoogleMail mail = new GoogleMail(nv.email, nv.email_pass, smtp.smtpserver, smtp.port.Value, smtp.use_ssl.GetValueOrDefault(false));
                string resp = "";
                var fileDDHs = new List<string>();
                var fileDDHsKhongGia = new List<string>();
                for (int i = 0; i <= count_mal - 1; i++)
                {
                    fileDDHs = taoFileDonDatHang(context, nv.manv, doitac.ma_dtkd, dsdh, false);
                    fileDDHsKhongGia = taoFileDonDatHang(context, nv.manv, doitac.ma_dtkd, dsdh, true);
                    if (fileDDHs[0].LastIndexOf(path) <= -1)
                    {
                        next = false;
                        context.Response.Write(fileDDHs[0]);
                    }
                    if (fileDDHs[1].LastIndexOf(path) <= -1)
                    {
                        next = false;
                        context.Response.Write(fileDDHs[1]);
                    }
                    if (fileDDHsKhongGia[0].LastIndexOf(path) <= -1)
                    {
                        next = false;
                        context.Response.Write(fileDDHsKhongGia[0]);
                    }
                    if (fileDDHsKhongGia[1].LastIndexOf(path) <= -1)
                    {
                        next = false;
                        context.Response.Write(fileDDHsKhongGia[1]);
                    }

                    if (next == true)
                    {
                        string noidung = tmp.content_mail
                            .Replace("%0D", "<br/>")
                            .Replace("[NGAYLAP]", dsdh.ngaylap.Value.ToString("dd/MM/yyyy"));
                        string noidungKhongGia = noidung;

                        noidung = noidung.Replace("[GIATRIDONHANG]", giatridonhang.ToString());
                        noidungKhongGia = noidungKhongGia.Replace("[GIATRIDONHANG]", "đã ẩn");

                        if (sendMail[i] == "newKcs" || sendMail[i] == "Kcs")
                        {
                            if (sendType == "toAllPlus")
                            {
                                mail.Send(nv.email, UserUtils.mailKCS, nv.email_cc, "", tmp.subject_mail, noidung, fileDDHs[0] + ";" + fileDDHs[1]);
                            }
                            else
                            {
                                mail.Send(nv.email, UserUtils.mailKCS, nv.email_cc, "", tmp.subject_mail, noidung, fileDDHs[0] + ";" + fileDDHs[1] + ";" + path + fileNameExcel);
                            }
                            resp += String.Format("Đã gửi mail thành công đến:<br/>{0}<br/>{1}<br/>", nv.email_cc, UserUtils.mailKCS);
                        }

                        if (lstGNCC.Contains(sendMail[i]))
                        {
                            string pathInBaoBi = "";
                            try
                            {
                                string sql = String.Format(@"select 
											pi_.c_danhsachdathang_id, po.sochungtu , pi_.ngaylap, dt.ten_dtkd, pi_.c_danhsachdathang_id
										from 
											c_donhang po
											left join c_danhsachdathang pi_ on po.c_donhang_id = pi_.c_donhang_id
											left join md_doitackinhdoanh dt on pi_.md_doitackinhdoanh_id = dt.md_doitackinhdoanh_id
										where 
											pi_.c_danhsachdathang_id = '{0}'", piId == null ? "" : piId);
                                // tạo file excel
                                rptXacNhanBaoBi report = new rptXacNhanBaoBi();
                                pathInBaoBi = context.Server.MapPath("../FileSendMail/AnCoInBaoBi" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xls");
                                SqlDataAdapter da = new SqlDataAdapter(sql, mdbc.GetConnection);
                                DataSet ds = new DataSet();
                                da.Fill(ds);
                                report.DataSource = ds;
                                report.DataAdapter = da;
                                report.ExportToXls(pathInBaoBi);
                            }
                            catch (Exception ex)
                            {
                                next = false;
                                context.Response.Write("Không tạo được file xác nhận bao bì PDF, " + ex.Message);
                            }

                            if (next)
                            {
                                string ccSend = "", toSend = "";
                                ccSend = nv.email_cc;
                                toSend = doitac.email + (string.IsNullOrEmpty(doitac.emailkt) ? "" : "," + doitac.emailkt);
                                if (sendType == "toAllPlus")
                                {
                                    if (sendMail[i] == "newNcu" | sendMail[i] == "Ncu")
                                    {
                                        if (!string.IsNullOrEmpty(doitac.email))
                                            mail.Send(nv.email, doitac.email, nv.email_cc, "", tmp.subject_mail, noidung, fileDDHs[0] + ";" + fileDDHs[1] + ";" + pathInBaoBi);
                                        if (!string.IsNullOrEmpty(doitac.emailkt))
                                            mail.Send(nv.email, doitac.emailkt, "", "", tmp.subject_mail, noidungKhongGia, fileDDHsKhongGia[0] + ";" + fileDDHsKhongGia[1] + ";" + pathInBaoBi);
                                    }
                                }
                                else
                                {
                                    if (sendMail[i] == "newNcu" | sendMail[i] == "Ncu")
                                    {
                                        if (!string.IsNullOrEmpty(doitac.email))
                                            mail.Send(nv.email, doitac.email, nv.email_cc, "", tmp.subject_mail, noidung, fileDDHs[0] + ";" + fileDDHs[1] + ";" + pathInBaoBi + ";" + path + fileNameExcel);
                                        if (!string.IsNullOrEmpty(doitac.emailkt))
                                            mail.Send(nv.email, doitac.emailkt, "", "", tmp.subject_mail, noidungKhongGia, fileDDHsKhongGia[0] + ";" + fileDDHsKhongGia[1] + ";" + pathInBaoBi + ";" + path + fileNameExcel);
                                    }
                                }
                                resp += string.Format("<br/>Đã gửi mail thành công đến:<br/>{0}<br/>{1}<br/>", ccSend, toSend);
                            }
                        }
                    }
                }
                if (next)
                {
                    string dk_trangthai = "";
                    c_danhsachdathang dsdh_nht = db.c_danhsachdathangs.Where(s => s.c_danhsachdathang_id == piId).FirstOrDefault();
                    md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == dsdh_nht.md_doitackinhdoanh_id).FirstOrDefault();

                    dk_trangthai = ", trangthai = N'DAGUI'";
                    String update = "update c_danhsachdathang set isgui_hdlh = 1" + dk_trangthai + " where c_danhsachdathang_id = @c_danhsachdathang_id";
                    mdbc.ExcuteNonQuery(update, "@c_danhsachdathang_id", piId);
                }
                context.Response.Write(resp);
            }
            catch (Exception ex)
            {
                context.Response.Write(ex.Message);
            }
        }
    }

    public void activePI(HttpContext context)
    {
        String msg = "";
        try
        {
            String piId = context.Request.QueryString["piId"];
            c_danhsachdathang dsdh = db.c_danhsachdathangs.FirstOrDefault(p => p.c_danhsachdathang_id.Equals(piId));

            c_donhang donhang = db.c_donhangs.FirstOrDefault(dh => dh.c_donhang_id.Equals(dsdh.c_donhang_id));

            if (dsdh.md_trangthai_id.Equals("SOANTHAO"))
            {
                var msgs = new List<Dictionary<string, string>>(msgPublics);
                var madtkds = msgs.Select(s=>s.Keys.FirstOrDefault()).ToList();

                string ma_dtkd = db.md_doitackinhdoanhs.
                        Where(s => s.md_doitackinhdoanh_id == dsdh.md_doitackinhdoanh_id).
                        Select(s => s.ma_dtkd).FirstOrDefault();

                if (dsdh.trangthai != "DAHIEULUC" & madtkds.Contains(ma_dtkd))
                {
                    msg = String.Format(@"Hiệu lực thất bại! {0} phải trong trạng thái ""Đã nhận""", dsdh.sochungtu);
                }
                else
                {
                    c_kehoachxuathang kehoach = new c_kehoachxuathang();
                    kehoach.c_kehoachxuathang_id = Security.EncodeMd5Hash(DateTime.Now.ToString());
                    kehoach.c_donhang_id = dsdh.c_donhang_id;
                    kehoach.chungloaihang = "";
                    kehoach.c_danhsachdathang_id = dsdh.sochungtu;
                    kehoach.md_doitackinhdoanh_id = dsdh.md_doitackinhdoanh_id;
                    kehoach.so_po = dsdh.so_po;
                    kehoach.shipmenttime = donhang.shipmenttime;
                    kehoach.ngaygiaohang = dsdh.hangiaohang_po;
                    kehoach.ngayxonghang = dsdh.hangiaohang_po;
                    kehoach.ngayxacnhanbaobi = dsdh.hangiaohang_po.Value.AddDays(-35);
                    kehoach.cont20 = 0;
                    kehoach.cont40 = 0;
                    kehoach.cont40hc = 0;
                    kehoach.md_trangthai_id = "SOANTHAO";
                    kehoach.ngaytao = DateTime.Now;
                    kehoach.ngaycapnhat = DateTime.Now;
                    kehoach.nguoitao = UserUtils.getUser(context);
                    kehoach.nguoicapnhat = UserUtils.getUser(context);
                    kehoach.hoatdong = true;

                    string sql_cbm = @"select SUM(tmp.cbm) 
										from (
											select case when cdg.sl_outer = 0 then 0
													else round(((cdg.l2 * cdg.h2 * cdg.w2) * cdh.sl_dathang/cdg.sl_outer)/1000000, 3) end as cbm
												from c_dongdsdh cdh, c_dongdonhang cdg
												where 
													cdh.c_dongdonhang_id = cdg.c_dongdonhang_id
													and c_danhsachdathang_id = '" + piId + "') as tmp";

                    decimal cbm = (decimal)mdbc.ExecuteScalar(sql_cbm);
                    kehoach.cbm = Math.Round(cbm, 3);
                    kehoach.cbm_conlai = Math.Round(cbm, 3); ;

                    string sql = @"select code_cl
                        from md_chungloai where md_chungloai_id
                        in(
	                        select distinct ms.md_chungloai_id
	                        from c_dongdsdh cnx, md_sanpham ms 
	                        where ms.md_sanpham_id = cnx.md_sanpham_id and 
		                        c_danhsachdathang_id in ('" + piId + "')" +
                            ")order by code_cl";
                    string cole_cl = " ";
                    DataTable com = mdbc.GetData(sql);
                    foreach (DataRow item in com.Rows)
                    {
                        cole_cl += item[0].ToString() + ", ";
                    }
                    kehoach.chungloaihang = cole_cl.Length > 2 ? cole_cl.Substring(0, cole_cl.Length - 2) : "";
                    db.c_kehoachxuathangs.InsertOnSubmit(kehoach);

                    dsdh.md_trangthai_id = "HIEULUC";
                    db.SubmitChanges();
                    //mdbc.ExcuteNonProcedure("p_hieuLucDsdh", "@dsdh_id", piId);

                    // Cập nhật  ismakepi cho đơn hàng nếu tất cả sản phẩm của đơn hàng đều nhỏ hơn 1
                    String getTongSlConLai = "select sum(soluong_conlai) from c_dongdonhang ddh where ddh.c_donhang_id = @c_donhang_id";
                    int c = int.Parse(mdbc.ExecuteScalar(getTongSlConLai, "@c_donhang_id", dsdh.c_donhang_id).ToString());
                    if (c < 1)
                    {
                        //c_donhang donhang = db.c_donhangs.FirstOrDefault(dh => dh.c_donhang_id.Equals(dsdh.c_donhang_id));
                        donhang.ismakepi = true;
                        db.SubmitChanges();
                        //mdbc.ExcuteNonProcedure("p_tinhCBMconlaicuaKHXH", "@invoiceid", piId);
                    }

                    msg = String.Format("Hiệu lực danh sách đặt hàng {0} thành công.!", dsdh.sochungtu);
                }
            }
            else
            {
                msg = String.Format("Hiện trạng thái danh sách đặt hàng {0} đã là hiệu lực.!", dsdh.sochungtu);
            }
        }
        catch (SqlException ex)
        {
            msg = "Lỗi xảy ra khi hiệu lực PI" + ex.Message;
        }
        context.Response.Write(msg);
    }

    public void getSelectOption(HttpContext context)
    {
        String sql = "select c_danhsachdathang_id, sochungtu from c_danhsachdathang where hoatdong = 1";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }


    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        string huongdanlamhang = context.Request.Form["huongdanlamhang"];
        string huongdanlamhangchung = context.Request.Form["huongdanlamhangchung"];
        var arrGuiDonHangHeThong = new List<string>();
        foreach (var msgPL in msgPublics)
        {
            var madtkd = msgPL.Keys.FirstOrDefault();
            arrGuiDonHangHeThong.Add(madtkd);
        }
        string msg = "";
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        String isgui_hdlh = context.Request.Form["isgui_hdlh"].ToLower();
        if (isgui_hdlh.Equals("true"))
        {
            isgui_hdlh = "true";
        }
        else
        {
            isgui_hdlh = "false";
        }

        c_danhsachdathang m = db.c_danhsachdathangs.Single(p => p.c_danhsachdathang_id == context.Request.Form["id"]);
        var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == m.md_doitackinhdoanh_id).FirstOrDefault();
        if (m.md_trangthai_id.Equals("SOANTHAO"))
        {
            m.ngaylap = DateTime.ParseExact(context.Request.Form["ngaylap"], "dd/MM/yyyy", null);
            m.hangiaohang_po = DateTime.ParseExact(context.Request.Form["hangiaohang_po"], "dd/MM/yyyy", null);
            m.nguoi_phutrach = UserUtils.getUser(context);
            m.nguoi_dathang = UserUtils.getUser(context);
            m.diachigiaohang = context.Request.Form["diachigiaohang"];
            m.isgui_hdlh = bool.Parse(isgui_hdlh);
            m.discount = decimal.Parse(context.Request.Form["discount"]);
            m.mota = context.Request.Form["mota"];
            m.hoatdong = hd;
            m.nguoicapnhat = UserUtils.getUser(context);
            m.ngaycapnhat = DateTime.Now;
            db.SubmitChanges();
        }
        else
        {
            m.isgui_hdlh = bool.Parse(isgui_hdlh);
            //jqGridHelper.Utils.writeResult(0,"Không thể chỉnh sửa khi đặt hàng đã hiệu lực.!");
        }

        //Tạm thời chỉ áp dụng Anco1
        if(arrGuiDonHangHeThong[0].Contains(dtkd.ma_dtkd))
        {
            if(m.trangthai == CHUAGUI | m.trangthai == TUCHOI | string.IsNullOrEmpty(m.trangthai))
            {
                m.huongdanlamhang = huongdanlamhang;
                m.huongdanlamhangchung = huongdanlamhangchung;
            }
            else if(m.huongdanlamhang != huongdanlamhang | m.huongdanlamhangchung != huongdanlamhangchung)
            {
                jqGridHelper.Utils.writeResult(0, "Không thể sửa HDLH khi đã gửi DSDH");
                goto EndEventHandler;
            }
        }
        else
        {
            m.huongdanlamhang = huongdanlamhang;
            m.huongdanlamhangchung = huongdanlamhangchung;
        }

        db.SubmitChanges();

        EndEventHandler:;
    }

    public void add(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        c_danhsachdathang mnu = new c_danhsachdathang
        {
            c_danhsachdathang_id = Security.EncodeMd5Hash(DateTime.Now.ToString("yyyyMMddddhhmmss")),
            //sochungtu = context.Request.Form["sochungtu"],
            ngaylap = DateTime.ParseExact(context.Request.Form["ngaylap"], "dd/MM/yyyy", null),
            hangiaohang_po = DateTime.ParseExact(context.Request.Form["hangiaohang_po"], "dd/MM/yyyy", null),
            nguoi_phutrach = UserUtils.getUser(context),
            nguoi_dathang = UserUtils.getUser(context),
            diachigiaohang = context.Request.Form["diachigiaohang"],
            discount = decimal.Parse(context.Request.Form["discount"]),
            //c_donhang_id = context.Request.Form["c_donhang_id"],
            //so_po = context.Request.Form["so_po"],
            md_trangthai_id = "SOANTHAO",

            mota = context.Request.Form["mota"],
            hoatdong = hd,
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.c_danhsachdathangs.InsertOnSubmit(mnu);
        db.SubmitChanges();
    }


    public void del(HttpContext context)
    {
        var msg = "";
        String id = context.Request.Form["id"];
        var ds = db.c_danhsachdathangs.Single(p => p.c_danhsachdathang_id.Equals(id));
        bool duocXoa = Public.LaNguoiTao(context, ds.nguoitao, db);

        if (ds.md_trangthai_id.Equals("HIEULUC"))
        {
            msg = $@"Không thể xóa khi đặt hàng đã hiệu lực.!";
            goto EndEventHandler;
        }

        if (!string.IsNullOrEmpty(ds.trangthai))
        {
            if (ds.trangthai.Equals("DAGUI"))
            {
                msg = $@"Đã gửi NCC.!";
                goto EndEventHandler;
            }

            if (ds.trangthai.Equals("DANHAN"))
            {
                msg = $@"Đã gửi NCC và NCC đã xem.!";
                goto EndEventHandler;
            }

            if (ds.trangthai.Equals("DAHIEULUC"))
            {
                msg = $@"Đã gửi NCC và NCC đã nhận.!";
                goto EndEventHandler;
            }
        }

        if (!duocXoa)
        {
            msg = $@"Chỉ tài khoản {ds.nguoitao} hoặc admin mới có thể xóa.!";
            goto EndEventHandler;
        }

        try
        {
            var ct = from p in db.c_dongdsdhs
                     where p.c_danhsachdathang_id == ds.c_danhsachdathang_id
                     select p;

            var pds = from p in db.c_phidathangs
                      where p.c_danhsachdathang_id == ds.c_danhsachdathang_id
                      select p;
            //Xoa Dong Hang
            db.c_dongdsdhs.DeleteAllOnSubmit(ct);
            //Xoa Phi dat hang
            db.c_phidathangs.DeleteAllOnSubmit(pds);
            //Xoa Huong dan lam hang
            var links = new List<string>();
            var taptins = db.md_taptins.Where(s => s.lienket == ds.c_danhsachdathang_id).ToList();
            foreach (var taptin in taptins)
            {
                db.md_taptins.DeleteOnSubmit(taptin);
                links.Add(ExcuteSignalRStatic.mapPathSignalR($@"~/{taptin.path}"));
            }

            var hdlhs = db.md_ghichuhdlhs.Where(s => s.lienket == ds.c_danhsachdathang_id).ToList();
            foreach (var hdlh in hdlhs)
            {
                db.md_ghichuhdlhs.DeleteOnSubmit(hdlh);
            }
            //Xoa Don dat hang
            db.c_danhsachdathangs.DeleteOnSubmit(ds);
            //Cap nhat
            db.SubmitChanges();
            foreach (var link in links)
            {
                if (File.Exists(link))
                    File.Delete(link);
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if(msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Xóa thành công.!");
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

        String sqlCount = "SELECT COUNT(*) AS count " +
            " FROM c_danhsachdathang dsdh, c_donhang dh, md_doitackinhdoanh dtkd " +
            " WHERE dsdh.c_donhang_id = dh.c_donhang_id" +
            " {0} " +
            " {1} " +
            " AND dsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id ";

        sqlCount = string.Format(sqlCount, isadmin == true ? "" : "AND dsdh.nguoitao IN(" + strAccount + ")", filter);

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
            sidx = "dsdh.c_danhsachdathang_id";
        }

        string strsql = "select *, (case when dcgh_1 is null then dcgh_2 else dcgh_1 end) as madtkd from( " +
                " select dsdh.c_danhsachdathang_id, dsdh.md_trangthai_id,dsdh.trangthai, dsdh.sochungtu sodsdh,dh.sochungtu as sodh, dh.customer_order_no, dsdh.ngaylap, " +
                " dsdh.hangiaohang_po, dtkd.ma_dtkd, " +
                " dsdh.nguoi_phutrach, " +
                " dsdh.nguoi_dathang, " +
                " (select dtkd_a.ma_dtkd from md_doitackinhdoanh dtkd_a where dtkd_a.md_doitackinhdoanh_id = dsdh.diachigiaohang) as dcgh_1, " +
                " dsdh.diachigiaohang as dcgh_2, " +
                " dsdh.huongdanlamhang,dsdh.huongdanlamhangchung, dsdh.discount, dsdh.isgui_hdlh, dsdh.ngaytao, " +
                " dsdh.nguoitao, dsdh.ngaycapnhat, dsdh.nguoicapnhat, dsdh.mota, dsdh.hoatdong, " +
                " ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + ") as RowNum " +
                " FROM c_danhsachdathang dsdh, c_donhang dh, md_doitackinhdoanh dtkd " +
                " WHERE dsdh.c_donhang_id = dh.c_donhang_id " +
                " AND dsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id " +
                " {0} " +
                " {1} " +
                ")P WHERE RowNum > @start AND RowNum < @end";

        strsql = String.Format(strsql, isadmin == true ? "" : "AND dsdh.nguoitao IN(" + strAccount + ")", filter);

        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["c_danhsachdathang_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["md_trangthai_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["trangthai"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["sodsdh"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["sodh"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["customer_order_no"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["hangiaohang_po"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_dtkd"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["madtkd"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["discount"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaylap"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";


            xml += "<cell><![CDATA[" + row["nguoi_phutrach"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoi_dathang"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["huongdanlamhang"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["huongdanlamhangchung"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["isgui_hdlh"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaytao"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaycapnhat"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoicapnhat"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["mota"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hoatdong"] + "]]></cell>";
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }

    public string taoFileThongTinSanPham(HttpContext context, string manv, c_danhsachdathang dsdh)
    {
        String fileNameExcel = manv + "Thong-Tin-San-Pham-" + DateTime.Now.ToString("ssmmhh-dd-MM-yyyy") + ".xls";
        //-- Tao Excel
        try
        {
            rptThongTinSanPham report = new rptThongTinSanPham();
            report.Parameters["so_dsdh"].Value = dsdh.sochungtu;
            report.Parameters["so_donhang"].Value = dsdh.so_po;
            SqlDataAdapter da = new SqlDataAdapter(getSqlThongTinSP(dsdh.c_danhsachdathang_id), mdbc.GetConnection);
            DataSet ds = new DataSet();
            da.Fill(ds);
            var tbl = ds.Tables[0];
            foreach(DataRow row in tbl.Rows)
            {
                string msp = row["sanpham"].ToString();
                row["hinhanh"] = ExcuteSignalRStatic.getImageProduct(msp);
            }
            report.DataSource = ds;
            report.DataAdapter = da;
            fileNameExcel = path + fileNameExcel;
            report.ExportToXls(fileNameExcel);
        }
        catch (Exception ex)
        {
            fileNameExcel = "";
            context.Response.Write(string.Format(@"<div>Không tạo được file Excel Thông tin sản phẩm</div><div style='margin-left:5px;'>Chi tiết: {0}</div>", ex.Message));
        }

        return fileNameExcel;
    }

    public List<string> taoFileDonDatHang(HttpContext context, string manv, string ma_dtkd, c_danhsachdathang dsdh, bool guiNCC)
    {
        //-Tao file dinh kem
        String fileName = manv + "Don-Dat-Hang-" + DateTime.Now.ToString("ssmmhh-dd-MM-yyyy") + guiNCC.ToString();
        String fileNameXls = fileName + ".xls";
        String fileNamePdf = fileName + ".pdf";
        //-- Tao excel
        try
        {
            var rptPI = new DanhSachDatHangReport(dsdh.c_danhsachdathang_id, logoPath, productImagePath);
            rptPI.guiNCC = guiNCC;
            //rptPI.TypePrint = "pdf";
            var wb = rptPI.CreateWBPI();
            var imgs = new List<AvariablePrj.lstImage>();
            foreach (var img in rptPI.Lstimage)
            {
                img.column = img.column - 1;
                img.columnLast = img.columnLast - 1;
                img.dx1 = 10;
                img.dx2 = 1000;
                img.dy1 = 40;
                img.dy2 = 215;
                imgs.Add(img);
            }
            wb = rptPI.ConfigExcel.setImageForExcel(wb, imgs);
            fileNameXls = path + fileNameXls;
            var xfile = new FileStream(fileNameXls, FileMode.Create, FileAccess.ReadWrite);
            wb.Write(xfile);
            xfile.Close();
            xfile.Dispose();
        }
        catch (Exception ex)
        {
            fileNameXls = "";
            context.Response.Write(string.Format(@"<div>Không tạo được file Excel Đơn Đặt Hàng</div><div style='margin-left:5px;'>Chi tiết: {0}</div>", ex.Message));
        }

        //-- Tao PDF
        try
        {
            var rptPI = new DanhSachDatHangReport(dsdh.c_danhsachdathang_id, logoPath, productImagePath);
            rptPI.guiNCC = guiNCC;
            rptPI.TypePrint = "pdf";
            var wb = rptPI.CreateWBPI();
            //wb = rptPI.ConfigExcel.setImageForExcel(wb, rptPI.Lstimage);

            var url = path + Guid.NewGuid().ToString() + ".xls";
            var xfile = new FileStream(url, FileMode.Create, FileAccess.ReadWrite);
            wb.Write(xfile);
            xfile.Close();
            xfile.Dispose();

            fileNamePdf =  path + fileNamePdf;
            var result = OfficeToPDF.ExcelConverter.Convert(url, fileNamePdf, null, rptPI.Lstimage, rptPI.LstText);
            File.Delete(url);
            //rptDanhSachDatHang report = new rptDanhSachDatHang();
            //SqlDataAdapter da = new SqlDataAdapter(getSqlDsdhPdf(dsdh.c_danhsachdathang_id, guiNCC), mdbc.GetConnection);
            //DataSet ds = new DataSet();
            //da.Fill(ds);
            //var tbl = ds.Tables[0];
            //if (tbl.Rows.Count > 0)
            //{
            //    string c_danhsachdathang_id = dsdh.c_danhsachdathang_id;
            //    tbl.Columns.Add("money", Type.GetType("System.String"));
            //    tbl.Columns.Add("mota_cong", Type.GetType("System.String"));
            //    tbl.Columns.Add("mota_tru", Type.GetType("System.String"));
            //    tbl.Columns.Add("discount", Type.GetType("System.Double"));
            //    tbl.Columns.Add("giatritang", Type.GetType("System.Double"));
            //    tbl.Columns.Add("giatrigiam", Type.GetType("System.Double"));
            //    tbl.Columns.Add("tongtiendatru", Type.GetType("System.Double"));
            //    //Header

            //    //Footer
            //    int lastRow = tbl.Rows.Count - 1;

            //    var strSumThanhTien = tbl.Compute("Sum(thanhtien)", string.Empty).ToString();
            //    double? total = null;
            //    if (!string.IsNullOrEmpty(strSumThanhTien))
            //        total = double.Parse(strSumThanhTien);

            //    var strDiscount = tbl.Rows[0]["discountdecimal"].ToString();
            //    double? discount_ = null;
            //    if (!string.IsNullOrEmpty(strDiscount))
            //        discount_ = double.Parse(strDiscount);

            //    var totalDiscount = total.GetValueOrDefault(0) * discount_.GetValueOrDefault(0) / 100;
            //    tbl.Rows[lastRow]["discount"] = totalDiscount;

            //    var phitang = (from t in db.c_phidathangs where t.isphicong.Equals(true) && t.c_danhsachdathang_id.Equals(c_danhsachdathang_id) select t.sotien).Sum();
            //    tbl.Rows[lastRow]["giatritang"] = phitang.GetValueOrDefault(0);

            //    var phigiam = (from t in db.c_phidathangs where t.isphicong.Equals(false) && t.c_danhsachdathang_id.Equals(c_danhsachdathang_id) select t.sotien).Sum();
            //    tbl.Rows[lastRow]["giatrigiam"] = phigiam.GetValueOrDefault(0);

            //    var varTang = db.c_phidathangs.FirstOrDefault(tg => tg.c_danhsachdathang_id.Equals(c_danhsachdathang_id) && tg.isphicong.Equals(true));
            //    var varGiam = db.c_phidathangs.FirstOrDefault(gi => gi.c_danhsachdathang_id.Equals(c_danhsachdathang_id) && gi.isphicong.Equals(false));

            //    string dgTang, dgGiam;
            //    dgTang = varTang == null ? "" : varTang.mota;
            //    dgGiam = varGiam == null ? "" : varGiam.mota;

            //    double? totalUSD = null;
            //    string textMoney = "";
            //    if (guiNCC == false)
            //    {
            //        totalUSD = total - (double)totalDiscount + (double)phitang.GetValueOrDefault(0) - (double)phigiam.GetValueOrDefault(0);
            //        if (totalUSD != null)
            //        {
            //            if (new string[] { "VINHGIA" }.Contains(ma_dtkd))
            //            {
            //                string m = MoneyToWord.ConvertMoneyToText(totalUSD.ToString()).Replace("Dollars", "");
            //                int j = m.LastIndexOf("and");

            //                if (m.Contains("Cents") | m.Contains("Cent"))
            //                {
            //                    m = m.Replace("Cents", "").Replace("Cent", "");
            //                    m = m.Insert(m.Length, "cents");
            //                }
            //                else
            //                {
            //                    m = m.Replace("Cents", "").Replace("Cent", "");
            //                }
            //                textMoney = m;
            //            }
            //            else
            //            {
            //                textMoney = MoneyToWord.ConvertMoneyToTextVND((decimal)totalUSD.GetValueOrDefault(0));
            //            }
            //            tbl.Rows[lastRow]["money"] = textMoney;
            //            tbl.Rows[lastRow]["tongtiendatru"] = totalUSD;
            //        }
            //    }

            //    string diengiai_cong = String.Format(@"select t.mota from c_phidathang t where t.isphicong = 1 and t.c_danhsachdathang_id = '{0}'", c_danhsachdathang_id == null ? "" : c_danhsachdathang_id);
            //    DataTable cong_ = mdbc.GetData(diengiai_cong);
            //    var mota_cong = new List<string>();
            //    for (int i_ = 0; i_ < cong_.Rows.Count; i_++)
            //    {
            //        mota_cong.Add(cong_.Rows[i_]["mota"].ToString());
            //    }

            //    string diengiai_tru = String.Format(@"select t.mota from c_phidathang t where t.isphicong = 0 and t.c_danhsachdathang_id = '{0}'", c_danhsachdathang_id == null ? "" : c_danhsachdathang_id);
            //    DataTable tru_ = mdbc.GetData(diengiai_tru);
            //    var mota_tru = new List<string>();
            //    for (int i_ = 0; i_ < tru_.Rows.Count; i_++)
            //    {
            //        mota_tru.Add(tru_.Rows[i_]["mota"].ToString());
            //    }
            //    tbl.Rows[lastRow]["mota_cong"] = string.Join(",", mota_cong);
            //    tbl.Rows[lastRow]["mota_tru"] = string.Join(",", mota_tru);
            //}
            //report.DataSource = ds;
            //report.DataAdapter = da;
            //fileNamePdf = path + fileNamePdf;
            //report.ExportToPdf(fileNamePdf);
        }
        catch (Exception ex)
        {
            fileNamePdf = "";
            context.Response.Write(string.Format(@"<div>Không tạo được file PDF Thông tin sản phẩm</div><div style='margin-left:5px;'>Chi tiết: {0}</div>", ex.Message));
        }

        var arrLst = new List<string>();
        arrLst.Add(fileNameXls);
        arrLst.Add(fileNamePdf);
        return arrLst;
    }

    public string taoFileXacNhanBaoBi(HttpContext context, string manv, c_danhsachdathang dsdh)
    {
        string pathInBaoBi = path + "AnCoInBaoBi" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xls";
        try
        {
            string sql = String.Format(@"select 
						pi_.c_danhsachdathang_id, po.sochungtu , pi_.ngaylap, dt.ten_dtkd, pi_.c_danhsachdathang_id
					from 
						c_donhang po
						left join c_danhsachdathang pi_ on po.c_donhang_id = pi_.c_donhang_id
						left join md_doitackinhdoanh dt on pi_.md_doitackinhdoanh_id = dt.md_doitackinhdoanh_id
					where 
						pi_.c_danhsachdathang_id = '{0}'", dsdh.c_danhsachdathang_id == null ? "" : dsdh.c_danhsachdathang_id);
            // tạo file excel
            rptXacNhanBaoBi report = new rptXacNhanBaoBi();
            SqlDataAdapter da = new SqlDataAdapter(sql, mdbc.GetConnection);
            DataSet ds = new DataSet();
            da.Fill(ds);
            report.DataSource = ds;
            report.DataAdapter = da;
            report.ExportToXls(pathInBaoBi);
        }
        catch (Exception ex)
        {
            pathInBaoBi = "";
            context.Response.Write(string.Format(@"<div>Không tạo được file Excel Xác Nhận Bao Bì</div><div style='margin-left:5px;'>Chi tiết: {0}</div>", ex.Message));
        }

        return pathInBaoBi;
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
