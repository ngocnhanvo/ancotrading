using Newtonsoft.Json;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
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
        private static readonly ConcurrentDictionary<string, List<string>> _schemaCache = new ConcurrentDictionary<string, List<string>>();
        public static List<string> GetDifferences(object obj1, object obj2, List<string> excludeProps = null)
        {
            if (excludeProps == null)
                excludeProps = new List<string>();
            string[] exclude = { "nguoitao", "ngaytao", "nguoicapnhat", "ngaycapnhat" };
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
                (s.anhiepluc_check ?? false) == false
                //(s.anbinh_check ?? false) == false &
                //(s.nexxdecor_check ?? false) == false
            ).FirstOrDefault();

            if (log == null)
            {
                if (log_cp.anco1_check == null)
                    log_cp.anco1_check = false;
                if (log_cp.anhiepluc_check == null)
                    log_cp.anhiepluc_check = false;

                log = new ad_log();
                log.ad_log_id = Helper.getNewId();
                log.taikhoan = UserUtils.getUser(context);
                log.table = log_cp.table;
                log.hanhdong = log_cp.hanhdong;
                log.id_lienket = log_cp.id_lienket;
                log.ma_lienket = log_cp.ma_lienket;
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
                log.ma_lienket = log_cp.ma_lienket;
                log.ngaytao = DateTime.Now;
            }

            if (submit)
                db.SubmitChanges();
        }

        public static DataTable layThongTinChiTiet(string table, string id, string key = "")
        {
            if (string.IsNullOrWhiteSpace(key))
                key = table + "_id";

            var columns = _schemaCache.GetOrAdd(table, (name) =>
            {
                // Đoạn này chỉ chạy DUY NHẤT một lần cho mỗi tên bảng
                string schemaSql = $@"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{name}'";
                var dtColumns = mdbc.GetData(schemaSql);
                return dtColumns.AsEnumerable()
                             .Select(r => r.Field<string>("COLUMN_NAME").ToLower())
                             .ToList();
            });

            string selectClause = "a.*";
            string joinClause = "";
            // Kiểm tra cột md_sanpham_id
            if (columns.Contains("md_sanpham_id") & table != "md_sanpham")
            {
                selectClause += ", sp.ma_sanpham";
                joinClause += $" LEFT JOIN md_sanpham sp ON sp.md_sanpham_id = a.md_sanpham_id";
            }
            // Kiểm tra cột md_doitackinhdoanh_id
            if (columns.Contains("md_doitackinhdoanh_id") & table != "md_doitackinhdoanh")
            {
                selectClause += ", dt.ma_dtkd";
                joinClause += $" LEFT JOIN md_doitackinhdoanh dt ON dt.md_doitackinhdoanh_id = a.md_doitackinhdoanh_id";
            }
            //Kiểm tra cột md_banggia_id
            if (columns.Contains("md_banggia_id") & table != "md_banggia")
            {
                selectClause += ", bg.ten_banggia";
                joinClause += $" LEFT JOIN md_banggia bg ON bg.md_banggia_id = a.md_banggia_id";
            }
            //Kiểm tra cột md_banggia_id
            if (columns.Contains("md_phienbanggia_id") & table != "md_phienbanggia")
            {
                selectClause += ", bg.ten_banggia";
                joinClause += $" LEFT JOIN md_phienbangia pbg ON pbg.md_phienbangia_id = a.md_phienbangia_id";
                joinClause += $" LEFT JOIN md_banggia bg ON bg.md_banggia_id = pbg.md_banggia_id";
            }
            //Kiểm tra cột md_dongtien_id
            if (columns.Contains("md_dongtien_id") & table != "md_dongtien")
            {
                selectClause += ", dt.ma_iso";
                joinClause += $" LEFT JOIN md_dongtien dt ON dt.md_dongtien_id = a.md_dongtien_id";
            }
            //Kiểm tra cột md_donvitinhsanpham_id
            if (columns.Contains("md_donvitinhsanpham_id") & table != "md_donvitinhsanpham")
            {
                selectClause += ", dvt.ten_dvt_tv";
                joinClause += $" LEFT JOIN md_donvitinhsanpham dvt ON dvt.md_donvitinhsanpham_id = a.md_donvitinhsanpham_id";
            }

            // 3. Ghép nối thành câu SQL hoàn chỉnh
            string sql = $@"
                SELECT {selectClause}
                FROM {table} a
                {joinClause}
                WHERE a.{key} = '{id}'
            ";
            return mdbc.GetData(sql);
        }
    }
}