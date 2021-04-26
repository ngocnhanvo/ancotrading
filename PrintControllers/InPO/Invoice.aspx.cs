using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.HPSF;
using NPOI.POIFS.FileSystem;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using System.Data;
using HSSFUtils;
using NPOI.HSSF;
using NPOI.HSSF.Util;
using NPOI.DDF;
using NPOI.HSSF.Model;
using NPOI.HSSF.Record;
using NPOI.HSSF.Record.Aggregates;
using NPOI.HSSF.Record.AutoFilter;
public partial class PrintControllers_Invoice_Default : System.Web.UI.Page
{
    public LinqDBDataContext db = new LinqDBDataContext();
    private String fmt0 = "#,##0", fmt0i0 = "#,##0.0", fmt0i00 = "#,##0.00", fmt0i000 = "#,##0.000";

    protected void Page_Load(object sender, EventArgs e)
    {
        //try
        {
            String c_donhang_id = Request.QueryString["c_donhang_id"];
            //-kiem tra co bao nhieu Khach Hang
            string check_dtkd = String.Format(@"select distinct dh.md_doitackinhdoanh_id
			from c_dongdonhang ddh
			left join c_donhang dh on dh.c_donhang_id = ddh.c_donhang_id
			where N'{0}' like  N'%'+dh.c_donhang_id+'%'
			order by dh.md_doitackinhdoanh_id asc
			", c_donhang_id == null ? "" : c_donhang_id);
            //--
            DataTable dt_ck = mdbc.GetData(check_dtkd);
            if (dt_ck.Rows.Count > 1)
            {
                Response.Write("<h3>Đơn hàng không cùng Khách hàng</h3>");
            }
            else
            {
                decimal total_all = 0, total = 0;
                string[] c_id = c_donhang_id.Split(',');
                for (int i = 0; i < c_id.Length; i++)
                {
                    var pTang = (from p in db.c_phidonhangs where p.c_donhang_id.Equals(c_id[i]) && p.phitang.Equals(true) select p.phi).Sum();
                    var pGiam = (from p in db.c_phidonhangs where p.c_donhang_id.Equals(c_id[i]) && p.phitang.Equals(false) select p.phi).Sum();

                    decimal tang, giam;
                    tang = pTang == null ? 0 : pTang.Value;
                    giam = pGiam == null ? 0 : pGiam.Value;

                    double totalDB = (double)mdbc.ExecuteScalar(@"
                        declare @discount numeric(18, 6) = isnull((select discount from c_donhang where c_donhang_id = @c_donhang_id), 0)
                        select a.total -
                        cast(a.total * @discount / 100 as decimal(18, 2)) 
                        from (
	                        select sum(amount) as total
	                        from (
		                        select a.hehang, a.amount - round(a.amount * a.discount / 100, 2) as amount
		                        from (
			                        select a.hehang, a.discount, sum(a.amount) as amount
			                        from (
				                        select
					                        dh.soluong * (isnull(dh.giachuan, dh.giafob)) as amount,
					                        isnull(dh.discount, 0) as discount,
					                        isnull(dh.phi, 0) as phi,
					                        SUBSTRING(sp.ma_sanpham,0,3) as hehang
				                        from 
					                        c_dongdonhang dh
					                        left join md_sanpham sp on sp.md_sanpham_id = dh.md_sanpham_id
				                        where 
					                        c_donhang_id = @c_donhang_id
			                        )a
			                        group by hehang, discount
		                        )a
	                        )a
                        )a
                    "
                    , "@c_donhang_id"
                    , c_id[i]);

                    total = (decimal)totalDB;
                    total = total + tang - giam;
                    total_all += total;
                }


                String totalWord = MoneyToWord.ConvertMoneyToText(total_all.ToString()).Replace("Dollars", "");

                int j = totalWord.LastIndexOf("and");

                if (totalWord.Contains("Cents") | totalWord.Contains("Cent"))
                {
                    totalWord = totalWord.Replace("Cents", "").Replace("Cent", "");
                    totalWord = totalWord.Insert(totalWord.Length, "cents");
                }
                else
                {
                    totalWord = totalWord.Replace("Cents", "").Replace("Cent", "");
                }

                //-- Lay sochungtu
                string soct_th = "";
                string count_sct = String.Format(@"select distinct dh.sochungtu
				from c_dongdonhang ddh
				left join c_donhang dh on dh.c_donhang_id = ddh.c_donhang_id
				where N'{0}' like  N'%'+dh.c_donhang_id+'%'
				order by dh.sochungtu asc
				", c_donhang_id == null ? "" : c_donhang_id);
                DataTable dt_ct = mdbc.GetData(count_sct);
                for (int i = 0; i < dt_ct.Rows.Count; i++)
                {
                    if (soct_th == "")
                        soct_th = "AS PER PROFORMA INVOICE NO.: " + dt_ct.Rows[i][0];
                    else
                        soct_th += ", " + dt_ct.Rows[i][0];
                }

                //-- Lay chungloai
                string cl_th = "";
                string count_cl = String.Format(@"select distinct cl.ta_ngan
				from c_dongdonhang ddh
				left join md_sanpham sp on sp.md_sanpham_id = ddh.md_sanpham_id
				left join md_chungloai cl on cl.md_chungloai_id = sp.md_chungloai_id
				left join c_donhang dh on dh.c_donhang_id = ddh.c_donhang_id
				where N'{0}' like  N'%'+dh.c_donhang_id+'%'
				order by cl.ta_ngan asc
				", c_donhang_id == null ? "" : c_donhang_id);
                DataTable dt_cl = mdbc.GetData(count_cl);
                for (int i = 0; i < dt_cl.Rows.Count; i++)
                {
                    if (cl_th == "")
                        cl_th = "" + dt_cl.Rows[i][0];
                    else
                        cl_th += ", " + dt_cl.Rows[i][0];
                }

                String select = String.Format(@"
				SELECT B.*
				FROM (select
				GETDATE() as ngaylap
				, dh.c_donhang_id
				, dh.sochungtu
				, dtkd.ten_dtkd
				, dtkd.diachi
				, dtkd.tel
				, dtkd.fax 
				, dh.portdischarge as cang_n
				, cx.ten_cangbien as cang_x
				, dh.shipmenttime
				, pmt.ten_paymentterm
				, sp.ma_sanpham
				, sp.mota_tiengviet
				, sp.mota_tienganh
				, ddh.soluong
				, isnull(ddh.giachuan, ddh.giafob) as giafob
                , ddh.discount as disHH
				, dh.totalcbm
                , dh.discount_hehang_value
				, convert(decimal(18,2) ,dh.discount) as discount
				, trl.ten_trongluong
				, dg.sl_outer
				, dg.sl_inner
				, dvt_outer.ten_dvt as dvt_outer
				, dvt_inner.ten_dvt as dvt_inner
				, dvt.ten_dvt
				, ddh.l1, ddh.w1, ddh.h1
				, ddh.l2, ddh.w2, ddh.h2, ddh.v2
				, case when dh.md_trongluong_id is not null then dg.sl_outer * (SELECT dbo.f_convertKgToPounds(sp.trongluong, dh.md_trongluong_id)) else 0 end as n_w_outer
				, case when dh.md_trongluong_id is not null then dg.sl_inner * (SELECT dbo.f_convertKgToPounds(sp.trongluong, dh.md_trongluong_id)) else 0 end as n_w_inner
				, (ddh.l2 + ddh.w2) * (ddh.w2 * ddh.h2) / 5400 as t_thung_outer
				, (ddh.l1 + ddh.w1) * (ddh.w1 * ddh.h1) / 5400 as t_thung_inner
				, '{1}' as money
                , (select 'ANCO COMPANY LTD. Account No. : ' + thongtin from md_nganhang where dh.md_nganhang_id = md_nganhang_id) as thongtinnganhang
				, '{2}' as sochungtu_th
				, '{3}' as chungloai_th
				from c_dongdonhang ddh
				left join c_donhang dh on dh.c_donhang_id = ddh.c_donhang_id
				left join md_sanpham sp on sp.md_sanpham_id = ddh.md_sanpham_id
				left join md_doitackinhdoanh dtkd on dtkd.md_doitackinhdoanh_id = dh.md_doitackinhdoanh_id
				left join md_paymentterm pmt on dh.md_paymentterm_id = pmt.md_paymentterm_id
				left join md_cangbien cx on cx.md_cangbien_id = dh.md_cangbien_id
				left join md_donggoi dg on dg.md_donggoi_id = ddh.md_donggoi_id
				left join md_donvitinh dvt_outer on dvt_outer.md_donvitinh_id = dg.dvt_outer
				left join md_donvitinh dvt_inner on dvt_inner.md_donvitinh_id = dg.dvt_inner
				left join md_donvitinhsanpham dvt on dvt.md_donvitinhsanpham_id = sp.md_donvitinhsanpham_id
				left join md_trongluong trl on trl.md_trongluong_id = dh.md_trongluong_id
				where N'{0}' like  N'%'+dh.c_donhang_id+'%'
				
				)B order by B.sochungtu asc, B.ma_sanpham asc
				", c_donhang_id == null ? "" : c_donhang_id, totalWord, soct_th, cl_th.ToUpper());

                DataTable dt = mdbc.GetData(select);
                if (dt.Rows.Count != 0)
                {
                    HSSFWorkbook hssfworkbook = this.CreateWorkBookPO(dt);
                    String saveAsFileName = String.Format("Invoice-{0}.xls", DateTime.Now);
                    this.SaveFile(hssfworkbook, saveAsFileName);
                    Response.Write(select);
                }
                else
                {
                    Response.Write("<h3>Đơn hàng không có dữ liệu</h3>");
                }
            }
        }
        //catch (Exception ex)
        {
            //Response.Write(String.Format("<h3>Quá trình chiếc xuất xảy ra lỗi {0}</h3>", ex.Message));
        }
    }

    public HSSFWorkbook CreateWorkBookPO(DataTable dt)
    {
        HSSFWorkbook hssfworkbook = new HSSFWorkbook();
        ISheet s1 = hssfworkbook.CreateSheet("Sheet1");
        HSSFSheet hssfsheet = (HSSFSheet)s1;

        Excel_Format ex_fm = new Excel_Format(hssfworkbook);
        ICellStyle cellBold = ex_fm.getcell(12, true, true, "", "L", "T");
        //-- 
        ICellStyle cellHeader = ex_fm.getcell(18, true, true, "", "C", "T");
        //-- 
        ICellStyle cellHeader_n = ex_fm.getcell(12, false, true, "", "C", "T");
        //--
        ICellStyle celltext = ex_fm.getcell(12, false, true, "", "L", "T");
        //--
        ICellStyle rightBold = ex_fm.getcell(12, true, false, "", "R", "T");
        //--
        ICellStyle right = ex_fm.getcell(12, false, false, "", "R", "T");
        //--
        ICellStyle leftBold = ex_fm.getcell(12, true, false, "", "L", "T");
        //--
        ICellStyle left = ex_fm.getcell(12, false, false, "", "L", "T");
        //--
        ICellStyle border = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
        //--
        ICellStyle borderright = ex_fm.getcell(12, false, true, "LRBT", "R", "T");
        //--
        ICellStyle borderonlyleft = ex_fm.getcell(12, false, true, "L", "T", "T");
        //--
        ICellStyle borderWrap = ex_fm.getcell(12, true, true, "LRBT", "C", "T");
        //--
        ICellStyle signBold = ex_fm.getcell(12, true, true, "", "C", "C");
        //--
        var number2Bold = ex_fm.getcell2(12, true, true, "", "R", "T", "#,##0.00");

        int heigh = 22;
        int row = 0;
        //set A1 - A3
        string[] a = { "ANCO COMPANY LIMITED", "3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam", "Tel.: (84-274) 3740 973   Fax:  (84-274) 3740 621  Email: anco@ancopottery.com", "COMMERCIAL INVOICE" };
        for (int i = 0; i < a.Count(); i++)
        {
            s1.CreateRow(row).CreateCell(0).SetCellValue(a[i]);
            s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 6));
            s1.GetRow(row).HeightInPoints = heigh;
            if (i == 0 | i == 3)
            {
                s1.GetRow(row).HeightInPoints = 30;
                s1.GetRow(row).GetCell(0).CellStyle = cellHeader;
            }
            else
            {
                s1.GetRow(row).GetCell(0).CellStyle = cellHeader_n;
            }
            row++;
        }
        //--

        //set F4 - F5
        string[] b = { "No.:", "Date:" };
        string[] b_value = { "", "ngaylap" };
        for (int i = 0; i < b.Count(); i++)
        {
            s1.CreateRow(row).CreateCell(3).SetCellValue(b[i]);
            s1.GetRow(row).GetCell(3).CellStyle = cellBold;
            s1.AddMergedRegion(new CellRangeAddress(row, row, 4, 6));

            if (i == 1)
                s1.GetRow(row).CreateCell(4).SetCellValue(DateTime.Parse(dt.Rows[0][b_value[i]].ToString()).ToString("dd/MM/yyyy"));
            else if (b_value[i] != "")
                s1.GetRow(row).CreateCell(4).SetCellValue(dt.Rows[0][b_value[i]].ToString());
            else
                s1.GetRow(row).CreateCell(4).SetCellValue("");
            s1.GetRow(row).GetCell(3).CellStyle = cellBold;
            s1.GetRow(row).GetCell(4).CellStyle = cellBold;
            s1.GetRow(row).HeightInPoints = heigh;
            row++;
        }

        //set A6 - A12
        string[] c = { "For the account & risk of the buyer:", " ", "M/V:", "From:", "To:", "B/L No.:", "Commodity:", " " };
        string[] c_value = { "", "", "", "cang_x", "cang_n", "", "chungloai_th", "sochungtu_th" };
        for (int i = 0; i < c.Count(); i++)
        {
            string rich_text = " {0} \n {1} \n Tel:{2} \n Fax{3}";
            heigh = 22;
            string v_l = c[i];
            if (i == 1)
            {
                heigh = 95;
                v_l = rich_text;
            }
            else if (i == 7 | i == 6)
            {
                heigh = 40;
            }
            s1.CreateRow(row).CreateCell(0).SetCellValue(c[i]);
            HSSFRichTextString rich = new HSSFRichTextString(String.Format(rich_text, dt.Rows[0]["ten_dtkd"].ToString(), dt.Rows[0]["diachi"].ToString(), dt.Rows[0]["tel"].ToString(), dt.Rows[0]["fax"].ToString()));
            if (i == 1)
                s1.GetRow(row).CreateCell(2).SetCellValue(rich);
            else if (c_value[i] != "")
                s1.GetRow(row).CreateCell(2).SetCellValue(dt.Rows[0][c_value[i]].ToString());
            else
                s1.GetRow(row).CreateCell(2).SetCellValue("");
            //--
            if (i == 1)
                s1.GetRow(row).GetCell(2).CellStyle = cellBold;
            else
                s1.GetRow(row).GetCell(2).CellStyle = celltext;
            //--
            s1.GetRow(row).GetCell(0).CellStyle = celltext;
            //--
            if (i == 0)
                s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 6));
            else
                s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 6));

