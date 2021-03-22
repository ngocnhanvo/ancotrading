<%@ WebHandler Language="C#" Class="KeHoachXuatHangController" %>

using System;
using System.Web;
using System.Linq;
using System.Data;

public class KeHoachXuatHangController : IHttpHandler {

    LinqDBDataContext db = new LinqDBDataContext();

    public void ProcessRequest (HttpContext context) {
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "autostopkh":
                this.autostopKH(context);
                break;
            case "stopkh":
                this.stopKH(context);
                break;
            case "activekh":
                this.activeKH(context);
                break;
            default:
                switch (oper)
                {
                    case "edit":
                        this.edit(context);
                        break;
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    public void autostopKH(HttpContext context)
    {
        try
        {
            string kh_id = context.Request.QueryString["khxh"];
            string msg = "";
            //--
            int check = db.c_kehoachxuathangs.Where(p => !p.md_trangthai_id.Equals("KETTHUC") && p.cbm_conlai <= 0).Count();
            if (check <= 0)
            {
                msg = "Không có Kế hoạch nào có CBM <= 0!";
            }
            else
            {
                foreach(c_kehoachxuathang khxh in db.c_kehoachxuathangs.Where(p => !p.md_trangthai_id.Equals("KETTHUC") && p.cbm_conlai <= 0))
                {
                    khxh.md_trangthai_id = "KETTHUC";
                }
                check = 1;
            }

            if(check == 1)
            {
                msg = "Cập nhật thành công.";
                db.SubmitChanges();
            }
            context.Response.Write(msg);
        }
        catch (Exception e)
        {
            context.Response.Write("Lỗi xảy ra khi kết thúc KHXH!, " + e.Message);
        }
    }

    public void stopKH(HttpContext context)
    {
        try
        {
            string kh_id = context.Request.QueryString["khxh"];
            string msg = "";
            bool next;
            c_kehoachxuathang khxh = db.c_kehoachxuathangs.FirstOrDefault(p => p.c_kehoachxuathang_id.Equals(kh_id));
            if (khxh == null)
            {
                next = false;
                msg = "Kế hoạch không tồn tại! có thể đã được xóa trước đó!, " + kh_id;
            }
            else
            {
                switch (khxh.md_trangthai_id)
                {
                    case "SOANTHAO":
                        next = false;
                        msg = "Phải hiệu lực mới được kết thức kế hoạch!";
                        break;
                    case "KETTHUC":
                        next = false;
                        msg = "Hiện tại trạng thái của kế hoạch đã là Kết Thúc!";
                        break;
                    case "HIEULUC":
                        next = true;
                        msg = "Kết thúc kế hoạch thành công!";
                        break;
                    default:
                        next = false;
                        msg = "Không xác định được trạng thái của kế hoạch!";
                        break;
                }
            }

            if (next)
            {
                khxh.md_trangthai_id = "KETTHUC";
                db.SubmitChanges();
            }
            context.Response.Write(msg);
        }
        catch (Exception e)
        {
            context.Response.Write("Lỗi xảy ra khi kết thúc KHXH!, " + e.Message);
        }
    }

    public void activeKH(HttpContext context) {
        try
        {
            string kh_id = context.Request.QueryString["khxh"];
            string msg = "";
            bool next = true;
            var khxh = db.c_kehoachxuathangs.FirstOrDefault(k=>k.c_kehoachxuathang_id.Equals(kh_id));

            if (!khxh.khongtem.Equals(true) && khxh.ngayxacnhantem == null)
            {
                next = false;
                msg += "<div>Vui lòng chọn ngày xác nhận tem!</div>";
            }

            if (!khxh.khongbaobi.Equals(true) && khxh.ngayxacnhanbaobi == null)
            {
                next = false;
                msg += "<div>Vui lòng chọn ngày xác nhận bao bì!</div>";
            }

            // if (!khxh.khongkhachkiem.Equals(true) && khxh.ngaykhachkiem == null)
            // {
            // next = false;
            // msg += "<div>Vui lòng chọn ngày khách kiểm!</div>";
            // }

            // if (khxh.ngayxuathang == null)
            // {
            // next = false;
            // msg += "<div>Vui lòng chọn ngày xuất hàng!</div>";
            // }

            if (khxh.ngayxonghang == null)
            {
                next = false;
                msg += "<div>Vui lòng chọn ngày xong hàng!</div>";
            }

            // if (khxh.ngaykiemhang == null)
            // {
            // next = false;
            // msg += "<div>Vui lòng chọn ngày kiểm hàng!</div>";
            // }

            if (next)
            {
                khxh.md_trangthai_id = "HIEULUC";
                db.SubmitChanges();
                context.Response.Write("Hiệu lực kế hoạch xuất hàng thành công!");
            }
            else {
                context.Response.Write(msg);
            }
        }
        catch (Exception e)
        {
            context.Response.Write("Lỗi xảy ra khi hiệu lực KHXH!");
        }
    }

    public void edit(HttpContext context)
    {
        //try
        {
            string kt = context.Request.Form["khongtem"].ToLower();
            string kbb = context.Request.Form["khongbaobi"].ToLower();
            string kkk = context.Request.Form["khongkhachkiem"].ToLower();


            bool  khongtem, khongbaobi, khongkhachkiem;
            khongtem = khongbaobi = khongkhachkiem = false;

            if (kt.Equals("on") || kt.Equals("true"))
            { khongtem = true; }

            if (kbb.Equals("on") || kbb.Equals("true"))
            { khongbaobi = true; }

            if (kkk.Equals("on") || kkk.Equals("true"))
            { khongkhachkiem = true; }

            String ngaygiaohang, ngayxonghang, ngayxacnhantem, ngayxacnhanbaobi, ngaykiemhang, ngayxuathang, ngaykhachkiem, c_kehoachxuathang_id, ketquakiemhang, ngayxnbaobi;
            ngaygiaohang = context.Request.Form["ngaygiaohang"];
            ngayxonghang = context.Request.Form["ngayxonghang"];
            ngayxacnhantem = context.Request.Form["ngayxacnhantem"];
            ngayxnbaobi = context.Request.Form["ngaytrenhat"];
            ngayxacnhanbaobi = context.Request.Form["ngayxacnhanbaobi"];
            ngaykiemhang = context.Request.Form["ngaykiemhang"];
            ngayxuathang = context.Request.Form["ngayxuathang"];
            ngaykhachkiem = context.Request.Form["ngaykhachkiem"];
            c_kehoachxuathang_id = context.Request.Form["id"];
            ketquakiemhang = context.Request.Form["ketquakiemhang"];
            c_kehoachxuathang kh = db.c_kehoachxuathangs.FirstOrDefault(p => p.c_kehoachxuathang_id.Equals(c_kehoachxuathang_id));
            if (kh != null)
            {
                if (kh.md_trangthai_id.Equals("SOANTHAO"))
                {
                    c_kehoachxuathang khxh = db.c_kehoachxuathangs.FirstOrDefault(p => p.c_kehoachxuathang_id.Equals(c_kehoachxuathang_id));
                    khxh.chungloaihang = context.Request.Form["chungloaihang"];

                    /*if (ngaygiaohang != "")
                    {
                        khxh.ngaygiaohang = DateTime.ParseExact(ngaygiaohang, "dd/MM/yyyy", null);    
                    }*/
                    if (ngayxonghang != "")
                    {
                        khxh.ngayxonghang = DateTime.ParseExact(ngayxonghang, "dd/MM/yyyy", null);
                    }
                    /*if (ngaykhachkiem != "")
                    {
                        khxh.ngaykhachkiem = DateTime.ParseExact(ngaykhachkiem, "dd/MM/yyyy", null);
                    }*/
                    khxh.khongtem = khongtem;
                    if (ngayxacnhantem != "")
                    {
                        khxh.ngayxacnhantem = DateTime.ParseExact(ngayxacnhantem, "dd/MM/yyyy", null);
                    }
                    khxh.khongbaobi = khongbaobi;
                    if (ngayxacnhanbaobi != "")
                    {
                        khxh.ngayxacnhanbaobi = DateTime.ParseExact(ngayxacnhanbaobi, "dd/MM/yyyy", null);
                    }
                    khxh.khongkhachkiem = khongkhachkiem;
                    /*if (ngaykiemhang != "")
                    {
                        khxh.ngaykiemhang = DateTime.ParseExact(ngaykiemhang, "dd/MM/yyyy", null);
                    }*/

                    if (ngayxnbaobi != "")
                    {
                        khxh.ngayxnbaobi = DateTime.ParseExact(ngayxnbaobi, "dd/MM/yyyy", null);
                    }
                    else {
                        khxh.ngayxnbaobi = null;
                    }
                    khxh.ketquakiemhang = ketquakiemhang;
                    khxh.nhanvienct = context.Request.Form["nhanvienct"];
                    //--
                    khxh.ghichu = context.Request.Form["ghichu"];
                    khxh.mota = context.Request.Form["mota"];
                    //--
                    khxh.ngaycapnhat = DateTime.Now;
                    khxh.nguoicapnhat = UserUtils.getUser(context);

                    foreach(c_kehoachxuathang kh2 in db.c_kehoachxuathangs.Where(p => p.so_po.Equals(khxh.so_po)))
                    {
                        if(kh2.md_trangthai_id.Equals("SOANTHAO"))
                        {
                            kh2.nhanvienct = khxh.nhanvienct;
                        }
                    }
                    db.SubmitChanges();
                }
                else
                {
                    jqGridHelper.Utils.writeResult(0, "Không được chỉnh sửa kế hoạch này.!");
                }
            }
        }
        // catch (Exception e) {
        // jqGridHelper.Utils.writeResult(0, "Lỗi: " + e.Message);
        // }
    }
    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        bool isadmin = db.nhanviens.FirstOrDefault(p => p.manv.Equals(UserUtils.getUser(context))).isadmin.Value;

        String dateFrom, dateTo, dateType;
        dateFrom = context.Request.QueryString["dateFrom"];
        dateTo = context.Request.QueryString["dateTo"];
        dateType = context.Request.QueryString["dateType"];


        DateTime fromDate, toDate;
        fromDate = dateFrom == "" || dateFrom == null ? DateTime.Now : DateTime.ParseExact(dateFrom, "dd/MM/yyyy", null);
        toDate = dateTo == "" || dateTo  == null ? DateTime.Now : DateTime.ParseExact(dateTo, "dd/MM/yyyy", null);

        string from = string.Format(@"convert(datetime, N'{0} 00:00:00', 103)", fromDate.ToString("dd/MM/yyy"));
        string to = string.Format(@"convert(datetime, N'{0} 23:59:59', 103)", toDate.ToString("dd/MM/yyy"));
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

        String sqlCount = "SELECT COUNT(*) AS count " +
            " FROM c_kehoachxuathang kh, c_donhang dh, md_doitackinhdoanh dtkd " +
            " WHERE kh.c_donhang_id = dh.c_donhang_id " +
            " AND kh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id " + filter +
            " {0} " +
            " AND dh.md_trangthai_id <> 'KETTHUC' ";

        if(dateType == "0")
        {
            sqlCount += " AND kh.ngaygiaohang >= {1} AND kh.ngaygiaohang <= {2} ";
        }
        else{
            sqlCount += " AND kh.ngayxonghang >= {1} AND kh.ngayxonghang <= {2} ";
        }

        sqlCount = String.Format(sqlCount, isadmin == true ? "" : "AND kh.nguoitao IN(" + strAccount + ")", from, to);

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
            sidx = "c_kehoachxuathang_id";
        }

        string strsql = @"select P.*, isnull((DATEDIFF(day, P.shipmenttime, P.etd)),0) as tre_nv from(
            select
            kh.c_kehoachxuathang_id
			, kh.md_trangthai_id
			, dh.sochungtu as ct_dh 
            , kh.c_danhsachdathang_id
			, dtkd.ma_dtkd
			, kh.chungloaihang 
            , kh.cbm 
            , kh.cbm_conlai 
            , kh.shipmenttime
			, (kh.shipmenttime - 7) as ngayxonghang_xxn
			, kh.ngayxonghang
			--, (kh.shipmenttime - 35) as ngaytrenhat
			, kh.ngayxnbaobi as ngaytrenhat
			, kh.khongtem 
			, kh.ngayxacnhantem
			, kh.khongbaobi
			, kh.ngayxacnhanbaobi
			, kh.ngaykiemhang
			, kh.ngaykhachkiem			
			, kh.ketquakiemhang
			, (
                select top 1 ngay_motokhai from c_packinginvoice where c_packinginvoice_id in (
				    select c_packinginvoice_id from c_dongpklinv where c_dongnhapxuat_id in
				    (
					    select c_dongnhapxuat_id 
					    from c_dongnhapxuat
					    where c_dongdonhang_id in (
						    select c_dongdonhang_id from c_dongdonhang where c_donhang_id = kh.c_donhang_id
					    )
				    )
			    )
                order by ngay_motokhai asc
            ) as etd
			, (select top 1 hoten from nhanvien where manv = (select distinct nguoitao from c_danhsachdathang where sochungtu = kh.c_danhsachdathang_id AND md_trangthai_id = 'HIEULUC')) as nguoilap
			, isnull((case when DATEDIFF(DAY, (kh.shipmenttime - 7), kh.ngayxonghang) > 0 then DATEDIFF(DAY, (kh.shipmenttime - 7), kh.ngayxonghang) else null end),0) as tre
			, (select top 1 ma_dtkd from md_doitackinhdoanh dtkd, c_donhang dh where dtkd.md_doitackinhdoanh_id = dh.md_doitackinhdoanh_id AND dh.c_donhang_id = kh.c_donhang_id) as khachhang
			, kh.ghichu 
            , kh.khongkhachkiem, kh.ngayxuathang, kh.ngaygiaohang
            , kh.thang, kh.nam, kh.nhanvienct  
            , kh.ngaytao, kh.nguoitao, kh.ngaycapnhat, kh.nguoicapnhat, kh.mota, kh.hoatdong 
            , ROW_NUMBER() OVER (ORDER BY " + sidx + " " + sord + @") as RowNum 
            FROM c_kehoachxuathang kh
			left join c_donhang dh on kh.c_donhang_id = dh.c_donhang_id
			left join md_doitackinhdoanh dtkd  on kh.md_doitackinhdoanh_id = dtkd.md_doitackinhdoanh_id
            WHERE 1=1  " + filter + @" {0} AND dh.md_trangthai_id <> 'KETTHUC'";

        if(dateType == "0")
        {
            strsql += " AND kh.ngaygiaohang >= {1} AND kh.ngaygiaohang <= {2} ";
        }
        else{
            strsql += " AND kh.ngayxonghang >= {1} AND kh.ngayxonghang <= {2} ";
        }

        strsql += " )P where RowNum > @start AND RowNum < @end ";

        strsql = string.Format(strsql, isadmin == true ? "" : "AND kh.nguoitao IN(" + strAccount + ")", from, to);

        System.Data.DataTable dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        int colCount = dt.Columns.Count;

        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            String a = row[9].ToString();
            xml += "<row>";
            xml += "<cell><![CDATA[" + row["c_kehoachxuathang_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["md_trangthai_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["khachhang"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ct_dh"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["c_danhsachdathang_id"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ma_dtkd"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["chungloaihang"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["cbm"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["cbm_conlai"] + "]]></cell>";

            xml += "<cell><![CDATA[" + (!row["shipmenttime"].ToString().Equals("") ? DateTime.Parse(row["shipmenttime"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + (!row["ngaygiaohang"].ToString().Equals("") ? DateTime.Parse(row["ngaygiaohang"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + (!row["ngayxonghang_xxn"].ToString().Equals("") ? DateTime.Parse(row["ngayxonghang_xxn"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + (!row["ngayxonghang"].ToString().Equals("") ? DateTime.Parse(row["ngayxonghang"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + (!row["ngayxacnhanbaobi"].ToString().Equals("") ? DateTime.Parse(row["ngayxacnhanbaobi"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";

            xml += "<cell><![CDATA[" + row["khongtem"] + "]]></cell>";
            xml += "<cell><![CDATA[" + (!row["ngayxacnhantem"].ToString().Equals("") ? DateTime.Parse(row["ngayxacnhantem"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";

            xml += "<cell><![CDATA[" + row["khongbaobi"] + "]]></cell>";

            xml += "<cell><![CDATA[" + (!row["ngaytrenhat"].ToString().Equals("") ? DateTime.Parse(row["ngaytrenhat"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + (!row["ngaykiemhang"].ToString().Equals("") ? DateTime.Parse(row["ngaykiemhang"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["khongkhachkiem"] + "]]></cell>";
            xml += "<cell><![CDATA[" + (!row["ngaykhachkiem"].ToString().Equals("") ? DateTime.Parse(row["ngaykhachkiem"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";

            xml += "<cell><![CDATA[" + row["ketquakiemhang"] + "]]></cell>";

            xml += "<cell><![CDATA[" + (!row["etd"].ToString().Equals("") ? DateTime.Parse(row["etd"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nhanvienct"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoilap"] + "]]></cell>";

            xml += "<cell><![CDATA[" + row["tre_nv"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["tre"] + "]]></cell>";

            xml += "<cell><![CDATA[" + (!row["ngayxuathang"].ToString().Equals("") ? DateTime.Parse(row["ngayxuathang"].ToString()).ToString("dd/MM/yyyy") : "") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["thang"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nam"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["ghichu"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaytao"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoitao"] + "]]></cell>";
            xml += "<cell><![CDATA[" + DateTime.Parse(row["ngaycapnhat"].ToString()).ToString("dd/MM/yyyy") + "]]></cell>";
            xml += "<cell><![CDATA[" + row["nguoicapnhat"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["mota"] + "]]></cell>";
            xml += "<cell><![CDATA[" + row["hoatdong"] + "]]></cell>";
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}