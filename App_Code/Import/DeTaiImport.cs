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


public class DeTaiImport : ImportOriginal
{
    private String code_dt, code_cl_id, code_cl, tv_ngan, ta_ngan, hinhthucban, ghichu;

    public String Code_dt
    {
        get { return code_dt; }
        set { code_dt = value; }
    }

    public String Code_cl_id
    {
        get { return code_cl_id; }
        set { code_cl_id = value; }
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
	
	public String Hinhthucban
    {
        get { return hinhthucban; }
        set { hinhthucban = value; }
    }

    public String Ghichu
    {
        get { return ghichu; }
        set { ghichu = value; }
    }

    public DeTaiImport()
    {
    
    }

    public DeTaiImport(String maDeTai, String md_chungloai_id, String code_cl, String tiengVietNgan, String tiengAnhNgan, String Hinhthucban, String ghiChu)
        : this(maDeTai, md_chungloai_id, code_cl, tiengVietNgan, tiengAnhNgan, Hinhthucban, ghiChu, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public DeTaiImport(String maDeTai, String md_chungloai_id, String code_cl, String tiengVietNgan, String tiengAnhNgan, String Hinhthucban, String ghiChu
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this.code_dt = maDeTai;
        this.code_cl_id = md_chungloai_id;
        this.code_cl = code_cl;
        this.tv_ngan = tiengVietNgan;
        this.ta_ngan = tiengAnhNgan;
		
		if(Hinhthucban == "0")
			hinhthucban = "Bán đại trà";
		else if(Hinhthucban == "1")
			hinhthucban = "Độc quyền";
		else if(Hinhthucban == "2")
			hinhthucban = "Quản lý ngoài";
		else if(Hinhthucban == "3")
			hinhthucban = "Bán thử nghiệm";
		else
			hinhthucban = "";
        this.hinhthucban = hinhthucban;
        //this.tv_dai = tiengVietDai;
        //this.ta_dai = tiengAnhDai;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.ghichu = ghiChu;
		this.hoatDong = hoatDong;
    }

    public void Import()
    {
        var mnu = new md_detai
        {
            md_detai_id = Helper.getNewId(),
            md_chungloai_id = code_cl_id,
            code_cl = code_cl,
            code_dt = code_dt,
            tv_ngan = tv_ngan,
            ta_ngan = ta_ngan,
            tv_dai = "",
            ta_dai = "",
            ta_nganWeb = "",
            hinhthucban = hinhthucban,
            trangthai = Helper.SOANTHAO,

            mota = ghichu,
            hoatdong = hoatDong,
            nguoitao = nguoiTao,
            nguoicapnhat = nguoiCapNhat,
            ngaytao = ngayTao,
            ngaycapnhat = ngayCapNhat
        };

        db.md_detais.InsertOnSubmit(mnu);
        VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                HttpContext.Current,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.add,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_detai_id
                }
            );
        db.SubmitChanges();
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public void Update()
    {
        md_detai o = db.md_detais.FirstOrDefault(p =>p.code_dt.Equals(code_dt) && p.code_cl.Equals(code_cl));
        var mnu = new md_detai();
        o.CopyPropertiesTo(mnu);
        o.md_chungloai_id = code_cl_id;
        o.tv_ngan = tv_ngan;
        //o.tv_dai = tv_dai;
        o.ta_ngan = ta_ngan;
        //o.ta_dai = ta_dai;
		o.hinhthucban = hinhthucban;
        o.ngaycapnhat = ngayCapNhat;
        o.nguoicapnhat = nguoiCapNhat;
        o.hoatdong = hoatDong;
        o.mota = ghichu;
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
                    id_lienket = o.md_detai_id
                }
            );
        }
        db.SubmitChanges();
    }
}
