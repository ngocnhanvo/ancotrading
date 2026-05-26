using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Views_yeucaucapnhat_in_phieuYCcapnhatHH : System.Web.UI.Page
{
    public string logo = "", sothapphan = "", inPDF = "";
    public InfoPrint infoPrint = PrintAnco2.GetInfoPrint();
    public HttpContext context = HttpContext.Current;
    public string loai = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        var context = HttpContext.Current;
        loai = context.Request.QueryString["loai"];
        sothapphan = PrintAnco2.GetDecimal(context.Request.QueryString["stp"], 1);
        string nameTemp = "";
        string nameRpt = "";
        if(loai == typeof(md_donggoi).Name)
        {
            nameTemp = "(AD) YCCNHH - Đóng gói.xls";
            nameRpt = "Dữ liệu đóng gói";
        }
        else if (loai == typeof(md_donggoisanpham).Name)
        {
            nameTemp = "(AD) YCCNHH - Đóng gói sản phẩm.xls";
            nameRpt = "Dữ liệu đóng gói sản phẩm";
        }
        else if (loai == typeof(md_giasanpham).Name)
        {
            nameTemp = "(AD) YCCNHH - Giá sản phẩm.xls";
            nameRpt = "Dữ liệu giá sản phẩm";
        }
        else if (loai == typeof(md_sanpham).Name)
        {
            nameTemp = "(AD) YCCNHH - Thông tin sản phẩm.xls";
            nameRpt = "Dữ liệu sản phẩm";
        }
        else if (loai == typeof(md_mausac).Name)
        {
            nameTemp = "(AD) YCCNHH - Màu sắc.xls";
            nameRpt = "Dữ liệu màu sắc";
        }
        else if (loai == typeof(md_detai).Name)
        {
            nameTemp = "(AD) YCCNHH - Đề tài.xls";
            nameRpt = "Dữ liệu đề tài";
        }
        else if (loai == typeof(md_chungloai).Name)
        {
            nameTemp = "(AD) YCCNHH - Chủng loại.xls";
            nameRpt = "Dữ liệu chủng loại";
        }
        else if (loai == typeof(md_kieudang).Name)
        {
            nameTemp = "(AD) YCCNHH - Kiểu dáng.xls";
            nameRpt = "Dữ liệu kiểu dáng";
        }
        else if (loai == typeof(md_chucnang).Name)
        {
            nameTemp = "(AD) YCCNHH - Chức năng.xls";
            nameRpt = "Dữ liệu chức năng";
        }
        else if (loai == typeof(md_hscode).Name)
        {
            nameTemp = "(AD) YCCNHH - HSCode.xls";
            nameRpt = "Dữ liệu HSCode";
        }
        else if (loai == typeof(md_nhomnangluc).Name)
        {
            nameTemp = "(AD) YCCNHH - Nhóm năng lực.xls";
            nameRpt = "Dữ liệu nhóm năng lực";
        }
        string sql = CreateSql(context);

        inPDF = "2";
        var task = new System.Threading.Tasks.Task(() =>
        {
            viewReport(sql);
        });

        //var download = Request.QueryString["download"].removeAllSpaceOrTrimText(true);
        //ReportViewer1.Attributes["download"] = string.IsNullOrWhiteSpace(download) ? "1" : download;
        PrintAnco2.exportDataWithType(task, sql, inPDF, nameTemp, nameRpt, ReportViewer1, true);
    }

    public void viewReport(String SqlQuery)
    {

    }

    public string CreateSql(HttpContext context)
    {
        string id = context.Request.QueryString["id"];
        string manhandien = context.Request.QueryString["mnd"];
        string where = "";
        var manhandiens = new List<string>();

        using (var db = new LinqDBDataContext())
        {
            var logs = db.md_phieuthongtinsanpham_logs.Where(s => s.md_phieuthongtinsanpham_id == id & s.table == loai).ToList();
            foreach (var log in logs)
            {
                manhandiens.Add(log.id_lienket);
            }
        }
        manhandiens = manhandiens.Distinct().ToList();


        string sql = $@"";
        if(loai == typeof(md_donggoi).Name)
        {
            where = $"and dg.md_donggoi_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and dg.ma_donggoi like N'%{manhandien}%'";
            sql = $@"
                select
			        dg.ma_donggoi, 
                    dg.sl_inner, 
			        (select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_inner) as [DVTInner], 
			        dg.l1,
                    dg.w1,
                    dg.h1, 
                    dg.sl_outer, 
			        (select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_outer) as [DVTOuter], 
			        dg.l2_mix as l2, 
                    dg.w2_mix as w2, 
                    dg.h2_mix as h2,
                    dg.v2,
			        dg.soluonggoi_ctn_20 as ctn20, 
                    dg.soluonggoi_ctn as ctn40, 
                    dg.soluonggoi_ctn_40hc as ctn40hc,
			        format(dg.ngayxacnhan,'dd/MM/yyyy') as [ngayxacnhan],
                    dg.mota as ghichu, 
                    dg.tldg, 
                    dg.cpdg
		        from md_donggoi dg 
                where 1=1 {where}
                order by dg.ma_donggoi
            ";
        }
        else if (loai == typeof(md_donggoisanpham).Name)
        {
            where = $"and dgsp.md_donggoisanpham_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and sp.ma_sanpham like N'%{manhandien}%'";
            sql = $@"
                select
			        dg.ma_donggoi, sp.ma_sanpham, (case when isnull(dgsp.macdinh, 0) = 1 then 1 else 0 end) as macdinh, dgsp.mota as ghichu
		        from md_donggoi dg
                    left join md_donggoisanpham dgsp on dgsp.md_donggoi_id = dg.md_donggoi_id
                    left join md_sanpham sp on sp.md_sanpham_id = dgsp.md_sanpham_id
                where 1=1 {where}
                order by dg.ma_donggoi, sp.ma_sanpham
            ";
        }
        else if (loai == typeof(md_giasanpham).Name)
        {
            where = $"and gsp.md_giasanpham_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and sp.ma_sanpham like N'%{manhandien}%'";
            sql = $@"
                select
			        sp.ma_sanpham, 
                    pbg.ten_phienbangia, 
                    format(pbg.ngay_hieuluc, 'dd/MM/yyyy') as nhl,
                    bg.ten_banggia, 
                    gsp.gia, 
                    gsp.phi,
                    gsp.mota as ghichu
		        from md_giasanpham gsp
                    left join md_phienbangia pbg on pbg.md_phienbangia_id = gsp.md_phienbangia_id
                    left join md_banggia bg on pbg.md_banggia_id = bg.md_banggia_id
                    left join md_sanpham sp on sp.md_sanpham_id = gsp.md_sanpham_id
                where 1=1 {where}
                order by sp.ma_sanpham, pbg.ngay_hieuluc desc
            ";
        }
        else if(loai == typeof(md_sanpham).Name)
        {
            where = $"and sp.md_sanpham_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and sp.ma_sanpham like N'%{manhandien}%'";
            sql = $@"
            select
                sp.ma_sanpham, 
                sp.mota_tiengviet, 
                sp.mota_tienganh, 
                kd.ten_tv as tenkd, 
                cn.ten_tv as tencn, 
                kd.ma_kieudang, 
                cn.ma_chucnang, 
                (select dvtsp.ten_dvt from md_donvitinhsanpham dvtsp where dvtsp.md_donvitinhsanpham_id = sp.md_donvitinhsanpham_id) as [dvtsp], 
                l_cm as l, 
                w_cm as w, 
                h_cm as h, 
                sp.trongluong, 
                sp.dientich, 
                sp.thetich, 
                (select nhom from md_nhomnangluc nnl where nnl.md_nhomnangluc_id = sp.md_nhomnangluc_id) as nnl, 
                cb.ma_cangbien, 
                dtkd.ma_dtkd as [NCC], 
                hscode.ma_hscode, 
                sp.chucnangsp, 
                CONVERT(VARCHAR, sp.ngayxacnhan, 103) as ngayxacnhan, 
                sp.hinhthucban, 
                sp.mota, 
                sp.ghichu, 
                isnull((
                    select top 1 gsp.gia 
                    from md_banggia bg, md_phienbangia pbg, md_giasanpham gsp
                    where bg.md_banggia_id = pbg.md_banggia_id
                    AND pbg.md_phienbangia_id = gsp.md_phienbangia_id
                    AND sp.md_sanpham_id = gsp.md_sanpham_id
                    AND bg.banggiaban = 1
					AND substring(bg.ten_banggia,0,5) = 'FOB-'
                    AND pbg.md_trangthai_id = 'HIEULUC'
                    order by pbg.ngay_hieuluc desc
                ), 0) as [giaban], 
                isnull((
                    select top 1 gsp.gia 
                    from md_banggia bg, md_phienbangia pbg, md_giasanpham gsp
                    where bg.md_banggia_id = pbg.md_banggia_id
                    AND pbg.md_phienbangia_id = gsp.md_phienbangia_id
                    AND sp.md_sanpham_id = gsp.md_sanpham_id
                    AND bg.banggiaban = 0
                    AND bg.ten_banggia like N'' + dtkd.ma_dtkd + '-%'
                    AND pbg.md_trangthai_id = 'HIEULUC'
                    order by pbg.ngay_hieuluc desc
                ), 0) as [giamua], 
                isnull(dg.sl_inner,0) as [SLInner], 
                isnull((select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_inner),0) as [DVTInner], 
                isnull(dg.l1,0) as l1, 
                isnull(dg.w1,0) as w1, 
                isnull(dg.h1,0) as h1, 
                isnull(dg.sl_outer,0) as [SLOuter], 
                isnull((select dvt.ten_dvt from md_donvitinh dvt where dvt.md_donvitinh_id = dg.dvt_outer),0) as [DVTOuter], 
                isnull(dg.l2_mix,0) as l2, 
                isnull(dg.w2_mix,0) as w2, 
                isnull(dg.h2_mix,0) as h2, 
                isnull(dg.soluonggoi_ctn_20,0) as [cont20], 
                isnull(dg.soluonggoi_ctn,0) as [cont40], 
                isnull(dg.soluonggoi_ctn_40hc,0) as [cont40hc], 
                isnull(dg.vd,0) as vd, 
                isnull(dg.vn,0) as vn, 
                isnull(dg.vl,0) as vl, 
                dg.ghichu_vachngan, 
                CONVERT(VARCHAR, dg.ngayxacnhan, 103) as ngayxacnhan_donggoi, 
                sp.trangthai, 
                dg.mota as [ghichu_dg]
            from 
                md_sanpham sp
				left join md_doitackinhdoanh dtkd on sp.nhacungung = dtkd.md_doitackinhdoanh_id
                left join md_donggoisanpham dgsp on dgsp.md_sanpham_id = sp.md_sanpham_id
				left join md_donggoi dg on dg.md_donggoi_id = dgsp.md_donggoi_id
				left join md_cangbien cb on sp.md_cangbien_id = cb.md_cangbien_id
                left join md_kieudang kd on sp.md_kieudang_id = kd.md_kieudang_id
				left join md_chucnang cn on sp.md_chucnang_id = cn.md_chucnang_id
				left join md_hscode hscode on sp.md_hscode_id = hscode.md_hscode_id
            where 1=1 and isnull(dgsp.macdinh,0)=1 {where}
            order by sp.ma_sanpham
            ";
        }
        else if(loai == typeof(md_mausac).Name)
        {
            where = $"and ms.md_mausac_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and (cl.code_cl + '-' + dt.code_dt + '-' + ms.code_mau) like N'%{manhandien}%'";
            sql = $@"
                select
			        ms.code_cl, 
			        ms.code_dt, 
			        ms.code_mau, 
			        ms.tv_ngan,
			        ms.ta_ngan,
			        N'/images/products/mausac/' + cl.code_cl + '-' + dt.code_dt + '-' + ms.code_mau + '.jpg' as [picture_mau],
			        (case when ms.hinhthucban = N'Bán đại trà' then 'X' else '' end) as htb1,
                    (case when ms.hinhthucban = N'Độc quyền' then 'X' else '' end) as htb2,
                    (case when ms.hinhthucban = N'Quản lý ngoài' then 'X' else '' end) as htb3,
                    (case when ms.hinhthucban = N'Bán thử nghiệm' then 'X' else '' end) as htb4,
			        ms.hemau,		
			        ms.mota
		        from md_mausac ms
                left join md_chungloai cl on ms.md_chungloai_id = cl.md_chungloai_id
                left join md_detai dt on ms.md_detai_id = dt.md_detai_id
		        WHERE 
                     1=1 {where}
		        order by ms.code_cl, ms.code_dt, ms.code_mau
            ";
        }
        else if (loai == typeof(md_detai).Name)
        {
            where = $"and dt.md_detai_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and (cl.code_cl + '-' + dt.code_dt) like N'%{manhandien}%'";
            sql = $@"
                select
			        dt.code_cl, 
			        dt.code_dt,
			        dt.tv_ngan,
			        dt.ta_ngan,
			        N'/images/products/detai/' + cl.code_cl + '-' + dt.code_dt + '.jpg' as [picture_detai],
			        (case when dt.hinhthucban = N'Bán đại trà' then 'X' else '' end) as htb1,
                    (case when dt.hinhthucban = N'Độc quyền' then 'X' else '' end) as htb2,
                    (case when dt.hinhthucban = N'Quản lý ngoài' then 'X' else '' end) as htb3,
                    (case when dt.hinhthucban = N'Bán thử nghiệm' then 'X' else '' end) as htb4,
			        dt.mota
		        from md_detai dt
                left join md_chungloai cl on dt.md_chungloai_id = cl.md_chungloai_id
		        WHERE 
                     1=1 {where}
		        order by dt.code_cl, dt.code_dt
            ";
        }
        else if (loai == typeof(md_chungloai).Name)
        {
            where = $"and cl.md_chungloai_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and cl.code_cl like N'%{manhandien}%'";
            sql = $@"
                select
			        cl.code_cl,
			        cl.tv_ngan,
			        cl.ta_ngan,
			        cl.mota
		        from md_chungloai cl
		        WHERE 
                     1=1 {where}
		        order by cl.code_cl
            ";
        }
        else if (loai == typeof(md_kieudang).Name)
        {
            where = $"and kd.md_kieudang_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and kd.ma_kieudang like N'%{manhandien}%'";
            sql = $@"
                select
			        kd.ma_kieudang,
			        kd.ten_tv,
			        kd.ten_ta,
			        kd.mota
		        from md_kieudang kd
		        WHERE 
                     1=1 {where}
		        order by kd.ma_kieudang
            ";
        }
        else if (loai == typeof(md_chucnang).Name)
        {
            where = $"and cn.md_chucnang_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and cn.ma_chucnang like N'%{manhandien}%'";
            sql = $@"
                select
			        cn.ma_chucnang,
			        cn.ten_tv,
			        cn.ten_ta,
			        cn.mota
		        from md_chucnang cn
		        WHERE 
                     1=1 {where}
		        order by cn.ma_chucnang
            ";
        }
        else if (loai == typeof(md_hscode).Name)
        {
            where = $"and hsc.md_hscode_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and hsc.hscode + ' - ' + hsc.hehang like N'%{manhandien}%'";
            sql = $@"
                select
			        hsc.ma_hscode,
                    hsc.hscode,
                    hsc.hehang,
			        hsc.tenhang_tv,
			        hsc.tenhang_ta,
                    hsc.thanhphan,
                    hsc.nhacungung,
			        hsc.mota
		        from md_hscode hsc
		        WHERE 
                     1=1 {where}
		        order by hsc.hscode + ' - ' + hsc.hehang
            ";
        }
        else if (loai == typeof(md_nhomnangluc).Name)
        {
            where = $"and nnl.md_nhomnangluc_id in ('{string.Join("','", manhandiens)}')";
            if (!string.IsNullOrWhiteSpace(manhandien))
                where += $"and cl.code_cl + ' - ' + nnl.nhom like N'%{manhandien}%'";
            sql = $@"
                select
			        cl.code_cl,
                    nnl.nhom,
                    nnl.mota_tiengviet,
	                nnl.hscode,
	                nnl.thoigianlamhang,
	                nnl.mota
		        from md_nhomnangluc nnl
                    left join md_chungloai cl on cl.md_chungloai_id = nnl.md_chungloai_id
		        WHERE 
                     1=1 {where}
		        order by cl.code_cl + ' - ' + nnl.nhom
            ";
        }
        return sql;
    }
}