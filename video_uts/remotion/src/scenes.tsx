import React from 'react';
import { AbsoluteFill, Img, staticFile, useCurrentFrame, interpolate } from 'remotion';
import { C, Appear, Card, Pill, Title, CupIcon, useActive } from './ui';
import type { Seg } from './Video';
import timeline from './timeline.json';

const cue = (seg: Seg, i: number) => seg.cues[Math.min(i, seg.cues.length - 1)] ?? 0;
const Pad: React.FC<{ children: React.ReactNode; style?: React.CSSProperties }> = ({ children, style }) => (
  <div style={{ position: 'absolute', left: 110, right: 110, top: 56, bottom: 150, ...style }}>{children}</div>
);

// ---------- 1. Pembuka ----------
const S1: React.FC<{ seg: Seg }> = ({ seg }) => (
  <AbsoluteFill style={{ background: `linear-gradient(135deg, ${C.primaryDark} 0%, ${C.primary} 60%, #8D6E63 100%)`, color: '#fff' }}>
    <div style={{ position: 'absolute', left: 140, top: 190, right: 140 }}>
      <Appear at={0}><div style={{ fontSize: 26, letterSpacing: 4, opacity: 0.85, fontWeight: 600 }}>UTS · MOBILE AND WEB APPLICATION DEVELOPMENT</div></Appear>
      <div style={{ display: 'flex', alignItems: 'center', gap: 36, marginTop: 26 }}>
        <Appear at={6}><div style={{ background: '#FBF7F3', borderRadius: 36, padding: 18 }}><CupIcon size={150} /></div></Appear>
        <Appear at={10}>
          <div style={{ fontSize: 104, fontWeight: 900, lineHeight: 1 }}>Aplikasi Es Teh</div>
          <div style={{ fontSize: 36, marginTop: 14, opacity: 0.92 }}>Penjualan & Persediaan Bahan Baku UMKM Es Teh</div>
        </Appear>
      </div>
      <Appear at={cue(seg, 1)} style={{ marginTop: 70, display: 'flex', gap: 28 }}>
        {[['Nama', 'Aisha Lufita'], ['NIM', '23.01.55.0012'], ['Kelas', 'A1 · Ganjil 2026/2027']].map(([k, v]) => (
          <div key={k} style={{ background: 'rgba(255,255,255,0.12)', border: '1px solid rgba(255,255,255,0.25)', borderRadius: 18, padding: '18px 30px', minWidth: 300 }}>
            <div style={{ fontSize: 20, opacity: 0.75, letterSpacing: 2 }}>{k.toUpperCase()}</div>
            <div style={{ fontSize: 36, fontWeight: 700, marginTop: 4 }}>{v}</div>
          </div>
        ))}
      </Appear>
      <Appear at={cue(seg, 3)} style={{ marginTop: 44, fontSize: 30, fontWeight: 600, color: '#FFE0B2' }}>Dari ide ke prototype</Appear>
    </div>
  </AbsoluteFill>
);

