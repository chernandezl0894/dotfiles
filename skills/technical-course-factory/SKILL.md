---
name: Technical Course Factory
description: Generate platform-ready technical courses in Spanish (Go or the subject language) with an initial questionnaire, course.yaml manifest, TOC.md, README, tracking, and lesson 1 only. Use when creating a course for a learning platform, adapting a source course, or generating lessons progressively on demand.
---

# Technical Course Factory

## Mission

Turn a subject, a source course, or a rough idea into a **platform-ready, progressive course** with:

- A course manifest (`course.yaml`).
- A human-readable table of contents (`TOC.md`).
- A public guide (`README.md`).
- A decision log (`SEGUIMIENTO.md`).
- A curriculum plan (`CURSO.md`).
- Lesson 1 only.

The factory plans the whole course but writes **one lesson** and stops. Later lessons are generated on demand. If the course is abandoned, no further tokens are spent.

## Ask first

Read `references/00-intake.md`. Ask only for missing **critical** data, in one short batch:

1. Subject and course title.
2. Audience and level: beginner, intermediate, advanced, expert or mixed.
3. Course language (default Spanish).
4. Code language (infer from the subject; default Go if unclear).
5. Platform target: generic Markdown, Moodle, Teachable, custom, other.
6. Modules and lessons: approximate count and lesson duration.
7. Prerequisites and learning outcomes.
8. Exercises per lesson: guided, independent, challenge, quiz.
9. Solutions: none, separate folder, or at the end of the lesson.
10. Assessment: quizzes, capstone, both or none.
11. Code density: none, minimal snippets, full code.
12. Budget/ceiling and whether cost matters.

If the user says “confío en tu criterio”, choose defaults, record them in `CURSO.md`, and proceed.

## Platform contract

Every course must have:

```text
<course>/
├── README.md
├── TOC.md
├── course.yaml
├── CURSO.md
├── SEGUIMIENTO.md
└── lessons/
    └── 01-<slug>.md
```

`course.yaml` is the machine-readable manifest. `TOC.md` is the human table of contents. Every lesson has YAML frontmatter with level, duration, objectives and exercise counts. See `references/07-platform-contract.md`.

## Course anatomy

- **Course**: metadata, level, language, code language, duration, tags, license, version.
- **Module**: a group of lessons with a shared goal.
- **Lesson**: one learning unit, 10–45 minutes, with objectives, content, examples, exercises and a quiz.
- **Exercise**: guided, independent, challenge or quiz. At least one per lesson.
- **Capstone** (optional): integrates several modules.

Default structure: flat lessons under `lessons/`, grouped by `module` metadata and TOC headings. Nested module folders are optional for large courses.

## Lesson anatomy

Every lesson includes:

1. YAML frontmatter: title, slug, module, lesson, level, duration, prerequisites, objectives, exercise counts, tags, version.
2. Learning objectives (3–5).
3. Why it matters.
4. Content sections with examples.
5. Common mistakes / misconceptions.
6. `## Ejercicios prácticos`: guided, independent, challenge (optional), quiz.
7. Key takeaways.
8. Next lesson.
9. Optional solutions link.

See `references/03-lessons.md` and `templates/lesson.template.md`.

## Defaults

- Course language: Spanish with tuteo.
- Technical terms: keep in English when the subject uses them.
- Code language: infer from the subject; fallback Go.
- Level: infer from the subject; fallback beginner for language fundamentals, intermediate for architecture.
- Lesson duration: 15–30 minutes.
- Exercises: 1 guided + 1 independent + 1 quiz; challenge optional.
- Solutions: separate folder, optional.
- Code density: minimal snippets (10–30 lines), no projects.
- Diagrams: Mermaid only.
- No images, videos, or screenshots.
- Source material: read-only.
- Output: a new folder under the workspace unless a path is given.

## Workflow

### 1. Inspect

- If `course.yaml` or `CURSO.md` exists, do not start over. Report status and route to `course-lesson-writer` or `course-qa-auditor`.
- If lessons or `SEGUIMIENTO.md` exist but `course.yaml` does not, enter **bootstrap mode**: infer the plan, preserve existing content, mark lessons as `Escrito`.
- If the folder is empty, create from scratch.

### 2. Plan the course

Use `templates/CURSO.template.md` and `references/01-blueprint.md`.

Include:

