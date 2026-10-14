extends SceneTree

var frame_count: int = 0
var main_scene: Node = null
var vehicle_node: Node = null
var dash_ui: Node = null
var street_rod_ui: Node = null
var artifact_dir: String = "C:/Users/icopa/.gemini/antigravity-ide/brain/80482df3-861c-4f01-b762-b7e41f9e5340/"

func _init():
	print("[Capture Suite] Initializing High-Poly & Dashboard verification capture...")

func _process(_delta: float):
	frame_count += 1
	
	if frame_count == 2:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		vehicle_node = main_scene.get_node_or_null("Vehicle")
		dash_ui = main_scene.get_node_or_null("UILayer/DashboardUI")
		street_rod_ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
		print("[Capture Suite] Main scene instantiated.")
		return
		
	if not main_scene or not vehicle_node or not dash_ui:
		return
		
	# Frame 25: Capture Fiat 127 in Garage showing sculpted hood, curved wheel arches, wraparound bumper
	if frame_count == 25:
		save_viewport_screenshot("screenshot_fiat127_highpoly_garage.png")
		print("[Capture Suite] Captured Fiat 127 high-poly garage view.")
		
		# Now exit garage to test driving & dashboards
		if main_scene.has_method("exit_garage_to_road"):
			main_scene.exit_garage_to_road()
			
	# Frame 40: Switch to Alfa 8C, set cockpit camera, update telemetry, and capture Alfa 8C dashboard
	if frame_count == 40:
		vehicle_node.apply_vehicle_model("alfa_8c")
		if main_scene.has_node("CameraController"):
			main_scene.get_node("CameraController").set_camera_mode(1) # COCKPIT
		var info_8c = vehicle_node.VEHICLE_CATALOG.get("alfa_8c", {})
		dash_ui.update_telemetry(75.0, 0.55, "3", 42.0, 82.0, 0.0, 0.0, false, 0.0, info_8c)
		
	if frame_count == 55:
		save_viewport_screenshot("screenshot_dashboard_alfa8c_jaeger.png")
		print("[Capture Suite] Captured Alfa 8C vintage Jaeger dashboard.")
		
		# Now switch to chase camera to show Alfa 8C 3D exterior curves
		if main_scene.has_node("CameraController"):
			main_scene.get_node("CameraController").set_camera_mode(0) # CHASE
			
	if frame_count == 70:
		save_viewport_screenshot("screenshot_alfa8c_pontoon_curves.png")
		print("[Capture Suite] Captured Alfa 8C pontoon exterior curves.")
		
		# Frame 75: Switch to Lancia Stratos HF Stradale
		vehicle_node.apply_vehicle_model("lancia_stratos")
		if main_scene.has_node("CameraController"):
			main_scene.get_node("CameraController").set_camera_mode(1) # COCKPIT
		var info_stratos = vehicle_node.VEHICLE_CATALOG.get("lancia_stratos", {})
		dash_ui.update_telemetry(110.0, 0.65, "4", 32.0, 88.0, 0.0, 0.0, false, 0.0, info_stratos)
		
	if frame_count == 90:
		save_viewport_screenshot("screenshot_dashboard_stratos_bertone.png")
		print("[Capture Suite] Captured Lancia Stratos Bertone wedge dashboard.")
		
		# Switch to Fiat 131 Abarth Rally
		vehicle_node.apply_vehicle_model("fiat_131_abarth")
		var info_131 = vehicle_node.VEHICLE_CATALOG.get("fiat_131_abarth", {})
		dash_ui.update_telemetry(95.0, 0.60, "3", 45.0, 85.0, 0.0, 0.0, false, 0.0, info_131)
		
	if frame_count == 105:
		save_viewport_screenshot("screenshot_dashboard_fiat131_abarth.png")
		print("[Capture Suite] Captured Fiat 131 Abarth rally dashboard.")
		
		# Chase camera view of Stratos / 131 Abarth
		if main_scene.has_node("CameraController"):
			main_scene.get_node("CameraController").set_camera_mode(0) # CHASE
			
	if frame_count == 120:
		save_viewport_screenshot("screenshot_fiat131_flared_rally_exterior.png")
		print("[Capture Suite] Captured Fiat 131 Abarth flared rally exterior.")
		print("[Capture Suite] ALL VERIFICATION CAPTURES COMPLETED!")
		quit()

func save_viewport_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var target_path = artifact_dir + filename
		var err = img.save_png(target_path)
		if err == OK:
			print("  [OK] Saved: ", target_path)
		else:
			print("  [ERROR] Failed saving: ", target_path, " code: ", err)
	else:
		print("  [WARN] Image texture is null on frame ", frame_count)
