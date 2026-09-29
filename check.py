"""Pre-push checks for jdpinedaj.github.io. Stdlib only.

Run: python3 check.py            (everything, including external links)
     python3 check.py --offline  (everything except the network link check)
Exit code 0 when everything passes, 1 otherwise.
"""
from __future__ import annotations

import html as html_lib
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).parent
INDEX = ROOT / "index.html"
SOURCES = ROOT / "sources.md"
PDF = ROOT / "JuanPineda_CV_AI_LLM.pdf"
TEXT_SUFFIXES = {".html", ".css", ".js", ".md", ".py", ".svg", ".txt"}
EM_DASH = chr(0x2014)
MIN_CARD_BLOCKS = 4
MIN_CARD_SENTENCES = 20


def normalise(text: str) -> str:
    """Strip tags, unescape entities, collapse whitespace, lowercase."""
    text = re.sub(r"<[^>]+>", "", text)
    text = html_lib.unescape(text)
    return re.sub(r"\s+", " ", text).strip().lower()


CARD_BLOCK = re.compile(r'<dl\b[^>]*class="[^"]*\bcard-text\b[^"]*"[^>]*>(.*?)</dl>', re.S)
DD = re.compile(r"<dd\b[^>]*>(.*?)</dd>", re.S)
BOUNDARY_BEFORE = ".:;"
BOUNDARY_AFTER = ".;"


def card_blocks(html: str) -> int:
    return len(CARD_BLOCK.findall(html))


def card_sentences(html: str) -> list[str]:
    """Every sentence inside a <dd> within a <dl class="card-text">."""
    sentences: list[str] = []
    for block in CARD_BLOCK.findall(html):
        for dd in DD.findall(block):
            for piece in normalise(dd).split(". "):
                piece = piece.strip().rstrip(".").strip()
                if piece:
                    sentences.append(piece)
    return sentences


def sentence_in_sources(sentence: str, lines: list[str]) -> bool:
    """True when the sentence sits on a clause boundary of one source line.

    A match must start at the line start or after '.', ':' or ';' and end at
    the line end or before '.' or ';'. That accepts a claim that follows a
    'Label:' prefix and rejects a truncated sentence.
    """
    for line in lines:
        start = line.find(sentence)
        while start != -1:
            before = line[:start].rstrip()
            after = line[start + len(sentence):].lstrip()
            ok_before = before == "" or before[-1] in BOUNDARY_BEFORE
            ok_after = after == "" or after[0] in BOUNDARY_AFTER
            if ok_before and ok_after:
                return True
            start = line.find(sentence, start + 1)
    return False


def missing_sentences(html: str, sources: str) -> list[str]:
    lines = [normalise(line) for line in sources.splitlines() if line.strip()]
    return [s for s in card_sentences(html) if not sentence_in_sources(s, lines)]


def anchor_targets(html: str) -> list[str]:
    return re.findall(r'href="(#[^"]+)"', html)


def missing_anchors(html: str) -> list[str]:
    ids = set(re.findall(r'\bid="([^"]+)"', html))
    return [a for a in anchor_targets(html) if a[1:] not in ids]


def external_links(html: str) -> list[str]:
    seen: list[str] = []
    for url in re.findall(r'<a\s[^>]*href="(https?://[^"]+)"', html):
        if url not in seen:
            seen.append(url)
    return seen


def _default_opener(req: urllib.request.Request, timeout: float):
    return urllib.request.urlopen(req, timeout=timeout)


def url_ok(url: str, opener=None, timeout: float = 10.0) -> bool:
    opener = opener or _default_opener
    headers = {"User-Agent": "Mozilla/5.0 (check.py; jdpinedaj.github.io)"}
    for method in ("HEAD", "GET"):
        req = urllib.request.Request(url, method=method, headers=headers)
        try:
            resp = opener(req, timeout)
            if 200 <= resp.status < 400:
                return True
        except urllib.error.HTTPError as err:
            if err.code == 999:
                return True  # LinkedIn's anti-bot answer: the page exists, bots are refused
            if err.code == 404 or method == "GET":
                return False
        except (urllib.error.URLError, TimeoutError, OSError):
            if method == "GET":
                return False
    return False


def og_image_path(html: str) -> str | None:
    """Local filename of the og:image, or None when it is not a raster image."""
    m = re.search(r'<meta property="og:image" content="[^"]*/([^"/]+)"', html)
    if not m or not m.group(1).lower().endswith((".png", ".jpg", ".jpeg")):
        return None
    return m.group(1)


def has_em_dash(text: str) -> bool:
    return EM_DASH in text


def tracked_text_files() -> list[Path]:
    return [
        p
        for p in ROOT.rglob("*")
        if p.is_file()
        and p.suffix in TEXT_SUFFIXES
        and ".git" not in p.parts
        and ".superpowers" not in p.parts
        and "__pycache__" not in p.parts
        and "shots" not in p.parts
    ]


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    offline = "--offline" in args
    failures: list[str] = []
    html = INDEX.read_text(encoding="utf-8")

    for path in tracked_text_files():
        if has_em_dash(path.read_text(encoding="utf-8")):
            failures.append(f"em-dash in {path.relative_to(ROOT)}")

    og = og_image_path(html)
    if og is None:
        failures.append("og:image must be a PNG or JPEG (chat clients do not unfurl SVG)")
    elif not (ROOT / og).exists():
        failures.append(f"og:image file missing: {og}")

    for anchor in missing_anchors(html):
        failures.append(f"anchor without target: {anchor}")

    if not PDF.exists() or PDF.stat().st_size < 10_000:
        failures.append(f"missing or too small: {PDF.name}")

    blocks = card_blocks(html)
    if blocks < MIN_CARD_BLOCKS:
        failures.append(f"only {blocks} card-text block(s) found, expected {MIN_CARD_BLOCKS}")
    sentences = card_sentences(html)
    if len(sentences) < MIN_CARD_SENTENCES:
        failures.append(f"only {len(sentences)} card sentence(s) found, expected at least {MIN_CARD_SENTENCES}")
    for sentence in missing_sentences(html, SOURCES.read_text(encoding="utf-8")):
        failures.append(f"card sentence not in sources.md: {sentence}")

    if not offline:
        for url in external_links(html):
            if not url_ok(url):
                failures.append(f"link not reachable: {url}")

    for failure in failures:
        print("FAIL", failure)
    print("OK" if not failures else f"{len(failures)} failure(s)")
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
