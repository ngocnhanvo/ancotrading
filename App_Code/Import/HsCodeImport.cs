using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public class HsCodeImport : ImportOriginal
{
    private string _ma_hscode, _hscode, _hehang, _diengiai, _diengiaiTA, _thanhphan, _nhacungung, _ghichu;

    public string Ma_hscode
    {
        get { return _ma_hscode; }
        set { _ma_hscode = value; }
    }

    public string Hscode
    {
        get { return _hscode; }
        set { _hscode = value; }
    }

    LinqDBDataContext db = new LinqDBDataContext();

    public HsCodeImport()
    {

    }

    public HsCodeImport(String ma_hscode, String hscode, String hehang, String diengiai, String diengiaiTA, String thanhphan, String nhacungung, String ghichu)
        : this(ma_hscode, hscode, hehang, diengiai, diengiaiTA, thanhphan, nhacungung, ghichu, DateTime.Now, "admin", DateTime.Now, "admin", true)
    {

    }

    public HsCodeImport(String ma_hscode, String hscode, String hehang, String diengiai, String diengiaiTA, String thanhphan, String nhacungung, String ghichu
        , DateTime ngayTao, String nguoiTao, DateTime ngayCapNhat, String nguoiCapNhat, bool hoatDong)
    {
        this._ma_hscode = ma_hscode;
        this._hscode = hscode;
        this._hehang = hehang;
        this._diengiai = diengiai;
        this._diengiaiTA = diengiaiTA;
        this._thanhphan = thanhphan;
        this._nhacungung = nhacungung;
        this._ghichu = ghichu;
        this.ngayTao = ngayTao;
        this.nguoiTao = nguoiTao;
        this.ngayCapNhat = ngayCapNhat;
        this.nguoiCapNhat = nguoiCapNhat;
        this.hoatDong = hoatDong;
    }

    public void Import()
    {
        md_hscode hs = new md_hscode();
        hs.md_hscode_id = ImportUtils.getNEWID();
        hs.ma_hscode = _ma_hscode;
        hs.hscode = _hscode;
        hs.hehang = _hehang;
        hs.tenhang_tv = _diengiai;
        hs.tenhang_ta = _diengiaiTA;
        hs.thanhphan = _thanhphan;
        hs.nhacungung = _nhacungung;
        hs.mota = _ghichu;
        hs.ngaytao = ngayTao;
        hs.nguoitao = nguoiTao;
        hs.ngaycapnhat = ngayCapNhat;
        hs.nguoicapnhat = nguoiCapNhat;
        hs.hoatdong = hoatDong;

        db.md_hscodes.InsertOnSubmit(hs);
        VoNgocNhan.API_Data.themLichSuHoatDong(
               db,
               HttpContext.Current,
               new ad_log
               {
                   nexxdecor_check = false,
                   hanhdong = VoNgocNhan.API_Data.add,
                   table = hs.GetType().Name,
                   id_lienket = hs.md_hscode_id
               }
           );
        db.SubmitChanges();
    }

    public void Update()
    {
        md_hscode hs = db.md_hscodes.FirstOrDefault(p => p.ma_hscode.Equals(_ma_hscode) & p.hehang.Equals(_hehang));
        if (hs != null)
        {
            var mnu = new md_hscode();
            hs.CopyPropertiesTo(mnu);
            hs.hscode = _hscode;
            hs.hehang = _hehang;
            hs.tenhang_tv = _diengiai;
            hs.tenhang_ta = _diengiaiTA;
            hs.thanhphan = _thanhphan;
            hs.nhacungung = _nhacungung;
            hs.mota = _ghichu;
            hs.ngaycapnhat = ngayCapNhat;
            hs.nguoicapnhat = nguoiCapNhat;
            hs.hoatdong = hoatDong;
            var diffs = VoNgocNhan.API_Data.GetDifferences(hs, mnu);
            if (diffs.Count > 0)
            {
                VoNgocNhan.API_Data.themLichSuHoatDong(
                    db,
                    HttpContext.Current,
                    new ad_log
                    {
                        nexxdecor_check = false,
                        hanhdong = VoNgocNhan.API_Data.edit,
                        table = hs.GetType().Name,
                        id_lienket = hs.md_hscode_id
                    }
                );
            }
            db.SubmitChanges();
        }
    }
}
