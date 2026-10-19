extends Node3D
const Rules=preload("res://scripts/rules.gd")
const Models=preload("res://scripts/models.gd")
const Store=preload("res://scripts/storage.gd")
const PlayerScene=preload("res://scenes/player.tscn")
const GhostScene=preload("res://scenes/ghost.tscn")
const COLORS=[Color("ff4765"),Color("ff78d0"),Color("3bdffc"),Color("ffac59")]
const CELL:=1.4
var sim=Rules.new()
var settings:Dictionary
var world_environment:WorldEnvironment
var camera:Camera3D
var hero:Node3D
var ghosts:Array=[]
var walls:Dictionary={}
var pickup_nodes:Dictionary={}
var ui:CanvasLayer
var menu:PanelContainer
var menu_content:VBoxContainer
var hud:Control
var score_label:Label
var status_label:Label
var life_label:Label
var flow_label:Label
var energy_bar:ProgressBar
var power_bar:ProgressBar
var toast:Label
var minimap:Control
var sound:AudioStreamPlayer
var music:AudioStreamPlayer
var sounds:Dictionary={}
var trail:Array=[]
var last_trail:=0.0
var first_frame:=true
var demo:=false
var smoke:=false
var elapsed:=0.0
var frame_times:Array=[]
var previous_graph:=0
var terminal_reported:=false
var current_screen:="title"
var key_stack:Array=[]
var screenshot_dir:=""
var screenshots_done:Dictionary={}
var demo_target:=Vector2i(5,9)
var menu_clock:=0.0
var real_previous_us:=0
var runtime_info:Dictionary={}
var report_path:=""
var observed_events:Dictionary={}
var shutdown_started:=false
var ribbon:MeshInstance3D
var ribbon_material:StandardMaterial3D

func _ready() -> void:
	settings=Store.read_settings()
	setup_input()
	for arg in OS.get_cmdline_user_args():
		if arg=="--demo":demo=true
		if arg=="--smoke":smoke=true
		if arg.begins_with("--report="):report_path=arg.get_slice("=",1)
		if arg.begins_with("--capture-dir="):screenshot_dir=arg.get_slice("=",1)
	build_world()
	build_ui()
	setup_audio()
	apply_settings()
	show_title()
	runtime_info={"version":"0.1.0-mv","engine":Engine.get_version_info().string,"os":OS.get_name(),"display":DisplayServer.get_name(),"requested_renderer":ProjectSettings.get_setting("rendering/renderer/rendering_method"),"active_renderer":RenderingServer.get_current_rendering_method(),"driver":RenderingServer.get_current_rendering_driver_name(),"adapter":RenderingServer.get_video_adapter_name()}
	print("NEOGRID_RUNTIME ",JSON.stringify(runtime_info))
	if demo or smoke:start_game()
	get_tree().auto_accept_quit=false

func setup_input() -> void:
	var mapping={"p1_up":[KEY_W,KEY_UP],"p1_down":[KEY_S,KEY_DOWN],"p1_left":[KEY_A,KEY_LEFT],"p1_right":[KEY_D,KEY_RIGHT],"p1_dash":[KEY_SPACE],"pause_game":[KEY_P,KEY_ESCAPE],"confirm_game":[KEY_ENTER],"toggle_camera":[KEY_C],"toggle_fullscreen":[KEY_F11]}
	for action in mapping:
		if not InputMap.has_action(action):InputMap.add_action(action)
		for code in mapping[action]:
			var event:=InputEventKey.new();event.physical_keycode=code;InputMap.action_add_event(action,event)

func coord(p:Vector2,y:float=0.0) -> Vector3:
	return Vector3((p.x-8)*CELL,y,(p.y-6)*CELL)

