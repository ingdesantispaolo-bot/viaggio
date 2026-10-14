extends SceneTree

var frame_count: int = 0
var main_scene: Node = null
var vehicle_node: Node = null
var dash_ui: Node = null
var cam_controller: Node = null
var artifact_dir: String = "C:/Users/icopa/.gemini/antigravity-ide/brain/80482df3-861c-4f01-b762-b7e41f9e5340/"

func _init():
	print("[Beauty Showcase v3] Initializing high-poly vehicle & dashboard photo studio...")

func _process(_delta: float):
	frame_count += 1
	
	if frame_count == 2:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		vehicle_node = main_scene.get_node_or_null("Vehicle")
		dash_ui = main_scene.get_node_or_null("UILayer/DashboardUI")
		cam_controller = main_scene.get_node_or_null("CameraController")
		return
		
	if not main_scene or not vehicle_node or not dash_ui:
		return
		
	# Exit garage at frame 10 after scene tree has fully settled
	if frame_count == 10:
		if main_scene.has_method("exit_garage_to_road"):
			main_scene.exit_garage_to_road()
		print("[Beauty Showcase v3] Exited garage to road.")
		return
		
	# Shot 1: Alfa 8C 2900B Spider Corto 3D Exterior Front 3/4 Beauty Shot
	if frame_count == 25:
		vehicle_node.apply_vehicle_model("alfa_8c")
		if cam_controller:
			cam_controller.set_process(false)
			cam_controller.set_physics_process(false)
			var c_pos = vehicle_node.global_position
			cam_controller.global_position = c_pos + Vector3(2.5, 0.95, 3.8)
			cam_controller.look_at(c_pos + Vector3(0.0, 0.45, 0.0), Vector3.UP)
		if dash_ui: dash_ui.visible = false
		
	if frame_count == 35:
		save_viewport_screenshot("screenshot_showcase_alfa8c_front34.png")
		print("[Beauty Showcase v3] Captured Alfa 8C front 3/4 beauty shot.")
		
	# Shot 2: Lancia Stratos HF Bertone Wedge Front 3/4 Beauty Shot
	if frame_count == 45:
		vehicle_node.apply_vehicle_model("lancia_stratos")
		if cam_controller:
			var c_pos = vehicle_node.global_position
			cam_controller.global_position = c_pos + Vector3(2.4, 0.85, 3.2)
			cam_controller.look_at(c_pos + Vector3(0.0, 0.35, 0.0), Vector3.UP)
			
	if frame_count == 55:
		save_viewport_screenshot("screenshot_showcase_stratos_front34.png")
		print("[Beauty Showcase v3] Captured Lancia Stratos front 3/4 beauty shot.")
		
	# Shot 3: Lancia Aurelia B20 GT Gran Turismo Front 3/4 Beauty Shot
	if frame_count == 65:
		vehicle_node.apply_vehicle_model("lancia_aurelia")
		if cam_controller:
			var c_pos = vehicle_node.global_position
			cam_controller.global_position = c_pos + Vector3(2.6, 1.05, 3.8)
			cam_controller.look_at(c_pos + Vector3(0.0, 0.45, 0.0), Vector3.UP)
			
	if frame_count == 75:
		save_viewport_screenshot("screenshot_showcase_aurelia_front34.png")
		print("[Beauty Showcase v3] Captured Lancia Aurelia B20 front 3/4 beauty shot.")
		
	# Shot 4: Lancia Delta HF Integrale Rally Front 3/4 (Flared Box Arches & Sculpted Vented Hood)
	if frame_count == 85:
		vehicle_node.apply_vehicle_model("delta_integrale")
		if cam_controller:
			var c_pos = vehicle_node.global_position
			cam_controller.global_position = c_pos + Vector3(2.5, 1.05, 3.6)
			cam_controller.look_at(c_pos + Vector3(0.0, 0.45, 0.0), Vector3.UP)
			
	if frame_count == 95:
		save_viewport_screenshot("screenshot_showcase_delta_integrale_front34.png")
		print("[Beauty Showcase v3] Captured Lancia Delta Integrale front 3/4 beauty shot.")
		
	# Shot 5: Fiat 127 Special Front 3/4 (Curved 180 arches, sculpted hood, chrome bumper with rostri)
	if frame_count == 105:
		vehicle_node.apply_vehicle_model("fiat_127")
		if cam_controller:
			var c_pos = vehicle_node.global_position
			cam_controller.global_position = c_pos + Vector3(2.3, 0.95, 3.2)
			cam_controller.look_at(c_pos + Vector3(0.0, 0.40, 0.0), Vector3.UP)
			
	if frame_count == 115:
		save_viewport_screenshot("screenshot_showcase_fiat127_front34.png")
		print("[Beauty Showcase v3] Captured Fiat 127 front 3/4 beauty shot.")
		
	# Shot 6: Fiat Topolino Front 3/4 (Swept pontoon fenders, 3D torpedo lamps)
	if frame_count == 125:
		vehicle_node.apply_vehicle_model("fiat_topolino")
		if cam_controller:
			var c_pos = vehicle_node.global_position
			cam_controller.global_position = c_pos + Vector3(2.2, 0.95, 2.9)
			cam_controller.look_at(c_pos + Vector3(0.0, 0.40, 0.0), Vector3.UP)
			
	if frame_count == 135:
		save_viewport_screenshot("screenshot_showcase_topolino_front34.png")
		print("[Beauty Showcase v3] Captured Fiat Topolino front 3/4 beauty shot.")
		print("[Beauty Showcase v3] ALL BEAUTY SHOTS V3 COMPLETED!")
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
