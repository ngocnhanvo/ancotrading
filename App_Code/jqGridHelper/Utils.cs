using System;
using System.Collections.Generic;
using System.Web;
using System.IO;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;

namespace jqGridHelper
{
    public class Utils
    {
		public static double Round2(double value, int digits)
        {
            if (digits >= 0) return Math.Round(value, digits);

            double n = Math.Pow(10, -digits);
            return Math.Round(value / n, 0) * n;
        }

        public static decimal Round3(decimal d, int decimals)
        {
            if (decimals >= 0) return decimal.Round(d, decimals);

            decimal n = (decimal)Math.Pow(10, -decimals);
            return decimal.Round(d / n, 0) * n;
        }
		
		public static decimal Round4(decimal d, int decimals)
        {
            if (decimals >= 0) return Math.Round(d, decimals);

            decimal n = (decimal)Math.Pow(10, -decimals);
            return Math.Round(d / n, 0) * n;
        }

        public static decimal Round5(decimal d, int decimals)
        {
            if (decimals >= 0) return decimal.Round(d, decimals);

            decimal n = (decimal)Math.Pow(10, -decimals);
            return decimal.Ceiling(d / n) * n;
        }

        public static void writeResult(int type, string message)
        {
            HttpContext.Current.Response.Clear();
            string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
            xml += "<root>";
            xml += "<type>" + type + "</type>";
            xml += "<message>" + message + "</message>";
            xml += "</root>";
            HttpContext.Current.Response.Write(xml);
        }

        public static void ShowMsg(String Content)
        {
            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.StatusCode = 500;
            HttpContext.Current.Response.StatusDescription = Content;
            HttpContext.Current.Response.Write(Content);
        }

        public static String ToXml(int page, int totalPage, int count, params object[] values)
        {
            String result = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
            result += String.Format(
                        "<rows><page>{0}</page><total>{1}</total><records>{2}</records>"
                        , page, totalPage, count
                      );
            for (int i = 0; i < values.Length; i++)
            {
                result += "<row>";
                result += "<cell><![CDATA[" + values[i] + "]]></cell>";
                result += "</row>";
            }
            result = "</rows>";
            return result;
        }



        public static string taoChungTuPO(string md_doitackinhdoanh_id, int isdonhangmau, string namchungtu, string loaiDH = "", LinqDBDataContext db = null)
        {
            if(db == null)
                db = new LinqDBDataContext();

            string result = "";
            string ctdh = "";
            string ctmau = "";
            string namht = "";
            string namct = "";
            string nam = "";
            string makhachhang = db.md_doitackinhdoanhs.Single(k => k.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id)).ma_dtkd;

            string sql = "";
            if (isdonhangmau == 0)
            {
                    sql = @"select top 1 substring(sochungtu, 1, 3) as ctdh, SUBSTRING(sochungtu, 1, 3) as ctmau, datepart(YEAR, GETDATE()), DATEPART(YEAR, ngaylap) 
                    from c_donhang 
                    where donhang_mau = 0 and isdonhangtmp = 0 and year(ngaylap) = " + namchungtu + " and md_doitackinhdoanh_id ='" + md_doitackinhdoanh_id + "' order by SUBSTRING(sochungtu, 1, 3) desc";
            }
            if (isdonhangmau == 1)
            {
                sql = @"select top 1 substring(sochungtu, 1, 3) as ctdh, SUBSTRING(sochungtu, 1, 3) as ctmau, datepart(YEAR, GETDATE()), DATEPART(YEAR, ngaylap) 
                    from c_donhang 
                    where donhang_mau = 1 and isdonhangtmp = 0 and year(ngaylap) = " + namchungtu + " and md_doitackinhdoanh_id ='" + md_doitackinhdoanh_id + "' order by SUBSTRING(sochungtu, 1, 3) desc";
            }
            else if(isdonhangmau == 2)// don hang tmp
            {
                sql = @"select top 1 substring(sochungtu, 1, 3) as ctdh, SUBSTRING(sochungtu, 1, 3) as ctmau, datepart(YEAR, GETDATE()), DATEPART(YEAR, ngaylap) 
                    from c_donhang 
                    where donhang_mau = 0 and isdonhangtmp = 1 and year(ngaylap) = " + namchungtu + " and md_doitackinhdoanh_id ='" + md_doitackinhdoanh_id + "' order by SUBSTRING(sochungtu, 1, 3) desc";
            }
            
            DataTable data = mdbc.GetData(sql);
            foreach (DataRow item in data.Rows)
            {
                ctdh = item[0].ToString();
                ctmau = item[1].ToString();
                namht = item[2].ToString();
                namct = item[3].ToString();
            }

            if (!string.IsNullOrWhiteSpace(loaiDH))
                makhachhang = makhachhang + "_" + loaiDH;

            if (isdonhangmau == 0)//la don hang cua khach
            {

                if (data.Rows.Count == 0)//neu chua co don hang nao cua khach nay
                {

                    result = "001/" + makhachhang + "-" + namchungtu.Substring(2, 2);
                }
                else
                {
                    //nam = (!namht.Equals(namct) ? namht.Substring(2, 2) : namct.Substring(2, 2));
                    result = genericNumberDoc(ctdh) + "/" + makhachhang + "-" + namchungtu.Substring(2, 2);
                }
            }
            else if (isdonhangmau == 1)//la don hang mau
            {
                if (data.Rows.Count == 0)//neu chua co don hang nao cua khach nay
                {
                    result = "001/" + makhachhang + "_SR-" + namchungtu.Substring(2, 2);
                }
                else
                {
                    //nam = (!namht.Equals(namct) ? namht.Substring(2, 2) : namct.Substring(2, 2));
                    result = genericNumberDoc(ctmau) + "/" + makhachhang + "_SR-" + namchungtu.Substring(2, 2);
                }
            }
            else if (isdonhangmau == 2) // la don hang tmp
            {
                if (data.Rows.Count == 0)//neu chua co don hang nao cua khach nay
                {
                    result = "001/" + makhachhang + "_TI-" + namchungtu.Substring(2, 2);
                }
                else
                {
                    //nam = (!namht.Equals(namct) ? namht.Substring(2, 2) : namct.Substring(2, 2));
                    result = genericNumberDoc(ctmau) + "/" + makhachhang + "_TI-" + namchungtu.Substring(2, 2);
                }
            }

