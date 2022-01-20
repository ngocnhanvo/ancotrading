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
    public class DeTaiTrenTrang
    {
        public class dtsRow
        {
            public string md_detai_id { get; set; }
            public string code_cl { get; set; }
            public string code_dt { get; set; }
            public string tv_ngan { get; set; }
            public string ta_ngan { get; set; }
        }

        public HSSFWorkbook hssfworkbook = null;
        public Excel_Format ex_fm = null;
        public ISheet s1 = null;
        public HSSFSheet hssfsheet = null;
        public PrintAnco2.InfoExcel infoExcel = new PrintAnco2.InfoExcel();
        public List<int> lstAutoSizeColumn = new List<int>();

        public List<dtsRow> msCLs { get; set; }

        public LinqDBDataContext db { get; set; }
        public int layoutDVT { get; set; }
        public int layoutDetai { get; set; }
        public bool inNgang { get; set; }

        public int createProduct_Landscape(int row, dtsRow msCL, int col1)
        {
            var khoangCachChuVaHinh = 4;

            if (msCL == null)
                goto end;

            string imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}.jpg", Public.imgPattern, msCL.code_cl, msCL.code_dt));
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

            if (img.Width <= 200 & img.Height <= 150)
                signaturePicturelogo.Resize(1.2);
            else if (img.Width <= 300 & img.Height <= 300)
                signaturePicturelogo.Resize(0.6);
            else
                signaturePicturelogo.Resize(0.5);

            s1.CreateRowVNN(row - 1).CreateCell(col1).SetCellValue(msCL.ta_ngan);

        end:;
            return row;
        }

        public int add6In1Pages(int row, List<dtsRow> msCLs)
        {
            dtsRow spR = null;
            row += 3;
            var space = 6;
            #region Đề tài 1
            spR = msCLs.Skip(0).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Đề tài 1

            #region Đề tài 2
            spR = msCLs.Skip(1).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space);
            #endregion Đề tài 2

            if (!inNgang)
                row += 20;

            #region Đề tài 3
            spR = msCLs.Skip(2).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, inNgang ? space * 2 : 0);
            #endregion Đề tài 3

            if (inNgang)
                row += 30;

            #region Đề tài 4
            spR = msCLs.Skip(3).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, inNgang ? 0 : space);
            #endregion Đề tài 4

            if (!inNgang)
                row += 20;

            #region Đề tài 5
            spR = msCLs.Skip(4).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, inNgang ? space : 0);
            #endregion Đề tài 5

            #region Đề tài 6
            spR = msCLs.Skip(5).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, inNgang ? space * 2 : space);
            #endregion Đề tài 6

            row += inNgang ? 14 : 12;
            return row;
        }

        public int add4In1Pages(int row, List<dtsRow> msCLs)
        {
            dtsRow spR = null;
            row += 6;
            var space = 6;
            #region Đề tài 1
            spR = msCLs.Skip(0).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Đề tài 1

            #region Đề tài 2
            spR = msCLs.Skip(1).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space);
            #endregion Đề tài 2

            row += 30;

            #region Đề tài 3
            spR = msCLs.Skip(2).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, 0);
            #endregion Đề tài 3

            #region Đề tài 4
            spR = msCLs.Skip(3).Take(1).FirstOrDefault();
            createProduct_Landscape(row, spR, space);
            #endregion Đề tài 4

            row += inNgang ? 14 : 12;
            return row;
        }

        public int addRowInPage(int row, List<dtsRow> msCLs)
        {
            if (layoutDetai == 4)
                row = add4In1Pages(row, msCLs);
            else if (layoutDetai == 6)
                row = add6In1Pages(row, msCLs);

            return row;
        }
    }
}
