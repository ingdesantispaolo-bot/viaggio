extends SceneTree

# ==============================================================================
# TEST & CAPTURE: CITTÀ DI SAN CRISTOFORO SUL MERIDIANO
# ==============================================================================
# Cattura screenshot della nuova città costruita all'inizio della strada:
# 1. Piazza della Repubblica, Chiesa Monumentale, Campanile, Municipio e Bar
# 2. Corso Garibaldi, Stazione Carabinieri, Panetteria, Macelleria e Periferia
# ==============================================================================

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86"
var root_node: Node3D
var vehicle: Node3D
var camera: CameraController
var main_script: Node
var frame_count: int = 0
var stage: int = 0

func _init():
	print(">>> AVVIO TEST & CAPTURE CITTÀ DI SAN CRISTOFORO...")

func _process(_delta: float):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			
			vehicle = root_node.get_node("Vehicle")
			camera = root_node.get_node("CameraController")
			main_script = root_node
			
			# Esci dal garage per attivare la fisica e posizionarci in città
			if main_script and main_script.has_method("exit_garage_to_road"):
				main_script.exit_garage_to_road()
				
			var dash = root_node.find_child("DashboardUI", true, false)
			if dash: dash.visible = false
			var uilayer = root_node.find_child("UILayer", true, false)
			if uilayer: uilayer.visible = false
				
		elif frame_count >= 10:
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		# Vista 1: Panoramica a volo d'uccello su Piazza della Repubblica, Chiesa e Municipio
		if frame_count == 2:
			print(">>> Posizionamento telecamera su Piazza della Repubblica & Chiesa...")
			camera.set_process(false)
			camera.set_physics_process(false)
			camera.current_mode = CameraController.CameraMode.DIORAMA_ALTO
			camera.global_position = Vector3(-18.0, 26.0, -28.0)
			camera.look_at(Vector3(25.0, 5.5, 0.0), Vector3.UP)
			camera.fov = 38.0
			
			# Posiziona l'auto in piazza vicino alla fontana
			vehicle.global_position = Vector3(14.0, 0.35, -4.0)
			vehicle.rotation = Vector3(0, deg_to_rad(70.0), 0)
			vehicle.linear_velocity = Vector3.ZERO
			
		elif frame_count == 14:
			capture_screenshot("screenshot_city_piazza_and_church.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		# Vista 2: Lungo Corso Garibaldi e Via delle Botteghe (Stazione Carabinieri, Panetteria, Macelleria)
		if frame_count == 2:
			print(">>> Posizionamento telecamera su Corso Garibaldi & Negozi...")
			camera.set_process(false)
			camera.set_physics_process(false)
			camera.current_mode = CameraController.CameraMode.DIORAMA_ISOMETRICO
			camera.global_position = Vector3(-8.0, 6.5, -18.0)
			camera.look_at(Vector3(22.0, 3.5, -2.0), Vector3.UP)
			camera.fov = 48.0
			
			# Posiziona l'auto su Corso Garibaldi all'incrocio di Via Roma
			vehicle.global_position = Vector3(-2.0, 0.35, -2.0)
			vehicle.rotation = Vector3(0, PI, 0)
			vehicle.linear_velocity = Vector3.ZERO
			
		elif frame_count == 14:
			capture_screenshot("screenshot_city_street_and_shops.png")
			print(">>> SCREENSHOT DELLA CITTÀ CATTURATI CON SUCCESSO!")
			quit(0)

func capture_screenshot(filename: String):
	var img = root.get_texture().get_image()
	var dest = artifact_dir + "/" + filename
	var err = img.save_png(dest)
	if err == OK:
		print("    [SCREENSHOT SALVATO] -> ", dest)
	else:
		print("    [-] Errore salvataggio screenshot: ", err)
