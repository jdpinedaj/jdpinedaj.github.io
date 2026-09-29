---
paths:
  - "check.py"
  - "test_check.py"
---
# check.py and its tests

- Stdlib only (`re`, `html`, `urllib`, `pathlib`, `unittest`). No third-party
  packages, no `requirements.txt`.
- `check.py` exposes pure functions (`card_sentences`, `missing_sentences`,
  `missing_anchors`, `external_links`, `url_ok`, `og_image_path`,
  `has_em_dash`) plus `main(argv)`; new checks follow that shape so they can be
  unit-tested without the network.
- `main([])` runs everything; `main(["--offline"])` skips `url_ok`. The
  post-edit hook runs the offline mode after every edit to the page, the
  sources or the checker; keep it fast (under a few seconds).
- Every check has a failing test and a passing test in `test_check.py`
  (`unittest`, AAA layout, one logical assertion per test). Network calls are
  mocked through the `opener` argument or `mock.patch.object(check, "url_ok")`.
- Sentence matching: strip tags, unescape entities, collapse whitespace,
  lowercase, split on ". ", then require a clause boundary in the source line
  (`.:;` before, `.;` after). Do not loosen the boundary rule to make a card
  pass.
- HTTP 999 (LinkedIn) and 403 (ResearchGate) count as reachable; 404 on HEAD
  does not retry with GET.
  Both are deliberate; `.claude/TODO.md` lists them as decisions to revisit.
- Run with `python3 -m unittest test_check` (about a second) and
  `python3 check.py --offline`.
