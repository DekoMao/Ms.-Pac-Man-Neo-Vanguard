extends SceneTree
const Rules=preload("res://scripts/rules.gd")
const Store=preload("res://scripts/storage.gd")
const Stages=preload("res://scripts/stages.gd")
var results:Array=[]
var failed:=0
func _initialize() -> void:call_deferred("run")
func check(id:String,ok:bool) -> void:
	results.append({"id":id,"passed":ok})
	if not ok:failed+=1
	print("PASS " if ok else "FAIL ",id)
func quiet(index:int=0):
	var r=Rules.new();r.reset(index,true);r.start()
	for g in r.ghosts:g.release=100000.0
	return r
func navigate_to_nearest(r) -> Vector2i:
	var start:=Vector2i(r.player.pos.round())
	var queue:Array=[start]
	var first:Dictionary={start:Vector2i.ZERO}
	for cell in queue:
		if r.pickups.has(cell):return first[cell]
		for d in Rules.DIRS:
			var next:Vector2i=r.neighbor(cell,d)
			if r.walkable(next) and not first.has(next):
				first[next]=d if cell==start else first[cell]
				queue.append(next)
	return Vector2i.ZERO
func solve_without_enemies(r) -> bool:
	for frame in 40000:
		if r.status=="won":return true
		if r.player.pos.x>=0 and r.player.pos.x<=16 and r.player.pos.distance_to(r.player.pos.round())<0.04:
			r.request_direction(navigate_to_nearest(r))
		r.tick()
	return false
