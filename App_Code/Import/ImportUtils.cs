using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Tiện ích import
/// </summary>
public static class ImportUtils
{
    private static LinqDBDataContext db = new LinqDBDataContext();

    /// <summary>
    /// Lấy thông tin đối tượng đồng tiền 
    /// </summary>
    /// <param name="tenDongTien">Tên đồng tiền muốn lấy</param>
    /// <returns>md_dongtien</returns>
 
    public static md_dongtien getDongTien(String tenDongTien)
    {
        md_dongtien dt = db.md_dongtiens.FirstOrDefault(p => p.ma_iso.Equals(tenDongTien));
        return dt;
    }

    /// <summary>
    /// Lấy ID mới
    /// </summary>
    /// <returns>32 ký tự</returns>
    public static String getNEWID()
    {
        String sel = "select RIGHT(sys.fn_sqlvarbasetostr(HashBytes('MD5', CAST(GETDATE() as nvarchar(32)) + CAST(NEWID() as nvarchar(255)) )),32)";
        return (String)mdbc.ExecuteScalar(sel);
    }

    /// <summary>
    /// Lấy thông tin một sản phẩm
    /// </summary>
    /// <param name="maSanPham">Mã sản phẩm cần lấy thông tin</param>
    /// <returns>md_sanpham</returns>
    public static md_sanpham getSanPham(String maSanPham)
    {
        md_sanpham sp = db.md_sanphams.FirstOrDefault(p => p.ma_sanpham.Equals(maSanPham));
        return sp;
        //String select = "select md_sanpham_id from md_sanpham where ma_sanpham=@ma_sanpham";
        //return (String)mdbc.ExecuteScalar(select, "@ma_sanpham", maSanPham);
    }

    /// <summary>
    /// Lấy thông tin biến tấu
    /// </summary>
    /// <param name="md_sanpham_id">mã 32 ký tự của sản phẩm</param>
    /// <param name="maBienTau">mã biến tấu</param>
    /// <returns></returns>
    public static md_bientau getBienTau(String md_sanpham_id, String maBienTau)
    {
        md_bientau bt = db.md_bientaus.FirstOrDefault(p => p.md_sanpham_id.Equals(md_sanpham_id) && p.ma_sanpham_ref.Equals(maBienTau));
        return bt;
    }

    /// <summary>
    /// Lấy thông tin cảng biển
    /// </summary>
    /// <param name="maCangBien"></param>
    /// <returns></returns>
    public static md_cangbien getCangBien(String maCangBien)
    {
        md_cangbien cb = db.md_cangbiens.FirstOrDefault(p => p.ma_cangbien.Equals(maCangBien));
        return cb;
    }

    /// <summary>
    /// Lấy thông tin chủng loại
    /// </summary>
    /// <param name="CodeChungLoai">Mã chủng loại cần lấy</param>
    /// <returns></returns>
    public static md_chungloai getChungLoai(String CodeChungLoai)
    {
        md_chungloai cl = db.md_chungloais.FirstOrDefault(p => p.code_cl.Equals(CodeChungLoai));
        return cl;
    }

    public static md_nhomchungloai getNhomChungLoai(String CodeNhomChungLoai)
    {
        md_nhomchungloai ncl = db.md_nhomchungloais.FirstOrDefault(p => p.code_ncl.Equals(CodeNhomChungLoai));
        return ncl;
    }

    public static md_doitackinhdoanh getDoiTac(String maDoiTac)
    {
        md_doitackinhdoanh dt = db.md_doitackinhdoanhs.FirstOrDefault(p => p.ma_dtkd.Equals(maDoiTac));
        return dt;
    }

    public static md_loaidtkd getLoaiDoiTac(bool isncc)
    {
        String maLoai = isncc == true ? "NCC" : "KH";

        md_loaidtkd ldt = db.md_loaidtkds.FirstOrDefault(p => p.ma_loaidtkd.Equals(maLoai));
        return ldt;
    }
	
