# Portfolio Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A single-page, hand-written portfolio at https://jdpinedaj.github.io/ that a tech lead can read in five minutes, with an architecture diagram per production system and a machine check that every card sentence traces to a verified source.

**Architecture:** One `index.html` holding all content, one `styles.css` with theme tokens on `:root`, one `script.js` under 100 lines for term highlighting, section tracking and theme toggle. Diagrams are inline SVG that use the CSS tokens. `check.py` (stdlib) validates links, anchors, em-dashes, the PDF and the card sentences against `sources.md`.

**Tech Stack:** HTML5, CSS custom properties, vanilla JS, inline SVG, Python 3.11+ stdlib for checks, GitHub Pages from `main` root.

**Spec:** `docs/superpowers/specs/2026-09-29-portfolio-site-design.md`

## Global Constraints

- No em-dash (U+2014) anywhere in any tracked file.
- No framework, no build step, no Node dependency. `script.js` under 100 lines.
- Every sentence in a system card `<dd>` must appear in `sources.md`, which is copied verbatim from `docs/cv_master.md` and `docs/pitch_bank.md` in the ai-job-hunt repo. ARIA has four domain agents, never five.
- Clients named: Johnson & Johnson, Iberia Airlines, The People Platform. No intermediary names.
- Only verified impact number: ARIA, a full working day down to about ten minutes.
- English only. No headshot. CTA is email, LinkedIn, CV PDF.
- Layout works at 375 px wide with 16 px gutters and no horizontal scroll.
- Theme tokens on `:root`; dark overrides under `prefers-color-scheme: dark` guarded by `:root:not([data-theme="light"])` and again under `:root[data-theme="dark"]`.
- Commit messages: plain, no co-author trailers, no AI attribution.

## Review Focus

1. A card sentence edited by hand later drifts from the source: `check.py` must fail with the offending sentence printed. Pinned in Task 1 test `test_sentence_not_in_sources_fails`.
2. `&amp;` in HTML ("Data Science &amp; AI") versus `&` in sources: the check must unescape entities before comparing. Pinned in Task 1 test `test_entities_unescaped`.
3. Sentences ending in a parenthesis or a closing tag, such as "(no API spend).": the splitter must not drop them or leave a trailing tag. Pinned in Task 1 test `test_split_keeps_parenthesised_sentence`.
4. localStorage unavailable (private window): the theme toggle must not throw and the page must still render. Pinned in Task 6 by wrapping in try/catch and probing with a stubbed `localStorage` that throws.
5. External link check hitting a host that rejects HEAD: fall back to GET before reporting failure. Pinned in Task 1 test `test_head_falls_back_to_get`.

---

## File structure

- `index.html`: all page content and metadata. Sections in spec order.
- `styles.css`: tokens, base, header, hero, cards, diagrams, governance grid, timeline, research, contact, footer, responsive rules, reduced motion.
- `script.js`: four small functions run on DOMContentLoaded.
- `og-image.svg`: 1200 by 630 preview image.
- `JuanPineda_CV_AI_LLM.pdf`: copied from ai-job-hunt `assets/cv/`.
- `sources.md`: verified claim lines for the four cards.
- `check.py`: checks; importable functions plus a `main()`.
- `test_check.py`: unittest for the pure functions in `check.py`.
- `README.md`: purpose, how to edit, how to check, how it deploys.
- `.gitignore`: `__pycache__/`, `shots/`.

---

### Task 1: sources.md, check.py and its tests

**Files:**
- Create: `sources.md`, `check.py`, `test_check.py`, `.gitignore`
- Copy: `JuanPineda_CV_AI_LLM.pdf` from `/mnt/c/Users/juanp/projects/ai-job-hunt/assets/cv/JuanPineda_CV_AI_LLM.pdf`

**Interfaces:**
- Produces: `check.py` with `normalise(text) -> str`, `card_sentences(html) -> list[str]`, `missing_sentences(html, sources) -> list[str]`, `anchor_targets(html) -> list[str]`, `missing_anchors(html) -> list[str]`, `external_links(html) -> list[str]`, `url_ok(url, opener=None) -> bool`, `has_em_dash(text) -> bool`, `main() -> int`.
- Card markup contract used by later tasks: each system card contains `<dl class="card-text">` with `<dt>` labels and `<dd>` claim text. Only `<dd>` content is checked.

- [ ] **Step 1: Write sources.md**

Copy the claim lines verbatim from `docs/cv_master.md` and `docs/pitch_bank.md` in the ai-job-hunt repo. Do not paraphrase. Sections: ARIA (pitch bank Tier 2 paragraph, the CV master ARIA intro line, the LLM Safety Framework line, the Engineering & Delivery line, the tech stack line), EVA (the CV master Iberia intro and its six bullet lines plus tech stack), TPP Text2SQL (the CV master TPP intro, Pipeline Architecture, Quality & Auditability and Earlier work lines, the pitch bank "Defence in depth" and "Every turn persisted" sentences, tech stack), Enterprise Text2SQL (the CV master intro, Agent Design and Hexagonal Architecture & Guardrails lines, tech stack). Header comment states the copy date, 2026-09-29.

- [ ] **Step 2: Write the failing tests**

