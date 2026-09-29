---
name: shots
description: Take full-page screenshots of index.html at phone, tablet and desktop widths in both themes with the Playwright script in shots/, check for horizontal overflow, and look at them. Use after any layout, CSS or diagram change.
allowed-tools: Bash(node shots/shoot.js:*), Bash(ls shots:*), Bash(cd shots && npm install), Read
---
# Screenshots

`shots/` is gitignored tooling (Playwright, `shoot.js`, output PNGs). Nothing
in it ships.

1. If `shots/node_modules` is missing: `cd shots && npm install` (Playwright
   and its Chromium; one-time).
2. From the repository root, one call per width and theme:

```bash
node shots/shoot.js 375 shots/mobile.png
node shots/shoot.js 375 shots/mobile-dark.png dark
node shots/shoot.js 768 shots/tablet.png
node shots/shoot.js 1280 shots/desktop.png
node shots/shoot.js 1280 shots/desktop-dark.png dark
```

Each call prints `{"out", "viewport", "scrollWidth"}`. `scrollWidth` greater
than `viewport` is horizontal overflow: find the element (usually a diagram,
a long monospace stack line or the timeline) and fix it before anything else.

3. Read every PNG and check: header readable, cards stacked with the diagram
   first on phones, diagram text legible in both themes, one accent colour,
   no clipped SVG, footer present. Compare against the spec's Visual system
   section when in doubt.
4. Report: widths taken, overflow per width, and what you saw that needs a
   change (or that nothing does).

The screenshot loads `file://` so external fonts may fall back to the system
stack; do not report that as a bug.
