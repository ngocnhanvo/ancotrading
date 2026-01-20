<%@ WebHandler Language="C#" Class="MauSacMainController" %>

using System;
using System.Web;
using System.Data;
using System.Linq;
using jqGridHelper;

public class MauSacMainController : IHttpHandler
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest(HttpContext context)
    {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "updatestatus":
                this.UpdateStatus(context);
                break;
            case "getoption":
                this.getSelectOption(context);
                break;
            case "HinhAnh":
                this.HinhAnh(context);
                break;
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

    public void HinhAnh(HttpContext context)
    {
        string msg = "";
        if (context.Request.Files.Count != 0)
        {
            HttpFileCollection files = context.Request.Files;
            for (int i = 1; i <= files.Count; i++)
            {
                string fileName = files[i - 1].FileName;
                int mimeI = fileName.LastIndexOf(".");
                string mime = fileName.Substring(mimeI);
                string name = fileName.Substring(0, mimeI);
                if (mime.ToLower() == ".jpg")
                {
                    try
                    {
                        string[] arrN = name.Split('-');
                        if (arrN.Length == 3)
                        {
                            string cl = arrN[0], dt = arrN[1], ms = arrN[2];
                            int countMS = db.md_mausacs.Where(p => p.code_cl.Equals(cl) & p.code_dt.Equals(dt) & p.code_mau.Equals(ms)).Count();
                            if (countMS > 0)
                            {
                                var link = $"images/products/mausac/{files[i - 1].FileName}";
                                files[i - 1].SaveAs(context.Server.MapPath($"../{link}"));
                                msg += "<div style='color:blue'>" + fileName + ": upload thành công.</div>";
                                VoNgocNhan.API_Data.themLichSuHoatDong(
                                    db,
                                    HttpContext.Current,
                                    new ad_log
                                    {
                                        nexxdecor_check = false,
                                        hanhdong = VoNgocNhan.API_Data.img,
                                        table = typeof(md_mausac).Name,
                                        id_lienket = $"{cl}-{dt}-{ms}",
                                        chitiet = link
                                    }
                                );
                            }
                            else
                            {
                                msg += "<div style='color:red'>" + fileName + ": không tồn tại màu này</div>";
                            }
                        }
                        else
                        {
                            msg += "<div style='color:red'>" + fileName + ": không đúng quy cách đặt tên (CL-DT-MS)</div>";
                        }
                    }
                    catch (Exception ex)
                    {
                        msg += "<div style='color:red'>" + fileName + ":" + ex.Message + "</div>";
                    }
                }
                else
                {
                    msg += "<div style='color:red'>" + fileName + ": không đúng định dạng jpg</div>";
                }
            }
        }
        else
        {
            msg += "<div style='color:red'>Hãy chọn hình ảnh</div>";
        }
        context.Response.Write(msg);
    }

    public void UpdateStatus(HttpContext context)
    {
        String msg = "";
        try
        {
            String id = context.Request.QueryString["md_mausac_id"];
            String trangthai = context.Request.QueryString["trangthai"];
            //// filter
            String filter = "";
            bool _search = bool.Parse(context.Request.QueryString["_search"]);
            if (_search)
            {
                String _filters = context.Request.QueryString["filters"];
                Filter f = Filter.CreateFilter(_filters);
                filter = f.ToScript();
            }

            String sqlGetProductId = @"
			SELECT ms.md_mausac_id 
			FROM md_mausac ms, md_chungloai cl, md_detai dt 
			WHERE 1=1 
			AND ms.md_chungloai_id = cl.md_chungloai_id 
			AND ms.md_detai_id = dt.md_detai_id 
            {1}
			{0}";
            md_mausac sp = db.md_mausacs.FirstOrDefault(p => p.md_mausac_id.Equals(id));

            var ttcp = new string[] { "TOACTIVE", "TOACTIVENHD" };
            if (sp != null | ttcp.Contains(trangthai))
            {
                bool next = true;
                switch (trangthai)
                {
                    case "HIEULUC":
                        msg = "Đã chuyển trạng thái màu sắc thành \"Hiệu lực\"!";
                        break;
                    case "SOANTHAO":
                        msg = "Đã chuyển trạng thái màu sắc thành \"Soạn thảo\"!";
                        break;
                    case "NHD":
                        msg = "Đã chuyển trạng thái màu sắc thành \"Ngưng hoạt động\"!";
                        break;
                    case "TOACTIVE":
                        msg = "Đã chuyển tất cả màu sắc được lọc từ \"soạn thảo\" sang \"Hiệu lực\"!";
                        break;
                    case "TOACTIVENHD":
                        msg = "Đã chuyển tất cả màu sắc được lọc từ \"Ngưng hoạt động\" sang \"Hiệu lực\"!";
                        break;
                    default:
                        msg = "Không xác định được trạng thái của màu sắc!";
                        next = false;
                        break;
                }

                if (next)
                {
                    if (trangthai.Equals("TOACTIVE"))
                    {
                        sqlGetProductId = String.Format(sqlGetProductId, filter, "AND ms.trangthai = 'SOANTHAO'");
                        var dt = mdbc.GetData(sqlGetProductId);
                        var ids = dt.AsEnumerable().Select(row => row[0].ToString()).ToList();
                        var spsSoanThao = db.md_mausacs.Where(s => ids.Contains(s.md_mausac_id)).ToList();
                        foreach (var spst in spsSoanThao)
                        {
                            spst.trangthai = Helper.HIEULUC;
                            VoNgocNhan.API_Data.themLichSuHoatDong(
                                db,
                                HttpContext.Current,
                                new ad_log
                                {
                                    nexxdecor_check = false,
                                    hanhdong = VoNgocNhan.API_Data.edit,
                                    table = spst.GetType().Name,
                                    id_lienket = spst.md_mausac_id
                                }
                            );
                        }
                        db.SubmitChanges();
                    }
                    else if (trangthai.Equals("TOACTIVENHD"))
                    {
                        sqlGetProductId = String.Format(sqlGetProductId, filter, "AND ms.trangthai = 'NHD'");
                        var dt = mdbc.GetData(sqlGetProductId);
                        var ids = dt.AsEnumerable().Select(row => row[0].ToString()).ToList();
                        var spsNHD = db.md_mausacs.Where(s => ids.Contains(s.md_mausac_id)).ToList();
                        foreach (var spst in spsNHD)
                        {
                            spst.trangthai = Helper.HIEULUC;
                            VoNgocNhan.API_Data.themLichSuHoatDong(
                                db,
                                HttpContext.Current,
                                new ad_log
                                {
                                    nexxdecor_check = false,
                                    hanhdong = VoNgocNhan.API_Data.edit,
                                    table = spst.GetType().Name,
                                    id_lienket = spst.md_mausac_id
                                }
                            );
                        }
                        db.SubmitChanges();
                    }
                    else
                    {
                        sp.trangthai = trangthai;
                        VoNgocNhan.API_Data.themLichSuHoatDong(
                                db,
                                HttpContext.Current,
                                new ad_log
                                {
                                    nexxdecor_check = false,
                                    hanhdong = VoNgocNhan.API_Data.edit,
                                    table = sp.GetType().Name,
                                    id_lienket = sp.md_mausac_id
                                }
                            );
                        db.SubmitChanges();
                    }
                }
            }
            else
            {
                msg = "Chưa chọn màu sắc hoặc màu sắc không tồn tại!";
            }
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        context.Response.Write(msg);
    }

    public void getSelectOption(HttpContext context)
    {
        String sql = "select md_mausac_id, code_mau from md_mausac where hoatdong = 1 order by code_mau desc";
        SelectHtmlControl s = new SelectHtmlControl(sql);
        context.Response.Write(s.ToString());
    }


    public void edit(HttpContext context)
    {
        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }

        String parDeTai_Id = context.Request.Form["md_detai_id"];
        var code_cl_dt = db.md_detais.Where(dt => dt.md_detai_id.Equals(parDeTai_Id)).Select(s => new { s.code_dt, s.code_cl, s.md_chungloai_id }).FirstOrDefault();

        md_mausac m = db.md_mausacs.Single(p => p.md_mausac_id == context.Request.Form["id"]);
        var mnu = new md_mausac();
        m.CopyPropertiesTo(mnu);
        m.md_mausac_id = context.Request.Form["md_mausac_id"];
        m.md_chungloai_id = code_cl_dt.md_chungloai_id;
        m.md_detai_id = parDeTai_Id;
        m.code_mau = context.Request.Form["code_mau"];
        m.code_cl = code_cl_dt.code_cl;
        m.code_dt = code_cl_dt.code_dt;
        m.tv_ngan = context.Request.Form["tv_ngan"];
        m.ta_ngan = context.Request.Form["ta_ngan"];
        m.tv_dai = context.Request.Form["tv_dai"];
        m.ta_dai = context.Request.Form["ta_dai"];
        m.hinhthucban = context.Request.Form["hinhthucban"];
        m.hemau = context.Request.Form["hemau"];

        m.mota = context.Request.Form["mota"];
        m.hoatdong = hd;
        m.nguoicapnhat = UserUtils.getUser(context);
        m.ngaycapnhat = DateTime.Now;
        var diffs = VoNgocNhan.API_Data.GetDifferences(m, mnu);
        if (diffs.Count > 0)
        {
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.edit,
                    table = m.GetType().Name,
                    id_lienket = m.md_mausac_id
                }
            );
        }
        db.SubmitChanges();
    }

    public void add(HttpContext context)
    {

        String h = context.Request.Form["hoatdong"].ToLower();
        bool hd = false;
        if (h.Equals("on") || h.Equals("true"))
        { hd = true; }
        String parDeTai_Id = context.Request.Form["md_detai_id"];
        var code_cl_dt = db.md_detais.Where(dt => dt.md_detai_id.Equals(parDeTai_Id)).Select(s => new { s.code_dt, s.code_cl, s.md_chungloai_id }).FirstOrDefault();


        md_mausac mnu = new md_mausac
        {
            md_mausac_id = Helper.getNewId(),
            md_chungloai_id = code_cl_dt.md_chungloai_id,
            md_detai_id = parDeTai_Id,
            code_mau = context.Request.Form["code_mau"],
            code_cl = code_cl_dt.code_cl,
            code_dt = code_cl_dt.code_dt,
            tv_ngan = context.Request.Form["tv_ngan"],
            ta_ngan = context.Request.Form["ta_ngan"],
            tv_dai = context.Request.Form["tv_dai"],
            ta_dai = context.Request.Form["ta_dai"],
            hinhthucban = context.Request.Form["hinhthucban"],
            hemau = context.Request.Form["hemau"],
            trangthai = Helper.SOANTHAO,

            mota = context.Request.Form["mota"],
            hoatdong = hd,
            nguoitao = UserUtils.getUser(context),
            nguoicapnhat = UserUtils.getUser(context),
            ngaytao = DateTime.Now,
            ngaycapnhat = DateTime.Now
        };

        db.md_mausacs.InsertOnSubmit(mnu);
        VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.add,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_mausac_id
                }
            );
        db.SubmitChanges();
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        try
        {
            var mnu = db.md_mausacs.Where(s => s.md_mausac_id == id).FirstOrDefault();
            if (mnu == null)
            {
                msg = "Không tìm thấy màu sắc đã chọn";
                goto EndEventHandler;
            }

            db.md_mausacs.DeleteOnSubmit(mnu);
            VoNgocNhan.API_Data.themLichSuHoatDong(
                db,
                context,
                new ad_log
                {
                    nexxdecor_check = false,
                    hanhdong = VoNgocNhan.API_Data.del,
                    table = mnu.GetType().Name,
                    id_lienket = mnu.md_mausac_id
                }
            );
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

        EndEventHandler:;

        if (msg.Length <= 0)
        {
            jqGridHelper.Utils.writeResult(1, "Xóa màu sắc thành công");
        }
        else
        {
            jqGridHelper.Utils.writeResult(0, msg);
        }
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

        String md_detai_id = context.Request.QueryString["DeTaiId"];

        String sqlCount = string.Format(@"
			SELECT COUNT(1) AS count
            FROM md_mausac ms
			LEFT JOIN md_chungloai cl on ms.md_chungloai_id = cl.md_chungloai_id
			LEFT JOIN md_detai dt on ms.md_detai_id = dt.md_detai_id
            WHERE 1=1 {0}
		", filter);


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
            sidx = "cl.code_cl,dt.code_dt,ms.code_mau";
        }
        else
        {
            sidx = sidx + " " + sord;
        }

        string strsql = string.Format(@"
			select * 
			from(
				select 
					ms.md_mausac_id, ms.trangthai, cl.code_cl, (cl.code_cl + '-' + dt.code_dt) as code_dt, ms.code_mau
					, ms.tv_ngan, ms.ta_ngan, ms.tv_dai, ms.ta_dai, ms.hinhthucban, ms.hemau
					, ms.ngaytao, ms.nguoitao, ms.ngaycapnhat, ms.nguoicapnhat, ms.mota, ms.hoatdong
					, ROW_NUMBER() OVER (ORDER BY {0}) as RowNum
				FROM md_mausac ms
					LEFT JOIN md_chungloai cl on ms.md_chungloai_id = cl.md_chungloai_id
					LEFT JOIN md_detai dt on ms.md_detai_id = dt.md_detai_id
				WHERE 
					1=1 {1}
            )P 
			where RowNum > @start AND RowNum < @end",
            sidx,
            filter
        );

        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["md_mausac_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["trangthai"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["code_cl"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["code_dt"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["code_mau"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["tv_ngan"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ta_ngan"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["tv_dai"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ta_dai"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hinhthucban"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hemau"] + "]]></cell>";

            if (row["ngaytao"].ToString() != null & row["ngaytao"].ToString() != "")
                xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaytao"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            else
                xml += "<cell><![CDATA[]]></cell>";

            xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";

            if (row["ngaycapnhat"].ToString() != null & row["ngaycapnhat"].ToString() != "")
                xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaycapnhat"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            else
                xml += "<cell><![CDATA[]]></cell>";

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
