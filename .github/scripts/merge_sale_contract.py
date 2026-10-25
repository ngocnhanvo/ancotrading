#!/usr/bin/env python3
"""Safely merge one approved Sale Contract file into Azure's existing revision."""
import pathlib
import subprocess
import sys
import tempfile

if len(sys.argv) != 4:
    raise SystemExit("Usage: merge_sale_contract.py azure-file github-base github-new")

target = pathlib.Path(sys.argv[1])
base = pathlib.Path(sys.argv[2])
new = pathlib.Path(sys.argv[3])
if not target.is_file():
    raise SystemExit("Azure Sale Contract target does not exist")

original = target.read_bytes()
if b"\x00" in original:
    raise SystemExit("Refusing to process a binary Sale Contract file")
eol = b"\r\n" if b"\r\n" in original else b"\n"
bom = b"\xef\xbb\xbf" if original.startswith(b"\xef\xbb\xbf") else b""

def clean(raw):
    return raw.removeprefix(b"\xef\xbb\xbf").replace(b"\r\n", b"\n")

current_bytes = clean(original)
new_bytes = clean(new.read_bytes())
if current_bytes == new_bytes:
    print("Approved Sale Contract changes already present in production")
    sys.exit(0)

with tempfile.TemporaryDirectory() as name:
    temp = pathlib.Path(name)
    inputs = [current_bytes, clean(base.read_bytes()), new_bytes]
    paths = []
    for index, data in enumerate(inputs):
        path = temp / ("version-%d.cs" % index)
        path.write_bytes(data)
        paths.append(str(path))
    merged = subprocess.run(
        ["git", "merge-file", "-p", paths[0], paths[1], paths[2]],
        capture_output=True,
    )
    if merged.returncode != 0:
        print("Azure changes conflict with the approved Sale Contract patch", file=sys.stderr)
        print("No production file has been modified.", file=sys.stderr)
        sys.exit(1)

result = merged.stdout
text = result.decode("utf-8-sig")
markers = [
    'SetCellValue("Shipment Time:")',
    'SetCellValue("The consignee:")',
    'SetCellValue("Payment term:")',
]
checks = {
    "No Payer line": 'SetCellValue("The Payer:")' not in text,
    "One consignee line": text.count(markers[1]) == 1,
    "Conditional consignee": "ShouldPrintConsignee(Consignee, tendtkd)" in text,
    "Correct layout order": all(marker in text for marker in markers)
        and text.index(markers[0]) < text.index(markers[1]) < text.index(markers[2]),
    "No conflict markers": "<<<<<<<" not in text and ">>>>>>>" not in text,
}
for key, valid in checks.items():
    print("%s: %s" % (key, "OK" if valid else "FAIL"))
if not all(checks.values()):
    raise SystemExit("Unexpected merged result: refusing to modify production")

if result != current_bytes:
    target.write_bytes(bom + result.replace(b"\n", eol))
    print("Merged Sale Contract update without overwriting unrelated Azure changes")
else:
    print("Approved Sale Contract changes already present in production")
