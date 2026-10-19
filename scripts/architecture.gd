extends RefCounted
## Modular art direction: metal shells, recessed neon displays and floor spill.
## All decorative geometry stays outside the corridor collision graph.
const Models=preload("res://scripts/models.gd")
const CELL:=1.4
const HEIGHT:=1.16
static var materials:Dictionary={}
static var cube:BoxMesh

static func box(parent:Node3D,size:Vector3,pos:Vector3,color:Color,emission:float=0.0,metal:float=0.0) -> MeshInstance3D:
	var mesh:=BoxMesh.new();mesh.size=size
	var key:=str(color)+"/"+str(emission)+"/"+str(metal)
	if not materials.has(key):
		materials[key]=Models.material(color,emission,metal)
		if metal>0.3:materials[key].roughness=0.45
	var node:=Models.mesh_node(mesh,materials[key],pos)
	parent.add_child(node)
	return node

static func glow(parent:Node3D,size:Vector2,pos:Vector3,color:Color,strength:float=0.3) -> void:
	var plane:=PlaneMesh.new();plane.size=size
	var mat:=ShaderMaterial.new();mat.shader=load("res://assets/light_spill.gdshader")
	mat.set_shader_parameter("tint",color);mat.set_shader_parameter("strength",strength)
	var n:=Models.mesh_node(plane,mat,pos);n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(n)

static func decorate(wall:MeshInstance3D,cell:Vector2i,floors:Dictionary,primary:Color,secondary:Color,footprint:Rect2) -> void:
	wall.name="Metal_%d_%d"%[cell.x,cell.y]
	for d in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]:
		if not floors.has(cell+d):continue
		var face:=Node3D.new();face.name="Fachada";wall.add_child(face)
		face.rotation.y=-atan2(d.y,d.x)+PI/2
		var center:Vector2=footprint.get_center()
		face.position=Vector3(0,0,0)
		if d.x!=0:face.position.x=(footprint.end.x if d.x>0 else footprint.position.x)-center.x
		if d.y!=0:face.position.z=(footprint.end.y if d.y>0 else footprint.position.y)-center.y
		face.scale.x=(footprint.size.x if d.y!=0 else footprint.size.y)/CELL
		var accent:Color=secondary if (cell.x+cell.y*3)%4==0 else primary
		# Layered metallic frame around a luminous inset; no luminous flat roof.
		box(face,Vector3(1.36,0.10,0.14),Vector3(0,0.51,0),Color("424165"),0.02,0.65)
		box(face,Vector3(1.38,0.045,0.07),Vector3(0,0.57,0.04),primary,0.50)
		box(face,Vector3(1.36,0.10,0.14),Vector3(0,-0.49,0),Color("242540"),0,0.65)
		box(face,Vector3(1.32,0.025,0.05),Vector3(0,-0.43,0.08),accent,0.55)
		box(face,Vector3(1.14,0.70,0.04),Vector3(0,0.0,0.025),Color("0a0d21"),0,0.4)
		box(face,Vector3(0.99,0.54,0.045),Vector3(0,0.025,0.055),Color("303455"),0,0.55)
		var lit:bool=(cell.x*3+cell.y)%3!=0
		box(face,Vector3(0.88,0.42,0.025),Vector3(0,0.025,0.085),accent.darkened(0.14) if lit else accent.darkened(0.83),0.40 if lit else 0.1,0.15)
		for x in [-0.63,0.63]:
			box(face,Vector3(0.10,1.06,0.16),Vector3(x,0.0,0.035),Color("393955"),0.01,0.6)
			box(face,Vector3(0.027,0.63,0.025),Vector3(x,0.02,0.128),secondary,0.75)
		# Short service vents break the display repetition.
		for x in [-0.28,0.0,0.28]:
			box(face,Vector3(0.17,0.018,0.035),Vector3(x,-0.32,0.085),Color("69788e"),0,0.65)
		# A softened colored reflection and light pool, independent of SSR.
		glow(face,Vector2(1.32,0.85),Vector3(0,-HEIGHT*0.5+0.035,0.44),accent,0.23 if lit else 0.09)
		var reflection:=box(face,Vector3(0.87,0.36,0.008),Vector3(0,-0.78,0.085),Color(accent,0.12),0.25)
		reflection.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	batch(wall)

static func batch(wall:MeshInstance3D) -> void:
	# Preserve per-wall fading/topology while instancing its opaque metalwork.
	var groups:Dictionary={}
	for node in wall.find_children("*","MeshInstance3D",true,false):
		if not node.mesh is BoxMesh:continue
		var mat:StandardMaterial3D=node.material_override
		if mat.albedo_color.a<1.0:continue
		var id:=mat.get_instance_id()
		if not groups.has(id):groups[id]={"material":mat,"transforms":[]}
		var t:Transform3D=wall.global_transform.affine_inverse()*node.global_transform
		t.basis=t.basis*Basis.from_scale(node.mesh.size)
		groups[id].transforms.append(t)
		node.get_parent().remove_child(node);node.queue_free()
	if cube==null:cube=BoxMesh.new();cube.size=Vector3.ONE
	for group in groups.values():
		var mesh:=MultiMesh.new();mesh.transform_format=MultiMesh.TRANSFORM_3D
		mesh.mesh=cube;mesh.instance_count=group.transforms.size()
		for i in group.transforms.size():mesh.set_instance_transform(i,group.transforms[i])
		var instances:=MultiMeshInstance3D.new();instances.multimesh=mesh;instances.material_override=group.material
		instances.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;wall.add_child(instances)

static func deck(parent:Node3D,primary:Color,secondary:Color) -> void:
	box(parent,Vector3(25.5,0.7,20),Vector3(0,-0.52,0),Color("101225"),0,0.65)
	for z in [-9.5,9.5]:
		box(parent,Vector3(25.3,0.09,0.07),Vector3(0,-0.23,z),primary,0.75)
		box(parent,Vector3(25.3,0.045,0.07),Vector3(0,-0.65,z),secondary,0.6)
	for x in [-12.3,12.3]:
		box(parent,Vector3(0.08,0.09,19.0),Vector3(x,-0.23,0),primary,0.75)
	for i in 17:
		for z in [-9.8,9.8]:
			box(parent,Vector3(0.12,0.16,0.03),Vector3(-11.2+i*1.4,-0.45,z),secondary,0.7)

static func routes(parent:Node3D,floors:Dictionary,house:Array,primary:Color) -> void:
	# Narrow route edge markings leave the gold pellet line unobstructed.
	for c in floors:
		if house.has(c):continue
		for d in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]:
			if floors.has(c+d):continue
			var size:=Vector3(1.34,0.012,0.018) if d.y!=0 else Vector3(0.018,0.012,1.34)
			box(parent,size,Vector3((c.x-8)*CELL+d.x*0.56,0.014,(c.y-6)*CELL+d.y*0.56),primary.darkened(0.26),0.48)
