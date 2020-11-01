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
using System.Drawing;
using GemBox.Spreadsheet;

/// <summary>
/// Xuat Excel voi Npoi
/// </summary>
public class ExportExcel
{
    HSSFWorkbook hssfworkbook = null;
    Excel_Format ex_fm = null;
    private int start = 0, end = 0;
    private String fmt0 = "#,##0", fmt0i0 = "#,##0.0", fmt0i00 = "#,##0.00", fmt0i000 = "#,##0.000";
    #region cellStyle
    public ICellStyle cellHeader = null;
    public ICellStyle cellHeader_n = null;

    public ICellStyle cellBold = null;
    public ICellStyle rightBold = null;
    public ICellStyle rightBold0dec = null;
    public ICellStyle rightBold2dec = null;
    public ICellStyle rightBold3dec = null;
    public ICellStyle leftBold = null;
    public ICellStyle centerBold = null;

    public ICellStyle celltext = null;
    public ICellStyle right = null;
    public ICellStyle left = null;
    public ICellStyle center = null;

    public ICellStyle border = null;
    public ICellStyle borderleft = null;
    public ICellStyle borderleftBold = null;
    public ICellStyle borderright = null;
    public ICellStyle borderrightBold = null;
    public ICellStyle borderrightBold0dec = null;
    public ICellStyle borderrightBold2dec = null;
    public ICellStyle borderrightBold3dec = null;
    public ICellStyle bordercenter = null;
    public ICellStyle bordercenterBold = null;

    public ICellStyle borderonlyleft = null;
    public ICellStyle borderWrap = null;
    public ICellStyle signBold = null;
    public ICellStyle borderright0dec = null;
    public ICellStyle borderright2dec = null;
    public ICellStyle borderright3dec = null;
    #endregion

    public ExportExcel(HSSFWorkbook hssf, int start, int end)
    {
        hssfworkbook = hssf;
        ex_fm = new Excel_Format(hssfworkbook);
        this.start = start;
        this.end = end;
        //-- 
        this.cellHeader = ex_fm.getcell(18, true, true, "", "C", "T");
        this.cellHeader_n = ex_fm.getcell(12, false, true, "", "C", "T");
        //--
        this.cellBold = ex_fm.getcell(12, true, true, "", "L", "T");
        this.rightBold = ex_fm.getcell(12, true, false, "", "R", "T");
        this.rightBold0dec = ex_fm.getcell2(12, true, false, "", "R", "T", fmt0);
        this.rightBold2dec = ex_fm.getcell2(12, true, false, "", "R", "T", fmt0i00);
        this.rightBold3dec = ex_fm.getcell2(12, true, false, "", "R", "T", fmt0i000);
        this.leftBold = ex_fm.getcell(12, true, false, "", "L", "T");
        this.centerBold = ex_fm.getcell(12, true, false, "", "C", "T");
        //--
        this.celltext = ex_fm.getcell(12, false, true, "", "L", "T");
        this.right = ex_fm.getcell(12, false, false, "", "R", "T");
        this.left = ex_fm.getcell(12, false, false, "", "L", "T");
        this.center = ex_fm.getcell(12, false, false, "", "C", "T");
        //--
        this.border = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
        this.borderleft = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
        this.borderleftBold = ex_fm.getcell(12, true, true, "LRBT", "L", "T");
        this.borderright = ex_fm.getcell(12, false, true, "LRBT", "R", "T");
        this.borderright0dec = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", fmt0);
        this.borderright2dec = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", fmt0i00);
        this.borderright3dec = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", fmt0i000);
        this.borderrightBold = ex_fm.getcell(12, true, true, "LRBT", "R", "T");
        this.borderrightBold0dec = ex_fm.getcell2(12, true, true, "LRBT", "R", "T", fmt0);
        this.borderrightBold2dec = ex_fm.getcell2(12, true, true, "LRBT", "R", "T", fmt0i00);
        this.borderrightBold3dec = ex_fm.getcell2(12, true, true, "LRBT", "R", "T", fmt0i000);
        this.bordercenter = ex_fm.getcell(12, false, true, "LRBT", "C", "T");
        this.bordercenterBold = ex_fm.getcell(12, true, true, "LRBT", "C", "T");
        //--
        this.borderonlyleft = ex_fm.getcell(12, false, true, "L", "T", "T");
        this.borderWrap = ex_fm.getcell(12, true, true, "LRBT", "C", "T");
        //--
        this.signBold = ex_fm.getcell(12, true, true, "", "C", "C");
        //--
        
    }

    public void MergedRegion(HSSFSheet s1, int row, int start, int end)
    {
        s1.AddMergedRegion(new CellRangeAddress(row, row, start, end));
    }

    public SizeF DetectSizeText(string a)
    {
        Font font = new Font("Arial", 12);
        System.Drawing.Image fakeImage = new Bitmap(1, 1); //As we cannot use CreateGraphics() in a class library, so the fake image is used to load the Graphics.
        Graphics graphics = Graphics.FromImage(fakeImage);
        SizeF size = graphics.MeasureString(a, font);
        return size;
    }

    public int GetHeight(int height, int widthCol, string str)
    {
        double width = DetectSizeText(str).Width;
        double widthDiv = (double)widthCol * (double)0.02967849293563;
        double aDec = width / (double)widthDiv;
        double aInt = int.Parse(aDec.ToString()[0].ToString());
        if (aDec - aInt > 0)
        {
            aInt = aInt + 1;
        }
        height = height * (int)aInt;
        return height;
    }

