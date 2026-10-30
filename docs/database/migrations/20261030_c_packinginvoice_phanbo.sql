-- AncoTrading: PO -> Packing Invoice deposit allocation ledger.
-- Run ONCE on the intended database using the existing SQL administrator workflow.
-- No FOREIGN KEY constraints are created (project convention).
-- IMPORTANT: read-only UI is delivered first. Activation/save will be implemented separately.
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.c_packinginvoice_phanbo', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.c_packinginvoice_phanbo
    (
        c_packinginvoice_phanbo_id NVARCHAR(32) NOT NULL,
        c_packinginvoice_id        NVARCHAR(32) NOT NULL,  -- logical key only, NO SQL FK
        c_donhang_id               NVARCHAR(32) NOT NULL,  -- logical key only, NO SQL FK
        sotienphanbo               DECIMAL(18, 2) NOT NULL,
        ngaytao                    DATETIME NOT NULL CONSTRAINT DF_c_packinginvoice_phanbo_ngaytao DEFAULT (GETDATE()),
        nguoitao                   NVARCHAR(32) NULL,
        ngaycapnhat                DATETIME NULL,
        nguoicapnhat               NVARCHAR(32) NULL,
        mota                       NVARCHAR(500) NULL,
        CONSTRAINT PK_c_packinginvoice_phanbo PRIMARY KEY CLUSTERED (c_packinginvoice_phanbo_id),
        CONSTRAINT CK_c_packinginvoice_phanbo_sotien CHECK (sotienphanbo >= 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.c_packinginvoice_phanbo', N'U') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1 FROM sys.indexes
       WHERE object_id = OBJECT_ID(N'dbo.c_packinginvoice_phanbo')
         AND name = N'IX_c_packinginvoice_phanbo_invoice_po'
   )
BEGIN
    CREATE NONCLUSTERED INDEX IX_c_packinginvoice_phanbo_invoice_po
    ON dbo.c_packinginvoice_phanbo (c_packinginvoice_id, c_donhang_id);
END;
GO

IF OBJECT_ID(N'dbo.c_packinginvoice_phanbo', N'U') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1 FROM sys.indexes
       WHERE object_id = OBJECT_ID(N'dbo.c_packinginvoice_phanbo')
         AND name = N'IX_c_packinginvoice_phanbo_po'
   )
BEGIN
    CREATE NONCLUSTERED INDEX IX_c_packinginvoice_phanbo_po
    ON dbo.c_packinginvoice_phanbo (c_donhang_id, c_packinginvoice_id)
    INCLUDE (sotienphanbo);
END;
GO

-- Verification: zero foreign keys by design.
SELECT t.name AS table_name, c.name AS column_name, ty.name AS data_type
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE t.object_id = OBJECT_ID(N'dbo.c_packinginvoice_phanbo')
ORDER BY c.column_id;

SELECT COUNT(*) AS actual_foreign_key_constraints
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID(N'dbo.c_packinginvoice_phanbo');