func build_world() -> void:
	world_environment=WorldEnvironment.new()
	var env:=Environment.new()
	env.background_mode=Environment.BG_COLOR;env.background_color=Color("060b19")
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color("8a9bc7");env.ambient_light_energy=0.70
	env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
	env.glow_enabled=true;env.glow_intensity=0.45;env.glow_bloom=0.08
	env.ssr_enabled=true;env.ssr_max_steps=32;env.ssao_enabled=true;env.ssao_radius=0.65;env.ssao_intensity=1.3
	world_environment.environment=env;add_child(world_environment)
	var key:=DirectionalLight3D.new();key.light_color=Color("92afff");key.light_energy=1.3;key.rotation_degrees=Vector3(-58,-30,0);key.shadow_enabled=true;add_child(key)
	var rim:=DirectionalLight3D.new();rim.light_color=Color("f8a2dd");rim.light_energy=0.65;rim.rotation_degrees=Vector3(-30,145,0);add_child(rim)
	for p in [Vector3(-9,5,-4),Vector3(8,5,5)]:
		var light:=OmniLight3D.new();light.position=p;light.light_color=Color("37cbf4") if p.x<0 else Color("ff4eab");light.light_energy=2.5;light.omni_range=15;add_child(light)
	var bottom:=BoxMesh.new();bottom.size=Vector3(26,0.1,20)
	add_child(Models.mesh_node(bottom,Models.material(Color("02050d")),Vector3(0,-1.8,0)))
	var floor_mesh:=PlaneMesh.new();floor_mesh.size=Vector2(17*CELL,13*CELL)
	var floor_mat:=ShaderMaterial.new();floor_mat.shader=load("res://assets/floor.gdshader")
	add_child(Models.mesh_node(floor_mesh,floor_mat,Vector3(0,-0.025,0)))
	var wall_mesh=Models.bevel_box(Vector3(CELL*0.97,1.18,CELL*0.97),0.09)
	for y in Rules.GRID.size():
		for x in Rules.GRID[y].length():
			var cell:=Vector2i(x,y)
			if sim.floors.has(cell):continue
			var color:=Color("44365e")
			var neon:bool=(x+y*3)%5==0 or x==0 or x==16
			if neon:color=Color("45d4ef") if (x+y)%2==0 else Color("e349a4")
			var mat=Models.material(color,0.40 if neon else 0.0,0.35)
			var wall=Models.mesh_node(wall_mesh,mat,coord(Vector2(cell),0.59))
			walls[cell]=wall;add_child(wall)
			if not neon:
				var trim_mesh:=BoxMesh.new();trim_mesh.size=Vector3(CELL*0.82,0.025,0.025)
				var trim=Models.mesh_node(trim_mesh,Models.material(Color("8c4dba"),0.4),Vector3(0,0.58,CELL*0.47));wall.add_child(trim)
	# Closing cell exists visually from the start but remains open until the safe swap.
	var closing=Models.mesh_node(wall_mesh,Models.material(Color("4ed8ee"),0.6,0.35),coord(Vector2(Rules.CLOSE_CELL),0.59));closing.visible=false;walls[Rules.CLOSE_CELL]=closing;add_child(closing)
	for cell in sim.pickups:create_pickup(cell,sim.pickups[cell])
	hero=PlayerScene.instantiate();hero.scale=Vector3.ONE*CELL;add_child(hero)
	for i in 4:
		var ghost=GhostScene.instantiate();ghost.tint=COLORS[i];ghost.scale=Vector3.ONE*CELL;add_child(ghost);ghosts.append(ghost)
	camera=Camera3D.new();camera.fov=45;camera.near=0.15;camera.far=90;add_child(camera);camera.current=true
	ribbon=MeshInstance3D.new();ribbon.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ribbon_material=Models.material(Color(1.0,0.68,0.13,0.7),1.2)
	ribbon_material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ribbon_material.cull_mode=BaseMaterial3D.CULL_DISABLED
	ribbon.material_override=ribbon_material;add_child(ribbon)
	# Sparse architecture beyond the board, entirely decorative.
	var rng:=RandomNumberGenerator.new();rng.seed=1403
	for i in 22:
		var h:=rng.randf_range(2,8)
		var tower=Models.mesh_node(Models.bevel_box(Vector3(1.8,h,1.6),0.04),Models.material(Color("0a1029"),0,0.2),Vector3(-21+i*2,h/2,-14-rng.randf_range(0,3)))
		add_child(tower)
		var strip:=BoxMesh.new();strip.size=Vector3(0.04,h*0.7,0.03)
		tower.add_child(Models.mesh_node(strip,Models.material(Color("326887"),0.6),Vector3(0.8,0,0.82)))

