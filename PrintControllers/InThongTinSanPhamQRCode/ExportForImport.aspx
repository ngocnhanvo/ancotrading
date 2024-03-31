<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ExportForImport.aspx.cs" Inherits="PrintControllers_ExportForImport_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <textarea id="txtMSPs" runat="server" style="height: calc(100vh - 40px); width: 400px;"></textarea>
        <asp:Button ID="Button1" style="padding: 10px; position: relative; top: -15px;" OnClick="Button1_Click" runat="server" Text="Xuất Excel"></asp:Button>
    </form>
</body>
</html>
