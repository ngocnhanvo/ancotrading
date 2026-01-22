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


public class CangXuatHangImport : ImportOriginal
{
    private String maSanPham, maCangBien;

    public String MaSanPham
    {
        get { return maSanPham; }
        set { maSanPham = value; }
    }

    public String MaCangBien
    {
        get { return maCangBien; }
        set { maCangBien = value; }
    }

    public CangXuatHangImport()
    {

    }

    public CangXuatHangImport(String md_sanpham_id, String md_cangbien_id)
        : this(md_sanpham_id, md_cangbien_id, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public CangXuatHangImport(String md_sanpham_id, String md_cangbien_id
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.maCangBien = md_cangbien_id;
        this.maSanPham = md_sanpham_id;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        var cxh = new md_cangxuathang();
        cxh.md_cangxuathang_id = Helper.getNewId();
        cxh.md_sanpham_id = maSanPham;
        cxh.md_cangbien_id = maCangBien;
        cxh.macdinh = true;
        cxh.ngaytao = ngayTao;
        cxh.ngaycapnhat = ngayCapNhat;
        cxh.nguoitao = nguoiTao;
        cxh.nguoicapnhat = nguoiCapNhat;
        cxh.hoatdong = hoatDong;
        db.md_cangxuathangs.InsertOnSubmit(cxh);
        VoNgocNhan.API_Data.themLichSuHoatDong(
            db,
            HttpContext.Current,
            new ad_log
            {
                nexxdecor_check = false,
                hanhdong = VoNgocNhan.API_Data.add,
                table = cxh.GetType().Name,
                id_lienket = cxh.md_cangxuathang_id
            }
        );
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Update()
    {
        md_cangxuathang bc = db.md_cangxuathangs.FirstOrDefault(p => p.md_cangbien_id.Equals(maCangBien) && p.md_sanpham_id.Equals(maSanPham));
        var mnu = new md_cangxuathang();
        bc.CopyPropertiesTo(mnu);
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
                    id_lienket = bc.md_cangxuathang_id
                }
            );
        }
        db.SubmitChanges();
    }
}
