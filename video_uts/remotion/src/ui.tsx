import React from 'react';
import { interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

export const C = {
  primary: '#6D4C41',
  primaryDark: '#4E342E',
  amber: '#C8873A',
  bg: '#FBF7F3',
  card: '#FFFFFF',
  soft: '#F3E9E2',
  text: '#2B1D17',
  muted: '#7A675E',
  line: '#E6D9CF',
  success: '#2E7D32',
  warn: '#B45309',
  error: '#C62828',
};

export const FONT = "'Roboto', system-ui, sans-serif";

/** Muncul halus (fade + naik) mulai frame `at` (relatif ke Sequence). */
export const useAppear = (at: number, dist = 24) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = spring({ frame: f - at, fps, config: { damping: 200 }, durationInFrames: 18 });
  return { opacity: s, transform: `translateY(${(1 - s) * dist}px)` } as React.CSSProperties;
};

export const Appear: React.FC<{ at: number; style?: React.CSSProperties; children: React.ReactNode; dist?: number }> = ({ at, style, children, dist }) => {
  const a = useAppear(at, dist);
  return <div style={{ ...style, ...a }}>{children}</div>;
};

/** true bila frame sekarang sudah melewati `at` (untuk penanda aktif). */
export const useActive = (at: number) => useCurrentFrame() >= at;

export const Title: React.FC<{ kicker: string; title: string; at?: number }> = ({ kicker, title, at = 0 }) => (
  <Appear at={at} style={{ marginBottom: 36 }}>
    <div style={{ color: C.amber, fontSize: 24, fontWeight: 700, letterSpacing: 3, textTransform: 'uppercase' }}>{kicker}</div>
    <div style={{ color: C.primaryDark, fontSize: 56, fontWeight: 800, marginTop: 6, lineHeight: 1.1 }}>{title}</div>
  </Appear>
);

export const Card: React.FC<{ style?: React.CSSProperties; children: React.ReactNode }> = ({ style, children }) => (
  <div
    style={{
      background: C.card,
      borderRadius: 20,
      padding: '24px 28px',
      boxShadow: '0 2px 0 rgba(78,52,46,0.06), 0 12px 32px rgba(78,52,46,0.08)',
      border: `1px solid ${C.line}`,
      ...style,
    }}
  >
    {children}
  </div>
);

export const Pill: React.FC<{ color: string; children: React.ReactNode; style?: React.CSSProperties }> = ({ color, children, style }) => (
  <span
    style={{
      display: 'inline-block',
      padding: '4px 14px',
      borderRadius: 999,
      background: color + '1A',
      color,
      fontWeight: 700,
      fontSize: 20,
      ...style,
    }}
  >
    {children}
  </span>
);

/** Ikon gelas es teh sederhana (SVG orisinal). */
export const CupIcon: React.FC<{ size?: number }> = ({ size = 120 }) => (
  <svg width={size} height={size} viewBox="0 0 120 120">
    <rect x="68" y="6" width="8" height="40" rx="4" fill={C.amber} transform="rotate(14 72 26)" />
    <path d="M26 30 H94 L86 108 Q85 114 79 114 H41 Q35 114 34 108 Z" fill="#fff" stroke={C.primary} strokeWidth="5" />
    <path d="M30 52 H90 L85 106 Q84 110 80 110 H40 Q36 110 35 106 Z" fill={C.amber} opacity="0.85" />
    <rect x="42" y="60" width="14" height="14" rx="3" fill="#fff" opacity="0.7" transform="rotate(-12 49 67)" />
    <rect x="62" y="72" width="14" height="14" rx="3" fill="#fff" opacity="0.6" transform="rotate(10 69 79)" />
    <rect x="22" y="24" width="76" height="10" rx="5" fill={C.primary} />
  </svg>
);

export const fadeOutAt = (frame: number, dur: number, len = 10) =>
  interpolate(frame, [dur - len, dur], [1, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' });
