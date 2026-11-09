import json,subprocess
R='/home/claude/video/remotion'
t=json.load(open(f'{R}/src/timeline.json'));FPS=30
args=[];fl=[]
segs=[s for s in t['segments'] if s['audio']]
for i,s in enumerate(segs):
    args+=['-i',f"{R}/public/{s['audio']}"]
    ms=round((s['start']+s['audioAt'])/FPS*1000)
    fl.append(f'[{i}:a]aresample=48000,aformat=channel_layouts=mono,adelay={ms}:all=1[a{i}]')
fl.append(''.join(f'[a{i}]' for i in range(len(segs)))+f'amix=inputs={len(segs)}:normalize=0:dropout_transition=0,apad,atrim=0:{t["total"]/FPS:.3f},loudnorm=I=-16:TP=-1.5:LRA=11[out]')
subprocess.run(['ffmpeg','-y','-v','error',*args,'-filter_complex',';'.join(fl),'-map','[out]','-ar','48000','-ac','2','-c:a','aac','-b:a','192k','/home/claude/video/out/narasi.m4a'],check=True)
print('ok')
