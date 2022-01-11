using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.XPath;
using System.IO;
using System.Data;
using System.Xml.Serialization;
using System.Xml;
using System.Text.RegularExpressions;
using Newtonsoft.Json;
using System.Reflection;
using System.Net;
using System.Text;
using QRCoder;
/// <summary>
/// Summary description for Extension
/// </summary>
public static class Extension
{
    public static string fmtDate = "dd/MM/yyyy";
	public static string API_VINHGIA = System.Web.Configuration.WebConfigurationManager.AppSettings["API_VINHGIA"];
	public static string API_ANCO2 = System.Web.Configuration.WebConfigurationManager.AppSettings["API_ANCO2"];

    public static string ConvertXML(this DataTable dtMain, int page, int total, Int64 records)
    {
        DataSet ds = new DataSet();
        ds.DataSetName = "rows";
        dtMain.TableName = "row";
        List<int> columnDate = new List<int>();
        for (int i = 0; i < dtMain.Columns.Count; i++)
        {
            var type = dtMain.Columns[i].DataType;
            if (type == typeof(DateTime))
            {
                columnDate.Add(i);
            }
        }

        DataTable dt = dtMain.Clone();
        foreach (int typeDate in columnDate)
        {
            dt.Columns[typeDate].DataType = typeof(String);
        }

        foreach (DataRow row in dtMain.Rows)
        {
            dt.ImportRow(row);
        }

        for (int j = 0; j < dt.Rows.Count; j++)
        {
            DataRow row = dt.Rows[j];
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (j == 0)
                {
                    var type = dt.Columns[i].DataType;
                }
                dt.Columns[i].ReadOnly = false;

                if (string.IsNullOrEmpty(row[i].ToString()))
                    row[i] = string.Empty;
                else if (columnDate.Contains(i))
                {
                    DateTime? chkDate = row[i].ToString().getDate();
                    if (chkDate.HasValue)
                        row[i] = chkDate.Value.ToString(fmtDate);
                }

                if (j == dt.Rows.Count - 1)
                {
                    dt.Columns[i].ColumnName = "cellVNNVNNVNNVNNVNNVNN" + i;
                }
            }
        }
        ds.Tables.Add(dt);
        string myXmlString = ds.GetXml();
        XmlDocument xml = new XmlDocument();
        xml.LoadXml(myXmlString);

        XmlNode nodeRecords = xml.CreateElement("records");
        nodeRecords.InnerText = records.ToString();
        xml.DocumentElement.PrependChild(nodeRecords);

        XmlNode nodeTotal = xml.CreateElement("total");
        nodeTotal.InnerText = total.ToString();
        xml.DocumentElement.PrependChild(nodeTotal);

