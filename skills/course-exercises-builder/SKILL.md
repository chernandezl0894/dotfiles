---
name: Course Exercises Builder
description: Add or improve per-lesson practical exercises, quizzes, capstone and exercise index for a platform-ready technical course. Use when the user asks for exercises, practice, katas, quiz bank, capstone or a practice pack for a course created with technical-course-factory.
---

# Course Exercises Builder

## Mission

Make practice explicit and platform-ready. Every lesson should have practical exercises; optionally add a capstone and a solutions folder.

## Read first

1. `course.yaml`, `TOC.md`, `CURSO.md`, `SEGUIMIENTO.md`.
2. The lesson files.
3. `~/.config/opencode/skills/technical-course-factory/references/05-exercises.md`.
4. `~/.config/opencode/skills/technical-course-factory/references/08-levels.md`.
5. `~/.config/opencode/skills/technical-course-factory/references/10-assessment.md`.
6. `~/.config/opencode/skills/technical-course-factory/templates/exercise.template.md`.

## Workflow

1. **Audit coverage**
   - For each written lesson, check for `## Ejercicios prácticos` and at least guided/independent/quiz.
   - Report missing exercises.

2. **Fill gaps**
   - Add exercises to existing lessons, matching level and objectives.
   - Do not rewrite the lesson content.
   - Keep exercise blocks consistent.

3. **Create a practice index** (optional)
   - `ejercicios/README.md`: method, rubric, order, definition of done.
   - Link from `README.md`.

4. **Capstone** (optional)
   - Real context, several modules, acceptance criteria, rubric, failure scenarios.
   - `ejercicios/capstone-<slug>.md`.

5. **Solutions** (optional)
   - `soluciones/` folder, separate from lessons.
   - Verify correctness.
   - Link only if the course includes solutions.

6. **Update metadata**
   - `course.yaml`: exercise counts.
   - `TOC.md`: exercise counts.
   - `README.md`/`CURSO.md`/`SEGUIMIENTO.md`: links and session.

7. **QA**
   - Run the audit script.
   - Check links, fences, exercise coverage.

## Defaults

- Text-only exercise statements.
- No code/project unless requested.
- 1 guided + 1 independent + 1 quiz per lesson; challenge for intermediate+.
- No solutions unless requested.

## Progressive option

- If the user names a lesson, edit only that lesson.
- If the user asks for a pack, improve all written lessons and add the index.
- Default: one lesson or the pack the user requested; do not touch future lessons.

## Final message

```text
Ejercicios actualizados: N lecciones.
Capstone: sí/no.
Soluciones: sí/no.
Siguiente opcional: cheatsheet, glosario o platform packager.
```

## Stop conditions

- No `course.yaml`: run the factory first.
- User asks for code/projects: confirm and record.
- User asks for solutions: confirm; default no.
