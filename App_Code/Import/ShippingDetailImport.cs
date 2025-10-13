using System;
using System.Data;
using System.Web;
using System.Linq;


public class ShippingDetailImport : ImportOriginal
{
    public String md_doitackinhdoanh_id { get; set; }
    public String Forwarder { get; set; }
    public String Shipper { get; set; }
    public String Consignee { get; set; }
    public String Notify { get; set; }
    public String AlsoNotify { get; set; }
    public String POD { get; set; }
    public String PlaceOfDelivery { get; set; }
    public String AddressForSendingOriginalDocs { get; set; }
    public String EmailSendPaymentRequest { get; set; }
    public String CacLoaiCTYC { get; set; }
    public String Mota { get; set; }

    public ShippingDetailImport()
    {

    }

    LinqDBDataContext db = new LinqDBDataContext();

    public md_doitackinhdoanh_spd exists()
    {
        return db.md_doitackinhdoanh_spds.Where(p => p.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id) && p.Forwarder.Equals(Forwarder)).FirstOrDefault();
    }

    public void Import()
    {
        var o = new md_doitackinhdoanh_spd();
        o.md_doitackinhdoanh_spd_id = Helper.getNewId();
        o.md_doitackinhdoanh_id = md_doitackinhdoanh_id;
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
        o.mota = Mota;
        o.ngaytao = DateTime.Now;
        o.nguoitao = UserUtils.getUser(HttpContext.Current);
        o.ngaycapnhat = DateTime.Now;
        o.nguoicapnhat = UserUtils.getUser(HttpContext.Current);
        db.md_doitackinhdoanh_spds.InsertOnSubmit(o);
        db.SubmitChanges();
    }

    
    public void Update(md_doitackinhdoanh_spd o)
    {
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
        o.mota = Mota;
        o.ngaycapnhat = DateTime.Now;
        o.nguoicapnhat = UserUtils.getUser(HttpContext.Current);
        db.SubmitChanges();
    }
}