// ---------- 2. Masalah ----------
const S2A: React.FC<{ seg: Seg }> = ({ seg }) => {
  const items = [
    { n: '1', t: 'Stok habis mendadak', d: 'Teh & gula habis di tengah jualan karena sisa stok tidak dipantau.', c: C.warn },
    { n: '2', t: 'Laba tidak diketahui', d: 'Biaya bahan per gelas tidak pernah dihitung.', c: C.error },
    { n: '3', t: 'Tidak ada data menu laris', d: 'Sulit memutuskan menu atau bahan mana yang perlu ditambah.', c: C.primary },
  ];
  return (
    <Pad>
      <Title kicker="Pertanyaan 1 · Problem statement" title="Masalah apa yang diselesaikan?" />
      <Appear at={cue(seg, 1)}>
        <Card style={{ fontSize: 30, lineHeight: 1.45, background: C.soft, border: 'none' }}>
          Penjual es teh skala kecil masih mencatat di <b>buku tulis</b> — atau tidak mencatat sama sekali.
        </Card>
      </Appear>
      <div style={{ display: 'flex', gap: 28, marginTop: 30 }}>
        {items.map((it, i) => (
          <Appear key={it.n} at={cue(seg, 3 + i)} style={{ flex: 1 }}>
            <Card style={{ height: 230, borderTop: `8px solid ${it.c}` }}>
              <div style={{ fontSize: 22, color: it.c, fontWeight: 800 }}>MASALAH {it.n}</div>
              <div style={{ fontSize: 34, fontWeight: 800, margin: '8px 0 10px' }}>{it.t}</div>
              <div style={{ fontSize: 25, color: C.muted, lineHeight: 1.4 }}>{it.d}</div>
            </Card>
          </Appear>
        ))}
      </div>
      <Appear at={cue(seg, 6)} style={{ marginTop: 28, fontSize: 28, color: C.primaryDark }}>
        <b>Mengapa penting?</b> Kehabisan bahan = kehilangan penjualan. Tidak tahu laba = tidak tahu usaha untung atau rugi.
      </Appear>
    </Pad>
  );
};

const S2B: React.FC<{ seg: Seg }> = ({ seg }) => (
  <Pad>
    <Title kicker="Pertanyaan 2 · Target pengguna & persona" title="Siapa pengguna utamanya?" />
    <div style={{ display: 'flex', gap: 36 }}>
      <Appear at={cue(seg, 1)} style={{ flex: 0.8 }}>
        <Card style={{ height: 500 }}>
          <div style={{ fontSize: 22, fontWeight: 800, color: C.amber, letterSpacing: 2 }}>TARGET PENGGUNA</div>
          <div style={{ fontSize: 34, fontWeight: 700, marginTop: 14, lineHeight: 1.35 }}>Pemilik sekaligus penjual usaha es teh kecil</div>
          <div style={{ fontSize: 26, color: C.muted, marginTop: 18, lineHeight: 1.5 }}>Gerobak atau kedai di dekat kampus & sekolah. Melayani sendiri, tanpa kasir khusus.</div>
        </Card>
      </Appear>
      <Appear at={cue(seg, 2)} style={{ flex: 1.2 }}>
        <Card style={{ height: 500, display: 'flex', gap: 30 }}>
          <div style={{ width: 170, height: 170, borderRadius: 999, background: C.soft, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 64, fontWeight: 800, color: C.primary, flexShrink: 0 }}>BR</div>
          <div>
            <div style={{ fontSize: 22, fontWeight: 800, color: C.amber, letterSpacing: 2 }}>PERSONA</div>
            <div style={{ fontSize: 42, fontWeight: 800, marginTop: 6 }}>Bu Rina, 38 tahun</div>
            <div style={{ fontSize: 25, color: C.muted, marginTop: 4 }}>Pemilik gerobak es teh dekat kampus</div>
            <Appear at={cue(seg, 3)} style={{ marginTop: 20, fontSize: 25, lineHeight: 1.55 }}>
              • ±80 gelas per hari, melayani sendirian<br />
              • Terbiasa ponsel Android, tidak sempat membuat pembukuan
            </Appear>
            <Appear at={cue(seg, 5)} style={{ marginTop: 16, background: C.soft, borderRadius: 14, padding: '14px 18px', fontSize: 25, lineHeight: 1.5 }}>
              <b>Tujuan:</b> catat penjualan cepat · tahu kapan belanja bahan · tahu untung harian
            </Appear>
          </div>
        </Card>
      </Appear>
    </div>
  </Pad>
);

