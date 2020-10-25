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
    private String c_danhsachdathang_id, logoPath, productImagePath, type;

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

    public String TypePrint
    {
        get { return type; }
        set { type = value; }
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
	                        , sp.ma_sanpham as maSo
							, (case when  SUBSTRING(sp.ma_sanpham,10,1) != 'F' then SUBSTRING(sp.ma_sanpham,0,9) else SUBSTRING(sp.ma_sanpham,0,12) end) as pic
							, ddsdh.ma_sanpham_khach as maKhachHang
                            , ddsdh.mota_tiengviet as moTa
                            , dvt.ma_edi as dvt
                            , ddsdh.sl_dathang as soLuong
							, ddsdh.gianhap as tongDonGiaMua
                            , isnull(ddsdh.giachuan, ddsdh.gianhap) as giaMua
                            , (ddsdh.gianhap - isnull(ddsdh.giachuan, ddsdh.gianhap)) as phi
							, dsdh.huongdanlamhang
							, dsdh.huongdanlamhangchung
							, ddsdh.huongdan_dathang
	                        , gh.ma_dtkd as diachigiaohang
							, dh.sl_cont
							, dh.loai_cont
							, dsdh.discount as discountdecimal
							, ddsdh.v2 as cbm
                            , (case ddsdh.sl_inner when 0 then ' ' else (cast(ddsdh.sl_inner as nvarchar) + ' ' + (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_inner)) end) as dginner
                            , (cast(ddsdh.sl_outer as nvarchar) + ' ' + (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_outer)) as dgouter
                            , ddsdh.sl_dathang / ddsdh.sl_inner as soKienInner
                            , ddsdh.sl_dathang / ddsdh.sl_outer as soKienOuter
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

			var phitang = (from t in db.c_phidathangs where t.isphicong.Equals(true) && t.c_danhsachdathang_id.Equals(c_danhsachdathang_id) select t.sotien).Sum();
			tbl.Rows[0]["giatritang"] = tbl.Rows[lastRow]["giatritang"] = phitang.GetValueOrDefault(0);
			
			var phigiam = (from t in db.c_phidathangs where t.isphicong.Equals(false) && t.c_danhsachdathang_id.Equals(c_danhsachdathang_id) select t.sotien).Sum();
			tbl.Rows[0]["giatrigiam"] = tbl.Rows[lastRow]["giatrigiam"] = phigiam.GetValueOrDefault(0);
            
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
        ICellStyle celltext10 = ex_fm.getcell(10, false, true, "", "L", "T");
        //--
        ICellStyle rightBold = ex_fm.getcell(12, true, false, "", "R", "T");
		//--
		ICellStyle right = ex_fm.getcell(12, false, false, "", "R", "T");
		//--
		ICellStyle leftBold = ex_fm.getcell(12, true, false, "", "L", "T");
		//--
		ICellStyle left = ex_fm.getcell(12, false, false, "", "L", "T");
        //--
        ICellStyle border_number = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.0####");
        ICellStyle border_number_ = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.####");
        ICellStyle border_number0 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0");
		ICellStyle border_number1 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.0");
		ICellStyle border_number2 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.00");
		ICellStyle border_number3 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.000");
		ICellStyle border_number4 = ex_fm.getcell2(12, false, true, "LRBT", "R", "T", "#,##0.0000");

        var number = ex_fm.getcell2(12, false, true, "", "R", "T", "#,##0.0####");
        var number0 = ex_fm.getcell2(12, false, true, "", "R", "T", "#,##0");
        var number1 = ex_fm.getcell2(12, false, true, "", "R", "T", "#,##0.0");
        var number2 = ex_fm.getcell2(12, false, true, "", "R", "T", "#,##0.00");
        var number3 = ex_fm.getcell2(12, false, true, "", "R", "T", "#,##0.000");

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
		for(int i = 0; i < a.Length; i++)
		{		
			s1.CreateRow(row).CreateCell(0).SetCellValue(a[i]);
			s1.AddMergedRegion(new CellRangeAddress(row, row, 0, 16));
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
        s1.GetRow(4).GetCell(1).CellStyle = celltext10;
        s1.GetRow(4).HeightInPoints = 20;
        s1.GetRow(4).CreateCell(2).SetCellValue(dt.Rows[0]["sochungtu"].ToString());
        s1.GetRow(4).GetCell(2).CellStyle = celltext10;

        s1.GetRow(4).CreateCell(4).SetCellValue("Theo P/O số:");
        s1.GetRow(4).GetCell(4).CellStyle = celltext10;
        s1.GetRow(4).CreateCell(5).SetCellValue(dt.Rows[0]["so_po"].ToString());
        s1.GetRow(4).GetCell(5).CellStyle = celltext10;
        s1.AddMergedRegion(new CellRangeAddress(4, 4, 5, 7));

        s1.CreateRow(5).CreateCell(1).SetCellValue("Ngày lập:");
        s1.GetRow(5).GetCell(1).CellStyle = celltext10;
        s1.GetRow(5).HeightInPoints = 20;
        s1.GetRow(5).CreateCell(2).SetCellValue(DateTime.Parse(dt.Rows[0]["ngaylap"].ToString()).ToString("dd/MM/yyyy"));
        s1.GetRow(5).GetCell(2).CellStyle = celltext10;

        s1.GetRow(5).CreateCell(4).SetCellValue("Customer Order No:");
        s1.GetRow(5).GetCell(4).CellStyle = celltext10;
        s1.GetRow(5).CreateCell(5).SetCellValue(dt.Rows[0]["customer_order_no"].ToString());
        s1.GetRow(5).GetCell(5).CellStyle = celltext10;

        s1.CreateRow(6).CreateCell(1).SetCellValue("Công ty AnCơ kính đề nghị Quý Công ty/Đơn vị: " + dt.Rows[0]["ten_dtkd"].ToString());
        s1.GetRow(6).GetCell(1).CellStyle = celltext10;
        s1.GetRow(6).HeightInPoints = 20;

        s1.CreateRow(7).CreateCell(1).SetCellValue("Điện thoại");
        s1.GetRow(7).GetCell(1).CellStyle = celltext10;
        s1.GetRow(7).HeightInPoints = 20;
        s1.GetRow(7).CreateCell(2).SetCellValue(dt.Rows[0]["tel"].ToString());
        s1.GetRow(7).GetCell(2).CellStyle = celltext10;

        s1.GetRow(7).CreateCell(4).SetCellValue("Fax");
        s1.GetRow(7).GetCell(4).CellStyle = celltext10;
        s1.GetRow(7).CreateCell(5).SetCellValue(dt.Rows[0]["fax"].ToString());
        s1.GetRow(7).GetCell(5).CellStyle = celltext10;
        s1.AddMergedRegion(new CellRangeAddress(7, 7, 5, 7));

        s1.CreateRow(10).CreateCell(1).SetCellValue("Cung cấp cho công ty chúng tôi các mặt hàng với chi tiết:");
        s1.GetRow(10).GetCell(1).CellStyle = celltext10;
        s1.GetRow(10).HeightInPoints = 20;

        row = 11;
		// set A13 - All
		// -- Header
		int cell = 0;
		string[] d = {
            "STT",
            "Mã số",
            "Hình ảnh",
            "Mã khách hàng",
            "Mô tả",
            "SL",
            "ĐVT",
            "Giá mua",
            "Phí",
            "Tổng đơn giá mua",
            "Thành tiền",
            "Hướng dẫn làm hàng",
            "Đóng gói Inner",
            "Đóng gói Outer",
            "Số kiện Inner",
            "Số kiện Outer",
            "Cbm",
            "Trọng lượng",
            "Xác nhận kích thước",
            "Giá gốc",
            "Phí"
        };

		IRow rowColumnHeader = s1.CreateRow(row);
		rowColumnHeader.HeightInPoints = 47;
		for(int i = 0; i < d.Length; i++)
		{		
			int with = 5000;
			rowColumnHeader.CreateCell(cell).SetCellValue(d[i]);
			rowColumnHeader.GetCell(i).CellStyle = borderWrap;

            if (i == 0)
            {
                with = 1500;
            }
            else if (i == 1)
            {
                with = 5500;
            }
            else if ( i == 4) {
				with = 7000;
			}
            else if (i == 5)
            {
                with = 3000;
            }
            else if (i == 6)
            {
                with = 2000;
            }
            else if (i == 16)
            {
                with = 3000;
            }
            else if(new int[] { 14, 15}.Contains(i)) {
				with = 4000;
			}
			else if( i >= 17) {
				with = 0;
			}

            if ((new int[] { 7, 8, 9 }.Contains(i)))
            {
                if (guiNCC)
                    with = 0;
                else
                    with = 4000;
            }

            s1.SetColumnWidth(cell,with);
			cell++;
		}
		row ++;
		//thu tu tong cong // dem so dong hang cua tung sochungtu
		int count_row = 1;
        double sumThanhTien = 0;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
			string[] e_value = {
                "stt",
                "maSo",
                "",
                "maKhachHang",
                "moTa",
                "soLuong",
                "dvt",
                "giaMua",
                "phi",
                "tongDonGiaMua",
                "thanhTien",
                "huongdan_dathang",
                "dginner",
                "dgouter",
                "soKienInner",
                "soKienOuter",
                "cbm",
                "trongluong",
                "ghichu",
                "giaMua",
                "phi"
            };
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

            var soLuong = double.Parse(dt.Rows[i]["soluong"].ToString());
            var tongDonGiaMua = double.Parse(dt.Rows[i]["tongDonGiaMua"].ToString());
            var thanhtien = soLuong * tongDonGiaMua;
            sumThanhTien += thanhtien;

            for (int j = 0; j < e_value.Length; j++)
			{
				var cel_row_t = row_t.CreateCell(j);
				if(e_value[j] == "stt")
                {
					cel_row_t.SetCellValue(count_row);
					cel_row_t.CellStyle = border_center; 
				}
                else if (new string[] { "dvt", "maSo" }.Contains(e_value[j]))
                {
                    cel_row_t.SetCellValue(dt.Rows[i][e_value[j]].ToString());
                    cel_row_t.CellStyle = border_center;
                }
                else if(e_value[j] == "thanhTien")
                {
                    if (guiNCC == false)
                        cel_row_t.CellFormula = String.Format("J{0}*F{0}",row + 1);
                    if (thanhtien.ToString().LastIndexOf(".") <= -1)
                        cel_row_t.CellStyle = type == "pdf" ? border_number0 : border_number;
                    else
                        cel_row_t.CellStyle = border_number;
                }
				else if(e_value[j] == "trongluong")
                {
					cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
					cel_row_t.CellStyle = border_number1;
				}
				else if(e_value[j] == "soLuong")
                {
					cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
					cel_row_t.CellStyle = border_number0;
				}
				else if (new string[] { "giaMua", "tongDonGiaMua", "phi" }.Contains(e_value[j]))
                {
                    var val = double.Parse(dt.Rows[i][e_value[j]].ToString());
                    if (guiNCC == false)
                        cel_row_t.SetCellValue(val);

                    if(val.ToString().LastIndexOf(".") <= -1)
                        cel_row_t.CellStyle = type == "pdf" ? border_number0 : border_number;
                    else
                        cel_row_t.CellStyle = border_number;
                }
				else if( new string[] { "cbm", "soKienInner", "soKienOuter" }.Contains(e_value[j]))
                {
					cel_row_t.SetCellValue(double.Parse(dt.Rows[i][e_value[j]].ToString()));
					cel_row_t.CellStyle = border_number2;
				}
				else if( e_value[j] == "")
                {
					cel_row_t.SetCellValue("");
					cel_row_t.CellStyle = border;
				}
				else
                {
					cel_row_t.SetCellValue(dt.Rows[i][e_value[j]].ToString());
					cel_row_t.CellStyle = border;
				}
			}	
			row++;
			count_row++;
		}
        var discountP = double.Parse(dt.Rows[0]["discountdecimal"].ToString());
        var discount = sumThanhTien * discountP / 100;

        //vi tri row dau tien
        int m = row - count_row + 2;
		int sub = row + 1;
		//start tong cong 1
        s1.CreateRow(row).CreateCell(1).SetCellValue("Tổng cộng:");
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
        s1.GetRow(row).CreateCell(5).SetCellFormula(String.Format("SUM(F{0}:F{1})", m, row));
        s1.GetRow(row).GetCell(5).CellStyle = number0;

        if (guiNCC == true)
            s1.GetRow(row).CreateCell(10).SetCellValue("");
        else
            s1.GetRow(row).CreateCell(10).SetCellFormula(String.Format("SUM(K{0}:K{1})", m, row));

        if (sumThanhTien.ToString().LastIndexOf(".") <= -1)
            s1.GetRow(row).GetCell(10).CellStyle = type == "pdf" ? number0 : number;
        else
            s1.GetRow(row).GetCell(10).CellStyle = number;

        s1.GetRow(row).GetCell(10).CellStyle = number;

        s1.GetRow(row).CreateCell(16).SetCellFormula(String.Format("SUM(Q{0}:Q{1})", m, row));
        s1.GetRow(row).GetCell(16).CellStyle = number2;

		row++;
		//start +
		int cong = row + 1;
        //s1.CreateRow(row).CreateCell(1).SetCellValue(dt.Rows[0]["diengiaitang"].ToString() + "(+):");
        var cellR01 = s1.CreateRow(row).CreateCell(1);
        cellR01.SetCellValue("(+):" + dt.Rows[0]["mota_cong"].ToString());
        cellR01.CellStyle = celltext10;

        var cellR10 = s1.GetRow(row).CreateCell(10);
        var phiTangVal = double.Parse(phitang == null ? "0" : phitang.Value.ToString());
        if (guiNCC == false)
        {
            cellR10.SetCellValue(phiTangVal);

            if (phiTangVal.ToString().LastIndexOf(".") <= -1)
                cellR10.CellStyle = type == "pdf" ? number0 : number;
            else
                cellR10.CellStyle = number;
        }

        if (phitang == null)
        {
            s1.GetRow(row).ZeroHeight = true;

            if (type == "pdf")
            {
                s1.GetRow(row).RemoveCell(cellR01);
                s1.GetRow(row).RemoveCell(cellR10);
            }
        }
        else
            s1.GetRow(row).HeightInPoints = 30;

        row++;
		//start -
		int tru = row + 1;
        //s1.CreateRow(row).CreateCell(1).SetCellValue(dt.Rows[0]["diengiaigiam"].ToString() + " (-):");
        cellR01 = s1.CreateRow(row).CreateCell(1);
        cellR01.SetCellValue("(-):" + dt.Rows[0]["mota_tru"].ToString());
        cellR01.CellStyle = celltext10;

        cellR10 = s1.GetRow(row).CreateCell(10);
        var phiGiamVal = double.Parse(phigiam == null ? "0" : phigiam.Value.ToString());
        if (guiNCC == false)
        {
            cellR10.SetCellValue(phiGiamVal);

            if (phiGiamVal.ToString().LastIndexOf(".") <= -1)
                cellR10.CellStyle = type == "pdf" ? number0 : number;
            else
                cellR10.CellStyle = number;
        }

        if (phigiam == null)
        {
            //s1.GetRow(row).HeightInPoints = 0;
            s1.GetRow(row).ZeroHeight = true;
            if (type == "pdf")
            {
                s1.GetRow(row).RemoveCell(cellR01);
                s1.GetRow(row).RemoveCell(cellR10);
            }
        }
        else
            s1.GetRow(row).HeightInPoints = 30;

        row++;
		// start discount
		int dis = row + 1;
        var ds2so = discountP.ToString("#,#0.##");
        s1.CreateRow(row).CreateCell(1).SetCellValue(String.Format("Discount ({0}%)", ds2so));
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
        cellR10 = s1.GetRow(row).CreateCell(10);
        if (guiNCC == false)
        {
            cellR10.SetCellValue(discount);
            if (discount.ToString().LastIndexOf(".") <= -1)
                cellR10.CellStyle = type == "pdf" ? number0 : number;
            else
                cellR10.CellStyle = number;
        }
		row++;
		// start tổng cộng đã trừ
		s1.CreateRow(row).CreateCell(1).SetCellValue("Tổng cộng đã trừ:");
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
        cellR10 = s1.GetRow(row).CreateCell(10);
        var tongCongDaTru = sumThanhTien + phiTangVal - phiGiamVal - discount;
        if (guiNCC == false)
        {
            cellR10.SetCellFormula(String.Format("K{0} + K{1} - K{2} - K{3}", sub, cong, tru, dis));
            if(tongCongDaTru.ToString().LastIndexOf(".") <= -1)
                cellR10.CellStyle = type == "pdf" ? number0 : number;
            else
                cellR10.CellStyle = number;
        }
		row++;
		// start viet bang chu
        s1.CreateRow(row).CreateCell(1).SetCellValue("Viết bằng chữ:");
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
        s1.GetRow(row).HeightInPoints = 30;
        if (guiNCC == false)
        {
            s1.GetRow(row).CreateCell(2).SetCellValue(MoneyToWord.ConvertMoneyToTextVND((decimal)tongCongDaTru, dt.Rows[0]["ma_dtkd"].ToString()));
            s1.GetRow(row).GetCell(2).CellStyle = celltext10;
            s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
        }
		row++;
		// start ghi chu
        s1.CreateRow(row).CreateCell(1).SetCellValue("Ghi chú:");
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).CreateCell(2).SetCellValue(dt.Rows[0]["mota"].ToString());
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
		s1.GetRow(row).HeightInPoints = 45;
        cellModel.BorderAll = false;
        cellModel.VerticalAlignment = VerticalAlignment.Top;
		cellModel.HorizontalAlignment = HorizontalAlignment.Left;
		s1.GetRow(row).GetCell(1).CellStyle = cellModel.CreateCellStyle();
        s1.GetRow(row).GetCell(2).CellStyle = cellModel.CreateCellStyle();
		row++;
		// Ngay xong hang
        s1.CreateRow(row).CreateCell(1).SetCellValue("Ngày xong hàng:");
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
        s1.GetRow(row).CreateCell(2).SetCellValue(DateTime.Parse(dt.Rows[0]["hangiaohang_po"].ToString()).ToString("dd/MM/yyyy"));
        s1.GetRow(row).GetCell(2).CellStyle = celltext10;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
		row++;
		// Dia diem xuat hang
        s1.CreateRow(row).CreateCell(1).SetCellValue("Địa điểm xuất hàng:");
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
        s1.GetRow(row).CreateCell(2).SetCellValue(dt.Rows[0]["diachigiaohang"].ToString());
        s1.GetRow(row).GetCell(2).CellStyle = celltext10;
        s1.AddMergedRegion(new CellRangeAddress(row, row, 2, 5));
		row++;
		//Huong dan lam hang
        s1.CreateRow(row).CreateCell(1).SetCellValue("Hướng dẫn làm hàng:");
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
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
        s1.GetRow(row).HeightInPoints = 30;
        s1.GetRow(row).GetCell(1).CellStyle = celltext10;
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

        var config = new ExportExcel(hssfworkbook, 0, 16);
        s1 = config.PrintExcel((HSSFSheet)s1, row);
        s1.PrintSetup.Landscape = true;

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
