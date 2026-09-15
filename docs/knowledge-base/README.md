# AncoTrading Knowledge Base

This directory is the long-term project memory for humans and AI agents working on AncoTrading.

It is intentionally split by concern instead of growing into one giant document.

## Reading order

For every task:

1. Read `/AGENTS.md`.
2. Read this file.
3. Read the relevant topic documents below.
4. Inspect the current implementation and DB model involved in the task.
5. After the task, update the knowledge base if durable knowledge was learned.

## Documents

### `ARCHITECTURE.md`

Where things live, what each major area is responsible for, and how requests/data typically flow through the legacy application.

### `CONVENTIONS.md`

Rules for making safe changes in this codebase: how to navigate it, what generated files to avoid editing directly, how to preserve existing patterns, and how to document newly discovered knowledge.

### `BUSINESS_LOGIC.md`

Durable business rules. This should become the most valuable document over time.

Each important rule should preferably contain:

- **Status:** `Confirmed` or `Inferred`.
- What the rule means in business terms.
- Important invariants/exceptions.
- **Where implemented:** `path -> class/function/handler/trigger`, when known.
- Related tables/entities/modules when known.

### `DECISIONS.md`

Decisions that future agents should not repeatedly reconsider without new evidence. Each decision records context, decision, reason and consequence.

## Evidence levels

### Confirmed

Use when the project owner explicitly confirms a business rule/requirement, or when a rule has otherwise been deliberately established as authoritative.

### Inferred

Use when an AI derives a likely rule from code, schema, naming or behavior but it has not yet been confirmed by the project owner.

Never silently promote `Inferred` knowledge to `Confirmed`.

## Source of truth

The knowledge base explains the system; it does not replace it.

For implementation details, the current source code and database are the source of truth. Documentation should capture *why*, *relationships*, *invariants*, *business meaning*, and *where to look*, rather than duplicate entire implementations.

If documentation conflicts with current code/DB, investigate before changing behavior. Once the intended behavior is established, fix the stale knowledge entry.

## Update policy

Update this knowledge base when a task reveals information that is likely to matter again, including:

- a business rule or exception;
- synchronization between modules/tables;
- a non-obvious calculation;
- a status transition rule;
- an architectural boundary;
- an important reusable convention;
- a compatibility constraint;
- a deliberate technical decision.

Do not add routine implementation trivia that is obvious from opening a single file.
