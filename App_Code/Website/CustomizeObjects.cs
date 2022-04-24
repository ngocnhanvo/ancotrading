using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
/// <summary>
/// Summary description for ObjectsCustom
/// </summary>
public class CustomizeObjects
{
    public class ObjItemLi
    {
        public string href { get; set; }
        public string text { get; set; }
        public string image { get; set; }
        public string image2 { get; set; }
        public string dactinh { get; set; }
        public string tieude { get; set; }
        public string tieudedai { get; set; }
        public string activeClass { get; set; }
        public List<ObjItemLi> menuChild { get; set; }
    }

    public static List<ObjItemLi> getMenuProductsWeb()
    {
        string url = ExcuteSignalRStatic.mapPathSignalR("~/App_Data/MenuProductWeb.json");
        string json = System.IO.File.ReadAllText(url);
        
        var menuPL0 = new List<ObjItemLi>();

        var json_res = JsonConvert.DeserializeObject<List<Dictionary<string,object>>>(json);
        
        if (json_res.Count > 0)
        {
            var menu0 = json_res.Where(s => s["parent"].ToString() == "notSelectNode").ToList();

            foreach (var rowMenu0 in menu0)
            {
                var A_attr0 = JsonConvert.DeserializeObject<Dictionary<string, object>>(rowMenu0["a_attr"].ToString());
                string active = "";
                var itemMN0 = new ObjItemLi() { href = A_attr0["href"].ToString(), text = rowMenu0["text"].ToString(), activeClass = active, menuChild = new List<ObjItemLi>() };

                var menu1 = json_res.Where(s => s["parent"].ToString() == rowMenu0["id"].ToString()).ToList();
                if (menu1.Count > 0)
                {
                    foreach (var rowMenu1 in menu1)
                    {
                        var A_attr1 = JsonConvert.DeserializeObject<Dictionary<string, object>>(rowMenu1["a_attr"].ToString());

                        var itemMN1 = new ObjItemLi() { href = A_attr1["href"].ToString(), text = rowMenu1["text"].ToString(), activeClass = "", menuChild = new List<ObjItemLi>() };

                        var menu2 = json_res.Where(s => s["parent"].ToString() == rowMenu1["id"].ToString()).ToList();
                        if (menu2.Count > 0)
                        {
                            foreach (var rowMenu2 in menu2)
                            {
                                var A_attr2 = JsonConvert.DeserializeObject<Dictionary<string, object>>(rowMenu2["a_attr"].ToString());
                                var itemMN2 = new ObjItemLi();

                                itemMN2.href = A_attr2["href"].ToString();
                                itemMN2.text = rowMenu2["text"].ToString();

                                if (A_attr2.ContainsKey("dactinh"))
                                    itemMN2.dactinh = A_attr2["dactinh"].ToString();

                                if (A_attr2.ContainsKey("tieude"))
                                    itemMN2.tieude = A_attr2["tieude"].ToString();

                                if (A_attr2.ContainsKey("tieudedai"))
                                    itemMN2.tieudedai = A_attr2["tieudedai"].ToString();

                                itemMN2.activeClass = "";
                                itemMN2.menuChild = new List<ObjItemLi>();
                                itemMN1.menuChild.Add(itemMN2);
                            }
                        }

                        itemMN0.menuChild.Add(itemMN1);
                    }
                }

                menuPL0.Add(itemMN0);
            }

            menuPL0 = menuPL0.Where(s => s.href == "#products").Select(s => s.menuChild).FirstOrDefault();
        }

        return menuPL0;
    }

    public CustomizeObjects()
    {
        //
        // TODO: Add constructor logic here
        //
    }
}