// ---------- 3. Kebutuhan ----------
const STORIES = [
  ['penjual', 'mencatat penjualan (menu, jumlah, tingkat gula)', 'total harga terhitung otomatis'],
  ['pemilik', 'stok bahan berkurang otomatis setiap penjualan', 'tidak perlu menghitung manual'],
  ['pemilik', 'melihat status stok Aman / Menipis / Habis', 'tahu kapan harus belanja bahan'],
  ['pemilik', 'penjualan ditolak bila stok tidak cukup', 'data stok tidak pernah minus'],
  ['pemilik', 'menambah menu baru beserta harganya', 'daftar menu sesuai jualan'],
  ['pemilik', 'melihat laporan penjualan, laba kotor, menu terlaris', 'tahu usaha untung atau tidak'],
];
const S3A: React.FC<{ seg: Seg }> = ({ seg }) => (
  <Pad>
    <Title kicker="Kebutuhan · User story" title="6 user story" />
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 22 }}>
      {STORIES.map(([who, want, why], i) => (
        <Appear key={i} at={cue(seg, i + 1)}>
          <Card style={{ padding: '18px 24px', display: 'flex', gap: 18, alignItems: 'flex-start' }}>
            <div style={{ width: 46, height: 46, borderRadius: 12, background: C.primary, color: '#fff', fontWeight: 800, fontSize: 24, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{i + 1}</div>
            <div style={{ fontSize: 24, lineHeight: 1.4 }}>
              Sebagai <b>{who}</b>, saya ingin <b>{want}</b>, agar <span style={{ color: C.muted }}>{why}</span>.
            </div>
          </Card>
        </Appear>
      ))}
    </div>
  </Pad>
);

const S3B: React.FC<{ seg: Seg }> = ({ seg }) => {
  const must = [['Pencatatan penjualan', 'US 1, 4'], ['Stok bahan + status', 'US 2, 3'], ['Menu & resep (+ form tambah menu)', 'US 5'], ['Laporan & laba kotor', 'US 6']];
  const should = ['Login (Firebase Authentication)', 'Catat pembelian bahan'];
  return (
    <Pad>
      <Title kicker="Pertanyaan 3 · Prioritas" title="Mengapa fitur ini yang diprioritaskan?" />
      <div style={{ display: 'flex', gap: 32 }}>
        <Appear at={cue(seg, 1)} style={{ flex: 1.3 }}>
          <Card style={{ borderTop: `8px solid ${C.success}` }}>
            <Pill color={C.success}>MUST</Pill>
            {must.map(([m, us]) => (
              <div key={m} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 29, padding: '14px 0', borderBottom: `1px solid ${C.line}` }}>
                <span style={{ fontWeight: 600 }}>{m}</span><span style={{ color: C.muted }}>{us}</span>
              </div>
            ))}
          </Card>
        </Appear>
        <Appear at={cue(seg, 3)} style={{ flex: 1 }}>
          <Card style={{ borderTop: `8px solid ${C.amber}` }}>
            <Pill color={C.amber}>SHOULD</Pill>
            {should.map((m) => (<div key={m} style={{ fontSize: 29, padding: '14px 0', borderBottom: `1px solid ${C.line}`, fontWeight: 600 }}>{m}</div>))}
            <div style={{ fontSize: 23, color: C.muted, marginTop: 14 }}>Dikerjakan setelah Firebase terhubung (P9–P12).</div>
          </Card>
        </Appear>
      </div>
      <Appear at={cue(seg, 2)} style={{ marginTop: 30 }}>
        <Card style={{ background: C.soft, border: 'none', fontSize: 28, lineHeight: 1.45 }}>
          🔑 <b>Resep per gelas</b> adalah kunci: dari resep, aplikasi <b>mengurangi stok</b> dan <b>menghitung laba kotor</b> secara otomatis — menjawab ketiga masalah sekaligus.
        </Card>
      </Appear>
    </Pad>
  );
};

