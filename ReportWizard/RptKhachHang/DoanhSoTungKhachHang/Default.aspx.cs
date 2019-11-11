// using System;
// using System.Collections.Generic;
// using System.Linq;
// using System.Web;
// using System.Web.UI;
// using System.Web.UI.WebControls;
// using System.Data.SqlClient;
// using System.Data;
// using DevExpress.XtraReports.UI;
// using System.Drawing;
// using System.Collections;
// using System.ComponentModel;

// public partial class PrintControllers_DoanhSoTungKH_Default : System.Web.UI.Page
// {
    // protected void Page_Load(object sender, EventArgs e)
    // {
        // String id = Context.Request.QueryString["id"];
        // rptInDonHang report = new rptInDonHang();
        // String sql = this.CreateSql(id);
        // this.viewReport(report, sql);
		// //Response.Write(sql);
    // }

    // public void ExportExcel(HttpContext context){
		// HSSFWorkbook hssfworkbook = new HSSFWorkbook();
        // ISheet s1 = hssfworkbook.CreateSheet("Sheet1");
		// HSSFSheet hssfsheet = (HSSFSheet)s1;
		
		// Excel_Format ex_fm = new Excel_Format(hssfworkbook); 
        // ICellStyle cellBold = ex_fm.getcell(12, true, true, "", "L", "T");
		// //-- 
		// ICellStyle cellHeader = ex_fm.getcell(18, true, true, "", "C", "T");
		// //-- 
		// ICellStyle cellHeader_n = ex_fm.getcell(12, false, true, "", "C", "T");
		// //--
		// ICellStyle celltext = ex_fm.getcell(12, false, true, "", "L", "T");
		// //--
		// ICellStyle rightBold = ex_fm.getcell(12, true, false, "", "R", "T");
		// ICellStyle rightBold0 = ex_fm.getcell2(12, true, false, "", "R", "T", fmt0);
		// ICellStyle rightBold3 = ex_fm.getcell2(12, true, false, "", "R", "T", fmt0i000);
		// //--
		// ICellStyle rightBold4 = ex_fm.getcell2(12, true, false, "", "R", "T", "#,##0.0000");
		// //--
		// ICellStyle right = ex_fm.getcell(12, false, false, "", "R", "T");
		// //--
		// ICellStyle leftBold = ex_fm.getcell(12, true, false, "", "L", "T");
		// //--
		// ICellStyle left = ex_fm.getcell(12, false, false, "", "L", "T");

		// ICellStyle border = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
		// ICellStyle border_center = ex_fm.getcell(12, false, true, "LRBT", "C", "T");
		// //--
		// ICellStyle borderright = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
		// //--
		// ICellStyle borderonlyleft = ex_fm.getcell(12, false, true, "L", "T", "T");
		// //--
		// ICellStyle borderWrap = ex_fm.getcell(12, true, true, "LRBT", "C", "T");
		// //--
		// ICellStyle signBold = ex_fm.getcell(12, true, true, "", "C", "C");
		// //--
		// //IDataFormat dataFormatCustom = hssfworkbook.CreateDataFormat();
		// int heigh = 22;
		// int row = 0;
		// //Logo
		// //private String logoPath, productImagePath;
		// String logoPath = System.IO.Path.Combine(Server.MapPath("~/images/"), "anco_logo_print.png");
		// //String productImagePath = Server.MapPath("~/images/products/fullsize/");
		// System.Drawing.Image logo = System.Drawing.Image.FromFile(logoPath);
        // MemoryStream mslogo = new MemoryStream();
        // logo.Save(mslogo, System.Drawing.Imaging.ImageFormat.Jpeg);

        // IDrawing patriarchlogo = s1.CreateDrawingPatriarch();
        // HSSFClientAnchor anchorlogo = new HSSFClientAnchor(0, 0, 0, 0, 1, 0, 2, 3);
        // anchorlogo.AnchorType = 3;

        // int indexlogo = hssfworkbook.AddPicture(mslogo.ToArray(), PictureType.JPEG);
        // IPicture signaturePicturelogo = patriarchlogo.CreatePicture(anchorlogo, indexlogo);
		
		// List<string> headerLst = new List<string>();
		// headerLst.Add("ANCO COMPANY LIMITED","3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam");
		// headerLst.Add("Tel.: (84-274) 3740 973   Fax:  (84-274) 3740 621  Email: anco@ancopottery.com");
		// headerLst.Add("PROFORMA INVOICE");
		
		// IRow rowHeader = s1.CreateRow(0);
		// int i = 0;
		
		// foreach(string item in headerLst) {
			// rowHeader.CreateCell(i).SetCellValue(item);
			// s1.SetColumnWidth(i,6000);
			// s1.GetRow(0).GetCell(i).CellStyle = cellHeader1;
			// i++;
		// }
			
		// s1.GetRow(0).HeightInPoints = 20;
			
		// int iRow = 1;
		// foreach (var item in lstStr)
		// {
			// IRow rowDetails = s1.CreateRow(iRow);
			// rowDetails.CreateCell(0).SetCellValue(item.maSP);
			// rowDetails.CreateCell(1).SetCellValue(item.ktSP);
			// rowDetails.GetCell(0).CellStyle = cellcenter;
			// rowDetails.GetCell(1).CellStyle = cellcenter;
			// iRow++;
		// }
		
		// this.SaveFile(hssfworkbook, filenameLC);
	// }

    // public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName)
    // {
        // MemoryStream exportData = new MemoryStream();
        // hsswb.Write(exportData);

        // Response.ContentType = "application/vnd.ms-excel";
        // Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", saveAsFileName));
        // Response.Clear();
        // Response.BinaryWrite(exportData.GetBuffer());
        // Response.End();
    // }
// }