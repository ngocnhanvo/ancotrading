using System.Collections.Generic;
using System.Linq;

public static class trg_c_donhang
{
    public static string load(LinqDBDataContext db, List<c_donhang> dhs, bool update = false)
    {
        string msg = "";
        var chungTu = db.md_sochungtus.FirstOrDefault(s =>
            db.md_loaichungtus.Any(l => l.md_loaichungtu_id == s.md_loaichungtu_id && l.kieu_doituong == "PO")
        );
        foreach (var dh in dhs)
        {
            decimal amount = dh.amount.GetValueOrDefault(0);
            decimal discount = dh.discount.GetValueOrDefault(0);
            dh.totalamount = amount - amount * discount / 100;

            if (chungTu != null)
                chungTu.so_duocgan = chungTu.so_duocgan.GetValueOrDefault(0) + chungTu.buocnhay.GetValueOrDefault(1);
        }

        if (update)
            db.SubmitChanges();
        return msg;
    }
}