	public static md_loaidtkd getLoaiDoiTacVNN(string value)
    {
		string maDoiTac = "";
        if(value == "0" | value == null | value == "") {
			maDoiTac = "KH";
		}
		else if(value == "1") {
			maDoiTac = "NCC";
		}
		else if(value == "2") {
			maDoiTac = "NCCVT";
		}
		else if(value == "3") {
			maDoiTac = "NHH";
		}
		
        md_loaidtkd ldt = db.md_loaidtkds.FirstOrDefault(p => p.ma_loaidtkd.Equals(maDoiTac));
        return ldt;
    }

    public static md_quocgia getQuocGia(String maQuocGia)
    {
        md_quocgia qg = db.md_quocgias.FirstOrDefault(p => p.ma_quocgia.Equals(maQuocGia));
        return qg;
    }

    public static md_khuvuc getKhuVuc(String maKhuVuc)
    {
        md_khuvuc kv = db.md_khuvucs.FirstOrDefault(p => p.ma_khuvuc.Equals(maKhuVuc));
        return kv;
    }

    public static md_donvitinh getDonViTinh(String tenDonViTinh)
    {
        md_donvitinh dvt = db.md_donvitinhs.FirstOrDefault(p => p.ten_dvt.Equals(tenDonViTinh));
        return dvt;
    }

    public static md_trongluong getTrongLuong(String tenTrongLuong)
    {
        md_trongluong tl = db.md_trongluongs.FirstOrDefault(p => p.ten_trongluong.Equals(tenTrongLuong));
        return tl;
    }

    public static md_donggoi getDongGoi(String maDongGoi)
    {
        md_donggoi dg = db.md_donggois.FirstOrDefault(p => p.ma_donggoi.Equals(maDongGoi));
        return dg;
    }

    public static md_phienbangia getPhienBanGia(String tenPhienBan)
    {
        md_phienbangia pbg = db.md_phienbangias.FirstOrDefault(p => p.ten_phienbangia.Equals(tenPhienBan));
        return pbg;
    }


    public static md_kieudang getKieuDang(String maKieuDang)
    {
        md_kieudang kd = db.md_kieudangs.FirstOrDefault(p => p.ma_kieudang.Equals(maKieuDang));
        return kd;
    }

    public static  md_chucnang getChucNang(String maChucNang)
    {
        md_chucnang cn = db.md_chucnangs.FirstOrDefault(p => p.ma_chucnang.Equals(maChucNang));
        return cn;
    }

    public static md_doitackinhdoanh getNhaCungUng(String maNhaCungUng)
    {
        md_doitackinhdoanh dt = db.md_doitackinhdoanhs.FirstOrDefault(p => p.ma_dtkd.Equals(maNhaCungUng));
        return dt;
    }

    public static md_nhomnangluc getNhomNangLuc(String heHang, String maNhom)
    {
        md_nhomnangluc nnl = db.md_nhomnanglucs.FirstOrDefault(p => p.hehang.Equals(heHang) && p.nhom.Equals(maNhom));
        return nnl;
    }

    public static md_donvitinhsanpham getDonViTinhSanPham(String maDonViTinh)
    {
        md_donvitinhsanpham dvt = db.md_donvitinhsanphams.FirstOrDefault(p => p.ma_edi.Equals(maDonViTinh));
        return dvt;
    }

    public static md_detai getDeTai(String CodeDeTai, String CodeChungLoai)
    {
        md_detai dt = db.md_detais.FirstOrDefault(p => p.code_dt.Equals(CodeDeTai) && p.code_cl.Equals(CodeChungLoai));
        return dt;
    }

    public static md_banggia getBangGia(String tenBangGia)
    {
        md_banggia bg = db.md_banggias.FirstOrDefault(p => p.ten_banggia.Equals(tenBangGia));
        return bg;
    }