```python
# test_check.py
import unittest
from unittest import mock
import urllib.error

import check


CARD = """
<article class="card">
<dl class="card-text">
<dt>Problem</dt>
<dd>ARIA automates J&amp;J's Architecture Review Board.</dd>
<dt>Architecture</dt>
<dd>Four domain architect agents (Business, Technology, Information,
Data Science &amp; AI) run on a shared <span class="term" data-term="engine">quality-agent engine</span> orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run. A review that took a reviewer a full working day now takes about ten minutes.</dd>
<dd>A full offline regression suite driven by a scripted mock LLM (no API spend).</dd>
</dl>
</article>
"""

SOURCES = """
ARIA automates J&J's Architecture Review Board. Four domain architect agents (Business, Technology, Information, Data Science & AI) run on a shared quality-agent engine orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run. A review that took a reviewer a full working day now takes about ten minutes.
plus a full offline regression suite driven by a scripted mock LLM (no API spend).
"""


class SentenceChecks(unittest.TestCase):
    def test_card_sentences_strip_tags_and_split(self):
        sentences = check.card_sentences(CARD)
        self.assertEqual(len(sentences), 4)
        self.assertTrue(sentences[0].startswith("aria automates"))
        self.assertNotIn("<", "".join(sentences))

    def test_entities_unescaped(self):
        self.assertIn("j&j's", check.card_sentences(CARD)[0])

    def test_split_keeps_parenthesised_sentence(self):
        self.assertEqual(
            check.card_sentences(CARD)[-1],
            "a full offline regression suite driven by a scripted mock llm (no api spend)",
        )

    def test_all_sentences_found(self):
        self.assertEqual(check.missing_sentences(CARD, SOURCES), [])

    def test_sentence_not_in_sources_fails(self):
        html = CARD.replace("about ten minutes", "about five minutes")
        missing = check.missing_sentences(html, SOURCES)
        self.assertEqual(len(missing), 1)
        self.assertIn("five minutes", missing[0])


class LinkChecks(unittest.TestCase):
    HTML = """
    <a href="#systems">S</a><a href="#missing">M</a>
    <section id="systems"></section>
    <a href="https://example.com/a">a</a>
    <a href="mailto:x@y.z">m</a>
    <a href="JuanPineda_CV_AI_LLM.pdf">cv</a>
    """

    def test_anchor_targets_reports_missing(self):
        self.assertEqual(check.missing_anchors(self.HTML), ["#missing"])

    def test_external_links_only_http(self):
        self.assertEqual(check.external_links(self.HTML), ["https://example.com/a"])

    def test_head_falls_back_to_get(self):
        calls = []

        def opener(req, timeout):
            calls.append(req.get_method())
            if req.get_method() == "HEAD":
                raise urllib.error.HTTPError(req.full_url, 405, "nope", {}, None)
            return mock.Mock(status=200)

        self.assertTrue(check.url_ok("https://example.com", opener=opener))
        self.assertEqual(calls, ["HEAD", "GET"])

    def test_url_not_ok_on_404(self):
        def opener(req, timeout):
            raise urllib.error.HTTPError(req.full_url, 404, "gone", {}, None)

        self.assertFalse(check.url_ok("https://example.com/x", opener=opener))


class EmDash(unittest.TestCase):
    def test_detects_em_dash(self):
        self.assertTrue(check.has_em_dash("a " + chr(0x2014) + " b"))
        self.assertFalse(check.has_em_dash("a - b"))


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd /mnt/c/Users/juanp/projects/jdpinedaj.github.io && python3 -m unittest test_check -v`
Expected: ImportError, no tests run.

- [ ] **Step 4: Write check.py**

```python
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
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `python3 -m unittest test_check -v`
Expected: 10 tests, OK.

- [ ] **Step 6: Copy the PDF and write .gitignore**

```bash
cp "/mnt/c/Users/juanp/projects/ai-job-hunt/assets/cv/JuanPineda_CV_AI_LLM.pdf" .
printf '__pycache__/\nshots/\n' > .gitignore
```

- [ ] **Step 7: Commit**

```bash
git add sources.md check.py test_check.py .gitignore JuanPineda_CV_AI_LLM.pdf
git commit -m "Checks: sources, anchors, links, em-dashes, PDF; CV PDF added"
```

---

### Task 2: index.html skeleton, metadata, header, hero, contact, footer

**Files:**
- Create: `index.html`

**Interfaces:**
- Produces: section ids `top`, `systems`, `governance`, `track-record`, `research`, `contact`. Header anchors to `#systems`, `#governance`, `#track-record`, `#contact`. Theme toggle `<button id="theme-toggle">`. The sections filled by Tasks 4, 5 and 7 exist from this task as real `<section>` elements with their ids and `<h2>`, so anchors resolve from now on.

- [ ] **Step 1: Write index.html**

Head, in this order: charset, viewport, title `Juan Pineda-Jaramillo, PhD | AI / LLM Engineer`, description, author, robots `index,follow`, canonical `https://jdpinedaj.github.io/`, `theme-color` `#f6f1ea`, Open Graph (`og:type` website, `og:site_name`, `og:title`, `og:description`, `og:url`, `og:image` `https://jdpinedaj.github.io/og-image.svg`, `og:image:alt`), Twitter card `summary_large_image` with title, description, image, `rel="me"` to `https://www.linkedin.com/in/jdpinedaj/` and `https://github.com/jdpinedaj`, Google Fonts preconnect and one stylesheet link for Newsreader (400, 600, italic 400), Inter (400, 500, 600) and IBM Plex Mono (400, 500) with `display=swap`, then `styles.css`, then `script.js` with `defer`, then the JSON-LD block:

