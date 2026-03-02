/*using Microsoft.Graph;
using Microsoft.Identity.Client;
using System;
using System.Collections.Generic;
using System.Net.Http.Headers;
using System.Threading.Tasks;*/
using System.Collections.Generic;

public class M365Mail
{
    public string email { get; set; }
    public string pass { get; set; }
    public string subject { get; set; }
    public string body { get; set; }
    public string to { get; set; }
    public string cc { get; set; }
    public string bcc { get; set; }
    public List<System.Net.Mail.Attachment> attachments { get; set; }

    /*private List<Attachment> ConvertAttachments(List<System.Net.Mail.Attachment> attachmentsInput)
    {
        var graphAttachments = new List<Attachment>();
        if (attachmentsInput == null || attachmentsInput.Count == 0) return graphAttachments;

        foreach (var att in attachmentsInput)
        {
            // Đọc dữ liệu từ Stream của attachment cũ
            byte[] contentBytes;
            using (var ms = new System.IO.MemoryStream())
            {
                att.ContentStream.Position = 0; // Đảm bảo stream ở vị trí bắt đầu
                att.ContentStream.CopyTo(ms);
                contentBytes = ms.ToArray();
            }

            graphAttachments.Add(new FileAttachment
            {
                ODataType = "#microsoft.graph.fileAttachment",
                Name = att.Name,
                ContentType = att.ContentType.MediaType,
                ContentBytes = contentBytes
            });
        }
        return graphAttachments;
    }

    private List<Recipient> ParseRecipients(string emailString)
    {
        var recipients = new List<Recipient>();
        if (string.IsNullOrWhiteSpace(emailString)) return recipients;

        var items = emailString.Split(new[] { ';', ',' }, StringSplitOptions.RemoveEmptyEntries);
        foreach (var item in items)
        {
            string displayEmail = item.removeAllSpaceOrTrimText(true);
            string displayName = displayEmail;
            if (displayName.Contains("<") && displayName.EndsWith(">"))
            {
                var parts = displayName.Split('<');
                displayName = parts[0].Trim();
                displayEmail = parts[1].Replace(">", "").Trim();
            }

            if (displayName.Contains("@"))
            {
                // Lấy phần trước chữ @. Ví dụ: "vongocnhan" từ "vongocnhan@gmail.com"
                displayName = displayName.Split('@')[0];

                // (Tùy chọn) Viết hoa chữ cái đầu cho đẹp
                if (displayName.Length > 1)
                    displayName = char.ToUpper(displayName[0]) + displayName.Substring(1);
            }
            // Nếu chỉ nhập email, ta tự tạo Name từ email để tránh lặp
            else if (displayName.Contains("@"))
            {
                // Lấy phần trước chữ @. Ví dụ: "vongocnhan" từ "vongocnhan@gmail.com"
                displayName = displayName.Split('@')[0];

                // (Tùy chọn) Viết hoa chữ cái đầu cho đẹp
                if (displayName.Length > 1)
                    displayName = char.ToUpper(displayName[0]) + displayName.Substring(1);
            }
            recipients.Add(new Recipient
            {
                EmailAddress = new EmailAddress { Name = displayName, Address = displayEmail }
            });
        }
        return recipients;
    }*/

    public void SendEmailOAuth2Sync()
    {
        /*var arr = pass.removeAllSpaceOrTrimText(true).Split(',');
        string clientId = arr[0];
        string tenantId = arr[1];
        string clientSecret = arr[2];
        //string clientId = "2695991b-90f8-4267-b295-10f6b80527bc";
        //string tenantId = "597823c6-0bdb-4b58-8ebe-a88da88a1b81";
        //string clientSecret = "R3t8Q~7i.l9fzYnyi73nfIC_iJxGxrDHkJt51bG9";
        string senderEmail = email;

        System.Net.ServicePointManager.SecurityProtocol =
    System.Net.SecurityProtocolType.Tls12 | System.Net.SecurityProtocolType.Tls11 | System.Net.SecurityProtocolType.Tls;
        // 2. Khởi tạo xác thực bằng MSAL (Microsoft.Identity.Client)
        IConfidentialClientApplication confidentialClient = ConfidentialClientApplicationBuilder
            .Create(clientId)
            .WithAuthority(new Uri($"https://login.microsoftonline.com/{tenantId}"))
            .WithClientSecret(clientSecret)
            .Build();

        // Định nghĩa Scope cho Graph API
        string[] scopes = new string[] { "https://graph.microsoft.com/.default" };

        // 3. Tạo DelegateAuthenticationProvider (Đặc trưng của v4)
        var authProvider = new DelegateAuthenticationProvider(async (request) =>
        {
            // Lấy Token tự động
            var authResult = await confidentialClient.AcquireTokenForClient(scopes).ExecuteAsync();
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", authResult.AccessToken);
        });

        // 4. Khởi tạo GraphServiceClient v4
        GraphServiceClient graphClient = new GraphServiceClient(authProvider);
        // 5. Soạn nội dung Email
        var emailMessage = new Message
        {
            Subject = this.subject,
            Body = new ItemBody
            {
                ContentType = BodyType.Html,
                Content = this.body
            },
            ToRecipients = ParseRecipients(to),
            CcRecipients = ParseRecipients(cc),
            BccRecipients = ParseRecipients(bcc)
        };

        var convertedAttachments = ConvertAttachments(attachments);
        if (convertedAttachments.Count > 0)
        {
            // Trong SDK v4, ta khởi tạo trang collection và add từng phần tử vào
            emailMessage.Attachments = new MessageAttachmentsCollectionPage();
            foreach (var att in convertedAttachments)
            {
                emailMessage.Attachments.Add(att);
            }
        }

        try
        {
            // 6. Gửi Mail (Cú pháp .Request().PostAsync() của v4)
            Task.Run(async () =>
                await graphClient.Users[senderEmail]
                    .SendMail(emailMessage, true)
                    .Request()
                    .PostAsync()
            ).GetAwaiter().GetResult();
        }
        catch (ServiceException ex)
        {
            throw new Exception($"Lỗi Graph API: {ex.ToString()}");
        }
        catch (Exception ex)
        {
            throw new Exception($"Lỗi hệ thống: {ex.ToString()}");
        }*/
    }
}
