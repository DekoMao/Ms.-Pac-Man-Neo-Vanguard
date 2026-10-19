extends SceneTree
## Controlled visual QA, not a recording of a human campaign run.
func _initialize() -> void:call_deferred("capture")
func frame() -> void:
	await process_frame
	await RenderingServer.frame_post_draw
func shot(name:String) -> void:
	for i in 4:await frame()
	assert(root.get_texture().get_image().save_png("res://evidencias/"+name+".png")==OK)
	print("CIRCUIT_CAPTURE ",name)
func capture() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game);current_scene=game
	await frame();await frame()
	await shot("circuito_menu_030")
	for i in 3:
		game.start_game(i);game.settings.camera_top=true;game.first_frame=true
		game.sim.request_shield()
		if i>=1:game.sim.request_magnet()
		game.sim.paused=true;game.update_hud()
		await shot("circuito_fase%d_030"%(i+1))
	game.settings.unlocked=2;game.settings.medals=[7,7,7]
	game.show_campaign()
	await shot("circuito_extras_030")
	game.start_game(2);game.sim.stage_captures=2;game.sim.risk.state="success"
	for c in game.sim.pickups.keys():game.sim.collect(c,game.sim.time)
	game._physics_process(1.0/120.0)
	await shot("circuito_final_030")
	game.queue_free();await process_frame;quit()
