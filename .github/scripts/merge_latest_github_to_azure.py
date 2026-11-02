#!/usr/bin/env python3
"""Merge only the approved four GitHub source files into Azure master.

Preserve the current Azure file encoding, line endings and independent edits.
All proposed merges are computed before writing any target file. Fail closed.
"""
from __future__ import annotations

import collections
import pathlib
import subprocess
import sys
import tempfile

FILES = (
    "App_Code/OfficeToPDF/Helper.cs",
    "App_Code/Public.cs",
    "Controllers/DongDonHangController.ashx",
    "Controllers/PackingController.ashx",
)


def read_git(rev: str, name: str) -> bytes:
    return subprocess.run(
        ["git", "show", f"{rev}:{name}"],
        check=True,
        capture_output=True,
    ).stdout


def unpack(data: bytes, source: str) -> tuple[str, str, str]:
    if data.startswith(b"\xff\xfe"):
        encoding = "utf-16"
    elif data.startswith(b"\xef\xbb\xbf"):
        encoding = "utf-8-sig"
    else:
        encoding = "utf-8"
    text = data.decode(encoding)
    if text.encode(encoding) != data:
        raise RuntimeError(f"Encoding could not be preserved for {source}")
    eol = "\r\n" if "\r\n" in text else "\n"
    if "\r\n" in text and "\n" in text.replace("\r\n", ""):
        raise RuntimeError(f"Mixed line endings in {source}; manual inspection required")
    return text.replace("\r\n", "\n"), encoding, eol


def pack(text: str, encoding: str, eol: str) -> bytes:
    return text.replace("\n", eol).encode(encoding)


def merge_text(ours: str, base: str, theirs: str) -> str:
    with tempfile.TemporaryDirectory(prefix="anco-merge-") as temp:
        d = pathlib.Path(temp)
        for name, value in (("ours", ours), ("base", base), ("theirs", theirs)):
            (d / name).write_bytes(value.encode("utf-8"))
        cmd = [
            "git", "merge-file", "-p",
            "-L", "approved-github", "-L", "common-baseline", "-L", "current-azure",
            str(d / "ours"), str(d / "base"), str(d / "theirs"),
        ]
        result = subprocess.run(cmd, capture_output=True)
        if result.returncode != 0:
            raise RuntimeError(
                "Conflicting or invalid merge; Azure unchanged. "
                f"git merge-file returned {result.returncode}"
            )
        return result.stdout.decode("utf-8")


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit("Usage: merge_latest_github_to_azure.py BASE SOURCE AZURE_DIRECTORY")
    base, head, directory = sys.argv[1:]
    azure = pathlib.Path(directory)
    if not (azure / ".git").exists():
        raise RuntimeError("Azure directory is not a git checkout")

    planned = []
    decisions = []
    for name in FILES:
        old, _, _ = unpack(read_git(base, name), f"GitHub base {name}")
        new, _, _ = unpack(read_git(head, name), f"GitHub current {name}")
        dest = azure / name
        if not dest.is_file():
            raise RuntimeError(f"File missing on Azure; aborting: {name}")
        original = dest.read_bytes()
        live, encoding, eol = unpack(original, f"Azure {name}")

        if name == "App_Code/Public.cs":
            assert new.count('cl = s.code_cl, dc = s.discount ?? 0') == 1
            assert 'cl = s.code_cl ?? "", dc = s.discount ?? 0' not in new

        if old == new:
            decision, joined = "UNCHANGED", live
        elif live == new:
            decision, joined = "ALREADY_SYNCED", live
        elif live == old:
            decision, joined = "APPLY_DIRECT", new
        else:
            decision = "MERGE_PRESERVING_AZURE"
            try:
                joined = merge_text(new, old, live)
            except RuntimeError as exc:
                raise RuntimeError(f"Conflict at {name}: {exc}") from exc

        if name == "App_Code/Public.cs":
            if joined.count('cl = s.code_cl, dc = s.discount ?? 0') != 1:
                raise RuntimeError("Final Azure Public.cs would not preserve nullable code_cl")
            if 'cl = s.code_cl ?? "", dc = s.discount ?? 0' in joined:
                raise RuntimeError("Final Azure Public.cs contains old string fallback")
        updated = pack(joined, encoding, eol)
        planned.append((dest, original, updated))
        decisions.append((name, decision, len(original), len(updated)))

    # No target file was modified before all four checks completed.
    for name, decision, before, after in decisions:
        print(f"{decision} | {name} | bytes_before={before} | bytes_after={after}")
    print("SUMMARY:", dict(collections.Counter(value for _, value, _, _ in decisions)))

    for dest, original, updated in planned:
        if updated != original:
            dest.write_bytes(updated)
    print("ALL_MERGES_VALIDATED: only approved paths updated in Azure checkout")


if __name__ == "__main__":
    main()
