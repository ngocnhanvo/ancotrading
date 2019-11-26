using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System.Data;
using System.Data.SqlClient;
using System.IO;

public partial class PrintControllers_InThongTinSanPhamMore_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string md_sanpham_id = Request.QueryString["md_sanpham_id"];
        String trangthai = Request.QueryString["trangthai"];
		String typedg = Request.QueryString["typedg"];
        if (trangthai != null & trangthai != "")
        {
            trangthai = " and sp.trangthai = '"+ trangthai +"'";
        }
        else
        {
            trangthai = " and sp.trangthai = 'DHD'";
        }
		
		if(typedg == "true") {
			typedg = "and dgsp.macdinh <> 1";
		}
		else {
			typedg = "and dgsp.macdinh = 1";
		}
		
        String sql = string.Format(@"select
                    sp.ma_sanpham as [ma san pham], sp.mota_tiengviet as [ten tieng viet], sp.mota_tienganh as [ten tieng anh], kd.ten_tv as [ten kieu dang], cn.ten_tv as [ten chuc nang]
                    , kd.ma_kieudang as [ma kieu dang], cn.ma_chucnang as [ma chuc nang] 
                    , (select dvtsp.ten_dvt from md_donvitinhsanpham dvtsp where dvtsp.md_donvitinhsanpham_id = sp.md_donvitinhsanpham_id) as [don vi tinh sp]
                    , l_cm as l, w_cm as w, h_cm as h
                    , sp.trongluong, sp.dientich
                    , (select nhom from md_nhomnangluc nnl where nnl.md_nhomnangluc_id = sp.md_nhomnangluc_id) as [nhom nang luc]    
					, cb.ma_cangbien as [Cang Bien], dtkd.ma_dtkd as [NCC]
					, hscode.ma_hscode as [HS Code]
					, sp.chucnangsp
					, CONVERT(VARCHAR, sp.ngayxacnhan, 103) as ngayxacnhan
					, sp.hinhthucban
					, sp.mota
					, sp.mota as ghichu
                    , isnull((
                        select top 1 gsp.gia 
                        from md_banggia bg, md_phienbangia pbg, md_giasanpham gsp
                        where bg.md_banggia_id = pbg.md_banggia_id
                        AND pbg.md_phienbangia_id = gsp.md_phienbangia_id
                        AND sp.md_sanpham_id = gsp.md_sanpham_id
                        AND bg.banggiaban = 1
						AND substring(bg.ten_banggia,0,5) = 'FOB-'
                        AND pbg.md_trangthai_id = 'HIEULUC'
                        order by pbg.ngay_hieuluc desc
                    ), 0) as [gia ban]
                    , isnull((
                        select top 1 gsp.gia 
                        from md_banggia bg, md_phienbangia pbg, md_giasanpham gsp
                        where bg.md_banggia_id = pbg.md_banggia_id
                        AND pbg.md_phienbangia_id = gsp.md_phienbangia_id
                        AND sp.md_sanpham_id = gsp.md_sanpham_id
                        AND bg.banggiaban = 0
                        AND pbg.md_trangthai_id = 'HIEULUC'
                        order by pbg.ngay_hieuluc desc
                    ), 0) as [gia mua]
                    , isnull(dg.sl_inner,0) as [SL Inner], isnull((select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_inner),0) as [DVT Inner]
                    , isnull(dg.l1,0) as l1, isnull(dg.w1,0) as w1, isnull(dg.h1,0) as h1
                    , isnull(dg.sl_outer,0) as [SL Outer], isnull((select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_outer),0) as [DVT Outer]
                    , isnull(dg.l2_mix,0) as l2, isnull(dg.w2_mix,0) as w2, isnull(dg.h2_mix,0) as h2
                    , isnull(dg.soluonggoi_ctn_20,0) as [SL Cont 20], isnull(dg.soluonggoi_ctn,0) as [SL Cont 40]
					, isnull(dg.soluonggoi_ctn_40hc,0) as [SL Cont 40 hc]
					, isnull(dg.vd,0) as vd
					, isnull(dg.vn,0) as vn
					, isnull(dg.vl,0) as vl
					, dg.ghichu_vachngan
                    , CONVERT(VARCHAR, dg.ngayxacnhan, 103) as ngayxacnhan_donggoi
					, sp.trangthai
					, dg.mota as [ghi chu dong goi]
                from 
                    md_sanpham sp
					left join md_doitackinhdoanh dtkd on sp.nhacungung = dtkd.md_doitackinhdoanh_id
                    left join md_donggoisanpham dgsp on dgsp.md_sanpham_id = sp.md_sanpham_id
					left join md_donggoi dg on dg.md_donggoi_id = dgsp.md_donggoi_id
					left join md_cangbien cb on sp.md_cangbien_id = cb.md_cangbien_id
                    left join md_kieudang kd on sp.md_kieudang_id = kd.md_kieudang_id
					left join md_chucnang cn on sp.md_chucnang_id = cn.md_chucnang_id
					left join md_hscode hscode on sp.md_hscode_id = hscode.md_hscode_id
                where sp.ma_sanpham like '{0}' {1} {2}
                order by ma_sanpham asc", md_sanpham_id, trangthai, typedg);

        DataTable dt = mdbc.GetData(sql);

        if (dt.Rows.Count > 0)
        {
            HSSFWorkbook hssfworkbook = new HSSFWorkbook();
            ISheet s1 = hssfworkbook.CreateSheet("Sheet1");
			
			Excel_Format ex_fm = new Excel_Format(hssfworkbook); 
			ICellStyle cellBold = ex_fm.cell_decimal_1(10, false, true, "", "R", "T");
			ICellStyle cellBold2 = ex_fm.cell_decimal_2(10, false, true, "", "R", "T");
			ICellStyle cellBold3 = ex_fm.cell_decimal_3(10, false, true, "", "R", "T");
			//-- 
			
            s1.CreateRow(0).CreateCell(0).SetCellValue("THÔNG TIN SẢN PHẨM");

            IRow rowHeader = s1.CreateRow(1);
            int i = 0;
            foreach (DataColumn col in dt.Columns)
            {
                rowHeader.CreateCell(i).SetCellValue(col.ColumnName);
                i++;
            }

            int iRow = 2;
            foreach (DataRow row in dt.Rows)
            {
                
                IRow rowDetails = s1.CreateRow(iRow);
                
                rowDetails.CreateCell(0).SetCellValue(row["ma san pham"].ToString());
                rowDetails.CreateCell(1).SetCellValue(row["ten tieng viet"].ToString());
                rowDetails.CreateCell(2).SetCellValue(row["ten tieng anh"].ToString());
				rowDetails.CreateCell(3).SetCellValue(row["ten kieu dang"].ToString());
                rowDetails.CreateCell(4).SetCellValue(row["ten chuc nang"].ToString());
                rowDetails.CreateCell(5).SetCellValue(row["ma kieu dang"].ToString());
                rowDetails.CreateCell(6).SetCellValue(row["ma chuc nang"].ToString());
                rowDetails.CreateCell(7).SetCellValue(row["don vi tinh sp"].ToString());
                rowDetails.CreateCell(8).SetCellValue(double.Parse(row["l"].ToString()));
				rowDetails.GetCell(8).CellStyle = cellBold;
                rowDetails.CreateCell(9).SetCellValue(double.Parse(row["w"].ToString()));
				rowDetails.GetCell(9).CellStyle = cellBold;
                rowDetails.CreateCell(10).SetCellValue(double.Parse(row["h"].ToString()));
				rowDetails.GetCell(10).CellStyle = cellBold;
                rowDetails.CreateCell(11).SetCellValue(double.Parse(row["trongluong"].ToString()));
				rowDetails.GetCell(11).CellStyle = cellBold2;
                rowDetails.CreateCell(12).SetCellValue(double.Parse(row["dientich"].ToString()));
				rowDetails.GetCell(12).CellStyle = cellBold3;
                rowDetails.CreateCell(13).SetCellValue(row["nhom nang luc"].ToString());
				rowDetails.CreateCell(14).SetCellValue(row["Cang Bien"].ToString());
				rowDetails.CreateCell(15).SetCellValue(row["NCC"].ToString());
                rowDetails.CreateCell(16).SetCellValue(row["HS Code"].ToString());
				rowDetails.CreateCell(17).SetCellValue(row["chucnangsp"].ToString());
				rowDetails.CreateCell(18).SetCellValue(row["ngayxacnhan"].ToString());
				rowDetails.CreateCell(19).SetCellValue(row["hinhthucban"].ToString());
                rowDetails.CreateCell(20).SetCellValue(row["mota"].ToString());
				rowDetails.CreateCell(21).SetCellValue(row["ghichu"].ToString());
                rowDetails.CreateCell(22).SetCellValue(double.Parse(row["gia ban"].ToString()));
				rowDetails.GetCell(22).CellStyle = cellBold2;
                rowDetails.CreateCell(23).SetCellValue(double.Parse(row["gia mua"].ToString()));
				rowDetails.GetCell(23).CellStyle = cellBold2;
                rowDetails.CreateCell(24).SetCellValue(double.Parse(row["SL Inner"].ToString()));
                rowDetails.CreateCell(25).SetCellValue(row["DVT Inner"].ToString());
                rowDetails.CreateCell(26).SetCellValue(double.Parse(row["l1"].ToString()));
				rowDetails.GetCell(26).CellStyle = cellBold;
                rowDetails.CreateCell(27).SetCellValue(double.Parse(row["w1"].ToString()));
				rowDetails.GetCell(27).CellStyle = cellBold;
                rowDetails.CreateCell(28).SetCellValue(double.Parse(row["h1"].ToString()));
				rowDetails.GetCell(28).CellStyle = cellBold;
                rowDetails.CreateCell(29).SetCellValue(double.Parse(row["SL Outer"].ToString()));
                rowDetails.CreateCell(30).SetCellValue(row["DVT Outer"].ToString());
                rowDetails.CreateCell(31).SetCellValue(double.Parse(row["l2"].ToString()));
				rowDetails.GetCell(31).CellStyle = cellBold;
                rowDetails.CreateCell(32).SetCellValue(double.Parse(row["w2"].ToString()));
				rowDetails.GetCell(32).CellStyle = cellBold;
                rowDetails.CreateCell(33).SetCellValue(double.Parse(row["h2"].ToString()));
				rowDetails.GetCell(33).CellStyle = cellBold;
                rowDetails.CreateCell(34).SetCellValue(double.Parse(row["SL Cont 20"].ToString()));
                rowDetails.CreateCell(35).SetCellValue(double.Parse(row["SL Cont 40"].ToString()));
                rowDetails.CreateCell(36).SetCellValue(double.Parse(row["SL Cont 40 hc"].ToString()));
                rowDetails.CreateCell(37).SetCellValue(double.Parse(row["vd"].ToString()));
				s1.SetColumnWidth(37, 0);
                rowDetails.CreateCell(38).SetCellValue(double.Parse(row["vn"].ToString()));
				s1.SetColumnWidth(38, 0);
                rowDetails.CreateCell(39).SetCellValue(double.Parse(row["vl"].ToString()));
				s1.SetColumnWidth(39, 0);
				rowDetails.CreateCell(40).SetCellValue(row["ghichu_vachngan"].ToString());
				s1.SetColumnWidth(40, 0);
				rowDetails.CreateCell(41).SetCellValue(row["ngayxacnhan_donggoi"].ToString());
                rowDetails.CreateCell(42).SetCellValue(row["trangthai"].ToString());
                rowDetails.CreateCell(43).SetCellValue(row["ghi chu dong goi"].ToString());        
                iRow++;
            }
            String saveAsFileName = "ThongTinSanPham.xls";
            this.SaveFile(hssfworkbook, saveAsFileName);
        }
        else
        {
            Response.Write("Không có dữ liệu" + md_sanpham_id);
        }
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