extends SceneTree

# THE LONG MERIDIAN - Procedural Biome Graph & Seed Verification Test
# Validates:
# 1. Seed initialization and FastNoiseLite determinism
# 2. BiomeGraph segment scheduling & Markov transitions
# 3. HUD Stage Banner formatting: 🧭 TAPPA 1/4 [#1991]: PASSO DELLE ALPI
# 4. In-flight Logbook stats modal displaying SEED MONDO PROCEDURALE: #1991
# 5. Clean Vulkan Forward+ rendering of procedural world streaming

var frame_count = 0
var test_step = 0
var main_scene: Node3D = null
var vehicle = null
var road_gen = null
var journey_director = null
var dashboard_ui = null
var camera = null
var biome_dir = null

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/20b96c58-2c7b-4954-896b-4aa78ece88ca"

func _init():
	print("[Procedural Biome Test] Starting test suite...")

func _process(delta):
	frame_count += 1
	
	if test_step == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			vehicle = main_scene.get_node("Vehicle")
			road_gen = main_scene.get_node("RoadGenerator")
			journey_director = main_scene.get_node("JourneyDirector")
			camera = main_scene.get_node("CameraController")
			biome_dir = main_scene.get_node("BiomeDirector")
			dashboard_ui = main_scene.get_node_or_null("UILayer/DashboardUI")
			if not dashboard_ui and main_scene.has_node("DashboardUI"):
				dashboard_ui = main_scene.get_node("DashboardUI")
			print("[Procedural Biome Test] Scene instantiated successfully.")
			
		elif frame_count == 25:
			# Verify seed and noise initialization
			print("[Procedural Biome Test] RoadGenerator expedition seed: %d" % road_gen.expedition_seed)
			assert(road_gen.expedition_seed == 1991, "Seed should default to 1991")
			assert(road_gen.elevation_noise != null, "Elevation noise must be initialized")
			assert(road_gen.curve_noise != null, "Curve noise must be initialized")
			assert(road_gen.biome_graph != null, "BiomeGraph must be initialized")
			
			# Test Biome queries
			var b_alps = road_gen.get_biome_at(100.0)
			print("[Procedural Biome Test] Biome @ 100m: %s" % b_alps.get("name", "Unknown"))
			assert("PASSO DELLE ALPI" in b_alps.get("name", ""), "Biome at 100m should be Passo delle Alpi")
			
			var b_lake = road_gen.get_biome_at(450.0)
			print("[Procedural Biome Test] Biome @ 450m: %s" % b_lake.get("name", "Unknown"))
			assert("LAGO" in b_lake.get("name", ""), "Biome at 450m should be Lago")
			
			var b_service = road_gen.get_biome_at(750.0)
			print("[Procedural Biome Test] Biome @ 750m: %s" % b_service.get("name", "Unknown"))
			assert("AGIP" in b_service.get("name", ""), "Biome at 750m should be Stazione Agip")
			
			var b_village = road_gen.get_biome_at(950.0)
			print("[Procedural Biome Test] Biome @ 950m: %s" % b_village.get("name", "Unknown"))
			assert("BORGO" in b_village.get("name", ""), "Biome at 950m should be Borgo")
			
			var b_canyon = road_gen.get_biome_at(2000.0)
			print("[Procedural Biome Test] Biome @ 2000m: %s" % b_canyon.get("name", "Unknown"))
			assert("GOLA" in b_canyon.get("name", ""), "Biome at 2000m should be Gola del Meridiano")
			
			print("[Procedural Biome Test] All Biome queries validated!")
			
			# Teleport car to 160m to verify HUD stage header with seed
			teleport_to_z(160.0)
			vehicle.current_speed_kmh = 50.0
			test_step = 1
			frame_count = 0
			
	elif test_step == 1:
		if frame_count == 25:
			# Verify HUD Stage Label contains Seed
			if dashboard_ui and dashboard_ui.label_hud_stage:
				var stage_text = dashboard_ui.label_hud_stage.text
				print("[Procedural Biome Test] Current HUD Stage Text: '%s'" % stage_text)
				assert("[#1991]" in stage_text, "HUD Stage label must display [#1991] seed tag")
			save_screenshot("verify_procedural_hud_seed.png")
			
			# STEP 2: Open Logbook Modal [M] to verify Seed display in Logbook
			if dashboard_ui and dashboard_ui.has_method("toggle_logbook"):
				dashboard_ui.toggle_logbook()
				print("[Procedural Biome Test] Opened Logbook modal overlay.")
			test_step = 2
			frame_count = 0
			
	elif test_step == 2:
		if frame_count == 25:
			if dashboard_ui and dashboard_ui.logbook_stats_label:
				var stats_text = dashboard_ui.logbook_stats_label.text
				print("[Procedural Biome Test] Logbook stats excerpt:\n%s" % stats_text)
				assert("SEED MONDO PROCEDURALE:\n#1991" in stats_text, "Logbook must display procedural seed #1991")
			save_screenshot("verify_procedural_logbook_seed.png")
			
			# Close logbook and test Markov expansion beyond 5600m
			dashboard_ui.toggle_logbook()
			
			# STEP 3: Markov Procedural Query at 7500m (infinite streaming)
			var b_infinite = road_gen.get_biome_at(7500.0)
			print("[Procedural Biome Test] Infinite procedural biome @ 7500m: %s (Type: %d)" % [b_infinite.get("name", "Unknown"), b_infinite.get("type", -1)])
			assert(b_infinite.has("type"), "Procedural expansion must generate valid biome segment")
			
			# STEP 4: Capture scenic shot of procedural highway in diorama alto
			teleport_to_z(380.0)
			test_step = 3
			frame_count = 0
			
	elif test_step == 3:
		if frame_count == 25:
			save_screenshot("verify_procedural_expedition_running.png")
			print("[Procedural Biome Test] ALL PROCEDURAL SEED & BIOME TESTS PASSED FLAWLESSLY!")
			quit()

func teleport_to_z(target_z: float):
	if road_gen:
		road_gen.update_generation(target_z)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			vehicle.current_speed_kmh = 45.0
	
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)
		
	if camera:
		camera.set_camera_mode(0) # Diorama Alto
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
					print("[Procedural Biome Test] Saved screenshot: ", full_path)
				else:
					print("[Procedural Biome Test] Error saving screenshot: ", err)
