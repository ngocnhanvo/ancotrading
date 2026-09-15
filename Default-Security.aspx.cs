using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Default_Security : System.Web.UI.Page
{
    public string script { get; set; }
    protected void Page_Load(object sender, EventArgs e)
    {
        var d = new DirectoryInfo(ExcuteSignalRStatic.mapPathSignalR("~/Scripts/Custom_Grid_script"));
        FileInfo[] Files = d.GetFiles("*.js");
        foreach (FileInfo file in Files)
        {
            string srcD_text = string.Format("Scripts/Custom_Grid_script/" + file.Name);
            string srcD_link = string.Format(srcD_text + "?ver=" + Guid.NewGuid());

            script += string.Format(@"<script src=""{0}"" type=""text/javascript""></script>{1}", srcD_link, Environment.NewLine);
        }

        // UI demo only: keep the production shell untouched and layer the
        // Modern Classic behavior/theme from the demogiaodien branch.
        script += string.Format(@"<script src=""theme/demogiaodien/modern-classic.js?ver={0}"" type=""text/javascript""></script>{1}", Guid.NewGuid(), Environment.NewLine);
        script += string.Format(@"<script src=""theme/demogiaodien/po-layout-fix.js?ver={0}"" type=""text/javascript""></script>{1}", Guid.NewGuid(), Environment.NewLine);
    }
}
