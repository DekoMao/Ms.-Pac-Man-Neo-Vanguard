class_name NeoRules
extends RefCounted
## Simulação planar própria: não utiliza nem emula ROMs.

const DIRS = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
const STEP := 1.0 / 120.0
const GRID = [
	"#################",
	"#o.............o#",
	"#.##.##.#.##.##.#",
	"#...............#",
	"#.##.#.###.#.##.#",
	"#....#.....#....#",
	"###.###...###.###",
	"#....#.....#....#",
	"#.##.#.###.#.##.#",
	"#...............#",
	"#.##.##.#.##.##.#",
	"#o.............o#",
	"#################"
]
const HOME = [Vector2i(7,5), Vector2i(8,5), Vector2i(9,5), Vector2i(8,6)]
const OPEN_CELL := Vector2i(5,5)
const CLOSE_CELL := Vector2i(8,3)
const PLAYER_RADIUS := 0.29
const GHOST_RADIUS := 0.30
const Stages = preload("res://scripts/stages.gd")
const TUNNEL_ROWS = [5,9]
const HOUSE = [Vector2i(7,5),Vector2i(8,5),Vector2i(9,5),Vector2i(7,6),Vector2i(8,6),Vector2i(9,6)]
const DOOR := Vector2i(8,4)
const EXIT := Vector2i(8,3)

var grid:Array = GRID
var open_cell := OPEN_CELL
var close_cell := CLOSE_CELL
var stage_id := 0
var campaign := false
var stage_deaths := 0
var stage_captures := 0
var shield_charges := 0
var magnet_charges := 0
var shield_until := -1.0
var grace_until := -1.0
var magnet_until := -1.0

var tuning: Dictionary
var floors: Dictionary = {}
var pickups: Dictionary = {}
var player: Dictionary
var ghosts: Array = []
var events: Array = []
var pending_events: Array = []
var time := 0.0
var score := 0
var lives := 3
var energy := 100.0
var power_until := -1.0
var window_id := 0
var combo := 0
var flow := 1.0
var flow_until := -1.0
var dash_until := -1.0
var dash_ready := 0.0
var drift_until := -1.0
var drift_ready := 0.0
var buffer_dir := Vector2i.ZERO
var held_dir := Vector2i.ZERO
var buffer_time := -100.0
var status := "ready"
var paused := false
var respawn_until := 0.0
var topology: Dictionary = {}
var topology_done := false
var graph_version := 0
var collected := 0
var initial_pellets := 0
var rng := RandomNumberGenerator.new()
var pressure_level := 0
var pressure_warned := 0
var power_warned := -1
var close_passes: Dictionary = {}
var near_ready: Dictionary = {}
var risk: Dictionary = {}
var mode:="circuit"
var run_elapsed:=0.0
var pulse_index:=0
var upgrade:=""
var dash_uses:=0
var max_chain:=0
var bonus=preload("res://scripts/bonus_fruit.gd").new()
var boss=preload("res://scripts/colossus.gd").new()
var train=preload("res://scripts/ghost_train.gd").new()
var fusion=preload("res://scripts/fusion.gd").new()

func _init(seed_value: int = 73021) -> void:
	var file = FileAccess.open("res://assets/balance.json", FileAccess.READ)
	tuning = JSON.parse_string(file.get_as_text())
	rng.seed = seed_value
	reset()

