extends RefCounted
## Original Godot implementation of grid bombs, independent of presentation.
const FUSE:=2.3
const FLAME:=0.65
const CHAIN_DELAY:=0.1
const DIRS=[Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]
var crates:Dictionary={}
var bombs:Array=[]
var flames:Array=[]
var drops:Dictionary={}
var capacity:=2
var radius:=2
var serial:=0
var broken:=0
var placed:=0
var chained:=0
var total_crates:=0
var next_place:=0.0

func reset(r,carry:Dictionary) -> void:
	crates.clear();bombs.clear();flames.clear();drops.clear()
	capacity=clampi(int(carry.get("bomb_capacity",2)),2,4)
	radius=clampi(int(carry.get("bomb_radius",2)),2,5)
	serial=0;broken=0;placed=0;chained=0;next_place=0
	if r.mode!="fusion":total_crates=0;return
	# Replace a handful of internal walls with amber caches. Baseline corridors,
	# house, exits and tunnels stay intact; each cache opens a new connection.
	var candidates:Array=[]
	for y in range(2,11):
		for x in range(2,15):
			var c:=Vector2i(x,y)
			if r.floors.has(c) or c in r.HOUSE or c==r.DOOR or c==r.open_cell or c==r.close_cell:continue
			if c.distance_to(Vector2i(8,5))<3:continue
			var neighbors:=0
			for d in DIRS:
				if r.walkable(c+d):neighbors+=1
			if neighbors>=2:candidates.append(c)
	# Spatially distributed and deterministic, including a visible early cache.
	var anchors=[Vector2i(2,8),Vector2i(14,8),Vector2i(4,2),Vector2i(12,2),Vector2i(4,10),Vector2i(12,10)]
	for i in anchors.size():
		var best:=Vector2i(-1,-1);var distance:=100000.0
		for c in candidates:
			if crates.has(c):continue
			var dist:float=c.distance_squared_to(anchors[(i+r.stage_id)%anchors.size()])
			if dist<distance:distance=dist;best=c
		if best.x<0:continue
		crates[best]=["capacity","range","shield","range","capacity","energy"][i]
	# Add the floor only after selection, so a cache never relies on another cache.
	for c in crates:r.floors[c]=true;r.pickups[c]="pellet"
	total_crates=crates.size()

func actor_key(a:Dictionary,is_player:bool) -> String:
	return "player" if is_player else str(a.get("id",-1))

func can_enter(c:Vector2i,a:Dictionary,is_player:bool) -> bool:
	if a.get("state","")=="returning":return true
	for b in bombs:
		if b.cell==c and not b.passers.has(actor_key(a,is_player)):return false
	return true

func request(r) -> bool:
	if r.mode!="fusion" or r.status!="playing" or r.paused or r.time<next_place or bombs.size()>=capacity:return false
	var c:=Vector2i(r.player.pos.round())
	if c.x<0 or c.x>16 or not r.walkable(c) or crates.has(c):return false
	if bombs.any(func(b):return b.cell==c):return false
	for f in flames:
		if c in f.cells and r.time<f.end:return false
	serial+=1;placed+=1;next_place=r.time+0.18
	var passers:Dictionary={"player":true}
	for g in r.ghosts:
		if g.pos.distance_to(Vector2(c))<1.0:passers[actor_key(g,false)]=true
	bombs.append({"id":serial,"cell":c,"at":r.time+FUSE,"placed":r.time,"radius":radius,"passers":passers,"chain":false})
	r.pending_events.append({"type":"bomb_placed","pos":Vector2(c)})
	return true

func next_deadline(now:float) -> float:
	var result:=INF
	for b in bombs:
		if b.at>now+0.00000001:result=minf(result,b.at)
	for f in flames:
		if f.end>now+0.00000001:result=minf(result,f.end)
	return result

func ray_cells(r,b:Dictionary) -> Array:
	var cells:Array=[b.cell]
	for d in DIRS:
		for length in range(1,int(b.radius)+1):
			# Flames never wrap through tunnels or damage the opposite screen edge.
			var c:Vector2i=b.cell+d*length
			if not r.floors.has(c) or c in r.HOUSE or c==r.DOOR:break
			cells.append(c)
			if crates.has(c) or bombs.any(func(other):return other.cell==c):break
	return cells

