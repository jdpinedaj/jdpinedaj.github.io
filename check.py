"""Pre-push checks for jdpinedaj.github.io. Stdlib only.

Run: python3 check.py
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


def normalise(text: str) -> str:
    """Strip tags, unescape entities, collapse whitespace, lowercase."""
    text = re.sub(r"<[^>]+>", "", text)
    text = html_lib.unescape(text)
    return re.sub(r"\s+", " ", text).strip().lower()


def card_sentences(html: str) -> list[str]:
    """Every sentence inside a <dd> within a <dl class="card-text">."""
    sentences: list[str] = []
    for block in re.findall(r'<dl class="card-text">(.*?)</dl>', html, re.S):
        for dd in re.findall(r"<dd>(.*?)</dd>", block, re.S):
            for piece in normalise(dd).split(". "):
                piece = piece.strip().rstrip(".").strip()
                if piece:
                    sentences.append(piece)
    return sentences


def missing_sentences(html: str, sources: str) -> list[str]:
    haystack = normalise(sources)
    return [s for s in card_sentences(html) if s not in haystack]


def anchor_targets(html: str) -> list[str]:
    return re.findall(r'href="(#[^"]+)"', html)


def missing_anchors(html: str) -> list[str]:
    ids = set(re.findall(r'\bid="([^"]+)"', html))
    return [a for a in anchor_targets(html) if a[1:] not in ids]


def external_links(html: str) -> list[str]:
    seen: list[str] = []
    for url in re.findall(r'href="(https?://[^"]+)"', html):
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
            if err.code == 404 or method == "GET":
                return False
        except (urllib.error.URLError, TimeoutError, OSError):
            if method == "GET":
                return False
    return False


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


def main() -> int:
    failures: list[str] = []
    html = INDEX.read_text(encoding="utf-8")

    for path in tracked_text_files():
        if has_em_dash(path.read_text(encoding="utf-8")):
            failures.append(f"em-dash in {path.relative_to(ROOT)}")

    for anchor in missing_anchors(html):
        failures.append(f"anchor without target: {anchor}")

    if not PDF.exists() or PDF.stat().st_size < 10_000:
        failures.append(f"missing or too small: {PDF.name}")

    for sentence in missing_sentences(html, SOURCES.read_text(encoding="utf-8")):
        failures.append(f"card sentence not in sources.md: {sentence}")

    for url in external_links(html):
        if not url_ok(url):
            failures.append(f"link not reachable: {url}")

    for failure in failures:
        print("FAIL", failure)
    print("OK" if not failures else f"{len(failures)} failure(s)")
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
