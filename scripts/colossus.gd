extends RefCounted
## An announced temporary route hazard; the central hologram has no contact hitbox.
var active:=false
var defeated:=false
var hp:=3
var charges:=0
var phase:="idle"
var next_at:=0.0
var cycle:=0
var hit_cycle:=-1
var cells:Array=[]
func reset() -> void:
	active=false;defeated=false;hp=3;charges=0;phase="idle";next_at=0;cycle=0;hit_cycle=-1;cells.clear()
func start(sim) -> void:
	sim.bonus.active=false
	active=true;phase="warning";next_at=sim.time+1.6;choose_lane(sim)
	for c in [Vector2i(1,1),Vector2i(15,1),Vector2i(15,11)]:sim.pickups[c]="power"
	sim.initial_pellets+=3
	sim.events.append({"type":"boss_intro","pos":Vector2(8,5.5)})
func choose_lane(sim) -> void:
	cells.clear();var row:int=[3,11,7][cycle%3]
	for x in range(1,16):
		if sim.walkable(Vector2i(x,row)):cells.append(Vector2i(x,row))
func update(sim) -> void:
	if not active or defeated:return
	var guard:=0
	while sim.time>=next_at and guard<8:
		guard+=1
		if phase=="warning":phase="attack";next_at+=0.9
		elif phase=="attack":phase="recover";next_at+=3.0
		else:phase="warning";cycle+=1;choose_lane(sim);next_at+=1.6
		sim.events.append({"type":"boss_"+phase,"pos":Vector2(8,5.5)})
func pulse(sim) -> bool:
	if not active or defeated or phase!="recover" or sim.time>=next_at or hit_cycle==cycle or charges<=0 or sim.paused or sim.status!="playing":return false
	charges-=1;hp-=1;hit_cycle=cycle
	sim.pending_events.append({"type":"boss_hit","pos":Vector2(8,5.5),"hp":hp})
	if hp==0:defeated=true;active=false;sim.score+=1500
	return true
func on_death(sim) -> void:
	if active:phase="warning";next_at=sim.time+3.5;cycle+=1;choose_lane(sim)
