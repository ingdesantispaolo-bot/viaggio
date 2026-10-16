extends SceneTree

const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")
const VehicleCrashSystem = preload("res://scripts/VehicleCrashSystem.gd")

var artifact_dir: String = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86/"

var frame_count: int = 0
var stage: int = 0

var root_3d: Node3D = null
var cam: Camera3D = null
var current_car_node: Node3D = null

func attach_showcase_wheels(parent: Node3D, track_x: float, y_mount: float, wb_z: float, r_rad: float, t_wid: float, rim_mat: Material, cap_mat: Material = null):
	var mat_tire = StandardMaterial3D.new()
	mat_tire.albedo_color = Color(0.09, 0.09, 0.10)
	mat_tire.roughness = 0.92
	
	var mat_rotor = StandardMaterial3D.new()
	mat_rotor.albedo_color = Color(0.65, 0.68, 0.70)
	mat_rotor.metallic = 0.88
	mat_rotor.roughness = 0.28
	
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var w_node = Node3D.new()
			w_node.position = Vector3(sx * track_x, y_mount, sz * wb_z)
			
			# Tire Outer
			var tire_mesh = MeshInstance3D.new()
			var cyl = CylinderMesh.new()
			cyl.top_radius = r_rad
			cyl.bottom_radius = r_rad
			cyl.height = t_wid
			cyl.radial_segments = 28
			cyl.material = mat_tire
			tire_mesh.mesh = cyl
			tire_mesh.rotation.z = PI * 0.5
			w_node.add_child(tire_mesh)
			
			# Deep Dish Rim
			var rim_mesh = MeshInstance3D.new()
			var r_cyl = CylinderMesh.new()
			r_cyl.top_radius = r_rad * 0.68
			r_cyl.bottom_radius = r_rad * 0.68
			r_cyl.height = t_wid * 1.02
			r_cyl.radial_segments = 24
			r_cyl.material = rim_mat
			rim_mesh.mesh = r_cyl
			tire_mesh.add_child(rim_mesh)
			
			# Center Hub Cap
			var cap_mesh = MeshInstance3D.new()
			var c_cyl = CylinderMesh.new()
			c_cyl.top_radius = r_rad * 0.28
			c_cyl.bottom_radius = r_rad * 0.28
			c_cyl.height = t_wid * 1.08
			c_cyl.radial_segments = 16
			c_cyl.material = cap_mat if cap_mat else rim_mat
			cap_mesh.mesh = c_cyl
			tire_mesh.add_child(cap_mesh)
			
			# Brake Rotor behind wheel
			var rotor = MeshInstance3D.new()
			var rot_cyl = CylinderMesh.new()
			rot_cyl.top_radius = r_rad * 0.52
			rot_cyl.bottom_radius = r_rad * 0.52
			rot_cyl.height = 0.02
			rot_cyl.material = mat_rotor
			rotor.mesh = rot_cyl
			rotor.position.y = -sx * (t_wid * 0.40)
			tire_mesh.add_child(rotor)
			
			parent.add_child(w_node)

func save_current_frame(filename: String):
	var vp = root.get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	
	img.save_png("res://" + filename)
	img.save_png(artifact_dir + filename)
	print("[VERIFICAZIONE v4] Foto salvata: " + filename)

func _init():
	print("[VERIFICAZIONE v4] Studio fotografico PBR avviato...")
	VehicleModelBuilder.init_materials()

