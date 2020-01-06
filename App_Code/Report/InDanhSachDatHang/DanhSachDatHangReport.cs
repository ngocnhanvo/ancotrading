using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using NPOI.SS.Util;

/// <summary>
/// Summary description for BaoGiaMauReport
/// </summary>
public class DanhSachDatHangReport
{
    LinqDBDataContext db = new LinqDBDataContext();
    private String c_danhsachdathang_id, logoPath, productImagePath;

    public String LogoPath
    {
        get { return logoPath; }
        set { logoPath = value; }
    }

    public String ProductImagePath
    {
        get { return productImagePath; }
        set { productImagePath = value; }
    }

    public HSSFWorkbook CreateWBPI()
    {
        String select = String.Format(@"
                        select 
	                        dsdh.sochungtu
							, dh.sochungtu as so_po
							, dh.customer_order_no
							, dsdh.ngaylap
							, dsdh.hangiaohang_po
							, dtkd.ma_dtkd
							, dtkd.ten_dtkd
							, dtkd.tel
							, dtkd.fax
	                        , sp.ma_sanpham
							, (case when  SUBSTRING(sp.ma_sanpham,10,1) != 'F' then SUBSTRING(sp.ma_sanpham,0,9) else SUBSTRING(sp.ma_sanpham,0,12) end) as pic
							, ddsdh.ma_sanpham_khach, ddsdh.mota_tiengviet, dvt.ma_edi
                            , ddsdh.sl_dathang
							, ddsdh.gianhap
							, dsdh.huongdanlamhang
							, dsdh.huongdanlamhangchung
							, ddsdh.huongdan_dathang
	                        , gh.ma_dtkd as diachigiaohang
							, dh.sl_cont
							, dh.loai_cont
							, dsdh.discount as discountdecimal
							, ddsdh.v2
                            , (case ddsdh.sl_inner when 0 then ' ' else (cast(ddsdh.sl_inner as nvarchar) + ' ' + (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_inner)) end) as dginner
                            , (cast(ddsdh.sl_outer as nvarchar) + ' ' + (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_outer)) as dgouter
                            , (select hoten from nhanvien where manv = dsdh.nguoitao) as nguoitao
							, sp.trongluong
							, sp.mota as ghichu
							, dsdh.mota
							, ddsdh.gianhap as gianhap
							, ddsdh.sl_dathang * ddsdh.gianhap as thanhtien
                        from 
	                        c_danhsachdathang dsdh
							left join md_doitackinhdoanh dtkd on dsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
							left join md_doitackinhdoanh gh on dsdh.diachigiaohang = gh.md_doitackinhdoanh_id
	                        left join c_dongdsdh ddsdh on dsdh.c_danhsachdathang_id = ddsdh.c_danhsachdathang_id
							left join md_sanpham sp on ddsdh.md_sanpham_id = sp.md_sanpham_id
							left join md_donvitinhsanpham dvt on sp.md_donvitinhsanpham_id = dvt.md_donvitinhsanpham_id
							left join c_donhang dh  on dsdh.c_donhang_id = dh.c_donhang_id
							left join md_donggoi dg on ddsdh.md_donggoi_id = dg.md_donggoi_id
                        where
	                        dsdh.c_danhsachdathang_id = N'{0}' order by sp.ma_sanpham asc"
							, c_danhsachdathang_id == null ? "" : c_danhsachdathang_id
						);

        DataTable dt = mdbc.GetData(select);
		var tbl = dt;
        if (tbl.Rows.Count > 0)
        {
            tbl.Columns.Add("money", Type.GetType("System.String"));
			tbl.Columns.Add("mota_cong", Type.GetType("System.String"));
			tbl.Columns.Add("mota_tru", Type.GetType("System.String"));
			tbl.Columns.Add("discount", Type.GetType("System.Double"));
			tbl.Columns.Add("giatritang", Type.GetType("System.Double"));
			tbl.Columns.Add("giatrigiam", Type.GetType("System.Double"));
			tbl.Columns.Add("tongtiendatru", Type.GetType("System.Double"));
            //Header

            //Footer
            int lastRow = tbl.Rows.Count - 1;

            var strSumThanhTien = tbl.Compute("Sum(thanhtien)", string.Empty).ToString();
			double? total = 0;
			if (!string.IsNullOrEmpty(strSumThanhTien))
                total = double.Parse(strSumThanhTien);
			
			var strDiscount = tbl.Rows[0]["discountdecimal"].ToString();
			double? discount = 0;
			if (!string.IsNullOrEmpty(strDiscount))
                discount = double.Parse(strDiscount);
            
			var totalDiscount = total.GetValueOrDefault(0) * discount.GetValueOrDefault(0) / 100;
			tbl.Rows[0]["discount"] = tbl.Rows[lastRow]["discount"] = totalDiscount;
			
			var phitang = (from t in db.c_phidathangs where t.isphicong.Equals(true) && t.c_danhsachdathang_id.Equals(c_danhsachdathang_id) select t.sotien).Sum();
			tbl.Rows[0]["giatritang"] = tbl.Rows[lastRow]["giatritang"] = phitang.GetValueOrDefault(0);
			
			var phigiam = (from t in db.c_phidathangs where t.isphicong.Equals(false) && t.c_danhsachdathang_id.Equals(c_danhsachdathang_id) select t.sotien).Sum();
			tbl.Rows[0]["giatrigiam"] = tbl.Rows[lastRow]["giatrigiam"] = phigiam.GetValueOrDefault(0);
			
			var varTang = db.c_phidathangs.FirstOrDefault(tg => tg.c_danhsachdathang_id.Equals(c_danhsachdathang_id) && tg.isphicong.Equals(true));
			var varGiam = db.c_phidathangs.FirstOrDefault(gi => gi.c_danhsachdathang_id.Equals(c_danhsachdathang_id) && gi.isphicong.Equals(false));

			string dgTang, dgGiam;
			dgTang = varTang == null ? "" : varTang.mota;
			dgGiam = varGiam == null ? "" : varGiam.mota;
			
			string textMoney = "";
			double? totalUSD = total - (double)totalDiscount + (double)phitang.GetValueOrDefault(0) - (double)phigiam.GetValueOrDefault(0);
			var ma_dtkd = tbl.Rows[0]["ma_dtkd"].ToString();
			if(new string[]{ "VINHGIA" }.Contains(ma_dtkd)) {
				string m = MoneyToWord.ConvertMoneyToText(totalUSD.ToString()).Replace("Dollars", "");			
				int j =  m.LastIndexOf("and");
			
				if (m.Contains("Cents") | m.Contains("Cent"))
				{
					m = m.Replace("Cents", "").Replace("Cent", "");
					m = m.Insert(m.Length, "cents");
				}
				else {
					m = m.Replace("Cents", "").Replace("Cent", "");
				}
				textMoney = m;
			}
			else {
				textMoney = MoneyToWord.ConvertMoneyToTextVND((decimal)totalUSD.GetValueOrDefault(0));
			}
			tbl.Rows[0]["money"] = tbl.Rows[lastRow]["money"] = textMoney;
			tbl.Rows[0]["tongtiendatru"] = tbl.Rows[lastRow]["tongtiendatru"] = totalUSD;
			
			string diengiai_cong = String.Format(@"select t.mota from c_phidathang t where t.isphicong = 1 and t.c_danhsachdathang_id = '{0}'", c_danhsachdathang_id == null ? "" : c_danhsachdathang_id);
			DataTable cong = mdbc.GetData(diengiai_cong);
			var mota_cong = new List<string>();
			for(int i = 0; i < cong.Rows.Count ; i++)
			{
				mota_cong.Add(cong.Rows[i]["mota"].ToString());
			}
			
			string diengiai_tru = String.Format(@"select t.mota from c_phidathang t where t.isphicong = 0 and t.c_danhsachdathang_id = '{0}'", c_danhsachdathang_id == null ? "" : c_danhsachdathang_id);									
			DataTable tru = mdbc.GetData(diengiai_tru);
			var mota_tru = new List<string>();
			for(int i = 0; i < tru.Rows.Count; i++)
			{
				mota_tru.Add(tru.Rows[i]["mota"].ToString());
			}
			tbl.Rows[0]["mota_cong"] = tbl.Rows[lastRow]["mota_cong"] = string.Join(",", mota_cong);
			tbl.Rows[0]["mota_tru"] = tbl.Rows[lastRow]["mota_tru"] = string.Join(",", mota_tru);
			HSSFWorkbook hssfworkbook = this.CreateHSSFWorkbook(tbl, phitang, phigiam);
            String saveAsFileName = String.Format("DonDatHang-{0}.xls", DateTime.Now);
            return hssfworkbook;
        }
        else
        {
            throw new Exception("<h3>Đơn đặt hàng không có dữ liệu</h3>");
        }
    }

