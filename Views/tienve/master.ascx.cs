using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;

public partial class Views_tienve_master : System.Web.UI.UserControl
{
    public string tienve_value_dtkd = "";
    private LinqDBDataContext db = new LinqDBDataContext();
    protected void Page_Load(object sender, EventArgs e)
    {
        string value = "{0}:{1};", kq = "";
        var khs = from a in db.md_doitackinhdoanhs
                  join b in db.md_loaidtkds on a.md_loaidtkd_id equals b.md_loaidtkd_id
                  where a.hoatdong == true & b.ma_loaidtkd == "KH"
                  orderby a.ma_dtkd ascending
                  select a;

        foreach (var kh in khs)
        {
            kq += string.Format(value, kh.md_doitackinhdoanh_id, kh.ma_dtkd);
        }
        tienve_value_dtkd = kq.Substring(0, kq.Length - 2);
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
    }
}
