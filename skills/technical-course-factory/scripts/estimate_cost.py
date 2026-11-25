#!/usr/bin/env python3
"""Estimate words, tokens and cost for a course folder.

Usage:
    python3 estimate_cost.py <course-dir> [--rate 0.60]

The estimate is approximate: tokens ~= words * 1.35.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path


def iter_markdown(root: Path):
    for path in sorted(root.rglob("*.md")):
        if any(part.startswith(".") or part == "node_modules" for part in path.parts):
            continue
        yield path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--rate", type=float, default=0.60,
                        help="USD per million output tokens (default 0.60)")
    args = parser.parse_args()

    root = args.root.resolve()
    if not root.is_dir():
        print(f"Not a directory: {root}")
        return 2

    rows = []
    total_words = 0
    for md in iter_markdown(root):
        words = len(md.read_text(encoding="utf-8", errors="replace").split())
        total_words += words
        rows.append((md.relative_to(root), words))

    total_tokens = int(total_words * 1.35)
    total_cost = total_tokens / 1_000_000 * args.rate

    width = max((len(str(p)) for p, _ in rows), default=10)
    print(f"{'file':<{width}}  {'words':>8}")
    print("-" * (width + 10))
    for path, words in rows:
        print(f"{str(path):<{width}}  {words:>8}")
    print("-" * (width + 10))
    print(f"{'TOTAL':<{width}}  {total_words:>8}")
    print(f"Tokens (est.): {total_tokens}")
    print(f"Cost (est.):   ${total_cost:.4f} USD at ${args.rate:.2f}/M")
    return 0


if __name__ == "__main__":
    sys.exit(main())
