<%@ WebHandler Language="C#" Class="CreateQuotationFromExcel" %>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using ExcelLibrary.SpreadSheet;

public class CreateQuotationFromExcel : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();
    string id = Guid.NewGuid().ToString().Replace("-", "").ToLower();
    string filePath = "", filenameLC = "";
    List<c_chitietbaogia> lstStr = new List<c_chitietbaogia>();
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.QueryString["oper"];
        switch (oper)
        {
            default:
                this.exec(context);
                break;
        }
    }

    public string NewId(){
        return Guid.NewGuid().ToString().Replace("-", "").ToLower();
    }

    public void exec(HttpContext context)
    {
        string msg = "";
        try
        {
            string khachhang_v = context.Request.Form["khachhang_v"];
            string ngaybaogia_v = context.Request.Form["ngaybaogia_v"];
            string shipmenttime = context.Request.Form["shipmenttime"];
            string ngayhethan_v = context.Request.Form["ngayhethan_v"];
            string ptrongluong_v = context.Request.Form["ptrongluong_v"];
            string pdongtien_v = context.Request.Form["pdongtien_v"];
            string pkichthuoc_v = context.Request.Form["pkichthuoc_v"];
            string gia_db_str = context.Request.Form["gia_db"];
            string chkPBGCu_str = context.Request.Form["chkPBGCu"];
            string phienbangiacu = context.Request.Form["phienbangiacu"];
            string cangbien = context.Request.Form["cangbien"];
            HttpFileCollection files = context.Request.Files;
            if (files.Count > 0)
            {
                filenameLC = files[0].FileName;
                filePath = context.Server.MapPath("../../VNN_Files/" + id + files[0].FileName);
                files[0].SaveAs(filePath);
            }
            else
            {
                msg = "Không tìm thấy tập tin.";
            }

            bool gia_db = false, chkPBGCu = false;
            if (chkPBGCu_str.Equals("on") || chkPBGCu_str.Equals("true"))
            { chkPBGCu = true; }
            if (gia_db_str.Equals("on") || gia_db_str.Equals("true"))
            { gia_db = true; }

            try
            {
                if (String.IsNullOrEmpty(msg))
                {
                    #region add c_baogia
                    String sochungtu = jqGridHelper.Utils.taoChungTuQO(khachhang_v, 1, DateTime.ParseExact(ngaybaogia_v, "dd/MM/yyyy", null).Year.ToString());
                    c_baogia mnu = new c_baogia
                    {
                        c_baogia_id = id,
                        sobaogia = sochungtu,
                        md_doitackinhdoanh_id = khachhang_v,
                        shipmenttime = int.Parse(shipmenttime),
                        ngaybaogia = DateTime.ParseExact(ngaybaogia_v, "dd/MM/yyyy", null),
                        ngayhethan = DateTime.ParseExact(ngayhethan_v, "dd/MM/yyyy", null),
                        md_trongluong_id = ptrongluong_v,
                        md_cangbien_id = cangbien,
                        md_dongtien_id = pdongtien_v,
                        md_kichthuoc_id = pkichthuoc_v,
                        totalcbm = 0,
                        totalcbf = 0,
                        totalquo = 0,
                        isform = true,
                        moq_item_color = "",
                        md_trangthai_id = "SOANTHAO",
                        chkPBGCu = chkPBGCu,
                        phienbangiacu = phienbangiacu,

                        nguoitao = UserUtils.getUser(context),
                        nguoicapnhat = UserUtils.getUser(context),
                        mota = "",
                        hoatdong = true,
                        gia_db = gia_db,
                        ngaytao = DateTime.Now,
                        ngaycapnhat = DateTime.Now
                    };

                    if (mnu.ngaybaogia >= mnu.ngayhethan)
                    {
                        msg = "Ngày báo giá không đuợc lớn hơn ngày hết hạn!";
                    }
                    else if (mnu.md_doitackinhdoanh_id == "c010dd297f3ee5797e426176e8685b2c")
                    {
                        msg = "Khách Hàng: Không được bỏ trống!";
                    }
                    else if (chkPBGCu == true & String.IsNullOrEmpty(phienbangiacu))
                    {
                        msg = "\"Phiên bảng giá cũ\" không thể bỏ trống.";
                    }

                    md_doitackinhdoanh doitac = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(mnu.md_doitackinhdoanh_id));
                    md_banggia bga = db.md_banggias.Where(s => s.ten_banggia.Contains(doitac.ma_dtkd + "-FOB")).FirstOrDefault();

                    if (bga == null & gia_db == true)
                    {
                        msg = "Khách hàng " + doitac.ma_dtkd + " không có bảng giá đặc biệt";
                    }

                    if (String.IsNullOrEmpty(msg))
                    {
                        db.c_baogias.InsertOnSubmit(mnu);
                        db.SubmitChanges();
                        var result = ReadExCel(context);
                        msg = result["msg"];
                        var ok = result["ok"] == "true";
                        if (ok)
                        {
                            db.SubmitChanges();
                            msg += string.Format(@"<div style='color:blue'>Đã tạo thành công báo giá ""{0}""</div>", sochungtu);
                        }
                        else
                        {
                            db.c_baogias.DeleteOnSubmit(mnu);
                            db.SubmitChanges();
                        }
                    }
                    #endregion
                }
            }
            catch (Exception ex)
            {
                msg = ex.Message;
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        context.Response.Write(msg);
    }

    public Dictionary<string, string> ReadExCel(HttpContext context) {
        var result = new Dictionary<string, string>();
        string msg = "";
        bool ok = false;
        try {
            int j = filePath.LastIndexOf(".");
            if(filePath.Substring(j) != ".xls") {
                filePath = ConvertXLSXToXLS.ConvertWorkbookXSSFToHSSF(filePath);
            }
            Workbook wb = Workbook.Load(filePath);
            Worksheet ws = wb.Worksheets[0];
            msg = this.NewFromCellCollection(context, ws.Cells);
            if (msg.StartsWith("false#"))
            {
                ok = false;
                msg = msg.Substring(6);
            }
            else
            {
                ok = true;
            }
        }
        catch {
            msg = "Không tìm thấy tập tin.";
        }
        result["msg"] = msg;
        result["ok"] = ok.ToString().ToLower();
        return result;
    }


    public string NewFromCellCollection(HttpContext context, CellCollection cellCollection)
    {
        int totalCount = cellCollection.Rows.Count;
        int rowErr = 0, rowAdd = 0;
        string msg = "";
        for (int i = 0; i < totalCount; i++)
        {
            string khachhang_id = context.Request.Form["khachhang_v"];
            string ma_sanpham = "", docquyen = "";
            decimal soluong = 0, giafob = 0;
            try
            {
                Row row = cellCollection.Rows[i];
                ma_sanpham = row.GetCell(0).Value.ToString();
                try { soluong = decimal.Parse(row.GetCell(1).Value.ToString()); } catch { }

                ma_sanpham = ma_sanpham.Replace(" ", "");
                md_sanpham sp = db.md_sanphams.FirstOrDefault(s => s.ma_sanpham == ma_sanpham);
                if (sp != null)
                {
                    if (!new string[] { "NHD", "HHT", "SOANTHAO"}.Contains(sp.trangthai))
                    {
                        try
                        {
                            var itemJS = UserUtils.get_giasanpham(context, id, sp.md_sanpham_id, db);
                            giafob = decimal.Parse(itemJS["gia"].ToString());
                        }
                        catch { }

                        if (giafob > -1)
                        {
                            docquyen = check_hanghoadocquyen(sp.md_sanpham_id, khachhang_id);

                            #region them dong don hang
                            var donggoi = (from a in db.md_donggoisanphams
                                           join b in db.md_donggois on a.md_donggoi_id equals b.md_donggoi_id
                                           where a.md_sanpham_id == sp.md_sanpham_id & a.macdinh == true
                                           select new
                                           {
                                               b.md_donggoi_id,
                                               b.doigia_donggoi,
                                               b.ghichu_vachngan,
                                               b.sl_inner,
                                               b.l1,
                                               b.w1,
                                               b.h1,
                                               b.sl_outer,
                                               b.l2_mix,
                                               b.w2_mix,
                                               b.h2_mix,
                                               b.v2,
                                               b.vd,
                                               b.vn,
                                               b.vl,
                                               b.soluonggoi_ctn
                                           }).FirstOrDefault();

                            //kiem tra hang hoa doc quyen
                            int count_dq = (from hdq in db.md_hanghoadocquyens
                                            where !hdq.md_doitackinhdoanh_id.Equals(khachhang_id) && hdq.md_sanpham_id.Equals(sp.md_sanpham_id)
                                            select new { hdq.md_hanghoadocquyen_id }).Count();
                            int count_dqdt = (from hdq in db.md_hanghoadocquyens
                                              where hdq.md_doitackinhdoanh_id.Equals(khachhang_id) && hdq.md_sanpham_id.Equals(sp.md_sanpham_id)
                                              select new { hdq.md_hanghoadocquyen_id }).Count();

                            string trangthai = "BT", mota = "";
                            if (count_dq > 0 && count_dqdt == 0 && donggoi.doigia_donggoi == true)
                            {
                                trangthai = "DGDGDQ";
                                mota += "DGDG & DQ";
                            }
                            else if (count_dq > 0 && count_dqdt == 0)
                            {
                                trangthai = "DQ";
                                mota += "DGDG & DQ";
                            }
                            else if (donggoi.doigia_donggoi == true)
                            {
                                trangthai = "DGDG";
                            }
                            else
                            {
                                trangthai = "BT";
                            }

                            c_chitietbaogia mnu = new c_chitietbaogia
                            {
                                c_chitietbaogia_id = NewId(),
                                c_baogia_id = id,
                                md_sanpham_id = sp.md_sanpham_id,
                                ma_sanpham_khach = "",
                                md_cangbien_id = sp.md_cangbien_id,
                                mota_tienganh = sp.mota_tienganh,
                                mota_tiengviet = sp.mota_tiengviet,
                                ghichu_vachngan = donggoi.ghichu_vachngan,
                                sothutu = i * 10,
                                giafob = giafob,
                                soluong = soluong,
                                md_donggoi_id = donggoi.md_donggoi_id,
                                sl_inner = donggoi.sl_inner,
                                l1 = donggoi.l1,
                                w1 = donggoi.w1,
                                h1 = donggoi.h1,
                                sl_outer = donggoi.sl_outer,
                                l2 = donggoi.l2_mix,
                                w2 = donggoi.w2_mix,
                                h2 = donggoi.h2_mix,
                                v2 = donggoi.v2,
                                vd = donggoi.vd,
                                vn = donggoi.vn,
                                vl = donggoi.vl,
                                sl_cont = donggoi.soluonggoi_ctn,
                                ghichu = "",
                                docquyen = docquyen,
                                mota = "",
                                hoatdong = true,
                                ngaytao = DateTime.Now,
                                ngaycapnhat = DateTime.Now,
                                nguoitao = UserUtils.getUser(context),
                                nguoicapnhat = UserUtils.getUser(context),
                                trangthai = trangthai
                            };

                            db.c_chitietbaogias.InsertOnSubmit(mnu);
                            rowAdd++;
                            #endregion

                        }
                        else
                        {
                            msg += string.Format(@"<div style='color:red'>Sản phẩm ""{0}"" chưa có giá FOB</div>", ma_sanpham);
                        }
                    }
                    else
                    {
                        var textTT = sp.trangthai == "SOANTHAO" ? "Soạn Thảo" : (sp.trangthai == "NHD" ? "Ngưng hoạt động" : "Hàng Hóa Tạm");
                        msg += string.Format(@"<div style='color:red'>Sản phẩm ""{0}"" có trạng thái ""{1}"" không cho phép import</div>", ma_sanpham, textTT);
                    }
                }
                else
                {
                    msg += string.Format(@"<div style='color:red'>Không tìm thấy sản phẩm có mã ""{0}""</div>", ma_sanpham);
                }
            }
            catch
            {
                rowErr++;
                if (rowErr <= 500)
                    totalCount += 1;
            }
        }

        if (rowAdd == 0)
            msg = "false#" + msg;

        return msg;
    }

    public string check_hanghoadocquyen(string md_sanpham_id, string md_doitackinhdoanh_id) {
        string msg = "";
        md_hanghoadocquyen hhdq = db.md_hanghoadocquyens.FirstOrDefault(s=>s.md_sanpham_id == md_sanpham_id);
        if(hhdq != null) {
            md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(s=>s.md_doitackinhdoanh_id == hhdq.md_doitackinhdoanh_id);
            if(dtkd != null) {
                if(dtkd.md_doitackinhdoanh_id != md_doitackinhdoanh_id) {
                    md_quocgia quocgia = db.md_quocgias.FirstOrDefault(s=>s.md_quocgia_id == dtkd.md_quocgia_id);
                    string ten_qg = "";
                    if(quocgia != null) {
                        ten_qg = quocgia.ten_quocgia;
                    }
                    //msg = "Mã hàng độc quyền cho khách "+ dtkd.ma_dtkd +" ở thị trường "+ ten_qg +". Bạn có muốn mở bán cho khách hàng của bạn không ? YES/NO";
                    msg = "Mã hàng độc quyền cho khách "+ dtkd.ma_dtkd +" ở thị trường "+ hhdq.mota +".\n Bạn có muốn mở bán cho khách hàng của bạn không ? YES/NO";
                }
            }
        }
        return msg;
    }

    public bool IsReusable
    {
        get { return false; }
    }
}