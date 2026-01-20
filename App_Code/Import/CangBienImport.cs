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


public class CangBienImport : ImportOriginal
{
    private String maCangBien, tenCangBien;

    public String TenCangBien
    {
        get { return tenCangBien; }
        set { tenCangBien = value; }
    }

    public String MaCangBien
    {
        get { return maCangBien; }
        set { maCangBien = value; }
    }

    public CangBienImport()
    {

    }

    public CangBienImport(String maCangBien, String tenCangBien)
        : this(maCangBien, tenCangBien, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public CangBienImport(String maCangBien, String tenCangBien, DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.maCangBien = maCangBien;
        this.tenCangBien = tenCangBien;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        md_cangbien obj = new md_cangbien
        {
            md_cangbien_id = Helper.getNewId(),
            ma_cangbien = maCangBien,
            ten_cangbien = tenCangBien,
            hoatdong = hoatDong,
            nguoitao = nguoiTao,
            nguoicapnhat = nguoiCapNhat,
            ngaytao = ngayTao,
            ngaycapnhat = ngayCapNhat
        };

        db.md_cangbiens.InsertOnSubmit(obj);
        VoNgocNhan.API_Data.themLichSuHoatDong(
           db,
           HttpContext.Current,
           new ad_log
           {
               nexxdecor_check = false,
               hanhdong = VoNgocNhan.API_Data.add,
               table = obj.GetType().Name,
               id_lienket = obj.md_cangbien_id
           }
        );
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Update()
    {
        md_cangbien bc = db.md_cangbiens.FirstOrDefault(p => p.ma_cangbien.Equals(maCangBien));
        var mnu = new md_cangbien();
        bc.CopyPropertiesTo(mnu);
        bc.ten_cangbien = tenCangBien;
        bc.ngaycapnhat = ngayCapNhat;
        bc.nguoicapnhat = nguoiCapNhat;
        bc.hoatdong = hoatDong;
        var diffs = VoNgocNhan.API_Data.GetDifferences(bc, mnu);
        if (diffs.Count > 0)
        {
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                HttpContext.Current,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.edit,
                    table = bc.GetType().Name,
                    id_lienket = bc.md_cangbien_id
                }
            );
        }
        db.SubmitChanges();
    }
}
