using System;
using System.Collections.Generic;
using System.Linq;

using System.IO;
using NPOI.HSSF.UserModel;

using NPOI.SS.UserModel;
using NPOI.SS.Util;
using System.Data;
using HSSFUtils;
using Newtonsoft.Json;

public partial class PrintControllers_InDonHang_Default : System.Web.UI.Page
{
    public LinqDBDataContext db = new LinqDBDataContext();
    private String fmt0 = "#,##0", fmt0i0 = "#,##0.0", fmt0i00 = "#,##0.00", fmt0i000 = "#,##0.000";
    decimal discountPO = 0;
    string type = "excel";
    string c_donhang_id = "";
    List<Dictionary<string, string>> lstimage = new List<Dictionary<string, string>>();
    protected void Page_Load(object sender, EventArgs e)
    {
        //try
        //{
        c_donhang_id = Request.QueryString["c_donhang_id"];
        type = Request.QueryString["type"];
        var dh = db.c_donhangs.Where(s => s.c_donhang_id == c_donhang_id).FirstOrDefault();
        discountPO = dh.discount_hehang.GetValueOrDefault(false) ? 0 : dh.discount.GetValueOrDefault(0);
        dh.discount = dh.phanbodiscount.GetValueOrDefault(false) == true ? 0 : dh.discount;
        dh.discount_hehang = dh.phanbodiscount.GetValueOrDefault(false) == true ? false : dh.discount_hehang;
        dh.discount_hehang_value = dh.phanbodiscount.GetValueOrDefault(false) == true ? "" : dh.discount_hehang_value;

        var pTang = (from p in db.c_phidonhangs where p.c_donhang_id.Equals(c_donhang_id) && p.phitang.Equals(true) select p.phi).Sum();
        var pGiam = (from p in db.c_phidonhangs where p.c_donhang_id.Equals(c_donhang_id) && p.phitang.Equals(false) select p.phi).Sum();

        string diengiaicong = "";
        string diengiaitru = "";

        foreach (c_phidonhang phi_1 in db.c_phidonhangs.Where(p => p.c_donhang_id.Equals(c_donhang_id) && p.phitang.Equals(true)))
        {
            // md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(s => s.md_doitackinhdoanh_id == phi_1.md_doitackinhdoanh_id);
            // diengiaicong += dtkd.ten_dtkd + ", ";
            diengiaicong += phi_1.mota + ", ";
        }
        if (diengiaicong.Length > 0)
        {
            diengiaicong = diengiaicong.Substring(0, diengiaicong.Length - 2);
        }
        foreach (c_phidonhang phi_2 in db.c_phidonhangs.Where(p => p.c_donhang_id.Equals(c_donhang_id) && p.phitang.Equals(false)))
        {
            // md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(s => s.md_doitackinhdoanh_id == phi_2.md_doitackinhdoanh_id);
            // diengiaitru += dtkd.ten_dtkd + ", ";
            diengiaitru += phi_2.mota + ", ";
        }
        if (diengiaitru.Length > 0)
        {
            diengiaitru = diengiaitru.Substring(0, diengiaitru.Length - 2);
        }

        decimal tang, giam;
        tang = pTang == null ? 0 : pTang.Value;
        giam = pGiam == null ? 0 : pGiam.Value;

        decimal total = decimal.Parse(
            mdbc.ExecuteScalar(@"
                select 
                    cast(A.amount - (A.amount * @discount / 100) as decimal(18, 2))
                from (
                    select 
                        sum(soluong * ((giafob + isnull(phi, 0)) - (giafob + isnull(phi, 0)) * isnull(discount, 0) / 100)) as amount 
                    from 
                        c_dongdonhang 
                    where 
                        c_donhang_id = @c_donhang_id
                )A
                "
                , "@c_donhang_id"
                , c_donhang_id
                , "@discount"
                , discountPO
            ) + ""
        );

        total = total + tang - giam;

        String totalWord = MoneyToWord.ConvertMoneyToText(total.ToString());
        if (totalWord.Contains("Dollars"))
        {
            totalWord = "USD " + totalWord.Replace("Dollars", "");
        }

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

        String no_cont = "";

        if (dh.cont20 != null)
        {
            if (dh.cont20.Value.Equals(0))
            {
                no_cont += "";
            }
            else
            {
                no_cont += String.Format(" {0} x 20\" ", dh.cont20.Value);
            }
        }

        if (dh.cont40 != null)
        {
            if (dh.cont40.Value.Equals(0))
            {
                no_cont += "";
            }
            else
            {
                no_cont += String.Format("+ {0} x 40\" ", dh.cont40.Value);
            }
        }

        if (dh.cont40hc != null)
        {
            if (dh.cont40hc.Value.Equals(0))
            {
                no_cont += "";
            }
            else
            {
                no_cont += String.Format("+ {0} x 40HC ", dh.cont40hc.Value);
            }
        }

        if (dh.cont45 != null)
        {
            if (dh.cont45.Value.Equals(0))
            {
                no_cont += "";
            }
            else
            {
                no_cont += String.Format("+ {0} x 45\" ", dh.cont45.Value);
            }
        }

        if (dh.contle != null)
        {
            if (dh.contle.Value.Equals(0))
            {
                no_cont += "";
            }
            else
            {
                no_cont += String.Format("+ {0} x LCL ", dh.contle.Value);
            }
        }
        if (!no_cont.Equals(""))
        {
            no_cont = no_cont.Substring(1);
        }

        string select = string.Format(@"
            SELECT 
                B.*
                , CASE
				    WHEN B.sl_inner = 0
				    THEN B.n_w_inner + B.t_thung_outer

				    WHEN B.dvt_inner like N'%ctn%' and B.dvt_outer like N'%ctn%'
				    THEN B.n_w_master + B.t_thung_outer

				    WHEN B.dvt_inner like N'%ctn%' and B.dvt_outer like N'%pal%'
				    THEN B.g_w_inner + 20

				    WHEN B.dvt_inner like N'%ctn%' and B.dvt_outer like N'%crt%'
				    THEN B.g_w_inner + 5

				    WHEN B.dvt_inner like N'%bun%' and B.dvt_outer like N'%crt%'
				    THEN B.g_w_inner + 5

				    WHEN B.dvt_inner like N'%bun%' and B.dvt_outer like N'%pal%'
				    THEN B.g_w_inner + 20

				    WHEN B.sl_inner = 0 and B.dvt_outer like N'%pal%'
				    THEN B.g_w_inner + 25
				ELSE 0 END as g_w_master
			FROM
			(
                SELECT 
                    A.*
                    , A.giafob * A.soluong as amount
                    
                    , (select dbo.get_commodity(N'{0}') )  + ' products' as commodity
                    , '{1}' as money
                    , '{4}' as diengiaicong
                    , '{5}' as diengiaitru
                    , isnull('{6}',0) as phicong
                    , isnull('{7}',0) as phitru
                    , N'{8}' as no_cont

                    , CASE
					    WHEN A.dvt_inner like N'%bun%'
					    THEN A.n_w_inner + 0.5
					    WHEN A.dvt_inner like N'%crt%'  
					    THEN A.n_w_inner + 3
					    WHEN A.dvt_inner like N'%ctn%'  
					    THEN A.n_w_inner + t_thung_inner
					ELSE 0 END as g_w_inner
				FROM (
                    select 
						dh.c_donhang_id
						, dh.sochungtu, dh.customer_order_no
						, dtkd.ten_dtkd
                        , dtkd.diachi
                        , dtkd.tel
                        , dtkd.fax
						, dh.payer
                        , dh.ngaylap 
						, sp.ma_sanpham
						, convert(nvarchar,isnull(ddh.sl_inner, 0)) + ' ' + dvt_inner.ten_dvt as ten_donggoi_inner
						, convert(nvarchar,isnull(ddh.sl_outer, 0)) + ' ' + dvt_outer.ten_dvt as ten_donggoi_outer
						, ddh.ma_sanpham_khach
                        , ddh.mota_tienganh
						, ddh.sl_outer
                        , ddh.sl_inner
						, (case ddh.sl_outer when 0 then ' ' else (cast(ddh.sl_outer as nvarchar) + ' '+ (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_outer)) end) as ten_donggoi
						, ddh.soluong
                        , dvt.ten_dvt as dvt_sp
                        , (
                            case 
                                when isnull(dh.phanbodiscount, 0) = 0
                                then ddh.giafob + isnull(ddh.phi, 0)
                                else (ddh.giafob + isnull(ddh.phi, 0)) - (ddh.giafob + isnull(ddh.phi, 0)) * 
                                    (
                                        case when dh.discount > 0 then dh.discount else ddh.discount end
                                    ) / 100
                            end
                        ) as giafob
                        
                        , isnull('{2}', 0) as dis
						, cast('{2}' as decimal(18,2)) as dis1
                        , N'{3}' as discount_hehang_value

                        , isnull(ddh.giachuan, ddh.giafob) as giachuan
                        , isnull(ddh.phi, 0) as phi
						, sp.l_cm, sp.w_cm, sp.h_cm, sp.l_inch, sp.w_inch, sp.h_inch
                        , convert(varchar, dh.shipmenttime, 106) as shipmenttime
                        , cb.ten_cangbien
                        , pmt.ten_paymentterm
                        , (' In favor of ANCO COMPANY LTD. Account No. : ' + ngh.thongtin) as mota
						, ddh.v2 as cbm
                        , (sp.trongluong * ddh.soluong) as trongluong
                        , (case ddh.sl_outer when 0 then 0 else (ddh.soluong / ddh.sl_outer) end ) as ofpack
						, (case dg.sl_inner when 0 then ' ' else (cast(dg.sl_inner as nvarchar) + ' '+ (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_inner)) end) as sl_inner_
						, dh.portdischarge
                        , CASE WHEN dh.hoahong is null THEN 0 ELSE dh.hoahong END as hoahong
						, (case when md_nguoilienhe_id is null then '' else (select ma_dtkd from md_doitackinhdoanh where md_doitackinhdoanh_id = dh.md_nguoilienhe_id) end) as nguoinhan
						, ddh.l1, ddh.w1, ddh.h1 , ddh.l2, ddh.w2, ddh.h2, hs.hscode as ma_hscode
						, dvt_outer.ten_dvt as dvt_outer
						, dvt_inner.ten_dvt as dvt_inner
						, (ddh.l2 + ddh.w2) * (ddh.w2 * ddh.h2) / 5400 as t_thung_outer
						, (ddh.l1 + ddh.w1) * (ddh.w1 * ddh.h1) / 5400 as t_thung_inner
						, case when dh.md_trongluong_id is not null then dg.sl_outer * sp.trongluong else 0 end as n_w_master
						, case when dh.md_trongluong_id is not null then dg.sl_inner * sp.trongluong else 0 end as n_w_inner
						, kt.ten_kichthuoc
                        , tl.ten_trongluong
                        , ddh.barcode
					from
						c_donhang dh
						left join c_dongdonhang ddh on dh.c_donhang_id = ddh.c_donhang_id
						left join md_doitackinhdoanh dtkd on dh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
						left join md_sanpham sp on ddh.md_sanpham_id = sp.md_sanpham_id
						left join md_donggoi dg on ddh.md_donggoi_id = dg.md_donggoi_id
						left join md_donvitinh dvt_outer on dvt_outer.md_donvitinh_id = dg.dvt_outer
						left join md_donvitinh dvt_inner on dvt_inner.md_donvitinh_id = dg.dvt_inner				
						left join md_donvitinhsanpham dvt on sp.md_donvitinhsanpham_id = dvt.md_donvitinhsanpham_id
						left join md_cangbien cb on dh.md_cangbien_id = cb.md_cangbien_id
						left join md_paymentterm pmt on dh.md_paymentterm_id = pmt.md_paymentterm_id
						left join md_nganhang ngh on dh.md_nganhang_id = ngh.md_nganhang_id
						left join md_kichthuoc kt on dh.md_kichthuoc_id = kt.md_kichthuoc_id
						left join md_trongluong tl on dh.md_trongluong_id = tl.md_trongluong_id
						left join md_hscode hs on sp.md_hscode_id = hs.md_hscode_id
                    where 1=1
				) A
            ) B
			where B.c_donhang_id = N'{0}' 
            order by B.ma_sanpham asc"
            , c_donhang_id == null ? "" : c_donhang_id
            , totalWord
            , dh.discount.GetValueOrDefault(0)
            , dh.discount_hehang_value
            , diengiaicong
            , diengiaitru
            , tang
            , giam
            , no_cont
        );

        try
        {
            DataTable dt = mdbc.GetData(select);

            if (dt.Rows.Count != 0)
            {
                HSSFWorkbook hssfworkbook = this.CreateWorkBookPO(dt);
                String saveAsFileName = String.Format("DonHang-{0}.xls", DateTime.Now);
                this.SaveFile(hssfworkbook, saveAsFileName);
            }
            else
            {
                Response.Write("<h3>Đơn hàng không có dữ liệu</h3>");
            }
        }
        catch(Exception ex)
        {
            Response.Write(ex + "");
        }
        //}
        //catch (Exception ex)
        //{
        //    Response.Write(String.Format("<h3>Quá trình chiếc xuất xảy ra lỗi {0}</h3>", ex.Message));
        //}
    }

