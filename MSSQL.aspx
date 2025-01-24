<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MSSQL.aspx.cs" Inherits="MSSQL" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="keywords" content="MSSQL" />
    <title>MSSQL online</title>
    <link rel="stylesheet" href="Scripts/ThanhSang/mssql/jqwidgets/styles/jqx.base.css" type="text/css" />
    <link rel="stylesheet" href="Scripts/ThanhSang/mssql/jqwidgets/styles/jqx.energyblue.css" type="text/css" />
    <style type="text/css">
        .jqx-fill-state-normal-energyblue, .jqx-widget-header-energyblue {
            border-color: #000000;
        }

        body { overflow: hidden; }

        #editor {
            margin: 0;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            font-size:125%;
        }

        .jqx-tree-dropdown > li.jqx-tree-item-li {
            font-size: 90%;
        }

        .jqx-tree-dropdown > li.jqx-tree-item-li .coltype {
            font-size: 80%;
            color: blue;
        }

        .jqx-tree-dropdown > li.jqx-tree-item-li .colnull {
            font-size: 80%;
            color: darkgrey;
        }

        .jqx-tree-dropdown > li.jqx-tree-item-li .key {
            font-size: 90%;
            color: red;
            top: 3px;
            left: 10px;
            position: relative;
        }

        #eventWindowContent { height: calc(100% - 80px); }
        #eventWindowContent .sql {
            margin-top: 10px;
            height: calc(100%);
            overflow: auto;
            border-bottom: 1px solid;
            padding-bottom: 5px;
        }

        #eventWindowContent .sql > textarea {
            font-weight: bold;
            width: calc(100% - 10px);
            height: calc(100% - 10px);
            resize: none;
            outline: none;
        }

        #resultSQL {
            margin-top: 10px;
            margin-left: 10px;
            font-weight: bold;
            overflow: auto;
            height: calc(100% - 15px);
        }

        #resultSQL table th {
            border-style: ridge;
            background-color: #e0e9f5;
            padding: 7px;
            position: sticky;
            top: 0;
        }
            #resultSQL table th:first-child {
                left: 0;
                z-index: 2;
            }

        #resultSQL table td {
            border-style: ridge;
            padding: 5px;
            font-weight: normal;
            background-color: #ffffff;
        }
            #resultSQL table td:first-child {
                position: sticky;
                left: 0;
            }

        .a_download{
            cursor: pointer;
            text-decoration: underline;
            USER-SELECT: none;
            color: blue;
        }
    </style>

    <script type="text/javascript" src="Scripts/ThanhSang/mssql/scripts/jquery-1.11.1.min.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxcore.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxsplitter.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxtree.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxbuttons.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxscrollbar.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxpanel.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxmenu.js"></script>
    <script type="text/javascript" src="Scripts/ThanhSang/mssql/jqwidgets/jqxwindow.js"></script>
    <script type="text/javascript" src="Scripts/NgocNhan/editor/src-noconflict/ace.js" charset="utf-8"></script>