```json
{
  "@context": "https://schema.org",
  "@graph": [
    {"@type": "WebSite", "@id": "https://jdpinedaj.github.io/#website",
     "url": "https://jdpinedaj.github.io/", "name": "Juan Pineda-Jaramillo",
     "publisher": {"@id": "https://jdpinedaj.github.io/#person"}},
    {"@type": "Person", "@id": "https://jdpinedaj.github.io/#person",
     "name": "Juan Pineda-Jaramillo", "alternateName": "Juan Pineda-Jaramillo, PhD",
     "givenName": "Juan", "familyName": "Pineda-Jaramillo", "honorificSuffix": "PhD",
     "url": "https://jdpinedaj.github.io/", "email": "mailto:juandpineda@gmail.com",
     "jobTitle": "AI / LLM Engineer",
     "description": "AI/LLM Engineer with a PhD in applied machine learning, building production multi-agent systems, RAG and LLM governance for regulated enterprises.",
     "address": {"@type": "PostalAddress", "addressLocality": "Valencia", "addressCountry": "ES"},
     "sameAs": ["https://www.linkedin.com/in/jdpinedaj/", "https://github.com/jdpinedaj",
                "https://scholar.google.com/citations?user=cnkQ4gMAAAAJ&hl=en"],
     "knowsAbout": ["Multi-agent systems", "LangGraph", "Retrieval-augmented generation",
                    "Knowledge graphs", "LLM guardrails", "LLM evaluation", "Text2SQL",
                    "Applied machine learning", "Transport and mobility analytics"]}
  ]
}
```

Body:

```html
<a class="skip" href="#systems">Skip to systems</a>
<header class="site-header">
  <a class="brand" href="#top">Juan Pineda-Jaramillo</a>
  <nav class="site-nav" aria-label="Primary">
    <a href="#systems">Systems</a>
    <a href="#governance">Governance</a>
    <a href="#track-record">Track record</a>
    <a href="#contact">Contact</a>
    <button id="theme-toggle" type="button" aria-label="Switch theme">Theme</button>
  </nav>
</header>
<main id="top">
  <section class="hero" aria-labelledby="hero-title">
    <p class="kicker">AI / LLM Engineer</p>
    <h1 id="hero-title">Juan Pineda-Jaramillo, PhD</h1>
    <p class="headline">Production multi-agent systems, RAG, and the governance layer that makes them safe enough for regulated enterprise use.</p>
    <p class="lede">I'm an AI/LLM Engineer currently working for Johnson &amp; Johnson, building multi-agent systems in production. One of them cut an enterprise review process from a full working day down to about ten minutes. Before that I built Iberia Airlines' multi-agent customer service assistant. PhD in applied ML, 14 years in the field.</p>
    <p class="hero-links">
      <a href="mailto:juandpineda@gmail.com">juandpineda@gmail.com</a>
      <a href="https://www.linkedin.com/in/jdpinedaj/">LinkedIn</a>
      <a href="JuanPineda_CV_AI_LLM.pdf">CV (PDF)</a>
    </p>
    <p class="hero-note">Valencia, Spain, working remotely.</p>
  </section>
  <section id="systems" class="section"><h2 class="section-title">Systems</h2></section>
  <section id="governance" class="section"><h2 class="section-title">Governance</h2></section>
  <section id="track-record" class="section"><h2 class="section-title">Track record</h2></section>
  <section id="research" class="section"><h2 class="section-title">Research</h2></section>
  <section id="contact" class="section contact">
    <h2 class="section-title">Contact</h2>
    <p>If you are evaluating me for a role or an engagement and want to talk through any of the systems above, write to me.</p>
    <p class="contact-links">
      <a href="mailto:juandpineda@gmail.com">juandpineda@gmail.com</a>
      <a href="https://www.linkedin.com/in/jdpinedaj/">linkedin.com/in/jdpinedaj</a>
      <a href="JuanPineda_CV_AI_LLM.pdf">Download the CV</a>
    </p>
  </section>
</main>
<footer class="site-footer">
  <p>Valencia, Spain. Built by hand, no framework. <a href="https://github.com/jdpinedaj/jdpinedaj.github.io">Source on GitHub</a>.</p>
</footer>
```

- [ ] **Step 2: Run the checks**

