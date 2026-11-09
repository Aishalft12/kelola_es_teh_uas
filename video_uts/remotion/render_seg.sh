#!/bin/bash
# render satu/lebih segmen: render_seg.sh S1 D4 ...
HS=/opt/pw-browsers/chromium_headless_shell-1243/chrome-headless-shell-linux64/chrome-headless-shell
cd /home/claude/video/remotion
for id in "$@"; do
  r=$(python3 -c "import json;t=json.load(open('src/timeline.json'));s=[x for x in t['segments'] if x['id']=='$id'][0];print(f\"{s['start']}-{s['start']+s['dur']-1}\")")
  tmp=/home/claude/video/out/$id.part.mp4
  node node_modules/@remotion/cli/remotion-cli.js render src/index.ts UTS $tmp --frames=$r --muted --codec=h264 --crf=18 --x264-preset=veryfast --pixel-format=yuv420p --concurrency=2 --browser-executable=$HS --log=error >/home/claude/video/out/$id.log 2>&1 \
    && mv $tmp /home/claude/video/out/$id.mp4 && echo "OK $id" || { echo "GAGAL $id"; tail -5 /home/claude/video/out/$id.log; }
done
