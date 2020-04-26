using System;
using System.Collections.Generic;
using System.Data;
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
}