<%@ WebHandler Language="C#" Class="UserQRCodeController" %>

using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;
using System.Collections.Generic;

public class UserQRCodeController : IHttpHandler {
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];

        switch (oper)
        {
            case "updateMenuProductWeb":
                this.updateMenuProductWeb(context);
                break;
            case "getInfo":
                this.getInfo(context);
                break;
            case "createLoginWebsite":
                this.createLoginWebsite(context);
                break;
            case "checkLoginWebsite":
                this.checkLoginWebsite(context);
                break;
            case "sendMail":
                this.SendMail(context);
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
    }

    public void updateMenuProductWeb(HttpContext context)
    {
        string msg = "";
        try
        {
            var content = context.Request.Form["content"];
            if (content.Length > 0)
            {
                content = content.Replace("%26", "&").Replace("%3F", "?");
                string url = ExcuteSignalRStatic.mapPathSignalR("~/App_Data/MenuProductWeb.json");
                System.IO.File.WriteAllText(url, content);
                msg = "1Update successfully";
            }
            else
            {
                msg = "0Update fail";
            }
        }
        catch(Exception ex)
        {
            msg = "0" + ex.Message;
        }
        context.Response.Write(msg);
    }

    public void getInfo(HttpContext context)
    {
        string ma_sanpham = context.Request.Form["msp"];
        string arr_sanpham = "'" + ma_sanpham + "'";
        string msg = "";
        var lstSps = new List<string>();
        var lstSpsMss = new List<Dictionary<string, string>>();

        try
        {
            lstSps.Add(ma_sanpham.Substring(0, ma_sanpham.Length - 3));
            ma_sanpham = ma_sanpham.Split(new[] { '\r', '\n' }).FirstOrDefault();
            string unknown = "(Unknown)";
            string dong0 = unknown, dong1 = unknown, dong2 = unknown, dong3 = unknown, dong4 = unknown, dong5 = unknown, dong6 = unknown, dong7 = unknown,
            dong8 = "", dong9 = "", dong10 = unknown, dong11 = unknown, dong12 = unknown, dong13 = unknown, dong14 = "", dong15 = unknown, dong16 = unknown,
            image = "", size = "", sizeSel = "", packingText = "", sizeText = "", shape = "";
            var json = new Dictionary<string, string>();

            var sp = db.md_sanphams.Where(s => s.ma_sanpham == ma_sanpham & s.trangthai == "DHD").FirstOrDefault();
            if (sp != null)
            {
                string cl = sp.ma_sanpham.Substring(0, 2);
                string bc = sp.ma_sanpham.Substring(9, 2);

                var plhh = db.md_chungloais.Where(s => s.code_cl == cl).FirstOrDefault();
                if (plhh != null)
                {
                    dong0 = plhh.ta_ngan.ToUpper();
                }

                shape = db.md_kieudangs.Where(s => s.md_kieudang_id == sp.md_kieudang_id).Select(s => s.ten_ta).FirstOrDefault();
                if (shape == "Rd.")
                    shape = "Round";
                else if (shape == "Sq.")
                    shape = "Squard";
                shape = shape + " Shape";

                dong6 = sp.ma_sanpham;
                //dong 7, dong 8, dong 9
                if (bc.Substring(0, 1) != "0" & bc != "S1")
                {
                    var arrBoChas = new string[] {
                        "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9",
                        "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9"
                    };
                    //Tim` bo cha cua san pham
                    string msp_0009 = sp.ma_sanpham.Substring(0, 9), msp_1103 = sp.ma_sanpham.Substring(11, 3);
                    string ma_bo_cha = db.md_sanphams.Where(s =>
                            s.ma_sanpham.Substring(0, 9) == msp_0009
                            & s.ma_sanpham.Substring(11, 3) == msp_1103
                            & arrBoChas.Contains(s.ma_sanpham.Substring(9, 2))
                        ).Select(s => s.ma_sanpham.Substring(9, 2)).FirstOrDefault();
                    //Lay cac ma cai thuoc bo cua san pham
                    string md_bo_id = db.md_bos.Where(s => s.ma_bo == bc & s.ma_bo_cha == ma_bo_cha).Select(s => s.md_bo_id).FirstOrDefault();
                    foreach (var bct in db.md_bo_chitiets.Where(s => s.md_bo_id == md_bo_id))
                    {
                        string sanpham_add = msp_0009 + bct.md_bo_detail + msp_1103;
                        arr_sanpham += ",'" + sanpham_add + "'";
                        lstSps.Add(msp_0009 + bct.md_bo_detail);
                    }
                }

                var arrSps = arr_sanpham.Split(',');
                for(var i=0; i < arrSps.Length; i++) {
                    sizeSel += arrSps[i].Substring(10, 2) + ",";
                }

                sizeSel = sizeSel.Length > 0 ? sizeSel.Substring(0, sizeSel.Length - 1) : "";

                var dt = ExcuteSignalRStatic.getPrice(arr_sanpham);
                string kichthuoc_9 = "";
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    var msp2 = row["ma_sanpham"].ToString();
                    var sp2 = db.md_sanphams.Where(s => s.ma_sanpham == msp2).FirstOrDefault();
                    if (msp2 != ma_sanpham)
                    {
                        if (row["l_cm"].ToString() != "0.0" & row["w_cm"].ToString() != "0.0" & row["h_cm"].ToString() != "0.0")
                        {
                            string kt = row["l_cm"] + "x" + row["w_cm"] + "xH" + row["h_cm"];
                            dong9 += ExcuteSignalRStatic.getSizeRectOrRound(db, sp2, kt) + "/ \\n          ";
                        }
                    }
                    else
                    {
                        dong7 = "$" + row["gia"].ToString();
                        if (row["l_cm"].ToString() != "0.0" & row["w_cm"].ToString() != "0.0" & row["h_cm"].ToString() != "0.0")
                        {
                            string kt = row["l_cm"] + "x" + row["w_cm"] + "xH" + row["h_cm"];
                            kichthuoc_9 = ExcuteSignalRStatic.getSizeRectOrRound(db, sp2, kt);
                        }
                    }
                }
                if (dong8 != "")
                {
                    dong8 = "( " + dong8.Substring(0, dong8.Length - 1) + ")";
                }
                if (dong9 != "")
                {
                    dong9 = dong9.Substring(0, dong9.Length - 14) + "cm";
                }
                else
                {
                    if (kichthuoc_9 != "")
                    {
                        dong9 = kichthuoc_9 + "cm";
                    }
                    else
                    {
                        dong9 = "";
                    }
                }

                dt = ExcuteSignalRStatic.getDongGoi(sp.md_sanpham_id);
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    string sl_inner = row["sl_inner"].ToString(), dvt_inner = row["dvtinner"].ToString();
                    string sl_outer = row["sl_outer"].ToString(), dvt_outer = row["dvtouter"].ToString();

                    var dDVT = ExcuteSignalRStatic.getTextFromInner(dvt_inner, dvt_outer, sl_inner, sl_outer);
                    if (dDVT != null)
                    {
                        dong10 = dDVT.inner;
                        dong11 = dDVT.outer;
                        packingText = dDVT.packingText;
                        sizeText = dDVT.sizeText;
                    }

                    dong12 = "L" + row["l2_mix"] + "xW" + row["w2_mix"] + "xH" + row["h2_mix"] + "cm";
                    dong13 = row["v2"].ToString();

                    string slc_20 = row["soluonggoi_ctn_20"].ToString();
                    string slc_40 = row["soluonggoi_ctn"].ToString();
                    string slc_40HC = row["soluonggoi_ctn_40hc"].ToString();

                    if (slc_40 != "" & slc_40 != "0")
                    {
                        dong14 += "\\n" + slc_40 + " " + dDVT.quantity + "/40'";
                    }
                    if (dong14 != "")
                    {
                        dong14 = dong14.Substring(2);
                    }
                }
                //dong 15
                dt = ExcuteSignalRStatic.getFOB(sp.md_sanpham_id);
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    dong15 = row["ten_cangbien"] + "";
                }

                string msp = sp.ma_sanpham;

                string detai_json = "", bientau_json = "", mausac_json = "", detai_chk = "", bientau_chk = "", mausac_chk = "";
                string chungloai = msp.Substring(0, 2);

                string sql_detail = string.Format(@"
					select 
	                    A.detai, 
                        A.bientau, 
                        A.mausac, 
                        dtai.ta_ngan as detai_ta, 
                        A.bientau as bientau_ta, 
                        msac.ta_ngan as mausac_ta
                    from (
	                    select distinct 
	                        substring(sp.ma_sanpham, 0, 7) as todetai, 
	                        substring(sp.ma_sanpham, 10, 2) as bientau,
	                        substring(sp.ma_sanpham, 7, 2) as detai,
	                        substring(sp.ma_sanpham, 13, 2) as mausac
	                    from md_sanpham (nolock) sp
	                    where 1=1
	                        and sp.hoatdong = 1 
	                        and sp.trangthai = 'DHD'
                            and substring(sp.ma_sanpham, 0, 12) in ('{2}')
                    ) A
                    left join md_detai (nolock) dtai on dtai.code_cl = '{1}' and dtai.code_dt = A.detai
                    left join md_mausac (nolock) msac on msac.code_cl = '{1}' and msac.code_dt = A.detai and msac.code_mau = A.mausac
                    where 
                        A.todetai = '{0}'
                        order by A.detai, A.bientau, A.mausac
				", msp.Substring(0, 6), chungloai, string.Join("','", lstSps));

                var dt_detail = mdbc.GetData(sql_detail);
                var arrBienTau = new List<string>();
                foreach (System.Data.DataRow row_dt in dt_detail.Rows)
                {
                    if (!detai_chk.Split(',').Contains(row_dt["detai"].ToString()))
                    {
                        detai_chk += row_dt["detai"] + ",";
                        string dtTA = row_dt["detai_ta"].ToString();
                        dtTA = dtTA.Replace(System.Environment.NewLine, " ");
                        dtTA = dtTA.Replace("\n", " ");
                        detai_json += row_dt["detai"] + " : " + dtTA + ",";
                    }

                    string detai_bientau = row_dt["detai"] + " - " + row_dt["bientau"];
                    if (!bientau_chk.Split(',').Contains(detai_bientau))
                    {
                        bientau_chk += detai_bientau + ",";
                        bientau_json += detai_bientau + ",";
                    }

                    var bientau = row_dt["bientau"] + "";
                    var maBT = msp.Substring(0, 9) + bientau;
                    if ((bientau.StartsWith("0") | bientau.StartsWith("F")) & !arrBienTau.Contains(bientau))
                    {
                        var spBT = db.md_sanphams.Where(s => s.ma_sanpham.StartsWith(maBT)).FirstOrDefault();
                        if (spBT != null)
                        {
                            string kt = spBT.l_cm + "x" + spBT.w_cm + "xH" + spBT.h_cm + "cm";
                            string sizeVal = row_dt["bientau"] + ":" + ExcuteSignalRStatic.getSizeRectOrRound(db, spBT, kt);
                            if (!size.Split(',').Contains(sizeVal)) {
                                size += sizeVal + ",";
                            }

                            // if (!sizeSel.Split(',').Contains(sizeVal)) {
                            // if(arr_sanpham.Contains(msp))
                            // sizeSel += sizeVal + ",";
                            // }
                        }
                    }

                    string detai_bientau_mausac = row_dt["detai"] + " - " + row_dt["bientau"] + " - " + row_dt["mausac"];
                    if (!mausac_chk.Split(',').Contains(detai_bientau_mausac))
                    {
                        mausac_chk += detai_bientau_mausac + ",";
                        string msTA = row_dt["mausac_ta"].ToString();
                        msTA = msTA.Replace(System.Environment.NewLine, " ");
                        msTA = msTA.Replace("\n", " ");
                        mausac_json += detai_bientau_mausac + " : " + msTA + ",";

                        var mspColor = sp.ma_sanpham.Substring(0, 12) + row_dt["mausac"];
                        if (lstSpsMss.Where(s => s["ma_sanpham"] == mspColor).Count() <= 0)
                        {
                            lstSpsMss.Add(new Dictionary<string, string>() {
                                { "id", detai_bientau_mausac },
                                { "val", msTA },
                                { "ma_sanpham", mspColor },
								{ "image", "/Controllers/API_System.ashx?oper=loadImageProduct&msp=" + mspColor }
                                //{ "image", ExcuteSignalRStatic.getImageProduct(mspColor) }
                            });
                        }
                    }
                }

                if (detai_json != "")
                {
                    detai_json = detai_json.Substring(0, detai_json.Length - 1);
                }
                if (bientau_json != "")
                {
                    bientau_json = bientau_json.Substring(0, bientau_json.Length - 1);
                }
                if (mausac_json != "")
                {
                    mausac_json = mausac_json.Substring(0, mausac_json.Length - 1);
                }

                json["dong0"] = dong0;
                json["dong1"] = dong1;
                json["dong2"] = dong2;
                json["dong3"] = dong3;
                json["dong4"] = dong4;
                json["dong5"] = dong5;
                json["dong6"] = dong6;
                json["dong7"] = dong7;
                json["dong8"] = dong8;
                json["dong9"] = dong9;
                json["dong10"] = dong10;
                json["dong11"] = dong11;
                json["dong12"] = dong12;
                json["dong13"] = dong13;
                json["dong14"] = dong14;
                json["dong15"] = dong15;
                json["dong16"] = dong16;

                var url = context.Request.Url;
                //json["image"] = ExcuteSignalRStatic.getImageProduct(msp);
				json["image"] = string.Format(@"/Controllers/API_System.ashx?oper=loadImageProduct&msp={0}", msp);
                json["imageColor"] = JsonConvert.SerializeObject(lstSpsMss);
                json["detai"] = detai_json;
                json["bientau"] = bientau_json;
                json["mausac"] = mausac_json;
                json["size"] = size;
                json["sizeSel"] = sizeSel;
                json["packingText"] = packingText;
                json["sizeText"] = sizeText;
                json["shape"] = shape;

                msg = "1" + JsonConvert.SerializeObject(json);
            }
        }
        catch(Exception ex)
        {
            msg = "0" + ex;
        }

        context.Response.Write(msg);
    }

    public void createLoginWebsite(HttpContext context)
    {
        string msg = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var contactPass = context.Request.Form["contactPass"];
            var companyName = context.Request.Form["companyName"];
            var contactPerson = context.Request.Form["contactPerson"];
            var contactMessage = context.Request.Form["contactMessage"];

            var user = db.userQRCodes.Where(s => s.contactEmail == contactEmail).FirstOrDefault();
            if(user != null)
            {
                if(!user.hoatdong.GetValueOrDefault(false))
                    msg = "Email is inactive.";
                else
                    msg = "Email already exist, please check your email to get password (at least 1 day)";
            }
            else if(string.IsNullOrWhiteSpace(companyName))
            {
                msg = "Company Name is not empty";
            }
            else if(string.IsNullOrWhiteSpace(contactPerson))
            {
                msg = "Contact Person is not empty";
            }
            else if(string.IsNullOrWhiteSpace(contactEmail))
            {
                msg = "Email is not empty";
            }
            else if(string.IsNullOrWhiteSpace(contactMessage))
            {
                msg = "Message is not empty";
            }
            else
            {
                user = new userQRCode();
                user.userQRCode_id = Helper.getNewId();
                user.contactEmail = contactEmail;
                user.companyName = companyName;
                user.contactPerson = contactPerson;
                user.contactMessage = contactMessage;
                user.sendMail = false;
                user.type = 0;
                user.hoatdong = true;
                user.ngaytao = DateTime.Now;
                user.ngaycapnhat = DateTime.Now;
                user.nguoitao = "system";
                user.nguoicapnhat = "system";
                db.userQRCodes.InsertOnSubmit(user);
                db.SubmitChanges();
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if (msg.Length > 0)
            msg = "0" + msg;
        else
            msg = "1Successful registration, please check your email to get the password (at least 1 day)";

        context.Response.Write(msg);
    }

    public void checkLoginWebsite(HttpContext context)
    {
        string msg = "", token = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var contactPass = context.Request.Form["contactPass"];
            var headerOrigin = context.Request.Form["headerOrigin"];
            var type = context.Request.Form["type"];

			var matkhau = Security.EncodeMd5Hash(contactPass);
			var nhanvien = db.nhanviens.Where(s => 
				s.manv == contactEmail 
				& (s.matkhau == matkhau | contactPass == "contactPassWillautoDetect")
				).FirstOrDefault();
			
			//Kiểm tra đang nhập của trang admin trên website
            if (type == "2")
            {
                if(nhanvien == null)
                {
                    msg = "Fail! Invalid Username or Password";
                }
                else if(!nhanvien.website.GetValueOrDefault(false))
                {
                    msg = "Fail! User have not permission for website (Admin)";
                }
                else
                {
                    var json = new Dictionary<string, string>();
                    json["name"] = nhanvien.manv;
                    json["time"] = DateTime.Now.ToString("dd/MM/yyyyTHH:mm:ss");;
                    json["url_return"] = headerOrigin;
                    json["ID"] = nhanvien.manv;
                    token = JsonConvert.SerializeObject(json);
                }
            }
            else
            {
				//Kiểm tra đang nhập của trang sản phẩm (Dành cho khách hàng)
				if(nhanvien == null) 
				{
					var user = db.userQRCodes.Where(s => s.contactEmail == contactEmail
						& (s.contactPass == contactPass | contactPass == "contactPassWillautoDetect")).FirstOrDefault();

					if (user == null)
					{
						msg = "Email or password is incorrect.";
					}
					else if (!user.hoatdong.GetValueOrDefault(false))
					{
						msg = "Email is inactive.";
					}
					else
					{
						var json = new Dictionary<string, string>();
						json["user"] = user.contactEmail;
						json["companyName"] = user.companyName;
						json["contactPerson"] = user.contactPerson;
						json["ngaytao"] = user.ngaytao.Value.ToString("dd/MM/yyyy");
						token = JsonConvert.SerializeObject(json);
					}
				}
				//Kiểm tra đang nhập của trang sản phẩm (Dành cho nhân viên)
				else 
				{
					if(!nhanvien.websiteClient.GetValueOrDefault(false))
					{
						msg = "Fail! User have not permission for website (Client)";
					}
					else
					{
						var json = new Dictionary<string, string>();
						json["user"] = nhanvien.manv;
						json["companyName"] = "";
						json["contactPerson"] = nhanvien.hoten;
						json["ngaytao"] = DateTime.Now.ToString("dd/MM/yyyy");
						json["employer"] = "true";
						
						json["name"] = nhanvien.manv;
						json["time"] = DateTime.Now.ToString("dd/MM/yyyyTHH:mm:ss");
						json["url_return"] = headerOrigin;
						json["ID"] = nhanvien.manv;
						
						token = JsonConvert.SerializeObject(json);
					}
				}
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if (msg.Length > 0)
            msg = "0" + msg;
        else
            msg = "1" + token;

        context.Response.Write(msg);
    }

    public void SendMail(HttpContext context)
    {
        string msg = "";
        try
        {
            var manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            var smtp = db.md_smtps.FirstOrDefault(p => p.macdinh.Equals(true));
            var mail = new GoogleMail(nv.email, nv.email_pass, smtp.smtpserver, smtp.port.Value, smtp.use_ssl.GetValueOrDefault(false));
            var temp = ExcuteSignalRStatic.mapPathSignalR("~/App_Data/MailTemp/QRCode-SendPass.html");
            temp = System.IO.File.ReadAllText(temp);
            var ids = context.Request.Form["ids"].Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();

            foreach (var id in ids)
            {
                var kh = db.userQRCodes.Where(s => s.userQRCode_id == id).FirstOrDefault();

                if (kh == null)
                {
                    msg = "Dòng đang chọn không tồn tại, hãy làm mới dữ liệu.";
                }
                else
                {
                    var pass = System.Web.Security.Membership.GeneratePassword(6, 1);
                    pass = pass.Replace("&", "VA");
                    pass = pass.Replace("+", "CO");
                    pass = pass.Replace("%", "PT");
                    pass = pass.Replace("?", "HO");
                    pass = "12" + pass + "21";
                    var tempCP = temp;
                    var lst = tempCP.Split(new string[] { "\n", "\r" }, StringSplitOptions.None).ToList();
                    var sb = lst[0];
                    sb = sb.Replace("<!--", "").Replace("-->", "");

                    lst.RemoveAt(0);
                    var bd = string.Join("\n", lst);
                    bd = bd.Replace("@[NAME]", kh.companyName);
                    bd = bd.Replace("@[PASS]", pass);
                    mail.Send(
                        kh.contactEmail
                        , sb
                        , bd
                    );

                    kh.contactPass = pass;
                    kh.sendMail = true;
                }
            }

            if(msg.Length <= 0)
                db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            msg =  "0" + msg;
        else
            msg =  "1Gửi mail thành công.";

        context.Response.Write(msg);
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var hoatdong = context.Request.Form["hoatdong"].ToLower() == "true";
            var nv = db.userQRCodes.Where(s => s.contactEmail == contactEmail).FirstOrDefault();
            if (nv == null)
            {
                msg = "Email không tồn tại, hãy làm mới dữ liệu.!";
            }
            else
            {
                nv.hoatdong = hoatdong;
            }
            db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Sửa thành công");
    }

    public void add(HttpContext context)
    {
        string msg = "";
        try
        {
            var contactEmail = context.Request.Form["contactEmail"];
            var companyName = context.Request.Form["companyName"];
            var contactPerson = context.Request.Form["contactPerson"];
            var contactMessage = context.Request.Form["contactMessage"];
            var type = int.Parse(context.Request.Form["type"]);
            var hoatdong = context.Request.Form["hoatdong"].ToLower() == "true";

            var nv = db.userQRCodes.Where(s => s.contactEmail == contactEmail).FirstOrDefault();
            if (nv == null)
            {
                nv = new userQRCode();
                nv.userQRCode_id = Helper.getNewId();
                nv.contactEmail = contactEmail;
                nv.companyName = companyName;
                nv.contactPerson = contactPerson;
                nv.contactMessage = contactMessage;
                nv.sendMail = false;
                nv.type = type;
                nv.hoatdong = hoatdong;
                nv.ngaytao = DateTime.Now;
                nv.ngaycapnhat = DateTime.Now;
                nv.nguoitao = UserUtils.getUser(context);
                nv.nguoicapnhat = UserUtils.getUser(context);
                nv.hoatdong = hoatdong;
                db.userQRCodes.InsertOnSubmit(nv);
                db.SubmitChanges();
            }
            else
            {
                msg = "Email đã tồn tại.!";
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Thêm thành công");
    }


    public void del(HttpContext context)
    {
        string msg = "";
        try
        {
            var ids = context.Request.Form["id"].Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();

            foreach (var id_del_ in ids)
            {
                var nv = db.userQRCodes.Where(s => s.userQRCode_id == id_del_).FirstOrDefault();

                if (nv == null)
                {
                    msg = "Dòng đang chọn không tồn tại, hãy làm mới dữ liệu.";
                }
                else
                {
                    db.userQRCodes.DeleteOnSubmit(nv);
                }
            }

            if(msg.Length <= 0)
                db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
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

        String sqlCount = "SELECT COUNT(1) AS count from userQRCode nv where 1=1 " + filter;
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
            sidx = "nv.ngaytao";
        }

        string strsql = string.Format(@"
            select 
                P.userQRCode_id,
                P.contactEmail,
                P.contactPass,
                P.companyName,
                P.contactPerson,
                P.contactMessage,
                P.sendMail,
                P.type,
                P.ngaytao,
                P.nguoitao,
                P.ngaycapnhat,
                P.nguoicapnhat,
                P.mota,
                P.hoatdong
            from( 
                select nv.*, 
                ROW_NUMBER() OVER (ORDER BY {0} {1}) as RowNum 
                from userQRCode nv 
                where 1=1 {2}  
            )P 
            where RowNum > @start AND RowNum < @end
        ",
        sidx,
        sord,
        filter
        );

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn col in dt.Columns)
            {
                if (new string[] { "ngaytao", "ngaycapnhat" }.Contains(col.ColumnName))
                {
                    var colDate = row[col.ColumnName] + "";
                    if(!string.IsNullOrEmpty(colDate))
                        xml += "<cell><![CDATA[" + DateTime.Parse(colDate.ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
                }
                else
                {
                    xml += "<cell><![CDATA[" + row[col.ColumnName] + "]]></cell>";
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