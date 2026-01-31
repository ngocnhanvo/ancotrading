<%@ WebHandler Language="C#" Class="PackingInvoiceController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

public class PackingInvoiceController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "sendmail":
                this.sendMail(context);
                break;
            case "getoption":
                this.getSelectOption(context);
                break;
            case "activepacking":
                this.activePacking(context);
                break;
            case "updatephicongphitru":
                this.Updatephicongphitru(context);
                break;
            case "getinvoiceinformation":
                this.GetInformation(context);
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


    //VNN
    public void GetInformation(HttpContext context)
    {
        string id = context.Request.QueryString["pakId"];
        string msg = "";

        try
        {
            decimal sum_thanhtien = 0;
            foreach (var dong_pkl in db.c_dongpklinvs.Where(p => p.c_packinginvoice_id.Equals(id)))
            {
                sum_thanhtien += dong_pkl.thanhtien.Value;
            }

            md_tygia tg = db.md_tygias.ToList().OrderByDescending(p => p.hieuluc_tungay).FirstOrDefault();


            var nhan = from p in db.c_dongpklinvs
                       join c in db.c_dongnhapxuats on p.c_dongnhapxuat_id equals c.c_dongnhapxuat_id
                       where p.c_packinginvoice_id == id
                       select new
                       {
                           c_nhapxuat_id = c.c_nhapxuat_id,
                           c_dongnhapxuat_id = p.c_dongnhapxuat_id,
                           dongnhapxuat_ref = c.dongnhapxuat_ref
                       };

            var nhanids = nhan.Select(s => s.dongnhapxuat_ref).Distinct().ToList();

            var nhan2ids = db.c_dongnhapxuats.Where(s => nhanids.Contains(s.c_dongnhapxuat_id)).Select(s => s.c_nhapxuat_id).Distinct().ToList();


            var nhan3 = db.c_nhapxuats.Where(s => nhan2ids.Contains(s.c_nhapxuat_id)).Select(
                        c => new
                        {
                            c_nhapxuat_id = c.c_nhapxuat_id,
                            c_donhang_id = c.c_donhang_id,
                            sophieu = c.sophieu,
                            ngay_giaonhan = c.ngay_giaonhan,
                            md_doitackinhdoanh_id = c.md_doitackinhdoanh_id,
                            nguoigao = c.nguoigiao,
                            nguoinhan = c.nguoinhan,
                            sophieukhach = c.sophieukhach,
                            ngay_phieu = c.ngay_phieu,
                            md_kho_id = c.md_kho_id,
                            soseal = c.soseal,
                            socontainer = c.socontainer,
                            loaicont = c.loaicont,
                            md_trangthai_id = c.md_trangthai_id,
                            md_loaichungtu_id = c.md_loaichungtu_id,
                            ngaytao = c.ngaytao,
                            nguoitao = c.nguoitao,
                            ngaycapnhat = c.ngaycapnhat,
                            nguoicapnhat = c.nguoicapnhat,
                            mota = c.mota,
                            hoatdong = c.hoatdong,
                            cr_invoice = c.cr_invoice,
                            cr_phieuxuat = c.cr_phieuxuat,
                            sophieunx = c.sophieunx,
                            container = c.container,
                            phicong = c.phicong,
                            phitru = c.phitru,
                            discount = c.discount,
                            totaldiscount = c.totaldiscount,
                            grandtotal = c.grandtotal,
                            sophieunhap = c.sophieunhap
                        });

            decimal sum_thanhtien2 = 0;
            decimal phicong = 0, phitru = 0;

            foreach (var t in nhan3.Distinct())
            {
                sum_thanhtien2 += t.grandtotal.Value;
                phicong += t.phicong.Value;
                phitru += t.phitru.Value;
            }

            c_packinginvoice c_pkl = db.c_packinginvoices.SingleOrDefault(p => p.c_packinginvoice_id.Equals(id));
            sum_thanhtien = sum_thanhtien - (sum_thanhtien * c_pkl.discount.Value / 100);
            //+ c_pkl.giatri_cong.Value - c_pkl.giatri_tru.Value
            sum_thanhtien = ((sum_thanhtien) * tg.chia_cho.Value);
            sum_thanhtien = sum_thanhtien * 82 / 100;

            //+  c_pkl.giatricong_po.Value * tg.chia_cho.Value -  c_pkl.giatritru_po.Value * tg.chia_cho.Value
            sum_thanhtien = sum_thanhtien + phicong - phitru;
            //context.Response.Write(string.Format("Invoice:{0}, Tổng giá trị các dòng Invoice:{1:#,##0.00}, Tổng giá trị các phiếu NK:{2:#,##0.00}"
            //    , db.c_packinginvoices.SingleOrDefault(p=>p.c_packinginvoice_id.Equals(id)).so_pkl , sum_thanhtien, sum_thanhtien2));

            msg = string.Format("Invoice:{0}, Tổng giá trị các phiếu NK:{2:#,##0.00}"
                , db.c_packinginvoices.SingleOrDefault(p => p.c_packinginvoice_id.Equals(id)).so_pkl, sum_thanhtien, sum_thanhtien2);
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        context.Response.Write(msg);
    }

    public void Updatephicongphitru(HttpContext context)
    {
        string id = context.Request.QueryString["pakId"];
        var nhan = from p in db.c_dongpklinvs
                   join c in db.c_dongnhapxuats on p.c_dongnhapxuat_id equals c.c_dongnhapxuat_id
                   where p.c_packinginvoice_id == id
                   select new
                   {
                       c_nhapxuat_id = c.c_nhapxuat_id,
                       c_dongnhapxuat_id = p.c_dongnhapxuat_id,
                       dongnhapxuat_ref = c.dongnhapxuat_ref
                   };

        var nhan2 = from p in nhan
                    join c in db.c_dongnhapxuats on p.dongnhapxuat_ref equals c.c_dongnhapxuat_id
                    select new
                    {
                        c_nhapxuat_id = c.c_nhapxuat_id
                    };

        var nhan3 = from p in nhan2
                    join c in db.c_nhapxuats on p.c_nhapxuat_id equals c.c_nhapxuat_id
                    select new
                    {
                        c_nhapxuat_id = c.c_nhapxuat_id,
                        c_donhang_id = c.c_donhang_id,
                        sophieu = c.sophieu,
                        ngay_giaonhan = c.ngay_giaonhan,
                        md_doitackinhdoanh_id = c.md_doitackinhdoanh_id,
                        nguoigao = c.nguoigiao,
                        nguoinhan = c.nguoinhan,
                        sophieukhach = c.sophieukhach,
                        ngay_phieu = c.ngay_phieu,
                        md_kho_id = c.md_kho_id,
                        soseal = c.soseal,
                        socontainer = c.socontainer,
                        loaicont = c.loaicont,
                        md_trangthai_id = c.md_trangthai_id,
                        md_loaichungtu_id = c.md_loaichungtu_id,
                        ngaytao = c.ngaytao,
                        nguoitao = c.nguoitao,
                        ngaycapnhat = c.ngaycapnhat,
                        nguoicapnhat = c.nguoicapnhat,
                        mota = c.mota,
                        hoatdong = c.hoatdong,
                        cr_invoice = c.cr_invoice,
                        cr_phieuxuat = c.cr_phieuxuat,
                        sophieunx = c.sophieunx,
                        container = c.container,
                        phicong = c.phicong,
                        phitru = c.phitru,
                        discount = c.discount,
                        totaldiscount = c.totaldiscount,
                        grandtotal = c.grandtotal,
                        sophieunhap = c.sophieunhap
                    };

        string doitac = "";
        bool ok = true;
        foreach (var t in nhan3.Distinct())
        {
            if (doitac == "")
            {
                doitac = t.md_doitackinhdoanh_id;
            }
            else
            {
                if (doitac != t.md_doitackinhdoanh_id)
                {
                    ok = false;
                }
            }
        }

        if (ok == false)
        {
            context.Response.Write(String.Format(id + ": " + "Có nhiều hơn một nhà cung ứng, không thể thao tác!!!"));
        }
        else
        {
            md_tygia tg = db.md_tygias.ToList().OrderByDescending(p=>p.hieuluc_tungay).FirstOrDefault();
            decimal tygia_value = tg.chia_cho.Value;


            var nhan4 = nhan3.Distinct().OrderBy(p => p.ngaytao).FirstOrDefault();
            string id_nhan4 = nhan4.c_nhapxuat_id;
            c_nhapxuat nx = db.c_nhapxuats.SingleOrDefault(p=> p.c_nhapxuat_id.Equals(id_nhan4));
            md_doitackinhdoanh dtkd_ = db.md_doitackinhdoanhs.SingleOrDefault(p => p.md_doitackinhdoanh_id.Equals(nx.md_doitackinhdoanh_id));
            if (dtkd_.ma_dtkd.Equals("VINHGIA_MUA") | dtkd_.ma_dtkd.Equals("AN BINH"))
            {
                if(dtkd_.ma_dtkd == "AN BINH") { tygia_value = 21500; }
                string giatricong_bd = nx.phicong.Value.ToString();
                string giatritru_bd = nx.phitru.Value.ToString();
                string pnk = nx.sophieu;
                c_packinginvoice c_pkl = db.c_packinginvoices.SingleOrDefault(p => p.c_packinginvoice_id.Equals(id));
                if (c_pkl.md_trangthai_id != "HIEULUC")
                {
                    if (nx.hoatdong == true)
                    {
                        decimal sum_dongnx = 0;
                        foreach (c_dongnhapxuat dnx in db.c_dongnhapxuats.ToList().Where(s=>s.c_nhapxuat_id.Equals(nx.c_nhapxuat_id)))
                        {
                            sum_dongnx += dnx.dongia.Value * dnx.slthuc_nhapxuat.Value;
                        }
                        sum_dongnx = sum_dongnx - sum_dongnx * nx.discount.Value / 100;
                        sum_dongnx = sum_dongnx + nx.phicong.Value + c_pkl.giatri_cong.Value*tygia_value - nx.phitru.Value - c_pkl.giatri_tru.Value*tygia_value;

                        nx.grandtotal = sum_dongnx;
                        string giatricong_moi = (nx.phicong + c_pkl.giatri_cong*tygia_value).ToString();
                        nx.phicong = nx.phicong + c_pkl.giatri_cong*tygia_value;
                        string giatritru_moi = (nx.phitru + c_pkl.giatri_tru*tygia_value).ToString();
                        nx.phitru = nx.phitru + c_pkl.giatri_tru*tygia_value;
                        nx.hoatdong = false;
                        db.SubmitChanges();
                        context.Response.Write(String.Format(id + ":" + "Cập nhật phí cộng phí trừ vào phiếu nhập kho \"{0}\" thành công.<br><br> &nbsp &nbsp &nbsp Phí cộng ban đầu \"{1}\".<br> &nbsp &nbsp &nbsp Phí trừ ban đầu \"{2}\""

                            + "<br> &nbsp &nbsp &nbsp Giá trị invoice cộng \"{3}\".<br> &nbsp &nbsp &nbsp Giá trị invoice trừ \"{4}\".<br>" +
                            " &nbsp &nbsp &nbsp Phí cộng mới \"{5}\".<br> &nbsp &nbsp &nbsp Phí trừ mới \"{6}\".", pnk, giatricong_bd, giatritru_bd, c_pkl.giatri_cong*tygia_value, c_pkl.giatri_tru*tygia_value, giatricong_moi, giatritru_moi));
                    }
                    else
                    {
                        context.Response.Write(String.Format(id + ":" + "Invoice này đã từng cập nhật phí cộng, phí trừ rồi"));
                    }
                }
                else
                {
                    context.Response.Write(String.Format(id + ":" + "Không thể cập nhật phí cộng, phí trừ vào invoice đã \"Hiệu lực\""));
                }
            }
            else
            {
                context.Response.Write(String.Format(id + ":" + "Không có phiếu nhập nào của đối tác \"VINHGIA_MUA\" hoặc \"AN BINH\""));
            }
        }
    }
    //end-VNN

    public void sendMail(HttpContext context)
    {
        md_mailtemplate tmp = db.md_mailtemplates.Single(p => p.use_for.Equals("PMTREQ") && p.default_mail.Equals(true));
        if (tmp != null)
        {
            String pklId = context.Request.QueryString["pklId"];

            // Lấy packing list - invoice
            var info = (from pkl in db.c_packinginvoices
                        join cb in db.md_cangbiens on pkl.noidi equals cb.md_cangbien_id
                        where pkl.c_packinginvoice_id.Equals(pklId)
                        select new { pkl, cb }).Single();

            // Lấy số lượng sản phẩm Packing List Invoice
            var totalQuantity = (from p in db.c_dongpklinvs where p.c_packinginvoice_id.Equals(pklId) select p.soluong).Sum();



            // Lấy thông tin khách hàng
            var dtkd = (from pkl in db.c_packinginvoices
                        join dt in db.md_doitackinhdoanhs on pkl.md_doitackinhdoanh_id equals dt.md_doitackinhdoanh_id
                        where pkl.c_packinginvoice_id.Equals(pklId)
                        select dt).Single();

            // Lấy danh sách đơn hàng thuộc invoice đang chọn
            var dsDonHang = from p in db.c_packinginvoices
                            join dp in db.c_dongpklinvs on p.c_packinginvoice_id equals dp.c_packinginvoice_id
                            join dh in db.c_donhangs on dp.c_donhang_id equals dh.c_donhang_id
                            where p.c_packinginvoice_id.Equals(pklId)
                            select new { dh };

            // Lấy danh sách số chứng từ đơn hàng
            var chungTuDonHang = (from dh in dsDonHang select new { dh.dh.sochungtu }).Distinct();

            // Lấy thông tin ngân hàng
            var nganhang = db.md_nganhangs.Single(
                        p=>p.md_nganhang_id.Equals(dsDonHang.Take(1).Single().dh.md_nganhang_id)
                    );

            //Chuyển danh sách đơn hàng sang chuỗi
            String dhStr = "";
            foreach (var item in chungTuDonHang)
            {
                dhStr += String.Format(", {0}", item.sochungtu);
            }


            // Lấy tổng số kiện
            var soKien = (from nxk in db.c_nhapxuats
                          join dnxk in db.c_dongnhapxuats on nxk.c_nhapxuat_id equals dnxk.c_nhapxuat_id
                          where nxk.c_donhang_id.Equals(dsDonHang.Take(1).Single().dh.c_donhang_id)
                          select new { dnxk.sokien_thucte });

            Nullable<decimal> toSoKien = soKien.Sum(p => p.sokien_thucte);

            String str = String.Format(tmp.content_mail);

            string sql = string.Format(@"select '{0}' as sopo, '{1}' as ngayguimail, '{2}' as tenkh, '{3}' as chungloai, '{4}' as tentau, '{5}' as noidi
                                        , '{6}' as noiden, '{7}' as shipmenttime, '{8}' as sobil, '{9}' as slinvoice, '{10}' as sokien, '{11}' as tongtieninvoice
                                        , '{12}' as soinvoice, '{13}' as datcoc, '{14}' as giatriconlai, N'{15}' as nganhang"
                         , dhStr, DateTime.Now.ToString("dd/MMM/yyyy"), dtkd.ten_dtkd.Replace("'","''"), info.pkl.commodity, info.pkl.mv, info.cb.ten_cangbien.Replace("'","''")
                         , info.pkl.noiden.Replace("'","''"), info.pkl.etd.Value.ToString("dd/MMM/yyyy"), info.pkl.blno, totalQuantity == null ? "0" : totalQuantity.Value.ToString()
                         , toSoKien == null ? "0" : toSoKien.Value.ToString(), info.pkl.totalgross == null ? "0" : info.pkl.totalgross.Value.ToString()
                         , info.pkl.so_inv, info.pkl.tiendatcoc == null ? "0" : info.pkl.tiendatcoc.Value.ToString(), info.pkl.tienconlai == null ? "0" : info.pkl.tienconlai.Value.ToString()
                         , nganhang.thongtin.Replace("'","''"));
            /*str = str.Replace("[CHUNGTUPO]", dhStr);
            str = str.Replace("[NGAYGUIMAIL]", DateTime.Now.ToString("dd/MMM/yyyy"));
            str = str.Replace("[TENKH]", dtkd.ten_dtkd);
            str = str.Replace("[SOPO]", dhStr);
            str = str.Replace("[CHUNGLOAI]", info.pkl.commodity);
            str = str.Replace("[TENTAU]", info.pkl.mv);
            str = str.Replace("[NOIDI]", info.cb.ten_cangbien);
            str = str.Replace("[NOIDEN]", info.pkl.noiden);
            str = str.Replace("[SHIPMENTTIME]", info.pkl.etd.Value.ToString("dd/MMM/yyyy"));
            str = str.Replace("[SOBIL]", info.pkl.blno);
            str = str.Replace("[SLINVOINE]", totalQuantity == null ? "0" : totalQuantity.Value.ToString());
            str = str.Replace("[SOKIEN]", toSoKien == null ? "0" : toSoKien.Value.ToString());
            str = str.Replace("[TONGTIENINVOICE]", info.pkl.totalgross == null ? "0" : info.pkl.totalgross.Value.ToString());
            str = str.Replace("[SOINVOICE]", info.pkl.so_inv);
            str = str.Replace("[DATCOC]", info.pkl.tiendatcoc == null ? "0" : info.pkl.tiendatcoc.Value.ToString());
            str = str.Replace("[GIATRICONLAI]", info.pkl.tienconlai == null ? "0" : info.pkl.tienconlai.Value.ToString());
            str = str.Replace("[NGANHANG]",nganhang.thongtin);

            str = str.Replace("[br]", "<br/>");
            str = str.Replace("[h3]", "<h3>");
            str = str.Replace("[/h3]", "</h3>");
            str = str.Replace("[center]", "<center>");
            str = str.Replace("[/center]", "</center>");
            str = str.Replace("[b]", "<b>");
            str = str.Replace("[/b]", "</b>");*/

            MemoryStream stream = new MemoryStream();
            rptPaymentRequest report = new rptPaymentRequest();
            System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, mdbc.GetConnection);
            DataSet ds = new DataSet();
            da.Fill(ds);
            report.DataSource = ds;
            report.DataAdapter = da;
            report.ExportToXls(stream);

            context.Response.ContentType = "application/vnd.ms-excel";
            context.Response.AddHeader("Accept-Header", stream.Length.ToString());
            context.Response.AddHeader("Content-Disposition", "Attachment; filename=" + "PaymentRequest" + ".xls");
            context.Response.AddHeader("Content-Length", stream.Length.ToString());
            context.Response.BinaryWrite(stream.ToArray());
            context.Response.End();
        }
    }

    public void activePacking(HttpContext context)
    {
        try
        {
            String pakId = context.Request.QueryString["pakId"];
            c_packinginvoice pak = db.c_packinginvoices.Single(p => p.c_packinginvoice_id.Equals(pakId));

            bool cr_invoice = (bool)mdbc.ExecuteScalar(@"select nx.cr_invoice from 
													c_dongpklinv dpkl, c_dongnhapxuat dnx, c_nhapxuat nx
												where
													dpkl.c_dongnhapxuat_id = dnx.c_dongnhapxuat_id
													and nx.c_nhapxuat_id = dnx.c_nhapxuat_id
													and dpkl.c_packinginvoice_id = '" + pakId + "'");

            string timPhieuNhapKho = string.Format(@"
                select dnx_nk.c_dongnhapxuat_id, dnx_nk.c_nhapxuat_id 
                from c_dongnhapxuat dnx_nk
                where dnx_nk.c_dongnhapxuat_id in 
                (
	                select dnx_xk.dongnhapxuat_ref from c_dongnhapxuat dnx_xk
	                where dnx_xk.c_dongnhapxuat_id in 
	                (
		                select dpkl.c_dongnhapxuat_id from c_packinginvoice pkl
		                left join c_dongpklinv dpkl on pkl.c_packinginvoice_id = dpkl.c_packinginvoice_id
		                where 
                        pkl.c_packinginvoice_id = '{0}'
                        and (
                            select COUNT(1) 
                            from md_doitackinhdoanh 
                            where md_doitackinhdoanh_id = dpkl.nhacungungid and ma_dtkd = '{1}'
                        ) > 0
	                )
                )
				and (
					select COUNT(1) 
					from c_danhsachdathang dsdh 
					inner join c_dongdsdh dh on dh.c_danhsachdathang_id = dsdh.c_danhsachdathang_id
					where 
						dh.c_dongdsdh_id = dnx_nk.c_dongdsdh_id
						and dsdh.ngaytao >= convert(datetime, N'01/08/2019 00:00', 103)
				) > 0
            ", pakId, "VINHGIA");
            if (cr_invoice.Equals(false))
            {
                if (pak.ngay_motokhai != null)
                {
                    if (pak.md_trangthai_id.Equals("HIEULUC"))
                    {
                        context.Response.Write(String.Format("Hiện trạng thái Packing List - Invoice {0} đã là hiệu lực.!", pak.so_inv));
                    }
                    else
                    {
                        pak.md_trangthai_id = "HIEULUC";
                        db.SubmitChanges();
                        context.Response.Write(
                            string.Format("Hiệu lực Packing List - Invoice {0} thành công.!", pak.so_inv)
                            );

                        //                //Cập nhật giá từ USD sang VND cho dòng hàng của phiếu nhập kho
                        //                DataTable dt = mdbc.GetData(timPhieuNhapKho);
                        //                var c_nhapxuat_id = new List<string>();
                        //                var c_dsdh_id = new List<string>();

                        //                foreach (DataRow row in dt.Rows)
                        //                {
                        //                    if (!c_nhapxuat_id.Contains(row[1].ToString()))
                        //                        c_nhapxuat_id.Add(row[1].ToString());
                        //                    c_dongnhapxuat dnx = db.c_dongnhapxuats.Where(s => s.c_dongnhapxuat_id == row[0].ToString()).FirstOrDefault();
                        //                    if (dnx != null)
                        //                    {
                        //                        decimal dongiaVND = jqGridHelper.Utils.Round3(dnx.dongia.Value * (decimal)pak.tygiaUSD_VND.Value, -2);
                        //                        dnx.mota = string.Format(@"{0} USD => {1} VND", dnx.dongia, dongiaVND);
                        //                        dnx.dongia = dongiaVND;
                        //                    }
                        //                }
                        //                if (dt.Rows.Count > 0)
                        //                {
                        //                    mdbc.ExecuteScalar(@"DISABLE Trigger ALL ON c_dongdsdh");
                        //                    mdbc.ExecuteScalar(@"DISABLE Trigger ALL ON c_dongnhapxuat");
                        //                    db.SubmitChanges();
                        //                    mdbc.ExecuteScalar(@"ENABLE Trigger ALL ON c_dongdsdh");
                        //                    mdbc.ExecuteScalar(@"ENABLE Trigger ALL ON c_dongnhapxuat");
                        //                }
                        //                //Cập nhật USD sang VND cho phí cộng phí trừ của phiếu nhập kho
                        //                if (c_nhapxuat_id.Count > 0)
                        //                {
                        //                    foreach (var nx in db.c_nhapxuats.Where(s => c_nhapxuat_id.Contains(s.c_nhapxuat_id)))
                        //                    {
                        //                        nx.phicong = jqGridHelper.Utils.Round3(nx.phicong.Value * (decimal)pak.tygiaUSD_VND.Value, -2);
                        //                        nx.phitru = jqGridHelper.Utils.Round3(nx.phitru.Value * (decimal)pak.tygiaUSD_VND.Value, -2);
                        //decimal tongtienPNK = 0;
                        //foreach(var dnx1 in db.c_dongnhapxuats.Where(s => s.c_nhapxuat_id == nx.c_nhapxuat_id)) {
                        //	tongtienPNK += dnx1.dongia.GetValueOrDefault(0) * dnx1.slthuc_nhapxuat.GetValueOrDefault(0);
                        //}
                        //                        nx.grandtotal = tongtienPNK - tongtienPNK * nx.discount / 100 + nx.phicong - nx.phitru;
                        //                    }
                        //                }
                        //                mdbc.ExecuteScalar(@"DISABLE Trigger ALL ON c_phidathang");
                        //                mdbc.ExecuteScalar(@"DISABLE Trigger ALL ON c_nhapxuat");
                        //                db.SubmitChanges();
                        //                mdbc.ExecuteScalar(@"ENABLE Trigger ALL ON c_phidathang");
                        //                mdbc.ExecuteScalar(@"ENABLE Trigger ALL ON c_nhapxuat");
                    }
                }
                else
                {
                    context.Response.Write(string.Format("Packing List - Invoice {0} chưa nhập ngày mở tờ khai.!", pak.so_inv));
                }
            }
            else
            {
                context.Response.Write("Phiếu xuất kho đã tạo invoice!");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("Lỗi: " + ex.Message);
        }
    }

    public void getSelectOption(HttpContext context)
    {
        String sql = "select c_packinginvoice_id, so_pkl from c_packinginvoice where hoatdong = 1";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }


    public void edit(HttpContext context)
    {
        string msg = "";
        try
        {
            var hd = context.Request.Form["hoatdong"].removeAllSpaceOrTrimText(false).ToNullableBool();
            String discount, giatricong, giatritru, handling_fee, giatritru_po, giatricong_po, so_inv;
            discount = context.Request.Form["discount"];
            giatricong = context.Request.Form["giatri_cong"];
            giatritru = context.Request.Form["giatri_tru"];
            giatritru_po = context.Request.Form["giatritru_po"];
            giatricong_po = context.Request.Form["giatricong_po"];
            handling_fee = context.Request.Form["handling_fee"];
            so_inv = context.Request.Form["so_inv"];
            //--
            c_packinginvoice m = db.c_packinginvoices.Single(p => p.c_packinginvoice_id == context.Request.Form["id"]);
            string ngayMTK = context.Request.Form["ngay_motokhai"];
            DateTime? dateNMTK = null;
            md_tygiamua tgm = null;
            if (!string.IsNullOrEmpty(ngayMTK))
            {
                dateNMTK = DateTime.ParseExact(ngayMTK, "dd/MM/yyyy", null);
                tgm = db.md_tygiamuas.Where(s => s.ngayapdung <= dateNMTK & s.ngayketthuc >= dateNMTK & s.trangthai == "HIEULUC").FirstOrDefault();
            }

            if (!m.md_trangthai_id.Equals(Helper.SOANTHAO))
            {
                msg = "Không thể chỉnh sửa khi Packing List Invoice đã hiệu lực!";
                goto EndEventHandler;
            }

            if(jqGridHelper.Utils.kiemtratrungSCT(db, "INV", so_inv))
            {
                msg = $@"Số INV ""{so_inv}"" đã tồn tại trong chương trình";
                goto EndEventHandler;
            }

            //Cot 1
            m.so_inv = so_inv;
            m.ngaylap = context.Request.Form["ngaylap"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.mv = context.Request.Form["mv"].removeAllSpaceOrTrimText(true);
            m.etd = context.Request.Form["etd"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.etd2 = context.Request.Form["etd2"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.importCountry = context.Request.Form["importCountry"].removeAllSpaceOrTrimText(true);
            m.blno = context.Request.Form["blno"].removeAllSpaceOrTrimText(true);
            m.khutrung = context.Request.Form["khutrung"].removeAllSpaceOrTrimText(true);
            m.ngayCutOff = context.Request.Form["ngayCutOff"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.checkBL = context.Request.Form["checkBL"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.LocalCharge = context.Request.Form["LocalCharge"].removeAllSpaceOrTrimText(true);
            m.co = context.Request.Form["co"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.ngayPayMent = context.Request.Form["ngayPayMent"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.ngayTelLex = context.Request.Form["ngayTelLex"].removeAllSpaceOrTrimText(true).ToNullableDate();
            m.noidi = context.Request.Form["noidi"].removeAllSpaceOrTrimText(true);
            m.noiden = context.Request.Form["noiden"].removeAllSpaceOrTrimText(true);
            m.ghichuCT = context.Request.Form["ghichuCT"].removeAllSpaceOrTrimText(true);
            m.hoatdong = hd;
            //Cot 2
            m.commodity = context.Request.Form["commodity"];
            m.handling_fee = handling_fee.Equals("") ? 0 : decimal.Parse(handling_fee);
            m.diengiai_cong = context.Request.Form["diengiai_cong"];
            m.giatri_cong = giatricong.Equals("") ? 0 : decimal.Parse(giatricong);
            m.diengiai_tru = context.Request.Form["diengiai_tru"];
            m.giatri_tru = giatritru.Equals("") ? 0 : decimal.Parse(giatritru);
            m.commodityvn = context.Request.Form["commodityvn"];
            m.ngay_motokhai = dateNMTK;
            decimal totalGross = (m.totalnet.Value - m.totaldis.Value) + m.giatri_cong.Value - m.giatri_tru.Value + m.giatricong_po.Value - m.giatritru_po.Value;
            m.totalgross = totalGross;
            m.mota = context.Request.Form["mota"].removeAllSpaceOrTrimText(true);
            m.consignee = context.Request.Form["consignee"];
            m.notifparty = context.Request.Form["notifparty"];
            m.alsonotifyparty = context.Request.Form["alsonotifyparty"];
            m.tygiaUSD_VND = tgm != null ? tgm.nhan_voi : 1;
            //Cột 3    
            m.giatritru_po = giatritru_po.Equals("") ? 0 : decimal.Parse(giatritru_po);
            m.giatricong_po = giatricong_po.Equals("") ? 0 : decimal.Parse(giatricong_po);
            //Không có trên giao diện
            m.nguoicapnhat = UserUtils.getUser(context);
            m.ngaycapnhat = DateTime.Now;
            var hoadon = db.c_hoadons.Where(s => s.c_packinginvoice_id == m.c_packinginvoice_id).FirstOrDefault();
            if (hoadon != null)
            {
                hoadon.ngayhoadon = m.ngay_motokhai;
                hoadon.ngayphathanh = m.ngay_motokhai;
                hoadon.tuongduongUSD = m.totalgross;
                hoadon.tuongduongVND = m.totalgross * hoadon.tygia;
                hoadon.giamgia = m.totaldis + m.giatri_tru + m.giatritru_po;
                hoadon.philamhang = m.handling_fee + m.giatri_cong + m.giatricong_po;
                hoadon.phicong = m.giatri_cong;
                hoadon.phitru = m.giatri_tru;
                hoadon.ngaycapnhat = m.ngaycapnhat;
                hoadon.nguoicapnhat = m.nguoicapnhat;
            }
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
            jqGridHelper.Utils.writeResult(1, "Cập nhật thành công");
    }

    public void add(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        c_packinginvoice mnu = new c_packinginvoice
        {
            c_packinginvoice_id = Security.EncodeMd5Hash(DateTime.Now.ToString("yyyyMMddddhhmmss")),
            so_pkl = context.Request.Form["so_pkl"],
            so_inv = context.Request.Form["so_inv"],
            //c_donhang_id = context.Request.Form["c_donhang_id"],
            //md_doitackinhdoanh_id = context.Request.Form["md_doitackinhdoanh_id"],
            md_trangthai_id = "SOANTHAO",
            ngaylap = DateTime.ParseExact(context.Request.Form["ngaylap"], "dd/MM/yyyy", null),
            nguoilap = context.Request.Form["nguoilap"],
            consignee = context.Request.Form["consignee"],
            notifparty = context.Request.Form["notifparty"],
            alsonotifyparty = context.Request.Form["alsonotifyparty"],
            mv = context.Request.Form["mv"],
            etd = DateTime.ParseExact(context.Request.Form["etd"], "dd/MM/yyyy", null),
            noidi = context.Request.Form["noidi"],
            noiden = context.Request.Form["noiden"],
            blno = context.Request.Form["blno"],
            commodity = context.Request.Form["commodity"],
            discount = decimal.Parse(context.Request.Form["discount"]),
            handling_fee = decimal.Parse(context.Request.Form["handling_fee"]),
            diengiai_cong = context.Request.Form["diengiai_cong"],
            giatri_cong = decimal.Parse(context.Request.Form["giatri_cong"]),
            diengiai_tru = context.Request.Form["diengiai_tru"],
            giatri_tru = decimal.Parse(context.Request.Form["giatri_tru"]),
            commodityvn = context.Request.Form["commodityvn"],
            ngay_motokhai = DateTime.ParseExact(context.Request.Form["ngay_motokhai"], "dd/MM/yyyy", null),
            ngay_phaitt = DateTime.ParseExact(context.Request.Form["ngay_motokhai"], "dd/MM/yyyy", null).AddDays(14),
            totalnet = decimal.Parse(context.Request.Form["totalnet"]),
            totalgross = decimal.Parse(context.Request.Form["totalgross"]),
            totaldis = decimal.Parse(context.Request.Form["totaldis"]),

            mota = context.Request.Form["mota"],
            hoatdong = hd,
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.c_packinginvoices.InsertOnSubmit(mnu);
        db.SubmitChanges();
    }


    public void del(HttpContext context)
    {
        string msg = "";
        try
        {
            String id = context.Request.Form["id"];
            var inv = db.c_packinginvoices.Where(s => s.c_packinginvoice_id == id).FirstOrDefault();
            if (inv == null)
                msg = "Không tìm thấy đối tượng cần xóa";
            else if (inv.md_trangthai_id != "SOANTHAO")
                msg = "Hóa đơn đã hiệu lực";
            else
            {
                var hoadon = db.c_hoadons.Where(s => s.c_packinginvoice_id == inv.c_packinginvoice_id).FirstOrDefault();
                if(hoadon != null)
                {
                    if(hoadon.md_trangthai_id != "SOANTHAO")
                        msg = "Hóa đơn liên kết với inv đã hiệu lực";
                    else
                    {
                        var dongHDs = db.c_hoadon_cts.Where(s => s.c_hoadon_id == hoadon.c_hoadon_id).ToList();
                        var dongINVs = db.c_dongpklinvs.Where(s => s.c_packinginvoice_id == inv.c_packinginvoice_id).ToList();

                        db.c_hoadons.DeleteOnSubmit(hoadon);
                        db.c_hoadon_cts.DeleteAllOnSubmit(dongHDs);
                        db.c_packinginvoices.DeleteOnSubmit(inv);
                        db.c_dongpklinvs.DeleteAllOnSubmit(dongINVs);
                        db.SubmitChanges();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length <= 0)
            jqGridHelper.Utils.writeResult(1, "Xóa thành công.");
        else
            jqGridHelper.Utils.writeResult(0, msg);
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



        string whereEX = isadmin == true ? "" : $" AND pi.nguoitao IN({strAccount})";
        String sqlCount = $"SELECT COUNT(1) AS count FROM c_packinginvoice pi where 1=1 {whereEX} {filter}";

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
            sidx = "pi.c_packinginvoice_id";
        }

        string strsql = $@"
            select 
                P.* 
            from (
                select 
                    pi.c_packinginvoice_id, 
                    pi.md_trangthai_id,
                    dtkd.ma_dtkd,
                    pi.so_inv, 
                    dbo.LayChungTuDonHang(pi.c_packinginvoice_id) as sodh, 
                    pi.nguoitao as nguoitao1,
                    pi.ngaylap,
                    pi.mv,
                    pi.etd, 
                    pi.etd2, 
                    pi.POL, 
                    pi.POD, 
                    pi.importCountry, 
                    pi.blno,
                    pi.Forwarder, 
                    pi.ngay_motokhai,
                    pi.totalgross,
                    pi.tiendatcoc, 
                    pi.tiendatra, 
                    pi.tienconlai,
                    pi.ngay_phaitt,
                    pi.khutrung,
                    pi.ngayCutOff,
                    pi.checkBL,
                    pi.LocalCharge,
                    pi.co,
                    pi.ngayPayMent,
                    pi.ngayTelLex,
                    pi.ghichuCT,
                    pi.so_pkl, 
                    pi.nguoilap,
                    pi.consignee, 
                    pi.notifparty, 
                    pi.alsonotifyparty,
                    (select ten_cangbien from md_cangbien cb where cb.md_cangbien_id = pi.noidi) as cbdi,
                    pi.noiden,
                    pi.commodity, 
                    pi.discount, 
                    pi.handling_fee, 
                    pi.diengiai_cong, 
                    pi.giatri_cong,
                    pi.diengiai_tru, 
                    pi.giatri_tru,
                    pi.diengiaicong_po, 
                    pi.giatricong_po, 
                    pi.diengiaitru_po,
                    pi.giatritru_po,
                    pi.totaldis, 
                    pi.totalnet, 
                    pi.commodityvn, 
                    pi.ngaytao, 
                    pi.nguoitao, 
                    pi.ngaycapnhat, 
                    pi.nguoicapnhat, 
                    pi.mota, 
                    pi.hoatdong,
                    ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
                FROM 
                    c_packinginvoice pi
                    left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = pi.md_doitackinhdoanh_id
                WHERE 
                    1=1 
                    {whereEX} 
                    {filter}
            ) P 
            WHERE 
                RowNum > @start AND RowNum < @end";

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
                        string fmt = Extension.fmtDate;
                        if (new string[] { "ngaytao", "ngaycapnhat" }.Contains(column.ColumnName))
                            fmt = Extension.fmtDateHHmmss;
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString(fmt));
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
