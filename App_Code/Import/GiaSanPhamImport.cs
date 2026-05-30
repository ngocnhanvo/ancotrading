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


public class GiaSanPhamImport : ImportOriginal
{
    LinqDBDataContext db = new LinqDBDataContext();
    private String idSanPham, maSanPham, tenPhienBanGia, moTa, barCode;
    private decimal gia, phi;
    private String maDongGoi;//#vothanhsang

    public String Barcode
    {
        get { return barCode; }
        set { barCode = value; }
    }
    public String MoTa
    {
        get { return moTa; }
        set { moTa = value; }
    }
    public String IdSanPham
    {
        get { return idSanPham; }
        set { idSanPham = value; }
    }
    public String MaSanPham
    {
        get { return maSanPham; }
        set { maSanPham = value; }
    }

    public String TenPhienBanGia
    {
        get { return tenPhienBanGia; }
        set { tenPhienBanGia = value; }
    }

    public decimal Gia
    {
        get { return gia; }
        set { gia = value; }
    }

    public decimal Phi
    {
        get { return phi; }
        set { phi = value; }
    }
    // #vothanhsang
    public String MaDongGoi
    {
        get { return maDongGoi; }
        set { maDongGoi = value; }
    }


    public GiaSanPhamImport()
    {
        db.CommandTimeout = 100 * 60;
    }

    public GiaSanPhamImport(String md_sanpham_id, String md_phienbangia_id, decimal gia, string moTa, string barCode, decimal phi, string maDongGoi)
        : this(md_sanpham_id, md_phienbangia_id, gia, moTa, barCode, phi, maDongGoi, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {
        db.CommandTimeout = 100 * 60;
    }

    public GiaSanPhamImport(String md_sanpham_id, String md_phienbangia_id, decimal gia, string moTa, string barCode
        , decimal phi, string maDongGoi, DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.idSanPham = md_sanpham_id;
        this.tenPhienBanGia = md_phienbangia_id;
        this.gia = gia;
        this.phi = phi;
        this.moTa = moTa;
        this.barCode = barCode;
        this.maDongGoi = maDongGoi;//#vothanhsang
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        md_giasanpham gsp = new md_giasanpham();
        gsp.md_giasanpham_id = ImportUtils.getNEWID();
        gsp.md_sanpham_id = idSanPham;
        gsp.md_phienbangia_id = tenPhienBanGia;
        gsp.gia = gia;
        gsp.phi = phi;
        gsp.mota = moTa;
        gsp.barcode = barCode;
        gsp.ma_donggoi = maDongGoi;// #vothanhsang
        gsp.ngaytao = ngayTao;
        gsp.nguoitao = nguoiTao;
        gsp.ngaycapnhat = ngayCapNhat;
        gsp.nguoicapnhat = nguoiCapNhat;
        gsp.hoatdong = hoatDong;

        db.md_giasanphams.InsertOnSubmit(gsp);
        VoNgocNhan.API_Data.themLichSuHoatDong(
            db,
            HttpContext.Current,
            new ad_log
            {
                nexxdecor_check = false,
                hanhdong = VoNgocNhan.API_Data.add,
                table = gsp.GetType().Name,
                id_lienket = gsp.md_giasanpham_id,
                ma_lienket = MaSanPham
            }
        );
        db.SubmitChanges();
    }


    public void Update()
    {
        md_giasanpham o = db.md_giasanphams.FirstOrDefault(p => p.md_sanpham_id.Equals(idSanPham) && p.md_phienbangia_id.Equals(tenPhienBanGia));
        var mnu = new md_giasanpham();
        o.CopyPropertiesTo(mnu);
        o.gia = gia;
        o.phi = phi;
        o.mota = moTa;
        o.barcode = barCode;
        o.ma_donggoi = maDongGoi;
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
                    id_lienket = o.md_giasanpham_id,
                    ma_lienket = MaSanPham
                }
            );
        }
        db.SubmitChanges();
    }
}
