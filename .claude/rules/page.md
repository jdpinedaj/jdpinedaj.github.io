---
paths:
  - "index.html"
  - "styles.css"
  - "script.js"
---
# The page (index.html, styles.css, script.js)

- Hand-written static files. No framework, no build step, no bundler, no Node
  dependency at runtime. Google Fonts is the only third-party load.
- `index.html` holds all content and metadata. Sections in spec order, each a
  `<section id="...">` used by the header anchors: hero (`#top`), systems,
  governance, track-record, research, contact.
- System cards: `<article class="card">` with a `<figure class="card-diagram">`
  (inline SVG) and a `<dl class="card-text">`. Only `<dd>` text is checked
  against `sources.md`; every sentence there must be verbatim from that file.
  Kicker, title and stack line are free text but still true.
- Terms in card text that match a diagram node carry
  `<span class="term" data-term="x">`; the SVG node carries the same
  `data-term`. Only text terms get `tabindex`; SVG nodes never become tab stops.
- Diagrams: inline SVG, viewBox around 560 by 360, fills and strokes through
  CSS custom properties so they switch with the theme. Every SVG has a `<title>`
  describing the system in one sentence.
- Tokens on `:root`; dark values under `@media (prefers-color-scheme: dark)`
  guarded by `:root:not([data-theme="light"])` and again under
  `:root[data-theme="dark"]`. One accent (burnt orange). Add a token before
  adding a literal colour.
- Layout works at 375 px with 16 px gutters and no horizontal scroll, and at
  768 px. `prefers-reduced-motion` disables the card fade-in.
- `script.js` stays under 100 lines, dependency-free, wrapped in an IIFE, and
  every function returns early when its element is missing. The page must read
  correctly with JS disabled (cards visible, anchors work, theme follows system).
- Metadata block (title, description, canonical, Open Graph with the PNG image,
  Twitter card, `rel="me"`, JSON-LD Person and WebSite) is complete; change one
  field everywhere it appears. `og:image` must stay a PNG or JPEG.
- After any layout change: `/shots` at 375, 768 and 1280 in both themes, then
  the `page-reviewer` agent.
