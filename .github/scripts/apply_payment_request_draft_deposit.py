#!/usr/bin/env python3
"""Apply only the reviewed draft-deposit change to Azure PaymentRequest.aspx.cs.

Usage: apply_payment_request_draft_deposit.py AZURE_FILE GITHUB_BASE GITHUB_NEW
All replacements are unambiguous and verified against the exact GitHub diff.
Unrelated Azure edits are retained; conflicts fail closed.
"""
from pathlib import Path
import sys

if len(sys.argv) != 4:
    sys.exit("Usage: apply_payment_request_draft_deposit.py AZURE_FILE BEFORE AFTER")

def read_text(data, label):
    if data.startswith(b"\xff\xfe"):
        encoding = "utf-16"
    elif data.startswith(b"\xef\xbb\xbf"):
        encoding = "utf-8-sig"
    else:
        encoding = "utf-8"
        if b"\x00" in data:
            raise RuntimeError(f"Unexpected binary data: {label}")
    value = data.decode(encoding)
    if value.encode(encoding) != data:
        raise RuntimeError(f"Could not roundtrip {label} encoding")
    eol = "\r\n" if "\r\n" in value else "\n"
    if eol == "\r\n" and "\n" in value.replace("\r\n", ""):
        raise RuntimeError(f"Mixed line endings in {label}")
    return value.replace("\r\n", "\n"), encoding, eol

def unique_replace(source, old, new, label):
    if source.count(old) != 1:
        raise RuntimeError(f"Missing or ambiguous {label}: count={source.count(old)}")
    return source.replace(old, new, 1)

target, previous, approved = map(Path, sys.argv[1:])
base = read_text(previous.read_bytes(), "GitHub previous")[0]
fresh = read_text(approved.read_bytes(), "GitHub approved")[0]
raw = target.read_bytes()
azure, encoding, eol = read_text(raw, "Azure")

anchor = '        info.pkl.tienconlai = info.pkl.tienconlai.GetValueOrDefault(0);\n'
tail = '        string sql = $@"\n'
if base.count(anchor + tail) != 1 or fresh.count(anchor) != 1:
    raise RuntimeError("GitHub deposit insertion anchor changed unexpectedly")

start = fresh.index(anchor) + len(anchor)
end = fresh.find(tail, start)
if end < start:
    raise RuntimeError("Expected SQL construction after new draft deposit logic")
insert = fresh[start:end]
required = (
    'Helper.SOANTHAO',
    'db.ExecuteQuery<decimal>',
    'SUM(sotienphanbo)',
    'dbo.c_packinginvoice_phanbo',
    'WHERE c_packinginvoice_id = {0}',
)
if not all(token in insert for token in required) or 'UPDATE' in insert.upper() or 'DELETE' in insert.upper():
    raise RuntimeError("Approved insertion fails required read-only deposit checks")

old_line = '                {info.pkl.tiendatcoc.Value} as datcoc,'
new_line = '                {depositForPaymentRequest.ToString(System.Globalization.CultureInfo.InvariantCulture)} as datcoc,'
if unique_replace(unique_replace(base, anchor + tail, anchor + insert + tail, "GitHub new block"),
                  old_line, new_line, "GitHub SQL alias") != fresh:
    raise RuntimeError("GitHub approved commit modifies additional unexpected code")

updated_block = anchor + insert + tail
if azure.count(anchor + tail) == 1:
    azure = unique_replace(azure, anchor + tail, updated_block, "Azure draft block")
    block_result = "INSERTED"
elif azure.count(updated_block) == 1:
    block_result = "ALREADY_PRESENT"
else:
    raise RuntimeError("Azure draft-deposit section differs; refusing overwrite")

if azure.count(old_line) == 1:
    azure = unique_replace(azure, old_line, new_line, "Azure deposit alias")
    alias_result = "UPDATED"
elif azure.count(new_line) == 1:
    alias_result = "ALREADY_PRESENT"
else:
    raise RuntimeError("Azure deposit SQL alias differs; refusing overwrite")

if azure.count(updated_block) != 1 or azure.count(new_line) != 1 or old_line in azure:
    raise RuntimeError("Final Azure Payment Request deposit validation failed")

output = azure.replace("\n", eol).encode(encoding)
if output != raw:
    target.write_bytes(output)
print(f"PAYMENT_REQUEST_SYNC_CHECK: block={block_result}, alias={alias_result}, file_changed={output != raw}")
