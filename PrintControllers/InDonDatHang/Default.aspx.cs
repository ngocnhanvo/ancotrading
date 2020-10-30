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

public partial class PrintControllers_InDonDatHang_Default : System.Web.UI.Page
{
    LinqDBDataContext db = new LinqDBDataContext();
    string type = "", c_danhsachdathang_id = "";
    List<Dictionary<string, string>> lstimage = new List<Dictionary<string, string>>();
    List<Dictionary<string, string>> lstText = new List<Dictionary<string, string>>();
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            type = Request.QueryString["type"];
            c_danhsachdathang_id = Request.QueryString["c_danhsachdathang_id"];
            String logoPath = System.IO.Path.Combine(Server.MapPath("~/images/"), "anco_logo_print.png");
            String imgPath = Server.MapPath("~/images/products/fullsize/");
            DanhSachDatHangReport rptDSDH = new DanhSachDatHangReport(c_danhsachdathang_id, logoPath, imgPath);
			rptDSDH.guiNCC = Request.QueryString["DSDHG"] == "False";
            rptDSDH.TypePrint = type;
            lstimage = rptDSDH.Lstimage;
            lstText = rptDSDH.LstText;
            HSSFWorkbook wb = rptDSDH.CreateWBPI();

            this.SaveFile(wb, "Danh-Sach-Dat-Hang-" + DateTime.Now.ToString() + ".xls");
        }
        catch (Exception ex)
        {
            Response.Write(ex + "");
        }
    }

    public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName)
    {
        var workbook = new Spire.Xls.Workbook();
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
        else 
        {
            var fileName = "DSDH_" + c_danhsachdathang_id + "_" + Guid.NewGuid().ToString();
            string url = Server.MapPath(string.Format(@"ReportPdf/{0}.xls", fileName));
            url = url.Replace("PrintControllers\\InDonDatHang\\", "");

            var exportData = new MemoryStream();
            hsswb.Write(exportData);
            workbook.LoadFromStream(exportData);

            foreach (var item in lstText)
            {
                var row = int.Parse(item["row"]) + 1;
                var column = int.Parse(item["column"]);
                var text = item["text"];
                var top = int.Parse(item["top"]);
                var left = int.Parse(item["left"]);
                var width = int.Parse(item["width"]);
                var height = int.Parse(item["height"]);

                width = width == 0 ? 200 : width;
                height = height == 0 ? 23 : width;
                if (text.Length > 0)
                {
                    var textbox = workbook.ActiveSheet.TextBoxes.AddTextBox(row, column, height, width) as Spire.Xls.Core.Spreadsheet.Shapes.XlsTextBoxShape;
                    textbox.Text = text;
                    textbox.Line.Weight = 0;
                    textbox.Line.Visible = false;
                    textbox.IsTextLocked = true;
                    textbox.HasFill = false;
                    //textbox.LeftColumn = 0;
                    textbox.LeftColumnOffset = left;
                    textbox.TopRowOffset = top;
                    textbox.HasLineFormat = true;
                    var font = workbook.CreateFont();
                    font.FontName = "Arial";
                    font.Size = 10.25;
                    font.IsBold = false;
                    font.Color = System.Drawing.Color.Black;
                    Response.Write(textbox.Text.Length + "\n");
                    (new Spire.Xls.RichText(textbox.RichText)).SetFont(0, textbox.Text.Length - 1, font);
                    //set background color
                    //textbox.Fill.FillType = Spire.Xls.ShapeFillType.SolidColor;
                    //textbox.Fill.ForeKnownColor = Spire.Xls.ExcelColors.BlueGray;
                    string NameColumn = ((char)(column + 65)).ToString() + row;
                    workbook.ActiveSheet.Range[NameColumn].Text = "";
                }
            }

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
                picture.Width = picture.Width > width ? (int)(width - 1) : picture.Width;
                var rateColumnAndPicture = (width - picture.Width) / 2 * 8;
                rateColumnAndPicture = rateColumnAndPicture <= 0 ? 0 : rateColumnAndPicture;
                picture.LeftColumnOffset = (int)rateColumnAndPicture;
                picture.TopRowOffset = 5;
            }
            //workbook.Save();

            if (type == "pdf")
            {
                var urlPDF = url.Replace(fileName + ".xls", fileName + ".pdf");
                workbook.SaveToFile(urlPDF, Spire.Xls.FileFormat.PDF);
                workbook.Dispose();
                //File.Delete(url);

                Response.Redirect(string.Format("../../ViewPDFPublic/index.aspx?urlpdf=../ReportPdf/{0}.pdf&zoomprint=1", fileName));
            }
            else
            {
                workbook.SaveToStream(exportData);
                workbook.Dispose();
                //File.Delete(url);

                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", saveAsFileName));
                Response.Clear();
                Response.BinaryWrite(exportData.GetBuffer());
                Response.End();
            }
        }
    }
}
