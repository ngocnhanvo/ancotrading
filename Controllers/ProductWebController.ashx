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
        public string detaiTA { get; set; }
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
        var a1 = context.Request.Form["a1"];
        var a2 = context.Request.Form["a2"];
        var sps = new List<productCatalog>();

        try
        {
            var idPresent = context.Request.Form["idPresent"].ToLower().Trim();
            var code = context.Request.Form["code"].ToLower().Trim();
            var isPresent = !string.IsNullOrWhiteSpace(idPresent);
            var isCode = !string.IsNullOrWhiteSpace(code);
            if (isPresent)
            {
                var lstD = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(Extension.readFileCatalog(idPresent));

                foreach (var item in lstD)
                {
                    sps.Add(new productCatalog()
                    {
                        code = item["code"],
                        titleWeb = "",
                        titleSubWeb = ""
                    });
                }

                if(!isCode)
                    goto end;
            }

            var menuWeb = CustomizeObjects.getMenuProductsWeb();

            if (isCode)
            {
                foreach (var mn1 in menuWeb)
                {
                    foreach (var mn2 in mn1.menuChild)
                    {
                        var arrDieuKienLocSP2 = mn2.href.Split(new string[] { " | " }, StringSplitOptions.RemoveEmptyEntries);

                        foreach (var dklsp in arrDieuKienLocSP2)
                        {
                            string sql = string.Format(@"
                                select sp.ma_sanpham, sp.md_kieudang_id
                                from md_sanpham sp
                                where 1=1
                                    AND sp.hoatdong = 1 
                                    AND sp.website = 1 
                                    AND sp.trangthai in ('DHD')
                                    AND sp.ma_sanpham like N'{0}'
                                    AND sp.ma_sanpham = N'{1}'
                                ",
                                dklsp,
                                code
                            );

                            var dt = mdbc.GetData(sql);
                            foreach (DataRow row in dt.Rows)
                            {
                                a1 = mn1.text;
                                a2 = mn2.text;
                                sps.Add(new productCatalog()
                                {
                                    code = row["ma_sanpham"].ToString(),
                                    shape = row["md_kieudang_id"].ToString(),
                                    titleWeb = a1,
                                    titleSubWeb = a2
                                });

                                break;
                            }
                        }
                    }
                }
            }

            if (!string.IsNullOrWhiteSpace(a1) & !string.IsNullOrWhiteSpace(a2))
            {
                var mnA1 = menuWeb.Where(s => s.text == a1).Select(s => s.menuChild).FirstOrDefault();
                var dieuKienLocSP = mnA1.Where(s => s.text == a2).Select(s => s.href).FirstOrDefault();
                var arrDieuKienLocSP = dieuKienLocSP.Split(new string[] { " | " }, StringSplitOptions.RemoveEmptyEntries);

                foreach (var dklsp in arrDieuKienLocSP)
                {
                    string sql = string.Format(@"
                    select 
                        sp.ma_sanpham, sp.md_kieudang_id
                    from 
                        md_sanpham sp
                    where 1=1
                        AND sp.hoatdong = 1 
                        AND sp.website = 1 
                        AND sp.trangthai in ('DHD')
                        AND sp.ma_sanpham like N'{0}'
                    ",
                        dklsp
                    );

                    var dt = mdbc.GetData(sql);
                    foreach (DataRow row in dt.Rows)
                    {
                        sps.Add(new productCatalog()
                        {
                            code = row["ma_sanpham"].ToString(),
                            shape = row["md_kieudang_id"].ToString(),
                            titleWeb = a1,
                            titleSubWeb = a2
                        });
                    }
                }
            }

            sps = sps.GroupBy(s => s.code).Select(s => s.First()).OrderBy(s => s.code).ToList();

        end:;

            foreach (var sp in sps)
            {
                var codeCL = sp.code.Substring(0, 2);
                var codeDT = sp.code.Substring(6, 2);
                sp.image = ExcuteSignalRStatic.getImageProductWeb(sp.code);
                sp.shape = db.md_kieudangs.Where(s => s.md_kieudang_id == sp.shape).Select(s => s.ten_ta).FirstOrDefault();
                sp.detaiTA = db.md_detais.Where(s => s.code_cl == codeCL & s.code_dt == codeDT).Select(s => s.ta_nganWeb).FirstOrDefault();

                if (sp.shape == "Rd.")
                    sp.shape = "Round Shape";
                else if (sp.shape == "Sq.")
                    sp.shape = "Squard Shape";
                else if (sp.shape == "Rect.")
                    sp.shape = "Rectangular Shape";
                else if (sp.shape == "Sta.")
                    sp.shape = "Star Shape";
                else
                    sp.shape = sp.shape + " Shape";
            }

            msg = "1" + Newtonsoft.Json.JsonConvert.SerializeObject(sps);
        }
        catch (Exception ex)
        {
            msg = "0" + ex;
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
