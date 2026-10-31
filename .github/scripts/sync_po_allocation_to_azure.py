#!/usr/bin/env python3
"""Merge only the reviewed PO allocation edits from GitHub into Azure master.

Input: Azure checkout, before-change GitHub files, after-change GitHub files.
Validate every result before writing; never use a whole-file overwrite.
"""
import difflib
import pathlib
import subprocess
import sys
import tempfile

FILES = (
    "Views/phanbococpo/Controller_PhanBoCocPO.ashx",
    "Views/phanbococpo/phanbococpo.js",
    "Views/phanbococpo/phanbococpo.ascx",
    "Views/phanbococpo/phanbococpo.ascx.cs",
    "Views/phanbococpo/phanbococpo.css",
    "Views/chungtuxuatkhoNV/inc-ctxkNV.aspx",
)

if len(sys.argv) != 4:
    sys.exit("Usage: sync_po_allocation_to_azure.py AZURE_ROOT BEFORE_ROOT AFTER_ROOT")
azure, before, after = map(pathlib.Path, sys.argv[1:])


def clean(data):
    if b"\x00" in data:
        raise ValueError("Unexpected binary data")
    return data.removeprefix(b"\xef\xbb\xbf").replace(b"\r\n", b"\n")


def occurrences(seq, fragment):
    if not fragment:
        return []
    size = len(fragment)
    return [i for i in range(len(seq) - size + 1) if seq[i:i + size] == fragment]


def patch_chunks(current, base, new, rel):
    """Apply uniquely matching 3-context source hunks only if merge-file conflicts."""
    original = current.splitlines(keepends=True)
    old = base.splitlines(keepends=True)
    fresh = new.splitlines(keepends=True)
    groups = list(difflib.SequenceMatcher(None, old, fresh, autojunk=False).get_grouped_opcodes(3))
    for group in groups:
        x1, x2 = group[0][1], group[-1][2]
        y1, y2 = group[0][3], group[-1][4]
        old_lines, new_lines = old[x1:x2], fresh[y1:y2]
        found = occurrences(original, old_lines)
        if len(found) == 1:
            idx = found[0]
            original[idx:idx + len(old_lines)] = new_lines
        elif len(occurrences(original, new_lines)) == 1:
            continue  # Hunk already present in Azure
        else:
            raise ValueError("%s: ambiguous/conflicting change; refusing Azure push" % rel)
    return b"".join(original)


def merge_text(current, base, new, rel):
    if current == new:
        return current
    if base == new:
        return current
    with tempfile.TemporaryDirectory() as td:
        paths = []
        for name, contents in (("azure", current), ("before", base), ("after", new)):
            p = pathlib.Path(td, name)
            p.write_bytes(contents)
            paths.append(str(p))
        output = subprocess.run(["git", "merge-file", "-p", *paths], capture_output=True)
    if output.returncode == 0:
        return output.stdout
    if output.returncode != 1:
        raise ValueError("%s: git merge-file failed: %s" % (rel, output.stderr.decode("utf-8", "replace")))
    return patch_chunks(current, base, new, rel)


def preserve_line_endings(original, updated):
    bom = b"\xef\xbb\xbf" if original.startswith(b"\xef\xbb\xbf") else b""
    old_lines = original.removeprefix(bom).splitlines(keepends=True)
    clean_lines = clean(original).splitlines(keepends=True)
    new_lines = updated.splitlines(keepends=True)
    default = b"\r\n" if original.count(b"\r\n") > original.count(b"\n") // 2 else b"\n"
    result = []
    diffs = difflib.SequenceMatcher(None, clean_lines, new_lines, autojunk=False)
    for op, i1, i2, j1, j2 in diffs.get_opcodes():
        if op == "equal":
            result.extend(old_lines[i1:i2])
        else:
            for offset, line in enumerate(new_lines[j1:j2]):
                corresponding = old_lines[i1 + offset] if i1 + offset < i2 else b""
                eol = b"\r\n" if corresponding.endswith(b"\r\n") else (
                    b"\n" if corresponding.endswith(b"\n") else default)
                result.append(line[:-1] + eol if line.endswith(b"\n") else line)
    return bom + b"".join(result)


# Check all files before modifying the Azure checkout. Abort if any file diverges.
changes = []
for rel in FILES:
    target = azure / rel
    baseline = before / rel
    revised = after / rel
    for path in (target, baseline, revised):
        if not path.is_file():
            raise ValueError("Missing required file " + str(path))
    raw = target.read_bytes()
    final = merge_text(clean(raw), clean(baseline.read_bytes()), clean(revised.read_bytes()), rel)
    if b"EnablePOAllocationDraftSave" in final or b"anco-pb-write-enabled" in final:
        raise ValueError(rel + ": stale config gate was not removed")
    if rel.endswith("Controller_PhanBoCocPO.ashx"):
        for essential in (b"writePolicy =", b"if (isSave && !admin)",
                          b"invalid_csrf", b"if (status != \"SOANTHAO\")",
                          b"exceeds_deposit", b"stale_allocation"):
            if essential not in final:
                raise ValueError("Missing controller safety guard " + repr(essential))
    if rel.endswith("phanbococpo.js"):
        for essential in (b"writePolicy", b"writeBlockReason",
                          b"anco-pb-lock-reason", b"20261031-write"):
            if essential not in final:
                raise ValueError("Missing frontend feature " + repr(essential))
    if rel.endswith("phanbococpo.ascx.cs") and b"anco_po_allocation_csrf" not in final:
        raise ValueError("CSRF token generator is missing")
    changes.append((target, raw, preserve_line_endings(raw, final)))

for target, old, new in changes:
    if old != new:
        target.write_bytes(new)
        print("Updated safely:", target.relative_to(azure))
    else:
        print("Already synchronized:", target.relative_to(azure))
