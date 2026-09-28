# Portfolio site design

Date: 2026-09-29. Status: approved in conversation, pending written review.

## Purpose

A single-page portfolio at https://jdpinedaj.github.io/ for Juan
Pineda-Jaramillo. The reader is the end client's tech lead or hiring manager,
who receives the link from an intermediary (staffing or consulting firm) and
has about five minutes to decide whether to take a call. The page is a
forwardable technical brief, not a personal blog and not an academic CV.

Success: a tech lead who has never heard of Juan understands within one
screen what he builds and for whom, and after one scroll can see how one of
his production systems is put together and why the governance layer matters.
The intermediary can paste the link into Teams or email and it previews well.

Reference the user liked: https://nyu-rts.github.io/andi-shehu-portfolio/.
What to keep from it: restraint, typography-driven layout, generous
whitespace, strong metadata. What to improve on: the cards should show the
work (architecture diagrams, design decisions, outcomes), not just describe
it, because none of Juan's flagship systems have a public demo or repo.

## Decisions already made

- Audience: end-client technical readers, reached through intermediaries.
- Language: English only.
- Call to action: email, LinkedIn, and the generic AI/LLM CV as a PDF
  download. No booking link.
- No headshot. Typography and diagrams carry the page.
- Clients named: Johnson & Johnson, Iberia Airlines, The People Platform.
  Intermediaries (Virtusa, ITMAGINATION, Truelogic, Knowmad Mood, Option,
  Oiga) are not named on the page.
- Tech: hand-written static HTML, CSS and vanilla JS. No framework, no build
  step, no Node toolchain. GitHub Pages serves the repository root.
- Every factual sentence on the page must trace to a verified source: the CV
  master (`docs/cv_master.md` in the ai-job-hunt repo) or the pitch bank
  (`docs/pitch_bank.md` in the same repo). The pitch bank wins on ARIA facts.
  ARIA has four domain agents on one shared engine, never five.
- No em-dashes anywhere in the repository.

## Repository

Path: `C:\Users\juanp\projects\jdpinedaj.github.io`. Public GitHub repo
`jdpinedaj/jdpinedaj.github.io`, Pages from the `main` branch, root folder.

Files at the root:

- `index.html`: the whole page.
- `styles.css`: all styles, theme tokens on `:root`.
- `script.js`: term-to-node highlighting, section tracking, theme toggle.
- `og-image.svg`: the link-preview image, 1200 by 630, name and headline on
  the paper background.
- `JuanPineda_CV_AI_LLM.pdf`: copied from `assets/cv/` in ai-job-hunt.
- `check.py`: pre-push checks, stdlib only.
- `sources.md`: the verified claim lines the system cards are allowed to use,
  copied from the CV master and pitch bank. `check.py` reads it.
- `README.md`: what the site is, how to edit it, how to run `check.py`.
- `docs/superpowers/specs/`, `docs/superpowers/plans/`: design and plan.

No `assets/` folder; seven files do not need one.

## Page structure

Top to bottom, each a `<section>` with an `id` used by the header anchors.

1. **Header**, sticky. Name on the left as the brand link to `#top`. Four
   anchors on the right: Systems, Governance, Track record, Contact. A theme
   toggle button after the anchors. On phones the anchors wrap to a second
   line; no hamburger menu.
2. **Hero** (`#top`). Kicker line "AI / LLM Engineer". Name as `h1`. A
   two-line headline: "Production multi-agent systems, RAG and the governance
   layer that makes them safe enough for regulated enterprise use." The Tier
   1 pitch from the pitch bank as one paragraph. Three inline links: email,
   LinkedIn, CV (PDF). A one-line location note: "Valencia, Spain, working
   remotely."
3. **Systems** (`#systems`). Four cards, in this order: ARIA, EVA, TPP
   Text2SQL, Enterprise Text2SQL agent. Card shape is fixed, see below.
4. **Governance** (`#governance`). Short intro sentence: "Anyone can wire up
   LangGraph. The part that is hard to claim is what keeps it safe in a
   regulated environment." Then a three-column grid (one column on phones):
   Guardrails, Evaluation, Observability. Each column is a short list drawn
   from the Tier 3 pitch and the CV master's LLM Safety, Evaluation and
   Observability lines.
5. **Track record** (`#track-record`). A horizontal timeline from 2011 to
   2026 with sector labels: civil engineering and transport (Colombia),
   PhD (Valencia), rail and freight (Luxembourg), mining and retail (Chile),
   finance and HR tech, mobility analytics (US), aviation (Iberia), pharma
   (J&J). Below it, a compact list of the earlier engagements, one line
   each, client and what was built, from the CV master.
6. **Research** (`#research`). One line: "PhD in applied machine learning,
   Universitat Politècnica de València, cum laude. Postdoc at the University
   of Luxembourg. 56 peer-reviewed publications." Link to Google Scholar.
   The two named papers from the CV master as two links.
7. **Contact** (`#contact`). The three links again, larger, with one sentence
   inviting the reader to write.
8. **Footer**. "Valencia, Spain. Built by hand, no framework." and the
   GitHub link.

## System card

Two columns on desktop, diagram left and text right. Stacks vertically on
phones, diagram first. Every card has:

