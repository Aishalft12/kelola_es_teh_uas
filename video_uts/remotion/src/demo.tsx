import React from 'react';
import { AbsoluteFill, OffthreadVideo, Sequence, Img, staticFile, useCurrentFrame, useVideoConfig, interpolate, Easing } from 'remotion';
import { C, Appear } from './ui';
import type { Seg } from './Video';
import demo from './demo.json';

export const DEMO_IDS = ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7'];

type Ev = { t: number; type: 'move' | 'tap'; x: number; y: number };

// Ukuran layar ponsel di video (layar aplikasi 420×900 CSS px)
const SCREEN_H = 900;
const SCREEN_W = 420;
const PHONE_SCALE = 940 / SCREEN_H; // tinggi layar 940 px di video

type Info = { title: string; points: { at: number; text: string; tone?: string }[]; zoom?: { from: number; to: number; scale: number; oy: number }[] };

// `at` = indeks kalimat narasi saat poin muncul
const INFO: Record<string, Info> = {
  D1: { title: 'Navigasi utama · NavigationBar', points: [
    { at: 1, text: 'Data simulasi: 4 menu, kategori, harga, status' },
    { at: 2, text: '4 halaman Must terhubung: Menu · Penjualan · Stok · Laporan' },
  ] },
  D2: { title: 'Halaman turunan · push / pop', points: [
    { at: 0, text: 'Ketuk kartu → Navigator.push ke Resep' },
    { at: 1, text: 'Resep per gelas: Teh 5 g · Gula 15 g · Gelas 1 pcs' },
    { at: 2, text: 'Tombol Kembali → Navigator.pop' },
  ] },
  D3: { title: 'Form Tambah Menu', points: [
    { at: 1, text: '4 kolom, 3 jenis input: TextFormField · Dropdown · Switch' },
    { at: 2, text: 'Simpan saat kosong → semua kolom ditolak', tone: C.error },
    { at: 2, text: 'SnackBar merah: “Periksa kembali data yang dimasukkan”', tone: C.error },
  ], zoom: [{ from: 1, to: 99, scale: 1.22, oy: 0 }] },
  D4: { title: 'Validasi input salah', points: [
    { at: 1, text: '“Es” → Nama menu minimal 3 karakter', tone: C.error },
    { at: 2, text: '“abc” → Harga harus berupa angka', tone: C.error },
    { at: 3, text: '“500” → Harga minimal Rp 1.000', tone: C.error },
    { at: 4, text: '“Es Teh Manis” → Nama menu sudah ada', tone: C.error },
  ], zoom: [{ from: 0, to: 99, scale: 1.22, oy: 0 }] },
  D5: { title: 'Input benar → data tampil di daftar', points: [
    { at: 0, text: 'Es Teh Melon · Es Teh Spesial · Rp 6.000 · Tersedia' },
    { at: 2, text: 'SnackBar hijau: menu berhasil ditambahkan', tone: C.success },
    { at: 2, text: 'Menu baru langsung tampil di daftar', tone: C.success },
  ], zoom: [{ from: 0, to: 1, scale: 1.22, oy: 0 }] },
  D6: { title: 'Aturan bisnis · cek kecukupan stok', points: [
    { at: 1, text: 'Stok gula 110 g · resep 15 g per gelas' },
    { at: 2, text: '8 gelas × 15 g = 120 g → ditolak', tone: C.error },
    { at: 2, text: 'Pesan: “Stok bahan tidak cukup — Gula kurang 10 gram”', tone: C.error },
    { at: 3, text: 'Tidak ada data yang berubah' },
  ] },
  D7: { title: 'Simpan penjualan · stok & laporan otomatis', points: [
    { at: 0, text: '2 gelas Es Teh Manis → Rp 10.000', tone: C.success },
    { at: 2, text: 'Stok gula 110 → 80 g · status Menipis', tone: C.warn },
    { at: 3, text: 'Laporan: total, laba kotor (dari resep), menu terlaris', tone: C.success },
  ] },
};

const cueF = (seg: Seg, i: number) => seg.cues[Math.min(i, seg.cues.length - 1)] ?? 0;

const Cursor: React.FC<{ evs: Ev[]; t: number }> = ({ evs, t }) => {
  // posisi terakhir
  let pos: Ev | null = null;
  for (const e of evs) { if (e.t <= t) pos = e; else break; }
  if (!pos) return null;
  const taps = evs.filter((e) => e.type === 'tap' && t >= e.t && t < e.t + 0.6);
  return (
    <>
      {taps.map((e, i) => {
        const k = (t - e.t) / 0.6;
        return <div key={i} style={{ position: 'absolute', left: e.x - 22, top: e.y - 22, width: 44, height: 44, borderRadius: 999, border: `3px solid ${C.amber}`, transform: `scale(${0.6 + k * 1.2})`, opacity: 1 - k }} />;
      })}
      <div style={{ position: 'absolute', left: pos.x - 13, top: pos.y - 13, width: 26, height: 26, borderRadius: 999, background: 'rgba(200,135,58,0.45)', border: '2px solid rgba(255,255,255,0.95)', boxShadow: '0 2px 8px rgba(0,0,0,0.3)' }} />
    </>
  );
};

