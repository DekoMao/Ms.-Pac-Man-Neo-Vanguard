extends Control
## Both map views read the same live pickups/floor graph as the simulation.
var sim:RefCounted
const LAST_ITEMS := 10

func map_layout() -> Dictionary:
	if sim == null: return {}
	var dimensions := Vector2(sim.grid[0].length(), sim.grid.size())
	var available := (size - Vector2(8,8)).max(Vector2.ZERO)
	var cell := minf(available.x / dimensions.x, available.y / dimensions.y)
	var extent := dimensions * cell
	return {"cell":cell, "origin":(size - extent) * 0.5, "extent":extent}

func _draw() -> void:
	var layout := map_layout()
	if layout.is_empty() or layout.cell <= 0.0: return
	var cell:float = layout.cell
	var origin:Vector2 = layout.origin
	for y in sim.grid.size():
		for x in sim.grid[y].length():
			var c := Vector2i(x,y)
			draw_rect(Rect2(origin + Vector2(c)*cell, Vector2.ONE*maxf(0.0,cell-0.7)),
				Color("20384b") if sim.floors.has(c) else Color("0a1020"))
	var last_items:bool = sim.pickups.size() > 0 and sim.pickups.size() <= LAST_ITEMS
	if sim.campaign:
		draw_rect(Rect2(origin+Vector2(6.5,4.5)*cell,Vector2(3,2)*cell),Color("7b8ac5"),false,1.0)
		for row in sim.TUNNEL_ROWS:
			for x in [0,16]:
				var p:Vector2=origin+(Vector2(x,row)+Vector2.ONE*0.5)*cell
				var sign:float=-1.0 if x==0 else 1.0
				draw_polyline(PackedVector2Array([p+Vector2(-sign*cell*0.2,-cell*0.25),p+Vector2(sign*cell*0.2,0),p+Vector2(-sign*cell*0.2,cell*0.25)]),Color("88e9ef"),maxf(1.0,cell*0.1))
	for c in sim.pickups:
		var center:Vector2 = origin + (Vector2(c)+Vector2.ONE*0.5)*cell
		var radius := maxf(1.3,cell*0.14)
		if last_items:
			# Steady rings stay readable with reduced effects and while paused.
			draw_circle(center, cell*0.37, Color("f3f8ff"), false, maxf(1.0,cell*0.04))
		match sim.pickups[c]:
			"power":
				draw_circle(center, cell*0.25, Color("ffdb76"), false, maxf(1.0,cell*0.07))
				draw_circle(center, radius, Color("fff1c0"))
			"fruit":
				var r := cell*0.27
				draw_colored_polygon(PackedVector2Array([center+Vector2(0,-r),center+Vector2(r,0),
					center+Vector2(0,r),center+Vector2(-r,0)]), Color("ff8bc7"))
			_:
				draw_circle(center, radius, Color("f8e5b0"))
	for ghost in sim.ghosts:
		var center:Vector2 = origin + (Vector2(clampf(ghost.pos.x,0,16),ghost.pos.y)+Vector2.ONE*0.5)*cell
		var color := Color("75dfff") if ghost.state == "vulnerable" else Color("df7ca8")
		if ghost.state in ["house","returning"]: color = Color("94a7bd")
		draw_circle(center, maxf(1.5,cell*0.21), color)
	var player_center:Vector2 = origin + (Vector2(clampf(sim.player.pos.x,0,16),sim.player.pos.y)+Vector2.ONE*0.5)*cell
	var r := cell*0.34
	var direction:Vector2 = Vector2(sim.player.dir)
	if direction == Vector2.ZERO: direction = Vector2.UP
	var side := direction.orthogonal()
	var marker := PackedVector2Array([player_center+direction*r,
		player_center-direction*r*0.7+side*r*0.7,
		player_center-direction*r*0.7-side*r*0.7])
	draw_colored_polygon(marker, Color("ffde73"))
	marker.append(marker[0])
	draw_polyline(marker, Color("050b15"), maxf(1.0,cell*0.06))

