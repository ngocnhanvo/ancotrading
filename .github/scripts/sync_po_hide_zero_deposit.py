#!/usr/bin/env python3
"""Merge only the approved zero-deposit display fix into Azure master.
Run: script AZURE_CHECKOUT GITHUB_BEFORE_SHA GITHUB_AFTER_SHA.
Verify both changes and compute both target files before touching either file.
"""
from pathlib import Path
import subprocess
import sys

JS = "Views/phanbococpo/phanbococpo.js"
ENTRY = "Views/chungtuxuatkhoNV/inc-ctxkNV.aspx"
OLD = "20261031-write"
NEW = "20261104-hide-zero-deposit"

REPLACEMENTS = (
    (
        '    function currentPo() { for (var i = 0; i < poRows.length; i++) if (poRows[i].id === selectedPo) return poRows[i]; return null; }',
        '    function poHasOriginalDeposit(po) { return po && po.deposited != null && num(po.deposited) !== 0; }\n'
        '    function currentPo() { for (var i = 0; i < poRows.length; i++) if (poRows[i].id === selectedPo && poHasOriginalDeposit(poRows[i])) return poRows[i]; return null; }'
    ),
    (
        '        var g=$("#anco-pb-po-grid"); g.jqGrid("clearGridData");\n'
        '        $.each(poRows,function(i,po){',
        '        var g=$("#anco-pb-po-grid"); g.jqGrid("clearGridData");\n'
        '        // Display only POs with a non-zero original deposit. Keep full data for draft saving.\n'
        '        var visiblePoRows=$.grep(poRows,poHasOriginalDeposit);\n'
        '        $.each(visiblePoRows,function(i,po){'
    ),
    (
        '        if (!currentPo()) selectedPo=poRows.length ? poRows[0].id : null;',
        '        if (!currentPo()) selectedPo=visiblePoRows.length ? visiblePoRows[0].id : null;'
    ),
    (
        '                notice(poRows.length ? "":"Invoice này không có dòng hàng liên kết PO.",false);',
        '                notice(!poRows.length ? "Invoice này không có dòng hàng liên kết PO." : !$.grep(poRows,poHasOriginalDeposit).length ? "Không có PO nào có cọc gốc khác 0 để hiển thị." : "",false);'
    ),
    (
        'return {revision:"20261031-write",init:init,setInvoice:setInvoice,syncInvoice:syncInvoice,refreshInvoice:refreshInvoice,resize:resize};',
        'return {revision:"20261104-hide-zero-deposit",init:init,setInvoice:setInvoice,syncInvoice:syncInvoice,refreshInvoice:refreshInvoice,resize:resize};'
    )
)

def source_blob(revision, path):
    return subprocess.run(["git", "show", f"{revision}:{path}"],
                          capture_output=True, check=True).stdout

def decode(raw, name):
    encoding = "utf-8-sig" if raw.startswith(b"\xef\xbb\xbf") else "utf-8"
    text = raw.decode(encoding)
    if text.encode(encoding) != raw:
        raise RuntimeError("Could not round-trip encoding: " + name)
    if "\r\n" in text and "\n" in text.replace("\r\n", ""):
        raise RuntimeError("JS mixed line endings: " + name)
    eol = "\r\n" if "\r\n" in text else "\n"
    return text.replace("\r\n", "\n"), encoding, eol

def apply_js(text, before=False):
    for old, new in REPLACEMENTS:
        count_old = text.count(old)
        count_new = text.count(new)
        if before:
            if count_old != 1 or count_new:
                raise RuntimeError("Unexpected JS source baseline at: " + old[:75])
            text = text.replace(old, new, 1)
        elif count_old == 1 and count_new == 0:
            text = text.replace(old, new, 1)
        elif count_old == 0 and count_new == 1:
            pass
        else:
            raise RuntimeError("Azure JS differs from expected approved change: " + old[:75])
    if "20261031-write" in text or "var visiblePoRows=$.grep(poRows,poHasOriginalDeposit);" not in text:
        raise RuntimeError("Final JS verification failed")
    return text

def apply_entry(raw, baseline=False):
    count_old = raw.count(OLD.encode())
    count_new = raw.count(NEW.encode())
    if baseline:
        if count_old != 2 or count_new:
            raise RuntimeError("Unexpected GitHub entry source baseline")
        return raw.replace(OLD.encode(), NEW.encode())
    if count_old == 2 and count_new == 0:
        return raw.replace(OLD.encode(), NEW.encode())
    if count_old == 0 and count_new == 2:
        return raw
    raise RuntimeError("Azure script cache revision has diverged")

def main():
    if len(sys.argv) != 4:
        raise SystemExit("Usage: sync_po_hide_zero_deposit.py AZURE_ROOT BASE_SHA HEAD_SHA")
    root, base, head = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
    if not (root / ".git").exists():
        raise RuntimeError("Expected Azure Git checkout")
    base_js = source_blob(base, JS)
    new_js = source_blob(head, JS)
    base_entry = source_blob(base, ENTRY)
    new_entry = source_blob(head, ENTRY)

    base_text = decode(base_js, "GitHub base JS")[0]
    new_text = decode(new_js, "GitHub approved JS")[0]
    if apply_js(base_text, before=True) != new_text:
        raise RuntimeError("GitHub approved JS has extra edits")
    if apply_entry(base_entry, baseline=True) != new_entry:
        raise RuntimeError("GitHub approved entry has extra edits")

    target_js = root / JS
    target_entry = root / ENTRY
    if not target_js.is_file() or not target_entry.is_file():
        raise RuntimeError("Missing Azure files")
    old_azure_js = target_js.read_bytes()
    azure_text, enc, eol = decode(old_azure_js, "Azure JS")
    changed_js = apply_js(azure_text).replace("\n", eol).encode(enc)
    old_azure_entry = target_entry.read_bytes()
    changed_entry = apply_entry(old_azure_entry)

    # Do not write either file until both files and baseline checks passed.
    if changed_js != old_azure_js:
        target_js.write_bytes(changed_js)
    if changed_entry != old_azure_entry:
        target_entry.write_bytes(changed_entry)
    print("VALIDATED_PO_HIDE_ZERO_DEPOSIT: JS_changed=%s entry_changed=%s"
          % (changed_js != old_azure_js, changed_entry != old_azure_entry))
    print("No other files or data were modified")

if __name__ == "__main__":
    main()