Run: `python3 check.py`
Expected: OK, except the GitHub repo link, which 404s until Task 9 creates the repo. Note it and continue.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Page skeleton: metadata, header, hero, contact, footer"
```

---

### Task 3: styles.css

**Files:**
- Create: `styles.css`

**Interfaces:**
- Produces: tokens `--bg`, `--surface`, `--surface-soft`, `--text`, `--muted`, `--line`, `--accent`, `--accent-soft`, `--font-serif`, `--font-sans`, `--font-mono`, `--radius`, `--content-width`. Classes used by later tasks: `.section`, `.section-title`, `.kicker`, `.lede`, `.hero-note`, `.card`, `.card-diagram`, `.card-text`, `.term`, `.is-active`, `.is-visible`, `.stack`, `.grid-3`, `.timeline`, `.timeline-item`, `.engagements`, `.pubs`. SVG styling via `.diagram .node rect`, `.diagram .node text`, `.diagram .edge`, `.diagram .band`, `.diagram .store`, `.diagram .node.is-active rect`.

- [ ] **Step 1: Write the tokens and base**

```css
:root {
  --bg: #f6f1ea;
  --surface: #fbf8f3;
  --surface-soft: #efe8de;
  --text: #1c1a17;
  --muted: #5f5a52;
  --line: #d9d1c5;
  --accent: #c2531c;
  --accent-soft: #f4dccd;
  --font-serif: "Newsreader", Georgia, "Times New Roman", serif;
  --font-sans: "Inter", "Segoe UI", Helvetica, Arial, sans-serif;
  --font-mono: "IBM Plex Mono", "SFMono-Regular", Consolas, monospace;
  --radius: 14px;
  --content-width: 1100px;
  color-scheme: light;
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg: #15130f; --surface: #1d1a15; --surface-soft: #242019;
    --text: #e9e2d6; --muted: #a39b8f; --line: #332e26;
    --accent: #e07a3f; --accent-soft: #3d2416; color-scheme: dark;
  }
}
:root[data-theme="dark"] {
  --bg: #15130f; --surface: #1d1a15; --surface-soft: #242019;
  --text: #e9e2d6; --muted: #a39b8f; --line: #332e26;
  --accent: #e07a3f; --accent-soft: #3d2416; color-scheme: dark;
}
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0; background: var(--bg); color: var(--text);
  font-family: var(--font-sans); font-size: 17px; line-height: 1.55;
  -webkit-font-smoothing: antialiased;
}
```

Then, in this order, rules for: `.skip` (visually hidden until focused), `.site-header` (sticky, blurred background, flex, wraps on phones), `.brand`, `.site-nav a[aria-current="true"]` (accent underline), `#theme-toggle` (mono, border, no background), `main` (`width: min(100% - 32px, var(--content-width)); margin: 0 auto`), `.hero` (serif `h1` at `clamp(2.2rem, 5vw, 3.4rem)`, `.headline` serif italic 1.35rem, `.lede` max-width 62ch, `.hero-links a` inline pills with accent border), `.section` (padding 56px 0, top border), `.section-title` (serif 1.9rem), `.kicker` (mono, uppercase, letter-spacing 0.14em, accent), `.card` (grid `minmax(0, 1.05fr) minmax(0, 1fr)` gap 32px, surface background, line border, radius, padding 28px, margin-bottom 28px, `opacity: 0; transform: translateY(12px)` until `.is-visible`), `.card-diagram svg` (width 100%, height auto), `.card-text dt` (mono small uppercase muted, margin-top 14px), `.card-text dd` (margin 4px 0 0), `.term` (dotted accent underline, cursor default; `.term.is-active` accent-soft background), `.stack` (mono 0.85rem muted), `.grid-3` (three columns, one on phones, each column surface card with `h3` serif and `ul` plain), `.timeline` (flex row with overflow-x auto on phones; each `.timeline-item` has a mono year, an accent dot on a line, and a label), `.engagements li` (grid `160px 1fr`, one column on phones), `.pubs a` (block links), `.contact-links a` (larger pills), `.site-footer` (muted, mono, small). Diagram rules:

```css
.diagram { font-family: var(--font-mono); font-size: 11px; }
.diagram .node rect { fill: var(--surface-soft); stroke: var(--line); stroke-width: 1.2; rx: 8; transition: stroke .15s, fill .15s; }
.diagram .node text { fill: var(--text); }
.diagram .node.is-active rect, .diagram .node:hover rect { fill: var(--accent-soft); stroke: var(--accent); stroke-width: 1.8; }
.diagram .edge { stroke: var(--muted); stroke-width: 1.2; fill: none; marker-end: url(#arrow); }
.diagram .band rect { fill: none; stroke: var(--accent); stroke-dasharray: 4 4; rx: 10; }
.diagram .band text, .diagram .label { fill: var(--accent); font-size: 10px; letter-spacing: .06em; text-transform: uppercase; }
.diagram .store rect { rx: 4; }
```

Responsive: `@media (max-width: 760px)` collapses `.card` and `.grid-3` to one column, `.engagements li` to one column, header nav wraps. `@media (prefers-reduced-motion: reduce)` disables transitions, sets cards visible, and `scroll-behavior: auto`.

- [ ] **Step 2: Render and check**

Run: `npx --yes playwright screenshot --viewport-size=375,900 --full-page file://$PWD/index.html shots/mobile.png && npx --yes playwright screenshot --viewport-size=1280,900 --full-page file://$PWD/index.html shots/desktop.png`
Then view both PNGs. Expected: no horizontal scroll at 375, header wraps, hero readable in both. If `npx playwright` is unavailable, open `index.html` in a browser at those widths.

- [ ] **Step 3: Commit**

```bash
git add styles.css
git commit -m "Styles: tokens, light and dark themes, layout, diagrams, responsive"
```

---

### Task 4: the four system cards (text)

**Files:**
- Modify: `index.html` (`#systems` section)

**Interfaces:**
- Consumes: `<dl class="card-text">` contract from Task 1; classes from Task 3.
- Produces: four `<article class="card" id="aria|eva|tpp|text2sql">`, each with an empty `<figure class="card-diagram">` that Task 5 fills, and the `data-term` values listed below that Task 5 must match.

- [ ] **Step 1: Write the ARIA card**

