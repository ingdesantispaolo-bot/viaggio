extends SceneTree

const artifact_dir: String = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86/"

var frame_count: int = 0
var root_3d: Node3D = null
var car_root: Node3D = null
var cam: Camera3D = null

func save_photo(filename: String):
	var vp = root.get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	img.save_png("res://" + filename)
	img.save_png(artifact_dir + filename)
	print("[MASTERPIECE 127] Foto salvata: " + filename)

func _init():
	print("[MASTERPIECE 127] Avvio costruzione ultra-dettagliata Fiat 127 Special 1974...")

# Helper Mesh Functions
func create_pbr_box(size: Vector3, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var b = BoxMesh.new()
	b.size = size
	b.subdivide_width = 1
	b.subdivide_height = 1
	b.subdivide_depth = 1
	mi.mesh = b
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

func create_pbr_cylinder(radius: float, height: float, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO, segs: int = 24) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var c = CylinderMesh.new()
	c.top_radius = radius
	c.bottom_radius = radius
	c.height = height
	c.radial_segments = segs
	mi.mesh = c
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

# Parametric Curved Hood with center spine and compound curvature
func create_sculpted_127_hood(pos: Vector3, mat: Material) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var length_slices = 12
	var width_slices = 12
	var length = 1.24
	var w_rear = 1.36
	var w_front = 1.24
	
	var grid = []
	for i in range(length_slices):
		var row = []
		var tz = float(i) / float(length_slices - 1)
		var z = -tz * length
		# Forward rake slope
		var base_y = -tz * 0.12
		var cur_w = lerp(w_rear, w_front, tz)
		
		for j in range(width_slices):
			var tx = float(j) / float(width_slices - 1) * 2.0 - 1.0 # -1.0 to 1.0
			var x = tx * (cur_w * 0.5)
			# Parabolic center crown
			var camber = cos(tx * PI * 0.5) * 0.045
			# Center crisp crease ridge
			var center_spine = (1.0 - abs(tx)) * 0.012
			var pt = pos + Vector3(x, base_y + camber + center_spine, z)
			row.append(pt)
		grid.append(row)
		
	for i in range(length_slices - 1):
		for j in range(width_slices - 1):
			var p00 = grid[i][j]; var p01 = grid[i][j + 1]
			var p10 = grid[i + 1][j]; var p11 = grid[i + 1][j + 1]
			var u0 = float(j) / float(width_slices - 1); var u1 = float(j + 1) / float(width_slices - 1)
			var v0 = float(i) / float(length_slices - 1); var v1 = float(i + 1) / float(length_slices - 1)
			
			st.set_uv(Vector2(u0, v0)); st.add_vertex(p00)
			st.set_uv(Vector2(u1, v0)); st.add_vertex(p01)
			st.set_uv(Vector2(u0, v1)); st.add_vertex(p10)
			
			st.set_uv(Vector2(u1, v0)); st.add_vertex(p01)
			st.set_uv(Vector2(u1, v1)); st.add_vertex(p11)
			st.set_uv(Vector2(u0, v1)); st.add_vertex(p10)
			
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.name = "SculptedHood"
	return mi

# Parametric Curved Roof with Arched Crown
func create_sculpted_127_roof(pos: Vector3, mat: Material) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var length_slices = 10
	var width_slices = 10
	var length = 1.35
	var width = 1.26
	
	var grid = []
	for i in range(length_slices):
		var row = []
		var tz = float(i) / float(length_slices - 1)
		var z = (tz - 0.5) * length
		var z_arch = sin(tz * PI) * 0.02
		
		for j in range(width_slices):
			var tx = float(j) / float(width_slices - 1) * 2.0 - 1.0
			var x = tx * (width * 0.5)
			var x_arch = cos(tx * PI * 0.5) * 0.035
			var pt = pos + Vector3(x, x_arch + z_arch, z)
			row.append(pt)
		grid.append(row)
		
	for i in range(length_slices - 1):
		for j in range(width_slices - 1):
			var p00 = grid[i][j]; var p01 = grid[i][j + 1]
			var p10 = grid[i + 1][j]; var p11 = grid[i + 1][j + 1]
			var u0 = float(j) / float(width_slices - 1); var u1 = float(j + 1) / float(width_slices - 1)
			var v0 = float(i) / float(length_slices - 1); var v1 = float(i + 1) / float(length_slices - 1)
			
			st.set_uv(Vector2(u0, v0)); st.add_vertex(p00)
			st.set_uv(Vector2(u1, v0)); st.add_vertex(p01)
			st.set_uv(Vector2(u0, v1)); st.add_vertex(p10)
			
			st.set_uv(Vector2(u1, v0)); st.add_vertex(p01)
			st.set_uv(Vector2(u1, v1)); st.add_vertex(p11)
			st.set_uv(Vector2(u0, v1)); st.add_vertex(p10)
			
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.name = "ArchedRoof"
	return mi

# Stamped Wheel Arch Lip
func create_curved_wheel_arch_lip(center: Vector3, radius: float, is_left: bool, mat: Material) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var segments = 20
	var side_mul = -1.0 if is_left else 1.0
	var width = 0.045
	var flare = 0.035
	
	for i in range(segments):
		var a0 = float(i) / float(segments) * PI
		var a1 = float(i + 1) / float(segments) * PI
		
		var y0 = sin(a0) * radius; var z0 = cos(a0) * radius
		var y1 = sin(a1) * radius; var z1 = cos(a1) * radius
		
		var y0_out = sin(a0) * (radius + width); var z0_out = cos(a0) * (radius + width)
		var y1_out = sin(a1) * (radius + width); var z1_out = cos(a1) * (radius + width)
		
		var p0_in = center + Vector3(0.0, y0, z0)
		var p0_out = center + Vector3(side_mul * flare, y0_out, z0_out)
		var p1_in = center + Vector3(0.0, y1, z1)
		var p1_out = center + Vector3(side_mul * flare, y1_out, z1_out)
		
		if is_left:
			st.add_vertex(p0_in); st.add_vertex(p0_out); st.add_vertex(p1_out)
			st.add_vertex(p0_in); st.add_vertex(p1_out); st.add_vertex(p1_in)
		else:
			st.add_vertex(p0_in); st.add_vertex(p1_out); st.add_vertex(p0_out)
			st.add_vertex(p0_in); st.add_vertex(p1_in); st.add_vertex(p1_out)
			
	st.generate_normals()
	var mi = MeshInstance3D.new()
	mi.mesh = st.commit()
	return mi

# Authentic 13" Stamped Steel Wheel with Chrome Baby-Moon Cap
func create_masterpiece_wheel(is_left: bool, rim_mat: Material, cap_mat: Material, tire_mat: Material) -> Node3D:
	var w = Node3D.new()
	var side_mul = -1.0 if is_left else 1.0
	
	# 1. Toroidal Rounded Rubber Tire
	var tire_mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.165
	torus.outer_radius = 0.27
	torus.rings = 32
	torus.ring_segments = 18
	tire_mesh.mesh = torus
	tire_mesh.material_override = tire_mat
	tire_mesh.rotation.z = PI * 0.5
	w.add_child(tire_mesh)
	
	# Tread Center Fill
	var tread_cyl = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.27
	cyl.bottom_radius = 0.27
	cyl.height = 0.11
	cyl.radial_segments = 32
	tread_cyl.mesh = cyl
	tread_cyl.material_override = tire_mat
	tread_cyl.rotation.z = PI * 0.5
	w.add_child(tread_cyl)
	
	# 2. Steel Rim Outer Ring & Drop Center Dish
	var rim_mesh = MeshInstance3D.new()
	var r_cyl = CylinderMesh.new()
	r_cyl.top_radius = 0.185
	r_cyl.bottom_radius = 0.185
	r_cyl.height = 0.125
	r_cyl.radial_segments = 28
	rim_mesh.mesh = r_cyl
	rim_mesh.material_override = rim_mat
	rim_mesh.rotation.z = PI * 0.5
	w.add_child(rim_mesh)
	
	# 3. Inner Stamped Disc with 8 Cooling Slots
	for i in range(8):
		var ang = float(i) / 8.0 * TAU
		var slot = MeshInstance3D.new()
		var slot_box = BoxMesh.new()
		slot_box.size = Vector3(0.015, 0.024, 0.045)
		slot.mesh = slot_box
		var mat_dark = StandardMaterial3D.new()
		mat_dark.albedo_color = Color(0.10, 0.10, 0.12)
		mat_dark.roughness = 0.95
		slot.material_override = mat_dark
		slot.position = Vector3(side_mul * 0.058, sin(ang) * 0.125, cos(ang) * 0.125)
		slot.rotation.x = ang
		w.add_child(slot)
		
	# 4. Domed Chrome Baby-Moon Fiat Hubcap
	var cap = MeshInstance3D.new()
	var cap_sphere = SphereMesh.new()
	cap_sphere.radius = 0.088
	cap_sphere.height = 0.05
	cap_sphere.radial_segments = 24
	cap_sphere.rings = 12
	cap.mesh = cap_sphere
	cap.material_override = cap_mat
	cap.position = Vector3(side_mul * 0.065, 0.0, 0.0)
	cap.rotation.z = PI * 0.5 if is_left else -PI * 0.5
	w.add_child(cap)
	
	# 4 Chrome Wheel Lug Bolts
	for bi in range(4):
		var b_ang = float(bi) / 4.0 * TAU + (PI * 0.25)
		var bolt = MeshInstance3D.new()
		var b_cyl = CylinderMesh.new()
		b_cyl.top_radius = 0.011
		b_cyl.bottom_radius = 0.011
		b_cyl.height = 0.015
		bolt.mesh = b_cyl
		bolt.material_override = cap_mat
		bolt.position = Vector3(side_mul * 0.068, sin(b_ang) * 0.055, cos(b_ang) * 0.055)
		bolt.rotation.z = PI * 0.5
		w.add_child(bolt)
		
	# 5. Brake Disc & Caliper behind rim
	var disc = MeshInstance3D.new()
	var d_cyl = CylinderMesh.new()
	d_cyl.top_radius = 0.14
	d_cyl.bottom_radius = 0.14
	d_cyl.height = 0.018
	disc.mesh = d_cyl
	var mat_rotor = StandardMaterial3D.new()
	mat_rotor.albedo_color = Color(0.68, 0.70, 0.72)
	mat_rotor.metallic = 0.92
	mat_rotor.roughness = 0.25
	disc.material_override = mat_rotor
	disc.position = Vector3(-side_mul * 0.02, 0.0, 0.0)
	disc.rotation.z = PI * 0.5
	w.add_child(disc)
	
	return w

func build_full_masterpiece_127() -> Node3D:
	var car = Node3D.new()
	car.name = "Fiat127_Masterpiece"
	
	# --- PBR MATERIALS (Authentic 1974 Coachwork) ---
	# Authentic Giallo Positano 1974 Synthetic Enamel with Clearcoat
	var mat_body = StandardMaterial3D.new()
	mat_body.albedo_color = Color(0.88, 0.70, 0.16, 1.0)
	mat_body.roughness = 0.14
	mat_body.metallic = 0.08
	mat_body.clearcoat_enabled = true
	mat_body.clearcoat = 1.0
	mat_body.clearcoat_roughness = 0.03
	
	# High-Polish Chrome
	var mat_chrome = StandardMaterial3D.new()
	mat_chrome.albedo_color = Color(0.96, 0.97, 0.99)
	mat_chrome.metallic = 0.98
	mat_chrome.roughness = 0.08
	
	# Satin Black Rubber & Trim
	var mat_rubber = StandardMaterial3D.new()
	mat_rubber.albedo_color = Color(0.11, 0.11, 0.12)
	mat_rubber.roughness = 0.88
	
	# Transparent Glass
	var mat_glass = StandardMaterial3D.new()
	mat_glass.albedo_color = Color(0.90, 0.95, 0.98, 0.16)
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_glass.roughness = 0.03
	mat_glass.metallic = 0.30
	mat_glass.clearcoat_enabled = true
	mat_glass.clearcoat = 1.0
	
	# Headlight Fluted Glass Shader
	var shader_headlight = load("res://shaders/vintage_fluted_headlight.gdshader")
	var mat_fluted_glass = ShaderMaterial.new()
	mat_fluted_glass.shader = shader_headlight
	mat_fluted_glass.set_shader_parameter("bulb_emission", Color(1.0, 0.95, 0.84, 1.0))
	mat_fluted_glass.set_shader_parameter("emission_energy", 2.2)
	mat_fluted_glass.set_shader_parameter("flute_frequency", 36.0)
	mat_fluted_glass.set_shader_parameter("prism_depth", 0.45)
	
	# Tire Shader
	var shader_tire = load("res://shaders/vintage_tire.gdshader")
	var mat_tire = ShaderMaterial.new()
	mat_tire.shader = shader_tire
	
	# --- 1. CHASSIS PLATFORM & LOWER BODYWORK WITH WHEEL WELL RECESSES ---
	# Authentic real 127 1:1 dimensions: Length 3.595m, Width 1.527m, Height 1.370m
	var center_tub = create_pbr_box(Vector3(1.42, 0.44, 1.62), mat_body, Vector3(0.0, 0.48, 0.0))
	car.add_child(center_tub)
	
	var floor_pan = create_pbr_box(Vector3(1.24, 0.08, 3.20), mat_rubber, Vector3(0.0, 0.24, 0.0))
	car.add_child(floor_pan)
	
	# Outer Wing Flanks & Inner Wheel Liners
	for side in [-1.0, 1.0]:
		var is_left = (side < 0)
		# Front winged outer fender flank
		var f_wing = create_pbr_box(Vector3(0.10, 0.28, 1.14), mat_body, Vector3(side * 0.70, 0.60, -1.12))
		var r_wing = create_pbr_box(Vector3(0.10, 0.46, 0.85), mat_body, Vector3(side * 0.70, 0.62, 1.15))
		car.add_child(f_wing); car.add_child(r_wing)
		
		# Inner splash liners
		var liner_f = create_pbr_box(Vector3(0.06, 0.38, 0.62), mat_rubber, Vector3(side * 0.60, 0.48, -1.11))
		var liner_r = create_pbr_box(Vector3(0.06, 0.38, 0.62), mat_rubber, Vector3(side * 0.60, 0.48, 1.11))
		car.add_child(liner_f); car.add_child(liner_r)
		
		# Stamped Wheel Arch Lips (Flared Lips with 3D depth)
		var arch_fl = create_curved_wheel_arch_lip(Vector3(side * 0.74, 0.38, -1.11), 0.30, is_left, mat_body)
		var arch_rl = create_curved_wheel_arch_lip(Vector3(side * 0.74, 0.38, 1.11), 0.30, is_left, mat_body)
		car.add_child(arch_fl); car.add_child(arch_rl)
		
		# Pio Manzù Crisp Character Beltline
		var belt_strip = create_pbr_box(Vector3(0.018, 0.024, 2.80), mat_rubber, Vector3(side * 0.755, 0.62, 0.02))
		car.add_child(belt_strip)
		
		# Chrome Door Push Handle
		var handle = create_pbr_box(Vector3(0.025, 0.035, 0.12), mat_chrome, Vector3(side * 0.755, 0.73, -0.12))
		car.add_child(handle)
		
		# Vintage Round Chrome Driver Mirror
		if side < 0:
			var m_stem = create_pbr_cylinder(0.008, 0.06, mat_chrome, Vector3(side * 0.77, 0.76, -0.44), Vector3(0, 0, PI * 0.5))
			var m_head = create_pbr_cylinder(0.045, 0.02, mat_chrome, Vector3(side * 0.81, 0.76, -0.44), Vector3(0, 0, PI * 0.5))
			car.add_child(m_stem); car.add_child(m_head)
			
	# --- 2. SCULPTED SLOPING HOOD (Pio Manzù Forward Rake) ---
	var hood = create_sculpted_127_hood(Vector3(0.0, 0.66, -0.48), mat_body)
	car.add_child(hood)
	
	# Asymmetric Bonnet Air Intake Scoop (Lato Guida)
	var scoop = create_pbr_box(Vector3(0.24, 0.025, 0.28), mat_rubber, Vector3(-0.30, 0.78, -0.92), Vector3(deg_to_rad(-4.0), 0, 0))
	car.add_child(scoop)
	
	# Cowl air intake grille below windshield
	var cowl_vent = create_pbr_box(Vector3(0.85, 0.015, 0.08), mat_rubber, Vector3(0.0, 0.78, -0.46))
	car.add_child(cowl_vent)
	
	# --- 3. FRONT FASCIA: 1974 SPECIAL GRILLE & CARELLO HEADLAMPS ---
	var nose_panel = create_pbr_box(Vector3(1.36, 0.24, 0.06), mat_rubber, Vector3(0.0, 0.60, -1.70))
	car.add_child(nose_panel)
	
	# Polished Chrome Grille Frame
	var gf_top = create_pbr_box(Vector3(1.38, 0.016, 0.04), mat_chrome, Vector3(0.0, 0.71, -1.72))
	var gf_bot = create_pbr_box(Vector3(1.38, 0.016, 0.04), mat_chrome, Vector3(0.0, 0.49, -1.72))
	car.add_child(gf_top); car.add_child(gf_bot)
	
	# Horizontal Grille Bars
	for gi in range(3):
		var bar = create_pbr_box(Vector3(1.34, 0.010, 0.02), mat_chrome, Vector3(0.0, 0.54 + float(gi) * 0.055, -1.73))
		car.add_child(bar)
		
	# Centered Blue Enamel Fiat 4-Rhombus Badge ([F][I][A][T])
	var mat_fiat_blue = StandardMaterial3D.new()
	mat_fiat_blue.albedo_color = Color(0.06, 0.22, 0.65)
	mat_fiat_blue.roughness = 0.25
	for bi in range(4):
		var rhom = create_pbr_box(Vector3(0.024, 0.065, 0.025), mat_fiat_blue, Vector3(-0.075 + float(bi) * 0.05, 0.60, -1.74), Vector3(0, 0, deg_to_rad(-18.0)))
		var let = create_pbr_box(Vector3(0.014, 0.035, 0.01), mat_chrome, Vector3(-0.075 + float(bi) * 0.05, 0.60, -1.755))
		car.add_child(rhom); car.add_child(let)
		
	# Carello Rectangular Sealed-Beam Headlights with Fluted Glass Shader
	for side in [-1.0, 1.0]:
		var hl_frame = create_pbr_box(Vector3(0.24, 0.16, 0.04), mat_chrome, Vector3(side * 0.48, 0.60, -1.71))
		var bowl = create_pbr_cylinder(0.08, 0.04, mat_chrome, Vector3(side * 0.48, 0.60, -1.71), Vector3(PI * 0.5, 0, 0))
		var lens = create_pbr_box(Vector3(0.21, 0.13, 0.02), mat_fluted_glass, Vector3(side * 0.48, 0.60, -1.735))
		car.add_child(hl_frame); car.add_child(bowl); car.add_child(lens)
		
		# Corner amber indicator
		var ind = create_pbr_box(Vector3(0.08, 0.11, 0.03), mat_rubber, Vector3(side * 0.64, 0.60, -1.68))
		var ind_lens = create_pbr_box(Vector3(0.07, 0.09, 0.02), mat_chrome, Vector3(side * 0.64, 0.60, -1.695))
		var mat_amb = StandardMaterial3D.new()
		mat_amb.albedo_color = Color(1.0, 0.55, 0.06); mat_amb.emission_enabled = true; mat_amb.emission = Color(1.0, 0.50, 0.04); mat_amb.emission_energy_multiplier = 1.6
		ind_lens.material_override = mat_amb
		car.add_child(ind); car.add_child(ind_lens)
		
	# Front Chrome Bumper with Rubber Strip & Overriders
	var b_front = create_pbr_box(Vector3(1.46, 0.075, 0.06), mat_chrome, Vector3(0.0, 0.36, -1.76))
	var bf_strip = create_pbr_box(Vector3(1.44, 0.025, 0.02), mat_rubber, Vector3(0.0, 0.36, -1.792))
	car.add_child(b_front); car.add_child(bf_strip)
	for side in [-1.0, 1.0]:
		var rostro = create_pbr_box(Vector3(0.05, 0.16, 0.08), mat_rubber, Vector3(side * 0.36, 0.36, -1.78))
		car.add_child(rostro)
		
	# Front Vintage Italian License Plate
	var f_plate = create_pbr_box(Vector3(0.32, 0.08, 0.02), mat_rubber, Vector3(0.0, 0.24, -1.77))
	car.add_child(f_plate)
	
	# --- 4. GREENHOUSE, SLENDER PILLARS & FASTBACK ROOFLINE ---
	# Windshield angled back at 42 degrees
	var windshield = create_pbr_box(Vector3(1.22, 0.02, 0.74), mat_glass, Vector3(0.0, 1.02, -0.28), Vector3(deg_to_rad(-42.0), 0, 0))
	car.add_child(windshield)
	
	# Slender A-Pillars with Chrome Trim Bead
	for side in [-1.0, 1.0]:
		var a_pil = create_pbr_box(Vector3(0.035, 0.72, 0.035), mat_body, Vector3(side * 0.63, 1.02, -0.28), Vector3(deg_to_rad(-42.0), 0, 0))
		var a_chrome = create_pbr_box(Vector3(0.015, 0.72, 0.015), mat_chrome, Vector3(side * 0.645, 1.025, -0.28), Vector3(deg_to_rad(-42.0), 0, 0))
		car.add_child(a_pil); car.add_child(a_chrome)
		
		# B-Pillar
		var b_pil = create_pbr_box(Vector3(0.04, 0.46, 0.08), mat_rubber, Vector3(side * 0.635, 1.04, 0.35))
		car.add_child(b_pil)
		
		# C-Pillar Sloping Fastback Haunches
		var c_pil = create_pbr_box(Vector3(0.05, 0.68, 0.12), mat_body, Vector3(side * 0.64, 1.05, 1.15), Vector3(deg_to_rad(38.0), 0, 0))
		car.add_child(c_pil)
		
		# Gocciolatoi Cromati (Roof Rain Gutters)
		var gutter = create_pbr_box(Vector3(0.018, 0.022, 1.88), mat_chrome, Vector3(side * 0.655, 1.28, 0.40))
		car.add_child(gutter)
		
		# Side Door Window & Rear Quarter Window
		var side_win = create_pbr_box(Vector3(0.02, 0.44, 1.44), mat_glass, Vector3(side * 0.63, 1.04, 0.42))
		car.add_child(side_win)
		
		# Deflettore Anteriore (Front Vent Wing with vertical division bar)
		var defl_bar = create_pbr_box(Vector3(0.015, 0.44, 0.015), mat_chrome, Vector3(side * 0.635, 1.04, -0.06))
		car.add_child(defl_bar)
		
	# Arched Roof Dome
	var roof = create_sculpted_127_roof(Vector3(0.0, 1.28, 0.42), mat_body)
	car.add_child(roof)
	
	# Sloping Fastback Lunotto (Rear Glass)
	var rear_glass = create_pbr_box(Vector3(1.18, 0.02, 0.68), mat_glass, Vector3(0.0, 1.02, 1.28), Vector3(deg_to_rad(38.0), 0, 0))
	car.add_child(rear_glass)
	
	# Rear Boot Lid / Hatch Tail
	var rear_deck = create_pbr_box(Vector3(1.36, 0.44, 0.48), mat_body, Vector3(0.0, 0.72, 1.48))
	car.add_child(rear_deck)
	
	# Chrome Wipers flat along cowl
	for wx in [-0.28, 0.18]:
		var wiper = create_pbr_box(Vector3(0.012, 0.40, 0.012), mat_chrome, Vector3(wx, 0.80, -0.42), Vector3(deg_to_rad(-42.0), 0, deg_to_rad(-82.0)))
		car.add_child(wiper)
		
	# --- 5. REAR FASCIA, HORIZONTAL TRICOLOR LIGHTS & CHROME BUMPER ---
	var rear_panel = create_pbr_box(Vector3(1.36, 0.28, 0.06), mat_rubber, Vector3(0.0, 0.60, 1.72))
	car.add_child(rear_panel)
	
	# Horizontal Taillight Clusters
	for side in [-1.0, 1.0]:
		var tl_frame = create_pbr_box(Vector3(0.24, 0.10, 0.02), mat_chrome, Vector3(side * 0.52, 0.62, 1.74))
		car.add_child(tl_frame)
		
		# Outer Amber Turn
		var tl_amb = create_pbr_box(Vector3(0.07, 0.08, 0.025), mat_rubber, Vector3(side * 0.59, 0.62, 1.75))
		var mat_tla = StandardMaterial3D.new()
		mat_tla.albedo_color = Color(1.0, 0.50, 0.05); mat_tla.emission_enabled = true; mat_tla.emission = Color(1.0, 0.45, 0.05); mat_tla.emission_energy_multiplier = 1.2
		tl_amb.material_override = mat_tla
		car.add_child(tl_amb)
		
		# Center Red Brake
		var tl_red = create_pbr_box(Vector3(0.10, 0.08, 0.025), mat_rubber, Vector3(side * 0.51, 0.62, 1.75))
		var mat_tlr = StandardMaterial3D.new()
		mat_tlr.albedo_color = Color(0.88, 0.08, 0.08); mat_tlr.emission_enabled = true; mat_tlr.emission = Color(0.92, 0.06, 0.06); mat_tlr.emission_energy_multiplier = 1.2
		tl_red.material_override = mat_tlr
		car.add_child(tl_red)
		
		# Inner White Reverse
		var tl_wh = create_pbr_box(Vector3(0.06, 0.08, 0.025), mat_chrome, Vector3(side * 0.43, 0.62, 1.75))
		car.add_child(tl_wh)
		
	# Rear Chrome Bumper with Rubber Strip & Rostri
	var b_rear = create_pbr_box(Vector3(1.46, 0.075, 0.06), mat_chrome, Vector3(0.0, 0.36, 1.74))
	var br_strip = create_pbr_box(Vector3(1.44, 0.025, 0.02), mat_rubber, Vector3(0.0, 0.36, 1.772))
	car.add_child(b_rear); car.add_child(br_strip)
	for side in [-1.0, 1.0]:
		var r_rostro = create_pbr_box(Vector3(0.05, 0.16, 0.08), mat_rubber, Vector3(side * 0.36, 0.36, 1.76))
		car.add_child(r_rostro)
		
	# Vintage Italian Rear License Plate (TO • 482910 with Orange Province TO)
	var r_plate = create_pbr_box(Vector3(0.24, 0.18, 0.02), mat_rubber, Vector3(0.0, 0.46, 1.75))
	var prov_stamp = create_pbr_box(Vector3(0.06, 0.04, 0.01), mat_chrome, Vector3(-0.06, 0.50, 1.762))
	var mat_or_prov = StandardMaterial3D.new()
	mat_or_prov.albedo_color = Color(0.96, 0.50, 0.08)
	prov_stamp.material_override = mat_or_prov
	car.add_child(r_plate); car.add_child(prov_stamp)
	
	# Chrome Script Badges ("Fiat 127", "Special")
	var badge_127 = create_pbr_box(Vector3(0.14, 0.025, 0.015), mat_chrome, Vector3(-0.35, 0.72, 1.73))
	var badge_sp = create_pbr_box(Vector3(0.10, 0.020, 0.015), mat_chrome, Vector3(0.35, 0.72, 1.73))
	car.add_child(badge_127); car.add_child(badge_sp)
	
	# Rolled Chrome Tailpipe (Exiting low on left side)
	var exhaust = create_pbr_cylinder(0.022, 0.28, mat_chrome, Vector3(-0.46, 0.24, 1.72), Vector3(PI * 0.5, 0, 0))
	car.add_child(exhaust)
	
	# --- 6. AUTHENTIC 13" WHEELS WITH BABY-MOON CHROME CAPS ---
	var mat_rim_steel = StandardMaterial3D.new()
	mat_rim_steel.albedo_color = Color(0.76, 0.78, 0.80)
	mat_rim_steel.metallic = 0.75
	mat_rim_steel.roughness = 0.32
	
	var w_fl = create_masterpiece_wheel(true, mat_rim_steel, mat_chrome, mat_tire)
	w_fl.position = Vector3(-0.64, 0.27, -1.11)
	car.add_child(w_fl)
	
	var w_fr = create_masterpiece_wheel(false, mat_rim_steel, mat_chrome, mat_tire)
	w_fr.position = Vector3(0.64, 0.27, -1.11)
	car.add_child(w_fr)
	
	var w_rl = create_masterpiece_wheel(true, mat_rim_steel, mat_chrome, mat_tire)
	w_rl.position = Vector3(-0.62, 0.27, 1.11)
	car.add_child(w_rl)
	
	var w_rr = create_masterpiece_wheel(false, mat_rim_steel, mat_chrome, mat_tire)
	w_rr.position = Vector3(0.62, 0.27, 1.11)
	car.add_child(w_rr)
	
	# --- 7. 3D COCKPIT (Visible through glass) ---
	var dash = create_pbr_box(Vector3(1.18, 0.16, 0.32), mat_rubber, Vector3(0.0, 0.68, -0.35))
	car.add_child(dash)
	
	var wood_strip = create_pbr_box(Vector3(1.16, 0.045, 0.02), mat_rubber, Vector3(0.0, 0.68, -0.21))
	var mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.38, 0.20, 0.11); mat_wood.roughness = 0.35
	wood_strip.material_override = mat_wood
	car.add_child(wood_strip)
	
	# Two-Spoke Fiat Steering Wheel
	var sw_rim = MeshInstance3D.new()
	var sw_torus = TorusMesh.new()
	sw_torus.inner_radius = 0.15; sw_torus.outer_radius = 0.175
	sw_rim.mesh = sw_torus
	sw_rim.material_override = mat_rubber
	sw_rim.position = Vector3(-0.32, 0.78, -0.16)
	sw_rim.rotation.x = deg_to_rad(-68.0)
	car.add_child(sw_rim)
	
	# Bucket Seats with Headrests (Special Trim)
	for seat_x in [-0.32, 0.32]:
		var seat = create_pbr_box(Vector3(0.42, 0.46, 0.42), mat_rubber, Vector3(seat_x, 0.44, 0.08))
		var back = create_pbr_box(Vector3(0.40, 0.48, 0.10), mat_rubber, Vector3(seat_x, 0.70, 0.28), Vector3(deg_to_rad(14.0), 0, 0))
		var headrest = create_pbr_box(Vector3(0.22, 0.12, 0.08), mat_rubber, Vector3(seat_x, 0.98, 0.35), Vector3(deg_to_rad(14.0), 0, 0))
		car.add_child(seat); car.add_child(back); car.add_child(headrest)
		
	return car