func reset(level:int=0, circuit:bool=false, carry:Dictionary={}) -> void:
	stage_id = clampi(level,0,5)
	mode=str(carry.get("mode","circuit"))
	if mode not in ["circuit","overdrive","train","fusion"]:mode="circuit"
	run_elapsed=maxf(0,float(carry.get("run_elapsed",0)))
	pulse_index=int(carry.get("pulse_index",floori(run_elapsed/40)))
	upgrade=str(carry.get("upgrade",""))
	if upgrade not in ["","shield","magnet","dash"]:upgrade=""
	dash_uses=0;max_chain=0;bonus.reset();boss.reset();train.reset(run_elapsed)
	train.next_at=float(carry.get("train_next_at",train.next_at))
	campaign = circuit
	grid = Stages.layout(stage_id) if campaign else GRID.duplicate()
	open_cell = OPEN_CELL
	close_cell = Vector2i(8,9) if campaign else CLOSE_CELL
	floors.clear()
	pickups.clear()
	for y in grid.size():
		for x in grid[y].length():
			if grid[y][x] != "#":
				var c := Vector2i(x,y)
				floors[c] = true
				pickups[c] = "power" if grid[y][x] == "o" else "pellet"
	player = actor(Vector2(1,9), Vector2i.ZERO)
	ghosts.clear()
	for i in 4:
		var g := actor(Vector2(HOME[i]), Vector2i.UP)
		g.merge({"state":"house", "home":HOME[i], "release":2.5 + i * 1.2, "immune":-1, "id":i})
		ghosts.append(g)
	for c in HOME + [close_cell, Vector2i(1,9)]:
		pickups.erase(c)
	if campaign:
		for c in HOUSE + [DOOR]:pickups.erase(c)
	pickups[Vector2i(3,9)] = "fruit"
	pickups[Vector2i(5,9)] = "power"
	time = 0.0
	score = maxi(0,int(carry.get("score",0)))
	lives = clampi(int(carry.get("lives",3)),1,3)
	stage_deaths = 0
	stage_captures = 0
	shield_charges = 1 if campaign else 0
	magnet_charges = 1 if campaign and stage_id >= 1 else 0
	shield_until = -1.0
	grace_until = -1.0
	magnet_until = -1.0
	energy = 100.0
	power_until = -1.0
	window_id = 0
	combo = 0
	flow = 1.0
	flow_until = -1.0
	dash_until = -1.0
	dash_ready = 0.0
	drift_until = -1.0
	drift_ready = 0.0
	buffer_time = -100.0
	buffer_dir = Vector2i.ZERO
	held_dir = Vector2i.ZERO
	status = "ready"
	paused = false
	topology.clear()
	topology_done = false
	graph_version = 0
	collected = 0
	initial_pellets = pickups.size()
	events.clear()
	pending_events.clear()
	pressure_level = 0
	pressure_warned = 0
	power_warned = -1
	close_passes.clear()
	near_ready.clear()
	risk = {"state":"available", "progress":0, "window":-1, "deadline":-1.0}
	fusion.reset(self,carry)
	initial_pellets=pickups.size()

static func actor(pos: Vector2, dir: Vector2i) -> Dictionary:
	return {"pos":pos, "previous":pos, "dir":dir}

func start() -> void:
	if status == "ready": status = "playing"

func pickup_progress() -> Dictionary:
	# All three pickup kinds are required by the current area's win condition.
	# Read live pickups: score, Flow and captured ghosts are unrelated.
	var counts := {"pellet":0, "power":0, "fruit":0}
	for kind in pickups.values():
		counts[kind] = counts.get(kind, 0) + 1
	var fraction := clampf(float(collected) / initial_pellets, 0.0, 1.0) if initial_pellets > 0 else 1.0
	return {"total":initial_pellets, "collected":collected, "remaining":pickups.size(),
		"pellets":counts.pellet, "powers":counts.power, "fruits":counts.fruit,
		"percent":100 if pickups.is_empty() else mini(99, floori(fraction * 100.0))}

func request_direction(dir: Vector2i) -> void:
	if not DIRS.has(dir) or paused or status != "playing": return
	buffer_dir = dir
	held_dir = dir
	buffer_time = time
	# Establish the first direction immediately so direction + dash works in one
	# input frame. A fresh reset has no implicit direction.
	if player.dir == Vector2i.ZERO and walkable(neighbor(Vector2i(player.pos.round()),dir)):
		player.dir = dir
	if dash_until <= time and dir == -player.dir:
		player.dir = dir

func request_dash() -> bool:
	var cost:float=30.0 if upgrade=="dash" else tuning.dash_cost
	if status != "playing" or paused or energy < cost or time < dash_ready:
		return false
	var p: Vector2 = player.pos
	var dir: Vector2i = player.dir
	var probe := p + Vector2(dir) * 0.035
	# Permit moving only inside legal corridors, including next center/edge.
	var c := Vector2i(p.round())
	if dir == Vector2i.ZERO or (p.distance_to(Vector2(c)) < 0.001 and not walkable(neighbor(c,dir))):
		return false
	if not walkable(normalize_cell(Vector2i(probe.round()))): return false
	energy -= cost
	dash_uses+=1
	dash_until = time + tuning.dash_duration
	dash_ready = time + tuning.dash_cooldown
	pending_events.append({"type":"dash", "pos":p})
	return true