func update(r) -> void:
	flames=flames.filter(func(f):return r.time<f.end-0.00000001)
	for b in bombs:
		for key in b.passers.keys():
			var a:Dictionary=r.player
			if key!="player":
				var id:=int(key)
				if id<0 or id>=r.ghosts.size():b.passers.erase(key);continue
				a=r.ghosts[id]
			if a.pos.distance_to(Vector2(b.cell))>=1.0-0.00001:b.passers.erase(key)
	# Snapshot blockers: simultaneous detonations cannot leak through a cache
	# destroyed by another bomb at that same simulation instant.
	var due:Array=bombs.filter(func(b):return b.at<=r.time+0.00000001)
	var plans:Array=[]
	for b in due:plans.append({"bomb":b,"cells":ray_cells(r,b)})
	for plan in plans:
		var b:Dictionary=plan.bomb;var cells:Array=plan.cells
		bombs.erase(b)
		flames.append({"id":b.id,"cells":cells,"start":r.time,"end":r.time+FLAME,"hit_ghosts":{}})
		if b.chain:chained+=1
		r.events.append({"type":"bomb_exploded","pos":Vector2(b.cell),"chain":b.chain})
		for c in cells:
			if crates.has(c):
				var kind:String=crates[c];crates.erase(c);broken+=1
				drops[c]=kind
				r.score+=50
				r.events.append({"type":"cache_open","pos":Vector2(c),"kind":kind})
			for other in bombs:
				if other.cell==c and other.at>r.time+CHAIN_DELAY:
					other.at=r.time+CHAIN_DELAY;other.chain=true

func contacts(r,player_path:Array,ghost_paths:Array,dt:float) -> Array:
	var result:Array=[]
	for f in flames:
		for c in f.cells:
			var path:Array=[{"a":Vector2(c),"b":Vector2(c),"t0":0.0,"t1":1.0}]
			var hit:float=r.path_contact(player_path,path,0.60)
			if hit<=1 and r.time+dt*hit<f.end:result.append({"type":"flame_player","at":hit,"priority":2})
			for i in r.ghosts.size():
				if r.ghosts[i].state in ["house","leaving","returning"]:continue
				hit=r.path_contact(ghost_paths[i],path,0.60)
				if hit<=1 and r.time+dt*hit<f.end:result.append({"type":"flame_ghost","at":hit,"priority":1.5,"index":i,"flame":f})
	for c in drops:
		# Newly exposed power-ups stay on the ground until the flame has cleared.
		if flames.any(func(f):return c in f.cells):continue
		var hit:float=r.path_contact(player_path,[{"a":Vector2(c),"b":Vector2(c),"t0":0.0,"t1":1.0}],0.32)
		if hit<=1:result.append({"type":"bomb_upgrade","at":hit,"priority":0,"cell":c})
	return result

func hit_ghost(r,g:Dictionary,f:Dictionary,at:float) -> void:
	if g.state in ["house","leaving","returning"]:return
	if g.state=="vulnerable" and r.power_until<=at+0.00000001:g.state=r.normal_state()
	if g.state=="vulnerable":r.capture(g,at);return
	if f.hit_ghosts.has(g.id):return
	f.hit_ghosts[g.id]=true
	g.stunned_until=maxf(g.get("stunned_until",-1.0),at+1.8)
	r.events.append({"type":"ghost_stunned","pos":g.pos,"ghost_id":g.id})

func boundary_hits(r) -> void:
	# A detonation exactly at the end of a tick applies at that instant too.
	for f in flames:
		for c in f.cells:
			for g in r.ghosts:
				if g.pos.distance_to(Vector2(c))<=0.60:hit_ghost(r,g,f,r.time)
			if r.player.pos.distance_to(Vector2(c))<=0.60 and not r.block_hit(r.time):
				r.die();return

func collect_drop(r,c:Vector2i) -> void:
	if not drops.has(c):return
	var kind:String=drops[c];drops.erase(c)
	match kind:
		"capacity":capacity=mini(4,capacity+1)
		"range":radius=mini(5,radius+1)
		"shield":r.shield_charges=mini(2,r.shield_charges+1)
		"energy":r.energy=100.0
	r.score+=100
	r.events.append({"type":"bomb_upgrade","pos":Vector2(c),"kind":kind})

func on_death(r) -> void:
	# Do not leave invisible fuse hazards under a respawn. Keep opened routes
	# and earned upgrades, but remove live ordnance and ghost stun.
	bombs.clear();flames.clear()
	for g in r.ghosts:g.stunned_until=-1.0

func carry() -> Dictionary:return {"bomb_capacity":capacity,"bomb_radius":radius}
