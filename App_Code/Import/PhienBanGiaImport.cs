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


public class PhienBanGiaImport : ImportOriginal
{
    private DateTime ngayHieuLuc;
    private String tenBangGia, tenPhienBan;

    public String TenBangGia
    {
        get { return tenBangGia; }
        set { tenBangGia = value; }
    }

    public String TenPhienBan
    {
        get { return tenPhienBan; }
        set { tenPhienBan = value; }
    }
    

    public DateTime NgayHieuLuc
    {
        get { return ngayHieuLuc; }
        set { ngayHieuLuc = value; }
    }

    public PhienBanGiaImport()
    { 
    }

    public PhienBanGiaImport(String md_banggia_id, String tenPhienBan, DateTime ngayHieuLuc)
        : this(md_banggia_id, tenPhienBan, ngayHieuLuc, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {
    
    }

    public PhienBanGiaImport(String md_banggia_id, String tenPhienBan, DateTime ngayHieuLuc
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.tenBangGia = md_banggia_id;
        this.tenPhienBan = tenPhienBan;
        this.ngayHieuLuc = ngayHieuLuc;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        md_phienbangia pbg = new md_phienbangia();
        pbg.md_phienbangia_id = ImportUtils.getNEWID();
        pbg.md_banggia_id = tenBangGia;
        pbg.ten_phienbangia = tenPhienBan;
        pbg.ngay_hieuluc = ngayHieuLuc;
        pbg.ngaytao = ngayTao;
        pbg.nguoitao = nguoiTao;
        pbg.ngaycapnhat = ngayCapNhat;
        pbg.nguoicapnhat = nguoiCapNhat;
        pbg.hoatdong = hoatDong;
        pbg.md_trangthai_id = Helper.SOANTHAO;

        db.md_phienbangias.InsertOnSubmit(pbg);
        VoNgocNhan.API_Data.themLichSuHoatDong(
            db,
            HttpContext.Current,
            new ad_log
            {
                nexxdecor_check = false,
                hanhdong = VoNgocNhan.API_Data.add,
                table = pbg.GetType().Name,
                id_lienket = pbg.md_phienbangia_id,
                ma_lienket = pbg.ten_phienbangia
            }
        );
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Update()
    {
        md_phienbangia o = db.md_phienbangias.FirstOrDefault(p => p.ten_phienbangia.Equals(tenPhienBan) && p.md_banggia_id.Equals(tenBangGia));
        var mnu = new md_phienbangia();
        o.CopyPropertiesTo(mnu);
        o.ngay_hieuluc = ngayHieuLuc;
        o.md_trangthai_id = Helper.HIEULUC;
        o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;
        o.hoatdong = hoatDong;
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
                    id_lienket = o.md_phienbangia_id,
                    ma_lienket = o.ten_phienbangia
                }
            );
        }
        db.SubmitChanges();
    }
}
