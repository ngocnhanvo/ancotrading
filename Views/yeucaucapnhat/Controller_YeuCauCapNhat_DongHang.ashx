<%@ WebHandler Language="C#" Class="Controller_YeuCauCapNhat_DongHang" %>

using System;
using System.Web;
using System.Data.Linq;
using System.Linq;
using System.Data;
using ExcelLibrary.SpreadSheet;
using System.Collections.Generic;
using System.IO;
public class Controller_YeuCauCapNhat_DongHang : IHttpHandler, IDisposable
{
    private LinqDBDataContext db = new LinqDBDataContext();

    public void Dispose()
    {
        if (db != null)
        {
            db.Dispose();
            db = null;
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.DisposeOnPipelineCompleted(this);
        String action, oper;
        action = context.Request.QueryString["action"];
        oper = context.Request.Form["oper"];
        switch (action)
        {
            case "taotudong":
                this.taotudong(context);
                break;
            default:
                switch (oper)
                {
                    case "del":
                        this.del(context);
                        break;
                    case "edit":
                        this.edit(context);
                        break;
                    case "add":
                        this.add(context);
                        break;
                    default:
                        this.load(context);
                        break;
                }
                break;
        }
    }

    private void updateLog(ad_log log, string ma_dtkd, List<md_phieuthongtinsanpham_log> pttspLogs)
    {
        if (pttspLogs != null)
        {
            pttspLogs.Add(new md_phieuthongtinsanpham_log()
            {
                ad_log_id = log.ad_log_id,
                table = log.table,
                id_lienket = log.id_lienket,
                ma_lienket = log.ma_lienket,
                chitiet = log.chitiet,
                hanhdong = log.hanhdong,
                ngaytao = log.ngaytao
            });
        }

        if (ma_dtkd == "ANCO1")
        {
            log.anco1_check = pttspLogs != null;
        }
        else if (ma_dtkd == "ANHIEPLUC")
        {
            log.anhiepluc_check = pttspLogs != null;
        }
    }

    public void taotudong(HttpContext context)
    {
        string msg = "";
        var idpr = context.Request.Form["idpr"];
        var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == idpr).FirstOrDefault();
        if (pyc == null)
        {
            msg = $@"Không tìm thấy phiếu đã chọn";
            goto EndEventHandler;
        }

        if (pyc.trangthai1 != Helper.SOANTHAO)
        {
            msg = $@"Phiếu yêu cầu không ở trạng thái Soạn Thảo";
            goto EndEventHandler;
        }

        var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == pyc.md_doitackinhdoanh_id).FirstOrDefault();

        var logs = new List<ad_log>();
        var pttspLogs_old = db.md_phieuthongtinsanpham_logs.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
        foreach (var logpttsp in pttspLogs_old)
        {
            var log = db.ad_logs.Where(s => s.ad_log_id == logpttsp.ad_log_id).FirstOrDefault();
            if (log != null)
            {
                updateLog(log, dtkd.ma_dtkd, null);
                logs.Add(log);
            }
        }
        db.md_phieuthongtinsanpham_logs.DeleteAllOnSubmit(pttspLogs_old);

        var logidsNot = logs.Select(s => s.ad_log_id).ToList();
        if (dtkd.ma_dtkd == "ANCO1")
        {
            logs = logs.Where(s => s.anco1_check == false).ToList();
            logs.AddRange(db.ad_logs.Where(s => s.anco1_check == false && !logidsNot.Contains(s.ad_log_id)).ToList());
        }
        else if (dtkd.ma_dtkd == "ANHIEPLUC")
        {
            logs = logs.Where(s => s.anhiepluc_check == false).ToList();
            logs.AddRange(db.ad_logs.Where(s => s.anhiepluc_check == false && !logidsNot.Contains(s.ad_log_id)).ToList());
        }