    public HSSFWorkbook CreateHSSFWorkbook(DataTable dt, Nullable<decimal> phitang, Nullable<decimal> phigiam)
    {
        HSSFWorkbook hssfworkbook = new HSSFWorkbook();
        ISheet s1 = hssfworkbook.CreateSheet("Sheet1");
		HSSFSheet hssfsheet = (HSSFSheet)s1;
		
		Excel_Format ex_fm = new Excel_Format(hssfworkbook); 
        ICellStyle cellBold = ex_fm.getcell(12, true, true, "", "L", "T");
		//-- 
		ICellStyle cellHeader = ex_fm.getcell(18, true, true, "", "C", "T");
		//-- 
		ICellStyle cellHeader_n = ex_fm.getcell(12, false, true, "", "C", "T");
		//--
		ICellStyle celltext = ex_fm.getcell(12, false, true, "", "L", "T");
		//--
		ICellStyle rightBold = ex_fm.getcell(12, true, false, "", "R", "T");
		//--
		ICellStyle right = ex_fm.getcell(12, false, false, "", "R", "T");
		//--
		ICellStyle leftBold = ex_fm.getcell(12, true, false, "", "L", "T");
		//--
		ICellStyle left = ex_fm.getcell(12, false, false, "", "L", "T");
		//--
		ICellStyle border_number0 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##");
		ICellStyle border_number1 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.0");
		ICellStyle border_number2 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.00");
		ICellStyle border_number3 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.000");
		ICellStyle border_number4 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.0000");
		ICellStyle border = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
		ICellStyle border_center = ex_fm.getcell(12, false, true, "LRBT", "C", "T");
		//--
		ICellStyle borderright = ex_fm.getcell(12, false, true, "LRBT", "L", "T");
		//--
		ICellStyle borderonlyleft = ex_fm.getcell(12, false, true, "L", "T", "T");
		//--
		ICellStyle borderWrap = ex_fm.getcell(12, true, true, "LRBT", "C", "T");
		//--
		ICellStyle signBold = ex_fm.getcell(12, true, true, "", "C", "C");
		//--
		HSSFUtils.CellStyleModel cellModel = new HSSFUtils.CellStyleModel(hssfworkbook);
        cellModel.BorderAll = true;
		//--
		//IDataFormat dataFormatCustom = hssfworkbook.CreateDataFormat();
		int heigh = 22;
		int row = 0;
		//set A1 - A4
		string[] a = { "ANCO COMPANY LIMITED","3B/2, 1B Hamlet, An Phu Ward, Thuan An Dist., Binh Duong Province, Vietnam","Tel.: (84-274) 3740 973   Fax:  (84-274) 3740 621  Email: anco@ancopottery.com","ĐƠN ĐẶT HÀNG"};
		for(int i = 0; i < a.Count(); i++)
		{		
			s1.CreateRow(row).CreateCell(0).SetCellValue(a[i]);
			s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 9));
			s1.GetRow(row).HeightInPoints = heigh;
			if(i == 0 | i == 3)
			{
				s1.GetRow(row).HeightInPoints = 30;
				s1.GetRow(row).GetCell(0).CellStyle = cellHeader;
			}
			else
			{
				s1.GetRow(row).GetCell(0).CellStyle = cellHeader_n;
			}
			row++;
		}
        s1.AddMergedRegion(new CellRangeAddress(5, 5, 5, 7));
        s1.AddMergedRegion(new CellRangeAddress(6, 6, 1, 9));
        s1.AddMergedRegion(new CellRangeAddress(10, 10, 1, 9));


        s1.CreateRow(4).CreateCell(1).SetCellValue("Số chứng từ:");
        s1.GetRow(4).CreateCell(2).SetCellValue(dt.Rows[0]["sochungtu"].ToString());

        s1.GetRow(4).CreateCell(4).SetCellValue("Theo P/O số:");
        s1.GetRow(4).CreateCell(5).SetCellValue(dt.Rows[0]["so_po"].ToString());
        s1.AddMergedRegion(new CellRangeAddress(4, 4, 5, 7));

        s1.CreateRow(5).CreateCell(1).SetCellValue("Ngày lập:");
        s1.GetRow(5).CreateCell(2).SetCellValue(DateTime.Parse(dt.Rows[0]["ngaylap"].ToString()).ToString("dd/MM/yyyy"));

        s1.GetRow(5).CreateCell(4).SetCellValue("Customer Order No:");
        s1.GetRow(5).CreateCell(5).SetCellValue(dt.Rows[0]["customer_order_no"].ToString());

        s1.CreateRow(6).CreateCell(1).SetCellValue("Công ty AnCơ kính đề nghị Quý Công ty/Đơn vị: " + dt.Rows[0]["ten_dtkd"].ToString());

        s1.CreateRow(7).CreateCell(1).SetCellValue("Điện thoại");
        s1.GetRow(7).CreateCell(2).SetCellValue(dt.Rows[0]["tel"].ToString());

        s1.GetRow(7).CreateCell(4).SetCellValue("Fax");
        s1.GetRow(7).CreateCell(5).SetCellValue(dt.Rows[0]["fax"].ToString());
        s1.AddMergedRegion(new CellRangeAddress(7, 7, 5, 7));

        s1.CreateRow(10).CreateCell(1).SetCellValue("Cung cấp cho công ty chúng tôi các mặt hàng với chi tiết:");

		row = 11;
		// set A13 - All
		// -- Header
		int cell = 0;
		string[] d = { "STT","Mã số","Hình ảnh","Mã khách hàng"
		,"Mô tả","ĐVT"
		,"Cbm","SL"
		,"Giá","Thành tiền","Hướng dẫn làm hàng"
		,"Đóng gói Inner","Đóng gói Outer","Trọng lượng","Xác nhận kích thước" };
		IRow rowColumnHeader = s1.CreateRow(row);
		rowColumnHeader.HeightInPoints = 47;
		for(int i = 0; i < d.Count(); i++)
		{		
			int with = 5000;
			rowColumnHeader.CreateCell(cell).SetCellValue(d[i]);
			rowColumnHeader.GetCell(i).CellStyle = borderWrap;
			if( i == 4) {
				with = 7000;
			}
			else if( i == 9) {
				with = 3000;
			}
			else if( i == 10 | i == 14 | i == 10) {
				with = 0;
			}

            if ((i == 8 | i == 9) & guiNCC == true)
                with = 0;
			s1.SetColumnWidth(cell,with);
			cell++;
		}
		row ++;
		//thu tu tong cong // dem so dong hang cua tung sochungtu
		int count_row = 1;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
			string[] e_value = {"no","ma_sanpham","","ma_sanpham_khach","mota_tiengviet","ma_edi","v2","sl_dathang"
			,"gianhap","thanhtien","huongdan_dathang","dginner","dgouter","trongluong","ghichu" };
            //
			IRow row_t = s1.CreateRow(row); row_t.HeightInPoints = 80;
            row_t.CreateCell(2);
            try
            {
                String imgPath = System.IO.Path.Combine(productImagePath, dt.Rows[i]["pic"].ToString() + ".jpg");
                System.Drawing.Image image = System.Drawing.Image.FromFile(imgPath);
                MemoryStream ms = new MemoryStream();
                image.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);

                IDrawing patriarch = s1.CreateDrawingPatriarch();
                HSSFClientAnchor anchor = new HSSFClientAnchor(0, 0, 0, 0, 2, 12 + i, 3, 13 + i);
                anchor.AnchorType = 2;

                int index = hssfworkbook.AddPicture(ms.ToArray(), PictureType.JPEG);
                IPicture signaturePicture = patriarch.CreatePicture(anchor, index);
            }
            catch
            { }

			for (int j = 0; j < e_value.Length; j++)
			{
				var cel_row_t = row_t.CreateCell(j);
				if(e_value[j] == "no") {
					cel_row_t.SetCellValue(count_row);
					cel_row_t.CellStyle = border_center; 
				}
				else if(e_value[j] == "thanhtien") {
                    if (guiNCC == false)
                        cel_row_t.CellFormula = String.Format("H{0}*I{0}",row + 1);
					cel_row_t.CellStyle = border_number1;
				}
				else if(e_value[j] == "trongluong"){
					cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
					cel_row_t.CellStyle = border_number1;
				}
				else if(e_value[j] == "sl_dathang") {
					cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
					cel_row_t.CellStyle = border_number0;
				}
				else if( e_value[j] == "gianhap") {
                    if (guiNCC == false)
                        cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
                    cel_row_t.CellStyle = border_number2;
                }
				else if( e_value[j] == "v2") {
					cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
					cel_row_t.CellStyle = border_number2;
				}
				else if( e_value[j] == "") {
					cel_row_t.SetCellValue("");
					cel_row_t.CellStyle = border;
				}
				else {
					cel_row_t.SetCellValue(dt.Rows[i][e_value[j]].ToString());
					cel_row_t.CellStyle = border;
				}
			}	
			row++;
			count_row++;
		}
		//vi tri row dau tien
		int m = row - count_row + 2;
		int sub = row + 1;
		//start tong cong 1
        s1.CreateRow(row).CreateCell(1).SetCellValue("Tổng cộng:");
        s1.GetRow(row).CreateCell(7).SetCellFormula(String.Format("SUM(H{0}:H{1})", m, row));
        cellModel.BorderAll = false;
        cellModel.FormatData = "#,##0";
        cellModel.HorizontalAlignment = HorizontalAlignment.Right;
        s1.GetRow(row).GetCell(7).CellStyle = cellModel.CreateCellStyle();

        s1.GetRow(row).CreateCell(6).SetCellFormula(String.Format("SUM(G{0}:G{1})", m, row));
        cellModel.FormatData = "#,##0.000";
        s1.GetRow(row).GetCell(6).CellStyle = cellModel.CreateCellStyle();

        if (guiNCC == true)
            s1.GetRow(row).CreateCell(9).SetCellValue("");
        else
            s1.GetRow(row).CreateCell(9).SetCellFormula(String.Format("SUM(J{0}:J{1})", m, row));
        cellModel.FormatData = "#,##0";
        s1.GetRow(row).GetCell(9).CellStyle = cellModel.CreateCellStyle();
		row++;
		//start +
		int cong = row + 1;
        //s1.CreateRow(row).CreateCell(1).SetCellValue(dt.Rows[0]["diengiaitang"].ToString() + "(+):");
        s1.CreateRow(row).CreateCell(1).SetCellValue("(+):" + dt.Rows[0]["mota_cong"].ToString());
        if (guiNCC == false)
        {
            s1.GetRow(row).CreateCell(9).SetCellValue(double.Parse(phitang == null ? "0" : phitang.Value.ToString()));
            cellModel.BorderAll = false;
            cellModel.FormatData = "#,##0";
            cellModel.HorizontalAlignment = HorizontalAlignment.Right;
            s1.GetRow(row).GetCell(9).CellStyle = cellModel.CreateCellStyle();
        }

        if (phitang == null)
        {
            s1.GetRow(row).HeightInPoints = 0;
        }
		row++;
		//start -
		int tru = row + 1;
        //s1.CreateRow(row).CreateCell(1).SetCellValue(dt.Rows[0]["diengiaigiam"].ToString() + " (-):");
        s1.CreateRow(row).CreateCell(1).SetCellValue("(-):" + dt.Rows[0]["mota_tru"].ToString());
        if (guiNCC == false)
        {
            s1.GetRow(row).CreateCell(9).SetCellValue(double.Parse(phigiam == null ? "0" : phigiam.Value.ToString()));
            cellModel.BorderAll = false;
            cellModel.FormatData = "#,##0";
            cellModel.HorizontalAlignment = HorizontalAlignment.Right;
            s1.GetRow(row).GetCell(9).CellStyle = cellModel.CreateCellStyle();
        }

        if (phigiam == null)
        {
            s1.GetRow(row).HeightInPoints = 0;
        }
		row++;
		// start discount
		int dis = row + 1;
        s1.CreateRow(row).CreateCell(1).SetCellValue(String.Format("Discount ({0}%)", dt.Rows[0]["discountdecimal"].ToString()));
        if (guiNCC == false)
        {
            s1.GetRow(row).CreateCell(9).SetCellValue(double.Parse(dt.Rows[0]["discount"].ToString()));
            cellModel.BorderAll = false;
            cellModel.FormatData = "#,##0";
            cellModel.HorizontalAlignment = HorizontalAlignment.Right;
            s1.GetRow(row).GetCell(9).CellStyle = cellModel.CreateCellStyle();
        }
		row++;
		// start tổng cộng đã trừ
		s1.CreateRow(row).CreateCell(1).SetCellValue("Tổng cộng đã trừ:");
        if (guiNCC == false)
        {
            s1.GetRow(row).CreateCell(9).SetCellFormula(String.Format("J{0} + J{1} - J{2} - J{3}", sub, cong, tru, dis));
            cellModel.FormatData = "#,##0";
            s1.GetRow(row).GetCell(9).CellStyle = cellModel.CreateCellStyle();
        }
		row++;
		// start viet bang chu
        s1.CreateRow(row).CreateCell(1).SetCellValue("Viết bằng chữ:");
        if (guiNCC == false)
        {
            s1.GetRow(row).CreateCell(2).SetCellValue(dt.Rows[0]["money"].ToString());
            s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
        }
		row++;
		// start ghi chu
        s1.CreateRow(row).CreateCell(1).SetCellValue("Ghi chú:");
        s1.GetRow(row).CreateCell(2).SetCellValue(dt.Rows[0]["mota"].ToString());
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
		s1.GetRow(row).HeightInPoints = 45;
		
        cellModel.VerticalAlignment = VerticalAlignment.Top;
		cellModel.HorizontalAlignment = HorizontalAlignment.Left;
		s1.GetRow(row).GetCell(1).CellStyle = cellModel.CreateCellStyle();
        s1.GetRow(row).GetCell(2).CellStyle = cellModel.CreateCellStyle();
		row++;
		// Ngay xong hang
        s1.CreateRow(row).CreateCell(1).SetCellValue("Ngày xong hàng:");
        s1.GetRow(row).CreateCell(2).SetCellValue(DateTime.Parse(dt.Rows[0]["hangiaohang_po"].ToString()).ToString("dd/MM/yyyy"));
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
		row++;
		// Dia diem xuat hang
        s1.CreateRow(row).CreateCell(1).SetCellValue("Địa điểm xuất hàng:");
        s1.GetRow(row).CreateCell(2).SetCellValue(dt.Rows[0]["diachigiaohang"].ToString());
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
		row++;
		//Huong dan lam hang
        s1.CreateRow(row).CreateCell(1).SetCellValue("Hướng dẫn làm hàng:");
		row++;
		// start dac diem hang hoa
		s1.CreateRow(row).CreateCell(1).SetCellValue("1. Đặc điểm hàng hóa:");
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 9));
        HSSFRichTextString rich = new HSSFRichTextString(dt.Rows[0]["huongdanlamhang"].ToString());
        s1.GetRow(row).CreateCell(2).SetCellValue(rich);
        s1.GetRow(row).HeightInPoints = 45;
		
		cellModel.VerticalAlignment = VerticalAlignment.Top;
		cellModel.HorizontalAlignment = HorizontalAlignment.Left;
		s1.GetRow(row).GetCell(1).CellStyle = cellModel.CreateCellStyle();
        s1.GetRow(row).GetCell(2).CellStyle = cellModel.CreateCellStyle();
		row++;
		// start cac huong dan khac
		s1.CreateRow(row).CreateCell(1).SetCellValue("2. Các hướng dẫn khác:");
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 9));
        HSSFRichTextString rich_khac = new HSSFRichTextString(dt.Rows[0]["huongdanlamhangchung"].ToString());
        s1.GetRow(row).CreateCell(2).SetCellValue(rich_khac);
        s1.GetRow(row).HeightInPoints = 45;
		
		cellModel.VerticalAlignment = VerticalAlignment.Top;
		cellModel.HorizontalAlignment = HorizontalAlignment.Left;
        s1.GetRow(row).GetCell(1).CellStyle = cellModel.CreateCellStyle();
        s1.GetRow(row).GetCell(2).CellStyle = cellModel.CreateCellStyle();
		row++;
		//--
        s1.CreateRow(row).CreateCell(1).SetCellValue("* Khi cơ sở nhận được đơn đặt hàng này vui lòng ký xác nhận và gửi lại.");
        s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 9));
		row++;
        ICellStyle cCenter = hssfworkbook.CreateCellStyle();
        cCenter.Alignment = HorizontalAlignment.Center;
        cCenter.VerticalAlignment = VerticalAlignment.Top;
		//--
        s1.CreateRow(row).CreateCell(1).SetCellValue("Người lập phiếu");
        s1.GetRow(row).GetCell(1).CellStyle = cCenter;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 2));
		//
		s1.GetRow(row).CreateCell(8).SetCellValue("Nhà cung ứng");
        s1.GetRow(row).GetCell(8).CellStyle = cCenter;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 8, 9));
		row++;
		//--
        s1.CreateRow(row).CreateCell(1).SetCellValue("Ký và ghi rõ họ tên");
        s1.GetRow(row).GetCell(1).CellStyle = cCenter;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 2));
		//--
		s1.GetRow(row).CreateCell(8).SetCellValue("Ký và ghi rõ họ tên");
        s1.GetRow(row).GetCell(8).CellStyle = cCenter;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 8, 9));
		row = row + 3;
		//
        s1.CreateRow(row).CreateCell(1).SetCellValue(dt.Rows[0]["nguoitao"].ToString());
        s1.GetRow(row).GetCell(1).CellStyle = cCenter;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 1, 2));
		row++;
        //s1.GetRow(row).CreateCell(4).SetCellValue("Trưởng phòng");
        //s1.AddMergedRegion(new CellRangeAddress(row, row, 4, 5));

        //s1.GetRow(row).CreateCell(4).SetCellValue("Ký và ghi rõ họ tên");
        //s1.AddMergedRegion(new CellRangeAddress(row, row, 4, 5));


        //s1.GetRow(row).CreateCell(8).SetCellValue(dt.Rows[0]["nguoitao"].ToString());
        //s1.GetRow(row).GetCell(8).CellStyle = cCenter;
        //s1.AddMergedRegion(new CellRangeAddress(row, row, 8, 9));


        ICellStyle cellUn = hssfworkbook.CreateCellStyle();
        IFont funderline = hssfworkbook.CreateFont();
        funderline.Underline = FontUnderlineType.Single;
        funderline.FontHeightInPoints = 12;
        cellUn.SetFont(funderline);
        cellUn.Alignment = HorizontalAlignment.Center;
        cellUn.VerticalAlignment = VerticalAlignment.Top;
        s1.GetRow(2).GetCell(0).CellStyle = cellUn;
		return hssfworkbook;
    }

    public String C_baogia_id
    {
        get { return c_danhsachdathang_id; }
        set { c_danhsachdathang_id = value; }
    }

    public bool guiNCC { get; set; }

    public DanhSachDatHangReport(String c_danhsachdathang_id, String logoPath, String productImagePath)
    {
        this.c_danhsachdathang_id = c_danhsachdathang_id;
        this.logoPath = logoPath;
        this.productImagePath = productImagePath;
        this.guiNCC = false;
    }

    public IFont CreateFontSize(HSSFWorkbook hsswb, short size)
    {
        IFont font = hsswb.CreateFont();
        font.FontHeightInPoints = size;
        return font;
    }
}
