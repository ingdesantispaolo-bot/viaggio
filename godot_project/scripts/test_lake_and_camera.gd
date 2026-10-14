extends SceneTree

# Automated Test Script to verify Lake Incoherence Fix & Mouse Camera Rotation
var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/20b96c58-2c7b-4954-896b-4aa78ece88ca"

func _init():
	print("[Lake & Camera Test] Starting automated verification...")

func _process(delta):
	frame_count += 1
	
	# STAGE 0: Spawn at Lake Area (Z = 410.0, Passo delle Alpi) and capture fixed lake landscape
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Lake & Camera Test] Main scene added.")
			setup_car_at_lake(410.0)
		elif frame_count > 45:
			save_screenshot("screenshot_lake_fixed.png")
			stage = 1
			frame_count = 0
			
	# STAGE 1: Test Mouse Orbit around Panda 4x4 in Chase Mode
	elif stage == 1:
		if frame_count == 1:
			var cam = main_scene.get_node("CameraController")
			if cam:
				# Simulate mouse drag orbit (Yaw ~45 deg, Pitch ~12 deg)
				cam.orbit_yaw = 0.78
				cam.orbit_pitch = 0.20
				cam.smoothed_orbit_yaw = 0.78
				cam.smoothed_orbit_pitch = 0.20
				cam.is_mouse_orbiting = true
		elif frame_count > 30:
			save_screenshot("screenshot_camera_mouse_orbit.png")
			stage = 2
			frame_count = 0
			
	# STAGE 2: Test Mouse Orbit looking directly at the Lake Basin
	elif stage == 2:
		if frame_count == 1:
			var cam = main_scene.get_node("CameraController")
			if cam:
				# Rotate camera to look towards the left where the lake sits in its valley
				cam.orbit_yaw = -1.25
				cam.orbit_pitch = 0.18
				cam.smoothed_orbit_yaw = -1.25
				cam.smoothed_orbit_pitch = 0.18
				cam.is_mouse_orbiting = true
		elif frame_count > 30:
			save_screenshot("screenshot_lake_view_from_road.png")
			setup_car_at_lake(520.0)
			stage = 3
			frame_count = 0
			
	# STAGE 3: Scenic Pier & Moored Rowboat at Z=520
	elif stage == 3:
		if frame_count == 1:
			var cam = main_scene.get_node("CameraController")
			if cam:
				cam.set_camera_mode(2) # SCENIC_DIORAMA
				cam.orbit_yaw = -0.75
				cam.orbit_pitch = 0.32
				cam.smoothed_orbit_yaw = -0.75
				cam.smoothed_orbit_pitch = 0.32
				cam.is_mouse_orbiting = true
		elif frame_count > 35:
			save_screenshot("screenshot_lake_pier_diorama.png")
			setup_car_at_lake(410.0)
			stage = 4
			frame_count = 0
			
	# STAGE 4: Test Cockpit Free-Look (Driver looking towards instrument cluster and side mirror)
	elif stage == 4:
		if frame_count == 1:
			var cam = main_scene.get_node("CameraController")
			if cam:
				cam.set_camera_mode(1) # CameraMode.BONNET_COCKPIT
				cam.orbit_yaw = 0.52   # Turn head towards right / gauges
				cam.orbit_pitch = -0.16 # Look slightly down at Veglia Borletti cluster
				cam.smoothed_orbit_yaw = 0.52
				cam.smoothed_orbit_pitch = -0.16
				cam.is_mouse_orbiting = true
		elif frame_count > 35:
			save_screenshot("screenshot_cockpit_head_look.png")
			stage = 5
			frame_count = 0
			
	# STAGE 5: Finish
	elif stage == 5:
		print("[Lake & Camera Test] All verification screenshots captured successfully!")
		quit()

func setup_car_at_lake(target_z: float):
	var vehicle = main_scene.get_node("Vehicle")
	var road_gen = main_scene.get_node("RoadGenerator")
	var biome_dir = main_scene.get_node("BiomeDirector")
	var cam = main_scene.get_node("CameraController")
	
	if road_gen:
		var info = road_gen.get_road_info_at(target_z)
		print("[Lake & Camera Test] Road info at Z=", target_z, ": ", info)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.38, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			if "current_speed_kmh" in vehicle:
				vehicle.current_speed_kmh = 35.0
			if vehicle.has_method("apply_vehicle_model"):
				vehicle.apply_vehicle_model("panda_4x4")
		road_gen.update_generation(target_z)
				
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)
		
	if cam:
		cam.set_camera_mode(0) # CHASE_LOW
		cam.setup_initial_position()

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var full_path = artifact_dir + "/" + filename
	var err = img.save_png(full_path)
	if err == OK:
		print("[Lake & Camera Test] Saved screenshot: ", full_path)
	else:
		print("[Lake & Camera Test] Error saving screenshot: ", err)
