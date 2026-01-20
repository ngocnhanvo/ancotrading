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


public class ChungLoaiHangHoaImport : ImportOriginal
{
    private String code_cl="", tv_ngan="", ta_ngan="", mota="";

    public String Code_cl
    {
        get { return code_cl; }
        set { code_cl = value; }
    }

    public String Tv_ngan
    {
        get { return tv_ngan; }
        set { tv_ngan = value; }
    }

    public String Ta_ngan
    {
        get { return ta_ngan; }
        set { ta_ngan = value; }
    }
	
	public String Mota
    {
        get { return mota; }
        set { mota = value; }
    }

    public ChungLoaiHangHoaImport()
    {
    
    }

    public ChungLoaiHangHoaImport(String maChungLoai, String tiengVietNgan, String tiengAnhNgan, String moTa)
        : this(maChungLoai, tiengVietNgan, tiengAnhNgan, moTa, DateTime.Now, "admin", DateTime.Now, "admin", true)
    { 
    
    }

    public ChungLoaiHangHoaImport(String maChungLoai, String tiengVietNgan, String tiengAnhNgan, String moTa
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.code_cl = maChungLoai;
        this.tv_ngan = tiengVietNgan;
        this.ta_ngan = tiengAnhNgan;
        //this.tv_dai = "";
        //this.ta_dai = "";
        this.mota = moTa;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        var mnu = new md_chungloai
        {
            md_chungloai_id = Helper.getNewId(),
            code_cl = code_cl,
            tv_ngan = tv_ngan,
            ta_ngan = ta_ngan,
            trangthai = Helper.SOANTHAO,
            mota = mota,
            hoatdong = hoatDong,
            nguoitao = nguoiTao,
            nguoicapnhat = nguoiCapNhat,
            ngaytao = ngayTao,
            ngaycapnhat = ngayCapNhat
        };

        db.md_chungloais.InsertOnSubmit(mnu);
        VoNgocNhan.API_Data.themLichSuHoatDong(
            db,
            HttpContext.Current,
            new ad_log
            {
                nexxdecor_check = false,
                hanhdong = VoNgocNhan.API_Data.add,
                table = mnu.GetType().Name,
                id_lienket = mnu.md_chungloai_id
            }
        );
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Update()
    {
        md_chungloai o = db.md_chungloais.FirstOrDefault(p => p.code_cl.Equals(code_cl));
        var mnu = new md_chungloai();
        o.CopyPropertiesTo(mnu);
        o.tv_ngan = tv_ngan;
        //o.tv_dai = tv_dai;
        o.ta_ngan = ta_ngan;
        //o.ta_dai = ta_dai;
        o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;
        o.hoatdong = hoatDong;
		o.mota = mota;
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
                    id_lienket = o.md_chungloai_id
                }
            );
        }
        db.SubmitChanges();
    }
}
