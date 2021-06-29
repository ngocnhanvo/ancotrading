using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Data.SqlClient;
using System.Data;
using DevExpress.XtraReports.UI;
using System.IO;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using NPOI.HSSF.UserModel;

using System;
using Spire.Xls;
using System.Drawing;
using System.Drawing.Imaging;


public partial class PrintControllers_InBaoGia_Default : System.Web.UI.Page
{
    LinqDBDataContext db = new LinqDBDataContext();
    public string type = "", c_baogia_id = "";
    public List<AvariablePrj.lstImage> lstImage = new List<AvariablePrj.lstImage>();
    protected void Page_Load(object sender, EventArgs e)
    {
        type = Request.QueryString["type"];
        //try
        {
            c_baogia_id = Request.QueryString["c_baogia_id"];
            String logoPath = System.IO.Path.Combine(Server.MapPath("~/images/"), "VINHGIA_logo_print.png");
            String imgPath = Public.imgProducts;

            var bg = db.c_baogias.FirstOrDefault(p => p.c_baogia_id.Equals(c_baogia_id));
            HSSFWorkbook wb = null;

			var rptBaoGia = new BaoGiaReport(c_baogia_id, logoPath, imgPath);
            rptBaoGia.TypeReport = type;
            rptBaoGia.LaBaoGiaMau = bg == null ? false : bg.isform.GetValueOrDefault(false);
            rptBaoGia.LaBaoGiaMauQR = bg == null ? true : false;
            wb = rptBaoGia.CreateWBQuotation();
            lstImage = rptBaoGia.Lstimage;
            this.SaveFile(wb, bg == null ? "AncoQuotationQR_R.xls" : (bg.isform.GetValueOrDefault(false) ? "AncoQuotation_R.xls" : "AncoQuotation.xls"));
        }
        //catch (Exception ex)
        {
            //Response.Write(ex.Message);
        }
    }

    public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName)
    {
        if (type == "pdf")
        {
            var fileName = "DSDH_" + c_baogia_id + "_" + Guid.NewGuid().ToString();
            string url = Server.MapPath(string.Format(@"ReportPdf/{0}.xls", fileName));
            url = url.Replace("PrintControllers\\InBaoGia\\", "");

            var xfile = new FileStream(url, FileMode.Create, System.IO.FileAccess.ReadWrite);
            hsswb.Write(xfile);
            xfile.Close();
            xfile.Dispose();

            var urlPDF = url.Replace(fileName + ".xls", fileName + ".pdf");

            var result = OfficeToPDF.ExcelConverter.Convert(url, urlPDF, null, lstImage, new List<AvariablePrj.lstText>());
            File.Delete(url);

            Response.Write(result);
            if (result.Length <= 0)
                Response.Redirect(string.Format("../../ViewPDFPublic/index.aspx?urlpdf=../ReportPdf/{0}.pdf&zoomprint=0.999&zoom=page-width&remove=true", fileName));
        }
        else
        {
            foreach (var item in lstImage)
            {
                var image = System.Drawing.Image.FromFile(item.link);

                MemoryStream ms = new MemoryStream();
                //pull the memory stream from the image (I need this for the byte array later)
                image.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
                image.Dispose();
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

            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", saveAsFileName));
            Response.Clear();
            Response.BinaryWrite(exportData.GetBuffer());
            Response.End();
        }
	}
}