func tick(dt: float = STEP) -> void:
	if mode!="fusion":_tick_step(dt);return
	if paused or status in ["ready","won","game_over","time_up"]:return
	# Resolve fuses at exact simulation boundaries, even for coarse caller dt.
	# Only the hybrid mode uses this subdivision; existing modes retain rules.
	var remaining:=maxf(0,dt)
	var output:Array=[]
	while remaining>0.00000001 and status in ["playing","respawning"]:
		var part:=minf(STEP,remaining)
		part=minf(part,fusion.next_deadline(time)-time)
		_tick_step(part)
		output.append_array(events);events.clear()
		remaining-=part
		if status=="playing":
			fusion.update(self);fusion.boundary_hits(self)
			output.append_array(events);events.clear()
	events=output

func timed_mode() -> bool:return mode in ["overdrive","train"]
func request_bomb() -> bool:return fusion.request(self)
func can_enter(c:Vector2i,a:Dictionary,is_player:bool) -> bool:
	return walkable(c,not is_player and a.get("state","") in ["returning","leaving","house"]) and (mode!="fusion" or fusion.can_enter(c,a,is_player))

func _tick_step(dt:float) -> void:
	if paused or status in ["ready", "won", "game_over","time_up"]: return
	if campaign and timed_mode():
		dt=minf(dt,maxf(0,180.0-run_time()))
		if dt<=0:status="time_up";return
	events.assign(pending_events)
	pending_events.clear()
	if status == "respawning":
		time += dt
		if time >= respawn_until: status = "playing"
		if campaign and timed_mode() and run_time()>=180:status="time_up";bonus.active=false
		return
	if mode=="fusion":fusion.update(self)
	boss.update(self)
	if mode=="overdrive" and floori(run_time()/40)>pulse_index:
		pulse_index=floori(run_time()/40)
		if power_until<=time:activate_power(time,3.0)
		else:power_until=maxf(power_until,time+3.0)
		events.append({"type":"overdrive_pulse","pos":player.pos})
	update_pressure()
	for a in [player] + ghosts: a.previous = a.pos
	var fruit_path:Array=bonus.prepare(self,dt)
	var train_paths:Array=train.prepare(self,dt)
	var speed: float = tuning.player_speed
	if time < dash_until: speed = tuning.dash_cells / tuning.dash_duration
	elif time < drift_until: speed *= 1.1
	var pp := advance(player, speed * dt, true)
	var ghost_paths: Array = []
	for g in ghosts:
		if g.state == "house" and time >= g.release:
			g.state = "leaving" if campaign else ("vulnerable" if time < power_until and g.immune != window_id else normal_state())
		if g.state == "leaving" and g.pos.distance_to(Vector2(EXIT)) < 0.06:
			g.pos = Vector2(EXIT)
			g.state = "vulnerable" if time < power_until and g.immune != window_id else normal_state()
		if g.state == "returning" and g.pos.distance_to(Vector2(g.home)) < 0.06:
			g.pos = Vector2(g.home)
			g.state = "house"
			g.release = time + 1.5
			g.immune = window_id
		if g.state in ["chase", "scatter"]: g.state = normal_state()
		var gs: float = tuning.ghost_speed
		if campaign: gs *= Stages.INFO[stage_id].speed
		if timed_mode():gs*=0.90+0.18*minf(1,run_time()/180)
		if g.state in ["chase", "scatter"]: gs *= 1.0 + 0.04 * pressure_level
		if g.state == "vulnerable": gs *= 0.65
		if g.state == "returning": gs = 5.0
		if time<g.get("stunned_until",-1.0):gs=0
		ghost_paths.append(advance(g, gs * dt if g.state != "house" else 0.0, false))
	var contacts: Array = []
	if mode=="fusion":contacts.append_array(fusion.contacts(self,pp,ghost_paths,dt))
	if bonus.active:
		var toi:float=path_contact(pp,fruit_path,0.43)
		if toi<=1:contacts.append({"at":toi,"priority":0,"type":"bonus"})
	for item in train_paths:
		var toi:float=path_contact(pp,item.path,PLAYER_RADIUS+0.23)
		if toi<=1:contacts.append({"at":toi,"priority":2,"type":"train","actor":item.actor})
	if boss.active and boss.phase=="attack":
		for c in boss.cells:
			var toi:float=path_contact(pp,[{"a":Vector2(c),"b":Vector2(c),"t0":0.0,"t1":1.0}],0.33)
			if toi<=1 and time+dt*toi<boss.next_at:contacts.append({"at":toi,"priority":2,"type":"hazard"})
	for cell in pickups:
		if fusion.crates.has(cell):continue
		var toi := path_contact(pp, [{"a":Vector2(cell), "b":Vector2(cell), "t0":0.0, "t1":1.0}], 0.23)
		if pickups[cell] == "pellet" and time < magnet_until:
			# Only the same/adjacent floor cell: never reach through a wall or diagonally.
			var here := Vector2i(player.pos.round())
			var before := Vector2i(player.previous.round())
			var adjacent := absi(cell.x-here.x)+absi(cell.y-here.y) <= (2 if upgrade=="magnet" else 1) or absi(cell.x-before.x)+absi(cell.y-before.y) <= (2 if upgrade=="magnet" else 1)
			if upgrade=="magnet":adjacent=path_distance(here,cell)<=2 or path_distance(before,cell)<=2
			if adjacent and walkable(cell):
				var magnetic_toi := path_contact(pp, [{"a":Vector2(cell), "b":Vector2(cell), "t0":0.0, "t1":1.0}], 2.05 if upgrade=="magnet" else 1.05)
				if time + dt * magnetic_toi < magnet_until: toi = minf(toi, magnetic_toi)
		if toi <= 1.0: contacts.append({"at":toi, "priority":0, "type":"pickup", "cell":cell})
	for i in ghosts.size():
		if ghosts[i].state in ["house","leaving"]: continue
		var toi := path_contact(pp, ghost_paths[i], PLAYER_RADIUS + GHOST_RADIUS)
		if toi <= 1.0: contacts.append({"at":toi, "priority":3 if mode=="fusion" else 2, "type":"ghost", "index":i})
	if power_until >= time and power_until <= time + dt:
		contacts.append({"at":(power_until-time)/dt, "priority":1, "type":"power_end"})
	if flow_until >= time and flow_until <= time + dt:
		contacts.append({"at":(flow_until-time)/dt, "priority":1, "type":"flow_end"})
	contacts.sort_custom(func(a,b): return a.priority < b.priority if abs(a.at-b.at) < 0.00000001 else a.at < b.at)
	for contact in contacts:
		var event_time: float = time + dt * contact.at
		match contact.type:
			"flame_player":
				if block_hit(event_time):continue
				die();break
			"flame_ghost":fusion.hit_ghost(self,ghosts[contact.index],contact.flame,event_time)
			"bomb_upgrade":fusion.collect_drop(self,contact.cell)
			"bonus":bonus.collect(self,event_time)
			"train":
				var g:Dictionary=contact.actor
				if g.state=="vulnerable":capture(g,event_time)
				elif g.state=="train" and event_time>=g.safe_until:
					if block_hit(event_time):continue
					die();break
			"hazard":
				if block_hit(event_time):continue
				die();break
			"pickup": collect(contact.cell, event_time)
			"power_end":
				if power_until <= event_time + 0.00000001:
					finish_risk(false)
					events.append({"type":"power_end", "pos":player.pos})
					for g in ghosts+train.followers:
						if g.state == "vulnerable": g.state = "train" if g.get("train",false) else normal_state()
			"flow_end":
				if flow_until <= event_time + 0.00000001: flow = 1.0
			"ghost":
				var g: Dictionary = ghosts[contact.index]
				if g.state == "vulnerable": capture(g, event_time)
				elif g.state in ["chase", "scatter"]:
					if event_time<g.get("stunned_until",-1.0):continue
					if block_hit(event_time): continue
					die()
					break
	time += dt
	if status == "playing":
		if bonus.active and time>=bonus.end_at:bonus.expire(self)
		update_close_passes(pp, ghost_paths)
		if risk.state == "active" and (time >= risk.deadline or risk.window != window_id): finish_risk(false)
		if time < power_until and power_until - time <= 1.5 and power_warned != window_id:
			power_warned = window_id
			events.append({"type":"power_warning", "pos":player.pos})
		update_topology()
		if pickups.is_empty() and campaign and mode in ["circuit","fusion"] and stage_id==5 and not boss.active and not boss.defeated:
			boss.start(self)
		elif (boss.defeated or (pickups.is_empty() and not boss.active)):
			status="won";bonus.active=false
			if campaign:score+=stage_result().bonus
			events.append({"type":"won","pos":player.pos})
	if campaign and timed_mode() and run_time()>=180.0:
		status="time_up";bonus.active=false

