using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;
using Newtonsoft.Json;

[HubName("mainhub")]
public class MainHub : Hub
{
    public partial class UserLoginMobile
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }

    public void Login(UserLoginMobile user)
    {
        string manv = user.Username;
        string password = user.Password;
        string json = string.Format(@"[{{ ""user"":""{0}"", ""key"":""{1}"", ""status"":""{2}""}}]", manv, "", "false");
        var response = new Dictionary<string,object>()
        {
            { "Success", false },
            { "Message", json }
        };

        if (manv != "" & manv != null)
        {
            string matkhau = Security.EncodeMd5Hash(password);
            string manvmd5 = Security.EncodeMd5Hash(manv);
            string sql = "select * from nhanvien where manv = @manv and matkhau = @matkhau and hoatdong = 1";
            var dt = mdbc.GetData(sql, "@manv", manv, "@matkhau", matkhau);

            if (dt.Rows.Count != 0)
            {
                json = string.Format(@"[{{ ""user"":""{0}"", ""key"":""{1}"", ""status"":""{2}""}}]", manv, manvmd5, "true");
            }

            response["Success"] = true;
            response["Message"] = json;
        }
        
        Clients.Caller.Login(response);
    }

    public void ProductInfo(string ma_sanpham)
    {
        var db = new LinqDBDataContext();
        string arr_sanpham = "'" + ma_sanpham + "'";
        var response = new Dictionary<string, object>()
        {
            { "Success", false },
            { "Message", "" }
        };
        try
        {
            ma_sanpham = ma_sanpham.Split(new[] { '\r', '\n' }).FirstOrDefault();
            string unknown = "(Unknown)";
            string dong0 = unknown, dong1 = unknown, dong2 = unknown, dong3 = unknown, dong4 = unknown, dong5 = unknown, dong6 = unknown, dong7 = unknown,
            dong8 = "", dong9 = "", dong10 = unknown, dong11 = unknown, dong12 = unknown, dong13 = unknown, dong14 = "", dong15 = unknown, dong16 = unknown, image = "";
            string json = @"[{{ ""dong0"":""{0}"", ""dong1"":""{1}"", ""dong2"":""{2}"", ""dong3"":""{3}"", 
			""dong4"":""{4}"", ""dong5"":""{5}"", ""dong6"":""{6}"", ""dong7"":""{7}"", ""dong8"":""{8}"", ""dong9"":""{9}"", 
			""dong10"":""{10}"", ""dong11"":""{11}"", ""dong12"":""{12}"", ""dong13"":""{13}"", ""dong14"":""{14}"",
			""dong15"":""{15}"", ""dong16"":""{16}"", ""image"":""{17}"", ""detai"":""{18}"", ""bientau"":""{19}"", ""mausac"":""{20}""}}]";


            md_sanpham sp = db.md_sanphams.FirstOrDefault(s => s.ma_sanpham == ma_sanpham & s.trangthai == "DHD");
            if (sp != null)
            {
                string cl = sp.ma_sanpham.Substring(0, 2);
                string bc = sp.ma_sanpham.Substring(9, 2);

                md_chungloai plhh = db.md_chungloais.FirstOrDefault(s => s.code_cl == cl);
                if (plhh != null)
                {
                    dong0 = plhh.ta_ngan.ToUpper();
                }
                dong6 = sp.ma_sanpham;
                //dong 7, dong 8, dong 9
                if (bc.Substring(0, 1) != "0" & bc != "S1")
                {
                    //Tim` bo S cua san pham
                    string msp_0009 = sp.ma_sanpham.Substring(0, 9), msp_1103 = sp.ma_sanpham.Substring(11, 3);
                    string ma_bo_cha = db.md_sanphams.Where(s => s.ma_sanpham.Substring(0, 9) == msp_0009
                    & s.ma_sanpham.Substring(11, 3) == msp_1103 & s.ma_sanpham.Substring(9, 2).Contains("S")).Select(s => s.ma_sanpham.Substring(9, 2)).FirstOrDefault();
                    //Lay cac ma cai thuoc bo cua san pham
                    string md_bo_id = db.md_bos.Where(s => s.ma_bo == bc & s.ma_bo_cha == ma_bo_cha).Select(s => s.md_bo_id).FirstOrDefault();
                    foreach (md_bo_chitiet bct in db.md_bo_chitiets.Where(s => s.md_bo_id == md_bo_id))
                    {
                        string sanpham_add = msp_0009 + bct.md_bo_detail + msp_1103;
                        arr_sanpham += ",'" + sanpham_add + "'";
                    }
                }
                string strsql =
                @"select T.* from(
					select sp.ma_sanpham, gsp.gia, dt.ma_iso, pbg.ngay_hieuluc, sp.l_cm, sp.w_cm, sp.h_cm,
					row_number() over(partition by sp.ma_sanpham order by pbg.ngay_hieuluc desc) as rn
					FROM md_sanpham sp, md_banggia bg, md_phienbangia pbg,
					 md_giasanpham gsp, md_dongtien dt 
					 WHERE gsp.md_phienbangia_id = pbg.md_phienbangia_id 
					 AND pbg.md_banggia_id = bg.md_banggia_id 
					 AND bg.md_dongtien_id = dt.md_dongtien_id 
					 AND gsp.hoatdong = 1 
					 AND bg.banggiaban = 1 
					 AND substring(bg.ten_banggia,0,5) = 'FOB-'
					 AND sp.ma_sanpham in ({0}) 
					 AND gsp.md_sanpham_id = sp.md_sanpham_id
				 )T
				where T.rn = 1 order by T.ma_sanpham";

                strsql = string.Format(strsql, arr_sanpham);
                System.Data.DataTable dt = mdbc.GetData(strsql);

                string kichthuoc_9 = "";
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    if (row["ma_sanpham"].ToString() != ma_sanpham)
                    {
                        //dong8 += "$" + row["gia"].ToString() + " / ";
                        if (row["l_cm"].ToString() != "0.0" & row["w_cm"].ToString() != "0.0" & row["h_cm"].ToString() != "0.0")
                        {
                            dong9 += row["l_cm"] + "x" + row["w_cm"] + "xH" + row["h_cm"] + "/ \\n          ";
                        }
                    }
                    else
                    {
                        dong7 = "$" + row["gia"].ToString();
                        if (row["l_cm"].ToString() != "0.0" & row["w_cm"].ToString() != "0.0" & row["h_cm"].ToString() != "0.0")
                        {
                            kichthuoc_9 = row["l_cm"] + "x" + row["w_cm"] + "xH" + row["h_cm"];
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
                //dong 10, dong 11, dong 12, dong 13, dong 14
                strsql =
                @"
				select dg.sl_inner, (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_inner) as dvtinner,
				dg.sl_outer, (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_outer) as dvtouter,
				dg.l1, dg.w1, dg.h1,
				dg.l2_mix, dg.w2_mix, dg.h2_mix, convert(decimal(18,3), dg.v2 / dg.sl_outer) as v2, dg.sl_cont_mix, dg.soluonggoi_ctn_20, dg.soluonggoi_ctn, dg.soluonggoi_ctn_40hc
				FROM md_donggoisanpham dgsp, md_donggoi dg
				WHERE 
				dgsp.md_sanpham_id = '{0}'
				AND dgsp.md_donggoi_id = dg.md_donggoi_id
				AND dgsp.macdinh = 1";

                strsql = string.Format(strsql, sp.md_sanpham_id);
                dt = mdbc.GetData(strsql);
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    string sl_inner = row["sl_inner"].ToString(), dvt_inner = row["dvtinner"].ToString();
                    string sl_outer = row["sl_outer"].ToString(), dvt_outer = row["dvtouter"].ToString();
                    if (sl_inner != "0" & dvt_inner != "0" & sl_inner != "" & dvt_inner != "")
                    {
                        dong10 = sl_inner + " " + dvt_inner;
                    }
                    else
                    {
                        dong10 = " ";
                    }

                    if (sl_outer != "0" & dvt_outer != "0" & sl_outer != "" & dvt_outer != "")
                    {
                        dong11 = sl_outer + " " + dvt_outer;
                    }
                    else
                    {
                        dong11 = " ";
                    }

                    dong12 = "L" + row["l2_mix"] + "xW" + row["w2_mix"] + "xH" + row["h2_mix"] + "cm";
                    dong13 = row["v2"].ToString();

                    // if(row["sl_cont_mix"].ToString() != "") {
                    // dong14 = " " + row["sl_cont_mix"] + "/01'";
                    // }
                    string slc_20 = row["soluonggoi_ctn_20"].ToString();
                    string slc_40 = row["soluonggoi_ctn"].ToString();
                    string slc_40HC = row["soluonggoi_ctn_40hc"].ToString();
                    // if(slc_20 != "" & slc_20 != "0") {
                    // dong14 += "\\n" + slc_20 + " pallets/20'";
                    // }
                    if (slc_40 != "" & slc_40 != "0")
                    {
                        dong14 += "\\n" + slc_40 + " pallets/40'";
                    }
                    // if(slc_40HC != "" & slc_40HC != "0") {
                    // dong14 += "\\n" + slc_40HC + " pallets/40'HC";
                    // }
                    if (dong14 != "")
                    {
                        dong14 = dong14.Substring(2);
                    }

                    if (dong9 == "")
                    {
                        if (row["l1"].ToString() != "0.0" & row["w1"].ToString() != "0.0" & row["h1"].ToString() != "0.0")
                        {
                            dong9 = row["l1"] + "x" + row["w1"] + "xH" + row["h1"] + "cm";
                        }
                    }
                }
                //dong 15
                strsql =
                @"
				select cb.ten_cangbien
				FROM md_cangxuathang cxh, md_cangbien cb
				WHERE 
				cxh.md_sanpham_id = '{0}'
				AND cxh.md_cangbien_id = cb.md_cangbien_id
				AND cxh.macdinh = 1";

                strsql = string.Format(strsql, sp.md_sanpham_id);
                dt = mdbc.GetData(strsql);
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    dong15 = row["ten_cangbien"] + "";
                }

                string msp = sp.ma_sanpham;
                if (!msp.Contains("-F"))
                {
                    image = msp.Substring(0, 8) + ".jpg";
                }
                else
                {
                    image = msp.Substring(0, 11) + ".jpg";
                }

                string detai_json = "", bientau_json = "", mausac_json = "", detai_chk = "", bientau_chk = "", mausac_chk = "";
                string chungloai = msp.Substring(0, 2);

                string sql_detail = string.Format(@"
					select A.detai, A.bientau, A.mausac, dtai.ta_ngan as detai_ta, A.bientau as bientau_ta, msac.ta_ngan as mausac_ta from (
						select distinct 
						substring(sp.ma_sanpham, 0, 7) as todetai, 
						substring(sp.ma_sanpham, 10, 2) as bientau,
						substring(sp.ma_sanpham, 7, 2) as detai,
						substring(sp.ma_sanpham, 13, 2) as mausac
						from md_sanpham sp
						where 1=1
						and sp.hoatdong = 1 
						and sp.trangthai = 'DHD'
					) A
					left join md_detai dtai on dtai.code_cl = '{1}' and dtai.code_dt = A.detai
					left join md_mausac msac on msac.code_cl = '{1}' and msac.code_dt = A.detai and msac.code_mau = A.mausac
					where 
					A.todetai = '{0}'
					order by A.detai, A.bientau, A.mausac
				", msp.Substring(0, 6), chungloai);
                System.Data.DataTable dt_detail = mdbc.GetData(sql_detail);
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

                    string detai_bientau_mausac = row_dt["detai"] + " - " + row_dt["bientau"] + " - " + row_dt["mausac"];
                    if (!mausac_chk.Split(',').Contains(detai_bientau_mausac))
                    {
                        mausac_chk += detai_bientau_mausac + ",";
                        string msTA = row_dt["mausac_ta"].ToString();
                        msTA = msTA.Replace(System.Environment.NewLine, " ");
                        msTA = msTA.Replace("\n", " ");
                        mausac_json += detai_bientau_mausac + " : " + msTA + ",";
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

                string kq_json = string.Format(json, dong0, dong1, dong2, dong3, dong4, dong5, dong6, dong7, dong8, dong9, dong10, dong11, dong12, dong13, dong14,
                dong15, dong16, image, detai_json, bientau_json, mausac_json);
                response["Message"] = kq_json;
            }
        }
        catch
        {

        }
        Clients.Caller.ProductInfo(response);
    }
}