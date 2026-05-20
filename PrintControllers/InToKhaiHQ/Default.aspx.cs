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
using NPOI.HSSF.Record.Chart;

public partial class PrintControllers_InToKhaiHQ_Default : System.Web.UI.Page
{
    public string doiDVT(string dvt)
    {
        if (dvt == "pc")
            return "CAI";
        else
            return "BO";
    }
    // 
    //  <td>
    // 
    //   </td> 
    //
    //
    //  

    protected void Page_Load(object sender, EventArgs e)
    {
        //try
        //{
        String c_pkivn_id = Request.QueryString["c_packinglist_id"];
        String select = $@"
            select 
                cpk.so_pkl, 
                cpk.ngaylap, 
                dt.ten_dtkd, 
                dt.diachi, 
                dt.tel, 
                dt.fax,
	            cpk.mv, 
                cb.ten_cangbien, 
                cpk.noiden, 
                cpk.blno, 
                cpk.commodity, 
                cpk.etd2, 
                cpk.commodityvn,  
                diengiaicong_po, 
                giatricong_po, 
                diengiaitru_po, 
                giatritru_po
            from 
                c_packinginvoice cpk
                left join md_doitackinhdoanh dt on cpk.md_doitackinhdoanh_id = dt.md_doitackinhdoanh_id 
                left join md_cangbien cb on cpk.noidi = cb.md_cangbien_id
            where 
                1=1
	            and cpk.c_packinginvoice_id ='{c_pkivn_id}'
        ";
        DataTable dt = mdbc.GetData(select);

        String selChungTuDH = $@"
            select top (1) 
                dh.sochungtu, 
                dh.ngaylap, 
                dh.customer_order_no, 
                ngh.thongtin, 
                pmt.ma_paymentterm, 
                pmt.ten_paymentterm, 
                spd.Consignee, 
                dh.payer,
                cb.ten_cangbien,
                spd.POD
            from 
                c_donhang dh
                left join c_dongpklinv dpkl on dh.c_donhang_id = dpkl.c_donhang_id
                left join md_paymentterm pmt on pmt.md_paymentterm_id = dh.md_paymentterm_id
                left join md_nganhang ngh on ngh.md_nganhang_id = dh.md_nganhang_id
                left join md_cangbien cb on cb.md_cangbien_id = dh.md_cangbien_id
                outer apply (select top 1 Consignee, Forwarder, POD from c_donhang_spd where c_donhang_id = dh.c_donhang_id and trangthai = 'DAGUI' order by ngaytao desc) spd
            where 
                1=1
                AND dpkl.c_packinginvoice_id = N'{c_pkivn_id}'
            order by 
                dh.ngaytao asc
        ";

        DataTable dtChungTuDH = mdbc.GetData(selChungTuDH);
        string chungTuDH = dtChungTuDH.Rows[0][0].ToString();
        var ngayLapDH = (dtChungTuDH.Rows[0][1] as DateTime?).Value;
        string customerNo = dtChungTuDH.Rows[0][2].ToString();
        string nganhang = dtChungTuDH.Rows[0][3].ToString();
        string ma_paymentterm = dtChungTuDH.Rows[0][4].ToString();
        string paymentterm = dtChungTuDH.Rows[0][5].ToString();
        string Consignee = dtChungTuDH.Rows[0][6].ToString();
        string payer = dtChungTuDH.Rows[0][7].ToString();
        string from = dtChungTuDH.Rows[0][8].ToString();
        string to = dtChungTuDH.Rows[0][9].ToString();

        if (dt.Rows.Count != 0)
        {
            HSSFWorkbook hssfworkbook = this.CreateWorkBookPO(dt, from, to);
            String saveAsFileName = String.Format("ToKhaiHaiQuan-{0}.xls", DateTime.Now);
            this.SaveFile(hssfworkbook, saveAsFileName);
        }
        else
        {
            Response.Write("<h3>PackingList/Invoice không có dữ liệu</h3>");
        }
        //}
        //catch (Exception ex)
        //{
        //    Response.Write(String.Format("<h3>Quá trình chiếc xuất xảy ra lỗi {0}</h3>", ex.Message));
        //}
    }

