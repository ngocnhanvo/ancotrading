using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System.Data;
using System.IO;
using NPOI.SS.Util;
using ExcelLibrary.SpreadSheet;

public partial class PrintControllers_ExportForImport_Default : System.Web.UI.Page
{
	private LinqDBDataContext db = new LinqDBDataContext();
	string id = Guid.NewGuid().ToString().Replace("-", "").ToLower();
	string filePath = "", filenameLC = "";
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        Button1.Visible = false;
        var lst = txtMSPs.InnerText.Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList();
        this.NewFromCellCollection(Context, lst);
    }

    public void NewFromCellCollection(HttpContext context, List<string> cellCollection)
    {
		int totalCount = cellCollection.Count;
		int rowErr = 0;
		var lstMSP = new List<string>();
		for (int i = 0; i < totalCount; i++)
		{
			try
            {
				string ma_sanpham = cellCollection[i];
                lstMSP.Add(ma_sanpham);
			}
			catch {
				rowErr++;
				if(rowErr <= 500)
					totalCount += 1;
			}
		}
		
		String sql = string.Format(@"
		select
            sp.ma_sanpham as [Mã Số Anco1],
	        sp.ma_sanpham as [Mã Số Anco], 
            sp.mota_tiengviet as [Mô Tả Tiếng Việt], 
            sp.mota_tienganh as [Mô Tả Tiếng Anh], 
            155 as [Định Khoản],
	        dvt.ten_dvt as [Đơn Vị Tính],
	        kd.ten_tv as [Hình dáng],
	        '' as [Nhóm năng lực],
	        sp.trongluong as [Trọng lượng],
	        sp.dientich as [Diện tích],
	        null as [Độ khó],
	        null as [HSTT riêng],
	        null as [CBM mặc định],
	        null as [NCC mặc định],
	        N'Kho hàng sau hoàn thiện' as [Kho mặc định],
	        N'Kho tồn thành phẩm ANCO1' as [Kho tồn],
	        null as [Quy trình (Xoay, Rót, Cán)],
	        null as [Mua ngoài],
            N'VAT10' as [Thuế],
	        0 as [Bán thành phẩm],
	        null as [Nơi giao hàng],
	        null as [Ghi chú],
	        sp.l_cm as [L (cm)],
	        sp.w_cm as [W (cm)],
	        sp.h_cm as [H (cm)]
        from md_sanpham sp
        left join md_donvitinhsanpham dvt on dvt.md_donvitinhsanpham_id = sp.md_donvitinhsanpham_id
        left join md_kieudang kd on kd.md_kieudang_id = sp.md_kieudang_id
        where sp.ma_sanpham in ('{0}')
        order by sp.ma_sanpham
		", string.Join("','", lstMSP));

        DataTable dt = mdbc.GetData(sql);
		
		if (dt.Rows.Count > 0)
        {
            HSSFWorkbook hssfworkbook = new HSSFWorkbook();
            ISheet s1 = hssfworkbook.CreateSheet("Sheet1");
			HSSFSheet hssfsheet = (HSSFSheet)s1;
			
			Excel_Format ex_fm = new Excel_Format(hssfworkbook);
			ICellStyle cellHeader = ex_fm.getcell(11, true, true, "", "C", "T");
			ICellStyle cellHeader1 = ex_fm.getcell(10, true, true, "", "C", "T");
			ICellStyle cellcenter = ex_fm.getcell(9, false, true, "", "C", "T");
            ICellStyle cellNumber0 = ex_fm.getcell2(9, false, true, "", "R", "T", "#,#0");
            ICellStyle cellNumber1 = ex_fm.getcell2(9, false, true, "", "R", "T", "#,#0.0");
            ICellStyle cellNumber2 = ex_fm.getcell2(9, false, true, "", "R", "T", "#,#0.00");
            ICellStyle cellNumber3 = ex_fm.getcell2(9, false, true, "", "R", "T", "#,#0.000");
            IRow rowHeader = s1.CreateRow(0);
            int i = 0;
            foreach (DataColumn col in dt.Columns)
            {
                rowHeader.CreateCell(i).SetCellValue(col.ColumnName);
                s1.SetColumnWidth(i, 4000);
                if (new int[] { 0, 1, 6, 7, 16, 20, 21 }.Contains(i))
                {
                    s1.SetColumnWidth(i, 4000);
                }
                else if (new int[] { 2, 3, 14, 15 }.Contains(i))
                {
                    s1.SetColumnWidth(i, 7000);
                }
                else if (new int[] { 4, 5, 8, 9, 10, 11, 12, 13, 17, 18, 19, 22, 23, 24 }.Contains(i))
                {
                    s1.SetColumnWidth(i, 2500);
                }
                s1.GetRow(0).GetCell(i).CellStyle = cellHeader1;
                i++;
				
            }
			s1.GetRow(0).HeightInPoints = 30;
				
            int iRow = 1;
            foreach (DataRow row in dt.Rows)
            {
                IRow rowDetails = s1.CreateRow(iRow);
                rowDetails.CreateCell(0).SetCellValue(row[0].ToString());
                rowDetails.CreateCell(1).SetCellValue(row[1].ToString());
                rowDetails.CreateCell(2).SetCellValue(row[2].ToString());
				rowDetails.CreateCell(3).SetCellValue(row[3].ToString());
				rowDetails.CreateCell(4).SetCellValue(double.Parse(row[4].ToString()));
                rowDetails.GetCell(4).CellStyle = cellNumber0;
                rowDetails.CreateCell(5).SetCellValue(row[5].ToString());
				rowDetails.CreateCell(6).SetCellValue(row[6].ToString());
				rowDetails.CreateCell(7).SetCellValue(row[7].ToString());
                rowDetails.CreateCell(8).SetCellValue(double.Parse(row[8].ToString()));
                rowDetails.GetCell(8).CellStyle = cellNumber2;
                rowDetails.CreateCell(9).SetCellValue(double.Parse(row[9].ToString()));
                rowDetails.GetCell(9).CellStyle = cellNumber3;
                rowDetails.CreateCell(14).SetCellValue(row[14].ToString());
                rowDetails.CreateCell(15).SetCellValue(row[15].ToString());
                rowDetails.CreateCell(18).SetCellValue(row[18].ToString());
                rowDetails.CreateCell(19).SetCellValue(double.Parse(row[19].ToString()));
                rowDetails.GetCell(19).CellStyle = cellNumber0;
                rowDetails.CreateCell(22).SetCellValue(double.Parse(row[22].ToString()));
                rowDetails.GetCell(22).CellStyle = cellNumber1;
                rowDetails.CreateCell(23).SetCellValue(double.Parse(row[23].ToString()));
                rowDetails.GetCell(23).CellStyle = cellNumber1;
                rowDetails.CreateCell(24).SetCellValue(double.Parse(row[24].ToString()));
                rowDetails.GetCell(24).CellStyle = cellNumber1;
                iRow++;
            }
            Button1.Visible = true;
            String saveAsFileName = "ThongTinSanPhamImport.xls";
            this.SaveFile(hssfworkbook, saveAsFileName);
        }
        else
        {
            Button1.Visible = true;
            Response.Write("Không có dữ liệu.");
        }
    }
	
	public bool isRound(string kd, LinqDBDataContext db) 
	{
		var kieudang = db.md_kieudangs.Where(s=>s.md_kieudang_id == kd & s.ma_kieudang == "ROU").FirstOrDefault();
		if(kieudang == null)
			return false;
		else
			return true;
	}
	
	public void SaveFile(HSSFWorkbook hsswb, String saveAsFileName)
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