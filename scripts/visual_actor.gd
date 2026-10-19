extends Node3D
const Models=preload("res://scripts/models.gd")
@export var ghost_actor:=false
@export var tint:=Color("3fdcff")
var model:Node3D
var reflection:Node3D
var frames:Array=[]
var last_state:=""

func _ready() -> void:
	model=Models.ghost(tint) if ghost_actor else Models.player()
	add_child(model)
	reflection=Models.reflected(model,tint if ghost_actor else Color("e6a526"))
	add_child(reflection)
	for i in 8: frames.append(Models.ghost_mesh(i*TAU/8) if ghost_actor else Models.pac_mesh(0.08+0.38*i/7.0))

func animate(t:float, direction:Vector2i, state:String="", power_time:float=0.0,reduce_motion:bool=false) -> void:
	if direction!=Vector2i.ZERO: rotation.y=lerp_angle(rotation.y, -atan2(direction.y,direction.x),0.25)
	var body:MeshInstance3D=model.get_node("Body")
	var reflected_body:MeshInstance3D=reflection.get_node("Body")
	var frame:int=int(t*12)%8
	if not ghost_actor:frame=int((sin(t*18)*0.5+0.5)*7)
	body.mesh=frames[frame];reflected_body.mesh=frames[frame]
	model.position.y=0.57+(0.0 if reduce_motion else 0.035*sin(t*6)) if not ghost_actor else 0.12+(0.0 if reduce_motion else 0.045*sin(t*4))
	reflection.position.y=-model.position.y
	if ghost_actor:
		var color:=tint
		if state=="vulnerable":color=Color("3eaeff") if power_time>1.5 or int(t*6)%2==0 else Color("c5e9ff")
		if state=="returning":color=Color("9daabf")
		var mat:StandardMaterial3D=body.material_override
		mat.albedo_color=Color(color,0.74);mat.emission=color
		body.visible=state!="returning"
		reflected_body.visible=body.visible
		var refmat:StandardMaterial3D=reflected_body.material_override
		refmat.albedo_color=Color(color,0.22)
