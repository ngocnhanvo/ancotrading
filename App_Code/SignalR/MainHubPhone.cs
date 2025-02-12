using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;
using Newtonsoft.Json;
using System.IO;
using System.Web;

[HubName("mainhubphone")]
public class MainHubPhone : Hub
{
    public partial class UserLoginMobile
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }

    public partial class UserApp
    {
        public string user { get; set; }
        public string name { get; set; }
        public string key { get; set; }
        public string status { get; set; }
    }

    public string emailcc = "anco@ancopottery.com";

    public void Login(UserLoginMobile user)
    {
        string manv = user.Username;
        string password = user.Password;
        dynamic data = new UserApp();
        data.user = manv;
        data.name = "";
        data.key = "";
        data.status = "false";

        string json = $@"[{JsonConvert.SerializeObject(data)}]";
        var response = new Dictionary<string, object>()
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

            if (dt.Rows.Count > 0)
            {
                data.name = dt.Rows[0]["hoten"];
                data.key = manvmd5;
                data.status = "true";
                json = $@"[{JsonConvert.SerializeObject(data)}]";
            }

            response["Success"] = true;
            response["Message"] = json;
        }

        Clients.Caller.Login(response);
    }

    public void CreateQO(dynamic parrams)
    {
        var response = new Dictionary<string, object>()
        {
            { "Success", false },
            { "Message", "" }
        };

        string msg = "";
        string BaoGiaID = parrams.BaoGiaID + "";
        string countStr = parrams.count + "";
        try
        {
            int count = countStr.ToNullableInt().GetValueOrDefault(0);
            var db = new LinqDBDataContext();
            var exec = new ExcuteSignalR();
            string username = parrams.username + "";
            string ma_dtkd = parrams.ma_dtkd + "";
            string ten_dtkd = parrams.ten_dtkd + "";
            string email = parrams.email + "";
            string phone = parrams.phone + "";
            string address = parrams.address + "";
            string nguoilienhe = parrams.nguoilienhe + "";
            string note = parrams.note + "";
            string note2 = parrams.note2 + "";
            string json_data = parrams.json_data + "";
            var d = JsonConvert.DeserializeObject<List<Objects.Json_product>>(json_data);

            var nv = db.nhanviens.FirstOrDefault(p => p.manv == username);
            if (nv == null)
            {
                msg = $@"Not found user ""${username}"" in system.";
            }
            else
            {
                var dtkd = exec.createDTKD(db, ma_dtkd, ten_dtkd, email, phone, address, nguoilienhe, note);

                bool hd = false, gia_db = false;
                int check = 0; // validate form on server
                int qo_mau = 1;

                string sochungtu = jqGridHelper.Utils.taoChungTuQO(dtkd.md_doitackinhdoanh_id, qo_mau, DateTime.Now.Year.ToString());


                string md_trongluong_id = "", md_cangbien_id = "", md_dongtien_id = "", md_kichthuoc_id = "";
                md_trongluong trl = db.md_trongluongs.FirstOrDefault(s => s.ten_trongluong == "kg");
                md_dongtien dtien = db.md_dongtiens.FirstOrDefault(s => s.ma_iso == "USD");
                md_cangbien cb = db.md_cangbiens.FirstOrDefault(s => s.ma_cangbien == "HCMP");
                md_kichthuoc kt = db.md_kichthuocs.FirstOrDefault(s => s.ten_kichthuoc == "cm");
                if (trl != null)
                {
                    md_trongluong_id = trl.md_trongluong_id;
                    md_dongtien_id = dtien.md_dongtien_id;
                    md_kichthuoc_id = kt.md_kichthuoc_id;
                    md_cangbien_id = cb.md_cangbien_id;
                }

                c_baogia mnu = new c_baogia
                {
                    c_baogia_id = Helper.getNewId(),
                    sobaogia = sochungtu,
                    md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id,
                    shipmenttime = 75,
                    ngaybaogia = DateTime.Now,
                    ngayhethan = DateTime.Now.AddMonths(6),
                    md_trongluong_id = md_trongluong_id,
                    md_cangbien_id = md_cangbien_id,
                    md_dongtien_id = md_dongtien_id,
                    md_kichthuoc_id = md_kichthuoc_id,
                    totalcbm = 0,
                    totalcbf = 0,
                    totalquo = 0,
                    isform = true,
                    moq_item_color = "",
                    md_trangthai_id = Helper.SOANTHAO,
                    nguoitao = username,
                    nguoicapnhat = username,
                    mota = note2,
                    hoatdong = hd,
                    gia_db = gia_db,
                    emailKH = email,
                    ngaytao = DateTime.Now,
                    ngaycapnhat = DateTime.Now
                };

                if (json_data == null | json_data == "" | json_data == "[]")
                {
                    check = 1;
                    msg = "Error: Have no product.";
                }
                else if (ma_dtkd.Trim() == "")
                {
                    check = 1;
                    msg = "Error: Customer Code is not empty.";
                }
                else if (ten_dtkd.Trim() == "")
                {
                    check = 1;
                    msg = "Error: Customer Name is not empty.";
                }

                if (check == 0)
                {
                    var mnuqr = new c_baogiaqr();
                    mnu.CopyPropertiesTo(mnuqr);
                    mnuqr.c_baogiaqr_id = mnu.c_baogia_id;
                    mnuqr.sobaogia = "***/" + sochungtu.Substring(4);
                    db.c_baogiaqrs.InsertOnSubmit(mnuqr);
                    db.SubmitChanges();

                    String getOrder = "select max(sothutu) as count from c_chitietbaogiaqr where c_baogiaqr_id = @c_baogia_id";
                    object omax = mdbc.ExecuteScalar(getOrder, "@c_baogia_id", mnuqr.c_baogiaqr_id);
                    int maxOrder = omax.ToString().Equals("") ? 0 : (int)omax;
                    foreach (var row in d)
                    {
                        decimal gia_fob = 0;
                        try { gia_fob = decimal.Parse(row.price.Replace("$", "").Replace(" ", "")); } catch { }
                        exec.add_ctbg(row.ma_sanpham, maxOrder, gia_fob, mnuqr.c_baogiaqr_id, username, dtkd.md_doitackinhdoanh_id, db, "qr", row.soluong);
                    }
                    db.SubmitChanges();

                    msg = parrams.success;
                    response["Success"] = true;
                    count++;
                    response["Count"] = count;
                }
            }
        }
        catch (Exception ex)
        {
            msg = ex + "";
        }
        response["Message"] = msg;
        response["BaoGiaID"] = BaoGiaID;
        Clients.Caller.QOPOexcute(response);
    }
}