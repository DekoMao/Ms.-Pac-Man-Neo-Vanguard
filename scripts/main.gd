extends Node3D
const Rules=preload("res://scripts/rules.gd")
const Models=preload("res://scripts/models.gd")
const Store=preload("res://scripts/storage.gd")
const PlayerScene=preload("res://scenes/player.tscn")
const GhostScene=preload("res://scenes/ghost.tscn")
const Feedback=preload("res://scripts/feedback.gd")
const Stages=preload("res://scripts/stages.gd")
const Architecture=preload("res://scripts/architecture.gd")
const Interface=preload("res://scripts/interface.gd")
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
var collection_label:Label
var collection_detail:Label
var collection_caption:Label
var collection_bar:ProgressBar
var map_overlay:PanelContainer
var overview_map:Control
var overview_caption:Label
var sound:AudioStreamPlayer
var music:AudioStreamPlayer
var sounds:Dictionary={}
var trail:Array=[]
var last_trail:=0.0
var first_frame:=true
var demo:=false
var smoke:=false
var smoke_fusion:=false
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
var feedback:Node3D
var voices:Array=[]
var voice_index:=0
var tension_music:AudioStreamPlayer
var hunt_music:AudioStreamPlayer
var phase_label:Label
var risk_label:Label
var power_caption:Label
var floor_material:ShaderMaterial
var toast_tween:Tween
var camera_anchor:=Vector3.ZERO
var maze_root:Node3D
var mission_label:Label
var ability_label:Label
var power_field:MeshInstance3D
var power_field_material:StandardMaterial3D
var stage_lights:Array=[]
var screen_root:Control
var game_frame:SubViewportContainer
var game_view:SubViewport
var header:PanelContainer
var sidebar:PanelContainer
var menu_scrim:ColorRect
var menu_scroll:ScrollContainer
var play_rect:Rect2
var house_gate:MeshInstance3D
var bonus_visual:Node3D
var bonus_caption:Label
var boss_visual:Node3D
var train_visuals:Array=[]
var hazard_visuals:Array=[]
var reveal_tween:Tween
var fusion_visual:Node3D
var best_before_run:=0
var session_metrics:Dictionary={"attempts":0,"retries":0,"death_cells":{},"abilities":{}}


func _ready() -> void:
	settings=Store.read_settings()
	setup_input()
	for arg in OS.get_cmdline_user_args():
		if arg=="--demo":demo=true
		if arg=="--smoke":smoke=true
		if arg=="--smoke-fusion":smoke=true;smoke_fusion=true
		if arg.begins_with("--report="):report_path=arg.get_slice("=",1)
		if arg.begins_with("--capture-dir="):screenshot_dir=arg.get_slice("=",1)
	build_world()
	fusion_visual=preload("res://scripts/fusion_visual.gd").new();add_child(fusion_visual)
	feedback=Feedback.new();add_child(feedback)
	build_ui()
	setup_audio()
	apply_settings()
	show_title()
	runtime_info={"version":"0.9.0-fusion","engine":Engine.get_version_info().string,"os":OS.get_name(),"display":DisplayServer.get_name(),"requested_renderer":ProjectSettings.get_setting("rendering/renderer/rendering_method"),"active_renderer":RenderingServer.get_current_rendering_method(),"driver":RenderingServer.get_current_rendering_driver_name(),"adapter":RenderingServer.get_video_adapter_name()}
	print("NEOGRID_RUNTIME ",JSON.stringify(runtime_info))
	if demo or smoke:start_game()
	if smoke_fusion:
		start_mode("fusion");sim.player.pos=Vector2(3,9);sim.player.previous=sim.player.pos
		sim.request_bomb();sim.request_direction(Vector2i.RIGHT)
	get_tree().auto_accept_quit=false

func setup_input() -> void:
	var mapping={"p1_up":[KEY_W,KEY_UP],"p1_down":[KEY_S,KEY_DOWN],"p1_left":[KEY_A,KEY_LEFT],"p1_right":[KEY_D,KEY_RIGHT],"p1_dash":[KEY_SPACE],"risk_wager":[KEY_Q],"pause_game":[KEY_P,KEY_ESCAPE],"confirm_game":[KEY_ENTER],"toggle_camera":[KEY_C],"toggle_fullscreen":[KEY_F11],"toggle_map":[KEY_M],"shield":[KEY_E],"magnet":[KEY_R],"boss_pulse":[KEY_F],"bomb":[KEY_B]}
	for action in mapping:
		if not InputMap.has_action(action):InputMap.add_action(action)
		for code in mapping[action]:
			var event:=InputEventKey.new();event.physical_keycode=code;InputMap.action_add_event(action,event)
	var pad={"p1_up":JOY_BUTTON_DPAD_UP,"p1_down":JOY_BUTTON_DPAD_DOWN,"p1_left":JOY_BUTTON_DPAD_LEFT,"p1_right":JOY_BUTTON_DPAD_RIGHT,"p1_dash":JOY_BUTTON_X,"shield":JOY_BUTTON_A,"magnet":JOY_BUTTON_Y,"risk_wager":JOY_BUTTON_LEFT_SHOULDER,"boss_pulse":JOY_BUTTON_RIGHT_SHOULDER,"pause_game":JOY_BUTTON_START,"confirm_game":JOY_BUTTON_A,"toggle_map":JOY_BUTTON_BACK,"bomb":JOY_BUTTON_B}
	for action in pad:
		var e:=InputEventJoypadButton.new();e.button_index=pad[action];InputMap.action_add_event(action,e)
	for tuple in [["p1_left",JOY_AXIS_LEFT_X,-1.0],["p1_right",JOY_AXIS_LEFT_X,1.0],["p1_up",JOY_AXIS_LEFT_Y,-1.0],["p1_down",JOY_AXIS_LEFT_Y,1.0]]:
		var e:=InputEventJoypadMotion.new();e.axis=tuple[1];e.axis_value=tuple[2];InputMap.action_add_event(tuple[0],e);InputMap.action_set_deadzone(tuple[0],0.5)

func coord(p:Vector2,y:float=0.0) -> Vector3:
	return Vector3((p.x-8)*CELL,y,(p.y-6)*CELL)

