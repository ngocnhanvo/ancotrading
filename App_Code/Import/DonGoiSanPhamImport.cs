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


public class DonGoiSanPhamImport : ImportOriginal
{
    private String maDongGoi, maSanPham, idSanPham;
    private bool macDinh;

    public bool MacDinh
    {
        get { return macDinh; }
        set { macDinh = value; }
    }

    public String MaDongGoi
    {
        get { return maDongGoi; }
        set { maDongGoi = value; }
    }

    public String MaSanPham
    {
        get { return maSanPham; }
        set { maSanPham = value; }
    }

    public String IdSanPham
    {
        get { return idSanPham; }
        set { idSanPham = value; }
    }

    public DonGoiSanPhamImport()
    {
    
    }

    public DonGoiSanPhamImport(String md_donggoi_id, String md_sanpham_id, bool macDinh)
        : this(md_donggoi_id, md_sanpham_id, macDinh, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public DonGoiSanPhamImport(String md_donggoi_id, String md_sanpham_id, bool macDinh
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.maDongGoi = md_donggoi_id;
        this.idSanPham = md_sanpham_id;
        this.macDinh = macDinh;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        md_donggoisanpham mnu = new md_donggoisanpham
        {
            md_donggoisanpham_id = Helper.getNewId(),
            md_donggoi_id = maDongGoi,
            md_sanpham_id = idSanPham,
            soluong = 1,
            macdinh = macDinh,
            hoatdong = hoatDong,
            nguoitao = nguoiTao,
            nguoicapnhat = nguoiCapNhat,
            ngaytao = ngayTao,
            ngaycapnhat = ngayCapNhat
        };

        db.md_donggoisanphams.InsertOnSubmit(mnu);
        VoNgocNhan.API_Data.themLichSuHoatDong(
           db,
           HttpContext.Current,
           new ad_log
           {
               nexxdecor_check = false,
               hanhdong = VoNgocNhan.API_Data.add,
               table = mnu.GetType().Name,
               id_lienket = mnu.md_donggoisanpham_id,
               ma_lienket = MaSanPham
           }
        );
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Update()
    {
        md_donggoisanpham o = db.md_donggoisanphams.FirstOrDefault(p => p.md_donggoi_id.Equals(maDongGoi) && p.md_sanpham_id.Equals(maSanPham));
        var mnu = new md_donggoisanpham();
        o.CopyPropertiesTo(mnu);
        o.soluong = 1;
        o.macdinh = macDinh;
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
                    id_lienket = o.md_donggoisanpham_id,
                    ma_lienket = MaSanPham
                }
            );
        }
        db.SubmitChanges();
    }
}
