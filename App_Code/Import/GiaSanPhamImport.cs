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
    private String maSanPham, tenPhienBanGia, moTa, barCode;
    private decimal gia, phi;
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

    public GiaSanPhamImport()
    {
    
    }

    public GiaSanPhamImport(String md_sanpham_id, String md_phienbangia_id, decimal gia, string moTa, string barCode, decimal phi)
        : this(md_sanpham_id, md_phienbangia_id, gia, moTa, barCode, phi, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public GiaSanPhamImport(String md_sanpham_id, String md_phienbangia_id, decimal gia, string moTa, string barCode
        , decimal phi, DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.maSanPham = md_sanpham_id;
        this.tenPhienBanGia = md_phienbangia_id;
        this.gia = gia;
        this.phi = phi;
        this.moTa = moTa;
        this.barCode = barCode;
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
        gsp.md_sanpham_id = maSanPham;
        gsp.md_phienbangia_id = tenPhienBanGia;
        gsp.gia = gia;
        gsp.phi = phi;
        gsp.mota = moTa;
        gsp.barcode = barCode;
        gsp.ngaytao = ngayTao;
        gsp.nguoitao = nguoiTao;
        gsp.ngaycapnhat = ngayCapNhat;
        gsp.nguoicapnhat = nguoiCapNhat;
        gsp.hoatdong = hoatDong;

        db.md_giasanphams.InsertOnSubmit(gsp);
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();
    public void Update()
    {
        md_giasanpham o = db.md_giasanphams.FirstOrDefault(p => p.md_sanpham_id.Equals(maSanPham) && p.md_phienbangia_id.Equals(tenPhienBanGia));
        o.gia = gia;
        o.phi = phi;
        o.mota = moTa;
        o.barcode = barCode;
        o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;
        o.hoatdong = hoatDong;
        db.SubmitChanges();
    }
}
