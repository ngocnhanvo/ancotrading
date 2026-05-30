<%@ WebHandler Language="C#" Class="DongGoiController" %>

using System;
using System.Web;
using System.Data;

public class DongGoiController : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string action = context.Request.QueryString["action"];

        switch (action)
        {
            case "getoption":
                this.getSelectOption(context);
                break;

            default:
                context.Response.Write("");
                break;
        }
    }

    public void getSelectOption(HttpContext context)
    {
        context.Response.ContentType = "text/html";
        context.Response.Charset = "UTF-8";

        string md_sanpham_id = context.Request.QueryString["md_sanpham_id"];
        string ma_sanpham = context.Request.QueryString["ma_sanpham"];

        string sql = "";

        if (!string.IsNullOrEmpty(md_sanpham_id))
        {
            sql = @"
            SELECT 
                dg.md_donggoi_id,
                dg.ten_donggoi,
                dg.ma_donggoi,
                ISNULL(dgsp.macdinh, 0) AS macdinh
            FROM md_donggoisanpham dgsp
            INNER JOIN md_donggoi dg 
                ON dgsp.md_donggoi_id = dg.md_donggoi_id
            WHERE dgsp.md_sanpham_id = @md_sanpham_id
              AND ISNULL(dgsp.hoatdong, 1) = 1
              AND ISNULL(dg.hoatdong, 1) = 1
            ORDER BY ISNULL(dgsp.macdinh, 0) DESC, dg.ten_donggoi ASC
        ";

            DataTable dt = mdbc.GetData(sql, "@md_sanpham_id", md_sanpham_id);
            context.Response.Write(BuildOptionHtml(dt));
        }
        else if (!string.IsNullOrEmpty(ma_sanpham))
        {
            sql = @"
            SELECT 
                dg.md_donggoi_id,
                dg.ten_donggoi,
                dg.ma_donggoi,
                ISNULL(dgsp.macdinh, 0) AS macdinh
            FROM md_sanpham sp
            INNER JOIN md_donggoisanpham dgsp 
                ON sp.md_sanpham_id = dgsp.md_sanpham_id
            INNER JOIN md_donggoi dg 
                ON dgsp.md_donggoi_id = dg.md_donggoi_id
            WHERE sp.ma_sanpham = @ma_sanpham
              AND ISNULL(dgsp.hoatdong, 1) = 1
              AND ISNULL(dg.hoatdong, 1) = 1
            ORDER BY ISNULL(dgsp.macdinh, 0) DESC, dg.ten_donggoi ASC
        ";

            DataTable dt = mdbc.GetData(sql, "@ma_sanpham", ma_sanpham);
            context.Response.Write(BuildOptionHtml(dt));
        }
        else
        {
            context.Response.Write("<option value=''>Vui lòng chọn sản phẩm</option>");
        }
    }

    private string BuildOptionHtml(DataTable dt)
    {
        string html = "";

        foreach (DataRow row in dt.Rows)
        {
            string selected = "";

            if (dt.Columns.Contains("macdinh"))
            {
                string macdinh = row["macdinh"].ToString().ToLower();
                selected = macdinh == "true" || macdinh == "1"
                    ? " selected='selected'"
                    : "";
            }
            html += "<option value='" + row["ma_donggoi"] + "'" + selected + ">"
                    + row["ten_donggoi"] + " - " + row["ma_donggoi"]
                    + "</option>";
            //html += "<option value='" + row["md_donggoi_id"] + "'" + selected + ">"
            //     + row["ten_donggoi"] + " - " + row["ma_donggoi"]
            //     + "</option>";
        }

        if (html == "")
        {
            html = "<option value=''>Không có đóng gói</option>";
        }

        return html;
    }

    public bool IsReusable
    {
        get { return false; }
    }
}