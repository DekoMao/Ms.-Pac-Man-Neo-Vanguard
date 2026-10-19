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

func _init(seed_value: int = 73021) -> void:
	var file = FileAccess.open("res://assets/balance.json", FileAccess.READ)
	tuning = JSON.parse_string(file.get_as_text())
	rng.seed = seed_value
	reset()

func reset() -> void:
	floors.clear()
	pickups.clear()
	for y in GRID.size():
		for x in GRID[y].length():
			if GRID[y][x] != "#":
				var c := Vector2i(x,y)
				floors[c] = true
				pickups[c] = "power" if GRID[y][x] == "o" else "pellet"
	player = actor(Vector2(1,9), Vector2i.RIGHT)
	ghosts.clear()
	for i in 4:
		var g := actor(Vector2(HOME[i]), Vector2i.UP)
		g.merge({"state":"house", "home":HOME[i], "release":2.5 + i * 1.2, "immune":-1, "id":i})
		ghosts.append(g)
	for c in HOME + [CLOSE_CELL, Vector2i(1,9)]:
		pickups.erase(c)
	pickups[Vector2i(3,9)] = "fruit"
	pickups[Vector2i(5,9)] = "power"
	time = 0.0
	score = 0
	lives = 3
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

static func actor(pos: Vector2, dir: Vector2i) -> Dictionary:
	return {"pos":pos, "previous":pos, "dir":dir}

func start() -> void:
	if status == "ready": status = "playing"

func request_direction(dir: Vector2i) -> void:
	if not DIRS.has(dir) or paused or status != "playing": return
	buffer_dir = dir
	held_dir = dir
	buffer_time = time
	if dash_until <= time and dir == -player.dir:
		player.dir = dir

func request_dash() -> bool:
	if status != "playing" or paused or energy < tuning.dash_cost or time < dash_ready:
		return false
	var p: Vector2 = player.pos
	var dir: Vector2i = player.dir
	var probe := p + Vector2(dir) * 0.035
	# Permit moving only inside legal corridors, including next center/edge.
	var c := Vector2i(p.round())
	if dir == Vector2i.ZERO or (p.distance_to(Vector2(c)) < 0.001 and not floors.has(c + dir)):
		return false
	if not floors.has(Vector2i(probe.round())): return false
	energy -= tuning.dash_cost
	dash_until = time + tuning.dash_duration
	dash_ready = time + tuning.dash_cooldown
	pending_events.append({"type":"dash", "pos":p})
	return true

func tick(dt: float = STEP) -> void:
	if paused or status in ["ready", "won", "game_over"]: return
	events.assign(pending_events)
	pending_events.clear()
	if status == "respawning":
		time += dt
		if time >= respawn_until: status = "playing"
		return
	update_pressure()
	for a in [player] + ghosts: a.previous = a.pos
	var speed: float = tuning.player_speed
	if time < dash_until: speed = tuning.dash_cells / tuning.dash_duration
	elif time < drift_until: speed *= 1.1
	var pp := advance(player, speed * dt, true)
	var ghost_paths: Array = []
	for g in ghosts:
		if g.state == "house" and time >= g.release:
			g.state = "vulnerable" if time < power_until and g.immune != window_id else normal_state()
		if g.state == "returning" and g.pos.distance_to(Vector2(g.home)) < 0.06:
			g.pos = Vector2(g.home)
			g.state = "house"
			g.release = time + 1.5
			g.immune = window_id
		if g.state in ["chase", "scatter"]: g.state = normal_state()
		var gs: float = tuning.ghost_speed
		if g.state in ["chase", "scatter"]: gs *= 1.0 + 0.04 * pressure_level
		if g.state == "vulnerable": gs *= 0.65
		if g.state == "returning": gs = 5.0
		ghost_paths.append(advance(g, gs * dt if g.state != "house" else 0.0, false))
	var contacts: Array = []
	for cell in pickups:
		var toi := path_contact(pp, [{"a":Vector2(cell), "b":Vector2(cell), "t0":0.0, "t1":1.0}], 0.23)
		if toi <= 1.0: contacts.append({"at":toi, "priority":0, "type":"pickup", "cell":cell})
	for i in ghosts.size():
		if ghosts[i].state == "house": continue
		var toi := path_contact(pp, ghost_paths[i], PLAYER_RADIUS + GHOST_RADIUS)
		if toi <= 1.0: contacts.append({"at":toi, "priority":2, "type":"ghost", "index":i})
	if power_until >= time and power_until <= time + dt:
		contacts.append({"at":(power_until-time)/dt, "priority":1, "type":"power_end"})
	if flow_until >= time and flow_until <= time + dt:
		contacts.append({"at":(flow_until-time)/dt, "priority":1, "type":"flow_end"})
	contacts.sort_custom(func(a,b): return a.priority < b.priority if abs(a.at-b.at) < 0.00000001 else a.at < b.at)
	for contact in contacts:
		var event_time: float = time + dt * contact.at
		match contact.type:
			"pickup": collect(contact.cell, event_time)
			"power_end":
				if power_until <= event_time + 0.00000001:
					finish_risk(false)
					events.append({"type":"power_end", "pos":player.pos})
					for g in ghosts:
						if g.state == "vulnerable": g.state = normal_state()
			"flow_end":
				if flow_until <= event_time + 0.00000001: flow = 1.0
			"ghost":
				var g: Dictionary = ghosts[contact.index]
				if g.state == "vulnerable": capture(g, event_time)
				elif g.state in ["chase", "scatter"]:
					die()
					break
	time += dt
	if status == "playing":
		update_close_passes(pp, ghost_paths)
		if risk.state == "active" and (time >= risk.deadline or risk.window != window_id): finish_risk(false)
		if time < power_until and power_until - time <= 1.5 and power_warned != window_id:
			power_warned = window_id
			events.append({"type":"power_warning", "pos":player.pos})
		update_topology()
		if pickups.is_empty():
			status = "won"
			events.append({"type":"won", "pos":player.pos})

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
	if not pickups.has(cell): return
	var kind: String = pickups[cell]
	pickups.erase(cell)
	collected += 1
	if kind == "power":
		finish_risk(false)
		window_id += 1
		combo = 0
		power_until = at + tuning.power_seconds
		score += 50
		for g in ghosts:
			if g.state not in ["returning", "house"]: g.state = "vulnerable"
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
	var points := 200 * (1 << mini(combo,3))
	score += points
	combo += 1
	g.state = "returning"
	g.immune = window_id
	flow = minf(3.0, flow + 0.5)
	flow_until = at + 5.0
	events.append({"type":"capture", "pos":g.pos, "points":points, "chain":combo})
	if risk.state == "active" and risk.window == window_id and at < risk.deadline:
		risk.progress += 1
		if risk.progress >= 2: finish_risk(true)

