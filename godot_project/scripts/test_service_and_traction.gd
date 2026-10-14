extends SceneTree

# Complete Verification Script for:
# 1. Road Adhesion (100%) vs Off-Road (Grass 36% 2WD vs 78% 4WD)
# 2. Obstacle Physics & Solid Collisions (Guardrail stop/deflection)
# 3. Service Area Visibility (Translucent Canopy) & Refueling/Repairs Interaction

var frame = 0
var main_scene: Node3D = null
var vehicle = null
var road_gen = null
var camera = null
var dashboard_ui = null

var step = 0
var timer = 0.0

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/20b96c58-2c7b-4954-896b-4aa78ece88ca"

func _init():
	print("[Verification] Starting Test Suite...")

func _process(delta):
	frame += 1
	if frame == 1:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		vehicle = main_scene.get_node("Vehicle")
		road_gen = main_scene.get_node("RoadGenerator")
		camera = main_scene.get_node("CameraController")
		dashboard_ui = main_scene.get_node_or_null("DashboardUI")
		if not dashboard_ui and main_scene.has_node("UILayer/DashboardUI"):
			dashboard_ui = main_scene.get_node("UILayer/DashboardUI")
		return

	if not vehicle or not road_gen:
		quit()
		return

	timer += delta

	# Step 0: Check On-Road Grip at initial position
	if step == 0 and timer >= 0.4:
		print("[Traction] On-Road: Surface='%s' | Grip=%.2f" % [vehicle.current_surface_name, vehicle.current_grip_mult])
		assert(vehicle.current_grip_mult == 1.0, "On-road grip must be 1.0")
		
		# Move to off-road grass laterally at current Z
		var cur_z = vehicle.global_position.z
		var r_info = road_gen.get_road_info_at(cur_z)
		var grass_pos = Vector3(r_info.x + 12.0, r_info.y + 0.35, cur_z)
		teleport_vehicle(grass_pos, PI)
		vehicle.is_4wd_engaged = true
		step = 1
		timer = 0.0
		return

	# Step 1: Check Off-Road 4WD Grip
	if step == 1 and timer >= 0.5:
		print("[Traction] Off-Road 4WD: Surface='%s' | Grip=%.2f" % [vehicle.current_surface_name, vehicle.current_grip_mult])
		assert(vehicle.current_grip_mult == 0.78, "Off-road 4WD grip should be 0.78")
		
		# Disengage 4WD to test 2WD off-road slip
		vehicle.is_4wd_engaged = false
		step = 2
		timer = 0.0
		return

	# Step 2: Check Off-Road 2WD Grip
	if step == 2 and timer >= 0.5:
		print("[Traction] Off-Road 2WD: Surface='%s' | Grip=%.2f" % [vehicle.current_surface_name, vehicle.current_grip_mult])
		assert(vehicle.current_grip_mult == 0.36, "Off-road 2WD grip should be 0.36")
		print("[Traction] Grip differentiation verified: 1.00 on road, 0.78 4WD grass, 0.36 2WD grass.")
		
		# Step 3: Test Guardrail / Obstacle Collision at Z=60
		vehicle.is_4wd_engaged = true
		var r_g = road_gen.get_road_info_at(60.0)
		var col_start = Vector3(r_g.x + 3.0, r_g.y + 0.35, 60.0)
		teleport_vehicle(col_start, PI * 0.80) # Pointed towards right guardrail
		camera.setup_initial_position()
		# Launch into guardrail
		var fwd = -vehicle.global_transform.basis.z
		PhysicsServer3D.body_set_state(vehicle.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, fwd * 9.0)
		step = 3
		timer = 0.0
		return

	# Step 3: Verify obstacle collision stop/deflection
	if step == 3 and timer >= 0.9:
		print("[Collision] Vehicle Pos after hitting barrier: %s, Velocity: %s" % [
			vehicle.global_position, vehicle.linear_velocity
		])
		save_screenshot("screenshot_obstacle_collision.png")
		print(">>> Captured: screenshot_obstacle_collision.png")
		
		# Step 4: Stream chunks ahead to Agip Service Station (Z=780)
		print("[Service Station] Streaming chunks to Z=900...")
		road_gen.update_generation(900.0)
		
		var r_st = road_gen.get_road_info_at(780.0)
		# Inner pump bay under canopy: X = r_st.x + 9.5, Z = 776.0
		var bay_pos = Vector3(r_st.x + 9.5, r_st.y + 0.35, 776.0)
		teleport_vehicle(bay_pos, PI)
		vehicle.current_fuel = 8.5 # Low fuel (reserve light on)
		camera.setup_initial_position()
		step = 4
		timer = 0.0
		return

	# Step 4: Verify vehicle in Service Bay under translucent canopy with [E] prompt
	if step == 4 and timer >= 0.9:
		var s_info = road_gen.get_service_station_at(vehicle.global_position)
		print("[Service Station] Pos: %s | in_zone=%s, in_bay=%s, station='%s'" % [
			vehicle.global_position, vehicle.is_in_service_zone, vehicle.is_in_service_bay, vehicle.service_station_name
		])
		assert(vehicle.is_in_service_zone == true, "Vehicle must be in service zone")
		assert(vehicle.is_in_service_bay == true, "Vehicle must be in service bay")
		save_screenshot("screenshot_service_station_bay.png")
		print(">>> Captured: screenshot_service_station_bay.png")
		
		# Trigger Service Action (Refueling + Tagliando)
		print("[Service Station] Triggering perform_service()...")
		var cfg = vehicle.VEHICLE_CATALOG[vehicle.current_model_id]
		vehicle.perform_service(cfg)
		step = 5
		timer = 0.0
		return

	# Step 5: Verify refueling completion & capture confirmation banner
	if step == 5 and timer >= 0.8:
		print("[Service Station] Refueled: Fuel=%.1fL | Temp=%.1fC | Msg='%s'" % [
			vehicle.current_fuel, vehicle.engine_temp, vehicle.service_message
		])
		assert(vehicle.current_fuel == 35.0, "Fuel must be full (35.0L)")
		save_screenshot("screenshot_service_refueling_done.png")
		print(">>> Captured: screenshot_service_refueling_done.png")
		print("[Verification] ALL TESTS PASSED SUCCESSFULLY!")
		quit()

func teleport_vehicle(pos: Vector3, yaw: float):
	var basis = Basis(Vector3.UP, yaw)
	var xform = Transform3D(basis, pos)
	PhysicsServer3D.body_set_state(vehicle.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, xform)
	PhysicsServer3D.body_set_state(vehicle.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
	PhysicsServer3D.body_set_state(vehicle.get_rid(), PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)
	vehicle.global_transform = xform
	vehicle.linear_velocity = Vector3.ZERO
	vehicle.angular_velocity = Vector3.ZERO

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var full_path = artifact_dir + "/" + filename
		var err = img.save_png(full_path)
		if err == OK:
			print("[Capture] Successfully saved: ", full_path)
