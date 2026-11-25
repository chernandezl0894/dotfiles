---
name: pdf-to-markdown
description: Convierte PDFs (libros, manuales, papers) a Markdown dividido por capítulos con un README índice que enlaza cada archivo, y entrega resumen corto, tabla de capítulos, reporte de calidad y sugerencias. Úsalo cuando el usuario pida convertir, digitalizar, extraer, resumir o separar un PDF por capítulos, montar una biblioteca en Markdown para Obsidian/RAG, o pasar un libro a texto. English triggers: convert PDF to markdown, split PDF by chapters, summarize a PDF book.
---

# PDF to Markdown

## Misión

Convertir uno o varios PDFs en una carpeta Markdown navegable:

- Un archivo por capítulo (`01-....md`, `02-....md`, …).
- `README.md` como índice con enlaces relativos a cada archivo.
- `metadata.json` (contrato para máquinas), `digest.md` (extracto barato) y `report.md` (calidad).
- Un informe para el usuario: resumen corto, tabla de capítulos, sugerencias y avisos.

El trabajo pesado lo hace un script determinista. Tú pones el criterio: interpretas el
digest, verificas y redactas. **Nunca resumes desde tu conocimiento previo del libro.**

## Ruta y motor

```bash
SKILL="$HOME/.config/opencode/skills/pdf-to-markdown"
uv run --script "$SKILL/scripts/pdf2md.py" --version
```

- Dependencias declaradas inline (PEP 723): `uv` las instala una vez en su caché. No instales nada global ni crees venv.
- Si `uv` no existe, dilo y detente; no intentes improvisar con `pdftotext`.
- El script no usa red, no llama a modelos y no modifica el PDF original.

## Reglas no negociables

1. **Analiza antes de convertir.** Ejecuta siempre `--analyze` primero y muestra qué detectó.
2. **Confianza baja = confirmar con el usuario.** Con `alta` puedes continuar; con `media` avisa; con `baja` explica el fallback y pide aprobación o un `--split` distinto.
3. **Un libro, una carpeta.** No mezcles libros ni reutilices una carpeta con otra conversión.
4. **No rellenes huecos.** Si el digest no contiene información, di que no está en el texto.
5. **PDF escaneado = parar y ofrecer OCR.** Nunca entregues Markdown vacío como si fuera éxito.
6. **Verifica con `--verify`.** No declares terminado sin que pase.
7. **No edites archivos generados** salvo que el usuario lo pida y lo justifique; si lo haces, dilo.

## Flujo obligatorio

### Paso 1 — Contexto (una sola pregunta si falta algo)

Necesitas: ruta(s) del PDF y la raíz de la biblioteca. **Convención por defecto: `~/library`**
con `pdf/`, `md/`, `notes/`, `INDEX.md` y `PLAN.md`. Con `--library ~/library` la salida va
sola a `md/<slug>/` y el libro se añade a `INDEX.md` (sin `--catalog` explícito). Si el
usuario ya dio la ruta, no preguntes lo demás: usa el valor por defecto y sigue.

### Paso 2 — Analizar

```bash
uv run --script "$SKILL/scripts/pdf2md.py" "/ruta/libro.pdf" --analyze --json 2>/dev/null
```

Presenta al usuario, en 5-8 líneas: páginas, título/autor detectados, método de división,
confianza, número de capítulos y avisos. Si hay avisos de OCR o confianza baja, decide con
el usuario antes de escribir. Para ajustar el método:

| Situación | Comando |
| --- | --- |
| El PDF trae bookmarks y quieres forzarlos | `--split outline` |
| Sin bookmarks pero con índice impreso | `--split toc` |
| Solo hay encabezados visuales | `--split headings` |
| Nada funciona | `--split pages --chunk 20` |

### Paso 3 — Convertir

```bash
uv run --script "$SKILL/scripts/pdf2md.py" "/ruta/libro.pdf" --library "$HOME/library"
```

Salida: `$HOME/library/md/<slug>/` y fila nueva en `$HOME/library/INDEX.md`.
`--force` solo para reconvertir algo ya existente y avisando. `--pending` lista los PDFs
de `pdf/` que aún no tienen Markdown (el backlog real).

**Formato del texto (automático).** El script deja un párrafo por línea, listas compactas y
elimina encabezados/pies corridos; no toca código, tablas, headings ni frontmatter. Para
normalizar conversiones antiguas sin releer el PDF:

