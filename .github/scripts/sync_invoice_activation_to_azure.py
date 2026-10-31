#!/usr/bin/env python3
"""Apply only Invoice-activation PO deposit settlement to Azure master.

Usage: sync_invoice_activation_to_azure.py azure-file github-before github-after
Fail on changed/ambiguous activation logic; preserve all unrelated Azure edits.
"""
import difflib
import pathlib
import sys

if len(sys.argv) != 4:
    sys.exit("Usage: sync_invoice_activation_to_azure.py azure-file before after")
target, before, after = map(pathlib.Path, sys.argv[1:])


def clean(data):
    if b"\x00" in data:
        raise RuntimeError("Refusing binary data")
    return data.removeprefix(b"\xef\xbb\xbf").replace(b"\r\n", b"\n")


def section(text, start, end):
    a = text.find(start)
    if a < 0 or text.count(start) != 1:
        raise RuntimeError("Missing or duplicate activation start: " + start[:70])
    b = text.find(end, a + len(start))
    if b < 0:
        raise RuntimeError("Missing activation end: " + end[:70])
    return text[a:b]


def replace_once(text, needle, replacement):
    if text.count(needle) != 1:
        raise RuntimeError("Azure activation body conflicts with approved change; no push.")
    return text.replace(needle, replacement)


def keep_line_endings(raw, new_content):
    bom = b"\xef\xbb\xbf" if raw.startswith(b"\xef\xbb\xbf") else b""
    old_lines = raw.removeprefix(bom).splitlines(keepends=True)
    normalized_lines = clean(raw).splitlines(keepends=True)
    edited_lines = new_content.splitlines(keepends=True)
    default = b"\r\n" if raw.count(b"\r\n") >= raw.count(b"\n") // 2 else b"\n"
    result = []
    matcher = difflib.SequenceMatcher(None, normalized_lines, edited_lines, autojunk=False)
    for op, i1, i2, j1, j2 in matcher.get_opcodes():
        if op == "equal":
            result.extend(old_lines[i1:i2])
        else:
            for offset, line in enumerate(edited_lines[j1:j2]):
                prior = old_lines[i1+offset] if i1+offset < i2 else b""
                eol = b"\r\n" if prior.endswith(b"\r\n") else (b"\n" if prior.endswith(b"\n") else default)
                result.append(line[:-1] + eol if line.endswith(b"\n") else line)
    return bom + b"".join(result)


raw = target.read_bytes()
cur = clean(raw).decode("utf-8")
base = clean(before.read_bytes()).decode("utf-8")
new = clean(after.read_bytes()).decode("utf-8")

# Do not accept unrelated source revisions as a replacement.
old_body = section(base, '                        pak.md_trangthai_id = "HIEULUC";',
                   '\n\n                        //                //Cập nhật giá')
new_body = section(new, '                        bool activated = ActivatePackingWithPoDeposit(pakId);',
                   '\n\n                        //                //Cập nhật giá')
new_helper = section(new, '\n    // Apply new PO allocations only at Invoice activation.',
                     '    public void getSelectOption(HttpContext context)')
if 'ActivatePackingWithPoDeposit' in base:
    raise RuntimeError("Base already contains the helper; wrong baseline")
if not all(needle in new_helper for needle in (
        'IsolationLevel.Serializable', 'tiendatcoc=@deposit',
        'dbo.c_packinginvoice_phanbo', 'dbo.c_dongphanboinv',
        'tx.Rollback()', 'tx.Commit()', 'UPDLOCK,HOLDLOCK')):
    raise RuntimeError("Approved helper missing essential safety checks")

if 'private static bool ActivatePackingWithPoDeposit' in cur:
    # No guesses about a partially deployed or independently modified helper.
    if cur.count(new_helper) != 1 or cur.count(new_body) != 1:
        raise RuntimeError("Azure has an incompatible version of Invoice allocation logic")
else:
    cur = replace_once(cur, old_body, new_body)
    cur = replace_once(cur, '    public void getSelectOption(HttpContext context)', new_helper +
                       '    public void getSelectOption(HttpContext context)')

if cur.count(new_body) != 1 or cur.count(new_helper) != 1:
    raise RuntimeError("Final code validation failed")
if cur.count('ActivatePackingWithPoDeposit(') != 2:
    raise RuntimeError("Incorrect helper call count")
if 'pak.md_trangthai_id = "HIEULUC";' in cur:
    raise RuntimeError("Unsafe legacy activation assignment remains")
if 'SELECT @@ROWCOUNT;' not in cur or 'perPo.Count == 0' not in cur:
    raise RuntimeError("Idempotent status validation missing")

updated = keep_line_endings(raw, cur.encode("utf-8"))
if raw != updated:
    target.write_bytes(updated)
    print("UPDATED: Controllers/PackingInvoiceController.ashx")
else:
    print("ALREADY_SYNCED: Controllers/PackingInvoiceController.ashx")
