using System;
using System.Data;
using Newtonsoft.Json;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using System.Collections.Generic;
using System.Linq;
using System.IO;

namespace Catalogue
{
    public class SanPhamTrenTrang
    {
        public class spsRow
        {
            public string md_sanpham_id { get; set; }
            public string ma_sanpham { get; set; }
            public string mota_tiengviet { get; set; }
        }

        public LinqDBDataContext db { get; set; }
        public int layoutDVT { get; set; }
        public int layoutHangHoa { get; set; }
        public int layoutGiaFOB { get; set; }
        public bool inNgang { get; set; }

        public ICellStyle s12_Bold_notWrapT_notBorder_LEFT = null;

        public HSSFWorkbook hssfworkbook = null;
        public Excel_Format ex_fm = null;
        public ISheet s1 = null;
        public HSSFSheet hssfsheet = null;
        public PrintAnco2.InfoExcel infoExcel = new PrintAnco2.InfoExcel();
        public List<int> lstAutoSizeColumn = new List<int>();

        public List<spsRow> msCLs { get; set; }

        public int createProduct_Landscape(int row, spsRow spR, int col1)
        {
            var khoangCachChuVaHinh = 4;

            if (spR == null)
            {
                var cellRowAdd = s1.CreateRowVNN(row).CreateCell(col1 + khoangCachChuVaHinh);
                cellRowAdd.SetCellValue(" ");
                cellRowAdd.CellStyle = s12_Bold_notWrapT_notBorder_LEFT;

                if (layoutGiaFOB == 2)
                {
                    cellRowAdd = s1.CreateRowVNN(row + 1).CreateCell(col1 + khoangCachChuVaHinh);
                    cellRowAdd.SetCellValue(string.Format(" "));
                    cellRowAdd.CellStyle = s12_Bold_notWrapT_notBorder_LEFT;
                }

                goto end;
            }

            string imgPath = ExcuteSignalRStatic.mapPathSignalR("~/" + ExcuteSignalRStatic.getImage(spR.ma_sanpham, 0)["msLink"]);
            if (File.Exists(imgPath))
            {
                var img = System.Drawing.Image.FromFile(imgPath);
                var mslogo = new MemoryStream();
                img.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

                var patriarchlogo = s1.CreateDrawingPatriarch();
                var anchorLogo = new HSSFClientAnchor();
                anchorLogo.Dx1 = 150;
                anchorLogo.Dy1 = 0;
                anchorLogo.Dx2 = 900;
                anchorLogo.Dy2 = 0;
                anchorLogo.Col1 = col1;
                anchorLogo.Row1 = row;
                anchorLogo.Col2 = col1 + 3;
                anchorLogo.Row2 = row + 9;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);

                if(img.Width <= 200 & img.Height <= 150)
                    signaturePicturelogo.Resize(1.2);
                else if (img.Width <= 300 & img.Height <= 300)
                    signaturePicturelogo.Resize(0.6);
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
                anchorLogo.Col1 = col1 + khoangCachChuVaHinh;
                anchorLogo.Row1 = row - 3;
                anchorLogo.Col2 = col1 + khoangCachChuVaHinh;
                anchorLogo.Row2 = row;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
            }

            md_giasanpham gsp = null;
            if (layoutGiaFOB == 2)
            {
                gsp = (from a in db.md_giasanphams
                          join b in db.md_phienbangias on a.md_phienbangia_id equals b.md_phienbangia_id
                          join c in db.md_banggias on b.md_banggia_id equals c.md_banggia_id
                          where
                            a.md_sanpham_id == spR.md_sanpham_id
                            & a.hoatdong == true
                            & c.banggiaban == true
                            & c.ten_banggia.Substring(0, 5).StartsWith("FOB-")
                            & b.ngay_hieuluc <= DateTime.Now
                          orderby b.ngay_hieuluc descending
                          select a).FirstOrDefault();
            }

            var cellRow5 = s1.CreateRowVNN(row).CreateCell(col1 + khoangCachChuVaHinh);
            cellRow5.SetCellValue("ITEM NO.: " + spR.ma_sanpham);
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

                string cmValPallet = "", inchValPallet = "";

                cmValPallet = string.Format(@"L{0} - W{1} - H{2} cm",
                    dg.l2_mix.DropTrailingZeros(),
                    dg.w2_mix.DropTrailingZeros(),
                    dg.h2_mix.DropTrailingZeros()
                    );