</head>
<body>
    <div id="mainSplitter" style="">
        <div>
            <div style="overflow: hidden; height: calc(100vh - 23px);" id='jqxTreePR'>
                <div id='jqxTree'>
                    <ul>
                        <%=loadJQXTree() %>
                    </ul>
                </div>
            </div>

            <div id='jqxMenuTable' style="position:absolute">
                <ul>
                    <li><a href="#">Select top 1000</a></li>
                    <li><a href="#">ADD TABLE</a></li>
                    <li><a href="#">RENAME TABLE</a></li>
                    <li><a href="#">DROP TABLE</a></li>
                    <li><a href="#">ADD COLUMN</a></li>
                    <li><a href="#">BACKUP DB</a></li>
                    <li><a href="#">REFRESH MENU</a></li>
                </ul>
            </div>

            <div id='jqxMenuColumn' style="position:absolute">
                <ul>
                    <li><a href="#">RENAME COLUMN</a></li>
                    <li><a href="#">MODIFY COLUMN</a></li>
                    <li><a href="#">DROP COLUMN</a></li>
                    <li><a href="#">RENAME KEY</a></li>
                </ul>
            </div>
        </div>
        <div>
            <div id="rightSplitter">
                <div>
                    <pre id="editor"></pre>
                </div>
                <div>
                    <div id="eventWindow">
                        <div>Execute SQL</div>
                        <div>
                            <div id="eventWindowContent">
                                <div class="title"></div>
                                <div class="sql">
                                    <textarea readonly="readonly"></textarea>
                                </div>
                            </div>
                            <div>
                                <div style="bottom: 14px;right: 25px;position: absolute;">
                                    <input type="button" id="ok" value="OK" style="margin-right: 15px" />
                                    <input type="button" id="cancel" value="Cancel" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="resultSQL"></div>
                </div>
            </div>

            <div id='jqxMenu2' style="position:absolute">
                <ul>
                    <li><a href="#">Execute SQL</a></li>
                </ul>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function isRightClick(event) {
            let rightclick;
            if (!event) 
                event = window.event;
            
            if (event.which) 
                rightclick = (event.which == 3);
            else if (event.button) 
                rightclick = (event.button == 2);
            
            return rightclick;
        }

        function convertJsonToTable(jsonData) {
            // Create the table element
            let table = $("<table>");
         
            // Get the keys (column names) of the first object in the JSON data
            let cols = Object.keys(jsonData[0]);
         
            // Create the header element
            let thead = $("<thead>");
            let tr = $("<tr>");
         
            // Loop through the column names and create header cells
            $.each(cols, function(i, item){
                let th = $("<th>");
                th.text(item); // Set the column name as the text of the header cell
                tr.append(th); // Append the header cell to the header row
            });
            thead.append(tr); // Append the header row to the header
            table.append(tr) // Append the header to the table
         
            // Loop through the JSON data and create table rows
            $.each(jsonData, function(i, item){
                let tr = $("<tr>");
            
                // Get the values of the current object in the JSON data
                let vals = Object.values(item);
            
                // Loop through the values and create table cells
                $.each(vals, (i, elem) => {
                    console.log(elem);
                    let td = $("<td>");
                    if(elem == null)
                        td.text('/NULL/');
                    else if(elem.toString().replace(/[\n\r]/g,'').trim() == '')
                        td.text('');
                    else if(Boolean(elem) == false)
                        td.text(0);
                    else if(elem == true)
                        td.text(1);
                    else
                        td.text(elem); // Set the value as the text of the table cell
                    tr.append(td); // Append the table cell to the table row
                });
                table.append(tr); // Append the table row to the table
            });
            return table; 
        }

        function loadMenuRight() {
            $("#jqxTree li.li_table > div").on('mousedown', function (event) {
                let target = $(event.target).parents('li:first')[0];
                let rightClick = isRightClick(event);
                if (rightClick && target != null) {
                    $("#jqxTree").jqxTree('selectItem', target);
                    let scrollTop = $(window).scrollTop();
                    let scrollLeft = $(window).scrollLeft();
                    $contextMenuColumn.jqxMenu('close');
                    let y = parseInt(event.clientY) + 5 + scrollTop;
                    let heightY = $('#mainSplitter').height() - $contextMenuTable.jqxMenu('height');
                    if (y > heightY)
                        y = heightY;
                    $contextMenuTable.jqxMenu('open', parseInt(event.clientX) + 5 + scrollLeft, y);
                    return false;
                }
            });

            $("#jqxTree li.li_table > ul > li > div").on('mousedown', function (event) {
                let target = $(event.target).parents('li:first')[0];
                let rightClick = isRightClick(event);
                if (rightClick && target != null) {
                    $("#jqxTree").jqxTree('selectItem', target);
                    let scrollTop = $(window).scrollTop();
                    let scrollLeft = $(window).scrollLeft();
                    $contextMenuTable.jqxMenu('close');
                    let y = parseInt(event.clientY) + 5 + scrollTop;
                    let heightY = $('#mainSplitter').height() - $contextMenuColumn.jqxMenu('height');
                    if (y > heightY)
                        y = heightY;
                    $contextMenuColumn.jqxMenu('open', parseInt(event.clientX) + 5 + scrollLeft, y);
                    return false;
                }
            });
        }

        $(document).bind('contextmenu', function (e) {
            return false;
        });

        $('#mainSplitter').jqxSplitter({ width: '100%', height: window.innerHeight - 20, panels: [{ size: 350 }] });
        $('#rightSplitter').jqxSplitter({ width: '100%', height: '100%', orientation: 'horizontal', panels: [{ size: '40%', collapsible: false }] });
        $('#eventWindow').jqxWindow({
            autoOpen: false,
            position: 'center',
            maxWidth: 400,
            minWidth: 200, 
            width: 400,
            height: 400,
            resizable: false,
            isModal: true,
            modalOpacity: 0.9, 
            cancelButton: $('#cancel'),
            initContent: function () {
                let $btnOK = $('#ok'), $btnCancel = $('#cancel');
                $btnOK.jqxButton({ width: '65px' });
                $btnOK.on('click', function () {
                    $btnOK.jqxButton({disabled: true });
                    $btnCancel.jqxButton({disabled: true });
                    $.ajax({
                        type: "POST",
                        url: "MSSQL.aspx/executeSQL",
                        data: JSON.stringify({ sql: $('#eventWindowContent .sql > textarea').val() }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (res) {
                            if(res.d.startsWith('[')) {
                                let json = JSON.parse(res.d);
                                $('#resultSQL').html(convertJsonToTable(json));
                            }
                            else {
                                $('#resultSQL').html(res.d);
                            }
                            $btnOK.jqxButton({disabled: false });
                            $btnCancel.jqxButton({disabled: false });
                            $btnCancel.click();
                        },
                        error: function (req, status, error) {
                            $btnOK.jqxButton({disabled: false });
                            $btnCancel.jqxButton({disabled: false });
                            alert("x" + error + status);
                        }
                    }).done(function (result) { 
                        $btnOK.jqxButton({disabled: false });
                        $btnCancel.jqxButton({disabled: false });
                    });

                    
                });

                $btnCancel.jqxButton({ width: '65px' });
                $btnOK.focus();
            }
        });

        $('#jqxTree').jqxTree({ height: '100%', width: '100%', theme: 'energyblue' });
        let $contextMenuTable = $("#jqxMenuTable").jqxMenu({ width: '200px', height: 190, autoOpenPopup: false, mode: 'popup'});
        let $contextMenuColumn = $("#jqxMenuColumn").jqxMenu({ width: '200px', height: 110, autoOpenPopup: false, mode: 'popup'});
        $contextMenuTable.on('itemclick', function (event)
        {
            let selectedItem = $('#jqxTree').jqxTree('selectedItem');
            if (selectedItem != null) {
                let item = $.trim($(event.args).text());
                let tblName = selectedItem.label;
                switch (item) {
                    case "Select top 1000":
                        $editor.setValue(`select top (1000) * from ${tblName}`);
                        break;
                    case "ADD TABLE":
                        $editor.setValue(
`CREATE TABLE [dbo].[md_tableNew](
	[md_tableNew_id] [varchar](32) NOT NULL,
	[nguoitao] [varchar](32) NULL,
	[vaitrotao] [varchar](32) NULL,
	[bophantao] [varchar](32) NULL,
	[nguoicapnhat] [varchar](32) NULL,
	[vaitrocapnhat] [varchar](32) NULL,
	[bophancapnhat] [varchar](32) NULL,
	[value_nguoitao] [nvarchar](150) NULL,
	[value_vaitrotao] [nvarchar](150) NULL,
	[value_bophantao] [nvarchar](150) NULL,
	[value_nguoicapnhat] [nvarchar](150) NULL,
	[value_vaitrocapnhat] [nvarchar](150) NULL,
	[value_bophancapnhat] [nvarchar](150) NULL,
	[ngaytao] [datetime] NULL,
	[ngaycapnhat] [datetime] NULL,
	[mota] [nvarchar](max) NULL,
	[hoatdong] [bit] NULL,
    CONSTRAINT [PK_md_tableNew] PRIMARY KEY CLUSTERED 
    (
	    [md_tableNew_id] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]`);
                        break;
                    case "RENAME TABLE":
                        $editor.setValue(`exec sp_rename 'dbo.${tblName}', 'new_table_name'`);
                        break;
                    case "DROP TABLE":
                        $editor.setValue(`DROP TABLE ${tblName}`);
                        break;
                    case "ADD COLUMN":
                        $editor.setValue(`ALTER TABLE ${tblName} ADD [column] nvarchar(MAX);`);
                        break;
                    case "BACKUP DB":
                        let now = new Date();
                        let ddNow = String(now.getDate()).padStart(2, '0');
                        let mmNow = String(now.getMonth() + 1).padStart(2, '0');
                        let yyyyNow = now.getFullYear();
                        let tenDB_backup = `<%=tenDB%>_${ddNow}-${mmNow}-${yyyyNow}.bak`;
                        $editor.setValue(
`--(download) ${tenDB_backup}
declare @folder nvarchar(MAX) = '<%=urlRoot.Replace("\\","\\\\")%>';
declare @file nvarchar(MAX) = '${tenDB_backup}';
declare @str nvarchar(MAX) = @folder + @file
BACKUP DATABASE <%=tenDB%>
TO DISK = @str
   WITH FORMAT,
      MEDIANAME = 'SQLServerBackups',
      NAME = 'Full Backup of <%=tenDB%>';`);
                        break;
                    case "REFRESH MENU":
                        let item = $('#jqxTree').jqxTree('getSelectedItem');
                        let label = item ? item.id : '';

                        $('#jqxTree').jqxTree('destroy');
                        $('#jqxTreePR').html(`<div id="jqxTree"><ul><li>Loading...</li></ul></div>`);
                        $.ajax({
                            type: "POST",
                            url: "MSSQL.aspx/loadJQXTree",
                            data: JSON.stringify({ sql: '' }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (res) {
                                $('#jqxTree > ul').html(res.d);
                                $('#jqxTree').jqxTree({ height: '100%', width: '100%', theme: 'energyblue' });
                                loadMenuRight();
                                $("#jqxTree").jqxTree('selectItem', $(`#${label}`)[0]);
                                $('#jqxTree').jqxTree('ensureVisible', $(`#${label}`)[0]);
                            },
                            error: function (req, status, error) {
                                alert("x" + error + status);
                            }
                        }).done(function (result) {

                        });
                        break;
                }
            }
        });

        $contextMenuColumn.on('itemclick', function (event)
        {
            let selectedItem = $('#jqxTree').jqxTree('selectedItem');
            
            if (selectedItem != null) {
                let item = $.trim($(event.args).text());
                let itemP = $('#jqxTree').jqxTree('getItem', selectedItem.parentElement);
                let tblName = itemP.label;
                let colName = selectedItem.element.getAttribute('value');
                let keyName = selectedItem.element.getAttribute('keyname');
                switch (item) {
                    case "RENAME COLUMN":
                        $editor.setValue(`EXEC sp_rename '${tblName}.${colName}',  'new_name', 'COLUMN';`);
                        break;
                    case "MODIFY COLUMN":
                        $editor.setValue(`ALTER TABLE ${tblName} ALTER COLUMN ${colName} datatype;`);
                        break;
                    case "DROP COLUMN":
                        $editor.setValue(`ALTER TABLE ${tblName} DROP COLUMN ${colName};`);
                        break;
                    case "RENAME KEY":
                        if(keyName) {
                            $editor.setValue(`EXEC sp_rename '[dbo].[${tblName}].[${keyName}]', 'PK_${tblName}'`);
                        }
                        else {
                            alert('Key is not found');
                        }
                        break;
                }
            }
        });

        loadMenuRight();

        var $editor = ace.edit("editor");
        $editor.setTheme("ace/theme/sqlserver");
        $editor.session.setMode("ace/mode/sql");

        let $contextMenu2 = $("#jqxMenu2").jqxMenu({ width: '130px', height: '40px', autoOpenPopup: false, mode: 'popup'});
        $contextMenu2.on('itemclick', function (event)
        {
            let text = $editor.getSelectedText();
            if(!text)
                text = $editor.getValue();

            if(!text)
                alert('Code is empty!!!');
            else {
                $('#eventWindowContent .title').html(`Do you want to execute above SQL?`);
                $('#eventWindowContent .sql > textarea').val(`${text}`);
                $('#eventWindow').jqxWindow('open');
            }
        });
        
        $('#editor').on('mousedown', function (event) {
            let rightClick = isRightClick(event);
                if (rightClick) {
                let scrollTop = $(window).scrollTop();
                let scrollLeft = $(window).scrollLeft();
                $contextMenu2.jqxMenu('open', parseInt(event.clientX) + 5 + scrollLeft, parseInt(event.clientY) + 5 + scrollTop);
                return false;
            }
        });         

        setInterval(function () { $.get('Controllers/GetSession.ashx'); }, 20000);
    </script>
</body>
</html>
