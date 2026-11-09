// Membuat suara narasi (id-ID-GadisNeural, gratis) untuk setiap segmen di segmen.json
const fs = require('fs');
const path = require('path');
const { MsEdgeTTS, OUTPUT_FORMAT } = require('msedge-tts');

const segmen = JSON.parse(fs.readFileSync(path.join(__dirname, 'segmen.json'), 'utf8'));
const OUT = path.join(__dirname, 'audio');
fs.mkdirSync(OUT, { recursive: true });

(async () => {
  for (const s of segmen) {
    const target = path.join(OUT, s.id + '.mp3');
    if (fs.existsSync(target) && fs.statSync(target).size > 1000) { console.log('lewati', s.id); continue; }
    for (let coba = 1; coba <= 3; coba++) {
      try {
        const tts = new MsEdgeTTS();
        await tts.setMetadata('id-ID-GadisNeural', OUTPUT_FORMAT.AUDIO_24KHZ_96KBITRATE_MONO_MP3);
        const tmp = fs.mkdtempSync(path.join(OUT, 'tmp-'));
        await tts.toFile(tmp, s.text);
        const mp3 = fs.readdirSync(tmp).find((f) => f.endsWith('.mp3'));
        fs.copyFileSync(path.join(tmp, mp3), target);
        fs.rmSync(tmp, { recursive: true, force: true });
        try { tts.close(); } catch {}
        console.log('OK', s.id);
        break;
      } catch (e) {
        console.log('gagal', s.id, 'percobaan', coba, e.message || e);
        if (coba === 3) process.exitCode = 1;
      }
    }
  }
  console.log('Selesai. File ada di folder tts\\audio');
})();
