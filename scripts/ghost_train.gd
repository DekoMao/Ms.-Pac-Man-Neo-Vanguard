extends RefCounted
const LIMIT:=8
var followers:Array=[]
var next_at:=8.0
var serial:=0
func reset(elapsed:float=0) -> void:
	followers.clear();serial=0
	next_at=8.0 if elapsed<8 else 8+20*(floorf((elapsed-8)/20)+1)
func prepare(sim,dt:float) -> Array:
	followers=followers.filter(func(g):return g.state!="returning")
	if sim.mode!="train":return []
	if sim.run_time()>=next_at:
		next_at+=20
		var spawn:=Vector2i(15,9);var best:=10000
		for c in [Vector2i(15,9),Vector2i(1,3),Vector2i(15,11),Vector2i(1,11)]:
			if not sim.walkable(c):continue
			var distance:int=sim.path_distance(Vector2i(sim.player.pos.round()),c)
			if absi(distance-6)<best:best=absi(distance-6);spawn=c
		for i in mini(2,LIMIT-followers.size()):
			serial+=1
			followers.append({"pos":Vector2(spawn),"previous":Vector2(spawn),"dir":Vector2i.ZERO,"state":"train","train":true,"id":100+serial,"immune":-1,"safe_until":sim.time+0.7})
			for d in sim.DIRS:
				if sim.walkable(sim.neighbor(spawn,d)):spawn=sim.neighbor(spawn,d);break
		sim.events.append({"type":"train_spawn","pos":Vector2(spawn),"count":followers.size()})
	var paths:Array=[]
	for i in followers.size():
		var g:Dictionary=followers[i];g.previous=g.pos
		g.state="vulnerable" if sim.time<sim.power_until else "train"
		g.target=sim.player.previous if i==0 else followers[i-1].previous
		g.head=i==0
		var moving:bool=i==0 or g.pos.distance_to(followers[i-1].pos)>0.85
		paths.append({"actor":g,"path":sim.advance(g,(1.30 if g.state=="vulnerable" else 2.65)*dt if moving else 0.0,false)})
	return paths
func direction(sim,g:Dictionary,cell:Vector2i) -> Vector2i:
	var options:Array=[]
	for d in sim.DIRS:
		if sim.walkable(sim.neighbor(cell,d)):options.append(d)
	if options.is_empty():return Vector2i.ZERO
	if options.size()>1:options.erase(-g.dir)
	var target:=Vector2i(g.target.round());var best:Vector2i=options[0];var value:=-10000
	for d in options:
		var dist:int=sim.path_distance(sim.neighbor(cell,d),target)
		var utility:int=dist if g.head and g.state=="vulnerable" else -dist
		if utility>value:value=utility;best=d
	return best
