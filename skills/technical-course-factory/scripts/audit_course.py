#!/usr/bin/env python3
"""Audit a platform-ready progressive course.

Usage:
    python3 audit_course.py <course-dir> [--forbidden php,symfony] [--no-code]

Checks:
- required files: README.md, TOC.md, course.yaml, CURSO.md, SEGUIMIENTO.md
- TOC lesson rows and statuses
- lesson files for written/reviewed lessons
- lesson frontmatter keys and practical exercises
- course.yaml basic keys
- relative links, paired fences, forbidden terms
- no-code mode: only mermaid fences
- duplicate glossary terms

Exit code 1 if blockers are found.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_links import find_broken_links  # noqa: E402

REQUIRED = ["README.md", "TOC.md", "course.yaml", "CURSO.md", "SEGUIMIENTO.md"]
STATUSES = {"planned", "in-progress", "written", "reviewed", "dropped"}
LEVELS = {"beginner", "intermediate", "advanced", "expert", "mixed"}
FRONTMATTER_KEYS = [
    "title", "slug", "module", "lesson", "level",
    "duration_minutes", "learning_objectives", "exercises",
]
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")


def strip_ticks(value: str) -> str:
    return value.strip().strip("`").strip()


def parse_toc(root: Path) -> list[dict[str, str]]:
    toc = root / "TOC.md"
    if not toc.exists():
        return []
    rows: list[dict[str, str]] = []
    for line in toc.read_text(encoding="utf-8", errors="replace").splitlines():
        if not line.strip().startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 6:
            continue
        if not re.fullmatch(r"\d+", cells[0]):
            continue
        link = LINK_RE.search(cells[1])
        rows.append({
            "number": cells[0],
            "lesson": cells[1],
            "file": link.group(1) if link else "",
            "level": strip_ticks(cells[2]),
            "duration": cells[3],
            "exercises": cells[4],
            "status": strip_ticks(cells[5]),
        })
    return rows


def parse_frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    keys: dict[str, str] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            break
        if ":" in line and not line.startswith((" ", "\t")):
            key, value = line.split(":", 1)
            keys[key.strip()] = value.strip()
    return keys


def check_course_yaml(root: Path) -> list[str]:
    problems: list[str] = []
    path = root / "course.yaml"
    if not path.exists():
        return problems
    text = path.read_text(encoding="utf-8", errors="replace")
    for key in ["id", "title", "description", "language", "code_language",
                "level", "duration_minutes", "version", "license", "tags", "modules"]:
        if not re.search(rf"^{re.escape(key)}\s*:", text, re.MULTILINE):
            problems.append(f"WARNING course.yaml: missing key '{key}'")
    if "file:" not in text:
        problems.append("BLOCKER course.yaml: no lesson files listed")
    return problems


def check_lessons(root: Path, toc_rows: list[dict[str, str]]) -> list[str]:
    problems: list[str] = []
    linked_files: set[str] = set()

    for row in toc_rows:
        status = row["status"]
        if status not in STATUSES:
            problems.append(
                f"WARNING TOC.md: unknown status '{status}' for lesson {row['number']}"
            )
        if row["level"] and row["level"] not in LEVELS:
            problems.append(
                f"WARNING TOC.md: unknown level '{row['level']}' for lesson {row['number']}"
            )
        if status in {"written", "reviewed"}:
            if not row["file"]:
                problems.append(
                    f"BLOCKER TOC.md: lesson {row['number']} is {status} but has no link"
                )
                continue
            file_path = (root / row["file"]).resolve()
            if not file_path.exists():
                problems.append(
                    f"BLOCKER TOC.md: lesson {row['number']} file missing: {row['file']}"
                )
                continue
            linked_files.add(str(file_path))
            fm = parse_frontmatter(file_path)
            for key in FRONTMATTER_KEYS:
                if key not in fm:
                    problems.append(
                        f"BLOCKER {row['file']}: missing frontmatter key '{key}'"
                    )
            body = file_path.read_text(encoding="utf-8", errors="replace")
            if "## Ejercicios prácticos" not in body:
                problems.append(
                    f"BLOCKER {row['file']}: missing '## Ejercicios prácticos'"
                )
            for heading in ["### Guiado", "### Independiente", "### Quiz"]:
                if heading not in body:
                    problems.append(
                        f"WARNING {row['file']}: missing exercise section '{heading}'"
                    )

    lessons_dir = root / "lessons"
    if lessons_dir.exists():
        for lesson in sorted(lessons_dir.glob("*.md")):
            if str(lesson.resolve()) not in linked_files:
                problems.append(
                    f"WARNING {lesson}: lesson file exists but is not linked from TOC.md"
                )
    return problems


def check_fences(root: Path, no_code: bool) -> list[str]:
    problems: list[str] = []
    for md in sorted(root.rglob("*.md")):
        if any(part.startswith(".") for part in md.parts):
            continue
        text = md.read_text(encoding="utf-8", errors="replace")
        fences = [line for line in text.splitlines() if line.startswith("```")]
        if len(fences) % 2 != 0:
            problems.append(f"BLOCKER {md}: odd number of code fences ({len(fences)})")
        if no_code:
            inside = False
            for line in text.splitlines():
                if line.startswith("```"):
                    if not inside:
                        lang = line.strip()[3:].strip().lower()
                        if lang and lang != "mermaid":
                            problems.append(
                                f"BLOCKER {md}: code block '{lang}' in no-code mode"
                            )
                    inside = not inside
    return problems


def check_forbidden(root: Path, terms: list[str]) -> list[str]:
    problems: list[str] = []
    if not terms:
        return problems
    for md in sorted(root.rglob("*.md")):
        if any(part.startswith(".") for part in md.parts):
            continue
        lower = md.read_text(encoding="utf-8", errors="replace").lower()
        for term in terms:
            term = term.strip().lower()
            if not term:
                continue
            for lineno, line in enumerate(lower.splitlines(), start=1):
                if term in line:
                    problems.append(f"BLOCKER {md}:{lineno}: forbidden term '{term}'")
    return problems


def check_glossary(root: Path) -> list[str]:
    problems: list[str] = []
    for md in sorted(root.rglob("*.md")):
        if any(part.startswith(".") for part in md.parts):
            continue
        lines = md.read_text(encoding="utf-8", errors="replace").splitlines()
        in_glossary = False
        seen: set[str] = set()
        header_seen = False
        for line in lines:
            if line.startswith("## "):
                in_glossary = "glosario" in line.lower()
                header_seen = False
                continue
            if not in_glossary or not line.strip().startswith("|"):
                continue
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if not header_seen:
                header_seen = True
                continue
            if all(re.fullmatch(r":?-{2,}:?", c) for c in cells if c):
                continue
            term = strip_ticks(cells[0]).lower() if cells else ""
            if not term or term in {"término", "term"}:
                continue
            if term in seen:
                problems.append(f"WARNING {md}: duplicate glossary term '{term}'")
            seen.add(term)
    return problems


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--forbidden", default="", help="comma-separated terms")
    parser.add_argument("--no-code", action="store_true")
    args = parser.parse_args()

    root = args.root.resolve()
    if not root.is_dir():
        print(f"Not a directory: {root}")
        return 2

    problems: list[str] = []
    for name in REQUIRED:
        if not (root / name).exists():
            problems.append(f"BLOCKER missing required file: {name}")

    toc_rows = parse_toc(root)
    if (root / "TOC.md").exists() and not toc_rows:
        problems.append("WARNING TOC.md: no lesson rows found")

    problems.extend(check_course_yaml(root))
    problems.extend(check_lessons(root, toc_rows))
    problems.extend(check_fences(root, args.no_code))
    problems.extend(check_glossary(root))

    terms = [t for t in args.forbidden.split(",") if t.strip()]
    problems.extend(check_forbidden(root, terms))

    for md, lineno, raw, _resolved in find_broken_links(root):
        problems.append(f"BLOCKER {md}:{lineno}: broken link '{raw}'")

    if not problems:
        print(f"OK: {root} passes the structural audit ({len(toc_rows)} lessons).")
        return 0

    blockers = sum(1 for p in problems if p.startswith("BLOCKER"))
    warnings = sum(1 for p in problems if p.startswith("WARNING"))
    for problem in problems:
        print(problem)
    print(f"\n{blockers} blocker(s), {warnings} warning(s).")
    return 1 if blockers else 0


if __name__ == "__main__":
    sys.exit(main())
