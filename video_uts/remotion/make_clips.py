import json,subprocess,os
R='/home/claude/video/rec'
fr=json.load(open(f'{R}/frames.json')); ev=json.load(open(f'{R}/events.json'))
marks=[e for e in ev if e['type']=='mark']
segs={}
for a,b in zip(marks,marks[1:]):
    t0,t1=a['t'],b['t']; name=a['name']
    sel=[f for f in fr if t0<=f['t']<t1]
    prev=[f for f in fr if f['t']<t0]
    if prev: sel=[{'t':t0,'name':prev[-1]['name']}]+sel
    lines=['ffconcat version 1.0']
    for i,f in enumerate(sel):
        nxt=sel[i+1]['t'] if i+1<len(sel) else t1
        lines+= [f"file '{R}/frames/{f['name']}'", f"duration {max(nxt-f['t'],0.001):.4f}"]
    lines.append(f"file '{R}/frames/{sel[-1]['name']}'")
    open(f'/tmp/{name}.txt','w').write('\n'.join(lines))
    out=f'/home/claude/video/remotion/public/clips/{name}.mp4'
    subprocess.run(['ffmpeg','-y','-loglevel','error','-f','concat','-safe','0','-i',f'/tmp/{name}.txt',
      '-vf','fps=30,tpad=stop_mode=clone:stop_duration=25,format=yuv420p','-c:v','libx264','-crf','18','-preset','veryfast','-movflags','+faststart',out+'.tmp.mp4'],check=True)
    os.rename(out+'.tmp.mp4',out)
    segs[name]={'len':round(t1-t0,3),'events':[{**{k:v for k,v in e.items() if k!='t'},'t':round(e['t']-t0,3)} for e in ev if t0<=e['t']<t1 and e['type'] in('move','tap')]}
    print(name,round(t1-t0,2),len(sel))
json.dump(segs,open('/home/claude/video/remotion/src/demo.json','w'))
