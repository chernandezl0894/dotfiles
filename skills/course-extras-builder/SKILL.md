---
name: Course Extras Builder
description: Add a glossary, cheatsheet, anti-patterns catalog, appendices, instructor guide, assessment pack or technical profile to a platform-ready technical course. Use when the user asks for reference material, teaching notes, interview guide, cheatsheet or extra assets for a course created with technical-course-factory.
---

# Course Extras Builder

## Mission

Create asset artifacts that make the course usable on a platform and in a classroom: glossary, cheatsheet, anti-patterns, appendices, instructor guide, assessment pack and technical profile.

## Read first

1. `course.yaml`, `TOC.md`, `README.md`, `CURSO.md`, `SEGUIMIENTO.md`.
2. `~/.config/opencode/skills/technical-course-factory/references/06-extras.md`.
3. `~/.config/opencode/skills/technical-course-factory/references/07-platform-contract.md`.
4. The language adapter and existing lessons for terminology.

## Artifacts

### Glossary

- `glosario.md`.
- Term, definition, lesson reference.
- One entry per term; link from README.

### Cheatsheet

- `cheatsheet-<language>.md` or `cheatsheet.md`.
- Definitions, syntax/idiom mapping, rules, review questions.
- 1–2 pages.

### Anti-patterns

- `anti-patterns.md`.
- 12–17 entries: symptoms, why, detect, fix, lesson reference.
- Smell → anti-pattern table.

### Appendices

- `apendices/` with `README.md` and one file per appendix.
- Deep dive, setup, testing, performance, security, deployment, migration.

### Instructor guide

- `guia-instructor.md`.
- Audience, timing, common questions, common mistakes, demos, homework, assessment.

### Assessment pack

- `evaluacion/` with quiz bank, rubrics, capstone brief, solutions.
- Link from README and course.yaml.

### Technical profile

- `perfil-tecnico-<stack>.md`.
- Levels, skills matrix, interview questions, portfolio, 90-day plan.
- Only when the course is career-oriented.

## Workflow

1. Pick one artifact (default) or the requested pack.
2. Read the course and terminology.
3. Write the artifact.
4. Link it from `README.md` and `TOC.md` if relevant.
5. Update `course.yaml`/`CURSO.md`/`SEGUIMIENTO.md`.
6. Run audit.
7. Stop and report the next optional asset.

## Rules

- Text-only by default.
- No duplication of lessons.
- Match level and language.
- No invented facts; mark opinions.
- One artifact per invocation unless asked for a pack.

## Final message

```text
Asset listo: <file>.
Enlazado desde README.md/TOC.md.
Registrado en CURSO.md/SEGUIMIENTO.md.
Siguiente opcional: <asset>.
```
