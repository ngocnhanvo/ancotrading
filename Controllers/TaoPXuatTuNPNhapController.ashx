<%@ WebHandler Language="C#" Class="TaoPXuatTuNPNhapController" %>

using System;
using System.Web;
using System.Linq;
using System.Data;

public class TaoPXuatTuNPNhapController : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
        //try
        {
            LinqDBDataContext db = new LinqDBDataContext();
            string msg = "";
            string list_docPO = "";
            // String ids = context.Request.Form["p[arrayPhieuXuat]"];
            // string[] s = ids.Replace(" ", "").Split(',');
			String ids = context.Request.Form["p_s"];
			string[] s = ids.Replace(" ", "").Split(',');
			string listPN = "'" + ids.Replace(",", "','").Replace(" ", "") + "'";
            // Kiểm tra các đơn hàng đã kết thúc chưa?
            String sqlStop = "select count(*) from c_donhang dh where dh.md_trangthai_id ='KETTHUC' AND dh.c_donhang_id IN( select distinct c_donhang_id from c_nhapxuat where c_nhapxuat_id IN( " + listPN + " ) )";
            int countStop = (int)mdbc.ExecuteScalar(sqlStop);

            if (countStop > 0)
            {
                msg = "Tạo phiếu xuất thất bại! Vì có đơn hàng đã kết thúc!";
            }
            else
            {
                string sql = @"select COUNT( distinct md_doitackinhdoanh_id) from c_donhang where c_donhang_id 
                in(select distinct c_donhang_id from c_nhapxuat where c_nhapxuat_id in (" + listPN + "))";
                int check = (int)mdbc.ExecuteScalar(sql);

                if (check == 1)
                {
                    string sql_dt = @"select distinct md_doitackinhdoanh_id from c_donhang where c_donhang_id 
                                in(select distinct c_donhang_id from c_nhapxuat where c_nhapxuat_id in (" + listPN + "))";
                    string doitackinhdoanh_id = (string)mdbc.ExecuteScalar(sql_dt);

                    string sql_doc_dh = "select sochungtu from c_donhang where c_donhang_id in(select distinct c_donhang_id from c_nhapxuat where c_nhapxuat_id in (" + listPN + "))";
                    DataTable tbl_doc_PO = mdbc.GetData(sql_doc_dh);
                    foreach (DataRow item in tbl_doc_PO.Rows)
                    {
                        list_docPO += item[0].ToString() + ", ";
                    }

                    c_nhapxuat obj = new c_nhapxuat();
                    obj.c_nhapxuat_id = Security.EncodeMd5Hash(DateTime.Now.ToString());
                    obj.cr_invoice = false;
                    obj.md_doitackinhdoanh_id = doitackinhdoanh_id;
                    obj.sophieunx = list_docPO.Substring(0, list_docPO.Length - 2);
                    obj.md_kho_id = (string)mdbc.ExecuteScalar("SELECT TOP 1 md_kho_id FROM md_kho");
                    obj.md_loaichungtu_id = "XK";
                    obj.md_trangthai_id = "SOANTHAO";
                    obj.ngay_giaonhan = DateTime.Now;
                    obj.ngay_phieu = DateTime.Now;
                    obj.hoatdong = true;
                    obj.ngaytao = DateTime.Now;
                    obj.ngaycapnhat = DateTime.Now;
                    obj.nguoitao = UserUtils.getUser(context);
                    obj.nguoicapnhat = UserUtils.getUser(context);
                    var chungtu = db.md_sochungtus.Single(ct => ct.tiento.Equals("XK"));
                    obj.sophieu = chungtu.tiento + "/" + chungtu.so_duocgan + "/" + chungtu.hauto;

                    // danh sách bảng tạm dòng xuất
                    var listDongXuat = new System.Collections.Generic.List<c_dongnhapxuat>();
                    int line = 10;

                    for (int i = 0; i < s.Length; i++)
                    {
                        var dongNhap = from dn in db.c_dongnhapxuats
                                       where dn.c_nhapxuat_id.Equals(s[i])
                                       select new
                                       {
                                           dn.c_dongdonhang_id,
                                           dn.c_dongnhapxuat_id,
                                           dn.c_dongdsdh_id,
                                           dn.md_donvitinh_id,
                                           dn.md_sanpham_id,
                                           dn.mota,
                                           dn.mota_tiengviet,
                                           dn.slthuc_nhapxuat,
                                           dn.slphai_nhapxuat,
                                           dn.sl_dathang
                                       };

                        foreach (var item in dongNhap)
                        {
                            var dongXuat = new c_dongnhapxuat();
                            var dongDH = db.c_dongdonhangs.Single(ddh => ddh.c_dongdonhang_id.Equals(item.c_dongdonhang_id));
                            dongXuat.c_dongnhapxuat_id = Security.EncodeMd5Hash(DateTime.Now.ToString() + item.c_dongnhapxuat_id);
                            dongXuat.c_nhapxuat_id = obj.c_nhapxuat_id;
                            dongXuat.c_dongdonhang_id = dongDH.c_dongdonhang_id;
                            dongXuat.dongnhapxuat_ref = item.c_dongnhapxuat_id;
                            dongXuat.dongia = dongDH.giafob;
                            dongXuat.c_dongdsdh_id = item.c_dongdsdh_id;
                            dongXuat.hoatdong = true;
                            dongXuat.md_donvitinh_id = item.md_donvitinh_id;
                            dongXuat.md_sanpham_id = item.md_sanpham_id;
                            dongXuat.mota = item.mota;
                            dongXuat.mota_tiengviet = item.mota_tiengviet;
                            dongXuat.slthuc_nhapxuat = item.slthuc_nhapxuat;
                            dongXuat.slphai_nhapxuat = item.slthuc_nhapxuat;
                            dongXuat.sl_dathang = item.sl_dathang;
                            dongXuat.line = line;
                            dongXuat.ngaytao = DateTime.Now;
                            dongXuat.nguoitao = UserUtils.getUser(context);
                            dongXuat.ngaycapnhat = DateTime.Now;
                            dongXuat.nguoicapnhat = UserUtils.getUser(context);

                            listDongXuat.Add(dongXuat);
                            line += 10;
                        }
                    }



                    // Thêm  nhập xuất
                    db.c_nhapxuats.InsertOnSubmit(obj);
                    db.SubmitChanges();

                    // Thêm dòng nhập xuất từ danh sách tạm
                    //db.c_dongnhapxuats.InsertAllOnSubmit(listAddDongXuat);
                    for (int i = 0; i < listDongXuat.Count; i++)
                    {
                        int count__ = (
                                       from ll in db.c_dongnhapxuats
                                       where ll.md_sanpham_id.Equals(listDongXuat[i].md_sanpham_id)
                                       && ll.c_nhapxuat_id.Equals(listDongXuat[i].c_nhapxuat_id)
                                       && ll.dongia.Equals(listDongXuat[i].dongia)
									   && ll.c_dongdonhang_id.Equals(listDongXuat[i].c_dongdonhang_id)
									   && ll.c_dongnhapxuat_id.Equals(listDongXuat[i].c_dongnhapxuat_id)
                                       select new { ll.c_dongnhapxuat_id }
                                       ).Count();
                        if (count__ == 0)
                        {
                            db.c_dongnhapxuats.InsertOnSubmit(listDongXuat[i]);
                            db.SubmitChanges();
                        }
                        else
                        {
                            c_dongnhapxuat dnx = db.c_dongnhapxuats.FirstOrDefault(
                                        p => p.md_sanpham_id.Equals(listDongXuat[i].md_sanpham_id)
                                        && p.c_nhapxuat_id.Equals(listDongXuat[i].c_nhapxuat_id)
                                        && p.dongia.Equals(listDongXuat[i].dongia)
										&& p.c_dongdonhang_id.Equals(listDongXuat[i].c_dongdonhang_id)
										&& p.c_dongnhapxuat_id.Equals(listDongXuat[i].c_dongnhapxuat_id)
                                    );
                            dnx.slthuc_nhapxuat += listDongXuat[i].slthuc_nhapxuat;
                            dnx.slphai_nhapxuat += listDongXuat[i].slphai_nhapxuat;
                            db.SubmitChanges();
                        }
                    }



                    //string getsct = db.c_nhapxuats.Single(xk=>xk.c_nhapxuat_id.Equals(obj.c_nhapxuat_id)).sophieu;
                    msg = "Tạo phiếu xuất thành công! Số PX: " + obj.sophieu;
                }
                else
                {
                    msg = "Không thể tạo phiếu xuất từ các phiếu nhập không cùng 1 khách hàng!";
                }
            }
            context.Response.Write(msg);
        }
        //catch (Exception ex)
        //{
            //context.Response.Write(ex.Message);
        //}

    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}