            return result;
        }

        public static string taoChungTuXuatKho(md_doitackinhdoanh dtkd, LinqDBDataContext db = null)
        {
            if (db == null)
                db = new LinqDBDataContext();

            string result = "";
            string nam = DateTime.Now.ToString("yy");
            string makhachhang = dtkd.ma_dtkd.Substring(0, 2);

            var ctxk = db.c_packinginvoices
                .Where(s => s.md_doitackinhdoanh_id == dtkd.md_doitackinhdoanh_id)
                .OrderByDescending(s => s.ngaytao)
                .Select(s => s.so_inv).FirstOrDefault();
            ctxk = ctxk == null ? "" : ctxk;

            var rgxSCT = new Regex($"^{makhachhang} [0-9][0-9][0-9][0-9]-[0-9][0-9]$");
            if (!rgxSCT.IsMatch(ctxk))
                result = $"{makhachhang} 0001-{nam}";
            else
            {
                var indexTT = ctxk.LastIndexOf(" ") + 1;
                string tiento = ctxk.Substring(0, indexTT);
                string so = ctxk.Substring(indexTT, 4); 
                string somoi = genericNumberDoc(so, 4);
                result = $"{makhachhang} {somoi}-{nam}";
            }

            return result;
        }


        public static string taoChungTuQO(string md_doitackinhdoanh_id, int isdonhangmau, string namchungtu)//isdonhangmau default la 0 do QO ko co QO mẩu
        {
            LinqDBDataContext db = new LinqDBDataContext();
            string result = "";
            string ctdh = "";
            string namht = "";
            string namct = "";
            string nam = "";
            string makhachhang = db.md_doitackinhdoanhs.Single(k => k.md_doitackinhdoanh_id.Equals(md_doitackinhdoanh_id)).ma_dtkd;
            string sql = @"select top 1 substring(sobaogia, 1, 3) as ctdh, datepart(YEAR, GETDATE()), DATEPART(YEAR, ngaybaogia) 
                    from c_baogia 
                    where isform = "+ isdonhangmau + " and year(ngaybaogia) = " + namchungtu +  " and md_doitackinhdoanh_id ='" + md_doitackinhdoanh_id + "' order by substring(sobaogia, 1, 3) desc";
            DataTable data = mdbc.GetData(sql);
            foreach (DataRow item in data.Rows)
            {
                ctdh = item[0].ToString();
                namht = item[1].ToString();
                namct = item[2].ToString();
            }
            if (isdonhangmau == 0)//la don hang cua khach
            {

                if (data.Rows.Count == 0)//neu chua co don hang nao cua khach nay
                {

                    result = "001/" + makhachhang + "-" + namchungtu.Substring(2, 2);
                }
                else
                {
                    //nam = (!namht.Equals(namct) ? namht.Substring(2, 2) : namct.Substring(2, 2));
                    result = genericNumberDoc(ctdh) + "/" + makhachhang + "-" + namct.Substring(2, 2);
                }
            }
            else
            {
                if (data.Rows.Count == 0)//neu chua co don hang nao cua khach nay
                {

                    result = "001/" + makhachhang + "_SR-" + namchungtu.Substring(2, 2);
                }
                else
                {
                    //nam = (!namht.Equals(namct) ? namht.Substring(2, 2) : namct.Substring(2, 2));
                    result = genericNumberDoc(ctdh) + "/" + makhachhang + "_SR" + "-" + namct.Substring(2, 2);
                }
            }


            return result;
        }

        public static string taoChungTuHoaDon(LinqDBDataContext db)
        {
            string result = "";
            var mm = DateTime.Now.ToString("MM");
            var yy = DateTime.Now.ToString("yy");
            var hoadon = db.c_hoadons.Select(s => new {
                ctdh = s.sophieu.Substring(0, 3),
                thang = s.sophieu.Substring(4, 2),
                nam = s.sophieu.Substring(7, 2)
            })
            .OrderByDescending(s=>s.nam)
            .ThenByDescending(s=>s.thang)
            .ThenByDescending(s=>s.ctdh)
            .Take(1).FirstOrDefault();


            if (hoadon == null)
            {
                result = "001/" + mm + "-" + yy;
            }
            else
            {
                if(hoadon.nam == yy & hoadon.thang == mm)
                    result = genericNumberDoc(hoadon.ctdh) + "/" + hoadon.thang + "-" + hoadon.nam;
                else
                    result = "001/" + mm + "-" + yy;
            }

            return result;
        }

        public static string genericNumberDoc(string doc, int number_length = 3)
        {
            try
            {
                int sr = int.Parse(doc);
                sr = sr + 1;
                string result = sr.ToString();

                while (result.Length < number_length)
                {
                    result = "0" + result;
                }
                return result;
            }
            catch (Exception ex)
            {
                return "001";
            }
        }
    }

}