    public HSSFWorkbook CreateWorkBookPO(DataTable dt, string from, string to)
    {
        LinqDBDataContext db = new LinqDBDataContext();
        String c_pkivn_id = Request.QueryString["c_packinglist_id"];
        var pdkInvoice = db.c_packinginvoices.Single(inv => inv.c_packinginvoice_id.Equals(c_pkivn_id));

        HSSFWorkbook hssfworkbook = new HSSFWorkbook();
        ISheet s1 = hssfworkbook.CreateSheet("Sheet1");

        IFont font12 = hssfworkbook.CreateFont();
        font12.FontHeightInPoints = 12;

        IFont font12Bold = hssfworkbook.CreateFont();
        font12Bold.FontHeightInPoints = 12;
        font12Bold.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.Bold;

        IFont font16Bold = hssfworkbook.CreateFont();
        font16Bold.FontHeightInPoints = 16;
        font16Bold.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.Bold;

        IFont font12BoldItalic = hssfworkbook.CreateFont();
        font12BoldItalic.FontHeightInPoints = 12;
        font12BoldItalic.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.Bold;
        font12BoldItalic.IsItalic = true;

        IFont font22Bold = hssfworkbook.CreateFont();
        font22Bold.FontHeightInPoints = 22;
        font22Bold.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.Bold;

        IFont font14Bold = hssfworkbook.CreateFont();
        font14Bold.FontHeightInPoints = 14;
        font14Bold.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.Bold;

        IFont font18Bold = hssfworkbook.CreateFont();
        font18Bold.FontHeightInPoints = 18;
        font18Bold.Boldweight = (short)NPOI.SS.UserModel.FontBoldWeight.Bold;

        // Cell Style 
        ICellStyle styleCenter18Bold = hssfworkbook.CreateCellStyle();
        styleCenter18Bold.SetFont(font18Bold);
        styleCenter18Bold.VerticalAlignment = VerticalAlignment.Top;
        styleCenter18Bold.Alignment = HorizontalAlignment.Center;
        styleCenter18Bold.WrapText = true;

        ICellStyle styleTop14Bold = hssfworkbook.CreateCellStyle();
        styleTop14Bold.SetFont(font14Bold);
        styleTop14Bold.VerticalAlignment = VerticalAlignment.Top;
        styleTop14Bold.WrapText = true;

        ICellStyle styleCenter22Bold = hssfworkbook.CreateCellStyle();
        styleCenter22Bold.SetFont(font22Bold);
        styleCenter22Bold.VerticalAlignment = VerticalAlignment.Top;
        styleCenter22Bold.Alignment = HorizontalAlignment.Center;
        styleCenter22Bold.WrapText = true;

        ICellStyle style22Bold = hssfworkbook.CreateCellStyle();
        style22Bold.SetFont(font22Bold);
        style22Bold.VerticalAlignment = VerticalAlignment.Top;
        style22Bold.WrapText = true;

        ICellStyle styleCenter12Bold = hssfworkbook.CreateCellStyle();
        styleCenter12Bold.SetFont(font12Bold);
        styleCenter12Bold.VerticalAlignment = VerticalAlignment.Top;
        styleCenter12Bold.Alignment = HorizontalAlignment.Center;
        styleCenter12Bold.WrapText = true;

        ICellStyle styleCenter16Bold = hssfworkbook.CreateCellStyle();
        styleCenter16Bold.SetFont(font16Bold);
        styleCenter16Bold.VerticalAlignment = VerticalAlignment.Top;
        styleCenter16Bold.Alignment = HorizontalAlignment.Center;
        styleCenter16Bold.WrapText = true;

        ICellStyle styleRight12Bold = hssfworkbook.CreateCellStyle();
        styleRight12Bold.SetFont(font12Bold);
        styleRight12Bold.VerticalAlignment = VerticalAlignment.Top;
        styleRight12Bold.Alignment = HorizontalAlignment.Right;
        styleRight12Bold.WrapText = true;

        ICellStyle styleCenterBorder12Bold = hssfworkbook.CreateCellStyle();
        styleCenterBorder12Bold.SetFont(font12Bold);
        styleCenterBorder12Bold.VerticalAlignment = VerticalAlignment.Top;
        styleCenterBorder12Bold.Alignment = HorizontalAlignment.Center;
        styleCenterBorder12Bold.WrapText = true;
        styleCenterBorder12Bold.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleCenterBorder12Bold.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleCenterBorder12Bold.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleCenterBorder12Bold.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;

        ICellStyle styleBorder12Bold = hssfworkbook.CreateCellStyle();
        styleBorder12Bold.SetFont(font12Bold);
        styleBorder12Bold.VerticalAlignment = VerticalAlignment.Top;
        styleBorder12Bold.WrapText = true;
        styleBorder12Bold.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12Bold.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12Bold.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12Bold.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;

        ICellStyle styleBorder12Bold_noWrap = hssfworkbook.CreateCellStyle();
        styleBorder12Bold_noWrap.SetFont(font12Bold);
        styleBorder12Bold_noWrap.VerticalAlignment = VerticalAlignment.Top;
        styleBorder12Bold_noWrap.WrapText = false;
        styleBorder12Bold_noWrap.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12Bold_noWrap.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12Bold_noWrap.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12Bold_noWrap.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;

        ICellStyle styleCenterBorderBottom12 = hssfworkbook.CreateCellStyle();
        styleCenterBorderBottom12.SetFont(font12);
        styleCenterBorderBottom12.VerticalAlignment = VerticalAlignment.Top;
        styleCenterBorderBottom12.Alignment = HorizontalAlignment.Center;
        styleCenterBorderBottom12.WrapText = true;
        styleCenterBorderBottom12.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;

        ICellStyle style12BoldItalic = hssfworkbook.CreateCellStyle();
        style12BoldItalic.SetFont(font12BoldItalic);
        style12BoldItalic.VerticalAlignment = VerticalAlignment.Top;
        style12BoldItalic.WrapText = true;

        ICellStyle styleCenter12 = hssfworkbook.CreateCellStyle();
        styleCenter12.SetFont(font12);
        styleCenter12.VerticalAlignment = VerticalAlignment.Top;
        styleCenter12.Alignment = HorizontalAlignment.Center;
        styleCenter12.WrapText = true;

        ICellStyle style12 = hssfworkbook.CreateCellStyle();
        style12.SetFont(font12);
        style12.VerticalAlignment = VerticalAlignment.Top;
        style12.WrapText = true;

        ICellStyle style12_noWrap = hssfworkbook.CreateCellStyle();
        style12_noWrap.SetFont(font12);
        style12_noWrap.VerticalAlignment = VerticalAlignment.Top;
        style12_noWrap.WrapText = false;

        ICellStyle style12Bold = hssfworkbook.CreateCellStyle();
        style12Bold.SetFont(font12Bold);
        style12Bold.VerticalAlignment = VerticalAlignment.Top;
        style12Bold.WrapText = true;

        ICellStyle style12TopBold = hssfworkbook.CreateCellStyle();
        style12TopBold.SetFont(font12Bold);
        style12TopBold.VerticalAlignment = VerticalAlignment.Top;
        style12TopBold.WrapText = true;

        ICellStyle style12Top = hssfworkbook.CreateCellStyle();
        style12Top.SetFont(font12);
        style12Top.VerticalAlignment = VerticalAlignment.Top;
        style12Top.WrapText = true;

        ICellStyle styleBorder12 = hssfworkbook.CreateCellStyle();
        styleBorder12.SetFont(font12);
        styleBorder12.VerticalAlignment = VerticalAlignment.Top;
        styleBorder12.WrapText = true;
        styleBorder12.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorder12.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;

        ICellStyle styleBorderCenter12 = hssfworkbook.CreateCellStyle();
        styleBorderCenter12.SetFont(font12);
        styleBorderCenter12.VerticalAlignment = VerticalAlignment.Top;
        styleBorderCenter12.Alignment = HorizontalAlignment.Center;
        styleBorderCenter12.WrapText = true;
        styleBorderCenter12.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorderCenter12.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorderCenter12.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleBorderCenter12.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;

        ICellStyle styleNumber0Border12 = hssfworkbook.CreateCellStyle();
        styleNumber0Border12.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0");
        styleNumber0Border12.SetFont(font12);
        styleNumber0Border12.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0Border12.Alignment = HorizontalAlignment.Right;
        styleNumber0Border12.WrapText = true;
        styleNumber0Border12.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0Border12.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0Border12.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0Border12.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;


        ICellStyle styleNumber0i0Border12 = hssfworkbook.CreateCellStyle();
        styleNumber0i0Border12.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.0");
        styleNumber0i0Border12.SetFont(font12);
        styleNumber0i0Border12.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i0Border12.Alignment = HorizontalAlignment.Right;
        styleNumber0i0Border12.WrapText = true;
        styleNumber0i0Border12.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i0Border12.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i0Border12.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i0Border12.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;


        ICellStyle styleNumber0i00Border12 = hssfworkbook.CreateCellStyle();
        styleNumber0i00Border12.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.00");
        styleNumber0i00Border12.SetFont(font12);
        styleNumber0i00Border12.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i00Border12.Alignment = HorizontalAlignment.Right;
        styleNumber0i00Border12.WrapText = true;
        styleNumber0i00Border12.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i00Border12.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i00Border12.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i00Border12.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;


        ICellStyle styleNumber0i000Border12 = hssfworkbook.CreateCellStyle();
        styleNumber0i000Border12.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.000");
        styleNumber0i000Border12.SetFont(font12);
        styleNumber0i000Border12.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i000Border12.Alignment = HorizontalAlignment.Right;
        styleNumber0i000Border12.WrapText = true;
        styleNumber0i000Border12.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i000Border12.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i000Border12.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        styleNumber0i000Border12.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;



        ICellStyle styleNumber012 = hssfworkbook.CreateCellStyle();
        styleNumber012.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0");
        styleNumber012.SetFont(font12);
        styleNumber012.VerticalAlignment = VerticalAlignment.Top;
        styleNumber012.Alignment = HorizontalAlignment.Right;
        styleNumber012.WrapText = true;


        ICellStyle styleNumber0i012 = hssfworkbook.CreateCellStyle();
        styleNumber0i012.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.0");
        styleNumber0i012.SetFont(font12);
        styleNumber0i012.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i012.Alignment = HorizontalAlignment.Right;
        styleNumber0i012.WrapText = true;


        ICellStyle styleNumber0i0012 = hssfworkbook.CreateCellStyle();
        styleNumber0i0012.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.00");
        styleNumber0i0012.SetFont(font12);
        styleNumber0i0012.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i0012.Alignment = HorizontalAlignment.Right;
        styleNumber0i0012.WrapText = true;

        ICellStyle styleNumber0i00012 = hssfworkbook.CreateCellStyle();
        styleNumber0i00012.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.000");
        styleNumber0i00012.SetFont(font12);
        styleNumber0i00012.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i00012.Alignment = HorizontalAlignment.Right;
        styleNumber0i00012.WrapText = true;


        ICellStyle styleNumber012Bold = hssfworkbook.CreateCellStyle();
        styleNumber012Bold.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0");
        styleNumber012Bold.SetFont(font12Bold);
        styleNumber012Bold.VerticalAlignment = VerticalAlignment.Top;
        styleNumber012Bold.Alignment = HorizontalAlignment.Right;
        styleNumber012Bold.WrapText = true;


        ICellStyle styleNumber0i012Bold = hssfworkbook.CreateCellStyle();
        styleNumber0i012Bold.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.0");
        styleNumber0i012Bold.SetFont(font12Bold);
        styleNumber0i012Bold.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i012Bold.Alignment = HorizontalAlignment.Right;
        styleNumber0i012Bold.WrapText = true;


        ICellStyle styleNumber0i0012Bold = hssfworkbook.CreateCellStyle();
        styleNumber0i0012Bold.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.00");
        styleNumber0i0012Bold.SetFont(font12Bold);
        styleNumber0i0012Bold.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i0012Bold.Alignment = HorizontalAlignment.Right;
        styleNumber0i0012Bold.WrapText = true;

        ICellStyle styleNumber0i00012Bold = hssfworkbook.CreateCellStyle();
        styleNumber0i00012Bold.DataFormat = NPOIUtils.GetDataFormat(hssfworkbook, "#,#0.000");
        styleNumber0i00012Bold.SetFont(font12Bold);
        styleNumber0i00012Bold.VerticalAlignment = VerticalAlignment.Top;
        styleNumber0i00012Bold.Alignment = HorizontalAlignment.Right;
        styleNumber0i00012Bold.WrapText = true;



        s1.SetColumnWidth(0, 5000);
        s1.SetColumnWidth(1, 3500);
        s1.SetColumnWidth(2, 6500);
        s1.SetColumnWidth(3, 3500);
        s1.SetColumnWidth(4, 3500);

        s1.SetColumnWidth(8, 4000);
        s1.SetColumnWidth(9, 4000);
        s1.SetColumnHidden(10, true);
        s1.SetColumnHidden(11, true);
        s1.SetColumnHidden(12, true);
        s1.SetColumnHidden(13, true);
        s1.SetColumnHidden(14, true);


        s1.SetMargin(MarginType.RightMargin, (double)0.5);
        s1.SetMargin(MarginType.TopMargin, (double)0.6);
        s1.SetMargin(MarginType.LeftMargin, (double)0.4);
        s1.SetMargin(MarginType.BottomMargin, (double)0.3);
        s1.FitToPage = true;

        IPrintSetup print = s1.PrintSetup;
        print.PaperSize = (short)PaperSize.A4;
        print.Scale = (short)80;
        print.FitWidth = (short)1;
        print.FitHeight = (short)0;

        int rowVNN = 0;
        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("HẢI QUAN VIỆT NAM");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style22Bold;
        s1.GetRow(rowVNN).HeightInPoints = 45;
        s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 0, 8));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("DANH MỤC KÈM THEO TỜ KHAI HÀNG HOÁ XUẤT KHẨU");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style12;
        s1.GetRow(rowVNN).HeightInPoints = 22;
        s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 0, 11));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("TKHQ SỐ:………………………/KV………………………….NGÀY……..THÁNG……….NĂM………….");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style12;
        s1.GetRow(rowVNN).HeightInPoints = 22;
        s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 0, 8));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(5).SetCellValue("No.:");
        s1.GetRow(rowVNN).GetCell(5).CellStyle = style12Bold;
        s1.GetRow(rowVNN).CreateCell(6).SetCellValue(dt.Rows[0]["so_pkl"].ToString());
        s1.GetRow(rowVNN).GetCell(6).CellStyle = style12Bold;
        s1.GetRow(rowVNN).HeightInPoints = 22;
        s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 6, 8));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(5).SetCellValue("Date");
        s1.GetRow(rowVNN).GetCell(5).CellStyle = style12Bold;
        s1.GetRow(rowVNN).HeightInPoints = 22;
        s1.GetRow(rowVNN).CreateCell(6).SetCellValue(DateTime.Now.ToString("dd-MMM-yyyy"));
        s1.GetRow(rowVNN).GetCell(6).CellStyle = style12Bold;
        s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 6, 8));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("Người mua:");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style12TopBold;
        string dc_kh = "";
        dc_kh = dt.Rows[0]["ten_dtkd"].ToString() + "\nAddress:" + dt.Rows[0]["diachi"].ToString() + "\nTel:" + dt.Rows[0]["tel"].ToString() + "\nFax:" + dt.Rows[0]["fax"].ToString();
        HSSFRichTextString rich = new HSSFRichTextString(dc_kh);
        s1.GetRow(rowVNN).CreateCell(2).SetCellValue(rich);
        s1.GetRow(rowVNN).GetCell(2).CellStyle = style12TopBold;
        s1.GetRow(rowVNN).HeightInPoints = 95;
        s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 2, 8));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("Tên tàu:");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style12;
        s1.GetRow(rowVNN).CreateCell(2).SetCellValue(dt.Rows[0]["mv"].ToString());
        s1.GetRow(rowVNN).GetCell(2).CellStyle = style12_noWrap;
        //s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 2, 8));
        s1.GetRow(rowVNN).HeightInPoints = 22;
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("Ngày tàu chạy:");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style12;
        var date_etd2 = dt.Rows[0]["etd2"].ToString().ToNullableDate();
        s1.GetRow(rowVNN).CreateCell(2).SetCellValue(date_etd2 == null ? "" : date_etd2.Value.ToString(Extension.fmtDate));
        s1.GetRow(rowVNN).GetCell(2).CellStyle = style12_noWrap;
        s1.GetRow(rowVNN).HeightInPoints = 22;
        //s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 2, 8));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("Cảng đi:");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style12;
        s1.GetRow(rowVNN).CreateCell(2).SetCellValue(from);
        s1.GetRow(rowVNN).GetCell(2).CellStyle = style12_noWrap;
        s1.GetRow(rowVNN).HeightInPoints = 22;
        //s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 2, 8));
        rowVNN++;

        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("Cảng đến:");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = style12;
        s1.GetRow(rowVNN).CreateCell(2).SetCellValue(to);
        s1.GetRow(rowVNN).GetCell(2).CellStyle = style12_noWrap;
        s1.GetRow(rowVNN).HeightInPoints = 22;
        //s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 2, 8));
        rowVNN++;

        //s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("Hàng hóa:");
        //s1.GetRow(rowVNN).GetCell(0).CellStyle = style12;
        //s1.GetRow(rowVNN).CreateCell(2).SetCellValue(dt.Rows[0]["commodityvn"].ToString());
        //s1.GetRow(rowVNN).GetCell(2).CellStyle = style12;
        //s1.GetRow(rowVNN).HeightInPoints = 22;
        //s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 2, 8));
        //rowVNN++;

        //table
        s1.CreateRow(rowVNN).CreateCell(0).SetCellValue("Mã số");
        s1.GetRow(rowVNN).CreateCell(1).SetCellValue("Mã số khách");
        s1.GetRow(rowVNN).CreateCell(2).SetCellValue("Diễn giải");
        s1.GetRow(rowVNN).CreateCell(3).SetCellValue("Mã HS 8 số");
        s1.GetRow(rowVNN).CreateCell(4).SetCellValue("Xuất sứ");
        s1.GetRow(rowVNN).CreateCell(5).SetCellValue("Số lượng(cái/bộ)");
        s1.GetRow(rowVNN).CreateCell(6).SetCellValue("Đơn vị tính");
        s1.GetRow(rowVNN).CreateCell(7).SetCellValue("Đơn giá");
        s1.GetRow(rowVNN).CreateCell(8).SetCellValue("Thành tiền");
        s1.GetRow(rowVNN).CreateCell(9).SetCellValue("SL cái cho từng mã hàng");
        s1.GetRow(rowVNN).CreateCell(10).SetCellValue("NW");
        s1.GetRow(rowVNN).CreateCell(11).SetCellValue("GW");
        s1.GetRow(rowVNN).CreateCell(12).SetCellValue("CBM");
        s1.GetRow(rowVNN).CreateCell(13).SetCellValue("Số kiện");
        s1.GetRow(rowVNN).GetCell(0).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(1).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(2).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(3).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(4).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(5).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(6).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(7).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(8).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(9).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(10).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(11).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(12).CellStyle = styleCenterBorder12Bold;
        s1.GetRow(rowVNN).GetCell(13).CellStyle = styleCenterBorder12Bold;
        //s1.AddMergedRegion(new CellRangeAddress(rowVNN, rowVNN, 3, 4));
        rowVNN++;

        string sql_group = $@"
            select distinct 
                dpk.c_donhang_id, 
                dh.sochungtu as sodh, 
                convert(decimal(18,2), po.discountPO) as discount, 
		        po.discountPO as discount1,
                po.hehang_value as discount_hehang_value,
		        cnx.container, 
                cnx.soseal, 
                cb.ten_cangbien, 
                cnx.c_nhapxuat_id
            from c_dongpklinv dpk, 
                c_packinginvoice cpk, 
                c_donhang dh outer APPLY (select * from dbo.ftbl_getInfoPO(dh.phanbodiscount, dh.discount, null, dh.discount_hehang_value)) as po, 
                c_dongnhapxuat dnx, 
                c_nhapxuat cnx, 
                md_cangbien cb
            where dpk.c_packinginvoice_id = '{c_pkivn_id}'
                and dpk.c_donhang_id = dh.c_donhang_id
		        and dpk.c_dongnhapxuat_id = dnx.c_dongnhapxuat_id
		        and dnx.c_nhapxuat_id = cnx.c_nhapxuat_id
                and dpk.c_packinginvoice_id = cpk.c_packinginvoice_id
		        and cpk.noidi = cb.md_cangbien_id
        ";
        DataTable dt_g = mdbc.GetData(sql_group);

        string dh_ = @"select distinct c_donhang_id, sodh, container, soseal , discount, discount1, discount_hehang_value, c_nhapxuat_id, ten_cangbien from (" + sql_group + ") as tmp order by container asc, sodh asc";
        DataTable data_dh = mdbc.GetData(dh_);

        int g_line = 0;
        int r = rowVNN;
        int countDonHang = data_dh.Rows.Count;
        int count = 1;
        double sumDiscount = 0;
        List<int> lstQuantity = new List<int>();
        List<int> lstNoOfPack = new List<int>();
        List<int> lstTotalSalary = new List<int>();
        List<int> lstDiscount = new List<int>();
        List<int> lstNW = new List<int>();
        List<int> lstGW = new List<int>();
        List<int> lstCBM = new List<int>();
        String funcDiscount = "";

        foreach (DataRow g_it in data_dh.Rows)
        {
            string discount_hehang_value = g_it["discount_hehang_value"].ToString();
            var nnl = string.IsNullOrEmpty(discount_hehang_value) ? null : Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(discount_hehang_value);

            s1.CreateRow(r).CreateCell(0).SetCellValue("");
            s1.GetRow(r).CreateCell(0).SetCellValue("P/I No. " + g_it["sodh"].ToString());
            if (g_line == 0)
            {
                s1.GetRow(r).CreateCell(5).SetCellValue("FOB " + g_it["ten_cangbien"].ToString());
            }
            else
            {
                s1.GetRow(r).CreateCell(5).SetCellValue("");
            }
            g_line++;

            s1.GetRow(r).GetCell(0).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(1).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(2).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(3).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(4).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).GetCell(5).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(6).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(7).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(8).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(9).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(10).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(11).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(12).CellStyle = styleBorder12Bold_noWrap;
            s1.GetRow(r).CreateCell(13).CellStyle = styleBorder12Bold_noWrap;

            //s1.AddMergedRegion(new CellRangeAddress(r, r, 0, 4));
            //s1.AddMergedRegion(new CellRangeAddress(r, r, 5, 8));

            string sql_de = $@"
                select 
                    ma_sanpham, ma_sanpham_khach, noofpack, soluong, gia, thanhtien, l1, w1, h1, l2, w2, h2,
					mota_tiengviet, ten_dvt, sl_outer, sl_outer_dg, dvt_outer, cbm, nkg, sl_inner, sl_outer, hscode,
				    case 
                        when sl_inner > 1 then round((((l1+w1)*(w1 + h1) / 5400 ) * sl_outer / sl_inner ) * noofpack + nkg, 2)
						else round(( ((l2+w2)*(w2+h2)) / 5400) * noofpack + nkg, 2)
					end as gkg
				from (
                    select 
                        sp.ma_sanpham, cdd.ma_sanpham_khach, case when cdd.sl_outer = 0 then 0 else round(dpk.soluong/cdd.sl_outer, 1) end as noofpack ,
					    dpk.soluong, dpk.gia, dpk.thanhtien, cdd.l2, cdd.w2, cdd.h2, cdd.l1, cdd.w1, cdd.h1,
					    dpk.mota_tiengviet, dvt.ten_dvt, mdg.sl_outer as sl_outer_dg, 
					    (select ten_dvt from md_donvitinh where md_donvitinh_id = mdg.dvt_outer) as dvt_outer,		
					    case when cdd.sl_outer = 0 then 0 else (round((cdd.l2 * cdd.h2 * cdd.w2/1000000 * dpk.soluong/cdd.sl_outer), 3)) end as cbm,
					    (sp.trongluong*dpk.soluong) as nkg, cdd.sl_inner, cdd.sl_outer, hsc.hscode
					from c_dongpklinv dpk 
                        left join md_sanpham sp on dpk.md_sanpham_id = sp.md_sanpham_id
						left join c_dongnhapxuat cdnx on dpk.c_dongnhapxuat_id = cdnx.c_dongnhapxuat_id
						left join c_dongdonhang cdd on cdnx.c_dongdonhang_id = cdd.c_dongdonhang_id
						left join md_donvitinhsanpham dvt on dvt.md_donvitinhsanpham_id = sp.md_donvitinhsanpham_id
						left join md_donggoi mdg on cdd.md_donggoi_id = mdg.md_donggoi_id
                        left join md_hscode hsc on hsc.md_hscode_id = sp.md_hscode_id
					where dpk.c_donhang_id = '{g_it["c_donhang_id"]}'
						and c_packinginvoice_id = '{c_pkivn_id}'
						and cdnx.c_nhapxuat_id = '{g_it["c_nhapxuat_id"]}'
				) as tmp 
                order by 
                    tmp.ma_sanpham asc
            ";

            DataTable dt_d = mdbc.GetData(sql_de);

            var startRowHH = -1;
            var lstHH = new List<int>();

            for (var i = 0; i < dt_d.Rows.Count; i++)
            {
                r++;
                DataRow g_dt = dt_d.Rows[i];
                var msp = g_dt["ma_sanpham"].ToString();
                var chungloai = msp.Substring(0, 2);
                var bocai = msp.Substring(9, 2);
                var chungloaiTT = i == dt_d.Rows.Count - 1 ? chungloai : dt_d.Rows[i + 1]["ma_sanpham"].ToString().Substring(0, 2);
                if (startRowHH == -1)
                    startRowHH = r;

                IRow ir = s1.CreateRow(r);
                ir.CreateCell(0).SetCellValue(msp);
                ir.GetCell(0).CellStyle = styleBorder12;

                ir.CreateCell(1).SetCellValue(g_dt["ma_sanpham_khach"].ToString());
                ir.GetCell(1).CellStyle = styleBorder12;

                ir.CreateCell(2).SetCellValue(g_dt["mota_tiengviet"].ToString());
                ir.GetCell(2).CellStyle = styleBorder12;

                ir.CreateCell(3).SetCellValue(g_dt["hscode"].ToString());
                ir.GetCell(3).CellStyle = styleBorder12;

                ir.CreateCell(4).SetCellValue("VIETNAM");
                ir.GetCell(4).CellStyle = styleBorder12;

                ir.CreateCell(5).SetCellValue(double.Parse(g_dt["soluong"].ToString()));
                ir.GetCell(5).CellStyle = styleNumber0Border12;

                ir.CreateCell(6).SetCellValue(doiDVT(g_dt["ten_dvt"].ToString()));
                ir.GetCell(6).CellStyle = styleBorder12;

                ir.CreateCell(7).SetCellValue(double.Parse(g_dt["gia"].ToString()));
                ir.GetCell(7).CellStyle = styleNumber0i00Border12;

                ir.CreateCell(8).CellFormula = String.Format("F{0}*H{0}", r + 1);
                //ir.CreateCell(8).SetCellValue(double.Parse(g_dt["thanhtien"].ToString()));
                ir.GetCell(8).CellStyle = styleNumber0i00Border12;

                //int result;
                //bool isNumber = int.TryParse(bocai, out result);
                //ir.CreateCell(9).SetCellValue(isNumber ? bocai.ToNullableInt().Value : 1);
                //ir.GetCell(9).CellStyle = styleNumber0Border12;

                int slCaiChoTungMaHang = LaySLCaiChoTungMaHang(msp);
                ir.CreateCell(9).SetCellValue(slCaiChoTungMaHang); 
                ir.GetCell(9).CellStyle = styleNumber0Border12;


                ir.CreateCell(10).SetCellValue(double.Parse(g_dt["nkg"].ToString()));
                ir.GetCell(10).CellStyle = styleNumber0i00Border12;

                ir.CreateCell(11).SetCellValue(double.Parse(g_dt["gkg"].ToString()));
                ir.GetCell(11).CellStyle = styleNumber0i00Border12;

                ir.CreateCell(12).SetCellValue(double.Parse(g_dt["cbm"].ToString()));
                ir.GetCell(12).CellStyle = styleNumber0i00Border12;

                ir.CreateCell(13).SetCellValue(double.Parse(g_dt["noofpack"].ToString()));
                ir.GetCell(13).CellStyle = styleNumber0i00Border12;

                if ((chungloai != chungloaiTT & i < dt_d.Rows.Count - 1) | i == dt_d.Rows.Count - 1)
                {
                    if (nnl != null)
                    {
                        string gthh = nnl == null ? "0" : nnl.Where(s => s["hehang"].ToString() == chungloai).Select(s => s["giatri"].ToString()).FirstOrDefault();
                        var rowHeight = gthh == "0" ? 0 : 20;
                        r++;
                        var rowToTalHeHang = s1.CreateRow(r);
                        rowToTalHeHang.HeightInPoints = rowHeight;
                        rowToTalHeHang.CreateCell(2).SetCellValue(string.Format("Tổng cộng ({0}):", lstHH.Count + 1));
                        rowToTalHeHang.GetCell(2).CellStyle = style12Bold;
                        s1.AddMergedRegion(new CellRangeAddress(r, r, 0, 1));
                        string fmlSum = string.Format(@"SUM(VNN{0}:VNN{1})", startRowHH + 1, r);
                        rowToTalHeHang.CreateCell(5).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "F"));
                        rowToTalHeHang.GetCell(5).CellStyle = styleNumber012Bold;
                        //rowToTalHeHang.CreateCell(6).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "G"));
                        //rowToTalHeHang.GetCell(6).CellStyle = styleNumber012Bold;
                        rowToTalHeHang.CreateCell(8).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "I"));
                        rowToTalHeHang.GetCell(8).CellStyle = styleNumber0i0012Bold;
                        rowToTalHeHang.CreateCell(9).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "J"));
                        rowToTalHeHang.GetCell(9).CellStyle = styleNumber0i0012Bold;
                        rowToTalHeHang.CreateCell(10).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "K"));
                        rowToTalHeHang.GetCell(10).CellStyle = styleNumber0i0012Bold;
                        rowToTalHeHang.CreateCell(11).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "L"));
                        rowToTalHeHang.GetCell(11).CellStyle = styleNumber0i0012Bold;
                        rowToTalHeHang.CreateCell(12).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "M"));
                        rowToTalHeHang.GetCell(12).CellStyle = styleNumber0i0012Bold;
                        rowToTalHeHang.CreateCell(13).CellFormula = string.Format("{0}", fmlSum.Replace("VNN", "N"));
                        rowToTalHeHang.GetCell(13).CellStyle = styleNumber0i0012Bold;
                        r++;

                        var rowDisHeHang = s1.CreateRow(r);
                        rowDisHeHang.HeightInPoints = rowHeight;
                        rowDisHeHang.CreateCell(2).SetCellValue(string.Format(@"Giảm giá ({0}%):", gthh));
                        rowDisHeHang.GetCell(2).CellStyle = style12Bold;
                        s1.AddMergedRegion(new CellRangeAddress(r, r, 0, 1));
                        rowDisHeHang.CreateCell(8).CellFormula = string.Format("ROUND(I{0}*{1}/100, 2)", r, gthh);
                        rowDisHeHang.GetCell(8).CellStyle = styleNumber0i0012Bold;
                        r++;

                        var rowTotalHeHang = s1.CreateRow(r);
                        rowTotalHeHang.HeightInPoints = rowHeight;
                        rowTotalHeHang.CreateCell(2).SetCellValue(string.Format("Tổng cộng ({0}):", lstHH.Count + 1));
                        rowTotalHeHang.GetCell(2).CellStyle = style12Bold;
                        s1.AddMergedRegion(new CellRangeAddress(r, r, 0, 1));
                        rowTotalHeHang.CreateCell(5).CellFormula = string.Format("F{0}", r - 1);
                        rowTotalHeHang.GetCell(5).CellStyle = styleNumber012Bold;
                        rowTotalHeHang.CreateCell(8).CellFormula = string.Format("I{0} - I{1}", r - 1, r);
                        rowTotalHeHang.GetCell(8).CellStyle = styleNumber0i0012Bold;
                        rowTotalHeHang.CreateCell(9).CellFormula = string.Format("J{0}", r - 1);
                        rowTotalHeHang.GetCell(9).CellStyle = styleNumber0i0012Bold;
                        rowTotalHeHang.CreateCell(10).CellFormula = string.Format("K{0}", r - 1);
                        rowTotalHeHang.GetCell(10).CellStyle = styleNumber0i0012Bold;
                        rowTotalHeHang.CreateCell(11).CellFormula = string.Format("L{0}", r - 1);
                        rowTotalHeHang.GetCell(11).CellStyle = styleNumber0i0012Bold;
                        rowTotalHeHang.CreateCell(12).CellFormula = string.Format("M{0}", r - 1);
                        rowTotalHeHang.GetCell(12).CellStyle = styleNumber0i0012Bold;
                        rowTotalHeHang.CreateCell(13).CellFormula = string.Format("N{0}", r - 1);
                        rowTotalHeHang.GetCell(13).CellStyle = styleNumber012Bold;
                        lstHH.Add(r);
                        startRowHH = r + 1;
                    }
                }
            }

            string sumQuantityPO = "", sumSubToTalPO = "", sumNoOfPackPO = "", sumNWPO = "", sumGWPO = "", sumCBMPO = "";
            if (nnl != null)
            {
                for (var iHH = 0; iHH < lstHH.Count; iHH++)
                {
                    var rowHH = lstHH[iHH];
                    sumQuantityPO += string.Format(@"F{0}+", rowHH + 1);
                    sumSubToTalPO += string.Format(@"I{0}+", rowHH + 1);
                    sumNWPO += string.Format(@"K{0}+", rowHH + 1);
                    sumGWPO += string.Format(@"L{0}+", rowHH + 1);
                    sumCBMPO += string.Format(@"M{0}+", rowHH + 1);
                    sumNoOfPackPO += string.Format(@"N{0}+", rowHH + 1);
                }
                sumQuantityPO += "0";
                sumSubToTalPO += "0";
                sumNWPO += "0";
                sumGWPO += "0";
                sumCBMPO += "0";
                sumNoOfPackPO += "0";
            }
            else
            {
                sumQuantityPO += string.Format(@"SUM(F{0}:F{1})", startRowHH + 1, r + 1);
                sumSubToTalPO += string.Format(@"SUM(I{0}:I{1})", startRowHH + 1, r + 1);
                sumNWPO += string.Format(@"SUM(K{0}:K{1})", startRowHH + 1, r + 1);
                sumGWPO += string.Format(@"SUM(L{0}:L{1})", startRowHH + 1, r + 1);
                sumCBMPO += string.Format(@"SUM(M{0}:M{1})", startRowHH + 1, r + 1);
                sumNoOfPackPO += string.Format(@"SUM(N{0}:N{1})", startRowHH + 1, r + 1);
            }

            r++;
            s1.CreateRow(r).CreateCell(2).SetCellValue(String.Format("Tổng cộng PO {0}:", countDonHang > 1 ? " (" + count.ToString() + ")" : ""));
            s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

            double dsc1 = double.Parse(g_it["discount1"].ToString());
            if (dsc1 == 0)
                s1.GetRow(r).HeightInPoints = 0;

            // total quantity
            s1.GetRow(r).CreateCell(5).CellFormula = sumQuantityPO;
            s1.GetRow(r).GetCell(5).CellStyle = styleNumber012Bold;
            lstQuantity.Add(r + 1);


            //total salary
            s1.GetRow(r).CreateCell(8).CellFormula = sumSubToTalPO;
            s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;
            lstTotalSalary.Add(r + 1);

            //total nw
            s1.GetRow(r).CreateCell(10).CellFormula = sumNWPO;
            s1.GetRow(r).GetCell(10).CellStyle = styleNumber0i0012Bold;
            lstNW.Add(r + 1);

            //total gw
            s1.GetRow(r).CreateCell(11).CellFormula = sumGWPO;
            s1.GetRow(r).GetCell(11).CellStyle = styleNumber0i0012Bold;
            lstGW.Add(r + 1);

            //total cbm
            s1.GetRow(r).CreateCell(12).CellFormula = sumCBMPO;
            s1.GetRow(r).GetCell(12).CellStyle = styleNumber0i0012Bold;
            lstCBM.Add(r + 1);

            //total NoOfPack
            s1.GetRow(r).CreateCell(13).CellFormula = sumNoOfPackPO;
            s1.GetRow(r).GetCell(13).CellStyle = styleNumber012Bold;
            lstNoOfPack.Add(r + 1);

            // discount hidden
            s1.GetRow(r).CreateCell(14).SetCellValue(double.Parse(g_it["discount1"].ToString()));
            s1.GetRow(r).GetCell(14).CellStyle = styleNumber0i0012Bold;
            // total discount

            r++;

            string str_dsc1 = dsc1.ToString();

            s1.CreateRow(r).CreateCell(2).SetCellValue(String.Format("Giảm giá ({0}%):", g_it["discount"].ToString()));
            s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

            //if(str_dsc1.Contains(".")) {
            //	string dot1 = str_dsc1.Split('.')[1];
            //	if(dot1.Length > 2) {
            //		funcDiscount = "I{0}*O{0}/100";
            //	}
            //	else {
            //		funcDiscount = "ROUND(I{0}*O{0}/100,2)";
            //	}
            //}
            //else {
            funcDiscount = "ROUND(I{0}*O{0}/100,2)";
            //}

            s1.GetRow(r).CreateCell(8).CellFormula = String.Format(funcDiscount, r);
            s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;

            sumDiscount += double.Parse(g_it["discount"].ToString());

            if (double.Parse(g_it["discount"].ToString()) == 0) s1.GetRow(r).HeightInPoints = 0;

            s1.GetRow(r).GetCell(2).CellStyle = style12Bold;
            lstDiscount.Add(r + 1);

            r++;
            s1.CreateRow(r).CreateCell(2).SetCellValue(String.Format("Tổng cộng PO {0}:", countDonHang > 1 ? " (" + count.ToString() + ")" : ""));
            s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

            // total quantity
            s1.GetRow(r).CreateCell(5).CellFormula = String.Format("F{0}", r - 1);
            s1.GetRow(r).GetCell(5).CellStyle = styleNumber012Bold;

            s1.GetRow(r).CreateCell(8).CellFormula = String.Format("I{0}-I{1}", r - 1, r);
            s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;

            s1.GetRow(r).CreateCell(10).CellFormula = String.Format("K{0}", r - 1);
            s1.GetRow(r).GetCell(10).CellStyle = styleNumber0i0012Bold;

            s1.GetRow(r).CreateCell(11).CellFormula = String.Format("L{0}", r - 1);
            s1.GetRow(r).GetCell(11).CellStyle = styleNumber0i0012Bold;

            s1.GetRow(r).CreateCell(12).CellFormula = String.Format("M{0}", r - 1);
            s1.GetRow(r).GetCell(12).CellStyle = styleNumber0i0012Bold;

            s1.GetRow(r).CreateCell(13).CellFormula = String.Format("N{0}", r - 1);
            s1.GetRow(r).GetCell(13).CellStyle = styleNumber0i0012Bold;

            count++;
            r++;
        }


        s1.CreateRow(r).CreateCell(2).SetCellValue(pdkInvoice.diengiai_cong + ":");
        s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

        s1.GetRow(r).CreateCell(8).SetCellValue(double.Parse(pdkInvoice.giatri_cong.Value.ToString()));
        s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;

        if (pdkInvoice.giatri_cong.Value == 0) s1.GetRow(r).HeightInPoints = 0;

        r++;
        s1.CreateRow(r).CreateCell(2).SetCellValue(pdkInvoice.diengiai_tru + ":");
        s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

        s1.GetRow(r).CreateCell(8).SetCellValue(double.Parse(pdkInvoice.giatri_tru.Value.ToString()));
        s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;
        if (pdkInvoice.giatri_tru.Value == 0) s1.GetRow(r).HeightInPoints = 0;

        r++;
        s1.CreateRow(r).CreateCell(2).SetCellValue(pdkInvoice.diengiaicong_po + ":");
        s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

        s1.GetRow(r).CreateCell(8).SetCellValue(double.Parse(pdkInvoice.giatricong_po.Value.ToString()));
        s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;
        if (pdkInvoice.giatricong_po.Value == 0) s1.GetRow(r).HeightInPoints = 0;

        r++;
        s1.CreateRow(r).CreateCell(2).SetCellValue(pdkInvoice.diengiaitru_po + ":");
        s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

        s1.GetRow(r).CreateCell(8).SetCellValue(double.Parse(pdkInvoice.giatritru_po.Value.ToString()));
        s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;
        if (pdkInvoice.giatritru_po.Value == 0) s1.GetRow(r).HeightInPoints = 0;

        r++;
        String strCount = "";
        for (int i = 1; i < count; i++)
        {
            strCount += " + " + i;
        }
        strCount = strCount.Substring(3);

        s1.CreateRow(r).CreateCell(2).SetCellValue(String.Format("Tổng cộng{0}:", countDonHang > 1 ? " (" + strCount.ToString() + ")" : ""));
        s1.GetRow(r).GetCell(2).CellStyle = style12Bold;

        // total quantity
        string fQuantity = "", fSalary = "", fDiscount = "", fNoOfPack = "", fGW = "", fCBM = "", fNW = "";

        foreach (int item in lstNW)
        {
            fNW += String.Format("+ K{0} ", item);
        }
        fNW = fNW.Substring(1);

        foreach (int item in lstGW)
        {
            fGW += String.Format("+ L{0} ", item);
        }
        fGW = fGW.Substring(1);

        foreach (int item in lstCBM)
        {
            fCBM += String.Format("+ M{0} ", item);
        }
        fCBM = fCBM.Substring(1);

        foreach (int item in lstNoOfPack)
        {
            fNoOfPack += String.Format("+ N{0} ", item);
        }
        fNoOfPack = fNoOfPack.Substring(1);

        foreach (int item in lstQuantity)
        {
            fQuantity += String.Format("+ F{0} ", item);
        }
        fQuantity = fQuantity.Substring(1);

        //total discount
        foreach (int item in lstDiscount)
        {
            fDiscount += String.Format("+ I{0} ", item);
        }
        fDiscount = fDiscount.Substring(1);


        //total salary
        foreach (int item in lstTotalSalary)
        {
            fSalary += String.Format("+ I{0} ", item);
        }
        fSalary = fSalary.Substring(1);

        s1.GetRow(r).CreateCell(5).SetCellFormula(fQuantity);
        s1.GetRow(r).GetCell(5).CellStyle = styleNumber012Bold;

        s1.GetRow(r).CreateCell(8).SetCellFormula(String.Format("({0}) - ({1}) + I{2} - I{3} + I{4} - I{5}", fSalary, fDiscount, r - 3, r - 2, r - 1, r));
        s1.GetRow(r).GetCell(8).CellStyle = styleNumber0i0012Bold;

        s1.GetRow(r).CreateCell(10).SetCellFormula(fNW);
        s1.GetRow(r).GetCell(10).CellStyle = styleNumber0i0012Bold;

        s1.GetRow(r).CreateCell(11).SetCellFormula(fGW);
        s1.GetRow(r).GetCell(11).CellStyle = styleNumber0i0012Bold;

        s1.GetRow(r).CreateCell(12).SetCellFormula(fCBM);
        s1.GetRow(r).GetCell(12).CellStyle = styleNumber0i0012Bold;

        s1.GetRow(r).CreateCell(13).SetCellFormula(fNoOfPack);
        s1.GetRow(r).GetCell(13).CellStyle = styleNumber0i0012Bold;

        s1.GetRow(r).HeightInPoints = 0;

        if ((countDonHang > 1) || (sumDiscount > 0 && countDonHang > 1) || (pdkInvoice.giatri_cong > 0) || (pdkInvoice.giatri_tru > 0) || (pdkInvoice.giatricong_po > 0) || (pdkInvoice.giatritru_po > 0))
        {
            s1.GetRow(r).HeightInPoints = 22;
        }


        s1.CreateRow(r + 1).CreateCell(0).SetCellValue("Số lượng:");
        s1.GetRow(r + 1).GetCell(0).CellStyle = style12;

        s1.GetRow(r + 1).CreateCell(1).CellFormula = String.Format("F{0}", r + 1);
        s1.GetRow(r + 1).GetCell(1).CellStyle = styleNumber012;
        s1.GetRow(r + 1).CreateCell(2).SetCellValue("cái, bộ");
        s1.GetRow(r + 1).GetCell(2).CellStyle = style12;

        s1.CreateRow(r + 2).CreateCell(0).SetCellValue("Đóng gói:");
        s1.GetRow(r + 2).GetCell(0).CellStyle = style12;
        s1.GetRow(r + 2).CreateCell(1).CellFormula = String.Format("N{0}", r + 1);
        s1.GetRow(r + 2).GetCell(1).CellStyle = styleNumber012;
        s1.GetRow(r + 2).CreateCell(2).SetCellValue("kiện");
        s1.GetRow(r + 2).GetCell(2).CellStyle = style12;

        //s1.CreateRow(r + 3).CreateCell(0).SetCellValue("Trọng lượng tịnh:");
        //      s1.GetRow(r + 3).GetCell(0).CellStyle = style12;
        //      s1.GetRow(r + 3).CreateCell(1).CellFormula = String.Format("J{0}", r + 1);
        //      s1.GetRow(r + 3).GetCell(1).CellStyle = styleNumber0i0012;
        //      s1.GetRow(r + 3).CreateCell(2).SetCellValue("kg");
        //      s1.GetRow(r + 3).GetCell(2).CellStyle = style12;

        s1.CreateRow(r + 3).CreateCell(0).SetCellValue("Trọng lượng:");
        s1.GetRow(r + 3).GetCell(0).CellStyle = style12;
        s1.GetRow(r + 3).CreateCell(1).CellFormula = String.Format("L{0}", r + 1);
        s1.GetRow(r + 3).GetCell(1).CellStyle = styleNumber0i0012;
        s1.GetRow(r + 3).CreateCell(2).SetCellValue("kg");
        s1.GetRow(r + 3).GetCell(2).CellStyle = style12;

        s1.CreateRow(r + 4).CreateCell(0).SetCellValue("Khối lượng:");
        s1.GetRow(r + 4).GetCell(0).CellStyle = style12;
        s1.GetRow(r + 4).CreateCell(1).CellFormula = String.Format("M{0}", r + 1);
        s1.GetRow(r + 4).GetCell(1).CellStyle = styleNumber0i0012;
        s1.GetRow(r + 4).CreateCell(2).SetCellValue("cbm");
        s1.GetRow(r + 4).GetCell(2).CellStyle = style12;


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

    public IFont CreateFontSize(HSSFWorkbook hsswb, short size)
    {
        IFont font = hsswb.CreateFont();
        font.FontHeightInPoints = size;
        return font;
    }

    //#VoThanhSang
    private int LaySLCaiChoTungMaHang(string maSanPham)
    {
        if (string.IsNullOrEmpty(maSanPham) || maSanPham.Length < 11)
            return 1;

        string ma = maSanPham.Substring(9, 2).ToUpper(); // vị trí 10 và 11

        // 01 → 07 = 1
        if (ma == "01" || ma == "02" || ma == "03" || ma == "04" || ma == "05" || ma == "06" || ma == "07")
            return 1;

        // S1-S7, B1-B7, L1-L7
        if ((ma.StartsWith("S") || ma.StartsWith("B") || ma.StartsWith("L")) && ma.Length == 2)
        {
            int so;
            if (int.TryParse(ma.Substring(1, 1), out so) && so >= 1 && so <= 7)
                return so;
        }

        // X1-X6
        switch (ma)
        {
            case "X1":
            case "X2":
            case "X3":
                return 2;

            case "X4":
            case "X5":
                return 3;

            case "X6":
                return 4;
        }

        return 1;
    }
    //EnVoThanhSang
}
