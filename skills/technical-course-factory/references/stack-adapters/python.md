# Stack adapter — Python

Default adapter for Python fundamentals and backend courses.

## Versions and tools

- Python 3.12+ (or the version the course declares).
- `venv` + `pip`, or `uv` if the user prefers.
- Formatter/linter: `ruff` (format + lint).
- Tests: `pytest`.
- Type hints: use them; `mypy` or `pyright` if the course includes typing.
- Packaging: `pyproject.toml`; no `setup.py` unless the course is legacy.

## Structure

```text
project/
├── pyproject.toml
├── src/
│   └── package/
│       ├── __init__.py
│       └── module.py
├── tests/
│   └── test_module.py
└── README.md
```

For teaching, a single-file script is fine at the beginning. Introduce packages when the lesson needs them.

## Idioms

- Variables and dynamic typing; explain type hints as documentation and checking.
- Functions are first-class; prefer small functions.
- Use `dataclasses` for data containers when behavior is light.
- Use classes when state and behavior belong together.
- Exceptions for errors; `raise` and `except` with specific types.
- `with` for resources.
- Comprehensions for simple transformations; loops for clarity.
- Generators for lazy sequences.
- `pathlib` for file paths.
- Avoid mutable default arguments.
- Avoid bare `except`.
- Follow PEP 8; use `ruff`.

## Teaching sequence for fundamentals

1. What Python is; install and REPL.
2. Variables and types.
3. Operators and strings.
4. Conditionals.
5. Loops.
6. Functions.
7. Lists, tuples, dictionaries, sets.
8. Modules and packages.
9. Files and exceptions.
10. Classes and dataclasses.
11. Tests with `pytest`.
12. Small project.

Adjust to the course duration.

## Common learner mistakes

- Indentation errors.
- `=` vs `==`.
- Mutable default arguments.
- Modifying a list while iterating.
- Confusing `is` and `==`.
- Shadowing built-ins.
- Ignoring exceptions.
- Off-by-one in ranges.
- Integer/float division.

## Exercises

- Beginner: predict output, fix a bug, write a small function.
- Intermediate: refactor, test, parse a file, use a library.
- Advanced: concurrency, performance, packaging, typing.
- Expert: architecture, plugin systems, async, production concerns.

## Anti-patterns to avoid in the course

- “Python is pseudocode” without explaining semantics.
- Teaching classes before functions and data.
- Using `eval` or `exec` in examples.
- Huge scripts with no functions.
- Ignoring `pytest`.
- Mixing tabs and spaces.
- Using deprecated libraries.

## Review checklist

- [ ] Version is stated.
- [ ] `venv`/install instructions are current.
- [ ] Snippets are PEP 8-ish and idiomatic.
- [ ] Exercises have expected output.
- [ ] Tests use `pytest`.
- [ ] No project scaffolding unless requested.
- [ ] Level-appropriate pacing.
