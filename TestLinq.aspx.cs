using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.Linq;



public partial class TestLinq : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //String tien = Currency.VndToString("9999999999");
        //Context.Response.Write(tien);
        
        md_dongtien dt = ImportUtils.getDongTien("VaD");
        Response.Write(dt == null);
    }
}
