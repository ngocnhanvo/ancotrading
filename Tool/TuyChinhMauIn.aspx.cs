using System;
using System.Linq;
using System.Web.UI.WebControls;
using System.Data;
using Newtonsoft.Json;
using System.Collections.Generic;
public partial class Tool_TuyChinhMauIn : System.Web.UI.Page
{
    public string optionsMauIn = "";
    public bool send = false;
    protected void Page_Load(object sender, EventArgs e)
    {
        var config = new ExportExcel();
        var jsons = config.getJsonInfoCHSTP();
        send = Request.Form["send"] == "true";
        var name = Request.Form["name"];
        var fontSize = Request.Form["fontSize"];
        if (send)
        {
            string msg = "";
            try
            {
                var json = jsons.Where(s => s["name"].ToString() == name).FirstOrDefault();
                json["fontSize"] = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(fontSize);

                config.writeJsonInfoCHSTP(JsonConvert.SerializeObject(jsons, Formatting.Indented));
            }
            catch(Exception ex)
            {
                msg = ex.Message;
            }
        }
        else
        {
            var selectRpt = jsons.Select(s =>
                string.Format("<option ktc='{2}' value='{0}'>{1}</option>",
                    s["name"].ToString(),
                    s["text"].ToString(),
                    s["fontSize"].ToString()
                )
            ).ToList();
            selectRpt.Insert(0, "<option selected disabled></option>");
            optionsMauIn = string.Format("<select id='selectRpt'>{0}</select>", string.Join("", selectRpt));
        }
    }
}