        var sps = new List<md_phieuthongtinsanpham_sanpham>();
        var pttspLogs = new List<md_phieuthongtinsanpham_log>();
        foreach (var log in logs)
        {
            if (log.table == typeof(md_sanpham).Name)
            {
                var sp = db.md_sanphams.Where(s => s.md_sanpham_id == log.id_lienket & s.trangthai != Helper.SOANTHAO).FirstOrDefault();
                if (sp != null)
                {
                    var spmd = db.md_nhacungungmacdinhs.Where(s => s.md_doitackinhdoanh_id == dtkd.md_doitackinhdoanh_id & s.md_sanpham_id == sp.md_sanpham_id).FirstOrDefault();
                    if (spmd != null)
                    {
                        sps.Add(new md_phieuthongtinsanpham_sanpham()
                        {
                            md_sanpham_id = sp.md_sanpham_id,
                            thongtinkhac = true
                        });

                        updateLog(log, dtkd.ma_dtkd, pttspLogs);
                    }
                }
            }
            else if (log.table == typeof(md_donggoi).Name)
            {
                var dg = db.md_donggois.Where(s => s.md_donggoi_id == log.id_lienket).FirstOrDefault();
                if (dg == null)
                {
                    if (log.hanhdong == VoNgocNhan.API_Data.del)
                    {
                        updateLog(log, dtkd.ma_dtkd, pttspLogs);
                    }
                    continue;
                }
                var dgsps = db.md_donggoisanphams.Where(s => s.md_donggoi_id == dg.md_donggoi_id).ToList();
                if (dgsps.Count > 0)
                {
                    foreach (var dgsp in dgsps)
                    {
                        var spdg = db.md_sanphams.Where(s => s.md_sanpham_id == dgsp.md_sanpham_id & s.trangthai != Helper.SOANTHAO).FirstOrDefault();
                        if (spdg != null)
                        {
                            var spmd = db.md_nhacungungmacdinhs.Where(s => s.md_doitackinhdoanh_id == dtkd.md_doitackinhdoanh_id & s.md_sanpham_id == spdg.md_sanpham_id).FirstOrDefault();
                            if (spmd != null)
                            {
                                sps.Add(new md_phieuthongtinsanpham_sanpham()
                                {
                                    md_sanpham_id = spdg.md_sanpham_id,
                                    donggoi = true
                                });

                                updateLog(log, dtkd.ma_dtkd, pttspLogs);
                            }
                        }
                    }
                }
            }
            else if (log.table == typeof(md_donggoisanpham).Name)
            {
                var dgsp = db.md_donggoisanphams.Where(s => s.md_donggoisanpham_id == log.id_lienket).FirstOrDefault();
                if (dgsp == null)
                {
                    if (log.hanhdong == VoNgocNhan.API_Data.del)
                    {
                        updateLog(log, dtkd.ma_dtkd, pttspLogs);
                    }
                    continue;
                }
                var spdg = db.md_sanphams.Where(s => s.md_sanpham_id == dgsp.md_sanpham_id & s.trangthai != Helper.SOANTHAO).FirstOrDefault();
                if (spdg != null)
                {
                    var spmd = db.md_nhacungungmacdinhs.Where(s => s.md_doitackinhdoanh_id == dtkd.md_doitackinhdoanh_id & s.md_sanpham_id == spdg.md_sanpham_id).FirstOrDefault();
                    if (spmd != null)
                    {
                        sps.Add(new md_phieuthongtinsanpham_sanpham()
                        {
                            md_sanpham_id = spdg.md_sanpham_id,
                            donggoi = true
                        });
                        updateLog(log, dtkd.ma_dtkd, pttspLogs);
                    }
                }
            }
            else if (log.table == typeof(md_banggia).Name)
            {
                var bg = db.md_banggias.Where(s => s.md_banggia_id == log.id_lienket).FirstOrDefault();
                if (bg == null)
                {
                    if (log.hanhdong == VoNgocNhan.API_Data.del)
                    {
                        updateLog(log, dtkd.ma_dtkd, pttspLogs);
                    }
                    continue;
                }

                if (bg.ten_banggia.StartsWith($"{dtkd.ma_dtkd}-GIAMUA"))
                {
                    updateLog(log, dtkd.ma_dtkd, pttspLogs);
                }
            }
            else if (log.table == typeof(md_phienbangia).Name)
            {
                var pbg = db.md_phienbangias.Where(s => s.md_phienbangia_id == log.id_lienket).FirstOrDefault();
                if (pbg == null)
                {
                    if (log.hanhdong == VoNgocNhan.API_Data.del)
                    {
                        updateLog(log, dtkd.ma_dtkd, pttspLogs);
                    }
                    continue;
                }

                var bg = db.md_banggias.Where(s => s.md_banggia_id == log.id_lienket).FirstOrDefault();
                if (bg == null) continue;

                if (bg.ten_banggia.StartsWith($"{dtkd.ma_dtkd}-GIAMUA"))
                {
                    updateLog(log, dtkd.ma_dtkd, pttspLogs);
                }
            }
            else if (log.table == typeof(md_giasanpham).Name)
            {
                var gsp = db.md_giasanphams.Where(s => s.md_giasanpham_id == log.id_lienket).FirstOrDefault();
                if (gsp == null)
                {
                    if (log.hanhdong == VoNgocNhan.API_Data.del)
                    {
                        updateLog(log, dtkd.ma_dtkd, pttspLogs);
                    }
                    continue;
                }
                var pbg = db.md_phienbangias.Where(s => s.md_phienbangia_id == gsp.md_phienbangia_id).FirstOrDefault();
                if (pbg == null) continue;
                var bg = db.md_banggias.Where(s => s.md_banggia_id == pbg.md_banggia_id).FirstOrDefault();
                if (bg == null) continue;

                if (bg.ten_banggia.StartsWith($"{dtkd.ma_dtkd}-GIAMUA"))
                {
                    if (pbg.md_trangthai_id == Helper.HIEULUC)
                    {
                        var spgia = db.md_sanphams.Where(s => s.md_sanpham_id == gsp.md_sanpham_id & s.trangthai != Helper.SOANTHAO).FirstOrDefault();
                        if (spgia != null)
                        {
                            sps.Add(new md_phieuthongtinsanpham_sanpham()
                            {
                                md_sanpham_id = spgia.md_sanpham_id,
                                gia = true
                            });

                            updateLog(log, dtkd.ma_dtkd, pttspLogs);
                        }
                    }
                }
            }
            else if(!string.IsNullOrWhiteSpace(log.ma_lienket))
            {
                updateLog(log, dtkd.ma_dtkd, pttspLogs);
            }
            //else if (log.table == typeof(md_chungloai).Name)
            //{
            //    var spcls = db.md_sanphams.Where(s => s.md_chungloai_id == log.id_lienket & s.trangthai != Helper.SOANTHAO).ToList();
            //    if (spcls.Count <= 0) continue;
            //    foreach (var spcl in spcls)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = spcl.md_sanpham_id,
            //            chungloai = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
            //else if (log.table == typeof(md_kieudang).Name)
            //{
            //    var spkds = db.md_sanphams.Where(s => s.md_kieudang_id == log.id_lienket & s.trangthai != Helper.SOANTHAO).ToList();
            //    if (spkds.Count <= 0) continue;
            //    foreach (var spkd in spkds)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = spkd.md_sanpham_id,
            //            kieudang = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
            //else if (log.table == typeof(md_chucnang).Name)
            //{
            //    var spcns = db.md_sanphams.Where(s => s.md_chucnang_id == log.id_lienket & s.trangthai != Helper.SOANTHAO).ToList();
            //    if (spcns.Count <= 0) continue;
            //    foreach (var spcn in spcns)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = spcn.md_sanpham_id,
            //            chucnang = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
            //else if (log.table == typeof(md_nhomnangluc).Name)
            //{
            //    var spnnls = db.md_sanphams.Where(s => s.md_nhomnangluc_id == log.id_lienket & s.trangthai != Helper.SOANTHAO).ToList();
            //    if (spnnls.Count <= 0) continue;
            //    foreach (var spnnl in spnnls)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = spnnl.md_sanpham_id,
            //            nhomnangluc = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
            //else if (log.table == typeof(md_hscode).Name)
            //{
            //    var sphscs = db.md_sanphams.Where(s => s.md_hscode_id == log.id_lienket & s.trangthai != Helper.SOANTHAO).ToList();
            //    if (sphscs.Count <= 0) continue;
            //    foreach (var sphsc in sphscs)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = sphsc.md_sanpham_id,
            //            hscode = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
            //else if (log.table == typeof(md_detai).Name)
            //{
            //    var dt = db.md_detais.Where(s => s.md_detai_id == log.id_lienket).FirstOrDefault();
            //    if (dt == null) continue;
            //    var spdts = db.md_sanphams.Where(s =>
            //        s.ma_sanpham.Substring(0, 2) == dt.code_cl
            //        & s.ma_sanpham.Substring(6, 2) == dt.code_dt
            //        & s.trangthai != Helper.SOANTHAO
            //        ).ToList();
            //    foreach (var spdt in spdts)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = spdt.md_sanpham_id,
            //            detai = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
            //else if (log.table == typeof(md_mausac).Name)
            //{
            //    var ms = db.md_mausacs.Where(s => s.md_mausac_id == log.id_lienket).FirstOrDefault();
            //    if (ms == null) continue;
            //    var spmss = db.md_sanphams.Where(s =>
            //        s.ma_sanpham.Substring(0, 2) == ms.code_cl
            //        & s.ma_sanpham.Substring(6, 2) == ms.code_dt
            //        & s.ma_sanpham.Substring(12, 2) == ms.code_mau
            //        & s.trangthai != Helper.SOANTHAO
            //        ).ToList();
            //    foreach (var spms in spmss)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = spms.md_sanpham_id,
            //            mausac = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
            //else if (log.table == typeof(md_hanghoadocquyen).Name)
            //{
            //    var hhdq = db.md_hanghoadocquyens.Where(s => s.md_hanghoadocquyen_id == log.id_lienket).FirstOrDefault();
            //    if (hhdq == null) continue;
            //    var spdqs = db.md_sanphams.Where(s => s.md_sanpham_id == hhdq.md_sanpham_id & s.trangthai != Helper.SOANTHAO).ToList();
            //    foreach (var spdq in spdqs)
            //    {
            //        sps.Add(new md_phieuthongtinsanpham_sanpham()
            //        {
            //            md_sanpham_id = spdq.md_sanpham_id,
            //            docquyen = true
            //        });

            //        updateLog(log, dtkd.ma_dtkd, pttspLogs);
            //    }
            //}
        }

