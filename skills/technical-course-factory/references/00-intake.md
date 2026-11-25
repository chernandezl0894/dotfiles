# 00 — Intake questionnaire

Ask once, in a short batch, only for what is missing. The goal is to plan a platform-ready course, not to interrogate.

## Critical questions

| # | Question | Default / inference |
|---:|---|---|
| 1 | ¿Qué curso quieres crear? | Required. |
| 2 | ¿Para quién y en qué nivel? | Beginner/intermediate/advanced/expert/mixed. |
| 3 | ¿En qué idioma se imparte? | Español con tuteo. |
| 4 | ¿En qué lenguaje se escribe el código? | Infer from subject; fallback Go. |
| 5 | ¿Para qué plataforma? | Generic Markdown. |
| 6 | ¿Cuántos módulos y lecciones? | 4–6 modules, 12–24 lessons. |
| 7 | ¿Duración por lección? | 15–30 min. |
| 8 | ¿Prerrequisitos? | Infer; ask if ambiguous. |
| 9 | ¿Qué debe poder hacer el alumno al final? | 4–8 outcomes. |
| 10 | ¿Qué ejercicios por lección? | 1 guided + 1 independent + 1 quiz. |
| 11 | ¿Soluciones? | Separate folder, optional. |
| 12 | ¿Evaluación? | Quizzes + capstone optional. |
| 13 | ¿Densidad de código? | Minimal snippets. |
| 14 | ¿Presupuesto? | Ask; record estimate. |

Optional: tone, branding, SEO, accessibility, license, tagging, instructor guide.

## Inference rules

- If the subject is a language or framework (Python, Go, Rust, React…), that is the **code language** and the **stack**.
- If the subject is architecture/DDD, default to Go but ask.
- If the level is not stated:
  - “fundamentos”, “desde cero”, “introducción” → `beginner`.
  - “avanzado”, “arquitectura”, “patrones” → `advanced`.
  - Otherwise → `intermediate`.
- If the platform is not stated, use generic Markdown with `course.yaml` and `TOC.md`.
- If the user says “sin código”, set `code_density: none`.
- If the user says “barato”, prefer minimal snippets and fewer lessons.
- If the user asks for “contenido para una plataforma”, require `course.yaml`, `TOC.md` and lesson frontmatter.

## Contract block for CURSO.md

```markdown
## Contrato

- **Título:** …
- **Público:** …
- **Nivel:** beginner | intermediate | advanced | expert | mixed
- **Idioma del curso:** Español, tuteo.
- **Lenguaje del código:** Python 3.12+
- **Plataforma:** Markdown genérico / Moodle / Teachable / otra.
- **Módulos:** …
- **Lecciones:** …
- **Duración:** … min por lección; … total.
- **Prerrequisitos:** …
- **Objetivos:** …
- **No objetivos:** …
- **Densidad de código:** none | minimal | full.
- **Ejercicios por lección:** guided, independent, challenge, quiz.
- **Soluciones:** no | carpeta separada | al final.
- **Evaluación:** quizzes | capstone | ambos | ninguna.
- **Presupuesto:** …
- **Fuente:** …
- **Carpeta:** …
```

## Level

See `references/08-levels.md`. Record the course level and, if mixed, the level per lesson.

## Language

Two separate values:

- **course language**: the language of the prose (Spanish by default).
- **code language**: the language of snippets (Python, Go, TypeScript…).

Never confuse them. A Spanish course about Python has `course_language: es` and `code_language: python`.

## Platform

See `references/07-platform-contract.md`. Minimum platform output:

- `course.yaml`
- `TOC.md`
- `README.md`
- lessons with YAML frontmatter
- exercises per lesson
- statuses and version

## Assumptions

Record:

- Versions of the language/framework.
- Libraries used in examples.
- Whether snippets are illustrative or runnable.
- Whether solutions are included.
- Whether exercises are auto-gradable.

Assumptions are acceptable; hidden assumptions are not.
