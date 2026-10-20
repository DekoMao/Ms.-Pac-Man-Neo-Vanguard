extends Node3D
const Models=preload("res://scripts/models.gd")
@export var ghost_actor:=false
@export var tint:=Color("3fdcff")
var model:Node3D
var reflection:Node3D
var frames:Array=[]
var last_state:=""
var action_heat:=0.0
var happy_heat:=0.0
var turn_lean:=0.0
var previous_direction:=Vector2i.ZERO
func react(kind:String) -> void:
	if kind=="dash":action_heat=1
	elif kind in ["capture","bonus_caught"]:happy_heat=1
	elif kind=="drift":turn_lean=0.16
func reset_expression() -> void:
	action_heat=0;happy_heat=0;turn_lean=0;previous_direction=Vector2i.ZERO
	model.scale=Vector3.ONE;model.rotation=Vector3.ZERO


func _ready() -> void:
	model=Models.ghost(tint) if ghost_actor else Models.player()
	add_child(model)
	reflection=Models.reflected(model,tint if ghost_actor else Color("e6a526"))
	add_child(reflection)
	for i in 8: frames.append(Models.ghost_mesh(i*TAU/8) if ghost_actor else Models.pac_mesh(0.08+0.38*i/7.0))

func animate(t:float, direction:Vector2i, state:String="", power_time:float=0.0,reduce_motion:bool=false,dt:float=1.0/60.0) -> void:
	if direction!=Vector2i.ZERO and previous_direction!=Vector2i.ZERO and direction!=previous_direction and direction!=-previous_direction:turn_lean=Vector2(previous_direction).cross(Vector2(direction))*0.13
	if direction!=Vector2i.ZERO:previous_direction=direction
	action_heat=move_toward(action_heat,0,dt*4);happy_heat=move_toward(happy_heat,0,dt*3);turn_lean=move_toward(turn_lean,0,dt*0.6)
	model.rotation.z=0 if reduce_motion else turn_lean
	model.scale=Vector3.ONE if reduce_motion else Vector3(1+action_heat*0.18-happy_heat*0.08,1-action_heat*0.12+happy_heat*0.12,1-action_heat*0.06)
	if direction!=Vector2i.ZERO: rotation.y=lerp_angle(rotation.y, -atan2(direction.y,direction.x),0.25)
	var body:MeshInstance3D=model.get_node("Body")
	var reflected_body:MeshInstance3D=reflection.get_node("Body")
	var frame:int=int(t*12)%8
	if not ghost_actor:frame=int((sin(t*18)*0.5+0.5)*7)
	body.mesh=frames[frame];reflected_body.mesh=frames[frame]
	model.position.y=0.57+(0.0 if reduce_motion else 0.035*sin(t*6)) if not ghost_actor else 0.12+(0.0 if reduce_motion else 0.045*sin(t*4))
	reflection.position.y=-model.position.y
	if ghost_actor:
		if not reduce_motion:
			var breath:float=sin(t*(8.0 if state=="vulnerable" else 4.0))*0.02
			model.scale=Vector3(1-breath,1+breath,1-breath)
		var color:=tint
		if state=="vulnerable":color=Color("2455c4") if reduce_motion or power_time>1.5 or int(t*3)%2==0 else Color("cadbff")
		if state=="returning":color=Color("9daabf")
		if state=="stunned":
			color=Color("b79ee4")
			if not reduce_motion:model.rotation.z=sin(t*12)*0.12
		var mat:StandardMaterial3D=body.material_override
		mat.albedo_color=Color(color,1.0);mat.emission=color
		body.visible=state!="returning"
		reflected_body.visible=body.visible
		var refmat:StandardMaterial3D=reflected_body.material_override
		refmat.albedo_color=Color(color,0.13)
		model.get_node("Mouth").visible=state=="vulnerable"
		reflection.get_node("Mouth").visible=state=="vulnerable"
		var look:Vector3=global_basis.inverse()*Vector3(direction.x,0,direction.y)
		for i in 2:
			var blink:bool=not reduce_motion and state not in ["returning","vulnerable"] and fmod(t,4.8)>4.68
			model.get_node("Eye%d"%i).scale=Vector3(0.65,0.18 if blink else (1.48 if state=="vulnerable" else 1.3),0.95)
			model.get_node("Pupil%d"%i).scale=Vector3(0.6,0.16 if blink else 1.05,1)
			var side:float=-1.0 if i==0 else 1.0
			model.get_node("Pupil%d"%i).position=Vector3(0.395,0.60+look.x*0.018,side*0.155+look.z*0.03)
			model.get_node("Glint%d"%i).visible=state!="vulnerable"
			reflection.get_node("Glint%d"%i).visible=state!="vulnerable"