    public static md_donggoisanpham getDongGoiSanPham(String maDongGoi, String maSanPham)
    {
        md_donggoi dg = ImportUtils.getDongGoi(maDongGoi);
        md_sanpham sp = ImportUtils.getSanPham(maSanPham);
        if (dg == null || sp == null)
        {
            return null;
        }
        else
        {
            md_donggoisanpham dgsp = db.md_donggoisanphams.FirstOrDefault(p => p.md_donggoi_id.Equals(dg.md_donggoi_id) && p.md_sanpham_id.Equals(sp.md_sanpham_id));
            return dgsp;
        }
    }

    public static md_cangxuathang getCangXuatHang(String maSanPham, String maCangBien)
    {
        md_sanpham sp = ImportUtils.getSanPham(maSanPham);
        md_cangbien cb = ImportUtils.getCangBien(maCangBien);

        if (sp == null || cb == null)
        {
            return null;
        }
        else
        {
            md_cangxuathang cx = db.md_cangxuathangs.FirstOrDefault(
                    p => p.md_cangbien_id.Equals(cb.md_cangbien_id)
                    && p.md_sanpham_id.Equals(sp.md_sanpham_id)
                );
            return cx;
        }
    }

    public static md_bocai getBoCai(String code_bc)
    {
        md_bocai bc = db.md_bocais.FirstOrDefault(p => p.code_bc.Equals(code_bc));
        return bc;
    }

    public static md_giasanpham getGiaSanPham(String maPhienBanGia, String maSanPham)
    {
        md_sanpham sp = ImportUtils.getSanPham(maSanPham);
        md_phienbangia pbg = ImportUtils.getPhienBanGia(maPhienBanGia);
        if (sp == null || pbg == null)
        {
            return null;
        }
        else
        {
            md_giasanpham gsp = db.md_giasanphams.FirstOrDefault(p => p.md_phienbangia_id.Equals(pbg.md_phienbangia_id) && p.md_sanpham_id.Equals(sp.md_sanpham_id));
            return gsp;
        }
    }

    public static md_hanghoadocquyen getHangHoaDocQuyen(String maSanPham, String maKhachHang)
    {
        md_sanpham sp = ImportUtils.getSanPham(maSanPham);
        md_doitackinhdoanh dtkd = ImportUtils.getDoiTac(maKhachHang);
        if (sp == null || dtkd == null)
        {
            return null;
        }
        else
        {
            md_hanghoadocquyen hhdq = db.md_hanghoadocquyens.FirstOrDefault(p => p.md_sanpham_id.Equals(sp.md_sanpham_id) && p.md_doitackinhdoanh_id.Equals(dtkd.md_doitackinhdoanh_id));
            return hhdq;
        }
    }

    public static md_mausac getMauSac(String CodeMauSac, String CodeChungLoai, String CodeDeTai)
    {
        md_mausac ms = db.md_mausacs.FirstOrDefault(p => p.code_mau.Equals(CodeMauSac) && p.code_dt.Equals(CodeDeTai) && p.code_cl.Equals(CodeChungLoai));
        return ms;
    }

    public static md_phukien getPhuKien(String CodePK, String CodeChungLoai, String CodeDeTai)
    {
        md_phukien ms = db.md_phukiens.FirstOrDefault(p => p.code_pk.Equals(CodePK) && p.code_dt.Equals(CodeDeTai) && p.code_cl.Equals(CodeChungLoai));
        return ms;
    }

    public static md_hscode getHSCode(String maHsCode)
    {
        md_hscode hs = db.md_hscodes.FirstOrDefault(p => p.ma_hscode.Equals(maHsCode));
        return hs;
    }

    public static md_nhacungungmacdinh getNhaCungUngMacDinh(String md_sanpham_id, String md_doitackinhdoanh_id)
    {
        md_nhacungungmacdinh n = db.md_nhacungungmacdinhs.FirstOrDefault(p => p.md_sanpham_id.Equals(md_sanpham_id) && p.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id));
        return n;
    }
}