            s1.GetRow(row).HeightInPoints = heigh;
            row++;
        }

        // set A13 - All
        // -- Header
        int cell = 0;
        string[] d = { "Seller's Article", "Buyer's Article", "Description of goods", "Quantity (pcs,sets)", "", "Unit price (USD/pc,set)", "Amount (USD)" };
        IRow rowColumnHeader = s1.CreateRow(row);
        rowColumnHeader.HeightInPoints = 47;
        for (int i = 0; i < d.Count(); i++)
        {
            int with = 5000;
            rowColumnHeader.CreateCell(cell).SetCellValue(d[i]);
            rowColumnHeader.GetCell(i).CellStyle = borderWrap;
            if (i == 2)
                with = 10000;
            s1.SetColumnWidth(cell, with);
            cell++;
        }
        s1.AddMergedRegion(new CellRangeAddress(row, row, 3, 4));
        row++;
        // -- Details
        // create column
        string sochungtu = "";
        //thu tu tong cong // dem so dong hang cua tung sochungtu
        int count_row = 0, count_row_tt = 1;
        // tap hop so luong dong tong cong // tap hop cac vi tri cua tong cong
        string l_cbm = "";
        // create detail row
        var startRowHH = -1;
        var lstHH = new List<int>();
        var lstPO = new List<int>();
        string discount_hehang_value = "-1";
        List<Dictionary<string, object>> nnl = null;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (discount_hehang_value == "-1")
            {
                discount_hehang_value = dt.Rows[i]["discount_hehang_value"].ToString();
                nnl = string.IsNullOrEmpty(discount_hehang_value) ? null : Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(discount_hehang_value);
            }

            var msp = dt.Rows[i]["ma_sanpham"].ToString();
            var chungloai = msp.Substring(0, 2);
            var chungloaiTT = i == dt.Rows.Count - 1 ? chungloai : dt.Rows[i + 1]["ma_sanpham"].ToString().Substring(0, 2);

            var soPO = dt.Rows[i]["sochungtu"].ToString();
            var soPOTT = i == dt.Rows.Count - 1 ? soPO : dt.Rows[i + 1]["sochungtu"].ToString();
            var soPOTR = i == 0 ? soPO : dt.Rows[i - 1]["sochungtu"].ToString();

            if (startRowHH == -1)
                startRowHH = row + 3;

            if (i == 0 | soPO != soPOTR) //ke dong sochungtu dau tien
            {
                s1.CreateRow(row).CreateCell(0).SetCellValue("Container/Seal No.: ");
                s1.GetRow(row).CreateCell(4).SetCellValue("FOB " + dt.Rows[i]["cang_x"].ToString());
                CellRangeAddress cellRange03 = new CellRangeAddress(row, row, 0, 3);
                CellRangeAddress cellRange46 = new CellRangeAddress(row, row, 4, 6);
                s1.AddMergedRegion(cellRange03);
                s1.AddMergedRegion(cellRange46);
                s1.GetRow(row).GetCell(0).CellStyle = leftBold;
                s1.GetRow(row).GetCell(4).CellStyle = borderWrap;
                s1.GetRow(row).CreateCell(7).CellStyle = borderonlyleft;
                s1.GetRow(row).HeightInPoints = 22;
                ex_fm.set_border(cellRange03, "LRTB", hssfsheet);
                ex_fm.set_border(cellRange46, "LRTB", hssfsheet);
                //--
                row++;
                //--
                s1.CreateRow(row).CreateCell(0).SetCellValue("P/I No. " + dt.Rows[i]["sochungtu"].ToString());
                cellRange03 = new CellRangeAddress(row, row, 0, 3);
                cellRange46 = new CellRangeAddress(row, row, 4, 6);
                s1.AddMergedRegion(cellRange03);
                s1.AddMergedRegion(cellRange46);
                s1.GetRow(row).GetCell(0).CellStyle = leftBold;
                s1.GetRow(row).CreateCell(7).CellStyle = borderonlyleft;
                s1.GetRow(row).HeightInPoints = 22;
                sochungtu = dt.Rows[i]["sochungtu"].ToString();
                ex_fm.set_border(cellRange03, "LRTB", hssfsheet);
                ex_fm.set_border(cellRange46, "LRTB", hssfsheet);
                row++;
            }
            else //ke dong sochungtu tiep theo
            {

            }

            string[] e_value = { "ma_sanpham", "", "mota_tienganh", "soluong", "ten_dvt", "giafob", "" };
            if (dt.Rows[i]["sochungtu"].ToString() != "9999")
            {
                IRow row_t = s1.CreateRow(row); row_t.HeightInPoints = 60;
                //
                int cell_t = 0;
                for (int j = 0; j < e_value.Count(); j++)
                {
                    if (j == 3 | j == 5)
                        row_t.CreateCell(cell_t).SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
                    else if (j == 6)
                        row_t.CreateCell(cell_t).CellFormula = String.Format("D{0} * F{0}", row + 1);
                    else if (e_value[j] == "")
                        row_t.CreateCell(cell_t).SetCellValue("");
                    else
                        row_t.CreateCell(cell_t).SetCellValue(dt.Rows[i][e_value[j]].ToString()); ;
                    cell_t++;
                }

                try
                {
                    for (int n = 0; n <= cell_t + 1; n++)
                    {
                        row_t.GetCell(n).CellStyle = border;
                    }
                }
                catch { }
                s1.GetRow(row).GetCell(3).CellStyle = borderright;
                s1.GetRow(row).GetCell(5).CellStyle = borderright;
                s1.GetRow(row).GetCell(6).CellStyle = borderright;
                s1.GetRow(row).GetCell(6).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");

                row++;
                count_row++;
                count_row_tt++;

                if (chungloai != chungloaiTT | i == dt.Rows.Count - 1 | soPO != soPOTT)
                {
                    if (nnl != null)
                    {
                        string gthh = dt.Rows[i]["disHH"] + "";
                        gthh = string.IsNullOrEmpty(gthh) ? "0" : gthh;
                        var rowHeight = gthh == "0" ? 0 : 20;
                        var rowToTalHeHang = s1.CreateRow(row);
                        rowToTalHeHang.HeightInPoints = rowHeight;
                        rowToTalHeHang.CreateCell(2).SetCellValue(string.Format("Sub Total ({0}):", lstHH.Count + 1));
                        rowToTalHeHang.GetCell(2).CellStyle = leftBold;
                        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 1));
                        string fmlSum = string.Format(@"SUM(VNN{0}:VNN{1})", startRowHH, row);
                        rowToTalHeHang.CreateCell(3).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "D"));
                        rowToTalHeHang.GetCell(3).CellStyle = number2Bold;
                        rowToTalHeHang.CreateCell(4).SetCellValue("pcs/sets");
                        rowToTalHeHang.GetCell(4).CellStyle = leftBold;
                        rowToTalHeHang.CreateCell(6).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "G"));
                        rowToTalHeHang.GetCell(6).CellStyle = number2Bold;
                        row++;
                        count_row++;
                        count_row_tt++;

                        var rowDisHeHang = s1.CreateRow(row);
                        rowDisHeHang.HeightInPoints = rowHeight;
                        rowDisHeHang.CreateCell(2).SetCellValue(string.Format(@"Discount ({0}%):", gthh));
                        rowDisHeHang.GetCell(2).CellStyle = leftBold;
                        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 1));
                        rowDisHeHang.CreateCell(6).CellFormula = string.Format("=ROUND(G{0}*{1}/100, 2)", row, gthh);
                        rowDisHeHang.GetCell(6).CellStyle = number2Bold;
                        row++;
                        count_row++;
                        count_row_tt++;

                        var rowTotalHeHang = s1.CreateRow(row);
                        rowTotalHeHang.HeightInPoints = rowHeight;
                        rowTotalHeHang.CreateCell(2).SetCellValue(string.Format("Total ({0}):", lstHH.Count + 1));
                        rowTotalHeHang.GetCell(2).CellStyle = leftBold;
                        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 1));
                        rowTotalHeHang.CreateCell(3).CellFormula = string.Format("D{0}", row - 1);
                        rowTotalHeHang.GetCell(3).CellStyle = number2Bold;
                        rowTotalHeHang.CreateCell(6).CellFormula = string.Format("G{0} - G{1}", row - 1, row);
                        rowTotalHeHang.GetCell(6).CellStyle = number2Bold;
                        row++;
                        count_row++;
                        count_row_tt++;

                        startRowHH = row + 1;
                        lstHH.Add(row);
                    }
                }

                if (soPO != soPOTT | i == dt.Rows.Count - 1)
                {
                    discount_hehang_value = "-1";

                    var discountPO = dt.Rows[i]["discount"] + "";
                    discountPO = discountPO.Replace(".00", "");

                    string sumQuantity = "", sumAmount = "";
                    if (nnl != null)
                    {
                        foreach (var iHH in lstHH)
                        {
                            sumQuantity += string.Format("D{0}+", iHH);
                            sumAmount += string.Format("G{0}+", iHH);
                        }
                        sumQuantity += "0";
                        sumAmount += "0";
                    }
                    else
                    {
                        sumQuantity += string.Format("SUM(D{0}:D{1})", startRowHH, row);
                        sumAmount += string.Format("SUM(G{0}:G{1})", startRowHH, row);
                    }
                    //vi tri row dau tien
                    int m = row - count_row + 1, sub_row = 0, discount_row = 0;
                    //start tong cong 1
                    s1.CreateRow(row).CreateCell(2).SetCellValue(string.Format("Sub Total:", lstPO.Count + 1));
                    s1.GetRow(row).CreateCell(3).CellFormula = string.Format("{0}", sumQuantity);
                    s1.GetRow(row).CreateCell(6).CellFormula = string.Format("{0}", sumAmount);
                    s1.GetRow(row).CreateCell(14).SetCellValue(discountPO);
                    s1.SetColumnWidth(14, 0);
                    // style
                    s1.GetRow(row).GetCell(2).CellStyle = leftBold;
                    s1.GetRow(row).GetCell(3).CellStyle = rightBold;
                    s1.GetRow(row).GetCell(6).CellStyle = rightBold;
                    for (int nht = 6; nht <= 6; nht++)
                    {
                        s1.GetRow(row).GetCell(nht).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
                    }

                    row++;
                    l_cbm += row + ",";
                    sub_row = row;
                    //end

                    //start giam gia
                    m = row - count_row + 1;
                    
                    s1.CreateRow(row).CreateCell(2).SetCellValue("Discount PO (" + discountPO + "%):");
                    s1.GetRow(row).CreateCell(6).CellFormula = String.Format("ROUND(G{0}*O{1}/100,2)", row, row);
                    s1.GetRow(row).GetCell(2).CellStyle = leftBold;
                    s1.GetRow(row).GetCell(6).CellStyle = rightBold;
                    s1.GetRow(row).GetCell(6).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
                    if (discountPO != "0" & !string.IsNullOrEmpty(discountPO))
                    {
                        s1.GetRow(row).HeightInPoints = 22;
                    }
                    else
                    {
                        s1.GetRow(row).HeightInPoints = 0;
                    }
                    row++;
                    discount_row = row;
                    //end

                    //start phi cong tru
                    string chuoi_ct = "0";
                    var phidonhang = db.c_phidonhangs.Where(s => s.c_donhang_id == dt.Rows[i]["c_donhang_id"].ToString()).ToList();
                    if (phidonhang.Count > 0)
                    {
                        string vitri_ct = "-0";
                        var loaiPhi = phidonhang.FirstOrDefault().phitang;
                        if(phidonhang.Count == 1)
                        {
                            phidonhang.Add(new c_phidonhang()
                            {
                                phitang = !loaiPhi,
                                phi = 0,
                            });
                        }

                        foreach (var pdh in phidonhang.OrderByDescending(s=>s.phitang))
                        {
                            //start phi cong va tru
                            m = row - count_row + 1;
                            string plus = "+";
                            int check_plus = 0;
                            if (pdh.phitang != true)
                            {
                                plus = "-";
                                check_plus = 1;
                            }

                            s1.CreateRow(row).CreateCell(2).SetCellValue("(" + plus + ")" + pdh.mota + ":");
                            s1.GetRow(row).CreateCell(6).SetCellValue((double)pdh.phi);
                            s1.GetRow(row).CreateCell(14).SetCellValue(check_plus);

                            s1.GetRow(row).GetCell(2).CellStyle = leftBold;
                            s1.GetRow(row).GetCell(6).CellStyle = rightBold;
                            s1.GetRow(row).GetCell(6).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
                            s1.GetRow(row).HeightInPoints = pdh.phi > 0 ? 22 : 0;
                            row++;
                            vitri_ct += plus + "H" + row;
                            //end    
                        }
                    }
                    else
                    {
                        //start phi cong
                        m = row - count_row + 1;
                        s1.CreateRow(row).CreateCell(2).SetCellValue("(+):");
                        s1.GetRow(row).CreateCell(6).SetCellValue(0);
                        s1.GetRow(row).CreateCell(14).SetCellValue(0);

                        s1.GetRow(row).GetCell(2).CellStyle = leftBold;
                        s1.GetRow(row).GetCell(6).CellStyle = rightBold;
                        s1.GetRow(row).GetCell(6).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
                        s1.GetRow(row).HeightInPoints = 0;
                        row++;
                        chuoi_ct += "+G" + row;
                        //end

                        //start phi tru
                        m = row - count_row + 1;
                        s1.CreateRow(row).CreateCell(2).SetCellValue("(-):");
                        s1.GetRow(row).CreateCell(6).SetCellValue(0);
                        s1.GetRow(row).CreateCell(14).SetCellValue(0);

                        s1.GetRow(row).GetCell(2).CellStyle = leftBold;
                        s1.GetRow(row).GetCell(6).CellStyle = rightBold;
                        s1.GetRow(row).GetCell(6).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
                        s1.GetRow(row).HeightInPoints = 0;
                        row++;
                        chuoi_ct += "-G" + row;
                        //end
                    }

                    //end

                    //start tong cong 2
                    
                    m = row - count_row + 1;
                    string sumToTalPO = "";
                    for (var iHH = 0; iHH < lstHH.Count; iHH++)
                    {
                        var rowHH = lstHH[iHH];
                        sumToTalPO += string.Format(@"G{0}+", rowHH + 1);
                    }
                    sumToTalPO += "0";
                    s1.CreateRow(row).CreateCell(2).SetCellValue(string.Format("Total ({0}):", lstPO.Count + 1));
                    s1.GetRow(row).CreateCell(3).CellFormula = string.Format("D{0}", sub_row);
                    s1.GetRow(row).CreateCell(6).CellFormula = string.Format("G{0}-G{1}+G{2}-G{3}", sub_row, sub_row + 1, sub_row + 2, sub_row + 3);
                    // style
                    s1.GetRow(row).GetCell(2).CellStyle = leftBold;
                    s1.GetRow(row).GetCell(3).CellStyle = rightBold;
                    s1.GetRow(row).GetCell(6).CellStyle = rightBold;
                    s1.GetRow(row).GetCell(6).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
                    s1.GetRow(row).HeightInPoints = 22;
                    row++;
                    lstPO.Add(row);
                    lstHH.Clear();
                    startRowHH = -1;
                    //end
                }
            }
        }
        //// tap hop 
        //string numbel_total = n_total.Substring(0, n_total.Length - 3), get_locate_soluong = "", get_locate_thanhtien = "";
        //string[] locate_total = l_total.Split(',');
        //string[] locate_cbm = l_cbm.Split(',');
        //for (int i = 0; i < locate_total.Count() - 1; i++)
        //{
        //    get_locate_soluong += "D" + locate_total[i] + "+";
        //    get_locate_thanhtien += "G" + locate_total[i] + "+";
        //}
        ////
        //string new_get_locate_thanhtien = get_locate_thanhtien.Substring(0, get_locate_thanhtien.Length - 1);
        //string new_get_locate_soluong = get_locate_soluong.Substring(0, get_locate_soluong.Length - 1);
        ////
        ////start tong cong total

        string totalTxt = "", sumQuantityAll = "", sumAmountAll = "";
        for (var i = 0; i < lstPO.Count; i++)
        {
            var rowPO = lstPO[i];
            totalTxt += string.Format("({0})+", i + 1);
            sumQuantityAll += string.Format(@"D{0}+", rowPO);
            sumAmountAll += string.Format(@"G{0}+", rowPO);
        }
        sumQuantityAll += "0";
        sumAmountAll += "0";
        totalTxt = totalTxt.Length > 0 ? totalTxt.Substring(0, totalTxt.Length - 1) : "";

        s1.CreateRow(row).CreateCell(2).SetCellValue(string.Format(@"Total {0}:", totalTxt));
        s1.GetRow(row).GetCell(2).CellStyle = leftBold;
        s1.GetRow(row).CreateCell(3).CellFormula = string.Format(sumQuantityAll);
        s1.GetRow(row).GetCell(3).CellStyle = rightBold;
        s1.GetRow(row).CreateCell(6).CellFormula = string.Format(sumAmountAll);
        s1.GetRow(row).GetCell(6).CellStyle = rightBold;
        //// style
        //
        //
        //
        //s1.GetRow(row).GetCell(6).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
        //s1.GetRow(row).HeightInPoints = 22;
        row++;
        s1.CreateRow(row).CreateCell(0).SetCellValue("Say:USD " + dt.Rows[0]["money"].ToString().Replace("Dollars", ""));
        s1.GetRow(row).GetCell(0).CellStyle = rightBold;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 6));
        row++;
        ////
        s1.CreateRow(row).CreateCell(0).SetCellValue("Please arrange the payment to our account with banking details as follows:");
        s1.GetRow(row).GetCell(0).CellStyle = right;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 6));
        row++;
        ////end

        //set A6 - A12
        string[] f = { "Infavour of:", "Add:", " " };
        string[] f_value = { "thongtinnganhang", "3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam", "Account no.:007.137.0321634 At bank: Joint Stock Commercial Bank For Foreign Trade of Vietnam (VIETCOMBANK), 10 Vo Van Kiet street , Dist.1 , Ho Chi Minh City ,Vietnam. Tel.: (84-28) 38297245, Fax: (84-28) 38297228, Swift code: BFTVVNVX007" };
        for (int i = 0; i < f.Count(); i++)
        {
            s1.CreateRow(row).CreateCell(0).SetCellValue(f[i]);
            if (i == 0)
            {
                s1.GetRow(row).CreateCell(1).SetCellValue(dt.Rows[0]["thongtinnganhang"].ToString());
            }
            else
            {
                s1.GetRow(row).CreateCell(1).SetCellValue(f_value[i]);
            }
            heigh = 22;
            if (i == 0 | i == 2)
                heigh = 55;
            else if (i == 1)
            {
                heigh = 30;
            }
            s1.GetRow(row).GetCell(0).CellStyle = celltext;
            s1.GetRow(row).GetCell(1).CellStyle = celltext;
            //s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 1));
            s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 6));
            s1.GetRow(row).HeightInPoints = heigh;
            row++;
        }
        //
        s1.CreateRow(row).CreateCell(3).SetCellValue("ANCO COMPANY LTD");
        s1.GetRow(row).GetCell(3).CellStyle = signBold;
        s1.GetRow(row).HeightInPoints = 22;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 3, 6));
        row++;

        #region Format Print Excel

        s1.PrintSetup.PaperSize = (short)PaperSize.A4;
        s1.FitToPage = true;
        s1.PrintSetup.FitWidth = 1;
        s1.PrintSetup.FitHeight = 0;
        s1.SetMargin(MarginType.TopMargin, 0.75);
        s1.SetMargin(MarginType.BottomMargin, 0.75);
        s1.SetMargin(MarginType.LeftMargin, 0.23);
        s1.SetMargin(MarginType.RightMargin, 0.23);
        s1.SetMargin(MarginType.HeaderMargin, 0.31);
        s1.SetMargin(MarginType.FooterMargin, 0.31);
        hssfworkbook.SetPrintArea(
            hssfworkbook.GetSheetIndex(s1.SheetName), //sheet index
            0, //start column
            6, //end column
            0, //start row
            row + 1
        );
        #endregion

        return hssfworkbook;
    }

    public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName)
    {
        MemoryStream exportData = new MemoryStream();
        hsswb.Write(exportData);

        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", saveAsFileName));
        Response.Clear();
        Response.BinaryWrite(exportData.GetBuffer());
        Response.End();
    }
}