func create_pickup(cell:Vector2i,kind:String) -> void:
	var root:=Node3D.new();root.position=coord(Vector2(cell));root.name="Item_%s_%s"%[cell.x,cell.y]
	if kind=="fruit":
		for side in [-1.0,1.0]:root.add_child(Models.mesh_node(Models.sphere(0.16),Models.material(Color("ff487c"),0.2,0.3),Vector3(side*0.13,0.38,0)))
		var stem:=CylinderMesh.new();stem.top_radius=0.025;stem.bottom_radius=0.025;stem.height=0.35
		var stalk=Models.mesh_node(stem,Models.material(Color("64ecac"),0.4),Vector3(0,0.65,0));stalk.rotation.z=-0.5;root.add_child(stalk)
	else:
		root.add_child(Models.mesh_node(Models.sphere(0.20 if kind=="power" else 0.075),Models.material(Color("ffe6a0"),2.2 if kind=="power" else 0.8,0.3),Vector3(0,0.28,0)))
		if kind=="power":
			var ring:=TorusMesh.new();ring.inner_radius=0.27;ring.outer_radius=0.30
			root.add_child(Models.mesh_node(ring,Models.material(Color("57e4f6"),1.4),Vector3(0,0.1,0)))
	add_child(root);pickup_nodes[cell]=root

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey and event.echo:return
	if event.is_action_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if event.is_action_pressed("toggle_camera"):
		settings.camera_top=not settings.camera_top;apply_settings();return
	if event.is_action_pressed("pause_game"):
		if current_screen=="playing":pause_game()
		elif current_screen=="pause":resume_game()
		else:show_title()
		return
	if current_screen!="playing":
		if event.is_action_pressed("confirm_game") and current_screen=="title":start_game()
		return
	var bindings={"p1_right":Vector2i.RIGHT,"p1_down":Vector2i.DOWN,"p1_left":Vector2i.LEFT,"p1_up":Vector2i.UP}
	for action in bindings:
		if event.is_action_pressed(action):
			key_stack.erase(action);key_stack.append(action);sim.request_direction(bindings[action])
		if event.is_action_released(action):
			key_stack.erase(action)
			sim.held_dir=bindings[key_stack.back()] if not key_stack.is_empty() else Vector2i.ZERO
	if event.is_action_pressed("p1_dash"):sim.request_dash()

func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT:
		key_stack.clear();sim.held_dir=Vector2i.ZERO;sim.buffer_dir=Vector2i.ZERO;sim.buffer_time=-100
		if current_screen=="playing" and not demo and not smoke:pause_game()
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		if sim.status in ["playing","respawning"] and hud!=null and hud.visible:show_quit_confirm()
		else:get_tree().quit()

func _physics_process(dt:float) -> void:
	if current_screen!="playing":return
	if demo:demo_input()
	sim.tick(dt)
	for event in sim.events:
		observed_events[event.type]=observed_events.get(event.type,0)+1
		match event.type:
			"dash":play_sound("dash");burst(coord(event.pos,0.4),Color("ffd568"),10)
			"pellet":play_sound("pellet")
			"power":burst(coord(event.pos,0.6),Color("72dcff"),22);play_sound("power");notify("POWER • CAPTURE OS FANTASMAS")
			"capture":burst(coord(event.pos,0.7),Color("58dfff"),24);play_sound("capture");notify("+%d  •  FLOW ×%.1f"%[event.points,sim.flow])
			"fruit":burst(coord(event.pos,0.6),Color("ff86bb"),16);play_sound("fruit")
			"drift":burst(coord(event.pos,0.3),Color("ffe576"),5)
			"warning":notify("RECONFIGURANDO ROTAS • AGUARDE A LUZ")
			"topology":burst(coord(event.pos,0.6),Color("75efff"),25);notify("NOVA ROTA ABERTA")
			"topology_cancel":notify("ROTA PRESERVADA • PASSAGEM OCUPADA")
			"death":burst(coord(event.pos,0.65),Color("ffd36c"),25);play_sound("death");notify("VIDA PERDIDA • PREPARE-SE")
	if sim.graph_version!=previous_graph:
		walls[Rules.OPEN_CELL].visible=false;walls[Rules.CLOSE_CELL].visible=true;previous_graph=sim.graph_version
	for cell in pickup_nodes.keys():
		if not sim.pickups.has(cell):pickup_nodes[cell].queue_free();pickup_nodes.erase(cell)
	if sim.status in ["won","game_over"] and not terminal_reported:
		terminal_reported=true
		settings.record=maxi(settings.record,sim.score);Store.write_settings(settings)
		show_results()

