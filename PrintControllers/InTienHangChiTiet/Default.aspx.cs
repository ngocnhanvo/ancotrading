using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraReports.UI;
using System.Data.SqlClient;
using System.Data;

public partial class PrintControllers_InTienHangChiTiet_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LinqDBDataContext db = new LinqDBDataContext();
        DateTime dateFrom = DateTime.ParseExact(Request.QueryString["startdate"], "dd/MM/yyyy", null);
        DateTime dateTo = DateTime.ParseExact(Request.QueryString["enddate"], "dd/MM/yyyy", null);
        DateTime datenow = DateTime.Now;
        String md_doitackinhdoanh_id = Request.QueryString["doitackinhdoanh_id"];

        rpt_tienhangdanhapchitiet report = new rpt_tienhangdanhapchitiet();
        String sql = this.CreateSql(dateFrom, dateTo, datenow, md_doitackinhdoanh_id);
        this.viewReport(report, sql);
    }

     public void viewReport(XtraReport report, String SqlQuery)
    {
        SqlDataAdapter da = new SqlDataAdapter(SqlQuery, mdbc.GetConnection);
        DataSet ds = new DataSet();
        da.Fill(ds);
        report.DataSource = ds;
        report.DataAdapter = da;
        ReportViewer1.Report = report;
    }

    public String CreateSql(DateTime dateFrom, DateTime dateTo, DateTime datenow, string dtkd)
    {
        string wheresql = "";
        //if (dtkd.Length > 0)
        //{
        //    wheresql = " and nhan.md_doitackinhdoanh_id = '" + dtkd + "'";
        //}
        String str="";
        if (dtkd == null | dtkd == "")
        {
            str = String.Format(@"
            DECLARE @startdate datetime = convert(datetime, '{0}', 103) 
            DECLARE @enddate datetime = convert(datetime, '{1}', 103) 
            DECLARE @table TABLE ( 
	            c_dongnhapxuat_id nvarchar(32),
	            so_inv nvarchar(50)
            )

            INSERT INTO @table
            SELECT dnx.dongnhapxuat_ref, A.so_inv
            FROM c_dongnhapxuat dnx (nolock)
            inner join (
	            SELECT cdiv5.c_dongnhapxuat_id,
		               civ5.so_inv
	            FROM c_dongpklinv cdiv5 (nolock),
		             c_packinginvoice civ5 (nolock)
	            WHERE civ5.c_packinginvoice_id = cdiv5.c_packinginvoice_id
	              AND civ5.md_trangthai_id = 'HIEULUC'
	              AND civ5.ngay_motokhai >= @startdate
	              AND civ5.ngay_motokhai <= @enddate
            ) A on dnx.c_dongnhapxuat_id = A.c_dongnhapxuat_id

              SELECT nhan.*,
                (SELECT convert(decimal,sum((cdnx5.slthuc_nhapxuat * cdnx5.dongia) - (cdnx5.slthuc_nhapxuat * cdnx5.dongia)*cnx5.discount/100))
                 FROM c_dongnhapxuat cdnx5,
                      c_nhapxuat cnx5,
                      c_dongdonhang cdgh5,
                      c_donhang dh5,
                      md_sanpham sp5
                 WHERE cnx5.c_nhapxuat_id = cdnx5.c_nhapxuat_id
                   AND cdnx5.md_sanpham_id = sp5.md_sanpham_id
                   AND cdgh5.c_dongdonhang_id = cdnx5.c_dongdonhang_id
                   AND cdgh5.c_donhang_id = dh5.c_donhang_id
                   AND cnx5.md_loaichungtu_id = 'NK'
                   AND cdnx5.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
	            ) AS tongtiencc ,

                (SELECT sum(cdnx5.dongia)
                 FROM c_dongnhapxuat cdnx5,
                      c_nhapxuat cnx5,
                      c_dongdonhang cdgh5,
                      c_donhang dh5,
                      md_sanpham sp5
                 WHERE cnx5.c_nhapxuat_id = cdnx5.c_nhapxuat_id
                   AND cdnx5.md_sanpham_id = sp5.md_sanpham_id
                   AND cdgh5.c_dongdonhang_id = cdnx5.c_dongdonhang_id
                   AND cdgh5.c_donhang_id = dh5.c_donhang_id
                   AND cnx5.md_loaichungtu_id = 'NK'
                   AND cdnx5.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
	            ) AS tongdongiacc,

                (SELECT sum(cdnx5.slthuc_nhapxuat)
                 FROM c_dongnhapxuat cdnx5,
                      c_nhapxuat cnx5,
                      c_dongdonhang cdgh5,
                      c_donhang dh5,
                      md_sanpham sp5
                 WHERE cnx5.c_nhapxuat_id = cdnx5.c_nhapxuat_id
                   AND cdnx5.md_sanpham_id = sp5.md_sanpham_id
                   AND cdgh5.c_dongdonhang_id = cdnx5.c_dongdonhang_id
                   AND cdgh5.c_donhang_id = dh5.c_donhang_id
                   AND cnx5.md_loaichungtu_id = 'NK'
                   AND cdnx5.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
	            ) AS tongsoluongcc
  
              FROM
                (
		            SELECT cnx.sophieu,
                        cnx.ngay_giaonhan,
                        sp.ma_sanpham,
                        cdnx.mota_tiengviet,
                        cdnx.slthuc_nhapxuat,
                        cdnx.dongia,
                        convert(decimal,(cdnx.slthuc_nhapxuat * cdnx.dongia) - (cdnx.slthuc_nhapxuat * cdnx.dongia)*cnx.discount/100) AS thanhtien,
				   
                        dtkd.ma_dtkd,
                        dh.sochungtu AS sopo,
                        cnx.phicong AS phicongPO,
                        cnx.phitru AS phitruPO,
                        @startdate AS tungay,
                        @enddate AS denngay,
                        GETDATE() AS today,
                        cnx.discount ,

                   (SELECT convert(decimal,sum((cdnx2.slthuc_nhapxuat * cdnx2.dongia) - (cdnx2.slthuc_nhapxuat * cdnx2.dongia)*cnx2.discount/100))
                    FROM c_dongnhapxuat cdnx2,
                         c_nhapxuat cnx2,
                         c_dongdonhang cdgh2,
                         c_donhang dh2,
                         md_sanpham sp2
                    WHERE cnx2.c_nhapxuat_id = cdnx2.c_nhapxuat_id
                      AND cdnx2.md_sanpham_id = sp2.md_sanpham_id
                      AND cdgh2.c_dongdonhang_id = cdnx2.c_dongdonhang_id
                      AND cdgh2.c_donhang_id = dh2.c_donhang_id
                      AND cnx2.md_loaichungtu_id = 'NK'
                      AND cnx2.md_doitackinhdoanh_id = cnx.md_doitackinhdoanh_id
                      AND cdnx2.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
		            ) AS tongtien ,

                   (SELECT sum(cdnx3.dongia)
                    FROM c_dongnhapxuat cdnx3,
                         c_nhapxuat cnx3,
                         c_dongdonhang cdgh3,
                         c_donhang dh3,
                         md_sanpham sp3
                    WHERE cnx3.c_nhapxuat_id = cdnx3.c_nhapxuat_id
                      AND cdnx3.md_sanpham_id = sp3.md_sanpham_id
                      AND cdgh3.c_dongdonhang_id = cdnx3.c_dongdonhang_id
                      AND cdgh3.c_donhang_id = dh3.c_donhang_id
                      AND cnx3.md_loaichungtu_id = 'NK'
                      AND cnx3.md_doitackinhdoanh_id = cnx.md_doitackinhdoanh_id
                      AND cdnx3.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)) AS tongdongia ,

		  
									
													
																
										   
														
														
	   
					 
	  
                   (SELECT sum(cdnx4.slthuc_nhapxuat)
                    FROM c_dongnhapxuat cdnx4,
                         c_nhapxuat cnx4,
                         c_dongdonhang cdgh4,
                         c_donhang dh4,
                         md_sanpham sp4
                    WHERE cnx4.c_nhapxuat_id = cdnx4.c_nhapxuat_id
                      AND cdnx4.md_sanpham_id = sp4.md_sanpham_id
                      AND cdgh4.c_dongdonhang_id = cdnx4.c_dongdonhang_id
                      AND cdgh4.c_donhang_id = dh4.c_donhang_id
                      AND cnx4.md_loaichungtu_id = 'NK'
                      AND cnx4.md_doitackinhdoanh_id = cnx.md_doitackinhdoanh_id
                      AND cdnx4.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)) AS tongsoluong,
		              tb.so_inv

									
													
																
										   
														
														
	   
					  
                 FROM c_dongnhapxuat cdnx,
                      c_nhapxuat cnx,
                      c_dongdonhang cdgh,
                      c_donhang dh,
                      md_sanpham sp,
                      md_doitackinhdoanh dtkd,
		              @table tb
                 WHERE cnx.c_nhapxuat_id = cdnx.c_nhapxuat_id
                   AND cdnx.md_sanpham_id = sp.md_sanpham_id
                   AND cdgh.c_dongdonhang_id = cdnx.c_dongdonhang_id
                   AND cdgh.c_donhang_id = dh.c_donhang_id
                   AND cnx.md_loaichungtu_id = 'NK'
                   AND cnx.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
						 
			
																		
		  
                   AND cdnx.c_dongnhapxuat_id = tb.c_dongnhapxuat_id) AS nhan
												  
															  
										  
													   
													   
	   
	  
  
 
	   
            ORDER BY nhan.ma_dtkd,
                     nhan.sophieu,
                     nhan.ma_sanpham
        ", dateFrom.ToString("dd/MM/yyyy"), dateTo.ToString("dd/MM/yyyy"), datenow.ToString("dd/MM/yyyy"));
        }
        else
        {
            str = String.Format(@"            
            DECLARE @startdate datetime = convert(datetime, '{0}', 103) 
            DECLARE @enddate datetime = convert(datetime, '{1}', 103) 
            DECLARE @table TABLE ( 
	            c_dongnhapxuat_id nvarchar(32),
	            so_inv nvarchar(50)
            )

            INSERT INTO @table
            SELECT dnx.dongnhapxuat_ref, A.so_inv
            FROM c_dongnhapxuat dnx (nolock)
            inner join (
	            SELECT cdiv5.c_dongnhapxuat_id,
		               civ5.so_inv
	            FROM c_dongpklinv cdiv5 (nolock),
		             c_packinginvoice civ5 (nolock)
	            WHERE civ5.c_packinginvoice_id = cdiv5.c_packinginvoice_id
	              AND civ5.md_trangthai_id = 'HIEULUC'
	              AND civ5.ngay_motokhai >= @startdate
	              AND civ5.ngay_motokhai <= @enddate
            ) A on dnx.c_dongnhapxuat_id = A.c_dongnhapxuat_id

              SELECT nhan.*,
                (SELECT convert(decimal,sum((cdnx5.slthuc_nhapxuat * cdnx5.dongia) - (cdnx5.slthuc_nhapxuat * cdnx5.dongia)*cnx5.discount/100))
                 FROM c_dongnhapxuat cdnx5,
                      c_nhapxuat cnx5,
                      c_dongdonhang cdgh5,
                      c_donhang dh5,
                      md_sanpham sp5
                 WHERE cnx5.c_nhapxuat_id = cdnx5.c_nhapxuat_id
                   AND cdnx5.md_sanpham_id = sp5.md_sanpham_id
                   AND cdgh5.c_dongdonhang_id = cdnx5.c_dongdonhang_id
                   AND cdgh5.c_donhang_id = dh5.c_donhang_id
                   AND cnx5.md_loaichungtu_id = 'NK'
										 
                   AND cdnx5.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
	            ) AS tongtiencc ,

                (SELECT sum(cdnx5.dongia)
                 FROM c_dongnhapxuat cdnx5,
                      c_nhapxuat cnx5,
                      c_dongdonhang cdgh5,
                      c_donhang dh5,
                      md_sanpham sp5
                 WHERE cnx5.c_nhapxuat_id = cdnx5.c_nhapxuat_id
                   AND cdnx5.md_sanpham_id = sp5.md_sanpham_id
                   AND cdgh5.c_dongdonhang_id = cdnx5.c_dongdonhang_id
                   AND cdgh5.c_donhang_id = dh5.c_donhang_id
                   AND cnx5.md_loaichungtu_id = 'NK'
										 
                   AND cdnx5.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
	            ) AS tongdongiacc,

                (SELECT sum(cdnx5.slthuc_nhapxuat)
                 FROM c_dongnhapxuat cdnx5,
                      c_nhapxuat cnx5,
                      c_dongdonhang cdgh5,
                      c_donhang dh5,
                      md_sanpham sp5
                 WHERE cnx5.c_nhapxuat_id = cdnx5.c_nhapxuat_id
                   AND cdnx5.md_sanpham_id = sp5.md_sanpham_id
                   AND cdgh5.c_dongdonhang_id = cdnx5.c_dongdonhang_id
                   AND cdgh5.c_donhang_id = dh5.c_donhang_id
                   AND cnx5.md_loaichungtu_id = 'NK'
										 
                   AND cdnx5.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
	            ) AS tongsoluongcc
  
              FROM
                (
		            SELECT cnx.sophieu,
                        cnx.ngay_giaonhan,
                        sp.ma_sanpham,
                        cdnx.mota_tiengviet,
                        cdnx.slthuc_nhapxuat,
                        cdnx.dongia,
                        convert(decimal,(cdnx.slthuc_nhapxuat * cdnx.dongia) - (cdnx.slthuc_nhapxuat * cdnx.dongia)*cnx.discount/100) AS thanhtien,
				   
                        dtkd.ma_dtkd,
                        dh.sochungtu AS sopo,
                        cnx.phicong AS phicongPO,
                        cnx.phitru AS phitruPO,
                        @startdate AS tungay,
                        @enddate AS denngay,
                        GETDATE() AS today,
                        cnx.discount ,

                   (SELECT convert(decimal,sum((cdnx2.slthuc_nhapxuat * cdnx2.dongia) - (cdnx2.slthuc_nhapxuat * cdnx2.dongia)*cnx2.discount/100))
                    FROM c_dongnhapxuat cdnx2,
                         c_nhapxuat cnx2,
                         c_dongdonhang cdgh2,
                         c_donhang dh2,
                         md_sanpham sp2
                    WHERE cnx2.c_nhapxuat_id = cdnx2.c_nhapxuat_id
                      AND cdnx2.md_sanpham_id = sp2.md_sanpham_id
                      AND cdgh2.c_dongdonhang_id = cdnx2.c_dongdonhang_id
                      AND cdgh2.c_donhang_id = dh2.c_donhang_id
                      AND cnx2.md_loaichungtu_id = 'NK'
                      AND cnx2.md_doitackinhdoanh_id = cnx.md_doitackinhdoanh_id
                      AND cdnx2.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)
																		
		  
									
													
																
										   
														
														
	   
		            ) AS tongtien ,

                   (SELECT sum(cdnx3.dongia)
                    FROM c_dongnhapxuat cdnx3,
                         c_nhapxuat cnx3,
                         c_dongdonhang cdgh3,
                         c_donhang dh3,
                         md_sanpham sp3
                    WHERE cnx3.c_nhapxuat_id = cdnx3.c_nhapxuat_id
                      AND cdnx3.md_sanpham_id = sp3.md_sanpham_id
                      AND cdgh3.c_dongdonhang_id = cdnx3.c_dongdonhang_id
                      AND cdgh3.c_donhang_id = dh3.c_donhang_id
                      AND cnx3.md_loaichungtu_id = 'NK'
                      AND cnx3.md_doitackinhdoanh_id = cnx.md_doitackinhdoanh_id
                      AND cdnx3.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)) AS tongdongia ,

		  
									
													
																
										   
														
														
	   
					 
	  
                   (SELECT sum(cdnx4.slthuc_nhapxuat)
                    FROM c_dongnhapxuat cdnx4,
                         c_nhapxuat cnx4,
                         c_dongdonhang cdgh4,
                         c_donhang dh4,
                         md_sanpham sp4
                    WHERE cnx4.c_nhapxuat_id = cdnx4.c_nhapxuat_id
                      AND cdnx4.md_sanpham_id = sp4.md_sanpham_id
                      AND cdgh4.c_dongdonhang_id = cdnx4.c_dongdonhang_id
                      AND cdgh4.c_donhang_id = dh4.c_donhang_id
                      AND cnx4.md_loaichungtu_id = 'NK'
                      AND cnx4.md_doitackinhdoanh_id = cnx.md_doitackinhdoanh_id
                      AND cdnx4.c_dongnhapxuat_id IN (SELECT c_dongnhapxuat_id FROM @table)) AS tongsoluong,
		              tb.so_inv
		  
									
													
																
										   
														
														
	   
					  
																													
											  
											
													
										  
								   
															 
												  
						 
			
																		
		  
								   
												  
															  
										  
													   
													   
	   
	  
  
 
	   
												   

                 FROM c_dongnhapxuat cdnx,
                      c_nhapxuat cnx,
                      c_dongdonhang cdgh,
                      c_donhang dh,
                      md_sanpham sp,
                      md_doitackinhdoanh dtkd,
		              @table tb
                 WHERE cnx.c_nhapxuat_id = cdnx.c_nhapxuat_id
                   AND cdnx.md_sanpham_id = sp.md_sanpham_id
                   AND cdgh.c_dongdonhang_id = cdnx.c_dongdonhang_id
                   AND cdgh.c_donhang_id = dh.c_donhang_id
                   AND cnx.md_loaichungtu_id = 'NK'
                   AND cnx.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
                   AND cnx.md_doitackinhdoanh_id = N'{2}'
                   AND cdnx.c_dongnhapxuat_id = tb.c_dongnhapxuat_id) AS nhan
            ORDER BY nhan.ma_dtkd,
                     nhan.sophieu,
                     nhan.ma_sanpham
            ", dateFrom.ToString("dd/MM/yyyy"), dateTo.ToString("dd/MM/yyyy"), dtkd, datenow.ToString("dd/MM/yyyy"));
        }
            return str;
    }
}