<%@ WebHandler Language="C#" Class="ProductWebController" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using NetServ.Net.Json;
using System.IO;
using System.Collections.Generic;
using jqGridHelper;
using System.Data;
using QRCoder;

public class ProductWebController : IHttpHandler
{
    public class productCatalog
    {
        public string code { get; set; }
        public string image { get; set; }
        public string shape { get; set; }
        public string title { get; set; }
        public string titleWeb { get; set; }
        public string titleSubWeb { get; set; }
        public string dacTinhCL { get; set; }
    }
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (oper)
        {
            case "getList":
                this.getList(context);
                break;
            case "upWeb":
                this.upWeb(context);
                break;
            case "del":
                this.del(context);
                break;
            default:
                this.load(context);
                break;
        }
    }

    public void getList(HttpContext context)
    {
        string msg = "";

        try
        {
            var title = context.Request.Form["title"].ToLower().Trim();
            var a1 = context.Request.Form["a1"];
            var a2 = context.Request.Form["a2"];
            var a3 = context.Request.Form["a3"];
            var a4 = context.Request.Form["a4"];
            var idPresent = context.Request.Form["idPresent"].ToLower().Trim();
            var code = context.Request.Form["code"].ToLower().Trim();
            md_chungloai chungloai = null;
            if (!string.IsNullOrWhiteSpace(code))
            {
                var spCode = db.md_sanphams.Where(s => s.ma_sanpham.ToLower().Trim() == code).FirstOrDefault();
                if (spCode != null)
                {
                    chungloai = db.md_chungloais.Where(s => s.md_chungloai_id == spCode.md_chungloai_id).FirstOrDefault();
                }
            }
            else
                chungloai = db.md_chungloais.Where(s => s.ta_ngan.ToLower().Trim() == title).FirstOrDefault();

            if (chungloai == null)
            {
                msg = "0" + string.Format(@"""{0}"" Collecttion is not found", title);
            }
            else
            {

                var sps = db.md_sanphams
                        .Where(s => s.md_chungloai_id == chungloai.md_chungloai_id & s.website == true & s.hoatdong == true & s.trangthai == "DHD")
                        .OrderBy(s => s.ma_sanpham)
                        .Select(s => new productCatalog { code = s.ma_sanpham, image = "", shape = s.md_kieudang_id, titleWeb = "", titleSubWeb = "", dacTinhCL = "" })
                        .ToList();

                if(!string.IsNullOrWhiteSpace(a1))
                {
                    a1 = a1.Trim();
                    sps = sps.Where(s => s.code.Substring(0, 2).StartsWith(a1)).ToList();
                }

                if(!string.IsNullOrWhiteSpace(a2))
                {
                    a2 = a2.Trim();
                    sps = sps.Where(s => s.code.Substring(3, 5).StartsWith(a2)).ToList();
                }

                if(!string.IsNullOrWhiteSpace(a3))
                {
                    var cloneSps = new List<productCatalog>();
                    a3 = a3.Trim();
                    var arrA3 = a3.Split('-');
                    foreach (var item in arrA3)
                        cloneSps.AddRange(sps.Where(s => s.code.Substring(9, 2).StartsWith(item)).ToList());

                    sps = cloneSps;
                }

                if(!string.IsNullOrWhiteSpace(a4))
                {
                    a4 = a4.Trim();
                    sps = sps.Where(s => s.code.Substring(12, 2).StartsWith(a4)).ToList();
                }

                foreach (var sp in sps)
                {
                    sp.image = ExcuteSignalRStatic.getImageProductWeb(sp.code);
                    sp.shape = db.md_kieudangs.Where(s => s.md_kieudang_id == sp.shape).Select(s => s.ten_ta).FirstOrDefault();
                    sp.titleWeb = chungloai.titleWeb;
                    sp.titleSubWeb = chungloai.titleSubWeb;
                    sp.dacTinhCL = chungloai.dacTinhCL;
                    sp.title = chungloai.ta_ngan == null ? "" : chungloai.ta_ngan;

                    if (sp.shape == "Rd.")
                        sp.shape = "Round Shape";
                    else if (sp.shape == "Sq.")
                        sp.shape = "Squard Shape";
                    else
                        sp.shape = sp.shape + " Shape";
                }

                msg = "1" + Newtonsoft.Json.JsonConvert.SerializeObject(sps);
            }
        }
        catch(Exception ex)
        {
            msg = "0" + ex.Message;
        }

        context.Response.Write(msg);
    }

    public void upWeb(HttpContext context)
    {
        var data = context.Request.Form["data"];
        var sps = Newtonsoft.Json.JsonConvert.DeserializeObject<List<md_sanpham>>(data);
        foreach(var sp in sps)
        {
            var spM = db.md_sanphams.Where(s => s.md_sanpham_id == sp.md_sanpham_id).FirstOrDefault();
            if (spM != null)
                spM.website = true;
        }
        db.SubmitChanges();
    }

    public void del(HttpContext context)
    {
        string msg = "";
        try
        {
            var ids = context.Request.Form["id"].Split(',').Where(s => !string.IsNullOrWhiteSpace(s)).ToList();

            foreach (var id_ in ids)
            {
                var sp = db.md_sanphams.Where(s => s.md_sanpham_id == id_).FirstOrDefault();

                if (sp == null)
                {
                    msg = "Dòng đang chọn không tồn tại, hãy làm mới dữ liệu.";
                }
                else
                {
                    sp.website = false;
                }
            }

            if(msg.Length <= 0)
                db.SubmitChanges();
        }
        catch(Exception ex)
        {
            msg = ex.Message;
        }

        if(msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Gỡ sản phẩm khỏi website thành công");
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
            Filter f = Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }


        String sqlCount = string.Format(@"
            SELECT COUNT(1) AS count 
            FROM 
	            md_sanpham sp 
                left join md_chungloai cl on sp.md_chungloai_id = cl.md_chungloai_id
	            left join md_doitackinhdoanh ncc on sp.nhacungung = ncc.md_doitackinhdoanh_id
	            left join md_chucnang cn on sp.md_chucnang_id = cn.md_chucnang_id
	            left join md_nhomnangluc nnl on sp.md_nhomnangluc_id = nnl.md_nhomnangluc_id
	            left join md_cangbien cb on sp.md_cangbien_id = cb.md_cangbien_id
	            left join md_donvitinhsanpham dvt on sp.md_donvitinhsanpham_id = dvt.md_donvitinhsanpham_id
	            left join md_kieudang kd on sp.md_kieudang_id = kd.md_kieudang_id
                left join md_hscode hscode on sp.md_hscode_id = hscode.md_hscode_id
            WHERE 
	            1=1
                {0}
                AND sp.hoatdong = 1 
                AND sp.website = 1 
                AND sp.trangthai in ('DHD')
            "
            , filter
        );

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
            sidx = "sp.ma_sanpham";
        }

        string strsql = string.Format(@"
            select * from( 
                SELECT
	                sp.md_sanpham_id, sp.trangthai, sp.ma_sanpham
	                , kd.ten_tv as ten_kd
	                , kd.ma_kieudang as ma_kd
	                , cn.ten_tv as ten_cn
	                , cn.ma_chucnang as ma_cn
	                , dvt.ten_dvt as tendvt
	                , sp.mota_tiengviet,  sp.mota_tienganh
	                , sp.L_inch, sp.W_inch, sp.H_inch, sp.L_cm, sp.W_cm, sp.H_cm, sp.Trongluong, sp.dientich, sp.thetich
	                , (nnl.hehang + '('+ nnl.nhom +')') as nangluc
	                , cl.code_cl, sp.ghichu, ncc.ma_dtkd
	                , cb.ten_cangbien as cangbien, hscode.ma_hscode, hscode.hscode, sp.chucnangsp, sp.ngayxacnhan, sp.hinhthucban
	                , sp.ngaytao, sp.nguoitao, sp.ngaycapnhat, sp.nguoicapnhat, sp.mota, sp.hoatdong
	                , ROW_NUMBER() OVER (ORDER BY {0} {1} ) as RowNum 
                FROM 
	                md_sanpham sp 
                    left join md_chungloai cl on sp.md_chungloai_id = cl.md_chungloai_id
	                left join md_doitackinhdoanh ncc on sp.nhacungung = ncc.md_doitackinhdoanh_id
	                left join md_chucnang cn on sp.md_chucnang_id = cn.md_chucnang_id
	                left join md_nhomnangluc nnl on sp.md_nhomnangluc_id = nnl.md_nhomnangluc_id
	                left join md_cangbien cb on sp.md_cangbien_id = cb.md_cangbien_id
	                left join md_donvitinhsanpham dvt on sp.md_donvitinhsanpham_id = dvt.md_donvitinhsanpham_id
	                left join md_kieudang kd on sp.md_kieudang_id = kd.md_kieudang_id                     
                    left join md_hscode hscode on sp.md_hscode_id = hscode.md_hscode_id	            
                WHERE 
	                1=1 {2}
                    AND sp.hoatdong = 1 
                    AND sp.website = 1
                    AND sp.trangthai in ('DHD')
            )P WHERE RowNum > @start AND RowNum < @end"
            , sidx
            , sord
            , filter
        );

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["md_sanpham_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["trangthai"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["md_sanpham_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_sanpham"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_kd"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_kd"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ten_cn"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_cn"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["mota_tiengviet"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["mota_tienganh"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["tendvt"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["L_inch"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["W_inch"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["H_inch"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["L_cm"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["W_cm"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["H_cm"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["trongluong"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["dientich"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["thetich"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nangluc"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["code_cl"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_dtkd"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["cangbien"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_hscode"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hscode"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["chucnangsp"] + "]]></cell>";

            var nxn = row["ngayxacnhan"] + "";
            xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", string.IsNullOrEmpty(nxn) ? "" : DateTime.Parse(nxn).ToString("dd/MM/yyyy"));

            xml += "<cell><![CDATA[" + row["hinhthucban"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ghichu"] + "]]></cell>";

            var ngaytao = row["ngaytao"] + "";
            xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", string.IsNullOrEmpty(ngaytao) ? "" : DateTime.Parse(ngaytao).ToString("dd/MM/yyyy"));

            xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";

            var ngaycapnhat = row["ngaycapnhat"] + "";
            xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", string.IsNullOrEmpty(ngaycapnhat) ? "" : DateTime.Parse(ngaycapnhat).ToString("dd/MM/yyyy"));

            xml += "<cell><![CDATA[" + row["nguoicapnhat"] + "]]></cell>";

            xml += "<cell><![CDATA[" + row["mota"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hoatdong"] + "]]></cell>";
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