                decimal cmToInch = (decimal)0.3937;
                inchValPallet = string.Format(@"L{0}"" - W{1}"" - H{2}""",
                    (dg.l2_mix.GetValueOrDefault(0) * cmToInch).ToString("#,#0.##"),
                    (dg.w2_mix.GetValueOrDefault(0) * cmToInch).ToString("#,#0.##"),
                    (dg.h2_mix.GetValueOrDefault(0) * cmToInch).ToString("#,#0.##")
                    );

                if (layoutDVT == 1)
                    palletSize = cmValPallet;
                else if (layoutDVT == 2)
                    palletSize = inchValPallet;
                else
                    palletSize = string.Format(@"{0} | {1}", cmValPallet, inchValPallet);

                if (dg.soluonggoi_ctn_20 > 0 & dg.soluonggoi_ctn > 0)
                    qtyCont = string.Format(@"Q'ty/cont: {0} pal/20""; {1} pal/40""", dg.soluonggoi_ctn_20.DropTrailingZeros(), dg.soluonggoi_ctn.DropTrailingZeros());
                else if (dg.soluonggoi_ctn_20 > 0)
                    qtyCont = string.Format(@"Q'ty/cont: {0} pal/20""", dg.soluonggoi_ctn_20.DropTrailingZeros());
                else if (dg.soluonggoi_ctn > 0)
                    qtyCont = string.Format(@"Q'ty/cont: {0} pal/40""", dg.soluonggoi_ctn.DropTrailingZeros());
            }

            if (strSize.StartsWith("0") | strSize.StartsWith("F") | strSize == "S1")
            {
                var cellRow6 = s1.CreateRowVNN(row + 1).CreateCell(col1 + khoangCachChuVaHinh);
                cellRow6.SetCellValue("Size:");

                var cellRow6_2 = s1.GetRow(row + 1).CreateCell(col1 + khoangCachChuVaHinh + 1);
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

                var cellRow7 = s1.CreateRowVNN(row + 2).CreateCell(col1 + khoangCachChuVaHinh);
                cellRow7.SetCellValue(donggoi);

                var cellRow8 = s1.CreateRowVNN(row + 3).CreateCell(col1 + khoangCachChuVaHinh);
                cellRow8.SetCellValue("Pallet size: " + palletSize);

                var cellRow9 = s1.CreateRowVNN(row + 4).CreateCell(col1 + khoangCachChuVaHinh);
                cellRow9.SetCellValue(qtyCont);

                if (gsp != null)
                {
                    var cellRow10 = s1.CreateRowVNN(row + 5).CreateCell(col1 + khoangCachChuVaHinh);
                    cellRow10.SetCellValue(string.Format("FOB PRICE: {0} USD", gsp.gia.GetValueOrDefault(0).ToString("#,#0.00")));
                    cellRow10.CellStyle = s12_Bold_notWrapT_notBorder_LEFT;
                }
            }
            else
            {
                md_bo boMain = null;
                if (strSize.StartsWith("S"))
                    boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == strSize).FirstOrDefault();
                else
                {
                    var maBoCha = "S6";
                    var maS = sp.ma_sanpham.Substring(0, 9) + maBoCha + sp.ma_sanpham.Substring(11);
                    var spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
                    if (spS == null)
                    {
                        maBoCha = "S5";
                        maS = sp.ma_sanpham.Substring(0, 9) + maBoCha + sp.ma_sanpham.Substring(11);
                        spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
                    }
                    if (spS == null)
                    {
                        maBoCha = "S4";
                        maS = sp.ma_sanpham.Substring(0, 9) + maBoCha + sp.ma_sanpham.Substring(11);
                        spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
                    }
                    if (spS == null)
                    {
                        maBoCha = "S3";
                        maS = sp.ma_sanpham.Substring(0, 9) + maBoCha + sp.ma_sanpham.Substring(11);
                        spS = db.md_sanphams.Where(s => s.ma_sanpham == maS).FirstOrDefault();
                    }
                    if (spS == null)
                    {
                        maBoCha = "S2";
                    }

                    boMain = db.md_bos.Where(s => s.ma_bo == strSize & s.ma_bo_cha == maBoCha).FirstOrDefault();
                }