func _process(dt:float) -> void:
	elapsed+=dt;menu_clock+=dt
	var now_us:=Time.get_ticks_usec()
	if real_previous_us>0 and elapsed>2.0:frame_times.append((now_us-real_previous_us)/1000.0)
	real_previous_us=now_us
	if frame_times.size()>10000:frame_times.pop_front()
	var alpha:=Engine.get_physics_interpolation_fraction()
	var p:Vector2=sim.player.previous.lerp(sim.player.pos,alpha)
	hero.position=coord(p)
	var visual_time:float=sim.time if current_screen!="title" else menu_clock
	hero.animate(visual_time,sim.player.dir,"",0.0,settings.reduced)
	for i in ghosts.size():
		var g:Dictionary=sim.ghosts[i]
		ghosts[i].position=coord(g.previous.lerp(g.pos,alpha))
		ghosts[i].animate(visual_time+i,g.dir,g.state,maxf(0,sim.power_until-sim.time),settings.reduced)
		# Expressive faces orient toward the camera; collision/direction stay planar.
		var facing:Vector3=camera.position-ghosts[i].position
		ghosts[i].rotation.y=-atan2(facing.z,facing.x)
	var target:=coord(p,0.0)
	if current_screen=="title":target=coord(Vector2(4.5,8))
	if settings.camera_top:target=Vector3.ZERO
	var offset:=Vector3(0.0,27,0.01) if settings.camera_top else Vector3(3.6,8.6,8.4)
	if first_frame:camera.position=target+offset;first_frame=false
	else:camera.position=camera.position.lerp(target+offset,1-exp(-dt*5))
	camera.look_at(target,Vector3(0,0,-1) if settings.camera_top else Vector3.UP)
	# Fade the foreground obstacle when it can occlude the player.
	for c in walls:
		var node:MeshInstance3D=walls[c]
		var near_player:bool=absf(c.x-p.x)<1.2 and c.y>p.y and c.y-p.y<1.4
		node.scale.y=lerpf(node.scale.y,0.28 if near_player and not settings.camera_top else 1.0,minf(1,dt*8))
	if not sim.topology.is_empty():
		var mat:StandardMaterial3D=walls[Rules.OPEN_CELL].material_override
		mat.emission_enabled=true;mat.emission=Color("68e6f0");mat.emission_energy_multiplier=1.0+sin(visual_time*8)*0.4
		walls[Rules.CLOSE_CELL].visible=true
		var preview_mat:StandardMaterial3D=walls[Rules.CLOSE_CELL].material_override
		preview_mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;preview_mat.albedo_color.a=0.22+0.08*sin(visual_time*8)
	else:
		walls[Rules.CLOSE_CELL].visible=sim.graph_version>0
		var closing_mat:StandardMaterial3D=walls[Rules.CLOSE_CELL].material_override
		closing_mat.transparency=BaseMaterial3D.TRANSPARENCY_DISABLED;closing_mat.albedo_color.a=1.0
	for cell in pickup_nodes:
		if sim.pickups.get(cell)=="power":pickup_nodes[cell].scale=Vector3.ONE*(1.0+0.10*sin(visual_time*4))
	update_hud()
	update_trail(dt)
	if demo and not screenshot_dir.is_empty():
		for mark in [2,7]:
			if sim.time>=mark and not screenshots_done.has(mark):screenshots_done[mark]=true;save_screenshot(mark)
	if demo and elapsed>9.8:music.stop();sound.stop()
	if smoke and elapsed>=3.0:
		print("NEOGRID_SMOKE_OK ",JSON.stringify({"score":sim.score,"time":sim.time,"ghosts":ghosts.size(),"pickups":pickup_nodes.size()}));get_tree().quit()

