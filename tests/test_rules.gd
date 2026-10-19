extends SceneTree
const Rules=preload("res://scripts/rules.gd")
const Store=preload("res://scripts/storage.gd")
var results:Array=[]
var failed:=0
func _initialize() -> void:call_deferred("run")
func check(name:String,condition:bool,detail:String="") -> void:
	results.append({"id":name,"passed":condition,"detail":detail})
	if not condition:failed+=1
	print("PASS " if condition else "FAIL ",name," ",detail)
func quiet():
	var r=Rules.new();r.start()
	for g in r.ghosts:g.release=100000.0
	r.pickups.clear();r.pickups[Vector2i(15,1)]="pellet"
	return r
func advance(r,seconds:float) -> void:
	for i in roundi(seconds/Rules.STEP):r.tick()
func run() -> void:
	var r=Rules.new()
	check("MAP-01-connected",r.topology_valid(r.floors))
	check("MAP-02-rectangular",r.GRID.all(func(row):return row.length()==17))
	check("MAP-03-items-reachable",r.pickups.keys().all(func(c):return r.floors.has(c)))
	r.start();r.paused=true;var t=r.time;r.tick();check("TIME-01-pause",r.time==t)
	r=quiet();r.request_direction(Vector2i.RIGHT);advance(r,0.5)
	check("MOVE-01-speed",r.player.pos.distance_to(Vector2(2.6,9))<0.001,str(r.player.pos))
	r=quiet();r.player.pos=Vector2(1,1);r.player.dir=Vector2i.LEFT;r.request_direction(Vector2i.LEFT);advance(r,1)
	check("MOVE-02-walls",r.player.pos==Vector2(1,1))
	r=quiet();r.player.pos=Vector2(3.8,3);r.player.dir=Vector2i.RIGHT;r.request_direction(Vector2i.UP);advance(r,0.15)
	check("MOVE-03-buffered-turn",absf(r.player.pos.x-4)<0.001 and r.player.pos.y<3,str(r.player.pos))
	check("DRIFT-01-new-turn",r.drift_until>0 and r.drift_ready>0)
	var drift=r.drift_ready;advance(r,0.35);check("DRIFT-02-held-no-farming",r.drift_ready==drift)
	r=quiet();r.player.pos=Vector2(3.1,3);r.player.dir=Vector2i.RIGHT;r.request_direction(Vector2i.UP);advance(r,0.4)
	check("DRIFT-03-outside-window",r.drift_until<0)
	r=quiet();r.energy=39;check("DASH-01-insufficient",not r.request_dash() and r.energy==39)
	r.energy=0;check("DASH-02-empty",not r.request_dash() and r.energy==0)
	r.energy=40;check("DASH-03-exact",r.request_dash() and r.energy==0)
	check("DASH-04-cooldown",not r.request_dash())
	r=quiet();r.player.pos=Vector2(1,1);r.player.dir=Vector2i.LEFT;check("DASH-05-blocked-no-cost",not r.request_dash() and r.energy==100)
	r=quiet();r.pickups[Vector2i(2,9)]="pellet";r.pickups[Vector2i(3,9)]="pellet";r.request_dash();advance(r,0.15)
	check("DASH-06-distance",r.player.pos.distance_to(Vector2(3,9))<0.001,str(r.player.pos))
	check("COLLECT-01-swept-single",r.score==20 and r.energy==70,"score=%d energy=%f"%[r.score,r.energy])
	r.collect(Vector2i(2,9),r.time);check("COLLECT-02-no-duplicate",r.score==20)
	var toi=Rules.segment_toi(Vector2.ZERO,Vector2(2,0),Vector2(2,0),Vector2.ZERO,0.6)
	check("COLLIDE-01-relative-sweep",absf(toi-0.35)<0.00001)
	r=quiet();r.tuning.ghost_speed=0.0;r.ghosts[0].state="chase";r.ghosts[0].pos=Vector2(1.7,9);r.pickups[Vector2i(2,9)]="power";r.request_dash();advance(r,0.15)
	check("COLLIDE-02-later-power-cannot-save",r.lives==2 and r.score==0 and r.power_until<0)
	r=quiet();r.tuning.ghost_speed=0.0;r.ghosts[0].state="chase";r.ghosts[0].pos=Vector2(2.9,9);r.pickups[Vector2i(2,9)]="power";r.request_dash();advance(r,0.15)
	check("COLLIDE-03-earlier-power-capture",r.lives==3 and r.score==250 and r.ghosts[0].state=="returning","score=%d state=%s"%[r.score,r.ghosts[0].state])
	check("FLOW-01-capture",r.flow==1.5 and r.combo==1)
	var oldscore=r.score;r.capture(r.ghosts[0],r.time);check("CAPTURE-01-returning-no-farming",r.score==oldscore)
	r.ghosts[0].pos=Vector2(r.ghosts[0].home);r.tick();advance(r,1.6)
	check("CAPTURE-02-window-immunity",r.ghosts[0].immune==r.window_id and r.ghosts[0].state!="vulnerable")
	r=quiet();r.tuning.ghost_speed=0
	for i in [0,1]:r.ghosts[i].state="chase";r.ghosts[i].pos=Vector2(1.8,9)
	r.request_dash();advance(r,0.15);check("LIVES-01-overlapping-ghosts",r.lives==2)
	r=quiet();r.flow=3.0;r.flow_until=0.1;advance(r,0.2);check("FLOW-02-expiry",r.flow==1.0)
	r=quiet();r.ghosts[0].state="vulnerable";r.power_until=0.1;advance(r,0.2);check("POWER-01-expiry",r.ghosts[0].state!="vulnerable")
	r=quiet();r.pickups[Vector2i(2,9)]="power";r.collect(Vector2i(2,9),0);var end=r.power_until
	r.time=2;r.pickups[Vector2i(3,9)]="power";r.collect(Vector2i(3,9),2)
	check("POWER-02-replace-duration",r.power_until==8 and end==6 and r.window_id==2)
	r=quiet();var candidate=r.floors.duplicate();candidate[Rules.OPEN_CELL]=true;candidate.erase(Rules.CLOSE_CELL)
	check("GRAPH-01-valid-swap",r.topology_valid(candidate))
	r.queue_topology();r.time=1.6;r.update_topology();check("GRAPH-02-atomic-swap",r.graph_version==1 and r.floors.has(Rules.OPEN_CELL) and not r.floors.has(Rules.CLOSE_CELL))
	r=quiet();r.player.pos=Vector2(Rules.CLOSE_CELL);r.queue_topology();r.time=1.6;r.update_topology()
	check("GRAPH-03-occupied-defer",r.graph_version==0 and not r.topology.is_empty())
	r.time=4.6;r.update_topology();check("GRAPH-04-cancel-after-limit",r.graph_version==0 and r.topology.is_empty())
	r=quiet();candidate=r.floors.duplicate();candidate[Vector2i(99,99)]=true;check("GRAPH-05-isolated-rejected",not r.topology_valid(candidate))
	r.score=99;r.flow=3;r.energy=5;r.reset();check("RESET-01-clean",r.score==0 and r.flow==1 and r.energy==100 and r.time==0 and r.status=="ready")
	var snapshots:Array=[]
	for fps in [30,60,144]:
		r=quiet();r.request_direction(Vector2i.RIGHT)
		var accumulator:=0.0
		for frame in fps*2:
			accumulator+=1.0/fps
			while accumulator+0.000000001>=Rules.STEP:r.tick();accumulator-=Rules.STEP
		snapshots.append([r.player.pos,r.score,r.energy,r.time])
	check("TIME-02-30-60-144-equivalence",snapshots[0]==snapshots[1] and snapshots[1]==snapshots[2],str(snapshots))
	var path="user://mv-test-"+str(Time.get_ticks_usec())+".json"
	var data=Store.read_settings(path);check("STORE-01-missing-defaults",data.record==0 and data.quality==2)
	data.record=1234;data.quality=1;data.mute=true
	check("STORE-02-save",Store.write_settings(data,path)==OK)
	var loaded=Store.read_settings(path);check("STORE-03-reload",loaded.record==1234 and loaded.quality==1 and loaded.mute)
	var file=FileAccess.open(path,FileAccess.WRITE);file.store_string("{broken");file.close()
	loaded=Store.read_settings(path);check("STORE-04-corrupt-defaults",loaded.record==0)
	# Clean only files created by this run, including its corrupted-file backup.
	var dir=DirAccess.open("user://")
	for filename in dir.get_files():
		if filename.begins_with(path.get_file()):dir.remove(filename)
	var output=FileAccess.open("res://evidencias/testes_logica.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"suite":"MV rules and persistence","engine":Engine.get_version_info().string,"executed":results.size(),"passed":results.size()-failed,"failed":failed,"results":results},"\t"));output.close()
	print("MV_TEST_RESULT executed=",results.size()," failed=",failed)
	quit(1 if failed>0 else 0)
