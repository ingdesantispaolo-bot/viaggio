extends SceneTree

var main_scene: Node = null
var vehicle: RigidBody3D = null
var road_gen: RoadGenerator = null
var biome_dir: Node = null
var camera: Camera3D = null

var test_step: int = 0
var frame_count: int = 0
var artifact_dir: String = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86"

func _init():
	print("[Coastal Capture] Inizializzazione cattura screenshot paesaggi costieri...")

func _process(delta: float):
	frame_count += 1
	
	if test_step == 0:
		if frame_count == 1:
			var main_packed = load("res://scenes/Main.tscn")
			assert(main_packed != null, "Impossibile caricare Main.tscn")
			main_scene = main_packed.instantiate()
			root.add_child(main_scene)
			
			vehicle = main_scene.get_node_or_null("Vehicle")
			road_gen = main_scene.get_node_or_null("RoadGenerator")
			biome_dir = main_scene.get_node_or_null("BiomeDirector")
			camera = main_scene.get_node_or_null("CameraController")
			
			var sr_ui = main_scene.find_child("StreetRodUI", true, false)
			if sr_ui:
				sr_ui.visible = false
			print("[Coastal Capture] Main scene caricata. Preriscaldamento chunk fino a 12000m...")
			
		elif frame_count == 15:
			teleport_to_z(8360.0)
			# Camera puntata verso il Belvedere e il Mare aperto sul lato sinistro (-X)
			var info = road_gen.get_road_info_at(8360.0)
			var car_pos = Vector3(info.x, info.y, 8360.0)
			camera.global_position = car_pos + Vector3(12.0, 6.0, -14.0)
			camera.look_at(car_pos + Vector3(-16.0, 0.5, 8.0), Vector3.UP)
			frame_count = 0
			test_step = 1

	elif test_step == 1:
		if frame_count == 20:
			capture_screenshot("coastal_belvedere_sea_8400m.png")
			print("[Coastal Capture] 1/4 Belvedere delle Sirene catturato!")
			
			teleport_to_z(8720.0)
			var info = road_gen.get_road_info_at(8720.0)
			var car_pos = Vector3(info.x, info.y, 8720.0)
			camera.global_position = car_pos + Vector3(8.0, 9.5, -28.0)
			camera.look_at(car_pos + Vector3(-28.0, 10.0, 12.0), Vector3.UP)
			frame_count = 0
			test_step = 2

	elif test_step == 2:
		if frame_count == 20:
			capture_screenshot("coastal_lighthouse_8720m.png")
			print("[Coastal Capture] 2/4 Faro Monumentale della Scogliera catturato!")
			
			teleport_to_z(9950.0)
			var info = road_gen.get_road_info_at(9950.0)
			var car_pos = Vector3(info.x, info.y, 9950.0)
			# Vista in soggettiva / terza persona ravvicinata che guarda lungo il corso del borgo
			camera.global_position = car_pos + Vector3(0.0, 2.2, -6.5)
			camera.look_at(car_pos + Vector3(0.0, 1.2, 18.0), Vector3.UP)
			frame_count = 0
			test_step = 3

	elif test_step == 3:
		if frame_count == 20:
			capture_screenshot("coastal_borgo_marina_10140m.png")
			print("[Coastal Capture] 3/4 Borgo Marina dei Pescatori & Pieve catturato!")
			
			teleport_to_z(11940.0)
			var info = road_gen.get_road_info_at(11940.0)
			var car_pos = Vector3(info.x, info.y, 11940.0)
			# Inquadratura monumentale su Porta Marina con la strada che attraversa l'arco
			camera.global_position = car_pos + Vector3(0.0, 4.0, -18.0)
			camera.look_at(car_pos + Vector3(0.0, 3.5, 12.0), Vector3.UP)
			frame_count = 0
			test_step = 4

	elif test_step == 4:
		if frame_count == 20:
			capture_screenshot("coastal_monumental_city_gate_11950m.png")
			print("[Coastal Capture] 4/4 Porta Marina di San Cristoforo catturata!")
			print("=====================================================================")
			print("TUTTE LE FOTOGRAFIE DEL CIRCUITO COSTIERO SALVATE CON SUCCESSO!")
			print("=====================================================================")
			quit(0)

func teleport_to_z(target_z: float):
	if not road_gen or not vehicle:
		return
	
	while road_gen.next_chunk_z < target_z + 240.0:
		road_gen.generate_chunk()
		
	var info = road_gen.get_road_info_at(target_z)
	var pos = Vector3(info.x, info.y + 0.35, target_z)
	vehicle.global_position = pos
	vehicle.linear_velocity = Vector3.ZERO
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.rotation = Vector3(0.0, info.angle, 0.0)
	if "current_z" in vehicle:
		vehicle.current_z = target_z
	vehicle.global_transform.origin = pos
	
	if biome_dir and biome_dir.has_method("update_atmosphere_for_z"):
		biome_dir.update_atmosphere_for_z(target_z)

func capture_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var save_path = artifact_dir + "/" + filename
		var err = img.save_png(save_path)
		if err == OK:
			print("[SCREENSHOT CAPTURED] Salvato in: %s" % save_path)
		else:
			print("[SCREENSHOT ERROR] Errore salvataggio: %d" % err)
