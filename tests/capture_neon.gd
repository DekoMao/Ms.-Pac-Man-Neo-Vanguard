extends SceneTree
## Controlled captures for layout/character review, not human gameplay.
func _initialize() -> void:call_deferred("capture")
func frame() -> void:
	await process_frame
	await RenderingServer.frame_post_draw
func shot(name:String) -> void:
	for i in 4:await frame()
	print("LAYOUT ",name," sidebar=",current_scene.sidebar.get_rect()," min=",current_scene.sidebar.get_combined_minimum_size()," visible=",current_scene.sidebar.is_visible_in_tree())
	assert(root.get_texture().get_image().save_png("res://evidencias/"+name+".png")==OK)
	print("ARCADE_CAPTURE ",name)
func capture() -> void:
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);current_scene=game
	await frame();await frame()
	game.start_game();game.sim.paused=true;game.update_hud()
	await shot("neon_jogo_050")
	game.set_physics_process(false);game.sim.paused=false
	for i in 480:
		game.demo_input();game._physics_process(1.0/120.0)
	game.sim.player.previous=game.sim.player.pos;game.sim.paused=true;game.first_frame=true
	await shot("neon_acao_050")
	game.set_physics_process(true)
	game.start_game(1);game.sim.paused=true;game.settings.camera_top=false
	await shot("neon_fase2_050")
	game.start_game(2);game.sim.paused=true
	await shot("neon_fase3_050")
	game.start_game();game.sim.paused=true;game.sim.player.pos=Vector2(8,3);game.sim.player.previous=game.sim.player.pos;game.first_frame=true
	await shot("neon_centro_050")
	game.settings.camera_top=true;game.first_frame=true;await shot("neon_mapa_050")
	game.settings.camera_top=false;game.show_title();game.first_frame=true;await shot("neon_menu_050")
	game.queue_free();await process_frame;quit()
