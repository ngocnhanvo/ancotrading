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

public partial class Views_hosochungtu_master : System.Web.UI.UserControl
{
    public string nccsStr = "[]";
    protected void Page_Load(object sender, EventArgs e)
    {
        var db = new LinqDBDataContext();
        var nccs = from a in db.md_doitackinhdoanhs
                   join b in db.md_loaidtkds on a.md_loaidtkd_id equals b.md_loaidtkd_id
                   where b.ma_loaidtkd == Helper.NCC & a.hoatdong == true
                   orderby a.ma_dtkd
                   select a.ma_dtkd;
        nccsStr = $"['{string.Join("','", nccs.ToList())}']";
    }
}
