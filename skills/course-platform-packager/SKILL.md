---
name: Course Platform Packager
description: Normalize a platform-ready course into a machine-readable manifest for import: slugs, order, lessons, levels, durations, exercise counts, tags, SEO, version and license. Use when the user asks to package, export, publish or prepare a course for a learning platform.
---

# Course Platform Packager

## Mission

Turn a course folder into a clean platform manifest without changing the lesson content.

Input:

- `course.yaml`
- `TOC.md`
- `lessons/*.md` with frontmatter
- optional `README.md`, `CURSO.md`, `SEGUIMIENTO.md`

Output:

- `platform/course.json` (normalized manifest).
- Optional `platform/toc.csv`.
- A short import report.

## Read first

1. `course.yaml`, `TOC.md`, lesson frontmatter.
2. `~/.config/opencode/skills/technical-course-factory/references/07-platform-contract.md`.
3. `~/.config/opencode/skills/technical-course-factory/references/04-quality.md`.

## Workflow

1. **Validate**
   - Required files exist.
   - TOC and manifest agree.
   - Slugs are unique and kebab-case.
   - Lesson order is continuous.
   - Every lesson has frontmatter.

2. **Normalize**
   - Course: id, title, description, language, code_language, level, duration, tags, version, license, authors.
   - Modules: id, title, order.
   - Lessons: id, slug, title, module, order, level, duration, exercises, status, file, tags.
   - SEO: title, description, canonical slug.
   - Reading time.

3. **Write `platform/course.json`**
   - Stable shape.
   - UTF-8.
   - No content changes.

4. **Write `platform/toc.csv`**
   - Columns: module, lesson, title, level, duration, exercises, status, file.

5. **Report**
   - Files generated.
   - Warnings: missing metadata, duplicate slugs, planned lessons without files.
   - Whether the course is importable.

## Manifest shape

```json
{
  "id": "course-id",
  "title": "Course title",
  "description": "...",
  "language": "es",
  "code_language": "python",
  "level": "beginner",
  "duration_minutes": 600,
  "version": 1,
  "license": "CC-BY-4.0",
  "tags": ["python"],
  "modules": [
    {
      "id": 1,
      "title": "Module",
      "lessons": [
        {
          "id": 1,
          "slug": "lesson-slug",
          "title": "Lesson",
          "file": "lessons/01-lesson.md",
          "level": "beginner",
          "duration_minutes": 20,
          "exercises": 3,
          "status": "written"
        }
      ]
    }
  ]
}
```

## Rules

- Do not generate lesson content.
- Do not change slugs silently.
- Do not include planned lessons as published content; mark status.
- Keep the manifest deterministic (stable ordering).
- No images, no binary assets.

## Final message

```text
Manifest: platform/course.json
TOC: platform/toc.csv
Lecciones: N escritas, M planificadas.
Importable: sí/no.
Warnings: …
```