func _process(_delta: float):
	frame_count += 1
	
	# FRAME 2: INITIAL SETUP OF 3D STUDIO SCENE
	if frame_count == 2:
		root_3d = Node3D.new()
		root.add_child(root_3d)
		
		var env_node = WorldEnvironment.new()
		var env = Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.12, 0.14, 0.17)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.85, 0.90, 0.95)
		env.ambient_light_energy = 0.82
		env.tonemap_mode = Environment.TONE_MAPPER_ACES
		env_node.environment = env
		root_3d.add_child(env_node)
		
		var key_light = DirectionalLight3D.new()
		key_light.rotation = Vector3(deg_to_rad(-35.0), deg_to_rad(40.0), 0.0)
		key_light.light_color = Color(1.0, 0.97, 0.90)
		key_light.light_energy = 1.8
		key_light.shadow_enabled = true
		root_3d.add_child(key_light)
		
		var fill_light = DirectionalLight3D.new()
		fill_light.rotation = Vector3(deg_to_rad(-20.0), deg_to_rad(-140.0), 0.0)
		fill_light.light_color = Color(0.65, 0.75, 0.95)
		fill_light.light_energy = 0.9
		root_3d.add_child(fill_light)
		
		var rim_light = DirectionalLight3D.new()
		rim_light.rotation = Vector3(deg_to_rad(15.0), deg_to_rad(175.0), 0.0)
		rim_light.light_color = Color(0.9, 0.95, 1.0)
		rim_light.light_energy = 0.8
		root_3d.add_child(rim_light)
		
		cam = Camera3D.new()
		root_3d.add_child(cam)
		cam.look_at_from_position(Vector3(3.2, 1.55, -3.6), Vector3(0.0, 0.75, 0.0), Vector3.UP)
		cam.current = true
		
		var floor_mesh = MeshInstance3D.new()
		var plane = PlaneMesh.new()
		plane.size = Vector2(40.0, 40.0)
		var mat_floor = StandardMaterial3D.new()
		mat_floor.albedo_color = Color(0.16, 0.17, 0.19)
		mat_floor.roughness = 0.75
		floor_mesh.mesh = plane
		floor_mesh.material_override = mat_floor
		root_3d.add_child(floor_mesh)
		
		# Build Renault 4 Pristine
		current_car_node = Node3D.new()
		current_car_node.name = "Renault4_Showcase"
		root_3d.add_child(current_car_node)
		
		var mat_r4 = StandardMaterial3D.new()
		mat_r4.albedo_color = Color(0.24, 0.46, 0.70, 1.0) # Bleu Ille-de-France
		mat_r4.roughness = 0.20
		mat_r4.clearcoat_enabled = true
		mat_r4.clearcoat = 0.95
		VehicleModelBuilder.build_renault_4(current_car_node, mat_r4)
		
		var mat_r4_rim = StandardMaterial3D.new()
		mat_r4_rim.albedo_color = Color(0.92, 0.90, 0.83) # Ivoire R4
		mat_r4_rim.roughness = 0.35
		mat_r4_rim.clearcoat_enabled = true
		mat_r4_rim.clearcoat = 0.70
		
		var mat_chrome_cap = StandardMaterial3D.new()
		mat_chrome_cap.albedo_color = Color(0.92, 0.94, 0.96)
		mat_chrome_cap.metallic = 0.90
		mat_chrome_cap.roughness = 0.15
		
		attach_showcase_wheels(current_car_node, 0.63, 0.28, 1.15, 0.28, 0.15, mat_r4_rim, mat_chrome_cap)
		print("[VERIFICAZIONE v4] Renault 4 assemblata.")
		return
		
	# FRAME 10: RENAULT 4 GTL PRISTINE PHOTO
	if frame_count == 10:
		save_current_frame("showcase_renault4_gtl.png")
		current_car_node.queue_free()
		
		# Build Fiat Panda 4x4 Pristine
		current_car_node = Node3D.new()
		current_car_node.name = "Panda_Showcase"
		root_3d.add_child(current_car_node)
		
		var mat_panda = StandardMaterial3D.new()
		mat_panda.albedo_color = Color(0.20, 0.32, 0.24, 1.0) # Verde Tasmania
		mat_panda.roughness = 0.22
		mat_panda.clearcoat_enabled = true
		mat_panda.clearcoat = 0.90
		VehicleModelBuilder.build_panda_4x4(current_car_node, mat_panda)
		
		var mat_panda_rim = StandardMaterial3D.new()
		mat_panda_rim.albedo_color = Color(0.72, 0.74, 0.76)
		mat_panda_rim.metallic = 0.65
		mat_panda_rim.roughness = 0.35
		attach_showcase_wheels(current_car_node, 0.65, 0.28, 1.08, 0.28, 0.16, mat_panda_rim)
		print("[VERIFICAZIONE v4] Fiat Panda 4x4 assemblata.")
		return
		
	# FRAME 18: FIAT PANDA 4x4 PRISTINE PHOTO
	if frame_count == 18:
		save_current_frame("showcase_panda_4x4.png")
		current_car_node.queue_free()
		
		# Build Lancia Delta HF Integrale Evo Pristine
		current_car_node = Node3D.new()
		current_car_node.name = "Delta_Showcase"
		root_3d.add_child(current_car_node)
		
		var mat_delta = StandardMaterial3D.new()
		mat_delta.albedo_color = Color(0.85, 0.08, 0.08, 1.0) # Rosso Monza Rally
		mat_delta.roughness = 0.15
		mat_delta.clearcoat_enabled = true
		mat_delta.clearcoat = 0.98
		VehicleModelBuilder.build_delta_integrale(current_car_node, mat_delta)
		
		var mat_delta_rim = StandardMaterial3D.new()
		mat_delta_rim.albedo_color = Color(0.96, 0.96, 0.98) # Speedline White
		mat_delta_rim.metallic = 0.35
		mat_delta_rim.roughness = 0.20
		mat_delta_rim.clearcoat_enabled = true
		mat_delta_rim.clearcoat = 0.85
		
		var mat_brembo = StandardMaterial3D.new()
		mat_brembo.albedo_color = Color(0.90, 0.10, 0.10)
		mat_brembo.roughness = 0.30
		
		attach_showcase_wheels(current_car_node, 0.76, 0.30, 1.25, 0.30, 0.22, mat_delta_rim, mat_brembo)
		print("[VERIFICAZIONE v4] Lancia Delta HF Integrale assemblata.")
		return
		
	# FRAME 26: LANCIA DELTA INTEGRALE PRISTINE PHOTO
	if frame_count == 26:
		save_current_frame("showcase_delta_integrale.png")
		current_car_node.queue_free()
		
		# Build Fiat 127 Special Pristine
		current_car_node = Node3D.new()
		current_car_node.name = "Fiat127_Showcase"
		root_3d.add_child(current_car_node)
		
		var mat_127 = StandardMaterial3D.new()
		mat_127.albedo_color = Color(0.86, 0.68, 0.18, 1.0) # Giallo Positano
		mat_127.roughness = 0.22
		mat_127.clearcoat_enabled = true
		mat_127.clearcoat = 0.85
		VehicleModelBuilder.build_fiat_127(current_car_node, mat_127)
		
		var mat_127_rim = StandardMaterial3D.new()
		mat_127_rim.albedo_color = Color(0.78, 0.80, 0.82)
		mat_127_rim.metallic = 0.75
		
		var mat_127_cap = StandardMaterial3D.new()
		mat_127_cap.albedo_color = Color(0.95, 0.96, 0.98)
		mat_127_cap.metallic = 0.92
		mat_127_cap.roughness = 0.12
		
		attach_showcase_wheels(current_car_node, 0.64, 0.27, 1.11, 0.27, 0.15, mat_127_rim, mat_127_cap)
		print("[VERIFICAZIONE v4] Fiat 127 Special assemblata.")
		return
		
	# FRAME 34: FIAT 127 SPECIAL PRISTINE PHOTO
	if frame_count == 34:
		save_current_frame("showcase_fiat_127.png")
		current_car_node.queue_free()
		
		# Build Renault 4 for Crash Test
		current_car_node = Node3D.new()
		current_car_node.name = "Renault4_CrashTest"
		root_3d.add_child(current_car_node)
		
		var mat_r4 = StandardMaterial3D.new()
		mat_r4.albedo_color = Color(0.24, 0.46, 0.70, 1.0)
		mat_r4.roughness = 0.20
		mat_r4.clearcoat_enabled = true
		mat_r4.clearcoat = 0.95
		VehicleModelBuilder.build_renault_4(current_car_node, mat_r4)
		
		var mat_r4_rim = StandardMaterial3D.new()
		mat_r4_rim.albedo_color = Color(0.92, 0.90, 0.83)
		mat_r4_rim.roughness = 0.35
		attach_showcase_wheels(current_car_node, 0.63, 0.28, 1.15, 0.28, 0.15, mat_r4_rim)
		print("[VERIFICAZIONE v4] Renault 4 per crash test assemblata.")
		return
		
	# FRAME 38: APPLY 50 KM/H IMPACT AND INELASTIC DEFORMATION
	if frame_count == 38:
		var contact_pt = current_car_node.global_position + Vector3(0.20, 0.62, -1.68)
		VehicleCrashSystem.apply_structural_deformation(current_car_node, contact_pt, 50.0, Vector3(-0.30, 0.0, 0.95))
		print("[VERIFICAZIONE v4] Impatto anelastico 50 km/h applicato con successo.")
		return
		
	# FRAME 42: SAVE CRASH PHOTO AND EXIT
	if frame_count == 42:
		save_current_frame("test_renault4_crashed.png")
		print("[VERIFICAZIONE v4] Studio completo con successo! Tutte le foto salvate.")
		quit(0)
