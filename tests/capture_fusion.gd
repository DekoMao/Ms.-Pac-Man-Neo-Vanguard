extends SceneTree
## Controlled QA presets rendered by the actual Forward+ engine.
func _initialize() -> void:call_deferred("capture")
func frame() -> void:await process_frame;await RenderingServer.frame_post_draw
func shot(name:String) -> void:
	for i in 5:await frame()
	assert(root.get_texture().get_image().save_png("res://evidencias/fusao_"+name+"_090.png")==OK)
	print("FUSION_CAPTURE ",name," renderer=",RenderingServer.get_current_rendering_method()," draw_calls=",RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
func position(game,p:Vector2) -> void:
	game.sim.player.pos=p;game.sim.player.previous=p;game.sim.player.dir=Vector2i.ZERO;game.sim.held_dir=Vector2i.ZERO;game.sim.buffer_dir=Vector2i.ZERO;game.first_frame=true
func capture() -> void:
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);current_scene=game
	await frame();await frame();game.set_physics_process(false);game.settings.camera_top=false
	game.start_mode("fusion");game.sim.paused=true;await shot("inicio")
	game.sim.paused=false;position(game,Vector2(3,9));assert(game.sim.request_bomb());game.sim.time=1.65;position(game,Vector2(5,9));game.sim.paused=true
	await shot("pavio")
	game.sim.paused=false;game.sim.request_shield();position(game,Vector2(5,9));assert(game.sim.request_bomb());position(game,Vector2(6,9));game.sim.time=2.25
	game._physics_process(0.16);game.sim.player.previous=game.sim.player.pos;game.sim.paused=true
	await shot("explosao")
	game.sim.paused=false;game.sim.fusion.flames.clear();game.sim.fusion.bombs.clear();game.sim.time=4;position(game,Vector2(4,9))
	game.sim.fusion.drops[Vector2i(3,9)]="capacity";game.sim.paused=true;game.first_frame=true
	await shot("melhoria")
	game.start_mode("fusion");game.settings.camera_top=true;game.sim.paused=true;game.first_frame=true
	await shot("labirinto")
	game.show_map();await shot("mapa")
	game.show_title();await shot("menu")
	game.queue_free();await process_frame;quit()
