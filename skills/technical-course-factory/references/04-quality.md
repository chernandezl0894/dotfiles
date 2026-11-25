# 04 — Quality gates

Quality is checked after setup, after each lesson, and at the end of the course.

## Blockers

- Missing `README.md`, `TOC.md`, `course.yaml`, `CURSO.md` or `SEGUIMIENTO.md`.
- A lesson marked `written`/`reviewed` without a file.
- `TOC.md` and `course.yaml` disagree on order, files or status.
- Broken relative links.
- Odd number of code fences.
- A `none` code-density course with non-Mermaid code blocks.
- A lesson without `## Ejercicios prácticos`.
- A lesson without guided/independent/quiz exercises (unless level profile says otherwise).
- Missing lesson frontmatter keys.
- References to a stack the course explicitly forbids.
- Module order that violates prerequisites.

## Warnings

- Duplicate glossary terms.
- Lesson duration unrealistic for its content.
- Level mismatch between frontmatter and TOC.
- More than 3 snippets in a `minimal` lesson.
- No common mistakes or key takeaways.
- Quiz without answers.
- Exercise without acceptance criteria.
- Cost estimate missing or exceeded.
- Tags/SEO/description missing in `course.yaml`.

## The audit script

```sh
python3 ~/.config/opencode/skills/technical-course-factory/scripts/audit_course.py <course-dir>
```

Options:

```sh
--forbidden php,symfony,doctrine
--no-code
```

It checks required files, TOC/lesson consistency, lesson frontmatter, exercise heading, links, fences, forbidden terms and `--no-code`. It does not judge pedagogical quality; that is the reviewer’s job.

## Review pass

A second pass checks:

- Objectives vs exercises vs quiz.
- Level and prerequisites.
- Examples and claims.
- Terminology and language.
- TOC and manifest.
- Exercises and solutions.
- Platform metadata.
- Accessibility and reading flow.

Only after this pass mark lessons and course as `reviewed`.

## Severity labels

- `BLOCKER` — must fix.
- `WARNING` — should fix.
- `INFO` — optional improvement.

Include file and line when possible.

## Human review

The skill can check structure and consistency, but not domain truth. A human expert should validate:

- APIs, versions and library names.
- Code snippets that claim to compile.
- Business rules and examples.
- Security or performance claims.
- Quiz answers.

Record the reviewer and date in `SEGUIMIENTO.md`.
