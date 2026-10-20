extends SceneTree
## Controlled QA scenes, not a claim of human gameplay or a physical GPU test.
func _initialize() -> void:call_deferred("capture")
func frame() -> void:
	await process_frame;await RenderingServer.frame_post_draw
func shot(name:String) -> void:
	for i in 4:await frame()
	assert(root.get_texture().get_image().save_png("res://evidencias/"+name+".png")==OK)
	print("LIVING_CAPTURE ",name," renderer=",RenderingServer.get_current_rendering_method()," draw_calls=",RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
func capture() -> void:
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);current_scene=game
	await frame();await frame();game.set_physics_process(false)
	game.settings.camera_top=false;game.start_game();game.sim.paused=true
	await shot("vivo_inicio_080")
	game.sim.paused=false;game.sim.time=12;game.sim.bonus.prepare(game.sim,0)
	game.sim.player.pos=Vector2(8,9);game.sim.player.previous=game.sim.player.pos
	game.sim.bonus.actor.pos=Vector2(10,9);game.sim.bonus.actor.previous=game.sim.bonus.actor.pos;game.sim.paused=true;game.first_frame=true
	await shot("vivo_fruta_080")
	game.start_game();game.sim.tuning.ghost_speed=0
	for i in 4:
		game.sim.ghosts[i].state="chase";game.sim.ghosts[i].pos=Vector2(2+i*0.5,9);game.sim.ghosts[i].previous=game.sim.ghosts[i].pos
	game.sim.activate_power(0,6);game.sim.request_direction(Vector2i.RIGHT);game.sim.request_dash();game._physics_process(0.15)
	game.sim.player.previous=game.sim.player.pos;game.sim.paused=true;game.feedback.update(0.08,game.sim);game.first_frame=true
	await shot("vivo_captura_080")
	game.start_mode("train");game.sim.time=28
	for g in game.sim.ghosts:g.release=100000
	game._physics_process(1.0/120);game.sim.time=48;game._physics_process(1.0/120)
	game.sim.player.pos=Vector2(9,9);game.sim.player.previous=game.sim.player.pos
	for i in game.sim.train.followers.size():game.sim.train.followers[i].pos=Vector2(7-i,9);game.sim.train.followers[i].previous=game.sim.train.followers[i].pos
	game.sim.paused=true;game.first_frame=true;await shot("vivo_trem_080")
	game.start_game(5);game.sim.pickups.clear();game._physics_process(1.0/120);game.sim.paused=true;game.first_frame=true
	game.sim.player.pos=Vector2(8,3);game.sim.player.previous=game.sim.player.pos
	await shot("vivo_colosso_080")
	game.sim.boss.phase="recover";game.sim.boss.next_at=game.sim.time+3;game.sim.boss.charges=2
	await shot("vivo_colosso_vulneravel_080")
	game.sim.status="won";game.sim.boss.active=false;game.show_results();game.show_upgrade_choice()
	await shot("vivo_melhorias_080")
	game.start_mode("overdrive");game.sim.score=15320;game.sim.time=179.999
	for g in game.sim.ghosts:g.release=100000
	game._physics_process(0.1);await shot("vivo_overdrive_080")
	game.show_campaign();await shot("vivo_fases_080")
	game.show_title();await shot("vivo_menu_080")
	game.queue_free();await process_frame;quit()
