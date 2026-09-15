# Architecture

## Status of this document

The entries below distinguish facts observed directly in the repository from higher-level interpretations.

## System overview

**Status: Confirmed from repository structure**

AncoTrading is a legacy ASP.NET Web Forms / C# application. It uses ASPX/ASCX UI files, `.ashx` HTTP handlers, shared code under `App_Code`, and a LINQ-to-SQL data model under `App_Code/LinQ`.

Production/default branch: `master`.

## Major areas

### `App_Code/`

**Status: Confirmed from repository**

Shared server-side C# code compiled by ASP.NET. This area contains multiple responsibilities accumulated over the lifetime of the application, including shared helpers and domain utilities.

Observed examples include:

- `AvariablePrj.cs`
- `Extension.cs`
- `ConvertMoney.cs`
- Excel formatting/conversion helpers
- mail helpers (`GoogleMail.cs`, `M365Mail.cs`)
- `Catalogue/`
- `Import/`
- `ExportExcel/`
- `LinQ/`

Do not assume every class here is a generic helper; inspect the actual dependency before changing it because `App_Code` can contain domain behavior used across many modules.

### `App_Code/LinQ/`

**Status: Confirmed from repository**

LINQ-to-SQL data-access model.

Important files:

- `LinqDB.dbml` — database mapping/model definition.
- `LinqDB.designer.cs` — large generated LINQ-to-SQL source file.
- `LinqDB.dbml.layout` — designer layout metadata.
- `InfomationDB.cs` — additional DB-related code; inspect before relying on its purpose.
- `ADmin_UpdateLinq.cs` — additional LINQ-related code; inspect before relying on its purpose.

### `Controllers/`

**Status: Confirmed from repository**

Contains many ASP.NET `.ashx` handlers. These handlers form an important server-side request/action layer rather than an ASP.NET MVC controller layer.

Observed examples:

- `API_Android.ashx`
- `API_Data.ashx`
- `API_System.ashx`
- `API_Website.ashx`
- `BaoCaoController.ashx`
- module-specific handlers such as `BienTauController.ashx`, `BoCaiController.ashx`, `BoPhanController.ashx`, `CangXuatHangController.ashx`, etc.

When investigating a UI action, search for the URL/handler called by the JavaScript or form, then trace the selected action/method inside the relevant `.ashx` handler into shared/data-access code.

### `ImportControllers/`

**Status: Confirmed from repository structure**

Dedicated import-related request handlers/workflows. Inspect the corresponding classes in `App_Code/Import/` when working on import behavior because validation/transformation may be split between endpoint and reusable import code.

### `ExportControllers/`

**Status: Confirmed from repository structure**

Dedicated export-related handlers/workflows. Export behavior may also depend on helpers under `App_Code/ExportExcel/` and other formatting utilities.

### ASPX / ASCX UI

**Status: Confirmed from repository**

The root includes Web Forms pages and controls such as `Default.aspx`, `Default-Security.aspx`, `Invoice.ascx`, etc. Additional UI is distributed through the repository.

Do not assume modern component boundaries. A business workflow may span markup, inline/client JavaScript, an `.ashx` handler, LINQ-to-SQL entities and database-side logic.

## Typical request/data flow

**Status: Inferred from architecture; verify per module**

A common flow is likely:

```text
ASPX/ASCX UI
    -> JavaScript / form / AJAX request
    -> Controllers/*.ashx (or import/export handler)
    -> App_Code shared/domain logic
    -> LINQ-to-SQL (`App_Code/LinQ/LinqDB.dbml`)
    -> SQL Server database
```

Some modules can bypass one or more layers. Always trace the actual task-specific flow.

## Database-side behavior

**Status: Confirmed as a project concern; implementation must be checked in the live/current DB scripts**

AncoTrading has business behavior that can also live in SQL Server triggers or database-side logic. A C# change can therefore have effects not obvious from the handler alone.

When a task involves calculated fields, synchronized records, order lines, prices, fees, statuses, inventory/accounting values or automatic updates, check whether a DB trigger/stored routine participates before changing the C# side.

## Architectural caution

This application is mature production software with cross-module dependencies. A local-looking field can be read or rewritten elsewhere.

For non-trivial business changes, trace at least:

```text
UI input/display
-> client request
-> handler/action
-> shared/domain code
-> LINQ entity/table
-> DB trigger/routine if applicable
-> reverse/update paths from related modules
```

Record newly discovered cross-module relationships in `BUSINESS_LOGIC.md`.