```html
<article class="card" id="aria">
  <figure class="card-diagram" aria-label="ARIA architecture diagram"></figure>
  <div>
    <p class="kicker">Johnson &amp; Johnson, pharma</p>
    <h3>ARIA, ARB Intake Verifier</h3>
    <dl class="card-text">
      <dt>Problem</dt>
      <dd><span class="term" data-term="intake">It ingests solution-architecture submissions (PPTX, PDF, DOCX and diagrams)</span>, reviews them against the enterprise standards library and returns a scored, fully cited report, cutting a review that took a reviewer a full working day down to roughly 10 minutes.</dd>
      <dt>Architecture</dt>
      <dd><span class="term" data-term="agents">Four domain architect agents (Business, Technology, Information, Data Science &amp; AI)</span> run on a shared <span class="term" data-term="engine">quality-agent engine</span> orchestrated through <span class="term" data-term="graph">LangGraph state machines</span>, and only the domains the deck flags as architecturally impacted actually run.</dd>
      <dd>The agents negotiate missing evidence over an <span class="term" data-term="a2a">A2A protocol</span> (batched star topology, each peer answers once instead of N-by-N) and revise their own findings with what comes back.</dd>
      <dd>Reasoning is grounded in the LeanIX enterprise architecture inventory (<span class="term" data-term="neo4j">Neo4j graph backend</span>) plus a <span class="term" data-term="pgvector">pgvector store</span> over the standards library; the agents assess slide diagrams directly as multimodal image input.</dd>
      <dt>Governance</dt>
      <dd>Designed and implemented <span class="term" data-term="guardrails">19 production guardrails at every graph node</span>: prompt injection, PII/PHI redaction (Presidio), data-exfiltration and prompt-leakage detection, schema and citation validation, per-run cost and token ceilings, among others. Every finding must cite catalog source IDs; citations are resolved against the catalog and ungrounded rows are dropped or flagged.</dd>
      <dt>Outcome</dt>
      <dd><span class="term" data-term="report">A review that took a reviewer a full working day now takes about ten minutes.</span></dd>
    </dl>
    <p class="stack">Python, LangGraph, LangChain, OpenAI Agents SDK, Azure OpenAI (GPT-5.x), FastAPI, Pydantic, Neo4j, PostgreSQL + pgvector, SQLAlchemy, Docker</p>
  </div>
</article>
```

The Problem `<dd>` starts with "It ingests", a substring of the source sentence, so the check passes. The stack line lives in `<p class="stack">`, outside the checked `<dl>`.

- [ ] **Step 2: Write the EVA card**

Kicker "Iberia Airlines, aviation". Title "EVA, Enhanced Virtual Assistant". Terms: `user`, `guardrail`, `router`, `agents`, `apis`, `mcp`, `models`.

- Problem: "Development of EVA (Enhanced Virtual Assistant), a multi-agent conversational ecosystem powered by LLMs to automate Iberia's customer service operations."
- Architecture, three `<dd>`: "Designed, tuned and deployed OpenAI and AWS Bedrock models for production-grade airline assistants handling check-in, cancellations, flight status, flight documentation and other customer processes." with `models` on "OpenAI and AWS Bedrock models"; "Built modular, hexagonal-architecture-based agents (Check-in, Cancellation, Flight Status, Translator, Tone, Booking, Guardrail) using LangChain and FastAPI with structured I/O through Pydantic schemas." with `agents` on the parenthesised list and `router` on "hexagonal-architecture-based agents"; "Integrated multiple Iberia APIs and implemented secure, scalable interaction via internal tools and custom MCP servers for external system access." with `apis` on "Iberia APIs" and `mcp` on "custom MCP servers".
- Governance: "Created prompt-injection and data-exfiltration detectors ensuring compliant and safe interactions." with `guardrail` on "prompt-injection and data-exfiltration detectors".
- Evaluation (this card has no verified outcome sentence, so the last label is "Evaluation"): "Developed internal evaluation tools for LLM cost tracking, token efficiency, latency and output quality."
- Stack: "Python, LangChain, OpenAI, AWS Bedrock (Nova Pro), FastAPI, Pydantic, DynamoDB, structlog, pytest, GitLab CI/CD".
- The `user` term has no text counterpart; it is a diagram-only node and is excluded from the term parity check in Task 5.

- [ ] **Step 3: Write the TPP card**

Kicker "The People Platform, mobility analytics". Title "TPP Text2SQL". Terms: `memory`, `extract`, `generate`, `execute`, `transform`, `faiss`, `guards`, `audit`.

- Problem: "TPP Text2SQL: production conversational analytics platform over US foot-traffic and mobility data, letting business users run their own analyses in natural language instead of queueing for a data analyst who can write SQL."
- Architecture, three `<dd>`: "Four-stage hexagonal pipeline (query extraction, context-aware SQL generation, secure execution, natural-language transformation) with session memory and multi-turn follow-up resolution, plus FAISS semantic example selection for few-shot SQL generation." with `extract` on "query extraction", `generate` on "context-aware SQL generation", `execute` on "secure execution", `transform` on "natural-language transformation", `memory` on "session memory", `faiss` on "FAISS semantic example selection"; "A case regression suite combining deterministic oracles with an LLM judge, pre-flight validation of extracted entities against the real catalogs, and every turn persisted to a PostgreSQL audit table." with `audit` on "PostgreSQL audit table"; "Earlier work for the same client: scalable algorithms to map US mobility trends and identify home locations, an EMR-based processing pipeline over large geolocation datasets, and the first text2SQL agents (AWS Bedrock Titan, later OpenAI)."
- Governance: "Defence in depth: regex input guard, a parallel LLM safety classifier adding no perceptible latency, a hardened read-only SQL backstop." with `guards` on the list after the colon.
- Auditability: "Every turn persisted to a PostgreSQL audit table."
- Stack: the TPP tech stack line from sources.

- [ ] **Step 4: Write the Enterprise Text2SQL card**

Kicker "Johnson &amp; Johnson, self-serve analytics". Title "Enterprise Text2SQL Agent". Terms: `agent`, `llmport`, `dbport`, `db`, `validation`, `mock`.

