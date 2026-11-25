# 01 — Course blueprint

`CURSO.md` is the human plan; `course.yaml` is the machine manifest; `TOC.md` is the visible table of contents. All three must agree.

## Steps

1. **Analyze the subject/source**: concepts, prerequisites, dependencies.
2. **Define outcomes**: 4–8 things the learner can do.
3. **Define level**: beginner, intermediate, advanced, expert or mixed.
4. **Choose the language pair**: course language and code language.
5. **Plan modules**: 3–6 modules with a shared goal.
6. **Plan lessons**: 2–6 lessons per module, 15–30 minutes each.
7. **Order by prerequisites**.
8. **Choose a running example** for project-based courses.
9. **Plan exercises per lesson**: guided, independent, challenge, quiz.
10. **Plan assessment**: quizzes, capstone, both or none.
11. **Plan platform metadata**: slug, tags, duration, version, license, SEO.
12. **Estimate cost**.
13. **Write `CURSO.md`**, `course.yaml`, `TOC.md`, `README.md`, `SEGUIMIENTO.md`.
14. **Write lesson 1 only**.

## Module rules

- A module has a clear outcome and 2–6 lessons.
- Lessons are independent enough to be consumed on a platform, but ordered.
- Do not create a module that is only a glossary.
- A lesson teaches one main idea.
- If a lesson exceeds 45 minutes, split it.
- If a lesson is under 8 minutes, merge it or add practice.

## Lesson numbering

- Stable IDs: `01`, `02`, … across the course, not per module.
- File names: `lessons/01-<slug>.md`.
- Slugs: lowercase kebab-case, unique, no accents.
- Module membership lives in frontmatter and TOC.

## Level design

| Level | Assumes | Lesson shape | Exercises |
|---|---|---|---|
| Beginner | Nothing | Setup, definitions, worked example, small steps | Guided + independent + quiz |
| Intermediate | Basics | Problem, options, tradeoffs, example | Independent + challenge + quiz |
| Advanced | Experience | Deep dive, edge cases, performance, design | Challenge + project + quiz |
| Expert | Production experience | Research, tradeoffs, architecture, incident analysis | Design/critique + capstone |
| Mixed | Defined per lesson | Base level plus optional stretch | Base + optional challenge |

See `references/08-levels.md`.

## Language design

- `course_language`: prose language (es by default).
- `code_language`: language of examples (Python, Go, TypeScript…).
- If the course teaches a language, that language is the code language.
- If no adapter exists, use `stack-adapters/_template.md` and record assumptions.

## Running example

For project-based courses, record:

- Domain and modules.
- Main concepts reused.
- Naming conventions.
- What changes between lessons.

For fundamentals courses, the “running example” can be a small script or a set of exercises that grow across lessons.

## Exercise plan

For each lesson, define:

- 1 guided exercise.
- 1 independent exercise.
- 1 optional challenge.
- 1 quiz (3–5 questions).

For advanced/expert, replace the guided exercise with a critique or design task.

## Assessment plan

- Formative: exercises and quizzes per lesson.
- Summative: module quiz or capstone.
- Rubrics for open-ended work.
- Solutions separate if included.

See `references/10-assessment.md`.

## Platform plan

`course.yaml` must include:

- `id`, `title`, `description`, `language`, `code_language`, `level`, `duration_minutes`, `version`, `license`, `tags`.
- `modules` with lessons, files, levels, durations and exercise counts.

`TOC.md` must mirror it. See `references/07-platform-contract.md`.

## Cost estimate

- Words per lesson × tokens factor.
- Add exercises and quizzes.
- Record rate and currency.
- Keep a ceiling. If exceeded, reduce lessons or code density.

## `CURSO.md` checklist

- [ ] Contract complete.
- [ ] Level and language pair.
- [ ] Outcomes and non-goals.
- [ ] Modules and lessons table.
- [ ] Prerequisites in order.
- [ ] Exercise plan per lesson.
- [ ] Assessment plan.
- [ ] Platform metadata.
- [ ] Running example.
- [ ] Glossary seed.
- [ ] Assumptions.
- [ ] Next step.