// ---------- 4. Rancangan ----------
const Box: React.FC<{ label: string; on: boolean; color?: string; sub?: string; w?: number }> = ({ label, on, color = C.primary, sub, w = 230 }) => (
  <div style={{
    width: w, minHeight: 96, borderRadius: 18, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
    textAlign: 'center', padding: '10px 14px', fontSize: 25, fontWeight: 700,
    background: on ? color : '#fff', color: on ? '#fff' : C.muted, border: `3px solid ${on ? color : C.line}`,
    boxShadow: on ? '0 10px 24px rgba(78,52,46,0.18)' : 'none',
  }}>
    {label}{sub && <div style={{ fontSize: 18, fontWeight: 500, marginTop: 4, opacity: 0.9 }}>{sub}</div>}
  </div>
);
const Arrow: React.FC<{ on: boolean; down?: boolean; label?: string }> = ({ on, down, label }) => (
  <div style={{ display: 'flex', flexDirection: down ? 'column' : 'row', alignItems: 'center', color: on ? C.primary : C.line, fontSize: 18, fontWeight: 700 }}>
    {label && down && <span style={{ marginBottom: 2 }}>{label}</span>}
    <div style={{ fontSize: 40, lineHeight: 1 }}>{down ? '↓' : '→'}</div>
    {label && !down && <span style={{ marginLeft: 4 }}>{label}</span>}
  </div>
);
const S4A: React.FC<{ seg: Seg }> = ({ seg }) => {
  const a = (i: number) => useActive(cue(seg, i));
  const s1 = a(1), s2 = a(2), s3 = a(3), s4 = a(4), s5 = a(5);
  return (
    <Pad>
      <Title kicker="Rancangan · User flow" title="Dari login sampai penjualan tersimpan" />
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <Box label="Buka aplikasi" on={s1} />
        <Arrow on={s1} />
        <Box label="Login" sub="Firebase Auth · P9" on={s1} color={C.amber} />
        <Arrow on={s1} />
        <Box label="Menu & Resep" on={s1} />
        <Arrow on={s2} />
        <Box label="Penjualan" sub="pilih menu, jumlah, gula" on={s2} />
        <Arrow on={s2} />
        <Box label="Simpan" on={s2} w={150} />
      </div>
      <div style={{ display: 'flex', justifyContent: 'flex-end', paddingRight: 30, marginTop: 6 }}><Arrow on={s3} down /></div>
      <div style={{ display: 'flex', justifyContent: 'flex-end', paddingRight: 0 }}>
        <Box label="Cek kecukupan stok" on={s3} color={C.primaryDark} w={300} />
      </div>
      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 60, marginTop: 10, alignItems: 'flex-start' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <Arrow on={s5} down label="tidak cukup" />
          <Box label="Ditolak" sub="SnackBar: stok tidak cukup" on={s5} color={C.error} w={300} />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <Arrow on={s4} down label="cukup" />
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <Box label="Tersimpan" sub="stok − resep" on={s4} color={C.success} w={220} />
            <Arrow on={s4} />
            <Box label="Laporan" sub="total · laba · terlaris" on={s4} color={C.success} w={250} />
          </div>
        </div>
      </div>
      <Appear at={cue(seg, 6)} style={{ position: 'absolute', left: 0, top: 620, fontSize: 24, color: C.warn, fontWeight: 600 }}>
        ⓘ Login sudah dirancang, dibangun di Pertemuan 9 bersama Firebase.
      </Appear>
    </Pad>
  );
};

