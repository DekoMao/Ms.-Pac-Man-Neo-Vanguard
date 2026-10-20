extends Node3D
## Presentation only. Gameplay and all hit areas live in fusion.gd.
const Models=preload("res://scripts/models.gd")
const CELL:=1.4
var game:Node3D
var cache_nodes:Dictionary={}
var bomb_nodes:Dictionary={}
var drop_nodes:Dictionary={}
var field_nodes:Dictionary={}
var revision:=-1

func cell_position(c:Vector2i,y:float=0) -> Vector3:return Vector3((c.x-8)*CELL,y,(c.y-6)*CELL)
func reset(g) -> void:
	game=g
	for n in get_children():remove_child(n);n.queue_free()
	cache_nodes.clear();bomb_nodes.clear();drop_nodes.clear();field_nodes.clear()
	if g.sim.mode!="fusion":return
	for c in g.sim.fusion.crates:
		var n:=cache();n.position=cell_position(c);add_child(n);cache_nodes[c]=n

func piece(parent:Node3D,size:Vector3,pos:Vector3,color:Color,glow:float=0) -> MeshInstance3D:
	var n:=Models.mesh_node(Models.bevel_box(size,0.025),Models.material(color,glow,0.5),pos);parent.add_child(n);return n
func cache() -> Node3D:
	var n:=Node3D.new();n.name="CacheEnergetico"
	piece(n,Vector3(1.02,0.08,1.02),Vector3(0,0.06,0),Color("34334b"))
	piece(n,Vector3(0.88,0.72,0.88),Vector3(0,0.46,0),Color("2d2633"))
	# Low amber cages read as destructible equipment, distinct from neon walls.
	for x in [-0.43,0.43]:
		for z in [-0.43,0.43]:piece(n,Vector3(0.07,0.83,0.07),Vector3(x,0.46,z),Color("ffb95b"),0.45)
	for y in [0.18,0.75]:
		for side in [-1.0,1.0]:
			piece(n,Vector3(0.91,0.045,0.035),Vector3(0,y,side*0.45),Color("f5b963"),0.45)
			piece(n,Vector3(0.035,0.045,0.91),Vector3(side*0.45,y,0),Color("f5b963"),0.45)
	for side in [-1.0,1.0]:
		for i in [-1,0,1]:
			var bar=piece(n,Vector3(0.06,0.45,0.025),Vector3(i*0.20,0.46,side*0.455),Color("e68b47"),0.15);bar.rotation.z=-0.42
	var core=Models.mesh_node(Models.sphere(0.14),Models.material(Color("fff0ae"),0.75),Vector3(0,0.89,0));n.add_child(core)
	return n

func bomb() -> Node3D:
	var n:=Node3D.new();n.name="BombaDePulso"
	n.add_child(Models.mesh_node(Models.sphere(0.31),Models.material(Color("22283b"),0,0.8),Vector3(0,0.35,0)))
	for y in [0.24,0.47]:
		var ring:=TorusMesh.new();ring.inner_radius=0.285;ring.outer_radius=0.315
		n.add_child(Models.mesh_node(ring,Models.material(Color("ffb767"),0.65,0.35),Vector3(0,y,0)))
	piece(n,Vector3(0.13,0.13,0.13),Vector3(0,0.69,0),Color("ffe2a0"),1)
	var halo:=TorusMesh.new();halo.inner_radius=0.40;halo.outer_radius=0.43
	var ring=Models.mesh_node(halo,Models.material(Color("ffbb71"),0.6),Vector3(0,0.035,0));ring.name="FuseRing";n.add_child(ring)
	return n

func drop(kind:String) -> Node3D:
	var n:=Node3D.new();n.name="Melhoria_"+kind
	var color:Color={"capacity":Color("77efff"),"range":Color("ffab69"),"shield":Color("9dffbf"),"energy":Color("fff18e")}.get(kind,Color.WHITE)
	var ring:=TorusMesh.new();ring.inner_radius=0.30;ring.outer_radius=0.34
	n.add_child(Models.mesh_node(ring,Models.material(color,0.5),Vector3(0,0.10,0)))
	var item=piece(n,Vector3(0.34,0.34,0.34),Vector3(0,0.39,0),color,0.5);item.rotation=Vector3(0.4,0.6,0.2)
	var text:=Label3D.new();text.text={"capacity":"+B","range":"+R","shield":"E","energy":"⚡"}.get(kind,"+")
	text.font=load("res://assets/DejaVuSans.ttf");text.font_size=40;text.pixel_size=0.006;text.position=Vector3(0,0.76,0);text.billboard=BaseMaterial3D.BILLBOARD_ENABLED;text.modulate=color;n.add_child(text)
	return n

func field(active:bool) -> Node3D:
	var n:=Node3D.new()
	var color:=Color("ffb668") if active else Color("ff765d")
	var plane:=PlaneMesh.new();plane.size=Vector2.ONE*1.13
	var mat:=Models.material(Color(color,0.35 if active else 0.13),0.6 if active else 0.2)
	n.add_child(Models.mesh_node(plane,mat,Vector3(0,0.035,0)))
	for side in [-1.0,1.0]:
		piece(n,Vector3(1.12,0.018,0.025),Vector3(0,0.05,side*0.55),color,0.6)
		piece(n,Vector3(0.025,0.018,1.12),Vector3(side*0.55,0.05,0),color,0.6)
	if active:
		piece(n,Vector3(0.18,0.32,1.05),Vector3(0,0.18,0),Color("ffe1a2"),0.95)
		piece(n,Vector3(1.05,0.25,0.18),Vector3(0,0.15,0),Color("ffc478"),0.8)
	return n

func update() -> void:
	if game==null:return
	visible=game.sim.mode=="fusion"
	if not visible:return
	var r=game.sim;var f=r.fusion
	for c in cache_nodes:cache_nodes[c].visible=f.crates.has(c)
	for id in bomb_nodes.keys():
		if not f.bombs.any(func(b):return b.id==id):bomb_nodes[id].queue_free();bomb_nodes.erase(id)
	for b in f.bombs:
		if not bomb_nodes.has(b.id):var n:=bomb();add_child(n);bomb_nodes[b.id]=n
		var n:Node3D=bomb_nodes[b.id];n.position=cell_position(b.cell)
		var left:float=maxf(0,b.at-r.time)
		var pulse:float=1.0 if game.settings.reduced else 1.0+sin(r.time*(15 if left<0.85 else 7))*0.045
		n.scale=Vector3.ONE*pulse;n.get_node("FuseRing").scale=Vector3.ONE*(0.75+0.25*left/f.FUSE)
	for c in drop_nodes.keys():
		if not f.drops.has(c):drop_nodes[c].queue_free();drop_nodes.erase(c)
	for c in f.drops:
		if not drop_nodes.has(c):var n:=drop(f.drops[c]);n.position=cell_position(c);add_child(n);drop_nodes[c]=n
		drop_nodes[c].visible=not f.flames.any(func(flame):return c in flame.cells)
	var fields:Dictionary={}
	for b in f.bombs:
		if b.at-r.time<=0.85:
			for c in f.ray_cells(r,b):fields[c]=false
	for flame in f.flames:
		for c in flame.cells:fields[c]=true
	for c in field_nodes.keys():
		if not fields.has(c) or field_nodes[c].active!=fields[c]:field_nodes[c].node.queue_free();field_nodes.erase(c)
	for c in fields:
		if not field_nodes.has(c):
			var n:=field(fields[c]);n.position=cell_position(c);add_child(n);field_nodes[c]={"node":n,"active":fields[c]}
