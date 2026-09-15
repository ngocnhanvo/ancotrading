# AncoTrading — AI Agent Entry Point

This file is the mandatory entry point for AI agents working on this repository.

## Project identity

- Repository: `ngocnhanvo/ancotrading`
- Production/default branch: `master`
- System: legacy ASP.NET Web Forms / C# business application.
- The repository contains long-lived production code and many business rules. Preserve existing conventions unless a change is explicitly justified.

## Mandatory reading before changing code

Read `docs/knowledge-base/README.md` first, then read the knowledge-base documents relevant to the task.

Do not treat documentation as a replacement for inspecting the current code and database model. Code + DB remain the source of truth for implementation details.

## High-level code map

The current repository is organized around areas such as:

- `App_Code/` — shared C# code, helpers, imports/exports, mail, catalogue logic and data-access related code.
- `App_Code/LinQ/` — LINQ-to-SQL model (`LinqDB.dbml`) and generated designer code.
- `Controllers/` — HTTP handlers (`.ashx`) implementing APIs and module/business actions.
- `ImportControllers/` — import endpoints/workflows.
- `ExportControllers/` — export endpoints/workflows.
- ASPX/ASCX files and JavaScript/CSS — UI and client-side behavior.

This is not assumed to use the DalatHoa `Controller/JQGrid/JQGridModify` or Entity Framework layout. Always follow the actual AncoTrading repository structure.

## Rules for AI agents

1. Inspect the relevant current code before proposing or implementing a change.
2. Trace business flows end-to-end when data is synchronized across modules, tables, handlers or triggers. Do not infer behavior from field names alone.
3. Never edit generated `App_Code/LinQ/LinqDB.designer.cs` casually. Changes to the database model should be understood through the DBML/database workflow first.
4. Preserve the existing architecture by default. Do not introduce MVC, repository/service layers, a new ORM, or a new framework into an isolated module merely to modernize it.
5. Keep `Confirmed` and `Inferred` knowledge separate. A rule confirmed by the project owner is stronger than an interpretation derived only from code.
6. For every durable business rule, record `Where implemented:` with the relevant `file -> class/function/handler` when known.
7. Do not copy large blocks of source code into the knowledge base. Explain intent, relationships, invariants and navigation points so documentation does not become stale unnecessarily.
8. When a task teaches us a reusable architectural fact, convention, business rule or design decision, update `docs/knowledge-base/` as part of that task.
9. If code and knowledge-base documentation disagree, investigate the discrepancy. Prefer current code/DB for implementation behavior and update stale documentation when the correct behavior is established.

## Knowledge-base maintenance

Use these files:

- `docs/knowledge-base/ARCHITECTURE.md` — system map and component relationships.
- `docs/knowledge-base/CONVENTIONS.md` — coding/navigation conventions and safe-change rules.
- `docs/knowledge-base/BUSINESS_LOGIC.md` — durable business rules and cross-module behavior.
- `docs/knowledge-base/DECISIONS.md` — architectural/technical decisions with reasons and consequences.

After a meaningful task, ask: **Did this task reveal knowledge another AI would otherwise have to reverse-engineer?** If yes, update the appropriate knowledge-base file before considering the task complete.