const S4B: React.FC<{ seg: Seg }> = ({ seg }) => {
  const pages = [['Menu & Resep', 'menu_resep_page.dart'], ['Penjualan', 'penjualan_page.dart'], ['Stok Bahan', 'stok_bahan_page.dart'], ['Laporan', 'laporan_page.dart']];
  return (
    <Pad>
      <Title kicker="Rancangan · Sitemap" title="4 halaman utama + 2 halaman turunan" />
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <Appear at={0}><Box label="Aplikasi Es Teh" sub="NavigationBar (mobile) · NavigationRail (web)" on w={560} /></Appear>
        <div style={{ height: 30, width: 3, background: C.primary }} />
        <div style={{ height: 3, width: 1320, background: C.primary }} />
        <div style={{ display: 'flex', gap: 40 }}>
          {pages.map(([p, f], i) => (
            <Appear key={p} at={cue(seg, 0) + 8 + i * 6} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
              <div style={{ height: 30, width: 3, background: C.primary }} />
              <Box label={p} sub={f} on w={300} />
              {i === 0 && (
                <Appear at={cue(seg, 1)} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                  <div style={{ fontSize: 19, color: C.amber, fontWeight: 700, margin: '8px 0' }}>Navigator.push ↓ / pop ↑</div>
                  <div style={{ display: 'flex', gap: 12 }}>
                    <Box label="Resep Menu" sub="resep_page.dart" on color={C.amber} w={200} />
                    <Box label="Tambah Menu" sub="menu_form_page.dart" on color={C.amber} w={220} />
                  </div>
                </Appear>
              )}
            </Appear>
          ))}
        </div>
      </div>
    </Pad>
  );
};

const Phone: React.FC<{ src: string; h?: number; label?: string; tone?: string }> = ({ src, h = 640, label, tone = C.primary }) => (
  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
    <div style={{ height: h, width: (h * 840) / 1800, borderRadius: 26, overflow: 'hidden', border: `8px solid #2B1D17`, boxShadow: '0 16px 36px rgba(0,0,0,0.18)', background: '#fff' }}>
      <Img src={staticFile(src)} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
    </div>
    {label && <div style={{ marginTop: 12, fontSize: 22, fontWeight: 700, color: tone }}>{label}</div>}
  </div>
);

const S4C: React.FC<{ seg: Seg }> = ({ seg }) => {
  const figma: string[] = (timeline as any).figma || [];
  const app = ['img/menu-dan-resep.png', 'img/penjualan.png', 'img/stok-bahan.png'];
  const sw = [['Primer', '#6D4C41'], ['Latar', '#FAFAFA'], ['Aman', '#2E7D32'], ['Menipis', '#B45309'], ['Galat', '#C62828']];
  return (
    <Pad style={{ top: 40 }}>
      <Title kicker="Rancangan · Wireframe Figma vs aplikasi" title="Wireframe konsisten dengan aplikasi" />
      <div style={{ display: 'flex', gap: 34, alignItems: 'flex-start' }}>
        {[0, 1, 2].map((i) => (
          <Appear key={i} at={6 + i * 8} style={{ display: 'flex', gap: 14 }}>
            {figma[i] ? <Phone src={figma[i]} h={500} label="Figma" tone={C.amber} /> : null}
            <Phone src={app[i]} h={500} label="Aplikasi" />
          </Appear>
        ))}
        <Appear at={cue(seg, 1)} style={{ marginLeft: 'auto' }}>
          <Card style={{ width: 300 }}>
            <div style={{ fontSize: 22, fontWeight: 800, color: C.amber, letterSpacing: 2, marginBottom: 12 }}>STYLE GUIDE</div>
            {sw.map(([n, c]) => (
              <div key={n} style={{ display: 'flex', alignItems: 'center', gap: 14, fontSize: 23, padding: '7px 0' }}>
                <div style={{ width: 34, height: 34, borderRadius: 9, background: c, border: `1px solid ${C.line}` }} />
                <b>{n}</b><span style={{ color: C.muted, marginLeft: 'auto', fontSize: 19 }}>{c}</span>
              </div>
            ))}
            <Appear at={cue(seg, 2)} style={{ marginTop: 12, fontSize: 21, color: C.muted, lineHeight: 1.5 }}>
              Tipografi: 22 · 16 · 14 · 12 px
            </Appear>
          </Card>
        </Appear>
      </div>
    </Pad>
  );
};

