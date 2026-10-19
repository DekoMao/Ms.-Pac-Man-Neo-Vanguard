extends Node
var game:Node
var tape:Array=[]
var tick:=0
var counts:Dictionary={}
var report:=""
var capture_dir:=""
var captured:Dictionary={}
func _physics_process(_dt:float) -> void:
	if tick>0:
		for event in game.sim.events:counts[event.type]=counts.get(event.type,0)+1
	if tick>=tape.size():
		if not report.is_empty():
			var f=FileAccess.open(report,FileAccess.WRITE)
			f.store_string(JSON.stringify({"ticks":tick,"simulation_seconds":game.sim.time,"lives":game.sim.lives,"score":game.sim.score,"status":game.sim.status,"events":counts},"\t"));f.close()
		set_physics_process(false);finish_capture();return
	var cmd:Dictionary=tape[tick]
	if cmd.has("direction"):
		var d:=Vector2i(int(cmd.direction[0]),int(cmd.direction[1]))
		if game.sim.player.dir!=d:game.sim.request_direction(d)
		else:game.sim.held_dir=d
	if cmd.get("risk",false) and game.sim.has_method("request_risk"):game.sim.request_risk()
	if cmd.get("dash",false):game.sim.request_dash()
	tick+=1
func finish_capture() -> void:
	game.set_physics_process(false)
	# Movie Maker mixes audio per rendered frame, not during OS.delay_msec.
	# Drain loop playbacks before engine teardown; retain the final visible frame.
	for player in game.find_children("*","AudioStreamPlayer",true,false):
		player.stop();player.stream=null
	for i in 4:await get_tree().process_frame
	get_tree().quit()
func _process(_dt:float) -> void:
	if capture_dir.is_empty():return
	for mark in [3,12,23,35,44]:
		if game.sim.time>=mark and not captured.has(mark):
			captured[mark]=true;capture(mark)
func capture(mark:int) -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(capture_dir)
	get_viewport().get_texture().get_image().save_png(capture_dir.path_join("real_%02ds.png"%mark))
