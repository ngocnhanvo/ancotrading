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


public class HangHoaDocQuyenImport : ImportOriginal
{
    private String maKhachHang, maSanPham, ngayKetThuc, moTa, ghiChu;

    public String MaKhachHang
    {
        get { return maKhachHang; }
        set { maKhachHang = value; }
    }

    public String MaSanPham
    {
        get { return maSanPham; }
        set { maSanPham = value; }
    }
	
	public String MoTa
    {
        get { return moTa; }
        set { moTa = value; }
    }
	
	public String NgayKetThuc
    {
        get { return ngayKetThuc; }
        set { ngayKetThuc = value; }
    }
	
	public String GhiChu
    {
        get { return ghiChu; }
        set { ghiChu = value; }
    }

    public HangHoaDocQuyenImport(String md_sanpham_id, String md_doitackinhdoanh_id, String ngayKetThuc, String moTa, String ghiChu)
        : this(md_sanpham_id, md_doitackinhdoanh_id, ngayKetThuc, moTa, ghiChu, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {
    
    }

    public HangHoaDocQuyenImport(String md_sanpham_id, String md_doitackinhdoanh_id, String ngayKetThuc, String moTa, String ghiChu
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.maSanPham = md_sanpham_id;
        this.maKhachHang = md_doitackinhdoanh_id;
		this.ngayKetThuc = ngayKetThuc;
		this.moTa = moTa;
		this.ghiChu = ghiChu;
		
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public HangHoaDocQuyenImport()
    {

    }

    public void Import()
    {
        var mnu = new md_hanghoadocquyen
        {
            md_hanghoadocquyen_id = Helper.getNewId(),
            md_doitackinhdoanh_id = maKhachHang,
            md_sanpham_id = maSanPham,
            mota = moTa,
            hoatdong = hoatDong,
            nguoitao = nguoiTao,
            nguoicapnhat = nguoiCapNhat,
            ngaytao = ngayTao,
            ngaycapnhat = ngayCapNhat,
            ghichu = ghiChu,
            ngayketthuc = ngayKetThuc.ToNullableDate()
        };
        db.md_hanghoadocquyens.InsertOnSubmit(mnu);
        VoNgocNhan.API_Data.themLichSuHoatDong(
            db,
            HttpContext.Current,
            new ad_log
            {
                nexxdecor_check = false,
                hanhdong = VoNgocNhan.API_Data.add,
                table = mnu.GetType().Name,
                id_lienket = mnu.md_hanghoadocquyen_id
            }
        );
        db.SubmitChanges();

        md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(maKhachHang));
        if (dtkd != null)
        {
            dtkd.isdocquyen = true;
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                HttpContext.Current,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.edit,
                    table = dtkd.GetType().Name,
                    id_lienket = dtkd.md_doitackinhdoanh_id
                }
            );
            db.SubmitChanges();
        }
    }

    LinqDBDataContext db = new LinqDBDataContext();
    public void Update()
    {
        md_hanghoadocquyen o = db.md_hanghoadocquyens.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(maKhachHang) && p.md_sanpham_id.Equals(maSanPham));
        var mnu = new md_hanghoadocquyen();
        o.CopyPropertiesTo(mnu);
        if(string.IsNullOrEmpty(ngayKetThuc))
			o.ngayketthuc = null;
		else
			o.ngayketthuc = DateTime.ParseExact(ngayKetThuc, "dd/MM/yyyy", null);
		o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;
		o.mota = moTa;
        o.hoatdong = hoatDong;
		o.ghichu = ghiChu;
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
                    id_lienket = o.md_hanghoadocquyen_id
                }
            );
        }
        db.SubmitChanges();

        md_doitackinhdoanh dtkd = db.md_doitackinhdoanhs.FirstOrDefault(p => p.md_doitackinhdoanh_id.Equals(maKhachHang));
        if (dtkd != null)
        {
            dtkd.isdocquyen = true;
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                HttpContext.Current,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.edit,
                    table = dtkd.GetType().Name,
                    id_lienket = dtkd.md_doitackinhdoanh_id
                }
            );
            db.SubmitChanges();
        }
    }
}
