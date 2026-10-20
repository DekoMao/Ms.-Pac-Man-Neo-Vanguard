extends SceneTree
const Rules=preload("res://scripts/rules.gd")
const Stages=preload("res://scripts/stages.gd")
const Store=preload("res://scripts/storage.gd")
const Scene=preload("res://scenes/main.tscn")
const CampaignTest=preload("res://tests/test_campaign.gd")
var checks:Array=[]
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(id:String,ok:bool) -> void:
	checks.append({"id":id,"passed":ok})
	if not ok:failures+=1
	print("PASS " if ok else "FAIL ",id)
func quiet(level:int=0,mode:String="circuit",upgrade:String=""):
	var r=Rules.new();r.reset(level,true,{"mode":mode,"upgrade":upgrade});r.start()
	for g in r.ghosts:g.release=100000.0
	return r
func sentinel(r) -> void:r.pickups.clear();r.pickups[Vector2i(15,1)]="pellet"
func fruit(r,p:Vector2=Vector2(3,9)) -> void:
	r.time=13;r.bonus.active=true;r.bonus.cursor=1;r.bonus.end_at=24
	r.bonus.actor={"pos":p,"previous":p,"dir":Vector2i.LEFT,"state":"bonus"}
func follower(r,p:Vector2) -> Dictionary:
	var g={"pos":p,"previous":p,"dir":Vector2i.LEFT,"state":"train","train":true,"id":101,"immune":-1,"safe_until":-1.0}
	r.train.followers=[g];r.train.next_at=10000;return g
func chase(r) -> bool:
	for i in 1439:
		if not r.bonus.active:return r.bonus.caught==1
		var c:=Vector2i(r.player.pos.round())
		if r.player.pos.x>=0 and r.player.pos.x<=16 and r.player.pos.distance_to(Vector2(c))<0.035:
			var best:=Vector2i.ZERO;var dist:=10000
			for d in Rules.DIRS:
				if not r.walkable(r.neighbor(c,d)):continue
				var dd:int=r.path_distance(r.neighbor(c,d),Vector2i(r.bonus.actor.pos.round()))
				if dd<dist:dist=dd;best=d
			r.request_direction(best)
		r.tick()
	return r.bonus.caught==1
func pad(button:int) -> void:
	var e:=InputEventJoypadButton.new();e.device=0;e.button_index=button;e.pressed=true;Input.parse_input_event(e)
	await process_frame
	e=InputEventJoypadButton.new();e.device=0;e.button_index=button;e.pressed=false;Input.parse_input_event(e)
	await process_frame
