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


public class DonViTinhDongGoiImport : ImportOriginal
{
    private String maDVT, tenDVT;

    public String MaDVT
    {
        get { return maDVT; }
        set { maDVT = value; }
    }

    public String TenDVT
    {
        get { return tenDVT; }
        set { tenDVT = value; }
    }


    public DonViTinhDongGoiImport()
    {
    
    }

    public DonViTinhDongGoiImport(String maDVT, String tenDVT)
        : this(maDVT, tenDVT, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public DonViTinhDongGoiImport(String maDVT, String tenDVT, DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.maDVT = maDVT;
        this.tenDVT = tenDVT;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        md_donvitinh obj = new md_donvitinh
        {
            md_donvitinh_id = Helper.getNewId(),
            ma_edi = maDVT,
            ten_dvt = tenDVT,
            hoatdong = hoatDong,
            nguoitao = nguoiTao,
            nguoicapnhat = nguoiCapNhat,
            ngaytao = ngayTao,
            ngaycapnhat = ngayCapNhat
        };

        db.md_donvitinhs.InsertOnSubmit(obj);
        VoNgocNhan.API_Data.themLichSuHoatDong(
           db,
           HttpContext.Current,
           new ad_log
           {
               nexxdecor_check = false,
               hanhdong = VoNgocNhan.API_Data.add,
               table = obj.GetType().Name,
               id_lienket = obj.md_donvitinh_id
           }
        );
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Update()
    {
        md_donvitinh o = db.md_donvitinhs.FirstOrDefault(p => p.ma_edi.Equals(maDVT));
        var mnu = new md_donvitinh();
        o.CopyPropertiesTo(mnu);
        o.ten_dvt = tenDVT;
        o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;
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
                    id_lienket = o.md_donvitinh_id
                }
            );
        }
        db.SubmitChanges();
    }
}
