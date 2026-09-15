using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;

/// <summary>
/// Generates a metadata-only JSON map of the SQL Server database for developers/AI agents.
/// No business/table row data is selected or written.
/// </summary>
public static class DatabaseSchemaMapGenerator
{
    public const string RelativeOutputPath = "docs/database/schema-map.json";

    public static string Generate(HttpContext context)
    {
        var info = new InfomationDB();
        if (string.IsNullOrWhiteSpace(info.ConnectionString))
            throw new InvalidOperationException("Database connection string was not found.");

        string json;
        using (var cn = new SqlConnection(info.ConnectionString))
        {
            cn.Open();
            json = BuildJson(cn, info.InitialCatalog);
        }

        var root = AppDomain.CurrentDomain.BaseDirectory;
        var outputPath = Path.Combine(root, RelativeOutputPath.Replace('/', Path.DirectorySeparatorChar));
        var directory = Path.GetDirectoryName(outputPath);
        if (!Directory.Exists(directory)) Directory.CreateDirectory(directory);

        // UTF-8 without BOM keeps Git diffs stable across repeated generations.
        File.WriteAllText(outputPath, json, new UTF8Encoding(false));
        return outputPath;
    }

    private static string BuildJson(SqlConnection cn, string databaseName)
    {
        var tables = Query(cn, @"
SELECT s.name AS schema_name, t.name AS table_name
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name;");

        var columns = Query(cn, @"
SELECT s.name AS schema_name, t.name AS table_name, c.column_id, c.name AS column_name,
       ty.name AS data_type, c.max_length, c.precision, c.scale, c.is_nullable,
       c.is_identity, c.is_computed, dc.definition AS default_definition,
       cc.definition AS computed_definition,
       CASE WHEN pk.column_id IS NULL THEN 0 ELSE 1 END AS is_primary_key,
       ISNULL(pk.key_ordinal, 0) AS primary_key_ordinal
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.columns c ON c.object_id = t.object_id
INNER JOIN sys.types ty ON ty.user_type_id = c.user_type_id
LEFT JOIN sys.default_constraints dc ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
LEFT JOIN sys.computed_columns cc ON cc.object_id = c.object_id AND cc.column_id = c.column_id
LEFT JOIN (
    SELECT ic.object_id, ic.column_id, ic.key_ordinal
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    WHERE i.is_primary_key = 1
) pk ON pk.object_id = c.object_id AND pk.column_id = c.column_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, c.column_id;");

        var foreignKeys = Query(cn, @"
SELECT s.name AS schema_name, t.name AS table_name, fk.name AS foreign_key_name,
       fkc.constraint_column_id AS ordinal,
       pc.name AS column_name, rs.name AS referenced_schema, rt.name AS referenced_table,
       rc.name AS referenced_column, fk.delete_referential_action_desc AS on_delete,
       fk.update_referential_action_desc AS on_update, fk.is_disabled
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables t ON t.object_id = fk.parent_object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.columns pc ON pc.object_id = t.object_id AND pc.column_id = fkc.parent_column_id
INNER JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
INNER JOIN sys.schemas rs ON rs.schema_id = rt.schema_id
INNER JOIN sys.columns rc ON rc.object_id = rt.object_id AND rc.column_id = fkc.referenced_column_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, fk.name, fkc.constraint_column_id;");

        var indexes = Query(cn, @"
SELECT s.name AS schema_name, t.name AS table_name, i.name AS index_name,
       i.is_unique, i.is_primary_key, i.type_desc,
       ic.key_ordinal, ic.is_included_column, c.name AS column_name, ic.is_descending_key
FROM sys.indexes i
INNER JOIN sys.tables t ON t.object_id = i.object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE t.is_ms_shipped = 0 AND i.name IS NOT NULL
ORDER BY s.name, t.name, i.name, ic.is_included_column, ic.key_ordinal, ic.index_column_id;");

        var triggers = Query(cn, @"
SELECT s.name AS schema_name, t.name AS table_name, tr.name AS trigger_name,
       tr.is_disabled, tr.is_instead_of_trigger,
       STUFF((SELECT ',' + te.type_desc
              FROM sys.trigger_events te
              WHERE te.object_id = tr.object_id
              ORDER BY te.type_desc
              FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '') AS events
FROM sys.triggers tr
INNER JOIN sys.tables t ON t.object_id = tr.parent_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE tr.is_ms_shipped = 0
ORDER BY s.name, t.name, tr.name;");

        var sb = new StringBuilder(1024 * 64);
        sb.AppendLine("{");
        Prop(sb, 1, "formatVersion", "1", false, true);
        Prop(sb, 1, "database", databaseName, true, true);
        sb.AppendLine(Indent(1) + "\"tables\": [");

        for (int ti = 0; ti < tables.Rows.Count; ti++)
        {
            var table = tables.Rows[ti];
            string schema = S(table["schema_name"]), tableName = S(table["table_name"]);
            sb.AppendLine(Indent(2) + "{");
            Prop(sb, 3, "schema", schema, true, true);
            Prop(sb, 3, "name", tableName, true, true);

            sb.AppendLine(Indent(3) + "\"columns\": [");
            var tableColumns = columns.Select(Filter(schema, tableName), "column_id ASC");
            for (int i = 0; i < tableColumns.Length; i++)
            {
                var r = tableColumns[i];
                sb.AppendLine(Indent(4) + "{");
                Prop(sb, 5, "name", S(r["column_name"]), true, true);
                Prop(sb, 5, "type", S(r["data_type"]), true, true);
                Prop(sb, 5, "maxLength", N(r["max_length"]), false, true);
                Prop(sb, 5, "precision", N(r["precision"]), false, true);
                Prop(sb, 5, "scale", N(r["scale"]), false, true);
                Prop(sb, 5, "nullable", B(r["is_nullable"]), false, true);
                Prop(sb, 5, "identity", B(r["is_identity"]), false, true);
                Prop(sb, 5, "computed", B(r["is_computed"]), false, true);
                PropNullable(sb, 5, "default", r["default_definition"], true);
                PropNullable(sb, 5, "computedDefinition", r["computed_definition"], true);
                Prop(sb, 5, "primaryKey", B(r["is_primary_key"]), false, true);
                Prop(sb, 5, "primaryKeyOrdinal", N(r["primary_key_ordinal"]), false, false);
                sb.Append(Indent(4) + "}");
                sb.AppendLine(i < tableColumns.Length - 1 ? "," : "");
            }
            sb.AppendLine(Indent(3) + "],");

            WriteForeignKeys(sb, foreignKeys, schema, tableName);
            sb.AppendLine(",");
            WriteIndexes(sb, indexes, schema, tableName);
            sb.AppendLine(",");
            WriteTriggers(sb, triggers, schema, tableName);
            sb.AppendLine();
            sb.Append(Indent(2) + "}");
            sb.AppendLine(ti < tables.Rows.Count - 1 ? "," : "");
        }

        sb.AppendLine(Indent(1) + "]");
        sb.AppendLine("}");
        return sb.ToString();
    }

    private static void WriteForeignKeys(StringBuilder sb, DataTable dt, string schema, string table)
    {
        sb.AppendLine(Indent(3) + "\"foreignKeys\": [");
        var rows = dt.Select(Filter(schema, table), "foreign_key_name ASC, ordinal ASC");
        string current = null;
        bool first = true;
        for (int i = 0; i < rows.Length;)
        {
            string name = S(rows[i]["foreign_key_name"]);
            int j = i;
            while (j < rows.Length && S(rows[j]["foreign_key_name"]) == name) j++;
            if (!first) sb.AppendLine(",");
            first = false;
            sb.AppendLine(Indent(4) + "{");
            Prop(sb, 5, "name", name, true, true);
            WriteStringArray(sb, 5, "columns", rows, i, j, "column_name", true);
            Prop(sb, 5, "referencedSchema", S(rows[i]["referenced_schema"]), true, true);
            Prop(sb, 5, "referencedTable", S(rows[i]["referenced_table"]), true, true);
            WriteStringArray(sb, 5, "referencedColumns", rows, i, j, "referenced_column", true);
            Prop(sb, 5, "onDelete", S(rows[i]["on_delete"]), true, true);
            Prop(sb, 5, "onUpdate", S(rows[i]["on_update"]), true, true);
            Prop(sb, 5, "disabled", B(rows[i]["is_disabled"]), false, false);
            sb.Append(Indent(4) + "}");
            i = j;
        }
        if (rows.Length > 0) sb.AppendLine();
        sb.Append(Indent(3) + "]");
    }

    private static void WriteIndexes(StringBuilder sb, DataTable dt, string schema, string table)
    {
        sb.AppendLine(Indent(3) + "\"indexes\": [");
        var rows = dt.Select(Filter(schema, table), "index_name ASC, is_included_column ASC, key_ordinal ASC");
        bool first = true;
        for (int i = 0; i < rows.Length;)
        {
            string name = S(rows[i]["index_name"]);
            int j = i;
            while (j < rows.Length && S(rows[j]["index_name"]) == name) j++;
            if (!first) sb.AppendLine(",");
            first = false;
            sb.AppendLine(Indent(4) + "{");
            Prop(sb, 5, "name", name, true, true);
            Prop(sb, 5, "unique", B(rows[i]["is_unique"]), false, true);
            Prop(sb, 5, "primaryKey", B(rows[i]["is_primary_key"]), false, true);
            Prop(sb, 5, "type", S(rows[i]["type_desc"]), true, true);
            WriteIndexColumns(sb, 5, "columns", rows, i, j, false, true);
            WriteIndexColumns(sb, 5, "includedColumns", rows, i, j, true, false);
            sb.Append(Indent(4) + "}");
            i = j;
        }
        if (rows.Length > 0) sb.AppendLine();
        sb.Append(Indent(3) + "]");
    }

    private static void WriteTriggers(StringBuilder sb, DataTable dt, string schema, string table)
    {
        sb.AppendLine(Indent(3) + "\"triggers\": [");
        var rows = dt.Select(Filter(schema, table), "trigger_name ASC");
        for (int i = 0; i < rows.Length; i++)
        {
            var r = rows[i];
            sb.AppendLine(Indent(4) + "{");
            Prop(sb, 5, "name", S(r["trigger_name"]), true, true);
            Prop(sb, 5, "disabled", B(r["is_disabled"]), false, true);
            Prop(sb, 5, "insteadOf", B(r["is_instead_of_trigger"]), false, true);
            var events = S(r["events"]).Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            sb.Append(Indent(5) + "\"events\": [");
            for (int e = 0; e < events.Length; e++)
            {
                if (e > 0) sb.Append(", ");
                sb.Append("\"" + J(events[e]) + "\"");
            }
            sb.AppendLine("]");
            sb.Append(Indent(4) + "}");
            sb.AppendLine(i < rows.Length - 1 ? "," : "");
        }
        sb.Append(Indent(3) + "]");
    }

    private static void WriteStringArray(StringBuilder sb, int level, string name, DataRow[] rows, int start, int end, string field, bool comma)
    {
        sb.Append(Indent(level) + "\"" + name + "\": [");
        for (int i = start; i < end; i++)
        {
            if (i > start) sb.Append(", ");
            sb.Append("\"" + J(S(rows[i][field])) + "\"");
        }
        sb.AppendLine("]" + (comma ? "," : ""));
    }

    private static void WriteIndexColumns(StringBuilder sb, int level, string name, DataRow[] rows, int start, int end, bool included, bool comma)
    {
        sb.Append(Indent(level) + "\"" + name + "\": [");
        bool first = true;
        for (int i = start; i < end; i++)
        {
            if (Convert.ToBoolean(rows[i]["is_included_column"], CultureInfo.InvariantCulture) != included) continue;
            if (!first) sb.Append(", ");
            first = false;
            if (included)
                sb.Append("\"" + J(S(rows[i]["column_name"])) + "\"");
            else
                sb.Append("{\"name\": \"" + J(S(rows[i]["column_name"])) + "\", \"descending\": " + B(rows[i]["is_descending_key"]) + "}");
        }
        sb.AppendLine("]" + (comma ? "," : ""));
    }

    private static DataTable Query(SqlConnection cn, string sql)
    {
        using (var cmd = new SqlCommand(sql, cn))
        using (var da = new SqlDataAdapter(cmd))
        {
            cmd.CommandTimeout = 120;
            var dt = new DataTable();
            da.Fill(dt);
            return dt;
        }
    }

    private static string Filter(string schema, string table)
    {
        return "schema_name = '" + schema.Replace("'", "''") + "' AND table_name = '" + table.Replace("'", "''") + "'";
    }

    private static void Prop(StringBuilder sb, int level, string name, string value, bool quote, bool comma)
    {
        sb.Append(Indent(level) + "\"" + name + "\": ");
        sb.Append(quote ? "\"" + J(value) + "\"" : value);
        sb.AppendLine(comma ? "," : "");
    }

    private static void PropNullable(StringBuilder sb, int level, string name, object value, bool comma)
    {
        if (value == null || value == DBNull.Value)
            Prop(sb, level, name, "null", false, comma);
        else
            Prop(sb, level, name, Convert.ToString(value, CultureInfo.InvariantCulture), true, comma);
    }

    private static string S(object value) { return value == null || value == DBNull.Value ? "" : Convert.ToString(value, CultureInfo.InvariantCulture); }
    private static string N(object value) { return value == null || value == DBNull.Value ? "0" : Convert.ToString(value, CultureInfo.InvariantCulture); }
    private static string B(object value) { return Convert.ToBoolean(value, CultureInfo.InvariantCulture) ? "true" : "false"; }
    private static string Indent(int level) { return new string(' ', level * 2); }

    private static string J(string value)
    {
        if (value == null) return "";
        var sb = new StringBuilder(value.Length + 8);
        foreach (char c in value)
        {
            switch (c)
            {
                case '\\': sb.Append("\\\\"); break;
                case '"': sb.Append("\\\""); break;
                case '\b': sb.Append("\\b"); break;
                case '\f': sb.Append("\\f"); break;
                case '\n': sb.Append("\\n"); break;
                case '\r': sb.Append("\\r"); break;
                case '\t': sb.Append("\\t"); break;
                default:
                    if (c < 32) sb.Append("\\u" + ((int)c).ToString("x4"));
                    else sb.Append(c);
                    break;
            }
        }
        return sb.ToString();
    }
}