        if (sps.Count <= 0 & pttspLogs.Count <= 0)
        {
            msg = "Không có dòng hàng nào được tạo";
            goto EndEventHandler;
        }

        if (sps.Count > 0)
        {
            var groupedSps = sps.GroupBy(s => s.md_sanpham_id)
                .Select(g => new md_phieuthongtinsanpham_sanpham()
                {
                    md_phieuthongtinsanpham_sanpham_id = Helper.getNewId(),
                    md_sanpham_id = g.Key,
                    md_phieuthongtinsanpham_id = pyc.md_phieuthongtinsanpham_id,
                    chungloai = g.Any(x => x.chungloai == true),
                    kieudang = g.Any(x => x.kieudang == true),
                    chucnang = g.Any(x => x.chucnang == true),
                    detai = g.Any(x => x.detai == true),
                    mausac = g.Any(x => x.mausac == true),
                    hscode = g.Any(x => x.hscode == true),
                    nhomnangluc = g.Any(x => x.nhomnangluc == true),
                    docquyen = g.Any(x => x.docquyen == true),
                    gia = g.Any(x => x.gia == true),
                    donggoi = g.Any(x => x.donggoi == true),
                    thongtinkhac = g.Any(x => x.thongtinkhac == true)
                })
                .ToList();
            sps = db.md_phieuthongtinsanpham_sanphams.Where(s => s.md_phieuthongtinsanpham_id == pyc.md_phieuthongtinsanpham_id).ToList();
            db.md_phieuthongtinsanpham_sanphams.DeleteAllOnSubmit(sps);
            db.md_phieuthongtinsanpham_sanphams.InsertAllOnSubmit(groupedSps);
        }

