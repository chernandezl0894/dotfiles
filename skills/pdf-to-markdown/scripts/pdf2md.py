#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pymupdf>=1.26", "pymupdf4llm>=0.2.9,<0.4"]
# ///
"""pdf2md — convierte un PDF en Markdown dividido por capítulos.

Uso:
    pdf2md.py libro.pdf                  # crea ./libro/
    pdf2md.py libro.pdf --analyze        # solo diagnostica, no escribe nada
    pdf2md.py libro.pdf -o ~/libros/x --lang es
    pdf2md.py *.pdf --catalog
    pdf2md.py --selftest                 # prueba interna con un PDF sintético

Salidas por libro:
    README.md        índice con enlaces a cada capítulo
    00-front-matter.md / NN-slug.md / 99-back-matter.md
    metadata.json    estructura para máquinas
    digest.md        extracto compacto para que un LLM resuma
    report.md        avisos y calidad de la conversión

El script es determinista, no usa red y no llama a ningún modelo.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import statistics
import sys
import unicodedata
from collections import Counter
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

# PyMuPDF imprime un aviso publicitario al importarse; lo silenciamos antes.
os.environ.setdefault("PYMUPDF_SUGGEST_LAYOUT_ANALYZER", "0")

try:
    import pymupdf
except ImportError:  # PyMuPDF < 1.24
    try:
        import fitz as pymupdf  # type: ignore
    except ImportError:
        sys.exit(
            "Falta PyMuPDF. Ejecuta el script con:\n"
            "  uv run --script pdf2md.py <archivo.pdf>\n"
            "o instala pymupdf y pymupdf4llm en el entorno activo."
        )

try:
    import pymupdf4llm

    HAS_PYMUPDF4LLM = True
except ImportError:
    pymupdf4llm = None  # type: ignore
    HAS_PYMUPDF4LLM = False

VERSION = "1.0.0"
SCHEMA = 1

# --------------------------------------------------------------------------- #
# Patrones
# --------------------------------------------------------------------------- #

CHAPTER_RE = re.compile(
    r"^(cap[ií]tulo|chapter|parte|part|libro|book|secci[oó]n|section|ap[eé]ndice|appendix)"
    r"\s+([0-9]{1,3}|[ivxlcdm]{1,7})\b",
    re.IGNORECASE,
)
TOC_HEADING_RE = re.compile(
    r"^[ \t]*(índice|indice|contenido|contenidos|contents|tabla de contenidos|table of contents)[ \t]*$",
    re.IGNORECASE,
)
BACK_MATTER_RE = re.compile(
    r"^[ \t]*(índice analítico|índice onomástico|index|bibliografía|bibliography|"
    r"obras citadas|referencias|notes|notas)[ \t]*$",
    re.IGNORECASE,
)
BACK_MATTER_STRICT_RE = re.compile(
    r"^[ \t]*(index|índice analítico|índice onomástico|bibliography|bibliografía|"
    r"obras citadas)[ \t]*$",
    re.IGNORECASE,
)
NUMBERED_RE = re.compile(r"^\d{1,3}[.)]\s+\S")
CHAPTER_WORD_RE = re.compile(r"^(chapter|cap[ií]tulo)\b", re.IGNORECASE)
PART_WORD_RE = re.compile(r"^(part|parte|book|libro)\b", re.IGNORECASE)
INDEX_LETTER_RE = re.compile(r"^[-\u2013\u2014]\s*[A-Z0-9ÁÉÍÓÚÑ]{1,3}\s*[-\u2013\u2014]$")
JUNK_TITLE_RE = re.compile(
    r"^(cubierta|portada|cover|title\s*page|copyright|cr[eé]ditos|"
    r"contenido|contenidos|contents|tabla de contenidos|table of contents|"
    r"índice|indice)[ \t]*$",
    re.IGNORECASE,
)
PAGE_NUM_RE = re.compile(r"^(?:pag(?:ina)?\s*)?(\d{1,4})$", re.IGNORECASE)
LIGATURES = {
    "\ufb00": "ff", "\ufb01": "fi", "\ufb02": "fl", "\ufb03": "ffi",
    "\ufb04": "ffl", "\ufb05": "st", "\ufb06": "st",
    "\u00ad": "", "\u00a0": " ", "\u2007": " ", "\u202f": " ",
}
TEXT_JUNK = str.maketrans({"…": "...", "“": '"', "”": '"', "‘": "'", "’": "'"})
RUNNING_HEADER_RE = re.compile(
    r"^.{0,90}?[•·]\s*\d{1,4}\s*$"
    r"|^(?:report erratum|report errata)\b.*$"
    r"|^\d{1,4}$",
    re.IGNORECASE,
)


# --------------------------------------------------------------------------- #
# Utilidades de texto
# --------------------------------------------------------------------------- #

def normalize_ligatures(text: str) -> str:
    for src, dst in LIGATURES.items():
        text = text.replace(src, dst)
    return text.translate(TEXT_JUNK)


def normalize_ws(text: str) -> str:
    return re.sub(r"[ \t]+", " ", text).strip()


def normalize_key(text: str) -> str:
    """Normaliza una línea para comparar cabeceras/pies repetidos."""
    text = normalize_ligatures(text).lower()
    text = re.sub(r"\d+", "#", text)
    text = re.sub(r"[^\w#áéíóúüñç]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def line_key(text: str) -> str:
    """Clave de línea tolerante al Markdown (enlaces y URLs)."""
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"https?://\S+", " ", text)
    return normalize_key(text)


def slugify(text: str, maxlen: int = 60) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = "".join(c for c in text if not unicodedata.combining(c))
    text = text.lower().replace("'", "").replace("\u2019", "")
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return (text[:maxlen].strip("-") or "capitulo")


def word_count(text: str) -> int:
    return len(re.findall(r"\w+", text, re.UNICODE))


def sanitize_title(text: str, maxlen: int = 160) -> str:
    text = normalize_ligatures(text or "").replace("\n", " ")
    text = re.sub(r"[*_`#>\[\]]+", "", text)
    text = normalize_ws(text)
    return (text[:maxlen].strip() or "Sin título")


def strip_chapter_number(title: str, index: int) -> str:
    """Elimina el número inicial cuando coincide con el índice del capítulo."""
    match = re.match(r"^(\d{1,3})[.)]\s+(.+)$", title)
    if match and int(match.group(1)) == index:
        return match.group(2).strip()
    match = re.match(
        r"^(chapter|cap[ií]tulo)\s+(\d{1,3})[.:\u2014\u2013-]\s*(.+)$", title, re.IGNORECASE
    )
    if match and int(match.group(2)) == index:
        return match.group(3).strip()
    return title


def sha256_of(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def excerpt(text: str, limit: int = 420) -> str:
    plain = re.sub(r"^---.*?---", "", text, flags=re.DOTALL)
    plain = re.sub(r"```.*?```", " ", plain, flags=re.DOTALL)
    plain = re.sub(r"!\[[^\]]*\]\([^)]*\)", " ", plain)
    plain = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", plain)
    plain = re.sub(r"^#{1,6}\s*", "", plain, flags=re.MULTILINE)
    plain = re.sub(r"[*_`>|]+", " ", plain)
    plain = normalize_ws(re.sub(r"\s+", " ", plain))
    if len(plain) <= limit:
        return plain
    cut = plain[:limit]
    end = max(cut.rfind(". "), cut.rfind("? "), cut.rfind("! "))
    if end > limit * 0.55:
        return cut[: end + 1].strip()
    return cut.rsplit(" ", 1)[0].strip() + " [...]"


# --------------------------------------------------------------------------- #
# Modelo
# --------------------------------------------------------------------------- #

@dataclass
class Line:
    page: int          # 1-based
    text: str
    size: float
    bold: bool
    rel_y: float       # 0 = arriba, 1 = abajo


@dataclass
class Chapter:
    index: int
    title: str
    start: int
    end: int
    kind: str = "chapter"      # front | chapter | back
    file: str = ""
    words: int = 0
    chars: int = 0
    text: str = ""

    @property
    def pages(self) -> str:
        return f"{self.start}-{self.end}"


@dataclass
class SplitResult:
    starts: list[tuple[str, int]]
    method: str
    confidence: str
    reason: str
    back_start: int | None = None


@dataclass
class Book:
    path: Path
    doc: object
    page_count: int
    title: str
    author: str
    lines: list[Line] = field(default_factory=list)
    body_size: float = 10.0
    repeated: set[str] = field(default_factory=set)
    char_counts: list[int] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    method: str = "pages"
    confidence: str = "baja"
    reason: str = ""
    chapters: list[Chapter] = field(default_factory=list)


# --------------------------------------------------------------------------- #
# Lectura del PDF
# --------------------------------------------------------------------------- #

def open_pdf(path: Path):
    if not path.exists():
        raise SystemExit(f"No existe el archivo: {path}")
    if path.suffix.lower() != ".pdf":
        raise SystemExit(f"No parece un PDF: {path}")
    try:
        doc = pymupdf.open(path)
    except Exception as exc:  # noqa: BLE001
        raise SystemExit(f"No se pudo abrir {path.name}: {exc}") from exc
    if doc.needs_pass:
        doc.close()
        raise SystemExit(f"{path.name} está protegido con contraseña.")
    if doc.page_count == 0:
        doc.close()
        raise SystemExit(f"{path.name} no tiene páginas.")
    return doc


def collect_lines(doc) -> list[Line]:
    lines: list[Line] = []
    for page_number in range(doc.page_count):
        page = doc[page_number]
        height = page.rect.height or 1.0
        data = page.get_text("dict")
        for block in data.get("blocks", []):
            if block.get("type") != 0:
                continue
            for raw_line in block.get("lines", []):
                spans = [s for s in raw_line.get("spans", []) if s.get("text", "").strip()]
                if not spans:
                    continue
                text = normalize_ws(normalize_ligatures("".join(s["text"] for s in spans)))
                if not text:
                    continue
                lines.append(
                    Line(
                        page=page_number + 1,
                        text=text,
                        size=round(max(float(s.get("size", 10)) for s in spans), 2),
                        bold=any(int(s.get("flags", 0)) & 16 for s in spans),
                        rel_y=round(float(raw_line["bbox"][1]) / height, 3),
                    )
                )
    return lines


def body_font_size(lines: list[Line]) -> float:
    counter: Counter[float] = Counter()
    for line in lines:
        counter[line.size] += len(line.text)
    if not counter:
        return 10.0
    return counter.most_common(1)[0][0]


def repeated_lines(lines: list[Line], page_count: int) -> set[str]:
    """Cabeceras y pies repetidos en la zona de margen (arriba o abajo)."""
    counter: Counter[str] = Counter()
    for line in lines:
        if 0.10 < line.rel_y < 0.90:
            continue
        key = line_key(line.text)
        if len(key) >= 4:
            counter[key] += 1
    threshold = max(3, int(page_count * 0.25))
    result: set[str] = set()
    for key, count in counter.items():
        # Cabeceras de capítulo: cambian el número de página, así que se repiten
        # pocas veces pero siempre con dígitos (normalizados a "#").
        if count >= threshold or ("#" in key and count >= 4 and len(key) <= 90):
            result.add(key)
    return result


def page_char_counts(lines: list[Line], page_count: int) -> list[int]:
    counts = [0] * page_count
    for line in lines:
        counts[line.page - 1] += len(re.sub(r"\s+", "", line.text))
    return counts


# --------------------------------------------------------------------------- #
# Detección de capítulos
# --------------------------------------------------------------------------- #

def chapters_from_outline(doc, page_count: int) -> SplitResult | None:
    try:
        toc = doc.get_toc(simple=True)
    except Exception:  # noqa: BLE001
        return None
    entries = []
    for item in toc or []:
        if not isinstance(item, (list, tuple)) or len(item) < 3:
            continue
        try:
            level, title, page = int(item[0]), str(item[1]).strip(), int(item[2])
        except (TypeError, ValueError):
            continue
        if title and 1 <= page <= page_count:
            entries.append((level, title, page))
    if len(entries) < 2:
        return None

    # El índice analítico suele venir en el outline y arruina cualquier estadística:
    # todo lo que empiece en su página se descarta y se recuerda como materia final.
    back_start: int | None = None
    for _, title, page in entries:
        if BACK_MATTER_STRICT_RE.match(title):
            back_start = page if back_start is None else min(back_start, page)
    if back_start is not None:
        entries = [entry for entry in entries if entry[2] < back_start]
        if len(entries) < 2:
            return None

    candidates = []
    for level in sorted({entry[0] for entry in entries}):
        selected = sorted(
            ((title, page) for lvl, title, page in entries if lvl == level),
            key=lambda item: item[1],
        )
        unique: list[tuple[str, int]] = []
        seen: set[int] = set()
        for title, page in selected:
            if page in seen:
                continue
            seen.add(page)
            unique.append((title, page))
        if len(unique) < 2:
            continue
        gaps = [b[1] - a[1] for a, b in zip(unique, unique[1:]) if b[1] > a[1]]
        candidates.append(
            {
                "level": level,
                "uniq": unique,
                "n": len(unique),
                "med": statistics.median(gaps) if gaps else 0,
                "numbered": sum(1 for t, _ in unique if NUMBERED_RE.match(t)),
                "chapter_word": sum(1 for t, _ in unique if CHAPTER_WORD_RE.match(t)),
                "parts": sum(1 for t, _ in unique if PART_WORD_RE.match(t)),
            }
        )
    if not candidates:
        return None

    # 1) Nivel con capítulos numerados ("1. Título") — la señal más fiable.
    numbered = [c for c in candidates if c["numbered"] >= 4 and 3 <= c["n"] <= 120]
    if numbered:
        best = max(numbered, key=lambda c: (c["numbered"], -c["level"]))
    else:
        # 2) Nivel con "Chapter N" / "Capítulo N".
        worded = [c for c in candidates if c["chapter_word"] >= 3 and 3 <= c["n"] <= 60]
        if worded:
            best = max(worded, key=lambda c: (c["chapter_word"], -c["level"]))
        else:
            # 3) Nivel estructural: el más superficial con tamaño de capítulo.
            structural = [c for c in candidates if 3 <= c["n"] <= 45 and c["med"] >= 5]
            if structural:
                best = min(structural, key=lambda c: c["level"])
            else:
                best = min(candidates, key=lambda c: (abs(c["n"] - 12), c["level"]))
            # Si lo elegido son "Partes", bajar un nivel a los capítulos.
            if best["parts"] >= 2 and best["parts"] * 2 >= best["n"]:
                deeper = [
                    c for c in candidates
                    if c["level"] > best["level"] and 4 <= c["n"] <= 60 and c["med"] >= 4
                ]
                if deeper:
                    best = min(deeper, key=lambda c: c["level"])

    unique = best["uniq"]
    if best["numbered"] >= 3:
        first = next(i for i, (t, _) in enumerate(unique) if NUMBERED_RE.match(t))
        unique = unique[first:]

    starts = [
        (title, page) for title, page in unique
        if not JUNK_TITLE_RE.match(title) and not INDEX_LETTER_RE.match(title)
    ]
    if len(starts) < 2:
        return None

    if best["numbered"] >= 5 and best["med"] >= 4:
        confidence = "alta"
    elif best["numbered"] >= 3 or best["med"] >= 4:
        confidence = "media"
    else:
        confidence = "baja"
    detail = (
        f"outline nivel {best['level']}: {len(starts)} capítulos"
        f"{' numerados' if best['numbered'] else ''}, salto mediano {best['med']:g} pág."
    )
    return SplitResult(starts, "outline", confidence, detail, back_start=back_start)


def find_toc_pages(lines: list[Line], page_count: int) -> list[int]:
    """Páginas que contienen un índice impreso (para no confundirlo con capítulos)."""
    by_page: dict[int, list[Line]] = {}
    for line in lines:
        by_page.setdefault(line.page, []).append(line)
    return [
        page for page in sorted(by_page)
        if page <= min(30, page_count) and by_page[page]
        and TOC_HEADING_RE.match(by_page[page][0].text)
    ]


def chapters_from_printed_toc(
    doc, page_count: int, lines: list[Line], toc_pages: list[int]
) -> SplitResult | None:
    """Intenta leer la página de Índice impresa y mapear sus números de página."""
    if not toc_pages:
        return None
    by_page: dict[int, list[Line]] = {}
    for line in lines:
        by_page.setdefault(line.page, []).append(line)

    raw: list[tuple[str, int]] = []
    first_toc = toc_pages[0]
    last_toc = first_toc
    for page in range(first_toc, min(first_toc + 6, page_count + 1)):
        found_here = 0
        for line in by_page.get(page, []):
            if TOC_HEADING_RE.match(line.text) or len(line.text) > 120:
                continue
            match = re.match(r"^(?P<title>.+?)[\s.·…]{2,}(?P<num>\d{1,4})$", line.text)
            if not match:
                match = re.match(r"^(?P<title>[^\d].{2,80}?)\s{2,}(?P<num>\d{1,4})$", line.text)
            if match:
                raw.append((sanitize_title(match.group("title")), int(match.group("num"))))
                found_here += 1
        if found_here:
            last_toc = page
        elif page > first_toc:
            break
    raw = [(t, p) for t, p in raw if len(t) >= 3]
    if len(raw) < 3:
        return None

    # Verificar buscando los títulos en el documento y calcular el desplazamiento.
    # Se busca solo después del índice: los títulos también aparecen en el propio índice.
    page_texts = [normalize_ws(doc[p].get_text("text")).lower() for p in range(page_count)]
    search_start = last_toc + 1
    verified: list[tuple[str, int, int]] = []
    offsets: list[int] = []
    for title, claimed in raw:
        needle = normalize_ws(title.lower())[:40]
        if not needle:
            continue
        for actual in range(search_start, page_count + 1):
            if needle in page_texts[actual - 1]:
                verified.append((title, claimed, actual))
                offsets.append(actual - claimed)
                break
    if len(offsets) < 3:
        return None
    offset = Counter(offsets).most_common(1)[0][0]
    agree = sum(1 for value in offsets if value == offset)
    if abs(offset) > 40 or agree < max(3, int(len(offsets) * 0.6)):
        return None

    fixed: list[tuple[str, int]] = []
    for title, claimed, found in verified:
        page = claimed + offset
        if abs(page - found) > 2:  # la evidencia manda sobre el número impreso
            page = found
        if 1 <= page <= page_count:
            fixed.append((title, page))
    fixed.sort(key=lambda item: item[1])
    deduped: list[tuple[str, int]] = []
    seen: set[int] = set()
    for title, page in fixed:
        if page not in seen:
            seen.add(page)
            deduped.append((title, page))
    if len(deduped) < 3:
        return None
    return SplitResult(
        deduped,
        "toc-impreso",
        "media" if agree == len(offsets) else "baja",
        f"índice impreso con {len(deduped)} entradas verificadas, desplazamiento {offset:+d} páginas",
    )


def chapters_from_headings(
    lines: list[Line], body_size: float, exclude_pages: set[int] | None = None
) -> SplitResult | None:
    exclude_pages = exclude_pages or set()

    def usable(line: Line) -> bool:
        return (
            line.page not in exclude_pages
            and len(line.text) <= 90
            and not re.search(r"[.·…]{3,}\s*\d+\s*$", line.text)
        )

    # 1) Patrones explícitos ("Capítulo 3", "Chapter IV") cerca del inicio de página
    pattern_hits: dict[int, list[Line]] = {}
    for line in lines:
        if usable(line) and line.rel_y <= 0.5 and CHAPTER_RE.match(line.text):
            pattern_hits.setdefault(line.page, []).append(line)
    if len(pattern_hits) >= 3:
        picks = [min(group, key=lambda l: l.rel_y) for group in pattern_hits.values()]
        starts = [(sanitize_title(p.text), p.page) for p in sorted(picks, key=lambda l: l.page)]
        return SplitResult(
            starts, "patrones", "media",
            f"{len(starts)} encabezados con patrón 'Capítulo/Chapter/Parte'",
        )

    # 2) Tipografía: líneas grandes o negritas al principio de página
    candidates = [
        line for line in lines
        if usable(line)
        and line.rel_y <= 0.55
        and 3 <= len(line.text) <= 100
        and (line.size >= body_size * 1.22 or (line.bold and line.size >= body_size * 1.08))
        and not line.text.endswith((".", ",", ";", ":"))
        and (line.text[0].isupper() or CHAPTER_RE.match(line.text))
        and not JUNK_TITLE_RE.match(line.text)
        and not PAGE_NUM_RE.match(line.text)
    ]
    if not candidates:
        return None
    sizes = sorted(c.size for c in candidates)
    threshold = max(body_size * 1.38, sizes[int(len(sizes) * 0.75)])
    strong: dict[int, Line] = {}
    for line in candidates:
        if line.size >= threshold and line.page not in strong:
            strong[line.page] = line
    if len(strong) < 2:
        return None
    starts = [(sanitize_title(l.text), l.page) for _, l in sorted(strong.items())]
    confidence = "media" if len(starts) <= 25 else "baja"
    return SplitResult(
        starts, "fuentes", confidence,
        f"{len(starts)} títulos detectados por tamaño de fuente (cuerpo {body_size:g} pt)",
    )


def chapters_by_pages(page_count: int, chunk: int) -> SplitResult:
    starts = []
    for start in range(1, page_count + 1, chunk):
        end = min(start + chunk - 1, page_count)
        starts.append((f"Páginas {start}-{end}", start))
    return SplitResult(
        starts, "paginas", "baja",
        f"sin estructura detectable: bloques fijos de {chunk} páginas",
    )


def find_back_matter(page_count: int, last_start: int, lines: list[Line]) -> int | None:
    """Busca un índice analítico o bibliografía al final del libro."""
    threshold = max(last_start, int(page_count * 0.70))
    hits = [
        line for line in lines
        if line.page >= threshold and line.rel_y <= 0.45 and BACK_MATTER_RE.match(line.text)
    ]
    return min(hit.page for hit in hits) if hits else None


# --------------------------------------------------------------------------- #
# Construcción y extracción
# --------------------------------------------------------------------------- #

def build_chapters(
    result: SplitResult, page_count: int, lines: list[Line]
) -> list[Chapter]:
    starts: list[tuple[str, int]] = []
    seen: set[int] = set()
    for title, page in sorted(result.starts, key=lambda item: item[1]):
        page = max(1, min(page, page_count))
        if page in seen:
            continue
        seen.add(page)
        starts.append((sanitize_title(title), page))
    if not starts:
        starts = [(f"Páginas 1-{page_count}", 1)]

    back_page = result.back_start or find_back_matter(page_count, starts[-1][1], lines)

    chapters: list[Chapter] = []
    index = 0
    if starts[0][1] > 1:
        chapters.append(Chapter(0, "Materia preliminar", 1, starts[0][1] - 1, kind="front"))
    for position, (title, start) in enumerate(starts):
        end = starts[position + 1][1] - 1 if position + 1 < len(starts) else page_count
        if back_page and back_page > start and end >= back_page:
            end = back_page - 1
        if end < start:
            continue
        index += 1
        chapters.append(Chapter(index, strip_chapter_number(title, index), start, end))
        if back_page and back_page > start and chapters[-1].end == back_page - 1:
            chapters.append(Chapter(99, "Materia final", back_page, page_count, kind="back"))
            break

    return chapters


def pymupdf4llm_options() -> dict:
    return {
        "write_images": False,
        "embed_images": False,
        "show_progress": False,
    }


def chapter_markdown(doc, start: int, end: int) -> str:
    pages = list(range(start - 1, end))
    if HAS_PYMUPDF4LLM:
        try:
            text = pymupdf4llm.to_markdown(doc, pages=pages, **pymupdf4llm_options())
            if text and text.strip():
                return text
        except TypeError:
            try:
                return pymupdf4llm.to_markdown(doc, pages=pages)
            except Exception:  # noqa: BLE001
                pass
        except Exception:  # noqa: BLE001
            pass
    return "\n\n".join(doc[page].get_text("text") for page in pages)


def clean_markdown(text: str, repeated: set[str], start: int, end: int, keep_markers: bool) -> str:
    text = normalize_ligatures(text)
    output: list[str] = []
    skip_blank = False
    for raw in text.splitlines():
        stripped = raw.strip()
        if not stripped:
            if skip_blank:
                skip_blank = False
                continue
            output.append("")
            continue
        if re.fullmatch(r"[-_=*]{3,}", stripped):
            continue
        drop = False
        if not keep_markers and line_key(stripped) in repeated:
            drop = True
        number = PAGE_NUM_RE.match(stripped)
        if number and start <= int(number.group(1)) <= end:
            drop = True
        if drop:
            # Al quitar una cabecera/pie, eliminar también el hueco que deja
            # alrededor para que el párrafo cortado se pueda reunir.
            if output and output[-1] == "":
                output.pop()
            skip_blank = True
            continue
        output.append(raw.rstrip())
        skip_blank = False

    text = "\n".join(output)
    # Deshacer guiones de corte solo entre minúsculas (informa-\nmación)
    text = re.sub(
        r"([a-záéíóúüñç])-\n([a-záéíóúüñç]{2,})",
        lambda m: m.group(1) + m.group(2),
        text,
    )
    text = re.sub(r"\n{3,}", "\n\n", text)
    # Quitar negritas dentro de encabezados que genera pymupdf4llm
    text = re.sub(r"^(#{1,6})\s*\*\*(.+?)\*\*\s*$", r"\1 \2", text, flags=re.MULTILINE)
    text = re.sub(r"^(#{1,6})\s+(.+?)\s*#+\s*$", r"\1 \2", text, flags=re.MULTILINE)
    return text.strip()


def ensure_title(markdown: str, title: str) -> str:
    body = markdown.lstrip()
    if body.startswith("#"):
        first, _, rest = body.partition("\n")
        existing = normalize_key(re.sub(r"^#+\s*", "", first).strip("* "))
        wanted = normalize_key(title)
        if (
            existing == wanted
            or existing.endswith(" " + wanted)
            or wanted.endswith(" " + existing)
        ):
            return f"# {title}\n\n{rest.lstrip()}"
    return f"# {title}\n\n{body}"


def split_frontmatter_text(text: str) -> tuple[str, str]:
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            close = text.find("\n", end + 1)
            return text[: close + 1], text[close + 1:]
    return "", text


def _join_wrapped(lines: list[str]) -> str:
    out = lines[0].rstrip()
    for raw in lines[1:]:
        nxt = raw.strip()
        if not nxt:
            continue
        if out.endswith("-") and nxt[:1].islower():
            out = out[:-1] + nxt
        else:
            out = out + " " + nxt
    return re.sub(r" {2,}", " ", out)


def _classify_chunk(lines: list[str]) -> list[tuple[str, list[str]]]:
    """Clasifica un bloque (separado por líneas en blanco) y lo refluye."""
    if len(lines) == 1 and len(lines[0]) <= 110 and RUNNING_HEADER_RE.match(lines[0].strip()):
        return [("header", [])]

    parts: list[tuple[str, list[str]]] = []
    while lines and HEADING_MD_RE.match(lines[0]):
        parts.append(("heading", [lines[0]]))
        lines = lines[1:]
    if not lines:
        return parts

    first = lines[0]
    if TABLE_MD_RE.match(first):
        parts.append(("table", lines))
    elif IMAGE_MD_RE.match(first) or RULE_MD_RE.match(first) or first.lstrip().startswith("<"):
        parts.append(("raw", lines))
    elif QUOTE_MD_RE.match(first):
        joined = _join_wrapped([QUOTE_MD_RE.sub("", line) for line in lines])
        parts.append(("quote", ["> " + joined]))
    else:
        match = LIST_MD_RE.match(first)
        if match and not any(LIST_MD_RE.match(line) for line in lines[1:]):
            indent, marker, rest = match.groups()
            parts.append(("list", [f"{indent}{marker} {_join_wrapped([rest] + lines[1:])}"]))
        elif match:
            parts.append(("list", lines))
        else:
            parts.append(("para", [_join_wrapped(lines)]))
    return parts


def _markdown_units(body: str) -> list[tuple[str, str]]:
    units: list[tuple[str, str]] = []
    in_fence = False
    fence = ""
    buffer: list[str] = []
    for line in body.splitlines():
        if in_fence:
            buffer.append(line)
            if line.strip().startswith(fence):
                units.append(("code", "\n".join(buffer)))
                buffer, in_fence = [], False
            continue
        match = re.match(r"^\s*(```+|~~~+)", line)
        if match:
            in_fence, fence, buffer = True, match.group(1), [line]
            continue
        units.append(("blank", "") if not line.strip() else ("line", line))
    if buffer:
        units.append(("code", "\n".join(buffer)))
    return units


def reflow_markdown(text: str) -> str:
    """Une líneas partidas: un párrafo por línea, listas compactas.

    No toca bloques de código, tablas, encabezados, frontmatter ni citas.
    Elimina encabezados/pies corridos y fusiona el párrafo que cortaban.
    """
    front, body = split_frontmatter_text(text)

    chunks: list[tuple[str, list[str]]] = []
    current: list[str] = []
    for kind, value in _markdown_units(body):
        if kind == "line":
            current.append(value)
        else:
            if current:
                chunks.extend(_classify_chunk(current))
                current = []
            chunks.append((kind, [value] if kind == "code" else []))
    if current:
        chunks.extend(_classify_chunk(current))

    out: list[str] = []
    prev: str | None = None
    pending_header = False
    for kind, lines in chunks:
        if kind == "header":
            pending_header = True
            continue
        if kind == "code":
            if out and out[-1] != "":
                out.append("")
            out.extend(lines)
            out.append("")
            prev, pending_header = "code", False
            continue
        if kind == "blank" or not lines:
            continue
        if pending_header and prev == "para" and kind == "para" and out and out[-1] != "":
            out[-1] = _join_wrapped([out[-1], lines[0]])
            pending_header = False
            continue
        # Párrafo cortado por un salto de página sin puntuación final
        if prev == "para" and kind == "para" and out and out[-1] != "":
            last = out[-1]
            nxt = lines[0]
            if nxt[:1].islower() and not re.search(r'[.!?:;»")\]]\s*$', last):
                out[-1] = _join_wrapped([last, nxt])
                pending_header = False
                continue
        if out and out[-1] != "" and not (prev == "list" and kind == "list"):
            out.append("")
        out.extend(lines)
        prev, pending_header = kind, False

    while out and out[-1] == "":
        out.pop()
    lead = "\n" if front else ""
    return front + lead + "\n".join(_strip_duplicate_title(out)) + "\n"


CHAPTER_LABEL_RE = re.compile(r"^\s*(chapter|cap[ií]tulo)\s+\d{1,3}\s*$", re.IGNORECASE)


def _strip_duplicate_title(lines: list[str]) -> list[str]:
    """Quita 'CHAPTER 1' y el título repetido justo debajo del H1."""
    index = next((i for i, line in enumerate(lines) if line.startswith("# ")), None)
    if index is None:
        return lines
    title = normalize_key(re.sub(r"^#\s*", "", lines[index]))
    if not title:
        return lines

    kept = lines[: index + 1]
    seen = 0
    for line in lines[index + 1:]:
        stripped = line.strip()
        if stripped:
            seen += 1
            if seen <= 6:
                if CHAPTER_LABEL_RE.match(stripped):
                    continue
                key = normalize_key(re.sub(r"^#+\s*", "", stripped).strip("* "))
                if key == title or key.endswith(" " + title):
                    continue
        kept.append(line)

    tail = kept[index + 1:]
    while tail and not tail[0].strip():
        tail.pop(0)
    return kept[: index + 1] + [""] + tail


HEADING_MD_RE = re.compile(r"^\s{0,3}#{1,6}\s")
TABLE_MD_RE = re.compile(r"^\s*\|")
QUOTE_MD_RE = re.compile(r"^\s*>\s?")
IMAGE_MD_RE = re.compile(r"^\s*!\[")
RULE_MD_RE = re.compile(r"^\s*([-*_])(\s*\1){2,}\s*$")
LIST_MD_RE = re.compile(r"^(\s*)([-*+]|\d{1,3}[.)])\s+(.*)$")


def yaml_frontmatter(data: dict) -> str:
    lines = ["---"]
    for key, value in data.items():
        if isinstance(value, (int, float)):
            lines.append(f"{key}: {value}")
        else:
            lines.append(f"{key}: {json.dumps(str(value), ensure_ascii=False)}")
    lines.append("---")
    return "\n".join(lines) + "\n\n"


def assign_filenames(chapters: list[Chapter]) -> None:
    used: set[str] = set()
    total = sum(1 for c in chapters if c.kind == "chapter")
    width = 2 if total < 100 else 3
    for chapter in chapters:
        if chapter.kind == "front":
            name = "00-front-matter.md"
        elif chapter.kind == "back":
            name = "99-back-matter.md"
        else:
            base = f"{chapter.index:0{width}d}-{slugify(chapter.title)}"
            name = f"{base}.md"
            counter = 2
            while name in used:
                name = f"{base}-{counter}.md"
                counter += 1
        used.add(name)
        chapter.file = name


# --------------------------------------------------------------------------- #
# Análisis
# --------------------------------------------------------------------------- #

def analyze_book(path: Path, split_mode: str = "auto", chunk: int = 20,
                 title_override: str | None = None, author_override: str | None = None) -> Book:
    doc = open_pdf(path)
    metadata = doc.metadata or {}
    raw_title = (title_override or metadata.get("title") or "").strip()
    if not raw_title or raw_title.lower().endswith((".doc", ".docx", ".indd", ".pdf")):
        raw_title = path.stem.replace("_", " ").replace("-", " ").strip()
    author = (author_override or metadata.get("author") or "").strip()

    lines = collect_lines(doc)
    body = body_font_size(lines)
    counts = page_char_counts(lines, doc.page_count)
    book = Book(
        path=path,
        doc=doc,
        page_count=doc.page_count,
        title=sanitize_title(raw_title),
        author=author,
        lines=lines,
        body_size=body,
        repeated=repeated_lines(lines, doc.page_count),
        char_counts=counts,
    )

    mode = split_mode.lower()
    result: SplitResult | None = None
    toc_pages = find_toc_pages(lines, book.page_count)
    if mode in ("auto", "outline"):
        result = chapters_from_outline(doc, book.page_count)
    if result is None and mode in ("auto", "toc"):
        result = chapters_from_printed_toc(doc, book.page_count, lines, toc_pages)
    if result is None and mode in ("auto", "headings", "fuentes"):
        result = chapters_from_headings(lines, body, set(toc_pages))
    if result is None:
        chunk_size = chunk
        if mode.startswith("pages:"):
            try:
                chunk_size = max(1, int(mode.split(":", 1)[1]))
            except ValueError:
                pass
        result = chapters_by_pages(book.page_count, chunk_size)

    book.method = result.method
    book.confidence = result.confidence
    book.reason = result.reason
    book.chapters = build_chapters(result, book.page_count, lines)

    total_chars = sum(counts)
    empty_pages = [i + 1 for i, count in enumerate(counts) if count < 80]
    if not lines or total_chars < book.page_count * 40:
        book.warnings.append(
            "El PDF casi no tiene capa de texto: parece un escaneo. "
            "Aplica OCR antes de convertir (ocrmypdf o tesseract)."
        )
    elif len(empty_pages) / max(1, book.page_count) > 0.15:
        book.warnings.append(
            f"{len(empty_pages)} de {book.page_count} páginas casi sin texto "
            f"({len(empty_pages) / book.page_count:.0%}). Revisa si hace falta OCR."
        )
    if book.confidence == "baja":
        book.warnings.append("La división por capítulos es aproximada; revisa la tabla del README.")
    if not book.chapters:
        book.warnings.append("No se generó ningún capítulo.")
    return book


# --------------------------------------------------------------------------- #
# Conversión
# --------------------------------------------------------------------------- #

def convert_book(
    book: Book,
    outdir: Path,
    *,
    force: bool = False,
    keep_markers: bool = False,
    update_catalog: bool = False,
    library: Path | None = None,
) -> dict:
    digest_source = sha256_of(book.path)
    metadata_path = outdir / "metadata.json"
    if metadata_path.exists() and not force:
        try:
            previous = json.loads(metadata_path.read_text(encoding="utf-8"))
            if previous.get("source", {}).get("sha256") == digest_source:
                print(f"  = ya convertido ({outdir}); usa --force para rehacerlo")
                return previous
        except (json.JSONDecodeError, OSError):
            pass

    outdir.mkdir(parents=True, exist_ok=True)
    assign_filenames(book.chapters)

    old_files: set[str] = set()
    if metadata_path.exists():
        try:
            previous = json.loads(metadata_path.read_text(encoding="utf-8"))
            old_files = {c["file"] for c in previous.get("chapters", []) if c.get("file")}
        except (json.JSONDecodeError, OSError, KeyError):
            old_files = set()

    for chapter in book.chapters:
        raw = chapter_markdown(book.doc, chapter.start, chapter.end)
        cleaned = clean_markdown(raw, book.repeated, chapter.start, chapter.end, keep_markers)
        body = ensure_title(cleaned, chapter.title)
        if chapter.kind != "back":
            body = reflow_markdown(body)
        front = yaml_frontmatter(
            {
                "title": chapter.title,
                "book": book.title,
                "author": book.author or "Desconocido",
                "chapter": chapter.index if chapter.kind == "chapter" else chapter.kind,
                "pages": chapter.pages,
                "source": book.path.name,
                "sha256": digest_source[:16],
                "split_method": book.method,
                "generated": datetime.now().strftime("%Y-%m-%d"),
            }
        )
        chapter.text = body
        chapter.words = word_count(body)
        chapter.chars = len(body)
        (outdir / chapter.file).write_text((front + body).rstrip() + "\n", encoding="utf-8")

    # Limpiar archivos de una conversión anterior que ya no forman parte del libro
    new_files = {c.file for c in book.chapters}
    for stale in old_files - new_files:
        target = outdir / stale
        if target.suffix == ".md" and target.exists():
            target.unlink()

    chapters_meta = [        {
            "index": c.index,
            "title": c.title,
            "file": c.file,
            "kind": c.kind,
            "start_page": c.start,
            "end_page": c.end,
            "words": c.words,
        }
        for c in book.chapters
    ]
    total_words = sum(c.words for c in book.chapters)
    images = sum(
        len(re.findall(r"!\[[^\]]*\]\(", c.text)) for c in book.chapters
    )
    try:
        pdf_images = sum(len(book.doc[p].get_images(full=True)) for p in range(book.page_count))
    except Exception:  # noqa: BLE001
        pdf_images = 0
    tables = sum(
        len(re.findall(r"^\|.+\|\s*$", c.text, flags=re.MULTILINE)) for c in book.chapters
    )

    metadata = {
        "schema": SCHEMA,
        "tool": {"name": "pdf2md", "version": VERSION},
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "source": {
            "path": str(book.path.resolve()),
            "name": book.path.name,
            "sha256": digest_source,
            "pages": book.page_count,
            "bytes": book.path.stat().st_size,
        },
        "book": {"title": book.title, "author": book.author or "Desconocido"},
        "split": {
            "method": book.method,
            "confidence": book.confidence,
            "reason": book.reason,
        },
        "stats": {
            "chapters": sum(1 for c in book.chapters if c.kind == "chapter"),
            "files": len(book.chapters),
            "words": total_words,
            "images": images,
            "pdf_images": pdf_images,
            "table_rows": tables,
            "pages_without_text": [i + 1 for i, n in enumerate(book.char_counts) if n < 80],
        },
        "chapters": chapters_meta,
        "warnings": book.warnings,
        "files": {
            "index": "README.md",
            "digest": "digest.md",
            "report": "report.md",
        },
    }
    metadata_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    write_index(outdir, metadata)
    write_digest(outdir, book, metadata)
    write_report(outdir, book, metadata)

    if update_catalog:
        update_catalog_file(metadata, outdir, library)

    return metadata


def write_index(outdir: Path, metadata: dict) -> None:
    info = metadata["book"]
    source = metadata["source"]
    split = metadata["split"]
    chapters = metadata["chapters"]
    details = [f"{source['pages']} páginas", f"{metadata['stats']['chapters']} capítulos"]
    if info["author"] and info["author"] != "Desconocido":
        details.insert(0, info["author"])
    lines = [f"# {info['title']}", "", f"> {' · '.join(details)}", ""]
    lines.append(
        f"Convertido de `{source['name']}` con **pdf2md {VERSION}** · división: "
        f"`{split['method']}` (confianza {split['confidence']})."
    )
    if split["confidence"] != "alta":
        lines.append("")
        lines.append(
            "> [!WARNING]\n"
            "> La detección de capítulos es aproximada. Revisa los rangos de página "
            "y usa `pdf2md --analyze` o `--split` para ajustar."
        )
    lines += ["", "## Contenido", "", "| # | Capítulo | Páginas | Palabras | Archivo |",
              "| --- | --- | --- | --- | --- |"]
    for chapter in chapters:
        label = chapter["title"].replace("|", "\\|")
        lines.append(
            f"| {chapter['index']:02d} | {label} | "
            f"{chapter['start_page']}-{chapter['end_page']} | {chapter.get('words', 0):,} | "
            f"[{chapter['file']}]({chapter['file']}) |"
        )
    lines += ["", "---", "", f"Generado el {datetime.now():%Y-%m-%d}. "
              "Edita `metadata.json` solo si sabes lo que haces: el skill lo usa como contrato."]
    (outdir / "README.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_digest(outdir: Path, book: Book, metadata: dict) -> None:
    lines = [
        f"# Digest — {book.title}",
        "",
        f"- Autor: {book.author or 'Desconocido'}",
        f"- Páginas: {book.page_count} · Capítulos: {metadata['stats']['chapters']} · "
        f"Palabras: {metadata['stats']['words']:,}",
        f"- División: {book.method} (confianza {book.confidence}) — {book.reason}",
    ]
    if book.warnings:
        lines.append(f"- Avisos: {len(book.warnings)} (ver report.md)")
    lines.append("")
    for chapter in book.chapters:
        lines.append(f"## [{chapter.index:02d}] {chapter.title}")
        lines.append(f"Archivo `{chapter.file}` · pp. {chapter.pages} · {chapter.words:,} palabras")
        lines.append("")
        snippet = excerpt(chapter.text)
        lines.append(snippet if snippet else "_(sin texto extraído)_")
        lines.append("")
    (outdir / "digest.md").write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def write_report(outdir: Path, book: Book, metadata: dict) -> None:
    no_text = metadata["stats"]["pages_without_text"]
    lines = [
        "# Reporte de calidad",
        "",
        "## Resumen",
        "",
        f"- Archivo: `{book.path.name}` ({book.page_count} páginas)",
        f"- División: `{book.method}` — confianza **{book.confidence}**",
        f"- Motivo: {book.reason}",
        f"- Capítulos: {metadata['stats']['chapters']}",
        f"- Palabras: {metadata['stats']['words']:,}",
        f"- Imágenes en el PDF: {metadata['stats'].get('pdf_images', 0)} "
        "(no se extraen a Markdown)",
        f"- Filas de tabla detectadas: {metadata['stats']['table_rows']}",
        "",
        "## Avisos",
        "",
    ]
    if book.warnings:
        lines += [f"- {warning}" for warning in book.warnings]
    else:
        lines.append("- Ninguno.")
    lines += ["", f"## Páginas sin texto ({len(no_text)})", ""]
    if no_text:
        preview = ", ".join(str(p) for p in no_text[:40])
        extra = " …" if len(no_text) > 40 else ""
        lines.append(f"{preview}{extra}")
        lines += ["", "Si son muchas, el PDF es un escaneo y conviene aplicar OCR."]
    else:
        lines.append("Todas las páginas tienen texto.")
    lines += ["", "## Cabeceras y pies eliminados", ""]
    if book.repeated:
        lines += [f"- `{key}`" for key in sorted(book.repeated)[:15]]
        if len(book.repeated) > 15:
            lines.append(f"- … y {len(book.repeated) - 15} más")
    else:
        lines.append("No se detectaron líneas repetidas.")
    lines += ["", "## Capítulos", "", "| # | Título | Páginas | Palabras |", "| --- | --- | --- | --- |"]
    for chapter in book.chapters:
        lines.append(
            f"| {chapter.index:02d} | {chapter.title.replace('|', chr(92) + '|')} | "
            f"{chapter.pages} | {chapter.words:,} |"
        )
    (outdir / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


CATALOG_HEADER = (
    "# Library\n\n"
    "| Book | Author | Chapters | Pages | Added | Read |\n"
    "| --- | --- | --- | --- | --- | --- |\n"
)


def catalog_path(library: Path | None = None) -> Path:
    if library is not None:
        return library / "INDEX.md"
    return Path.home() / ".local" / "share" / "biblioteca" / "INDICE.md"


def update_catalog_file(metadata: dict, outdir: Path, library: Path | None = None) -> None:
    path = catalog_path(library)
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_text(CATALOG_HEADER, encoding="utf-8")
    content = path.read_text(encoding="utf-8")
    if not content.strip():
        path.write_text(CATALOG_HEADER, encoding="utf-8")
        content = CATALOG_HEADER
    book = metadata["book"]
    root = library if library is not None else path.parent
    try:
        link = os.path.relpath(outdir / "README.md", root).replace(os.sep, "/")
    except ValueError:
        link = str(outdir / "README.md")
    if metadata["source"]["sha256"] in content or f"]({link})" in content:
        return
    row = (
        f"| {book['title'].replace('|', '\\|')} | {book['author']} | "
        f"{metadata['stats']['chapters']} | {metadata['source']['pages']} | "
        f"{datetime.now():%Y-%m-%d} | [Read]({link}) |\n"
    )
    with path.open("a", encoding="utf-8") as handle:
        handle.write(row)


def refresh_book_stats(book_dir: Path) -> tuple[int, int]:
    """Recalcula palabras/tablas y reescribe metadata.json y README.md."""
    metadata_path = book_dir / "metadata.json"
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    old_words = int(metadata.get("stats", {}).get("words", 0))
    total_words = 0
    images = 0
    table_rows = 0
    for chapter in metadata["chapters"]:
        path = book_dir / chapter["file"]
        if not path.exists():
            continue
        _, body = split_frontmatter_text(path.read_text(encoding="utf-8"))
        chapter["words"] = word_count(body)
        total_words += chapter["words"]
        images += len(re.findall(r"!\[[^\]]*\]\(", body))
        table_rows += len(re.findall(r"^\|.+\|\s*$", body, flags=re.MULTILINE))
    stats = metadata.setdefault("stats", {})
    stats["words"] = total_words
    stats["images"] = images
    stats["table_rows"] = table_rows
    stats["chapters"] = sum(1 for c in metadata["chapters"] if c.get("kind") == "chapter")
    stats["files"] = len(metadata["chapters"])
    metadata_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_index(book_dir, metadata)
    return old_words, total_words


def reflow_directory(root: Path) -> int:
    """Reescribe los .md ya generados sin releer el PDF (idempotente)."""
    books = sorted({p.parent for p in root.glob("*/metadata.json")})
    if (root / "metadata.json").exists():
        books.append(root)
    if not books:
        print(f"No se encontraron libros convertidos en {root}")
        return 1

    for book_dir in books:
        files = [
            f for f in sorted(book_dir.glob("[0-9]*.md"))
            if f.name != "99-back-matter.md"
        ]
        before = after = changed = 0
        for path in files:
            text = path.read_text(encoding="utf-8")
            before += len(text.splitlines())
            new_text = reflow_markdown(text)
            after += len(new_text.splitlines())
            if new_text != text:
                changed += 1
                path.write_text(new_text, encoding="utf-8")
        old_words, new_words = refresh_book_stats(book_dir)
        print(
            f"{book_dir.name}: líneas {before:,} → {after:,} · "
            f"{changed} archivos · palabras {old_words:,} → {new_words:,}"
        )
    return 0


def list_pending(library: Path) -> int:
    pdf_root = library / "pdf"
    md_root = library / "md"
    if not pdf_root.exists():
        print(f"No existe {pdf_root}")
        return 1
    pending, converted = [], []
    for pdf in sorted(pdf_root.rglob("*.pdf")):
        slug = slugify(pdf.stem)
        if (md_root / slug / "README.md").exists():
            converted.append((pdf, slug))
        else:
            pending.append((pdf, slug))
    print(f"Library: {library}")
    print(f"PDFs: {len(pending) + len(converted)} · convertidos: {len(converted)} · pendientes: {len(pending)}")
    for pdf, slug in pending:
        print(f"  - {pdf.relative_to(library)}  →  md/{slug}")
    return 0


# --------------------------------------------------------------------------- #
# Impresión
# --------------------------------------------------------------------------- #

def analysis_dict(book: Book) -> dict:
    return {
        "source": {
            "path": str(book.path.resolve()),
            "name": book.path.name,
            "pages": book.page_count,
        },
        "book": {"title": book.title, "author": book.author or "Desconocido"},
        "split": {
            "method": book.method,
            "confidence": book.confidence,
            "reason": book.reason,
        },
        "stats": {
            "chars": sum(book.char_counts),
            "body_font_size": book.body_size,
            "pages_without_text": [i + 1 for i, n in enumerate(book.char_counts) if n < 80],
        },
        "chapters": [
            {
                "index": c.index,
                "title": c.title,
                "kind": c.kind,
                "start_page": c.start,
                "end_page": c.end,
            }
            for c in book.chapters
        ],
        "warnings": book.warnings,
    }


def print_analysis(book: Book, outdir: Path | None = None) -> None:
    print(f"\nPDF: {book.path.name} — {book.page_count} páginas")
    print(f"Título: {book.title}")
    print(f"Autor:  {book.author or 'Desconocido'}")
    print(f"Texto:  {sum(book.char_counts):,} caracteres · cuerpo {book.body_size:g} pt")
    print(f"Señal:  {book.method} (confianza {book.confidence})")
    print(f"Motivo: {book.reason}")
    print(f"\nCapítulos detectados ({len(book.chapters)}):")
    for chapter in book.chapters:
        print(f"  [{chapter.index:02d}] pp. {chapter.pages:>9}  {chapter.title}")
    if book.warnings:
        print("\nAvisos:")
        for warning in book.warnings:
            print(f"  ! {warning}")
    if outdir is not None:
        print(f"\nSalida: {outdir}")
        for name in ("README.md", "digest.md", "report.md", "metadata.json"):
            print(f"  {outdir / name}")


def verify_output(outdir: Path) -> int:
    """Comprueba el contrato de salida: archivos, enlaces y cobertura de páginas."""
    metadata_path = outdir / "metadata.json"
    if not metadata_path.exists():
        print(f"FALLO: no existe {metadata_path}")
        return 1
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"FALLO: metadata.json inválido: {exc}")
        return 1

    problems: list[str] = []
    for chapter in metadata.get("chapters", []):
        if not (outdir / chapter["file"]).exists():
            problems.append(f"falta el archivo {chapter['file']}")

    index_path = outdir / metadata.get("files", {}).get("index", "README.md")
    if index_path.exists():
        for link in re.findall(r"\]\(([^)#]+\.md)\)", index_path.read_text(encoding="utf-8")):
            if not (outdir / link).exists():
                problems.append(f"enlace roto en el índice: {link}")
    else:
        problems.append(f"falta el índice {index_path.name}")

    covered: set[int] = set()
    for chapter in metadata.get("chapters", []):
        covered.update(range(int(chapter["start_page"]), int(chapter["end_page"]) + 1))
    total = int(metadata.get("source", {}).get("pages", 0))
    missing = sorted(set(range(1, total + 1)) - covered)
    if missing:
        preview = ", ".join(str(p) for p in missing[:15])
        problems.append(f"{len(missing)} páginas sin asignar ({preview}{' …' if len(missing) > 15 else ''})")

    short = [
        c["file"] for c in metadata.get("chapters", [])
        if c["kind"] == "chapter" and c.get("words", 0) < 120
    ]
    if short:
        problems.append(f"capítulos casi vacíos: {', '.join(short[:5])}")

    if problems:
        print(f"FALLO en {outdir}")
        for problem in problems:
            print(f"  - {problem}")
        return 1
    stats = metadata.get("stats", {})
    print(
        f"OK {outdir}: {stats.get('chapters', 0)} capítulos, "
        f"{stats.get('words', 0):,} palabras, {total} páginas cubiertas"
    )
    return 0


# --------------------------------------------------------------------------- #
# Autotest
# --------------------------------------------------------------------------- #

def _selftest_build_pdf(target: Path) -> None:
    doc = pymupdf.open()
    width, height = 595, 842

    def page(header: str | None, number: int, blocks: list[tuple[str, float, bool]]):
        p = doc.new_page(width=width, height=height)
        if header:
            p.insert_text((72, 40), header, fontsize=8, fontname="helv")
        p.insert_text((520, 800), str(number), fontsize=8, fontname="helv")
        y = 90.0
        for text, size, bold in blocks:
            p.insert_text((72, y), text, fontsize=size, fontname="hebo" if bold else "helv")
            y += size * 2.0
        return p

    def filler(p, lines_count: int = 22):
        text = ("Este es un párrafo de prueba para el autotest de pdf2md. "
                "El texto se repite para simular un cuerpo de libro real. ") * 3
        p.insert_textbox(pymupdf.Rect(72, 130, 523, 760), "\n\n".join([text] * 6)[:2200],
                         fontsize=10, fontname="helv", lineheight=1.35)

    page(None, 1, [("LIBRO DE PRUEBA", 26, True), ("Subtítulo del autotest", 14, False)])
    page(None, 2, [("Índice", 20, True), ("Capítulo 1: El inicio ....... 3", 10, False),
                   ("Capítulo 2: El nudo ......... 5", 10, False),
                   ("Capítulo 3: El final ........ 7", 10, False)])
    chapters = [("Capítulo 1: El inicio", 3), ("Capítulo 2: El nudo", 5), ("Capítulo 3: El final", 7)]
    for title, start in chapters:
        p = page("LIBRO DE PRUEBA", start, [(title, 22, True),
                                            ("Una frase de entrada del capítulo.", 10, False)])
        filler(p)
        for extra in (start + 1, start + 2):
            q = page("LIBRO DE PRUEBA", extra, [("Texto de continuación.", 10, False)])
            filler(q)
    doc.set_metadata({"title": "Libro de prueba", "author": "Autotest"})
    doc.set_toc([[1, title, page] for title, page in chapters])
    doc.save(target)
    doc.close()


def run_selftest() -> int:
    import tempfile

    failures = 0
    with tempfile.TemporaryDirectory(prefix="pdf2md-selftest-") as tmp:
        root = Path(tmp)
        pdf = root / "prueba.pdf"
        _selftest_build_pdf(pdf)
        book = analyze_book(pdf)
        print(f"[1] análisis: {book.method} / {book.confidence} / {len(book.chapters)} capítulos")
        if book.method != "outline" or len(book.chapters) < 4:
            print("    FALLO: se esperaba outline y al menos 4 archivos")
            failures += 1

        outdir = root / "salida"
        metadata = convert_book(book, outdir)
        expected = ["README.md", "digest.md", "report.md", "metadata.json", "00-front-matter.md"]
        for name in expected:
            if not (outdir / name).exists():
                print(f"    FALLO: falta {name}")
                failures += 1
        chapters = [c for c in metadata["chapters"] if c["kind"] == "chapter"]
        print(f"[2] conversión: {len(chapters)} capítulos, {metadata['stats']['words']} palabras")
        if len(chapters) != 3:
            print("    FALLO: se esperaban 3 capítulos")
            failures += 1

        index = (outdir / "README.md").read_text(encoding="utf-8")
        links = re.findall(r"\]\(([^)]+\.md)\)", index)
        for link in links:
            if not (outdir / link).exists():
                print(f"    FALLO: enlace roto -> {link}")
                failures += 1
        print(f"[3] índice: {len(links)} enlaces, todos existentes" if failures == 0 else "[3] índice: con errores")

        digest = (outdir / "digest.md").read_text(encoding="utf-8")
        if "## [01]" not in digest:
            print("    FALLO: digest mal formado")
            failures += 1
        print(f"[4] digest: {len(digest)} caracteres")

        first = next(c for c in metadata["chapters"] if c["kind"] == "chapter")
        body = (outdir / first["file"]).read_text(encoding="utf-8")
        if not body.startswith("---\n") or not re.search(r"^# .+", body, re.MULTILINE):
            print("    FALLO: frontmatter o título ausente")
            failures += 1
        print(f"[5] capítulo: {first['file']} ({len(body)} caracteres)")

        if verify_output(outdir) != 0:
            failures += 1

        book.doc.close()

    print("\nRESULTADO:", "OK" if failures == 0 else f"{failures} fallo(s)")
    return 0 if failures == 0 else 1


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #

def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="pdf2md",
        description="Convierte PDFs a Markdown divididos por capítulos, con índice y metadatos.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Ejemplos:\n"
            "  pdf2md.py libro.pdf --analyze\n"
            "  pdf2md.py libro.pdf -o ~/libros/libro --lang es\n"
            "  pdf2md.py *.pdf --catalog\n"
        ),
    )
    parser.add_argument("pdf", nargs="*", help="archivo(s) PDF de entrada")
    parser.add_argument("-o", "--output", help="carpeta de salida (por defecto: ./<slug>)")
    parser.add_argument("--analyze", action="store_true", help="solo diagnostica, no escribe archivos")
    parser.add_argument(
        "--split",
        default="auto",
        choices=["auto", "outline", "toc", "headings", "pages"],
        help="método de división (por defecto auto: outline → índice → tipografía → páginas)",
    )
    parser.add_argument("--chunk", type=int, default=20, help="páginas por bloque si se usa --split pages")
    parser.add_argument("--lang", default="es", help="idioma esperado (solo informativo)")
    parser.add_argument("--title", help="forzar título del libro")
    parser.add_argument("--author", help="forzar autor")
    parser.add_argument("--force", action="store_true", help="reconvertir aunque ya exista")
    parser.add_argument("--keep-page-markers", action="store_true", help="no borrar líneas de número de página")
    parser.add_argument("--catalog", action="store_true", help="añadir el libro al catálogo global")
    parser.add_argument(
        "--library",
        metavar="DIR",
        help="raíz de la biblioteca (pdf/, md/, notes/, INDEX.md); activa el catálogo",
    )
    parser.add_argument("--pending", action="store_true", help="listar PDFs de la biblioteca sin Markdown")
    parser.add_argument("--json", action="store_true", help="salida JSON (para uso automatizado)")
    parser.add_argument("--verify", metavar="DIR", help="verificar una carpeta ya convertida")
    parser.add_argument(
        "--reflow",
        metavar="DIR",
        help="unir líneas partidas en .md ya generados (no relee el PDF)",
    )
    parser.add_argument("--selftest", action="store_true", help="ejecutar prueba interna")
    parser.add_argument("--version", action="version", version=f"pdf2md {VERSION}")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    if args.selftest:
        return run_selftest()
    if args.verify:
        return verify_output(Path(args.verify).expanduser())
    if args.reflow:
        return reflow_directory(Path(args.reflow).expanduser())
    library = Path(args.library).expanduser() if args.library else None
    if args.pending:
        if library is None:
            print("ERROR: --pending requiere --library DIR", file=sys.stderr)
            return 2
        return list_pending(library)
    if not args.pdf:
        parse_args(["--help"])
        return 2

    failures = 0
    for raw_path in args.pdf:
        path = Path(raw_path).expanduser()
        try:
            book = analyze_book(
                path,
                split_mode=args.split,
                chunk=args.chunk,
                title_override=args.title,
                author_override=args.author,
            )
        except SystemExit as exc:
            print(f"ERROR: {exc}", file=sys.stderr)
            failures += 1
            continue

        if args.analyze:
            if args.json:
                print(json.dumps(analysis_dict(book), ensure_ascii=False, indent=2))
            else:
                print_analysis(book)
            book.doc.close()
            continue

        outdir = Path(args.output).expanduser() if args.output else None
        if outdir is None:
            outdir = (library / "md" / slugify(path.stem)) if library else Path(slugify(path.stem))
        elif len(args.pdf) > 1:
            outdir = outdir / slugify(path.stem)
        if not args.json:
            print_analysis(book, outdir)
        try:
            metadata = convert_book(
                book,
                outdir,
                force=args.force,
                keep_markers=args.keep_page_markers,
                update_catalog=args.catalog or library is not None,
                library=library,
            )
            if args.json:
                print(json.dumps(metadata, ensure_ascii=False, indent=2))
        except Exception as exc:  # noqa: BLE001
            print(f"ERROR convirtiendo {path.name}: {exc}", file=sys.stderr)
            failures += 1
        finally:
            book.doc.close()
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
