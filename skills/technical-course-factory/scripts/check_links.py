#!/usr/bin/env python3
"""Check relative Markdown links in a course folder.

Usage:
    python3 check_links.py <course-dir>

Exit code 1 when a broken link is found.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
SKIP_PREFIXES = ("http://", "https://", "#", "mailto:", "tel:")


def iter_markdown(root: Path):
    for path in sorted(root.rglob("*.md")):
        if any(part.startswith(".") or part == "node_modules" for part in path.parts):
            continue
        yield path


def find_broken_links(root: Path) -> list[tuple[Path, int, str, Path]]:
    broken: list[tuple[Path, int, str, Path]] = []
    for md in iter_markdown(root):
        text = md.read_text(encoding="utf-8", errors="replace")
        for lineno, line in enumerate(text.splitlines(), start=1):
            for match in LINK_RE.finditer(line):
                raw = match.group(1).strip()
                if raw.startswith(SKIP_PREFIXES):
                    continue
                target = raw.split("#", 1)[0]
                if not target:
                    continue
                resolved = (md.parent / target).resolve()
                if not resolved.exists():
                    broken.append((md, lineno, raw, resolved))
    return broken


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    args = parser.parse_args()

    root = args.root.resolve()
    if not root.is_dir():
        print(f"Not a directory: {root}")
        return 2

    broken = find_broken_links(root)
    if not broken:
        print(f"OK: no broken links in {root}")
        return 0

    for md, lineno, raw, resolved in broken:
        print(f"BROKEN {md}:{lineno} -> {raw} (resolved: {resolved})")
    print(f"\n{len(broken)} broken link(s).")
    return 1


if __name__ == "__main__":
    sys.exit(main())
