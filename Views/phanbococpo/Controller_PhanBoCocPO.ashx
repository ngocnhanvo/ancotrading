<%@ WebHandler Language="C#" Class="Controller_PhanBoCocPO" %>
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Web.SessionState;
using System.Diagnostics;
using System.Linq;
using System.Web;
using Newtonsoft.Json;

public class Controller_PhanBoCocPO : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.Charset = "UTF-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.TrySkipIisCustomErrors = true;

        bool isLoad = context.Request.HttpMethod == "GET" &&
            String.Equals(context.Request.QueryString["action"], "load", StringComparison.OrdinalIgnoreCase);
        bool isSave = context.Request.HttpMethod == "POST" &&
            String.Equals(context.Request.Form["action"], "save", StringComparison.OrdinalIgnoreCase);
        if (!isLoad && !isSave)
        {
            Error(context, 405, "method_not_allowed", "Thao tác hoặc phương thức HTTP không được hỗ trợ.");
            return;
        }
        if (isSave)
        {
            if (context.Session == null ||
                !String.Equals(context.Request.Form["csrf"], context.Session["anco_po_allocation_csrf"] as string, StringComparison.Ordinal) ||
                String.IsNullOrEmpty(context.Session["anco_po_allocation_csrf"] as string))
            {
                Error(context, 403, "invalid_csrf", "Phiên bảo vệ đã hết hạn. Tải lại trang và thử lại.");
                return;
            }
        }

        string invoiceId = ((isSave ? context.Request.Form["invoiceId"] : context.Request.QueryString["invoiceId"]) ?? "").Trim();
        if (invoiceId.Length == 0 || invoiceId.Length > 32)
        {
            Error(context, 400, "invalid_invoice", "Chưa chọn Invoice hợp lệ.");
            return;
        }

        // The error stage and SQL error number identify failures without exposing
        // SQL internals to ordinary users. Detailed SQL diagnostics require admin.
        string stage = "open_context";
        bool isAdmin = false;
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

                stage = "lookup_invoice";
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
                stage = "verify_permissions";
                bool admin = db.nhanviens
                    .Where(p => p.manv == user)
                    .Select(p => p.isadmin)
                    .FirstOrDefault() == true;
                isAdmin = admin;
                if (isSave && !admin)
                {
                    Error(context, 403, "admin_required", "Giai đoạn thử nghiệm chỉ quản trị viên mới được lưu phân bổ.");
                    return;
                }
                if (!admin && !String.Equals(invoice.nguoitao, user, StringComparison.OrdinalIgnoreCase))
                {
                    var group = LinqUtils.GetUserListInGroup(user);
                    if (group == null || !group.Any(p => String.Equals(p, invoice.nguoitao, StringComparison.OrdinalIgnoreCase)))
                    {
                        Error(context, 403, "forbidden", "Bạn không có quyền xem Invoice này.");
                        return;
                    }
                }

                stage = "connect_sql";
                using (var connection = mdbc.GetConnection)
                {
                    connection.Open();
                    if (isSave)
                    {
                        stage = "save_draft";
                        SaveDraft(context, connection, invoiceId, user);
                        return;
                    }
                    stage = "verify_table";
                    using (var check = new SqlCommand(
                        "SELECT OBJECT_ID(N'dbo.c_packinginvoice_phanbo', N'U')", connection))
                    {
                        object tableId = check.ExecuteScalar();
                        if (tableId == null || tableId == DBNull.Value)
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

                    stage = "read_po_balances";
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

                    stage = "read_allocation_details";
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

                    stage = "serialize_response";
                    // Match the existing POST guards; a disabled UI is never the security boundary.
                    string writeBlockReason = !admin
                        ? "Chỉ quản trị viên mới được lưu phân bổ cọc."
                        : !String.Equals(invoice.md_trangthai_id, "SOANTHAO", StringComparison.Ordinal)
                        ? "Invoice không ở trạng thái SOANTHAO, không thể thêm hoặc sửa phân bổ cọc."
                        : "";
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        ok = true,
                        invoice = new { id = invoice.c_packinginvoice_id, number = invoice.so_inv, status = invoice.md_trangthai_id },
                        writePolicy = new { allowed = writeBlockReason.Length == 0, reason = writeBlockReason },
                        po = poRows,
                        details = detailRows,
                        version = ComputeVersion(connection, null, invoiceId)
                    }));
                }
            }
        }
        catch (SqlException ex)
        {
            Trace.TraceError("Controller_PhanBoCocPO failed. Stage={0}, SqlNumber={1}, SqlState={2}. {3}",
                stage, ex.Number, ex.State, ex.ToString());
            // Never reveal SQL internals to non-admins. For the authenticated
            // administrator, diagnostic=1 exposes the server's exact SQL error.
            if (isAdmin && String.Equals(context.Request.QueryString["diagnostic"], "1", StringComparison.Ordinal))
            {
                context.Response.StatusCode = 500;
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    ok = false,
                    code = "database_error",
                    message = "SQL Server trả về lỗi khi tải phân bổ cọc.",
                    diagnostic = new { stage = stage, sqlNumber = ex.Number, sqlState = ex.State, sqlMessage = ex.Message }
                }));
            }
            else
            {
                Error(context, 500, "database_error", "Không đọc được dữ liệu phân bổ cọc từ SQL Server. Vui lòng kiểm tra CSDL và bảng phân bổ.");
            }
        }
        catch (Exception ex)
        {
            Trace.TraceError("Controller_PhanBoCocPO unexpected error. Stage={0}. {1}", stage, ex.ToString());
            Error(context, 500, "unexpected_error", "Không tải được phân bổ cọc. Vui lòng kiểm tra nhật ký máy chủ.");
        }
    }


    public sealed class DraftRow
    {
        public string id { get; set; }
        public string poId { get; set; }
        public decimal amount { get; set; }
    }

    private static void SaveDraft(HttpContext context, SqlConnection connection, string invoiceId, string user)
    {
        string expectedVersion = context.Request.Form["version"] ?? "";
        string json = context.Request.Form["rows"] ?? "";
        List<DraftRow> rows = null;
        try { rows = JsonConvert.DeserializeObject<List<DraftRow>>(json); }
        catch (JsonException)
        {
            Error(context, 400, "invalid_rows", "Dữ liệu phân bổ không đúng định dạng.");
            return;
        }

        if (rows == null || rows.Count > 100 || expectedVersion.Length != 64 || json.Length > 40000 ||
            rows.Any(r => r == null || String.IsNullOrWhiteSpace(r.poId) ||
                r.poId.Length > 32 || (r.id != null && r.id.Length > 40) ||
                r.amount <= 0 || r.amount > 999999999999m ||
                Decimal.Round(r.amount, 2) != r.amount))
        {
            Error(context, 400, "invalid_rows", "Mỗi dòng phải có PO hợp lệ và số tiền lớn hơn 0, tối đa 2 chữ số thập phân (tối đa 100 dòng).");
            return;
        }

        using (SqlTransaction tx = connection.BeginTransaction(IsolationLevel.Serializable))
        {
            try
            {
                string status;
                using (var cmd = new SqlCommand(
                    "SELECT md_trangthai_id FROM dbo.c_packinginvoice WITH (UPDLOCK, HOLDLOCK) WHERE c_packinginvoice_id = @invoice", connection, tx))
                {
                    cmd.Parameters.Add("@invoice", SqlDbType.NVarChar, 32).Value = invoiceId;
                    object result = cmd.ExecuteScalar();
                    status = result == null || result == DBNull.Value ? "" : Convert.ToString(result);
                }
                if (status != "SOANTHAO")
                {
                    tx.Rollback();
                    Error(context, 409, "invoice_not_draft", "Chỉ Invoice đang soạn thảo mới được lưu phân bổ.");
                    return;
                }

                // Reject stale edits instead of overwriting a second user's changes.
                if (!String.Equals(expectedVersion, ComputeVersion(connection, tx, invoiceId), StringComparison.Ordinal))
                {
                    tx.Rollback();
                    Error(context, 409, "stale_allocation", "Dữ liệu đã thay đổi trên máy chủ. Tải lại Invoice rồi thực hiện phân bổ.");
                    return;
                }

                var poIds = rows.Select(r => r.poId).Distinct(StringComparer.Ordinal).OrderBy(x => x, StringComparer.Ordinal).ToList();
                foreach (string poId in poIds)
                {
                    // Lock each PO in a predictable order; the activation phase
                    // must take these same PO locks before applying an Invoice.
                    decimal available;
                    using (var cmd = new SqlCommand(@"
                        SELECT CONVERT(decimal(18,2), ISNULL(dh.datcoc,0) - ISNULL((
                            SELECT SUM(pb.sotienphanbo) FROM dbo.c_packinginvoice_phanbo pb
                            INNER JOIN dbo.c_packinginvoice p ON p.c_packinginvoice_id = pb.c_packinginvoice_id
                            WHERE pb.c_donhang_id=dh.c_donhang_id AND p.md_trangthai_id=N'HIEULUC'
                        ),0))
                        FROM dbo.c_donhang dh WITH(UPDLOCK,HOLDLOCK)
                        WHERE dh.c_donhang_id=@poId AND EXISTS(
                            SELECT 1 FROM dbo.c_dongpklinv d
                            WHERE d.c_donhang_id=dh.c_donhang_id AND d.c_packinginvoice_id=@invoice
                        )", connection, tx))
                    {
                        cmd.Parameters.Add("@poId", SqlDbType.NVarChar, 32).Value = poId;
                        cmd.Parameters.Add("@invoice", SqlDbType.NVarChar, 32).Value = invoiceId;
                        object value = cmd.ExecuteScalar();
                        if (value == null || value == DBNull.Value)
                        {
                            tx.Rollback();
                            Error(context, 400, "po_not_linked", "PO không thuộc Invoice hoặc không tồn tại.");
                            return;
                        }
                        available = (decimal)value;
                    }
                    if (rows.Where(r => r.poId == poId).Sum(r => r.amount) > available)
                    {
                        tx.Rollback();
                        Error(context, 409, "exceeds_deposit", "Tổng tiền phân bổ vượt số cọc còn lại của PO.");
                        return;
                    }
                }

                var existing = new Dictionary<string, string>(StringComparer.Ordinal);
                using (var cmd = new SqlCommand(@"
                    SELECT c_packinginvoice_phanbo_id,c_donhang_id
                    FROM dbo.c_packinginvoice_phanbo WITH(UPDLOCK,HOLDLOCK)
                    WHERE c_packinginvoice_id=@invoice", connection, tx))
                {
                    cmd.Parameters.Add("@invoice", SqlDbType.NVarChar, 32).Value = invoiceId;
                    using (var rd = cmd.ExecuteReader())
                        while (rd.Read()) existing.Add(rd.GetString(0), rd.GetString(1));
                }

                var retainedIds = new HashSet<string>(StringComparer.Ordinal);
                foreach (DraftRow row in rows)
                {
                    if (!String.IsNullOrWhiteSpace(row.id) && !row.id.StartsWith("tmp-", StringComparison.Ordinal))
                    {
                        if (!existing.ContainsKey(row.id) || existing[row.id] != row.poId || !retainedIds.Add(row.id))
                        {
                            tx.Rollback();
                            Error(context, 400, "invalid_row_id", "Dòng phân bổ không tồn tại trong Invoice hoặc bị trùng.");
                            return;
                        }
                    }
                }

                foreach (string oldId in existing.Keys)
                {
                    if (retainedIds.Contains(oldId)) continue;
                    using (var cmd = new SqlCommand(
                        "DELETE FROM dbo.c_packinginvoice_phanbo WHERE c_packinginvoice_phanbo_id=@id AND c_packinginvoice_id=@invoice", connection, tx))
                    {
                        cmd.Parameters.Add("@id", SqlDbType.NVarChar, 32).Value = oldId;
                        cmd.Parameters.Add("@invoice", SqlDbType.NVarChar, 32).Value = invoiceId;
                        cmd.ExecuteNonQuery();
                    }
                }

                foreach (DraftRow row in rows)
                {
                    bool update = !String.IsNullOrWhiteSpace(row.id) && retainedIds.Contains(row.id);
                    using (var cmd = new SqlCommand(update
                        ? @"UPDATE dbo.c_packinginvoice_phanbo
                            SET sotienphanbo=@amount, ngaycapnhat=GETDATE(), nguoicapnhat=@user
                            WHERE c_packinginvoice_phanbo_id=@id AND c_packinginvoice_id=@invoice"
                        : @"INSERT INTO dbo.c_packinginvoice_phanbo
                            (c_packinginvoice_phanbo_id,c_packinginvoice_id,c_donhang_id,sotienphanbo,nguoitao)
                            VALUES (@id,@invoice,@poId,@amount,@user)", connection, tx))
                    {
                        cmd.Parameters.Add("@id", SqlDbType.NVarChar, 32).Value = update ? row.id : Guid.NewGuid().ToString("N");
                        cmd.Parameters.Add("@invoice", SqlDbType.NVarChar, 32).Value = invoiceId;
                        cmd.Parameters.Add("@poId", SqlDbType.NVarChar, 32).Value = row.poId;
                        var amount = cmd.Parameters.Add("@amount", SqlDbType.Decimal);
                        amount.Precision = 18; amount.Scale = 2; amount.Value = row.amount;
                        cmd.Parameters.Add("@user", SqlDbType.NVarChar, 32).Value = user.Length > 32 ? user.Substring(0, 32) : user;
                        cmd.ExecuteNonQuery();
                    }
                }

                // Do NOT overwrite c_packinginvoice.tiendatcoc or tiendatcocPO:
                // both already contain values for other Invoice flows.
                tx.Commit();
                context.Response.Write(JsonConvert.SerializeObject(new { ok = true, message = "Đã lưu bản nháp phân bổ.", savedRows = rows.Count }));
            }
            catch
            {
                try { tx.Rollback(); } catch (InvalidOperationException) {}
                throw;
            }
        }
    }

    private static string ComputeVersion(SqlConnection connection, SqlTransaction tx, string invoiceId)
    {
        var content = new StringBuilder();
        using (var cmd = new SqlCommand(@"
            SELECT c_packinginvoice_phanbo_id, c_donhang_id, sotienphanbo
            FROM dbo.c_packinginvoice_phanbo
            WHERE c_packinginvoice_id=@invoice
            ORDER BY c_packinginvoice_phanbo_id", connection, tx))
        {
            cmd.Parameters.Add("@invoice", SqlDbType.NVarChar, 32).Value = invoiceId;
            using (var rd = cmd.ExecuteReader())
                while (rd.Read())
                {
                    content.Append(rd.GetString(0)).Append('|')
                        .Append(rd.GetString(1)).Append('|')
                        .Append(rd.GetDecimal(2).ToString("F2", CultureInfo.InvariantCulture)).Append('\n');
                }
        }
        using (var hash = SHA256.Create())
            return BitConverter.ToString(hash.ComputeHash(Encoding.UTF8.GetBytes(content.ToString()))).Replace("-", "");
    }

    private static void Error(HttpContext context, int status, string code, string message)
    {
        context.Response.StatusCode = status;
        context.Response.Write(JsonConvert.SerializeObject(new { ok = false, code = code, message = message }));
    }

    public bool IsReusable { get { return false; } }
}
