using System;
using System.Data;
using Newtonsoft.Json;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public partial class PrintControllers_More_print_HDNFOBVND : System.Web.UI.Page
{
    #region class
    private LinqDBDataContext db = new LinqDBDataContext();
    private HSSFWorkbook hssfworkbook = null;
    private Excel_Format ex_fm = null;
    private ISheet s1 = null;
    private HSSFSheet hssfsheet = null;
    private bool inNgang = false;
    private int maxColumn = 10;
    private string idCatalog = "";
    private PrintAnco2.InfoExcel infoExcel = new PrintAnco2.InfoExcel();
    private List<int> lstAutoSizeColumn = new List<int>();
    ICellStyle s15_notBold_notWrapT_notBorder_LEFT = null;
    ICellStyle s15_notBold_notWrapT_notBorder_CENTER = null;
    ICellStyle s12_notBold_notWrapT_notBorder_LEFT = null;
    ICellStyle s12_notBold_notWrapT_notBorder_CENTER = null;
    ICellStyle s12_Bold_notWrapT_notBorder_CENTER = null;
    ICellStyle s8_notBold_notWrapT_notBorder_CENTER = null;
    ICellStyle s12_notBold_wrapT_notBorder_Center_Red = null;
    ICellStyle s12_notBold_wrapT_notBorder_Center_LightBlue = null;
    ICellStyle s12_notBold_wrapT_border_Left = null;
    ICellStyle s12_notBold_notWrapT_border_Left_Number = null;
    ICellStyle s12_notBold_notWrapT_border_Left_NumberLess0 = null;
    ICellStyle s12_notBold_wrapT_border_Center_Red = null;
    ICellStyle s12_notBold_wrapT_border_Center_LightBlue = null;
    ICellStyle s12_notBold_notWrapT_border_Left_Number_Red = null;
    ICellStyle s12_notBold_notWrapT_border_Left_Number_LightBlue = null;

    ICellStyle s18_notBold_notWrapT_notBorder_LEFT = null;
    ICellStyle s11_notBold_notWrapT_notBorder_LEFT = null;
    ICellStyle s11_Bold_notWrapT_notBorder_LEFT = null;
    ICellStyle s12_Bold_notWrapT_notBorder_LEFT = null;

    ICellStyle s18_notBold_notWrapT_notBorder_CENTER = null;
    ICellStyle s18_Bold_notWrapT_notBorder_CENTER = null;
    ICellStyle s16_notBold_notWrapT_notBorder_CENTER_Arial = null;
    ICellStyle s18_notBold_notWrapT_notBorder_CENTER_Arial = null;
    ICellStyle s11_Bold_notWrapT_notBorder_CENTER = null;
    ICellStyle s11_notBold_notWrapT_notBorder_CENTER = null;

    public Catalogue.MauSacTrenTrang mstt = new Catalogue.MauSacTrenTrang();
    public Catalogue.DeTaiTrenTrang dttt = new Catalogue.DeTaiTrenTrang();
    public Catalogue.SanPhamTrenTrang sptt = new Catalogue.SanPhamTrenTrang();
    public List<md_chungloai> lstCLs = new List<md_chungloai>();
    public List<Catalogue.SanPhamTrenTrang.spsRow> lstSps = new List<Catalogue.SanPhamTrenTrang.spsRow>();
    public List<Catalogue.DeTaiTrenTrang.dtsRow> lstDts = new List<Catalogue.DeTaiTrenTrang.dtsRow>();
    public List<Catalogue.MauSacTrenTrang.mssRow> lstMss = new List<Catalogue.MauSacTrenTrang.mssRow>();
    #endregion class

    #region function
    public int addRowHeader(int row, md_chungloai cl, int laplai)
    {
        string logoPath = Path.Combine(ExcuteSignalRStatic.mapPathSignalR("~/images/"), "anco_logo_catalog.png");
        var logo = System.Drawing.Image.FromFile(logoPath);
        var mslogo = new MemoryStream();
        logo.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

        var patriarchlogo = s1.CreateDrawingPatriarch();
        var anchorLogo = new HSSFClientAnchor();
        anchorLogo.Dx1 = 150;
        anchorLogo.Dy1 = 10;
        anchorLogo.Dx2 = 900;
        anchorLogo.Dy2 = 256;
        //anchorLogo.Col1 = 0;
        anchorLogo.Row1 = row;
        //anchorLogo.Col2 = 0;
        //anchorLogo.Row2 = row + 2;
        anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
        int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
        var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);

        signaturePicturelogo.Resize(0.5);

        var first = lstSps.Where(s => s.ma_sanpham.Substring(0, 2) == cl.code_cl).FirstOrDefault();
        string cangBien = "";
        if (first != null)
        {
            var cxh = db.md_cangxuathangs.Where(s => s.md_sanpham_id == first.md_sanpham_id & s.macdinh == true).FirstOrDefault();
            if (cxh != null)
                cangBien = db.md_cangbiens.Where(s => s.md_cangbien_id == cxh.md_cangbien_id).Select(s => s.ten_cangbien).FirstOrDefault();
        }

        var getCell = inNgang ? 0 : 1;

        var row1 = s1.CreateRow(row);
        row1.CreateCell(getCell).SetCellValue("ANCO COMPANY LIMITED");
        row1.GetCell(getCell).CellStyle = s12_Bold_notWrapT_notBorder_CENTER;
        s1.AddMergedRegion(new CellRangeAddress(row, row, getCell, maxColumn));
        //Dòng 2
        row++;
        var row2 = s1.CreateRow(row);
        row2.CreateCell(getCell).SetCellValue("3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam");
        row2.GetCell(getCell).CellStyle = s8_notBold_notWrapT_notBorder_CENTER;
        s1.AddMergedRegion(new CellRangeAddress(row, row, getCell, maxColumn));
        //Dòng 3
        row++;
        var row3 = s1.CreateRow(row);
        ICellStyle cellUn = hssfworkbook.CreateCellStyle();
        IFont funderline = hssfworkbook.CreateFont();
        funderline.Underline = FontUnderlineType.Single;
        funderline.FontHeightInPoints = 8;
        funderline.FontName = "Arial";
        cellUn.SetFont(funderline);
        cellUn.Alignment = HorizontalAlignment.Center;
        cellUn.VerticalAlignment = VerticalAlignment.Top;
        cellUn.WrapText = false;

        row3.CreateCell(getCell).SetCellValue("Tel.: (84-274) 3740 973   Fax:  (84–274) 3740 621  Email: anco@ancopottery.com  website: www.ancopottery.com");
        row3.GetCell(getCell).CellStyle = cellUn;
        s1.AddMergedRegion(new CellRangeAddress(row, row, getCell, maxColumn));
        //Dòng 4
        row++;
        var row4 = s1.CreateRow(row);
        row4.CreateCell(1).SetCellValue("");
        s1.AddMergedRegion(new CellRangeAddress(row, row, 1, maxColumn));
        //Dòng 5
        row++;
        var row5 = s1.CreateRow(row);
        row5.CreateCell(0).SetCellValue("PRESENTATION");
        row5.GetCell(0).CellStyle = s18_notBold_notWrapT_notBorder_CENTER;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, maxColumn));
        //Dòng 6
        if (laplai >= 0)
        {
            row++;
            var row6 = s1.CreateRowVNN(row);
            row6.CreateCell(0).SetCellValue(cl.ta_ngan.ToUpper() + " PRODUCTS");
            row6.GetCell(0).CellStyle = s18_Bold_notWrapT_notBorder_CENTER;
            s1.AddMergedRegion(new CellRangeAddress(row, row, 0, maxColumn));
        }
        //Dòng 7
        row++;
        var row7 = s1.CreateRowVNN(row);
        row7.CreateCell(0).SetCellValue("Port of loading: " + cangBien);
        row7.GetCell(0).CellStyle = s11_notBold_notWrapT_notBorder_CENTER;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, maxColumn));

        if(laplai > 0)
        {
            row1.GetCell(getCell).SetCellValue("");
            row2.GetCell(getCell).SetCellValue("");
            row3.GetCell(getCell).SetCellValue("");
        }

        row++;
        return row;
    }

    public int addRowFooter(int row, int laplai, int layoutHH)
    {
        if(!inNgang)
        {
            row += 7;
        }
        else
        {
            if (layoutHH == 4)
                row += 10;
            else
                row += 4;
        }


        var row1 = s1.CreateRow(row);
        row1.CreateCell(0).SetCellValue("For your selection, order and further inquiry, please click here:");
        row1.GetCell(0).CellStyle = s18_notBold_notWrapT_notBorder_CENTER_Arial;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, maxColumn));

        row++;
        var row2 = s1.CreateRow(row);
        var text = "http://www.ancopottery.com/presentation?id=" + idCatalog;
        HSSFHyperlink link = new HSSFHyperlink(HyperlinkType.Url);
        link.Address = text;
        link.FirstColumn = 0;
        link.LastColumn = maxColumn;
        link.FirstRow = row;
        link.LastRow = row;
        row2.CreateCell(0).SetCellValue(text);
        row2.GetCell(0).Hyperlink = link;
        ICellStyle cellUn = hssfworkbook.CreateCellStyle();
        IFont funderline = hssfworkbook.CreateFont();
        funderline.Underline = FontUnderlineType.Single;
        funderline.FontHeightInPoints = 12;
        funderline.FontName = "Arial";
        funderline.Color = IndexedColors.Blue.Index;
        cellUn.SetFont(funderline);
        cellUn.Alignment = HorizontalAlignment.Center;
        cellUn.WrapText = false;
        row2.GetCell(0).CellStyle = cellUn;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, maxColumn));
        row++;
        return row;
    }
    #endregion function

    protected void Page_Load(object sender, EventArgs e)
    {
        string kieuIn = Request.Form["kieuIn"];
        int layoutHangHoa = int.Parse(Request.Form["layoutHangHoa"]);
        int layoutMauSac = int.Parse(Request.Form["layoutMauSac"]);
        int layoutDetai = int.Parse(Request.Form["layoutDetai"]);
        int layoutDVT = int.Parse(Request.Form["layoutDVT"]);
        int layoutGiaFOB = int.Parse(Request.Form["layoutGiaFOB"]);

        inNgang = new int[] { 4, 6 }.Contains(layoutHangHoa);

        maxColumn = inNgang ? 19 : 10;

        hssfworkbook = new HSSFWorkbook();
        ex_fm = new Excel_Format(hssfworkbook);
        s1 = hssfworkbook.CreateSheet("Sheet1");
        hssfsheet = (HSSFSheet)s1;

        #region cell style
        ex_fm.fontFamily = "Arial";
        s8_notBold_notWrapT_notBorder_CENTER = ex_fm.getcell(8, false, false, "", "C", "T");
        s12_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(12, false, false, "", "L", "T");
        s12_notBold_notWrapT_notBorder_CENTER = ex_fm.getcell(12, false, false, "", "C", "T");
        s12_Bold_notWrapT_notBorder_LEFT = ex_fm.getcell(12, true, false, "", "L", "T");
        s12_Bold_notWrapT_notBorder_CENTER = ex_fm.getcell(12, true, false, "", "C", "T");
        s15_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(15, false, false, "", "L", "T");
        s15_notBold_notWrapT_notBorder_CENTER = ex_fm.getcell(15, false, false, "", "C", "T");
        s16_notBold_notWrapT_notBorder_CENTER_Arial = ex_fm.getcell(16, false, false, "", "C", "T");
        s18_notBold_notWrapT_notBorder_CENTER_Arial = ex_fm.getcell(18, false, false, "", "C", "T");

        ex_fm.fontFamily = "Calibri";
        s18_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(18, false, false, "", "L", "T");
        s11_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(11, false, false, "", "L", "T");
        s11_Bold_notWrapT_notBorder_LEFT = ex_fm.getcell(11, true, false, "", "L", "T");

        s18_notBold_notWrapT_notBorder_CENTER = ex_fm.getcell(18, false, false, "", "C", "T");
        s18_Bold_notWrapT_notBorder_CENTER = ex_fm.getcell(18, true, false, "", "C", "T");
        s11_notBold_notWrapT_notBorder_CENTER = ex_fm.getcell(11, false, false, "", "C", "T");
        s11_Bold_notWrapT_notBorder_CENTER = ex_fm.getcell(11, true, false, "", "C", "T");
        #endregion cell stytle

        //Gan gia tri can thiet khi hien thi san pham
        sptt.s1 = s1;
        sptt.hssfworkbook = hssfworkbook;
        sptt.s12_Bold_notWrapT_notBorder_LEFT = s12_Bold_notWrapT_notBorder_LEFT;
        sptt.db = db;
        sptt.layoutHangHoa = layoutHangHoa;
        sptt.layoutGiaFOB = layoutGiaFOB;
        sptt.layoutDVT = layoutDVT;
        sptt.inNgang = inNgang;
        //Gan gia tri can thiet khi hien thi mau sac
        mstt.s1 = s1;
        mstt.hssfworkbook = hssfworkbook;
        mstt.db = db;
        mstt.layoutMauSac = layoutMauSac;
        mstt.layoutDVT = layoutDVT;
        mstt.inNgang = inNgang;
        //Gan gia tri can thiet khi hien thi de tai
        dttt.s1 = s1;
        dttt.hssfworkbook = hssfworkbook;
        dttt.layoutDetai = layoutDetai;
        dttt.layoutDVT = layoutDVT;
        dttt.inNgang = inNgang;

        string sps = Request.Form["sps"];
        string dts = Request.Form["dts"];
        string mss = Request.Form["mss"];

        if (!string.IsNullOrWhiteSpace(sps))
        {
            lstSps = JsonConvert.DeserializeObject<List<Catalogue.SanPhamTrenTrang.spsRow>>(sps).OrderBy(s => s.ma_sanpham).ToList();
            var codeCLs = lstSps.Select(s => s.ma_sanpham.Substring(0, 2)).Distinct().ToList();
            lstCLs = db.md_chungloais.Where(s => codeCLs.Contains(s.code_cl)).OrderBy(s => s.code_cl).ToList();
            idCatalog = Extension.createFileCatalog(lstSps);
            sptt.idCatalog = idCatalog;
        }

        if (!string.IsNullOrWhiteSpace(dts))
            lstDts = JsonConvert.DeserializeObject<List<Catalogue.DeTaiTrenTrang.dtsRow>>(dts).OrderBy(s => s.code_cl).ThenBy(s => s.code_dt).ToList();

        if (!string.IsNullOrWhiteSpace(mss))
            lstMss = JsonConvert.DeserializeObject<List<Catalogue.MauSacTrenTrang.mssRow>>(mss).OrderBy(s => s.code_cl).ThenBy(s => s.code_dt).ThenBy(s => s.code_mau).ToList();

        int row = 0;
        foreach (var item in lstCLs)
        {
            var spcls = lstSps.Where(s => s.ma_sanpham.Substring(0, 2) == item.code_cl).OrderBy(s => s.ma_sanpham).ToList();
            var dtcls = lstDts.Where(s => s.code_cl == item.code_cl).OrderBy(s => s.code_dt).ToList();
            var mscls = lstMss.Where(s => s.code_cl == item.code_cl).OrderBy(s => s.code_dt).ThenBy(s => s.code_mau).ToList();

            //Hien thi san pham
            int spCount = 1, spTime = 0;
            var laplai = 0;
            foreach (var sp in spcls)
            {
                if (spCount % layoutHangHoa == 0 | spCount == spcls.Count)
                {
                    row = addRowHeader(row, item, laplai);
                    
                    var lstms = spcls.Skip(spTime * layoutHangHoa).Take(layoutHangHoa).ToList();

                    row = sptt.addRowInPage(row, lstms);
                    row = addRowFooter(row, laplai, layoutHangHoa);

                    laplai++;

                    if (spCount < spcls.Count)
                    {
                        s1.SetRowBreak(row - 1);
                        spTime++;
                    }
                }
                spCount++;
            }

            //Ngat trang neu co mau sac duoc chon
            if (lstMss.Count > 0)
                s1.SetRowBreak(row - 1);

            //Hien thi mau sac
            int msCount = 1, msTime = 0;
            foreach (var ms in mscls)
            {
                if (msCount % layoutMauSac == 0 | msCount == mscls.Count)
                {
					row = addRowHeader(row, item, laplai);
                    s1.CreateRow(row).CreateCell(0).SetCellValue("Available color:");
                    s1.GetRow(row).GetCell(0).CellStyle = s11_Bold_notWrapT_notBorder_LEFT;
                    s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 10));
                    row++;
                    var lstms = mscls.Skip(msTime * layoutMauSac).Take(layoutMauSac).ToList();

                    row = mstt.addRowInPage(row, lstms);

                    if (msCount < mscls.Count)
                    {
                        s1.SetRowBreak(row - 1);
                        msTime++;
                    }
                }
                msCount++;
            }

            //Ngat trang neu co de tai duoc chon
            if (lstDts.Count > 0)
                s1.SetRowBreak(row - 1);

            //Hien thi mau sac
            int dtCount = 1, dtTime = 0;
            foreach (var dt in dtcls)
            {
                if (dtCount % layoutDetai == 0 | dtCount == dtcls.Count)
                {
					row = addRowHeader(row, item, laplai);
                    s1.CreateRow(row).CreateCell(0).SetCellValue("Available pattern:");
                    s1.GetRow(row).GetCell(0).CellStyle = s11_Bold_notWrapT_notBorder_LEFT;
                    s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 10));
                    row++;
                    var lstms = dtcls.Skip(dtTime * layoutDetai).Take(layoutDetai).ToList();

                    row = dttt.addRowInPage(row, lstms);

                    if (dtCount < dtcls.Count)
                    {
                        s1.SetRowBreak(row - 1);
                        dtTime++;
                    }
                }
                dtCount++;
            }

            var nextItem = lstCLs.NextOf(item);
            if (nextItem != null)
            {
                s1.SetRowBreak(row);
                row++;
            }
        }


        var printCf = new PrintAnco2();
        printCf.isPDF = kieuIn == "1";
        printCf.columnLast = maxColumn;
        printCf.hssfworkbook = hssfworkbook;

        s1.PrintSetup.Landscape = inNgang;
        s1.PrintSetup.PaperSize = (short)PaperSize.A4_Small;
        s1.PrintSetup.FitWidth = 1;
        s1.PrintSetup.FitHeight = 0;
        s1.SetMargin(NPOI.SS.UserModel.MarginType.TopMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.BottomMargin, 0);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.LeftMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.RightMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.HeaderMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.FooterMargin, 0);

        hssfworkbook.SetPrintArea(
            hssfworkbook.GetSheetIndex(s1.SheetName), //sheet index
            0, //start column
            maxColumn,
            0, //start row
            row
        );

        string DisplayName = "Presentation";

        string filename = Helper.getNewId();
        var urlExcel = ExcuteSignalRStatic.mapPathSignalR(string.Format("~/FileUpload/{0}.xls", filename));
        var xfile = new FileStream(urlExcel, FileMode.Create, FileAccess.ReadWrite);
        hssfworkbook.Write(xfile);
        xfile.Close();
        xfile.Dispose();

        var urlPDF = urlExcel.Substring(0, urlExcel.LastIndexOf(".") + 1) + "pdf";
        var excelConvert = new OfficeToPDF.ExcelConverter();
        excelConvert.lstAutoSizeColumn = lstAutoSizeColumn;
        excelConvert.endRow = s1.LastRowNum;
        excelConvert.endColumn = 10;

        var msg = excelConvert.ConvertInterop(urlExcel, printCf.isPDF.GetValueOrDefault(false) ? urlPDF : urlExcel, null);

        if (msg.Length <= 0)
        {
            if (printCf.isPDF.GetValueOrDefault(false))
            {
                Response.Redirect(string.Format("../../ViewPDFPublic/index.aspx?urlpdf=../FileUpload/{0}.pdf&zoomprint=0.999&zoom=page-width&remove=false&namedown={1}", filename, DisplayName));
            }
            else
            {
                var xfileRead = new FileStream(urlExcel, FileMode.Open, FileAccess.ReadWrite);
                var memoryStream = new MemoryStream();
                xfileRead.CopyTo(memoryStream);
                xfileRead.Close();
                xfileRead.Dispose();
                File.Delete(urlExcel);

                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}.xls", DisplayName));
                Response.Clear();
                Response.BinaryWrite(memoryStream.ToArray());
                Response.End();
            }
        }
        else
        {
            Response.Write(msg);
        }
    }
}