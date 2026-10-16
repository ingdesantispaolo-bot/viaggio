@tool
extends SceneTree

const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")

func _init():
	print("[SHOWCASE] Generazione snapshot HD pulite dei modelli realistici...")
	VehicleModelBuilder.init_materials()
	
	var root_3d = Node3D.new()
	root.add_child(root_3d)
	
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.12, 0.14, 0.18) # Dark Studio Luxury
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.70, 0.75, 0.82)
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env_node.environment = env
	root_3d.add_child(env_node)
	
	# Key light & Rim light
	var sun = DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-35.0), deg_to_rad(35.0), 0.0)
	sun.light_color = Color(1.0, 0.98, 0.92)
	sun.light_energy = 2.0
	sun.shadow_enabled = true
	root_3d.add_child(sun)
	
	var rim_light = DirectionalLight3D.new()
	rim_light.rotation = Vector3(deg_to_rad(-20.0), deg_to_rad(-145.0), 0.0)
	rim_light.light_color = Color(0.75, 0.88, 1.0)
	rim_light.light_energy = 1.2
	root_3d.add_child(rim_light)
	
	# Dark studio floor with subtle reflection
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(30.0, 30.0)
	var mat_floor = StandardMaterial3D.new()
	mat_floor.albedo_color = Color(0.15, 0.16, 0.18)
	mat_floor.roughness = 0.28
	mat_floor.metallic = 0.15
	floor_mesh.mesh = plane
	floor_mesh.material_override = mat_floor
	root_3d.add_child(floor_mesh)
	
	# Studio Camera 3D
	var cam = Camera3D.new()
	root_3d.add_child(cam)
	cam.look_at_from_position(Vector3(2.7, 1.35, -3.1), Vector3(0.0, 0.55, -0.25), Vector3.UP)
	cam.current = true
	
	await create_timer(0.35).timeout
	var vp = root.get_viewport()
	
	# 1. RENAULT 4 GTL (1980)
	var r4 = Node3D.new()
	root_3d.add_child(r4)
	var mat_r4 = StandardMaterial3D.new()
	mat_r4.albedo_color = Color(0.22, 0.46, 0.72) # Bleu Ille-de-France
	mat_r4.roughness = 0.18
	mat_r4.metallic = 0.25
	mat_r4.clearcoat_enabled = true
	mat_r4.clearcoat = 0.92
	VehicleModelBuilder.build_renault_4(r4, mat_r4)
	await create_timer(0.25).timeout
	vp.get_texture().get_image().save_png("res://showcase_renault4_gtl.png")
	r4.queue_free()
	print("[SHOWCASE] Renault 4 GTL salvata.")
	
	# 2. FIAT PANDA 4X4 STEYR-PUCH (1983)
	await create_timer(0.10).timeout
	var panda = Node3D.new()
	root_3d.add_child(panda)
	var mat_panda = StandardMaterial3D.new()
	mat_panda.albedo_color = Color(0.18, 0.32, 0.22) # Verde Tasmania
	mat_panda.roughness = 0.20
	mat_panda.metallic = 0.30
	mat_panda.clearcoat_enabled = true
	mat_panda.clearcoat = 0.88
	VehicleModelBuilder.build_panda_4x4(panda, mat_panda)
	await create_timer(0.25).timeout
	vp.get_texture().get_image().save_png("res://showcase_panda_4x4.png")
	panda.queue_free()
	print("[SHOWCASE] Fiat Panda 4x4 salvata.")
	
	# 3. LANCIA DELTA HF INTEGRALE EVOLUZIONE (1991)
	await create_timer(0.10).timeout
	var delta = Node3D.new()
	root_3d.add_child(delta)
	var mat_delta = StandardMaterial3D.new()
	mat_delta.albedo_color = Color(0.85, 0.08, 0.08) # Rosso Monza Rally
	mat_delta.roughness = 0.14
	mat_delta.metallic = 0.40
	mat_delta.clearcoat_enabled = true
	mat_delta.clearcoat = 0.98
	VehicleModelBuilder.build_delta_integrale(delta, mat_delta)
	await create_timer(0.25).timeout
	vp.get_texture().get_image().save_png("res://showcase_delta_integrale.png")
	delta.queue_free()
	print("[SHOWCASE] Lancia Delta HF Integrale salvata.")
	
	# 4. FIAT 127 SPECIAL (1974)
	await create_timer(0.10).timeout
	var f127 = Node3D.new()
	root_3d.add_child(f127)
	var mat_127 = StandardMaterial3D.new()
	mat_127.albedo_color = Color(0.86, 0.68, 0.18) # Giallo Positano
	mat_127.roughness = 0.20
	mat_127.metallic = 0.15
	mat_127.clearcoat_enabled = true
	mat_127.clearcoat = 0.90
	VehicleModelBuilder.build_fiat_127(f127, mat_127)
	await create_timer(0.25).timeout
	vp.get_texture().get_image().save_png("res://showcase_fiat_127.png")
	f127.queue_free()
	print("[SHOWCASE] Fiat 127 Special salvata.")
	
	print("[SHOWCASE] Tutte le immagini generate con successo!")
	quit(0)
