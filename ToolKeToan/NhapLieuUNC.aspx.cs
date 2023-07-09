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

public partial class ToolKeToan_NhapLieuUNC : System.Web.UI.Page
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
                    for (int i = 1; i < totalCount; i++)
                    {
                        try
                        {
                            Row row = cellCollection.Rows[i];
                            string sophieu = row.GetCell(0).Value.ToString();

                            var unc = db.c_thuchis.Where(s => s.sophieu == sophieu).FirstOrDefault();
                            if(unc == null)
                            {
                                msg += string.Format(msgFmtErr, i, sophieu + " không tồn tại");
                            }
                            else if(unc.md_trangthai_id == "HIEULUC")
                            {
                                msg += string.Format(msgFmtErr, i, sophieu + " đã hiệu lực");
                            }
                            else
                            {
                                var context = Context;
                                var tenCongTy = row.GetCell(4).Value.ToString().removeAllSpaceOrTrimText(true);
                                string ltt = row.GetCell(10).Value.ToString().removeAllSpaceOrTrimText(true);
                                bool isPO = ltt == "PO", isINV = ltt == "IN";
                                string poINV = row.GetCell(11).Value == null ? "" : row.GetCell(11).Value.ToString().removeAllSpaceOrTrimText(true);
                                var dtkd = db.md_doitackinhdoanhs.Where(s => s.ten_dtkd == tenCongTy).FirstOrDefault();
                                c_donhang po = isPO ? db.c_donhangs.Where(s => s.sochungtu == poINV).FirstOrDefault() : null;
                                c_packinginvoice inv = isINV ? db.c_packinginvoices.Where(s => s.so_inv == poINV).FirstOrDefault() : null;
                                string msgDT = "";
                                if (dtkd == null)
                                {
                                    msgDT = string.Format(msgFmtErr, i, tenCongTy + " không tồn tại");
                                }

                                if(po == null & isPO)
                                {
                                    msgDT = string.Format(msgFmtErr, i, poINV + " không tồn tại PO này");
                                }

                                if (inv == null & isINV)
                                {
                                    msgDT = string.Format(msgFmtErr, i, poINV + " không tồn tại INV này");
                                }

                                if (msgDT.Length <= 0)
                                {
                                    string loai = row.GetCell(1).Value.ToString().removeAllSpaceOrTrimText(true);

                                    string tc = "0";
                                    string tiencong = "0";
                                    string c_thuchi_id = unc.c_thuchi_id;
                                    string ids = "";
                                    string values = "";
                                    string md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id;
                                    string ctd_ngaychi = row.GetCell(9).Value.ToString().removeAllSpaceOrTrimText(true);
                                    string thueStr = row.GetCell(8).Value.ToString().removeAllSpaceOrTrimText(true);

                                    string loaiphieu2 = Helper.bienDichLoaiChiTraKhac(row.GetCell(12).Value == null ? "" : row.GetCell(12).Value.ToString().removeAllSpaceOrTrimText(true));
                                    string tkno = row.GetCell(2).Value == null ? "" : row.GetCell(2).Value.ToString().removeAllSpaceOrTrimText(true);
                                    string tkco = row.GetCell(3).Value == null ? "" : row.GetCell(3).Value.ToString().removeAllSpaceOrTrimText(true);
                                    string diengiai = row.GetCell(13).Value == null ? "" : row.GetCell(13).Value.ToString().removeAllSpaceOrTrimText(true);
                                    string c_donhang_id = isPO ? po.sochungtu : "";
                                    string c_packinginvoice_id = isINV ? inv.so_inv : "";
                                    string mota = "";
                                    string sotien = row.GetCell(7).Value == null ? "" : row.GetCell(7).Value.ToString().removeAllSpaceOrTrimText(true);
                                    string c_nhapxuat_id = "";
                                    string sotaikhoan = row.GetCell(5).Value == null ? "" : row.GetCell(5).Value.ToString().removeAllSpaceOrTrimText(true);
                                    string nganhang = row.GetCell(6).Value == null ? "" : row.GetCell(6).Value.ToString().removeAllSpaceOrTrimText(true);
                                    msgDT = Helper.themChiTietUyNhiemChi(context, db,
                                        loai, tc, tiencong, c_thuchi_id, ids, values, md_doitackinhdoanh_id, ctd_ngaychi, thueStr, ltt,
                                        loaiphieu2, tkno, tkco, diengiai, c_donhang_id, c_packinginvoice_id, mota, sotien, c_nhapxuat_id,
                                        sotaikhoan, nganhang
                                        );

                                    if (msgDT.Length > 0)
                                    {
                                        cotheImport = false;
                                        msg += string.Format(msgFmtErr, i, msgDT);
                                    }
                                    else
                                        msg += string.Format(msgFmtSuc, i, "Dữ liệu an toàn");
                                }
                                else
                                {
                                    msg += msgDT;
                                    cotheImport = false;
                                }
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
                        msg += string.Format(msgFmtSuc.Replace("Dòng {0}:", ""), "<br>", string.Format("Đã import thành công {0} dòng.", totalCount - 1));
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
