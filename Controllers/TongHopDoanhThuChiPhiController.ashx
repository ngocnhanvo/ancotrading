<%@ WebHandler Language="C#" Class="TongHopDoanhThuChiPhiController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;

public class TongHopDoanhThuChiPhiController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            default:
                switch (oper)
                {
                    case "del":
                        this.del(context);
                        break;
                    case "edit":
                        this.edit(context);
                        break;
                    case "add":
                        this.add(context);
                        break;
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public string removeSpace(string a)
    {
        if (string.IsNullOrWhiteSpace(a))
            a = "0";
        return a.Replace(" ", "");
    }

    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        var id = context.Request.Form["id"];
        var xuongId = context.Request.Form["xuongId"];
        var nam = int.Parse(context.Request.Form["nam"]);
        var thang = int.Parse(context.Request.Form["thang"]);
        var noDauNamStr = removeSpace(context.Request.Form["noDauNam"]);
        var noDauNam = string.IsNullOrEmpty(noDauNamStr) ? 0 : decimal.Parse(noDauNamStr);
        var lst = (from o in db.rpt_tonghopdoanhthuchiphis
                   where
                        o.nam.Equals(nam)
                        & o.thang.Equals(thang)
                        & o.xuongId.Equals(xuongId)
                        & !o.rpt_tonghopdoanhthuchiphi_id.Equals(id)
                   select new { o.rpt_tonghopdoanhthuchiphi_id });

        if (lst.Count() != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Đã tồn tại!");
        }
        else
        {
            var m = db.rpt_tonghopdoanhthuchiphis.Single(p => p.rpt_tonghopdoanhthuchiphi_id.Equals(id));
            m.xuongId = xuongId;
            m.nam = nam;
            m.thang = thang;
            m.noDauNam = thang == 1 ? noDauNam : 0;
            m.chiPhiHCNS = decimal.Parse(removeSpace(context.Request.Form["chiPhiHCNS"]));
            m.chiPhiXuatKhau = decimal.Parse(removeSpace(context.Request.Form["chiPhiXuatKhau"]));
            m.chiTienMatKhac = decimal.Parse(removeSpace(context.Request.Form["chiTienMatKhac"]));
            m.cuocGuiMauKiemDinh = decimal.Parse(removeSpace(context.Request.Form["cuocGuiMauKiemDinh"]));
            m.dsoVTXuatChoBPCtyKhac = decimal.Parse(removeSpace(context.Request.Form["dsoVTXuatChoBPCtyKhac"]));
            m.khieuNai = 0;
            m.luongCN = decimal.Parse(removeSpace(context.Request.Form["luongCN"]));
            m.luongNV = decimal.Parse(removeSpace(context.Request.Form["luongNV"]));
            m.phiCDBHXHCN = decimal.Parse(removeSpace(context.Request.Form["phiCDBHXHCN"]));
            m.phiCDBHXHNV = decimal.Parse(removeSpace(context.Request.Form["phiCDBHXHNV"]));
            m.thuongLeTetNV = decimal.Parse(removeSpace(context.Request.Form["thuongLeTetNV"]));
            m.thuongLeTetCN = decimal.Parse(removeSpace(context.Request.Form["thuongLeTetCN"]));
            m.tienPheLieu = decimal.Parse(removeSpace(context.Request.Form["tienPheLieu"]));

            m.mota = context.Request.Form["mota"];
            m.hoatdong = hd;
            m.nguoicapnhat = UserUtils.getUser(context);
            m.ngaycapnhat = DateTime.Now;
            db.SubmitChanges();
        }
    }

    public void add(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        var xuongId = context.Request.Form["xuongId"];
        var nam = int.Parse(context.Request.Form["nam"]);
        var thang = int.Parse(context.Request.Form["thang"]);
        var noDauNamStr = removeSpace(context.Request.Form["noDauNam"]);
        var noDauNam = string.IsNullOrEmpty(noDauNamStr) ? 0 : decimal.Parse(noDauNamStr);

        var lst = from o in db.rpt_tonghopdoanhthuchiphis where o.nam.Equals(nam) & o.thang.Equals(thang) select o;
        if (lst.Count() != 0)
        {
            jqGridHelper.Utils.writeResult(0, "Đã có code chủng loại này!");
        }
        else
        {
            var mnu = new rpt_tonghopdoanhthuchiphi();
            mnu.rpt_tonghopdoanhthuchiphi_id = Helper.getNewId();
            mnu.nam = nam;
            mnu.thang = thang;
            mnu.xuongId = xuongId;
            mnu.noDauNam = thang == 1 ? noDauNam : 0;
            mnu.chiPhiHCNS = decimal.Parse(removeSpace(context.Request.Form["chiPhiHCNS"]));
            mnu.chiPhiXuatKhau = decimal.Parse(removeSpace(context.Request.Form["chiPhiXuatKhau"]));
            mnu.chiTienMatKhac = decimal.Parse(removeSpace(context.Request.Form["chiTienMatKhac"]));
            mnu.cuocGuiMauKiemDinh = decimal.Parse(removeSpace(context.Request.Form["cuocGuiMauKiemDinh"]));
            mnu.dsoVTXuatChoBPCtyKhac = decimal.Parse(removeSpace(context.Request.Form["dsoVTXuatChoBPCtyKhac"]));
            mnu.khieuNai = 0;
            mnu.luongCN = decimal.Parse(removeSpace(context.Request.Form["luongCN"]));
            mnu.luongNV = decimal.Parse(removeSpace(context.Request.Form["luongNV"]));
            mnu.phiCDBHXHCN = decimal.Parse(removeSpace(context.Request.Form["phiCDBHXHCN"]));
            mnu.phiCDBHXHNV = decimal.Parse(removeSpace(context.Request.Form["phiCDBHXHNV"]));
            mnu.thuongLeTetNV = decimal.Parse(removeSpace(context.Request.Form["thuongLeTetNV"]));
            mnu.thuongLeTetCN = decimal.Parse(removeSpace(context.Request.Form["thuongLeTetCN"]));
            mnu.tienPheLieu = decimal.Parse(removeSpace(context.Request.Form["tienPheLieu"]));
            mnu.mota = context.Request.Form["mota"];
            mnu.hoatdong = hd;
            mnu.nguoitao = UserUtils.getUser(context);
            mnu.nguoicapnhat = UserUtils.getUser(context);
            mnu.ngaytao = DateTime.Now;
            mnu.ngaycapnhat = DateTime.Now;

            db.rpt_tonghopdoanhthuchiphis.InsertOnSubmit(mnu);
            db.SubmitChanges();
        }
    }

    public void del(HttpContext context)
    {
        var id = context.Request.Form["id"];
        id = id.Insert(0, "'");
        id = id.Insert(id.Length, "'");
        id = id.Replace(",", "','");
        var sql = "delete rpt_tonghopdoanhthuchiphi where rpt_tonghopdoanhthuchiphi_id IN (" + id + ")";
        mdbc.ExcuteNonQuery(sql);
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";

        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = "SELECT COUNT(1) AS count FROM rpt_tonghopdoanhthuchiphi cl where 1=1 {0} ";
        sqlCount = string.Format(sqlCount, filter);

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

        var orderBy = sidx + " " + sord;
        if (sidx.Equals("") || sidx == null)
        {
            orderBy = "ncc.ma_dtkd, cl.nam desc, cl.thang desc";
        }

        string strsql = string.Format(@"
            select * from (
                select 
                    cl.rpt_tonghopdoanhthuchiphi_id, ncc.ma_dtkd, cl.noDauNam, cl.nam, cl.thang, cl.dsoVTXuatChoBPCtyKhac, 
                    cl.tienPheLieu, cl.chiPhiXuatKhau, cl.chiPhiHCNS, cl.luongNV, cl.luongCN, 
                    cl.phiCDBHXHNV, cl.phiCDBHXHCN, cl.thuongLeTetNV, cl.thuongLeTetCN, 
                    cl.chiTienMatKhac, cl.khieuNai, cl.cuocGuiMauKiemDinh, 
                    cl.ngaytao, cl.nguoitao, cl.ngaycapnhat, cl.nguoicapnhat, cl.mota, cl.hoatdong,
                    ROW_NUMBER() OVER (ORDER BY {0}) as RowNum
                FROM rpt_tonghopdoanhthuchiphi cl 
                left join md_doitackinhdoanh ncc on ncc.md_doitackinhdoanh_id = cl.xuongId
                where 1=1 {1}
            )P 
            where RowNum > @start AND RowNum < @end
            order by P.RowNum
            ",
            orderBy,
            filter
        );
        strsql = string.Format(strsql, filter);
        //throw new ArgumentNullException(strsql);

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row[0] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[1] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[2] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[3] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[4] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[5] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[6] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[7] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[8] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[9] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[10] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[11] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[12] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[13] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[14] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[15] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[16] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[17] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[18].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[19] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row[20].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row[21] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[22] + "]]></cell>";
            xml += "<cell><![CDATA[" + row[23] + "]]></cell>";
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
