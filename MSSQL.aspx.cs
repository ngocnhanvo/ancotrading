using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class MSSQL : System.Web.UI.Page
{
    public class LeftMenu
    {
        public string tablename { get; set; }
        public List<LeftMenuItem> items { get; set; }

    }
    public class LeftMenuItem
    {
        public string columnname { get; set; }
        public string columntype { get; set; }
        public string IS_NULLABLE { get; set; }
        public string CHARACTER_MAXIMUM_LENGTH { get; set; }
        public string NUMERIC_PRECISION { get; set; }
        public string NUMERIC_PRECISION_RADIX { get; set; }
        public string key { get; set; }
    }

    public string tenDB = "";
    public static string urlRoot = "", urlMid = "App_Data";
    protected void Page_Load(object sender, EventArgs e)
    {
        tenDB = mdbc.GetConnection.Database;
        urlRoot = $"{AppDomain.CurrentDomain.BaseDirectory}{urlMid}\\";
        if (!IsPostBack)
        {

        }
    }

    // Hiển thị tên các bảng trong khung 1 (ListBox)
    public static List<LeftMenu> LoadTables()
    {
        var list = new List<LeftMenu>();
        var dt = mdbc.GetData("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME");
        foreach (System.Data.DataRow row in dt.Rows)
        {
            var item = new LeftMenu();
            item.tablename = row["TABLE_NAME"].ToString();
            item.items = LoadColumns(item.tablename);
            list.Add(item);
        }

        return list;

    }

    public static List<LeftMenuItem> LoadColumns(string tableName)
    {
        var list = new List<LeftMenuItem>();
        var query = $@"
SELECT 
	col.COLUMN_NAME, 
	col.DATA_TYPE, 
	col.IS_NULLABLE, 
	col.CHARACTER_MAXIMUM_LENGTH, 
	col.NUMERIC_PRECISION, 
	col.NUMERIC_PRECISION_RADIX,
	key_.CONSTRAINT_NAME
FROM 
	INFORMATION_SCHEMA.COLUMNS col
	left join INFORMATION_SCHEMA.KEY_COLUMN_USAGE key_ on key_.COLUMN_NAME = col.COLUMN_NAME 
		AND OBJECTPROPERTY(OBJECT_ID(key_.CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
		AND key_.TABLE_NAME = col.TABLE_NAME AND key_.TABLE_SCHEMA = col.TABLE_SCHEMA 
WHERE 
	col.TABLE_NAME = N'{tableName}' 
order by 
	col.ORDINAL_POSITION
        ";
        var dt = mdbc.GetData(query);
        foreach (System.Data.DataRow row in dt.Rows)
        {
            var columnItem = new LeftMenuItem
            {
                columnname = row["COLUMN_NAME"].ToString(),
                columntype = row["DATA_TYPE"].ToString(),
                IS_NULLABLE = row["IS_NULLABLE"].ToString(),
                CHARACTER_MAXIMUM_LENGTH = row["CHARACTER_MAXIMUM_LENGTH"].ToString(),
                NUMERIC_PRECISION = row["NUMERIC_PRECISION"].ToString(),
                NUMERIC_PRECISION_RADIX = row["NUMERIC_PRECISION_RADIX"].ToString(),
                key = row["CONSTRAINT_NAME"].ToString()
            };
            list.Add(columnItem);
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static string loadJQXTree()
    {
        string msg = "";
        foreach (var item in LoadTables())
        {
            string liDT = "";
            foreach (var itemChild in item.items)
            {
                string length = "", nullable = "", key = itemChild.key;
                if (!string.IsNullOrEmpty(itemChild.CHARACTER_MAXIMUM_LENGTH))
                {
                    length = $"({itemChild.CHARACTER_MAXIMUM_LENGTH})";
                    if (length == "(-1)")
                        length = "(MAX)";
                }
                else if (!string.IsNullOrEmpty(itemChild.NUMERIC_PRECISION))
                    length = $"({itemChild.NUMERIC_PRECISION},{itemChild.NUMERIC_PRECISION_RADIX})";

                if (itemChild.IS_NULLABLE == "NO")
                {
                    nullable = "NOT NULL";
                }
                else
                {
                    nullable = "NULL";
                }

                if (!string.IsNullOrEmpty(key))
                    key = $"<br><a class='key'>key name: {key}</a>";
                liDT += $@"
                    <li value=""{itemChild.columnname}"" keyname=""{itemChild.key}"">
                        {itemChild.columnname}, <a class='coltype'>{itemChild.columntype}{length}</a>, <a class='colnull'>{nullable}</a>{key}
                    </li>";
            }
            msg += $@"
            <li class=""li_table"" id=""litree{item.tablename.Replace("$", "_")}"">
                {item.tablename}
                <ul>
                    {liDT}
                </ul>
            </li>";
        }
        return msg;
    }

    [System.Web.Services.WebMethod]
    public static string executeSQL(string sql)
    {
        string sqlLower = sql.ToLower();
        string msg = "";
        try
        {
            var choPhepThucThi = true;
            if (sqlLower.Contains("ad_logmssql"))
            {
                var actions = new string[] { "drop", "delete", "sp_rename", "truncate", "alter", "update", "insert", "add" };
                foreach (var action in actions)
                {
                    if (sqlLower.Contains(action))
                    {
                        choPhepThucThi = false;
                        break;
                    }
                }
            }
            if (!choPhepThucThi)
                throw new Exception($@"table ""ad_logmssql"" cannot be executed sql");
            else
            {
                var dt = mdbc.GetData(sql);
                if (sql.ToLower() != "select top (1000) * from ad_logmssql")
                {
                    mdbc.ExcuteNonQuery($@"
                INSERT INTO [dbo].[ad_logmssql]
                       ([ad_logmssql_id]
                       ,[clientip]
                       ,[user]
                       ,[sql]
                       ,[ngaytao]
                       ,[nguoitao]
                       ,[ngaycapnhat]
                       ,[nguoicapnhat]
                       ,[mota]
                       ,[hoatdong])
                 VALUES
                       (N'{Helper.getNewId()}'
                       ,N'{Helper.getClientIP(HttpContext.Current)}'
                       ,N''
                       ,N'{sql.Replace("'", "''")}'
                       ,N'{DateTime.Now.ToString("yyyy-MM-dd HH:mm")}'
                       ,N''
                       ,N'{DateTime.Now.ToString("yyyy-MM-dd HH:mm")}'
                       ,N''
                       ,N''
                       ,1)
                ");
                }

                if (dt.Columns.Count <= 0)
                {
                    msg = "Query executed successfully";
                    if (sql.StartsWith("--(download) "))
                    {
                        sql = sql.Split('\n')[0];
                        string name = sql.Replace("--(download) ", "");
                        sql = $@"{urlMid}\\{name}";
                        msg += $@"<br><br><a class=""a_download"" onclick=""window.location.href=`Controllers/API_System.ashx?oper=downloadFile&path={sql}&name={name}`"">Click to download file ""{name}""</a>";
                    }
                    
                }
                else
                {
                    var name = $@"({dt.Rows.Count})";
                    if (dt.Rows.Count <= 0)
                        dt.Rows.Add();
                    var Col = dt.Columns.Add(name, System.Type.GetType("System.Int32"));
                    Col.SetOrdinal(0);
                    int i = 0;
                    foreach (System.Data.DataRow row in dt.Rows)
                    {
                        i++;
                        row[name] = i;
                    }
                    msg = Newtonsoft.Json.JsonConvert.SerializeObject(dt);
                }
            }
        }
        catch (Exception ex)
        {
            msg = $@"Error: {ex.Message}";
        }
        return msg;
    }
}