func demo_input() -> void:
	var cell:=Vector2i(sim.player.pos.round())
	if sim.player.pos.distance_to(Vector2(cell))>0.05:return
	if sim.time<1.0:demo_target=Vector2i(5,9)
	elif sim.time<3.0:demo_target=Vector2i(9,7)
	else:
		var best:=10000
		for g in sim.ghosts:
			if g.state!="vulnerable":continue
			var d:int=sim.path_distance(cell,Vector2i(g.pos.round()))
			if d<best:best=d;demo_target=Vector2i(g.pos.round())
		if best==10000:
			for c in sim.pickups:
				var d:int=sim.path_distance(cell,c)
				if sim.pickups[c]=="power":d-=3
				if d<best:best=d;demo_target=c
	var direction:=Vector2i.ZERO;var distance:=10000
	for d in Rules.DIRS:
		if not sim.floors.has(cell+d):continue
		var dd:int=sim.path_distance(cell+d,demo_target)
		if dd<distance:distance=dd;direction=d
	if direction!=sim.player.dir:sim.request_direction(direction)
	else:sim.held_dir=direction
	if sim.time>0.25 and sim.floors.has(cell+direction*2) and direction==sim.player.dir:sim.request_dash()

func save_screenshot(mark:int) -> void:
	await RenderingServer.frame_post_draw
	var image=get_viewport().get_texture().get_image()
	if image!=null and not image.is_empty():
		DirAccess.make_dir_recursive_absolute(screenshot_dir)
		image.save_png(screenshot_dir.path_join("NeoGrid_real_%02ds.png"%mark))

func notify(text:String) -> void:
	toast.text=text;toast.modulate.a=1.0
	var tween=create_tween();tween.tween_interval(2.0);tween.tween_property(toast,"modulate:a",0.0,0.8)

func burst(pos:Vector3,color:Color,amount:int) -> void:
	if settings.reduced:return
	var particles:=CPUParticles3D.new()
	particles.position=pos;particles.amount=amount if settings.quality>0 else mini(amount,8)
	particles.lifetime=0.6;particles.one_shot=true;particles.explosiveness=1.0
	particles.direction=Vector3.UP;particles.spread=130;particles.gravity=Vector3(0,-2,0)
	particles.initial_velocity_min=1.0;particles.initial_velocity_max=3.0
	particles.scale_amount_min=0.025;particles.scale_amount_max=0.08
	particles.mesh=Models.sphere(1.0);particles.material_override=Models.material(color,1.0)
	add_child(particles);particles.emitting=true
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)

func update_trail(dt:float) -> void:
	if current_screen=="playing" and sim.player.pos.distance_to(sim.player.previous)>0.0001 and sim.time-last_trail>0.035 and not settings.reduced:
		last_trail=sim.time
		var hot:bool=sim.time<sim.dash_until or sim.flow>1.0
		var orb=Models.mesh_node(Models.sphere(0.12 if hot else 0.055),Models.material(Color("ffcb58"),1.8),hero.position+Vector3(0,0.26,0));add_child(orb)
		trail.append({"node":orb,"life":0.34 if hot else 0.18,"max":0.34 if hot else 0.18})
	for i in range(trail.size()-1,-1,-1):
		if current_screen=="playing":trail[i].life-=dt
		trail[i].node.scale=Vector3.ONE*maxf(0.01,trail[i].life/trail[i].max)
		if trail[i].life<=0:trail[i].node.queue_free();trail.remove_at(i)

	if trail.size()>1:
		var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var points:Array=[hero.position+Vector3(0,0.26,0)]
		for i in range(trail.size()-1,-1,-1):points.append(trail[i].node.position)
		for i in range(points.size()-1):
			var delta:Vector3=points[i+1]-points[i]
			if delta.length_squared()<0.00001:continue
			var side:=Vector3(-delta.z,0,delta.x).normalized()*0.11*(1.0-float(i)/points.size())
			var vertices=[points[i]-side,points[i]+side,points[i+1]+side,points[i+1]-side]
			Models.face(st,vertices,Vector3.UP)
		ribbon.mesh=st.commit();ribbon.visible=true
	else:ribbon.visible=false

