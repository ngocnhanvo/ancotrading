using System;
using System.Linq;
using System.Web.UI.WebControls;
using System.Data;
using Newtonsoft.Json;
using System.Collections.Generic;
public partial class Tool_TinhGiaBoTheoPhanTram : System.Web.UI.Page
{
    public bool send = false;
    protected void Page_Load(object sender, EventArgs e)
    {
        send = Request.Form["send"] == "true";
        if (send)
        {
            string pbgcu = Request.Form["pbgcu"];
            string pbgmoi = Request.Form["pbgmoi"];
            string searchTemp = Request.Form["search"];
            var phantram = decimal.Parse(Request.Form["phantram"]);
            var tinhGiaBoTuCai = phantram == 0;
            var filter = "";
            if (!string.IsNullOrWhiteSpace(searchTemp))
                filter = string.Format(" and sp.ma_sanpham LIKE N'{0}'", searchTemp);

            string sql = string.Format(@"
                select
                    gsp.md_giasanpham_id,
                    gsp.md_phienbangia_id,
                    sp.ma_sanpham,
                    sp.md_sanpham_id,
                    gsp.gia,
                    gsp.phi,
                    isnull(gsp.gia, 0) + isnull(gsp.phi, 0) as tongGia,
                    gsp.mota,
                    gsp.barcode
                from md_giasanpham gsp
                left join md_sanpham sp on gsp.md_sanpham_id = sp.md_sanpham_id
                where gsp.md_phienbangia_id = (select md_phienbangia_id from md_phienbangia where ten_phienbangia = '{0}') {1}
                order by sp.ma_sanpham
            ", pbgcu, filter);

            var tbl = mdbc.GetData(sql);
            var db = new LinqDBDataContext();
            var pbgMoiId = db.md_phienbangias.Where(s => s.ten_phienbangia == pbgmoi).Select(s=>s.md_phienbangia_id).FirstOrDefault();
            foreach (DataRow row in tbl.Rows)
            {
                var spCode = row["ma_sanpham"] + "";
                var spId = row["md_sanpham_id"] + "";
                var pbgCuId = row["md_phienbangia_id"] + "";
                var giaCu = row["gia"] as decimal?;
                var phiCu = row["phi"] as decimal?;

                var laMaBo = new string[] { "S", "B", "L", "X" }.Contains(spCode.Substring(9, 1));
                var giaTriBo = spCode.Substring(9, 2);
                laMaBo = giaTriBo != "S1";
                decimal? giaMoi = 0;
                decimal? phiMoi = 0;

                if (tinhGiaBoTuCai)
                {
                    if (laMaBo)
                    {
                        var boMain = Helper.layBoLonNhat(db, giaTriBo, spCode);

                        foreach (var cai in db.md_bo_chitiets.Where(s => s.md_bo_id == boMain.md_bo_id).OrderBy(s => s.md_bo_detail).ToList())
                        {
                            var maCai = spCode.Substring(0, 9) + cai.md_bo_detail + spCode.Substring(11);

                            var spCai = db.md_sanphams.Where(s => s.ma_sanpham == maCai).FirstOrDefault();

                            if (spCai == null)
                                throw new Exception(string.Format(@"Mã cái ""{0}"" không tồn tại.",maCai));
                            else
                            {
                                var gspCai = db.md_giasanphams.Where(s => s.md_phienbangia_id == pbgCuId & s.md_sanpham_id == spId).FirstOrDefault();
                                if (spCai == null)
                                    throw new Exception(string.Format(@"Mã cái ""{0}"" không có giá.", maCai));
                                else
                                {
                                    giaMoi += gspCai.gia.GetValueOrDefault(0);
                                    phiMoi += gspCai.phi.GetValueOrDefault(0);
                                }
                            }
                        }
                    }
                    else
                    {
                        giaMoi = giaCu;
                        phiMoi = phiCu;
                    }
                }
                else
                {
                    giaMoi = giaCu * phantram / 100;
                    phiMoi = phiCu * phantram / 100;
                }

                var gspMoi = db.md_giasanphams.Where(s => s.md_phienbangia_id == pbgMoiId & s.md_sanpham_id == spId).FirstOrDefault();
                if(gspMoi == null)
                {
                    gspMoi = new md_giasanpham();
                    gspMoi.md_giasanpham_id = Helper.getNewId();
                    gspMoi.md_phienbangia_id = pbgMoiId;
                    gspMoi.md_sanpham_id = spId;
                    gspMoi.gia = giaMoi;
                    gspMoi.phi = phiMoi;
                    gspMoi.mota = row["mota"].ToString();
                    gspMoi.barcode = row["barcode"].ToString();
                    gspMoi.nguoitao = UserUtils.getUser(Context);
                    gspMoi.ngaytao = DateTime.Now;
                    gspMoi.nguoicapnhat = UserUtils.getUser(Context);
                    gspMoi.ngaycapnhat = DateTime.Now;
                    db.md_giasanphams.InsertOnSubmit(gspMoi);
                }
                else
                {
                    gspMoi.gia = giaMoi;
                    gspMoi.phi = phiMoi;
                    gspMoi.nguoicapnhat = UserUtils.getUser(Context);
                    gspMoi.ngaycapnhat = DateTime.Now;
                }
            }

            db.SubmitChanges();
        }
    }
}
