# 06 — Course assets

Assets make the course usable after reading and easier to operate on a platform. They are not chapters.

## Asset catalog

| Asset | Purpose |
|---|---|
| `TOC.md` | Table of contents and progress. |
| `course.yaml` | Platform manifest. |
| Glossary | Terms and definitions. |
| Cheatsheet | One-page reference. |
| Anti-patterns | Common mistakes and fixes. |
| Appendices | Deep dives on specific topics. |
| Instructor guide | How to teach, timing, common questions. |
| Assessment pack | Quizzes, rubrics, capstone, solutions. |
| Technical profile | Role, levels, skills, interviews, portfolio. |
| Platform manifest | Normalized JSON for import. |

## Cheatsheet

- Definitions.
- Concept → syntax/idiom mapping.
- “Where does this go?” table.
- Rules/checklists.
- Review questions.
- Heuristics.
- 1–2 pages, no code unless necessary.

## Glossary

- Term, definition, lesson reference.
- One entry per term.
- Use the course language; keep technical terms in English when appropriate.
- Link terms from lessons.

## Anti-patterns

- 12–17 entries.
- Symptoms, why it hurts, detect, fix, lesson reference.
- Smell → anti-pattern table.
- “When not to use this” section.

## Appendices

Choose only what the course needs:

- Deep dive into a hard concept.
- Tooling/setup.
- Testing strategy.
- Performance.
- Security.
- Deployment.
- Migration guide.

Each appendix: purpose, when to use, step-by-step, checklist, common mistakes, exercise.

## Instructor guide

- Audience and level.
- Lesson timing.
- Prerequisites.
- Common questions and answers.
- Common learner mistakes.
- Suggested live demos.
- Homework and assessment.
- Accessibility notes.

## Assessment pack

- Quiz bank with answers.
- Exercise solutions (separate).
- Rubrics.
- Capstone brief.
- Grading guide.

## Technical profile

Only when relevant (career-oriented course):

- Role and levels.
- Skills matrix.
- Idiom and domain checklists.
- Interview questions.
- Portfolio projects.
- 90-day plan.
- Tools and reading.

## Platform manifest

Use `course-platform-packager` to generate `platform/course.json` from `course.yaml`, `TOC.md` and lesson frontmatter. It normalizes slugs, order, durations, exercise counts, tags and SEO.

## Update tracking

- Link assets from `README.md`.
- Add to `course.yaml`/`CURSO.md`.
- Add a session row and cost to `SEGUIMIENTO.md`.

## Quality checklist

- [ ] Asset is relevant to the level and language.
- [ ] No duplication of lessons.
- [ ] No code/project unless requested.
- [ ] Links work.
- [ ] README and tracking updated.
- [ ] Platform metadata is complete.
