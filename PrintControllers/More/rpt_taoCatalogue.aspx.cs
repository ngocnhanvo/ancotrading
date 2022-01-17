using System;
using System.Data;
using Newtonsoft.Json;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public partial class PrintControllers_More_rpt_taoCatalogue : System.Web.UI.Page
{
    #region class
    private LinqDBDataContext db = new LinqDBDataContext();
    private HSSFWorkbook hssfworkbook = null;
    private Excel_Format ex_fm = null;
    private ISheet s1 = null;
    private HSSFSheet hssfsheet = null;
    private PrintAnco2.InfoExcel infoExcel = new PrintAnco2.InfoExcel();
    private List<int> lstAutoSizeColumn = new List<int>();
    ICellStyle s15_notBold_notWrapT_notBorder_LEFT = null;
    ICellStyle s12_notBold_notWrapT_notBorder_LEFT = null;
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
    ICellStyle s11_Bold_notWrapT_notBorder_CENTER = null;
    ICellStyle s11_notBold_notWrapT_notBorder_CENTER = null;
    public class spsRow
    {
        public string md_sanpham_id { get; set; }
        public string ma_sanpham { get; set; }
        public string mota_tiengviet { get; set; }
    }

    public Catalogue.MauSacTrenTrang mstt = new Catalogue.MauSacTrenTrang();
    public Catalogue.DeTaiTrenTrang dttt = new Catalogue.DeTaiTrenTrang();
    public List<md_chungloai> lstCLs = new List<md_chungloai>();
    public List<spsRow> lstSps = new List<spsRow>();
    public List<Catalogue.DeTaiTrenTrang.dtsRow> lstDts = new List<Catalogue.DeTaiTrenTrang.dtsRow>();
    public List<Catalogue.MauSacTrenTrang.mssRow> lstMss = new List<Catalogue.MauSacTrenTrang.mssRow>();
    public int layoutDVT = 0;
    #endregion class

    #region function
    public int addRowHeader(int row, md_chungloai cl)
    {
        string logoPath = Path.Combine(ExcuteSignalRStatic.mapPathSignalR("~/images/"), "anco_logo_print.png");
        var logo = System.Drawing.Image.FromFile(logoPath);
        var mslogo = new MemoryStream();
        logo.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

        var patriarchlogo = s1.CreateDrawingPatriarch();
        var anchorLogo = new HSSFClientAnchor();
        anchorLogo.Dx1 = 150;
        anchorLogo.Dy1 = 10;
        anchorLogo.Dx2 = 900;
        anchorLogo.Dy2 = 253;
        anchorLogo.Col1 = 0;
        anchorLogo.Row1 = row;
        anchorLogo.Col2 = 0;
        anchorLogo.Row2 = row + 2;
        anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
        int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
        var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
        
        var first = lstSps.Where(s=>s.ma_sanpham.Substring(0,2) == cl.code_cl).FirstOrDefault();
        string cangBien = "";
        if (first != null)
        {
            var cxh = db.md_cangxuathangs.Where(s => s.md_sanpham_id == first.md_sanpham_id & s.macdinh == true).FirstOrDefault();
            if (cxh != null)
                cangBien = db.md_cangbiens.Where(s => s.md_cangbien_id == cxh.md_cangbien_id).Select(s => s.ten_cangbien).FirstOrDefault();
        }

        var row1 = s1.CreateRow(row);
        row1.CreateCell(1).SetCellValue("ANCO COMPANY LIMITED");
        row1.GetCell(1).CellStyle = s15_notBold_notWrapT_notBorder_LEFT;
        //Dòng 2
        row++;
        var row2 = s1.CreateRow(row);
        row2.CreateCell(1).SetCellValue("3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam");
        row2.GetCell(1).CellStyle = s12_notBold_notWrapT_notBorder_LEFT;

        //Dòng 3
        ICellStyle cellUn = hssfworkbook.CreateCellStyle();
        IFont funderline = hssfworkbook.CreateFont();
        funderline.Underline = FontUnderlineType.Single;
        funderline.FontHeightInPoints = 12;
        funderline.FontName = "Arial";
        cellUn.SetFont(funderline);
        cellUn.Alignment = HorizontalAlignment.Left;
        cellUn.VerticalAlignment = VerticalAlignment.Top;
        cellUn.WrapText = false;
        row++;
        var row3 = s1.CreateRow(row);
        row3.CreateCell(1).SetCellValue("Tel.: (84-274) 3740 973   Fax:  (84–274) 3740 621  Email: anco@ancopottery.com");
        row3.GetCell(1).CellStyle = cellUn;
        //Dòng 4
        row++;
        var row4 = s1.CreateRow(row);
        row4.CreateCell(1).SetCellValue("");
        //Dòng 5
        row++;
        var row5 = s1.CreateRow(row);
        row5.CreateCell(0).SetCellValue("PRESENTATION");
        row5.GetCell(0).CellStyle = s18_notBold_notWrapT_notBorder_CENTER;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 9));
        //Dòng 6
        if (lstCLs.Count > 1)
        {
            row++;
            var row6 = s1.CreateRow(row);
            row6.CreateCell(0).SetCellValue(cl.ta_ngan.ToUpper());
            row6.GetCell(0).CellStyle = s11_Bold_notWrapT_notBorder_CENTER;
            s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 9));
        }
        //Dòng 7
        row++;
        var row7 = s1.CreateRow(row);
        row7.CreateCell(0).SetCellValue("Port of loading: " + cangBien);
        row7.GetCell(0).CellStyle = s11_notBold_notWrapT_notBorder_CENTER;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 9));

        row++;
        return row;
    }

    public int addRowProduct(int row, spsRow spR)
    {
        row += 5;
        string imgPath = ExcuteSignalRStatic.mapPathSignalR("~/" + ExcuteSignalRStatic.getImage(spR.ma_sanpham, 0)["msLink"]);
        if (File.Exists(imgPath))
        {
            var img = System.Drawing.Image.FromFile(imgPath);
            var mslogo = new MemoryStream();
            img.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

            var patriarchlogo = s1.CreateDrawingPatriarch();
            var anchorLogo = new HSSFClientAnchor();
            anchorLogo.Dx1 = 150;
            anchorLogo.Dy1 = 10;
            anchorLogo.Dx2 = 900;
            anchorLogo.Dy2 = 253;
            anchorLogo.Col1 = 0;
            anchorLogo.Row1 = row;
            anchorLogo.Col2 = 3;
            anchorLogo.Row2 = row + 9;
            anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
            int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
            var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
        }

        string qrCodePath = ExcuteSignalRStatic.mapPathSignalR("~/images/qrcode/") + spR.ma_sanpham + ".jpg";
        if (File.Exists(qrCodePath))
        {
            var qrcodeIMG = System.Drawing.Image.FromFile(qrCodePath);
            var mslogo = new MemoryStream();
            qrcodeIMG.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

            var patriarchlogo = s1.CreateDrawingPatriarch();
            var anchorLogo = new HSSFClientAnchor();
            anchorLogo.Dx1 = 100;
            anchorLogo.Dy1 = 10;
            anchorLogo.Dx2 = 900;
            anchorLogo.Dy2 = 0;
            anchorLogo.Col1 = 5;
            anchorLogo.Row1 = row - 3;
            anchorLogo.Col2 = 5;
            anchorLogo.Row2 = row;
            anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
            int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
            var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
        }

        var cellRow5 = s1.CreateRow(row).CreateCell(5);
        cellRow5.SetCellValue("ITEM NO.:" + spR.ma_sanpham);
        cellRow5.CellStyle = s12_Bold_notWrapT_notBorder_LEFT;

        var strSize = spR.ma_sanpham.Substring(9, 2);

        var sp = db.md_sanphams.Where(s => s.ma_sanpham == spR.ma_sanpham).FirstOrDefault();
        var kieudang = "";
        var donggoi = "";
        var palletSize = "";
        var qtyCont = "";

        if (sp != null)
        {
            kieudang = db.md_kieudangs.Where(s => s.md_kieudang_id == sp.md_kieudang_id).Select(s => s.ma_kieudang).FirstOrDefault();
            var dgsp = db.md_donggoisanphams.Where(s => s.md_sanpham_id == sp.md_sanpham_id).FirstOrDefault();
            var dg = db.md_donggois.Where(s => s.md_donggoi_id == dgsp.md_donggoi_id).FirstOrDefault();
            var dvtInner = db.md_donvitinhs.Where(s => s.md_donvitinh_id == dg.dvt_inner).Select(s => s.ten_dvt).FirstOrDefault();
            var dvtOuter = db.md_donvitinhs.Where(s => s.md_donvitinh_id == dg.dvt_outer).Select(s => s.ten_dvt).FirstOrDefault();

            if (dg.sl_inner > 0 & dg.sl_outer > 0)
            {
                donggoi = string.Format(@"Inner: {0} {1}  Master: {2} {3}",
                    dg.sl_inner,
                    dvtInner,
                    dg.sl_outer,
                    dvtOuter
                    );
            }
            else if (dg.sl_inner > 0)
            {
                donggoi = string.Format(@"Inner: {0} {1}",
                    dg.sl_inner,
                    dvtInner
                    );
            }
            else if (dg.sl_outer > 0)
            {
                donggoi = string.Format(@"Inner: {0} {1}",
                    dg.sl_outer,
                    dvtOuter
                    );
            }

            palletSize = string.Format(@"Pallet size: L{0} - W{1} - H{2} cm",
                dg.l2_mix.DropTrailingZeros(),
                dg.w2_mix.DropTrailingZeros(),
                dg.h2_mix.DropTrailingZeros()
                );

            if (dg.soluonggoi_ctn_20 > 0 & dg.soluonggoi_ctn > 0)
                qtyCont = string.Format(@"Q'ty/cont: {0} pal/20""; {1} pal/40""", dg.soluonggoi_ctn_20.DropTrailingZeros(), dg.soluonggoi_ctn.DropTrailingZeros());
            else if (dg.soluonggoi_ctn_20 > 0)
                qtyCont = string.Format(@"Q'ty/cont: {0} pal/20""", dg.soluonggoi_ctn_20.DropTrailingZeros());
            else if (dg.soluonggoi_ctn > 0)
                qtyCont = string.Format(@"Q'ty/cont: {0} pal/40""", dg.soluonggoi_ctn.DropTrailingZeros());
        }

        if (strSize.StartsWith("0") | strSize.StartsWith("F") | strSize == "S1")
        {
            var cellRow6 = s1.CreateRow(row + 1).CreateCell(5);
            cellRow6.SetCellValue("Size:");

            var cellRow6_2 = s1.GetRow(row + 1).CreateCell(6);
            string cmVal = "", inchVal = "";
            if (kieudang == "ROU")
            {
                cmVal = string.Format(@"D{0} - H{1} cm", sp.l_cm.DropTrailingZeros(), sp.h_cm.DropTrailingZeros());
                inchVal = string.Format(@"D{0}"" - H{1}""", sp.l_inch.DropTrailingZeros(), sp.h_inch.DropTrailingZeros());
            }
            else
            {
                cmVal = string.Format(@"L{0} - W{1} - H{2} cm", sp.l_cm.DropTrailingZeros(), sp.w_cm.DropTrailingZeros(), sp.h_cm.DropTrailingZeros());
                inchVal = string.Format(@"L{0}"" - W{1}"" - H{2}""", sp.l_inch.DropTrailingZeros(), sp.w_inch.DropTrailingZeros(), sp.h_inch.DropTrailingZeros());
            }

            if (layoutDVT == 1)
                cellRow6_2.SetCellValue(string.Format(@"{0}", cmVal));
            else if (layoutDVT == 2)
                cellRow6_2.SetCellValue(string.Format(@"{0}", inchVal));
            else
                cellRow6_2.SetCellValue(string.Format(@"{0} | {1}", cmVal, inchVal));

            var cellRow7 = s1.CreateRow(row + 2).CreateCell(5);
            cellRow7.SetCellValue(donggoi);

            var cellRow8 = s1.CreateRow(row + 3).CreateCell(5);
            cellRow8.SetCellValue(palletSize);

            var cellRow9 = s1.CreateRow(row + 4).CreateCell(5);
            cellRow9.SetCellValue(qtyCont);
        }
        else
        {
            md_bo boMain = null;
            if(strSize.StartsWith("S"))
                boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == strSize).FirstOrDefault();
            else
            {
                boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == "S6").FirstOrDefault();
                if(boMain == null)
                    boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == "S5").FirstOrDefault();
                else if (boMain == null)
                    boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == "S4").FirstOrDefault();
                else if (boMain == null)
                    boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == "S3").FirstOrDefault();
                else if (boMain == null)
                    boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == "S2").FirstOrDefault();
            }

            int countR = 0;
            foreach(var cai in db.md_bo_chitiets.Where(s=>s.md_bo_id == boMain.md_bo_id).OrderBy(s=>s.md_bo_detail).ToList())
            {
                countR++;
                var maCai = sp.ma_sanpham.Substring(0, 9) + cai.md_bo_detail + sp.ma_sanpham.Substring(11);
                throw new Exception(maCai);
                var spCai = db.md_sanphams.Where(s => s.ma_sanpham == maCai).FirstOrDefault();
                var cellRow = s1.CreateRow(row + countR).CreateCell(5);
                cellRow.SetCellValue(string.Format(@"Size {0}:", cai.md_bo_detail));

                string cmVal = "", inchVal = "";
                cellRow = s1.GetRow(row + countR).CreateCell(6);
                if (kieudang == "ROU")
                {
                    cmVal = string.Format(@"D{0} - H{1} cm", spCai.l_cm.DropTrailingZeros(), spCai.h_cm.DropTrailingZeros());
                    inchVal = string.Format(@"D{0}"" - H{1}""", spCai.l_inch.DropTrailingZeros(), spCai.h_inch.DropTrailingZeros());
                }
                else
                {
                    cmVal = string.Format(@"L{0} - W{1} - H{2} cm", spCai.l_cm.DropTrailingZeros(), spCai.w_cm.DropTrailingZeros(), spCai.h_cm.DropTrailingZeros());
                    inchVal = string.Format(@"L{0}"" - W{1}"" - H{2}""", spCai.l_inch.DropTrailingZeros(), spCai.w_inch.DropTrailingZeros(), spCai.h_inch.DropTrailingZeros());
                }

                if (layoutDVT == 1)
                    cellRow.SetCellValue(string.Format(@"{0}", cmVal));
                else if (layoutDVT == 2)
                    cellRow.SetCellValue(string.Format(@"{0}", inchVal));
                else
                    cellRow.SetCellValue(string.Format(@"{0} | {1}", cmVal, inchVal));
            }

            var cellRow2 = s1.CreateRow(row + countR + 1).CreateCell(5);
            cellRow2.SetCellValue(donggoi);

            cellRow2 = s1.CreateRow(row + countR + 2).CreateCell(5);
            cellRow2.SetCellValue(palletSize);

            cellRow2 = s1.CreateRow(row + countR + 3).CreateCell(5);
            cellRow2.SetCellValue(qtyCont);
        }

        row += 12;
        return row;
    }
    #endregion function

    protected void Page_Load(object sender, EventArgs e)
    {
        hssfworkbook = new HSSFWorkbook();
        ex_fm = new Excel_Format(hssfworkbook);
        s1 = hssfworkbook.CreateSheet("Sheet1");
        hssfsheet = (HSSFSheet)s1;

        mstt.s1 = s1;
        mstt.hssfworkbook = hssfworkbook;
        dttt.s1 = s1;
        dttt.hssfworkbook = hssfworkbook;

        #region cell style
        ex_fm.fontFamily = "Arial";
        s12_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(12, false, false, "", "L", "T");
        s12_Bold_notWrapT_notBorder_LEFT = ex_fm.getcell(12, true, false, "", "L", "T");
        s15_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(15, false, false, "", "L", "T");

        ex_fm.fontFamily = "Calibri";
        s18_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(18, false, false, "", "L", "T");
        s11_notBold_notWrapT_notBorder_LEFT = ex_fm.getcell(11, false, false, "", "L", "T");
        s11_Bold_notWrapT_notBorder_LEFT = ex_fm.getcell(11, true, false, "", "L", "T");

        s18_notBold_notWrapT_notBorder_CENTER = ex_fm.getcell(18, false, false, "", "C", "T");
        s11_notBold_notWrapT_notBorder_CENTER = ex_fm.getcell(11, false, false, "", "C", "T");
        s11_Bold_notWrapT_notBorder_CENTER = ex_fm.getcell(11, true, false, "", "C", "T");
        #endregion cell stytle

        string kieuIn = Request.Form["kieuIn"];
        int layoutHangHoa = int.Parse(Request.Form["layoutHangHoa"]);
        int layoutMauSac = int.Parse(Request.Form["layoutMauSac"]);
        int layoutDetai = int.Parse(Request.Form["layoutDetai"]);
        layoutDVT = int.Parse(Request.Form["layoutDVT"]);
        var inNgang = new int[] { 4, 6 }.Contains(layoutHangHoa);

        string sps = Request.Form["sps"];
        string dts = Request.Form["dts"];
        string mss = Request.Form["mss"];
        
        if (!string.IsNullOrWhiteSpace(sps))
        {
            lstSps = JsonConvert.DeserializeObject<List<spsRow>>(sps).OrderBy(s => s.ma_sanpham).ToList();
            var codeCLs = lstSps.Select(s => s.ma_sanpham.Substring(0, 2)).Distinct().ToList();
            lstCLs = db.md_chungloais.Where(s => codeCLs.Contains(s.code_cl)).ToList();
        }

        if (!string.IsNullOrWhiteSpace(dts))
            lstDts = JsonConvert.DeserializeObject<List<Catalogue.DeTaiTrenTrang.dtsRow>>(dts).OrderBy(s => s.code_cl).ThenBy(s => s.code_dt).ToList();
        
        if (!string.IsNullOrWhiteSpace(mss))
            lstMss = JsonConvert.DeserializeObject<List<Catalogue.MauSacTrenTrang.mssRow>>(mss).OrderBy(s => s.code_cl).ThenBy(s => s.code_dt).ThenBy(s => s.code_mau).ToList();

        int row = 0;
        foreach (var item in lstCLs)
        {
            var spcls = lstSps.Where(s => s.ma_sanpham.Substring(0, 2) == item.code_cl).ToList();
            var dtcls = lstDts.Where(s => s.code_cl == item.code_cl).ToList();
            var mscls = lstMss.Where(s => s.code_cl == item.code_cl).ToList();

            row = addRowHeader(row, item);
            
            if(!inNgang)
            {
                int spCount = 1;
                foreach (var sp in spcls)
                {
                    row = addRowProduct(row, sp);
                    if (spCount % layoutHangHoa == 0)
                    {
                        if (spCount < spcls.Count)
                        {
                            s1.SetRowBreak(row);
                            row++;
                            row = addRowHeader(row, item);
                        }
                    }
                    spCount++;
                }
                
                if(lstMss.Count > 0)
                    s1.SetRowBreak(row);

                int msCount = 1, msTime = 0;
                foreach (var ms in mscls)
                {
                    if (msCount % layoutMauSac == 0 | msCount == mscls.Count)
                    {
                        row++;
                        row++;
                        s1.CreateRow(row).CreateCell(0).SetCellValue("Available color:");
                        s1.GetRow(row).GetCell(0).CellStyle = s11_Bold_notWrapT_notBorder_LEFT;
                        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 10));
                        row++;
                        var lstms = mscls.Skip(msTime * layoutMauSac).Take(layoutMauSac).ToList();
                        row = mstt.add6ColorIn1Pages(row, lstms);

                        if (msCount < mscls.Count)
                        {
                            s1.SetRowBreak(row);
                            msTime++;
                        }
                    }
                    msCount++;
                }

                if (lstDts.Count > 0)
                {
                    s1.SetRowBreak(row);
                }

                int dtCount = 1, dtTime = 0;
                foreach (var dt in dtcls)
                {
                    if (dtCount % layoutDetai == 0 | dtCount == dtcls.Count)
                    {
                        row++;
                        row++;
                        s1.CreateRow(row).CreateCell(0).SetCellValue("Available pattern:");
                        s1.GetRow(row).GetCell(0).CellStyle = s11_Bold_notWrapT_notBorder_LEFT;
                        s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 10));
                        row++;
                        var lstms = dtcls.Skip(dtTime * layoutDetai).Take(layoutDetai).ToList();
                        row = dttt.add6In1Pages(row, lstms);

                        if (dtCount < dtcls.Count)
                        {
                            s1.SetRowBreak(row);
                            dtTime++;
                        }
                    }
                    dtCount++;
                }

                var nextItem = lstCLs.NextOf(item);
                if(nextItem != null)
                {
                    s1.SetRowBreak(row);
                    row++;
                }
            }
        }
        

        var printCf = new PrintAnco2();
        printCf.isPDF = kieuIn == "1";
        printCf.columnLast = 10;
        printCf.hssfworkbook = hssfworkbook;

        s1.PrintSetup.Landscape = inNgang;
        s1.PrintSetup.PaperSize = (short)PaperSize.A4_Small;
        s1.PrintSetup.FitWidth = 1;
        s1.PrintSetup.FitHeight = 0;
        s1.SetMargin(NPOI.SS.UserModel.MarginType.TopMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.BottomMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.LeftMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.RightMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.HeaderMargin, 0.23);
        s1.SetMargin(NPOI.SS.UserModel.MarginType.FooterMargin, 0.23);

        //hssfworkbook.SetPrintArea(
        //    hssfworkbook.GetSheetIndex(s1.SheetName), //sheet index
        //    0, //start column
        //    10,
        //    0, //start row
        //    s1.LastRowNum
        //);

        string DisplayName = "Presenttation";

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
                Response.Redirect(string.Format("../../ViewPDFPublic/index.aspx?urlpdf=../FileUpload/{0}.pdf&zoomprint=0.999&zoom=page-width&remove=true&namedown={1}", filename, DisplayName));
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