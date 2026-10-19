---
paths:
  - "check.py"
  - "test_check.py"
---
# check.py and its tests

- Stdlib only (`re`, `html`, `urllib`, `pathlib`, `unittest`). No third-party
  packages, no `requirements.txt`.
- `check.py` exposes pure functions (`card_sentences`, `missing_sentences`,
  `missing_anchors`, `external_links`, `url_status`, `url_ok`, `og_image_path`,
  `has_em_dash`) plus `main(argv)`; new checks follow that shape so they can be
  unit-tested without the network.
- `main([])` runs everything; `main(["--offline"])` skips `url_ok`. The
  post-edit hook runs the offline mode after every edit to the page, the
  sources or the checker; keep it fast (under a few seconds).
- Every check has a failing test and a passing test in `test_check.py`
  (`unittest`, AAA layout, one logical assertion per test). Network calls are
  mocked through the `opener` argument or `mock.patch.object(check, "url_status")`
  (what `main` calls; `url_ok` is its boolean wrapper).
- Sentence matching: strip tags, unescape entities, collapse whitespace,
  lowercase, split on ". ", then require a clause boundary in the source line
  (`.:;` before, `.;` after). Do not loosen the boundary rule to make a card
  pass.
- Bot blocks count as reachable, scoped by host in `BOT_BLOCKED_CODES`: 999
  anywhere (LinkedIn), 403 on ResearchGate, 403 and 429 on Google Scholar (it
  blocks the GitHub Actions runners). A 404 always fails, and 404 on HEAD does
  not retry with GET. Deliberate; `.claude/TODO.md` lists them as decisions to
  revisit. A failure prints the status: `link not reachable (HTTP 404): <url>`.
- `external_links` unescapes HTML entities (`&amp;`) before the request.
- Run with `python3 -m unittest test_check` (about a second) and
  `python3 check.py --offline`.