func run() -> void:
	var fingerprints:Array=[]
	for i in 3:
		var stage=quiet(i)
		fingerprints.append(str(stage.grid))
		check("STAGE-%d-connected"%i,stage.topology_valid(stage.floors))
		check("STAGE-%d-item-spawn-contract"%i,stage.floors.has(Vector2i(1,9)) and stage.pickups.values().count("power")==5 and stage.pickups.values().count("fruit")==1 and stage.pickup_progress().remaining==stage.initial_pellets)
		var candidate=stage.floors.duplicate();candidate[stage.open_cell]=true;candidate.erase(stage.close_cell)
		check("STAGE-%d-safe-topology"%i,stage.topology_valid(candidate))
		check("STAGE-%d-complete-via-movement"%i,solve_without_enemies(stage) and stage.pickups.is_empty() and stage.pickup_progress().percent==100)
	check("STAGE-distinct-layouts",fingerprints[0]!=fingerprints[1] and fingerprints[1]!=fingerprints[2] and fingerprints[0]!=fingerprints[2])
	var r=quiet()
	check("SHIELD-one-charge",r.request_shield() and r.shield_charges==0 and not r.request_shield())
	r.player.dir=Vector2i.ZERO;r.tuning.ghost_speed=0
	for i in [0,1]:r.ghosts[i].state="chase";r.ghosts[i].pos=r.player.pos
	r.tick()
	check("SHIELD-overlapping-ghosts-one-block",r.lives==3 and r.grace_until>r.time and r.events.filter(func(e):return e.type=="shield_hit").size()==1)
	r.time=r.grace_until;r.tick()
	check("SHIELD-grace-expiry-is-dangerous",r.lives==2 and r.stage_deaths==1)
	r=quiet();r.request_shield();r.time=8.0
	check("SHIELD-exact-expiry",not r.block_hit(8.0))
	r=quiet();r.paused=true
	check("POWERS-no-use-while-paused",not r.request_shield() and r.shield_charges==1)
	r=quiet();r.request_shield();r.paused=true;var before=r.shield_until-r.time
	for tick in 120:r.tick()
	check("POWERS-duration-pauses",r.shield_until-r.time==before)
	r=quiet()
	check("MAGNET-locked-stage-one",not r.request_magnet())
	r=quiet(1)
	check("MAGNET-single-charge",r.request_magnet() and r.magnet_charges==0 and not r.request_magnet())
	r.player.dir=Vector2i.ZERO;r.tick()
	check("MAGNET-adjacent-pellet",not r.pickups.has(Vector2i(2,9)))
	check("MAGNET-no-remote-fruit-or-power",r.pickups.has(Vector2i(3,9)) and r.pickups.has(Vector2i(1,11)))
	# Across wall (2,8), from (2,9) to (2,7): two grid steps, never attracted.
	r.player.pos=Vector2(2,9);r.player.dir=Vector2i.ZERO;r.pickups[Vector2i(2,7)]="pellet";r.tick()
	check("MAGNET-no-through-wall",r.pickups.has(Vector2i(2,7)))
	r=quiet(1);r.player.dir=Vector2i.ZERO;r.request_magnet();r.time=6.0;r.tick()
	check("MAGNET-expiry-stops-attraction",r.pickups.has(Vector2i(2,9)))
	r=quiet(1);r.request_shield();r.request_magnet();r.die()
	check("POWERS-death-clears-without-refill",r.shield_charges==0 and r.magnet_charges==0 and r.shield_until<0 and r.magnet_until<0)
	r.reset(2,true,{"score":9876,"lives":2})
	check("STAGE-transition-carries-session",r.score==9876 and r.lives==2 and r.collected==0 and r.stage_captures==0 and r.stage_deaths==0 and r.shield_charges==1 and r.magnet_charges==1)
	r=quiet();r.status="won";r.time=100;r.stage_captures=2
	check("MEDAL-first-stage-complete",r.stage_result().mask==7 and r.stage_result().bonus==1000)
	r.time=111
	check("MEDAL-speed-target",r.stage_result().mask==3 and not r.stage_result().fast)
	r=quiet(1);r.status="won";r.stage_deaths=1
	check("MEDAL-deathless-not-awarded-after-death",not r.stage_result().challenge)
	r=quiet(2);r.status="won";r.risk.state="success"
	check("MEDAL-reactor-wager",r.stage_result().challenge)
	r.status="game_over"
	check("MEDAL-no-rewards-on-defeat",r.stage_result().mask==0 and r.stage_result().bonus==0)
	r=quiet();r.pickups.clear();r.pickups[Vector2i(2,9)]="pellet";r.player.pos=Vector2(2,9);r.player.dir=Vector2i.ZERO;r.tick()
	var scored:int=r.score;r.tick()
	check("MEDAL-victory-bonus-once",r.status=="won" and scored==760 and r.score==scored)
	var path="user://circuit-test-"+str(Time.get_ticks_usec())+".json"
	var file=FileAccess.open(path,FileAccess.WRITE);file.store_string('{"schema":2,"record":2240,"volume":0.4}');file.close()
	var data=Store.read_settings(path)
	check("SAVE-migrates-without-losing-record",data.schema==3 and data.record==2240 and data.unlocked==0 and data.medals==[0,0,0])
	data.unlocked=2;data.medals=[7,3,1];data.circuit_record=9999;data.trail_style=1
	Store.write_settings(data,path);data=Store.read_settings(path)
	check("SAVE-retains-campaign-and-cosmetic",data.unlocked==2 and data.medals==[7,3,1] and data.trail_style==1 and data.circuit_record==9999)
	file=FileAccess.open(path,FileAccess.WRITE);file.store_string('{"unlocked":99,"medals":[99,"bad",-1,7],"trail_style":99}');file.close()
	data=Store.read_settings(path)
	check("SAVE-bounded-unlocks-and-medals",data.unlocked==2 and data.medals==[7,0,0] and data.trail_style==1)
	var dir=DirAccess.open("user://")
	for name in dir.get_files():
		if name.begins_with(path.get_file()):dir.remove(name)
	var out=FileAccess.open("res://evidencias/testes_circuito.json",FileAccess.WRITE)
	out.store_string(JSON.stringify({"suite":"Circuit stages, powers, rewards and save migration","engine":Engine.get_version_info().string,"executed":results.size(),"passed":results.size()-failed,"failed":failed,"results":results},"\t"));out.close()
	print("CIRCUIT_TEST_RESULT executed=",results.size()," failed=",failed)
	quit(1 if failed else 0)
