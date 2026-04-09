using DevExpress.XtraReports.UI;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using Spire.Xls;
using System;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using static AvariablePrj;


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
            String logoPath = System.IO.Path.Combine(Server.MapPath("~/images/"), "anco_logo_print.png");
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
        var fileName = "DSDH_" + c_baogia_id + "_" + Guid.NewGuid().ToString();
        string url = Server.MapPath(string.Format(@"ReportPdf/{0}.xls", fileName));
        url = url.Replace("PrintControllers\\InBaoGia\\", "");

        using (var xfile = new FileStream(url, FileMode.Create, System.IO.FileAccess.ReadWrite))
        {
            hsswb.Write(xfile);
            xfile.Close();
            xfile.Dispose();
        }

        var s1 = hsswb.GetSheetAt(0);
        var excel = new OfficeToPDF.ExcelConverter();
        excel.lstImage = lstImage;
        excel.lstText = null;
        if (type == "pdf")
        {
            var urlPDF = url.Replace(fileName + ".xls", fileName + ".pdf");

            var result = excel.ConvertInterop(url, urlPDF, s1.LastRowNum, 0);
            File.Delete(url);

            Response.Write(result);
            if (result.Length <= 0)
                Response.Redirect(string.Format("../../ViewPDFPublic/index.aspx?urlpdf=../ReportPdf/{0}.pdf&zoomprint=0.999&zoom=page-width&remove=true", fileName));
        }
        else
        {
            var urlXls = url.Replace(fileName + ".xls", fileName + "1.xls");
            var result = excel.ConvertInterop(url, urlXls, s1.LastRowNum, 0);
            File.Delete(url);
            Response.Write(result);
            if (result.Length <= 0)
            {
                var data = "";
                data += "oper=downloadFile";
                data += string.Format("&name={0}", saveAsFileName);
                data += string.Format("&path=ReportPdf/{0}1.xls", fileName);
                data += string.Format("&remove=true");
                Response.Redirect(string.Format("../../Controllers/API_System.ashx?{0}", data));
            }
        }
	}
}




