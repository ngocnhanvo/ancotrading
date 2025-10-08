using System;
using System.Globalization;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using System.Collections.Generic;
/// <summary>
/// Summary description for Helper
/// </summary>
public static class Helper
{
    #region bien toan cuc
    public static string CHUAGUI = "CHUAGUI";
    public static string DAGUI = "DAGUI";
    public static string DANHAN = "DANHAN";
    public static string TUCHOI = "TUCHOI";
    public static string SOANTHAO = "SOANTHAO";
    public static string HIEULUC = "HIEULUC";
    public static string KETTHUC = "KETTHUC";
    public static string HUY = "HUY";
    public static string NK = "NK";
    public static string XK = "XK";
    public static string HDBS = "HDBS", HDDG = "HDDG", HDCT = "HDCT", HDTEM_BAOBI = "HDTEM-BAOBI", PYCM = "PYCM", PTSP = "PTSP";
    public static string[] hoatdongs = new string[] { "true", "on" };
    #endregion bien toan cuc

    public static void removeFileWithPath(string path)
    {
        if (System.IO.File.Exists(path))
            System.IO.File.Delete(path);
    }

    public static string getClientIP(HttpContext context)
    {
        string clientIp = (
            context.Request.ServerVariables["HTTP_X_CLUSTER_CLIENT_IP"] ??
                context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ??
                   context.Request.ServerVariables["REMOTE_ADDR"]).Split(',')[0].Trim();

        return clientIp;
    }

    public static int getPage(HttpContext context)
    {
        int kq = 1;
        if (!string.IsNullOrWhiteSpace(context.Request.QueryString["page"]))
        {
            kq = int.Parse(context.Request.QueryString["page"]);
        }
        return kq;
    }

    public static void removeDirectoryWithPath(string path)
    {
        if (System.IO.Directory.Exists(path))
        {
            var filesLost = new System.IO.DirectoryInfo(path).GetFiles("*");
            foreach (var file in filesLost)
                System.IO.File.Delete(file.FullName);
            System.IO.Directory.Delete(path);
        }
    }

    public static string getNewId()
    {
        return Guid.NewGuid().ToString().Replace("-", "");
    }

    public static string EncodeHTML_VNN(string a)
    {
        if (a == null)
        {
            a = "";
        }
        a = a.Replace("&", "%26");
        a = a.Replace("+", "%2B");
        a = a.Replace("&", "%26");
        a = a.Replace("+", "%2B");
        return a;
    }

    public static string load_number(string number, int number_length)
    {
        int dodai = number_length - number.Length;
        string kq = "";
        for (int i = 0; i < dodai; i++)
        {
            kq += "0";
        }
        kq += number;

        return kq;
    }

    public static System.Collections.Generic.Dictionary<string, string> pathReport(string name)
    {
        name = name.Replace("/", "-");
        var obj = new System.Collections.Generic.Dictionary<string, string>();
        obj["name"] = name;
        obj["link"] = HttpContext.Current.Server.MapPath("~/DEV_REPORT/pdfs/" + name);
        obj["linkView"] = EncodeHTML_VNN("DEV_REPORT/pdfs/" + name);
        return obj;
    }

    public static System.Collections.Generic.Dictionary<string, string> pathImport(string name)
    {
        name = name.Replace("/", "-");
        var obj = new System.Collections.Generic.Dictionary<string, string>();
        obj["name"] = name;
        obj["link"] = HttpContext.Current.Server.MapPath("~/file_import/" + name);
        obj["linkView"] = "~/file_import/" + name;
        return obj;
    }

    public static string getConnectStrings(string ten_connectstring)
    {
        return System.Web.Configuration.WebConfigurationManager.ConnectionStrings[ten_connectstring].ConnectionString;
    }

    public static string getFilter(HttpContext context)
    {
        string filter = "";
        jqGridHelper.Filter f = new jqGridHelper.Filter();
        bool _search = bool.Parse(context.Request.Params["_search"]);
        if (_search)
        {
            String _filters = context.Request.Params["filters"];
            if (_filters != null & _filters != "")
            {
                f = jqGridHelper.Filter.CreateFilter(_filters);
                filter = f.ToScript();
            }
        }
        return filter;
    }

