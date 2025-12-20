using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class inc_po : System.Web.UI.Page
{
    public string nvctsStr = "':'";
    protected void Page_Load(object sender, EventArgs e)
    {
        using (var db = new LinqDBDataContext())
        {
            nvctsStr = Helper.selectoption_NhanVienChungTu(db);
        }
    }
}
