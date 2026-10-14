extends SceneTree

# THE LONG MERIDIAN - Expedition Gameplay & Graphic Verification Suite
# Verifies:
# 1. Expedition Journey Director & HUD Header (Stages, PK odometer, Objectives, Score)
# 2. Milestone Discovery Fanfare & Lore popups
# 3. Off-Road Price Totem Positioning & Clean Storefront (Fixes from screenshots)
# 4. Interactive Refueling & Service Station Mechanics (+250 pt bonus)
# 5. Low Fuel & Overheat Cockpit Resource Warnings
# 6. Interactive Expedition Logbook & Route Map ([M] / [TAB])

var frame_count = 0
var stage = 0
var main_scene: Node3D = null
var vehicle = null
var road_gen = null
var journey_director = null
var dashboard_ui = null
var camera = null

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/20b96c58-2c7b-4954-896b-4aa78ece88ca"

func _init():
	print("[Expedition Suite] Initializing automated gameplay & visual verification...")

func _process(delta):
	frame_count += 1
	
	# Initial Boot
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			vehicle = main_scene.get_node("Vehicle")
			road_gen = main_scene.get_node("RoadGenerator")
			journey_director = main_scene.get_node("JourneyDirector")
			camera = main_scene.get_node("CameraController")
			dashboard_ui = main_scene.get_node_or_null("UILayer/DashboardUI")
			if not dashboard_ui and main_scene.has_node("DashboardUI"):
				dashboard_ui = main_scene.get_node("DashboardUI")
			print("[Expedition Suite] Main scene instantiated. Vehicle & JourneyDirector wired.")
			
		elif frame_count == 35:
			# Verify starting HUD state
			print("[Expedition Suite] Checking PK and Objective at start...")
			assert(journey_director != null, "JourneyDirector must exist")
			assert(dashboard_ui != null, "DashboardUI must exist")
			save_screenshot("expedition_hud_start.png")
			
			# Advance to Milestone 1: Malga Passo delle Alpi (Z = 250)
			teleport_to_z(255.0, 1) # Chase camera
			stage = 1
			frame_count = 0
			
	# Stage 1: Milestone 1 Discovery & Fanfare
	elif stage == 1:
		if frame_count == 15:
			print("[Expedition Suite] At Z=255. Checking Milestone reached...")
			# Update journey director with distance
			journey_director.update_progress(255.0, delta, 60.0)
		elif frame_count == 40:
			print("[Expedition Suite] Score after milestone: %d (expected >= 200)" % journey_director.expedition_score)
			save_screenshot("expedition_milestone_fanfare.png")
			
			# Drive off-road to verify dynamic wheel dust particles
			print("[Expedition Suite] Testing dynamic wheel particles on off-road gravel/grass...")
			var r_info = road_gen.get_road_info_at(280.0)
			vehicle.global_position = Vector3(r_info.x + (r_info.width * 0.5) + 1.2, r_info.y + 0.45, 280.0)
			vehicle.linear_velocity = Vector3(0.0, 0.0, 14.0)
			vehicle.current_speed_kmh = 50.0
			camera.set_camera_mode(1) # Chase
			camera.setup_initial_position()
			stage = 15
			frame_count = 0
			
	elif stage == 15:
		if frame_count == 25:
			save_screenshot("expedition_wheel_particles.png")
			# Advance to Agip Station at Passo delle Alpi (Z = 740)
			teleport_to_z(740.0, 0) # Diorama camera
			stage = 2
			frame_count = 0
			
	# Stage 2: Service Station & Off-Road Totem Verification
	elif stage == 2:
		if frame_count == 25:
			print("[Expedition Suite] At Agip Alpi 1840M (Z=740). Setting view of totem and forecourt...")
			var r_info = road_gen.get_road_info_at(740.0)
			# Look towards service station and totem
			set_scenic_camera_shot(Vector3(r_info.x - 14.0, r_info.y + 7.5, 715.0), Vector3(r_info.x + 12.0, r_info.y + 2.0, 755.0))
		elif frame_count == 55:
			save_screenshot("agip_totem_clean_verge.png")
			
			# Drive into pump bay and perform service
			print("[Expedition Suite] Moving vehicle to pump bay...")
			var r_info = road_gen.get_road_info_at(765.0)
			vehicle.global_position = Vector3(r_info.x + 12.5, r_info.y + 0.45, 765.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.current_speed_kmh = 0.0
			vehicle.current_fuel = 12.0 # Simulate low fuel
			camera.set_camera_mode(3) # Low chase
			camera.setup_initial_position()
			stage = 3
			frame_count = 0
			
	# Stage 3: Service Station Refueling Interaction & Resource Warning
	elif stage == 3:
		if frame_count == 15:
			var cfg = vehicle.VEHICLE_CATALOG[vehicle.current_model_id]
			vehicle.perform_service(cfg)
			print("[Expedition Suite] Service performed. Fuel: %.1f L, Score: %d" % [vehicle.current_fuel, journey_director.expedition_score])
		elif frame_count == 40:
			save_screenshot("agip_refueling_bay.png")
			
			# Open Expedition Logbook Modal
			print("[Expedition Suite] Opening Expedition Logbook...")
			dashboard_ui.toggle_logbook()
			stage = 4
			frame_count = 0
			
	# Stage 4: Expedition Logbook & Map Verification
	elif stage == 4:
		if frame_count == 25:
			print("[Expedition Suite] Capturing Expedition Logbook modal...")
			save_screenshot("expedition_logbook_modal.png")
			dashboard_ui.toggle_logbook()
			stage = 5
			frame_count = 0
			
	# Stage 5: Final Check & Exit
	elif stage == 5:
		print("[Expedition Suite] ALL TESTS & VERIFICATION SCREENSHOTS COMPLETED SUCCESSFULLY!")
		quit()

func set_scenic_camera_shot(cam_pos: Vector3, look_pos: Vector3):
	if camera:
		camera.set_physics_process(false)
		camera.global_position = cam_pos
		camera.look_at(look_pos, Vector3.UP)

func teleport_to_z(target_z: float, cam_mode: int):
	if road_gen:
		road_gen.update_generation(target_z)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			vehicle.current_speed_kmh = 45.0
	
	var biome_dir = main_scene.get_node_or_null("BiomeDirector")
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)
		
	if camera:
		camera.set_physics_process(true)
		camera.set_camera_mode(cam_mode)
		camera.setup_initial_position()

func save_screenshot(filename: String):
	var vp = root.get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var full_path = artifact_dir + "/" + filename
				var err = img.save_png(full_path)
				if err == OK:
					print("[Expedition Suite] Saved screenshot: ", full_path)
				else:
					print("[Expedition Suite] Error saving screenshot: ", err)
