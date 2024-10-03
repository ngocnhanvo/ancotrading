using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class inc_ds_dathang : System.Web.UI.Page
{
    public string js = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        js = System.IO.File.ReadAllText(ExcuteSignalRStatic.mapPathSignalR("~/Scripts/aspx.js/inc-ds-dathang.js"));
    }
}
