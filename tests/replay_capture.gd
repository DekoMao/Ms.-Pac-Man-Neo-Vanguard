extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var options:Dictionary={}
	for arg in OS.get_cmdline_user_args():
		if arg.contains("="):options[arg.get_slice("=",0)]=arg.get_slice("=",1)
	var scene=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene);current_scene=scene
	scene.settings.reduced=false;scene.settings.camera_top=false;scene.settings.quality=2;scene.settings.volume=0.55;scene.settings.mute=false
	if scene.settings.has("camera_motion"):scene.settings.camera_motion=0.65
	scene.apply_settings();scene.start_game()
	var driver=load(get_script().resource_path.get_base_dir().path_join("replay_driver.gd")).new()
	driver.game=scene;driver.tape=JSON.parse_string(FileAccess.get_file_as_string(options["--tape"]))
	driver.report=options.get("--replay-report","");driver.capture_dir=options.get("--capture","")
	driver.process_physics_priority=-100;root.add_child(driver)