func build_world() -> void:
	world_environment=WorldEnvironment.new()
	var env:=Environment.new()
	env.background_mode=Environment.BG_COLOR;env.background_color=Color("070a16")
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color("8a9bc7");env.ambient_light_energy=0.52
	env.tonemap_mode=Environment.TONE_MAPPER_ACES
	env.glow_enabled=true;env.glow_intensity=0.45;env.glow_bloom=0.08
	env.fog_enabled=true;env.fog_light_color=Color("21263f");env.fog_light_energy=0.35;env.fog_density=0.009
	env.ssr_enabled=true;env.ssr_max_steps=32;env.ssao_enabled=true;env.ssao_radius=0.65;env.ssao_intensity=1.3
	world_environment.environment=env;add_child(world_environment)
	var key:=DirectionalLight3D.new();key.light_color=Color("92afff");key.light_energy=1.15;key.light_specular=0.22;key.rotation_degrees=Vector3(-58,-30,0);key.shadow_enabled=true;add_child(key)
	var rim:=DirectionalLight3D.new();rim.light_color=Color("f8a2dd");rim.light_energy=0.85;rim.light_specular=0.10;rim.rotation_degrees=Vector3(-30,145,0);add_child(rim)
	for p in [Vector3(-9,5,-4),Vector3(8,5,5)]:
		var light:=OmniLight3D.new();light.position=p;light.light_color=Color("37cbf4") if p.x<0 else Color("ff4eab");light.light_energy=1.15;light.light_specular=0.08;light.omni_range=15;add_child(light);stage_lights.append(light)
	var bottom:=BoxMesh.new();bottom.size=Vector3(26,0.1,20)
	add_child(Models.mesh_node(bottom,Models.material(Color("02050d")),Vector3(0,-1.8,0)))
	var floor_mesh:=PlaneMesh.new();floor_mesh.size=Vector2(17*CELL,13*CELL)
	var floor_mat:=ShaderMaterial.new();floor_mat.shader=load("res://assets/floor.gdshader")
	floor_material=floor_mat
	add_child(Models.mesh_node(floor_mesh,floor_mat,Vector3(0,-0.025,0)))
	rebuild_maze()
	hero=PlayerScene.instantiate();hero.scale=Vector3.ONE*CELL;add_child(hero)
	var field:=TorusMesh.new();field.inner_radius=0.67;field.outer_radius=0.72
	power_field_material=Models.material(Color("64eaff"),1.0)
	power_field=Models.mesh_node(field,power_field_material);power_field.visible=false;add_child(power_field)
	for i in 4:
		var ghost=GhostScene.instantiate();ghost.tint=COLORS[i];ghost.scale=Vector3.ONE*CELL;add_child(ghost);ghosts.append(ghost)
	bonus_visual=Models.bonus_fruit();bonus_visual.visible=false;add_child(bonus_visual)
	boss_visual=Models.ghost(Color("bd8cff"));boss_visual.scale=Vector3.ONE*CELL*2.2;boss_visual.visible=false;add_child(boss_visual)
	for i in 8:
		var follower=GhostScene.instantiate();follower.tint=COLORS[i%4];follower.scale=Vector3.ONE*CELL*0.68;follower.visible=false;add_child(follower);train_visuals.append(follower)
	for i in 17:
		var plate:=PlaneMesh.new();plate.size=Vector2.ONE*CELL*0.92
		var mat=Models.material(Color(1,0.22,0.34,0.25),0.6);mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		var n=Models.mesh_node(plate,mat);n.visible=false;add_child(n);hazard_visuals.append(n)
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
		for level in range(1,int(h/0.45)):
			for column in 3:
				if (level*7+column+i)%5==0:continue
				Architecture.box(tower,Vector3(0.20,0.06,0.025),Vector3(-0.57+column*0.53,-h*0.5+level*0.45,0.82),Color("54709b") if i%3 else Color("a359b7"),0.35)


func rebuild_maze() -> void:
	if is_instance_valid(maze_root):remove_child(maze_root);maze_root.queue_free()
	maze_root=Node3D.new();maze_root.name="Labirinto";add_child(maze_root)
	walls.clear();pickup_nodes.clear()
	var stage:Dictionary=Stages.INFO[sim.stage_id]
	var primary:=Color(stage.primary)
	var secondary:=Color(stage.secondary)
	stage_lights[0].light_color=primary;stage_lights[1].light_color=secondary
	floor_material.set_shader_parameter("line_color",primary)
	var wall_mesh=Models.bevel_box(Vector3(CELL,Architecture.HEIGHT,CELL),0.018)
	for y in sim.grid.size():
		for x in sim.grid[y].length():
			var cell:=Vector2i(x,y)
			if sim.floors.has(cell):continue
			walls[cell]=create_wall(cell,wall_mesh,primary,secondary)
	var closing=create_wall(sim.close_cell,wall_mesh,primary,secondary)
	closing.visible=false;walls[sim.close_cell]=closing
	Architecture.deck(maze_root,primary,secondary)
	Architecture.routes(maze_root,sim.floors,Rules.HOUSE,primary)
	build_ghost_house(primary,secondary)
	for row in sim.tunnel_rows():
		for x in [0,16]:build_tunnel(Vector2i(x,row),primary if row==5 else secondary)
	for c in sim.pickups:
		create_pickup(c,sim.pickups[c])
		pickup_nodes[c].visible=not sim.fusion.crates.has(c)

func create_wall(cell:Vector2i,_mesh:Mesh,primary:Color,secondary:Color) -> MeshInstance3D:
	# Inset exposed faces, keeping adjacent wall cells joined. This gives the
	# narrow architectural walls of the concepts instead of a board of cubes.
	var left:float=-0.39 if sim.floors.has(cell+Vector2i.LEFT) else -CELL*0.5
	var right:float=0.39 if sim.floors.has(cell+Vector2i.RIGHT) else CELL*0.5
	var back:float=-0.39 if sim.floors.has(cell+Vector2i.UP) else -CELL*0.5
	var front:float=0.39 if sim.floors.has(cell+Vector2i.DOWN) else CELL*0.5
	var footprint:=Rect2(left,back,right-left,front-back)
	var body:=BoxMesh.new();body.size=Vector3(footprint.size.x,Architecture.HEIGHT,footprint.size.y)
	var mat:=Models.material(Color("1d2035"),0.01,0.28);mat.roughness=0.58;mat.metallic_specular=0.22
	var wall=Models.mesh_node(body,mat,coord(Vector2(cell),Architecture.HEIGHT*0.5)+Vector3(footprint.get_center().x,0,footprint.get_center().y))
	maze_root.add_child(wall)
	Architecture.decorate(wall,cell,sim.floors,primary,secondary,footprint)
	return wall

func build_ghost_house(primary:Color,secondary:Color) -> void:
	var house:=Node3D.new();house.name="CasaRegeneracao";maze_root.add_child(house)
	var plate:=BoxMesh.new();plate.size=Vector3(CELL*2.95,0.035,CELL*1.95)
	house.add_child(Models.mesh_node(plate,Models.material(Color("162c45"),0.12,0.4),coord(Vector2(8,5.5),0.025)))
	for x in [6.55,9.45]:
		var rail:=BoxMesh.new();rail.size=Vector3(0.035,0.04,CELL*1.95)
		house.add_child(Models.mesh_node(rail,Models.material(secondary,0.6),coord(Vector2(x,5.5),0.12)))
	for y in [4.55,6.45]:
		var rail:=BoxMesh.new();rail.size=Vector3(CELL*2.9,0.04,0.035)
		house.add_child(Models.mesh_node(rail,Models.material(secondary,0.6),coord(Vector2(8,y),0.12)))
	for x in [6.62,9.38]:
		for y in [4.62,6.38]:
			Architecture.box(house,Vector3(0.14,1.42,0.14),coord(Vector2(x,y),0.71),Color("414360"),0,0.6)
			Architecture.box(house,Vector3(0.06,0.95,0.06),coord(Vector2(x,y),0.82),secondary,0.8)
	var halo:=TorusMesh.new();halo.inner_radius=0.69;halo.outer_radius=0.73
	house.add_child(Models.mesh_node(halo,Models.material(secondary,0.55),coord(Vector2(8,5.5),0.08)))
	Architecture.glow(house,Vector2(3.7,2.5),coord(Vector2(8,5.5),0.06),secondary,0.14)
	var gate:=BoxMesh.new();gate.size=Vector3(CELL*0.9,0.07,0.08)
	house_gate=Models.mesh_node(gate,Models.material(Color("f3b0e8"),0.75),coord(Vector2(Rules.DOOR),0.40));house_gate.name="Porta";house.add_child(house_gate)

