# Diagnóstico de pdf2md

Orden recomendado: `--analyze --json` → leer `report.md` → `--verify` → ajustar `--split`.

## Síntomas y acciones

| Síntoma | Causa probable | Acción |
| --- | --- | --- |
| `El PDF casi no tiene capa de texto` | Escaneo sin OCR | `ocrmypdf --language spa libro.pdf libro-ocr.pdf` y reconvertir |
| `N páginas casi sin texto` | Ilustraciones, páginas en blanco o escaneo parcial | Revisar `stats.pages_without_text`; si son capítulos enteros, OCR |
| Un solo capítulo | Sin outline, sin índice y sin encabezados detectables | `--split pages --chunk 15` y avisar de que es aproximado |
| Decenas de capítulos de 1-2 páginas | Subtítulos tomados como capítulos | `--split outline` (elige otro nivel) o `--split pages` |
| Faltan capítulos | Outline incompleto o índice impreso con numeración romana | `--split headings`; si falla, `--split pages` |
| Capítulos desordenados o solapados | Outline con páginas duplicadas o erróneas | Revisar `metadata.json`; probar `--split toc` o `pages` |
| Faltan páginas del medio | Rango mal cerrado por detección de materia final | Revisar `report.md`; `--verify` lo detecta (`páginas sin asignar`) |
| Cabeceras del libro dentro del texto | Patrón no repetido lo suficiente | Detectar manualmente y limpiar; reportarlo |
| Párrafos partidos en líneas de ~90 caracteres | Conversión antigua sin reflow | `pdf2md --reflow ~/library/md` |
| Acentos o ligaduras raras | Fuente con codificación exótica | Suele resolverse con OCR; si no, posprocesar |
| Tablas destruidas | PDF sin líneas de tabla reales | Avisar; considerar `pymupdf_layout` o `docling` |
| Imágenes ausentes | `write_images=False` por diseño | Avisar; pedir extracción aparte si hace falta |
| `Falta PyMuPDF` | Se ejecutó con `python3` en vez de `uv` | Usar `uv run --script ...` |
| Primera ejecución lenta | `uv` descarga dependencias (~25 MB) | Normal, solo la primera vez |
| `ya convertido` | Mismo SHA-256 en `metadata.json` | `--force` si de verdad hay que rehacerlo |

## Inspección rápida de una salida

```bash
OUT="/ruta/salida"
python3 -m json.tool "$OUT/metadata.json" | head -40
sed -n '1,60p' "$OUT/report.md"
grep -c '^## ' "$OUT/digest.md"
```

## Cuándo no usar este skill

- PDFs con fórmulas matemáticas pesadas o maquetación a dos columnas compleja: la
  conversión será mediocre; avisa y propone `marker`/`docling` como alternativa.
- PDFs protegidos con contraseña: el script se detiene; pide el PDF desbloqueado.
- EPUB/MOBI: no es PDF; usa `pandoc`.
- Extracción de imágenes o figuras como archivos: no está soportado en v1.

## Reconvertir con otro método

```bash
uv run --script "$SKILL/scripts/pdf2md.py" libro.pdf -o salida --split headings --force
uv run --script "$SKILL/scripts/pdf2md.py" libro.pdf -o salida --split pages --chunk 12 --force
uv run --script "$SKILL/scripts/pdf2md.py" --verify salida
```

## Depurar la detección

`--analyze --json` devuelve `split.method`, `split.confidence`, `split.reason`, la lista de
capítulos con rangos de página y `stats.pages_without_text`. Compara esos rangos con el
índice real del libro antes de aceptar el resultado.
