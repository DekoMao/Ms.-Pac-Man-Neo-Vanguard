"""Original reward tones; keeps the approved soundtrack unchanged."""
from pathlib import Path
import math,wave,array
root=Path(__file__).resolve().parents[1]/'assets/audio';rate=22050
for name,notes,duration in [('capture_1',[523.25,659.25],.42),('capture_2',[587.33,783.99],.42),('capture_3',[659.25,880,1046.5],.42),('capture_4',[783.99,987.77,1174.66,1567.98],.62),('bonus_spawn',[659.25,987.77],.38),('bonus_caught',[783.99,1046.5,1318.51],.58)]:
 values=array.array('h')
 for i in range(round(rate*duration)):
  t=i/rate;v=0
  for j,f in enumerate(notes):
   q=t-j*.055
   if q>=0:v+=.20*(math.sin(math.tau*f*q)+.22*math.sin(math.tau*f*2*q))*min(1,q/.004)*math.exp(-q*11)
  values.append(round(max(-.75,min(.75,v))*32767))
 with wave.open(str(root/(name+'.wav')),'wb') as w:w.setparams((1,2,rate,len(values),'NONE','not compressed'));w.writeframes(values.tobytes())
