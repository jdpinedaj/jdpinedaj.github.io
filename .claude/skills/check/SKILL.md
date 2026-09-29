---
name: check
description: Run the full verification of the page (unit tests, offline checks and the external link check) and report the output verbatim. Use before a merge to main, after a content change, or when Juan asks whether the site is in a good state.
allowed-tools: Bash(python3 -m unittest:*), Bash(python3 check.py:*), Read, Grep
---
# Full check

Run both, in order, and quote the real output. Never report green from memory.

1. `python3 -m unittest test_check` (about a second; every test passes).
2. `python3 check.py` (with the network). Expected last line: `OK`.

What each failure means:
- `card sentence not in sources.md: ...`: a card was reworded. Fix `index.html`
  to match the source line (`/claim` if the claim is new). Never edit
  `sources.md` to make it pass.
- `em-dash in <file>`: replace with a comma, colon, full stop or parentheses.
- `anchor without target`: a header link or in-page link points to a missing
  `id`.
- `link not reachable`: retry once; if it still fails, check the URL by hand
  before changing it (LinkedIn answers 999 and counts as reachable).
- `og:image ...`: the preview image must be the PNG and must exist.
- `missing or too small: JuanPineda_CV_AI_LLM.pdf`: the CV was moved or
  replaced by a placeholder.

Report: the two commands, their last lines, and the fix applied to each
failure. If either did not run, say so; the check is not done.