        pttspLogs = pttspLogs
            .GroupBy(p => p.ad_log_id)
            .Select(g => g.First())
            .ToList();
        foreach (var pttspLog in pttspLogs)
        {
            pttspLog.md_phieuthongtinsanpham_log_id = Helper.getNewId();
            pttspLog.md_phieuthongtinsanpham_id = pyc.md_phieuthongtinsanpham_id;
            db.md_phieuthongtinsanpham_logs.InsertOnSubmit(pttspLog);
        }
        db.SubmitChanges();

    EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Tạo tự động thành công");
    }

    public void edit(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"];
        string ma_sanpham = context.Request.Form["ma_sanpham"].removeAllSpaceOrTrimText(true);
        try
        {
            var dh = db.md_phieuthongtinsanpham_sanphams.Where(s => s.md_phieuthongtinsanpham_sanpham_id == id).FirstOrDefault();
            if (dh == null)
            {
                msg = $@"Không tìm thấy dòng hàng đang chọn";
                goto EndEventHandler;
            }

            var sp = db.md_sanphams.Where(s => s.ma_sanpham == ma_sanpham).FirstOrDefault();
            if (sp == null)
            {
                msg = $@"Không tìm thấy dòng ""sản phẩm"" đã chọn";
                goto EndEventHandler;
            }

            var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == dh.md_phieuthongtinsanpham_id).FirstOrDefault();
            if (pyc.trangthai1 != Helper.SOANTHAO)
            {
                msg = $@"Phiếu yêu cầu không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == pyc.md_doitackinhdoanh_id).FirstOrDefault();
            var nccmd = db.md_nhacungungmacdinhs.Where(s => s.md_sanpham_id == sp.md_sanpham_id & (s.macdinh ?? false) == true).FirstOrDefault();
            if (nccmd == null)
            {
                msg = $@"Mã hàng ""{sp.ma_sanpham}"" chưa có nhà cung cấp mặc định";
                goto EndEventHandler;
            }

            if (nccmd.md_doitackinhdoanh_id != pyc.md_doitackinhdoanh_id)
            {
                msg = $@"Mã hàng ""{sp.ma_sanpham}"" không thuộc nhà cung cấp ""{dtkd.ma_dtkd}""";
                goto EndEventHandler;
            }

            dh.md_sanpham_id = sp.md_sanpham_id;
            dh.chungloai = context.Request.Form["chungloai"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.kieudang = context.Request.Form["kieudang"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.chucnang = context.Request.Form["chucnang"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.detai = context.Request.Form["detai"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.mausac = context.Request.Form["mausac"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.donggoi = context.Request.Form["donggoi"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.gia = context.Request.Form["gia"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.hscode = context.Request.Form["hscode"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.nhomnangluc = context.Request.Form["nhomnangluc"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.docquyen = context.Request.Form["docquyen"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.thongtinkhac = context.Request.Form["thongtinkhac"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.ngaycapnhat = DateTime.Now;
            dh.nguoicapnhat = UserUtils.getUser(context);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Sửa thành công");
    }

    public void add(HttpContext context)
    {
        string msg = "";
        string idpr = context.Request.Form["idpr"];
        string ma_sanpham = context.Request.Form["ma_sanpham"].removeAllSpaceOrTrimText(true);
        try
        {
            var sp = db.md_sanphams.Where(s => s.ma_sanpham == ma_sanpham).FirstOrDefault();
            if (sp == null)
            {
                msg = $@"Không tìm thấy dòng ""sản phẩm"" đã chọn";
                goto EndEventHandler;
            }

            var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == idpr).FirstOrDefault();
            if (pyc.trangthai1 != Helper.SOANTHAO)
            {
                msg = $@"Phiếu yêu cầu không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            var dtkd = db.md_doitackinhdoanhs.Where(s => s.md_doitackinhdoanh_id == pyc.md_doitackinhdoanh_id).FirstOrDefault();
            var nccmd = db.md_nhacungungmacdinhs.Where(s => s.md_sanpham_id == sp.md_sanpham_id & (s.macdinh ?? false) == true).FirstOrDefault();
            if (nccmd == null)
            {
                msg = $@"Mã hàng ""{sp.ma_sanpham}"" chưa có nhà cung cấp mặc định";
                goto EndEventHandler;
            }

            if (nccmd.md_doitackinhdoanh_id != pyc.md_doitackinhdoanh_id)
            {
                msg = $@"Mã hàng ""{sp.ma_sanpham}"" không thuộc nhà cung cấp ""{dtkd.ma_dtkd}""";
                goto EndEventHandler;
            }

            var dh = new md_phieuthongtinsanpham_sanpham();
            dh.md_phieuthongtinsanpham_sanpham_id = Helper.getNewId();
            dh.md_phieuthongtinsanpham_id = pyc.md_phieuthongtinsanpham_id;
            dh.md_sanpham_id = sp.md_sanpham_id;
            dh.chungloai = context.Request.Form["chungloai"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.kieudang = context.Request.Form["kieudang"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.chucnang = context.Request.Form["chucnang"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.detai = context.Request.Form["detai"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.mausac = context.Request.Form["mausac"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.donggoi = context.Request.Form["donggoi"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.gia = context.Request.Form["gia"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.hscode = context.Request.Form["hscode"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.nhomnangluc = context.Request.Form["nhomnangluc"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.docquyen = context.Request.Form["docquyen"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.thongtinkhac = context.Request.Form["thongtinkhac"].removeAllSpaceOrTrimText(true).ToNullableBool();
            dh.ngaytao = DateTime.Now;
            dh.nguoitao = UserUtils.getUser(context);
            dh.ngaycapnhat = DateTime.Now;
            dh.nguoicapnhat = UserUtils.getUser(context);
            db.md_phieuthongtinsanpham_sanphams.InsertOnSubmit(dh);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Thêm thành công");
    }


    public void del(HttpContext context)
    {
        string msg = "";
        string id = context.Request.Form["id"].removeAllSpaceOrTrimText(true);
        try
        {
            var dh = db.md_phieuthongtinsanpham_sanphams.Where(s => s.md_phieuthongtinsanpham_sanpham_id == id).FirstOrDefault();
            if (dh == null)
            {
                msg = $@"Không tìm thấy dòng hàng";
                goto EndEventHandler;
            }

            var pyc = db.md_phieuthongtinsanphams.Where(s => s.md_phieuthongtinsanpham_id == dh.md_phieuthongtinsanpham_id).FirstOrDefault();
            if (pyc == null)
            {
                msg = $@"Không tìm thấy phiếu yêu cầu";
                goto EndEventHandler;
            }

            if (pyc.trangthai1 != Helper.SOANTHAO)
            {
                msg = $@"Phiếu không ở trạng thái Soạn Thảo";
                goto EndEventHandler;
            }

            db.md_phieuthongtinsanpham_sanphams.DeleteOnSubmit(dh);
            db.SubmitChanges();
        }
        catch (Exception ex)
        {
            msg = ex.Message;
        }

    EndEventHandler:;

        if (msg.Length > 0)
            jqGridHelper.Utils.writeResult(0, msg);
        else
            jqGridHelper.Utils.writeResult(1, "Xóa thành công");
    }

    public void load(HttpContext context)
    {
        context.Response.ContentType = "text/xml";
        context.Response.Charset = "UTF-8";
        String id = context.Request.QueryString["id"];
        //// filter
        String filter = "";
        bool _search = bool.Parse(context.Request.QueryString["_search"]);
        if (_search)
        {
            String _filters = context.Request.QueryString["filters"];
            jqGridHelper.Filter f = jqGridHelper.Filter.CreateFilter(_filters);
            filter = f.ToScript();
        }

        String sqlCount = $@"
            SELECT COUNT(1) AS count 
            FROM md_phieuthongtinsanpham_sanpham tt
            left join md_sanpham sp on sp.md_sanpham_id = tt.md_sanpham_id
            WHERE tt.md_phieuthongtinsanpham_id = '{id}' {filter}
        ";
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
            sidx = "sp.ma_sanpham";
            sord = "asc";
        }

        string strsql = $@"
        select * from (
            select 
                tt.md_phieuthongtinsanpham_sanpham_id, 
                sp.ma_sanpham,
                tt.chungloai,
                tt.kieudang,
                tt.chucnang,
	            tt.detai,
	            tt.mausac,
	            tt.donggoi,
	            tt.gia,
                tt.hscode,
                tt.nhomnangluc,
                tt.docquyen,
                tt.thongtinkhac,
                tt.ngaytao, 
                tt.nguoitao, 
                tt.ngaycapnhat, 
                tt.nguoicapnhat, 
                tt.mota,
                tt.hoatdong,
                ROW_NUMBER() OVER (ORDER BY {sidx} {sord}) as RowNum
            FROM md_phieuthongtinsanpham_sanpham tt
                left join md_sanpham sp on sp.md_sanpham_id = tt.md_sanpham_id
            WHERE tt.md_phieuthongtinsanpham_id = '{id}' {filter}
        )P WHERE RowNum > @start AND RowNum < @end";

        var dt = mdbc.GetData(strsql, "@start", start, "@end", end);
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        xml += "<rows>";
        xml += "<page>" + page + "</page>";
        xml += "<total>" + total_page + "</total>";
        xml += "<records>" + count + "</records>";
        foreach (System.Data.DataRow row in dt.Rows)
        {
            xml += "<row>";
            foreach (System.Data.DataColumn column in dt.Columns)
            {
                if (column.DataType == System.Type.GetType("System.DateTime"))
                {
                    try
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", ((DateTime)row[column.ColumnName]).ToString("dd/MM/yyyy"));
                    }
                    catch
                    {
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                    }
                }
                else if (column.DataType == Type.GetType("System.Decimal"))
                {
                    if (row[column.ColumnName] != null)
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
                    else
                        xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", "");
                }
                else
                {
                    xml += string.Format(@"<cell><![CDATA[{0}]]></cell>", row[column.ColumnName]);
                }
            }
            xml += "</row>";
        }
        xml += "</rows>";
        context.Response.Write(xml);
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
