extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var options:Dictionary={}
	for arg in OS.get_cmdline_user_args():
		if arg.contains("="):options[arg.get_slice("=",0)]=arg.get_slice("=",1)
	var r=load("res://scripts/rules.gd").new(73021)
	var bot=load(get_script().resource_path.get_base_dir().path_join("action_bot.gd")).new()
	bot.caution=float(options.get("--caution","1.5"))
	var initial={"seed":73021,"player":str(r.player.pos),"dir":str(r.player.dir),"lives":r.lives,"energy":r.energy,"pickups":[],"ghosts":[]}
	for c in r.pickups:initial.pickups.append([c.x,c.y,r.pickups[c]])
	for g in r.ghosts:initial.ghosts.append({"pos":str(g.pos),"state":g.state,"release":g.release,"dir":str(g.dir)})
	r.start()
	var tape:Array=[]
	var playback:bool=options.has("--read-tape")
	if playback:tape=JSON.parse_string(FileAccess.get_file_as_string(options["--read-tape"]))
	var seconds:=float(options.get("--seconds","45"))
	var samples:Array=[]
	var event_counts:Dictionary={}
	var event_log:Array=[]
	var max_combo:=0
	var max_flow:=1.0
	for tick in roundi(seconds*120):
		var cmd:Dictionary=tape[tick] if playback else bot.commands(r)
		if not playback:tape.append(cmd)
		bot.apply(r,cmd)
		r.tick()
		max_combo=maxi(max_combo,r.combo);max_flow=maxf(max_flow,r.flow)
		for e in r.events:
			event_counts[e.type]=event_counts.get(e.type,0)+1
			if e.type!="pellet":event_log.append({"tick":tick,"time":r.time,"type":e.type,"pos":str(e.pos)})
		if tick%120==0:samples.append({"seconds":tick/120.0,"pos":str(r.player.pos),"lives":r.lives,"score":r.score,"status":r.status,"flow":r.flow})
	if options.has("--write-tape"):
		var f=FileAccess.open(options["--write-tape"],FileAccess.WRITE);f.store_string(JSON.stringify(tape));f.close()
	var report={"initial":initial,"ticks":tape.size(),"duration_requested":seconds,"simulation_seconds":r.time,"status":r.status,"lives":r.lives,"score":r.score,"events":event_counts,"event_log":event_log,"max_combo":max_combo,"max_flow":max_flow,"samples":samples,"tape_replayed":playback,"caution":bot.caution}
	var f=FileAccess.open(options.get("--out","/tmp/neogrid-compare.json"),FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("COMPARISON_RESULT ",JSON.stringify({"score":r.score,"lives":r.lives,"seconds":r.time,"status":r.status,"max_combo":max_combo,"events":event_counts}))
	quit()
