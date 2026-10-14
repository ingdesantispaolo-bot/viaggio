extends SceneTree

# Automated Test Script to Capture High-Res Screenshots of Renault 4, BMW 320i, and Mercedes A 250
var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

func _init():
	print("[Vehicle Screenshot Runner] Starting visual verification for Renault 4, BMW 320i E30, Mercedes A 250...")

func _process(delta):
	frame_count += 1
	
	# STAGE 0: Renault 4 GTL Exterior 3/4 Beauty Shot
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Vehicle Screenshot Runner] Main scene added.")
			setup_car("renault_4")
		elif frame_count == 25:
			set_car_beauty_camera(-2.8, 1.25, -3.2, 0.45)
		elif frame_count > 50:
			save_screenshot("screenshot_renault_4_exterior.png")
			stage = 1
			frame_count = 0
			
	# STAGE 1: Renault 4 GTL Cockpit & Jaeger Dashboard
	elif stage == 1:
		if frame_count == 1:
			set_cockpit_view()
		elif frame_count > 40:
			save_screenshot("screenshot_renault_4_cockpit.png")
			stage = 2
			frame_count = 0
			
	# STAGE 2: BMW 320i E30 Exterior 3/4 Beauty Shot
	elif stage == 2:
		if frame_count == 1:
			setup_car("bmw_320_e30")
		elif frame_count == 20:
			set_car_beauty_camera(-3.2, 1.15, -3.4, 0.40)
		elif frame_count > 50:
			save_screenshot("screenshot_bmw_320_exterior.png")
			stage = 3
			frame_count = 0
			
	# STAGE 3: BMW 320i E30 Cockpit & VDO Dashboard / Econometer
	elif stage == 3:
		if frame_count == 1:
			set_cockpit_view()
		elif frame_count > 40:
			save_screenshot("screenshot_bmw_320_cockpit.png")
			stage = 4
			frame_count = 0
			
	# STAGE 4: Mercedes-Benz A 250 Sport Exterior 3/4 Beauty Shot
	elif stage == 4:
		if frame_count == 1:
			setup_car("mercedes_a250")
		elif frame_count == 20:
			set_car_beauty_camera(-3.2, 1.20, -3.5, 0.42)
		elif frame_count > 50:
			save_screenshot("screenshot_mercedes_a250_exterior.png")
			stage = 5
			frame_count = 0
			
	# STAGE 5: Mercedes-Benz A 250 Cockpit & Twin-Tube / COMAND Display
	elif stage == 5:
		if frame_count == 1:
			set_cockpit_view()
		elif frame_count > 40:
			save_screenshot("screenshot_mercedes_a250_cockpit.png")
			stage = 6
			frame_count = 0
			
	elif stage == 6:
		print("[Vehicle Screenshot Runner] All screenshots captured successfully!")
		quit()

func setup_car(model_id: String):
	var vehicle = main_scene.get_node("Vehicle")
	var road_gen = main_scene.get_node("RoadGenerator")
	var biome_dir = main_scene.get_node("BiomeDirector")
	
	var target_z = 240.0
	if road_gen:
		road_gen.update_generation(target_z)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			if "current_speed_kmh" in vehicle:
				vehicle.current_speed_kmh = 75.0
			if vehicle.has_method("apply_vehicle_model"):
				vehicle.apply_vehicle_model(model_id)
			
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)

func set_car_beauty_camera(rel_x: float, rel_y: float, rel_z: float, look_y: float):
	var vehicle = main_scene.get_node("Vehicle")
	var cam = main_scene.get_node("CameraController")
	if vehicle and cam:
		cam.set_physics_process(false)
		var cam_world = vehicle.global_transform * Vector3(rel_x, rel_y, rel_z)
		cam.global_position = cam_world
		cam.look_at(vehicle.global_transform * Vector3(0.0, look_y, 0.0), Vector3.UP)

func set_cockpit_view():
	var cam = main_scene.get_node("CameraController")
	if cam:
		cam.set_physics_process(true)
		cam.set_camera_mode(3) # CameraMode.BONNET_COCKPIT

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var full_path = artifact_dir + "/" + filename
	var err = img.save_png(full_path)
	if err == OK:
		print("[Vehicle Screenshot Runner] Saved screenshot: ", full_path)
	else:
		print("[Vehicle Screenshot Runner] Error saving screenshot: ", err)