func build_tunnel(cell:Vector2i,color:Color) -> void:
	var portal:=Node3D.new();portal.name="Tunel_%d_%d"%[cell.x,cell.y];portal.position=coord(Vector2(cell));maze_root.add_child(portal)
	var post:=BoxMesh.new();post.size=Vector3(0.07,0.88,0.07)
	for side in [-1,1]:portal.add_child(Models.mesh_node(post,Models.material(color,0.8),Vector3(0,0.44,side*CELL*0.46)))
	var beam:=BoxMesh.new();beam.size=Vector3(0.07,0.07,CELL*0.97)
	portal.add_child(Models.mesh_node(beam,Models.material(color,0.8),Vector3(0,0.9,0)))
	var arrow:=Label3D.new();arrow.text="‹" if cell.x==0 else "›";arrow.font=load("res://assets/DejaVuSans.ttf");arrow.font_size=64;arrow.pixel_size=0.007
	arrow.billboard=BaseMaterial3D.BILLBOARD_ENABLED;arrow.position=Vector3(0,0.48,0);arrow.modulate=color;portal.add_child(arrow)

func create_pickup(cell:Vector2i,kind:String) -> void:
	var root:=Node3D.new();root.position=coord(Vector2(cell));root.name="Item_%s_%s"%[cell.x,cell.y]
	if kind=="fruit":
		for side in [-1.0,1.0]:root.add_child(Models.mesh_node(Models.sphere(0.16),Models.material(Color("ff487c"),0.2,0.3),Vector3(side*0.13,0.38,0)))
		var stem:=CylinderMesh.new();stem.top_radius=0.025;stem.bottom_radius=0.025;stem.height=0.35
		var stalk=Models.mesh_node(stem,Models.material(Color("64ecac"),0.4),Vector3(0,0.65,0));stalk.rotation.z=-0.5;root.add_child(stalk)
	else:
		root.add_child(Models.mesh_node(Models.sphere(0.20 if kind=="power" else 0.075),Models.material(Color("ffd15a"),1.3 if kind=="power" else 0.32,0.3),Vector3(0,0.28,0)))
		if kind=="power":
			var ring:=TorusMesh.new();ring.inner_radius=0.27;ring.outer_radius=0.30
			root.add_child(Models.mesh_node(ring,Models.material(Color("57e4f6"),1.4),Vector3(0,0.1,0)))
	maze_root.add_child(root);pickup_nodes[cell]=root

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey and event.echo:return
	if event.is_action_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if event.is_action_pressed("toggle_camera"):
		settings.camera_top=not settings.camera_top;apply_settings();return
	if event.is_action_pressed("pause_game"):
		if current_screen=="playing":pause_game()
		elif current_screen in ["pause","map"]:resume_game()
		else:show_title()
		return
	if event.is_action_pressed("toggle_map"):
		if current_screen in ["playing","pause"]:show_map()
		elif current_screen=="map":resume_game()
		return
	if current_screen!="playing":
		if event.is_action_pressed("confirm_game") and current_screen=="title":start_game()
		elif event.is_action_pressed("confirm_game") and current_screen=="results":retry_run()
		return
	var bindings={"p1_right":Vector2i.RIGHT,"p1_down":Vector2i.DOWN,"p1_left":Vector2i.LEFT,"p1_up":Vector2i.UP}
	for action in bindings:
		if event.is_action_pressed(action):
			key_stack.erase(action);key_stack.append(action);sim.request_direction(bindings[action])
		if event.is_action_released(action) and not Input.is_action_pressed(action):
			key_stack.erase(action)
			sim.held_dir=bindings[key_stack.back()] if not key_stack.is_empty() else Vector2i.ZERO
	if event.is_action_pressed("p1_dash"):sim.request_dash()
	if event.is_action_pressed("risk_wager"):sim.request_risk()
	if event.is_action_pressed("shield"):sim.request_shield()
	if event.is_action_pressed("magnet"):sim.request_magnet()
	if event.is_action_pressed("boss_pulse"):sim.request_boss_pulse()
	if event.is_action_pressed("bomb"):sim.request_bomb()

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
	# The opening is safe: the phase clock and house release wait for direction.
	if sim.time==0.0 and (sim.mode=="circuit" or sim.run_elapsed==0) and sim.player.dir==Vector2i.ZERO and sim.held_dir==Vector2i.ZERO and not sim.pickups.is_empty() and sim.fusion.bombs.is_empty():return
	sim.tick(dt)
	for event in sim.events:
		observed_events[event.type]=observed_events.get(event.type,0)+1
		feedback.react(event,sim,settings.reduced)
		if event.type in ["dash","shield_armed","magnet"]:session_metrics.abilities[event.type]=int(session_metrics.abilities.get(event.type,0))+1
		if event.type=="death":
			var cell:String=str(Vector2i(event.pos.round()));session_metrics.death_cells[cell]=int(session_metrics.death_cells.get(cell,0))+1
		match event.type:
			"dash":
				play_sound("dash");burst(coord(event.pos,0.4),Color("ffd568"),10)
				if not settings.reduced:hero.react("dash")
			"pellet":play_sound("pellet")
			"power":burst(coord(event.pos,0.6),Color("72dcff"),22);play_sound("power");notify("AGORA VOCÊ CAÇA  •  Q PARA APOSTAR")
			"capture":
				burst(coord(event.pos,0.7),Color("58dfff"),12+mini(event.chain,4)*3)
				play_sound("capture",1.0+(mini(event.chain,4)-1)*0.08,-17);play_sound("capture_%d"%mini(event.chain,4),1,-17)
				if not settings.reduced:hero.react("capture")
				notify(("CAÇADA PERFEITA!" if event.chain==4 else "CADEIA %d"%event.chain)+"  •  +%d  •  FLOW ×%.1f"%[event.points,sim.flow])
			"bonus_spawn":play_sound("bonus_spawn",1,-18);notify("FRUTA MÓVEL!  •  BÔNUS OPCIONAL")
			"bonus_caught":
				burst(coord(event.pos,0.5),Color("ffe188"),18);play_sound("bonus_caught",1,-15)
				if not settings.reduced:hero.react("bonus_caught")
				notify("BÔNUS +%d  •  +15 ENERGIA"%event.points)
			"bonus_expired":notify("A FRUTA ESCAPOU  •  CONTINUE A LIMPEZA")
			"bomb_placed":play_sound("bomb_place",1,-18)
			"bomb_exploded":
				play_sound("bomb_explode",1.1 if event.chain else 1,-16);burst(coord(event.pos,0.3),Color("ffbf73"),8)
			"cache_open":burst(coord(event.pos,0.4),Color("ffd28a"),10)
			"bomb_upgrade":
				play_sound("bonus_caught",1.1,-17);notify({"capacity":"CAPACIDADE +1", "range":"ALCANCE +1", "shield":"CARGA DE ESCUDO +1", "energy":"ENERGIA COMPLETA"}.get(event.kind,"MELHORIA")+"  •  +100")
			"ghost_stunned":burst(coord(event.pos,0.8),Color("bca6ff"),5)
			"train_spawn":play_sound("pressure",1,-18);notify("TREM FANTASMA  •  %d SEGUIDORES"%event.count)
			"overdrive_pulse":notify("OVERDRIVE  •  3s PARA CAÇAR")
			"boss_intro":
				for c in sim.pickups:
					if not pickup_nodes.has(c):create_pickup(c,sim.pickups[c])
				notify("COLOSSO: COLETE NÚCLEOS. F / RB QUANDO VULNERÁVEL")
			"boss_warning":notify("COLOSSO: SAIA DA ROTA VERMELHA")
			"boss_recover":notify("COLOSSO VULNERÁVEL  •  F / RB: PULSO")
			"boss_hit":play_sound("risk_success",1,-15);notify("NÚCLEO ATINGIDO  •  %d RESTANTES"%event.hp)
			"fruit":burst(coord(event.pos,0.6),Color("ff86bb"),16);play_sound("fruit")
			"drift":
				burst(coord(event.pos,0.3),Color("ffe576"),5)
				if not settings.reduced:hero.react("drift")
			"wrap":
				if event.player:
					first_frame=true
					for entry in trail:entry.node.queue_free()
					trail.clear();ribbon.visible=false
			"warning":notify("RECONFIGURANDO ROTAS • AGUARDE A LUZ")
			"topology":burst(coord(event.pos,0.6),Color("75efff"),25);notify("NOVA ROTA ABERTA")
			"topology_cancel":notify("ROTA PRESERVADA • PASSAGEM OCUPADA")
			"death":burst(coord(event.pos,0.65),Color("ffd36c"),25);play_sound("death");notify("VIDA PERDIDA • PREPARE-SE")
			"near_miss":play_sound("near_miss");notify("POR UM FIO  •  +6 DE ENERGIA")
			"pressure_warning":play_sound("pressure");notify("O RITMO VAI SUBIR  •  NÍVEL %d"%event.level)
			"pressure":play_sound("pressure",1.08)
			"power_warning":play_sound("power_warning");notify("POWER TERMINANDO  •  PREPARE A FUGA")
			"power_end":play_sound("power_end");notify("VOLTE A FUGIR  •  USE AS ROTAS")
			"risk_start":play_sound("risk_start");notify("APOSTA: 2 CAPTURAS NESTE POWER  •  +600")
			"risk_success":play_sound("risk_success");notify("APOSTA VENCIDA  •  +600  •  +35 ENERGIA")
			"risk_failed":notify("APOSTA ENCERRADA  •  TENTE NA PRÓXIMA PARTIDA")
			"shield_armed":play_sound("power",0.85);notify("ESCUDO ATIVO  •  8s / UM CONTATO")
			"shield_hit":play_sound("near_miss",0.8);notify("ESCUDO ABSORVEU O IMPACTO  •  SAIA DO CERCO")
			"magnet":play_sound("power",1.15);notify("ÍMÃ ATIVO  •  6s / PONTOS VIZINHOS")
	if sim.graph_version!=previous_graph:
		walls[sim.open_cell].visible=false;walls[sim.close_cell].visible=true;previous_graph=sim.graph_version
	for cell in pickup_nodes.keys():
		if not sim.pickups.has(cell):pickup_nodes[cell].queue_free();pickup_nodes.erase(cell)
		elif sim.mode=="fusion":pickup_nodes[cell].visible=not sim.fusion.crates.has(cell)
	if sim.status=="won" and sim.timed_mode():
		var direction:Vector2i=sim.held_dir if sim.held_dir!=Vector2i.ZERO else sim.player.dir
		var held:Array=key_stack.duplicate()
		start_game((sim.stage_id+1)%6,{"mode":sim.mode,"score":sim.score,"lives":mini(3,sim.lives+1),"run_elapsed":sim.run_time(),"pulse_index":sim.pulse_index,"train_next_at":sim.train.next_at,"continuing":true,"best_before":best_before_run})
		key_stack=held
		if direction!=Vector2i.ZERO:sim.request_direction(direction)
		return
	if sim.status in ["won","game_over","time_up"] and not terminal_reported:
		terminal_reported=true
		var record_key:String=sim.mode+"_record"
		settings[record_key]=maxi(settings[record_key],sim.score)
		if sim.mode=="circuit" and sim.status=="won":
			settings.unlocked=maxi(settings.unlocked,mini(5,sim.stage_id+1))
			settings.medals[sim.stage_id]=int(settings.medals[sim.stage_id]) | int(sim.stage_result().mask)
			settings.experts[sim.stage_id]=int(settings.experts[sim.stage_id]) | int(sim.stage_result().expert_mask)
		Store.write_settings(settings);show_results()

