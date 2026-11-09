"""Susun timeline.json dari segmen.json + durasi audio (ffprobe).
Bila audio belum ada, durasi diperkirakan dari jumlah karakter (untuk uji tampilan)."""
import json, os, re, subprocess, sys

FPS = 30
ROOT = '/home/claude/video/remotion'
segs = json.load(open('/mnt/user-data/outputs/video_uts/tts/segmen.json'))
demo = json.load(open(f'{ROOT}/src/demo.json'))
AUD = f'{ROOT}/public/audio'
LEAD = 0.35   # jeda sebelum narasi mulai
TAIL = 0.6   # jeda setelah narasi


def dur(path):
    out = subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', path], capture_output=True, text=True).stdout
    return float(out.strip())


def sentences(text):
    # pisah per kalimat; abaikan titik di dalam angka (23.01.55.0012)
    parts = re.split(r'(?<=[.?!])\s+(?=[A-Z0-9])', text.strip())
    return [p for p in parts if p]


def chunks(sentence, maxlen=95):
    if len(sentence) <= maxlen:
        return [sentence]
    words, out, cur = sentence.split(' '), [], ''
    for w in words:
        if cur and len(cur) + 1 + len(w) > maxlen:
            out.append(cur); cur = w
        else:
            cur = (cur + ' ' + w).strip()
        if cur.endswith((',', ':')) and len(cur) > maxlen * 0.55:
            out.append(cur); cur = ''
    if cur:
        out.append(cur)
    return out


# (indeks kalimat, waktu aksi di klip) — aksi ditahan sampai narasi menyebutnya
ANCHORS = {
    'D1': [(2, 3.4)],
    'D2': [(0, 0.7), (2, 6.5)],
    'D3': [(0, 0.6), (2, 3.3)],
    'D4': [(1, 0.8), (2, 5.5), (3, 9.3), (4, 13.9)],
    'D5': [(1, 11.8)],
    'D6': [(0, 0.7), (2, 4.0)],
    'D7': [(0, 0.8), (1, 7.9), (2, 14.0), (3, 20.2)],
}
RATE = {'D1': 1.6}  # potongan terakhir diputar lebih cepat
timeline, t = [], 0
estimated = False
for s in segs:
    a = f'{AUD}/{s["id"]}.mp3'
    if os.path.exists(a):
        ad = dur(a)
    else:
        ad = len(s['text']) / 15.5; estimated = True
    total = LEAD + ad + TAIL
    pieces = None
    if s['id'] in ('S1',):
        total += 0.5
    nfr = round(total * FPS)
    # waktu kalimat & caption proporsional terhadap jumlah karakter
    sents = sentences(s['text'])
    nchar = sum(len(x) for x in sents)
    cues, caps, cur = [], [], LEAD
    for x in sents:
        sd = ad * len(x) / nchar
        cues.append(round(cur * FPS))
        cs = chunks(x)
        cc = sum(len(c) for c in cs)
        cc_t = cur
        for c in cs:
            d = sd * len(c) / cc
            caps.append({'text': c, 'from': round(cc_t * FPS), 'to': round((cc_t + d) * FPS)})
            cc_t += d
        cur += sd
    if s['id'] in ANCHORS:
        pieces, end = [], 0
        sc, cp = 0.0, 0.0  # waktu scene, waktu klip
        for si, act in ANCHORS[s['id']]:
            c = cues[si] / FPS if si >= 0 else 0
            if act > cp:
                pieces.append({'from': round(sc * FPS), 'clipFrom': round(cp * FPS), 'len': round((act - cp) * FPS), 'freeze': False})
                sc += act - cp; cp = act
            if c > sc:
                pieces.append({'from': round(sc * FPS), 'clipFrom': round(cp * FPS), 'len': round((c - sc) * FPS), 'freeze': True})
                sc = c
        L = demo[s['id']]['len']
        rate = RATE.get(s['id'], 1.0)
        pieces.append({'from': round(sc * FPS), 'clipFrom': round(cp * FPS), 'len': round((L - cp + 30) * FPS), 'freeze': False, 'rate': rate})
        nfr = max(nfr, round((sc + (L - cp) / rate + 0.6) * FPS))
    timeline.append({'id': s['id'], 'start': t, 'dur': nfr, 'pieces': pieces, 'audio': f'audio/{s["id"]}.mp3' if os.path.exists(a) else None,
                     'audioAt': round(LEAD * FPS), 'cues': cues, 'captions': caps})
    t += nfr

figdir = f'{ROOT}/public/figma'
figma = sorted(f'figma/{f}' for f in os.listdir(figdir)) if os.path.isdir(figdir) else []
# gambar diam untuk potongan freeze
for x in timeline:
    for p in x['pieces'] or []:
        if p['freeze']:
            img = f"clips/{x['id']}_{p['clipFrom']}.jpg"
            p['img'] = img
            out = f'{ROOT}/public/{img}'
            if not os.path.exists(out):
                subprocess.run(['ffmpeg', '-y', '-v', 'error', '-ss', f"{p['clipFrom'] / FPS:.4f}", '-i', f"{ROOT}/public/clips/{x['id']}.mp4", '-frames:v', '1', '-q:v', '2', out], check=True)
json.dump({'total': t, 'segments': timeline, 'figma': figma}, open(f'{ROOT}/src/timeline.json', 'w'), ensure_ascii=False)
print(f'total {t/FPS:.1f} s = {int(t/FPS//60)}:{t/FPS%60:04.1f}', '(PERKIRAAN)' if estimated else '')
for x in timeline:
    print(x['id'], round(x['dur'] / FPS, 1), len(x['cues']), 'kalimat')
