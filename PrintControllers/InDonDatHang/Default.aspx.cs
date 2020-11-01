using System;
using System.Collections.Generic;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;

public partial class PrintControllers_InDonDatHang_Default : System.Web.UI.Page
{
    LinqDBDataContext db = new LinqDBDataContext();
    string type = "", c_danhsachdathang_id = "";
    List<AvariablePrj.lstIamge> lstimage = new List<AvariablePrj.lstIamge>();
    List<AvariablePrj.lstText> lstText = new List<AvariablePrj.lstText>();
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
                var image = System.Drawing.Image.FromFile(item.link);

                MemoryStream ms = new MemoryStream();
                //pull the memory stream from the image (I need this for the byte array later)
                image.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
                //the drawing patriarch will hold the anchor and the master information
                IDrawing patriarch = hsswb.GetSheetAt(0).CreateDrawingPatriarch();
                //store the coordinates of which cell and where in the cell the image goes
                int intx1 = item.column - 1;
                int inty1 = item.row;
                int intx2 = item.column;
                int inty2 = 1 + item.row;

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

            var xfile = new FileStream(url, FileMode.Create, System.IO.FileAccess.ReadWrite);
            hsswb.Write(xfile);
            xfile.Close();
            xfile.Dispose();

            if (type == "pdf")
            {
                var urlPDF = url.Replace(fileName + ".xls", fileName + ".pdf");

                var result = OfficeToPDF.ExcelConverter.Convert(url, urlPDF, null, lstimage, lstText);
                //File.Delete(url);

                Response.Write(result);
                if(result.Length <= 0)
                    Response.Redirect(string.Format("../../ViewPDFPublic/index.aspx?urlpdf=../ReportPdf/{0}.pdf&zoomprint=0.999&zoom=page-width", fileName));
            }
        }
    }
}
