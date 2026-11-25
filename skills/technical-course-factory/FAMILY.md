# Technical Course Factory — familia de skills

Generador de cursos progresivos y listos para plataforma. El plan completo se crea al inicio; el contenido se escribe lección a lección.

## Skills

| ID | Rol | Cuándo usarla |
|---|---|---|
| `technical-course-factory` | Orquestador | Cuestionario, plan, `course.yaml`, `TOC.md`, README, seguimiento y lección 1. |
| `course-lesson-writer` | Escritor progresivo | Generar la siguiente lección, una por invocación. |
| `course-exercises-builder` | Práctica | Añadir o mejorar ejercicios por lección, quizzes y capstone. |
| `course-extras-builder` | Assets | Glosario, cheatsheet, anti-patterns, apéndices, guía de instructor, perfil. |
| `course-qa-auditor` | Calidad | Auditar TOC, manifest, frontmatter, niveles, ejercicios, enlaces y metadatos. |
| `course-platform-packager` | Exportación | Generar `platform/course.json` y `platform/toc.csv` para importar. |

## Flujo progresivo

```text
1. technical-course-factory
   → preguntas
   → CURSO.md + course.yaml + TOC.md + README.md + SEGUIMIENTO.md
   → lección 1
   → STOP

2. course-lesson-writer
   → lección 2
   → STOP

3. course-lesson-writer
   → lección 3
   → STOP

4. course-exercises-builder
   → ejercicios por lección + quiz + capstone

5. course-extras-builder
   → glosario / cheatsheet / anti-patterns / guía / perfil

6. course-platform-packager
   → platform/course.json + toc.csv

7. course-qa-auditor
   → auditoría y segunda pasada
```

Regla clave: **no se generan lecciones futuras sin pedirlo**. Si se abandona el curso, no se gastan tokens en contenido que nadie va a leer.

## Estructura de un curso

```text
<course>/
├── README.md
├── TOC.md
├── course.yaml
├── CURSO.md
├── SEGUIMIENTO.md
├── lessons/
│   ├── 01-<slug>.md
│   └── 02-<slug>.md
├── ejercicios/        # opcional
├── soluciones/        # opcional
├── apendices/         # opcional
├── evaluacion/        # opcional
└── platform/          # generado por el packager
```

## Cada curso incluye

- Tabla de contenido (`TOC.md`).
- Manifest (`course.yaml`).
- Nivel del curso y nivel por lección.
- Idioma del curso y lenguaje del código.
- Contenido de cada lección.
- Ejercicios prácticos por lección: guiado, independiente, reto y quiz.
- Objetivos, errores comunes, puntos clave y siguiente lección.
- Metadatos de plataforma: slug, duración, tags, versión, licencia.
- Estado y progreso.

## Niveles

`beginner`, `intermediate`, `advanced`, `expert`, `mixed`.

Cada nivel cambia profundidad, ejemplos, pacing y ejercicios. Ver `references/08-levels.md`.

## Lenguajes

- `course_language`: idioma del texto (español por defecto).
- `code_language`: lenguaje del código (Python, Go, TypeScript…).

Adaptadores disponibles:

- Go
- TypeScript/NestJS
- Python
- Plantilla genérica para cualquier otro lenguaje (`stack-adapters/_template.md`).

## Preguntas iniciales

La factory pregunta, en un solo lote:

- Tema, público y nivel.
- Idioma del curso y lenguaje del código.
- Plataforma.
- Módulos y lecciones.
- Prerrequisitos y objetivos.
- Ejercicios por lección.
- Soluciones y evaluación.
- Densidad de código.
- Presupuesto.

Si el usuario dice “confío en tu criterio”, usa defaults y los registra en `CURSO.md`.

## Ejemplos de invocación

- «Crea un curso de fundamentos de Python para principiantes, en español, 10 lecciones.»
- «Crea un curso de DDD con Go, nivel intermedio, con ejercicios por lección.»
- «Genera la lección 3 del curso Python.»
- «Añade quizzes y un capstone al curso Go.»
- «Añade glosario y guía de instructor.»
- «Empaqueta el curso para Moodle.»
- «Audita el curso: TOC, manifest, niveles y ejercicios.»

## Scripts

```sh
python3 scripts/audit_course.py <course-dir>
python3 scripts/check_links.py <course-dir>
python3 scripts/estimate_cost.py <course-dir>
```

Opciones:

```sh
--forbidden php,symfony,doctrine
--no-code
```

## Principios

- Plan completo, contenido progresivo.
- Un curso, una plataforma, un manifest.
- Cada lección tiene práctica.
- Nivel y lenguaje explícitos.
- Scripts para lo mecánico; revisión humana para lo técnico.
- Sin proyectos ni código ejecutable salvo petición.
