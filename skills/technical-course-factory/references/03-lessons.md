# 03 — Lesson rules

A lesson is a self-contained learning unit for a platform: one idea, one outcome, practice, and a clear next step.

## Lesson template

1. YAML frontmatter.
2. Title and metadata.
3. Learning objectives (3–5).
4. Why it matters.
5. Prerequisites / recap.
6. Content sections.
7. Worked example(s).
8. Common mistakes / misconceptions.
9. `## Ejercicios prácticos`:
   - Guided.
   - Independent.
   - Challenge (optional).
   - Quiz (3–5 questions).
10. Key takeaways.
11. Next lesson.
12. Optional solutions link.

## Frontmatter

```yaml
---
title: Variables y tipos
slug: variables-y-tipos
module: 1
module_title: Primeros pasos
lesson: 1
level: beginner
duration_minutes: 25
prerequisites: []
learning_objectives:
  - Declarar variables con tipos básicos.
  - Predecir el resultado de una operación.
exercises:
  guided: 1
  independent: 1
  challenge: 0
  quiz: 1
tags: [python, basics]
version: 1
---
```

Rules:

- `slug` is unique, lowercase kebab-case, no accents.
- `level` is one of the course levels.
- `duration_minutes` is realistic.
- `exercises` counts must match the body.
- `tags` are short and platform-friendly.

## Content rules by level

| Level | Depth | Examples | Exercises |
|---|---|---|---|
| Beginner | Definitions, setup, one step at a time | Many small examples, expected output | Guided + independent + quiz |
| Intermediate | Problem, options, tradeoffs | One realistic example | Independent + challenge + quiz |
| Advanced | Edge cases, performance, design | Production-like example | Challenge + critique + quiz |
| Expert | Research, architecture, incidents | Case study | Design/critique + capstone |
| Mixed | Base level + optional stretch | Base + stretch | Base + optional challenge |

## Code density

| Mode | Allows |
|---|---|
| `none` | No code fences except Mermaid. |
| `minimal` | 1–3 snippets, 10–30 lines, illustrative. |
| `full` | Larger examples, tests, wiring; still no project unless requested. |

Never switch modes without recording it in `CURSO.md` and `course.yaml`.

## Exercises per lesson

Each lesson has at least:

- 1 **guided** exercise: step-by-step, with expected outcome.
- 1 **independent** exercise: only the goal and constraints.
- 1 **quiz**: 3–5 questions with answers/explanations.

Optional:

- 1 **challenge**: harder, open-ended.
- 1 **project** for advanced/expert.

Exercises must be practical, not trivia. They should be doable in the lesson’s time or as homework.

## Common mistakes

Include 2–4 level-appropriate misconceptions:

- Beginner: syntax, types, indentation, scope.
- Intermediate: abstractions, error handling, testing.
- Advanced: concurrency, performance, design coupling.
- Expert: tradeoffs, operability, failure modes.

## Diagrams

- Mermaid only.
- At most one diagram per lesson unless necessary.
- Use the Ubiquitous Language or the lesson vocabulary.
- No images or screenshots.

## Self-check before marking `written`

- [ ] Frontmatter complete.
- [ ] Objectives observable.
- [ ] Content matches the level.
- [ ] Snippet is minimal and idiomatic.
- [ ] Guided, independent and quiz exercises exist.
- [ ] Answers or rubric for the quiz.
- [ ] Common mistakes included.
- [ ] Key takeaways.
- [ ] Next lesson link.
- [ ] No forbidden stack references.
- [ ] No project scaffolding.