func _process(_delta: float):
	frame_count += 1
	
	if frame_count == 2:
		root_3d = Node3D.new()
		root.add_child(root_3d)
		
		# Studio Environment
		var env_node = WorldEnvironment.new()
		var env = Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.12, 0.14, 0.18)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.85, 0.90, 0.98)
		env.ambient_light_energy = 0.88
		env.tonemap_mode = Environment.TONE_MAPPER_ACES
		env.tonemap_exposure = 1.02
		env_node.environment = env
		root_3d.add_child(env_node)
		
		# 3-Point Studio Lighting
		var key_light = DirectionalLight3D.new()
		key_light.rotation = Vector3(deg_to_rad(-32.0), deg_to_rad(45.0), 0.0)
		key_light.light_color = Color(1.0, 0.98, 0.94)
		key_light.light_energy = 1.85
		key_light.shadow_enabled = true
		root_3d.add_child(key_light)
		
		var fill_light = DirectionalLight3D.new()
		fill_light.rotation = Vector3(deg_to_rad(-18.0), deg_to_rad(-135.0), 0.0)
		fill_light.light_color = Color(0.70, 0.80, 0.98)
		fill_light.light_energy = 1.05
		root_3d.add_child(fill_light)
		
		var rim_light = DirectionalLight3D.new()
		rim_light.rotation = Vector3(deg_to_rad(18.0), deg_to_rad(175.0), 0.0)
		rim_light.light_color = Color(0.92, 0.96, 1.0)
		rim_light.light_energy = 0.90
		root_3d.add_child(rim_light)
		
		var floor_mesh = MeshInstance3D.new()
		var plane = PlaneMesh.new()
		plane.size = Vector2(40.0, 40.0)
		var mat_floor = StandardMaterial3D.new()
		mat_floor.albedo_color = Color(0.15, 0.16, 0.18)
		mat_floor.roughness = 0.70
		floor_mesh.mesh = plane
		floor_mesh.material_override = mat_floor
		root_3d.add_child(floor_mesh)
		
		# Build Masterpiece Fiat 127 Special
		car_root = build_full_masterpiece_127()
		root_3d.add_child(car_root)
		
		cam = Camera3D.new()
		cam.name = "ShowcaseCam"
		root_3d.add_child(cam)
		cam.look_at_from_position(Vector3(3.1, 1.45, -3.4), Vector3(0.0, 0.68, 0.0), Vector3.UP)
		cam.current = true
		print("[MASTERPIECE 127] Modello assemblato e camera impostata.")
		return
		
	# FRAME 12: SAVE FRONT 3/4 BEAUTY SHOT
	if frame_count == 12:
		save_photo("showcase_fiat_127_masterpiece_front.png")
		if cam:
			cam.look_at_from_position(Vector3(-3.2, 1.48, 3.2), Vector3(0.0, 0.68, 0.0), Vector3.UP)
			print("[MASTERPIECE 127] Camera spostata a vista posteriore 3/4...")
		return
		
	# FRAME 20: SAVE REAR 3/4 BEAUTY SHOT AND EXIT
	if frame_count == 20:
		save_photo("showcase_fiat_127_masterpiece_rear.png")
		print("[MASTERPIECE 127] Servizio fotografico completato con successo!")
		quit(0)
