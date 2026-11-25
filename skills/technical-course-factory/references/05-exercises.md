# 05 — Exercises and assessment

Exercises are part of every lesson, not an optional appendix.

## Per-lesson exercise set

| Type | Purpose | Required |
|---|---|---|
| Guided | Practice with steps and expected result. | Beginner/intermediate |
| Independent | Goal and constraints, no steps. | All levels |
| Challenge | Open-ended or harder. | Intermediate+ |
| Quiz | Check recall, prediction, debugging. | All levels |

Adjust per `references/08-levels.md`.

## Exercise design

- Map each exercise to a learning objective.
- Use realistic contexts.
- State input, expected output and constraints.
- Include at least one edge case or sad path.
- Provide acceptance criteria.
- For open-ended work, provide a rubric.
- Keep the exercise doable in the lesson or as homework.

## Exercise block in a lesson

```markdown
## Ejercicios prácticos

### Guiado — <title>
1. …
2. …
Resultado esperado: …

### Independiente — <title>
Objetivo: …
Restricciones: …
Criterios de aceptación: …

### Reto — <title> (opcional)
…

### Quiz
1. …
   - a) …
   - b) …
   - c) …
Respuesta: …
Explicación: …
```

No code is required in the exercise statement. If code density allows, include a small starter snippet, but not a full project.

## Capstone

Optional, for intermediate+ or multi-module courses:

- Real context.
- Integrates several modules.
- Acceptance criteria and rubric.
- Failure scenarios.
- Documentation/retrospective.

## Solutions

- Default: separate `soluciones/` folder, not linked from the lesson.
- Optional: end of lesson, clearly marked.
- Always verify solutions.
- Do not include solutions in the main content by default.

## Pack-level artifacts

`course-exercises-builder` may create:

- `ejercicios/README.md` (index, rubric, method).
- Extra practice files.
- Capstone.
- Solutions folder (optional).

## Quality checklist

- [ ] Every lesson has guided/independent/quiz (or level equivalent).
- [ ] Exercises map to objectives.
- [ ] At least one edge case.
- [ ] Acceptance criteria.
- [ ] Rubric for open-ended work.
- [ ] Quiz answers/explanations.
- [ ] No untaught concepts.
- [ ] No code/project unless requested.
