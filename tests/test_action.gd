extends SceneTree
const Rules=preload("res://scripts/rules.gd")
const Store=preload("res://scripts/storage.gd")
var results:Array=[]
var failed:=0
func _initialize() -> void:call_deferred("run")
func check(id:String,ok:bool) -> void:
	results.append({"id":id,"passed":ok})
	if not ok:failed+=1
	print("PASS " if ok else "FAIL ",id)
func quiet():
	var r=Rules.new();r.start();r.player.dir=Vector2i.ZERO
	for g in r.ghosts:g.release=100000.0
	r.pickups.clear();r.pickups[Vector2i(15,1)]="pellet"
	return r
func path(a:Vector2,b:Vector2) -> Array:return [{"a":a,"b":b,"t0":0.0,"t1":1.0}]
func powered():
	var r=quiet();r.pickups[Vector2i(1,9)]="power";r.collect(Vector2i(1,9),0.0)
	return r
func run() -> void:
	var r=quiet();r.time=7.3;r.tick()
	check("PRESSURE-01-advance-warning",r.pressure_level==0 and r.events.any(func(e):return e.type=="pressure_warning"))
	r.tick();check("PRESSURE-02-warning-once",not r.events.any(func(e):return e.type=="pressure_warning"))
	r.time=8;r.tick();check("PRESSURE-03-tier-after-warning",r.pressure_level==1)
	r.time=20;r.tick();r.time=32;r.tick();check("PRESSURE-04-bounded-progression",r.pressure_level==3)
	r.time=200;r.tick();check("PRESSURE-05-speed-cap",r.pressure_level==3 and 1+0.04*r.pressure_level<=1.12+0.000001)
	r=quiet();r.time=7.3;r.paused=true;r.tick();check("PRESSURE-06-pause-safe",r.pressure_level==0 and r.pressure_warned==0 and r.time==7.3)
	r.reset();check("PRESSURE-07-restart-clean",r.pressure_level==0 and r.pressure_warned==0)
	var gap=Rules.path_clearance(path(Vector2(0,0),Vector2(2,0)),path(Vector2(2,0.75),Vector2(0,0.75)))
	check("NEAR-01-relative-swept-clearance",absf(gap-0.75)<0.000001)
	r=quiet();r.energy=60;r.ghosts[0].state="chase";r.ghosts[0].pos=Vector2(3,9)
	var stationary:Array=[]
	for g in r.ghosts:stationary.append(path(g.pos,g.pos))
	r.player.previous=Vector2(2,8.25);r.player.pos=Vector2(3,8.25)
	r.update_close_passes(path(r.player.previous,r.player.pos),stationary)
	check("NEAR-02-approach-no-premature-reward",r.energy==60 and r.close_passes.has(0))
	r.player.previous=r.player.pos;r.player.pos=Vector2(4.5,8.25)
	r.update_close_passes(path(r.player.previous,r.player.pos),stationary)
	check("NEAR-03-reward-after-safe-exit",r.energy==66 and r.events.any(func(e):return e.type=="near_miss"))
	r.player.previous=Vector2(2,8.25);r.player.pos=Vector2(4.5,8.25)
	r.update_close_passes(path(r.player.previous,r.player.pos),stationary)
	check("NEAR-04-per-opponent-cooldown",r.energy==66)
	r.time=4;r.player.previous=Vector2(2,9);r.player.pos=Vector2(4,9)
	r.update_close_passes(path(r.player.previous,r.player.pos),stationary)
	check("NEAR-05-collision-never-rewarded",r.energy==66 and not r.close_passes.has(0))
	r.ghosts[0].state="vulnerable";r.player.previous=Vector2(2,8.25);r.player.pos=Vector2(4.5,8.25)
	r.update_close_passes(path(r.player.previous,r.player.pos),stationary)
	check("NEAR-06-hunt-not-farmable",r.energy==66)
	r=quiet();check("RISK-01-requires-power",not r.request_risk() and r.energy==100)
	r=powered();r.paused=true;check("RISK-02-paused-no-cost",not r.request_risk() and r.energy==100)
	r.paused=false;r.energy=19;check("RISK-03-insufficient-no-cost",not r.request_risk() and r.energy==19)
	r.energy=100;check("RISK-04-explicit-cost-and-deadline",r.request_risk() and r.energy==80 and r.risk.deadline==r.power_until)
	check("RISK-05-no-double-charge",not r.request_risk() and r.energy==80)
	for i in 2:
		r.ghosts[i].state="vulnerable";r.capture(r.ghosts[i],0.5+i)
	check("RISK-06-two-captures-reward",r.risk.state=="success" and r.risk.progress==2 and r.score==1250 and r.energy==100)
	var score:int=r.score;r.finish_risk(true)
	check("RISK-07-once-per-phase",not r.request_risk() and r.score==score)
	r=powered();r.request_risk();r.time=6;r.tick()
	check("RISK-08-expiry-no-life-penalty",r.risk.state=="failed" and r.lives==3 and r.energy==80)
	r=powered();r.request_risk();r.pickups[Vector2i(2,9)]="power";r.collect(Vector2i(2,9),1.0)
	check("RISK-09-new-window-cannot-extend-wager",r.risk.state=="failed" and r.window_id==2)
	r=powered();r.request_risk();r.close_passes[0]={"dash":true};r.die()
	check("RISK-10-death-fails-and-clears-escape",r.risk.state=="failed" and r.close_passes.is_empty() and r.lives==2)
	r=powered();r.request_risk();r.reset();check("RISK-11-restart-offers-new-attempt",r.risk.state=="available" and r.energy==100)
	r=powered();r.time=4.6;r.tick();check("POWER-03-warning-before-expiry",r.events.any(func(e):return e.type=="power_warning") and r.power_until>r.time)
	r.tick();check("POWER-04-warning-once",not r.events.any(func(e):return e.type=="power_warning"))
	var settings=Store.defaults();check("ACCESS-01-default-camera-strength",settings.camera_motion==0.65)
	var f=FileAccess.open("res://evidencias/testes_acao.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"suite":"Action refinement: pressure, escape geometry, optional risk","executed":results.size(),"passed":results.size()-failed,"failed":failed,"results":results},"\t"));f.close()
	quit(1 if failed else 0)