    public HSSFSheet PrintExcel(HSSFSheet s1, int row)
    {
        s1.PrintSetup.PaperSize = (short)PaperSize.A4;
        s1.FitToPage = true;
        s1.PrintSetup.FitWidth = 1;
        s1.PrintSetup.FitHeight = 0;
        s1.SetMargin(MarginType.TopMargin, 0.25);
        s1.SetMargin(MarginType.BottomMargin, 0.25);
        s1.SetMargin(MarginType.LeftMargin, 0.23);
        s1.SetMargin(MarginType.RightMargin, 0.23);
        s1.SetMargin(MarginType.HeaderMargin, 0.1);
        s1.SetMargin(MarginType.FooterMargin, 0.1);
        hssfworkbook.SetPrintArea(
            hssfworkbook.GetSheetIndex(s1.SheetName), //sheet index
            0, //start column
            this.end, //end column
            0, //start row
            row + 1
        );
        return s1;
    }

    public int SetHeaderAnco(HSSFSheet s1, string title, string tungay, string denngay, bool haveTTAnco)
    {
        int height = 22;
        int row = 0;
        //set A1 - A3
        List<string> lstHeader = new List<string>();
        if (haveTTAnco == true)
        {
            lstHeader.Add("ANCO COMPANY LIMITED");
            lstHeader.Add("3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam");
            lstHeader.Add("Tel.: (84-274) 3740 973   Fax:  (84-274) 3740 621  Email: anco@ancopottery.com");
        }
        lstHeader.Add(title);
        for (int i = 0; i < lstHeader.Count; i++)
        {
            s1.CreateRow(row).CreateCell(0).SetCellValue(lstHeader[i]);
            s1.AddMergedRegion(new CellRangeAddress(row, row, this.start, this.end));
            s1.GetRow(row).HeightInPoints = height;
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

        //set Ngay in bao cao
        height = 30;
        var rowCurr1 = s1.CreateRow(row);
        MergedRegion(s1, row, this.start, this.end);
        rowCurr1.CreateCell(this.start).SetCellValue("Bình dương, ngày: " + DateTime.Now.ToString("dd/MM/yyyy"));
        rowCurr1.GetCell(this.start).CellStyle = right;
        rowCurr1.HeightInPoints = height;
        row++;
        //set Tu ngay den ngay
        var rowCurr2 = s1.CreateRow(row);
        MergedRegion(s1, row, this.start, this.end);
        rowCurr2.CreateCell(this.start).SetCellValue("Từ ngày: " + tungay + "                    Đến ngày: " + denngay);
        rowCurr2.GetCell(this.start).CellStyle = center;
        rowCurr2.HeightInPoints = height;
        row++;

        return row;
    }

    public float MeasureTextHeight(string text, int width)
    {
        double width2 = width * 0.003756;
        width2 = width2 * 7.5;
        if (string.IsNullOrEmpty(text)) return (float)0.0;
        var bitmap = new Bitmap(1, 1);
        var graphics = Graphics.FromImage(bitmap);

        var pixelWidth = Convert.ToInt32(width * 7.5);  //7.5 pixels per excel column width
        var drawingFont = new Font("Arial", 12);
        var size = graphics.MeasureString(text, drawingFont, (int)width2);

        //72 DPI and 96 points per inch.  Excel height in points with max of 409 per Excel requirements.
        return (float)Math.Min(Convert.ToDouble(size.Height) * 72 / 96, 409) + 5;
    }

    public float MeasureTextHeight(string text, int width, string font, float fontSize)
    {
        double width2 = width * 0.003756;
        width2 = width2 * 7.5;
        if (string.IsNullOrEmpty(text)) return (float)0.0;
        var bitmap = new Bitmap(1, 1);
        var graphics = Graphics.FromImage(bitmap);

        var pixelWidth = Convert.ToInt32(width * 7.5);  //7.5 pixels per excel column width
        var drawingFont = new Font(font, fontSize);
        var size = graphics.MeasureString(text, drawingFont, (int)width2);

        //72 DPI and 96 points per inch.  Excel height in points with max of 409 per Excel requirements.
        return (float)Math.Min(Convert.ToDouble(size.Height) * 72 / 96, 409) + 5;
    }

    public void set_borderThin(CellRangeAddress cellRange, string border, HSSFSheet hssfsheet)
    {
        ex_fm.set_border(cellRange, border, hssfsheet);
    }

    public void set_borderThick(CellRangeAddress cellRange, string border, HSSFSheet hssfsheet)
    {
        ex_fm.set_border2(cellRange, border, hssfsheet);
    }

    public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName, HttpContext context)
    {
        MemoryStream exportData = new MemoryStream();
        hsswb.Write(exportData);

        context.Response.ContentType = "application/vnd.ms-excel";
        context.Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", saveAsFileName));
        context.Response.Clear();
        context.Response.BinaryWrite(exportData.GetBuffer());
        context.Response.End();
    }
}

public class ItemValue
{
    private int? _width;
    public string item { get; set; }
    public string value { get; set; }
    public int witdh
    {
        get { return (_width == null ? 5000 : _width.GetValueOrDefault(0)); }
        set { _width = value; }
    }
}

public class columnHeader
{
    public string text { get; set; }
    public string value { get; set; }
    public int width { get; set; }
    public int columnAt { get; set; }
}
