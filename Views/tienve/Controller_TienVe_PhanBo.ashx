<%@ WebHandler Language="C#" Class="Controller_TienVe_PhanBo" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;

public class Controller_TienVe_PhanBo : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.Params["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "loadGrid":
                this.loadGrid(context);
                break;
            case "getAmount":
                this.getAmount(context);
                break;
            case "createReceipt":
                this.createReceipt(context);
                break;
            case "createPayment":
                this.createPayment(context);
                break;
            case "lammoiTienPhanBo":
                this.lammoiTienPhanBo(context);
                break;
            case "layPhi":
                this.layPhi(context);
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

    public decimal layPhi(HttpContext context, string id = "", kt_tienve tv = null, decimal tiencoc_thanhtoan = 0)
    {
        bool sg = false;
        decimal phi = 0, ptv = 0, tktv = 0;
        if(tv == null)
        {
            sg = true;
            id = context.Request.Form["id"].removeAllSpaceOrTrimText(false);
            tiencoc_thanhtoan = context.Request.Form["tctt"].removeAllSpaceOrTrimText(false).ToNullableDecimal().GetValueOrDefault(0);
            tv = db.kt_tienves.Where(s => s.kt_tienve_id == id).FirstOrDefault();
        }

        if (tv != null)
        {
            ptv = tv.phi.GetValueOrDefault(0);
            tktv = tv.tienkhach.GetValueOrDefault(0);
            if(tktv > 0)
                phi = Math.Round(tiencoc_thanhtoan * ptv / tktv, 2, MidpointRounding.AwayFromZero);
        }

        if(sg)
        {
            var rs = new { phi, ptv, tktv };
            context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(rs));
        }

        return phi;
    }

    public void lammoiTienPhanBo(HttpContext context, string id = "")
    {
        bool sg = false;
        if(string.IsNullOrWhiteSpace(id))
        {
            sg = true;
            id = context.Request.Form["id"].removeAllSpaceOrTrimText(false);
        }
        var kttvs = db.kt_tienve_phanbos.Where(s => s.kt_tienve_id == id & s.loaihd == "PO").ToList();
        foreach(var cttv in kttvs)
        {
            var dhid = db.c_donhangs.Where(s => s.sochungtu == cttv.sctlienquan).Select(s=>s.c_donhang_id).FirstOrDefault();

            var invids = db.c_dongpklinvs.Where(s => s.c_donhang_id == dhid).Select(s => s.c_packinginvoice_id).Distinct().ToList();

            var cttcs = db.c_dongphanboinvs.Where(s => invids.Contains(s.c_packinginvoice_id)).ToList();

            cttv.tpb_inv = cttcs.Sum(s => s.sotienphanbo.GetValueOrDefault(0));
        }

        db.SubmitChanges();

        if(sg)
        {
            context.Response.Write("Cập nhập tiền phân bổ thành công");
        }
    }

    public void createPayment(HttpContext context)
    {
        string msg = "";
        var msgs = new List<string>();
        string id = context.Request.Form["id"];
        try
        {
            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == id).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai != Helper.HIEULUC)
            {
                msg = $@"Dòng ""tiền về"" phải ở trạng thái Hiệu Lực";
                goto EndEventHandler;
            }

            var cttvs = db.kt_tienve_phanbos.Where(s => s.kt_tienve_id == tv.kt_tienve_id & s.trangthai == Helper.SOANTHAO & s.loaihd == "CK").ToList();

            string loai = context.Request.Form["loai"];
            var sochungtu = db.md_sochungtus.Single(s => s.tiento.Equals("PC"));
            string sphieu = sochungtu.tiento + "/" + sochungtu.so_duocgan + "/" + sochungtu.hauto;
            bool check = (bool)mdbc.ExecuteScalarProcedure("p_kiemtragiaodich", "@date", (DateTime.ParseExact(context.Request.Form["ngaylapphieu"], "dd/MM/yyyy", null)).ToString("MM/dd/yyyy"),"@md_doitackinhdoanh_id", tv.dtkd_id);
            if (!check.Equals(true))
            {
                msg = "Không thể thêm giao dịch vào kỳ kế toán đã đóng!";
                goto EndEventHandler;
            }
            var mnu = new c_thuchi();
            mnu.c_thuchi_id = Helper.getNewId();
            mnu.sophieu = sphieu;
            mnu.loai = loai;
            mnu.md_doitackinhdoanh_id = tv.dtkd_id;
            mnu.ngaylapphieu = DateTime.ParseExact(context.Request.Form["ngaylapphieu"], "dd/MM/yyyy", null);
            mnu.nguoi_giaonop = context.Request.Form["nguoi_giaonop"];
            mnu.ngay_giaonop = DateTime.ParseExact(context.Request.Form["ngay_giaonop"], "dd/MM/yyyy", null);
            mnu.sotien = cttvs.Sum(s => s.sotien.GetValueOrDefault(0));
            mnu.md_dongtien_id = context.Request.Form["md_dongtien_id"];
            mnu.tygia = decimal.Parse(context.Request.Form["tygia"]);
            mnu.lydo = context.Request.Form["lydo"];
            mnu.sochungtu = context.Request.Form["sochungtu"];
            mnu.quydoi_vnd = context.Request.Form["quydoi_vnd"].removeAllSpaceOrTrimText(false).ToNullableDecimal();
            mnu.tk_quy = context.Request.Form["tk_quy"].removeAllSpaceOrTrimText(false).ToNullableInt();
            mnu.tongcackhoan = 0;
            mnu.tongkhoanphi = 0;
            mnu.tienconlai = mnu.tongcackhoan - mnu.sotien + mnu.tongkhoanphi;
            mnu.md_trangthai_id = Helper.SOANTHAO;
            string md_loaichungtu_id = db.md_loaichungtus.Where(s => s.kieu_doituong == "PC").Select(s => s.md_loaichungtu_id).FirstOrDefault();
            mnu.md_loaichungtu_id = md_loaichungtu_id;
            mnu.ispaymentin = false;
            mnu.mota = context.Request.Form["mota"];
            mnu.hoatdong = true;
            mnu.kt_tienve_id = tv.kt_tienve_id;
            mnu.nguoitao = UserUtils.getUser(context);
            mnu.nguoicapnhat = UserUtils.getUser(context);
            mnu.ngaytao = DateTime.Now;
            mnu.ngaycapnhat = DateTime.Now;
            db.c_thuchis.InsertOnSubmit(mnu);
            sochungtu.so_duocgan = sochungtu.so_duocgan + sochungtu.buocnhay;

            if (tv.conlai <= 0)
                tv.trangthai = Helper.KETTHUC;
            db.SubmitChanges();

            foreach(var cttv in cttvs)
            {
                cttv.phieuthu_id = mnu.c_thuchi_id;
                cttv.trangthai = Helper.HIEULUC;
                var sotien = cttv.sotien.GetValueOrDefault(0);
                var poID = db.c_donhangs.Where(s => s.sochungtu == cttv.sctlienquan).Select(s => s.c_donhang_id).FirstOrDefault();
                var invID = db.c_packinginvoices.Where(s => s.so_pkl == cttv.sctlienquan).Select(s => s.c_packinginvoice_id).FirstOrDefault();

                string loai2 = "CK";
                string tc = "false";
                string tiencong = "0";
                string c_thuchi_id = mnu.c_thuchi_id;
                string ids = "";
                string values = "";
                string md_doitackinhdoanh_id = "";
                string ctd_ngaychi = DateTime.Now.ToString("dd/MM/yyyy");
                string thueStr = "0";
                string ltt = "IN";
                string loaiphieu2 = "";
                string tkno = "331";
                string tkco = "112";
                string diengiai = "";
                string c_donhang_id = "";
                string c_packinginvoice_id = invID;
                string mota = "";
                string sotien2 = sotien.ToString();
                string c_nhapxuat_id = "";
                string sotaikhoan = "";
                string nganhang = "";
                string msg2 = Helper.themChiTietUyNhiemChi(context, db,
                    loai2, tc, tiencong, c_thuchi_id, ids, values, md_doitackinhdoanh_id,
                    ctd_ngaychi, thueStr, ltt, loaiphieu2, tkno, tkco, diengiai, c_donhang_id,
                    c_packinginvoice_id, mota, sotien2, c_nhapxuat_id, sotaikhoan, nganhang, cttv.kt_tienve_phanbo_id
                    );

                db.SubmitChanges();
                msgs.Add(msg2);
            }

            msgs = msgs.Where(s => !string.IsNullOrWhiteSpace(s)).ToList();
            if(msgs.Count > 0)
                msg = string.Join("<br>", msgs);
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            context.Response.Write($@"<div style='color:red' class='error'>{msg}</div>");
        else
            context.Response.Write($@"<div style='color:blue'>Tạo phiếu chi thành công</div>");
    }

    public void createReceipt(HttpContext context)
    {
        string msg = "";
        var msgs = new List<string>();
        string id = context.Request.Form["id"];
        try
        {
            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == id).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai != Helper.HIEULUC)
            {
                msg = $@"Dòng ""tiền về"" phải ở trạng thái Hiệu Lực";
                goto EndEventHandler;
            }

            var cttvs = db.kt_tienve_phanbos.Where(s => s.kt_tienve_id == tv.kt_tienve_id & s.trangthai == Helper.SOANTHAO & s.loaihd != "CK").ToList();

            string loai = context.Request.Form["loai"];
            var sochungtu = db.md_sochungtus.Single(s => s.tiento.Equals("PT"));
            string sphieu = sochungtu.tiento + "/" + sochungtu.so_duocgan + "/" + sochungtu.hauto;
            bool check = (bool)mdbc.ExecuteScalarProcedure("p_kiemtragiaodich", "@date", (DateTime.ParseExact(context.Request.Form["ngaylapphieu"], "dd/MM/yyyy", null)).ToString("MM/dd/yyyy"),"@md_doitackinhdoanh_id", tv.dtkd_id);
            if (!check.Equals(true))
            {
                msg = "Không thể thêm giao dịch vào kỳ kế toán đã đóng!";
                goto EndEventHandler;
            }
            var mnu = new c_thuchi();
            mnu.c_thuchi_id = Helper.getNewId();
            mnu.sophieu = sphieu;
            mnu.loai = loai;
            mnu.md_doitackinhdoanh_id = tv.dtkd_id;
            mnu.ngaylapphieu = DateTime.ParseExact(context.Request.Form["ngaylapphieu"], "dd/MM/yyyy", null);
            mnu.nguoi_giaonop = context.Request.Form["nguoi_giaonop"];
            mnu.ngay_giaonop = DateTime.ParseExact(context.Request.Form["ngay_giaonop"], "dd/MM/yyyy", null);
            mnu.sotien = cttvs.Sum(s => s.sotien.GetValueOrDefault(0));
            mnu.md_dongtien_id = context.Request.Form["md_dongtien_id"];
            mnu.tygia = decimal.Parse(context.Request.Form["tygia"]);
            mnu.lydo = context.Request.Form["lydo"];
            mnu.sochungtu = context.Request.Form["sochungtu"];
            mnu.quydoi_vnd = context.Request.Form["quydoi_vnd"].removeAllSpaceOrTrimText(false).ToNullableDecimal();
            mnu.tk_quy = context.Request.Form["tk_quy"].removeAllSpaceOrTrimText(false).ToNullableInt();
            mnu.tongcackhoan = 0;
            mnu.tongkhoanphi = 0;
            mnu.tienconlai = mnu.tongcackhoan - mnu.sotien + mnu.tongkhoanphi;
            mnu.md_trangthai_id = Helper.SOANTHAO;
            string md_loaichungtu_id = db.md_loaichungtus.Where(s => s.kieu_doituong == "PT").Select(s => s.md_loaichungtu_id).FirstOrDefault();
            mnu.md_loaichungtu_id = md_loaichungtu_id;
            mnu.ispaymentin = true;
            mnu.mota = context.Request.Form["mota"];
            mnu.hoatdong = true;
            mnu.kt_tienve_id = tv.kt_tienve_id;
            mnu.nguoitao = UserUtils.getUser(context);
            mnu.nguoicapnhat = UserUtils.getUser(context);
            mnu.ngaytao = DateTime.Now;
            mnu.ngaycapnhat = DateTime.Now;
            db.c_thuchis.InsertOnSubmit(mnu);
            sochungtu.so_duocgan = sochungtu.so_duocgan + sochungtu.buocnhay;

            if (tv.conlai <= 0)
            {
                tv.trangthai = Helper.KETTHUC;
                //tv.mota = tv.mota + Public.ketThucTienVe(db, tv.kt_tienve_id);
            }
            db.SubmitChanges();

            foreach(var cttv in cttvs)
            {
                cttv.phieuthu_id = mnu.c_thuchi_id;
                cttv.trangthai = Helper.HIEULUC;

                var istiencoc = cttv.loaihd == "PO" ? "true" : "false";
                var sotien = cttv.sotien.GetValueOrDefault(0);
                var poID = db.c_donhangs.Where(s => s.sochungtu == cttv.sctlienquan).Select(s => s.c_donhang_id).FirstOrDefault();
                var invID = db.c_packinginvoices.Where(s => s.so_pkl == cttv.sctlienquan).Select(s => s.c_packinginvoice_id).FirstOrDefault();
                msgs.Add(Public.add_CTPT(db, context, istiencoc, mnu.c_thuchi_id, mnu, "0", "0", sotien.ToString(), "", poID, invID, cttv.loaihd, cttv.kt_tienve_phanbo_id));
            }

            msgs = msgs.Where(s => !string.IsNullOrWhiteSpace(s)).ToList();
            if(msgs.Count > 0)
                msg = string.Join("<br>", msgs);
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            context.Response.Write($@"<div style='color:red' class='error'>{msg}</div>");
        else
            context.Response.Write($@"<div style='color:blue'>Tạo phiếu thu thành công</div>");
    }

    public decimal getAmount(HttpContext context, string id = "")
    {
        var kocoId = string.IsNullOrWhiteSpace(id);
        if(kocoId)
            id = context.Request.QueryString["id"];

        var phieuthu = string.IsNullOrWhiteSpace(context.Request.QueryString["tpc"].removeAllSpaceOrTrimText(false));

        decimal st = 0;

        if(phieuthu)
            st = db.kt_tienve_phanbos.Where(s =>
                s.kt_tienve_id == id &
                s.trangthai == Helper.SOANTHAO &
                s.loaihd != "CK"
                ).ToList().Sum(s => s.sotien.GetValueOrDefault(0));
        else
            st = db.kt_tienve_phanbos.Where(s =>
                s.kt_tienve_id == id &
                s.trangthai == Helper.SOANTHAO &
                s.loaihd == "CK"
                ).ToList().Sum(s => s.sotien.GetValueOrDefault(0));

        if (kocoId)
            context.Response.Write(st);
        return st;
    }

    public void loadGrid(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        string tvid = context.Request.Params["tvid"];
        if (string.IsNullOrWhiteSpace(tvid))
            tvid = "Not404";
        string loai = context.Request.Params["loai"];
        if (string.IsNullOrWhiteSpace(loai))
        {
            loai = "Not404";
            tvid = loai;
        }
        //// filter
        string filter = "", sct = "dh.sochungtu", gtcc = "dh.amount", dtt = "null", conlai = "null";
        var _search = Helper.hoatdongs.Contains(context.Request.Form["_search"].removeAllSpaceOrTrimText(false).ToLower());
        if (_search)
        {
            String _filters = context.Request.Form["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        string fromSQL = $@"
            from c_donhang dh
	        where 
                1=1
	            and dh.md_trangthai_id = '{Helper.HIEULUC}'
                and dh.md_doitackinhdoanh_id in (select dtkd_id from kt_tienve where kt_tienve_id = '{tvid}')
                {filter}
        ";

        if(loai != "PO")
        {
            sct = "dh.so_pkl";
            gtcc = "dh.totalgross";
            dtt = "dh.tiendatra";
            conlai = "dh.tienconlai";
            fromSQL = $@"
                from c_packinginvoice dh
                where 
                    1=1
	                and dh.md_trangthai_id = '{Helper.HIEULUC}'
                    and dh.md_doitackinhdoanh_id in (select dtkd_id from kt_tienve where kt_tienve_id = '{tvid}')
                    and dh.tienconlai > 0
                    {filter}
            ";
        }

        String sqlCount = $"SELECT COUNT(1) AS count {fromSQL}";
        int page = 1;
        int limit = 500;
        String sidx = "";
        String sord = "";
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
            sidx = "dh.ngaytao";
        }

        if (sord.Equals("") || sord == null)
        {
            sord = "desc";
        }

        string strsql = $@"
        select P.* from (
            select 
                {sct} as sochungtu,
                {gtcc} as gtcc,
                {dtt} as dtt,
                {conlai} as conlai,
                dh.ngaytao, 
                dh.nguoitao, 
                dh.ngaycapnhat, 
                dh.nguoicapnhat, 
                dh.mota, 
                dh.hoatdong, 
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            {fromSQL}
        )P 
        where RowNum > @start AND RowNum < @end
        order by P.RowNum
        ";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
            }
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }


    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var cttv = db.kt_tienve_phanbos.Where(s => s.kt_tienve_phanbo_id == id).FirstOrDefault();
            if (cttv == null)
            {
                msg = $@"Không tìm thấy dòng ""chi tiết tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(cttv.trangthai != Helper.SOANTHAO)
            {
                msg = $@"Dòng ""chi tiết tiền về"" không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == cttv.kt_tienve_id).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai == Helper.KETTHUC)
            {
                msg = $@"Dòng ""tiền về"" đã Kết Thúc";
                goto EndEventHandler;
            }

            var loai = context.Request.Form["loaihd"].removeAllSpaceOrTrimText(false);
            if(string.IsNullOrWhiteSpace(loai))
            {
                msg = $@"Không tìm thấy kiểu hồ sơ";
                goto EndEventHandler;
            }

            var sct = context.Request.Form["sctlienquan"].removeAllSpaceOrTrimText(true);
            if (loai == "IN")
            {
                var po = db.c_donhangs.Where(s => s.sochungtu == sct).FirstOrDefault();
                if (po == null)
                {
                    msg = $@"Không tìm thấy PO";
                    goto EndEventHandler;
                }
            }
            else
            {
                var inv = db.c_packinginvoices.Where(s => s.so_pkl == sct).FirstOrDefault();
                if (inv == null)
                {
                    msg = $@"Không tìm thấy Invoice";
                    goto EndEventHandler;
                }
            }

            var tienphanbocu = cttv.sotien.GetValueOrDefault(0);
            var sotien = context.Request.Form["sotien"].removeAllSpaceOrTrimText(false).ToNullableDecimal().GetValueOrDefault(0);
            var phi = layPhi(context, null, tv, sotien);
            phi = loai == "CK" ? 0 : phi;
            if(sotien > tv.conlai + tienphanbocu)
            {
                msg = $@"Tổng tiền phân bổ vượt quá giới hạn {sotien.DropTrailingZeros()} > {(tv.conlai  + tienphanbocu).DropTrailingZeros()}";
                goto EndEventHandler;
            }

            cttv.loaihd = loai;
            cttv.sctlienquan = sct;
            cttv.sotien = sotien;
            cttv.phi = phi;
            cttv.ngaycapnhat = DateTime.Now;
            cttv.nguoicapnhat = UserUtils.getUser(context);
            tv.tongtienphanbo = tv.tongtienphanbo - tienphanbocu + sotien;
            tv.conlai = tv.tienkhach - tv.tongtienphanbo;
            db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Sửa thành công");
    }

    public void add(HttpContext context)
    {
        string msg = "";
        string tvid = context.Request.Form["tvid"];
        try
        {
            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == tvid).FirstOrDefault();
            if (tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if(tv.trangthai == Helper.KETTHUC)
            {
                msg = $@"Dòng ""tiền về"" đã Kết Thúc";
                goto EndEventHandler;
            }
            var loai = context.Request.Form["loaihd"].removeAllSpaceOrTrimText(false);
            if(string.IsNullOrWhiteSpace(loai))
            {
                msg = $@"Không tìm thấy kiểu hồ sơ";
                goto EndEventHandler;
            }

            var sct = context.Request.Form["sctlienquan"].removeAllSpaceOrTrimText(true);
            if (loai == "PO")
            {
                var po = db.c_donhangs.Where(s => s.sochungtu == sct).FirstOrDefault();
                if (po == null)
                {
                    msg = $@"Không tìm thấy PO";
                    goto EndEventHandler;
                }
            }
            else
            {
                var inv = db.c_packinginvoices.Where(s => s.so_pkl == sct).FirstOrDefault();
                if (inv == null)
                {
                    msg = $@"Không tìm thấy Invoice";
                    goto EndEventHandler;
                }
            }

            var sotien = context.Request.Form["sotien"].removeAllSpaceOrTrimText(false).ToNullableDecimal().GetValueOrDefault(0);
            var phi = layPhi(context, null, tv, sotien);
            phi = loai == "CK" ? 0 : phi;

            if (sotien > tv.conlai)
            {
                msg = $@"Tổng tiền phân bổ vượt quá giới hạn {sotien.DropTrailingZeros()} > {tv.conlai.DropTrailingZeros()}";
                goto EndEventHandler;
            }

            var cttv = new kt_tienve_phanbo();
            cttv.kt_tienve_phanbo_id = Helper.getNewId();
            cttv.kt_tienve_id = tv.kt_tienve_id;
            cttv.trangthai = Helper.SOANTHAO;
            cttv.loaihd = loai;
            cttv.sctlienquan = sct;
            cttv.sotien = sotien;
            cttv.phi = phi;
            cttv.ngaytao = DateTime.Now;
            cttv.nguoitao = UserUtils.getUser(context);
            cttv.ngaycapnhat = DateTime.Now;
            cttv.nguoicapnhat = UserUtils.getUser(context);
            db.kt_tienve_phanbos.InsertOnSubmit(cttv);
            tv.tongtienphanbo = tv.tongtienphanbo.GetValueOrDefault(0) + sotien;
            tv.conlai = tv.tienkhach - tv.tongtienphanbo;
            tv.trangthai = Helper.HIEULUC;
            db.SubmitChanges();

            //lammoiTienPhanBo(context, tv.kt_tienve_id);
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Thêm thành công");
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var cttv = db.kt_tienve_phanbos.Where(s => s.kt_tienve_phanbo_id == id).FirstOrDefault();
            if (cttv == null)
            {
                msg = $@"Không tìm thấy dòng ""dòng tiền về"" đã chọn";
                goto EndEventHandler;
            }

            var tv = db.kt_tienves.Where(s => s.kt_tienve_id == cttv.kt_tienve_id).FirstOrDefault();
            if(tv == null)
            {
                msg = $@"Không tìm thấy dòng ""tiền về"" đã chọn";
                goto EndEventHandler;
            }

            if (cttv.trangthai != Helper.SOANTHAO)
            {
                msg = $@"Dòng ""chi tiết tiền về"" không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }


            tv.tongtienphanbo = tv.tongtienphanbo.GetValueOrDefault(0) - (cttv.sotien.GetValueOrDefault(0) + cttv.phi.GetValueOrDefault(0));
            tv.conlai = tv.tienkhach - tv.tongtienphanbo;

            var cttvs = db.kt_tienve_phanbos.Where(s => s.kt_tienve_id == tv.kt_tienve_id & s.kt_tienve_phanbo_id != cttv.kt_tienve_phanbo_id).Count();
            if(cttvs <= 0)
                tv.trangthai = Helper.SOANTHAO;
            db.kt_tienve_phanbos.DeleteOnSubmit(cttv);
            db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length > 0)
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

        string id = context.Request.QueryString["id"];
        string whereSQL = $"and cttv.kt_tienve_id = '{id}'";
        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM kt_tienve_phanbo cttv
            left join c_thuchi tc on tc.c_thuchi_id = cttv.phieuthu_id
            WHERE 1=1 {whereSQL} {filter}";
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
            sidx = "cttv.ngaytao";
            sord = "desc";
        }

        string strsql = $@"
        select * from(
            select 
                cttv.kt_tienve_phanbo_id, 
                cttv.kt_tienve_id, 
                cttv.trangthai, 
                tc.sophieu as sochungtu,
                cttv.loaihd,
                cttv.sctlienquan,
                cttv.sotien,
	            cttv.phi,
                cttv.tpb_inv,
                cttv.sotien - isnull(cttv.tpb_inv, 0) as tcl,
                cttv.ngaytao, 
                cttv.nguoitao, 
                cttv.ngaycapnhat, 
                cttv.nguoicapnhat, 
                cttv.hoatdong,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM kt_tienve_phanbo cttv
                left join c_thuchi tc on tc.c_thuchi_id = cttv.phieuthu_id
            WHERE 1=1 {whereSQL} {filter}
        )P WHERE RowNum > @start AND RowNum < @end";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
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
