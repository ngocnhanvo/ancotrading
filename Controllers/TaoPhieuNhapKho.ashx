<%@ WebHandler Language="C#" Class="TaoPhieuNhapKho" %>

using System;
using System.Web;
using System.Linq;
using System.Data.Linq;
using Newtonsoft.Json.Linq;
using NetServ.Net.Json;
using System.Collections.Generic;
using ExcelLibrary.SpreadSheet;

public class TaoPhieuNhapKho : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        string action = context.Request.Params["action"].ToString();
        if (action.Equals("TaoPhieuNhap"))
        {
            taoPhieuNhap(context);
        }
        else if (action.Equals("TaoPhieuNhapExcel"))
        {
            string file = upload(context);
            if (file.Substring(0, 4) != "false")
            {
                taoPhieuNhapExcel(context, file);
            }
            else
            {
                context.Response.Write(file);
            }
        }
    }

    public string upload(HttpContext context)
    {
        string msg = "";
        HttpFileCollection files = context.Request.Files;
        string path = ExcuteSignalRStatic.mapPathSignalR("~/FileUpload");
        if (files.Count > 0)
        {
            if (System.IO.Directory.Exists(path))
            {
                int j = files[0].FileName.LastIndexOf(".");
                string mime = files[0].FileName.Substring(j);
                msg = $"{path}/{Helper.getNewId()}{mime}";
                files[0].SaveAs(msg);

                if (mime != ".xls")
                {
                    ConvertXLSXToXLS.ConvertWorkbookXSSFToHSSF(msg);
                    System.IO.File.Delete(msg);
                    msg = msg.Replace(".xlsx", ".xls");
                }
            }
            else
            {
                msg = "false";
            }
        }
        else
        {
            msg = "false#2";
        }
        return msg;
    }

    public object getValue(Cell cell, bool layStr = false)
    {
        return cell == null ? "" : (layStr ? cell.StringValue : cell.Value);
    }

    public void taoPhieuNhapExcel(HttpContext context, string file)
    {
        string msg = "";
        var db = new LinqDBDataContext();
        var productList = new List<phieuNhapKho>();
        var wb = Workbook.Load(file);
        var ws = wb.Worksheets[0];
        var rows = ws.Cells;
        var row = rows.Rows[7];
        var ngayxuat = row.GetCell(1).Value;
        row = rows.Rows[8];
        var soPO = row.GetCell(1).StringValue;
        row = rows.Rows[9];
        var mancu = row.GetCell(1).Value;
        row = rows.Rows[10];
        var dsdhso = row.GetCell(1).StringValue;
        row = rows.Rows[11];
        var noigiaohang = row.GetCell(1).Value;
        row = rows.Rows[12];
        var tare = getValue(row.GetCell(1), true).ToString().ToNullableDecimal();
        row = rows.Rows[13];
        var mg = getValue(row.GetCell(1), true).ToString().ToNullableDecimal();
        row = rows.Rows[14];
        var vgm = getValue(row.GetCell(1), true).ToString().ToNullableDecimal();
        string soctn = "", soseal = "", loaictn = "";
        var dh = db.c_donhangs.Where(s => s.sochungtu == soPO).FirstOrDefault();

        var dsdh = db.c_danhsachdathangs.Where(s => s.sochungtu == dsdhso).FirstOrDefault();
        if(dsdh.md_trangthai_id != Helper.HIEULUC)
        {
            msg = $@"false#Đơn đặt hàng ""{dsdh.sochungtu}"" chưa hiệu lực";
            goto EndEventHandler;
        }

        var saveI = 17;
        int stt = 10;
        String id = ImportUtils.getNEWID();
        var c_dongdsdh_ids = new List<string>();
        for(var i = saveI; i < rows.Rows.Count; i++)
        {
            row = rows.Rows[i];
            int cell = 0;
            var ctn = getValue(row.GetCell(cell));
            cell++;
            var seal = getValue(row.GetCell(cell));
            cell++;
            var type = getValue(row.GetCell(cell));
            cell++;
            var msp = row.GetCell(cell).StringValue;
            cell++;
            var sl = getValue(row.GetCell(cell));
            //cell++;
            //var makhach = getValue(row.GetCell(cell));
            //cell++;
            //var mota = getValue(row.GetCell(cell));
            //cell++;
            //var slinner = getValue(row.GetCell(cell));
            //cell++;
            //var dvtinner = getValue(row.GetCell(cell));
            //cell++;
            //var slmaster = getValue(row.GetCell(cell));
            //cell++;
            //var dvtmaster = getValue(row.GetCell(cell));
            //cell++;
            //var nop = getValue(row.GetCell(cell));
            //cell++;
            //var nw = getValue(row.GetCell(cell));
            //cell++;
            //var gw = getValue(row.GetCell(cell));
            //cell++;
            //var cbm = getValue(row.GetCell(cell));
            //cell++;
            //var l1 = getValue(row.GetCell(cell));
            //cell++;
            //var w1 = getValue(row.GetCell(cell));
            //cell++;
            //var h1 = getValue(row.GetCell(cell));
            //cell++;
            //var l2 = getValue(row.GetCell(cell));
            //cell++;
            //var w2 = getValue(row.GetCell(cell));
            //cell++;
            //var h2 = getValue(row.GetCell(cell));

            if(msp.ToLower().Contains("tổng cộng"))
            {
                saveI = i;
                break;
            }

            if(i == saveI)
            {
                soctn = ctn.ToString();
                soseal = seal.ToString();
                loaictn = type.ToString();
            }
            var sp = db.md_sanphams.Where(s => s.ma_sanpham == msp).FirstOrDefault();
            var ddh = db.c_dongdonhangs.Where(s => s.c_donhang_id == dh.c_donhang_id & s.md_sanpham_id == sp.md_sanpham_id).FirstOrDefault();
            var ddsdh = db.c_dongdsdhs.Where(s => s.c_danhsachdathang_id == dsdh.c_danhsachdathang_id & s.md_sanpham_id == sp.md_sanpham_id).FirstOrDefault();
            var sobj = new c_dongnhapxuat();
            sobj.c_dongnhapxuat_id = Helper.getNewId();
            sobj.c_nhapxuat_id = id;
            sobj.c_dongdonhang_id = ddh.c_dongdonhang_id;
            sobj.c_dongdsdh_id = ddsdh.c_dongdsdh_id;
            sobj.md_sanpham_id = sp.md_sanpham_id;
            // lấy mô tả của sản phẩm
            sobj.mota_tiengviet = sp.mota_tiengviet;

            sobj.md_donvitinh_id = sp.md_donvitinhsanpham_id;
            sobj.slphai_nhapxuat = ddsdh.sl_dathang;
            sobj.slthuc_nhapxuat = sl.ToString().ToNullableDecimal();
            sobj.sl_dathang = ddsdh.sl_dathang;
            sobj.dongia = ddsdh.gianhap;

            sobj.hoatdong = true;
            sobj.ngaytao = DateTime.Now;
            sobj.ngaycapnhat = DateTime.Now;
            sobj.nguoitao = UserUtils.getUser(context);
            sobj.nguoicapnhat = UserUtils.getUser(context);
            sobj.line = stt;
            stt += 10;
            db.c_dongnhapxuats.InsertOnSubmit(sobj);
            c_dongdsdh_ids.Add(sobj.c_dongdonhang_id);
        }

        row = rows.Rows[saveI+3];
        var ddhh = getValue(row.GetCell(1));
        row = rows.Rows[saveI+5];
        var chdk = getValue(row.GetCell(1));

        var count = db.c_dongnhapxuats.Where(s => s.c_nhapxuat_id != id & c_dongdsdh_ids.Contains(s.c_dongdsdh_id)).Count();
        string diengiai = "";
        if (count == 0)
        {
            foreach(var pdh in db.c_phidathangs.Where(s=> s.c_danhsachdathang_id == dsdh.c_danhsachdathang_id))
            {
                string congtru = "";
                if(pdh.isphicong == true)
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
        var obj = new c_nhapxuat();
        obj.c_nhapxuat_id = id;
        obj.c_donhang_id = dh.c_donhang_id;
        obj.md_doitackinhdoanh_id = dsdh.md_doitackinhdoanh_id;
        obj.sophieu = $"{chungtu.tiento}/{chungtu.so_duocgan}/{chungtu.hauto}";
        chungtu.so_duocgan = chungtu.so_duocgan + 1;
        obj.socontainer = 1;
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
        obj.container = soctn;
        obj.soseal = soseal;
        obj.loaicont = string.IsNullOrWhiteSpace(loaictn) ? dh.loai_cont : loaictn;
        obj.tare = tare;
        obj.mg = mg;
        obj.vgm = vgm;
        obj.md_trangthai_id = Helper.SOANTHAO;
        db.c_nhapxuats.InsertOnSubmit(obj);
        db.SubmitChanges();

        String update = "update c_dongnhapxuat set hoatdong = 1 where c_nhapxuat_id = @id";
        mdbc.ExcuteNonQuery(update, "@id", id);
        msg = $"Tạo phiếu nhập kho thành công! {obj.sophieu}";

        EndEventHandler:;

        context.Response.Write(msg);
    }

    public void taoPhieuNhap(HttpContext context)
    {
        //try
        {
            LinqDBDataContext db = new LinqDBDataContext();
            string jsondata = context.Request.Form["grid_form"].ToString();
            var dsdh = new c_danhsachdathang();
            string dsdh_id = "", diengiai = "";
            IList<JToken> tokenList = JToken.Parse(jsondata).ToList();

            List<phieuNhapKho> productList = new List<phieuNhapKho>();

            foreach (JToken token in tokenList)
            {
                productList.Add(Newtonsoft.Json.JsonConvert.DeserializeObject<phieuNhapKho>(token.ToString()));
            }

            string msg = "";
            // Kiểm tra số lượng nhập thực tế
            bool next = true;
            foreach (var item in productList)
            {
                //Nếu lớn hơn số lượng còn lại sẽ không được tiếp tục
                if (item.sl_nhapthucte > item.sl_conlai || item.sl_nhapthucte == 0)
                {
                    msg = "Tạo phiếu nhập thất bại! Hãy kiểm tra lại số lượng nhập thực tế của sản phẩm lớn hơn số lượng còn lại hoặc bằng 0.";
                    next = false;
                }
            }

            List<string> c_danhsachdathang_ids = new List<string>();
            foreach (var item in productList)
            {
                c_danhsachdathang_ids.Add(item.c_danhsachdathang_id);
            }

            if (c_danhsachdathang_ids.Distinct().Count() > 1)
            {
                msg = "Tạo phiếu nhập thất bại! Không thể tạo phiếu nhập nhiều hơn một danh sách đặt hàng.";
                next = false;
            }

            // Nếu số lượng thực tế hợp lý
            if (next)
            {
                if (productList.Count > 0)
                {
                    String id = ImportUtils.getNEWID();
                    //tao 1 dong dat hang
                    c_nhapxuat obj = new c_nhapxuat();
                    obj.c_nhapxuat_id = id;
                    int stt = 10;
                    var c_dongdsdh_ids = new System.Collections.Generic.List<string>();
                    foreach (phieuNhapKho item in productList)
                    {
                        if (item.sl_nhapthucte > 0)
                        {
                            c_dongnhapxuat sobj = new c_dongnhapxuat();
                            obj.c_donhang_id = item.c_donhang_id;
                            sobj.c_dongnhapxuat_id = Helper.getNewId();
                            sobj.c_nhapxuat_id = id;
                            sobj.c_dongdonhang_id = item.c_dongdonhang_id;
                            sobj.c_dongdsdh_id = item.c_dongdsdh_id;
                            dsdh_id = db.c_dongdsdhs.Single(s => s.c_dongdsdh_id.Equals(item.c_dongdsdh_id)).c_danhsachdathang_id;
                            //sobj. = db.c_donhangs.Single(o=>o.c_donhang_id.Equals(item.c_donhang_id)).sochungtu; 
                            sobj.md_sanpham_id = item.md_sanpham_id;

                            // lấy mô tả của sản phẩm
                            md_sanpham sp = db.md_sanphams.Single(p => p.md_sanpham_id.Equals(item.md_sanpham_id));
                            sobj.mota_tiengviet = sp.mota_tiengviet;

                            sobj.md_donvitinh_id = db.md_sanphams.Single(s => s.md_sanpham_id.Equals(item.md_sanpham_id)).md_donvitinhsanpham_id;
                            sobj.slphai_nhapxuat = item.sl_po;
                            sobj.slthuc_nhapxuat = item.sl_nhapthucte;
                            sobj.sl_dathang = item.sl_dathang;
                            sobj.dongia = db.c_dongdsdhs.Single(ddh => ddh.c_dongdsdh_id.Equals(item.c_dongdsdh_id)).gianhap;

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

                    //string sqlCount = @"select count(*) from c_nhapxuat where md_loaichungtu_id = 'NK' and c_donhang_id = '" + obj.c_donhang_id +"'";
                    //int count = (int)mdbc.ExecuteScalar(sqlCount);
                    var count = db.c_dongnhapxuats.Where(s => s.c_nhapxuat_id != obj.c_nhapxuat_id & c_dongdsdh_ids.Contains(s.c_dongdsdh_id)).Count();
                    if (count == 0)
                    {
                        foreach(c_phidathang pdh in db.c_phidathangs.Where(s=> s.c_danhsachdathang_id == dsdh_id))
                        {
                            string congtru = "";
                            if(pdh.isphicong == true)
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
                    obj.loaicont = dh.loai_cont;

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
        //catch (Exception e)
        //{
        //     context.Response.Write(e.Message);
        //}
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}