<%@ WebHandler Language="C#" Class="UploadFile" %>

using System;
using System.Web;
using System.Linq;
using System.Data.Linq;

public class UploadFile : IHttpHandler {
    LinqDBDataContext db = new LinqDBDataContext();
    
    public void ProcessRequest (HttpContext context) {

        if (context.Request.Files.Count != 0)
        {
            HttpFileCollection files = context.Request.Files;
            for (int i = 1; i <= files.Count; i++)
            {
                String fileName = files[i - 1].FileName;
				String filterName="";
				try
				{
					if (fileName.ElementAt(9).ToString().ToLower().Equals("f"))
					{
						filterName = fileName.Substring(0, 11);		
					}
					else
					{
						filterName = fileName.Substring(0, 8);	
					}
                }
				catch
				{
					filterName = fileName.Substring(0, 8);
				}
                files[i - 1].SaveAs(context.Server.MapPath("../images/products/fullsize/" + files[i - 1].FileName));
                md_anhsanpham asp = db.md_anhsanphams.FirstOrDefault(p => p.url.Equals(filterName) && p.filter.Equals(filterName));

                if (asp == null)
                {
                    md_anhsanpham img = new md_anhsanpham();
                    img.md_anhsanpham_id = ImportUtils.getNEWID();
                    img.url = fileName;
                    img.filter = filterName;
                    img.ngaytao = DateTime.Now;
                    img.ngaycapnhat = DateTime.Now;
                    img.hoatdong = true;

                    db.md_anhsanphams.InsertOnSubmit(img);
                    db.SubmitChanges();
                }
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}