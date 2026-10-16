extends Node3D

func _ready():
	print("--- RENDERING FIAT 127 HYBRID EXTERNAL MODEL ---")
	
	# Environment & Sun
	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.12, 0.14, 0.18, 1.0)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.65, 0.70, 0.80, 1.0)
	env_res.ambient_light_energy = 1.0
	env_res.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.environment = env_res
	add_child(env)
	
	var sun = DirectionalLight3D.new()
	sun.position = Vector3(10, 20, 10)
	sun.look_at(Vector3.ZERO, Vector3.UP)
	sun.light_energy = 1.6
	sun.shadow_enabled = true
	add_child(sun)
	
	var fill = DirectionalLight3D.new()
	fill.position = Vector3(-10, 10, -10)
	fill.look_at(Vector3.ZERO, Vector3.UP)
	fill.light_energy = 0.8
	add_child(fill)
	
	# Floor
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(50, 50)
	var mat_floor = StandardMaterial3D.new()
	mat_floor.albedo_color = Color(0.2, 0.22, 0.25)
	mat_floor.roughness = 0.4
	floor_mesh.mesh = plane
	floor_mesh.material_override = mat_floor
	add_child(floor_mesh)
	
	# Spawn Vehicle
	var veh_scene = load("res://scenes/Vehicle.tscn")
	var vehicle = veh_scene.instantiate()
	add_child(vehicle)
	vehicle.position = Vector3(0, 0.4, 0)
	vehicle.apply_vehicle_model("fiat_127")
	
	# Camera 1: 3/4 Front
	var cam = Camera3D.new()
	cam.position = Vector3(-3.5, 1.5, -4.0)
	cam.look_at(Vector3(0, 0.5, 0), Vector3.UP)
	cam.current = true
	add_child(cam)
	
	await get_tree().create_timer(0.2).timeout
	
	var img = get_viewport().get_texture().get_image()
	var shot_path = "user://fiat_127_render_front.png"
	img.save_png(shot_path)
	print("Salvato screenshot frontale: ", ProjectSettings.globalize_path(shot_path))
	
	# Camera 2: 3/4 Rear
	cam.position = Vector3(3.5, 1.6, 4.0)
	cam.look_at(Vector3(0, 0.5, 0), Vector3.UP)
	await get_tree().create_timer(0.2).timeout
	
	img = get_viewport().get_texture().get_image()
	var shot_path_rear = "user://fiat_127_render_rear.png"
	img.save_png(shot_path_rear)
	print("Salvato screenshot posteriore: ", ProjectSettings.globalize_path(shot_path_rear))
	
	get_tree().quit(0)
