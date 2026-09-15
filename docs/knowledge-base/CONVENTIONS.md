# Conventions

These conventions are intended to make changes safer and to keep long-term project knowledge useful.

## 1. Follow the existing architecture

**Status: Confirmed project policy**

AncoTrading is an established production Web Forms application. New work should normally fit the existing module patterns.

Do not introduce MVC, repository/service layers, a different ORM, a SPA framework, or another architectural style into one isolated module unless the project owner explicitly chooses that migration.

Improvement is welcome, but compatibility and consistency with surrounding production code come first.

## 2. Read before editing

Before modifying a module:

1. Find its UI/ASPX/ASCX and client-side behavior.
2. Identify the actual `.ashx` endpoint/action involved.
3. Identify shared `App_Code` dependencies.
4. Identify LINQ-to-SQL entities/tables involved.
5. Search for other readers/writers of important fields.
6. Check database triggers/routines when automatic DB behavior may exist.
7. Read relevant knowledge-base entries.

Never implement a business change solely from a field or function name.

## 3. LINQ-to-SQL generated code

`App_Code/LinQ/LinqDB.designer.cs` is generated code associated with `LinqDB.dbml`.

Do not casually hand-edit the generated designer file. Determine whether the model/database mapping should instead be changed through the DBML/database workflow.

If an emergency/manual generated-file change is ever intentionally made, document the reason and regeneration risk in `DECISIONS.md`.

## 4. Preserve existing behavior outside task scope

Legacy modules often have hidden consumers. Prefer the smallest coherent change that satisfies the requirement.

When changing shared helpers, API handlers, common calculations or DB-side behavior, search for all important call sites/consumers first.

## 5. Business rules need two kinds of evidence

Use these labels in knowledge documentation:

### `Confirmed`

The project owner explicitly stated/approved the rule, or it has been deliberately established as authoritative.

### `Inferred`

The rule appears to follow from code/schema/current behavior but has not been confirmed as intended business policy.

Never rewrite an inferred observation as a confirmed requirement just because it seems obvious.

## 6. Record where rules live

For durable business rules, use this shape when practical:

```text
Status: Confirmed | Inferred

Rule:
<business meaning>

Where implemented:
- path/to/file -> class/function/action
- database trigger/procedure/table when applicable

Related:
- tables/entities/modules

Notes:
- exceptions, reverse synchronization, compatibility constraints
```

The goal is to let the next agent jump directly to the relevant implementation without copying the implementation into documentation.

## 7. Knowledge base is explanatory, not generated documentation

Do not dump source code, entity definitions or exhaustive file lists into the knowledge base.

Document information that is expensive to rediscover:

- why behavior exists;
- non-obvious relationships;
- business invariants;
- synchronization direction(s);
- exceptions;
- historical compatibility requirements;
- implementation navigation points.

## 8. Update knowledge after meaningful tasks

A task should update the knowledge base when it discovers or establishes durable knowledge.

Examples:

- "Changing A automatically updates B."
- "Status X forbids deleting Y."
- "Orders created before date D use formula V1; newer orders use V2."
- "This value is calculated by a SQL trigger, not the UI."
- "This handler is shared by three modules."

Routine CSS tweaks or obvious one-file fixes generally do not need a knowledge entry unless they expose a reusable convention.

## 9. Prefer business language plus implementation pointers

Write rules in language that explains the domain first, then point to implementation.

Bad long-term documentation:

```text
field abc = xyz ? 1 : 0
```

Better:

```text
Confirmed — Orders created from the migration date onward use the new contract-price calculation.
Where implemented: <trigger/function when established>
```

Then the current code remains responsible for exact syntax/formula details.

## 10. Do not hide uncertainty

If only part of a flow has been inspected, say so. Add `Inferred`, `Needs verification`, or a focused TODO rather than inventing missing behavior.
