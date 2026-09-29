---
paths:
  - "sources.md"
---
# sources.md: the verified claim lines

- Every line is copied verbatim from `docs/cv_master.md` or `docs/pitch_bank.md`
  in the ai-job-hunt repo (`/mnt/c/Users/juanp/projects/ai-job-hunt`). Nothing
  is written here first. If a claim is not in those files, it does not go on
  the page.
- Never edit a line to make a card sentence pass `check.py`. The fix goes in
  `index.html`. If the card wording is better, change the master first (in the
  ai-job-hunt repo, with Juan), then copy the line here.
- Keep the section headers per system (ARIA, EVA, Numetrix (TPP) Text2SQL,
  SRS Summarizer) and the date line at the top updated when lines are added.
- ARIA: four domain agents on one shared engine. The pitch bank wins over the
  CV master when they differ on ARIA.
- Juan's rule for what counts (2026-09-29): anything built, committed and
  delivered is a claim, even if the business later configured something else
  (Neo4j retrieval, all 19 guardrails, Helm charts). Anything that never
  existed in code is not (OpenAI Agents SDK in ARIA, MCP servers in his Iberia
  agents). Do not add "parked", "unused" or "only N of" hedges to the page.
- No em-dashes; the checker scans this file too.
- Adding a line is the `/claim` skill: locate the sentence in the master, copy
  it here, use it in the card, run `python3 check.py --offline`.
