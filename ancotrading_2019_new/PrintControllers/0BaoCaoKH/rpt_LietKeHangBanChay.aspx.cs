using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using NPOI.HSSF.Util;

public partial class ReportWizard_RptKhachHang_rpt_LietKeHangBanChay : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string startdate = Request.QueryString["startdate"];
        string enddate = Request.QueryString["enddate"];
        startdate = startdate + " 00:00:00";
        enddate = enddate + " 23:59:59";
        string hehang_id = Request.QueryString["hehang_id"];
        if (String.IsNullOrEmpty(hehang_id))
        {
            hehang_id = "null";
        }
        else
        {
            hehang_id = string.Format("'{0}'", hehang_id);
        }

        string dtkd_id = Request.QueryString["dtkd_id"];
        if (String.IsNullOrEmpty(dtkd_id))
        {
            dtkd_id = "null";
        }
        else
        {
            dtkd_id = string.Format("'{0}'", dtkd_id);
        }

        string sql = string.Format(@"
            declare @tungay datetime, @denngay datetime 
		    declare @table table (
                makh nvarchar(100),
                sl int,
                ma_dtkd nvarchar(100),
                tungay datetime,
                denngay datetime
            )

            set @tungay = (select convert(datetime,'{0}',103))
		    set @denngay = (select convert(datetime,'{1}', 103))
            insert into @table
            exec [dbo].[rpt_lietkehangbanchay] @tungay, @denngay, {2}, {3}

            select A.makh, A.sl, A.ma_dtkd
            from @table A
            order by A.makh, A.ma_dtkd
        ", startdate, enddate, hehang_id, dtkd_id);

        DataTable dt = mdbc.GetData(sql);
        if (dt.Rows.Count != 0)
        {
            this.CreateWorkBookPO(dt, Request.QueryString["startdate"], Request.QueryString["enddate"]);
        }
        else
        {
            Response.Write("<h3>Đơn hàng không có dữ liệu</h3>");
        }
    }

    public void CreateWorkBookPO(DataTable dt, string tungay, string denngay)
    {
        HSSFWorkbook hssfworkbook = new HSSFWorkbook();
        ISheet s1 = hssfworkbook.CreateSheet("Sheet1");
        HSSFSheet hssfsheet = (HSSFSheet)s1;
        ExportExcel export = new ExportExcel(hssfworkbook, 0, 3);
        int row = export.SetHeaderAnco(hssfsheet, "LIỆT KÊ MẶT HÀNG BÁN CHẠY(THEO INVOICE)", tungay, denngay, true);

        #region Header Column
        int widthDF = 7000;
        List<ItemValue> lstHeader = new List<ItemValue>();
        var item = new ItemValue
        {
            item = "STT",
            value = "rowNum",
            witdh = 2000
        };
        lstHeader.Add(item);

        item = new ItemValue
        {
            item = "MÃ KH",
            value = "makh",
            witdh = widthDF
        };
        lstHeader.Add(item);

        item = new ItemValue
        {
            item = "SL",
            value = "sl",
            witdh = widthDF
        };
        lstHeader.Add(item);

        item = new ItemValue
        {
            item = "KHÁCH HÀNG",
            value = "ma_dtkd",
            witdh = 10000
        };
        lstHeader.Add(item);

        IRow rowColumnHeader = s1.CreateRow(row);
        rowColumnHeader.HeightInPoints = 40;
        for (int j = 0; j < lstHeader.Count; j++)
        {
            rowColumnHeader.CreateCell(j).SetCellValue(lstHeader[j].item);
            rowColumnHeader.GetCell(j).CellStyle = export.borderWrap;
            s1.SetColumnWidth(j, lstHeader[j].witdh);
        }
        row++;
        #endregion

        #region Set Table
        int start_sum = row + 1;
        string groupData = "";
        int countRG = 1;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            IRow row_t = s1.CreateRow(row);
            float height = 25;
            if (groupData != dt.Rows[i]["makh"].ToString())
            {
                row_t.HeightInPoints = height;
                for (int j = 0; j < lstHeader.Count; j++)
                {
                    var cell = row_t.CreateCell(j);
                    if (lstHeader[j].value == "rowNum")
                    {
                        cell.SetCellValue(countRG);
                        cell.CellStyle = export.bordercenterBold;
                    }
                    else if (lstHeader[j].value == "sl")
                    {
                        var sumSL = dt.AsEnumerable().Where(s => s.Field<string>("makh") == groupData).Sum(x => x.Field<int>("sl"));
                        cell.SetCellValue(int.Parse(sumSL.ToString()));
                        cell.CellStyle = export.borderrightBold;
                    }
                    else if (lstHeader[j].value == "makh")
                    {
                        groupData = dt.Rows[i][lstHeader[j].value].ToString();
                        cell.SetCellValue(groupData);
                        cell.CellStyle = export.borderleftBold;
                    }
                    else
                    {
                        cell.SetCellValue("");
                        cell.CellStyle = export.bordercenter;
                    }
                }
                countRG++;
                row++;
                row_t = s1.CreateRow(row);
            }
            
            for (int j = 0; j < lstHeader.Count; j++)
            {
                var cell = row_t.CreateCell(j);
                if (lstHeader[j].value == "sl")
                {
                    cell.SetCellValue(int.Parse(dt.Rows[i][lstHeader[j].value].ToString()));
                    cell.CellStyle = export.borderright;
                }
                else if (lstHeader[j].value == "ma_dtkd")
                {
                    string str = dt.Rows[i][lstHeader[j].value].ToString();
                    float heightMAX = export.MeasureTextHeight(str, lstHeader[j].witdh);
                    if (heightMAX > height)
                    {
                        height = heightMAX;
                    }
                    cell.SetCellValue(str);
                    cell.CellStyle = export.border;
                }
                else
                {
                    cell.SetCellValue("");
                    cell.CellStyle = export.bordercenter;
                }
            }
            row_t.HeightInPoints = height;
            row++;
        }
        int end_sum = row;
        #endregion

        hssfsheet = export.PrintExcel(hssfsheet, row);
        String saveAsFileName = String.Format("MatHangBanChayTheoINV-{0}.xls", DateTime.Now);
        export.SaveFile(hssfworkbook, saveAsFileName, Context);
    }
}