        XmlNode nodePage = xml.CreateElement("page");
        nodePage.InnerText = page.ToString();
        xml.DocumentElement.PrependChild(nodePage);
        string xmlFinal = xml.OuterXml;
        for (int i = 0; i < dt.Columns.Count; i++)
        {
            xmlFinal = xmlFinal.SafeReplace("cellVNNVNNVNNVNNVNNVNN" + i, "cell", true);
        }
        return xmlFinal;
    }

    public static DateTime? getDate(this string t)
    {
        DateTime tempDate;
        DateTime.TryParse(t, out tempDate);
        return tempDate;
    }

    public static string ConvertJson(this DataTable t, int page, int total, Int64 records)
    {
        var result = new
        {
            page = page,
            total = total,
            records = records,
            rows = t
        };
        return JsonConvert.SerializeObject(result);
    }

    public static string SafeReplace(this string input, string find, string replace, bool matchWholeWord)
    {
        string textToFind = matchWholeWord ? string.Format(@"\b{0}\b", find) : find;
        return Regex.Replace(input, textToFind, replace);
    }
	
	public static decimal DecRound(this decimal dtMain, int dec)
    {
        dtMain = Decimal.Round(dtMain, dec);
        return dtMain;
	}

    public static T Cast<T>(this Object myobj)
    {
        Type objectType = myobj.GetType();
        Type target = typeof(T);
        var x = Activator.CreateInstance(target, false);
        var z = from source in objectType.GetMembers().ToList()
                where source.MemberType == MemberTypes.Property
                select source;
        var d = from source in target.GetMembers().ToList()
                where source.MemberType == MemberTypes.Property
                select source;
        List<MemberInfo> members = d.Where(memberInfo => d.Select(c => c.Name)
           .ToList().Contains(memberInfo.Name)).ToList();
        PropertyInfo propertyInfo;
        object value;
        foreach (var memberInfo in members)
        {
            propertyInfo = typeof(T).GetProperty(memberInfo.Name);
            try
            {
                value = myobj.GetType().GetProperty(memberInfo.Name).GetValue(myobj, null);

                propertyInfo.SetValue(x, value, null);
            }
            catch
            {

            }
        }
        return (T)x;
    }

	public static void CopyPropertiesTo<T, TU>(this T source, TU dest)
    {
        var sourceProps = typeof(T).GetProperties().Where(x => x.CanRead).ToList();
        var destProps = typeof(TU).GetProperties()
                .Where(x => x.CanWrite)
                .ToList();

        foreach (var sourceProp in sourceProps)
        {
            if (destProps.Any(x => x.Name == sourceProp.Name))
            {
                var p = destProps.First(x => x.Name == sourceProp.Name);
                if (p.CanWrite)
                { // check if the property can be set or no.
                    p.SetValue(dest, sourceProp.GetValue(source, null), null);
                }
            }

        }
    }
	
	public static string DecodeHTML(string text)
    {
        try { text = text.Replace("0ψ0", "<").Replace("1Ψ1", ">"); }
        catch { }
        return text;
    }

    public static string EncodeHTML(string text)
    {
        try { text = text.Replace("<", "0ψ0").Replace(">", "1Ψ1"); }
        catch { }
        return text;
    }
	
	public static string GetModule(string link, Dictionary<string, object> jsonData)
    {
        var myUri = new Uri(link);
        string jsonString = JsonConvert.SerializeObject(jsonData);
        var request = WebRequest.Create(myUri);
        request.ContentType = "application/x-www-form-urlencoded";
        request.Method = "POST";
        string postData = string.Format(@"data={0}", jsonString);
        Stream reqStream = request.GetRequestStream();
        byte[] postArray = Encoding.UTF8.GetBytes(postData);
        reqStream.Write(postArray, 0, postArray.Length);
        reqStream.Close();
        var sr = new StreamReader(request.GetResponse().GetResponseStream());
        string result = sr.ReadToEnd();
        return result;
    }

    public static Dictionary<string, string> infoAncoPoterry()
    {
        var result = new Dictionary<string, string>();
        var json = File.ReadAllText(ExcuteSignalRStatic.mapPathSignalR("~/App_Data/JSON/ancopottery.com.json"));
        result = JsonConvert.DeserializeObject<Dictionary<string, string>>(json);
        return result;
    }

    public static void createQRCodeFromProduct(string ma_sanpham, QRCodeGenerator qrGenerator)
    {
        if(qrGenerator == null)
            qrGenerator = new QRCodeGenerator();

        var infoAncoPoterry = Extension.infoAncoPoterry();
        var link = string.Format(@"{0}/{1}", infoAncoPoterry["website"], infoAncoPoterry["detail"]);
        var folder = ExcuteSignalRStatic.mapPathSignalR(infoAncoPoterry["folderQRCode"]);
        var file = folder + "/" + ma_sanpham + ".jpg";
        link = link.Replace("[code]", ma_sanpham);
        var qrCode = qrGenerator.CreateQrCode(link, QRCodeGenerator.ECCLevel.M);

        if (File.Exists(file))
            File.Delete(file);

        using (var bitMap = qrCode.GetGraphic(20))
        {
            bitMap.Save(file, System.Drawing.Imaging.ImageFormat.Jpeg);
            bitMap.Dispose();
        }
    }
}