<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PaymentRequest.aspx.cs"Inherits="SendMail_PaymentRequest" %>
<html>
<body>
<%
    String pklId = Context.Request.QueryString["pklId"];
%>
<iframe width="100%" height="100%" src="../Controllers/PackingInvoiceController.ashx?action=sendmail&pklId=<%= pklId %>"></iframe>
</body>
</html>