```bash
uv run --script "$SKILL/scripts/pdf2md.py" --reflow "$HOME/library/md"
```

Es idempotente, tarda ~1 s por libro y no consume tokens. Se salta `99-back-matter.md`
(el índice analítico debe conservar una entrada por línea).

### Paso 4 — Verificar

```bash
uv run --script "$SKILL/scripts/pdf2md.py" --verify "/ruta/salida"
```

Debe imprimir `OK ... páginas cubiertas`. Si falla, corrige (normalmente `--force` con otro
`--split`) o reporta el fallo con honestidad.

### Paso 5 — Entregar

Lee **solo** `digest.md` y `metadata.json` (y `report.md` para los avisos). No abras los
capítulos uno a uno salvo que el usuario pida análisis profundo de una sección concreta.

Usa exactamente esta estructura:

```markdown
## Resultado
- **Libro:** Título — Autor
- **Salida:** `/ruta/salida`
- **Estructura:** N capítulos · P páginas · ~X palabras
- **División:** método (confianza) — una frase de por qué

## Resumen
Máximo 150 palabras. Qué es el libro, para quién, qué problema resuelve y qué enfoque usa.
Sin adjetivos de marketing y sin inventar contenido que no esté en el digest.

## Capítulos
| # | Capítulo | Páginas | De qué trata |
| --- | --- | --- | --- |
| 01 | Título real | 9-30 | Una línea basada en el extracto |

## Sugerencias
- Por dónde empezar y por qué.
- 2-4 capítulos clave para el objetivo probable del usuario.
- Qué se puede saltar o usar solo como referencia.
- Huecos o problemas del texto (páginas sin texto, tablas rotas, capítulos desbalanceados).

## Calidad de la conversión
- Método y confianza.
- Avisos de `report.md` y resultado de `--verify`.
- Páginas problemáticas o material no convertido (imágenes, tablas, fórmulas).

## Recomendaciones siguientes
1-3 acciones concretas: aplicar OCR, dividir un capítulo, generar embeddings, enlazar con
notas existentes, convertir otra edición, etc.
```

Si son varios PDFs, repite el bloque por libro y cierra con una tabla comparativa.

## Casos especiales

**PDF escaneado** (`report.md` avisa de páginas sin texto o `stats.pages_without_text` es alto):
detente y ofrece:

```bash
sudo apt install ocrmypdf tesseract-ocr tesseract-ocr-spa
ocrmypdf --language spa --deskew --clean libro.pdf libro-ocr.pdf
```

Después reconvierte el PDF con OCR. No prometas calidad sin OCR.

**Confianza baja o capítulos absurdos** (1 capítulo, o 80 de 3 páginas): propone
`--split pages --chunk 15` como red de seguridad, o revisa el índice impreso con el usuario.

**Libro muy grande (>600 páginas):** avisa del tiempo; el digest sigue siendo barato, pero
`--analyze` y la conversión tardan. Ofrece convertir solo un rango si el usuario lo pide
(no hay flag de rango: convierte el libro completo o extrae páginas antes con `qpdf`).

**El usuario solo quiere el resumen, no los archivos:** ejecuta igual el pipeline (es la
fuente de verdad) y entrega el resumen; menciona dónde quedó la carpeta.

## Contrato de salida

```
<salida>/
├── README.md            índice con enlaces relativos
├── 00-front-matter.md   portada, copyright, prólogo
├── 01-....md            un archivo por capítulo
├── 99-back-matter.md    notas, bibliografía, índice analítico
├── metadata.json        capítulos, páginas, confianza, stats, warnings
├── digest.md            títulos + extracto por capítulo (tu fuente para resumir)
└── report.md            avisos y calidad
```

Con `--library`, la ruta es `~/library/md/<slug>/` y se añade una fila a `~/library/INDEX.md`.

Los archivos llevan frontmatter YAML (`title`, `book`, `author`, `chapter`, `pages`,
`source`, `sha256`, `split_method`, `generated`) para Obsidian, Hugo o RAG.

## Definition of done

- [ ] `--analyze` mostrado y método/confianza explicados.
- [ ] Carpeta con `README.md`, capítulos, `metadata.json`, `digest.md` y `report.md`.
- [ ] `--verify` en verde.
- [ ] Resumen ≤150 palabras basado en el digest.
- [ ] Tabla de capítulos con descripciones de una línea.
- [ ] Avisos de calidad y recomendaciones incluidos.

Detalles de diagnóstico: `references/troubleshooting.md`.