func _process(dt:float) -> void:
	if fusion_visual!=null:fusion_visual.update()
	elapsed+=dt;menu_clock+=dt
	if current_screen=="playing" and not sim.paused:feedback.update(dt,sim)
	var now_us:=Time.get_ticks_usec()
	if real_previous_us>0 and elapsed>2.0:frame_times.append((now_us-real_previous_us)/1000.0)
	real_previous_us=now_us
	if frame_times.size()>10000:frame_times.pop_front()
	var alpha:float=1.0 if sim.paused else Engine.get_physics_interpolation_fraction()
	var p:Vector2=sim.player.previous.lerp(sim.player.pos,alpha)
	hero.position=coord(p)
	power_field.position=coord(p,0.1)
	power_field.visible=sim.time<maxf(sim.shield_until,sim.grace_until) or sim.time<sim.magnet_until
	var magnetic:bool=sim.time<sim.magnet_until
	power_field.scale=Vector3.ONE*(2.0 if magnetic else 1.0)
	power_field_material.albedo_color=Color("8affb9") if magnetic else Color("64eaff")
	power_field_material.emission=power_field_material.albedo_color
	var visual_time:float=sim.time if current_screen!="title" else menu_clock
	var animation_dt:float=dt if current_screen=="title" or (current_screen=="playing" and not sim.paused) else 0
	hero.animate(visual_time,sim.player.dir,"",0.0,settings.reduced,animation_dt)
	if sim.player.dir==Vector2i.ZERO and sim.time==0:
		var facing:Vector3=camera.position-hero.position
		hero.rotation.y=-atan2(facing.z,facing.x)
	for i in ghosts.size():
		var g:Dictionary=sim.ghosts[i]
		ghosts[i].position=coord(g.previous.lerp(g.pos,alpha))
		ghosts[i].animate(visual_time+i,g.dir,"stunned" if sim.time<g.get("stunned_until",-1.0) and g.state!="vulnerable" else g.state,maxf(0,sim.power_until-sim.time),settings.reduced,animation_dt)
		# Expressive faces orient toward the camera; collision/direction stay planar.
		var facing:Vector3=camera.position-ghosts[i].position
		ghosts[i].rotation.y=-atan2(facing.z,facing.x)
	bonus_visual.visible=sim.bonus.active and sim.status=="playing"
	if bonus_visual.visible:bonus_visual.position=coord(sim.bonus.actor.previous.lerp(sim.bonus.actor.pos,alpha),0.10 if settings.reduced else 0.10+sin(visual_time*7)*0.07)
	for i in 8:
		train_visuals[i].visible=i<sim.train.followers.size() and sim.status=="playing"
		if not train_visuals[i].visible:continue
		var g:Dictionary=sim.train.followers[i]
		train_visuals[i].visible=g.state!="returning"
		train_visuals[i].position=coord(g.previous.lerp(g.pos,alpha));train_visuals[i].animate(visual_time+i,g.dir,g.state,maxf(0,sim.power_until-sim.time),settings.reduced,animation_dt)
		var facing:Vector3=camera.position-train_visuals[i].position;train_visuals[i].rotation.y=-atan2(facing.z,facing.x)
	boss_visual.visible=sim.boss.active
	if boss_visual.visible:
		boss_visual.position=coord(Vector2(8,5.5),0.45 if settings.reduced else 0.45+sin(visual_time*2)*0.1)
		var facing:Vector3=camera.position-boss_visual.position;boss_visual.rotation.y=-atan2(facing.z,facing.x)
		var mat:StandardMaterial3D=boss_visual.get_node("Body").material_override
		var tint:=Color("6eeeff") if sim.boss.phase=="recover" else Color("bd8cff")
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;mat.albedo_color=Color(tint,0.62);mat.emission=tint
	for i in hazard_visuals.size():
		hazard_visuals[i].visible=sim.boss.active and sim.boss.phase in ["warning","attack"] and i<sim.boss.cells.size()
		if hazard_visuals[i].visible:
			hazard_visuals[i].position=coord(Vector2(sim.boss.cells[i]),0.04)
			var mat:StandardMaterial3D=hazard_visuals[i].material_override
			mat.albedo_color.a=0.65 if sim.boss.phase=="attack" else 0.23
	# A close, oblique perspective is the main view. C provides the full maze.
	var target:=hero.position+Vector3(1.4,0.25,-0.6)
	if current_screen=="title":target=Vector3(0,0.25,0)
	if settings.camera_top:target=Vector3.ZERO
	var offset:=Vector3(0,27,0.01) if settings.camera_top else Vector3(-4.8,8.1,8.9)
	var motion:float=0.0 if settings.reduced else settings.camera_motion
	if first_frame:camera_anchor=target+offset;first_frame=false
	else:camera_anchor=camera_anchor.lerp(target+offset,1-exp(-dt*5))
	camera.position=camera_anchor+feedback.camera_offset(motion)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL if settings.camera_top else Camera3D.PROJECTION_PERSPECTIVE
	camera.fov=49.0
	camera.size=maxf(20.5,26.5/maxf(0.5,play_rect.size.x/play_rect.size.y))
	camera.look_at(camera_anchor-offset,Vector3(0,0,-1) if settings.camera_top else Vector3.UP)

	var hunting:bool=sim.time<sim.power_until
	floor_material.set_shader_parameter("hunt_mix",1.0 if hunting else 0.0)
	update_audio(dt,hunting)
	if is_instance_valid(house_gate):house_gate.visible=not sim.ghosts.any(func(g):return g.state in ["returning","leaving"])
	# Fade the foreground obstacle when it can occlude the player.
	for c in walls:
		var node:MeshInstance3D=walls[c]
		var near_player:bool=(-(c.x-p.x)*0.47+(c.y-p.y)*0.89)>0.1 and Vector2(c).distance_to(p)<1.6
		node.scale.y=lerpf(node.scale.y,0.40 if near_player and not settings.camera_top else 1.0,minf(1,dt*8))
		node.position.y=Architecture.HEIGHT*node.scale.y*0.5
	if not sim.topology.is_empty():
		var mat:StandardMaterial3D=walls[sim.open_cell].material_override
		mat.emission_enabled=true;mat.emission=Color("68e6f0");mat.emission_energy_multiplier=0.4 if settings.reduced else 0.6+sin(visual_time*8)*0.2
		walls[sim.close_cell].visible=true
		var preview_mat:StandardMaterial3D=walls[sim.close_cell].material_override
		preview_mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;preview_mat.albedo_color.a=0.25
	else:
		walls[sim.close_cell].visible=sim.graph_version>0
		var closing_mat:StandardMaterial3D=walls[sim.close_cell].material_override
		closing_mat.transparency=BaseMaterial3D.TRANSPARENCY_DISABLED;closing_mat.albedo_color.a=1.0
	for cell in pickup_nodes:
		if sim.pickups.get(cell)=="power":pickup_nodes[cell].scale=Vector3.ONE*(1.0+0.10*sin(visual_time*4))
	update_hud()
	update_trail(dt)
	Interface.layout(self)
	if demo and not screenshot_dir.is_empty():
		for mark in [2,7]:
			if sim.time>=mark and not screenshots_done.has(mark):screenshots_done[mark]=true;save_screenshot(mark)
	if smoke and elapsed>=3.0:
		var explosions:int=observed_events.get("bomb_exploded",0)
		if smoke_fusion and explosions<1:
			push_error("FUSION_SMOKE_FAILED: no detonation observed");get_tree().quit(1);return
		print("NEOGRID_SMOKE_OK ",JSON.stringify({"score":sim.score,"time":sim.time,"ghosts":ghosts.size(),"pickups":pickup_nodes.size(),"mode":sim.mode,"explosions":explosions}));get_tree().quit()

