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
- Keep the section headers per system (ARIA, EVA, TPP Text2SQL, Enterprise
  Text2SQL) and the date line at the top updated when lines are added.
- ARIA: four domain agents on one shared engine. The pitch bank wins over the
  CV master when they differ on ARIA.
- No em-dashes; the checker scans this file too.
- Adding a line is the `/claim` skill: locate the sentence in the master, copy
  it here, use it in the card, run `python3 check.py --offline`.
