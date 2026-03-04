using System.Collections.Generic;
using System.Linq;

public static class trg_c_baogia
{
    public static string load(LinqDBDataContext db, List<c_baogia> dhs, bool update = false)
    {
        string msg = "";
        var chungTu = db.md_sochungtus.FirstOrDefault(s =>
            db.md_loaichungtus.Any(l => l.md_loaichungtu_id == s.md_loaichungtu_id && l.kieu_doituong == "QO")
        );

        foreach (var dh in dhs)
        {
            if (chungTu != null)
                chungTu.so_duocgan = chungTu.so_duocgan.GetValueOrDefault(0) + chungTu.buocnhay.GetValueOrDefault(1);
        }

        if (update)
            db.SubmitChanges();
        return msg;
    }
}
