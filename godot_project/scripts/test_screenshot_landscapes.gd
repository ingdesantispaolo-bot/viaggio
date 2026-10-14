extends SceneTree

# Automated Test Script to Capture High-Res Screenshots of New Landscapes & Biomes
var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/5de6aa96-819b-4902-a405-f58b4fa2f294"

func _init():
	print("[Screenshot Runner] Initializing landscape visual test...")

func _process(delta):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Screenshot Runner] Main scene added to root.")
			teleport_to_z(475.0, 2)
		elif frame_count == 25:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(475.0)
			set_scenic_camera_shot(Vector3(info.x + 10.0, info.y + 4.2, 452.0), Vector3(info.x - 24.0, -1.2, 475.0))
		elif frame_count > 60:
			save_screenshot("screenshot_lago_alpino.png")
			stage = 1
			frame_count = 0
	elif stage == 1:
		if frame_count == 1:
			teleport_to_z(1015.0, 2)
			print("[Screenshot Runner] Teleported to Borgo San Cristoforo (Z=1015).")
		elif frame_count == 20:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(1015.0)
			set_scenic_camera_shot(Vector3(info.x - 12.0, info.y + 4.5, 995.0), Vector3(info.x + 18.0, info.y + 6.0, 1025.0))
		elif frame_count > 45:
			save_screenshot("screenshot_borgo_villaggio.png")
			stage = 2
			frame_count = 0
	elif stage == 2:
		if frame_count == 1:
			teleport_to_z(1485.0, 2)
			print("[Screenshot Runner] Teleported to Ponte dei Ciclopi (Z=1485).")
		elif frame_count == 20:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(1485.0)
			set_scenic_camera_shot(Vector3(info.x - 14.0, info.y + 5.2, 1465.0), Vector3(info.x + 1.0, info.y + 1.0, 1495.0))
		elif frame_count > 45:
			save_screenshot("screenshot_ponte_ciclopi.png")
			stage = 3
			frame_count = 0
	elif stage == 3:
		if frame_count == 1:
			teleport_to_z(3155.0, 2)
			print("[Screenshot Runner] Teleported to Stazione di Servizio (Z=3155).")
		elif frame_count == 20:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(3155.0)
			set_scenic_camera_shot(Vector3(info.x - 8.0, info.y + 3.8, 3130.0), Vector3(info.x + 16.0, info.y + 3.0, 3175.0))
		elif frame_count > 45:
			save_screenshot("screenshot_stazione_servizio.png")
			stage = 4
			frame_count = 0
	elif stage == 4:
		if frame_count == 1:
			teleport_to_z(5445.0, 2)
			print("[Screenshot Runner] Teleported to Borgo dell'Altopiano & Mulino (Z=5445).")
		elif frame_count == 20:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(5445.0)
			set_scenic_camera_shot(Vector3(info.x - 10.0, info.y + 4.2, 5420.0), Vector3(info.x + 18.0, info.y + 3.2, 5465.0))
		elif frame_count > 45:
			save_screenshot("screenshot_altopiano_mulino.png")
			stage = 5
			frame_count = 0
	elif stage == 5:
		print("[Screenshot Runner] All landscape screenshots captured successfully!")
		quit()

func set_scenic_camera_shot(cam_pos: Vector3, look_pos: Vector3):
	var cam = main_scene.get_node("CameraController")
	if cam:
		cam.set_physics_process(false)
		cam.global_position = cam_pos
		cam.look_at(look_pos, Vector3.UP)

func teleport_to_z(target_z: float, cam_mode: int):
	var vehicle = main_scene.get_node("Vehicle")
	var road_gen = main_scene.get_node("RoadGenerator")
	var biome_dir = main_scene.get_node("BiomeDirector")
	var cam = main_scene.get_node("CameraController")
	
	if road_gen:
		road_gen.update_generation(target_z)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			vehicle.current_speed_kmh = 55.0
	
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)
		biome_dir.update_biome(target_z, 1.0)
		
	if cam:
		cam.set_physics_process(true)
		cam.set_camera_mode(cam_mode)
		cam.setup_initial_position()

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var full_path = artifact_dir + "/" + filename
	var err = img.save_png(full_path)
	if err == OK:
		print("[Screenshot Runner] Saved screenshot: ", full_path)
	else:
		print("[Screenshot Runner] Error saving screenshot: ", err)
