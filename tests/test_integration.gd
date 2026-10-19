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
func run() -> void:
	game=Scene.instantiate();root.add_child(game);current_scene=game
	await process_frame;await process_frame
	var musical_cycle:float=float(game.music.stream.loop_end)/game.music.stream.mix_rate
	check("AUDIO-01-full-musical-loop",absf(musical_cycle-32.0*60.0/112.0)<0.01)
	check("UI-01-title-and-menu",game.current_screen=="title" and game.menu.visible)
	check("SCENE-01-real-actors",game.hero.get_node("Protagonista/Body").mesh is ArrayMesh and game.ghosts.size()==4)
	await press(KEY_ENTER)
	check("UI-02-enter-start",game.current_screen=="playing" and not game.sim.paused)
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
	check("ACCESS-02-reduced-camera-zero-impulse",game.camera.fov==45 and game.feedback.camera_offset(0)==Vector3.ZERO and game.feedback.effects.is_empty())
	game.settings.reduced=reduced_before
	var strength:float=game.settings.camera_motion;game.settings.camera_motion=0.0;game._process(0.016)
	check("ACCESS-03-slider-zero-fov-fixed",game.camera.fov==45)
	game.settings.camera_motion=strength
	game.sim.pickups[Vector2i(1,9)]="power";game.sim.collect(Vector2i(1,9),game.sim.time)
	await press(KEY_Q)
	check("INPUT-01-risk-wager-key",game.sim.risk.state=="active" and game.sim.energy==80)
	game.start_game();check("ACCESS-04-restart-clears-cosmetic-state",game.feedback.impact==0 and game.feedback.effects.is_empty())
	var file=FileAccess.open("res://evidencias/testes_integracao.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"suite":"MV scene and input routing (headless, synthetic keys)","executed":checks.size(),"passed":checks.size()-failures,"failed":failures,"results":checks},"\t"));file.close()
	game.queue_free();await process_frame
	print("MV_INTEGRATION_RESULT executed=",checks.size()," failed=",failures)
	quit(1 if failures else 0)
