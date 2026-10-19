extends SceneTree
const Rules=preload("res://scripts/rules.gd")
const Map=preload("res://scripts/minimap.gd")
var results:Array=[]
var failures:=0

func _initialize() -> void:call_deferred("run")

func check(id:String,ok:bool,detail:String="") -> void:
	results.append({"id":id,"passed":ok,"detail":detail})
	if not ok:failures+=1
	print("PASS " if ok else "FAIL ",id," ",detail)

func balanced(progress:Dictionary) -> bool:
	return progress.total==progress.collected+progress.remaining and progress.remaining==progress.pellets+progress.powers+progress.fruits

func run() -> void:
	var r=Rules.new()
	var initial:Dictionary=r.pickup_progress()
	check("PROGRESS-01-initial-counts",balanced(initial) and initial.collected==0 and initial.percent==0 and initial.powers==5 and initial.fruits==1,str(initial))
	r.score=10000;r.flow=3.0
	check("PROGRESS-02-independent-of-score-flow",r.pickup_progress()==initial)
	r.collect(Vector2i(2,9),0.0)
	var after:Dictionary=r.pickup_progress()
	check("PROGRESS-03-normal-pellet",balanced(after) and after.collected==1 and after.pellets==initial.pellets-1 and after.remaining==initial.remaining-1)
	r.collect(Vector2i(2,9),0.0)
	check("PROGRESS-04-duplicate-contact-idempotent",r.pickup_progress()==after)
	r.collect(Vector2i(3,9),0.0)
	check("PROGRESS-05-fruit-is-required-item",r.pickup_progress().fruits==0 and r.pickup_progress().remaining==initial.remaining-2)
	r.collect(Vector2i(5,9),0.0)
	check("PROGRESS-06-power-count",r.pickup_progress().powers==initial.powers-1 and balanced(r.pickup_progress()))
	after=r.pickup_progress();r.die()
	check("PROGRESS-07-death-keeps-collected-state",r.pickup_progress()==after)
	r.reset()
	check("PROGRESS-08-restart-restores-counts",r.pickup_progress()==initial)
	r.start()
	for g in r.ghosts:g.release=100000.0
	r.request_direction(Vector2i.RIGHT);r.request_dash()
	for i in 18:r.tick()
	check("PROGRESS-09-dash-collects-once",r.pickup_progress().collected==2 and r.pickup_progress().remaining==initial.remaining-2 and balanced(r.pickup_progress()))
	after=r.pickup_progress();r.paused=true
	for i in 120:r.tick()
	check("PROGRESS-10-pause-keeps-counts",r.pickup_progress()==after)
	r.reset()
	for c in r.pickups.keys():
		if r.pickups.size()<=10:break
		r.collect(c,r.time)
	check("PROGRESS-11-last-ten-exact",r.pickup_progress().remaining==10 and balanced(r.pickup_progress()))
	for c in r.pickups.keys():
		if r.pickups.size()<=1:break
		r.collect(c,r.time)
	check("PROGRESS-12-not-complete-with-one-left",r.pickup_progress().remaining==1 and r.pickup_progress().percent<100)
	var last:Vector2i=r.pickups.keys()[0]
	r.player.pos=Vector2(last);r.player.previous=r.player.pos;r.player.dir=Vector2i.ZERO
	for g in r.ghosts:g.release=100000.0
	r.start();r.tick()
	check("PROGRESS-13-last-pickup-wins",r.status=="won" and r.pickup_progress().remaining==0 and r.pickup_progress().percent==100 and balanced(r.pickup_progress()))
	var map=Map.new();map.sim=r
	for dimensions in [Vector2(235,156),Vector2(510,390),Vector2(400,230)]:
		map.size=dimensions
		var layout:Dictionary=map.map_layout()
		check("MAP-SCALE-%dx%d"%[dimensions.x,dimensions.y],layout.cell>0 and layout.origin.x>=0 and layout.origin.y>=0 and layout.origin.x+layout.extent.x<=dimensions.x and layout.origin.y+layout.extent.y<=dimensions.y)
	map.free()
	var file=FileAccess.open("res://evidencias/testes_mapa.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"suite":"Map pickup progress and layout","engine":Engine.get_version_info().string,"executed":results.size(),"passed":results.size()-failures,"failed":failures,"results":results},"\t"));file.close()
	print("MAP_TEST_RESULT executed=",results.size()," failed=",failures)
	quit(1 if failures else 0)
