<%@ Page Language="C#" AutoEventWireup="true" CodeFile="linq.aspx.cs" Inherits="Linq" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        #form1 {
            text-align:center;
            margin-top: 20px;
        }

        #updateLinq, #pullcode, #generateDBMap {
            margin-right: 50px;
        }

        #result {
            display: flex;
            width: 50%;
            max-width: 570px;
            margin: 30px auto;
            padding: 5px;
            border: 1px solid #000000;
            height: calc(100vh - 115px);
            background-color: #505050;
            color: #FFF;
        }

        .loadingPage {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 11000;
            background-color: rgba(255, 255, 255, 0.7);
        }

        .hide { display: none; }

        #loader {
            display: block;
            position: relative;
            left: 50%;
            top: 50%;
            width: 150px;
            height: 150px;
            margin: -75px 0 0 -75px;
            border-radius: 50%;
            border: 3px solid transparent;
            border-top-color: #3498db;
            cursor: default;
            -webkit-animation: spin 2s linear infinite;
            animation: spin 2s linear infinite;
        }

        #loader:before {
            content: "";
            position: absolute;
            top: 5px; left: 5px; right: 5px; bottom: 5px;
            border-radius: 50%;
            border: 3px solid transparent;
            border-top-color: #e74c3c;
            -webkit-animation: spin 3s linear infinite;
            animation: spin 3s linear infinite;
        }

        #loader:after {
            content: "";
            position: absolute;
            top: 15px; left: 15px; right: 15px; bottom: 15px;
            border-radius: 50%;
            border: 3px solid transparent;
            border-top-color: #f9c922;
            -webkit-animation: spin 1.5s linear infinite;
            animation: spin 1.5s linear infinite;
        }

        @-webkit-keyframes spin {
            0% { -webkit-transform: rotate(0deg); -ms-transform: rotate(0deg); transform: rotate(0deg); }
            100% { -webkit-transform: rotate(360deg); -ms-transform: rotate(360deg); transform: rotate(360deg); }
        }

        @keyframes spin {
            0% { -webkit-transform: rotate(0deg); -ms-transform: rotate(0deg); transform: rotate(0deg); }
            100% { -webkit-transform: rotate(360deg); -ms-transform: rotate(360deg); transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div runat="server" id="loaderMain" class="loadingPage hide">
        <div id="loader"></div>
    </div>
    <form id="form1" runat="server">
        <asp:Button runat="server" Text="Click to update Linq" ID="updateLinq" OnClick="updateLinq_Click"/>

        <asp:Button runat="server" Text="Generate DB Map" ID="generateDBMap" OnClick="generateDBMap_Click"/>

        <asp:Button runat="server" Text="Click to pull code" ID="pullcode" OnClick="pullcode_Click"/>

        <asp:Button runat="server" Text="Click to open MSSQL" ID="openMSSQL" OnClick="openmssql_Click"/>
    </form>

    <textarea readonly id="result" runat="server"></textarea>

    <script type="text/javascript">
        ['updateLinq', 'generateDBMap', 'pullcode'].forEach(function (id) {
            document.getElementById(id).onclick = function () {
                document.getElementById('loaderMain').classList.remove('hide');
            };
        });
    </script>
</body>
</html>