func run_time() -> float:return run_elapsed+time
func tunnel_rows() -> Array:return [3,5,9] if campaign and stage_id==3 else TUNNEL_ROWS
func request_boss_pulse() -> bool:return boss.pulse(self)
func activate_power(at:float,duration:float,emit:bool=true) -> void:
	finish_risk(false);window_id+=1;combo=0;power_until=at+duration
	for g in ghosts+train.followers:
		if g.state not in ["returning","house","leaving"]:g.state="vulnerable"
	if emit:events.append({"type":"power","pos":player.pos})

func request_shield() -> bool:
	if not campaign or paused or status != "playing" or shield_charges <= 0 or time < shield_until: return false
	shield_charges -= 1
	shield_until = time + (11.0 if upgrade=="shield" else 8.0)
	pending_events.append({"type":"shield_armed", "pos":player.pos})
	return true

func request_magnet() -> bool:
	if not campaign or paused or status != "playing" or magnet_charges <= 0 or time < magnet_until: return false
	magnet_charges -= 1
	magnet_until = time + (9.0 if upgrade=="magnet" else 6.0)
	pending_events.append({"type":"magnet", "pos":player.pos})
	return true

func block_hit(at:float) -> bool:
	if at < grace_until: return true
	if at >= shield_until: return false
	shield_until = -1.0
	grace_until = at + 1.0
	events.append({"type":"shield_hit", "pos":player.pos})
	return true

