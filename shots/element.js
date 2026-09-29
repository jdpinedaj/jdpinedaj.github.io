// Usage: node shots/element.js <width> <selector> <out.png> [dark]
const { chromium } = require('playwright');
(async () => {
  const [w, sel, out, scheme] = process.argv.slice(2);
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: Number(w), height: 900 },
    colorScheme: scheme === 'dark' ? 'dark' : 'light',
    reducedMotion: 'reduce',
    deviceScaleFactor: 2,
  });
  await page.goto('file://' + process.cwd() + '/index.html');
  await page.waitForTimeout(600);
  await page.locator(sel).screenshot({ path: out });
  console.log(out);
  await browser.close();
})();
