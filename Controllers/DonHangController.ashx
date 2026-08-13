<%@ WebHandler Language="C#" Class="DonHangController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;
public class DonHangController : IHttpHandler, IDisposable
{
    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        context.DisposeOnPipelineCompleted(this);
        String action, oper;
        action = context.Request.Params["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "huypo":
                this.HuyDonHang(context);
                break;
            case "getpoinformation":
                this.getPoInformation(context);
                break;
            case "stoppo":
                this.stopPO(context);
                break;
            case "sendmail":
                this.sendMail(context);
                break;
            case "getoption":
                this.getSelectOption(context);
                break;
            case "createpi":
                this.createPI(context);
                break;
            case "activepo":
                this.activePO(context);
                break;
            case "viewcapacity":
                this.viewCapacity(context);
                break;
            case "getdocument":
                this.getDocument(context);
                break;
            case "get_dsncc":
                this.get_dsncc(context);
                break;
            case "CopyDonHang":
                this.CopyDonHang(context);
                break;
            case "ChuyenDonHang":
                this.ChuyenDonHang(context);
                break;
            case "ChuyenChungTu":
                this.ChuyenChungTu(context);
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

    #region action
    public static T Clone<T>(T source)
    {
        var dcs = new System.Runtime.Serialization.DataContractSerializer(typeof(T));
        using (var ms = new System.IO.MemoryStream())
        {
            dcs.WriteObject(ms, source);
            ms.Seek(0, System.IO.SeekOrigin.Begin);
            return (T)dcs.ReadObject(ms);
        }
    }

    public void ChuyenChungTu(HttpContext context)
    {
        string msg = "";
        var dhut_po = context.Request.Form["dhut_po"].removeAllSpaceOrTrimText(true);
        var slcont20_po = context.Request.Form["slcont20"].removeAllSpaceOrTrimText(true).ToNullableDecimal();
        var slcont40_po = context.Request.Form["slcont40"].removeAllSpaceOrTrimText(true).ToNullableDecimal();
        var slcont40hc_po = context.Request.Form["slcont40hc"].removeAllSpaceOrTrimText(true).ToNullableDecimal();
        var slcont45_po = context.Request.Form["slcont45"].removeAllSpaceOrTrimText(true).ToNullableDecimal();
        var slcontLCL_po = context.Request.Form["slcontLCL"].removeAllSpaceOrTrimText(true).ToNullableDecimal();
        var nxhdc_po = context.Request.Form["nxhdc_po"].removeAllSpaceOrTrimText(true);
        var ghichu_po = context.Request.Form["ghichu_po"].removeAllSpaceOrTrimText(true);

        //var loaichuyen_po = context.Request.Form["loaichuyen_po"].removeAllSpaceOrTrimText(true);
        //var laBoSung = loaichuyen_po == Helper.Bosung;
        //var laDacBiet = loaichuyen_po == Helper.Dacbiet;
        //var laNhieuDonRiengLe = loaichuyen_po == "NhieuDonRiengLe";

        var loaichuyen_po = context.Request.Form["loaichuyen_po"].removeAllSpaceOrTrimText(true);

        var laBoSung = loaichuyen_po == Helper.Bosung;
        var laDacBiet = loaichuyen_po == Helper.Dacbiet;
        var laNhieuDonRiengLe = loaichuyen_po == "NhieuDonRiengLe";

        var laChuyenXuatNhieuLan = loaichuyen_po == "ChuyenXuat2Lan" || loaichuyen_po == "ChuyenXuat3Lan";

        int soLanChuyenXuat = 1;

        if (loaichuyen_po == "ChuyenXuat2Lan")
        {
            soLanChuyenXuat = 2;
        }
        else if (loaichuyen_po == "ChuyenXuat3Lan")
        {
            soLanChuyenXuat = 3;
        }



        var files = context.Request.Files;
        var lengthF = files.Count;

        try
        {
            string[] ids = context.Request.Params["id"].Split(',');
            var dhs = db.c_donhangs.Where(s => ids.Contains(s.c_donhang_id)).ToList();


            //#beginvts-02-06-2026
            var khachHangKhacNhau = dhs
            .Select(s => s.md_doitackinhdoanh_id)
            .Distinct()
            .Count();

            if (khachHangKhacNhau > 1 && !laNhieuDonRiengLe)
            {
                msg = "Không thể gửi chứng từ. Các PO được chọn phải cùng khách hàng.";
                goto EndEventHandler;
            }
            //#endvts-02-06-2026

            var dhst = dhs.Where(s => s.md_trangthai_id == Helper.SOANTHAO).Select(s => s.sochungtu).OrderBy(s => s).ToList();
            if (dhst.Count > 0)
            {
                msg = $@"Đơn hàng ""{string.Join(", ", dhst)}"" chưa Hiệu Lực";
                goto EndEventHandler;
            }

            string manv = UserUtils.getUser(context);
            var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
            if (nv == null)
            {
                msg = $@"Không tìm thấy nhân viên đang thực hiện chức năng này";
                goto EndEventHandler;
            }

            var tbps = (from a in db.nhanviens
                        join b in db.vaitros on a.mavt equals b.mavt
                        join c in db.vaitro2s on a.vaitro2_id equals c.vaitro2_id
                        where b.tenvt == Helper.TENBP_CHUNGTU && c.ma_vt2 == Helper.MACV_TruongBoPhan
                        orderby a.manv
                        select a.email).ToList();
            if (tbps.Count <= 0)
            {
                msg = $@"Không tìm thấy trưởng bộ phận của bộ phận {Helper.TENBP_CHUNGTU}";
                goto EndEventHandler;
            }
            var emailTBPs = string.Join(";", tbps);

            //int count = 0;
            //string idut = "", sctut = "", nvctut = "";
            int count = 0;
            string idut = "", sctut = "", nvctut = "";

            // Danh sách hồ sơ chứng từ sẽ được gắn tập tin đính kèm
            var hsctIdsDinhKem = new List<string>();

            // Danh sách tập tin cần lưu vật lý sau khi SubmitChanges
            var taptinCanLuuFiles = new List<KeyValuePair<md_taptin, int>>();

            var insertXuatLogs = new List<Action>();


            //#beginvts-02-06-2026
            int soLanBoSung = 0;
            //#endvts-02-06-2026

            if (laBoSung)
            {
                var dhut = dhs.Where(s => s.c_donhang_id == dhut_po).FirstOrDefault();
                if (dhut == null)
                {
                    msg = $@"Không tìm thấy đơn hàng ưu tiên đã chọn";
                    goto EndEventHandler;
                }

                var hsctut = db.c_donhangchungtus.Where(s => s.c_donhang_id == dhut.c_donhang_id).FirstOrDefault();
                if (dhut == null)
                {
                    msg = $@"Không tìm thấy đơn hàng ưu tiên đã chọn";
                    goto EndEventHandler;
                }

                if (hsctut == null)
                {
                    msg = $@"Đơn hàng ""{dhut.sochungtu}"" không có hồ sơ chứng từ liên kết";
                    goto EndEventHandler;
                }

                if (!string.IsNullOrWhiteSpace(hsctut.dongghep))
                {
                    msg = $@"Đơn hàng ""{dhut.sochungtu}"" không phải đơn hàng ưu tiên, nó được ghép với đơn ""{hsctut.dongghep}""";
                    goto EndEventHandler;
                }

                hsctut.trangthai2 = Helper.Bosung;
                hsctut.cont20 = slcont20_po;
                hsctut.cont40 = slcont40_po;
                hsctut.cont40hc = slcont40hc_po;
                hsctut.cont45 = slcont45_po;
                hsctut.contLCL = slcontLCL_po;
                hsctut.mota = ghichu_po;
                hsctut.ngaydieuchinh = nxhdc_po.ToNullableDate();
                hsctut.ngaychuyenhoso = DateTime.Now;



                //#beginvts-02-06-2026
                // Lấy số lần bổ sung

                soLanBoSung = db.c_donhangchungtu_bosung_logs
                    .Where(s => s.c_donhangchungtu_id == hsctut.c_donhangchungtu_id)
                    .Count() + 1;

                // Lưu lịch sử

                var log = new c_donhangchungtu_bosung_log();

                log.id = Helper.getNewId();
                log.c_donhangchungtu_id = hsctut.c_donhangchungtu_id;
                log.c_donhang_id = dhut.c_donhang_id;
                log.sochungtu = dhut.sochungtu;
                log.sothutu = soLanBoSung;

                log.cont20 = slcont20_po;
                log.cont40 = slcont40_po;
                log.cont40hc = slcont40hc_po;
                log.cont45 = slcont45_po;
                log.contLCL = slcontLCL_po;

                log.ngaydieuchinh = nxhdc_po.ToNullableDate();
                log.mota = ghichu_po;

                log.ngaygui = DateTime.Now;
                log.nguoigui = UserUtils.getUser(context);

                db.c_donhangchungtu_bosung_logs.InsertOnSubmit(log);

                //#endvts-02-06-2026



                //idut = hsctut.c_donhangchungtu_id;
                //sctut = dhut.sochungtu;

                //nvctut = db.nhanviens.Where(s => s.manv == dhut.nhanvienCT).Select(s => s.email).FirstOrDefault();
                //count = 1;
                idut = hsctut.c_donhangchungtu_id;
                sctut = dhut.sochungtu;

                hsctIdsDinhKem.Add(idut);

                nvctut = db.nhanviens
                    .Where(s => s.manv == dhut.nhanvienCT)
                    .Select(s => s.email)
                    .FirstOrDefault();

                count = 1;
            }
            else
            {

                var chuaguis = new string[] { Helper.CHUAGUI, Helper.TUCHOI };
                if (!laChuyenXuatNhieuLan)
                {
                    var dhdg = dhs
                        .Where(s => !chuaguis.Contains(s.trangthaict) & !string.IsNullOrEmpty(s.trangthaict))
                        .Select(s => s.sochungtu)
                        .OrderBy(s => s)
                        .ToList();

                    if (dhdg.Count > 0)
                    {
                        msg = $@"Đơn hàng ""{string.Join(", ", dhdg)}"" đã gửi trước đó";
                        goto EndEventHandler;
                    }
                }



                if (laChuyenXuatNhieuLan)
                {
                    // ==========================================================
                    // 1. Kiểm tra dữ liệu nhập của tất cả các lần xuất
                    // ==========================================================
                    for (int lan = 1; lan <= soLanChuyenXuat; lan++)
                    {
                        string dhutLanCheck = (context.Request.Form["dhut_po_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true);

                        if (string.IsNullOrWhiteSpace(dhutLanCheck))
                        {
                            msg = $@"Chưa chọn đơn hàng ưu tiên cho lần {lan}";
                            goto EndEventHandler;
                        }

                        var dhUuTienLanCheck = dhs.FirstOrDefault(s => s.c_donhang_id == dhutLanCheck);

                        if (dhUuTienLanCheck == null)
                        {
                            msg = $@"Không tìm thấy đơn hàng ưu tiên lần {lan}";
                            goto EndEventHandler;
                        }

                        string nvctLanCheck = db.nhanviens
                            .Where(s => s.manv == dhUuTienLanCheck.nhanvienCT)
                            .Select(s => s.email)
                            .FirstOrDefault();

                        if (string.IsNullOrWhiteSpace(nvctLanCheck))
                        {
                            msg = $@"Đơn hàng ""{dhUuTienLanCheck.sochungtu}"" chưa chọn nhân viên chứng từ";
                            goto EndEventHandler;
                        }
                    }

                    // ==========================================================
                    // 2. Lấy dữ liệu LẦN 1 để tạo c_donhangchungtu 1 lần duy nhất
                    // ==========================================================
                    string dhutLan1 = (context.Request.Form["dhut_po_lan_1"] ?? "").removeAllSpaceOrTrimText(true);

                    decimal? slcont20Lan1 = (context.Request.Form["slcont20_lan_1"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                    decimal? slcont40Lan1 = (context.Request.Form["slcont40_lan_1"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                    decimal? slcont40hcLan1 = (context.Request.Form["slcont40hc_lan_1"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                    decimal? slcont45Lan1 = (context.Request.Form["slcont45_lan_1"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                    decimal? slcontLCLLan1 = (context.Request.Form["slcontLCL_lan_1"] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();

                    string nxhdcLan1 = (context.Request.Form["nxhdc_po_lan_1"] ?? "").removeAllSpaceOrTrimText(true);
                    string ghichuLan1 = (context.Request.Form["ghichu_po_lan_1"] ?? "").removeAllSpaceOrTrimText(true);

                    var dhUuTienLan1 = dhs.FirstOrDefault(s => s.c_donhang_id == dhutLan1);

                    if (dhUuTienLan1 == null)
                    {
                        msg = "Không tìm thấy đơn hàng ưu tiên lần 1";
                        goto EndEventHandler;
                    }

                    string sctutLan1 = dhUuTienLan1.sochungtu;

                    string nvctutLan1 = db.nhanviens
                        .Where(s => s.manv == dhUuTienLan1.nhanvienCT)
                        .Select(s => s.email)
                        .FirstOrDefault();

                    if (string.IsNullOrWhiteSpace(nvctutLan1))
                    {
                        msg = $@"Đơn hàng ""{sctutLan1}"" chưa chọn nhân viên chứng từ";
                        goto EndEventHandler;
                    }

                    // Gán lại biến chính để phần gửi mail phía dưới dùng dữ liệu lần 1
                    dhut_po = dhutLan1;
                    slcont20_po = slcont20Lan1;
                    slcont40_po = slcont40Lan1;
                    slcont40hc_po = slcont40hcLan1;
                    slcont45_po = slcont45Lan1;
                    slcontLCL_po = slcontLCLLan1;
                    nxhdc_po = nxhdcLan1;
                    ghichu_po = ghichuLan1;

                    // Map PO nào có HSCT nào để log dùng đúng c_donhangchungtu_id
                    var hsctIdTheoDonHang = new Dictionary<string, string>();

                    var dhsTaoHoSo = dhs
                        .OrderBy(s => s.c_donhang_id == dhutLan1 ? 0 : 1)
                        .ThenBy(s => s.ngaylap)
                        .ToList();

                    // ==========================================================
                    // 3. Tạo c_donhangchungtu chỉ 1 lượt, giống Loại chuyển Mới
                    // ==========================================================
                    foreach (var dh in dhsTaoHoSo)
                    {
                        if (string.IsNullOrWhiteSpace(dh.nhanvienCT))
                        {
                            msg = $@"Đơn hàng ""{dh.sochungtu}"" chưa chọn nhân viên chứng từ";
                            goto EndEventHandler;
                        }

                        dh.trangthaict = Helper.DAGUI;

                        var hsct = new c_donhangchungtu();
                        hsct.c_donhangchungtu_id = Helper.getNewId();
                        hsct.trangthai = Helper.SOANTHAO;
                        hsct.c_donhang_id = dh.c_donhang_id;
                        hsct.trangthai2 = Helper.Moi;

                        if (dh.c_donhang_id == dhutLan1)
                        {
                            hsct.cont20 = slcont20Lan1;
                            hsct.cont40 = slcont40Lan1;
                            hsct.cont40hc = slcont40hcLan1;
                            hsct.cont45 = slcont45Lan1;
                            hsct.contLCL = slcontLCLLan1;
                            hsct.mota = ghichuLan1;
                            hsct.ngaydieuchinh = nxhdcLan1.ToNullableDate();
                            hsct.ngaychuyenhoso = DateTime.Now;

                            idut = hsct.c_donhangchungtu_id;
                            sctut = dh.sochungtu;
                            nvctut = nvctutLan1;
                        }
                        else
                        {
                            hsct.dongghep = sctutLan1;
                        }

                        hsct.nhanvienCT = dh.nhanvienCT;
                        hsct.ngaytao = DateTime.Now;
                        hsct.ngaycapnhat = DateTime.Now;
                        hsct.nguoitao = UserUtils.getUser(context);
                        hsct.nguoicapnhat = UserUtils.getUser(context);
                        hsct.hoatdong = true;
                        hsct.daguimail = false;

                        db.c_donhangchungtus.InsertOnSubmit(hsct);

                        hsctIdsDinhKem.Add(hsct.c_donhangchungtu_id);
                        hsctIdTheoDonHang[dh.c_donhang_id] = hsct.c_donhangchungtu_id;

                        var spd = db.c_donhang_spds
                            .Where(s => s.c_donhang_id == dh.c_donhang_id & (s.trangthai ?? "") != Helper.DAGUI)
                            .OrderByDescending(s => s.ngaytao)
                            .FirstOrDefault();

                        if (spd != null)
                        {
                            spd.trangthai = Helper.DAGUI;
                        }

                        count++;
                    }

                    // ==========================================================
                    // 4. Lưu c_donhangchungtu_xuat_log đủ 2 lần hoặc 3 lần
                    // ==========================================================
                    for (int lan = 1; lan <= soLanChuyenXuat; lan++)
                    {
                        string dhutLan = (context.Request.Form["dhut_po_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true);

                        decimal? slcont20Lan = (context.Request.Form["slcont20_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                        decimal? slcont40Lan = (context.Request.Form["slcont40_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                        decimal? slcont40hcLan = (context.Request.Form["slcont40hc_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                        decimal? slcont45Lan = (context.Request.Form["slcont45_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();
                        decimal? slcontLCLLan = (context.Request.Form["slcontLCL_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true).ToNullableDecimal();

                        string nxhdcLan = (context.Request.Form["nxhdc_po_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true);
                        string ghichuLan = (context.Request.Form["ghichu_po_lan_" + lan] ?? "").removeAllSpaceOrTrimText(true);

                        var dhUuTienLan = dhs.FirstOrDefault(s => s.c_donhang_id == dhutLan);

                        if (dhUuTienLan == null)
                        {
                            msg = $@"Không tìm thấy đơn hàng ưu tiên lần {lan}";
                            goto EndEventHandler;
                        }

                        string logHsctId = idut;

                        if (hsctIdTheoDonHang.ContainsKey(dhUuTienLan.c_donhang_id))
                        {
                            logHsctId = hsctIdTheoDonHang[dhUuTienLan.c_donhang_id];
                        }

                        string logId = Helper.getNewId();
                        string logDonHangId = dhUuTienLan.c_donhang_id;
                        string logSoChungTu = dhUuTienLan.sochungtu;
                        string logDonHangUuTien = dhUuTienLan.sochungtu;
                        int logSoThuTu = lan;
                        string logLoaiChuyen = loaichuyen_po;

                        string logNgayDieuChinhText = (nxhdcLan ?? "").Trim();

                        if (!string.IsNullOrWhiteSpace(logNgayDieuChinhText) && logNgayDieuChinhText.Length >= 10)
                        {
                            logNgayDieuChinhText = logNgayDieuChinhText.Substring(0, 10);
                        }

                        string logMota = ghichuLan ?? "";
                        DateTime logNgayGui = DateTime.Now;
                        string logNguoiGui = UserUtils.getUser(context) ?? "";

                        insertXuatLogs.Add(delegate
                        {
                            db.ExecuteCommand(@"
                                INSERT INTO c_donhangchungtu_xuat_log
                                (
                                    id,
                                    c_donhangchungtu_id,
                                    c_donhang_id,
                                    sothutu,
                                    loaichuyen,
                                    sochungtu,
                                    donhanguutien,
                                    cont20,
                                    cont40,
                                    cont40hc,
                                    cont45,
                                    contLCL,
                                    ngaydieuchinh,
                                    mota,
                                    ngaygui,
                                    nguoigui
                                )
                                VALUES
                                (
                                    {0},
                                    {1},
                                    {2},
                                    {3},
                                    {4},
                                    {5},
                                    {6},
                                    {7},
                                    {8},
                                    {9},
                                    {10},
                                    {11},
                                    CASE WHEN {12} = '' THEN NULL ELSE CONVERT(datetime, {12}, 103) END,
                                    {13},
                                    {14},
                                    {15}
                                )",
                                logId,
                                logHsctId,
                                logDonHangId,
                                logSoThuTu,
                                logLoaiChuyen,
                                logSoChungTu,
                                logDonHangUuTien,
                                slcont20Lan.GetValueOrDefault(0),
                                slcont40Lan.GetValueOrDefault(0),
                                slcont40hcLan.GetValueOrDefault(0),
                                slcont45Lan.GetValueOrDefault(0),
                                slcontLCLLan.GetValueOrDefault(0),
                                logNgayDieuChinhText,
                                logMota,
                                logNgayGui,
                                logNguoiGui
                            );
                        });

                        // Tập tin đính kèm theo từng lần, nhưng không được tạo thêm log
                        string fileKeyLan = "ttdk1_po_lan_" + lan;

                        for (int i = 0; i < lengthF; i++)
                        {
                            string fileKey = files.GetKey(i);

                            if (fileKey != fileKeyLan)
                            {
                                continue;
                            }

                            string fileName = files[i].FileName.removeAllSpaceOrTrimText(true);

                            int mimeI = fileName.LastIndexOf(".");
                            string mime = fileName.Substring(mimeI).ToLower();

                            var fileTypesLan = new string[] { ".doc", ".docx", ".xls", ".xlsx", ".pdf" };

                            if (!fileTypesLan.Contains(mime))
                            {
                                msg = $@"{fileName}: phải là word, pdf hoặc excel";
                                goto EndEventHandler;
                            }

                            foreach (var hsctIdDinhKem in hsctIdsDinhKem)
                            {
                                var idFile = Helper.getNewId();
                                var path = $"taptin/chungtu/{idFile}{mime}";

                                var taptin = new md_taptin();
                                taptin.md_taptin_id = idFile;
                                taptin.lienket = hsctIdDinhKem;
                                taptin.trangthai = Helper.CHUAGUI;
                                taptin.doituong_dinhkem = "HSCT";
                                taptin.tentaptin = fileName;
                                taptin.path = path;
                                taptin.size = files[i].ContentLength;
                                taptin.mimetype = mime;
                                taptin.hoatdong = true;
                                taptin.ngaytao = DateTime.Now;
                                taptin.nguoitao = UserUtils.getUser(context);

                                db.md_taptins.InsertOnSubmit(taptin);

                                taptinCanLuuFiles.Add(new KeyValuePair<md_taptin, int>(taptin, i));
                            }
                        }
                    }

                    // Đã xử lý xong chuyển xuất 2 lần / 3 lần
                    // c_donhangchungtu chỉ tạo 1 lượt theo thông tin lần 1
                    // c_donhangchungtu_xuat_log lưu đủ lần 1, 2, 3
                    goto SauKhiTaoHoSoChungTu;
                }






                dhs = dhs.OrderBy(s => s.c_donhang_id == dhut_po ? 0 : 1).ToList();
                foreach (var dh in dhs)
                {
                    if (string.IsNullOrWhiteSpace(dh.nhanvienCT))
                    {
                        msg = $@"Đơn hàng ""{dh.sochungtu}"" chưa chọn nhân viên chứng từ";
                        goto EndEventHandler;
                    }
                    dh.trangthaict = Helper.DAGUI;
                    var hsct = new c_donhangchungtu();
                    hsct.c_donhangchungtu_id = Helper.getNewId();
                    hsct.trangthai = Helper.SOANTHAO;
                    hsct.c_donhang_id = dh.c_donhang_id;
                    hsct.trangthai2 = Helper.Moi;

                    if (laNhieuDonRiengLe)
                    {
                        // Gửi nhiều đơn riêng lẻ:
                        // Không có đơn hàng ưu tiên
                        // Không cont
                        // Không ngày điều chỉnh
                        // Không đóng ghép
                        hsct.mota = ghichu_po;
                        hsct.ngaychuyenhoso = DateTime.Now;

                        // Lấy hồ sơ đầu tiên để lưu tập tin đính kèm và gửi mail
                        if (string.IsNullOrWhiteSpace(idut))
                        {
                            idut = hsct.c_donhangchungtu_id;
                            sctut = dh.sochungtu;
                            nvctut = db.nhanviens
                                .Where(s => s.manv == dh.nhanvienCT)
                                .Select(s => s.email)
                                .FirstOrDefault();
                        }
                    }
                    else if (laDacBiet)
                    {
                        hsct.cont20 = dh.cont20;
                        hsct.cont40 = dh.cont40;
                        hsct.cont40hc = dh.cont40hc;
                        hsct.cont45 = dh.cont45;
                        hsct.contLCL = dh.contle;
                        hsct.ngaychuyenhoso = DateTime.Now;

                        if (dh.c_donhang_id == dhut_po)
                        {
                            idut = hsct.c_donhangchungtu_id;
                            sctut = dh.sochungtu;
                            nvctut = db.nhanviens
                                .Where(s => s.manv == dh.nhanvienCT)
                                .Select(s => s.email)
                                .FirstOrDefault();
                        }
                    }
                    else
                    {
                        if (dh.c_donhang_id == dhut_po)
                        {
                            hsct.cont20 = slcont20_po;
                            hsct.cont40 = slcont40_po;
                            hsct.cont40hc = slcont40hc_po;
                            hsct.cont45 = slcont45_po;
                            hsct.contLCL = slcontLCL_po;
                            hsct.mota = ghichu_po;
                            hsct.ngaydieuchinh = nxhdc_po.ToNullableDate();
                            hsct.ngaychuyenhoso = DateTime.Now;

                            idut = hsct.c_donhangchungtu_id;
                            sctut = dh.sochungtu;
                            nvctut = db.nhanviens
                                .Where(s => s.manv == dh.nhanvienCT)
                                .Select(s => s.email)
                                .FirstOrDefault();
                        }
                        else
                        {
                            hsct.dongghep = sctut;
                        }
                    }


                    hsct.nhanvienCT = dh.nhanvienCT;
                    hsct.ngaytao = DateTime.Now;
                    hsct.ngaycapnhat = DateTime.Now;
                    hsct.nguoitao = UserUtils.getUser(context);
                    hsct.nguoicapnhat = UserUtils.getUser(context);
                    hsct.hoatdong = true;
                    // Mặc định khi mới gửi đến chứng từ là chưa gửi mail
                    hsct.daguimail = false;
                    db.c_donhangchungtus.InsertOnSubmit(hsct);

                    if (laNhieuDonRiengLe)
                    {
                        hsctIdsDinhKem.Add(hsct.c_donhangchungtu_id);
                    }

                    var spd = db.c_donhang_spds.Where(s => s.c_donhang_id == dh.c_donhang_id & (s.trangthai ?? "") != Helper.DAGUI).OrderByDescending(s => s.ngaytao).FirstOrDefault();
                    if (spd != null)
                        spd.trangthai = Helper.DAGUI;

                    count++;
                }
            }
            SauKhiTaoHoSoChungTu:;
            if (string.IsNullOrWhiteSpace(nvctut))
            {
                msg = $@"Đơn hàng ""{sctut}"" chưa chọn nhân viên chứng từ";

                goto EndEventHandler;
            }


            if (hsctIdsDinhKem.Count <= 0 && !string.IsNullOrWhiteSpace(idut))
            {
                hsctIdsDinhKem.Add(idut);
            }

            //var fileTypes = new string[] { ".doc", ".docx", ".xls", ".xlsx", ".pdf" };
            //var pathRoot = "taptin/chungtu";
            //for (int i = 0; i < lengthF; i++)
            //{
            var fileTypes = new string[] { ".doc", ".docx", ".xls", ".xlsx", ".pdf" };
            var pathRoot = "taptin/chungtu";

            if (!laChuyenXuatNhieuLan)
            {
                for (int i = 0; i < lengthF; i++)
                {
                    string fileName = files[i].FileName.removeAllSpaceOrTrimText(true);

                    int mimeI = fileName.LastIndexOf(".");
                    string mime = fileName.Substring(mimeI).ToLower();

                    if (!fileTypes.Contains(mime))
                    {
                        msg = $@"{fileName}: phải là word, pdf hoặc excel";
                        goto EndEventHandler;
                    }

                    foreach (var hsctIdDinhKem in hsctIdsDinhKem)
                    {
                        var taptinTonTai = db.md_taptins
                            .Where(p =>
                                p.tentaptin == fileName
                                && p.doituong_dinhkem == "HSCT"
                                && p.lienket == hsctIdDinhKem
                            )
                            .FirstOrDefault();

                        if (taptinTonTai != null)
                        {
                            msg = $@"{fileName}: đã tồn tại trước đó trong hồ sơ chứng từ này";
                            goto EndEventHandler;
                        }

                        var idFile = Helper.getNewId();
                        var path = $"{pathRoot}/{idFile}{mime}";

                        var taptin = new md_taptin();
                        taptin.md_taptin_id = idFile;
                        taptin.lienket = hsctIdDinhKem;
                        taptin.trangthai = Helper.CHUAGUI;
                        taptin.doituong_dinhkem = "HSCT";
                        taptin.tentaptin = fileName;
                        taptin.path = path;
                        taptin.size = files[i].ContentLength;
                        taptin.mimetype = mime;
                        taptin.hoatdong = true;
                        taptin.ngaytao = DateTime.Now;
                        taptin.nguoitao = UserUtils.getUser(context);

                        db.md_taptins.InsertOnSubmit(taptin);

                        // Lưu lại để sau SubmitChanges thì SaveAs file vật lý
                        taptinCanLuuFiles.Add(new KeyValuePair<md_taptin, int>(taptin, i));
                    }
                }
            }

            if (count == 0)
                msg = "Không có đơn hàng nào được chuyển tới chứng từ";
            else
            {
                //db.SubmitChanges();
                //var taptins = new List<md_taptin>();
                db.SubmitChanges();

                foreach (var insertXuatLog in insertXuatLogs)
                {
                    insertXuatLog();
                }

                var taptins = new List<md_taptin>();


                foreach (var item in taptinCanLuuFiles)
                {
                    var taptin = item.Key;
                    int fileIndex = item.Value;

                    var path = $"{pathRoot}/{taptin.md_taptin_id}{taptin.mimetype}";
                    path = ExcuteSignalRStatic.mapPathSignalR($"~/{path}");

                    files[fileIndex].SaveAs(path);

                    // Chỉ lấy file của hồ sơ đầu tiên để đính kèm mail,
                    // tránh gửi mail bị lặp cùng 1 file nhiều lần.
                    if (taptin.lienket == idut)
                    {
                        taptins.Add(taptin);
                    }
                }
                //var taptins = new List<md_taptin>();
                //for (int i = 1; i <= lengthF; i++)
                //{
                //    string fileName = files[i - 1].FileName.removeAllSpaceOrTrimText(true);
                //    var taptin = db.md_taptins.Where(p => p.tentaptin == fileName & p.doituong_dinhkem == "HSCT" & p.lienket == idut).FirstOrDefault();
                //    if (taptin != null)
                //    {
                //        var path = $"{pathRoot}/{taptin.md_taptin_id}{taptin.mimetype}";
                //        path = ExcuteSignalRStatic.mapPathSignalR($"~/{path}");
                //        files[i - 1].SaveAs(path);
                //        taptins.Add(taptin);
                //    }
                //}

                try
                {
                    var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
                    if (!string.IsNullOrWhiteSpace(nv.smtp))
                    {
                        smtp = db.md_smtps.Where(s => s.md_smtp_id == nv.smtp).FirstOrDefault();
                    }

                    var mail = new GoogleMail();
                    mail.Email = nv.email;
                    mail.Password = nv.email_pass;
                    mail.Smtp = smtp.smtpserver;
                    mail.Port = smtp.port.Value;
                    mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);

                    string scts = string.Join(", ", dhs.Select(s => s.sochungtu).ToList());
                    //string title = $@"Gửi CT đơn hàng ""{scts}""", body = $@"Đơn hàng ưu tiên ""{sctut}""";

                    //#beginvts-02-06-2026
                    string tenNVCT = db.nhanviens
                    .Where(s => dhs.Select(d => d.nhanvienCT).Contains(s.manv))
                    .Select(s => s.hoten)
                    .FirstOrDefault();

                    if (string.IsNullOrWhiteSpace(tenNVCT))
                        tenNVCT = nvctut;




                    //   string rows = "";

                    //// Gom danh sách PO theo tên khách hàng
                    //var dsDongGhepTheoKhach = dhs
                    //    .Select(dh =>
                    //    {
                    //        var kh = db.md_doitackinhdoanhs
                    //            .FirstOrDefault(x => x.md_doitackinhdoanh_id == dh.md_doitackinhdoanh_id);

                    //        return new
                    //        {
                    //            TenKhachHang = kh != null ? kh.ten_dtkd : "",
                    //            SoChungTu = dh.sochungtu
                    //        };
                    //    })
                    //    .GroupBy(x => x.TenKhachHang)
                    //    .ToDictionary(
                    //        g => g.Key,
                    //        g => new
                    //        {
                    //            Count = g.Count(),
                    //            SoChungTus = string.Join("<br/>", g.Select(x => HttpUtility.HtmlEncode(x.SoChungTu)).Distinct())
                    //        }
                    //    );

                    //foreach (var dh in dhs.OrderBy(s => s.ngaylap))
                    //{
                    //    var dtkd = db.md_doitackinhdoanhs
                    //        .FirstOrDefault(x => x.md_doitackinhdoanh_id == dh.md_doitackinhdoanh_id);


                    //    string maKhachHang = dtkd != null ? dtkd.ten_dtkd : "";
                    //    string dongGhep = "";

                    //    if (!string.IsNullOrWhiteSpace(maKhachHang) && dsDongGhepTheoKhach.ContainsKey(maKhachHang))
                    //    {
                    //        var nhom = dsDongGhepTheoKhach[maKhachHang];

                    //        if (nhom.Count > 1)
                    //        {
                    //            dongGhep = nhom.SoChungTus;
                    //        }
                    //    }
                    //    // Nhà cung ứng
                    //    // Nếu tên field nhà cung ứng của anh khác, chỉ cần đổi chỗ x.md_doitackinhdoanh_id_ncc
                    //    string nhaCungUng = string.Join("<br/>",
                    //        (
                    //            from ddh in db.c_dongdonhangs
                    //                //join ncc in db.md_doitackinhdoanhs
                    //                //    on ddh.md_doitackinhdoanh_id equals ncc.md_doitackinhdoanh_id
                    //            join ncc in db.md_doitackinhdoanhs
                    //                  on ddh.nhacungungid equals ncc.md_doitackinhdoanh_id
                    //            where ddh.c_donhang_id == dh.c_donhang_id
                    //            select ncc.ma_dtkd
                    //        )
                    //        .Distinct()
                    //        .ToList()
                    //    );

                    //    rows += $@"
                    //    <tr>
                    //        <td>{HttpUtility.HtmlEncode(maKhachHang)}</td>
                    //        <td>{HttpUtility.HtmlEncode(dh.sochungtu)}</td>
                    //        <td></td>
                    //        <td style='text-align:center'>{(dh.shipmenttime.HasValue ? dh.shipmenttime.Value.ToString("dd/MM/yyyy") : "")}</td>
                    //        <td style='text-align:center'>{(dh.shipmentdate.HasValue ? dh.shipmentdate.Value.ToString("dd/MM/yyyy") : "")}</td>
                    //        <td style='text-align:right'>{slcont20_po}</td>
                    //        <td style='text-align:right'>{slcont40_po}</td>
                    //        <td style='text-align:right'>{slcont40hc_po}</td>
                    //        <td style='text-align:right'>{slcont45_po}</td>
                    //        <td style='text-align:right'>{slcontLCL_po}</td>
                    //        <td>{dongGhep}</td>
                    //        <td>{nhaCungUng}</td>
                    //    </tr>";
                    //}


                    //string rows = "";

                    //foreach (var dh in dhs
                    //    .OrderBy(s => s.c_donhang_id == dhut_po ? 0 : 1)
                    //    .ThenBy(s => s.ngaylap))
                    //{
                    string rows = "";
                    int stt = 0;

                    foreach (var dh in dhs
                        .OrderBy(s => s.c_donhang_id == dhut_po ? 0 : 1)
                        .ThenBy(s => s.ngaylap))
                    {
                        stt++;
                    var dtkd = db.md_doitackinhdoanhs
                        .FirstOrDefault(x => x.md_doitackinhdoanh_id == dh.md_doitackinhdoanh_id);

                    //string maKhachHang = dtkd != null ? dtkd.ten_dtkd : "";
                    string maKhachHang = dtkd != null ? (dtkd.ma_dtkd ?? "") : "";
                    bool laDongUuTien = dh.c_donhang_id == dhut_po;

                    string dongGhep = "";
                    string cont20Mail = "";
                    string cont40Mail = "";
                    string cont40hcMail = "";
                    string cont45Mail = "";
                    string contLCLMail = "";

                    // Trường hợp gửi mới bình thường
                    //if (!laDacBiet)
                    //{
                    //    if (laDongUuTien)
                    //    {
                    //        // Dòng đơn hàng ưu tiên: Đóng ghép rỗng, cont lấy theo form nhập
                    //        dongGhep = "";
                    //        cont20Mail = slcont20_po.ToString();
                    //        cont40Mail = slcont40_po.ToString();
                    //        cont40hcMail = slcont40hc_po.ToString();
                    //        cont45Mail = slcont45_po.ToString();
                    //        contLCLMail = slcontLCL_po.ToString();
                    //    }
                    //    else
                    //    {
                    //        // Các dòng còn lại: Đóng ghép = số PO ưu tiên, cont để rỗng
                    //        dongGhep = sctut;
                    //        cont20Mail = "";
                    //        cont40Mail = "";
                    //        cont40hcMail = "";
                    //        cont45Mail = "";
                    //        contLCLMail = "";
                    //    }
                    //}
                    //else
                    //{
                    //    // Trường hợp đặc biệt: lấy cont theo từng PO
                    //    dongGhep = "";
                    //    cont20Mail = dh.cont20.ToString();
                    //    cont40Mail = dh.cont40.ToString();
                    //    cont40hcMail = dh.cont40hc.ToString();
                    //    cont45Mail = dh.cont45.ToString();
                    //    contLCLMail = dh.contle.ToString();
                    //}   


                    if (laNhieuDonRiengLe)
                    {
                        // Gửi nhiều đơn riêng lẻ: toàn bộ cont và đóng ghép để rỗng
                        dongGhep = "";
                        cont20Mail = "";
                        cont40Mail = "";
                        cont40hcMail = "";
                        cont45Mail = "";
                        contLCLMail = "";
                    }
                    else if (!laDacBiet)
                    {
                        if (laDongUuTien)
                        {
                            dongGhep = "";
                            cont20Mail = slcont20_po.ToString();
                            cont40Mail = slcont40_po.ToString();
                            cont40hcMail = slcont40hc_po.ToString();
                            cont45Mail = slcont45_po.ToString();
                            contLCLMail = slcontLCL_po.ToString();
                        }
                        else
                        {
                            dongGhep = sctut;
                            cont20Mail = "";
                            cont40Mail = "";
                            cont40hcMail = "";
                            cont45Mail = "";
                            contLCLMail = "";
                        }
                    }
                    else
                    {
                        dongGhep = "";
                        cont20Mail = dh.cont20.ToString();
                        cont40Mail = dh.cont40.ToString();
                        cont40hcMail = dh.cont40hc.ToString();
                        cont45Mail = dh.cont45.ToString();
                        contLCLMail = dh.contle.ToString();
                    }


                    // Nhà cung ứng hiển thị cột ở Table  Hồ Sơ 
                    string nhaCungUng = string.Join("<br/>",
                        (
                            from ddh in db.c_dongdonhangs
                            join ncc in db.md_doitackinhdoanhs
                                on ddh.nhacungungid equals ncc.md_doitackinhdoanh_id
                            where ddh.c_donhang_id == dh.c_donhang_id
                            select ncc.ma_dtkd
                        )
                        .Distinct()
                        .ToList()
                    );
                    
                    //string cocDonHang = dh.datcoc == null ? "" : dh.datcoc.ToString();
                    string cocDonHang = dh.datcoc.GetValueOrDefault(0).ToString("#,##0.##");

                    rows += $@"
                    <tr>
                        <td style='text-align:center'>{stt}</td>
                        <td>{HttpUtility.HtmlEncode(maKhachHang)}</td>
                        <td>{HttpUtility.HtmlEncode(dh.sochungtu)}</td>
                        <td>{HttpUtility.HtmlEncode(dh.customer_order_no)}</td>
                        <td style='text-align:center'>{(dh.shipmenttime.HasValue ? dh.shipmenttime.Value.ToString("dd/MM/yyyy") : "")}</td>
                        <td style='text-align:center'>{(dh.shipmentdate.HasValue ? dh.shipmentdate.Value.ToString("dd/MM/yyyy") : "")}</td>
                        <td style='text-align:right'>{cont20Mail}</td>
                        <td style='text-align:right'>{cont40Mail}</td>
                        <td style='text-align:right'>{cont40hcMail}</td>
                        <td style='text-align:right'>{cont45Mail}</td>
                        <td style='text-align:right'>{contLCLMail}</td>
                        <td>{HttpUtility.HtmlEncode(dongGhep)}</td>
                        <td>{nhaCungUng}</td>
                        <td style='text-align:center'>
                            {HttpUtility.HtmlEncode(cocDonHang)}
                        </td>
                    </tr>";
                }











                    string title = $@"Gửi CT đơn hàng ""{scts}""";

                string body = $@"
                    <div style='font-family:Arial;font-size:14px'>
                        <p>Xin chào: <b>{tenNVCT}</b></p>
                        <p>Danh sách PO gửi chứng từ:</p>

                        <table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse;width:100%;font-size:13px'>
                            <thead>
                                <tr style='background:#f2f2f2;font-weight:bold;text-align:center'>
                                    <th>STT</th>
                                    <th>Mã số khách</th>
                                    <th>Số PO</th>
                                    <th>Số order no</th>
                                    <th>Shipment time</th>
                                    <th>NXH của xưởng</th>
                                    <th>Cont 20</th>
                                    <th>40DC</th>
                                    <th>40HC</th>
                                    <th>45</th>
                                    <th>LCL</th>
                                    <th>Đóng ghép</th>
                                    <th>Nhà Cung Ứng</th>
                                    <th>Cọc Đơn Hàng</th>
                                </tr>
                            </thead>
                            <tbody>{rows}</tbody>
                        </table>
                    </div>";
                //string title = $@"Gửi CT đơn hàng ""{scts}""";
                //string body = $@"
                //<div style='font-family:Arial;font-size:14px'>
                //    <p>Xin chào: <b>{tenNVCT}</b></p>
                //    <p>Danh sách PO gửi chứng từ:</p>

                //    <table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse;width:100%'>
                //        <thead>
                //            <tr style='background:#f2f2f2;font-weight:bold;text-align:center'>
                //                <th>Ngày PO</th>
                //                <th>Số PO</th>
                //                <th>NXH Điều Chỉnh</th>
                //                <th>Cont 20</th>
                //                <th>Cont 40DC</th>
                //                <th>Cont 40HC</th>
                //                <th>Cont 45</th>
                //                <th>Ghi Chú</th>
                //            </tr>
                //        </thead>
                //        <tbody>{rows}</tbody>
                //    </table>
                //</div>";



                //#endvts-02-06-2026



                //if (laBoSung)
                //{
                //    title = $@"Gửi CT thông tin bổ sung của đơn hàng ""{sctut}""";
                //    body = "Vui lòng truy cập hệ thống AncoTrading để xem thông tin bổ sung chi tiết";
                //}

                if (laBoSung)
                {
                    title = $@"Gửi CT thông tin bổ sung của đơn hàng ""{sctut}""";

                    string noiDungGhiChu = "";
                    if (!string.IsNullOrWhiteSpace(ghichu_po))
                    {
                        noiDungGhiChu = $@"
                            <p>
                                <b>Nội dung:</b> {HttpUtility.HtmlEncode(ghichu_po)}
                            </p>";
                    }

                    body = $@"
                        <div style='font-family:Arial;font-size:14px'>
                            <p>
                                Đơn hàng số <b>{sctut}</b>
                                bổ sung thông tin lần thứ
                                <b>{soLanBoSung}</b>.
                            </p>

                            {noiDungGhiChu}
                        </div>";
                }


                var attachments = new List<System.Net.Mail.Attachment>();
                foreach (var tt in taptins)
                {
                    var attachment = new System.Net.Mail.Attachment(ExcuteSignalRStatic.mapPathSignalR($"~/{tt.path}"));
                    attachment.Name = tt.tentaptin;
                    attachments.Add(attachment);
                }

                string cc = $"{nv.email_cc},{emailTBPs}";
                mail.Send(
                    nv.email
                    , nvctut
                    , cc
                    , ""
                    , title
                    , body
                    , attachments
                );
            }
                catch (Exception ex)
        {
            msg = ex.ToString();
        }
    }
}
        catch (Exception e)
{
    msg = e.Message;
}

EndEventHandler:;
context.Response.Write(msg);
    }

    public void ChuyenDonHang(HttpContext context)
{
    string msg = "";
    string user = context.Request.Form["user"];
    try
    {
        user = user.Trim();
        var nv = db.nhanviens.Where(s => s.manv == user).FirstOrDefault();
        if (nv == null)
        {
            msg = string.Format("Không tìm thấy tài khoản có mã là {0}.", user);
            goto EndEventHandler;
        }

        string[] ids = context.Request.Params["id"].Split(',');
        int count = 0;
        foreach (var id in ids)
        {
            //Don hang
            var dh = db.c_donhangs.Where(p => p.c_donhang_id.Equals(id)).FirstOrDefault();
            if (dh != null)
            {
                if (dh.nguoilap != nv.manv)
                {
                    dh.nguoitao = nv.manv;
                    dh.nguoicapnhat = nv.manv;
                    dh.nguoilap = nv.manv;
                    //Dong don hang
                    var ddhs = db.c_dongdonhangs.Where(s => s.c_donhang_id == dh.c_donhang_id).ToList();
                    foreach (var ddh in ddhs)
                    {
                        ddh.nguoitao = nv.manv;
                        ddh.nguoicapnhat = nv.manv;
                    }
                    //Phi don hang
                    var pdhs = db.c_phidonhangs.Where(s => s.c_donhang_id == dh.c_donhang_id).ToList();
                    foreach (var pdh in pdhs)
                    {
                        pdh.nguoitao = nv.manv;
                        pdh.nguoicapnhat = nv.manv;
                    }

                    count++;
                }
                //Danh Sach Dat Hang
                var dsdhs = db.c_danhsachdathangs.Where(s => s.c_donhang_id == dh.c_donhang_id).ToList();
                foreach (var dsdh in dsdhs)
                {
                    dsdh.nguoi_dathang = nv.manv;
                    dsdh.nguoi_phutrach = nv.manv;
                    dsdh.nguoitao = nv.manv;
                    dsdh.nguoicapnhat = nv.manv;
                }
            }
        }

        if (count == 0)
            msg = "Không có đơn hàng nào được chuyển";
        else
            db.SubmitChanges();
    }
    catch (Exception e)
    {
        msg = e.Message;
    }

    EndEventHandler:;
    context.Response.Write(msg);
}

public void CopyDonHang(HttpContext context)
{
    try
    {
        string msg = "";
        string id = context.Request.QueryString["poId"];
        c_donhang dh = db.c_donhangs.Where(p => p.c_donhang_id.Equals(id)).FirstOrDefault();
        string sochungtu = jqGridHelper.Utils.taoChungTuPO(dh.md_doitackinhdoanh_id, dh.donhang_mau == true ? 1 : 0, DateTime.Now.Year.ToString(), dh.loai);

        string sqlCount = @"select count(b.trangthai) as count from c_dongdonhang a left join md_sanpham b on a.md_sanpham_id = b.md_sanpham_id where a.c_donhang_id  = '" + id + @"' and b.trangthai != 'DHD'";

        int count = (int)mdbc.ExecuteScalar(sqlCount);
        if (dh == null)
        {
            msg = "<div style='color:red'>Lỗi: Không tìm thấy PO đã chọn.</div>";
        }
        else if (count > 0)
        {
            msg = "<div style='color:red'>Lỗi: PO có chứa mã hàng không hoạt động.</div>";
        }
        else
        {
            string id_new = ImportUtils.getNEWID();
            c_donhang dh_new = Clone(dh);
            dh_new.c_donhang_id = id_new;
            dh_new.sochungtu = sochungtu;
            dh_new.md_trangthai_id = "SOANTHAO";
            dh_new.ismakepi = false;
            dh_new.ngaylap = DateTime.Now;
            dh_new.nguoilap = UserUtils.getUser(context);
            //--
            dh_new.ngaytao = DateTime.Now;
            dh_new.nguoitao = UserUtils.getUser(context);
            dh_new.ngaycapnhat = DateTime.Now;
            dh_new.nguoicapnhat = UserUtils.getUser(context);

            foreach (c_dongdonhang ddh in db.c_dongdonhangs.Where(s => s.c_donhang_id == dh.c_donhang_id))
            {
                c_dongdonhang ddh_new = Clone(ddh);
                ddh_new.c_dongdonhang_id = ImportUtils.getNEWID();
                ddh_new.c_donhang_id = id_new;
                ddh_new.soluong_dathang = 0;
                ddh_new.soluong_conlai = ddh_new.soluong;
                ddh_new.soluong_daxuat = 0;
                //--
                ddh_new.ngaytao = DateTime.Now;
                ddh_new.nguoitao = UserUtils.getUser(context);
                ddh_new.ngaycapnhat = DateTime.Now;
                ddh_new.nguoicapnhat = UserUtils.getUser(context);
                db.c_dongdonhangs.InsertOnSubmit(ddh_new);
            }

            foreach (c_phidonhang pdh in db.c_phidonhangs.Where(s => s.c_donhang_id == dh.c_donhang_id))
            {
                c_phidonhang pdh_new = Clone(pdh);
                pdh_new.c_phidonhang_id = ImportUtils.getNEWID();
                pdh_new.c_donhang_id = id_new;
                //--
                pdh_new.ngaytao = DateTime.Now;
                pdh_new.nguoitao = UserUtils.getUser(context);
                pdh_new.ngaycapnhat = DateTime.Now;
                pdh_new.nguoicapnhat = UserUtils.getUser(context);
                db.c_phidonhangs.InsertOnSubmit(pdh_new);
            }

            db.c_donhangs.InsertOnSubmit(dh_new);
            db.SubmitChanges();
            msg = "<div style='color:blue'>Tạo mới PO \"" + sochungtu + "\" thành công.</div>";
        }
        context.Response.Write(msg);
    }
    catch (Exception e)
    {
        context.Response.Write(e.Message);
    }
}

public void HuyDonHang(HttpContext context)
{
    context.Response.ContentType = "text/plain";
    context.Response.Charset = "UTF-8";
    try
    {
        string c_donhang_id = context.Request.QueryString["poId"];
        c_donhang dh = db.c_donhangs.SingleOrDefault(p => p.c_donhang_id.Equals(c_donhang_id));
        if (dh != null)
        {

            if (dh.md_trangthai_id.Equals("HIEULUC"))
            {
                var ddhs = from ddh in db.c_dongdonhangs where ddh.c_donhang_id.Equals(dh.c_donhang_id) select ddh.c_dongdonhang_id;

                var ddsdhs = from ddsdh in db.c_dongdsdhs
                             join dsdh in db.c_danhsachdathangs
                                 on ddsdh.c_danhsachdathang_id equals dsdh.c_danhsachdathang_id
                             where
                                ddhs.Contains(ddsdh.c_dongdonhang_id)
                                && ddsdh.sl_dagiao < ddsdh.sl_dathang
                                && dsdh.md_trangthai_id.Equals("HIEULUC")
                             select ddsdh;

                // Xoa danh sach dat hang soan thao
                List<string> lstSoanThao = (from ddsdh in db.c_dongdsdhs
                                            join dsdh in db.c_danhsachdathangs
                                                on ddsdh.c_danhsachdathang_id equals dsdh.c_danhsachdathang_id
                                            where
                                               ddhs.Contains(ddsdh.c_dongdonhang_id)
                                               && dsdh.md_trangthai_id.Equals("SOANTHAO")
                                            select ddsdh.c_danhsachdathang_id).ToList();


                foreach (var c_danhsachdathang_id in lstSoanThao)
                {
                    c_danhsachdathang dsdh = db.c_danhsachdathangs.SingleOrDefault(p => p.c_danhsachdathang_id.Equals(c_danhsachdathang_id));
                    if (dsdh != null)
                    {
                        var d_dsdhs = from ddsdh in db.c_dongdsdhs where ddsdh.c_danhsachdathang_id.Equals(dsdh.c_danhsachdathang_id) select ddsdh;
                        db.c_dongdsdhs.DeleteAllOnSubmit(d_dsdhs);
                        db.c_danhsachdathangs.DeleteOnSubmit(dsdh);
                    }
                }

                // # Xoa danh sach dat hang soan thao


                // Set so luong huy cho cac danh sach dat hang hieu luc
                List<string> lstDanhSachDatHang = new List<string>();
                foreach (var ddsdh in ddsdhs)
                {
                    ddsdh.sl_huy = ddsdh.sl_dathang - ddsdh.sl_dagiao;
                    lstDanhSachDatHang.Add(ddsdh.c_danhsachdathang_id);
                }
                // # Set so luong huy cho cac danh sach dat hang hieu luc

                // Cap nhat trang thai cho danh sach dat hang
                foreach (string c_danhsachdathang_id in lstDanhSachDatHang)
                {
                    c_danhsachdathang dsdh = db.c_danhsachdathangs.SingleOrDefault(p => p.c_danhsachdathang_id.Equals(c_danhsachdathang_id));
                    if (dsdh != null)
                    {
                        dsdh.md_trangthai_id = "HUY";
                    }
                }
                // # Cap nhat trang thai cho danh sach dat hang

                // Xóa các kế hoạch xuất hàng đang soạn thảo và kết thúc các kế hoạch đang hiệu lực
                List<c_kehoachxuathang> lstKHXHXoa = new List<c_kehoachxuathang>();
                foreach (string c_danhsachdathang_id in lstDanhSachDatHang)
                {
                    c_danhsachdathang dsdh = db.c_danhsachdathangs.SingleOrDefault(p => p.c_danhsachdathang_id.Equals(c_danhsachdathang_id));
                    if (dsdh != null)
                    {
                        c_kehoachxuathang khxh = db.c_kehoachxuathangs.Single(p => p.c_danhsachdathang_id.Equals(dsdh.sochungtu));
                        if (khxh.md_trangthai_id.Equals("SOANTHAO"))
                        {
                            lstKHXHXoa.Add(khxh);
                        }
                        else if (khxh.md_trangthai_id.Equals("HIEULUC"))
                        {
                            khxh.md_trangthai_id = "KETTHUC";
                        }
                    }
                }
                // # Xóa các kế hoạch xuất hàng đang soạn thảo và kết thúc các kế hoạch đang hiệu lực

                db.c_kehoachxuathangs.DeleteAllOnSubmit(lstKHXHXoa);
                dh.md_trangthai_id = "HUY";
                db.SubmitChanges();
                context.Response.Write("Hủy đơn hàng thành công!");
            }
            else
            {
                context.Response.Write("Chỉ có thể đơn hàng hiệu lực!");
            }
        }
        else
        {
            context.Response.Write("Không tìm thấy đơn hàng!");
        }
    }
    catch (Exception e)
    {
        context.Response.Write(e.Message);
    }
}

public void getPoInformation(HttpContext context)
{
    context.Response.ContentType = "text/plain";
    context.Response.Charset = "UTF-8";
    string c_donhang_id = context.Request.QueryString["poId"];
    string msg = Public.triggerDonHang(db, null, c_donhang_id);
    context.Response.Write(msg);
}

public void getDocument(HttpContext context)
{
    try
    {
        string doitackinhdoanh_id = context.Request.Form["md_doitackinhdoanh_id"];
        string dh_mau = context.Request.Form["isdonhangmau"].ToLower();
        string ngaydonhang = context.Request.Form["ngaydonhang"];
        DateTime ngaydh = DateTime.ParseExact(ngaydonhang, "dd/MM/yyyy", null);
        int isdh_mau;
        isdh_mau = 0;

        if (dh_mau.Equals("on") || dh_mau.Equals("true"))
        { isdh_mau = 1; }

        string sct = jqGridHelper.Utils.taoChungTuPO(doitackinhdoanh_id, isdh_mau, ngaydh.Year.ToString());
        context.Response.Write("<root><value>" + sct + "</value></root>");
    }
    catch (Exception e)
    {
        context.Response.Write("<root><value>" + e.Message + "</value></root>");
    }
}

public void stopPO(HttpContext context)
{
    String msg = "";
    try
    {
        String c_donhang_id = context.Request.QueryString["poId"];
        c_donhang dh = db.c_donhangs.Single(p => p.c_donhang_id.Equals(c_donhang_id));

        if (dh != null)
        {
            switch (dh.md_trangthai_id)
            {
                case "SOANTHAO":
                    msg = String.Format("Trạng thái đơn hàng {0} là Hiệu Lực mới có thể kết thúc.!", dh.sochungtu);
                    break;
                case "KETTHUC":
                    msg = String.Format("Hiện tại trạng thái đơn hàng {0} đã là kết thúc.!", dh.sochungtu);
                    break;
                case "HIEULUC":
                    dh.md_trangthai_id = "KETTHUC";
                    db.SubmitChanges();
                    msg = String.Format("Đã kết thúc đơn hàng {0} thành công.!", dh.sochungtu);
                    break;
                default:
                    msg = String.Format("Không xác định được trạng thái của đơn hàng {0}.!", dh.sochungtu);
                    break;
            }
        }
        else
        {
            msg = "Đơn hàng không tồn tại.!";
        }
    }
    catch (Exception ex)
    {
        msg = ex.Message;
    }
    context.Response.Write(msg);
}

public void sendMail(HttpContext context)
{
    md_mailtemplate tmp = db.md_mailtemplates.Single(p => p.use_for.Equals("PO") && p.default_mail.Equals(true));
    if (tmp != null)
    {
        String poId = context.Request.QueryString["poId"];
        c_donhang donhang = db.c_donhangs.Single(p => p.c_donhang_id.Equals(poId));
        md_doitackinhdoanh doitac = db.md_doitackinhdoanhs.Single(p => p.md_doitackinhdoanh_id.Equals(donhang.md_doitackinhdoanh_id));
        String str = String.Format("mailto:{0}?subject={1}&body={2}", doitac.email, tmp.subject_mail, tmp.content_mail.Replace("[SOPO]", donhang.sochungtu));
        context.Response.Write(str);
    }
}

public void viewCapacity(HttpContext context)
{
    String poId = context.Request.QueryString["poId"];
    var donhang = db.c_donhangs.FirstOrDefault(dh => dh.c_donhang_id.Equals(poId));
    String result = "";
    if (donhang.isdonhangtmp.Equals(true))
    {
        result = "<div style=\"padding:15px; border:1px solid red; background:#ffadad;\"><h3>Không được xem năng lực đơn hàng tem.! " + "</h3></div>";
    }
    else
    {

        string ngaylap = donhang.ngaylap.Value.ToString("MM/dd/yyyy");
        String selCapacity = "select count(*) as count from dbo.f_tinhNangLucCungUng('" + poId + "') where result_nhandh =0 or result=0";
        int check = (int)mdbc.ExecuteScalar(selCapacity);
        String partnerId = db.c_donhangs.Single(dh => dh.c_donhang_id.Equals(poId)).md_doitackinhdoanh_id;
        System.Data.DataTable dt = mdbc.GetDataFromProcedure("tinhNangLucCungUng", "@donhang_id", poId);


        DateTime maxDate = DateTime.ParseExact("01/01/1900", "dd/MM/yyyy", null);
        int colCount = dt.Columns.Count;
        int rowCount = dt.Rows.Count;
        if (rowCount > 0)
        {
            result += "<div style=\"height:450px; overflow:auto\"><table class=\"view-capacity\">";
            result += String.Format("<tr style=\"background:green; color:white\"><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td>{8}</td></tr>"
                    , "Đầu Mã", "Tên Nhóm Năng Lực", "Đối Tác", "Tổng CBM Cần Đặt", "CBM Đặt Được", "Thời Gian Dự Kiến", "Tuần Thứ", "Thời Gian Yêu Cầu", "Đánh Giá Năng Lực Cung Ứng");
            foreach (System.Data.DataRow row in dt.Rows)
            {
                result += "<tr>";
                result += String.Format("<td>{0}</td>", row[0]);
                result += String.Format("<td>{0}</td>", row[1]);
                result += String.Format("<td>{0}</td>", row["ma_dtkd"]);
                result += String.Format("<td>{0}</td>", row[2]);
                result += String.Format("<td>{0}</td>", row[3]);
                result += String.Format("<td>{0}</td>", DateTime.Parse(row[4].ToString()).ToString("dd/MM/yyyy"));
                result += String.Format("<td>{0}</td>", row[5]);
                result += String.Format("<td>{0}</td>", DateTime.Parse(row[6].ToString()).ToString("dd/MM/yyyy"));
                //result += String.Format("<td>{0}</td>", row[7]);
                //result += String.Format("<td>{0}</td>", row[8]);
                //result += String.Format("<td><img src=\"iconcollection/{0}\"/></td>", row[9].ToString() == "True" ? "tick-icon.png" : "del.png");
                result += String.Format("<td><img src=\"iconcollection/{0}\"/></td>", row[10].ToString() == "True" ? "tick-icon.png" : "del.png");
                //result += String.Format("<td><img src=\"iconcollection/{0}\"/></td>", bool.Parse(row[10].ToString()) == true && bool.Parse(row[9].ToString()) == true ? "tick-icon.png" : "del.png");
                result += "</tr>";

                if (bool.Parse(row[10].ToString()))
                {
                    DateTime ngaydukien = DateTime.Parse(row[4].ToString());
                    if (maxDate < ngaydukien)
                    {
                        maxDate = ngaydukien;
                    }
                }
            }
            result += "</table></div>";


            //kiem tran xem co dat dc het sl  can dat ko
            //string sql_tongcandat = @"select sum(tmp.tong_cbmcandat) from (select distinct dauma, tong_cbmcandat from f_tinhNangLucCungUng('" + poId + "')) as tmp";

            //string sql_tongcandat = @"select sum(tmp.tong_cbmcandat) from (select distinct dauma, tong_cbmcandat from f_tinhNangLucCungUng('" + poId + "')) as tmp";

            if (check > 0)
            {
                //tinh thoi gian du kien 
                string sql_dk = @"select case when (tgdk < tgyc and tgnhandh > tgantoan_dh) then tgyc
										when (tgdk < tgyc and tgnhandh < tgantoan_dh) then ngay_dh + tgnhandh
										when (tgdk > tgyc and tgnhandh > tgantoan_dh) then tgdk
										else tgdk
										end
								from(
									 select MAX(thoigiandukien) tgdk, thoigianyeucau tgyc, max(tgnhan_dh) tgnhandh, max(tgantoan_dh) tgantoan_dh, cast('" + ngaylap + "' as datetime) as ngay_dh" +
                                     " from f_tinhNangLucCungUng('" + poId + "')" +
                                     " group by thoigianyeucau) as tmp";
                DateTime ngaydk = (DateTime)mdbc.ExecuteScalar(sql_dk);
                result = "<div style=\"padding:15px; border:1px solid red; background:#ffadad;\"><h3>Năng lực nhà cung ứng không đáp ứng được đơn hàng này.!<br/>Ngày dự kiến: " + ngaydk.ToString("dd/MM/yyyy") + "</h3></div>" + result;
            }
            else
            {
                string sql_tongcandat = string.Format(@"SELECT sum(v2)  from c_dongdonhang ddh where ddh.c_donhang_id ='{0}'", poId);
                string sql_slCandat = @"select isnull(SUM(cbm_candat), 0) from f_tinhNangLucCungUng('" + poId + "')";
                string tong = mdbc.ExecuteScalar(sql_tongcandat).ToString();
                decimal slTongCanDat = decimal.Parse(tong);
                decimal slCanDat = decimal.Parse(mdbc.ExecuteScalar(sql_slCandat).ToString());

                if (slCanDat < slTongCanDat)
                {
                    result = "<div style=\"padding:15px; border:1px solid red; background:#ffadad;\"><h3>Năng lực nhà cung ứng không đáp ứng được đơn hàng này.!</h3>Năng lực Cung Ứng: " + slCanDat + ", CBM Đơn Hàng: " + slTongCanDat + "</div>" + result;
                }
                else
                {
                    if (check == 0 && slCanDat >= slTongCanDat)
                    {
                        result = "<div style=\"padding:15px; border:1px sold green; background:#b9fdbf;\"><h3>Năng lực nhà cung ứng đáp ứng được đơn hàng này.!</h3>Năng lực Cung Ứng: " + slCanDat + ", CBM Đơn Hàng: " + slTongCanDat + "</div>" + result;
                    }
                    else
                    {
                        string sql_chk_lai_tongcandat = @"select isnull(sum(tmp.tong_cbmcandat), 0) from (select distinct dauma, tong_cbmcandat from f_tinhNangLucCungUng('" + poId + "')) as tmp";
                        decimal sl_chk_lai_TongCanDat = decimal.Parse(mdbc.ExecuteScalar(sql_chk_lai_tongcandat).ToString());

                        if (slCanDat >= sl_chk_lai_TongCanDat)
                        {
                            result = "<div style=\"padding:15px; border:1px solid green; background:#b9fdbf;\"><h3>Năng lực nhà cung ứng đáp ứng được đơn hàng này.!</h3>" + (slCanDat >= slTongCanDat) + "</div>" + result;
                        }
                        else
                        {
                            result = "<div style=\"padding:15px; border:1px solid red; background:#ffadad;\"><h3>Không đủ dữ liệu để tính năng lực.! </h3></div>" + result;
                        }
                    }
                }
            }
        }
        else
        {
            result += "<div style=\"padding:15px; border:1px solid red; background:#b9fdbf;\">Không đủ dữ liệu để tính năng lực.!</div>";
        }
    }
    context.Response.Write(result);
}

public void createPI(HttpContext context)
{
    String result = "";
    String poId = context.Request.QueryString["poId"];

    c_donhang donhang = db.c_donhangs.Single(p => p.c_donhang_id.Equals(poId));

    // String selCountPartner = String.Format(@"SELECT 
    // count(distinct sp.nhacungung) as Count 
    // FROM 
    // c_dongdonhang ddh
    // left join md_sanpham sp on ddh.md_sanpham_id = sp.md_sanpham_id 
    // WHERE 
    // c_donhang_id = '{0}'", poId);
    String selCountPartner = String.Format(@"SELECT 
									count(distinct ddh.nhacungungid) as Count 
									FROM 
									c_dongdonhang ddh
									WHERE
									c_donhang_id = '{0}'", poId);
    int countPartner = (int)mdbc.ExecuteScalar(selCountPartner);

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
                String getTongSoLuongConLai = "select count(1) from c_dongdonhang where soluong_conlai < 1 AND c_donhang_id = @c_donhang_id";
                int sum = (int)mdbc.ExecuteScalar(getTongSoLuongConLai, "@c_donhang_id", donhang.c_donhang_id);
                if (sum == 0)
                {
                    var dsSanPham = new List<dongDatHang>();
                    dsSanPham = db.c_dongdonhangs.Where(s => s.c_donhang_id == donhang.c_donhang_id)
                            .Select(s => new dongDatHang
                            {
                                c_dongdonhang_id = s.c_dongdonhang_id,
                                c_donhang_id = s.c_donhang_id,
                                sanpham_id = s.md_sanpham_id,
                                ma_sanpham = "",
                                ma_sanpham_khach = s.ma_sanpham_khach,
                                md_doitackinhdoanh_id = s.nhacungungid,
                                soluong = s.soluong.GetValueOrDefault(0),
                                soluong_dadat = s.soluong.GetValueOrDefault(0),
                                soluong_conlai = s.soluong.GetValueOrDefault(0)
                            }).ToList();

                    result += UserUtils.createPI(context, donhang, dsSanPham, db);
                }
                else
                {
                    result += string.Format("Tạo đơn đặt hàng thất bại! vì đơn hàng có mã hàng hết số lượng còn lại!");
                }
            }
        }
    }
    context.Response.Write(result);
}

public void activePO(HttpContext context)
{
    try
    {
        String result = "";
        String poId = context.Request.Form["poId"];
        c_donhang donhang = db.c_donhangs.FirstOrDefault(p => p.c_donhang_id.Equals(poId));
        if (donhang != null)
        {
            String trangthai = donhang.md_trangthai_id;
            switch (trangthai)
            {
                case "HIEULUC":
                    context.Response.Write("Hiện tại trạng thái đơn hàng đã là hiệu lực!");
                    break;
                case "KETTHUC":
                    context.Response.Write("Hiện tại trạng thái đơn hàng đã là kết thúc!");
                    break;
                case "SOANTHAO":

                    if (donhang.cont20 <= 0 & donhang.cont40 <= 0 & donhang.cont40hc <= 0 & donhang.cont45 <= 0 & donhang.contle <= 0)
                    {
                        result += "Hiệu lực đơn hàng thất bại! Phải có ít nhất 1 cont lớn hơn 0. <br/>";
                    }
                    else if (donhang.ngaylap >= donhang.shipmenttime || donhang.ngaylap >= donhang.shipmentdate)
                    {
                        result += "Ngày lập PO không thể lớn hơn shipmenttime hoặc shipmentdate! <br/>";
                    }
                    else if (donhang.shipmentdate <= donhang.shipmenttime)
                    {
                        result += "Ngày Shipmentdate phải lớn hơn ngày Shipmenttime! <br/>";
                    }
                    else if (donhang.isdonhangtmp.Equals(true) | donhang.donhang_mau.Equals(true))
                    {
                        c_donhang dh = db.c_donhangs.Single(p => p.c_donhang_id == poId);
                        dh.md_trangthai_id = Helper.HIEULUC;
                        db.SubmitChanges();
                        result += "Hiệu lực đơn hàng thành công.! <br/>";
                    }
                    else
                    {
                        c_donhang dh = db.c_donhangs.Single(p => p.c_donhang_id == poId);
                        dh.md_trangthai_id = Helper.HIEULUC;
                        db.SubmitChanges();
                        result += "Hiệu lực đơn hàng thành công.! <br/>";
                        /*
                        String partnerId = db.c_donhangs.Single(dh => dh.c_donhang_id.Equals(poId)).md_doitackinhdoanh_id;
                        System.Data.DataTable dt = mdbc.GetDataFromProcedure("tinhNangLucCungUng", "@donhang_id", poId);
                        int count = dt.Rows.Count;

                        //string sql_TongCanDat = @"select sum(tmp.tong_cbmcandat) from (select distinct dauma, tong_cbmcandat from f_tinhNangLucCungUng('" + poId + "')) as tmp";
                        string sql_TongCanDat = string.Format(@"select sum(v2)  from c_dongdonhang ddh where ddh.c_donhang_id ='{0}'", poId);
                        string sql_slCandat = @"select isnull(SUM(cbm_candat), 0) from f_tinhNangLucCungUng('" + poId + "')";
                        string tong = mdbc.ExecuteScalar(sql_TongCanDat).ToString();
                        string tongCanDat = mdbc.ExecuteScalar(sql_slCandat).ToString();
                        decimal slTongCanDat = string.IsNullOrWhiteSpace(tong) ? 0 : decimal.Parse(tong);
                        decimal slCanDat = string.IsNullOrWhiteSpace(tongCanDat) ? 0 : decimal.Parse(tongCanDat);
                        if (count != 0 && slCanDat >= slTongCanDat)
                        {
                            String selDetails = "select COUNT(1) as count from c_dongdonhang where c_donhang_id = @c_donhang_id";
                            int countNL = (int)mdbc.ExecuteScalar(selDetails, "@c_donhang_id", poId);
                            if (countNL > 0)
                            {
                                string sql_check = @"select COUNT(1) from [dbo].[f_tinhNangLucCungUng]('" + poId + "')" + " where result_nhandh = 0 or result = 0";
                                int check = (int)mdbc.ExecuteScalar(sql_check);
                                if (check == 0)
                                {
                                    c_donhang dh = db.c_donhangs.Single(p => p.c_donhang_id == poId);
                                    dh.md_trangthai_id = "HIEULUC";
                                    db.SubmitChanges();
                                    mdbc.ExecuteScalarProcedure("p_bookNangLucCungUng", "@donhang_id", poId);
                                    result += "Hiệu lực đơn hàng thành công.! <br/>";
                                }
                                else
                                {
                                    result += "Đơn hàng không đủ năng lực NCC.! <br/>";
                                }
                            }
                            else
                            {
                                result += "Đơn hàng chưa có dòng hàng.! <br/>";
                            }
                        }
                        else
                        {
                            string sql_chk_lai_tongcandat = @"select isnull(sum(tmp.tong_cbmcandat), 0) from (select distinct dauma, tong_cbmcandat from f_tinhNangLucCungUng('" + poId + "')) as tmp";
                            decimal sl_chk_lai_TongCanDat = decimal.Parse(mdbc.ExecuteScalar(sql_chk_lai_tongcandat).ToString());
                            if (count != 0 && slCanDat >= slTongCanDat)
                            {
                                String selDetails = "select COUNT(1) as count from c_dongdonhang where c_donhang_id = @c_donhang_id";
                                int countNL = (int)mdbc.ExecuteScalar(selDetails, "@c_donhang_id", poId);
                                if (countNL > 0)
                                {
                                    string sql_check = @"select COUNT(1) from [dbo].[f_tinhNangLucCungUng]('" + poId + "')" + " where result_nhandh = 0 or result = 0";
                                    int check = (int)mdbc.ExecuteScalar(sql_check);
                                    if (check == 0)
                                    {
                                        c_donhang dh = db.c_donhangs.Single(p => p.c_donhang_id == poId);
                                        dh.md_trangthai_id = "HIEULUC";
                                        db.SubmitChanges();
                                        mdbc.ExecuteScalarProcedure("p_bookNangLucCungUng", "@donhang_id", poId);
                                        result += "Hiệu lực đơn hàng thành công.! <br/>";
                                    }
                                }
                                else
                                {
                                    result += "Đơn hàng chưa có dòng hàng.! <br/>";
                                }
                            }
                            else
                            {
                                result += "Năng lực của nhà cung ứng không đáp ứng đủ cho đơn hàng này.! <br/>";
                                result += "<table><tr><td><input type='checkbox'/></td><td>Yêu cầu Administrator Hiệu Lực</td></tr></table>";
                            }
                        }
                        */
                    }
                    break;
                default:
                    break;
            }
        }

        context.Response.Write(result);
    }
    catch (Exception ex)
    {
        context.Response.Write(ex.ToString());
    }
}

public void getSelectOption(HttpContext context)
{
    String sql = "select c_donhang_id, sochungtu from c_donhang where hoatdong = 1";
    SelectHtmlControl s = new SelectHtmlControl(sql);
    context.Response.Write(s.ToString());
}
#endregion

#region oper

#region AddEditDel
public void add(HttpContext context)
{
    try
    {
        string msg = "";
        int check = 0;
        int donhangmau_ = 0;
        String loaiDH = context.Request.Form["loai"];
        String dh_mau = context.Request.Form["donhang_mau"].ToLower();
        String dagui_mail = context.Request.Form["dagui_mail"].ToLower();
        String donhang_tmp = context.Request.Form["isdonhangtmp"].ToLower();
        String gia_db = context.Request.Form["gia_db"].ToLower();
        string chkPBGCu_str = context.Request.Form["chkPBGCu"];
        string phienbangiacu = context.Request.Form["phienbangiacu"];
        string phienbangiadacbiet = context.Request.Form["phienbangiadacbiet"];
        if (!string.IsNullOrWhiteSpace(phienbangiadacbiet))
            phienbangiadacbiet = db.md_phienbangias.Where(s => s.ten_phienbangia == phienbangiadacbiet).Select(s => s.md_phienbangia_id).FirstOrDefault();

        string phanbodiscountStr = (context.Request.Form["phanbodiscount"] + "").ToLower();
        var phanbodiscount = phanbodiscountStr.Equals("on") || phanbodiscountStr.Equals("true");
        string chuyenphiDSDHStr = (context.Request.Form["chuyenphiDSDH"] + "").ToLower();
        var chuyenphiDSDH = chuyenphiDSDHStr.Equals("on") || chuyenphiDSDHStr.Equals("true");

        bool isdh_mau, isdonhang_tmp, isgiadb, chkPBGCu = false;
        isdh_mau = isdonhang_tmp = isgiadb = false;
        decimal mnu_cont20 = 0;
        try { mnu_cont20 = decimal.Parse(context.Request.Form["cont20"]); } catch { }
        decimal mnu_cont40 = 0;
        try { mnu_cont40 = decimal.Parse(context.Request.Form["cont40"]); } catch { }
        decimal mnu_cont40hc = 0;
        try { mnu_cont40hc = decimal.Parse(context.Request.Form["cont40hc"]); } catch { }
        decimal mnu_cont45 = 0;
        try { mnu_cont45 = decimal.Parse(context.Request.Form["cont45"]); } catch { }
        decimal mnu_contle = 0;
        try { mnu_contle = decimal.Parse(context.Request.Form["contle"]); } catch { }


        if (chkPBGCu_str != null)
        {
            chkPBGCu_str = chkPBGCu_str.ToLower();
            if (chkPBGCu_str.Equals("on") || chkPBGCu_str.Equals("true"))
            { chkPBGCu = true; }
        }

        if (donhang_tmp.Equals("on") || donhang_tmp.Equals("true"))
        { isdonhang_tmp = true; donhangmau_ = 2; }

        if (dh_mau.Equals("on") || dh_mau.Equals("true"))
        { isdh_mau = true; donhangmau_ = 1; }

        if (gia_db.Equals("on") || gia_db.Equals("true"))
        { isgiadb = true; }

        if (dagui_mail.Equals("on") || dagui_mail.Equals("true"))
        {
            dagui_mail = "true";
        }
        else
        {
            dagui_mail = "false";
        }

        int countsct = (from dh in db.c_donhangs where dh.sochungtu.Equals(context.Request.Form["sochungtu"]) select new { dh.sochungtu }).Count();
        if (countsct > 0)
        {
            jqGridHelper.Utils.writeResult(0, "Số chứng từ đã tồn tại.");
        }
        else if (isdonhang_tmp && isdh_mau)
        {
            jqGridHelper.Utils.writeResult(0, "Tạo đơn hàng thất bại! chỉ được chọn hoặc đơn hàng tmp hoặt đơn hàng mẫu.");
        }
        else if (mnu_cont20 <= 0 & mnu_cont40 <= 0 & mnu_cont40hc <= 0 & mnu_cont45 <= 0 & mnu_contle <= 0)
        {
            jqGridHelper.Utils.writeResult(0, "Tạo đơn hàng thất bại! Phải có ít nhất 1 cont lớn hơn 0.");
        }
        else
        {
            string md_cangbien_id = context.Request.Form["md_cangbien_id"];
            md_cangbien cb = db.md_cangbiens.FirstOrDefault(p => p.md_cangbien_id.Equals(md_cangbien_id));
            md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(context.Request.Form["md_doitackinhdoanh_id"]));
            if (cb != null)
            {
                c_donhang mnu = new c_donhang();
                mnu.c_donhang_id = ImportUtils.getNEWID();
                mnu.loai = loaiDH;
                mnu.md_trangthai_id = Helper.SOANTHAO;
                mnu.md_doitackinhdoanh_id = context.Request.Form["md_doitackinhdoanh_id"];
                mnu.c_baogia_id = context.Request.Form["c_baogia_id"];
                mnu.ngaylap = DateTime.ParseExact(context.Request.Form["ngaylap"], "dd/MM/yyyy", null);
                mnu.nguoilap = UserUtils.getUser(context);
                mnu.md_cangbien_id = context.Request.Form["md_cangbien_id"];
                mnu.discount = decimal.Parse(context.Request.Form["discount"]);
                mnu.tanggia = context.Request.Form["tanggia"].ToNullableDecimal().GetValueOrDefault(0);
                mnu.shipmentdate = DateTime.ParseExact(context.Request.Form["shipmentdate"], "dd/MM/yyyy", null);
                mnu.shipmenttime = DateTime.ParseExact(context.Request.Form["shipmenttime"], "dd/MM/yyyy", null);
                mnu.md_paymentterm_id = context.Request.Form["md_paymentterm_id"];
                mnu.md_nganhang_id = context.Request.Form["md_nganhang_id"];
                mnu.md_trongluong_id = context.Request.Form["md_trongluong_id"];
                mnu.md_dongtien_id = context.Request.Form["md_dongtien_id"];
                mnu.md_kichthuoc_id = context.Request.Form["md_kichthuoc_id"];
                mnu.cont20 = decimal.Parse(context.Request.Form["cont20"]);
                mnu.cont40 = decimal.Parse(context.Request.Form["cont40"]);
                mnu.cont40hc = decimal.Parse(context.Request.Form["cont40hc"]);
                mnu.cont45 = decimal.Parse(context.Request.Form["cont45"]);
                mnu.contle = decimal.Parse(context.Request.Form["contle"]);
                mnu.payer = context.Request.Form["payer"];
                mnu.portdischarge = context.Request.Form["portdischarge"];
                mnu.donhang_mau = isdh_mau;
                mnu.isdonhangtmp = isdonhang_tmp;
                mnu.dagui_mail = bool.Parse(dagui_mail);
                mnu.hoahong = decimal.Parse(context.Request.Form["hoahong"]);
                mnu.md_nguoilienhe_id = context.Request.Form["md_nguoilienhe_id"];
                mnu.ismakepi = false;
                mnu.customer_order_no = context.Request.Form["customer_order_no"];
                mnu.gia_db = isgiadb;
                mnu.phienbangiadacbiet = phienbangiadacbiet;
                mnu.chkPBGCu = chkPBGCu;
                mnu.phienbangiacu = phienbangiacu;
                mnu.ghichu = context.Request.Form["ghichu"];
                mnu.nhanvienCT = context.Request.Form["nhanvienCT"].removeAllSpaceOrTrimText(true);
                if (mnu.ngaypass == null)
                    mnu.ngaypass = context.Request.Form["ngaypass"].removeAllSpaceOrTrimText(false).ToNullableDate();

                if (!context.Request.Form["ngaydieuchinh"].Equals(""))
                {
                    mnu.ngaydieuchinh = DateTime.ParseExact(context.Request.Form["ngaydieuchinh"], "dd/MM/yyyy", null);
                }

                mnu.md_banggia_id = context.Request.Form["md_banggia_id"];
                mnu.sochungtu = jqGridHelper.Utils.taoChungTuPO(context.Request.Form["md_doitackinhdoanh_id"], donhangmau_, mnu.ngaylap.Value.Year.ToString(), loaiDH, db);

                mnu.chuyenphiDSDH = chuyenphiDSDH;
                mnu.phanbodiscount = phanbodiscount;
                mnu.mota = context.Request.Form["mota"];
                mnu.hoatdong = true;
                mnu.ngaytao = DateTime.Now;
                mnu.ngaycapnhat = DateTime.Now;
                mnu.nguoitao = UserUtils.getUser(context);
                mnu.nguoicapnhat = UserUtils.getUser(context);

                md_doitackinhdoanh doitac = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(mnu.md_doitackinhdoanh_id));
                md_banggia bga = db.md_banggias.Where(s => s.ten_banggia.Contains(doitac.ma_dtkd + "-FOB")).FirstOrDefault();
                if (bga == null & isgiadb == true)
                {
                    msg = "Khách hàng " + doitac.ma_dtkd + " không có bảng giá đặc biệt";
                    check++;
                }
                else if (mnu.ngaylap >= mnu.shipmentdate || mnu.ngaylap >= mnu.shipmenttime)
                {
                    check++;
                    msg = "Ngày lập PO không được phép lớn hơn shipmenttime hoặc shipmentdate!";
                }
                else if (mnu.shipmentdate <= mnu.shipmenttime)
                {
                    check++;
                    msg = "Ngày Shipmentdate phải lớn hơn Shipmenttime!";
                }
                else if (dtkd.ma_dtkd == "")
                {
                    msg = "Khách Hàng không được để trống!";
                    check++;
                }
                else if (chkPBGCu == true & String.IsNullOrEmpty(phienbangiacu))
                {
                    msg = "\"Phiên bảng giá cũ\" không thể bỏ trống.";
                    check++;
                }

                if (check == 0)
                {
                    db.c_donhangs.InsertOnSubmit(mnu);

                    //var spd = db.md_doitackinhdoanh_spds.Where(s => s.md_doitackinhdoanh_id == dtkd.md_doitackinhdoanh_id).OrderByDescending(s => s.ngaytao).FirstOrDefault();
                    //if (spd != null)
                    //{
                    //    var spd2 = new c_donhang_spd();
                    //    spd2.c_donhang_spd_id = Helper.getNewId();
                    //    spd2.c_donhang_id = mnu.c_donhang_id;
                    //    spd2.Forwarder = spd.Forwarder;
                    //    spd2.Shipper = spd.Shipper;
                    //    spd2.Consignee = spd.Consignee;
                    //    spd2.Notify = spd.Notify;
                    //    spd2.AlsoNotify = spd.AlsoNotify;
                    //    spd2.POD = spd.POD;
                    //    spd2.PlaceOfDelivery = spd.PlaceOfDelivery;
                    //    spd2.AddressForSendingOriginalDocs = spd.AddressForSendingOriginalDocs;
                    //    spd2.EmailSendPaymentRequest = spd.EmailSendPaymentRequest;
                    //    spd2.CacLoaiCTYC = spd.CacLoaiCTYC;
                    //    spd2.mota = "";
                    //    spd2.ngaytao = DateTime.Now;
                    //    spd2.nguoitao = UserUtils.getUser(context);
                    //    spd2.ngaycapnhat = DateTime.Now;
                    //    spd2.nguoicapnhat = UserUtils.getUser(context);
                    //    spd2.hoatdong = true;
                    //    db.c_donhang_spds.InsertOnSubmit(spd2);
                    //}
                    db.SubmitChanges();
                    trg_c_donhang.load(db, new List<c_donhang>() { mnu }, true);
                    jqGridHelper.Utils.writeResult(1, "Thêm mới thành công!");
                }
                else
                {
                    jqGridHelper.Utils.writeResult(0, msg);
                }
            }
            else
            {
                jqGridHelper.Utils.writeResult(0, "Hãy chọn một cảng biển!");
            }
        }
    }
    catch (Exception ex)
    {
        jqGridHelper.Utils.writeResult(0, ex.Message);
    }
}

public void edit(HttpContext context)
{
    try
    {
        string msg = "";
        int check = 0;
        String h = context.Request.Form["hoatdong"].ToLower();
        String dh_mau = context.Request.Form["donhang_mau"].ToLower();
        String dagui_mail = context.Request.Form["dagui_mail"].ToLower();
        String donhang_tmp = context.Request.Form["isdonhangtmp"].ToLower();
        string phanbodiscountStr = (context.Request.Form["phanbodiscount"] + "").ToLower();
        var phanbodiscount = phanbodiscountStr.Equals("on") || phanbodiscountStr.Equals("true");
        string chuyenphiDSDHStr = (context.Request.Form["chuyenphiDSDH"] + "").ToLower();
        var chuyenphiDSDH = chuyenphiDSDHStr.Equals("on") || chuyenphiDSDHStr.Equals("true");

        decimal mnu_cont20 = 0;
        try { mnu_cont20 = decimal.Parse(context.Request.Form["cont20"]); } catch { }
        decimal mnu_cont40 = 0;
        try { mnu_cont40 = decimal.Parse(context.Request.Form["cont40"]); } catch { }
        decimal mnu_cont40hc = 0;
        try { mnu_cont40hc = decimal.Parse(context.Request.Form["cont40hc"]); } catch { }
        decimal mnu_cont45 = 0;
        try { mnu_cont45 = decimal.Parse(context.Request.Form["cont45"]); } catch { }
        decimal mnu_contle = 0;
        try { mnu_contle = decimal.Parse(context.Request.Form["contle"]); } catch { }

        bool isdh_mau, isdonhang_tmp;
        isdh_mau = isdonhang_tmp = false;

        if (dh_mau.Equals("on") || dh_mau.Equals("true"))
        { isdh_mau = true; }


        if (donhang_tmp.Equals("on") || donhang_tmp.Equals("true"))
        { isdonhang_tmp = true; }


        if (dagui_mail.Equals("on") || dagui_mail.Equals("true"))
        {
            dagui_mail = "true";
        }
        else
        {
            dagui_mail = "false";
        }

        string md_cangbien_id = context.Request.Form["md_cangbien_id"];
        md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(context.Request.Form["md_doitackinhdoanh_id"]));
        md_cangbien cb = db.md_cangbiens.FirstOrDefault(p => p.md_cangbien_id.Equals(md_cangbien_id));
        c_donhang m = db.c_donhangs.Single(p => p.c_donhang_id == context.Request.Form["id"]);
        var ngaypass = context.Request.Form["ngaypass"].removeAllSpaceOrTrimText(false).ToNullableDate();
        var nvct = context.Request.Form["nhanvienCT"].removeAllSpaceOrTrimText(true);

        if (m.md_trangthai_id.Equals(Helper.HIEULUC))
        {
            var tbps = Public.layTruongBoPhan(db, Helper.TENBP_CHUNGTU).Select(s => s.email).ToList();
            if (tbps.Count <= 0)
            {
                jqGridHelper.Utils.writeResult(0, $@"Không tìm thấy trưởng bộ phận của bộ phận {Helper.TENBP_CHUNGTU}");
                goto EndEventHandler;
            }
            string emailTBPs = string.Join(";", tbps);

            m.portdischarge = context.Request.Form["portdischarge"];
            m.mota = context.Request.Form["mota"];
            m.ghichu = context.Request.Form["ghichu"];
            m.nhanvienCT = nvct;

            var codoingaypass = false;
            var emailNVCT = "";
            if (ngaypass != null)
            {
                if (m.ngaypass == null)
                {
                    m.ngaypass = ngaypass;
                    codoingaypass = true;
                }
                else if (m.ngaypass != ngaypass)
                {
                    jqGridHelper.Utils.writeResult(0, "Không thể đổi ngày pass kiểm hóa khi đơn hàng đã hiệu lực và trường đã có giá trị trước đó.");
                    goto EndEventHandler;
                }

                if(codoingaypass)
                {
                    emailNVCT = db.nhanviens.Where(s => s.manv == m.nhanvienCT).Select(s => s.email).FirstOrDefault();
                    if(string.IsNullOrWhiteSpace(emailNVCT))
                    {
                        jqGridHelper.Utils.writeResult(0, $@"Không tìm thấy email của nhân viên chứng từ ""{m.nhanvienCT}""");
                        goto EndEventHandler;
                    }
                }
            }
            db.SubmitChanges();

            if (codoingaypass)
            {
                string manv = UserUtils.getUser(context);
                var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
                var smtp = db.md_smtps.Where(p => p.macdinh.Equals(true)).FirstOrDefault();
                if (!string.IsNullOrWhiteSpace(nv.smtp))
                {
                    smtp = db.md_smtps.Where(s => s.md_smtp_id == nv.smtp).FirstOrDefault();
                }
                var mail = new GoogleMail();
                mail.Email = nv.email;
                mail.Password = nv.email_pass;
                mail.Smtp = smtp.smtpserver;
                mail.Port = smtp.port.Value;
                mail.Ssl = smtp.use_ssl.GetValueOrDefault(false);
                string title = $@"Bán hàng gửi ngày pass kiểm hóa cho đơn hàng ({m.sochungtu})", body = $@"Ngày pass kiểm hóa: {m.ngaypass.Value.ToString(Extension.fmtDate)}";
                string cc = $"{nv.email},{emailTBPs}";
                var attachments = new List<System.Net.Mail.Attachment>();
                mail.Send(
                    nv.email
                    , emailNVCT
                    , cc
                    , ""
                    , title
                    , body
                    , attachments
                );
            }
        }
        else if (m.md_doitackinhdoanh_id != dtkd.md_doitackinhdoanh_id)
        {
            jqGridHelper.Utils.writeResult(0, "Không thể đổi khách hàng.");
        }
        else if (mnu_cont20 <= 0 & mnu_cont40 <= 0 & mnu_cont40hc <= 0 & mnu_cont45 <= 0 & mnu_contle <= 0)
        {
            jqGridHelper.Utils.writeResult(0, "Tạo đơn hàng thất bại! Phải có ít nhất 1 cont lớn hơn 0.");
        }
        else
        {
            if (cb != null)
            {
                m.discount_hehang = context.Request.Form["discount_hehang"] == "True";
                m.discount_hehang_value = m.discount_hehang.GetValueOrDefault(false) ? context.Request.Form["discount_hehang_value"] : "";
                m.tanggiahehang = context.Request.Form["tanggiahehang"] == "True";
                m.tanggiahehang_value = m.tanggiahehang.GetValueOrDefault(false) ? context.Request.Form["tanggiahehang_value"] : "";
                m.md_doitackinhdoanh_id = context.Request.Form["md_doitackinhdoanh_id"];
                m.sochungtu = context.Request.Form["sochungtu"];
                m.ngaylap = DateTime.ParseExact(context.Request.Form["ngaylap"], "dd/MM/yyyy", null);
                //m.nguoilap = UserUtils.getUser(context);
                m.md_cangbien_id = context.Request.Form["md_cangbien_id"];

                m.tanggia = context.Request.Form["tanggia"].ToNullableDecimal().GetValueOrDefault(0);
                m.discount = decimal.Parse(context.Request.Form["discount"]);
                m.shipmentdate = DateTime.ParseExact(context.Request.Form["shipmentdate"], "dd/MM/yyyy", null);
                m.shipmenttime = DateTime.ParseExact(context.Request.Form["shipmenttime"], "dd/MM/yyyy", null);
                m.md_paymentterm_id = context.Request.Form["md_paymentterm_id"];
                m.md_nganhang_id = context.Request.Form["md_nganhang_id"];
                m.md_trongluong_id = context.Request.Form["md_trongluong_id"];
                m.md_dongtien_id = context.Request.Form["md_dongtien_id"];
                m.md_kichthuoc_id = context.Request.Form["md_kichthuoc_id"];
                m.payer = context.Request.Form["payer"];
                m.portdischarge = context.Request.Form["portdischarge"];
                m.sl_cont = 0;
                m.cont20 = decimal.Parse(context.Request.Form["cont20"]);
                m.cont40 = decimal.Parse(context.Request.Form["cont40"]);
                m.cont40hc = decimal.Parse(context.Request.Form["cont40hc"]);
                m.cont45 = decimal.Parse(context.Request.Form["cont45"]);
                m.contle = decimal.Parse(context.Request.Form["contle"]);
                m.customer_order_no = context.Request.Form["customer_order_no"];

                m.md_banggia_id = context.Request.Form["md_banggia_id"];
                m.donhang_mau = isdh_mau;
                m.dagui_mail = bool.Parse(dagui_mail);
                m.isdonhangtmp = isdonhang_tmp;
                m.hoahong = decimal.Parse(context.Request.Form["hoahong"]);
                m.md_nguoilienhe_id = context.Request.Form["md_nguoilienhe_id"];
                m.ghichu = context.Request.Form["ghichu"];
                m.ngaypass = ngaypass;
                m.nhanvienCT = nvct;
                if (!context.Request.Form["ngaydieuchinh"].Equals(""))
                {
                    m.ngaydieuchinh = DateTime.ParseExact(context.Request.Form["ngaydieuchinh"], "dd/MM/yyyy", null);
                }

                int countsct = (from dh in db.c_donhangs where dh.sochungtu.Equals(context.Request.Form["sochungtu"]) && !dh.c_donhang_id.Equals(m.c_donhang_id) select new { dh.sochungtu }).Count();

                m.mota = context.Request.Form["mota"];
                m.phanbodiscount = phanbodiscount;
                m.chuyenphiDSDH = chuyenphiDSDH;
                m.hoatdong = true;
                m.ngaycapnhat = DateTime.Now;
                m.nguoicapnhat = UserUtils.getUser(context);

                if (countsct > 0)
                {
                    msg = "Số chứng từ đã tồn tại";
                    check++;
                }

                if (m.ngaylap >= m.shipmenttime || m.ngaylap >= m.shipmentdate)
                {
                    msg = "Ngày lập PO không thể lớn hơn shipmenttime hoặc shipmentdate!";
                    check++;
                }

                if (m.shipmentdate <= m.shipmenttime)
                {
                    msg = "Ngày Shipmentdate phải lớn hơn ngày Shipmenttime!";
                    check++;
                }

                if (dtkd.ma_dtkd == "")
                {
                    msg = "Khách Hàng không được để trống!";
                    check++;
                }

                if (m.md_trangthai_id.Equals(Helper.KETTHUC))
                {
                    msg = "Không thể sửa PO đã kết thúc!";
                    check++;
                }

                if (check == 0)
                {
                    db.SubmitChanges();

                    if (m.md_trangthai_id == Helper.SOANTHAO)
                    {
                        if (m.discount_hehang.GetValueOrDefault(false))
                        {
                            foreach (var cdh in db.c_dongdonhangs.Where(s => s.c_donhang_id == m.c_donhang_id).ToList())
                            {
                                Public.TangGiaHehangValue(m, cdh, db);
                                var t = Public.DiscountHehangValue(m.discount_hehang_value, cdh, db);
                                cdh.giafob = t.giafob;
                                cdh.discount = t.discount;
                            }
                        }
                        else
                        {
                            foreach (var cdh in db.c_dongdonhangs.Where(s => s.c_donhang_id == m.c_donhang_id).ToList())
                            {
                                Public.TangGiaHehangValue(m, cdh, db);
                                cdh.giafob = cdh.giachuan == null ? cdh.giafob : cdh.giachuan;
                                cdh.discount = 0;
                            }
                        }
                    }

                    db.SubmitChanges();
                    Public.triggerDonHang(db, m, null, true);
                    trg_c_donhang.load(db, new List<c_donhang>() { m }, true);
                    jqGridHelper.Utils.writeResult(1, "Cập nhật thành công!");
                }
                else
                {
                    jqGridHelper.Utils.writeResult(0, msg);
                }
            }
            else
            {
                jqGridHelper.Utils.writeResult(0, "Hãy chọn một cảng biển!");
            }
        }
    }
    catch (Exception ex)
    {
        jqGridHelper.Utils.writeResult(0, ex + "");
    }

    EndEventHandler:;
}

public void del(HttpContext context)
{
    String id = context.Request.Form["id"];
    c_donhang donhang = db.c_donhangs.FirstOrDefault(i => i.c_donhang_id.Equals(id));
    string msg = "";
    // id = id.Insert(0, "'");
    // id = id.Insert(id.Length, "'");
    // id = id.Replace(",", "','");
    try
    {
        if (donhang != null)
        {
            bool duocXoa = Public.LaNguoiTao(context, donhang.nguoitao, db);
            if (
                donhang.md_trangthai_id.Equals("HIEULUC") |
                donhang.md_trangthai_id.Equals("HUY") |
                donhang.md_trangthai_id.Equals("KETTHUC")
            )
            {
                msg = "Chỉ có thể xóa đơn hàng ở trạng thái \"Soạn Thảo\"!";
                jqGridHelper.Utils.writeResult(0, msg);
            }
            else if (duocXoa == false)
            {
                jqGridHelper.Utils.writeResult(0, string.Format(@"Chỉ tài khoản {0} hoặc admin mới có thể xóa.!", donhang.nguoitao));
            }
            else
            {
                // String sql = "delete c_donhang where c_donhang_id IN (" + id + ")";
                // String sqlDetails = "delete c_dongdonhang where c_donhang_id IN (" + id + ")";
                // mdbc.ExcuteNonQuery(sqlDetails);
                // mdbc.ExcuteNonQuery(sql);
                var bgqr = db.c_baogiaqrs.Where(s => s.c_baogiaqr_id == donhang.c_baogia_id).FirstOrDefault();
                if (bgqr != null)
                    bgqr.md_trangthai_id = Helper.SOANTHAO;
                db.c_donhangs.DeleteOnSubmit(donhang);
                db.SubmitChanges();

                foreach (c_dongdonhang ddh in db.c_dongdonhangs.Where(s => s.c_donhang_id == id))
                {
                    db.c_dongdonhangs.DeleteOnSubmit(ddh);
                }

                foreach (var ddh in db.c_phidonhangs.Where(s => s.c_donhang_id == id))
                {
                    db.c_phidonhangs.DeleteOnSubmit(ddh);
                }

                foreach (var ddh in db.c_donhang_spds.Where(s => s.c_donhang_id == id))
                {
                    db.c_donhang_spds.DeleteOnSubmit(ddh);
                }

                db.SubmitChanges();
                jqGridHelper.Utils.writeResult(1, "Xóa thành công!");
            }
        }
        else
        {
            jqGridHelper.Utils.writeResult(1, "Không tìm tháy đơn hàng, vui lòng làm mới dữ liệu!");
        }
    }
    catch (Exception ex)
    {
        jqGridHelper.Utils.writeResult(0, "Fail!" + ex.Message);
    }
}
#endregion

#region load
public void load(HttpContext context)
{
    context.Response.ContentType = "text/xml";
    context.Response.Charset = "UTF-8";

    bool isadmin = db.nhanviens.FirstOrDefault(p => p.manv.Equals(UserUtils.getUser(context))).isadmin.Value;

    String md_trangthai_id = context.Request.QueryString["status"];
    md_trangthai_id = md_trangthai_id == null ? "" : md_trangthai_id.ToUpper();

    String fStatus = "";

    if (md_trangthai_id.Equals("ALL"))
    {
        fStatus = "";
    }
    else
    {
        fStatus = String.Format("AND dh.md_trangthai_id = N'{0}' ", md_trangthai_id);
    }

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


    String sqlCount = @"SELECT COUNT(1) AS count 
            FROM c_donhang dh with (nolock)
			left join md_doitackinhdoanh dtkd with (nolock) on dh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
			left join md_cangbien cbien with (nolock) on dh.md_cangbien_id = cbien.md_cangbien_id
            left join md_paymentterm pmt with (nolock) on dh.md_paymentterm_id = pmt.md_paymentterm_id
			left join md_trongluong tl with (nolock) on dh.md_trongluong_id = tl.md_trongluong_id
			left join md_kichthuoc kt with (nolock) on dh.md_kichthuoc_id = kt.md_kichthuoc_id
			left join md_dongtien dtien with (nolock) on dh.md_dongtien_id = dtien.md_dongtien_id
			left join md_nganhang ngh with (nolock) on dh.md_nganhang_id = ngh.md_nganhang_id
            WHERE 1 = 1 {0} " + fStatus + " {1}";

    sqlCount = String.Format(sqlCount, isadmin == true ? "" : "AND dh.nguoitao IN(" + strAccount + ")", filter);

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
        sidx = "dh.c_donhang_id";
    }
    //dh.payer,
    string strsql = @"select * from( 
            select dh.c_donhang_id, dh.md_trangthai_id, dh.trangthaict, dh.donhang_mau, dh.sochungtu, dh.customer_order_no, 
            dtkd.ma_dtkd, dh.ngaylap, dh.nguoilap, 
            cbien.ten_cangbien, dh.discount, dh.shipmenttime, 
            dh.shipmentdate, pmt.ten_paymentterm, ngh.ma_nganhang,  tl.ten_trongluong, 
            dtien.ma_iso as tendongtien, kt.ten_kichthuoc, 
            CASE 
                WHEN LTRIM(RTRIM(ISNULL(dh.payer, ''))) = '' 
                    THEN ISNULL(dtkd.payer, '')
                ELSE dh.payer
            END as payer,
            dh.portdischarge, 
			dh.amount,
            dh.totalcbm, dh.totalcbf, dh.dagui_mail, 
            dh.cont20, dh.cont40, dh.cont40hc, dh.contle, dh.cont45, 
            dh.ismakepi, dh.isdonhangtmp, 
            (case when md_nguoilienhe_id is null then '' else (select ma_dtkd from md_doitackinhdoanh where md_doitackinhdoanh_id = dh.md_nguoilienhe_id) end) as nguoilienhe, 
            dh.hoahong, dh.ngaydieuchinh, 
            dh.ngaytao, dh.nguoitao, dh.ngaycapnhat, dh.nguoicapnhat, dh.mota, dh.hoatdong, 
            dh.tanggia,
            dh.tanggiahehang,
            dh.tanggiahehang_value,
            dh.gia_db,
            pbg.ten_phienbangia,
            dh.chkPBGCu,
            dh.phienbangiacu,
            dh.ghichu,
            dh.loai,
            dh.phanbodiscount,
            dh.chuyenphiDSDH,
            dh.discount_hehang,
            dh.discount_hehang_value,
            dh.ngaypass,
            dh.ngayBHXN,
            dh.nhanvienCT,
            ROW_NUMBER() OVER (ORDER BY {2} {3}) as RowNum 
            FROM c_donhang dh with (nolock)
			left join md_doitackinhdoanh dtkd with (nolock) on dh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
			left join md_cangbien cbien with (nolock) on dh.md_cangbien_id = cbien.md_cangbien_id
            left join md_paymentterm pmt with (nolock) on dh.md_paymentterm_id = pmt.md_paymentterm_id
			left join md_trongluong tl with (nolock) on dh.md_trongluong_id = tl.md_trongluong_id
			left join md_kichthuoc kt with (nolock) on dh.md_kichthuoc_id = kt.md_kichthuoc_id
			left join md_dongtien dtien with (nolock) on dh.md_dongtien_id = dtien.md_dongtien_id
			left join md_nganhang ngh with (nolock) on dh.md_nganhang_id = ngh.md_nganhang_id
            left join md_phienbangia pbg with (nolock) on dh.phienbangiadacbiet = pbg.md_phienbangia_id
            WHERE 1 = 1 {0} {4} {1} )P where RowNum > @start AND RowNum < @end";

    strsql = String.Format(strsql,
        isadmin == true ? "" : "AND dh.nguoitao IN(" + strAccount + ")",
        filter, sidx, sord, fStatus);

    System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
    string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
    xml += "<rows>";
    xml += "<page>" + page + "</page>";
    xml += "<total>" + total_page + "</total>";
    xml += "<records>" + count + "</records>";
    foreach (System.Data.DataRow row in dt.Rows)
    {
        xml += "<row>";
        xml += "<cell><![CDATA[" + row["c_donhang_id"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["md_trangthai_id"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["trangthaict"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ma_dtkd"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["sochungtu"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["customer_order_no"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ten_cangbien"] + "]]></cell>";
        xml += "<cell><![CDATA[" + DateTime.Parse(row["shipmenttime"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
        xml += "<cell><![CDATA[" + row["totalcbm"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["amount"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["discount"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ten_paymentterm"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ma_nganhang"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["hoahong"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["nguoilienhe"] + "]]></cell>";

        xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaylap"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
        xml += "<cell><![CDATA[" + row["nguoilap"] + "]]></cell>";
        xml += "<cell><![CDATA[" + DateTime.Parse(row["shipmentdate"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
        xml += "<cell><![CDATA[" + ((!row["ngaydieuchinh"].ToString().Equals("")) ? DateTime.Parse(row["ngaydieuchinh"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
        xml += "<cell><![CDATA[" + row["donhang_mau"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["isdonhangtmp"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ten_trongluong"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["tendongtien"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ten_kichthuoc"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["payer"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["portdischarge"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["totalcbf"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["cont20"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["cont40"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["cont40hc"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["cont45"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["contle"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["dagui_mail"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ismakepi"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["loai"] + "]]></cell>";
        xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaytao"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
        xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";
        xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaycapnhat"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
        xml += "<cell><![CDATA[" + row["nguoicapnhat"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["mota"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["hoatdong"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["tanggia"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["tanggiahehang"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["tanggiahehang_value"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["gia_db"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ten_phienbangia"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["chkPBGCu"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["phienbangiacu"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["ghichu"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["phanbodiscount"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["chuyenphiDSDH"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["discount_hehang"] + "]]></cell>";
        xml += "<cell><![CDATA[" + row["discount_hehang_value"] + "]]></cell>";
        xml += "<cell><![CDATA[" + ((!row["ngaypass"].ToString().Equals("")) ? DateTime.Parse(row["ngaypass"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
        xml += "<cell><![CDATA[" + ((!row["ngayBHXN"].ToString().Equals("")) ? DateTime.Parse(row["ngayBHXN"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
        xml += "<cell><![CDATA[" + row["nhanvienCT"] + "]]></cell>";
        xml += "</row>";
    }
    xml += "</rows>";
    context.Response.Write(xml);
}
#endregion

public void get_dsncc(HttpContext context)
{
    string json = "[";
    string c_donhang_id = context.Request.QueryString["c_donhang_id"];
    var dtkds = from a in db.c_dongdonhangs
                join b in db.md_doitackinhdoanhs on a.nhacungungid equals b.md_doitackinhdoanh_id
                where a.c_donhang_id == c_donhang_id
                select new { b.md_doitackinhdoanh_id, b.ma_dtkd };

    foreach (var row in dtkds.Distinct().OrderBy(s => s.ma_dtkd))
    {
        json += string.Format(@"{{""id"":""{0}"", ""ma_dtkd"":""{1}"", ""tien"":""{2}""}},", row.md_doitackinhdoanh_id, row.ma_dtkd, 0);
    }
    if (json != "[")
    {
        json = json.Substring(0, json.Length - 1);
    }
    json += "]";

    context.Response.Write(json);
}
#endregion

public void Dispose()
{
    if (db != null)
    {
        db.Dispose();
        db = null;
    }
}

public bool IsReusable
{
    get
    {
        return false;
    }
}
}
