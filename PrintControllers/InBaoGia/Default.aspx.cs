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
    protected void Page_Load(object sender, EventArgs e)
    {
        type = Request.QueryString["type"];
        //try
        {
            c_baogia_id = Request.QueryString["c_baogia_id"];
            String logoPath = System.IO.Path.Combine(Server.MapPath("~/images/"), "anco_logo_print.png");
            String imgPath = Public.imgProducts;

            c_baogia bg = db.c_baogias.FirstOrDefault(p => p.c_baogia_id.Equals(c_baogia_id));
            HSSFWorkbook wb = null;
			if(bg != null) 
			{
				//if (bg.isform.Value)
				//{
				//	BaoGiaMauReport rptBaoGia = new BaoGiaMauReport(c_baogia_id, logoPath, imgPath);
				//	wb = rptBaoGia.CreateWBQuotation();
				//	this.SaveFile(wb, "AncoQuotation_R.xls");				
				//}
				//else
				//{
					var rptBaoGia = new BaoGiaReport(c_baogia_id, logoPath, imgPath);
                    rptBaoGia.TypeReport = type;
					wb = rptBaoGia.CreateWBQuotation();
					this.SaveFile(wb, bg.isform.GetValueOrDefault(false) ? "AncoQuotation_R.xls" : "AncoQuotation.xls");
				//}
			}
			else 
			{
				var rptBaoGia = new BaoGiaReport(c_baogia_id, logoPath, imgPath);
				wb = rptBaoGia.CreateWBQuotation();
				this.SaveFile(wb, "AncoQuotationQR_R.xls");
			}
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

            var result = OfficeToPDF.ExcelConverter.Convert(url, urlPDF, null, new List<AvariablePrj.lstIamge>(), new List<AvariablePrj.lstText>());
            File.Delete(url);

            Response.Write(result);
            if (result.Length <= 0)
                Response.Redirect(string.Format("../../ViewPDFPublic/index.aspx?urlpdf=../ReportPdf/{0}.pdf&zoomprint=0.999&zoom=page-width&remove=true", fileName));
        }
        else
        {
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




