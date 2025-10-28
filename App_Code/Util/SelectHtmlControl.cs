using System;
using System.Collections.Generic;
using System.Web;
using System.Data;

public class SelectHtmlControl
{
    private String _sql;

    public String Sql
    {
        get { return _sql; }
        set { _sql = value; }
    }

    public SelectHtmlControl()
    { }

    public SelectHtmlControl(String sql)
    {
        _sql = sql;
    }
    public string ToOptionList()
    {
        DataTable dt = mdbc.GetData(_sql);
        String str = "";
        if (dt.Rows.Count != 0)
        {

            foreach (DataRow item in dt.Rows)
            {
                str += string.Format("<option value=\"{0}\">{1}</option>", item[0], item[1]);
            }
        }
        else
        {
            str = "null";
        }
        return str;
    }

    public string ToOptionSearch()
    {
        DataTable dt = mdbc.GetData(_sql);
        String str = "";
        if (dt.Rows.Count != 0)
        {
            str += "<select>";
            str += "<option value=\"[ALL]\">[ALL]</option>";
            foreach (DataRow item in dt.Rows)
            {
                str += string.Format("<option value=\"{0}\">{1}</option>", item[0], item[1]);
            }
            str += "</select>";
        }
        else
        {
            str = "null";
        }
        return str;
    }

    public string ToOptionNullFirst()
    {
        DataTable dt = mdbc.GetData(_sql);
        String str = "";
        if (dt.Rows.Count != 0)
        {
            str += "<select>";
            str += "<option value=\"\"></option>";
            foreach (DataRow item in dt.Rows)
            {
                str += string.Format("<option value=\"{0}\">{1}</option>", item[0], item[1]);
            }
            str += "</select>";
        }
        else
        {
            str = "null";
        }
        return str;
    }


    public override string ToString()
    {
        DataTable dt = mdbc.GetData(_sql);
        String str = "<select>";
        foreach (DataRow item in dt.Rows)
        {
            str += string.Format("<option value=\"{0}\">{1}</option>", item[0], item[1]);
        }
        str += "</select>";
        return str;
    }

    public string ToSelected(String id)
    {
        DataTable dt = mdbc.GetData(_sql);
        String str = "<select>";
        foreach (DataRow item in dt.Rows)
        {
			string other_str = "", cpdg = "";
			
			try {
				other_str = item[2].ToString();
			}
			catch { }

            try
            {
                cpdg = item[3].ToString();
            }
            catch { }

            string selected = "";
            if (item[0].ToString().Equals(id))
            {
                selected = "selected";
            }

            str += $@"<option other=""{other_str}"" cpdg=""{cpdg}"" {selected} value=""{item[0]}"">{item[1]}</option>";
        }
        str += "</select>";
        return str;
    }

    public string ToDongGoiSelected(String id)
    {
        DataTable dt = mdbc.GetData(_sql);
        String str = "<select>";
        foreach (DataRow item in dt.Rows)
        {
            string dg_id = item[0].ToString();
            string dg_ma = item[1].ToString();
            string dg_sli = item[2].ToString();
            string dg_dvi = item[3].ToString();
            string dg_slo = item[4].ToString();
            string dg_dvo = item[5].ToString();
            string dg_ten = item[6].ToString();
            string dg_dgia = item[7].ToString();
            string dg_cpdg = item[8].ToString();
            string dg_mota = item[9].ToString();

            string selected = "";
            if (dg_id.Equals(id))
            {
                selected = "selected";
            }

            string text = $"{dg_ma} ({dg_sli} {dg_dvi} // {dg_slo} {dg_dvo})";
            str += $@"<option other=""{dg_dgia}"" cpdg=""{dg_cpdg}"" mtdg=""{dg_mota}"" {selected} value=""{dg_id}"">{text}</option>";
        }
        str += "</select>";
        return str;
    }
}
