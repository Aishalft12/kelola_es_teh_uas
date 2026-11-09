import React, { useEffect, useState } from 'react';
import {
  AbsoluteFill, Audio, Sequence, staticFile, useCurrentFrame, interpolate,
  delayRender, continueRender,
} from 'remotion';
import timeline from './timeline.json';
import { C, FONT } from './ui';
import { SCENES } from './scenes';
import { DemoScene, DEMO_IDS } from './demo';

export type Caption = { text: string; from: number; to: number };
export type Seg = {
  id: string; start: number; dur: number; audio: string | null; audioAt: number;
  cues: number[]; captions: Caption[];
};

const SECTIONS = ['Pembuka', 'Masalah & Pengguna', 'Kebutuhan', 'Rancangan', 'Demo', 'Rencana Teknis'];
const sectionOf = (id: string) =>
  id === 'S1' ? 0 : id.startsWith('S2') ? 1 : id.startsWith('S3') ? 2 : id.startsWith('S4') ? 3 : id.startsWith('D') ? 4 : 5;

const useFont = () => {
  const [handle] = useState(() => delayRender('font'));
  useEffect(() => {
    const ff = new FontFace('Roboto', `url(${staticFile('Roboto.ttf')})`, { weight: '100 900' });
    ff.load().then((f) => { (document as any).fonts.add(f); continueRender(handle); }).catch(() => continueRender(handle));
  }, [handle]);
};

const Header: React.FC<{ seg: Seg }> = ({ seg }) => {
  const cur = sectionOf(seg.id);
  if (seg.id === 'S1' || seg.id === 'S6E') return null;
  return (
    <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 64, display: 'flex', alignItems: 'center', padding: '0 56px', gap: 10, borderBottom: `1px solid ${C.line}`, background: '#FFFDFB' }}>
      <div style={{ fontWeight: 800, color: C.primary, fontSize: 22, marginRight: 24 }}>Aplikasi Es Teh</div>
      {SECTIONS.map((s, i) => (
        <div key={s} style={{
          padding: '6px 16px', borderRadius: 999, fontSize: 18, fontWeight: i === cur ? 700 : 500,
          background: i === cur ? C.primary : 'transparent', color: i === cur ? '#fff' : i < cur ? C.primary : C.muted,
        }}>{i + 1}. {s}</div>
      ))}
      <div style={{ marginLeft: 'auto', color: C.muted, fontSize: 18 }}>Aisha Lufita · 23.01.55.0012 · A1</div>
    </div>
  );
};

export const Captions: React.FC<{ seg: Seg; demo?: boolean }> = ({ seg, demo }) => {
  const f = useCurrentFrame();
  const c = seg.captions.find((x) => f >= x.from && f < x.to);
  if (!c) return null;
  const o = interpolate(f, [c.from, c.from + 5], [0, 1], { extrapolateRight: 'clamp' });
  const style: React.CSSProperties = demo
    ? { position: 'absolute', left: 860, right: 70, bottom: 56 }
    : { position: 'absolute', left: 0, right: 0, bottom: 44, display: 'flex', justifyContent: 'center' };
  return (
    <div style={style}>
      <div style={{
        opacity: o, maxWidth: demo ? undefined : 1500, background: 'rgba(43,29,23,0.86)', color: '#fff',
        fontSize: demo ? 28 : 30, lineHeight: 1.35, padding: '14px 26px', borderRadius: 14, textAlign: demo ? 'left' : 'center',
      }}>{c.text}</div>
    </div>
  );
};

const SegView: React.FC<{ seg: Seg }> = ({ seg }) => {
  const demo = DEMO_IDS.includes(seg.id);
  const Scene = SCENES[seg.id];
  return (
    <AbsoluteFill style={{ background: C.bg }}>
      <AbsoluteFill style={{ top: seg.id === 'S1' || seg.id === 'S6E' ? 0 : 64 }}>
        {demo ? <DemoScene seg={seg} /> : Scene ? <Scene seg={seg} /> : null}
      </AbsoluteFill>
      <Header seg={seg} />
      <Captions seg={seg} demo={demo} />
      {seg.audio && (
        <Sequence from={seg.audioAt}>
          <Audio src={staticFile(seg.audio)} />
        </Sequence>
      )}
    </AbsoluteFill>
  );
};

export const Video: React.FC = () => {
  useFont();
  const segs = timeline.segments as Seg[];
  return (
    <AbsoluteFill style={{ fontFamily: FONT, color: C.text, background: C.bg }}>
      {segs.map((s) => (
        <Sequence key={s.id} from={s.start} durationInFrames={s.dur} name={s.id}>
          <SegView seg={s} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};
