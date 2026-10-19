extends SceneTree
const Rules=preload("res://scripts/rules.gd")
const Scene=preload("res://scenes/main.tscn")
const Interface=preload("res://scripts/interface.gd")
var results:Array=[]
var failed:=0
func _initialize() -> void:call_deferred("run")
func check(id:String,ok:bool) -> void:
	results.append({"id":id,"passed":ok})
	if not ok:failed+=1
	print("PASS " if ok else "FAIL ",id)
func quiet():
	var r=Rules.new();r.reset(0,true);r.start()
	for g in r.ghosts:g.release=100000.0
	return r
func run() -> void:
	var r=quiet()
	check("TUNNEL-graph-pairs",r.neighbor(Vector2i(0,5),Vector2i.LEFT)==Vector2i(16,5) and r.neighbor(Vector2i(16,9),Vector2i.RIGHT)==Vector2i(0,9))
	check("TUNNEL-shortest-path",r.path_distance(Vector2i(0,9),Vector2i(16,9))==1)
	for side in [0,16]:
		r=quiet();r.player.pos=Vector2(side,9);r.player.dir=Vector2i.LEFT if side==0 else Vector2i.RIGHT
		var paths:Array=r.advance(r.player,1.2,true)
		check("TUNNEL-direction-%d"%side,absf(r.player.pos.x-(15.8 if side==0 else 0.2))<0.0001 and r.player.pos.y==9)
		check("TUNNEL-no-middle-sweep-%d"%side,paths.all(func(p):return p.a.distance_to(p.b)<1.21) and Rules.path_contact(paths,[{"a":Vector2(8,9),"b":Vector2(8,9),"t0":0.0,"t1":1.0}],0.6)>1.0)
		check("TUNNEL-interpolation-reset-%d"%side,r.player.previous.distance_to(r.player.pos)<0.21)
	r=quiet();r.player.pos=Vector2(0,9);r.player.dir=Vector2i.LEFT
	check("TUNNEL-dash-allowed",r.request_dash())
	for i in 18:r.tick()
	check("TUNNEL-dash-keeps-distance",absf(r.player.pos.x-15.0)<0.001 and r.lives==3)
	r=quiet();r.player.pos=Vector2(0,9);r.player.dir=Vector2i.LEFT;r.request_dash();r.tuning.ghost_speed=0
	r.ghosts[0].pos=Vector2(16,9);r.ghosts[0].previous=r.ghosts[0].pos;r.ghosts[0].state="chase"
	for i in 18:r.tick()
	check("TUNNEL-arrival-is-not-invulnerable",r.lives==2)
	r=quiet();r.player.pos=Vector2(1,1);r.player.dir=Vector2i.LEFT;r.advance(r.player,2.0,true)
	check("TUNNEL-other-borders-closed",r.player.pos==Vector2(1,1))
	r=quiet();var g:Dictionary=r.ghosts[0];g.state="chase";g.pos=Vector2(0,5);g.dir=Vector2i.LEFT;r.player.pos=Vector2(16,5)
	r.advance(g,1.0,false)
	check("TUNNEL-ghosts-use-link",g.pos==Vector2(16,5))
	r=quiet();r.player.pos=Vector2(Rules.EXIT);r.player.dir=Vector2i.DOWN;r.held_dir=Vector2i.DOWN;r.advance(r.player,3.0,true)
	check("HOUSE-player-cannot-enter",r.player.pos==Vector2(Rules.EXIT) and not r.walkable(Rules.DOOR))
	check("HOUSE-no-required-items-inside",Rules.HOUSE.all(func(c):return not r.pickups.has(c)) and not r.pickups.has(Rules.DOOR))
	check("HOUSE-route-access-by-state",r.path_distance(Rules.EXIT,Rules.HOME[0],true)<10000 and r.walkable(Rules.DOOR,true))
	r=quiet();r.player.dir=Vector2i.ZERO;r.ghosts[0].release=0
	for i in 220:r.tick()
	check("HOUSE-ghost-exits-through-door",r.ghosts[0].state in ["chase","scatter"] and r.ghosts[0].pos.y<=3.01)
	r=quiet();r.player.dir=Vector2i.ZERO;g=r.ghosts[0];g.state="vulnerable";g.pos=Vector2(Rules.EXIT);g.previous=g.pos;r.capture(g,r.time)
	for i in 90:r.tick()
	check("HOUSE-return-and-regeneration",g.state=="house" and g.pos==Vector2(g.home) and g.release>r.time)
	for i in 360:r.tick()
	check("HOUSE-regenerated-ghost-exits",g.state in ["chase","scatter"] and g.immune==r.window_id)
	for dimensions in [Vector2(960,720),Vector2(1280,720),Vector2(1920,1080),Vector2(2560,1080)]:
		var z:Dictionary=Interface.zones(dimensions)
		check("HUD-safe-zones-%dx%d"%[dimensions.x,dimensions.y],not z.play.intersects(z.header) and not z.play.intersects(z.sidebar) and not z.play.intersects(z.footer) and Rect2(Vector2.ZERO,dimensions).encloses(z.play))
	var game=Scene.instantiate();root.add_child(game);current_scene=game
	await process_frame;await process_frame
	game.start_game();game.sim.paused=true
	await process_frame;await process_frame
	check("HUD-camera-in-dedicated-viewport",game.camera.get_viewport()==game.game_view and game.game_view.world_3d==game.get_world_3d() and game.sidebar.is_visible_in_tree() and game.sidebar.size.x==224 and game.sidebar.find_children("*","Button",true,false).all(func(b):return b.focus_mode==Control.FOCUS_NONE))
	for dimensions in [Vector2(960,720),Vector2(1280,720),Vector2(1920,1080)]:
		game.screen_root.size=dimensions;Interface.layout(game);game._process(0)
		await process_frame;await process_frame
		var view:=Rect2(Vector2.ZERO,dimensions)
		check("HUD-live-bounds-%dx%d"%[dimensions.x,dimensions.y],view.encloses(game.sidebar.get_rect()) and not game.sidebar.get_rect().intersects(game.play_rect) and not game.header.get_rect().intersects(game.play_rect))
	game.pause_game();await process_frame;await process_frame
	check("MENU-bounded-and-scrollable",Rect2(Vector2.ZERO,game.screen_root.size).encloses(game.menu.get_rect()) and game.menu_scroll is ScrollContainer)
	game.show_help();await process_frame;await process_frame
	check("MENU-help-text-wraps",game.menu_content.get_children().filter(func(n):return n is Label).all(func(n):return n.autowrap_mode!=TextServer.AUTOWRAP_OFF))
	game.resume_game();game.show_map();await process_frame;await process_frame
	check("MAP-overlay-bounded",Rect2(Vector2.ZERO,game.screen_root.size).encloses(game.map_overlay.get_rect()) and game.sim.paused)
	var ghost=game.ghosts[0];ghost.animate(0,Vector2i.LEFT,"chase",0,true)
	check("GHOST-opaque-readable-body",ghost.model.get_node("Body").material_override.albedo_color.a==1.0 and ghost.model.get_node("Pupil0")!=null)
	ghost.animate(0,Vector2i.LEFT,"vulnerable",4,true)
	check("GHOST-frightened-face",ghost.model.get_node("Mouth").visible and ghost.model.get_node("Body").visible)
	ghost.animate(0,Vector2i.LEFT,"returning",0,true)
	check("GHOST-returning-eyes-only",not ghost.model.get_node("Body").visible and not ghost.model.get_node("Mouth").visible and ghost.model.get_node("Eye0").visible)
	game.queue_free();await process_frame
	var out=FileAccess.open("res://evidencias/testes_arcade.json",FileAccess.WRITE)
	out.store_string(JSON.stringify({"suite":"Tunnels, ghost house, UI safe zones and ghost presentation","engine":Engine.get_version_info().string,"executed":results.size(),"passed":results.size()-failed,"failed":failed,"results":results},"\t"));out.close()
	print("ARCADE_TEST_RESULT executed=",results.size()," failed=",failed)
	quit(1 if failed else 0)
