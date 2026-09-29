// Usage: node shots/shoot.js <width> <out.png> [dark]
const { chromium } = require('playwright');
(async () => {
  const [w, out, scheme] = process.argv.slice(2);
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: Number(w), height: 900 },
    colorScheme: scheme === 'dark' ? 'dark' : 'light',
    reducedMotion: 'reduce',
  });
  await page.goto('file://' + process.cwd() + '/index.html');
  await page.waitForTimeout(800);
  const scrollW = await page.evaluate(() => document.documentElement.scrollWidth);
  await page.screenshot({ path: out, fullPage: true });
  console.log(JSON.stringify({ out, viewport: Number(w), scrollWidth: scrollW }));
  await browser.close();
})();
