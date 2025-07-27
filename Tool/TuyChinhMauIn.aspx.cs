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
    public ExportExcel config = new ExportExcel();

    public string loadOptions(List<Dictionary<string, object>> jsons)
    {
        if(jsons == null)
            jsons = config.getJsonInfoCHSTP();

        var selectRpt = jsons.Select(s =>
                    string.Format("<option ktc='{2}' stps='{3}' value='{0}'>{1}</option>",
                        s["name"].ToString(),
                        s["text"].ToString(),
                        s["fontSize"].ToString(),
                        s["soThapPhan"].ToString().Replace("'", "\\'")
                    )
                ).ToList();
        selectRpt.Insert(0, "<option selected disabled></option>");
       return string.Join("", selectRpt);
    }
    protected void Page_Load(object sender, EventArgs e)
    {    
        var jsons = config.getJsonInfoCHSTP();
        send = Request.Form["send"] == "true";
        var name = Request.Form["name"];
        var fontSize = Request.Form["fontSize"];
        var dtkd = Request.Form["dtkd"];
        var soThapPhan = Request.Form["soThapPhan"];

        if (send)
        {
            string msg = "";
            try
            {
                var json = jsons.Where(s => s["name"].ToString() == name).FirstOrDefault();
                json["fontSize"] = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(fontSize);

                var soThapPhanJson = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(json["soThapPhan"].ToString());
                var soThapPhanJsonSet = JsonConvert.DeserializeObject<Dictionary<string, object>>(soThapPhan);
                if (string.IsNullOrEmpty(dtkd))
                {
                    soThapPhanJson[0]["soluong"] = soThapPhanJsonSet["soluong"];
                    soThapPhanJson[0]["cbm"] = soThapPhanJsonSet["cbm"];
                    soThapPhanJson[0]["discount"] = soThapPhanJsonSet["discount"];
                    soThapPhanJson[0]["amount"] = soThapPhanJsonSet["amount"];
                    json["soThapPhan"] = soThapPhanJson;
                }
                else
                {
                    var soThapPhanJsonDTKDs = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(soThapPhanJson[0]["dtkd"].ToString());

                    var soThapPhanJsonDTKD = soThapPhanJsonDTKDs.Where(s => s["name"].ToString() == dtkd).FirstOrDefault();

                    if(soThapPhanJsonDTKD != null)
                    {
                        soThapPhanJsonDTKD["soluong"] = soThapPhanJsonSet["soluong"];
                        soThapPhanJsonDTKD["cbm"] = soThapPhanJsonSet["cbm"];
                        soThapPhanJsonDTKD["discount"] = soThapPhanJsonSet["discount"];
                        soThapPhanJsonDTKD["amount"] = soThapPhanJsonSet["amount"];
                        soThapPhanJson[0]["dtkd"] = soThapPhanJsonDTKDs;

                        Response.Write(JsonConvert.SerializeObject(soThapPhanJson));
                        json["soThapPhan"] = soThapPhanJson;
                    }
                }
                config.writeJsonInfoCHSTP(JsonConvert.SerializeObject(jsons, Formatting.Indented));

                Response.Write(loadOptions(null));
            }
            catch(Exception ex)
            {
                msg = ex.Message;
            }
        }
        else
        {
            optionsMauIn = string.Format("<select id='selectRpt'>{0}</select>", loadOptions(jsons));
        }
    }
}
