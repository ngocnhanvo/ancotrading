# Business Logic

This file is the durable business-rule memory for AncoTrading.

Only record rules that are useful beyond a single implementation session. Keep exact formulas in code/DB when possible; document their business meaning, version boundary and implementation location here.

---

## Orders — order-line derived fields and formula versioning

### Formula selection by order creation date

**Status: Confirmed**

A previously established AncoTrading requirement is that some order-line calculation logic has an old and a new formula. The formula version is selected using the **order's creation date (`ngaytao`)**:

- orders created before the agreed migration/cutover date use the old formula;
- orders created on/after that date use the new formula.

This preserves historical orders while allowing the new calculation for newer orders.

**Important:** the exact cutover date and current formula expressions must be verified from the current SQL trigger/code before modifying this behavior. Do not guess the date from this document.

**Where implemented:**

- SQL Server trigger `[dbo].[updateCBMCBFPO]` on `[dbo].[c_dongdonhang]` — known implementation point from prior project work; verify against the current production/database script before editing.

**Related:**

- order header (`c_donhang`)
- order lines (`c_dongdonhang`)
- order creation date (`ngaytao`)
- derived order-line fields handled by the trigger

**Notes:**

The trigger has historically updated multiple derived order-line values. When changing one formula, inspect the complete trigger and both old/new branches so historical compatibility is not accidentally removed.

---

## Orders — fee allocation

### Allocation is only valid for editable draft orders

**Status: Confirmed from prior implementation work**

Order-fee allocation (`phanBoPhi`) is guarded by order state and required data:

- the order must be in the system's draft/`SOANTHAO` state before allocation is allowed;
- the order must contain order lines;
- active order fees must exist before fee allocation can proceed.

**Where implemented:**

- server-side order controller/action containing `phanBoPhi(HttpContext context)` — exact current repository path must be located before the next modification.

**Related:**

- `c_donhang`
- `c_dongdonhang`
- `c_phidonhang`
- `Helper.SOANTHAO`

**Notes:**

There was prior code where the second validation accidentally checked the order-line count again when the intent was to validate fees. When revisiting this flow, verify that the active-fee collection itself is checked.

---

## Cross-module synchronization rule template

When a future task reveals two-way or automatic synchronization, document both directions explicitly rather than writing only "A syncs with B".

Example structure:

```text
## <Domain A> / <Domain B>

### A -> B
Status: Confirmed
Rule: ...
Where implemented: ...

### B -> A
Status: Confirmed | Inferred
Rule: ...
Where implemented: ...

### Invariants / loop prevention
- ...
```

This is especially important for accounting, payment, order, inventory and status workflows where changing one record may cause another layer or DB trigger to write back.

---

## Pending knowledge to establish

These are not business rules. They are reminders of areas that should be documented when encountered naturally in future tasks:

- order lifecycle/status transitions;
- purchase/order pricing and packing calculations;
- inventory synchronization;
- payment/accounting flows;
- import validation rules;
- permissions/approval rules;
- report calculations that differ from transactional calculations.

Do not reverse-engineer all of these merely to fill documentation. Add them when actual work provides reliable evidence and context.