func demo_input() -> void:
	if sim.player.pos.x<0 or sim.player.pos.x>16:return
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
		if not sim.walkable(sim.neighbor(cell,d)):continue
		var dd:int=sim.path_distance(sim.neighbor(cell,d),demo_target)
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
	if toast_tween!=null and toast_tween.is_valid():toast_tween.kill()
	toast_tween=create_tween();toast_tween.tween_interval(1.4);toast_tween.tween_property(toast,"modulate:a",0.0,0.5)

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
		var trail_color:=Color("62ebee") if settings.trail_style==1 and total_medals()>=3 else Color("ffcb58")
		var orb=Models.mesh_node(Models.sphere(0.12 if hot else 0.055),Models.material(trail_color,1.8),hero.position+Vector3(0,0.26,0));add_child(orb)
		ribbon_material.albedo_color=trail_color;ribbon_material.emission=trail_color
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
	for i in 8:
		var voice:=AudioStreamPlayer.new();add_child(voice);voices.append(voice)
	sound=voices[0]
	music=AudioStreamPlayer.new();add_child(music)
	for n in ["pellet","power","capture","dash","death","fruit","near_miss","pressure","power_warning","power_end","risk_start","risk_success","capture_1","capture_2","capture_3","capture_4","bonus_spawn","bonus_caught","bomb_place","bomb_explode"]:sounds[n]=load("res://assets/audio/"+n+".wav")
	music.stream=load("res://assets/audio/pulse.wav")
	if music.stream is AudioStreamWAV:music.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;music.stream.loop_end=roundi(music.stream.get_length()*music.stream.mix_rate)
	music.volume_db=-15;music.play()
	tension_music=AudioStreamPlayer.new();hunt_music=AudioStreamPlayer.new()
	for pair in [[tension_music,"tension_layer"],[hunt_music,"hunt_layer"]]:
		add_child(pair[0]);pair[0].stream=load("res://assets/audio/"+pair[1]+".wav")
		pair[0].stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
		pair[0].stream.loop_end=roundi(pair[0].stream.get_length()*pair[0].stream.mix_rate)
		pair[0].volume_db=-60;pair[0].play()

func play_sound(kind:String,pitch:float=1.0,gain_db:float=-12.0) -> void:
	if not sounds.has(kind):return
	var voice:AudioStreamPlayer=voices[voice_index%voices.size()];voice_index+=1
	voice.stop();voice.stream=sounds[kind];voice.pitch_scale=pitch
	voice.volume_db=-24 if kind=="pellet" else gain_db;voice.play()

func update_audio(dt:float,hunting:bool) -> void:
	var active:bool=current_screen=="playing"
	var danger:float=feedback.threat
	var gain:float=0.14+sim.pressure_level*0.14+danger*0.25 if active and not hunting else 0.001
	var hunt_gain:float=minf(0.95,0.48+(sim.flow-1)*0.20) if active and hunting else 0.001
	tension_music.volume_db=lerpf(tension_music.volume_db,linear_to_db(maxf(0.001,gain))-16.0,1-exp(-dt*6))
	hunt_music.volume_db=lerpf(hunt_music.volume_db,linear_to_db(maxf(0.001,hunt_gain))-14.0,1-exp(-dt*9))
	music.volume_db=lerpf(music.volume_db,-17.0-feedback.chain_heat*2.0-feedback.power_heat*3.0,1-exp(-dt*10))

