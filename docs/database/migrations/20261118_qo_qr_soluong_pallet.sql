-- Q/O QR: preserve outer pack count separately from converted total pieces.
-- Run on the intended ANCO SQL Server database BEFORE deploying the updated backend.
-- This is deliberately NOT a backfill: historical Q/O QR lines get 0 pallets,
-- because their split between loose items and outer packs cannot be reconstructed.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID(N'dbo.c_chitietbaogiaqr', N'U') IS NULL
BEGIN
    THROW 51000, 'Required table dbo.c_chitietbaogiaqr does not exist.', 1;
END;

IF COL_LENGTH(N'dbo.c_chitietbaogiaqr', N'soluong_pallet') IS NULL
BEGIN
    ALTER TABLE dbo.c_chitietbaogiaqr
        ADD soluong_pallet NUMERIC(18,0) NULL
            CONSTRAINT DF_c_chitietbaogiaqr_soluong_pallet DEFAULT (0) WITH VALUES;
END;

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.c_chitietbaogiaqr')
      AND name = N'soluong_pallet'
      AND (system_type_id <> TYPE_ID(N'numeric') OR scale <> 0)
)
BEGIN
    THROW 51001, 'Existing soluong_pallet column type does not match NUMERIC(...,0).', 1;
END;

UPDATE dbo.c_chitietbaogiaqr
SET soluong_pallet = 0
WHERE soluong_pallet IS NULL;

COMMIT TRANSACTION;

-- Verification: existing historical rows should have pallet = 0.
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN soluong_pallet IS NULL THEN 1 ELSE 0 END) AS null_pallet_rows,
       SUM(CASE WHEN soluong_pallet < 0 THEN 1 ELSE 0 END) AS negative_pallet_rows
FROM dbo.c_chitietbaogiaqr;
