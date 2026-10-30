using System;
using System.Configuration;
using System.Web;
using System.Web.UI;

public partial class Views_phanbococpo_phanbococpo : UserControl
{
    protected string AllocationToken { get; private set; }
    protected bool SaveEnabled { get; private set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        // The HTTP handler checks both this session-bound token and server flag.
        SaveEnabled = String.Equals(
            ConfigurationManager.AppSettings["EnablePOAllocationDraftSave"],
            "true", StringComparison.OrdinalIgnoreCase);
        if (Session["anco_po_allocation_csrf"] == null)
            Session["anco_po_allocation_csrf"] = Guid.NewGuid().ToString("N");
        AllocationToken = Convert.ToString(Session["anco_po_allocation_csrf"]);
    }
}