func pause_music(paused:bool) -> void:
	for track in [music,tension_music,hunt_music]:track.stream_paused=paused

func apply_settings() -> void:
	AudioServer.set_bus_mute(0,settings.mute)
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(0.001,settings.volume)))
	var env:Environment=world_environment.environment
	env.glow_enabled=not settings.reduced
	env.glow_intensity=0.16 if settings.reduced else 0.55
	env.ssr_enabled=settings.quality>0
	env.ssao_enabled=settings.quality>0
	env.ssr_max_steps=32 if settings.quality==2 else 16
	game_view.positional_shadow_atlas_size=2048 if settings.quality==2 else 1024
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
	Interface.build(self)

func clear_menu(title:String,subtitle:String="") -> void:
	if reveal_tween!=null and reveal_tween.is_valid():reveal_tween.kill()
	menu.modulate=Color.WHITE;menu.scale=Vector2.ONE
	map_overlay.visible=false
	for c in menu_content.get_children():menu_content.remove_child(c);c.queue_free()
	menu.visible=true
	menu_scrim.visible=true;menu_scroll.scroll_vertical=0
	menu_content.add_child(label(title,35,Color("ffdb76")))
	if not subtitle.is_empty():menu_content.add_child(label(subtitle,13,Color("8fc5d5")))
	Interface.layout(self)

func show_title() -> void:
	current_screen="title";sim.paused=true;hud.visible=false
	clear_menu("NEO—GRID","MS. PAC-MAN  /  UMA NOVA ÓRBITA ARCADE")
	menu_content.add_child(label("Corra entre luzes. Transforme a caçada.",13))
	menu_content.add_child(button("NOVO · Fusão — Bomber Chase",func():start_mode("fusion")))
	menu_content.add_child(button("Jogar Circuito Neon · 6 fases",start_game))
	menu_content.add_child(button("Overdrive · 3 minutos",func():start_mode("overdrive")))
	menu_content.add_child(button("Trem Fantasma · 3 minutos",func():start_mode("train")))
	menu_content.add_child(button("Fases, medalhas e extras",show_campaign))
	menu_content.add_child(button("Como jogar",show_help))
	menu_content.add_child(button("Configurações",show_settings))
	menu_content.add_child(button("Melhor pontuação · %06d"%settings.circuit_record,show_records))
	menu_content.add_child(button("Sair",func():get_tree().quit()))
	menu_content.add_child(label("MV 0.9  •  FUSÃO / BOMBER CHASE",10,Color("7787a2")))

func start_game(level:int=0, carry:Dictionary={}) -> void:
	key_stack.clear();first_frame=true
	level=clampi(level,0,5)
	if not carry.get("continuing",false):
		session_metrics.attempts+=1
		best_before_run=int(settings[str(carry.get("mode","circuit"))+"_record"])
	else:best_before_run=int(carry.get("best_before",best_before_run))
	map_overlay.visible=false
	sim.reset(level,true,carry);sim.start();sim.paused=false;current_screen="playing";hud.visible=true;menu.visible=false;terminal_reported=false;previous_graph=0;music.stream_paused=false
	menu_scrim.visible=false;Interface.layout(self)
	feedback.reset();hero.reset_expression()
	for ghost in ghosts:ghost.reset_expression()
	bonus_visual.visible=false
	observed_events.clear();first_frame=true
	for track in [music,tension_music,hunt_music]:track.stop();track.stream_paused=false;track.play(0.0)
	rebuild_maze();fusion_visual.reset(self)
	for entry in trail:entry.node.queue_free()
	trail.clear();ribbon.visible=false
	key_stack.clear();last_trail=0
	notify("SETAS / WASD PARA COMEÇAR  •  C: VER TODO O MAPA")

func start_mode(mode:String) -> void:start_game(0,{"mode":mode})
func retry_run() -> void:
	session_metrics.retries+=1;start_mode(sim.mode)
func next_stage(choice:String="") -> void:
	if sim.status!="won" or sim.stage_id>=5:return
	var carry:Dictionary={"mode":sim.mode,"score":sim.score,"lives":mini(3,sim.lives+1),"upgrade":choice,"continuing":true,"best_before":best_before_run}
	if sim.mode=="fusion":carry.merge(sim.fusion.carry())
	start_game(sim.stage_id+1,carry)
func show_upgrade_choice() -> void:
	current_screen="upgrade";clear_menu("PREPARE A PRÓXIMA ROTA","Escolha uma melhoria válida apenas na próxima fase.")
	for item in [["shield","Escudo reativo · 11 segundos"],["magnet","Ímã ampliado · 9s / até 2 células conectadas"],["dash","Dash econômico · custa 30 de energia"]]:
		var key:String=item[0];menu_content.add_child(button(item[1],func():next_stage(key)))
	menu_content.add_child(button("Seguir com poderes padrão",func():next_stage()))

func total_medals() -> int:
	var count:=0
	for mask in settings.medals:count+=Stages.medal_count(int(mask))
	return count

func show_campaign() -> void:
	current_screen="campaign";sim.paused=true;hud.visible=false;pause_music(true)
	clear_menu("CIRCUITO NEON","%d / 18 medalhas  ·  extras por habilidade"%total_medals())
	for i in 6:
		var unlocked:bool=i<=settings.unlocked
		var stars:int=Stages.medal_count(int(settings.medals[i]))
		var entry=button("%d · %s  %s"%[i+1,Stages.INFO[i].name,"★".repeat(stars)+"☆".repeat(3-stars) if unlocked else "BLOQUEADA"],func():start_game(i))
		entry.disabled=not unlocked;menu_content.add_child(entry)
		menu_content.add_child(label("Extras: "+" • ".join(expert_names(int(settings.experts[i]))),11,Color("adbedb")))
	menu_content.add_child(label("Cada fase: concluir + desafio + tempo.\nExtras: sem dash, sem mortes e cadeia de 4.\nExtras conquistados: %d / 18"%expert_medals()+"",13,Color("9fc5d3")))
	var cosmetic=button("Rastro: %s"%("Turquesa" if settings.trail_style==1 else "Dourado"),func():settings.trail_style=1-settings.trail_style;Store.write_settings(settings);show_campaign())
	cosmetic.disabled=total_medals()<3;menu_content.add_child(cosmetic)
	menu_content.add_child(label("Rastro turquesa: obtenha 3 medalhas.\nÍmã: disponível a partir da fase 2.",12,Color("9fc5d3")))
	menu_content.add_child(button("Voltar",show_title))

func pause_game() -> void:
	current_screen="pause";sim.paused=true;key_stack.clear();sim.held_dir=Vector2i.ZERO;sim.buffer_dir=Vector2i.ZERO;pause_music(true)
	clear_menu("PAUSA","Seu tempo está preservado.")
	menu_content.add_child(button("Continuar",resume_game));menu_content.add_child(button("Mapa da área · M",show_map));menu_content.add_child(button("Reiniciar este modo",retry_run));menu_content.add_child(button("Configurações",show_settings));menu_content.add_child(button("Voltar à abertura",show_title));menu_content.add_child(button("Sair",show_quit_confirm))

func show_map() -> void:
	pause_game()
	current_screen="map";menu.visible=false;map_overlay.visible=true
	update_hud()

func resume_game() -> void:
	map_overlay.visible=false
	current_screen="playing";sim.paused=false;menu.visible=false;hud.visible=true;pause_music(false)
	menu_scrim.visible=false;Interface.layout(self)