func challenge_met() -> bool:
	if mode=="fusion":return fusion.chained>=1
	match stage_id:
		0: return stage_captures >= 2
		1: return stage_deaths == 0
		2:return risk.state=="success"
		3:return dash_uses==0
		4:return max_chain>=4
		_:return boss.defeated

func stage_result() -> Dictionary:
	var cleared := status == "won"
	var challenge := cleared and challenge_met()
	var fast:bool = cleared and time <= Stages.INFO[stage_id].par
	var mask := int(cleared) | (int(challenge) << 1) | (int(fast) << 2)
	return {"mask":mask, "stars":Stages.medal_count(mask), "challenge":challenge, "fast":fast,
		"expert_mask":(int(cleared and dash_uses==0) | (int(cleared and stage_deaths==0)<<1) | (int(cleared and max_chain>=4)<<2)),
		"bonus":(500 if cleared else 0) + (250 if challenge else 0) + (250 if fast else 0)}

func normal_state() -> String:
	return "scatter" if fmod(time, 20.0) < 5.0 - pressure_level * 0.7 else "chase"

func update_pressure() -> void:
	var next := mini(3, pressure_level + 1)
	var threshold := 8.0 + (next - 1) * 12.0
	if pressure_level >= 3: return
	if time >= threshold - 0.8 and pressure_warned < next:
		pressure_warned = next
		events.append({"type":"pressure_warning", "pos":player.pos, "level":next})
	if time >= threshold:
		pressure_level = next
		events.append({"type":"pressure", "pos":player.pos, "level":next})

func request_risk() -> bool:
	# One optional wager per phase, reusing Power, energy and the capture chain.
	if status != "playing" or paused or risk.state != "available" or power_until - time < 2.0 or energy < 20.0:
		return false
	energy -= 20.0
	risk = {"state":"active", "progress":0, "window":window_id, "deadline":power_until}
	pending_events.append({"type":"risk_start", "pos":player.pos})
	return true

func finish_risk(success: bool) -> void:
	if risk.state != "active": return
	risk.state = "success" if success else "failed"
	if success:
		score += 600
		energy = minf(100.0, energy + 35.0)
	events.append({"type":"risk_success" if success else "risk_failed", "pos":player.pos})