func run() -> void:
	var maps:Array=[]
	for i in 6:
		var r=quiet(i);maps.append(str(r.grid))
		check("MAP-%d-rectangular-connected"%i,r.grid.all(func(row):return row.length()==17) and r.topology_valid(r.floors))
		var valid:=true
		for c in r.pickups:
			if r.path_distance(Vector2i(1,9),c)>=10000:valid=false
		check("MAP-%d-all-required-items-reachable"%i,valid)
		var candidate=r.floors.duplicate();candidate[r.open_cell]=true;candidate.erase(r.close_cell)
		check("MAP-%d-safe-dynamic-route"%i,r.topology_valid(candidate))
		if i in [3,4]:check("MAP-%d-complete-via-movement"%i,CampaignTest.solve_without_enemies(r))
	check("MAP-six-distinct-layouts",maps.size()==6 and maps.all(func(m):return maps.count(m)==1))
	var r=quiet(3)
	check("MAP-ring-extra-tunnel",r.tunnel_rows()==[3,5,9] and r.neighbor(Vector2i(0,3),Vector2i.LEFT)==Vector2i(16,3) and r.walkable(Vector2i(16,3)))
	for i in 6:
		r=quiet(i);var before:Dictionary=r.pickup_progress();r.time=11.9;r.tick();check("FRUIT-%d-not-early"%i,not r.bonus.active)
		r.time=12;r.tick();check("FRUIT-%d-spawn-and-independent-counter"%i,r.bonus.active and r.pickup_progress()==before)
		var legal:=true
		for frame in 240:
			r.tick()
			if not r.walkable(r.normalize_cell(Vector2i(r.bonus.actor.pos.round()))):legal=false
		check("FRUIT-%d-legal-moving-path"%i,legal and r.bonus.actor.pos!=r.bonus.actor.previous)
		r=quiet(i);r.time=12;r.tick();check("FRUIT-%d-catchable-without-dash"%i,chase(r))
	r=quiet();r.time=12;r.tick();var fp:Vector2=r.bonus.actor.pos;var ft:float=r.time;r.paused=true
	for frame in 600:r.tick()
	check("FRUIT-pause-freezes-opportunity",r.time==ft and r.bonus.actor.pos==fp and r.bonus.end_at==24)
	r.paused=false;r.time=24;r.tick();check("FRUIT-expiry-has-no-penalty",not r.bonus.active and r.score==0 and r.lives==3)
	r.tick();check("FRUIT-expiry-event-once",not r.events.any(func(e):return e.type=="bonus_expired"))
	r.time=34;r.tick();check("FRUIT-second-opportunity",r.bonus.active and r.bonus.cursor==2 and r.bonus.end_at==46)
	r.time=46;r.tick();r.time=60;r.tick();check("FRUIT-two-only",not r.bonus.active and r.bonus.cursor==2)
	r=quiet();fruit(r);var pc:Dictionary=r.pickup_progress();r.flow=3;r.energy=95;r.bonus.collect(r,13)
	check("FRUIT-flow-reward-no-required-collection",r.score==900 and r.energy==100 and r.bonus.earned==900 and r.pickup_progress()==pc and not r.bonus.collect(r,13))
	r=quiet();fruit(r);check("FRUIT-exact-expiry-rejected",not r.bonus.collect(r,24))
	r=quiet();sentinel(r);fruit(r,Vector2(2.2,9));r.request_direction(Vector2i.RIGHT);r.request_dash();r.tick(0.15)
	check("FRUIT-relative-sweep-dash",r.bonus.caught==1 and r.score==300 and r.energy==75 and r.player.pos.distance_to(r.bonus.actor.pos)>0.43)
	r=quiet();sentinel(r);fruit(r,Vector2(3.1,9));r.tuning.ghost_speed=0;r.ghosts[0].state="chase";r.ghosts[0].pos=Vector2(1.7,9);r.request_direction(Vector2i.RIGHT);r.request_dash();r.tick(0.15)
	check("FRUIT-later-reward-not-collected-after-death",r.lives==2 and r.bonus.caught==0 and not r.bonus.active)
	r=quiet();fruit(r);r.pickups.clear();r.tick();check("FRUIT-does-not-block-victory",r.status=="won" and not r.bonus.active)
	r=quiet();fruit(r,Vector2(r.close_cell));r.queue_topology();r.time=15;r.update_topology();check("FRUIT-defers-occupied-topology",r.graph_version==0)
	r.bonus.actor.pos=Vector2(15,11);r.update_topology();check("FRUIT-releases-topology",r.graph_version==1)
	for mode in ["overdrive","train"]:
		r=quiet(0,mode);r.time=179.995;r.tick(0.1)
		check("TIMER-%s-exact-180"%mode,r.status=="time_up" and absf(r.run_time()-180)<0.000001)
		r=quiet(0,mode);r.time=179;r.paused=true;r.tick(2)
		check("TIMER-%s-pause"%mode,r.time==179 and r.status=="playing")
		r=quiet(0,mode);r.time=179;r.status="respawning";r.respawn_until=181;r.tick(2);r.tick()
		check("TIMER-%s-respawn-cannot-exceed-limit"%mode,r.status=="time_up" and r.run_time()==180)
	r=quiet(0,"overdrive");r.time=40;r.tick();check("OVERDRIVE-scheduled-power",r.power_until>=43 and r.pulse_index==1)
	var end:float=r.power_until;r.tick();check("OVERDRIVE-no-repeat-pulse",r.power_until==end)
	r=quiet(0,"overdrive");r.time=39;r.activate_power(39,6);r.combo=2;r.time=40;r.tick()
	check("OVERDRIVE-pulse-preserves-longer-power-and-chain",r.power_until==45 and r.combo==2)
	r.reset(1,true,{"mode":"overdrive","run_elapsed":45,"score":2000,"lives":2});r.start();r.tick()
	check("OVERDRIVE-wave-carries-time-and-score",r.run_time()>45 and r.score==2000 and r.lives==2 and r.pulse_index==1)
	for choice in ["shield","magnet","dash"]:
		r=quiet(1,"circuit",choice)
		if choice=="shield":r.request_shield();check("UPGRADE-long-shield",r.shield_until==11)
		if choice=="magnet":r.request_magnet();check("UPGRADE-long-magnet",r.magnet_until==9)
		if choice=="dash":r.request_direction(Vector2i.RIGHT);r.energy=30;check("UPGRADE-cheaper-dash",r.request_dash() and r.energy==0 and r.dash_uses==1)
		r.reset(2,true);check("UPGRADE-%s-does-not-stack"%choice,r.upgrade=="")
	r=quiet(1,"circuit","magnet");r.player.pos=Vector2(2,9);r.request_magnet();r.pickups[Vector2i(2,7)]="pellet";r.tick()
	check("UPGRADE-magnet-no-through-wall",r.pickups.has(Vector2i(2,7)))
	r=quiet();r.status="won";r.max_chain=4;check("EXTRAS-three-skill-badges",r.stage_result().expert_mask==7)
	r.dash_uses=1;r.stage_deaths=1;check("EXTRAS-independent-criteria",r.stage_result().expert_mask==4)
	r.status="game_over";check("EXTRAS-only-on-completion",r.stage_result().expert_mask==0)
	r=quiet(0,"train");r.time=8;r.tick();check("TRAIN-spawns-in-special-mode",r.train.followers.size()==2 and r.train.followers.all(func(g):return r.walkable(Vector2i(g.pos.round()))))
	for t in [28,48,68,88]:r.time=t;r.tick()
	check("TRAIN-bounded-to-eight",r.train.followers.size()==8)
	var train_pos:Vector2=r.train.followers[0].pos;r.paused=true;r.tick();check("TRAIN-pause",r.train.followers[0].pos==train_pos)
	r=quiet(0,"train");sentinel(r);r.time=10;follower(r,Vector2(2.9,9));r.pickups[Vector2i(2,9)]="power";r.request_direction(Vector2i.RIGHT);r.request_dash();r.tick(0.15)
	check("TRAIN-earlier-power-enables-capture",r.lives==3 and r.score==250 and r.train.followers[0].state=="returning")
	r=quiet(0,"train");sentinel(r);r.time=10;follower(r,Vector2(1.7,9));r.pickups[Vector2i(2,9)]="power";r.request_direction(Vector2i.RIGHT);r.request_dash();r.tick(0.15)
	check("TRAIN-later-power-cannot-save",r.lives==2 and r.score==0 and r.train.followers.is_empty())
	r=quiet(0,"train");sentinel(r);r.time=10;follower(r,Vector2(2.7,9));r.power_until=10.01;r.request_direction(Vector2i.RIGHT);r.request_dash();r.tick(0.15)
	check("TRAIN-expiry-before-contact-is-hostile",r.lives==2 and r.stage_captures==0)
	r=quiet(5);r.pickups.clear();r.tick();check("BOSS-only-after-final-maze",r.boss.active and r.status=="playing" and r.pickups.size()==3 and r.boss.hp==3)
	r.boss.charges=1;check("BOSS-warning-not-vulnerable",not r.request_boss_pulse() and r.boss.charges==1)
	r.time=r.boss.next_at;r.boss.update(r);check("BOSS-warning-before-attack",r.boss.phase=="attack")
	r.time=r.boss.next_at;r.boss.update(r);check("BOSS-recovery-window",r.boss.phase=="recover")
	r.boss.charges=0
	for c in r.pickups.keys():r.collect(c,r.time)
	check("BOSS-three-cores-reachable-and-charged",r.boss.charges==3 and r.pickups.is_empty())
	r.boss.charges=3;check("BOSS-one-hit-per-cycle",r.request_boss_pulse() and r.boss.hp==2 and not r.request_boss_pulse() and r.boss.charges==2)
	for i in 2:
		r.time=r.boss.next_at;r.boss.update(r);r.time=r.boss.next_at;r.boss.update(r);r.time=r.boss.next_at;r.boss.update(r);r.request_boss_pulse()
	r.tick();check("BOSS-three-cycles-win",r.boss.defeated and r.boss.hp==0 and r.status=="won" and r.stage_result().challenge)
	r=quiet(5);r.pickups.clear();r.tick();r.player.pos=Vector2(r.boss.cells[0]);r.player.previous=r.player.pos;r.player.dir=Vector2i.ZERO;r.time=r.boss.next_at;r.tick()
	check("BOSS-announced-hazard-damages-once",r.lives==2 and r.status=="respawning" and r.boss.phase=="warning")
	r=quiet(5,"overdrive");r.pickups.clear();r.tick();check("BOSS-not-in-timed-modes",not r.boss.active and r.status=="won")
	var path="user://expanded-test.json";var file=FileAccess.open(path,FileAccess.WRITE);file.store_string('{"schema":3,"circuit_record":12345,"record":2240,"medals":[7,3,1],"unlocked":2}');file.close()
	var data=Store.read_settings(path)
	check("SAVE-archives-three-stage-record",data.legacy_circuit_record==12345 and data.circuit_record==0 and data.record==2240)
	check("SAVE-expands-without-losing-medals",data.schema==4 and data.medals==[7,3,1,0,0,0] and data.experts==[0,0,0,0,0,0] and data.unlocked==2)
	DirAccess.remove_absolute(path)
	var game=Scene.instantiate();root.add_child(game);current_scene=game
	await process_frame;await process_frame;game.set_physics_process(false);game.start_game()
	var snapshot:Array=[game.sim.time,game.sim.score,game.sim.player.duplicate()]
	for chain in 4:game.feedback.react({"type":"capture","pos":Vector2(3,9),"points":200*(1<<chain),"chain":chain+1},game.sim,false)
	check("FEEDBACK-does-not-mutate-rules",snapshot==[game.sim.time,game.sim.score,game.sim.player])
	check("FEEDBACK-one-caption-budget",game.feedback.effects.filter(func(e):return e.kind=="caption").size()==1)
	game.feedback.reset();game.feedback.react({"type":"capture","pos":Vector2(3,9),"points":1600,"chain":4},game.sim,true)
	check("FEEDBACK-reduced-effects-neutral",game.feedback.effects.is_empty())
	game.hero.react("dash");game.hero.animate(1,Vector2i.RIGHT,"",0,false,0);check("ANIMATION-dash-stretch",game.hero.model.scale.x>1 and game.hero.model.scale.y<1)
	game.hero.animate(1,Vector2i.RIGHT,"",0,true,0);check("ANIMATION-reduced-motion-neutral",game.hero.model.scale==Vector3.ONE)
	game.start_game();check("ANIMATION-restart-clears-impulses",game.hero.action_heat==0 and game.hero.happy_heat==0)
	check("AUDIO-distinct-capture-crescendo",game.sounds.capture_1!=game.sounds.capture_2 and game.sounds.capture_4.get_length()>game.sounds.capture_1.get_length())
	game.voice_index=0;game.play_sound("capture",1,-17);game.play_sound("capture_4",1,-17)
	check("AUDIO-simultaneous-reward-voices",game.voices[0].stream==game.sounds.capture and game.voices[1].stream==game.sounds.capture_4 and game.voices[0].volume_db==-17)
	await pad(JOY_BUTTON_DPAD_RIGHT);check("PAD-dpad-direction",game.sim.player.dir==Vector2i.RIGHT)
	await pad(JOY_BUTTON_X);check("PAD-dash",game.sim.dash_uses==1)
	game.start_game();await pad(JOY_BUTTON_A);check("PAD-shield",game.sim.shield_charges==0)
	game.start_game(1);await pad(JOY_BUTTON_Y);check("PAD-magnet",game.sim.magnet_charges==0)
	game.start_game();var motion:=InputEventJoypadMotion.new();motion.axis=JOY_AXIS_LEFT_X;motion.axis_value=0.2;Input.parse_input_event(motion);await process_frame
	check("PAD-deadzone-prevents-drift",game.sim.player.dir==Vector2i.ZERO)
	motion=InputEventJoypadMotion.new();motion.axis=JOY_AXIS_LEFT_X;motion.axis_value=0.8;Input.parse_input_event(motion);await process_frame
	check("PAD-stick-starts-direction",game.sim.player.dir==Vector2i.RIGHT)
	motion=InputEventJoypadMotion.new();motion.axis=JOY_AXIS_LEFT_X;motion.axis_value=0;Input.parse_input_event(motion);await process_frame
	game.start_game();fruit(game.sim);game.sim.paused=true;game._process(0)
	check("FRUIT-UI-caption-and-model",game.bonus_visual.visible and game.bonus_caption.visible)
	for size in [Vector2(960,720),Vector2(1280,720),Vector2(1920,1080)]:
		game.screen_root.size=size;game._process(0);await process_frame;await process_frame
		check("HUD-bonus-safe-%dx%d"%[size.x,size.y],Rect2(Vector2.ZERO,size).encloses(game.sidebar.get_rect()) and not game.sidebar.get_rect().intersects(game.play_rect))
	game.start_game();game.sim.status="won";game.show_results();game.show_upgrade_choice()
	check("UPGRADE-UI-three-choices-plus-standard",game.menu_content.get_children().filter(func(n):return n is Button).size()==4)
	game.menu_content.get_child(2).pressed.emit();check("UPGRADE-UI-callback-carries-choice",game.sim.stage_id==1 and game.sim.upgrade=="shield" and game.sim.player.dir==Vector2i.ZERO)
	var circuit_best:int=game.settings.circuit_record;var train_best:int=game.settings.train_record
	game.start_mode("overdrive");game.sim.score=999999;game.sim.time=179.99
	for g in game.sim.ghosts:g.release=100000
	game._physics_process(0.1)
	check("OVERDRIVE-UI-results-and-record-isolation",game.current_screen=="results" and game.settings.overdrive_record==999999 and game.settings.circuit_record==circuit_best and game.settings.train_record==train_best)
	game.retry_run();check("OVERDRIVE-UI-immediate-rematch",game.current_screen=="playing" and game.sim.mode=="overdrive" and game.sim.run_time()==0 and game.sim.score==0 and game.best_before_run==999999)
	game.sim.time=30;game.sim.request_direction(Vector2i.RIGHT);game.sim.pickups.clear();game._physics_process(Rules.STEP)
	check("OVERDRIVE-UI-continuous-wave-time",game.sim.stage_id==1 and game.sim.mode=="overdrive" and game.sim.run_elapsed>=30 and game.current_screen=="playing" and game.sim.player.dir==Vector2i.RIGHT)
	game.start_game(5);game.sim.pickups.clear();game._physics_process(Rules.STEP);game._process(0)
	check("BOSS-UI-active-warning-and-core-counter",game.boss_visual.visible and game.hazard_visuals.any(func(n):return n.visible) and game.collection_label.text.begins_with("COLOSSO"))
	game.sim.boss.phase="recover";game.sim.boss.next_at=100;game.sim.boss.charges=1
	await pad(JOY_BUTTON_RIGHT_SHOULDER);check("PAD-boss-pulse",game.sim.boss.hp==2 and game.sim.boss.charges==0)
	game.start_mode("train");game.sim.time=8
	for g in game.sim.ghosts:g.release=100000
	game._physics_process(Rules.STEP);game._process(0)
	check("TRAIN-UI-visible-followers",game.train_visuals.filter(func(n):return n.visible).size()==2)
	game.queue_free();await process_frame
	var out=FileAccess.open("res://evidencias/testes_expansao.json",FileAccess.WRITE);out.store_string(JSON.stringify({"suite":"Expanded arcade: six maps, moving fruit, modes, upgrades, skills, train, boss and pad","executed":checks.size(),"passed":checks.size()-failures,"failed":failures,"results":checks},"\t"));out.close()
	print("EXPANSION_TEST_RESULT executed=",checks.size()," failed=",failures)
	quit(1 if failures else 0)
