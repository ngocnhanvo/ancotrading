# Business Logic

This file is the durable business-rule memory for AncoTrading.

Only record rules that are useful beyond a single implementation session. Keep exact formulas in code/DB when possible; document their business meaning, version boundary and implementation location here.

---

## Nexxdecor — product code and image filename compatibility

### Nexxdecor variants use a two-letter third block

**Status: Confirmed**

Nexxdecor products imported into the shared Anco catalogue use the same 14-character / 4-block product-code shape:

```text
NN-NNNNN-AA-NN
```

For Nexxdecor, block 3 is exactly two alphabetic characters. Classification is based on the complete two-letter block shape; individual letters are not banned. For example, `TB` is a valid Nexxdecor block.

Examples:

- `36-02305-TC-01` is a valid Nexxdecor code/image basename.
- `42-01400-TW-16` is a valid Nexxdecor code/image basename.
- `42-05101-TB-16` is a valid Nexxdecor code/image basename.

Product image uploads must accept these Nexxdecor basenames in addition to the existing Anco filename formats. The upload rule must stay aligned with the Nexxdecor code classification used by the public product-detail flow so the same code is not accepted in one path and rejected in another.

Special `XX` rule:

- `NN-NNNNN-XX-NN` represents a Nexxdecor table/chair set MAHH.
- The product-detail response must leave Packing, Pallet size, Q'ty cont and Available sizes empty for `XX`.
- Colors remain available and selectable normally.
- `XX` remains the product-code block used when the selected color is added to the inquiry list; it is not a visible size option.

**Where implemented:**

- `Controllers/UserQRCodeController.ashx` -> `getInfo(HttpContext context)` — classifies Nexxdecor product variants.
- `Controllers/UploadFileWeb.ashx` -> `ProcessRequest(HttpContext context)` — validates product image filenames before saving.
- `App_Code/SignalR/MainHub.cs` -> `PreviewAll(dynamic arrSP)` — supplies inquiry/cart preview data; `XX` must return empty packing fields instead of omitting them.
- `App_Code/SignalR/Objects.cs` -> `Inquiry_QRCode.CreateWBQuotation()` — quotation export must include `XX` products even when they have no default packaging row; packing/package-count cells stay blank.

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

**Status: Confirmed**

Order-fee allocation (`phanBoPhi`) is guarded by order state and required data:

- the order must be in the system's draft/`SOANTHAO` state before allocation is allowed;
- the order must contain order lines;
- active order fees must exist before fee allocation can proceed;
- total order-line quantity must be greater than zero.

The allocation calculates per-unit add/subtract fees from active `c_phidonhang` records. When allocation succeeds, each `c_dongdonhang` receives the same calculated per-unit values in both the live fee fields and the allocation snapshot fields:

- `phi = phi_pb =` allocated add fee (`phiCong`);
- `phitru = phitru_pb =` allocated subtract fee (`phiTru`).

`phi_pb` and `phitru_pb` therefore preserve the values produced specifically by the **"Phân bổ phí vào dòng hàng"** action, while the existing `phi` and `phitru` fields continue to receive the same values for compatibility with existing behavior.

**Where implemented:**

- `Controllers/PhiDonHangController.ashx` -> `phanBoPhi(HttpContext context)`.

**Related:**

- `c_donhang`
- `c_dongdonhang.phi`
- `c_dongdonhang.phitru`
- `c_dongdonhang.phi_pb`
- `c_dongdonhang.phitru_pb`
- `c_phidonhang`
- `Helper.SOANTHAO`

---

## PO — order-line fee editability

### `phi` / "Phí cộng" is intended to be editable by default

**Status: Confirmed**

In the PO order-line Add/Edit form under `#donhang-details-1`, the field `phi` (display label **"Phí cộng"**) is intended to be editable by default while the surrounding PO/order state permits editing.

The jqGrid column may correctly declare `editable: true` but still render as locked if its `editoptions` contains `disabled: true`:

```js
{
    name: 'phi',
    label: 'Phí cộng',
    index: 'ddh.phi',
    editable: true,
    editoptions: { defaultValue: '0', disabled: true }
}
```

Therefore, when diagnosing a PO fee field that appears permanently locked, inspect `editoptions.disabled` before adding new permission or JavaScript unlock logic. To restore the intended default editability, remove `disabled: true` (or otherwise ensure it is not disabled).

**Where implemented:**

- `Views/po/cacdongpo.ascx` — jqGrid order-line column definition for `name: 'phi'`; this is the PO detail UI loaded under `#donhang-details-1`.
- `Controllers/DongDonHangController.ashx` -> `edit(HttpContext context)` — server accepts `Request.Form["phi"]`, validates that the value is non-negative, and assigns it to `c_dongdonhang.phi` for editable draft orders.

**Related:**

- `c_dongdonhang.phi`
- PO detail tab `#donhang-details-1`
- `Helper.SOANTHAO`

**Notes:**

Do not confuse jqGrid's `editable: true` with the final enabled/disabled state of the generated input. `editoptions: { disabled: true }` overrides the practical ability to type into the field even though the column itself is marked editable.

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
