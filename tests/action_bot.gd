extends RefCounted
## Deterministic automated player for reproducible recordings, never edits state.
const DIRS=[Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]
var caution:=1.5
func commands(r) -> Dictionary:
	var cmd:Dictionary={}
	if r.status!="playing" or r.paused:return cmd
	if r.power_until-r.time>2.0:cmd.risk=true
	var c:=Vector2i(r.player.pos.round())
	if r.player.pos.distance_to(Vector2(c))>0.055:return cmd
	var target:=c
	var best:=100000.0
	var hunt:bool=r.power_until-r.time>0.9
	if hunt:
		for g in r.ghosts:
			if g.state!="vulnerable":continue
			var distance:int=r.path_distance(c,Vector2i(g.pos.round()))
			if distance<best and distance<(r.power_until-r.time)*3.0:best=distance;target=Vector2i(g.pos.round())
	if best==100000:
		for cell in r.pickups:
			var d:float=r.path_distance(c,cell)
			if r.pickups[cell]=="power" and not hunt:d-=4.0
			if d<best:best=d;target=cell
	var value:=-100000.0
	var direction:=Vector2i.ZERO
	var lethal_gap:=100.0
	for g in r.ghosts:
		if g.state in ["chase","scatter"]:lethal_gap=minf(lethal_gap,r.player.pos.distance_to(g.pos))
	for d in DIRS:
		if not r.floors.has(c+d):continue
		var score:float=-r.path_distance(c+d,target)
		if d==-r.player.dir:score-=0.6
		for g in r.ghosts:
			if g.state not in ["chase","scatter"]:continue
			var gap:float=Vector2(c+d).distance_to(g.pos)
			var route_gap:int=r.path_distance(c+d,Vector2i(g.pos.round()))
			score-=maxf(0.0,3.0-minf(route_gap,gap))*caution
		if score>value:value=score;direction=d
	if direction!=Vector2i.ZERO:cmd.direction=[direction.x,direction.y]
	if r.time>0.25 and r.floors.has(c+direction*2) and direction==r.player.dir and lethal_gap>2.3:
		cmd.dash=true
	return cmd

func apply(r,cmd:Dictionary) -> void:
	if cmd.has("direction"):
		var d:=Vector2i(int(cmd.direction[0]),int(cmd.direction[1]))
		if r.player.dir!=d:r.request_direction(d)
		else:r.held_dir=d
	if cmd.get("risk",false) and r.has_method("request_risk"):r.request_risk()
	if cmd.get("dash",false):r.request_dash()
