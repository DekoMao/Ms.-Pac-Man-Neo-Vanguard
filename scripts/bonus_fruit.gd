extends RefCounted
const WINDOWS=[12.0,34.0]
var active:=false
var cursor:=0
var end_at:=-1.0
var caught:=0
var earned:=0
var patrol:=0
var actor:Dictionary={}
func reset() -> void:
	active=false;cursor=0;end_at=-1;caught=0;earned=0;patrol=0
	actor={"pos":Vector2(15,9),"previous":Vector2(15,9),"dir":Vector2i.ZERO,"state":"bonus"}
func prepare(sim,dt:float) -> Array:
	if not sim.campaign or sim.boss.active:return []
	if active and sim.time>=end_at:expire(sim)
	while not active and cursor<2 and sim.time>=WINDOWS[cursor]:
		var start:float=WINDOWS[cursor];cursor+=1
		var duration:float=10.0 if sim.stage_id==4 else 12.0
		if sim.time>=start+duration:continue
		var best:=Vector2i(15,9);var cost:=10000
		for cell in [Vector2i(15,9),Vector2i(1,3),Vector2i(15,11),Vector2i(1,11),Vector2i(8,1)]:
			if not sim.walkable(cell):continue
			var distance:int=sim.path_distance(Vector2i(sim.player.pos.round()),cell)
			var candidate:int=absi(distance-7)+(20 if distance<3 else 0)
			if candidate<cost:cost=candidate;best=cell
		actor={"pos":Vector2(best),"previous":Vector2(best),"dir":Vector2i.ZERO,"state":"bonus"}
		active=true;end_at=start+duration;patrol=(sim.stage_id+cursor)%4
		sim.events.append({"type":"bonus_spawn","pos":actor.pos,"until":end_at})
	if not active:return []
	actor.previous=actor.pos
	return sim.advance(actor,(2.25 if sim.stage_id==4 else 1.75)*dt,false)
func direction(sim,cell:Vector2i) -> Vector2i:
	var options:Array=[]
	for d in sim.DIRS:
		if sim.walkable(sim.neighbor(cell,d)):options.append(d)
	if options.is_empty():return Vector2i.ZERO
	if options.size()>1:options.erase(-actor.dir)
	var pc:=Vector2i(sim.player.pos.round())
	var flee:bool=sim.path_distance(cell,pc)<=3
	var targets=[Vector2i(15,1),Vector2i(1,11),Vector2i(1,1),Vector2i(15,11)]
	if cell==targets[patrol]:patrol=(patrol+1)%4
	var target:Vector2i=pc if flee else targets[patrol]
	var best:Vector2i=options[0];var value:=-10000
	for d in options:
		var distance:int=sim.path_distance(sim.neighbor(cell,d),target)
		var utility:int=distance if flee else -distance
		if utility>value:value=utility;best=d
	return best
func collect(sim,at:float) -> bool:
	if not active or at>=end_at or sim.status!="playing":return false
	active=false;caught+=1
	var points:int=roundi((300+100*sim.stage_id)*sim.flow)
	earned+=points;sim.score+=points;sim.energy=minf(100,sim.energy+15)
	sim.events.append({"type":"bonus_caught","pos":actor.pos,"points":points})
	return true
func expire(sim) -> void:
	if not active:return
	active=false;sim.events.append({"type":"bonus_expired","pos":actor.pos})
