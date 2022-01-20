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
    public class MauSacTrenTrang
    {
        public class mssRow
        {
            public string md_mausac_id { get; set; }
            public string code_cl { get; set; }
            public string code_dt { get; set; }
            public string code_mau { get; set; }
            public string tv_ngan { get; set; }
            public string ta_ngan { get; set; }
        }

        public LinqDBDataContext db { get; set; }
        public int layoutDVT { get; set; }
        public int layoutMauSac { get; set; }
        public bool inNgang { get; set; }

        public HSSFWorkbook hssfworkbook = null;
        public Excel_Format ex_fm = null;
        public ISheet s1 = null;
        public HSSFSheet hssfsheet = null;
        public PrintAnco2.InfoExcel infoExcel = new PrintAnco2.InfoExcel();
        public List<int> lstAutoSizeColumn = new List<int>();

        public List<mssRow> msCLs { get; set; }

        public int createProduct_Landscape(int row, mssRow msCL, int col1)
        {
            var khoangCachChuVaHinh = 4;

            if (msCL == null)
                goto end;

            string imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}-{3}.jpg", Public.imgColor, msCL.code_cl, msCL.code_dt, msCL.code_mau));
            if (!File.Exists(imgPath))
            {
                imgPath = ExcuteSignalRStatic.mapPathSignalR("~/" + Public.imgNotFound);
            }
            var img = System.Drawing.Image.FromFile(imgPath);
            var mslogo = new MemoryStream();
            img.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

            var patriarchlogo = s1.CreateDrawingPatriarch();
            var anchorLogo = new HSSFClientAnchor();
            anchorLogo.Dx1 = 150;
            anchorLogo.Dy1 = 10;
            anchorLogo.Dx2 = 900;
            anchorLogo.Dy2 = 253;
            anchorLogo.Col1 = col1;
            anchorLogo.Row1 = row;
            anchorLogo.Col2 = col1 + khoangCachChuVaHinh;
            anchorLogo.Row2 = row + 11;
            anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
            int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
            var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
            signaturePicturelogo.Resize(inNgang ? 1.2 : 1);
            s1.CreateRowVNN(row - 1).CreateCell(col1).SetCellValue(msCL.ta_ngan);

            end:;
            return row;
        }

        public int add6In1Pages(int row, List<mssRow> msCLs)
        {
            mssRow spR = null;
            row += 3;
            var space = inNgang ? 7 : 4;
            #region Màu sắc 1
            spR = msCLs.Skip(0).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Màu sắc 1

            #region Màu sắc 2
            spR = msCLs.Skip(1).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space);
            #endregion Màu sắc 2

            #region Màu sắc 3
            spR = msCLs.Skip(2).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space*2);
            #endregion Màu sắc 3

            row += 30;

            #region Màu sắc 4
            spR = msCLs.Skip(3).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Màu sắc 4
            
            #region Màu sắc 5
            spR = msCLs.Skip(4).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space);
            #endregion Màu sắc 5

            #region Màu sắc 6
            spR = msCLs.Skip(5).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space*2);
            #endregion Màu sắc 6

            row += inNgang ? 14 : 12;
            return row;
        }

        public int add4In1Pages(int row, List<mssRow> msCLs)
        {
            mssRow spR = null;
            row += 6;
            var space = inNgang ? 9 : 6;
            #region Màu sắc 1
            spR = msCLs.Skip(0).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Màu sắc 1

            #region Màu sắc 2
            spR = msCLs.Skip(1).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space);
            #endregion Màu sắc 2

            row += 30;

            #region Màu sắc 3
            spR = msCLs.Skip(2).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Màu sắc 3

            #region Màu sắc 4
            spR = msCLs.Skip(3).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space);
            #endregion Màu sắc 4

            row += inNgang ? 14 : 12;
            return row;
        }

        public int addRowInPage(int row, List<mssRow> msCLs)
        {
            if (layoutMauSac == 4)
                row = add4In1Pages(row, msCLs);
            else if (layoutMauSac == 6)
                row = add6In1Pages(row, msCLs);

            return row;
        }
    }
}
