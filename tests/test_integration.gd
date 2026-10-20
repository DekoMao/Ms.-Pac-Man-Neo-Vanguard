extends SceneTree
const Scene=preload("res://scenes/main.tscn")
var checks:Array=[]
var failures:=0
var game:Node3D
func _initialize() -> void:call_deferred("run")
func check(id:String,ok:bool) -> void:
	checks.append({"id":id,"passed":ok})
	if not ok:failures+=1
	print("PASS " if ok else "FAIL ",id)
func press(code:int) -> void:
	var e:=InputEventKey.new();e.physical_keycode=code;e.pressed=true
	Input.parse_input_event(e)
	await process_frame
	e=InputEventKey.new();e.physical_keycode=code;e.pressed=false
	Input.parse_input_event(e)
	await process_frame
func finish_stage() -> void:
	game.sim.player.dir=Vector2i.ZERO;game.sim.held_dir=Vector2i.ZERO
	for g in game.sim.ghosts:g.release=100000.0;g.state="house"
	for c in game.sim.pickups.keys():game.sim.collect(c,game.sim.time)
	game._physics_process(1.0/120.0)
func run() -> void:
	game=Scene.instantiate();root.add_child(game);current_scene=game
	await process_frame;await process_frame
	var musical_cycle:float=float(game.music.stream.loop_end)/game.music.stream.mix_rate
	check("AUDIO-01-full-musical-loop",absf(musical_cycle-32.0*60.0/112.0)<0.01)
	check("UI-01-title-and-menu",game.current_screen=="title" and game.menu.visible)
	check("SCENE-01-real-actors",game.hero.get_node("Protagonista/Body").mesh is ArrayMesh and game.ghosts.size()==4)
	await press(KEY_ENTER)
	check("UI-02-enter-start",game.current_screen=="playing" and not game.sim.paused)
	check("START-UI-01-enter-does-not-move",game.sim.player.dir==Vector2i.ZERO and game.sim.player.pos==Vector2(1,9) and game.sim.time==0.0)
	for i in 600:game._physics_process(1.0/120.0)
	check("START-UI-05-clock-and-house-wait-for-input",game.sim.time==0 and game.sim.ghosts.all(func(g):return g.state=="house"))
	await press(KEY_SPACE)
	check("START-UI-06-dash-alone-stays-idle",game.sim.time==0 and game.sim.energy==100 and game.sim.player.pos==Vector2(1,9))
	await press(KEY_D)
	check("START-UI-02-direction-starts-movement",game.sim.player.dir==Vector2i.RIGHT)
	await press(KEY_P)
	var now:float=game.sim.time
	await physics_frame;await physics_frame
	check("UI-03-pause-stops-time",game.current_screen=="pause" and game.sim.time==now)
	game.resume_game();await process_frame
	check("UI-04-explicit-resume",game.current_screen=="playing" and not game.sim.paused)
	var old:bool=game.settings.camera_top;await press(KEY_C)
	check("UI-05-camera-toggle",game.settings.camera_top!=old)
	game.settings.camera_top=old;game.apply_settings()
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check("UI-06-focus-pauses",game.current_screen=="pause" and game.sim.held_dir==Vector2i.ZERO)
	game.show_help();check("UI-07-help",game.current_screen=="help" and game.menu_content.get_child_count()>2)
	game.show_settings();check("UI-08-settings",game.current_screen=="settings")
	game.show_title();game.show_records();check("UI-09-records",game.current_screen=="records")
	game.start_game();game.sim.score=900;game.sim.flow=3;game.start_game()
	check("START-UI-03-restart-clears-direction",game.sim.player.dir==Vector2i.ZERO and game.sim.held_dir==Vector2i.ZERO and game.key_stack.is_empty())
	check("UI-10-restart-clears-run",game.sim.score==0 and game.sim.flow==1 and game.sim.lives==3)
	game.show_quit_confirm();check("UI-11-quit-confirmation",game.current_screen=="quit" and game.sim.paused)
	game.pause_game();game._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	check("UI-12-window-close-while-paused",game.current_screen=="quit")
	game.start_game();game.pause_game()
	check("AUDIO-02-pause-all-synchronized-layers",game.music.stream_paused and game.tension_music.stream_paused and game.hunt_music.stream_paused)
	game.resume_game()
	check("AUDIO-03-resume-all-layers",not game.music.stream_paused and not game.tension_music.stream_paused and not game.hunt_music.stream_paused)
	game.voice_index=0;game.play_sound("power");game.play_sound("near_miss")
	check("AUDIO-04-independent-cue-voices",game.voices[0].stream==game.sounds.power and game.voices[1].stream==game.sounds.near_miss)
	var reduced_before:bool=game.settings.reduced
	game.settings.reduced=true;game.feedback.reset()
	game.feedback.react({"type":"power","pos":Vector2(1,9)},game.sim,true)
	game._process(0.016)
	check("ACCESS-02-reduced-camera-zero-impulse",game.camera.fov==49 and game.feedback.camera_offset(0)==Vector3.ZERO and game.feedback.effects.is_empty())
	game.settings.reduced=reduced_before
	var strength:float=game.settings.camera_motion;game.settings.camera_motion=0.0;game._process(0.016)
	check("ACCESS-03-slider-zero-fov-fixed",game.camera.fov==49)
	game.settings.camera_motion=strength
	game.sim.pickups[Vector2i(1,9)]="power";game.sim.collect(Vector2i(1,9),game.sim.time)
	await press(KEY_Q)
	check("INPUT-01-risk-wager-key",game.sim.risk.state=="active" and game.sim.energy==80)
	game.start_game();check("ACCESS-04-restart-clears-cosmetic-state",game.feedback.impact==0 and game.feedback.effects.is_empty())
	game.update_hud()
	var count_before:Dictionary=game.sim.pickup_progress()
	check("MAP-UI-01-live-counter",game.collection_label.text=="FALTAM %d ITENS"%count_before.remaining and game.collection_bar.value==0)
	await press(KEY_M)
	check("MAP-UI-02-key-opens-paused-map",game.current_screen=="map" and game.map_overlay.visible and game.sim.paused and game.music.stream_paused)
	var map_time:float=game.sim.time
	var map_count:Dictionary=game.sim.pickup_progress()
	await physics_frame;await physics_frame
	check("MAP-UI-03-map-freezes-simulation",game.sim.time==map_time and game.sim.pickup_progress()==map_count)
	check("MAP-UI-04-shared-live-state",game.overview_map.sim==game.sim and game.minimap.sim==game.sim)
	check("MAP-UI-05-map-fits-reference-viewport",game.map_overlay.position.y>=0 and game.map_overlay.position.y+game.map_overlay.size.y<=game.map_overlay.get_parent().size.y)
	await press(KEY_ESCAPE)
	check("MAP-UI-06-escape-resumes",game.current_screen=="playing" and not game.map_overlay.visible and not game.sim.paused and not game.music.stream_paused)
	await press(KEY_M);await press(KEY_M)
	check("MAP-UI-07-m-closes-map",game.current_screen=="playing" and not game.map_overlay.visible)
	game.pause_game();game.show_map();game.start_game();game.update_hud()
	check("MAP-UI-08-restart-clears-overlay",not game.map_overlay.visible and game.collection_bar.value==0)
	for c in game.sim.pickups.keys():
		if game.sim.pickups.size()<=1:break
		game.sim.collect(c,game.sim.time)
	game.update_hud()
	check("MAP-UI-09-last-item-caption",game.collection_label.text=="ÚLTIMO ITEM")
	game.sim.collect(game.sim.pickups.keys()[0],game.sim.time);game.update_hud()
	check("MAP-UI-10-complete-caption",game.collection_label.text=="ÁREA LIMPA" and game.collection_bar.value==game.collection_bar.max_value)
	game.start_game();game.update_hud()
	check("CIRCUIT-UI-01-start-first-phase",game.sim.campaign and game.sim.stage_id==0 and game.sim.shield_charges==1 and game.sim.magnet_charges==0)
	await press(KEY_E)
	check("CIRCUIT-UI-02-shield-input",game.sim.shield_charges==0 and game.sim.shield_until>game.sim.time)
	await press(KEY_R)
	check("CIRCUIT-UI-03-magnet-locked",game.sim.magnet_until<0)
	game.sim.stage_captures=2;game.sim.time=60;finish_stage()
	check("CIRCUIT-UI-04-win-records-unlock-and-medals",game.current_screen=="results" and game.settings.unlocked>=1 and game.settings.medals[0]==7 and game.settings.circuit_record==game.sim.score)
	var carry_score:int=game.sim.score;game.sim.lives=1;game.next_stage()
	check("CIRCUIT-UI-05-next-carries-score-and-life",game.sim.stage_id==1 and game.sim.score==carry_score and game.sim.lives==2 and game.sim.magnet_charges==1)
	check("START-UI-04-next-phase-waits",game.sim.player.pos==Vector2(1,9) and game.sim.player.dir==Vector2i.ZERO)
	check("CIRCUIT-UI-06-rebuilds-visual-map",game.walls.has(Vector2i(8,1)) and not game.walls.has(Vector2i(3,2)) and game.pickup_nodes.size()==game.sim.pickups.size())
	await press(KEY_E);await press(KEY_R)
	check("CIRCUIT-UI-07-second-phase-powers",game.sim.shield_until>game.sim.time and game.sim.magnet_until>game.sim.time)
	await press(KEY_M)
	var held_time:float=game.sim.time
	await press(KEY_E);await physics_frame;await physics_frame
	check("CIRCUIT-UI-08-map-freezes-powers",game.sim.time==held_time and game.sim.shield_charges==0 and game.sim.magnet_charges==0)
	await press(KEY_M)
	game.sim.time=60;finish_stage();game.next_stage()
	check("CIRCUIT-UI-09-third-phase-unlocked",game.sim.stage_id==2 and game.settings.unlocked==2 and game.sim.lives==3)
	game.sim.risk.state="success";game.sim.time=60;finish_stage()
	check("CIRCUIT-UI-10-third-is-intermediate",game.menu_content.get_child(0).text=="FASE CONCLUÍDA!" and game.settings.medals[2]==7)
	game.next_stage()
	check("CIRCUIT-UI-11-fourth-phase-accessible",game.sim.stage_id==3 and game.current_screen=="playing")
	for i in [3,4]:
		game.sim.time=60;game.sim.max_chain=4;finish_stage();game.next_stage()
	game.sim.boss.defeated=true;game.sim.time=90;finish_stage()
	check("CIRCUIT-UI-12-six-phase-finale",game.menu_content.get_child(0).text=="CIRCUITO CONCLUÍDO!" and game.settings.unlocked==5 and game.total_medals()==18)
	game.next_stage();check("CIRCUIT-UI-13-final-does-not-wrap",game.sim.stage_id==5 and game.current_screen=="results")
	game.show_campaign();game.menu_content.get_children().filter(func(n):return n is Button and n.text.begins_with("3 ·")).front().pressed.emit()
	check("CIRCUIT-UI-14-selector-preserved",game.current_screen=="playing" and game.sim.stage_id==2)
	game.start_game();check("CIRCUIT-UI-15-progress-preserved",game.sim.stage_id==0 and game.sim.score==0 and game.settings.medals==[7,7,7,7,7,7] and game.settings.unlocked==5)
	var file=FileAccess.open("res://evidencias/testes_integracao.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"suite":"MV scene and input routing (headless, synthetic keys)","executed":checks.size(),"passed":checks.size()-failures,"failed":failures,"results":checks},"\t"));file.close()
	game.queue_free();await process_frame
	print("MV_INTEGRATION_RESULT executed=",checks.size()," failed=",failures)
	quit(1 if failures else 0)

