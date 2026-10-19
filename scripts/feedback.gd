extends Node3D
## Presentation only. Never changes time, movement, radii or collision results.
const Models=preload("res://scripts/models.gd")
var impact:=0.0
var dash_heat:=0.0
var power_heat:=0.0
var chain_heat:=0.0
var near_heat:=0.0
var threat:=0.0
var clock:=0.0
var effects:Array=[]

func update(dt:float,sim) -> void:
	clock+=dt
	impact=move_toward(impact,0.0,dt*4.5)
	dash_heat=move_toward(dash_heat,0.0,dt*5.0)
	power_heat=move_toward(power_heat,0.0,dt*0.9)
	chain_heat=move_toward(chain_heat,0.0,dt*2.2)
	near_heat=move_toward(near_heat,0.0,dt*2.5)
	var nearest:=10.0
	for g in sim.ghosts:
		if g.state in ["chase","scatter"]:nearest=minf(nearest,sim.player.pos.distance_to(g.pos))
	var target:=clampf((3.4-nearest)/2.8,0.0,1.0)
	threat=lerpf(threat,target,1-exp(-dt*7.0))
	for i in range(effects.size()-1,-1,-1):
		var e:Dictionary=effects[i]
		e.age+=dt
		var t:float=clampf(e.age/e.duration,0.0,1.0)
		if e.kind=="ring":
			e.node.scale=Vector3.ONE*lerpf(0.3,e.radius,1-pow(1-t,2))
			e.material.albedo_color.a=(1-t)*0.65
		else:
			e.node.position.y+=dt*0.65
			e.node.modulate.a=1-t*t
		if t>=1.0:e.node.queue_free();effects.remove_at(i)

func reset() -> void:
	impact=0;dash_heat=0;power_heat=0;chain_heat=0;near_heat=0;threat=0;clock=0
	for e in effects:e.node.queue_free()
	effects.clear()

func react(event:Dictionary,sim,reduced:bool) -> void:
	var color:=Color("ffd36c")
	var radius:=1.2
	var text:=""
	match event.type:
		"dash":dash_heat=1.0;impact=maxf(impact,0.28)
		"near_miss":near_heat=1;impact=0.4;text="POR UM FIO  +6E";radius=1.6
		"power":power_heat=1;impact=0.7;color=Color("63e9ff");radius=4.0;text="AGORA E SUA VEZ"
		"capture":
			var chain:int=event.get("chain",sim.combo)
			chain_heat=minf(1.5,0.5+chain*0.25);impact=0.35+chain*0.10
			color=Color("74eeff").lerp(Color("ffb8ea"),minf(1.0,chain/4.0))
			radius=1.8+chain*0.35;text="+%d  CADEIA %d"%[event.points,chain]
		"risk_success":color=Color("adffd0");radius=3.0;text="APOSTA +600";chain_heat=1.5
		"shield_armed":color=Color("64eaff");radius=2.0;text="ESCUDO ATIVO"
		"shield_hit":color=Color("64eaff");radius=2.5;text="IMPACTO ABSORVIDO";impact=0.35
		"magnet":color=Color("8affb9");radius=2.8;text="IMA ATIVO"
		"death":impact=0.8
		_:return
	if reduced:return
	var p:Vector2=event.pos
	var world:=Vector3((p.x-8)*1.4,0.04,(p.y-6)*1.4)
	var ring:=TorusMesh.new();ring.inner_radius=0.48;ring.outer_radius=0.52;ring.rings=32;ring.ring_segments=8
	var mat=Models.material(Color(color,0.65),1.0)
	mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	var node=Models.mesh_node(ring,mat,world);node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node);effects.append({"kind":"ring","node":node,"material":mat,"age":0.0,"duration":0.55 if event.type!="power" else 1.0,"radius":radius})
	if not text.is_empty():
		var caption:=Label3D.new();caption.text=text;caption.position=world+Vector3(0,1.5,0)
		caption.billboard=BaseMaterial3D.BILLBOARD_ENABLED;caption.font_size=48;caption.pixel_size=0.006
		caption.modulate=color;caption.outline_size=12;caption.no_depth_test=true
		add_child(caption);effects.append({"kind":"caption","node":caption,"age":0.0,"duration":1.2})

func camera_offset(motion:float) -> Vector3:
	return Vector3(sin(clock*47.0)*impact*0.065,cos(clock*39.0)*impact*0.045,0)*motion

func fov_offset(sim,motion:float) -> float:
	return (dash_heat*4.0+near_heat*1.1+threat*0.8-2.0*float(sim.time<sim.power_until)-chain_heat*0.6)*motion

