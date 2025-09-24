using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Linq;

public partial class Views_tienve_tienvenganhang : System.Web.UI.UserControl
{
    public decimal tygia = 23000;
    private LinqDBDataContext db = new LinqDBDataContext();
    protected void Page_Load(object sender, EventArgs e)
    {
        var tg = db.md_tygias.Where(s => s.hieuluc_tungay <= DateTime.Now & s.hieuluc_denngay >= DateTime.Now).OrderByDescending(s => s.ngaytao).FirstOrDefault();
        tygia = tg == null ? tygia : tg.chia_cho.GetValueOrDefault(0);
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
    }
}
