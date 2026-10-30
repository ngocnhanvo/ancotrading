<%@ WebHandler Language="C#" Class="Controller_PhanBoCocPO" %>
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using Newtonsoft.Json;

public class Controller_PhanBoCocPO : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.Charset = "UTF-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.TrySkipIisCustomErrors = true;

        if (!String.Equals(context.Request.HttpMethod, "GET", StringComparison.OrdinalIgnoreCase))
        {
            Error(context, 405, "method_not_allowed", "API phân bổ cọc hiện chỉ hỗ trợ đọc.");
            return;
        }

        if (!String.Equals(context.Request.QueryString["action"], "load", StringComparison.OrdinalIgnoreCase))
        {
            Error(context, 400, "invalid_action", "Thao tác không hợp lệ.");
            return;
        }

        string invoiceId = (context.Request.QueryString["invoiceId"] ?? "").Trim();
        if (invoiceId.Length == 0 || invoiceId.Length > 32)
        {
            Error(context, 400, "invalid_invoice", "Chưa chọn Invoice hợp lệ.");
            return;
        }

        try
        {
            using (var db = new LinqDBDataContext())
            {
                string user = UserUtils.getUser(context);
                if (String.IsNullOrWhiteSpace(user))
                {
                    Error(context, 401, "unauthorized", "Vui lòng đăng nhập lại.");
                    return;
                }

                var invoice = db.c_packinginvoices
                    .Where(p => p.c_packinginvoice_id == invoiceId)
                    .Select(p => new { p.c_packinginvoice_id, p.so_inv, p.md_trangthai_id, p.nguoitao })
                    .FirstOrDefault();

                if (invoice == null)
                {
                    Error(context, 404, "not_found", "Không tìm thấy Invoice.");
                    return;
                }

                // Match the Invoice master grid's visibility (creator + own group, admin bypass).
                bool admin = db.nhanviens
                    .Where(p => p.manv == user)
                    .Select(p => p.isadmin)
                    .FirstOrDefault() == true;
                if (!admin && !String.Equals(invoice.nguoitao, user, StringComparison.OrdinalIgnoreCase))
                {
                    var group = LinqUtils.GetUserListInGroup(user);
                    if (group == null || !group.Any(p => String.Equals(p, invoice.nguoitao, StringComparison.OrdinalIgnoreCase)))
                    {
                        Error(context, 403, "forbidden", "Bạn không có quyền xem Invoice này.");
                        return;
                    }
                }

                using (var connection = new SqlConnection(db.Connection.ConnectionString))
                {
                    connection.Open();
                    using (var check = new SqlCommand(
                        "SELECT OBJECT_ID(N'dbo.c_packinginvoice_phanbo', N'U')", connection))
                    {
                        if (check.ExecuteScalar() == DBNull.Value)
                        {
                            Error(context, 503, "schema_pending",
                                "Chưa có bảng c_packinginvoice_phanbo. Quản trị SQL cần chạy script docs/database/migrations/20261030_c_packinginvoice_phanbo.sql.");
                            return;
                        }
                    }

                    var poRows = new List<object>();
                    var detailRows = new List<object>();

                    // Invoice may contain many lines of the SAME PO; DISTINCT is required.
                    // The active total excludes draft allocations, which do NOT reserve money.
                    const string poSql = @"
                        WITH linked_po AS (
                            SELECT DISTINCT d.c_donhang_id
                            FROM dbo.c_dongpklinv d
                            WHERE d.c_packinginvoice_id = @invoiceId
                              AND d.c_donhang_id IS NOT NULL
                        )
                        SELECT dh.c_donhang_id, dh.sochungtu,
                               CONVERT(decimal(18,2), ISNULL(dh.datcoc, 0)) AS datcoc,
                               CONVERT(decimal(18,2), ISNULL(activePb.tong, 0)) AS daphanbo,
                               CONVERT(decimal(18,2), ISNULL(dh.datcoc, 0) - ISNULL(activePb.tong, 0)) AS conlai,
                               CONVERT(decimal(18,2), ISNULL(currentPb.tong, 0)) AS phanboinv
                        FROM linked_po l
                        JOIN dbo.c_donhang dh ON dh.c_donhang_id = l.c_donhang_id
                        OUTER APPLY (
                            SELECT SUM(pb.sotienphanbo) AS tong
                            FROM dbo.c_packinginvoice_phanbo pb
                            JOIN dbo.c_packinginvoice pi
                              ON pi.c_packinginvoice_id = pb.c_packinginvoice_id
                            WHERE pb.c_donhang_id = dh.c_donhang_id
                              AND pi.md_trangthai_id = N'HIEULUC'
                        ) activePb
                        OUTER APPLY (
                            SELECT SUM(pb.sotienphanbo) AS tong
                            FROM dbo.c_packinginvoice_phanbo pb
                            WHERE pb.c_donhang_id = dh.c_donhang_id
                              AND pb.c_packinginvoice_id = @invoiceId
                        ) currentPb
                        ORDER BY dh.sochungtu, dh.c_donhang_id";

                    using (var cmd = new SqlCommand(poSql, connection))
                    {
                        cmd.Parameters.Add("@invoiceId", SqlDbType.NVarChar, 32).Value = invoiceId;
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                poRows.Add(new
                                {
                                    id = reader.GetString(0),
                                    code = reader.IsDBNull(1) ? "" : reader.GetString(1),
                                    deposited = reader.GetDecimal(2),
                                    allocated = reader.GetDecimal(3),
                                    remaining = reader.GetDecimal(4),
                                    currentAllocated = reader.GetDecimal(5)
                                });
                            }
                        }
                    }

                    const string detailSql = @"
                        SELECT pb.c_packinginvoice_phanbo_id, pb.c_donhang_id,
                               pb.sotienphanbo, pb.ngaytao, pb.nguoitao
                        FROM dbo.c_packinginvoice_phanbo pb
                        WHERE pb.c_packinginvoice_id = @invoiceId
                          AND EXISTS (
                              SELECT 1 FROM dbo.c_dongpklinv d
                              WHERE d.c_packinginvoice_id = pb.c_packinginvoice_id
                                AND d.c_donhang_id = pb.c_donhang_id
                          )
                        ORDER BY pb.ngaytao, pb.c_packinginvoice_phanbo_id";

                    using (var cmd = new SqlCommand(detailSql, connection))
                    {
                        cmd.Parameters.Add("@invoiceId", SqlDbType.NVarChar, 32).Value = invoiceId;
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                detailRows.Add(new
                                {
                                    id = reader.GetString(0),
                                    poId = reader.GetString(1),
                                    amount = reader.GetDecimal(2),
                                    createdAt = reader.GetDateTime(3).ToString("dd/MM/yyyy HH:mm"),
                                    createdBy = reader.IsDBNull(4) ? "" : reader.GetString(4)
                                });
                            }
                        }
                    }

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        ok = true,
                        invoice = new { id = invoice.c_packinginvoice_id, number = invoice.so_inv, status = invoice.md_trangthai_id },
                        po = poRows,
                        details = detailRows
                    }));
                }
            }
        }
        catch (SqlException)
        {
            // Avoid sending SQL schema, connection details or secrets to the browser.
            Error(context, 500, "database_error", "Không đọc được dữ liệu phân bổ cọc từ SQL Server. Vui lòng kiểm tra CSDL và bảng phân bổ.");
        }
        catch (Exception)
        {
            Error(context, 500, "unexpected_error", "Không tải được phân bổ cọc. Vui lòng kiểm tra nhật ký máy chủ.");
        }
    }

    private static void Error(HttpContext context, int status, string code, string message)
    {
        context.Response.StatusCode = status;
        context.Response.Write(JsonConvert.SerializeObject(new { ok = false, code = code, message = message }));
    }

    public bool IsReusable { get { return false; } }
}
