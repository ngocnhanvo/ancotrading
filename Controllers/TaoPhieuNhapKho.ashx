<%@ WebHandler Language="C#" Class="TaoPhieuNhapKho" %>

using System;
using System.Web;
using System.Linq;
using System.Data.Linq;
using Newtonsoft.Json.Linq;
using NetServ.Net.Json;
using System.Collections.Generic;

public class TaoPhieuNhapKho : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string action = context.Request.Form["action"].ToString();
        if (action.Equals("TaoPhieuNhap"))
        {
            taoPhieuNhap(context);
        }
    }

    public void taoPhieuNhap(HttpContext context)
    {
        try
        {
            var db = new LinqDBDataContext();
            string jsondata = context.Request.Form["grid_form"].ToString();
            string so_cont = context.Request.Form["so_cont"].removeAllSpaceOrTrimText(true);
            string so_seal = context.Request.Form["so_seal"].removeAllSpaceOrTrimText(true);
            string loai_cont = context.Request.Form["loai_cont"].removeAllSpaceOrTrimText(true);
            var dsdh = new c_danhsachdathang();
            string dsdh_id = "", dh_id = "", diengiai = "";
            IList<JToken> tokenList = JToken.Parse(jsondata).ToList();

            List<phieuNhapKho> productList = new List<phieuNhapKho>();

            foreach (JToken token in tokenList)
            {
                productList.Add(Newtonsoft.Json.JsonConvert.DeserializeObject<phieuNhapKho>(token.ToString()));
            }

            string msg = "";
            // Kiểm tra số lượng nhập thực tế
            bool next = true;
            //foreach (var item in productList)
            //{
            //    //Nếu lớn hơn số lượng còn lại sẽ không được tiếp tục
            //    if (item.sl_nhapthucte > item.sl_conlai || item.sl_nhapthucte == 0)
            //    {
            //        msg = "Tạo phiếu nhập thất bại! Hãy kiểm tra lại số lượng nhập thực tế của sản phẩm lớn hơn số lượng còn lại hoặc bằng 0.";
            //        next = false;
            //    }
            //}

            if (productList.Where(s=>s.sl_nhapthucte > 0).Count() <= 0)
            {
                msg = "Tạo phiếu nhập thất bại! Không có dòng hàng.";
                next = false;
            }

            if (productList.Select(s=>s.c_danhsachdathang_id).Distinct().Count() > 1)
            {
                msg = "Tạo phiếu nhập thất bại! Không thể tạo phiếu nhập nhiều hơn một danh sách đặt hàng.";
                next = false;
            }

            // Nếu số lượng thực tế hợp lý
            if (next)
            {
                dsdh_id = productList.Select(s => s.c_danhsachdathang_id).FirstOrDefault();
                dh_id = productList.Select(s => s.c_donhang_id).FirstOrDefault();
                if(string.IsNullOrWhiteSpace(dh_id))
                {
                    dh_id = db.c_danhsachdathangs.Where(s => s.c_danhsachdathang_id == dsdh_id).Select(s => s.c_donhang_id).FirstOrDefault();
                }
                string id = ImportUtils.getNEWID();
                //tao 1 dong dat hang
                c_nhapxuat obj = new c_nhapxuat();
                obj.c_nhapxuat_id = id;
                obj.c_donhang_id = dh_id;
                int stt = 10;
                var c_dongdsdh_ids = new List<string>();
                var msgErrs = new List<string>();
                foreach (phieuNhapKho item in productList.Where(s=>s.sl_nhapthucte > 0).ToList())
                {
                    var sp = db.md_sanphams.Single(p => p.ma_sanpham.Equals(item.ma_sanpham));
                    if (sp == null)
                    {
                        msgErrs.Add($"{item.ma_sanpham} không tồn tại");
                    }
                    else
                    {
                        var ddh = db.c_dongdonhangs.Where(s => s.c_donhang_id == dh_id & s.md_sanpham_id == sp.md_sanpham_id).FirstOrDefault();
                        if(ddh == null)
                            msgErrs.Add($"{sp.ma_sanpham} không tồn tại trong đơn hàng");

                        var ddsdh = db.c_dongdsdhs.Where(s => s.c_danhsachdathang_id == dsdh_id & s.md_sanpham_id == sp.md_sanpham_id).FirstOrDefault();
                        if(ddsdh == null)
                            msgErrs.Add($"{sp.ma_sanpham} không tồn tại trong đơn đặt hàng");
                        else if(item.sl_nhapthucte > ddsdh.sl_conlai)
                            msgErrs.Add($"{sp.ma_sanpham} có số lượng nhập lớn hơn số lượng còn được nhập ({item.sl_nhapthucte.DropTrailingZeros()} > {ddsdh.sl_conlai.GetValueOrDefault(0).DropTrailingZeros()})");

                        var dvt = db.md_sanphams.Where(s => s.md_sanpham_id.Equals(sp.md_sanpham_id)).FirstOrDefault();
                        if(dvt == null)
                            msgErrs.Add($"{sp.ma_sanpham} không tồn tại đơn vị tính");

                        if (msgErrs.Count <= 0)
                        {
                            var sobj = new c_dongnhapxuat();
                            sobj.md_xuatban_id = item.md_xuatban_id;
                            sobj.c_dongnhapxuat_id = Helper.getNewId();
                            sobj.c_nhapxuat_id = id;

                            sobj.c_dongdonhang_id = ddh.c_dongdonhang_id;
                            sobj.c_dongdsdh_id = ddsdh.c_dongdsdh_id;
                            //dsdh_id = db.c_dongdsdhs.Single(s => s.c_dongdsdh_id.Equals(item.c_dongdsdh_id)).c_danhsachdathang_id;
                            //sobj. = db.c_donhangs.Single(o=>o.c_donhang_id.Equals(item.c_donhang_id)).sochungtu; 
                            sobj.md_sanpham_id = sp.md_sanpham_id;
                            sobj.mota_tiengviet = sp.mota_tiengviet;
                            sobj.md_donvitinh_id = dvt.md_donvitinhsanpham_id;
                            sobj.slphai_nhapxuat = ddh.soluong;
                            sobj.slthuc_nhapxuat = item.sl_nhapthucte;
                            sobj.sl_dathang = ddsdh.sl_dathang;
                            sobj.dongia = ddsdh.gianhap;
                            sobj.sl_inner = item.sl_inner;
                            sobj.dvt_inner = item.dvt_inner;
                            sobj.sl_outer = item.sl_outer;
                            sobj.dvt_outer = item.dvt_outer;
                            sobj.tenkien = item.tenkien;
                            sobj.sokien = item.sokien;
                            sobj.nw = item.nw;
                            sobj.gw = item.gw;
                            sobj.cbm = item.cbm;
                            sobj.l_inner = item.l_inner;
                            sobj.w_inner = item.w_inner;
                            sobj.h_inner = item.h_inner;
                            sobj.l_master = item.l_master;
                            sobj.w_master = item.w_master;
                            sobj.h_master = item.h_master;
                            sobj.hoatdong = true;
                            sobj.ngaytao = DateTime.Now;
                            sobj.ngaycapnhat = DateTime.Now;
                            sobj.nguoitao = UserUtils.getUser(context);
                            sobj.nguoicapnhat = UserUtils.getUser(context);
                            sobj.line = stt;
                            stt += 10;
                            db.c_dongnhapxuats.InsertOnSubmit(sobj);
                            c_dongdsdh_ids.Add(sobj.c_dongdsdh_id);
                        }
                    }
                }

                if (msgErrs.Count > 0)
                {
                    var styleErr = "style='color:red; padding:5px;'";
                    msg = $"<div {styleErr}>{string.Join($"</div><div {styleErr}>", msgErrs)}</div>";
                    context.Response.Write(msg);
                }
                else
                {
                    var count = db.c_dongnhapxuats.Where(s => s.c_nhapxuat_id != obj.c_nhapxuat_id & c_dongdsdh_ids.Contains(s.c_dongdsdh_id)).Count();
                    if (count == 0)
                    {
                        foreach (c_phidathang pdh in db.c_phidathangs.Where(s => s.c_danhsachdathang_id == dsdh_id))
                        {
                            string congtru = "";
                            if (pdh.isphicong == true)
                            {
                                congtru = "+";
                            }
                            else
                            {
                                congtru = "-";
                            }
                            diengiai += "Phí " + congtru + " " + pdh.sotien + " : " + pdh.mota + ";\n ";
                        }
                    }
                    else
                    {
                        diengiai = "";
                    }

                    md_sochungtu chungtu = db.md_sochungtus.Where(ct => ct.ten_sochungtu.Equals("Nhập kho")).FirstOrDefault();
                    var dh = db.c_donhangs.Single(so => so.c_donhang_id.Equals(obj.c_donhang_id));
                    obj.md_doitackinhdoanh_id = db.c_danhsachdathangs.Single(d => d.c_danhsachdathang_id.Equals(dsdh_id)).md_doitackinhdoanh_id;

                    obj.sophieu = chungtu.tiento + "/" + chungtu.so_duocgan + "/" + chungtu.hauto;
                    chungtu.so_duocgan = chungtu.so_duocgan + 1;
                    obj.socontainer = 1;
                    obj.container = so_cont;
                    obj.soseal = so_seal;
                    var cont = new DataAcess.md_loaicont();
                    var loaicont = cont.get().Where(s => s.ten == loai_cont).Select(s => s.ma).FirstOrDefault();
                    if (string.IsNullOrWhiteSpace(loai_cont))
                        obj.loaicont = dh.loai_cont;
                    else
                        obj.loaicont = loaicont;

                    md_kho kho = db.md_khos.Where(ct => !ct.md_kho_id.Equals("")).FirstOrDefault();

                    obj.md_kho_id = kho.md_kho_id;
                    obj.ngay_phieu = DateTime.Now;
                    obj.ngay_giaonhan = DateTime.Now;
                    obj.cr_invoice = false;
                    obj.cr_phieuxuat = false;
                    obj.mota = diengiai;
                    obj.nguoitao = UserUtils.getUser(context);
                    obj.nguoicapnhat = UserUtils.getUser(context);

                    obj.ngaytao = DateTime.Now;
                    obj.ngaycapnhat = DateTime.Now;
                    obj.hoatdong = true;
                    obj.md_loaichungtu_id = "NK";
                    obj.md_trangthai_id = "SOANTHAO";

                    db.c_nhapxuats.InsertOnSubmit(obj);
                    db.SubmitChanges();

                    String update = "update c_dongnhapxuat set hoatdong = 1 where c_nhapxuat_id = @id";
                    mdbc.ExcuteNonQuery(update, "@id", id);
                    context.Response.Write("Tạo phiếu xác nhận thành công!" + obj.sophieu);
                }
            }
            else {
                context.Response.Write(msg);
            }
        }
        catch (Exception e)
        {
            context.Response.Write(e.Message);
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}