func update_close_passes(player_path: Array, ghost_paths: Array) -> void:
	for i in ghosts.size():
		var g: Dictionary = ghosts[i]
		if g.state not in ["chase", "scatter"]:
			close_passes.erase(i)
			continue
		var gap := path_clearance(player_path, ghost_paths[i])
		var end_gap: float = player.pos.distance_to(g.pos)
		var touching := gap <= PLAYER_RADIUS + GHOST_RADIUS + 0.000001
		if touching:
			close_passes.erase(i)
			continue
		if gap <= 0.95 and time >= near_ready.get(i, -1.0) and player.pos.distance_to(player.previous) > 0.001:
			if not close_passes.has(i): close_passes[i] = {"dash":false}
			close_passes[i].dash = close_passes[i].dash or time - STEP < dash_until
		if close_passes.has(i) and end_gap > 1.12:
			energy = minf(100.0, energy + 6.0)
			events.append({"type":"near_miss", "pos":player.pos, "dash":close_passes[i].dash})
			near_ready[i] = time + 3.0
			close_passes.erase(i)

static func path_clearance(a: Array, b: Array) -> float:
	var nearest := INF
	for sa in a:
		for sb in b:
			var lo: float = maxf(sa.t0, sb.t0)
			var hi: float = minf(sa.t1, sb.t1)
			if hi < lo: continue
			var p := point_on(sa,lo) - point_on(sb,lo)
			var v := point_on(sa,hi) - point_on(sb,hi) - p
			var t := clampf(-p.dot(v) / v.length_squared(), 0.0, 1.0) if v.length_squared() > 0.000000001 else 0.0
			nearest = minf(nearest, (p + v * t).length())
	return nearest

func collect(cell: Vector2i, at: float) -> void:
	if not pickups.has(cell) or fusion.crates.has(cell): return
	var kind: String = pickups[cell]
	pickups.erase(cell)
	collected += 1
	if kind == "power":
		activate_power(at,tuning.power_seconds,false);score+=50
		if boss.active:boss.charges+=1
	elif kind == "fruit":
		score += roundi(100 * flow)
		queue_topology()
	else:
		score += roundi(10 * flow)
		energy = minf(100.0, energy + tuning.pellet_energy)
	events.append({"type":kind, "pos":Vector2(cell)})
	if collected * 2 >= initial_pellets: queue_topology()

func capture(g: Dictionary, at: float) -> void:
	if g.state != "vulnerable": return
	stage_captures += 1
	var points := 200 * (1 << mini(combo,3))
	score += points
	combo += 1
	max_chain=maxi(max_chain,combo)
	g.state = "returning"
	g.immune = window_id
	flow = minf(3.0, flow + 0.5)
	flow_until = at + 5.0
	events.append({"type":"capture", "pos":g.pos, "points":points, "chain":combo,"ghost_id":g.id})
	if risk.state == "active" and risk.window == window_id and at < risk.deadline:
		risk.progress += 1
		if risk.progress >= 2: finish_risk(true)

func die() -> void:
	fusion.on_death(self)
	bonus.active=false;boss.on_death(self);train.followers.clear()
	stage_deaths += 1
	shield_until = -1.0
	grace_until = -1.0
	magnet_until = -1.0
	finish_risk(false)
	close_passes.clear()
	lives -= 1
	events.append({"type":"death", "pos":player.pos})
	flow = 1.0
	flow_until = -1.0
	power_until = -1.0
	combo = 0
	dash_until = -1.0
	drift_until = -1.0
	buffer_time = -100.0
	buffer_dir = Vector2i.ZERO
	held_dir = Vector2i.ZERO
	player.pos = Vector2(1,9)
	player.previous = player.pos
	player.dir = Vector2i.ZERO
	for g in ghosts:
		g.pos = Vector2(g.home)
		g.previous = g.pos
		g.state = "house"
		g.release = time + 2.5 + g.id * 1.2
	status = "respawning" if lives > 0 else "game_over"
	respawn_until = time + 1.5