func setup_audio() -> void:
	sound=AudioStreamPlayer.new();add_child(sound);sound.max_polyphony=5
	music=AudioStreamPlayer.new();add_child(music)
	for n in ["pellet","power","capture","dash","death","fruit"]:sounds[n]=load("res://assets/audio/"+n+".wav")
	music.stream=load("res://assets/audio/pulse.wav")
	if music.stream is AudioStreamWAV:music.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;music.stream.loop_end=roundi(music.stream.get_length()*music.stream.mix_rate)
	music.volume_db=-15;music.play()

func play_sound(kind:String) -> void:
	if sounds.has(kind):sound.stream=sounds[kind];sound.volume_db=-18 if kind=="pellet" else -10;sound.play()

func apply_settings() -> void:
	AudioServer.set_bus_mute(0,settings.mute)
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(0.001,settings.volume)))
	var env:Environment=world_environment.environment
	env.glow_enabled=not settings.reduced
	env.glow_intensity=0.20 if settings.reduced else 0.45
	env.ssr_enabled=settings.quality>0
	env.ssao_enabled=settings.quality>0
	env.ssr_max_steps=32 if settings.quality==2 else 16
	get_viewport().positional_shadow_atlas_size=2048 if settings.quality==2 else 1024
	Store.write_settings(settings)

func label(text:String,size:int,color:Color=Color("e9f1ff")) -> Label:
	var l:=Label.new();l.text=text;l.add_theme_font_size_override("font_size",size);l.add_theme_color_override("font_color",color);return l

func panel() -> PanelContainer:
	var p:=PanelContainer.new();var style:=StyleBoxFlat.new();style.bg_color=Color(0.025,0.04,0.10,0.94)
	style.border_color=Color(0.25,0.65,0.8,0.55);style.set_border_width_all(1);style.set_corner_radius_all(12);style.content_margin_left=20;style.content_margin_right=20;style.content_margin_top=14;style.content_margin_bottom=14;p.add_theme_stylebox_override("panel",style);return p

func button(text:String,callback:Callable) -> Button:
	var b:=Button.new();b.text=text;b.custom_minimum_size=Vector2(330,42);b.add_theme_font_size_override("font_size",17)
	var style:=StyleBoxFlat.new();style.bg_color=Color("17263e");style.set_corner_radius_all(6);style.content_margin_left=18;style.content_margin_right=18
	var hover:=style.duplicate();hover.bg_color=Color("24617b");hover.border_color=Color("67e6ef");hover.set_border_width_all(1)
	b.add_theme_stylebox_override("normal",style);b.add_theme_stylebox_override("hover",hover);b.add_theme_stylebox_override("focus",hover);b.add_theme_stylebox_override("pressed",hover);b.pressed.connect(callback);return b

