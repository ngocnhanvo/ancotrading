using System;
using System.Web.Security;
using System.Data;
using System.Net;
using System.Collections.Generic;
public partial class Login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        string host = Request.Url.Host;
        string manv = txtUserName.Text;
        string msg = "";
        string matkhau = Security.EncodeMd5Hash(txtPassword.Text);
        string sql = "select * from nhanvien where manv = @manv and matkhau = @matkhau and hoatdong = 1";
        DataTable dt = mdbc.GetData(sql, "@manv", manv, "@matkhau", matkhau);
        if (dt.Rows.Count != 0)
        {
            string username = dt.Rows[0]["manv"].ToString();
            var remote = (dt.Rows[0]["remote"] + "").ToLower() == "true";
            var canOTP = (dt.Rows[0]["canOTP"] + "").ToLower() == "true";
            if (host.Contains("14.161.40.208"))
            {
                if (!remote)
                    msg = "Tài khoản không thể truy cập từ xa.";
                else
                {
                    if (canOTP)
                    {
                        char[] charArr = "0123456789".ToCharArray();
                        var lstRD = new List<string>();
                        Random objran = new Random();
                        int noofcharacters = 6;
                        for (int i = 0; i < noofcharacters; i++)
                        {
                            //It will not allow Repetation of Characters
                            int pos = objran.Next(1, charArr.Length);
                            if (!lstRD.Contains(charArr.GetValue(pos).ToString()))
                                lstRD.Add(charArr.GetValue(pos).ToString());
                            else
                                i--;
                        }
                        string body = "";
                        string strrandom = string.Join(" ", lstRD);
                        body += username + "[" + strrandom + "]";
                        sql = "update nhanvien set otp = @otp, otp_created = getdate() where manv = @manv";
                        mdbc.ExcuteNonQuery(sql, "@manv", username, "@otp", strrandom.Replace(" ", ""));

                        string ErrorMessage = "";
                        try
                        {
                            //TwilioClient.Init(Public.accountSid, Public.authToken);
                            //CreateMessageOptions options = new CreateMessageOptions(new Twilio.Types.PhoneNumber("+84935385878"));
                            //options.Body = body;
                            //options.From = new Twilio.Types.PhoneNumber(Public.fromTwillo);
                            //ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
                            //var message = MessageResource.Create(options);
                            //ErrorMessage = message.ErrorMessage;
                        }
                        catch
                        {

                        }

                        if (string.IsNullOrEmpty(ErrorMessage))
                            Response.Redirect("OTP.aspx?us=" + username, true);
                        else
                            msg = ErrorMessage;
                    }
                }
            }

            if (msg.Length <= 0)
            {
                FormsAuthentication.SetAuthCookie(username, false);
                //string url = (Request.QueryString["ReturnUrl"] != null) ? Request.QueryString["ReturnUrl"].ToString() : "Default-Security.aspx";
                string url = "Default-Security.aspx";
                Response.Redirect(url, true);
            }
        }
        else
        {
            msg = "Thông tin đăng nhập không đúng";
        }
        this.RegisterStartupScript("ThongBao", string.Format(@"<script>alert('{0}')</script>", msg));
    }
}