func advance(a: Dictionary, distance: float, is_player: bool) -> Array:
	var segments: Array = []
	var total := maxf(distance, 0.000001)
	var spent := 0.0
	var guard := 0
	while distance > 0.000001 and guard < 12:
		guard += 1
		var p: Vector2 = a.pos
		var center := Vector2i(p.round())
		if p.distance_to(Vector2(center)) < 0.00001:
			a.pos = Vector2(center)
			if is_player:
				var wanted := buffer_dir if time-buffer_time <= tuning.turn_buffer else held_dir
				if wanted != Vector2i.ZERO and time >= dash_until and can_enter(neighbor(center,wanted),a,true):
					if a.dir != Vector2i.ZERO and Vector2(wanted).dot(Vector2(a.dir)) == 0 and time-buffer_time <= tuning.drift_window and time >= drift_ready:
						drift_until = time + 0.2
						drift_ready = time + 0.35
						events.append({"type":"drift", "pos":a.pos})
					a.dir = wanted
					buffer_time = -100.0
			elif a.get("state","")=="bonus":a.dir=bonus.direction(self,center)
			elif a.get("train",false):a.dir=train.direction(self,a,center)
			else: a.dir = choose_direction(a, center)
			if not can_enter(neighbor(center,a.dir),a,is_player): break
		if a.dir == Vector2i.ZERO: break
		var d: Vector2i = a.dir
		var next: Vector2 = p
		if d.x > 0: next.x = floorf(p.x + 0.00001) + 1.0
		if d.x < 0: next.x = ceilf(p.x - 0.00001) - 1.0
		if d.y > 0: next.y = floorf(p.y + 0.00001) + 1.0
		if d.y < 0: next.y = ceilf(p.y - 0.00001) - 1.0
		var move := minf(distance, p.distance_to(next))
		a.pos = p + Vector2(d) * move
		segments.append({"a":p, "b":a.pos, "t0":spent/total, "t1":(spent+move)/total})
		distance -= move
		spent += move
		if campaign and int(roundf(a.pos.y)) in tunnel_rows() and (a.pos.x <= -1.0+0.000001 or a.pos.x >= 17.0-0.000001):
			a.pos.x += 17.0 if a.pos.x<0 else -17.0
			a.previous = a.pos
			# A discontinuity, never a swept line through the middle of the maze.
			segments.append({"a":a.pos,"b":a.pos,"t0":spent/total,"t1":spent/total})
			events.append({"type":"wrap","pos":a.pos,"player":is_player})
	if spent/total < 1.0:
		segments.append({"a":a.pos, "b":a.pos, "t0":spent/total, "t1":1.0})
	return segments

func choose_direction(g: Dictionary, c: Vector2i) -> Vector2i:
	var options: Array = []
	var access:bool = g.state in ["returning","leaving","house"]
	for d in DIRS:
		if can_enter(neighbor(c,d),g,false): options.append(d)
	if options.is_empty(): return Vector2i.ZERO
	if options.size() > 1 and not access: options.erase(-g.dir)
	var target := Vector2i(player.pos.round())
	if g.state == "returning": target = g.home
	elif g.state == "leaving": target = EXIT
	elif g.state == "scatter": target = [Vector2i(15,1),Vector2i(1,1),Vector2i(15,11),Vector2i(1,11)][g.id]
	elif g.id == 1: target += player.dir * 3
	elif g.id == 2: target = Vector2i(16,12)-target
	elif g.id == 3: target = Vector2i(3,9) if fmod(time,12) < 6 else target
	var best: Vector2i = options[0]
	var value := -100000.0
	for d in options:
		var dist := path_distance(neighbor(c,d), target, access)
		var utility := float(dist if g.state == "vulnerable" else -dist)
		if mode=="fusion" and not access:
			# Prefer a safe route when a bomb is about to detonate, without
			# revealing hidden information or making ghosts permanently timid.
			for b in fusion.bombs:
				if b.at-time<0.85 and neighbor(c,d) in fusion.ray_cells(self,b):utility-=100
			for f in fusion.flames:
				if neighbor(c,d) in f.cells:utility-=200
		if utility > value:
			value = utility
			best = d
	return best

func normalize_cell(c:Vector2i) -> Vector2i:
	if campaign and c.y in tunnel_rows():
		if c.x==-1:return Vector2i(16,c.y)
		if c.x==17:return Vector2i(0,c.y)
	return c

func neighbor(c:Vector2i,d:Vector2i) -> Vector2i:
	return normalize_cell(c+d)

func walkable(c:Vector2i,house_access:bool=false) -> bool:
	return floors.has(c) and not fusion.crates.has(c) and (not campaign or house_access or (c not in HOUSE and c!=DOOR))

