using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
/// <summary>
/// Summary description for ObjectsCustom
/// </summary>
/// 
namespace VoNgocNhan
{
    public class API_Data
    {
        public static string add = "add";
        public static string edit = "edit";
        public static string del = "del";
        public static string img = "img";

        public static List<string> GetDifferences(object obj1, object obj2, List<string> excludeProps = null)
        {
            if (excludeProps == null)
                excludeProps = new List<string>();
            string[] exclude = {"nguoitao", "ngaytao", "nguoicapnhat", "ngaycapnhat" };
            excludeProps.AddRange(exclude);
            List<string> changes = new List<string>();
            var type = obj1.GetType();

            foreach (var prop in type.GetProperties())
            {
                // 1. Kiểm tra nếu thuộc tính nằm trong danh sách loại trừ
                if (excludeProps.Contains(prop.Name)) continue;

                // 2. Lấy giá trị của 2 đối tượng
                var val1 = prop.GetValue(obj1);
                var val2 = prop.GetValue(obj2);

                // 3. So sánh giá trị
                if (!object.Equals(val1, val2))
                {
                    changes.Add($"{prop.Name}: '{val2}' -> '{val1}'");
                }
            }
            return changes;
        }

        public static void themLichSuHoatDong(LinqDBDataContext db, HttpContext context, ad_log log_cp, bool submit = false)
        {
            var log = db.ad_logs.Where(s =>
                s.table == log_cp.table &
                s.id_lienket == log_cp.id_lienket &
                s.hanhdong == log_cp.hanhdong &
                (s.anco1_check ?? false) == false &
                (s.anhiepluc_check ?? false) == false &
                (s.anbinh_check ?? false) == false &
                (s.nexxdecor_check ?? false) == false
            ).FirstOrDefault();

            if (log == null)
            {
                log = new ad_log();
                log.ad_log_id = Helper.getNewId();
                log.taikhoan = UserUtils.getUser(context);
                log.table = log_cp.table;
                log.hanhdong = log_cp.hanhdong;
                log.id_lienket = log_cp.id_lienket;
                log.anco1_check = log_cp.anco1_check;
                log.anhiepluc_check = log_cp.anhiepluc_check;
                log.anbinh_check = log_cp.anbinh_check;
                log.nexxdecor_check = log_cp.nexxdecor_check;
                log.chitiet = log_cp.chitiet;
                log.ngaytao = DateTime.Now;
                log.nguoitao = log.taikhoan;
                db.ad_logs.InsertOnSubmit(log);
            }
            else
            {
                log.ngaytao = DateTime.Now;
            }

            if (submit)
                db.SubmitChanges();
        }

        public static DataTable layThongTinChiTiet(string table, string id, string key = "")
        {
            if (string.IsNullOrWhiteSpace(key))
                key = table + "_id";
            string sql = $"select * from {table} where {key} = '{id}'";
            return mdbc.GetData(sql);
        }
    }
}