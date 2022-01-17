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

        public int add6In1Pages(int row, List<dtsRow> msCLs)
        {
            int space = 10;
            row += 2;
            dtsRow msCL = null;
            string imgPath = "";

            #region Đề tài 1
            msCL = msCLs.Skip(0).Take(1).FirstOrDefault();
            if (msCL != null)
            {
                imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}.jpg", Public.imgPattern, msCL.code_cl, msCL.code_dt));
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
                anchorLogo.Col1 = 0;
                anchorLogo.Row1 = row;
                anchorLogo.Col2 = 4;
                anchorLogo.Row2 = row + 11;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
                s1.CreateRow(row - 1).CreateCell(0).SetCellValue(msCL.ta_ngan);
            }
            #endregion Đề tài 1

            #region Đề tài 2
            msCL = msCLs.Skip(1).Take(1).FirstOrDefault();
            if (msCL != null)
            {
                imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}.jpg", Public.imgPattern, msCL.code_cl, msCL.code_dt));
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
                anchorLogo.Col1 = 6;
                anchorLogo.Row1 = row;
                anchorLogo.Col2 = 10;
                anchorLogo.Row2 = row + 11;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
                s1.GetRow(row - 1).CreateCell(6).SetCellValue(msCL.ta_ngan);
            }
            #endregion Đề tài 2

            #region Đề tài 3
            msCL = msCLs.Skip(2).Take(1).FirstOrDefault();
            if (msCL != null)
            {
                imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}.jpg", Public.imgPattern, msCL.code_cl, msCL.code_dt));
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
                anchorLogo.Col1 = 0;
                anchorLogo.Row1 = row + 12 + space;
                anchorLogo.Col2 = 4;
                anchorLogo.Row2 = row + 11 + 12 + space;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
                s1.CreateRow(row + 12 - 1 + space).CreateCell(0).SetCellValue(msCL.ta_ngan);
            }
            #endregion

            #region Đề tài 4
            msCL = msCLs.Skip(3).Take(1).FirstOrDefault();
            if (msCL != null)
            {
                imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}.jpg", Public.imgPattern, msCL.code_cl, msCL.code_dt));
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
                anchorLogo.Col1 = 6;
                anchorLogo.Row1 = row + 12 + space;
                anchorLogo.Col2 = 10;
                anchorLogo.Row2 = row + 11 + 12 + space;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
                s1.GetRow(row + 12 - 1 + space).CreateCell(6).SetCellValue(msCL.ta_ngan);
            }
            #endregion Đề tài 4

            #region Đề tài 5
            msCL = msCLs.Skip(4).Take(1).FirstOrDefault();
            if (msCL != null)
            {
                imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}.jpg", Public.imgPattern, msCL.code_cl, msCL.code_dt));
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
                anchorLogo.Col1 = 0;
                anchorLogo.Row1 = row + 12 * 2 + space * 2;
                anchorLogo.Col2 = 4;
                anchorLogo.Row2 = row + 11 + 12 * 2 + space * 2;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
                s1.CreateRow(row + 12 * 2 - 1 + space * 2).CreateCell(0).SetCellValue(msCL.ta_ngan);
            }
            #endregion Đề tài 5

            #region Đề tài 6
            msCL = msCLs.Skip(5).Take(1).FirstOrDefault();
            if (msCL != null)
            {
                imgPath = ExcuteSignalRStatic.mapPathSignalR(string.Format(@"~/{0}/{1}-{2}.jpg", Public.imgPattern, msCL.code_cl, msCL.code_dt));
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
                anchorLogo.Col1 = 6;
                anchorLogo.Row1 = row + 12 * 2 + space * 2;
                anchorLogo.Col2 = 10;
                anchorLogo.Row2 = row + 11 + 12 * 2 + space * 2;
                anchorLogo.AnchorType = (int)AnchorType.MoveDontResize;
                int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
                var signaturePicturelogo = patriarchlogo.CreatePicture(anchorLogo, indexlogo);
                s1.GetRow(row + 12 * 2 - 1 + space * 2).CreateCell(6).SetCellValue(msCL.ta_ngan);
            }
            #endregion Đề tài 6
            
            row = row + 11 + 12 * 2 + 1 + space * 2;
            return row;
        }
    }
}