                int countR = 0;
                foreach (var cai in db.md_bo_chitiets.Where(s => s.md_bo_id == boMain.md_bo_id).OrderBy(s => s.md_bo_detail).ToList())
                {
                    countR++;
                    var maCai = sp.ma_sanpham.Substring(0, 9) + cai.md_bo_detail + sp.ma_sanpham.Substring(11);

                    var spCai = db.md_sanphams.Where(s => s.ma_sanpham == maCai).FirstOrDefault();

                    if (spCai == null)
                        throw new Exception(maCai);

                    var cellRow = s1.CreateRowVNN(row + countR).CreateCell(col1 + khoangCachChuVaHinh);
                    cellRow.SetCellValue(string.Format(@"Size {0}:", cai.md_bo_detail));

                    string cmVal = "", inchVal = "";
                    cellRow = s1.GetRow(row + countR).CreateCell(col1 + khoangCachChuVaHinh + 1);
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

                var cellRow2 = s1.CreateRowVNN(row + countR + 1).CreateCell(col1 + khoangCachChuVaHinh);
                cellRow2.SetCellValue(donggoi);

                cellRow2 = s1.CreateRowVNN(row + countR + 2).CreateCell(col1 + khoangCachChuVaHinh);
                cellRow2.SetCellValue(palletSize);

                cellRow2 = s1.CreateRowVNN(row + countR + 3).CreateCell(col1 + khoangCachChuVaHinh);
                cellRow2.SetCellValue(qtyCont);

                if (gsp != null)
                {
                    cellRow2 = s1.CreateRowVNN(row + countR + 4).CreateCell(col1 + khoangCachChuVaHinh);
                    cellRow2.SetCellValue(string.Format("FOB PRICE: {0} USD", gsp.gia.GetValueOrDefault(0).ToString("#,#0.00")));
                    cellRow2.CellStyle = s12_Bold_notWrapT_notBorder_LEFT;
                }
            }

            end:;
            return row;
        }

        public int add3In1Pages(int row, List<spsRow> msCLs)
        {
            spsRow spR = null;
            row += 4;
            
            #region Sản Phẩm 1
            spR = msCLs.Skip(0).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Sản Phẩm 1

            row += 16;
            

            #region Sản Phẩm 2
            spR = msCLs.Skip(1).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            //more += spR == null ? 1 : 0;
            #endregion Sản Phẩm 2

            row += 16;

            #region Sản Phẩm 3
            spR = msCLs.Skip(2).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Sản Phẩm 3

            row += 9;

            return row;
        }

        public int add4In1Pages(int row, List<spsRow> msCLs)
        {
            spsRow spR = null;
            row += 6;
            #region Sản Phẩm 1
            spR = msCLs.Skip(0).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Sản Phẩm 1

            #region Sản Phẩm 2
            spR = msCLs.Skip(1).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 10);
            #endregion Sản Phẩm 2

            row += 18;

            #region Sản Phẩm 3
            spR = msCLs.Skip(2).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Sản Phẩm 3

            #region Sản Phẩm 4
            spR = msCLs.Skip(3).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 10);
            #endregion Sản Phẩm 4

            row += 9;
            return row;
        }

        public int add6In1Pages(int row, List<spsRow> msCLs)
        {
            spsRow spR = null;
            row += 3;

            #region Sản Phẩm 1
            spR = msCLs.Skip(0).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Sản Phẩm 1

            #region Sản Phẩm 2
            spR = msCLs.Skip(1).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 10);
            #endregion Sản Phẩm 2

            row += 14;

            #region Sản Phẩm 3
            spR = msCLs.Skip(2).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Sản Phẩm 3

            #region Sản Phẩm 4
            spR = msCLs.Skip(3).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 10);
            #endregion Sản Phẩm 4

            row += 14;

            #region Sản Phẩm 5
            spR = msCLs.Skip(4).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Sản Phẩm 5

            #region Sản Phẩm 6
            spR = msCLs.Skip(5).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 10);
            #endregion Sản Phẩm 6

            row += 8;
            return row;
        }

        public int addRowInPage(int row, List<spsRow> msCLs)
        {
            if (layoutHangHoa == 3)
                row = add3In1Pages(row, msCLs);
            else if (layoutHangHoa == 4)
                row = add4In1Pages(row, msCLs);
            else if (layoutHangHoa == 6)
                row = add6In1Pages(row, msCLs);

            return row;
        }
    }
}
