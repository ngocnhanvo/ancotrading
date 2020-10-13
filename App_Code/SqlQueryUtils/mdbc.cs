using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Data.SqlClient;
using System.Web.Configuration;


public static class mdbc
{
    // Lay chuoi ket noi trong web.config
    // Tao va tra ve doi tuong SqlConnection
    public static SqlConnection GetConnection
    {
        get
        {
            String str = WebConfigurationManager.ConnectionStrings["anco_test_importConnectionString"].ConnectionString;
            SqlConnection cnn  = new SqlConnection(str);
            return cnn;
        }
    }

    public static SqlConnection GetLinqConnection
    {
        get
        {
            LinqDBDataContext db = new LinqDBDataContext();
            return new SqlConnection(db.Connection.ConnectionString);
        }
    }

    /*public static SqlCommand CreateCommand(String sql, params object[] nameValue)
    {
        SqlCommand Command = new SqlCommand(sql, mdbc.GetConnection);
        Command.CommandType = CommandType.Text;
        for (int i = 0; i < nameValue.Length; i+=2)
        {
            Command.Parameters.AddWithValue(nameValue[i].ToString(), nameValue[i + 1].ToString());
        }
        return Command;
    }

    public static SqlCommand CreateCommand(String sql, bool procdure, params object[] nameValue)
    {
        SqlCommand Command = new SqlCommand(sql, mdbc.GetConnection);
        Command.CommandType = CommandType.StoredProcedure;
        for (int i = 0; i < nameValue.Length; i += 2)
        {
            Command.Parameters.AddWithValue(nameValue[i].ToString(), nameValue[i + 1].ToString());
        }
        return Command;
    }

    public static DataTable Fill(DataTable dt, String sql, params object[] nameValue)
    {
        SqlCommand cmd = mdbc.CreateCommand(sql, nameValue);
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(dt);
        return dt;
    }

    public static DataTable Fill(DataTable dt, String sql, bool procdure, params object[] nameValue)
    {
        SqlCommand cmd = mdbc.CreateCommand(sql, true, nameValue);
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(dt);
        return dt;
    }

    public static DataTable GetData(String sql, params object[] nameValue)
    {
        return Fill(new DataTable(), sql, nameValue);
    }

    public static DataTable GetDataFromProcedure(String sql, params object[] nameValue)
    {
        return Fill(new DataTable(), sql, true, nameValue);
    }

    public static int ExcuteNonQuery(String sql, params object[] nameValue)
    {
        SqlCommand cmd = mdbc.CreateCommand(sql,  nameValue);
        cmd.CommandTimeout = 1000;
                cmd.Connection.Open();
                int rows = cmd.ExecuteNonQuery();
                cmd.Connection.Close();
        return rows;    
    }

    public static int ExcuteNonProcedure(String sql, params object[] nameValue)
    { 
        SqlCommand cmd = mdbc.CreateCommand(sql, true, nameValue);
        cmd.Connection.Open();
        int rows = cmd.ExecuteNonQuery();
        cmd.Connection.Close();
        return rows;
    }

    public static SqlDataReader ExecuteReader(String sql, params object[] nameValue)
    {
        SqlCommand cmd = CreateCommand(sql,nameValue);
        cmd.Connection.Open();
        SqlDataReader rd = cmd.ExecuteReader();
        
        return rd;
    }

    // Lấy một giá trị đơn dựa vào câu lệnh sql và danh sách tham số
    public static object ExecuteScalar(String sql, params object[] parameters)
    {
        SqlCommand cmd = CreateCommand(sql, parameters);
        cmd.Connection.Open();
        object value = cmd.ExecuteScalar();
        cmd.Connection.Close();
        return value;
    }

    // Lấy một giá trị đơn dựa vào câu lệnh sql và danh sách tham số
    public static object ExecuteScalarProcedure(String sql, params object[] parameters)
    {
        SqlCommand cmd = CreateCommand(sql, true, parameters);
        cmd.Connection.Open();
        object value = cmd.ExecuteScalar();
        cmd.Connection.Close();
        return value;
    }*/
	