// ---------- 5. Keadaan kosong (tangkapan) ----------
const D8: React.FC<{ seg: Seg }> = () => (
  <Pad>
    <Title kicker="Demo · Keadaan kosong" title="Data kosong ditangani dengan pesan jelas" />
    <div style={{ display: 'flex', gap: 80, justifyContent: 'center' }}>
      <Appear at={4}><Phone src="img/keadaan-kosong-menu.png" h={560} label="Menu — belum ada menu" /></Appear>
      <Appear at={14}><Phone src="img/keadaan-kosong-stok.png" h={560} label="Stok — belum ada bahan" /></Appear>
    </div>
    <div style={{ textAlign: 'center', marginTop: 10, fontSize: 21, color: C.muted }}>Tangkapan layar aplikasi saat data simulasi dikosongkan</div>
  </Pad>
);

// ---------- 6. Rencana teknis ----------
const S6A: React.FC<{ seg: Seg }> = ({ seg }) => {
  const stack = [
    ['Flutter + Dart', 'Material 3 · satu kode untuk Android & web', C.primary, 0],
    ['Cloud Firestore', 'Database NoSQL', C.amber, 1],
    ['Firebase Authentication', 'Login pemilik usaha', C.amber, 1],
    ['Firebase Hosting', 'Versi web aplikasi', C.amber, 1],
  ] as const;
  return (
    <Pad>
      <Title kicker="Rencana teknis · Tech stack" title="Flutter + Firebase (paket Spark, gratis)" />
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 28 }}>
        {stack.map(([t, d, c, i], k) => (
          <Appear key={t} at={cue(seg, i) + k * 5}>
            <Card style={{ borderLeft: `10px solid ${c}`, height: 170 }}>
              <div style={{ fontSize: 38, fontWeight: 800 }}>{t}</div>
              <div style={{ fontSize: 27, color: C.muted, marginTop: 10 }}>{d}</div>
            </Card>
          </Appear>
        ))}
      </div>
    </Pad>
  );
};

const COLS: [string, string[]][] = [
  ['users', ['nama', 'email', 'peran']],
  ['menu', ['nama', 'kategori', 'harga', 'tersedia']],
  ['bahan', ['nama', 'satuan', 'stok', 'stokMinimum', 'hargaBeli', 'isiKemasan']],
  ['resep', ['menuId → menu', 'bahanId → bahan', 'jumlahPerGelas']],
  ['penjualan', ['tanggal', 'total', 'labaKotor', 'items[ ]: menuId, jumlah, tingkatGula, subtotal, biayaBahan']],
  ['pembelian', ['bahanId → bahan', 'jumlah', 'hargaTotal', 'tanggal']],
];
const S6B: React.FC<{ seg: Seg }> = ({ seg }) => (
  <Pad style={{ top: 40 }}>
    <Title kicker="Pertanyaan 4 · Rancangan database Firestore" title="Bagaimana data akan disimpan?" />
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 20 }}>
      {COLS.map(([name, fields], i) => (
        <Appear key={name} at={cue(seg, 2 + i)}>
          <Card style={{ padding: '16px 22px', minHeight: 205 }}>
            <div style={{ fontFamily: 'monospace', fontSize: 28, fontWeight: 800, color: C.primary }}>/{name}</div>
            {fields.map((f) => (<div key={f} style={{ fontFamily: 'monospace', fontSize: 20, color: C.text, marginTop: 6, lineHeight: 1.3 }}>· {f}</div>))}
          </Card>
        </Appear>
      ))}
    </div>
    <Appear at={cue(seg, 8)} style={{ marginTop: 22 }}>
      <Card style={{ background: C.soft, border: 'none', fontSize: 25, padding: '14px 24px' }}>
        ⚙️ <b>Batch write</b>: kurangi <code>bahan.stok</code> + tambah dokumen <code>penjualan</code> dalam satu operasi — stok tidak pernah berkurang tanpa penjualan sah.
      </Card>
    </Appear>
  </Pad>
);

