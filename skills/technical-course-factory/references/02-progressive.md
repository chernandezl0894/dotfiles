# 02 — Progressive protocol

The course is generated lesson by lesson. This file defines the state machine.

## Statuses

| Status | Meaning |
|---|---|
| `planned` | In `course.yaml` and `TOC.md`, not written. |
| `in-progress` | Being written in the current session. |
| `written` | Lesson file exists and passes mini QA. |
| `reviewed` | Second pass completed. |
| `dropped` | Removed from the plan with a reason. |

Use the same values in `course.yaml`, `TOC.md` and `SEGUIMIENTO.md`.

## Initial setup

The factory creates:

- `course.yaml` with every lesson `planned`.
- `TOC.md` with the complete course and only lesson 1 linked.
- `README.md`, `CURSO.md`, `SEGUIMIENTO.md`.
- Lesson 1 → `written`.

Then it stops.

## Next lesson

`course-lesson-writer`:

1. Reads `course.yaml`, `TOC.md`, `CURSO.md`, `SEGUIMIENTO.md`.
2. Picks the next `planned` lesson with the lowest number, unless the user names one.
3. Checks prerequisites are `written` or `reviewed`.
4. Writes exactly one lesson.
5. Updates status, TOC, README, tracking, glossary, cost.
6. Runs mini QA.
7. Stops and reports the next lesson.

## Batch mode

If the user says “genera las lecciones 2 y 3” or “genera todo”:

- Write one lesson.
- Update tracking.
- Pause and report.
- Ask before continuing.
- Never write more than the user explicitly requested.

## Abandonment

If the user stops:

- Do not generate anything else.
- Leave `course.yaml`, `TOC.md`, `README.md`, `CURSO.md`, `SEGUIMIENTO.md` consistent.
- The course remains useful as a plan plus written lessons.
- No background jobs or automatic continuation.

## Bootstrap mode

When a folder has lessons but no `course.yaml`:

1. Read existing files and infer titles, order and concepts.
2. Create `course.yaml`, `TOC.md`, `README.md`, `CURSO.md`, `SEGUIMIENTO.md`.
3. Preserve existing content; do not overwrite without merging.
4. Mark existing lessons `written`.
5. Stop and report the next planned lesson.

## Handoff message

```text
Lección N lista: lessons/NN-<slug>.md.
Estado: N de M.
Siguiente: lección N+1 — <title>.
Para continuar, pide «genera la lección N+1» o usa course-lesson-writer.
```

## Failure modes

- Writing ahead “to save a turn”: forbidden by default.
- Marking a lesson `written` without the file: forbidden.
- Changing the plan silently: record it in `CURSO.md`, `course.yaml`, `TOC.md` and `SEGUIMIENTO.md`.
- A lesson without exercises: forbidden.
- Skipping prerequisites: warn and ask.
- Mismatched TOC and manifest: blocker.
