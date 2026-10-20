class_name NeoModels
extends RefCounted
## Malhas, materiais e personagens originais gerados no motor.

static func material(color: Color, emission: float = 0.0, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = 0.25
	mat.emission_enabled = emission > 0.0
	mat.emission = color
	mat.emission_energy_multiplier = emission
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat

static func mesh_node(mesh: Mesh, mat: Material, pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = mesh
	n.material_override = mat
	n.position = pos
	return n

static func sphere(radius: float, height: float = -1.0) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0 if height < 0.0 else height
	mesh.radial_segments = 32
	mesh.rings = 20
	return mesh

static func add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void:
	# Godot uses clockwise front faces.
	if (b-a).cross(c-a).dot(normal) > 0.0:
		var swap := b; b=c; c=swap
	for v in [a,b,c]:
		st.set_normal(normal)
		st.add_vertex(v)

static func face(st: SurfaceTool, points: Array, normal: Vector3) -> void:
	for i in range(1,points.size()-1): add_tri(st, points[0], points[i], points[i+1],normal)

static func bevel_box(size: Vector3, bevel: float = 0.065) -> ArrayMesh:
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var h := size*0.5
	# Six flat faces, twelve bevel strips and eight corner triangles.
	for axis in 3:
		var u := (axis+1)%3;var v := (axis+2)%3
		for sign_value in [-1.0,1.0]:
			var normal := Vector3.ZERO;normal[axis]=sign_value
			var points: Array=[]
			for uv in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
				var p := Vector3.ZERO;p[axis]=sign_value*h[axis];p[u]=uv.x*(h[u]-bevel);p[v]=uv.y*(h[v]-bevel);points.append(p)
			face(st,points,normal)
	for axis in 3:
		var u := (axis+1)%3;var v := (axis+2)%3
		for su in [-1.0,1.0]:
			for sv in [-1.0,1.0]:
				var points: Array=[]
				for corner in [Vector2(-1,0),Vector2(1,0),Vector2(1,1),Vector2(-1,1)]:
					var p := Vector3.ZERO;p[axis]=corner.x*(h[axis]-bevel)
					p[u]=su*(h[u]-bevel*corner.y);p[v]=sv*(h[v]-bevel*(1.0-corner.y));points.append(p)
				var normal:=Vector3.ZERO;normal[u]=su;normal[v]=sv
				face(st,points,normal.normalized())
	for sx in [-1.0,1.0]:
		for sy in [-1.0,1.0]:
			for sz in [-1.0,1.0]:
				var s:=Vector3(sx,sy,sz);var points:Array=[]
				for axis in 3:
					var p:=s*(h-Vector3.ONE*bevel);p[axis]=s[axis]*h[axis];points.append(p)
				face(st,points,s.normalized())
	return st.commit()

static func pac_mesh(angle: float) -> ArrayMesh:
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r := 0.47
	for zring in 24:
		var lat0 := -PI/2.0+PI*zring/24.0
		var lat1 := -PI/2.0+PI*(zring+1)/24.0
		for t in 48:
			var theta0 := angle+(TAU-2*angle)*t/48.0
			var theta1 := angle+(TAU-2*angle)*(t+1)/48.0
			var points:Array=[]
			for pair in [Vector2(lat0,theta0),Vector2(lat1,theta0),Vector2(lat1,theta1),Vector2(lat0,theta1)]:
				points.append(Vector3(cos(pair.x)*cos(pair.y),cos(pair.x)*sin(pair.y),sin(pair.x))*r)
			for ids in [[0,2,1],[0,3,2]]:
				for id in ids:
					st.set_normal(points[id].normalized());st.add_vertex(points[id])
	var mesh:=st.commit()
	var inside:=SurfaceTool.new();inside.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1.0,1.0]:
		var normal:=Vector3(-sin(angle),side*cos(angle),0)
		for i in 24:
			var a:=-PI/2+PI*i/24.0;var b:=-PI/2+PI*(i+1)/24.0
			var pa:=Vector3(cos(a)*cos(angle),side*cos(a)*sin(angle),sin(a))*r
			var pb:=Vector3(cos(b)*cos(angle),side*cos(b)*sin(angle),sin(b))*r
			add_tri(inside,Vector3.ZERO,pa,pb,normal)
	inside.commit(mesh)
	return mesh

static func player() -> Node3D:
	var root:=Node3D.new();root.name="Protagonista"
	var gold:=material(Color("ffd15b"),0.45,0.15)
	gold.cull_mode=BaseMaterial3D.CULL_DISABLED
	var body:=mesh_node(pac_mesh(0.25),null);body.name="Body";body.set_surface_override_material(0,gold);body.set_surface_override_material(1,material(Color("6e301c"),0.0,0.1));root.add_child(body)
	for side in [-1.0,1.0]:
		var white:=mesh_node(sphere(0.101),material(Color("fff7e3")),Vector3(0.18,0.29,side*0.32));white.scale=Vector3(0.7,1.25,0.67);root.add_child(white)
		var pupil:=mesh_node(sphere(0.052),material(Color("0c1737")),Vector3(0.228,0.305,side*0.37));root.add_child(pupil)
		var lash:=mesh_node(bevel_box(Vector3(0.045,0.12,0.035),0.01),material(Color("0a132a")),Vector3(0.18,0.4,side*0.33));lash.rotation.z=-0.4;root.add_child(lash)
		var bow:=mesh_node(sphere(0.17),material(Color("fa368f"),0.1,0.35),Vector3(-0.11,0.48,side*0.15));bow.scale=Vector3(0.7,0.74,1.15);bow.rotation.x=side*0.5;root.add_child(bow)
		var shoe:=mesh_node(sphere(0.13),material(Color("ff8f34"),0.0,0.2),Vector3(0.02,-0.40,side*0.22));shoe.scale=Vector3(1.3,0.65,0.75);root.add_child(shoe)
	root.add_child(mesh_node(sphere(0.09),material(Color("ff98cd"),0.3),Vector3(-0.10,0.51,0)))
	return root

static func ghost_mesh(phase: float = 0.0) -> ArrayMesh:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings:=20;var slices:=48
	for ring in rings:
		for slice in slices:
			var points:Array=[]
			for ij in [Vector2(ring,slice),Vector2(ring+1,slice),Vector2(ring+1,slice+1),Vector2(ring,slice+1)]:
				var q:float=ij.x/rings;var a:float=TAU*ij.y/slices
				var rad:=0.36
				var y:float=0.04+q*0.98
				if q>0.55:
					var dome:float=(q-0.55)/0.45*PI*0.5
					rad=0.36*cos(dome);y=0.58+0.36*sin(dome)
				else:
					y=0.07+q/0.55*0.51+0.065*cos(a*6+phase)*pow(1-q/0.55,2)
				points.append(Vector3(cos(a)*rad,y,sin(a)*rad))
			for ids in [[0,2,1],[0,3,2]]:
				for id in ids:
					var p:Vector3=points[id]
					var normal:=Vector3(p.x,maxf(0,p.y-0.58),p.z).normalized()
					st.set_normal(normal);st.add_vertex(p)
	return st.commit()

static func ghost(color: Color) -> Node3D:
	var root:=Node3D.new();root.name="Fantasma"
	var mat:=material(color,0.32,0.08)
	mat.rim_enabled=true;mat.rim=0.65;mat.rim_tint=0.6
	mat.roughness=0.28
	mat.cull_mode=BaseMaterial3D.CULL_BACK
	var shell:=mesh_node(ghost_mesh(),mat);shell.name="Body";root.add_child(shell)
	for i in 2:
		var side:float=-1.0 if i==0 else 1.0
		var eye:=mesh_node(sphere(0.125),material(Color("f5fbff"),0.05),Vector3(0.31,0.60,side*0.155))
		eye.name="Eye%d"%i;eye.scale=Vector3(0.65,1.3,0.95);root.add_child(eye)
		var pupil:=mesh_node(sphere(0.056),material(Color("142451")),Vector3(0.395,0.60,side*0.155))
		pupil.name="Pupil%d"%i;pupil.scale=Vector3(0.6,1.05,1);root.add_child(pupil)
		var glint:=mesh_node(sphere(0.017),material(Color.WHITE),Vector3(0.43,0.626,side*0.155-0.017))
		glint.name="Glint%d"%i;root.add_child(glint)
	var mouth:=Node3D.new();mouth.name="Mouth";mouth.visible=false;root.add_child(mouth)
	for i in 5:
		var lip=mesh_node(bevel_box(Vector3(0.035,0.024,0.083),0.006),material(Color("f5fbff"),0.1),Vector3(0.345,0.30,-0.16+i*0.08))
		lip.rotation.x=0.42 if i%2==0 else -0.42;mouth.add_child(lip)
	return root

static func reflected(source: Node3D, color: Color) -> Node3D:
	var duplicate:Node3D=source.duplicate()
	var mat:=material(Color(color,0.23),0.25)
	mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	for node in duplicate.find_children("*","MeshInstance3D",true,false):
		node.material_override=mat;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	duplicate.scale.y=-1.0
	return duplicate


static func bonus_fruit() -> Node3D:
	var root:=Node3D.new();root.name="FrutaBonus"
	for side in [-1.0,1.0]:
		root.add_child(mesh_node(sphere(0.20),material(Color("ff609f"),0.3,0.2),Vector3(side*0.16,0.40,0)))
		var stem:=CylinderMesh.new();stem.top_radius=0.018;stem.bottom_radius=0.018;stem.height=0.32
		var n:=mesh_node(stem,material(Color("aaffb0"),0.3),Vector3(side*0.08,0.67,0));n.rotation.z=side*0.45;root.add_child(n)
	var ring:=TorusMesh.new();ring.inner_radius=0.39;ring.outer_radius=0.42
	var halo:=mesh_node(ring,material(Color("ffe188"),0.65),Vector3(0,0.08,0));halo.name="Halo";root.add_child(halo)
	return root
