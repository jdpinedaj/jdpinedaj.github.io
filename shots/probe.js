const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.addInitScript(() => {
    Object.defineProperty(window, 'localStorage', { get() { throw new Error('blocked'); } });
  });
  const errors = [];
  page.on('pageerror', e => errors.push(String(e)));
  await page.goto('file://' + process.cwd() + '/index.html');
  await page.hover('#aria .term[data-term="engine"]');
  const active = await page.$$eval('#aria .node.is-active', els => els.length);
  await page.mouse.move(0, 0);
  const cleared = await page.$$eval('#aria .is-active', els => els.length);
  await page.focus('#tpp .term[data-term="faiss"]');
  const focused = await page.$$eval('#tpp .node.is-active', els => els.length);
  const before = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
  await page.click('#theme-toggle');
  const after = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
  await page.click('#theme-toggle');
  const again = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await page.waitForTimeout(400);
  const visible = await page.$$eval('.card.is-visible', els => els.length);
  console.log(JSON.stringify({ errors, activeNodes: active, cleared, focused, before, after, again, visibleCards: visible }));
  await browser.close();
})();