    public static int Week_(DateTime? nullable)
    {
        if (nullable.HasValue)
        {
            GregorianCalendar gCalendar = new GregorianCalendar();
            int WeekNumber = gCalendar.GetWeekOfYear(nullable.Value, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
            return WeekNumber;
        }
        else
            return 0;
    }

    public static DateTime FirstDateOfWeekISO8601(int year, int weekOfYear)
    {
        DateTime jan1 = new DateTime(year, 1, 1);
        int daysOffset = DayOfWeek.Thursday - jan1.DayOfWeek;
        DateTime firstThursday = jan1.AddDays(daysOffset);
        var cal = CultureInfo.CurrentCulture.Calendar;
        int firstWeek = cal.GetWeekOfYear(firstThursday, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);

        var weekNum = weekOfYear;
        if (firstWeek == 1)
        {
            weekNum -= 1;
        }
        var result = firstThursday.AddDays(weekNum * 7);
        return result.AddDays(-3);
    }

    public static void downloadFiles(HttpContext context, string name, string link, int type)
    {
        string contentType = type == 0 ? "application/pdf" : "application/vnd.ms-excel";
        context.Response.Buffer = true;
        context.Response.Clear();
        context.Response.AddHeader("Content-Disposition", "attachment;filename=" + name);
        context.Response.AddHeader("content-length", new System.IO.FileInfo(link).Length.ToString());
        context.Response.ContentType = contentType;
        context.Response.Charset = "";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.WriteFile(link);
        context.Response.End();
    }

    public static void viewFile(DevExpress.XtraReports.UI.XtraReport report)
    {
        if (report != null)
        {
            var pathRp = pathReport(report.DisplayName + ".pdf");
            report.ExportToPdf(pathRp["link"]);

            string url = "ViewPDFPublic/index.aspx?url_pdf=" + pathRp["linkView"] + "&remove=true&zoom=page-width&id=" + Guid.NewGuid();
            HttpContext.Current.Response.Redirect(url);
        }
    }

    public static md_bo layBoLonNhat(LinqDBDataContext db, string giaTriBo, string ma_sanpham)
    {
        md_bo boMain = null;
        if (giaTriBo.StartsWith("S"))
            boMain = db.md_bos.Where(s => s.ma_bo == giaTriBo & s.ma_bo_cha == giaTriBo).FirstOrDefault();
        else
        {
            var maBoCha = "S6";
            var maS = ma_sanpham.Substring(0, 9) + maBoCha + ma_sanpham.Substring(11);
            var spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
            if (spS == null)
            {
                maBoCha = "S5";
                maS = ma_sanpham.Substring(0, 9) + maBoCha + ma_sanpham.Substring(11);
                spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
            }
            if (spS == null)
            {
                maBoCha = "S4";
                maS = ma_sanpham.Substring(0, 9) + maBoCha + ma_sanpham.Substring(11);
                spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
            }
            if (spS == null)
            {
                maBoCha = "S3";
                maS = ma_sanpham.Substring(0, 9) + maBoCha + ma_sanpham.Substring(11);
                spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
            }
            if (spS == null)
            {
                maBoCha = "S2";
            }

            boMain = db.md_bos.Where(s => s.ma_bo == giaTriBo & s.ma_bo_cha == maBoCha).FirstOrDefault();
        }

        return boMain;
    }

    public static string themChiTietUyNhiemChi(
        HttpContext context, LinqDBDataContext db, 
        string loai, string istiencocStr, string tiencong, string c_thuchi_id, string ids,
        string values, string md_doitackinhdoanh_id, string ctd_ngaychi, string thueStr,
        string ltt, string loaiphieu2, string tkno, string tkco, string diengiai,
        string c_donhang_id, string c_packinginvoice_id, string mota,
        string sotien, string c_nhapxuat_id, string sotaikhoan, string nganhang, string tvpbid = "")
    {
        string msg = "";

        try
        {
            string sphieu_id = "b1b236e7fd8250eca850782b295d528e", sphieu = "", tiento = "UNC";

            if (loai == "TM")
            {
                sphieu_id = "91fb9d0f2fcbc85bdefa91cfa289f0d4"; //TM C
                tiento = "C";
            }

            hotro ht = db.hotros.Where(s => s.c_chitietthuchi_id == sphieu_id).FirstOrDefault();
            md_sochungtu sochungtu = db.md_sochungtus.Single(s => s.tiento == tiento);
            if (ht != null)
            {
                if (ht.ngaymoinhat.Value.Year == DateTime.Now.Year)
                {
                    if (ht.ngaymoinhat.Value.Month != DateTime.Now.Month)
                    {
                        sochungtu.so_duocgan = 1;
                    }
                    if (loai == "TM")
                        sphieu = sochungtu.so_duocgan + sochungtu.tiento + "/" + sochungtu.hauto;
                    else if (loai == "CK")
                        sphieu = sochungtu.tiento + sochungtu.so_duocgan + "/" + sochungtu.hauto;
                    sochungtu.so_duocgan = sochungtu.so_duocgan + sochungtu.buocnhay;
                }
                else
                {
                    if (loai == "TM")
                        sphieu = sochungtu.so_duocgan + sochungtu.tiento + "/" + sochungtu.hauto;
                    else if (loai == "CK")
                        sphieu = sochungtu.tiento + sochungtu.so_duocgan + "/" + sochungtu.hauto;
                    sochungtu.so_duocgan = sochungtu.so_duocgan + sochungtu.buocnhay;
                }
            }
            else
            {
                if (loai == "TM")
                    sphieu = sochungtu.so_duocgan + sochungtu.tiento + "/" + sochungtu.hauto;
                else if (loai == "CK")
                    sphieu = sochungtu.tiento + sochungtu.so_duocgan + "/" + sochungtu.hauto;
                sochungtu.so_duocgan = sochungtu.so_duocgan + sochungtu.buocnhay;
            }

            if (tiencong == null || tiencong == "")
                tiencong = "0";

            bool istiencoc = false;
            if (istiencocStr != null)
            {
                if (istiencocStr.ToLower().Equals("on")) { istiencoc = true; }
            }

            var thuchi = db.c_thuchis.Single(c => c.c_thuchi_id.Equals(c_thuchi_id));

            ids = ids.Replace("[", "").Replace("]", "").Replace("\"", "").Trim();
            values = values.Replace("[", "").Replace("]", "").Replace("\"", "").Trim();

            DateTime ngaychi = DateTime.ParseExact(ctd_ngaychi, "dd/MM/yyyy", null);
            int thue = int.Parse(thueStr);
            string[] idsArr = ids.Split(',');
            string[] valuesArr = values.Split(',');
            decimal sum_ = 0;
            for (int i = 0; i < valuesArr.Length; i++)
            {
                if (valuesArr[i].Length > 1)
                {
                    sum_ += decimal.Parse(valuesArr[i]);
                }
            }

            if (thuchi.md_trangthai_id.Equals("SOANTHAO"))
            {
                var idVal = new string[] { thuchi.md_doitackinhdoanh_id, thuchi.doitacValue };

                if (thuchi.sotien.Value > sum_)
                {
                    string lp2 = ltt == "KH" ? loaiphieu2 : "";
                    if (idsArr.Length > 0 && values.Length > 0)
                    {
                        for (int i = 0; i < idsArr.Length; i++)
                        {
                            var mnu = new c_chitietthuchi();
                            mnu.c_chitietthuchi_id = Helper.getNewId();
                            mnu.c_thuchi_id = c_thuchi_id;
                            mnu.loaiphieu2 = lp2;
                            mnu.loai = loai;
                            mnu.so_c = sphieu;
                            mnu.tk_no = int.Parse(tkno);
                            mnu.tk_co = int.Parse(tkco);
                            mnu.md_doitackinhdoanh_id = md_doitackinhdoanh_id;
                            mnu.dtkd_id_ThuChi = idVal[0];
                            mnu.dtkd_val_ThuChi = idVal[1];
                            mnu.sotien = decimal.Parse(valuesArr[i]);
                            mnu.sotiencong = decimal.Parse(tiencong);
                            mnu.quydoi = (thuchi.tygia.Value * decimal.Parse(valuesArr[i]));
                            mnu.diengiai = diengiai;
                            mnu.c_donhang_id = c_donhang_id;
                            mnu.ngaychi = ngaychi;
                            mnu.c_packinginvoice_id = c_packinginvoice_id;
                            mnu.obj_code = idsArr[i];
                            mnu.isdatcoc = istiencoc;
                            mnu.thue = thue;
                            mnu.mota = mota;
                            mnu.sotaikhoan = sotaikhoan;
                            mnu.nganhang = nganhang;
                            mnu.kt_tienve_phanbo_id = tvpbid;
                            mnu.hoatdong = true;
                            mnu.ngaytao = DateTime.Now;
                            mnu.ngaycapnhat = DateTime.Now;
                            mnu.nguoitao = UserUtils.getUser(context);
                            mnu.nguoicapnhat = UserUtils.getUser(context);

                            db.c_chitietthuchis.InsertOnSubmit(mnu);
                        }
                    }
                    else
                    {
                        var mnu = new c_chitietthuchi();
                        mnu.c_chitietthuchi_id = Helper.getNewId();
                        mnu.c_thuchi_id = c_thuchi_id;
                        mnu.so_c = sphieu;
                        mnu.loai = loai;
                        mnu.tk_no = int.Parse(tkno);
                        mnu.tk_co = int.Parse(tkco);
                        mnu.md_doitackinhdoanh_id = md_doitackinhdoanh_id;
                        mnu.dtkd_id_ThuChi = idVal[0];
                        mnu.dtkd_val_ThuChi = idVal[1];
                        mnu.sotien = decimal.Parse(sotien);
                        mnu.sotiencong = decimal.Parse(tiencong);
                        mnu.quydoi = (thuchi.tygia.Value * decimal.Parse(sotien));
                        mnu.diengiai = diengiai;
                        mnu.c_donhang_id = c_donhang_id;
                        mnu.ngaychi = ngaychi;
                        mnu.c_packinginvoice_id = c_packinginvoice_id;
                        mnu.obj_code = c_nhapxuat_id;
                        mnu.loaiphieu = ltt;
                        mnu.loaiphieu2 = lp2;
                        mnu.isdatcoc = istiencoc;
                        mnu.thue = thue;
                        mnu.mota = mota;
                        mnu.sotaikhoan = sotaikhoan;
                        mnu.nganhang = nganhang;
                        mnu.kt_tienve_phanbo_id = tvpbid;
                        mnu.hoatdong = true;
                        mnu.ngaytao = DateTime.Now;
                        mnu.ngaycapnhat = DateTime.Now;
                        mnu.nguoitao = UserUtils.getUser(context);
                        mnu.nguoicapnhat = UserUtils.getUser(context);

                        db.c_chitietthuchis.InsertOnSubmit(mnu);
                    }

                    ht = db.hotros.Where(s => s.c_chitietthuchi_id == sphieu_id).FirstOrDefault();
                    if (ht == null)
                    {
                        ht = new hotro();
                        ht.hotro_id = Security.EncodeMd5Hash(DateTime.Now.ToString("yyyyMMddddhhmmss"));
                        ht.c_chitietthuchi_id = sphieu_id;
                        ht.ngaymoinhat = DateTime.Now;
                        ht.hoatdong = true;
                        ht.ngaytao = DateTime.Now;
                        ht.ngaycapnhat = DateTime.Now;
                        ht.nguoitao = UserUtils.getUser(context);
                        ht.nguoicapnhat = UserUtils.getUser(context);
                        db.hotros.InsertOnSubmit(ht);
                    }
                    else
                    {
                        ht.ngaymoinhat = DateTime.Now;
                        ht.hoatdong = true;
                        ht.nguoicapnhat = UserUtils.getUser(context);
                        ht.ngaycapnhat = DateTime.Now;
                    }
                }
                else
                {
                    msg = "Số tiền phân bổ không hợp lệ!";
                }
            }
            else
            {
                msg = "Không thể thêm mới khi phiếu chi đã hiệu lực.";
            }
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        return msg;
    }

    public static string themPhieuThu(
        HttpContext context, LinqDBDataContext db,
        string tiento, decimal? soduocgan, string hauto, string dinhDanh,
        string md_doitackinhdoanh_id, string loai, string ngaylapphieu, string nguoi_giaonop,
        string ngay_giaonop, string sotien, string md_dongtien_id, string tygia,
        string lydo, string loaiphieu, string md_loaichungtu_id, 
        string sochungtuPT, string quydoi_vnd,
        string tk_quy, string mota
        )
    {
        string msg = "";

        try
        {
            var mnu = db.c_thuchis.Where(s => s.sophieu == dinhDanh).FirstOrDefault();
            var add = mnu == null;
            if (add)
            {
                mnu = new c_thuchi();
                mnu.c_thuchi_id = Helper.getNewId();
                string sphieu = tiento + "/" + soduocgan + "/" + hauto;
                mnu.sophieu = sphieu;
            }
            
            bool check = (bool)mdbc.ExecuteScalarProcedure("p_kiemtragiaodich", "@date", (DateTime.ParseExact(ngaylapphieu, "dd/MM/yyyy", null)).ToString("MM/dd/yyyy"), "@md_doitackinhdoanh_id", md_doitackinhdoanh_id);
            if (check.Equals(true))
            {
                mnu.loai = loai;
                mnu.md_doitackinhdoanh_id = md_doitackinhdoanh_id;
                mnu.ngaylapphieu = DateTime.ParseExact(ngaylapphieu, "dd/MM/yyyy", null);
                mnu.nguoi_giaonop = nguoi_giaonop;
                mnu.ngay_giaonop = DateTime.ParseExact(ngay_giaonop, "dd/MM/yyyy", null);
                mnu.sotien = decimal.Parse(sotien);
                mnu.md_dongtien_id = md_dongtien_id;
                mnu.tygia = decimal.Parse(tygia);
                mnu.lydo = lydo;
                mnu.loaiphieu = loaiphieu;
                mnu.sochungtu = sochungtuPT;
                if (string.IsNullOrWhiteSpace(quydoi_vnd))
                {
                    mnu.quydoi_vnd = (mnu.sotien.GetValueOrDefault(0) * mnu.tygia.GetValueOrDefault(0)).DecRound(-2);
                }
                else
                {
                    mnu.quydoi_vnd = decimal.Parse(quydoi_vnd);
                }

                if(!string.IsNullOrWhiteSpace(tk_quy))
                    mnu.tk_quy = int.Parse(tk_quy);

                mnu.tongcackhoan = 0;
                mnu.tongkhoanphi = 0;
                mnu.tienconlai = mnu.tongcackhoan - mnu.sotien + mnu.tongkhoanphi;
                mnu.md_trangthai_id = Helper.SOANTHAO;
                
                mnu.md_loaichungtu_id = md_loaichungtu_id;
                mnu.ispaymentin = true;

                mnu.mota = mota;
                mnu.hoatdong = true;
                mnu.nguoitao = UserUtils.getUser(context);
                mnu.nguoicapnhat = UserUtils.getUser(context);
                mnu.ngaytao = DateTime.Now;
                mnu.ngaycapnhat = DateTime.Now;

                if (add)
                    db.c_thuchis.InsertOnSubmit(mnu);
            }
            else
            {
                msg = "Không thể thêm giao dịch vào kỳ kế toán đã đóng!";
            }
        }
        catch (Exception e)
        {
            msg = e.Message;
        }

        return msg;
    }

    public static string bienDichLoaiChiTraKhac(string lct)
    {
        string kq = "";
        switch(lct)
        {
            case "0": kq = "chenhLechTyGiaDSBH"; break;
            case "1": kq = "dsoVTXuatChoBPCtyKhac"; break;
            case "2": kq = "tienBHXHBHLDNghiViec"; break;
            case "3": kq = "dienNuocRacCtyHaca"; break;
            case "4": kq = "nopTamUng"; break;
            case "5": kq = "tienPheLieu"; break;
            case "6": kq = "VTBBPLTNK"; break;
            case "7": kq = "chiPhiXuatKhau"; break;
            case "8": kq = "chiPhiHCNS"; break;
            case "9": kq = "luongNV"; break;
            case "10": kq = "luongCN"; break;
            case "11": kq = "phiCDBHXHNV"; break;
            case "12": kq = "phiCDBHXHCN"; break;
            case "13": kq = "thuongLeTetNV"; break;
            case "14": kq = "thuongLeTetCN"; break;
            case "15": kq = "chiTienMatKhac"; break;
            case "16": kq = "trich20PheLieu"; break;
            case "17": kq = "KhieuNai"; break;
            case "18": kq = "cuocGuiMauKiemDinh"; break;
        }

        return kq;
    }
}