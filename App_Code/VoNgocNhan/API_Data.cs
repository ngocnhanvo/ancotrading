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
            var log = new ad_log();
            log.ad_log_id = Helper.getNewId();
            log.taikhoan = UserUtils.getUser(context);
            log.table = table;
            log.hanhdong = hanhdong;
            log.id_lienket = id;
            log.ngaytao = DateTime.Now;
            log.nguoitao = log.taikhoan;
            db.ad_logs.InsertOnSubmit(log);

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