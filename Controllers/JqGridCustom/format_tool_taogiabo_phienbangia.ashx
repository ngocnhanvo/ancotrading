<%@ WebHandler Language="C#" Class="format_tool_taogiabo_phienbangia" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using Newtonsoft.Json;

public class format_tool_taogiabo_phienbangia : IHttpHandler {
    public class ItemMaster
    {
        public string md_banggia_id { get; set; }
        public string ten_banggia { get; set; }
        public string dongtien { get; set; }
        public bool? banggiaban { get; set; }
        public string mota { get; set; }
        public DateTime? ngaytao { get; set; }
        public string dongHang { get; set; }
    }

    public class ItemDetail
    {
        public string id { get; set; }
        public string md_banggia_id { get; set; }
        public string ten_phienbangia { get; set; }
        public string ngay_hieuluc { get; set; }
        public bool? hoatdong { get; set; }
    }

    public class jsonData
    {
        public int total { get; set; }
        public int page { get; set; }
        public int records { get; set; }
        public List<ItemMaster> rows { get; set; }
    }


    private LinqDBDataContext db = new LinqDBDataContext();
    public void ProcessRequest(HttpContext context)
    {
        var hasType = context.Request.QueryString["hasType"] == "true";
        var trangThaiPBG = hasType ? "SOANTHAO" : "HIEULUC";
        var bgs = db.md_banggias.Where(s => s.hoatdong == true).Select(s=>new ItemMaster{
            md_banggia_id = s.md_banggia_id,
            ten_banggia = s.ten_banggia,
            banggiaban = s.banggiaban,
            dongtien = s.md_dongtien_id,
            mota = s.mota,
            ngaytao = s.ngaytao,
            dongHang = "[]"
        }).OrderBy(s=>s.ngaytao).ToList();

        foreach(var bg in bgs)
        {
            bg.dongtien = db.md_dongtiens.Where(s => s.md_dongtien_id == bg.dongtien).Select(s => s.ma_iso).FirstOrDefault();
            bg.dongHang = JsonConvert.SerializeObject(
                db.md_phienbangias.Where(s => s.md_banggia_id == bg.md_banggia_id & s.md_trangthai_id == trangThaiPBG & s.hoatdong == true)
                .OrderByDescending(s=>s.ngay_hieuluc)
                .ToList()
                .Select(s=>new ItemDetail {
                    id = s.md_phienbangia_id,
                    md_banggia_id = s.md_banggia_id,
                    ten_phienbangia = s.ten_phienbangia,
                    ngay_hieuluc = s.ngay_hieuluc == null ? "" : s.ngay_hieuluc.Value.ToString("dd/MM/yyyy"),
                    hoatdong = s.hoatdong
                })
                .ToList()
            );
        }

        var lstYCGH = new jsonData();
        lstYCGH.total = 1;
        lstYCGH.page = 1;
        lstYCGH.records = bgs.Count;
        lstYCGH.rows = bgs;
        context.Response.Write(JsonConvert.SerializeObject(lstYCGH));
    }


    public bool IsReusable
    {
        get { return false; }
    }
}