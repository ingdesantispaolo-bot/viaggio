extends SceneTree

# Automated Road Dynamics Verification & Screenshot Capture
var frame = 0
var main_scene: Node3D = null
var vehicle = null
var road_gen = null
var current_car_idx = 0
var car_ids = ["panda_4x4", "delta_integrale", "mercedes_gwagen"]
var car_timer = 0.0
var step = 0

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/20b96c58-2c7b-4954-896b-4aa78ece88ca"

func _init():
	print("[Road Telemetry] Initializing road verification run...")

func _process(delta):
	frame += 1
	if frame == 1:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		vehicle = main_scene.get_node("Vehicle")
		road_gen = main_scene.get_node("RoadGenerator")
		vehicle.apply_vehicle_model(car_ids[current_car_idx])
		return

	if not vehicle or not road_gen:
		quit()
		return

	car_timer += delta
	
	# Apply acceleration throttle
	Input.action_press("accelerate")
	
	# Intelligent Road Keeping Auto-Steering (lookahead 12m)
	var car_pos = vehicle.global_position
	var lookahead_z = car_pos.z + 12.0
	var target_x = road_gen.get_road_center_x(lookahead_z)
	var x_err = car_pos.x - target_x
	
	# Proportional-Derivative steering
	var vx = vehicle.linear_velocity.x
	var steer_correction = clamp(-x_err * 0.18 - vx * 0.12, -0.7, 0.7)
	vehicle.steering = lerp(vehicle.steering, steer_correction * deg_to_rad(vehicle.VEHICLE_CATALOG[vehicle.current_model_id].steer_angle), delta * 12.0)

	var spd = vehicle.current_speed_kmh
	var gear = vehicle.gear_name
	var rpm = int(vehicle.engine_rpm)
	
	if fmod(car_timer, 1.0) < delta * 1.5:
		print("Road Run [%s] t: %.1fs | Spd: %.1f km/h | Gear: %s | RPM: %d | Pos: (%.1f, %.1f, %.1f)" % [
			car_ids[current_car_idx], car_timer, spd, gear, rpm, car_pos.x, car_pos.y, car_pos.z
		])

	# Stage 0: Panda 4x4 capture at t = 9.0s (DIORAMA_ALTO)
	if step == 0 and car_timer >= 9.0:
		save_screenshot("screenshot_diorama_panda.png")
		print(">>> Captured screenshot: screenshot_diorama_panda.png at %.1f km/h in %s" % [spd, gear])
		step = 1
		car_timer = 0.0
		current_car_idx = 1
		vehicle.global_position = Vector3(0.0, 0.45, 20.0)
		vehicle.rotation = Vector3(0.0, PI, 0.0)
		vehicle.linear_velocity = Vector3.ZERO
		vehicle.angular_velocity = Vector3.ZERO
		vehicle.apply_vehicle_model(car_ids[current_car_idx])
		return

	# Stage 1: Delta Integrale capture at t = 8.0s (DIORAMA_ALTO)
	if step == 1 and car_timer >= 8.0:
		save_screenshot("screenshot_diorama_delta.png")
		print(">>> Captured screenshot: screenshot_diorama_delta.png at %.1f km/h in %s" % [spd, gear])
		step = 2
		car_timer = 0.0
		current_car_idx = 2
		vehicle.global_position = Vector3(0.0, 0.45, 20.0)
		vehicle.rotation = Vector3(0.0, PI, 0.0)
		vehicle.linear_velocity = Vector3.ZERO
		vehicle.angular_velocity = Vector3.ZERO
		vehicle.apply_vehicle_model(car_ids[current_car_idx])
		return

	# Stage 2: Mercedes G-Wagen capture at t = 8.0s (DIORAMA_ALTO)
	if step == 2 and car_timer >= 8.0:
		save_screenshot("screenshot_diorama_gwagen.png")
		print(">>> Captured screenshot: screenshot_diorama_gwagen.png at %.1f km/h in %s" % [spd, gear])
		step = 3
		car_timer = 0.0
		current_car_idx = 1 # Switch back to Delta Integrale
		vehicle.global_position = Vector3(0.0, 0.45, 20.0)
		vehicle.rotation = Vector3(0.0, PI, 0.0)
		vehicle.linear_velocity = Vector3.ZERO
		vehicle.angular_velocity = Vector3.ZERO
		vehicle.apply_vehicle_model(car_ids[current_car_idx])
		var cam = main_scene.get_node("CameraController")
		if cam:
			cam.set_camera_mode(1) # DIORAMA_ISOMETRICO (pure top-down 45-deg bird's-eye view)
		return

	# Stage 3: Isometric Top-down Bird's-eye view capture at t = 8.0s
	if step == 3 and car_timer >= 8.0:
		save_screenshot("screenshot_diorama_isometric.png")
		print(">>> Captured screenshot: screenshot_diorama_isometric.png at %.1f km/h in %s" % [spd, gear])
		print("[Road Telemetry] All verification captures completed!")
		quit()

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var full_path = artifact_dir + "/" + filename
		var err = img.save_png(full_path)
		if err == OK:
			print("[Road Telemetry] Successfully saved: ", full_path)