func show_help() -> void:
	current_screen="help";sim.paused=true;clear_menu("COMO JOGAR")
	for text in ["WASD / setas  ·  mover e antecipar curvas","Espaço  ·  dash, custo de 40 de energia","C  ·  vista oblíqua / superior   ·   F11  ·  tela cheia","P / Esc  ·  pausa   ·   Enter  ·  iniciar","Colete a esfera de luz para capturar fantasmas.","Capturas ativam Flow. Frutas abrem novas rotas.","Limpe a fase para avançar; +1 vida até o limite de 3."]:
		menu_content.add_child(label(text,13))
	menu_content.add_child(label("Q durante Power · aposte 20E em 2 capturas: +600 / +35E.",13))
	menu_content.add_child(label("Uma aposta por fase. Não altera vidas nem colisões.",13))
	menu_content.add_child(label("Ritmo sobe após aviso. Quase colisão só conta ao escapar.",13))
	menu_content.add_child(label("M · mapa ampliado com pausa. O HUD mostra todos os itens restantes.",13))
	menu_content.add_child(label("Túneis laterais ligam bordas opostas. A casa central regenera os fantasmas.",13))
	menu_content.add_child(label("E · escudo de um impacto / 8s. R · ímã de pontos / 6s (fase 2+).",13))
	menu_content.add_child(label("Uma carga por poder por fase. Morrer encerra os efeitos; não recarrega.",13))
	menu_content.add_child(label("Fantasmas que voltaram à cor original já são perigosos.",13))
	menu_content.add_child(label("Fruta dourada móvel: bônus opcional. Não entra no contador.",13))
	menu_content.add_child(label("Colosso: colete 3 núcleos e use F / RB na recuperação.",13))
	menu_content.add_child(label("FUSÃO: B / botão B planta bomba. Pavio 2,3s; cruz bloqueada por paredes e caches; explosões encadeiam bombas.",13))
	menu_content.add_child(label("Caches âmbar guardam pontos obrigatórios e melhorias: +B capacidade, +R alcance, E escudo. A explosão também atinge você, mesmo durante Power. E absorve um impacto.",13))
	menu_content.add_child(label("Sem Power, bombas atordoam fantasmas por 1,8s. Com Power, capturam. Saia da marcação laranja antes da explosão; M pausa para planejar.",13))
	menu_content.add_child(label("Controle: direcional/analógico; X dash; A escudo; Y ímã; LB aposta; RB pulso; Start pausa.",13))
	menu_content.add_child(button("Voltar",show_title))

func show_settings() -> void:
	current_screen="settings";sim.paused=true;clear_menu("CONFIGURAÇÕES")
	var quality:=OptionButton.new();for text in ["Baixa","Média","Alta"]:quality.add_item(text)
	quality.selected=settings.quality;quality.item_selected.connect(func(i):settings.quality=i;apply_settings());menu_content.add_child(quality)
	var volume:=HSlider.new();volume.min_value=0;volume.max_value=1;volume.step=0.05;volume.value=settings.volume;volume.custom_minimum_size=Vector2(320,28)
	menu_content.add_child(label("Volume",14));menu_content.add_child(volume);volume.value_changed.connect(func(v):settings.volume=v;apply_settings())
	var motion:=HSlider.new();motion.min_value=0;motion.max_value=1;motion.step=0.05;motion.value=settings.camera_motion
	motion.custom_minimum_size=Vector2(320,28);menu_content.add_child(label("Intensidade da câmera  ·  0 desativa impulsos",13));menu_content.add_child(motion)
	motion.value_changed.connect(func(v):settings.camera_motion=v;apply_settings())
	for pair in [["mute","Silenciar"],["reduced","Reduzir efeitos e movimento"],["camera_top","Câmera superior 3D"]]:
		var check:=CheckButton.new();check.text=pair[1];check.button_pressed=settings[pair[0]];check.toggled.connect(func(v):settings[pair[0]]=v;apply_settings());menu_content.add_child(check)
	menu_content.add_child(button("Voltar",func():pause_game() if hud.visible else show_title()))

func expert_medals() -> int:
	var count:=0
	for mask in settings.experts:count+=Stages.medal_count(int(mask))
	return count
func show_records() -> void:
	current_screen="records";clear_menu("SEUS RECORDES","Uma classificação separada para cada modo")
	for item in [["Circuito",settings.circuit_record],["Overdrive",settings.overdrive_record],["Trem Fantasma",settings.train_record],["Fusão",settings.fusion_record]]:menu_content.add_child(label("%s · %06d"%[item[0],item[1]],22))
	menu_content.add_child(label("Circuito anterior de 3 fases: %06d"%settings.legacy_circuit_record,13))
	menu_content.add_child(button("Voltar",show_title))
