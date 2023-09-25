using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using NPOI.HSSF.Util;
using System.Data.Linq;
using System.Linq;
using ExcelLibrary.SpreadSheet;
using ExcelLibrary;

public partial class ToolKeToan_NhapLieuPT : System.Web.UI.Page
{
    private LinqDBDataContext db = new LinqDBDataContext();
    string id = Guid.NewGuid().ToString().Replace("-", "").ToLower();
    string filePath = "", filenameLC = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        string type = Request.QueryString["type"];

        HttpFileCollection files = Request.Files;
        string msg = "";
        string msgFmtErr = "<div style='color:red'>Dòng {0}: {1}</div>";
        string msgFmtSuc = "<div style='color:blue'>Dòng {0}: {1}</div>";
        if (files.Count > 0)
        {
            filenameLC = files[0].FileName.Replace(".xlsx", ".xls");
            if (filenameLC != "")
            {
                filePath = Server.MapPath("../VNN_Files/" + id + files[0].FileName);
                files[0].SaveAs(filePath);
                try
                {
                    int j = filePath.LastIndexOf(".");
                    if (filePath.Substring(j) != ".xls")
                    {
                        filePath = ConvertXLSXToXLS.ConvertWorkbookXSSFToHSSF(filePath);
                    }
                    Workbook wb = Workbook.Load(filePath);
                    Worksheet ws = wb.Worksheets[0];
                    var cellCollection = ws.Cells;
                    int totalCount = cellCollection.Rows.Count;
                    var cotheImport = true;

                    var sochungtu = db.md_sochungtus.Single(s => s.tiento.Equals("PT"));
                    string md_loaichungtu_id = db.md_loaichungtus.Where(s => s.kieu_doituong == "PT").Select(s => s.md_loaichungtu_id).FirstOrDefault();

                    for (int i = 1; i < totalCount; i++)
                    {
                        string msgDT = "";
                        try
                        {
                            Row row = cellCollection.Rows[i];

                            var loaiPhieuThu = row.GetCell(0).Value == null ? "" : row.GetCell(0).Value.ToString().removeAllSpaceOrTrimText(true);
                            var dinhDanh = row.GetCell(1).Value == null ? "" : row.GetCell(1).Value.ToString().removeAllSpaceOrTrimText(true);
                            var maKH = row.GetCell(2).Value == null ? "" : row.GetCell(2).Value.ToString().removeAllSpaceOrTrimText(true);
                            var ngayLapPhieu = row.GetCell(3).Value == null ? "" : row.GetCell(3).Value.ToString();
                            var nguoiGiaoNop = row.GetCell(4).Value == null ? "" : row.GetCell(4).Value.ToString();
                            var ngayGiaoNop = row.GetCell(5).Value == null ? "" : row.GetCell(5).Value.ToString();
                            var soTien = row.GetCell(6).Value == null ? "0" : row.GetCell(6).Value.ToString();
                            var dongTien = row.GetCell(7).Value == null ? "VND" : row.GetCell(7).Value.ToString().removeAllSpaceOrTrimText(true);
                            var tyGia = row.GetCell(8).Value == null ? "1" : row.GetCell(8).Value.ToString().removeAllSpaceOrTrimText(true);
                            var quyDoiVND = row.GetCell(9).Value == null ? "" : row.GetCell(9).Value.ToString().removeAllSpaceOrTrimText(true);
                            var moTa1 = row.GetCell(10).Value == null ? "" : row.GetCell(10).Value.ToString().removeAllSpaceOrTrimText(true);
                            var soChungTu = row.GetCell(11).Value == null ? "" : row.GetCell(11).Value.ToString().removeAllSpaceOrTrimText(true);
                            var taiKhoanQuy = row.GetCell(12).Value == null ? "" : row.GetCell(12).Value.ToString().removeAllSpaceOrTrimText(true);
                            var moTa2 = row.GetCell(13).Value == null ? "" : row.GetCell(13).Value.ToString().removeAllSpaceOrTrimText(true);

                            var dtkd = db.md_doitackinhdoanhs.Where(s => s.ma_dtkd == maKH).FirstOrDefault();
                            if (dtkd == null)
                            {
                                msgDT = string.Format(msgFmtErr, i, "Mã KH " + maKH + " không tồn tại");
                            }

                            var dongtien = db.md_dongtiens.Where(s => s.ma_iso == dongTien).FirstOrDefault();
                            if (dongtien == null)
                            {
                                msgDT = string.Format(msgFmtErr, i, "Đồng tiền " + dongTien + " không tồn tại");
                            }

                            if(string.IsNullOrWhiteSpace(ngayGiaoNop) | ngayGiaoNop == "0")
                            {
                                msgDT = string.Format(msgFmtErr, i, "Ngày giao nộp có giá trị sai");
                            }

                            if (string.IsNullOrWhiteSpace(soTien))
                            {
                                msgDT = string.Format(msgFmtErr, i, "Số tiền có giá trị sai");
                            }

                            if (msgDT.Length <= 0)
                            {
                                msgDT = Helper.themPhieuThu(Context, db,
                                     sochungtu.tiento,
                                     sochungtu.so_duocgan,
                                     sochungtu.hauto,
                                     dinhDanh,
                                     dtkd.md_doitackinhdoanh_id,
                                     loaiPhieuThu,
                                     ngayLapPhieu,
                                     nguoiGiaoNop,
                                     ngayGiaoNop,
                                     soTien,
                                     dongtien.md_dongtien_id,
                                     tyGia,
                                     moTa1,
                                     "",
                                     md_loaichungtu_id,
                                     soChungTu,
                                     quyDoiVND,
                                     taiKhoanQuy,
                                     moTa2
                                     );

                                if (msgDT.Length > 0)
                                {
                                    cotheImport = false;
                                    msg += string.Format(msgFmtErr, i, msgDT);
                                }
                                else
                                {
                                    sochungtu.so_duocgan = sochungtu.so_duocgan + sochungtu.buocnhay;
                                    msg += string.Format(msgFmtSuc, i, "Dữ liệu an toàn");
                                }
                            }
                            else
                            {
                                msg += msgDT;
                                cotheImport = false;
                            }
                        }
                        catch(Exception ex)
                        {
                            msg += string.Format(msgFmtErr, i, ex);
                            cotheImport = false;
                        }
                    }

                    if (cotheImport)
                    {
                        db.SubmitChanges();
                        msg += string.Format(msgFmtSuc.Replace("Dòng {0}:", ""), "<br>", string.Format("Đã thêm hoặc chỉnh sửa thành công {0} dòng.", totalCount - 1));
                    }
                }
                catch (Exception ex)
                {
                    msg = ex.Message;
                }
            }
        }
        else
        {
            msg = "<h3>Không tìm thấy tập tin</h3>";
        }

        Response.Write(msg);
    }
}
