extends Control
var sim:RefCounted
func _draw() -> void:
	if sim==null:return
	var cell:=8.0
	for y in sim.GRID.size():
		for x in sim.GRID[y].length():
			var c:=Vector2i(x,y)
			draw_rect(Rect2(Vector2(x,y)*cell,Vector2.ONE*(cell-1)),Color("24425a") if sim.floors.has(c) else Color("101225"))
	for cell_pos in sim.pickups:
		if sim.pickups[cell_pos]=="power":draw_circle((Vector2(cell_pos)+Vector2.ONE*0.5)*cell,2.1,Color("edc966"))
	for ghost in sim.ghosts:draw_circle((ghost.pos+Vector2.ONE*0.5)*cell,2.3,Color("4bcfff") if ghost.state=="vulnerable" else Color("d966a0"))
	draw_circle((sim.player.pos+Vector2.ONE*0.5)*cell,3.0,Color("ffdd6d"))
