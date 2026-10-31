using System;
using System.Web;
using System.Web.UI;

public partial class Views_phanbococpo_phanbococpo : UserControl
{
    protected string AllocationToken { get; private set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        // The HTTP handler validates this session-bound token on every save.
        if (Session["anco_po_allocation_csrf"] == null)
            Session["anco_po_allocation_csrf"] = Guid.NewGuid().ToString("N");
        AllocationToken = Convert.ToString(Session["anco_po_allocation_csrf"]);
    }
}