const S6C: React.FC<{ seg: Seg }> = ({ seg }) => {
  const plan = [['P9', 'Setup Firebase + Login'], ['P10', 'Menu & bahan → Firestore'], ['P11', 'Penjualan + batch write stok'], ['P12', 'Form Catat Pembelian'], ['P13', 'Laporan dari Firestore'], ['P14', 'Deploy Firebase Hosting'], ['P15', 'Pengujian & finalisasi UAS']];
  const step = Math.max(8, Math.floor((seg.dur - 60) / plan.length));
  return (
    <Pad>
      <Title kicker="Rencana teknis · Linimasa" title="Rencana Pertemuan 9 – 15" />
      <div style={{ position: 'relative', marginTop: 50 }}>
        <div style={{ position: 'absolute', left: 40, right: 40, top: 38, height: 6, background: C.line, borderRadius: 3 }} />
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          {plan.map(([p, t], i) => (
            <Appear key={p} at={cue(seg, 0) + 10 + i * step} style={{ width: 210, display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
              <div style={{ width: 82, height: 82, borderRadius: 999, background: i === 0 ? C.amber : C.primary, color: '#fff', fontWeight: 800, fontSize: 28, display: 'flex', alignItems: 'center', justifyContent: 'center', border: `6px solid ${C.bg}` }}>{p}</div>
              <div style={{ fontSize: 25, fontWeight: 700, marginTop: 16, lineHeight: 1.3 }}>{t}</div>
            </Appear>
          ))}
        </div>
      </div>
    </Pad>
  );
};

const S6D: React.FC<{ seg: Seg }> = ({ seg }) => {
  const cols = [
    ['Kendala', C.error, 0, 'Stok di halaman Stok tidak ikut berubah setelah penjualan disimpan.', 'Solusi: ValueNotifier sebagai penanda versi data → nanti stream Firestore.'],
    ['Pelajaran', C.success, 2, 'Rancang aturan bisnis dulu (resep, validasi stok).', 'Kode jadi jauh lebih mudah diuji — 18 kasus uji otomatis.'],
    ['Belum selesai', C.warn, 3, 'Login · koneksi Firebase · form Catat Pembelian.', 'Semua masuk rencana P9–P12, sebelum UAS.'],
  ] as const;
  return (
    <Pad>
      <Title kicker="Penutup" title="Kendala, pelajaran & yang belum selesai" />
      <div style={{ display: 'flex', gap: 28 }}>
        {cols.map(([t, c, i, a, b]) => (
          <Appear key={t} at={cue(seg, i)} style={{ flex: 1 }}>
            <Card style={{ borderTop: `8px solid ${c}`, height: 430 }}>
              <div style={{ fontSize: 36, fontWeight: 800, color: c }}>{t}</div>
              <div style={{ fontSize: 27, marginTop: 18, lineHeight: 1.45, fontWeight: 600 }}>{a}</div>
              <div style={{ fontSize: 25, marginTop: 18, lineHeight: 1.45, color: C.muted }}>{b}</div>
            </Card>
          </Appear>
        ))}
      </div>
    </Pad>
  );
};

const S6E: React.FC<{ seg: Seg }> = () => {
  const f = useCurrentFrame();
  const o = interpolate(f, [0, 15], [0, 1], { extrapolateRight: 'clamp' });
  return (
    <AbsoluteFill style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primary})`, color: '#fff', alignItems: 'center', justifyContent: 'center', opacity: o }}>
      <div style={{ background: '#FBF7F3', borderRadius: 36, padding: 18 }}><CupIcon size={130} /></div>
      <div style={{ fontSize: 96, fontWeight: 900, marginTop: 30 }}>Terima kasih</div>
      <div style={{ fontSize: 32, marginTop: 14, opacity: 0.9 }}>Aisha Lufita · 23.01.55.0012 · Kelas A1</div>
      <div style={{ fontSize: 26, marginTop: 10, opacity: 0.75 }}>github.com/Aishalft12/kelola_es_teh_uas</div>
    </AbsoluteFill>
  );
};

export const SCENES: Record<string, React.FC<{ seg: Seg }>> = { S1, S2A, S2B, S3A, S3B, S4A, S4B, S4C, D8, S6A, S6B, S6C, S6D, S6E };
