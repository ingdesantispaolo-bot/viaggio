extends SceneTree

# ==============================================================================
# TEST & CAPTURE: PIANURA AGRICOLA DEI PODERI, RETE STRADALE & MAPPA ANNI '80
# ==============================================================================

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86"
var root_node: Node3D
var vehicle: Node3D
var camera: CameraController
var road_gen: RoadGenerator
var frame_count: int = 0
var stage: int = 0

func _init():
	print(">>> AVVIO TEST & CAPTURE: PIANURA AGRICOLA DEI PODERI & RETE STRADALE...")

func _process(_delta: float):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			
			vehicle = root_node.get_node("Vehicle")
			camera = root_node.get_node("CameraController")
			road_gen = root_node.get_node("RoadGenerator")
			
			if root_node.has_method("exit_garage_to_road"):
				root_node.exit_garage_to_road()
				
			var dash = root_node.find_child("DashboardUI", true, false)
			if dash: dash.visible = false
			var uilayer = root_node.find_child("UILayer", true, false)
			if uilayer: uilayer.visible = false
			
			# Pre-genera chunk fino a Z=1300 per popolare l'intera pianura
			if road_gen:
				while road_gen.next_chunk_z < 1250.0:
					road_gen.generate_chunk()
				print("[+] Chunk pianura generati fino a Z=%.1fm" % road_gen.next_chunk_z)
				
		elif frame_count >= 12:
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		# Vista 1: Cascina Corte San Giorgio, Fienile, Trattore Fiat & Campi di Grano (Z ~ 240)
		if frame_count == 2:
			print(">>> Posizionamento telecamera su Cascina Corte San Giorgio & Campi...")
			camera.set_process(false)
			camera.set_physics_process(false)
			camera.current_mode = CameraController.CameraMode.DIORAMA_ALTO
			camera.global_position = Vector3(18.0, 16.0, 205.0)
			camera.look_at(Vector3(46.0, 3.5, 240.0), Vector3.UP)
			camera.fov = 44.0
			
			vehicle.global_position = Vector3(0.0, 0.7, 225.0)
			vehicle.rotation = Vector3.ZERO
			vehicle.linear_velocity = Vector3.ZERO
			
		elif frame_count == 14:
			capture_screenshot("screenshot_plain_cascina_and_wheat.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		# Vista 2: Antico Mulino ad Acqua, Ponte ad arco & Ruscello Chiaro (Z ~ 480)
		if frame_count == 2:
			print(">>> Posizionamento telecamera su Antico Mulino & Ruscello Chiaro...")
			camera.global_position = Vector3(22.0, 14.5, 455.0)
			camera.look_at(Vector3(-18.0, 3.0, 485.0), Vector3.UP)
			camera.fov = 46.0
			
			vehicle.global_position = Vector3(0.0, 1.25, 475.0)
			vehicle.rotation = Vector3.ZERO
			vehicle.linear_velocity = Vector3.ZERO
			
		elif frame_count == 14:
			capture_screenshot("screenshot_plain_watermill_and_stream.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		# Vista 3: Lago dei Salici, Pontile da pesca & Vigneti a spalliera (Z ~ 1040)
		if frame_count == 2:
			print(">>> Posizionamento telecamera su Lago dei Salici & Pontile...")
			camera.global_position = Vector3(26.0, 18.0, 1005.0)
			camera.look_at(Vector3(60.0, 1.5, 1045.0), Vector3.UP)
			camera.fov = 45.0
			
			vehicle.global_position = Vector3(0.0, 1.45, 1030.0)
			vehicle.rotation = Vector3.ZERO
			vehicle.linear_velocity = Vector3.ZERO
			
		elif frame_count == 14:
			capture_screenshot("screenshot_plain_lake_and_vineyards.png")
			stage = 4
			frame_count = 0
			
	elif stage == 4:
		# Vista 4: Carta Topografica IGM 1983 con Pianura dei Poderi e Rete Secondaria
		if frame_count == 2:
			print(">>> Cattura schermata Carta Topografica IGM '80s...")
			var MapClass = load("res://scripts/TopographicMapControl.gd")
			var map_inst = MapClass.new()
			map_inst.size = Vector2(1280, 800)
			map_inst.selected_waypoint_idx = 1 # Seleziona Cascina San Giorgio
			map_inst.player_distance_z = 240.0
			root.add_child(map_inst)
			
		elif frame_count == 6:
			capture_screenshot("screenshot_topographic_map_plain_80s.png")
			print(">>> TUTTI GLI SCREENSHOT DELLA PIANURA E DELLA MAPPA CATTURATI CON SUCCESSO!")
			quit(0)

func capture_screenshot(filename: String):
	var img = root.get_texture().get_image()
	var dest = artifact_dir + "/" + filename
	var err = img.save_png(dest)
	if err == OK:
		print("    [SCREENSHOT SALVATO] -> ", dest)
	else:
		print("    [-] Errore salvataggio screenshot: ", err)
