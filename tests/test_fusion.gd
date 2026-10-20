extends SceneTree
const Rules=preload("res://scripts/rules.gd")
const Scene=preload("res://scenes/main.tscn")
const Store=preload("res://scripts/storage.gd")
const CampaignTest=preload("res://tests/test_campaign.gd")
var checks:Array=[]
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(id:String,ok:bool) -> void:
	checks.append({"id":id,"passed":ok})
	if not ok:failures+=1
	print("PASS " if ok else "FAIL ",id)
func quiet(level:int=0):
	var r=Rules.new();r.reset(level,true,{"mode":"fusion"});r.start()
	for g in r.ghosts:g.release=100000.0
	r.pickups.clear();r.pickups[Vector2i(15,1)]="pellet"
	return r
func pos(r,p:Vector2) -> void:
	r.player.pos=p;r.player.previous=p;r.player.dir=Vector2i.ZERO;r.held_dir=Vector2i.ZERO;r.buffer_dir=Vector2i.ZERO
func plant(r,c:Vector2i,at:float=0) -> void:
	pos(r,Vector2(c));r.time=at;assert(r.request_bomb())
func ghost(r,p:Vector2) -> Dictionary:
	var g:Dictionary=r.ghosts[0];g.pos=p;g.previous=p;g.state="chase";g.dir=Vector2i.ZERO
	r.tuning.ghost_speed=0;return g
func wait_seconds(r,seconds:float) -> void:
	var n:=floori(seconds/Rules.STEP)
	for i in n:r.tick()
	var tail:float=seconds-n*Rules.STEP
	if tail>0.00000001:r.tick(tail)
func collect_by_movement(r) -> bool:
	var expected:int=r.initial_pellets
	for frame in 40000:
		if r.collected==expected:return true
		if r.player.pos.x>=0 and r.player.pos.x<=16 and r.player.pos.distance_to(r.player.pos.round())<0.04:r.request_direction(CampaignTest.navigate_to_nearest(r))
		r.tick()
	return false