export const DemoScene: React.FC<{ seg: Seg }> = ({ seg }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const d = (demo as any)[seg.id] as { len: number; events: Ev[] };
  const info = INFO[seg.id];
  const src = staticFile(`clips/${seg.id}.mp4`);
  const pieces = (seg as any).pieces as { from: number; clipFrom: number; len: number; freeze: boolean }[];
  const cur = [...pieces].reverse().find((p) => f >= p.from) || pieces[0];
  const clipT = (cur.clipFrom + (cur.freeze ? 0 : (f - cur.from) * ((cur as any).rate || 1))) / fps;

  // zoom: dari kalimat ke-from sampai kalimat ke-to
  let scale = 1, oy = 0;
  for (const z of info.zoom || []) {
    const a = cueF(seg, z.from), b = z.to >= 99 ? seg.dur + 30 : cueF(seg, z.to);
    const kin = interpolate(f, [a, a + 18], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing: Easing.inOut(Easing.cubic) });
    const kout = interpolate(f, [b, b + 18], [1, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing: Easing.inOut(Easing.cubic) });
    const k = Math.min(kin, kout);
    if (k > 0) { scale = 1 + (z.scale - 1) * k; oy = z.oy; }
  }

  const sw = SCREEN_W * PHONE_SCALE, sh = SCREEN_H * PHONE_SCALE;
  return (
    <AbsoluteFill>
      {/* ponsel */}
      <div style={{ position: 'absolute', left: 230, top: 18, width: sw + 24, height: sh + 24, borderRadius: 44, background: '#1E1512', padding: 12, boxShadow: '0 24px 60px rgba(43,29,23,0.35)' }}>
        <div style={{ width: sw, height: sh, borderRadius: 32, overflow: 'hidden', position: 'relative', background: '#fff' }}>
          <div style={{ position: 'absolute', left: 0, top: 0, width: SCREEN_W, height: SCREEN_H, transformOrigin: '0 0', transform: `scale(${PHONE_SCALE})` }}>
            <div style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>
              <div style={{ position: 'absolute', inset: 0, transformOrigin: `0% ${oy}%`, transform: `scale(${scale})` }}>
                {pieces.map((p, i) => (
                  <Sequence key={i} from={p.from} durationInFrames={p.len} layout="none">
                    {p.freeze ? (
                      <Img src={staticFile((p as any).img)} style={{ position: 'absolute', width: SCREEN_W, height: SCREEN_H }} />
                    ) : (
                      <OffthreadVideo src={src} startFrom={p.clipFrom} playbackRate={(p as any).rate || 1} muted style={{ position: 'absolute', width: SCREEN_W, height: SCREEN_H }} />
                    )}
                  </Sequence>
                ))}
                <Cursor evs={d.events} t={clipT} />
              </div>
            </div>
          </div>
        </div>
      </div>
      <div style={{ position: 'absolute', left: 230, top: sh + 46, width: sw + 24, textAlign: 'center', fontSize: 19, color: C.muted }}>
        Aplikasi Flutter yang berjalan (build web, Chrome)
      </div>

      {/* panel kanan */}
      <div style={{ position: 'absolute', left: 860, right: 70, top: 60 }}>
        <Appear at={0}>
          <div style={{ color: C.amber, fontSize: 22, fontWeight: 800, letterSpacing: 3 }}>DEMO PROTOTYPE · {seg.id.replace('D', 'BAGIAN ')}</div>
          <div style={{ fontSize: 50, fontWeight: 800, color: C.primaryDark, marginTop: 8, lineHeight: 1.12 }}>{info.title}</div>
        </Appear>
        <div style={{ marginTop: 34, display: 'flex', flexDirection: 'column', gap: 16 }}>
          {info.points.map((p, i) => (
            <Appear key={i} at={cueF(seg, p.at) + i * 3}>
              <div style={{ display: 'flex', gap: 16, alignItems: 'flex-start', background: '#fff', border: `1px solid ${C.line}`, borderLeft: `8px solid ${p.tone || C.primary}`, borderRadius: 14, padding: '16px 22px', fontSize: 28, lineHeight: 1.35 }}>
                {p.text}
              </div>
            </Appear>
          ))}
        </div>
      </div>
    </AbsoluteFill>
  );
};