    public HSSFWorkbook CreateWorkBookPO(DataTable dt)
    {
        string discount_hehang_value = dt.Rows[0]["discount_hehang_value"] + "";
        string tenKT = dt.Rows[0]["ten_kichthuoc"] + "";
        string tenTL = dt.Rows[0]["ten_trongluong"] + "";
        var nnl = string.IsNullOrEmpty(discount_hehang_value) ? null : JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(discount_hehang_value);
        
        HSSFWorkbook hssfworkbook = new HSSFWorkbook();
        ISheet s1 = hssfworkbook.CreateSheet("Sheet1");
        HSSFSheet hssfsheet = (HSSFSheet)s1;

        var config = new ExportExcel(hssfworkbook, 0, type == "pdf"? 12 : 16);

        Excel_Format ex_fm = new Excel_Format(hssfworkbook);
        ICellStyle cellBold = ex_fm.getcell(12, true, true, "", "L", "T");
        ICellStyle cellBoldTop = ex_fm.getcell(12, true, true, "", "L", "B");
        //-- 
        ICellStyle cellHeader = ex_fm.getcell(18, true, true, "", "C", "T");
        //-- 
        ICellStyle cellHeader_n = ex_fm.getcell(12, false, true, "", "C", "T");
        //--
        ICellStyle celltext = ex_fm.getcell(12, false, true, "", "L", "T");
        //--
        ICellStyle rightBold = ex_fm.getcell(12, true, false, "", "R", "T");
        var bottomLeftBold = ex_fm.getcell(12, true, false, "B", "L", "T");

        ICellStyle rightBold0 = ex_fm.getcell2(12, true, false, "", "R", "T", fmt0);
        ICellStyle rightBold3 = ex_fm.getcell2(12, true, false, "", "R", "T", fmt0i000);
        //--
        ICellStyle rightBold4 = ex_fm.getcell2(12, true, false, "", "R", "T", "#,##0.0000");
        //--
        ICellStyle right = ex_fm.getcell(12, false, false, "", "R", "T");
        //--
        ICellStyle leftBold = ex_fm.getcell(12, true, false, "", "L", "T");
        //--
        ICellStyle left = ex_fm.getcell(12, false, false, "", "L", "T");
        //--
        ICellStyle border_number0 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##");
        ICellStyle border_number1 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.0");
        ICellStyle border_number2 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.00");
        ICellStyle border_number3 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.000");
        ICellStyle border_number4 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.0000");
        ICellStyle border = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
        ICellStyle border_center = ex_fm.getcell(12, false, true, "LRBT", "C", "T");
        //--
        ICellStyle borderright = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
        //--
        ICellStyle borderonlyleft = ex_fm.getcell(12, false, true, "L", "T", "T");
        //--
        ICellStyle borderWrap = ex_fm.getcell(12, true, true, "LRBT", "C", "T");
        //--
        ICellStyle signBold = ex_fm.getcell(12, true, true, "", "C", "C");
        //--
        //IDataFormat dataFormatCustom = hssfworkbook.CreateDataFormat();
        int heigh = 22;
        int row = 0;
        //Logo
        //private String logoPath, productImagePath;
        String logoPath = System.IO.Path.Combine(Server.MapPath("~/images/"), "anco_logo_print.png");
        //String productImagePath = Server.MapPath("~/images/products/fullsize/");
        System.Drawing.Image logo = System.Drawing.Image.FromFile(logoPath);
        MemoryStream mslogo = new MemoryStream();
        logo.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

        IDrawing patriarchlogo = s1.CreateDrawingPatriarch();
        HSSFClientAnchor anchorlogo = new HSSFClientAnchor(0, 0, 0, 0, 1, 0, 2, 3);
        anchorlogo.AnchorType = 3;

        int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
        IPicture signaturePicturelogo = patriarchlogo.CreatePicture(anchorlogo, indexlogo);
        //
        //set A1 - A4
        string[] a = {
            "ANCO COMPANY LIMITED",
            "3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam",
            "Tel.: (84-274) 3740 973   Fax:  (84-274) 3740 621  Email: anco@ancopottery.com",
            "PROFORMA INVOICE"
        };

        for (int i = 0; i < a.Length; i++)
        {
            s1.CreateRow(row).CreateCell(0).SetCellValue(a[i]);
            s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 12));
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
        //set J4 - F8
        string[] b = { "Date:", "No.:" };
        string[] b_value = { "ngaylap", "sochungtu" };
        for (int i = 0; i < b.Count(); i++)
        {
            s1.CreateRow(row).CreateCell(9).SetCellValue(b[i]);
            s1.GetRow(row).GetCell(9).CellStyle = cellBold;
            s1.AddMergedRegion(new CellRangeAddress(row, row, 10, 12));

            if (i == 0)
                s1.GetRow(row).CreateCell(10).SetCellValue(DateTime.Parse(dt.Rows[0][b_value[i]].ToString()).ToString("dd/MMM/yyyy"));
            else if (b_value[i] != "")
                s1.GetRow(row).CreateCell(10).SetCellValue(dt.Rows[0][b_value[i]].ToString());

            s1.GetRow(row).GetCell(9).CellStyle = cellBold;
            s1.GetRow(row).GetCell(10).CellStyle = cellBold;
            s1.GetRow(row).HeightInPoints = heigh;
            row++;
        }
        //set A7 - A11
        string[] c = {
            "The Buyer:"
            , "The Payer:"
            , "ANCO Company agrees to sale and the Buyer agrees to buy the goods under terms and conditions as follows:"
            , "Customer's order no.:"
            , "Commodity:"
            , "Item nos., description, packing, quantity, unit price and amount:"
        };
        string[] c_value = {
            ""
            , "payer"
            , ""
            , "customer_order_no"
            , "commodity"
            , ""
        };
        for (int i = 0; i < c.Length; i++)
        {
            s1.CreateRow(row).CreateCell(1).SetCellValue(c[i]);
            string rich_text = "{0} \n {1} \n Tel:{2} \n Fax{3}";
            HSSFRichTextString rich = new HSSFRichTextString(String.Format(rich_text, dt.Rows[0]["ten_dtkd"].ToString(), dt.Rows[0]["diachi"].ToString(), dt.Rows[0]["tel"].ToString(), dt.Rows[0]["fax"].ToString()));
            if (i == 0)
            {
                heigh = 95;
                s1.GetRow(row).GetCell(1).CellStyle = cellBoldTop;
                s1.GetRow(row).CreateCell(2).SetCellValue(rich);
                s1.GetRow(row).GetCell(2).CellStyle = cellBoldTop;
                s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 12));
            }
            else
            {
                if (c_value[i] != "")
                {
                    s1.GetRow(row).CreateCell(3).SetCellValue(dt.Rows[0][c_value[i]].ToString());
                    s1.AddMergedRegion(new CellRangeAddress(row, row, 3, 12));
                }
                else
                {
                    s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 12));
                }

                if (i == 3)
                    s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 2));
                heigh = 22;
                s1.GetRow(row).GetCell(1).CellStyle = celltext;
            }
            
            s1.GetRow(row).HeightInPoints = heigh;
            row++;
        }

        // set A13 - All
        // -- Header
        int cell = 0;
        string[] d = {
            "No."
            , "ANCO Item No."
            , "Picture - Only for shape ref."
            , "Customer Item No."
            , "Description"
            , "Packing inner/master",""
            , "Nbr of Packs"
            , "Quantity (sets/pcs)",""
            , "FOB price (USD)"
            , "CBM"
            , "Amount (USD)"
            , string.Format(@"Master Packing size (LxWxH){0}", tenKT)
            , ""
            , ""
            , "HS CODE"
            , string.Format(@"Weight({0}s)", tenTL)
            , string.Format(@"N.W/master ({0}s)", tenTL)
            , string.Format(@"G.W/master ({0}s)", tenTL)
            , "Master packing"
            , "Inner packing"
            , "Inner Packing size (LxWxH)"
            , ""
            , ""
            , "Product size (LxWxH) cm"
            , ""
            , ""
            , "Product size (LxWxH) inch"
            , ""
            , ""
            , "Barcode"
            , "Giá gốc"
            , "Phí"
        };

        string[] e_value = {
            "no"
            , "ma_sanpham"
            , ""
            , "ma_sanpham_khach"
            , "mota_tienganh"
            , "ten_donggoi_inner"
            , "ten_donggoi_outer"
            , "ofpack"
            , "soluong"
            , "dvt_sp"
            , "giafob"
            , "cbm"
            , "amount"
            , "l2"
            , "w2"
            , "h2"
            , "ma_hscode"
            , "trongluong"
            , "n_w_master"
            , "g_w_master"
            , "sl_outer"
            , "sl_inner"
            , "l1"
            , "w1"
            , "h1"
            , "l_cm"
            , "w_cm"
            , "h_cm"
            , "l_inch"
            , "w_inch"
            , "h_inch"
            , "barcode"
            , "giachuan"
            , "phi"
        };

        IRow rowColumnHeader = s1.CreateRow(row);
        rowColumnHeader.HeightInPoints = 47;
        for (int i = 0; i < d.Length; i++)
        {
            int with = 4500;
            rowColumnHeader.CreateCell(cell).SetCellValue(d[i]);
            rowColumnHeader.GetCell(i).CellStyle = borderWrap;
            if (i == 0)
            {
                with = 2000;
            }
            else if (i == 1)
            {
                with = type == "pdf" ? 6000 : with;
            }
            else if (i == 4)
            {
                with = type == "pdf" ? 12000 : 10000;
            }
            else if (i == 5 | i == 6)
            {
                with = 3000;
            }
            else if (i == 8 | i == 9)
            {
                with = 3000;
            }
            else if (i == 13 | i == 14 | i == 15)
            {
                with = 3000;
            }
            else if (i > 16)
                with = 0;

            if(type=="pdf")
            {
                if (i > 12)
                    with = 0;
            }

            s1.AddMergedRegion(new CellRangeAddress(row, row, 5, 6));
            s1.AddMergedRegion(new CellRangeAddress(row, row, 8, 9));
            s1.AddMergedRegion(new CellRangeAddress(row, row, 13, 15));
            s1.AddMergedRegion(new CellRangeAddress(row, row, 22, 24));
            s1.AddMergedRegion(new CellRangeAddress(row, row, 25, 27));
            s1.AddMergedRegion(new CellRangeAddress(row, row, 28, 30));
            s1.SetColumnWidth(cell, with);
            cell++;
        }
        row++;
        // -- Details
        int count_row = 1;
        //
        double discount = 0, discount1 = 0, startRowHH = -1;
        var lstHH = new List<int>();
        var lstAmountHH = new List<int>();
        // create detail row
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            var msp = dt.Rows[i]["ma_sanpham"].ToString();
            var mota = dt.Rows[i]["mota_tienganh"] + "";
            var masterSize = new List<string>();
            masterSize.Add(dt.Rows[i]["l2"] + "");
            masterSize.Add(dt.Rows[i]["w2"] + "");
            masterSize.Add(dt.Rows[i]["h2"] + "");

            var cmInch = Public.convertCmToInch(mota, masterSize, tenKT);
            dt.Rows[i]["mota_tienganh"] = cmInch["mota"];
            masterSize = cmInch["masterSize"] as List<string>;
            dt.Rows[i]["l2"] = masterSize[0];
            dt.Rows[i]["w2"] = masterSize[1];
            dt.Rows[i]["h2"] = masterSize[2];

            var kgPound = Public.convertKgToPound(
                dt.Rows[i]["trongluong"] + ""
                , dt.Rows[i]["n_w_master"] + ""
                , dt.Rows[i]["g_w_master"] + ""
                , tenTL
                );
            dt.Rows[i]["trongluong"] = kgPound["weight"];
            dt.Rows[i]["n_w_master"] = kgPound["NWmaster"];
            dt.Rows[i]["g_w_master"] = kgPound["GWmaster"];

            var chungloai = msp.Substring(0, 2);
            var chungloaiTT = i == dt.Rows.Count - 1 ? chungloai : dt.Rows[i + 1]["ma_sanpham"].ToString().Substring(0, 2);

            if (startRowHH == -1)
                startRowHH = row;

            discount = double.Parse(dt.Rows[i]["dis"].ToString());
            discount1 = double.Parse(dt.Rows[i]["dis1"].ToString());

            IRow row_t = s1.CreateRow(row);
            float heightMAX = config.MeasureTextHeight(mota, 10000);
            row_t.HeightInPoints = heightMAX < 60 ? 60 : heightMAX;

            //
            try
            {
                string imagesPath = Path.Combine(Server.MapPath("~"), "");
                //grab the image file
                string anhhienthi = ExcuteSignalRStatic.getImageProduct(msp);
                imagesPath = Path.Combine(imagesPath, anhhienthi);
                var image = System.Drawing.Image.FromFile(imagesPath);

                lstimage.Add(new Dictionary<string, string>() {
                    { "row", row + "" },
                    { "column", 3 + "" },
                    { "link", imagesPath },
                    { "height", row_t.HeightInPoints + "" },
                    { "width", 4500 + "" },
                    { "heightR", image.Height + "" },
                    { "widthR", image.Width + "" }
                });
            }
            catch { }
            //

            for (int j = 0; j < e_value.Length; j++)
            {
                var cel_row_t = row_t.CreateCell(j);
                if (e_value[j] == "no")
                {
                    cel_row_t.SetCellValue(count_row);
                    cel_row_t.CellStyle = border_center;
                }
                else if (e_value[j] == "ofpack")
                {
                    cel_row_t.CellFormula = String.Format("I{0}/U{0}", row + 1);
                    cel_row_t.CellStyle = border_number2;
                }
                else if (e_value[j] == "cbm")
                {
                    cel_row_t.CellFormula = String.Format("((N{0}*O{0}*P{0})*H{0})/1000000", row + 1);
                    cel_row_t.CellStyle = border_number3;
                }
                else if (e_value[j] == "amount")
                {
                    cel_row_t.CellFormula = String.Format("IF(K{0}*I{0}<>0,K{0}*I{0},0)", row + 1);
                    cel_row_t.CellStyle = border_number2;
                }
                else if (e_value[j] == "soluong")
                {
                    cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
                    cel_row_t.CellStyle = border_number0;
                }
                else if (new string[] { "giafob", "giachuan", "phi" }.Contains(e_value[j]))
                {
                    cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
                    cel_row_t.CellStyle = border_number2;
                }
                else if (new string[] { "l2", "w2", "h2" }.Contains(e_value[j]))
                {
                    cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
                    cel_row_t.CellStyle = border_number2;
                }
                else if (new string[] { "ma_hscode", "ma_sanpham" }.Contains(e_value[j]))
                {
                    cel_row_t.SetCellValue(dt.Rows[i][e_value[j]].ToString());
                    cel_row_t.CellStyle = border_center;
                }
                // else if( e_value[j] == "ten_donggoi_inner") {
                // cel_row_t.SetCellValue(dt.Rows[i][e_value[j]].ToString().Replace(" ","\n"));
                // cel_row_t.CellStyle = border_center;
                // }
                else if (e_value[j] == "")
                {
                    cel_row_t.SetCellValue("");
                    cel_row_t.CellStyle = border;
                }
                else
                {
                    cel_row_t.SetCellValue(dt.Rows[i][e_value[j]].ToString());
                    cel_row_t.CellStyle = border;
                }
                //  table style


                // else if(j == 8)
                // s1.GetRow(row).GetCell(j).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##");
                // else
                // s1.GetRow(row).GetCell(j).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
            }
            row++;
            count_row++;

            if (nnl != null)
            {
                if (chungloai != chungloaiTT | i == dt.Rows.Count - 1)
                {
                    string gthh = nnl == null ? "0" : nnl.Where(s => s["hehang"].ToString() == chungloai).Select(s => s["giatri"].ToString()).FirstOrDefault();

                    var rowToTalHeHang = s1.CreateRow(row);
                    //rowToTalHeHang.HeightInPoints = 25;
                    rowToTalHeHang.CreateCell(4).SetCellValue(string.Format("Sub Total ({0}):", lstHH.Count + 1));
                    var range1_3 = new CellRangeAddress(row, row, 1, 3);
                    var range4_10 = new CellRangeAddress(row, row, 4, 10);
                    s1.AddMergedRegion(range1_3);
                    s1.AddMergedRegion(range4_10);
                    //RegionUtil.SetBorderBottom((int)BorderStyle.Thin, range1_3, s1, hssfworkbook);
                    //RegionUtil.SetBorderBottom((int)BorderStyle.Thin, range4_10, s1, hssfworkbook);
                    rowToTalHeHang.GetCell(4).CellStyle = leftBold;
                    string fmlSum = string.Format(@"SUM(M{0}:M{1})", startRowHH + 1, row);
                    rowToTalHeHang.CreateCell(12).CellFormula = string.Format("{0}", fmlSum, row + 1);
                    rowToTalHeHang.GetCell(12).CellStyle = rightBold;
                    row++;
                    
                    var rowDisHeHang = s1.CreateRow(row);
                    //rowDisHeHang.HeightInPoints = 25;
                    rowDisHeHang.CreateCell(4).SetCellValue(string.Format(@"Discount ({0}%):", gthh));
                    rowDisHeHang.GetCell(4).CellStyle = leftBold;
                    s1.AddMergedRegion(new CellRangeAddress(row, row, 4, 10));
                    rowDisHeHang.CreateCell(12).CellFormula = string.Format("M{0}*{1}/100", row, gthh);
                    rowDisHeHang.GetCell(12).CellStyle = rightBold;
                    row++;

                    var rowTotalHeHang = s1.CreateRow(row);
                    //rowTotalHeHang.HeightInPoints = 25;
                    rowTotalHeHang.CreateCell(4).SetCellValue(string.Format("Total ({0}):", lstHH.Count + 1));
                    rowTotalHeHang.GetCell(4).CellStyle = leftBold;
                    s1.AddMergedRegion(new CellRangeAddress(row, row, 4, 10));
                    rowTotalHeHang.CreateCell(12).CellFormula = string.Format("M{0} - M{1}", row - 1, row);
                    rowTotalHeHang.GetCell(12).CellStyle = rightBold;

                    lstAmountHH.Add(row);

                    row++;
                    count_row++;
                    startRowHH = row;
                    lstHH.Add(row);
                }
            }
        }

        //vi tri row dau tien
        int m = row - count_row;
        int sub = row + 1;

        string sumAmount = "", sumTotalAmount = "";
        if (nnl != null)
        {   
            s1.CreateRow(row).CreateCell(4).SetCellValue("Sub Total:");
            foreach (var i in lstAmountHH)
            {
                sumAmount += string.Format("M{0}+", i - 1);
                sumTotalAmount += string.Format("M{0}+", i + 1);
            }
            sumAmount += "0";
            sumTotalAmount += "0";

            s1.GetRow(row).CreateCell(7).CellFormula = string.Format("SUM(H{0}:H{1})", m, row - 3);
            s1.GetRow(row).CreateCell(8).CellFormula = string.Format("SUM(I{0}:I{1})", m, row - 3);
            s1.GetRow(row).CreateCell(11).CellFormula = string.Format("SUM(L{0}:L{1})", m, row - 3);
            s1.GetRow(row).CreateCell(12).CellFormula = string.Format("{0}", sumAmount);
        }
        else
        {
            s1.CreateRow(row).CreateCell(4).SetCellValue("Sub Total:");
            s1.GetRow(row).CreateCell(7).CellFormula = String.Format("SUM(H{0}:H{1})", m, row);
            s1.GetRow(row).CreateCell(8).CellFormula = String.Format("SUM(I{0}:I{1})", m, row);
            s1.GetRow(row).CreateCell(11).CellFormula = String.Format("SUM(L{0}:L{1})", m, row);
            s1.GetRow(row).CreateCell(12).CellFormula = String.Format("SUM(M{0}:M{1})", m, row);
        }

        //s1.GetRow(13).GetCell(0).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.0");

        //tru so dong du
        //start tong cong total
        
        //start tong cong 1
        
        s1.GetRow(row).CreateCell(20).SetCellValue(discount);
        // style
        s1.GetRow(row).GetCell(4).CellStyle = leftBold;
        s1.GetRow(row).GetCell(7).CellStyle = rightBold;
        s1.GetRow(row).GetCell(8).CellStyle = rightBold0;
        s1.GetRow(row).GetCell(11).CellStyle = rightBold3;
        s1.GetRow(row).GetCell(12).CellStyle = rightBold;


        // for(int nht = 7; nht <= 7; nht++)
        // {
        // s1.GetRow(row).GetCell(nht).CellStyle = rightBold;
        // s1.GetRow(row).GetCell(nht).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
        // }						
        row++;
        //end
        //start giam gia

        int dis = row + 1;
        if (nnl == null)
        {
            s1.CreateRow(row).CreateCell(4).SetCellValue("Discount (" + discount1 + "%):");

            string str_dsc1 = discount.ToString();
            string funcDiscount = "";
            if (str_dsc1.Contains("."))
            {
                string dot1 = str_dsc1.Split('.')[1];
                if (dot1.Length > 2)
                {
                    funcDiscount = "M{0}*U{0}/100";
                }
                else
                {
                    funcDiscount = "ROUND(M{0}*U{0}/100,2)";
                }
            }
            else
            {
                funcDiscount = "ROUND(M{0}*U{0}/100,2)";
            }
            s1.GetRow(row).CreateCell(12).CellFormula = String.Format(funcDiscount, row, row);
            s1.GetRow(row).GetCell(4).CellStyle = leftBold;
            s1.GetRow(row).GetCell(12).CellStyle = rightBold;
            s1.GetRow(row).GetCell(12).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
            if (discount1 <= 0)
            {
                s1.GetRow(row).HeightInPoints = 0;
                s1.GetRow(row).ZeroHeight = true;
                if (type == "pdf")
                {
                    s1.GetRow(row).RemoveCell(s1.GetRow(row).GetCell(4));
                    s1.GetRow(row).RemoveCell(s1.GetRow(row).GetCell(12));
                }
            }
            row++;
        }

        //end
        int cong = row + 1;
        s1.CreateRow(row).CreateCell(4).SetCellValue("(+) " + dt.Rows[0]["diengiaicong"].ToString());
        //s1.GetRow(row).CreateCell(12).SetCellValue(dt.Rows[0]["phicong"].ToString());
        s1.GetRow(row).CreateCell(12).CellFormula = String.Format("Value(\"{0}\")", dt.Rows[0]["phicong"].ToString());
        // style
        s1.GetRow(row).GetCell(4).CellStyle = leftBold;
        s1.GetRow(row).GetCell(12).CellStyle = rightBold;
        row++;
        //
        int tru = row + 1;
        s1.CreateRow(row).CreateCell(4).SetCellValue("(-) " + dt.Rows[0]["diengiaitru"].ToString());
        //s1.GetRow(row).CreateCell(12).SetCellValue(dt.Rows[0]["phitru"].ToString());
        s1.GetRow(row).CreateCell(12).CellFormula = String.Format("Value(\"{0}\")", dt.Rows[0]["phitru"].ToString());
        // style
        s1.GetRow(row).GetCell(4).CellStyle = leftBold;
        s1.GetRow(row).GetCell(12).CellStyle = rightBold;
        row++;
        //
        string totalTxt = "";
        for (var i = 0; i < lstAmountHH.Count; i++)
            totalTxt += string.Format("({0})+", i+1);
        totalTxt = totalTxt.Length > 0 ? totalTxt.Substring(0, totalTxt.Length - 1) : "";
        string txtTotal = nnl == null ? "Total:" : string.Format("Total {0}:", totalTxt);
        s1.CreateRow(row).CreateCell(4).SetCellValue(txtTotal);
        s1.GetRow(row).CreateCell(12).CellFormula = String.Format("{0} - {1} + M{2} - M{3}"
            , nnl == null ? "M" + sub : sumTotalAmount
            , nnl == null ? "M" + dis : "0"
            , cong
            , tru);
        s1.GetRow(row).GetCell(4).CellStyle = leftBold;
        s1.GetRow(row).GetCell(12).CellStyle = rightBold;
        s1.GetRow(row).GetCell(12).CellStyle.DataFormat = CellDataFormat.GetDataFormat(hssfworkbook, "#,##0.00");
        row++;
        //
        s1.CreateRow(row).CreateCell(0).SetCellValue("Say: " + dt.Rows[0]["money"].ToString());
        s1.GetRow(row).GetCell(0).CellStyle = rightBold;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 12));
        row++;
        //
        s1.CreateRow(row).CreateCell(0).SetCellValue("(10% more or less in quantity and amount are acceptable).");
        s1.GetRow(row).GetCell(0).CellStyle = rightBold;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 12));
        row++;
        //set A6 - A12
        string[] f = { "No. of Container(s):", "Port of loading:", "Port of discharge:", "Shipment Time:", "Payment term:", "Bank Details:" };
        string[] f_value = { "no_cont", "ten_cangbien", "portdischarge", "shipmenttime", "ten_paymentterm", "mota" };
        for (int i = 0; i < f.Count(); i++)
        {
            s1.CreateRow(row).CreateCell(1).SetCellValue(f[i]);
            s1.GetRow(row).CreateCell(3).SetCellValue(dt.Rows[0][f_value[i]].ToString());
            heigh = 22;
            if (i == 5)
                heigh = 95;
            s1.GetRow(row).GetCell(1).CellStyle = celltext;
            s1.GetRow(row).GetCell(3).CellStyle = celltext;
            s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 2));
            s1.AddMergedRegion(new CellRangeAddress(row, row, 3, 12));
            s1.GetRow(row).HeightInPoints = heigh;
            row++;
        }
        //
        s1.CreateRow(row).CreateCell(1).SetCellValue("This agreement comes into effect from the signing date.:");
        s1.GetRow(row).GetCell(1).CellStyle = left;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 12));
        row++;
        row++;
        //
        s1.CreateRow(row).CreateCell(0).SetCellValue("CONFIRMED BY THE BUYER");
        s1.GetRow(row).GetCell(0).CellStyle = signBold;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 4));
        //
        s1.GetRow(row).CreateCell(5).SetCellValue("ANCO COMPANY LTD.");
        s1.GetRow(row).GetCell(5).CellStyle = signBold;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 5, 12));
        row++;
        //
        s1.CreateRow(row).CreateCell(5).SetCellValue("(Signed)");
        s1.GetRow(row).GetCell(5).CellStyle = signBold;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 5, 12));
        row++;

        ICellStyle cellUn = hssfworkbook.CreateCellStyle();
        IFont funderline = hssfworkbook.CreateFont();
        funderline.Underline = FontUnderlineType.Single;
        funderline.FontHeightInPoints = 12;
        cellUn.SetFont(funderline);
        cellUn.Alignment = HorizontalAlignment.Center;
        cellUn.VerticalAlignment = VerticalAlignment.Top;
        s1.GetRow(2).GetCell(0).CellStyle = cellUn;

        s1 = config.PrintExcel((HSSFSheet)s1, row);

        if (type == "pdf")
        {
            s1.PrintSetup.Landscape = false;
            //s1.SetColumnHidden(14, true);
            //s1.SetColumnHidden(15, true);
            //s1.SetColumnHidden(16, true);
        }
        else
            s1.PrintSetup.Landscape = true;
        return hssfworkbook;
    }

    public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName)
    {
        var workbook = new Spire.Xls.Workbook();
        //xuất Excel không áp dụng Spire.Xls
        if (type != "pdf")
        {
            foreach (var item in lstimage)
            {
                var row = int.Parse(item["row"]);
                var column = int.Parse(item["column"]);
                var link = item["link"];
                var image = System.Drawing.Image.FromFile(link);

                MemoryStream ms = new MemoryStream();
                //pull the memory stream from the image (I need this for the byte array later)
                image.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
                //the drawing patriarch will hold the anchor and the master information
                IDrawing patriarch = hsswb.GetSheetAt(0).CreateDrawingPatriarch();
                //store the coordinates of which cell and where in the cell the image goes
                int intx1 = column - 1;
                int inty1 = row;
                int intx2 = column;
                int inty2 = 1 + row;

                HSSFClientAnchor anchor = new HSSFClientAnchor(0, 0, 0, 0, intx1, inty1, intx2, inty2);
                //types are 0, 2, and 3. 0 resizes within the cell, 2 doesn’t
                anchor.AnchorType = 0;
                //add the byte array and encode it for the excel file
                int index = hsswb.AddPicture(ms.ToArray(), PictureType.JPEG);
                IPicture signaturePicture = patriarch.CreatePicture(anchor, index);
            }

            MemoryStream exportData = new MemoryStream();
            hsswb.Write(exportData);
            hsswb.Clear();

            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", saveAsFileName));
            Response.Clear();
            Response.BinaryWrite(exportData.GetBuffer());
            Response.End();
        }
        //xuất Excel có áp dụng Spire.Xls
        else
        {
            var fileName = "PO_" + c_donhang_id;
            string url = Server.MapPath(string.Format(@"ReportPdf/{0}.xls", fileName));
            url = url.Replace("PrintControllers\\InDonHang\\", "");
            var file = new FileStream(url, FileMode.Create);
            hsswb.Write(file);
            file.Close();

            workbook.LoadFromFile(url);

            foreach (var item in lstimage)
            {
                var row = int.Parse(item["row"]) + 1;
                var column = int.Parse(item["column"]);
                var width = int.Parse(item["width"]) * 0.0273;
                double height = double.Parse(item["height"]) * 1.332;
                var widthR = int.Parse(item["widthR"]);
                var heightR = int.Parse(item["heightR"]);
                double percent = height / heightR;
                var link = item["link"];
                var picture = workbook.ActiveSheet.Pictures.Add(row, column, link);
                if (type != "pdf")
                    picture.UpdatePositions = true;
                picture.Width = (int)(widthR * percent);
                picture.Height = (int)(heightR * percent - 3.5);
                Response.Write("picture.Width:" + picture.Width);
                Response.Write("widthColumn:" + width);
                var rateColumnAndPicture = (width - picture.Width) / 2 * 8;
                picture.LeftColumnOffset = (int)rateColumnAndPicture;
                picture.TopRowOffset = 5;
            }
            workbook.Save();

            if (type == "pdf")
            {
                var urlPDF = url.Replace(fileName + ".xls", fileName + ".pdf");
                workbook.SaveToFile(urlPDF, Spire.Xls.FileFormat.PDF);
                workbook.Dispose();
                File.Delete(url);

                Response.Redirect(string.Format("../../ReportPdf/{0}.pdf?{1}", fileName, Guid.NewGuid().ToString()));
            }
            else
            {
                MemoryStream exportData = new MemoryStream();
                workbook.SaveToStream(exportData);
                workbook.Dispose();
                File.Delete(url);

                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", saveAsFileName));
                Response.Clear();
                Response.BinaryWrite(exportData.GetBuffer());
                Response.End();
            }
        }
    }
}
