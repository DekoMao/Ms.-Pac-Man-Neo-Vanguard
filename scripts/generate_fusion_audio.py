"""Original pulse bomb effects; no benchmark audio or commercial samples."""
from pathlib import Path
import array, math, random, wave
root=Path(__file__).resolve().parents[1]/'assets/audio'
rate=22050
for name,duration in [('bomb_place',.16),('bomb_explode',.55)]:
    rng=random.Random(901);values=array.array('h');phase=0.0
    for i in range(round(rate*duration)):
        t=i/rate
        frequency=(630-1600*t) if name=='bomb_place' else (155*math.exp(-t*13)+43)
        phase+=math.tau*frequency/rate
        body=math.sin(phase)*math.exp(-t*(24 if name=='bomb_place' else 8))
        noise=(rng.random()*2-1)*math.exp(-t*18)*(.08 if name=='bomb_place' else .35)
        value=(body*.55+noise)*min(1,t/.003)
        values.append(round(max(-.9,min(.9,value))*32767))
    with wave.open(str(root/(name+'.wav')),'wb') as w:
        w.setparams((1,2,rate,len(values),'NONE','not compressed'));w.writeframes(values.tobytes())