func die() -> void:
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
				if wanted != Vector2i.ZERO and time >= dash_until and floors.has(center + wanted):
					if a.dir != Vector2i.ZERO and Vector2(wanted).dot(Vector2(a.dir)) == 0 and time-buffer_time <= tuning.drift_window and time >= drift_ready:
						drift_until = time + 0.2
						drift_ready = time + 0.35
						events.append({"type":"drift", "pos":a.pos})
					a.dir = wanted
					buffer_time = -100.0
			else: a.dir = choose_direction(a, center)
			if not floors.has(center + a.dir): break
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
	if spent/total < 1.0:
		segments.append({"a":a.pos, "b":a.pos, "t0":spent/total, "t1":1.0})
	return segments

func choose_direction(g: Dictionary, c: Vector2i) -> Vector2i:
	var options: Array = []
	for d in DIRS:
		if floors.has(c+d): options.append(d)
	if options.is_empty(): return Vector2i.ZERO
	if options.size() > 1: options.erase(-g.dir)
	var target := Vector2i(player.pos.round())
	if g.state == "returning": target = g.home
	elif g.state == "scatter": target = [Vector2i(15,1),Vector2i(1,1),Vector2i(15,11),Vector2i(1,11)][g.id]
	elif g.id == 1: target += player.dir * 3
	elif g.id == 2: target = Vector2i(16,12)-target
	elif g.id == 3: target = Vector2i(3,9) if fmod(time,12) < 6 else target
	var best: Vector2i = options[0]
	var value := -100000.0
	for d in options:
		var dist := path_distance(c+d, target)
		var utility := float(dist if g.state == "vulnerable" else -dist)
		if utility > value:
			value = utility
			best = d
	return best

func path_distance(start_cell: Vector2i, target: Vector2i) -> int:
	# At most one small-board BFS per legal direction, only at cell centers.
	if not floors.has(target):
		var closest := 100000
		for c in floors:
			var d: int = absi(c.x-target.x)+absi(c.y-target.y)
			if d < closest: closest=d
		var best_target: Vector2i = start_cell
		for c in floors:
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
			if floors.has(c+d) and not distances.has(c+d):
				distances[c+d] = distances[c]+1
				queue.append(c+d)
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
	if topology_done or not topology.is_empty(): return
	topology = {"apply_at":time+1.5, "cancel_at":time+4.5}
	events.append({"type":"warning", "pos":Vector2(OPEN_CELL)})

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
			if candidate.has(c+d) and not visited.has(c+d): visited[c+d]=true; queue.append(c+d)
	return visited.size() == candidate.size()

func update_topology() -> void:
	if topology.is_empty() or time < topology.apply_at: return
	var candidate := floors.duplicate()
	candidate[OPEN_CELL] = true
	candidate.erase(CLOSE_CELL)
	var safe := topology_valid(candidate)
	for a in [player]+ghosts:
		if a.pos.distance_to(Vector2(OPEN_CELL)) < 1.1 or a.pos.distance_to(Vector2(CLOSE_CELL)) < 1.1: safe=false
	if safe:
		floors = candidate
		graph_version += 1
		topology_done = true
		topology.clear()
		events.append({"type":"topology", "pos":Vector2(OPEN_CELL)})
	elif time >= topology.cancel_at:
		topology.clear()
		topology_done = true
		events.append({"type":"topology_cancel", "pos":Vector2(OPEN_CELL)})