func path_distance(start_cell: Vector2i, target: Vector2i, house_access:bool=false) -> int:
	start_cell=normalize_cell(start_cell)
	target=normalize_cell(target)
	# At most one small-board BFS per legal direction, only at cell centers.
	if not walkable(target,house_access):
		var closest := 100000
		for c in floors:
			if not walkable(c,house_access):continue
			var d: int = absi(c.x-target.x)+absi(c.y-target.y)
			if d < closest: closest=d
		var best_target: Vector2i = start_cell
		for c in floors:
			if not walkable(c,house_access):continue
			if absi(c.x-target.x)+absi(c.y-target.y) == closest: best_target=c; break
		target = best_target
	var queue: Array = [start_cell]
	var distances := {start_cell:0}
	var index := 0
	while index < queue.size():
		var c: Vector2i = queue[index]
		index += 1
		if c == target: return distances[c]
		for d in DIRS:
			var next := neighbor(c,d)
			if walkable(next,house_access) and not distances.has(next):
				distances[next] = distances[c]+1
				queue.append(next)
	return 10000

static func segment_toi(a: Vector2, b: Vector2, c: Vector2, d: Vector2, radius: float) -> float:
	var p := a-c
	var v := (b-a)-(d-c)
	var cc := p.length_squared()-radius*radius
	if cc <= 0: return 0.0
	var aa := v.length_squared()
	if aa < 0.000000001: return 2.0
	var bb := 2.0*p.dot(v)
	var discriminant := bb*bb-4.0*aa*cc
	if discriminant < 0.0: return 2.0
	var t := (-bb-sqrt(discriminant))/(2.0*aa)
	return t if t >= 0 and t <= 1 else 2.0

static func point_on(segment: Dictionary, t: float) -> Vector2:
	var duration: float = segment.t1-segment.t0
	return segment.a.lerp(segment.b, (t-segment.t0)/duration) if duration > 0.0000001 else segment.b

static func path_contact(a: Array, b: Array, radius: float) -> float:
	var earliest := 2.0
	for sa in a:
		for sb in b:
			var lo: float = maxf(sa.t0,sb.t0)
			var hi: float = minf(sa.t1,sb.t1)
			if hi < lo: continue
			var t := segment_toi(point_on(sa,lo), point_on(sa,hi), point_on(sb,lo), point_on(sb,hi),radius)
			if t <= 1.0: earliest = minf(earliest, lerpf(lo,hi,t))
	return earliest

func queue_topology() -> void:
	if mode=="fusion":return # Bombs open the new routes in this mode.
	if topology_done or not topology.is_empty(): return
	topology = {"apply_at":time+1.5, "cancel_at":time+4.5}
	events.append({"type":"warning", "pos":Vector2(open_cell)})

func topology_valid(candidate: Dictionary) -> bool:
	if candidate.is_empty(): return false
	for c in pickups:
		if not candidate.has(c): return false
	for c in HOME:
		if not candidate.has(c): return false
	var visited: Dictionary = {}
	var queue: Array = [candidate.keys()[0]]
	visited[queue[0]] = true
	var i := 0
	while i < queue.size():
		var c: Vector2i = queue[i]
		i += 1
		for d in DIRS:
			var next := neighbor(c,d)
			if candidate.has(next) and not visited.has(next): visited[next]=true; queue.append(next)
	return visited.size() == candidate.size()

func update_topology() -> void:
	if topology.is_empty() or time < topology.apply_at: return
	var candidate := floors.duplicate()
	candidate[open_cell] = true
	candidate.erase(close_cell)
	var safe := topology_valid(candidate)
	var occupants:Array=[player]+ghosts
	if bonus.active:occupants.append(bonus.actor)
	occupants.append_array(train.followers)
	for a in occupants:
		if a.pos.distance_to(Vector2(open_cell)) < 1.1 or a.pos.distance_to(Vector2(close_cell)) < 1.1: safe=false
	if safe:
		floors = candidate
		graph_version += 1
		topology_done = true
		topology.clear()
		events.append({"type":"topology", "pos":Vector2(open_cell)})
	elif time >= topology.cancel_at:
		topology.clear()
		topology_done = true
		events.append({"type":"topology_cancel", "pos":Vector2(open_cell)})