- Kicker: client and sector, for example "Johnson & Johnson, pharma".
- Title: system name, for example "ARIA, ARB Intake Verifier".
- Problem: one sentence.
- Architecture: three beats, one short paragraph each or three list items.
- Governance: one sentence.
- Outcome: one sentence. ARIA has the only verified impact number ("a review
  that took a reviewer a full working day now takes about ten minutes"). The
  other three cards state the outcome qualitatively. No invented numbers.
- Stack: one monospace line.

Source per card:

- ARIA: pitch bank Tier 2 and Tier 3, CV master ARIA block.
- EVA: pitch bank "Second and third systems", CV master Iberia block.
- TPP Text2SQL: pitch bank "Second and third systems", CV master TPP block.
- Enterprise Text2SQL: CV master Enterprise Text2SQL block.

Terms in the card text that correspond to a diagram node are wrapped in
`<span class="term" data-term="...">`. The diagram node carries the same
`data-term`.

## Diagrams

Inline SVG inside each card, hand-drawn, viewBox around 560 by 360, using
CSS custom properties for fill, stroke and text so the diagram switches with
the theme. Nodes are rounded rectangles with a label; edges are lines with
a small arrowhead marker. Each node has `data-term`. Nodes with the active
class get the accent stroke and a slightly stronger fill.

ARIA: intake (PPTX, PDF, DOCX, diagrams) flows into a LangGraph state
machine; four domain agents (Business, Technology, Information, Data Science
& AI) sit on one shared quality-agent engine; an A2A star connects them;
Neo4j (LeanIX inventory) and pgvector (standards library) ground the agents;
a cited report comes out; a band labelled "19 guardrails at every node
boundary" spans the graph.

EVA: user message enters through the Guardrail agent; a router dispatches to
Check-in, Cancellation, Flight Status, Translator, Tone and Booking agents;
Iberia APIs and custom MCP servers sit behind them; OpenAI and AWS Bedrock
Nova Pro are the model layer.

TPP Text2SQL: four stages in a row (query extraction, context-aware SQL
generation, secure execution, natural-language transformation); FAISS
example selection feeds stage two; session memory feeds stage one; three
guard layers marked (regex input guard, parallel LLM safety classifier,
read-only SQL backstop); a PostgreSQL audit table at the end.

Enterprise Text2SQL: one tool-calling agent in a loop with the database;
LLMPort and DatabasePort as the only two edges out of the agent; read-only
SQL validation, step budget and row caps marked on the database edge; a
mock LLM shown as an alternative adapter on the LLMPort edge.

## Visual system

- Light theme: warm off-white paper background, near-black ink text, warm
  grey muted text, a thin warm grey line colour.
- Dark theme: deep ink background, warm light grey text, muted mid grey,
  dark line colour.
- One accent, burnt orange, for links, active nodes and terms, the timeline
  and the kicker lines. Same hue in both themes, slightly lighter in dark.
- Type: a serif for headings, a humanist sans for body, a monospace for
  kickers, stacks, diagram labels and the timeline years. Loaded from Google
  Fonts with `display=swap`; system fallbacks declared.
- Content width 1100 px max, 16 px side gutter on phones, no horizontal
  scroll at 375 px.
- Motion: hover and focus states, and a one-time fade-in on cards as they
  enter the viewport using IntersectionObserver. Respects
  `prefers-reduced-motion`.
- Tokens on `:root`, dark overrides under `prefers-color-scheme: dark`
  guarded by `:root:not([data-theme="light"])`, and again under
  `:root[data-theme="dark"]`, so the toggle can force either theme.

## Interaction and JS

`script.js`, under 100 lines, no dependencies, wrapped so it does nothing
harmful if an element is missing:

- Term highlighting: `mouseenter`, `mouseleave`, `focus` and `blur` on any
  `.term` toggle `.is-active` on every element with the same `data-term`
  inside the same card, in both directions (text to diagram, diagram to
  text). Terms are focusable (`tabindex="0"`) so keyboard users get it too.
- Section tracking: an IntersectionObserver marks the header anchor of the
  section currently in view with `aria-current="true"`.
- Theme toggle: reads `localStorage` inside try/catch, sets `data-theme` on
  `<html>`, updates the button label. Without a stored choice the system
  setting applies.
- Card fade-in: IntersectionObserver adds `.is-visible` once.

Everything renders and reads correctly with JS disabled: diagrams and text
are static, anchors work, theme follows the system.

## Metadata

In `<head>`: title "Juan Pineda-Jaramillo, PhD | AI / LLM Engineer",
description, canonical URL, `theme-color`, Open Graph type, site name,
title, description, url, image and image alt, Twitter card
`summary_large_image`, `rel="me"` links to LinkedIn and GitHub, and a
schema.org JSON-LD block with `WebSite` and `Person` (name, honorific
suffix, job title, url, email, sameAs for LinkedIn, GitHub and Google
Scholar, knowsAbout list). A `robots` meta allowing indexing.

## Verification

`check.py` runs with `python3 check.py` and exits non-zero on any failure:

1. No em-dash character in any tracked text file.
2. Every `href="#..."` in `index.html` resolves to an `id` in the same file.
3. Every external `http(s)` link in `index.html` returns a 2xx or 3xx
   status (HEAD, falling back to GET), using `urllib` with a short timeout.
   Failures are printed with the URL.
4. `JuanPineda_CV_AI_LLM.pdf` exists and is larger than 10 KB.
5. Every sentence inside `.card-text` in the four system cards appears in
   `sources.md`, after normalising whitespace. Sentences are split on ". "
   after stripping tags. This catches rewrites that drift from the verified
   claims.

Manual pass before the first publish and after any layout change:

- Chrome device toolbar at 375 px and 768 px, both themes.
- Keyboard-only navigation through anchors, toggle and terms.
- JS disabled: page still reads correctly.
- Google Rich Results test on the deployed URL for the Person block.
- Paste the URL into a chat client to confirm the preview image and text.

## Out of scope

Blog, multiple pages, analytics, contact form, booking link, publication
list beyond the two named papers, project links to private repositories,
any build tooling, any content not traceable to the CV master or pitch bank.