- Problem: "Enterprise Text2SQL Agent: self-serve natural-language querying of enterprise databases, so business users get answers without depending on a SQL-fluent data analyst."
- Architecture, two `<dd>`: "A single tool-calling agent that discovers the schema at runtime, writes read-only SQL and recovers from its own errors by receiving database failures back as tool results; onboarding a new database is a connection-string change, with zero schema-specific prompt engineering." with `agent` on "A single tool-calling agent" and `db` on "receiving database failures back as tool results"; "The agent depends only on LLMPort and DatabasePort contracts, so switching LLM vendor or database platform means writing an adapter" with `llmport` on "LLMPort" and `dbport` on "DatabasePort".
- Governance: "read-only SQL validation, step budget and row caps, plus a full offline regression suite driven by a scripted mock LLM (no API spend)." with `validation` on "read-only SQL validation, step budget and row caps" and `mock` on "scripted mock LLM". Lowercase "read-only" at the start is intentional: it is a substring of the source and the check lowercases anyway.
- Stack: "Python, Azure OpenAI, LangChain, SQLAlchemy, Pydantic, structlog, pytest".

- [ ] **Step 5: Run the checks**

Run: `python3 check.py`
Expected: OK, or only the GitHub repo link failing (created in Task 9). Any "card sentence not in sources.md" line means a sentence drifted; fix the card, not the sources.

- [ ] **Step 6: Commit**

```bash
git add index.html
git commit -m "Systems: four cards with sourced text and term markup"
```

---

### Task 5: the four diagrams

**Files:**
- Modify: `index.html` (each `<figure class="card-diagram">`)

**Interfaces:**
- Consumes: `data-term` values from Task 4, diagram CSS classes from Task 3.
- Produces: one inline `<svg class="diagram" viewBox="0 0 560 360" role="img" aria-labelledby="...">` per card, each with a `<title>`, and `<g class="node" data-term="...">` groups. The arrow marker `<defs><marker id="arrow">` is declared once in the first SVG; markers resolve document-wide.

Node pattern, repeated by hand:

```html
<g class="node" data-term="engine" tabindex="0">
  <rect x="200" y="150" width="160" height="40"/>
  <text x="280" y="175" text-anchor="middle">shared quality engine</text>
</g>
```

Edge pattern: `<path class="edge" d="M 120 170 L 196 170"/>`. Store pattern: same as node with `class="node store"`. Band pattern: `<g class="node band" data-term="guardrails"><rect x="10" y="60" width="540" height="250"/><text x="20" y="52">19 guardrails at every node boundary</text></g>`.

- [ ] **Step 1: ARIA diagram** (terms `intake`, `graph`, `agents`, `engine`, `a2a`, `neo4j`, `pgvector`, `guardrails`, `report`)

`intake` node at left, arrow to `graph` node "LangGraph state machine". From `graph`, four `agents` nodes stacked vertically (Business, Technology, Information, Data Science & AI), all four in one `data-term="agents"` group. Beneath them the `engine` node "shared quality-agent engine". An `a2a` group: a small hub between the four agents with thin edges to each, labelled "A2A star". At the right, two `store` nodes `neo4j` "Neo4j (LeanIX inventory)" and `pgvector` "pgvector (standards)", edges from the agents. `report` node "cited report" at bottom right. The `guardrails` band surrounds everything from `graph` to `report`.

- [ ] **Step 2: EVA diagram** (terms `user`, `guardrail`, `router`, `agents`, `apis`, `mcp`, `models`)

`user` at left, arrow to `guardrail` node "Guardrail agent", arrow to `router`. From `router`, six `agents` nodes in a 2 by 3 grid (Check-in, Cancellation, Flight Status, Translator, Tone, Booking) in one group. Right column: `apis` store "Iberia APIs" and `mcp` store "custom MCP servers", edges from the agent grid. Bottom: `models` node "OpenAI / AWS Bedrock Nova Pro" spanning the width under the agents, label "model layer".

- [ ] **Step 3: TPP diagram** (terms `memory`, `extract`, `generate`, `execute`, `transform`, `faiss`, `guards`, `audit`)

Four stage nodes in a row (`extract`, `generate`, `execute`, `transform`), arrows between them. `memory` store above `extract` with an edge down. `faiss` store above `generate` with an edge down. `guards` group: three small labelled nodes under the row ("regex guard", "parallel LLM classifier", "read-only SQL backstop"), all in one `data-term="guards"` group with the label "defence in depth". `audit` store at the far right below `transform`, "PostgreSQL audit table", edge from `transform`.

- [ ] **Step 4: Enterprise Text2SQL diagram** (terms `agent`, `llmport`, `dbport`, `db`, `validation`, `mock`)

`agent` node in the centre "tool-calling agent". Two edges out: left to `llmport` node "LLMPort", right to `dbport` node "DatabasePort". Beyond `llmport`, two adapters: "Azure OpenAI" (plain node, no term) and `mock` "scripted mock LLM (tests)". Beyond `dbport`, the `db` store "enterprise database" with a curved return edge back to the agent labelled "errors as tool results". `validation` node on the `dbport` to `db` edge: "read-only SQL, step budget, row caps".

- [ ] **Step 5: Render and check**

Run the two screenshot commands from Task 3 Step 2 and view them. Expected: every diagram legible at 375 px (labels not overlapping, nothing clipped), and every `data-term` in a card's text has a matching node. Verify with:

```bash
python3 - <<'EOF'
import re
html = open("index.html", encoding="utf-8").read()
for cid, body in re.findall(r'<article class="card" id="(\w+)">(.*?)</article>', html, re.S):
    text_terms = set(re.findall(r'<span class="term" data-term="([^"]+)"', body))
    node_terms = set(re.findall(r'<g class="[^"]*node[^"]*" data-term="([^"]+)"', body))
    print(cid, "text-only:", text_terms - node_terms, "node-only:", node_terms - text_terms)
EOF
```

Expected: every "text-only" set empty; "node-only" empty except `{'user'}` on eva. Then `python3 check.py`.

- [ ] **Step 6: Commit**