func build_ui() -> void:
	ui=CanvasLayer.new();add_child(ui)
	var root:=Control.new();root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.add_child(root)
	var theme:=Theme.new();theme.default_font=load("res://assets/DejaVuSans.ttf");root.theme=theme
	hud=Control.new();hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);hud.mouse_filter=Control.MOUSE_FILTER_IGNORE;root.add_child(hud)
	var top=panel();top.position=Vector2(25,20);hud.add_child(top)
	var row:=HBoxContainer.new();row.add_theme_constant_override("separation",28);top.add_child(row)
	var col:=VBoxContainer.new();row.add_child(col);col.add_child(label("NEO—GRID  /  MV",13,Color("5de0eb")));score_label=label("000000",30);col.add_child(score_label)
	var livescol:=VBoxContainer.new();row.add_child(livescol);livescol.add_child(label("VIDAS",11,Color("97a9c4")));life_label=label("● ● ●",22,Color("ffce68"));livescol.add_child(life_label)
	var minimap_panel=panel();minimap_panel.position=Vector2(1090,20);hud.add_child(minimap_panel)
	minimap=Control.new();minimap.set_script(load("res://scripts/minimap.gd"));minimap.sim=sim;minimap.custom_minimum_size=Vector2(136,104);minimap_panel.add_child(minimap)
	var bottom=panel();bottom.position=Vector2(25,625);bottom.custom_minimum_size.x=420;hud.add_child(bottom)
	var box:=VBoxContainer.new();bottom.add_child(box)
	flow_label=label("FLOW ×1.0",16,Color("ffb5df"));box.add_child(flow_label)
	energy_bar=ProgressBar.new();energy_bar.show_percentage=false;energy_bar.custom_minimum_size=Vector2(370,10);energy_bar.max_value=100;box.add_child(energy_bar)
	status_label=label("ESPAÇO · DASH    C · CÂMERA    P · PAUSA",11,Color("9aacc4"));box.add_child(status_label)
	var power_panel=panel();power_panel.position=Vector2(1000,637);power_panel.custom_minimum_size.x=250;hud.add_child(power_panel)
	var pbox:=VBoxContainer.new();power_panel.add_child(pbox);pbox.add_child(label("POWER PELLET",11,Color("91e2ff")));power_bar=ProgressBar.new();power_bar.show_percentage=false;power_bar.custom_minimum_size=Vector2(200,8);power_bar.max_value=6;pbox.add_child(power_bar)
	toast=label("",19,Color("fcdd8c"));toast.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;toast.position=Vector2(300,110);toast.size=Vector2(680,50);hud.add_child(toast)
	menu=panel();menu.position=Vector2(65,100);menu.custom_minimum_size=Vector2(400,0);root.add_child(menu)
	menu_content=VBoxContainer.new();menu_content.add_theme_constant_override("separation",12);menu.add_child(menu_content)

func clear_menu(title:String,subtitle:String="") -> void:
	for c in menu_content.get_children():menu_content.remove_child(c);c.queue_free()
	menu.visible=true
	menu_content.add_child(label(title,35,Color("ffdb76")))
	if not subtitle.is_empty():menu_content.add_child(label(subtitle,13,Color("8fc5d5")))

func show_title() -> void:
	current_screen="title";sim.paused=true;hud.visible=false
	clear_menu("NEO—GRID","MS. PAC-MAN  /  UMA NOVA ÓRBITA ARCADE")
	menu_content.add_child(label("Corra entre luzes. Transforme a caçada.",13))
	menu_content.add_child(button("Jogar o demonstrador",start_game))
	menu_content.add_child(button("Como jogar",show_help))
	menu_content.add_child(button("Configurações",show_settings))
	menu_content.add_child(button("Recorde  ·  %06d"%settings.record,show_records))
	menu_content.add_child(button("Sair",func():get_tree().quit()))
	menu_content.add_child(label("MV 0.1  •  IMPLEMENTAÇÃO PRÓPRIA",10,Color("7787a2")))

func start_game() -> void:
	sim.reset();sim.start();sim.paused=false;current_screen="playing";hud.visible=true;menu.visible=false;terminal_reported=false;previous_graph=0;music.stream_paused=false
	walls[Rules.OPEN_CELL].visible=true;walls[Rules.CLOSE_CELL].visible=false
	for n in pickup_nodes.values():n.queue_free()
	pickup_nodes.clear()
	for c in sim.pickups:create_pickup(c,sim.pickups[c])
	key_stack.clear();last_trail=0
	notify("SEU PRÓXIMO MOVIMENTO MUDA TUDO")

func pause_game() -> void:
	current_screen="pause";sim.paused=true;key_stack.clear();sim.held_dir=Vector2i.ZERO;sim.buffer_dir=Vector2i.ZERO;music.stream_paused=true
	clear_menu("PAUSA","Seu tempo está preservado.")
	menu_content.add_child(button("Continuar",resume_game));menu_content.add_child(button("Reiniciar",start_game));menu_content.add_child(button("Configurações",show_settings));menu_content.add_child(button("Voltar à abertura",show_title));menu_content.add_child(button("Sair",show_quit_confirm))

func resume_game() -> void:
	current_screen="playing";sim.paused=false;menu.visible=false;hud.visible=true;music.stream_paused=false

