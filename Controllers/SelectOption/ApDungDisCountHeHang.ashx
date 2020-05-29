<%@ WebHandler Language="C#" Class="ApDungDisCountHeHang" %>

using System.Collections.Generic;
using System.Web;
using System.Data;
using Newtonsoft.Json;

public class ApDungDisCountHeHang : IHttpHandler
{

    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        string oper = context.Request.QueryString["action"];
        switch (oper)
        {
            case "DiscountHH":
                this.load(context);
                break;
        }
    }

    public void load(HttpContext context)
    {
        string id = context.Request.QueryString["c_donhang_id"];
        var hh_ddh = string.Format(@"
            select cl.code_cl
            from c_dongdonhang ddh 
            left join md_sanpham sp on sp.md_sanpham_id = ddh.md_sanpham_id
            left join md_chungloai cl on cl.md_chungloai_id = sp.md_chungloai_id
            where ddh.c_donhang_id = '{0}'
            group by cl.code_cl
        ", id);

        var dt = mdbc.GetData(hh_ddh);
        var tbl = new List<Dictionary<string, object>>();
        foreach(DataRow row in dt.Rows)
        {
            tbl.Add(new Dictionary<string, object>()
            {
                { "hehang", row["code_cl"] },
                { "giatri", "0" }
            });
        }
        context.Response.Write(JsonConvert.SerializeObject(tbl));
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
