// Rekam demo aplikasi Flutter (build web asli) dengan CDP screencast.
// Hasil: frames/NNNNN.jpg + frames.json (waktu tiap frame) + events.json (gerak mouse, tap, penanda segmen)
const { chromium } = require('playwright');
const fs = require('fs');
const setup = require('./lib_route');

const OUT = '/home/claude/video/rec';
fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT + '/frames', { recursive: true });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let T0 = 0;
const now = () => (Date.now() - T0) / 1000;
const events = [];
let mouse = { x: 210, y: 600 };

(async () => {
  const b = await chromium.launch({ args: ['--force-device-scale-factor=2'] });
  const ctx = await b.newContext({ viewport: { width: 420, height: 900 }, deviceScaleFactor: 2 });
  await setup(ctx);
  const p = await ctx.newPage();
  await p.goto('http://localhost:8765/');
  await p.waitForTimeout(5000);
  await p.evaluate(() => document.querySelector('flt-semantics-placeholder').click());
  await p.waitForTimeout(800);

  // cari pusat elemen dari pohon semantik Flutter
  async function find(label, opts = {}) {
    for (let i = 0; i < 30; i++) {
      const r = await p.evaluate(({ label, role, exact, nth }) => {
        const ns = [...document.querySelectorAll('flt-semantics, input')].filter((n) => {
          const t = (n.getAttribute('aria-label') || n.getAttribute('placeholder') || n.textContent || '').trim();
          const rr = n.getBoundingClientRect();
          if (rr.width <= 0 || rr.width >= 420) return false;
          if (role && n.getAttribute('role') !== role && n.tagName.toLowerCase() !== role) return false;
          return exact ? t === label : t.startsWith(label);
        });
        const n = ns[nth || 0];
        if (!n) return null;
        const rr = n.getBoundingClientRect();
        return { x: rr.x + rr.width / 2, y: rr.y + rr.height / 2, w: rr.width, h: rr.height };
      }, { label, ...opts });
      if (r) return r;
      await sleep(100);
    }
    throw new Error('tidak ketemu: ' + label);
  }

  async function moveTo(x, y, ms = 450) {
    const steps = Math.max(8, Math.round(ms / 16));
    const sx = mouse.x, sy = mouse.y;
    for (let i = 1; i <= steps; i++) {
      const k = i / steps, e = k < 0.5 ? 2 * k * k : 1 - Math.pow(-2 * k + 2, 2) / 2;
      const nx = sx + (x - sx) * e, ny = sy + (y - sy) * e;
      await p.mouse.move(nx, ny);
      events.push({ t: now(), type: 'move', x: nx, y: ny });
      await sleep(ms / steps);
    }
    mouse = { x, y };
  }
  async function tap(x, y, pause = 600) {
    await moveTo(x, y);
    await sleep(120);
    events.push({ t: now(), type: 'tap', x, y });
    await p.mouse.down(); await sleep(70); await p.mouse.up();
    await sleep(pause);
  }
  async function tapEl(label, opts = {}, pause = 600) {
    const r = await find(label, opts);
    await tap(r.x + (opts.dx || 0), r.y + (opts.dy || 0), pause);
  }
  async function type(text, delay = 110) {
    for (const ch of text) { await p.keyboard.type(ch); await sleep(delay); }
  }
  async function clearField() {
    await p.keyboard.press('Control+A'); await sleep(150);
    await p.keyboard.press('Backspace'); await sleep(250);
  }
  const mark = (name) => { events.push({ t: now(), type: 'mark', name }); console.log('mark', name, now().toFixed(2)); };
  // gerakkan kursor menjauh supaya tooltip NavigationBar tidak muncul
  const park = () => moveTo(400, 650, 350);

  // ---- mulai screencast ----
  const cdp = await ctx.newCDPSession(p);
  const frames = [];
  let n = 0;
  cdp.on('Page.screencastFrame', async (f) => {
    const t = now();
    const name = String(n++).padStart(5, '0') + '.jpg';
    fs.writeFileSync(`${OUT}/frames/${name}`, Buffer.from(f.data, 'base64'));
    frames.push({ t, name });
    try { await cdp.send('Page.screencastFrameAck', { sessionId: f.sessionId }); } catch {}
  });
  T0 = Date.now();
  await cdp.send('Page.startScreencast', { format: 'jpeg', quality: 92, maxWidth: 840, maxHeight: 1800, everyNthFrame: 1 });
  await p.mouse.move(mouse.x, mouse.y);
  await sleep(500);

  // D1 — navigasi 4 halaman
  mark('D1');
  await sleep(2500);
  await tapEl('Penjualan', { role: 'tab' }, 60); await park(); await sleep(1600);
  await tapEl('Stok', { role: 'tab' }, 60); await park(); await sleep(1600);
  await tapEl('Laporan', { role: 'tab' }, 60); await park(); await sleep(1800);
  await tapEl('Menu', { role: 'tab', exact: true }, 60); await park(); await sleep(1200);

  // D2 — push ke Resep, pop kembali
  mark('D2');
  await tapEl('Es Teh Manis', { role: 'button' }, 400);
  await sleep(4500);
  await tapEl('Kembali', { role: 'button' }, 400); await park(); await sleep(1500);

  // D3 — form kosong
  mark('D3');
  await tapEl('Tambah Menu', { role: 'button' }, 1800);
  await tapEl('Simpan Menu', { role: 'button' }, 400);
  await sleep(4000);

  // D4 — input salah
  mark('D4');
  await tapEl('Nama Menu', { role: 'input' }, 400);
  await type('Es'); await sleep(2600);
  await tapEl('Harga (Rp)', { role: 'input' }, 400);
  await type('abc'); await sleep(2600);
  await clearField(); await type('500'); await sleep(2600);
  await tapEl('Nama Menu', { role: 'input' }, 300);
  await clearField(); await type('Es Teh Manis', 80); await sleep(3000);

  // D5 — input benar
  mark('D5');
  await clearField(); await type('Es Teh Melon', 90); await sleep(800);
  const kat = await find('Kategori', { role: 'button' });
  await tap(kat.x, kat.y, 900);
  await p.screenshot({ path: OUT + '/dropdown.png' });
  await tap(90, kat.y + 5 * 48, 900);
  await tapEl('Harga (Rp)', { role: 'input' }, 300);
  await clearField(); await type('6000'); await sleep(1000);
  await tapEl('Simpan Menu', { role: 'button' }, 400); await park();
  await sleep(4500);

  // D6 — stok tidak cukup ditolak
  mark('D6');
  await tapEl('Penjualan', { role: 'tab' }, 60); await park(); await sleep(1200);
  const g = await find('Es Teh Manis', { role: 'group' });
  const rowY = g.y - g.h / 2 + 76;
  const plus = { x: 157, y: rowY };
  await moveTo(plus.x, plus.y);
  for (let i = 0; i < 8; i++) { events.push({ t: now(), type: 'tap', x: plus.x, y: plus.y }); await p.mouse.down(); await sleep(60); await p.mouse.up(); await sleep(380); }
  await sleep(1800);
  await tapEl('Simpan Penjualan', { role: 'button' }, 400); await park();
  await sleep(5000);

  // D7 — penjualan valid, stok berkurang, laporan
  mark('D7');
  const minus = { x: 107, y: rowY };
  await moveTo(minus.x, minus.y);
  for (let i = 0; i < 6; i++) { events.push({ t: now(), type: 'tap', x: minus.x, y: minus.y }); await p.mouse.down(); await sleep(60); await p.mouse.up(); await sleep(380); }
  await sleep(1000);
  await tapEl('Less', { role: 'checkbox' }, 1200);
  await tapEl('Simpan Penjualan', { role: 'button' }, 400); await park();
  await sleep(3500);
  await tapEl('Stok', { role: 'tab' }, 60); await park(); await sleep(4000);
  await tapEl('Laporan', { role: 'tab' }, 60); await park(); await sleep(5000);
  mark('END');

  await cdp.send('Page.stopScreencast');
  await sleep(300);
  fs.writeFileSync(`${OUT}/frames.json`, JSON.stringify(frames));
  fs.writeFileSync(`${OUT}/events.json`, JSON.stringify(events));
  console.log('frames', frames.length, 'durasi', now().toFixed(1));
  await b.close();
})().catch((e) => { console.error(e); process.exit(1); });