	public static SqlCommand CreateCommand(String sql, params object[] nameValue)
    {
        SqlCommand Command = new SqlCommand(sql, mdbc.GetConnection);
        Command.CommandType = CommandType.Text;
        for (int i = 0; i < nameValue.Length; i+=2)
        {
            Command.Parameters.AddWithValue(nameValue[i].ToString(), nameValue[i + 1].ToString());
        }
        return Command;
    }
	
	public static SqlCommand CreateCommand2(String sql, params object[] nameValue)
    {
        SqlCommand Command = new SqlCommand(sql, mdbc.GetConnection);
        Command.CommandType = CommandType.Text;
        for (int i = 0; i < nameValue.Length; i+=3)
        {
            Command.Parameters.AddWithValue(nameValue[i].ToString(), nameValue[i + 1].ToString(), nameValue[i + 2].ToString());
        }
        return Command;
    }

    public static SqlCommand CreateCommand(String sql, bool procdure, params object[] nameValue)
    {
        SqlCommand Command = new SqlCommand(sql, mdbc.GetConnection);
        Command.CommandType = CommandType.StoredProcedure;
        for (int i = 0; i < nameValue.Length; i += 2)
        {
            Command.Parameters.AddWithValue(nameValue[i].ToString(), nameValue[i + 1].ToString());
        }
        return Command;
    }

    public static DataTable Fill(DataTable dt, String sql, params object[] nameValue)
    {
        SqlCommand cmd = mdbc.CreateCommand(sql, nameValue);
        cmd.CommandTimeout = 50000;
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(dt);
        return dt;
    }

    public static DataTable Fill(DataTable dt, String sql, bool procdure, params object[] nameValue)
    {
        SqlCommand cmd = mdbc.CreateCommand(sql, true, nameValue);
        cmd.CommandTimeout = 50000;
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(dt);
        return dt;
    }

    public static DataTable GetData(String sql, params object[] nameValue)
    {
        return Fill(new DataTable(), sql, nameValue);
    }

    public static DataTable GetDataFromProcedure(String sql, params object[] nameValue)
    {
        return Fill(new DataTable(), sql, true, nameValue);
    }

    public static int ExcuteNonQuery(String sql, params object[] nameValue)
    {
        SqlCommand cmd = mdbc.CreateCommand(sql,  nameValue);
        cmd.CommandTimeout = 50000;
                cmd.Connection.Open();
                int rows = cmd.ExecuteNonQuery();
                cmd.Connection.Close();
        return rows;    
    }

    public static int ExcuteNonProcedure(String sql, params object[] nameValue)
    { 
        SqlCommand cmd = mdbc.CreateCommand(sql, true, nameValue);
        cmd.CommandTimeout = 50000;
        cmd.Connection.Open();
        int rows = cmd.ExecuteNonQuery();
        cmd.Connection.Close();
        return rows;
    }

    public static SqlDataReader ExecuteReader(String sql, params object[] nameValue)
    {
        SqlCommand cmd = CreateCommand(sql,nameValue);
        cmd.CommandTimeout = 50000;
        cmd.Connection.Open();
        SqlDataReader rd = cmd.ExecuteReader();
        
        return rd;
    }

    // Lấy một giá trị đơn dựa vào câu lệnh sql và danh sách tham số
    public static object ExecuteScalar(String sql, params object[] parameters)
    {
        SqlCommand cmd = CreateCommand(sql, parameters);
        cmd.CommandTimeout = 50000;
        cmd.Connection.Open();
        object value = cmd.ExecuteScalar();
        cmd.Connection.Close();
        return value;
    }
	
	public static object ExecuteScalar2(String sql, params object[] parameters)
    {
        SqlCommand cmd = CreateCommand2(sql, parameters);
        cmd.CommandTimeout = 50000;
        cmd.Connection.Open();
        object value = cmd.ExecuteScalar();
        cmd.Connection.Close();
        return value;
    }

    // Lấy một giá trị đơn dựa vào câu lệnh sql và danh sách tham số
    public static object ExecuteScalarProcedure(String sql, params object[] parameters)
    {
        SqlCommand cmd = CreateCommand(sql, true, parameters);
        cmd.CommandTimeout = 50000;
        cmd.Connection.Open();
        object value = cmd.ExecuteScalar();
        cmd.Connection.Close();
        return value;
    }
}
