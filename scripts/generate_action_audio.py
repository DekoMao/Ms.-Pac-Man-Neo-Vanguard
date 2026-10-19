"""Original additive/noise cues; no external audio or dependencies. 112 BPM layers."""
from pathlib import Path
import math
import random
import wave
import array

ROOT=Path(__file__).resolve().parents[1]/'assets/audio'
RATE=22050
BEAT=60/112

def save(name,duration,synth):
    samples=array.array('h')
    peak=0.0
    for i in range(round(duration*RATE)):
        t=i/RATE
        value=max(-0.92,min(0.92,synth(t)))
        peak=max(peak,abs(value))
        samples.append(round(value*32767))
    with wave.open(str(ROOT/(name+'.wav')),'wb') as w:
        w.setparams((1,2,RATE,len(samples),'NONE','not compressed'))
        w.writeframes(samples.tobytes())
    print(name,len(samples),round(peak,3))

def tone(t,f):return math.sin(math.tau*f*t)
def env(t,d):return max(0.0,1-t/d)**2*min(1.0,t/0.008)
rng=random.Random(73021)
save('near_miss',0.48,lambda t:(0.30*rng.uniform(-1,1)+0.30*tone(t,650+1800*t))*env(t,0.48))
save('pressure',0.75,lambda t:0.45*(tone(t,110)+0.3*tone(t,220))*env(t%0.25,0.20))
save('power_warning',0.80,lambda t:0.44*tone(t,[880,660,440][min(2,int(t/0.25))])*env(t%0.25,0.22))
save('power_end',0.50,lambda t:0.40*tone(t,380-400*t)*env(t,0.5))
save('risk_start',0.40,lambda t:0.38*(tone(t,330)+0.5*tone(t,660))*env(t,0.4))
save('risk_success',0.90,lambda t:0.18*sum(tone(t,f) for f in [523.25,659.25,783.99])*env(t,0.9))
def tension(t):
    local=t%(BEAT*0.5)
    kick=tone(local,95-110*min(local,0.3))*math.exp(-local*20)
    tick=rng.uniform(-1,1)*math.exp(-local*100)
    return 0.48*kick+0.12*tick
def hunt(t):
    step=int(t/(BEAT*0.5))%8
    f=[523.25,659.25,783.99,1046.5,783.99,659.25,587.33,783.99][step]
    local=t%(BEAT*0.5)
    return (0.24*tone(t,f)+0.08*tone(t,f*2))*env(local,BEAT*0.45)
save('tension_layer',32*BEAT,tension)
save('hunt_layer',32*BEAT,hunt)
