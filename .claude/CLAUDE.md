# jdpinedaj.github.io

Juan Pineda-Jaramillo's portfolio: one hand-written page (index.html, styles.css,
script.js), no framework, no build step, served by GitHub Pages from the root of
`main`. Live at https://jdpinedaj.github.io/. The reader is a tech lead or hiring
manager who receives the link from an intermediary and has five minutes.

Public repository. Nothing under `.claude/` may carry information that is not
already on the page: no rates, no intermediary names, no pitch material.

## The two rules the checker enforces

1. Every sentence inside a system card (`<dl class="card-text">`) appears verbatim
   in `sources.md`. Change the card to match the source, never the source to match
   the card. New claims enter `sources.md` only from the CV master or pitch bank in
   the ai-job-hunt repo (`/claim`), and only if they are true.
2. No em-dashes (U+2014) anywhere in the repository. A hook blocks them on write.

Facts that are fixed: ARIA has four domain agents on one shared engine, never five.
The only verified impact number is ARIA's (a full working day down to about ten
minutes). SRS Summarizer is a proof of concept, not production, and is not agentic.
Clients named: Johnson & Johnson, Iberia Airlines, The People Platform (Numetrix).

## Commands

```bash
python3 -m unittest test_check      # 19 tests, under a second
python3 check.py --offline          # every check except external links
python3 check.py                    # the same plus link reachability (network)
node shots/shoot.js 375 shots/m.png [dark]   # screenshot (PNGs are gitignored)
```

The spec in `.claude/superpowers/specs/2026-09-29-portfolio-site-design.md` (kept
out of git: it names the intermediaries the page does not) is the reference for
layout, tokens, metadata and out-of-scope items.

## How to work here

- Work on a branch; `main` only receives merges and is what Pages serves. A hook
  refuses edits and commits on `main`. Deploy = `/deploy`.
- Commits: plain subject that says what changed, no tool attribution, no trailers.
- Juan writes in Spanish; answer in Spanish. Page, code, commits and docs in English.
- Path-scoped conventions load from `rules/` when you open the matching file.
  Playbooks: `/check`, `/shots`, `/claim`, `/deploy`. Read-only reviewer: agent
  `page-reviewer`, run before calling a layout or content change done.
- If a hook blocks an action, fix the cause; do not look for another way to run it.
- `.claude/TODO.md` (gitignored) holds the open items and the decisions worth
  revisiting; `.claude/superpowers/` (gitignored) holds specs and plans.
