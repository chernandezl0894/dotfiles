---
name: Course QA Auditor
description: Audit a platform-ready technical course for TOC/manifest consistency, lesson frontmatter, level and exercise coverage, broken links, odd fences, forbidden stack references, metadata and cost. Use when the user asks to review, audit, validate or run a second pass on a course created with technical-course-factory.
---

# Course QA Auditor

## Mission

Find structural, metadata and consistency defects in a platform-ready course. Report clearly. Do not rewrite content unless asked.

## Read first

1. `course.yaml`, `TOC.md`, `README.md`, `CURSO.md`, `SEGUIMIENTO.md`.
2. `~/.config/opencode/skills/technical-course-factory/references/04-quality.md`.
3. `~/.config/opencode/skills/technical-course-factory/references/07-platform-contract.md`.
4. `~/.config/opencode/skills/technical-course-factory/references/08-levels.md`.
5. The language adapter.

## Run

```sh
python3 ~/.config/opencode/skills/technical-course-factory/scripts/audit_course.py <course-dir>
python3 ~/.config/opencode/skills/technical-course-factory/scripts/estimate_cost.py <course-dir>
```

Flags:

```sh
--forbidden php,symfony,doctrine
--no-code
```

## Checks

- Required files: README, TOC, course.yaml, CURSO, SEGUIMIENTO.
- TOC rows match `course.yaml` and lesson files.
- Statuses consistent (`planned`, `in-progress`, `written`, `reviewed`, `dropped`).
- Lesson frontmatter has required keys.
- Each written lesson has `## Ejercicios prácticos`.
- Exercise counts in frontmatter match the body.
- Level consistency between course, TOC and lesson.
- Language pair (`language` vs `code_language`).
- Relative links.
- Paired code fences.
- `no-code` mode only allows Mermaid.
- Forbidden stack terms.
- Glossary duplicates.
- Cost/progress/session updated.
- Platform metadata: id, title, description, level, language, tags, duration, version, license.

## Report format

```text
BLOCKER  file:line — problem — fix
WARNING  file:line — problem — fix
INFO     file:line — suggestion
```

Summary:

- Files checked.
- Blockers/warnings.
- Ready for `reviewed` or not.

## Modes

- **Audit only** (default): report, no edits.
- **Fix blockers**: only with explicit request; one category at a time.
- **Review pass**: terminology, continuity, snippet accuracy, pedagogy; mark `reviewed` only if clean.

## Rules

- Do not rewrite a lesson during an audit.
- Do not change the plan; report it.
- Do not mark `reviewed` with blockers.
- If a fact needs a human expert, say so.
- Keep the report short and actionable.

## Final message

```text
Auditoría: <course>
BLOCKERS: N
WARNINGS: N
Estado: listo / no listo para reviewed.
Siguiente: corregir <category> o pedir revisión humana.
```
