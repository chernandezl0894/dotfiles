---
name: Course Lesson Writer
description: Write the next or a specified lesson of a progressive, platform-ready technical course using course.yaml, TOC.md, CURSO.md and SEGUIMIENTO.md. Updates tracking, exercises and TOC, then stops. Use when the user says continue, next lesson, generate lesson N, or asks to resume a course started with technical-course-factory.
---

# Course Lesson Writer

## Mission

Write **exactly one lesson** of an existing progressive course, keep continuity, update the platform manifest and TOC, and stop.

Do not start a new course. If `course.yaml` or `CURSO.md` does not exist, tell the user to run `technical-course-factory` first. If lessons exist but the manifest does not, ask the factory to bootstrap the course.

## Read first

1. `course.yaml` and `TOC.md`.
2. `CURSO.md` and `SEGUIMIENTO.md`.
3. The previous lesson.
4. Shared rules:
   - `~/.config/opencode/skills/technical-course-factory/references/02-progressive.md`
   - `~/.config/opencode/skills/technical-course-factory/references/03-lessons.md`
   - `~/.config/opencode/skills/technical-course-factory/references/08-levels.md`
   - `~/.config/opencode/skills/technical-course-factory/references/09-pedagogy.md`
   - `~/.config/opencode/skills/technical-course-factory/references/04-quality.md`
5. The language adapter:
   - Python: `.../stack-adapters/python.md`
   - Go: `.../stack-adapters/go.md`
   - TypeScript/NestJS: `.../stack-adapters/typescript-nestjs.md`
   - Other: `.../stack-adapters/_template.md`
6. Template:
   - `~/.config/opencode/skills/technical-course-factory/templates/lesson.template.md`

## Workflow

1. **Find the lesson**
   - If the user names a number, use it.
   - Otherwise choose the lowest `planned` lesson.
   - If none remain, report the course as complete.

2. **Check prerequisites**
   - The lesson’s `prerequisites` must be `written` or `reviewed`.
   - If not, warn and ask before continuing.

3. **Check continuity**
   - Reuse terminology and examples.
   - Read the previous lesson’s takeaways and next step.
   - If a concept/name changes, explain why and update `CURSO.md`.

4. **Write one lesson**
   - Follow the lesson template and level profile.
   - Include YAML frontmatter.
   - Include objectives, content, example, common mistakes, guided/independent/quiz exercises, key takeaways and next lesson.
   - Respect code density and language adapter.

5. **Update platform files**
   - `course.yaml`: lesson `status: written`, duration and exercise counts.
   - `TOC.md`: status and link.
   - `README.md`: progress.
   - `SEGUIMIENTO.md`: progress, session, glossary, cost.
   - Record the next lesson.

6. **Mini QA**
   - Run:
     ```sh
     python3 ~/.config/opencode/skills/technical-course-factory/scripts/audit_course.py <course-dir>
     ```
   - Fix broken links, odd fences, TOC/manifest mismatch, missing exercises.
   - Do not rewrite previous lessons.

7. **Stop**
   - Do not write the next lesson.
   - Report the next lesson and continuation command.

## Batch requests

If the user asks for several lessons:

- Write one.
- Update tracking.
- Pause.
- Ask before continuing.
- Never generate beyond the requested count.

## Final message

```text
Lección N lista: lessons/NN-<slug>.md.
Estado: N de M.
Siguiente: lección N+1 — <title>.
Para continuar, pide «genera la lección N+1» o usa course-lesson-writer.
```

## Stop conditions

Ask before:

- Writing lesson 2 when the user only asked to start.
- Skipping a prerequisite.
- Changing the plan, level or language.
- Creating code/projects.
- Rewriting a previous lesson.
- Exceeding the budget.
