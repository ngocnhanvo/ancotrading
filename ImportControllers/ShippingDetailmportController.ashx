<%@ WebHandler Language="C#" Class="ShippingDetailmportController" %>

using System;
using System.Web;
using ExcelLibrary.SpreadSheet;
using ExcelLibrary;

public class ShippingDetailmportController : IHttpHandler
{

    public void ProcessRequest (HttpContext context) {
        String filename = context.Request.QueryString["filename"];
        String file = context.Server.MapPath("../FileUpload/" + filename);
        int j = file.LastIndexOf(".");
        if(file.Substring(j) != ".xls") {
            file = ConvertXLSXToXLS.ConvertWorkbookXSSFToHSSF(file);
        }
        Workbook wb = Workbook.Load(file);
        Worksheet ws = wb.Worksheets[0];
        if (System.IO.File.Exists(file))
            System.IO.File.Delete(file);
        this.NewFromCellCollection(context, ws.Cells);
    }

    public void NewFromCellCollection(HttpContext context, CellCollection cellCollection)
    {
        for (int i = 1; i < cellCollection.Rows.Count; i++)
        {
            try
            {
                Row row = cellCollection.Rows[i];
                String maDTKD = row.GetCell(0).Value == null ? String.Empty : row.GetCell(0).Value.ToString();
                String Forwarder = row.GetCell(1).Value == null ? String.Empty : row.GetCell(1).Value.ToString();
                String Shipper = row.GetCell(2).Value == null ? String.Empty : row.GetCell(2).Value.ToString();
                String  Consignee = row.GetCell(3).Value == null ? String.Empty : row.GetCell(3).Value.ToString();
                String Notify = row.GetCell(4).Value == null ? String.Empty : row.GetCell(4).Value.ToString();
                String AlsoNotify = row.GetCell(5).Value == null ? String.Empty : row.GetCell(5).Value.ToString();
                String POD = row.GetCell(6).Value == null ? String.Empty : row.GetCell(6).Value.ToString();
                String PlaceOfDelivery = row.GetCell(7).Value == null ? String.Empty : row.GetCell(7).Value.ToString();
                String AddressForSendingOriginalDocs = row.GetCell(8).Value == null ? String.Empty : row.GetCell(8).Value.ToString();
                String EmailSendPaymentRequest = row.GetCell(9).Value == null ? String.Empty : row.GetCell(9).Value.ToString();
                String CacLoaiCTYC = row.GetCell(10).Value == null ? String.Empty : row.GetCell(10).Value.ToString();
                String Mota = row.GetCell(11).Value == null ? String.Empty : row.GetCell(11).Value.ToString();

                String msg = "";
                msg += String.Format("<div>--- Import Dòng {0} ---</div>", i + 1);
                bool next = true;
                var dtkd = ImportUtils.getDoiTac(maDTKD);
                if (dtkd == null)
                {
                    msg = $@"<div style=""color:red"">Không tìm thấy ĐTKD</div>";
                    next = false;
                }

                if (next)
                {
                    var o = new ShippingDetailImport();
                    o.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id;
                    o.Forwarder = Forwarder;
                    o.Shipper = Shipper;
                    o.Consignee = Consignee;
                    o.Notify = Notify;
                    o.AlsoNotify = AlsoNotify;
                    o.POD = POD;
                    o.PlaceOfDelivery = PlaceOfDelivery;
                    o.AddressForSendingOriginalDocs = AddressForSendingOriginalDocs;
                    o.EmailSendPaymentRequest = EmailSendPaymentRequest;
                    o.CacLoaiCTYC = CacLoaiCTYC;
                    o.Mota = Mota;
                    var spd = o.exists();

                    if (spd == null)
                    {
                        o.Import();
                        msg += String.Format("<div style=\"color:green\">Thêm shipping detail thành công!</div>");
                    }
                    else
                    {
                        o.Update(spd);
                        msg += String.Format("<div style=\"color:green\">Cập nhật shipping detail thành công!</div>");
                    }
                }
                msg += String.Format("<div>--- Kết thúc dòng {0} ---</div>", i + 1);
                context.Response.Write(msg);
            }
            catch (Exception ex)
            {
                context.Response.Write(String.Format("<div style=\"color:red\">Dòng {0} xảy ra lỗi {1}</div>", i + 1, ex.Message));
            }
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}