<%@ WebHandler Language="C#" Class="DanhSachDatHangController" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
public class DanhSachDatHangController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Params["oper"];
        switch (action)
        {
            case "getoption":
                this.getSelectOption(context);
                break;
            default:
                switch (oper)
                {
                    case "loadPXK":
                        this.loadPXK(context);
                        break;
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public void loadPXK(HttpContext context)
    {
        string msg = "";
        string poId = context.Request.QueryString["poId"];
        var item = new Dictionary<string, object>();
        string madtkd = "ANCO1";
        try
        {
            if (string.IsNullOrWhiteSpace(poId))
                msg = "[]";
            else
            {
                item["dsdhId"] = poId;

                msg = Extension.GetModule(
                    Extension.API_ALL(madtkd) + "?oper=getPhieuXKs",
                                    item
                                );
            }

            var datas = JsonConvert.DeserializeObject<List<DataAcess.md_xuatban>>(msg);
            int records = datas.Count;
            string xmlDT = "";
            foreach (var row in datas)
            {
                var dxhs = (from a in db.c_dongnhapxuats
                            join b in db.c_nhapxuats on a.c_nhapxuat_id equals b.c_nhapxuat_id
                            where a.md_xuatban_id == row.md_xuatban_id &
                            b.md_trangthai_id == Helper.HIEULUC &
                            b.md_loaichungtu_id == "NK" &
                            a.slthuc_nhapxuat > 0
                            select a).ToList();
                var tongsl = dxhs.Select(s => s.slthuc_nhapxuat.GetValueOrDefault(0)).Sum();
                if (tongsl < row.tongsl.GetValueOrDefault(0))
                {
                    xmlDT += "<row>";
                    xmlDT += "<cell><![CDATA[" + row.md_xuatban_id + "]]></cell>";
                    xmlDT += "<cell><![CDATA[" + row.sochungtu + "]]></cell>";
                    xmlDT += "<cell><![CDATA[" + row.ngaychuyen.Value.ToString("dd/MM/yyyy") + "]]></cell>";
                    xmlDT += "<cell><![CDATA[" + row.so_cont + "]]></cell>";
                    xmlDT += "<cell><![CDATA[" + row.so_seal + "]]></cell>";
                    xmlDT += "<cell><![CDATA[" + row.loai_cont + "]]></cell>";
                    xmlDT += "</row>";
                }
                else
                {
                    records--;
                }
            }


            string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
            xml += "<rows>";
            xml += "<page>" + 1 + "</page>";
            xml += "<total>" + 1 + "</total>";
            xml += "<records>" + records + "</records>";
            xml += xmlDT;
            xml += "</rows>";
            msg = xml;
        }
        catch (Exception ex)
        {
            msg = ex.ToString();
        }

        context.Response.Write(msg);
    }

    public void getSelectOption(HttpContext context)
    {
        String sql = "select c_danhsachdathang_id, sochungtu from c_danhsachdathang where hoatdong = 1";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        var laAB = context.Request.QueryString["laAB"].removeAllSpaceOrTrimText(true) == "1";

        bool isadmin = db.nhanviens.FirstOrDefault(p => p.manv.Equals(UserUtils.getUser(context))).isadmin.Value;

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        // phân quyền theo nhóm
        String manv = UserUtils.getUser(context);
        String strAccount = "";
        System.Collections.Generic.List<String> lstAccount = LinqUtils.GetUserListInGroup(manv);
        foreach (String item in lstAccount)
        {
            strAccount += String.Format(", '{0}'", item);
        }
        strAccount = String.Format("'{0}'{1}", manv, strAccount);

        if (!isadmin)
            filter += $"AND dsdh.nguoitao IN({strAccount})";
        if(laAB)
            filter += $"AND dtkd.ma_dtkd = 'ANCO1'";

        String sqlCount = $@"
            SELECT COUNT(*) AS count
            FROM c_danhsachdathang dsdh, c_donhang dh, md_doitackinhdoanh dtkd
            WHERE 
                dsdh.c_donhang_id = dh.c_donhang_id
                AND dsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id 
                AND dsdh.md_trangthai_id = 'HIEULUC' {filter} 
                AND dsdh.c_danhsachdathang_id IN (select distinct ddsdh.c_danhsachdathang_id from c_dongdsdh ddsdh where ddsdh.sl_conlai > 0)
        ";

        int page = int.Parse(context.Request.QueryString["page"]);
        int limit = int.Parse(context.Request.QueryString["rows"]);
        String sidx = context.Request.QueryString["sidx"];
        String sord = context.Request.QueryString["sord"];
        int total_page;
        int count = (int)mdbc.ExecuteScalar(sqlCount);
        int start, end;

        if (count > 0)
        {
            total_page = (int)Math.Ceiling(1.0 * count / limit);
        }
        else
        {
            total_page = 0;
        }

        if (page > total_page) page = total_page;
        start = limit * page - limit;
        end = (page * limit) + 1;

        if (sidx.Equals("") || sidx == null)
        {
            sidx = "dsdh.c_danhsachdathang_id";
        }

        string strsql = $@"
            select * from (
                select 
                    dsdh.c_danhsachdathang_id, dsdh.sochungtu sodsdh, dsdh.ngaylap,
                    dsdh.hangiaohang_po, dsdh.nguoi_phutrach, dsdh.nguoi_dathang,
                    dh.sochungtu as sodh, dsdh.so_po, dsdh.md_trangthai_id, dsdh.huongdanlamhang, dsdh.ngaytao,
                    dsdh.nguoitao, dsdh.ngaycapnhat, dsdh.nguoicapnhat, dsdh.mota, dsdh.hoatdong,
                    ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
                FROM c_danhsachdathang dsdh, c_donhang dh, md_doitackinhdoanh dtkd
                WHERE 
                    dsdh.c_donhang_id = dh.c_donhang_id 
                    AND dsdh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
                    AND dsdh.md_trangthai_id = 'HIEULUC' {filter} 
                    AND dsdh.c_danhsachdathang_id IN (select distinct ddsdh.c_danhsachdathang_id from c_dongdsdh ddsdh where ddsdh.sl_conlai > 0)
            )P 
            WHERE RowNum > @start AND RowNum < @end
        ";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row[0] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[1] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[2].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[3].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[4] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[5] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[6] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[7] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[8] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[9] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[10].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[11] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[12].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[13] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[14] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[15] + "]]></cell>";
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
