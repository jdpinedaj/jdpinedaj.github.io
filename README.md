# jdpinedaj.github.io

Portfolio of Juan Pineda-Jaramillo, PhD, AI / LLM Engineer. One hand-written
page, no framework, no build step. Live at https://jdpinedaj.github.io/.

The page is written for the tech lead or hiring manager who receives the link
from an intermediary and has five minutes: what Juan builds, how four production
systems are put together (architecture diagram per system), what keeps them
safe, and how to get in touch.

## Files

- `index.html`: the whole page, content and metadata.
- `styles.css`: theme tokens on `:root`, light and dark, layout, diagrams.
- `script.js`: term-to-diagram highlighting, section tracking, theme toggle,
  card reveal. Under 100 lines. The page reads correctly without it.
- `og-image.svg`: link preview image.
- `JuanPineda_CV_AI_LLM.pdf`: the generic AI/LLM CV linked from the page.
- `sources.md`: the verified claim lines the four system cards may use.
- `check.py`: pre-push checks. `test_check.py`: unit tests for it.
- `docs/superpowers/`: design spec and implementation plan.

## Editing

Edit `index.html` directly. Two rules:

1. Every sentence inside a system card's `<dl class="card-text">` must appear
   verbatim in `sources.md`. Change the card to match the source, never the
   source to match the card. Add a new verified line to `sources.md` only
   after it exists in the CV master.
2. No em-dashes anywhere.

Before pushing:

```
python3 -m unittest test_check
python3 check.py            # add --offline to skip the network link check
```

`check.py` fails on em-dashes, broken in-page anchors, unreachable external
links, a missing CV PDF, and any card sentence that is not in `sources.md`.

## Deploy

GitHub Pages serves the `main` branch root. A push is live within about a
minute.
