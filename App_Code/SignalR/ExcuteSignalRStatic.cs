using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for Objects
/// </summary>
public static class ExcuteSignalRStatic
{
    public static DataTable getDongGoi(string md_sanpham_id)
    {
        string strsql =
                @"
				select dg.sl_inner, (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_inner) as dvtinner,
				dg.sl_outer, (select ten_dvt from md_donvitinh where md_donvitinh_id = dg.dvt_outer) as dvtouter,
				dg.l1, dg.w1, dg.h1,
				dg.l2_mix, dg.w2_mix, dg.h2_mix, convert(decimal(18,3), dg.v2 / dg.sl_outer) as v2, dg.sl_cont_mix, dg.soluonggoi_ctn_20, dg.soluonggoi_ctn, dg.soluonggoi_ctn_40hc
				FROM md_donggoisanpham (nolock) dgsp, md_donggoi (nolock) dg
				WHERE 
				dgsp.md_sanpham_id = '{0}'
				AND dgsp.md_donggoi_id = dg.md_donggoi_id
				AND dgsp.macdinh = 1";

        strsql = string.Format(strsql, md_sanpham_id);
        return mdbc.GetData(strsql);
    }

    public static DataTable getFOB(string md_sanpham_id)
    {
        string strsql =
                @"
				    select top 1 cb.ten_cangbien 
                    from md_cangbien (nolock) cb 
                    where cb.md_cangbien_id = (
	                    select top 1
		                    cxh.md_cangbien_id
	                    FROM 
		                    md_cangxuathang (nolock) cxh
	                    WHERE 
		                    cxh.md_sanpham_id = '{0}'
		                    and cxh.macdinh = 1
                    )
                ";

        strsql = string.Format(strsql, md_sanpham_id);
        return mdbc.GetData(strsql);
    }

    public static DataTable getPrice(string arrMSP)
    {
        string strsql =
                @"    
                    declare @tblBG table (
	                    bgid nvarchar(32)
	                    , tenbg nvarchar(MAX)
	                    , bgban bit
	                    , pbgid nvarchar(32)
	                    , ngayhl datetime
	                    , dongtien nvarchar(32)
                    )
                    insert into @tblBG
                    select bg.md_banggia_id, bg.ten_banggia, bg.banggiaban, pbg.md_phienbangia_id, pbg.ngay_hieuluc, dt.ma_iso
                    from md_banggia (nolock) bg
                    inner join md_phienbangia (nolock) pbg on bg.md_banggia_id = pbg.md_banggia_id
                    inner join md_dongtien (nolock) dt on bg.md_dongtien_id = dt.md_dongtien_id
                    where 
	                    1=1
	                    and bg.banggiaban = 1
	                    AND substring(bg.ten_banggia, 0, 5) = 'FOB-' 

                    declare @tblGia table (
	                    spid nvarchar(32)
	                    , ma_sanpham nvarchar(MAX)
	                    , l_cm decimal(18,1)
	                    , w_cm decimal(18,1)
	                    , h_cm decimal(18,1)
	                    , gia decimal(18,2)
	                    , pbgid nvarchar(32)
                    )
                    insert into @tblGia
                    select 
		                    sp.*
		                    , gsp.gia
		                    ,gsp.md_phienbangia_id
	                    from (
		                    select sp.md_sanpham_id, sp.ma_sanpham, sp.l_cm, sp.w_cm, sp.h_cm
		                    FROM 
			                    md_sanpham (nolock) sp
		                    WHERE 
			                    1=1
			                    AND sp.ma_sanpham in ({0})
	                    ) sp
	                    inner join md_giasanpham (nolock) gsp on gsp.md_sanpham_id = sp.md_sanpham_id
	                    where
		                    1=1
		                    AND gsp.hoatdong = 1 

                    select 
	                    T.* 
                    from (
	                    select 
		                    gia.*
		                    , row_number() over(partition by gia.ma_sanpham order by bg.ngayhl desc) as rn
	                    from 
		                    @tblGia gia
		                    inner join @tblBG bg on bg.pbgid = gia.pbgid
	                )T
                    where T.rn = 1 order by T.ma_sanpham
                ";

        strsql = string.Format(strsql, arrMSP);
        return mdbc.GetData(strsql);
    }

    public static dynamic getImage(string ma_sanpham)
    {
        var response = new Dictionary<string, object>()
        {
            { "cl", "" },
            { "dt", "" },
            { "ms", "" },
            { "msLink", "images/products/fullsize/default.jpg" }
        };

        try
        {
            string msLink = "images/products/mausac/";
            string cl = ma_sanpham.Substring(0, 2);
            string dt = ma_sanpham.Substring(6, 2);
            string ms = ma_sanpham.Substring(12, 2);
            var context = HttpContext.Current;
            string image = context.Server.MapPath(msLink).Replace("signalr\\", "");
            string clDTMS = string.Format(@"{0}-{1}-{2}.jpg", cl, dt, ms);
            if (File.Exists(image + ma_sanpham + ".jpg"))
                msLink += ma_sanpham + ".jpg";
            else if (File.Exists(image + clDTMS))
                msLink += clDTMS;
            else
                msLink = "images/products/fullsize/default.jpg";

            response["cl"] = cl;
            response["dt"] = dt;
            response["ms"] = ms;
            response["msLink"] = msLink;
        }
        catch { }

        return response;
    }

    public static string getImageProduct(string msp)
    {
        string image = "";
        if (!msp.Contains("-F"))
        {
            image = msp.Substring(0, 8) + ".jpg";
        }
        else
        {
            image = msp.Substring(0, 11) + ".jpg";
        }

        return Public.imgProduct + image;
    }

    public static dynamic getTextFromInner(string inner, string outer, string slinner, string slouter)
    {
        string packingText = "1", sizeText = "2";

        if (inner.LastIndexOf("bun") > -1)
        {
            packingText = "Packing in bundle";
            sizeText = "Pallet size";
        }
        else if (inner.LastIndexOf("ctn") > -1)
        {
            packingText = "Packing in carton";
            sizeText = "Carton size";
        }
        else if (inner.LastIndexOf("Crate") > -1)
        {
            packingText = "Packing in wooden crate";
            sizeText = "Crate size";
        }

        inner = inner.Replace("/bun", "/bundle").Replace("/ctn", "/carton");
        outer = outer.Replace("/pal", "/pallet").Replace("/ctn", "/carton");

        packingText = inner;
        sizeText = inner.LastIndexOf("ctn") + "";

        if (slinner != "0" & inner != "0" & slinner != "" & inner != "")
            inner = slinner + " " + inner;
        else
            inner = " ";

        if (slouter != "0" & outer != "0" & slouter != "" & outer != "")
            outer = slouter + " " + outer;
        else
            outer = " ";

        return new {
            packingText,
            sizeText,
            inner,
            outer
        };
    }
	
	public static string mapPathSignalR(string path)
    {
        return System.Web.Hosting.HostingEnvironment.MapPath(path);
    }
}