func show_help() -> void:
	current_screen="help";sim.paused=true;clear_menu("COMO JOGAR")
	for text in ["WASD / setas  ·  mover e antecipar curvas","Espaço  ·  dash, custo de 40 de energia","C  ·  vista oblíqua / superior   ·   F11  ·  tela cheia","P / Esc  ·  pausa   ·   Enter  ·  iniciar","Colete a esfera de luz para capturar fantasmas.","Capturas ativam Flow. Frutas abrem novas rotas.","Colete todos os itens para concluir a área MV."]:
		menu_content.add_child(label(text,13))
	menu_content.add_child(button("Voltar",show_title))

func show_settings() -> void:
	current_screen="settings";sim.paused=true;clear_menu("CONFIGURAÇÕES")
	var quality:=OptionButton.new();for text in ["Baixa","Média","Alta"]:quality.add_item(text)
	quality.selected=settings.quality;quality.item_selected.connect(func(i):settings.quality=i;apply_settings());menu_content.add_child(quality)
	var volume:=HSlider.new();volume.min_value=0;volume.max_value=1;volume.step=0.05;volume.value=settings.volume;volume.custom_minimum_size=Vector2(320,28)
	menu_content.add_child(label("Volume",14));menu_content.add_child(volume);volume.value_changed.connect(func(v):settings.volume=v;apply_settings())
	for pair in [["mute","Silenciar"],["reduced","Reduzir efeitos e movimento"],["camera_top","Câmera superior 3D"]]:
		var check:=CheckButton.new();check.text=pair[1];check.button_pressed=settings[pair[0]];check.toggled.connect(func(v):settings[pair[0]]=v;apply_settings());menu_content.add_child(check)
	menu_content.add_child(button("Voltar",func():pause_game() if hud.visible else show_title()))

func show_records() -> void:
	current_screen="records";clear_menu("SEU RECORDE","MV • regras 0.1 • um jogador")
	menu_content.add_child(label("%06d"%settings.record,48));menu_content.add_child(button("Voltar",show_title))

func show_results() -> void:
	current_screen="results";sim.paused=true
	clear_menu("ÁREA CONCLUÍDA" if sim.status=="won" else "FIM DE JOGO","%06d pontos  •  Recorde %06d"%[sim.score,settings.record])
	menu_content.add_child(button("Jogar novamente",start_game));menu_content.add_child(button("Voltar à abertura",show_title))

func show_quit_confirm() -> void:
	sim.paused=true;current_screen="quit";clear_menu("ENCERRAR PARTIDA?","A partida atual será encerrada.")
	menu_content.add_child(button("Continuar jogando",resume_game));menu_content.add_child(button("Sair",func():get_tree().quit()))

func update_hud() -> void:
	score_label.text="%06d"%sim.score
	life_label.text="● ".repeat(maxi(0,sim.lives))
	flow_label.text="FLOW ×%.1f    ·    DASH %d%%"%[sim.flow,sim.energy]
	energy_bar.value=sim.energy;power_bar.value=maxf(0,sim.power_until-sim.time)
	minimap.queue_redraw()

func _exit_tree() -> void:
	if is_instance_valid(sound):sound.stop();sound.stream=null
	if is_instance_valid(music):music.stop();music.stream=null
	sounds.clear()
	OS.delay_msec(100)
	if not report_path.is_empty():
		frame_times.sort()
		var metrics:Dictionary={"runtime":runtime_info,"frames_after_warmup":frame_times.size(),"recorded_events":observed_events,"score":sim.score,"lives":sim.lives,"simulation_seconds":sim.time,"preset":settings.quality,"resolution":get_viewport().get_visible_rect().size,"wall_clock_frame_times_ms":true,"gpu_time_ms":null,"note":"Software renderer / Movie Maker is not native Windows validation or a physical GPU benchmark."}
		if not frame_times.is_empty():
			metrics.p95_ms=frame_times[mini(frame_times.size()-1,int(frame_times.size()*0.95))]
			metrics.p99_ms=frame_times[mini(frame_times.size()-1,int(frame_times.size()*0.99))]
		var file=FileAccess.open(report_path,FileAccess.WRITE)
		if file!=null:file.store_string(JSON.stringify(metrics,"\t"));file.close()
