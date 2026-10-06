<%@ WebHandler Language="C#" Class="UploadFileWeb" %>

using System;
using System.Web;
using System.Linq;
using System.Text.RegularExpressions;

public class UploadFileWeb : IHttpHandler
{
    LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {

        if (context.Request.Files.Count != 0)
        {
            HttpFileCollection files = context.Request.Files;
            for (int i = 1; i <= files.Count; i++)
            {
                string fileName = files[i - 1].FileName;
                string filterName = fileName.Substring(0, fileName.LastIndexOf("."));
                string jpg = fileName.Substring(fileName.LastIndexOf("."));

                var rgxMauSac2 = new Regex("^[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9]$");
                var rgxMauSac3 = new Regex("^[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9]-F[0-9]-[0-9][0-9]$");
                var rgxMauSac4 = new Regex("^[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9]-G[0-9]-[0-9][0-9]$");
                var rgxNexxVariant = new Regex("^[0-9]{2}-[0-9]{5}-[A-Z]{2}-[0-9]{2}$", RegexOptions.IgnoreCase);

                string nexxVariant = filterName.Length >= 11 ? filterName.Substring(9, 2).ToUpperInvariant() : "";
                bool isNexxVariant = rgxNexxVariant.IsMatch(filterName)
                    && nexxVariant.IndexOfAny(new char[] { 'S', 'B', 'L', 'X', 'F', 'G' }) < 0;

                if (rgxMauSac2.IsMatch(filterName) | rgxMauSac3.IsMatch(filterName) | rgxMauSac4.IsMatch(filterName) | isNexxVariant)
                {
                    files[i - 1].SaveAs(Public.imgWebsites + files[i - 1].FileName);
                    context.Response.Write(Public.imgWebsites + files[i - 1].FileName);
                }
                else
                {
                    context.Response.Write("Tên hình ảnh sai quy cách." + filterName);
                }
            }
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}