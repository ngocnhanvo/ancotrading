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
            HSSFWorkbook wb = rptDSDH.CreateWBPI();

            this.SaveFile(wb, "Danh-Sach-Dat-Hang-" + DateTime.Now.ToString() + ".xls");
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }
    }

    public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName)
    {
        if (type == "pdf")
        {
            var fileName = "DSDH_" + c_danhsachdathang_id + "_" + Guid.NewGuid().ToString();
            string url = Server.MapPath(string.Format(@"ReportPdf/{0}.xls", fileName));
            url = url.Replace("PrintControllers\\InDonDatHang\\", "");
            var file = new FileStream(url, FileMode.Create);
            hsswb.Write(file);
            file.Close();

            var workbook = new Spire.Xls.Workbook();
            workbook.LoadFromFile(url);
            var urlPDF = url.Replace(fileName + ".xls", fileName + ".pdf");
            workbook.SaveToFile(urlPDF, Spire.Xls.FileFormat.PDF);
            workbook.Dispose();

            File.Delete(url);

            Response.Redirect(string.Format("../../ReportPdf/{0}.pdf", fileName));
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
