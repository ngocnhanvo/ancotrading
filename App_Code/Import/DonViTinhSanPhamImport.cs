using System;
using System.Data;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using ExcelLibrary.SpreadSheet;


public class DonViTinhSanPhamImport
{
    private String maDVT, tenDVT;

    public String MaDVT { get; set; }
    public String TenDVT { get; set; }

    public DonViTinhSanPhamImport()
    {
    
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Import()
    {
        var context = HttpContext.Current;
        md_donvitinhsanpham obj = new md_donvitinhsanpham
        {
            md_donvitinhsanpham_id = Helper.getNewId(),
            ma_edi = maDVT,
            ten_dvt = tenDVT,
            hoatdong = true,
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.md_donvitinhsanphams.InsertOnSubmit(obj);
        VoNgocNhan.API_Data.themLichSuHoatDong(
               db,
               context,
               new ad_log
               {
                   nexxdecor_check = false,
                   hanhdong = VoNgocNhan.API_Data.add,
                   table = obj.GetType().Name,
                   id_lienket = obj.md_donvitinhsanpham_id
               }
           );
        db.SubmitChanges();
    }

    public void Update()
    {
        var context = HttpContext.Current;
        md_donvitinhsanpham o = db.md_donvitinhsanphams.FirstOrDefault(p => p.ma_edi.Equals(maDVT));
        var mnu = new md_donvitinhsanpham();
        o.CopyPropertiesTo(mnu);
        o.ten_dvt = tenDVT;
        o.ngaycapnhat = DateTime.Now;
        o.nguoicapnhat = UserUtils.getUser(context);
        var diffs = VoNgocNhan.API_Data.GetDifferences(o, mnu);
        if (diffs.Count > 0)
        {
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                HttpContext.Current,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.edit,
                    table = o.GetType().Name,
                    id_lienket = o.md_donvitinhsanpham_id
                }
            );
        }
        db.SubmitChanges();
    }
}
