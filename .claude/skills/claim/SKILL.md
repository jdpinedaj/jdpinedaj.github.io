---
name: claim
description: Add or change a factual sentence on the page by taking it verbatim from the CV master or pitch bank in the ai-job-hunt repo, adding it to sources.md and then to index.html. Use when Juan wants a card to say something new, or when check.py reports a card sentence not in sources.md and the card wording should stay.
argument-hint: "[what the card should say, and which card]"
disable-model-invocation: true
---
# New or changed claim: $ARGUMENTS

The page only says what the verified sources say. You select and copy; you do
not write new sentences.

1. Sources, in this order of authority for ARIA (pitch bank wins), otherwise
   equal:
   - `/mnt/c/Users/juanp/projects/ai-job-hunt/docs/pitch_bank.md`
   - `/mnt/c/Users/juanp/projects/ai-job-hunt/docs/cv_master.md`
   Find the sentence that says what Juan wants. If no sentence says it, stop
   and say so: the claim first has to enter the CV master (that is done in
   the ai-job-hunt repo, with Juan), and only if it is true.
2. Copy the sentence verbatim into `sources.md`, under the right system
   header, on its own line or as part of the paragraph it comes from. Update
   the date line at the top. Strip nothing, reword nothing, no em-dashes.
3. Use it in `index.html` inside the card's `<dl class="card-text">`. A
   sentence may be trimmed at a clause boundary (`.`, `:` or `;`), never
   extended. Wrap terms that match a diagram node in
   `<span class="term" data-term="...">`.
4. `python3 check.py --offline` must print `OK`. If it reports the sentence,
   the copy is not verbatim: diff the two strings character by character.
5. Report: source file and line, the sentence, the card, the check output.

Fixed facts: ARIA has four domain agents on one shared engine. The only
verified impact number is ARIA's. Intermediaries are never named on the page.
