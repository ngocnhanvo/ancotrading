# Decisions

This file records durable technical/architectural decisions so future agents understand not only *what* the project does, but *why* certain approaches should be preserved.

Use this format for future entries:

```text
### YYYY-MM-DD — Decision title

Status: Active | Superseded

Context:
...

Decision:
...

Reason:
...

Consequence:
...
```

---

### 2026-09-15 — Use a layered AI knowledge base

**Status: Active**

**Context:**

AncoTrading is a large, mature legacy application. A single growing `KNOWLEDGE_BASE.md` would eventually become difficult to navigate and maintain, while `AGENTS.md` alone is not suitable for detailed business knowledge.

**Decision:**

Use:

```text
AGENTS.md

docs/knowledge-base/
  README.md
  ARCHITECTURE.md
  CONVENTIONS.md
  BUSINESS_LOGIC.md
  DECISIONS.md
```

`AGENTS.md` is the mandatory entry point. Detailed knowledge is split by concern.

**Reason:**

AI agents need a small, obvious bootstrap document plus focused long-term memory that can grow without becoming one monolithic file.

**Consequence:**

Future meaningful development tasks should update the relevant knowledge-base document when they establish durable knowledge another agent would otherwise need to reverse-engineer.

---

### 2026-09-15 — Separate Confirmed knowledge from Inferred knowledge

**Status: Active**

**Context:**

Legacy code often expresses historical implementation behavior that may not fully represent intended current business policy. AI agents can also infer plausible rules that have never been confirmed by the project owner.

**Decision:**

Knowledge entries distinguish `Confirmed` from `Inferred` whenever the distinction matters.

**Reason:**

Prevent an AI interpretation from silently becoming an authoritative business requirement.

**Consequence:**

Future agents must preserve the evidence level. `Inferred` becomes `Confirmed` only after reliable confirmation, not merely repetition across sessions.

---

### 2026-09-15 — Code and database remain implementation source of truth

**Status: Active**

**Context:**

Knowledge documentation can become stale, especially in a production system with C#, generated LINQ mappings and SQL-side behavior.

**Decision:**

The knowledge base explains business meaning, relationships, invariants and navigation points. Current source code and database remain the source of truth for exact implementation behavior.

**Reason:**

Avoid maintaining a second copy of formulas/implementation that can drift from production.

**Consequence:**

Before editing, agents must inspect current code/DB. If documentation conflicts with implementation, investigate intended behavior and then update stale documentation.

---

### 2026-09-15 — Preserve the existing Web Forms architecture by default

**Status: Active**

**Context:**

AncoTrading is existing production software built around ASP.NET Web Forms, `.ashx` handlers, `App_Code` and LINQ-to-SQL. Modules can have non-obvious cross-dependencies.

**Decision:**

Continue implementing features and fixes within the existing architecture unless a deliberate migration/refactor is separately approved.

**Reason:**

Introducing an isolated modern architecture into one module increases inconsistency, integration cost and maintenance risk without migrating the system as a whole.

**Consequence:**

Do not independently introduce MVC, a repository/service architecture, a replacement ORM or another framework merely as local cleanup. Refactoring within existing conventions is allowed when it improves the requested work without breaking compatibility.
