# Language adapter template

Use this file to create an adapter for any language or framework. Keep it short and concrete.

## Stack

- **Language/framework:**
- **Typical version:**
- **Package manager:**
- **Runtime:**

## Structure

```text
<project structure>
```

## Idioms

- How to model data (structs/classes/dataclasses…).
- How to express behavior.
- How to handle errors.
- How to manage state.
- How to write tests.
- How to handle concurrency, if relevant.

## Tooling

- Formatter.
- Linter.
- Test runner.
- Build/package.
- Type checker, if any.

## Common libraries

| Need | Option |
|---|---|
| HTTP | … |
| Persistence | … |
| Testing | … |
| CLI | … |
| Config | … |

## Anti-patterns

- Literal translations from other languages.
- Over-abstraction.
- Framework leakage into the domain.
- Global state.
- Ignoring the language’s error model.

## Level notes

- Beginner: setup, first program, small exercises.
- Intermediate: testing, project structure, error handling.
- Advanced: performance, concurrency, design.
- Expert: production, observability, tradeoffs.

## Review checklist

- [ ] Snippets are idiomatic.
- [ ] Versions/libraries are current or marked.
- [ ] Tests use the language’s standard tooling.
- [ ] No project scaffolding in the course.
- [ ] Level-appropriate examples.
