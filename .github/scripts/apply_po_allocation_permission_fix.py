#!/usr/bin/env python3
"""Apply only the reviewed admin-only allocation permission removal to Azure."""
from pathlib import Path
import sys

target, old_file, new_file = map(Path, sys.argv[1:])
def decode(data):
    if b"\x00" in data: raise RuntimeError("Unexpected binary data")
    bom = b"\xef\xbb\xbf" if data.startswith(b"\xef\xbb\xbf") else b""
    return data[len(bom):].decode("utf-8").replace("\r\n", "\n"), bom, (b"\r\n" if b"\r\n" in data else b"\n")
old = decode(old_file.read_bytes())[0]
new = decode(new_file.read_bytes())[0]
guard = '''                if (isSave && !admin)
                {
                    Error(context, 403, "admin_required", "Giai đoạn thử nghiệm chỉ quản trị viên mới được lưu phân bổ.");
                    return;
                }
'''
policy_before = '''                    // Match the existing POST guards; a disabled UI is never the security boundary.
                    string writeBlockReason = !admin
                        ? "Chỉ quản trị viên mới được lưu phân bổ cọc."
                        : !String.Equals(invoice.md_trangthai_id, "SOANTHAO", StringComparison.Ordinal)
                        ? "Invoice không ở trạng thái SOANTHAO, không thể thêm hoặc sửa phân bổ cọc."
                        : "";'''
policy_after = '''                    // Keep the existing Invoice draft-state guard; no admin-only restriction.
                    string writeBlockReason = !String.Equals(invoice.md_trangthai_id, "SOANTHAO", StringComparison.Ordinal)
                        ? "Invoice không ở trạng thái SOANTHAO, không thể thêm hoặc sửa phân bổ cọc."
                        : "";'''
if old.count(guard) != 1 or old.count(policy_before) != 1:
    raise RuntimeError("GitHub baseline differs from the approved patch")
if old.replace(guard, "", 1).replace(policy_before, policy_after, 1) != new:
    raise RuntimeError("GitHub commit changes more than the approved permissions")
raw = target.read_bytes()
azure, bom, eol = decode(raw)
if azure.count(guard) == 1:
    azure = azure.replace(guard, "", 1)
elif "if (isSave && !admin)" in azure or "admin_required" in azure:
    raise RuntimeError("Azure has a different admin save guard; refusing to overwrite")
if azure.count(policy_before) == 1:
    azure = azure.replace(policy_before, policy_after, 1)
elif azure.count(policy_after) != 1:
    raise RuntimeError("Azure writePolicy diverged; refusing to overwrite")
if "admin_required" in azure or "if (isSave && !admin)" in azure or azure.count(policy_after) != 1:
    raise RuntimeError("Expected permissions change is not complete")
encoded = bom + azure.replace("\n", eol.decode("ascii")).encode("utf-8")
if encoded != raw:
    target.write_bytes(encoded)
    print("AZURE_CONTROLLER_UPDATED")
else:
    print("AZURE_CONTROLLER_ALREADY_UPDATED")