func show_results() -> void:
	current_screen="results";sim.paused=true;hud.visible=false;pause_music(true)
	var won:bool=sim.status=="won"
	var title:String=("CIRCUITO CONCLUÍDO!" if sim.stage_id==5 else "FASE CONCLUÍDA!") if won else ("TEMPO ENCERRADO!" if sim.status=="time_up" else "FIM DE JOGO")
	clear_menu(title,"%06d pontos  •  Melhor %06d"%[sim.score,settings[sim.mode+"_record"]])
	if sim.timed_mode():
		var difference:int=sim.score-best_before_run
		menu_content.add_child(label("NOVO RECORDE! +%d"%difference if difference>0 else ("Recorde igualado" if difference==0 else "Faltaram %d pontos para seu recorde"%-difference),20,Color("8affb9")))
		menu_content.add_child(label("Tempo jogado: %.1fs / 180s"%sim.run_time(),14))
	if won and sim.mode in ["circuit","fusion"]:
		var result:Dictionary=sim.stage_result()
		menu_content.add_child(label("★".repeat(result.stars)+"☆".repeat(3-result.stars),32,Color("ffdb76")))
		menu_content.add_child(label("Frutas móveis: %d / 2  •  +%d pontos"%[sim.bonus.caught,sim.bonus.earned],13,Color("b8e9d2")))
		menu_content.add_child(label("Área limpa: +500\n%s: %s\nTempo %.1fs / alvo %.0fs: %s"%[("Reação em cadeia" if sim.mode=="fusion" else Stages.INFO[sim.stage_id].challenge),"+250" if result.challenge else "tente novamente",sim.time,Stages.INFO[sim.stage_id].par,"+250" if result.fast else "tente novamente"],14))
		menu_content.add_child(label("Extras desta fase: %s"%" • ".join(expert_names(result.expert_mask)),12,Color("b9c8ef")))
		if sim.stage_id<5:menu_content.add_child(button("Próxima fase · escolher melhoria",show_upgrade_choice))
	menu_content.add_child(button("Jogar novamente · Enter / A",retry_run));menu_content.add_child(button("Fases e extras",show_campaign));menu_content.add_child(button("Voltar à abertura",show_title))
	Interface.layout(self)
	if won and not settings.reduced:
		menu.pivot_offset=menu.size*0.5;menu.scale=Vector2.ONE*0.98;menu.modulate.a=0
		reveal_tween=create_tween().set_parallel(true);reveal_tween.tween_property(menu,"modulate:a",1.0,0.18)
		reveal_tween.tween_property(menu,"scale",Vector2.ONE,0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
func expert_names(mask:int) -> PackedStringArray:
	var names:=PackedStringArray()
	for i in 3:
		if mask & (1<<i):names.append(["sem dash","sem mortes","cadeia de 4"][i])
	if names.is_empty():names.append("tente novamente")
	return names

func show_quit_confirm() -> void:
	sim.paused=true;current_screen="quit";clear_menu("ENCERRAR PARTIDA?","A partida atual será encerrada.")
	menu_content.add_child(button("Continuar jogando",resume_game));menu_content.add_child(button("Sair",func():get_tree().quit()))

func update_hud() -> void:
	var progress:Dictionary=sim.pickup_progress()
	var remaining:int=progress.remaining
	if remaining==0:collection_label.text="ÁREA LIMPA"
	elif remaining==1:collection_label.text="ÚLTIMO ITEM"
	elif remaining<=10:collection_label.text="ÚLTIMOS %d ITENS"%remaining
	else:collection_label.text="FALTAM %d ITENS"%remaining
	collection_label.modulate=Color("ffdf92") if remaining>10 else Color("b8f2ff")
	collection_caption.text="COLETADOS %d / %d  ·  %d%%"%[progress.collected,progress.total,progress.percent]
	collection_detail.text="Pontos %d  •  Power %d  •  Frutas %d"%[progress.pellets,progress.powers,progress.fruits]
	collection_bar.max_value=maxi(1,progress.total);collection_bar.value=progress.collected
	overview_caption.text="%d itens restantes  ·  %d / %d coletados"%[remaining,progress.collected,progress.total]
	score_label.text="%06d"%sim.score
	life_label.text="● ".repeat(maxi(0,sim.lives))
	flow_label.text="FLOW ×%.1f"%sim.flow
	energy_bar.value=sim.energy;power_bar.value=maxf(0,sim.power_until-sim.time)
	var hunting:bool=sim.time<sim.power_until
	bonus_caption.visible=sim.bonus.active
	bonus_caption.text="FRUTA MÓVEL · %.1fs\nBônus opcional · +%d × Flow"%[maxf(0,sim.bonus.end_at-sim.time),300+100*sim.stage_id] if sim.bonus.active else ""
	phase_label.text="%d/6 · %s\n%s"%[sim.stage_id+1,Stages.INFO[sim.stage_id].name,"CAÇA / CADEIA %d"%sim.combo if hunting else "FUGA / RITMO %d"%sim.pressure_level]
	if sim.timed_mode():phase_label.text=("OVERDRIVE" if sim.mode=="overdrive" else "TREM FANTASMA")+" · %02d:%02d"%[int(ceilf(180-sim.run_time()))/60,int(ceilf(180-sim.run_time()))%60]+"\nFLOW ×%.1f"%sim.flow
	if sim.mode=="fusion":
		phase_label.text="FUSÃO · %d/6 · %s\n%s"%[sim.stage_id+1,Stages.INFO[sim.stage_id].name,"BOMBAS DE CAÇA" if hunting else "ABRA ROTAS / PREPARE A CAÇA"]
	if sim.boss.active:
		collection_label.text="COLOSSO · %d / 3"%sim.boss.hp
		collection_caption.text="%d cargas · F / RB"%sim.boss.charges
		collection_bar.max_value=3;collection_bar.value=3-sim.boss.hp
		collection_detail.text={"warning":"AVISO: saia da rota vermelha","attack":"VARREDURA ATIVA","recover":"VULNERÁVEL: use seu pulso"}.get(sim.boss.phase,"")
	var stage:Dictionary=Stages.INFO[sim.stage_id]
	var challenge_status:String="Cumprido" if sim.challenge_met() else "Em andamento"
	if sim.stage_id==0 and not sim.challenge_met():challenge_status="%d / 2 capturas"%sim.stage_captures
	if sim.stage_id==1:challenge_status="Sem perdas até agora" if sim.stage_deaths==0 else "Tente na próxima partida"
	if sim.stage_id==2 and sim.risk.state=="failed":challenge_status="Tente na próxima partida"
	mission_label.text="%s\n%s\n%.0fs / alvo %.0fs"%[stage.challenge,challenge_status,sim.time,stage.par]
	var shield_text:String="ATIVO %.1fs"%maxf(0,sim.shield_until-sim.time) if sim.time<sim.shield_until else ("PRONTO" if sim.shield_charges>0 else "SEM CARGA")
	if sim.time<sim.grace_until:shield_text="PROTEÇÃO"
	var magnet_text:String="ATIVO %.1fs"%maxf(0,sim.magnet_until-sim.time) if sim.time<sim.magnet_until else ("PRONTO" if sim.magnet_charges>0 else "SEM CARGA")
	if sim.stage_id==0:magnet_text="LIBERA NA FASE 2"
	ability_label.text="E · ESCUDO: %s\nR · ÍMÃ: %s"%[shield_text,magnet_text]
	if sim.mode=="fusion":
		ability_label.text+="\nB / B PAD · BOMBAS %d / %d\nALCANCE %d · PAVIO 2,3s"%[sim.fusion.capacity-sim.fusion.bombs.size(),sim.fusion.capacity,sim.fusion.radius]
		mission_label.text="CACHES ABERTOS %d / %d\nReações em cadeia: %d\nPontos nos caches contam na limpeza."%[sim.fusion.broken,sim.fusion.total_crates,sim.fusion.chained]
	phase_label.modulate=Color("76e9ff") if hunting else Color("ffcb79").lerp(Color("ff7c88"),feedback.threat*0.6)
	power_caption.text="CAÇA  •  %.1fs"%maxf(0,sim.power_until-sim.time) if hunting else "POWER PELLET  /  BUSQUE A LUZ"
	match sim.risk.state:
		"available":risk_label.text="Q · apostar 20E: 2 capturas\n+600 pontos / +35 energia" if hunting else "Q · aposta liberada durante Power"
		"active":risk_label.text="APOSTA %d / 2 · %.1fs"%[sim.risk.progress,maxf(0,sim.risk.deadline-sim.time)]
		"success":risk_label.text="APOSTA VENCIDA\n+600 pontos  /  +35 energia"
		"failed":risk_label.text="APOSTA ENCERRADA"
	minimap.queue_redraw()
	if map_overlay.visible:overview_map.queue_redraw()

func _exit_tree() -> void:
	if is_instance_valid(sound):sound.stop();sound.stream=null
	if is_instance_valid(music):music.stop();music.stream=null
	for voice in voices:voice.stop();voice.stream=null
	for track in [tension_music,hunt_music]:
		if is_instance_valid(track):track.stop();track.stream=null
	sounds.clear()
	OS.delay_msec(100)
	if not report_path.is_empty():
		frame_times.sort()
		var metrics:Dictionary={"runtime":runtime_info,"frames_after_warmup":frame_times.size(),"recorded_events":observed_events,"score":sim.score,"lives":sim.lives,"simulation_seconds":sim.time,"pressure_level":sim.pressure_level,"risk":sim.risk,"preset":settings.quality,"resolution":get_viewport().get_visible_rect().size,"wall_clock_frame_times_ms":true,"gpu_time_ms":null,"local_session_metrics":session_metrics,"mode":sim.mode,"run_seconds":sim.run_time(),"controller_ids":Input.get_connected_joypads(),"note":"Wall-clock observations on the reported adapter, not GPU timestamps."}
		if not frame_times.is_empty():
			metrics.p95_ms=frame_times[mini(frame_times.size()-1,int(frame_times.size()*0.95))]
			metrics.p99_ms=frame_times[mini(frame_times.size()-1,int(frame_times.size()*0.99))]
		var file=FileAccess.open(report_path,FileAccess.WRITE)
		if file!=null:file.store_string(JSON.stringify(metrics,"\t"));file.close()

