#!/usr/bin/env python3
"""Apply only PO deposit grid/read-side changes to a separate Azure checkout.

Handles both an Azure branch without the feature and one with the earlier 110px
feature, while preserving unrelated Azure changes. Does not modify SQL data.
"""
import difflib
import pathlib
import re
import subprocess
import sys
import tempfile

if len(sys.argv) != 4:
    raise SystemExit("Usage: sync_po_deposit_columns.py AZURE_ROOT GITHUB_BASE_ROOT GITHUB_NEW_ROOT")

azure_root, base_root, new_root = map(pathlib.Path, sys.argv[1:])


def normalized(raw):
    if b"\x00" in raw:
        raise ValueError("Binary file; refusing to update")
    return raw.removeprefix(b"\xef\xbb\xbf").replace(b"\r\n", b"\n")


def load(root, rel):
    path = root / rel
    if not path.is_file():
        raise ValueError("Missing input file: " + str(path))
    return normalized(path.read_bytes())


def merge(current, base, new, rel):
    with tempfile.TemporaryDirectory() as td:
        inputs = []
        for name, data in (("azure", current), ("base", base), ("github", new)):
            path = pathlib.Path(td) / name
            path.write_bytes(data)
            inputs.append(str(path))
        p = subprocess.run(["git", "merge-file", "-p", *inputs], capture_output=True)
        if p.returncode != 0:
            raise ValueError(rel + ": conflicting Azure edits; nothing will be pushed")
        return p.stdout


def has_name(text, field):
    return len(re.findall(r"\bname\s*:\s*'" + re.escape(field) + r"'", text))


def change_width(text, field):
    # Restrict changes to the column's own definition, not another field.
    pattern = (r"(\bname\s*:\s*'" + re.escape(field) +
               r"'(?:(?!\n\s*\},).)*?\bwidth\s*:\s*)(\d+)")
    match = re.search(pattern, text, flags=re.S)
    if match is None:
        raise ValueError(field + ": cannot locate existing width")
    if match.group(2) not in ("70", "110"):
        raise ValueError(field + ": production width is neither 70 nor 110; refusing overwrite")
    return text[:match.start(2)] + "70" + text[match.end(2):]


def ui_transform(current, base, new):
    text = current.decode("utf-8")
    names = ["datcoc", "daphanbo", "cocconlai"]
    found = [has_name(text, name) for name in names]
    if found == [0, 0, 0]:
        updated = merge(current, base, new, "inc-po.aspx")
        text = updated.decode("utf-8")
    elif found == [1, 1, 1]:
        for field in names:
            text = change_width(text, field)
    else:
        raise ValueError("PO UI has incomplete/duplicate deposit columns: " + str(found))
    order = ["amount", *names, "discount"]
    positions = [text.find("name: '" + field + "'") for field in order]
    if not all(has_name(text, name) == 1 for name in names) or -1 in positions or positions != sorted(positions):
        raise ValueError("PO UI deposit columns are missing, duplicated or in incorrect order")
    for name in names:
        match = re.search(r"\bname\s*:\s*'" + name + r"'(?:(?!\n\s*\},).)*?\bwidth\s*:\s*(\d+)", text, flags=re.S)
        if not match or match.group(1) != "70":
            raise ValueError("PO width validation failed: " + name)
    return text.encode("utf-8")


def backend_transform(current, base, new):
    text = current.decode("utf-8")
    tokens = (" AS datcoc,", " AS daphanbo,", " AS cocconlai,",
              'row["datcoc"]', 'row["daphanbo"]', 'row["cocconlai"]',
              "pi.md_trangthai_id = N'HIEULUC'")
    found = [token in text for token in tokens]
    if not any(found):
        text = merge(current, base, new, "Controllers/DonHangController.ashx").decode("utf-8")
    elif not all(found):
        raise ValueError("PO controller has a partial/incompatible deposit allocation implementation")
    if not all(token in text for token in tokens):
        raise ValueError("PO controller deposit SQL/XML validation failed")
    cells = ['row["amount"]', 'row["datcoc"]', 'row["daphanbo"]',
             'row["cocconlai"]', 'row["discount"]']
    loc = [text.find(token, text.index('public void load(HttpContext context)')) for token in cells]
    if -1 in loc or loc != sorted(loc):
        raise ValueError("PO XML columns are not aligned with UI order")
    return text.encode("utf-8")


# Calculate and validate both files before writing either one.
changes = []
for rel, transform in (("inc-po.aspx", ui_transform),
                       ("Controllers/DonHangController.ashx", backend_transform)):
    target = azure_root / rel
    raw = target.read_bytes()
    result = transform(normalized(raw), load(base_root, rel), load(new_root, rel))
    bom = b"\xef\xbb\xbf" if raw.startswith(b"\xef\xbb\xbf") else b""
    original_lines = raw.removeprefix(bom).splitlines(keepends=True)
    normalized_lines = normalized(raw).splitlines(keepends=True)
    revised_lines = result.splitlines(keepends=True)
    eol = b"\r\n" if b"\r\n" in raw else b"\n"
    output = []
    matcher = difflib.SequenceMatcher(a=normalized_lines, b=revised_lines, autojunk=False)
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            output.extend(original_lines[i1:i2])
        else:
            for offset, line in enumerate(revised_lines[j1:j2]):
                # Keep each original line ending when replacing an existing line.
                original_line = original_lines[i1 + offset] if i1 + offset < i2 else b""
                line_eol = b"\r\n" if original_line.endswith(b"\r\n") else (
                    b"\n" if original_line.endswith(b"\n") else eol)
                output.append(line.rstrip(b"\n").rstrip(b"\r") +
                              (line_eol if line.endswith(b"\n") else b""))
    actual = bom + b"".join(output)
    changes.append((target, raw, actual))

for target, old, new in changes:
    if new != old:
        target.write_bytes(new)
        print("Updated safely:", target.relative_to(azure_root))
    else:
        print("Already in sync:", target.relative_to(azure_root))