```bash
git add index.html
git commit -m "Diagrams: inline SVG for ARIA, EVA, TPP and Enterprise Text2SQL"
```

---

### Task 6: script.js

**Files:**
- Create: `script.js`

**Interfaces:**
- Consumes: `[data-term]` elements inside `.card`, `.site-nav a[href^="#"]`, `section[id]`, `#theme-toggle`.

- [ ] **Step 1: Write script.js**

```js
(function () {
  "use strict";

  function highlightTerms() {
    var items = document.querySelectorAll("[data-term]");
    Array.prototype.forEach.call(items, function (el) {
      var card = el.closest(".card");
      if (!card) return;
      var term = el.getAttribute("data-term");
      var peers = card.querySelectorAll('[data-term="' + term + '"]');
      function set(on) {
        Array.prototype.forEach.call(peers, function (p) {
          p.classList.toggle("is-active", on);
        });
      }
      el.addEventListener("mouseenter", function () { set(true); });
      el.addEventListener("mouseleave", function () { set(false); });
      el.addEventListener("focus", function () { set(true); });
      el.addEventListener("blur", function () { set(false); });
      if (el.classList.contains("term") && !el.hasAttribute("tabindex")) {
        el.setAttribute("tabindex", "0");
      }
    });
  }

  function trackSections() {
    var links = document.querySelectorAll('.site-nav a[href^="#"]');
    var sections = document.querySelectorAll("section[id]");
    if (!("IntersectionObserver" in window) || !links.length) return;
    var byId = {};
    Array.prototype.forEach.call(links, function (a) {
      byId[a.getAttribute("href").slice(1)] = a;
    });
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        Array.prototype.forEach.call(links, function (a) {
          a.removeAttribute("aria-current");
        });
        var link = byId[entry.target.id];
        if (link) link.setAttribute("aria-current", "true");
      });
    }, { rootMargin: "-40% 0px -55% 0px" });
    Array.prototype.forEach.call(sections, function (s) { observer.observe(s); });
  }

  function revealCards() {
    var cards = document.querySelectorAll(".card");
    if (!("IntersectionObserver" in window)) {
      Array.prototype.forEach.call(cards, function (c) { c.classList.add("is-visible"); });
      return;
    }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });
    Array.prototype.forEach.call(cards, function (c) { observer.observe(c); });
  }

  function themeToggle() {
    var button = document.getElementById("theme-toggle");
    if (!button) return;
    var root = document.documentElement;
    function stored() {
      try { return localStorage.getItem("theme"); } catch (e) { return null; }
    }
    function current() {
      var s = stored();
      if (s === "dark" || s === "light") return s;
      return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }
    function apply(theme) {
      root.setAttribute("data-theme", theme);
      button.textContent = theme === "dark" ? "Light" : "Dark";
    }
    apply(current());
    button.addEventListener("click", function () {
      var next = current() === "dark" ? "light" : "dark";
      try { localStorage.setItem("theme", next); } catch (e) { /* private window */ }
      apply(next);
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    highlightTerms();
    trackSections();
    revealCards();
    themeToggle();
  });
})();
```

Note: when `localStorage` throws, `current()` falls back to the system setting on every call, so the toggle flips visually but does not persist. That is the intended degradation.

- [ ] **Step 2: Verify line count and behaviour**

Run: `wc -l script.js` Expected: under 100.

Behaviour probe with headless Chromium, including the throwing-localStorage case:

```bash
mkdir -p shots && cat > shots/probe.js <<'EOF'
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.addInitScript(() => {
    Object.defineProperty(window, 'localStorage', { get() { throw new Error('blocked'); } });
  });
  const errors = [];
  page.on('pageerror', e => errors.push(String(e)));
  await page.goto('file://' + process.cwd() + '/index.html');
  await page.hover('#aria .term[data-term="engine"]');
  const active = await page.$$eval('#aria .node.is-active', els => els.length);
  const before = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
  await page.click('#theme-toggle');
  const after = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
  console.log(JSON.stringify({ errors, activeNodes: active, before, after }));
  await browser.close();
})();
EOF
node shots/probe.js
```

Expected: `errors` empty, `activeNodes` 1, `before` and `after` different. If `require('playwright')` fails, run `npm --prefix shots install playwright` and re-run with `NODE_PATH=shots/node_modules`.

- [ ] **Step 3: Commit**

```bash
git add script.js
git commit -m "Script: term highlighting, section tracking, card reveal, theme toggle"
```

---

### Task 7: Governance, Track record and Research sections

**Files:**
- Modify: `index.html` (`#governance`, `#track-record`, `#research`)

**Interfaces:**
- Consumes: `.grid-3`, `.timeline`, `.timeline-item`, `.engagements`, `.pubs`, `.lede`, `.hero-note` from Task 3.

- [ ] **Step 1: Governance**

```html
<section id="governance" class="section">
  <h2 class="section-title">Governance</h2>
  <p class="lede">Anyone can wire up LangGraph. The part that is hard to claim is what keeps it safe in a regulated environment.</p>
  <div class="grid-3">
    <div>
      <h3>Guardrails</h3>
      <ul>
        <li>Prompt-injection detection, regex and semantic</li>
        <li>PII/PHI redaction with Presidio and spaCy</li>
        <li>Data-exfiltration and system-prompt-leakage blocking</li>
        <li>Schema and citation validation</li>
        <li>Per-run cost and token ceilings, model-version pinning</li>
        <li>Immutable hashed audit trails</li>
      </ul>
    </div>
    <div>
      <h3>Evaluation</h3>
      <ul>
        <li>Ground-truth eval harnesses</li>
        <li>Deterministic oracles combined with LLM-as-judge</li>
        <li>Adversarial red-team corpora</li>
        <li>Offline regression suites driven by mock LLMs</li>
      </ul>
    </div>
    <div>
      <h3>Observability</h3>
      <ul>
        <li>Tracing with Arize Phoenix, OpenTelemetry and LangSmith</li>
        <li>Per-run token, latency and cost tracking</li>
        <li>Structured logging, containerised FastAPI services, Kubernetes and Helm</li>
      </ul>
    </div>
  </div>
</section>
```