func run() -> void:
	for level in 6:
		var baseline=Rules.new();baseline.reset(level,true)
		var r=quiet(level)
		check("FUSION-%d-six-distributed-caches"%level,r.fusion.crates.size()==6)
		check("FUSION-%d-all-original-corridors-preserved"%level,baseline.floors.keys().all(func(c):return r.walkable(c,true)))
		check("FUSION-%d-caches-add-floor-and-hidden-required-point"%level,r.fusion.crates.keys().all(func(c):return r.floors.has(c) and not r.walkable(c)))
		var reachable:=true
		for c in r.fusion.crates:
			var sides:=0
			for d in Rules.DIRS:
				if r.walkable(c+d) and r.path_distance(Vector2i(1,9),c+d)<10000:sides+=1
			if sides<2:reachable=false
		check("FUSION-%d-cache-accessible-from-two-original-lanes"%level,reachable)
		check("FUSION-%d-protected-house-and-tunnels"%level,r.fusion.crates.keys().all(func(c):return c not in Rules.HOUSE and c!=Rules.DOOR and c.x>1 and c.x<15))
	var r=quiet()
	check("BOMB-start-stationary",r.player.dir==Vector2i.ZERO and r.time==0)
	check("BOMB-place-allowed-while-standing",r.request_bomb() and r.fusion.bombs.size()==1 and r.fusion.placed==1)
	check("BOMB-duplicate-tile-rejected",not r.request_bomb())
	r.time=0.2;pos(r,Vector2(3,9));check("BOMB-second-capacity",r.request_bomb())
	r.time=0.4;pos(r,Vector2(5,9));check("BOMB-capacity-bounded",not r.request_bomb())
	r.paused=true;check("BOMB-pause-input-blocked",not r.request_bomb());r.tick(4)
	check("BOMB-pause-freezes-fuse",r.fusion.bombs.size()==2 and r.time==0.4)
	r=quiet();plant(r,Vector2i(3,9));pos(r,Vector2(9,9));r.tick(2.299)
	check("BOMB-not-early",r.fusion.flames.is_empty() and r.fusion.bombs.size()==1)
	r.tick(0.001)
	check("BOMB-exact-fuse-and-capacity-return",r.fusion.bombs.is_empty() and r.fusion.flames.size()==1 and absf(r.time-2.3)<0.0000001)
	check("BOMB-range-two-orthogonal-no-diagonals",Vector2i(5,9) in r.fusion.flames[0].cells and Vector2i(6,9) not in r.fusion.flames[0].cells and Vector2i(4,8) not in r.fusion.flames[0].cells)
	r.tick(0.65);check("BOMB-flame-expires-half-open",r.fusion.flames.is_empty())
	r=quiet();plant(r,Vector2i(3,9));r.request_direction(Vector2i.RIGHT);wait_seconds(r,0.34)
	check("BOMB-owner-can-exit-new-bomb",r.player.pos.x>4.0)
	r.request_direction(Vector2i.LEFT);wait_seconds(r,0.5)
	check("BOMB-owner-cannot-reenter-after-full-exit",r.player.pos.x>=4.0-0.00001 and not r.fusion.can_enter(Vector2i(3,9),r.player,true))
	r=quiet();plant(r,Vector2i(3,9));var g=ghost(r,Vector2(5,9))
	check("BOMB-blocks-other-ghost",not r.can_enter(Vector2i(3,9),g,false))
	g.state="returning";check("BOMB-returning-eyes-can-pass",r.can_enter(Vector2i(3,9),g,false))
	check("BOMB-rays-stop-at-solid-wall",Vector2i(3,8) not in r.fusion.ray_cells(r,r.fusion.bombs[0]))
	r=quiet();plant(r,Vector2i(0,9));r.fusion.bombs[0].radius=5
	check("BOMB-tunnel-no-wrapped-flame",Vector2i(16,9) not in r.fusion.ray_cells(r,r.fusion.bombs[0]))
	r=quiet();r.fusion.crates.clear();r.fusion.crates[Vector2i(4,9)]="range"
	plant(r,Vector2i(3,9));r.fusion.bombs[0].radius=5
	var ray:Array=r.fusion.ray_cells(r,r.fusion.bombs[0])
	check("CACHE-ray-stops-at-first-cache",Vector2i(4,9) in ray and Vector2i(5,9) not in ray)
	plant(r,Vector2i(5,9),0.2);r.fusion.bombs[1].radius=5
	for b in r.fusion.bombs:b.at=r.time
	r.fusion.update(r)
	check("CACHE-simultaneous-blasts-use-same-blocker-snapshot",r.fusion.flames.size()==2 and Vector2i(5,9) not in r.fusion.flames[0].cells and Vector2i(3,9) not in r.fusion.flames[1].cells)
	r=quiet();plant(r,Vector2i(3,9));plant(r,Vector2i(5,9),0.4);pos(r,Vector2(9,9));r.tick(1.9)
	check("CHAIN-triggered-with-short-delay",r.fusion.bombs.size()==1 and absf(r.fusion.bombs[0].at-2.4)<0.0000001)
	r.tick(0.099);check("CHAIN-not-premature",r.fusion.bombs.size()==1)
	r.tick(0.001);check("CHAIN-exact-delay-once",r.fusion.bombs.is_empty() and r.fusion.chained==1 and r.fusion.flames.size()==2)
	r.tick(0.2);check("CHAIN-no-double-detonation",r.fusion.chained==1 and r.fusion.flames.size()==2)
	r=quiet();plant(r,Vector2i(3,9));r.tick(2.3)
	check("DAMAGE-self-blast-costs-one-life",r.lives==2 and r.status=="respawning" and r.stage_deaths==1)
	check("DAMAGE-death-clears-all-active-ordnance",r.fusion.bombs.is_empty() and r.fusion.flames.is_empty() and r.player.dir==Vector2i.ZERO)
	r=quiet();plant(r,Vector2i(3,9));r.activate_power(0,10);r.tick(2.3)
	check("DAMAGE-power-does-not-protect-hero",r.lives==2)
	r=quiet();plant(r,Vector2i(3,9));r.request_shield();r.tick(2.3)
	check("DAMAGE-shield-absorbs-blast",r.lives==3 and r.shield_until<0 and r.grace_until>r.time)
	r.tick(0.65);check("DAMAGE-grace-prevents-overlap-repeat",r.lives==3 and r.status=="playing")
	r=quiet();plant(r,Vector2i(3,9));g=ghost(r,Vector2(5,9));pos(r,Vector2(10,9));r.tick(2.3)
	check("GHOST-unpowered-blast-stuns-not-captures",g.state in ["chase","scatter"] and g.stunned_until>r.time and r.stage_captures==0)
	var stun_end:float=g.stunned_until;r.tick(0.4)
	check("GHOST-one-stun-per-blast",g.stunned_until==stun_end)
	pos(r,Vector2(5,9));r.grace_until=r.time+1;r.tick(0.25);r.grace_until=-1
	r.tick();check("GHOST-stunned-body-harmless",r.lives==3)
	r.tick(1.2);check("GHOST-contact-danger-returns-after-stun",r.lives==2)
	r=quiet();plant(r,Vector2i(3,9));g=ghost(r,Vector2(5,9));pos(r,Vector2(10,9));r.activate_power(0,6);r.tick(2.3)
	check("GHOST-powered-blast-captures-with-flow",g.state=="returning" and r.stage_captures==1 and r.combo==1 and r.flow==1.5)
	r.tick(0.4);check("GHOST-no-capture-farming",r.stage_captures==1)
	r=quiet();plant(r,Vector2i(3,9));g=ghost(r,Vector2(5,9));pos(r,Vector2(10,9));r.activate_power(0,2.3);r.tick(2.3)
	check("GHOST-power-expiry-at-detonation-is-not-capture",r.stage_captures==0 and g.stunned_until>r.time)
	r=quiet();plant(r,Vector2i(3,9));g=ghost(r,Vector2(5,9));pos(r,Vector2(10,9));r.tick(2.3);r.activate_power(r.time,6);r.tick()
	check("GHOST-power-during-live-flame-captures-stunned-ghost",r.stage_captures==1)
	r=quiet();plant(r,Vector2i(3,9));pos(r,Vector2(5,9));r.fusion.bombs[0].at=0.12;r.request_direction(Vector2i.LEFT);r.request_dash();r.tick(0.15)
	check("DAMAGE-dash-swept-through-live-flame",r.lives==2)
	r=quiet();var c:Vector2i=r.fusion.crates.keys()[0];var next:=Vector2i.ZERO
	for d in Rules.DIRS:
		if r.walkable(c+d):next=c+d;break
	r.pickups[c]="pellet";var before:int=r.pickups.size();r.collect(c,0)
	check("CACHE-hidden-required-item-cannot-be-collected",r.pickups.size()==before)
	plant(r,next);pos(r,Vector2(1,9));r.grace_until=4;r.tick(2.3)
	check("CACHE-explosion-opens-route-and-reveals-upgrade",not r.fusion.crates.has(c) and r.walkable(c) and r.fusion.drops.has(c) and r.pickups.has(c))
	check("CACHE-blast-stops-on-cache",c in r.fusion.flames[0].cells)
	pos(r,Vector2(c));r.tick()
	check("CACHE-drop-waits-for-flame-clear",r.fusion.drops.has(c))
	r.tick(0.65)
	check("CACHE-drop-collected-and-required-point-counted",not r.fusion.drops.has(c) and not r.pickups.has(c) and r.fusion.capacity==3)
	r.fusion.drops[c]="range";r.fusion.collect_drop(r,c);r.fusion.drops[c]="shield";r.fusion.collect_drop(r,c)
	check("UPGRADE-range-and-shield-charge",r.fusion.radius==3 and r.shield_charges==2)
	for i in 10:r.fusion.drops[c]="range";r.fusion.collect_drop(r,c);r.fusion.drops[c]="capacity";r.fusion.collect_drop(r,c)
	check("UPGRADE-hard-limits",r.fusion.radius==5 and r.fusion.capacity==4)
	var carry:Dictionary=r.fusion.carry();carry.mode="fusion";r.reset(1,true,carry)
	check("UPGRADE-carries-to-next-phase",r.fusion.radius==5 and r.fusion.capacity==4)
	r.reset(0,true,{"mode":"fusion"});check("UPGRADE-new-run-resets-loadout",r.fusion.radius==2 and r.fusion.capacity==2)
	r.start();r.time=180;r.tick();check("FUSION-no-time-limit",r.status=="playing" and r.time>180)
	r.reset(0,true);check("REGRESSION-circuit-has-no-bombs-caches-or-new-items",r.fusion.crates.is_empty() and not r.request_bomb() and r.initial_pellets==103)
	for level in 6:
		r=quiet(level);r.pickups.clear()
		# QA fixture detonates a legal bomb from an adjacent lane for each cache.
		# After opening them, all required pickups are traversed via real movement.
		for cache in r.fusion.crates.keys():
			var side:=Vector2i.ZERO
			for d in Rules.DIRS:
				if r.walkable(cache+d):side=cache+d;break
			pos(r,Vector2(side));r.time+=0.2;r.fusion.bombs.clear();assert(r.request_bomb());r.fusion.bombs[0].at=r.time;r.fusion.update(r);r.fusion.flames.clear()
		check("COMPLETION-%d-all-six-caches-openable"%level,r.fusion.crates.is_empty() and r.fusion.broken==6)
		r.reset(level,true,{"mode":"fusion"});r.start();r.fusion.crates.clear();r.fusion.drops.clear()
		for enemy in r.ghosts:enemy.release=100000
		check("COMPLETION-%d-all-hidden-points-reachable-and-clearable"%level,collect_by_movement(r))
	var gscene=Scene.instantiate();root.add_child(gscene);current_scene=gscene
	await process_frame;gscene.set_physics_process(false);gscene.start_mode("fusion")
	check("UI-fusion-launch-stationary-with-six-caches",gscene.sim.mode=="fusion" and gscene.sim.player.dir==Vector2i.ZERO and gscene.fusion_visual.cache_nodes.size()==6)
	var e:=InputEventKey.new();e.physical_keycode=KEY_B;e.pressed=true;gscene._unhandled_input(e)
	check("INPUT-keyboard-bomb",gscene.sim.fusion.bombs.size()==1)
	gscene.start_mode("fusion");var pad:=InputEventJoypadButton.new();pad.button_index=JOY_BUTTON_B;pad.pressed=true;gscene._unhandled_input(pad)
	check("INPUT-controller-B-bomb",gscene.sim.fusion.bombs.size()==1)
	gscene.sim.paused=true;var when:float=gscene.sim.time;gscene.sim.tick(3)
	check("UI-pause-freezes-real-bomb",gscene.sim.time==when and gscene.sim.fusion.bombs.size()==1)
	gscene.sim.status="won";gscene.sim.fusion.capacity=4;gscene.sim.fusion.radius=5;gscene.next_stage("dash")
	check("UI-next-phase-preserves-bomb-upgrades",gscene.sim.stage_id==1 and gscene.sim.mode=="fusion" and gscene.sim.fusion.capacity==4 and gscene.sim.fusion.radius==5 and gscene.sim.upgrade=="dash")
	gscene.retry_run();check("UI-rematch-clears-bombs-and-loadout",gscene.sim.stage_id==0 and gscene.sim.fusion.bombs.is_empty() and gscene.sim.fusion.radius==2)
	gscene.update_hud();check("UI-counter-and-bomb-resources-visible",gscene.ability_label.text.contains("BOMBAS 2 / 2") and gscene.mission_label.text.contains("0 / 6"))
	for size in [Vector2(960,720),Vector2(1280,720),Vector2(1920,1080)]:
		root.size=Vector2i(size);await process_frame;await process_frame;gscene.update_hud()
		check("UI-fusion-sidebar-bounds-%d"%int(size.x),gscene.toast.get_global_rect().end.y<=gscene.sidebar.get_global_rect().end.y and gscene.ability_label.get_global_rect().end.x<=gscene.sidebar.get_global_rect().end.x)
	var oldmedals:Array=gscene.settings.medals.duplicate();gscene.sim.time=10;gscene.sim.status="won";gscene.sim.score=3210;gscene._physics_process(0.01)
	check("UI-fusion-win-stops-for-result-not-timed-wave",gscene.current_screen=="results" and gscene.sim.stage_id==0 and gscene.settings.fusion_record==3210 and gscene.settings.medals==oldmedals)
	gscene.show_upgrade_choice();check("UI-fusion-next-choice-available",gscene.current_screen=="upgrade")
	gscene.settings.fusion_record=1200;var savepath:="user://fusion-test.json";Store.write_settings(gscene.settings,savepath)
	check("SAVE-independent-fusion-record",Store.read_settings(savepath).fusion_record==1200)
	gscene.show_title();await process_frame;await process_frame
	check("UI-menu-bounded-with-new-mode",gscene.menu.get_rect().end.y<=gscene.screen_root.size.y and gscene.menu.size.x<=gscene.screen_root.size.x)
	check("VISUAL-approved-camera-and-materials-preserved",gscene.camera.fov==49 and gscene.world_environment.environment.ssr_enabled)
	gscene.queue_free();await process_frame
	var file=FileAccess.open("res://evidencias/testes_fusao.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"executed":checks.size(),"failed":failures,"checks":checks},"\t"));file.close()
	print("FUSION_TEST_RESULT executed=",checks.size()," failed=",failures)
	quit(1 if failures else 0)
