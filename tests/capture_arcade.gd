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
	await shot("arcade_jogo_040")
	game.show_map();await shot("arcade_mapa_040")
	game.resume_game();game.pause_game();game.show_settings()
	await shot("arcade_config_040")
	game.resume_game();game.sim.paused=true;game.settings.camera_top=true
	await shot("arcade_superior_040")
	game.settings.camera_top=false;game.hud.visible=false;game._process(0);game.set_process(false)
	game.camera.size=6.8;game.camera.position=Vector3(4,5,5);game.camera.look_at(Vector3(0,0.6,-0.5))
	await shot("arcade_fantasmas_040")
	game.set_process(true);game.show_title();await shot("arcade_menu_040")
	game.queue_free();await process_frame;quit()
