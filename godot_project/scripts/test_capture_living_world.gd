extends SceneTree

# ==============================================================================
# SCREENSHOT CAPTURE: LIVING WORLD AAA - VALICO DEI MOTORI '93
# ==============================================================================
# Captures high-fidelity screenshots of:
# 1. Borgo San Cristoforo 3D Town Life (Ape Piaggio, Vespa, Cabina SIP, Bar terrace)
# 2. Amiga 500 Topographic Map (Tab 5)
# 3. Amiga 500 Diner with Affinity Bar & Character Dialogues (Tab 3)
# 4. Amiga 500 "La Gazzetta del Valico '93" Dynamic Newspaper (Tab 1)
# ==============================================================================

const CameraController = preload("res://scripts/CameraController.gd")
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

var root_node: Node3D
var road_gen: Node3D
var vehicle: Node3D
var camera: CameraController
var sr_ui: Control
var frame_count: int = 0
var stage: int = 0

func _init():
	print("\n>>> AVVIO CAPTURE SCREENSHOT: LIVING WORLD AAA")

func _process(_delta: float):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			
			road_gen = root_node.get_node("RoadGenerator")
			vehicle = root_node.get_node("Vehicle")
			camera = root_node.get_node("CameraController")
			sr_ui = root_node.find_child("StreetRodUI", true, false)
			
			if sr_ui and sr_ui.has_method("close_screen"):
				sr_ui.close_screen()
		elif frame_count >= 8:
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		# 1. Position camera and car in Borgo San Cristoforo (Z = 920m) to view Ape, Vespa, SIP booth & Bar
		if frame_count == 2:
			print(">>> Posizionamento in Borgo San Cristoforo (Z = 920m) per screenshot vita di paese...")
			var rd_info = road_gen.get_road_info_at(920.0)
			vehicle.apply_vehicle_model("fiat_127")
			vehicle.global_position = Vector3(rd_info.x - 0.8, rd_info.y + 0.35, 920.0)
			vehicle.rotation = Vector3(0, PI + rd_info.angle, 0)
			
			camera.current_mode = CameraController.CameraMode.DIORAMA_ALTO
			camera.setup_initial_position()
		elif frame_count == 15:
			capture_screenshot("screenshot_borgo_life_3d.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		# 2. Open Tab 5: Carta Topografica del Valico '93
		if frame_count == 2:
			print(">>> Apertura Tab 5: Carta Topografica IGM '93...")
			if sr_ui:
				sr_ui.open_screen(4)
				sr_ui.select_map_waypoint(4) # Tornanti dei Larici
		elif frame_count == 10:
			capture_screenshot("screenshot_amiga_topographic_map.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		# 3. Open Tab 3: Diner "Da Bepi" with Don Attilio & Affinity bar
		if frame_count == 2:
			print(">>> Apertura Tab 3: Diner 'Da Bepi' con Don Attilio & Affinità...")
			if sr_ui:
				sr_ui.open_screen(2)
				sr_ui.select_diner_character("don_attilio")
		elif frame_count == 10:
			capture_screenshot("screenshot_amiga_diner_affinity.png")
			stage = 4
			frame_count = 0
			
	elif stage == 4:
		# 4. Open Tab 1: La Gazzetta del Valico '93
		if frame_count == 2:
			print(">>> Apertura Tab 1: La Gazzetta del Valico '93...")
			if sr_ui:
				sr_ui.open_screen(0)
		elif frame_count == 10:
			capture_screenshot("screenshot_amiga_gazzetta_press.png")
			print(">>> TUTTI GLI SCREENSHOT ACQUISITI CON SUCCESSO!")
			quit(0)

func capture_screenshot(filename: String):
	var img = root.get_texture().get_image()
	var dest = artifact_dir + "/" + filename
	var err = img.save_png(dest)
	if err == OK:
		print("    [SCREENSHOT SALVATO] -> %s" % dest)
	else:
		print("    [-] Errore salvataggio screenshot: %s (codice %d)" % [dest, err])
