using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.Linq;



public partial class Linq : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    protected void updateLinq_Click(object sender, EventArgs e)
    {
        ADmin_UpdateLinq.Exec_UpdateLinq(Context);
        result.InnerHtml = $"Updated Linq on {DateTime.Now.ToString("dd/MM/yyyy HH:mm")}";
    }

    protected void openmssql_Click(object sender, EventArgs e)
    {
        Response.Redirect("mssql.aspx");
    }

    protected void pullcode_Click(object sender, EventArgs e)
    {
        var filepath = $"{AppDomain.CurrentDomain.BaseDirectory}";
        filepath += $"\\App_Data\\pull_code.bat";

        System.Diagnostics.Process process = new System.Diagnostics.Process();
        process.StartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
        process.StartInfo.FileName = filepath;
        process.EnableRaisingEvents = true;
        process.StartInfo.UseShellExecute = false;
        process.StartInfo.CreateNoWindow = true;
        process.StartInfo.RedirectStandardOutput = true;
        process.StartInfo.RedirectStandardError = true;
        process.StartInfo.RedirectStandardInput = true;

        var stdOutput = new System.Text.StringBuilder();
        process.OutputDataReceived += (sender1, args) => stdOutput.AppendLine(args.Data);
        process.ErrorDataReceived += (sender1, args) => stdOutput.AppendLine(args.Data);
        process.Start();
        process.BeginErrorReadLine();
        process.BeginOutputReadLine();
        process.WaitForExit();
        result.InnerHtml = stdOutput.ToString();
    }
}
