<%@ WebHandler Language="C#" Class="format_tool_taogiabo_phienbangia" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using Newtonsoft.Json;

public class format_tool_taogiabo_phienbangia : IHttpHandler {
    public class ItemMaster
    {
        public string md_giasanpham_id { get; set; }
        public string md_phienbangia_id { get; set; }
        public string ma_sanpham { get; set; }
        public decimal? gia { get; set; }
        public decimal? phi { get; set; }
        public decimal? tongGia { get; set; }
        public string mota { get; set; }
    }

    public class jsonData
    {
        public int total { get; set; }
        public int page { get; set; }
        public int records { get; set; }
        public List<ItemMaster> rows { get; set; }
    }


    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        var lstYCGH = new jsonData();
        var pbgId = context.Request.QueryString["pbgId"];
        if (string.IsNullOrWhiteSpace(pbgId))
            goto end;

        var searchTerm = context.Request.QueryString["searchTemp"];
        string filter = Helper.getFilter(context);
        if (!string.IsNullOrWhiteSpace(searchTerm))
            filter += string.Format(" and sp.ma_sanpham LIKE N'{1}{0}{1}'", searchTerm, searchTerm.Contains("%") ? "" : "%");

        int page = Helper.getPage(context);
        int limit = int.Parse(context.Request.Params["rows"]);
        int start, end;
        start = limit * page - limit;
        end = (page * limit) + 1;

        string fromSQL = string.Format(@"
            from md_giasanpham gsp
                left join md_sanpham sp on gsp.md_sanpham_id = sp.md_sanpham_id
            where gsp.md_phienbangia_id = '{1}' and isnull(sp.ma_sanpham,'') != '' {0}
        ", filter, pbgId);

        string sql = string.Format(@"
            declare @start int = {1}, @end int = {2};
            
            select A.*
            from (
                select
                    gsp.md_giasanpham_id,
                    gsp.md_phienbangia_id,
                    sp.ma_sanpham,
                    gsp.gia,
                    gsp.phi,
                    isnull(gsp.gia, 0) + isnull(gsp.phi, 0) as tongGia,
                    gsp.mota,
                    ROW_NUMBER() OVER (ORDER BY sp.ma_sanpham asc) as rowNum
                {0}
            ) A
            where A.rowNum > @start and A.rowNum < @end
            order by A.rowNum
        ", fromSQL, start, end);

        var count = (int?)mdbc.ExecuteScalar(string.Format("select count(1) {0}", fromSQL));
        var tbl = mdbc.GetData(sql);

        int totalPage = 0;
        if (count.GetValueOrDefault(0) > 0)
        {
            totalPage = (int)Math.Ceiling(1.0 * count.Value / limit);
        }

        lstYCGH.total = totalPage;
        lstYCGH.page = page;
        lstYCGH.records = count.GetValueOrDefault(0);
        lstYCGH.rows = new List<ItemMaster>();
        foreach (DataRow row in tbl.Rows)
        {
            var jsrow = new ItemMaster();
            foreach (var propertyInfo in jsrow.GetType().GetProperties())
            {
                var data = row[propertyInfo.Name];
                if (data != DBNull.Value)
                    propertyInfo.SetValue(jsrow, data);
            }

            lstYCGH.rows.Add(jsrow);
        }

        end:;
        context.Response.Write(JsonConvert.SerializeObject(lstYCGH));
    }

    public bool IsReusable
    {
        get { return false; }
    }
}