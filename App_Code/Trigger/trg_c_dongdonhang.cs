using System.Collections.Generic;
using System.Linq;

public static class trg_c_dongdonhang
{
    public static string load(LinqDBDataContext db, List<c_dongdonhang> dhs, bool update = false)
    {
        string msg = "";
        // Lấy danh sách ID sản phẩm cần dùng
        var spIds = dhs.Where(d => d.md_sanpham_id != null).Select(d => d.md_sanpham_id).Distinct().ToList();

        // Truy vấn 1 lần duy nhất vào DB và lưu vào Dictionary để tra cứu nhanh
        var dictSp = db.md_sanphams
        .Where(s => spIds.Contains(s.md_sanpham_id))
        .ToDictionary(s => s.md_sanpham_id, s => s);

        foreach (var dh in dhs)
        {
            md_sanpham sp = null;
            if (dictSp.TryGetValue(dh.md_sanpham_id, out sp))
            {
                if (dh.sl_outer.GetValueOrDefault(0) == 0)
                {
                    dh.v2 = 0;
                }
                else
                {
                    decimal l = dh.l2.GetValueOrDefault(0);
                    decimal h = dh.h2.GetValueOrDefault(0);
                    decimal w = dh.w2.GetValueOrDefault(0);
                    decimal sl = dh.soluong.GetValueOrDefault(0);
                    decimal slo = dh.sl_outer.GetValueOrDefault(0);

                    decimal volume = (l * h * w * sl) / (slo * 1000000m);
                    dh.v2 = System.Math.Round(volume, 3, System.MidpointRounding.AwayFromZero);
                }
                if (!string.IsNullOrEmpty(sp.ma_sanpham))
                {
                    dh.code_cl = sp.ma_sanpham.Length >= 2
                                 ? sp.ma_sanpham.Substring(0, 2)
                                 : sp.ma_sanpham;
                }
                dh.md_chungloai_id = sp.md_chungloai_id;
            }
        }

        if (update)
            db.SubmitChanges();
        return msg;
    }
}
