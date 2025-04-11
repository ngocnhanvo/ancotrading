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


public class PhuKienImport : ImportOriginal
{
    private String code_mau, code_dt, code_cl, md_detai_id, md_chungloai_id, tv_ngan, ta_ngan, tv_dai, ta_dai, ghichu;

    public String Md_detai_id
    {
        get { return md_detai_id; }
        set { md_detai_id = value; }
    }

    public String Md_chungloai_id
    {
        get { return md_chungloai_id; }
        set { md_chungloai_id = value; }
    }

    public String Code_mau
    {
        get { return code_mau; }
        set { code_mau = value; }
    }

    public String Code_dt
    {
        get { return code_dt; }
        set { code_dt = value; }
    }

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
	
	public String Tv_dai
    {
        get { return tv_dai; }
        set { tv_dai = value; }
    }
	
	public String Ta_dai
    {
        get { return ta_dai; }
        set { ta_dai = value; }
    }

    public String Ghichu
    {
        get { return ghichu; }
        set { ghichu = value; }
    }

    public PhuKienImport()
    {
    
    }

    public PhuKienImport(String md_chungloai_id, String md_detai_id, String maMau, String code_dt, String code_cl, String tiengVietNgan, String tiengAnhNgan, String tiengVietDai, String tiengAnhDai, String ghiChu)
        : this(md_chungloai_id, md_detai_id, maMau, code_dt, code_cl, tiengVietNgan, tiengAnhNgan, tiengVietDai, tiengAnhDai, ghiChu, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public PhuKienImport(String md_chungloai_id, String md_detai_id, String maMau, String code_dt, String code_cl, String tiengVietNgan, String tiengAnhNgan, String tiengVietDai, String tiengAnhDai, String ghiChu
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {	
        this.code_mau = maMau;
        this.md_detai_id = md_detai_id;
        this.md_chungloai_id = md_chungloai_id;
        this.code_dt = code_dt;
        this.code_cl = code_cl;
        this.tv_ngan = tiengVietNgan;
        this.ta_ngan = tiengAnhNgan;
        this.tv_dai = tiengVietDai;
        this.ta_dai = tiengAnhDai;
        this.ghichu = ghiChu;
		this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Import()
    {
        var o = new md_phukien();
        o.md_phukien_id = Helper.getNewId();
        o.trangthai = Helper.SOANTHAO;
        o.md_chungloai_id = md_chungloai_id;
        o.md_detai_id = md_detai_id;
        o.code_dt = code_dt;
        o.code_cl = code_cl;
        o.code_pk = code_mau;
        o.tv_ngan = tv_ngan;
        o.tv_dai = tv_dai;
        o.ta_ngan = ta_ngan;
        o.ta_dai = ta_dai;
        o.mota = ghichu;
        o.ngaytao = ngayTao;
        o.nguoitao = nguoiTao;
        o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;
        db.md_phukiens.InsertOnSubmit(o);
        db.SubmitChanges();
    }

    
    public void Update()
    {
        var o = db.md_phukiens.FirstOrDefault(p => p.code_pk.Equals(code_mau) && p.code_cl.Equals(code_cl) && p.code_dt.Equals(code_dt));
        o.md_chungloai_id = md_chungloai_id;
        o.md_detai_id = md_detai_id;
        o.code_dt = code_dt;
        o.code_cl = code_cl;
        o.tv_ngan = tv_ngan;
        o.tv_dai = tv_dai;
        o.ta_ngan = ta_ngan;
        o.ta_dai = ta_dai;
        o.mota = ghichu;
		o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;

        db.SubmitChanges();
    }
}
