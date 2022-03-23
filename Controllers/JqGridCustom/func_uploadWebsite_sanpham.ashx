<%@ WebHandler Language="C#" Class="func_uploadWebsite_sanpham" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using Newtonsoft.Json;

public class func_uploadWebsite_sanpham : IHttpHandler {

    public class jsonDataRow
    {
        public string md_sanpham_id { get; set; }
        public string ma_sanpham { get; set; }
        public string mota_tiengviet { get; set; }
    }

    public class jsonData
    {
        public int total { get; set; }
        public int page { get; set; }
        public int records { get; set; }
        public List<jsonDataRow> rows { get; set; }
    }

    public void ProcessRequest(HttpContext context)
    {
        string id = context.Request.Params["id"];
        string filter = Helper.getFilter(context);
        string searchTerm = context.Request.Params["searchTerm"];

        if (!string.IsNullOrWhiteSpace(searchTerm))
            filter += string.Format(" and sp.ma_sanpham LIKE N'{1}{0}{1}'", searchTerm, searchTerm.Contains("%") ? "" : "%");

        int page = Helper.getPage(context);
        int limit = int.Parse(context.Request.Params["rows"]);
        int start, end;
        start = limit * page - limit;
        end = (page * limit) + 1;

        string fromSQL = string.Format(@"
            from md_sanpham sp
            where 1=1 and sp.trangthai='DHD' and isnull(sp.website, 0) = 0 {0}
        ", filter);

        string sql = string.Format(@"
            declare @start int = {1}, @end int = {2};
            select A.*
            from (
                select 
                    sp.md_sanpham_id,
                    sp.ma_sanpham,
                    sp.mota_tiengviet,
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

        var lstYCGH = new jsonData();
        lstYCGH.total = totalPage;
        lstYCGH.page = page;
        lstYCGH.records = count.GetValueOrDefault(0);
        lstYCGH.rows = new List<jsonDataRow>();
        foreach (DataRow row in tbl.Rows)
        {
            var jsrow = new jsonDataRow();
            foreach (var propertyInfo in jsrow.GetType().GetProperties())
            {
                var data = row[propertyInfo.Name];
                if (data != DBNull.Value)
                    propertyInfo.SetValue(jsrow, data);
            }

            lstYCGH.rows.Add(jsrow);
        }

        context.Response.Write(JsonConvert.SerializeObject(lstYCGH));
    }


    public bool IsReusable
    {
        get { return false; }
    }
}