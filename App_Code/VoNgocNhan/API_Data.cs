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
        public static string dell = "dell";
        public static void themLichSuHoatDong(LinqDBDataContext db, HttpContext context, string table, string id, string hanhdong, bool submit = false)
        {
            var log = db.ad_logs.Where(s =>
                s.table == table &
                s.id_lienket == id &
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
                log.table = table;
                log.hanhdong = hanhdong;
                log.id_lienket = id;
                log.ngaytao = DateTime.Now;
                log.nguoitao = log.taikhoan;
                db.ad_logs.InsertOnSubmit(log);
            }
            else
            {
                log.taikhoan = UserUtils.getUser(context);
                log.hanhdong = hanhdong;
                log.nguoicapnhat = log.taikhoan;
                log.ngaycapnhat = DateTime.Now;
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