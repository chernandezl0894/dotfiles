# 07 — Platform content contract

The course must be importable by a learning platform without manual surgery.

## Required files

```text
<course>/
├── README.md
├── TOC.md
├── course.yaml
├── CURSO.md
├── SEGUIMIENTO.md
└── lessons/
    ├── 01-<slug>.md
    └── ...
```

Optional:

```text
exercises/        # capstone, extra practice, solutions
assets/           # diagrams as code, glossary exports
platform/         # generated manifest for the platform
```

## `course.yaml`

Minimum shape:

```yaml
id: python-fundamentals
title: Fundamentos de Python
description: Curso introductorio de Python para principiantes.
language: es
code_language: python
level: beginner
duration_minutes: 600
version: 1
license: CC-BY-4.0
tags: [python, programming, fundamentals]
authors:
  - name: ...
modules:
  - id: 1
    title: Primeros pasos
    lessons:
      - id: 1
        title: Qué es Python y cómo ejecutarlo
        file: lessons/01-que-es-python.md
        level: beginner
        duration_minutes: 20
        exercises: 3
        status: written
      - id: 2
        title: Variables y tipos
        file: lessons/02-variables-y-tipos.md
        level: beginner
        duration_minutes: 25
        exercises: 3
        status: planned
```

Rules:

- `id` is stable and unique.
- `slug`/file names are kebab-case.
- `language` is the prose language; `code_language` is the snippet language.
- Every lesson has `level`, `duration_minutes`, `exercises` and `status`.
- Do not use tabs; use spaces.
- Keep the YAML simple enough for a human to edit.

## `TOC.md`

Must mirror `course.yaml`:

```markdown
# Tabla de contenido

**Curso:** Fundamentos de Python
**Nivel:** beginner
**Idioma:** español
**Código:** Python 3.12+
**Duración:** ~10 h

## Módulo 1 — Primeros pasos

| # | Lección | Nivel | Duración | Ejercicios | Estado |
|---:|---|---|---:|---:|---|
| 1 | [Qué es Python](./lessons/01-que-es-python.md) | beginner | 20 min | 3 | `written` |
| 2 | Variables y tipos | beginner | 25 min | 3 | `planned` |
```

Rules:

- Link only written lessons.
- Show level, duration, exercise count and status.
- Keep the order identical to `course.yaml`.

## Lesson frontmatter

```yaml
---
title: Variables y tipos
slug: variables-y-tipos
module: 1
module_title: Primeros pasos
lesson: 2
level: beginner
duration_minutes: 25
prerequisites: [1]
learning_objectives:
  - Declarar variables.
  - Usar tipos básicos.
exercises:
  guided: 1
  independent: 1
  challenge: 0
  quiz: 1
tags: [python, basics]
version: 1
---
```

Required keys: `title`, `slug`, `module`, `lesson`, `level`, `duration_minutes`, `learning_objectives`, `exercises`.

## Reading time

Estimate:

- 200 words per minute for prose.
- Add 5–10 minutes for exercises.
- Round to 5 minutes.

Use the estimate in `duration_minutes`.

## Slugs

- Lowercase.
- Kebab-case.
- No accents, spaces or punctuation.
- Unique across the course.
- Stable after publication; if changed, add a redirect/alias in `course.yaml`.

## SEO and platform metadata

Include:

- `title`, `description`, `tags`.
- `level`, `language`, `code_language`.
- `duration_minutes`.
- `version`, `license`.
- `authors`.
- Optional `canonical_url`, `cover` (text only; no images generated).

## Accessibility

- One `#` per lesson.
- Logical heading order.
- Table headers.
- Code blocks with language labels.
- No images without alt text; prefer Mermaid.
- Short paragraphs and clear lists.
- Avoid color-only meaning.

## Versioning

- `version` increments when content changes.
- Record changes in `SEGUIMIENTO.md`.
- Keep lesson slugs stable.