- Contract: audience, level, outcomes, non-goals, prerequisites, languages, platform, code density, duration, budget.
- Course map: modules, lessons, order, prerequisites.
- Running example (if the course is project-based).
- Exercise and assessment plan.
- Platform metadata plan.
- Glossary seed.
- Assumptions.

### 3. Create `course.yaml`

Use `templates/course.yaml.template`. It must list modules, lessons, files, levels, durations and exercise counts.

### 4. Create `TOC.md`

Use `templates/TOC.template.md`. Show the complete course, lesson level, duration, exercises and status. Link only written lessons.

### 5. Create `README.md`

Use `templates/README.template.md`. It is the public landing page: pitch, audience, level, prerequisites, outcomes, TOC, how to continue, conventions.

### 6. Create `SEGUIMIENTO.md`

Use `templates/SEGUIMIENTO.template.md`. Decisions, conventions, progress, sessions, glossary, doubts, cost.

### 7. Write lesson 1 only

Use `templates/lesson.template.md`, `references/03-lessons.md`, `references/08-levels.md`, `references/09-pedagogy.md` and the language adapter.

Rules:

- Respect level and code density.
- Include practical exercises and a quiz.
- Use the running example if the plan defines one.
- Do not write future lessons.

### 8. Update tracking

- `course.yaml`: lesson 1 → `written`.
- `TOC.md`: status and link.
- `README.md`: progress.
- `SEGUIMIENTO.md`: progress, session, glossary, cost.

### 9. Mini QA

```sh
python3 ~/.config/opencode/skills/technical-course-factory/scripts/audit_course.py <course-dir>
```

Fix blockers: missing files, broken links, odd fences, TOC/lesson mismatch, missing metadata, missing exercises.

### 10. Stop and hand off

Report:

- What was created.
- Lesson 1 path and what it covers.
- Next lesson.
- Exact instruction to continue: “pide la lección 2” or use `course-lesson-writer`.
- Reminder: no future lessons until requested.

## Deliverables at this stage

```text
<course>/
├── README.md
├── TOC.md
├── course.yaml
├── CURSO.md
├── SEGUIMIENTO.md
└── lessons/
    └── 01-<slug>.md
```

No exercises folder, extras, or later lessons yet. Those are separate skills.

## Family

- `course-lesson-writer` — next lesson.
- `course-exercises-builder` — per-lesson exercises and capstone.
- `course-extras-builder` — glossary, cheatsheet, anti-patterns, guide, profile.
- `course-platform-packager` — `platform/course.json` and `toc.csv`.
- `course-qa-auditor` — structural and consistency audit.

## Reference map

- `references/00-intake.md` — initial questionnaire and defaults.
- `references/01-blueprint.md` — course map, modules, lessons, levels.
- `references/02-progressive.md` — statuses and next-lesson protocol.
- `references/03-lessons.md` — lesson rules and exercises.
- `references/04-quality.md` — QA gates.
- `references/05-exercises.md` — exercise taxonomy.
- `references/06-extras.md` — cheatsheet, glossary, instructor guide, profile.
- `references/07-platform-contract.md` — `course.yaml`, TOC, frontmatter, slugs.
- `references/08-levels.md` — beginner/intermediate/advanced/expert.
- `references/09-pedagogy.md` — objectives, examples, retrieval, misconceptions.
- `references/10-assessment.md` — quizzes, rubrics, solutions, capstones.
- `references/stack-adapters/go.md` — Go defaults.
- `references/stack-adapters/typescript-nestjs.md` — TypeScript/NestJS.
- `references/stack-adapters/python.md` — Python.
- `references/stack-adapters/_template.md` — generic adapter for any language.
- `templates/` — course.yaml, TOC, README, CURSO, SEGUIMIENTO, lesson, exercise.

## Stop conditions

Ask before:

- Overwriting an existing course.
- Writing outside the requested folder.
- Creating code, projects, migrations or Docker files.
- Adding future lessons by default.
- Expanding scope beyond the approved plan.
- Exceeding the budget.
- Inventing APIs, versions or facts you cannot verify.
- Deleting or rewriting existing lessons.

## Hard rules

- Source is read-only.
- No literal translations: adapt idioms and level.
- Every lesson has at least one practical exercise.
- Every course has a TOC and a manifest.
- No future lessons by default.
- Keep `course.yaml`, `TOC.md`, `README.md`, `CURSO.md` and `SEGUIMIENTO.md` in sync.
- If a fact is uncertain, mark it as an assumption.
- If the user asks for “all”, checkpoint after each lesson.