Every bullet paraphrases the CV master's LLM Safety, Evaluation and MLOps lines. Nothing new.

- [ ] **Step 2: Track record**

Timeline items, each `<li class="timeline-item"><span class="year">2011</span><span class="label">Civil engineering, Colombia</span></li>`: 2011 "Civil engineering, Colombia"; 2013 "Transport engineering, Medellín public agencies"; 2017 "PhD, applied ML, Valencia"; 2019 "Rail and freight ML, Luxembourg"; 2021 "Mining and retail, Chile"; 2022 "Finance and HR tech"; 2023 "Mobility analytics and Text2SQL, US"; 2024 "Aviation, Iberia multi-agent assistant"; 2025 "Pharma, J&J agentic systems". Years follow the CV order and the education dates, not exact contract dates; a `<p class="hero-note">` under the list says "In order, not to scale."

Engagements list, `<ul class="engagements">`, one `<li>` each as `<span>Client</span><span>What was built</span>`:

- Codelco, Chile: recommendation system and mixed linear programming model to optimise operation of the Chuquicamata mine; Kedro pipelines on Azure Databricks.
- Falabella.com, Chile: collaborative-filtering recommendation system with an automated pipeline from warehouse extraction to model deployment.
- Pirani Risk, Colombia: anti-money-laundering product using PCA and Birch clustering over bank clients.
- Energage, US: customer churn prediction model informing retention decisions.
- CFL Multimodal, Luxembourg: ML models predicting disruptions in rail intermodal operations across EU nations, with MLOps pipelines.
- MetroValencia and Logitren, Spain: energy consumption prediction and optimisation for metro and freight trains.
- Government of Antioquia and Medellín, Colombia: railway feasibility studies and the transport chapter of the regional development plan.

- [ ] **Step 3: Research**

```html
<section id="research" class="section">
  <h2 class="section-title">Research</h2>
  <p>PhD in applied machine learning, Universitat Politècnica de València, cum laude. Postdoc at the University of Luxembourg. 56 peer-reviewed publications.</p>
  <ul class="pubs">
    <li><a href="https://scholar.google.com/citations?user=cnkQ4gMAAAAJ&amp;hl=en">Google Scholar profile</a></li>
    <li><a href="https://ieeexplore.ieee.org/abstract/document/10241468">Tourist satisfaction and transport systems (IEEE)</a></li>
    <li><a href="https://doi.org/10.1016/j.trpro.2023.02.188">Urban metro satisfaction, topic modelling (Transportation Research Procedia)</a></li>
  </ul>
</section>
```

- [ ] **Step 4: Run the checks and screenshots**

Run: `python3 check.py` and the two screenshot commands. Expected: OK (GitHub repo link aside); timeline scrolls horizontally on phones without widening the page.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "Governance grid, track record timeline and engagements, research strip"
```

---

### Task 8: og-image.svg and README

**Files:**
- Create: `og-image.svg`, `README.md`

- [ ] **Step 1: og-image.svg**

1200 by 630, paper background `#f6f1ea`, an accent bar on the left, name in serif at 72px, headline in sans at 34px, a mono footer line "jdpinedaj.github.io". Fonts referenced by family with system fallbacks, since preview renderers do not load web fonts.

- [ ] **Step 2: README.md**

Sections: what the site is (one paragraph), files (one line each), how to edit (edit `index.html`, keep card sentences verbatim from `sources.md`, run `python3 check.py` before pushing), how to run the unit tests (`python3 -m unittest test_check`), how it deploys (GitHub Pages from `main` root, live within a minute of pushing).

- [ ] **Step 3: Commit**

```bash
git add og-image.svg README.md
git commit -m "Preview image and README"
```

---

### Task 9: publish

**Files:** none new.

- [ ] **Step 1: Final checks**

Run: `python3 -m unittest test_check && python3 check.py` (expect only the GitHub repo link to fail, if anything) and the screenshot pass at 375 and 1280 in both themes. Force dark with `--color-scheme=dark` on the playwright screenshot command.

- [ ] **Step 2: Create the repo and push**

```bash
gh repo create jdpinedaj/jdpinedaj.github.io --public --source=. --remote=origin --push
gh api -X POST repos/jdpinedaj/jdpinedaj.github.io/pages -f "source[branch]=main" -f "source[path]=/" || true
```

The second command enables Pages; GitHub enables user sites automatically on first push, so a 409 from it is fine.

- [ ] **Step 3: Verify live**

```bash
for i in 1 2 3 4 5 6; do sleep 20; curl -s -o /dev/null -w "%{http_code}\n" https://jdpinedaj.github.io/ | grep -q 200 && break; done
curl -s https://jdpinedaj.github.io/ | grep -c "ARIA, ARB Intake Verifier"
python3 check.py
```

Expected: 200, count 1, `OK` from check.py now that the repo link resolves.

- [ ] **Step 4: Rich Results and preview**

Open https://search.google.com/test/rich-results?url=https://jdpinedaj.github.io/ in a browser and confirm a Person entity is detected. Paste the URL into a chat client to confirm the preview. These are manual and are reported as done or not done, never assumed.
