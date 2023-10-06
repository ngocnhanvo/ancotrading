using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using DevExpress.XtraReports.UI;
using System.Drawing;
using System.Collections;
using System.ComponentModel;

public partial class PrintControllers_InPhieuNhapHang_SendMail : System.Web.UI.Page
{
    private LinqDBDataContext db = new LinqDBDataContext();
    protected void Page_Load(object sender, EventArgs e)
    {
        string nguoinhan = Request.Params["nguoinhanNK"];
        string cc = Request.Params["ccNK"];
        string bcc = Request.Params["bccNK"];
        string pkId = Request.Params["nhapkhoIdNK"];
        var nk = db.c_nhapxuats.Where(s => s.c_nhapxuat_id == pkId).FirstOrDefault();
        if(nk == null)
        {
            Response.Write("Lỗi: phiếu nhập kho không tồn tại");
            goto EndEventHandler;
        }

        string manv = UserUtils.getUser(Context);
        var nv = db.nhanviens.FirstOrDefault(p => p.manv.Equals(manv));
        md_smtp smtp = null;
        if (string.IsNullOrWhiteSpace(nv.smtp))
            smtp = db.md_smtps.FirstOrDefault(p => p.macdinh.Equals(true));
        else
            smtp = db.md_smtps.FirstOrDefault(p => p.md_smtp_id == nv.smtp);

        var mail = new GoogleMail(nv.email, nv.email_pass, smtp.smtpserver, smtp.port.Value, smtp.use_ssl.GetValueOrDefault(false));
        var temName = "NK_KT";
        var template = db.md_mailtemplates.Where(s => s.ten_template == temName).FirstOrDefault();
        if (template == null)
        {
            Response.Write(string.Format(@"Không tìm thấy mẫu gửi mail có tên ""{0}""", temName));
            goto EndEventHandler;
        }

        string fd = "PrintControllers/InPhieuNhapHang/";
        string linkConnect = string.Format(@"{0}?c_nhapxuat_id={1}&type=excel", fd, pkId);
        var data = new Dictionary<string, object>();
        var msgDT = Extension.GetModule(linkConnect, data);
        try
        {
            var dicFile = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, string>>(msgDT);
            var xls = dicFile["xls"];
            var pdf = dicFile["pdf"];
            var dh = db.c_donhangs.Where(s => s.c_donhang_id == nk.c_donhang_id).FirstOrDefault();

            var subject = template.subject_mail;
            subject = subject.Replace("PHIEUNHAP", nk.sophieu);
            subject = subject.Replace("SOPO", dh.sochungtu);

            var content = template.content_mail;
            content = content.Replace("PHIEUNHAP", nk.sophieu);
            content = content.Replace("SOPO", dh.sochungtu);

            mail.Send(
                nv.email
                , nguoinhan
                , cc
                , bcc
                , subject
                , content
                , xls + ";" + pdf
            );

            Response.Write("<center><h1>Gửi mail thành công, chậm nhất là 30 phút để mail đến được đích</center></h1>");
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }

        EndEventHandler:;
    }
}