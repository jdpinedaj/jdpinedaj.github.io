// Reports: card opacity with JS disabled, tab stops before #contact, SVG label overflows (fonts on and off)
const { chromium } = require('playwright');
const url = 'file://' + process.cwd() + '/index.html';
async function overflows(page) {
  return page.evaluate(() => {
    const out = [];
    document.querySelectorAll('.diagram g.node').forEach(g => {
      const rects = [...g.querySelectorAll('rect')];
      g.querySelectorAll('text').forEach(t => {
        const w = t.getComputedTextLength();
        const x = Number(t.getAttribute('x'));
        const anchor = t.getAttribute('text-anchor') || 'start';
        const left = anchor === 'middle' ? x - w / 2 : anchor === 'end' ? x - w : x;
        const right = left + w;
        const host = rects.find(r => {
          const rx = Number(r.getAttribute('x')), rw = Number(r.getAttribute('width'));
          const ry = Number(r.getAttribute('y')), rh = Number(r.getAttribute('height'));
          const y = Number(t.getAttribute('y'));
          return y >= ry && y <= ry + rh && x >= rx && x <= rx + rw;
        });
        if (host) {
          const rx = Number(host.getAttribute('x')), rw = Number(host.getAttribute('width'));
          if (left < rx + 4 || right > rx + rw - 4) out.push(`${t.textContent} (${Math.round(w)} in ${rw})`);
        }
      });
    });
    return out;
  });
}
(async () => {
  const browser = await chromium.launch();
  const nojs = await browser.newContext({ javaScriptEnabled: false });
  let page = await nojs.newPage(); await page.goto(url);
  const opacities = await page.$$eval('.card', els => els.map(e => getComputedStyle(e).opacity));
  await nojs.close();
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  page = await ctx.newPage(); await page.goto(url, { waitUntil: 'networkidle' });
  let stops = 0;
  for (let i = 0; i < 200; i++) {
    await page.keyboard.press('Tab');
    const inContact = await page.evaluate(() => !!document.activeElement.closest('#contact'));
    stops++;
    if (inContact) break;
  }
  const withFonts = await overflows(page);
  const blocked = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  await blocked.route(/fonts\.g/, r => r.abort());
  page = await blocked.newPage(); await page.goto(url, { waitUntil: 'networkidle' });
  const fallback = await overflows(page);
  console.log(JSON.stringify({ nojsOpacity: opacities, tabStopsToContact: stops, overflowWithFonts: withFonts, overflowFallback: fallback }, null, 1));
  await browser.close();
})();
