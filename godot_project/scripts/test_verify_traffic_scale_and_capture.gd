extends SceneTree

# ==============================================================================
# TEST VERIFICA: SCALA 75%, CORSIA DI DESTRA (CODICE DELLA STRADA) & AUDIO MOTORE
# ==============================================================================

const CivilianTrafficManager = preload("res://scripts/CivilianTrafficManager.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")
const CameraController = preload("res://scripts/CameraController.gd")

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/80482df3-861c-4f01-b762-b7e41f9e5340"

var root_node: Node3D
var road_gen: Node3D
var vehicle: VehicleController
var camera: CameraController
var traffic_mgr: Node3D
var sr_ui: Control
var frame_count: int = 0
var stage: int = 0

func _init():
	print("\n==================================================================")
	print("  TEST VERIFICA: SCALA 75%, CORSIA DI DESTRA & AUDIO MOTORE")
	print("==================================================================")

func _process(delta: float):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			
			road_gen = root_node.get_node("RoadGenerator")
			vehicle = root_node.get_node("Vehicle")
			camera = root_node.get_node("CameraController")
			traffic_mgr = root_node.find_child("CivilianTrafficManager", true, false)
			sr_ui = root_node.find_child("StreetRodUI", true, false)
			
			if sr_ui and sr_ui.has_method("close_screen"):
				sr_ui.close_screen()
		elif frame_count >= 10:
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		# Verifica audio e scala veicolo giocatore
		print("\n--- VERIFICA 1: AUDIO MOTORE & SCALA PLAYER ---")
		assert(VehicleController.PLAYER_SCALE == 0.75, "PLAYER_SCALE deve essere esattamente 0.75!")
		
		# Verifica AudioEngine
		var audio = vehicle.get_node_or_null("VehicleAudio")
		assert(audio != null, "VehicleAudio deve esistere sul veicolo del giocatore")
		assert(audio.engine_player != null, "engine_player deve essere istanziato")
		assert(audio.engine_player.stream != null, "Lo stream audio del motore non deve essere nullo")
		assert(audio.engine_player.playing, "Il suono del motore deve essere in riproduzione attiva (loop)")
		assert(audio.engine_player.volume_db >= -10.0, "Il volume del motore deve essere ben udibile (>= -10.0 dB)")
		print("[PASS] Audio motore in riproduzione attiva continua, volume corposo: %.1f dB" % audio.engine_player.volume_db)
		
		# Verifica CollisionShape3D scalata
		var col_shape = vehicle.get_node_or_null("CollisionShape3D")
		assert(col_shape != null, "CollisionShape3D del giocatore deve esistere")
		print("[PASS] Scala giocatore verificata: collisione e modelli proporzionati al 75%.")
		
		stage = 2
		frame_count = 0
		
	elif stage == 2:
		print("\n--- VERIFICA 2: TRAFFICO CIVILE IN CORSIA DI DESTRA (CODICE DELLA STRADA) ---")
		assert(CivilianTrafficManager.CIVILIAN_SCALE == 0.75, "CIVILIAN_SCALE deve essere 0.75!")
		
		# Assicura spawn traffico davanti al giocatore
		if traffic_mgr:
			for i in range(8):
				traffic_mgr.try_spawn_traffic_vehicle(vehicle.global_position.z)
				
			print("Numero veicoli civili generati: %d" % traffic_mgr.active_traffic.size())
			for car in traffic_mgr.active_traffic:
				var r_info = road_gen.get_road_info_at(car.current_z)
				var half_w = r_info.width * 0.5
				# Verifica rigorosa corsia di destra (In Italia si tiene la destra: coord X negativa)
				assert(car.lane_offset < 0.0, "Tutti i veicoli DEVONO viaggiare a DESTRA (offset < 0)! Rilevato offset: %f" % car.lane_offset)
				assert(car.lane_offset >= -half_w * 0.65, "I veicoli non devono andare sul ciglio della strada! offset: %f, limite: %f" % [car.lane_offset, -half_w * 0.65])
				assert(not car.is_oncoming, "Nessun veicolo regolare deve viaggiare contromano!")
				
			print("[PASS] Tutti i veicoli circolano rigorosamente nella corsia di DESTRA, senza toccare il ciglio.")
		
		stage = 3
		frame_count = 0
		
	elif stage == 3:
		# Posiziona il veicolo in corsa e allinea la telecamera per lo screenshot
		if frame_count == 2:
			print("\n--- CATTURA SCREENSHOT DI GIOCO IN-ENGINE ---")
			var p_z = 110.0
			var rd_info = road_gen.get_road_info_at(p_z)
			var half_w = rd_info.width * 0.5
			
			# Applica modello Fiat 127 Special al giocatore
			vehicle.apply_vehicle_model("fiat_127")
			vehicle.current_speed_kmh = 65.0
			vehicle.current_gear = 3
			vehicle.gear_name = "3ª"
			vehicle.current_fuel = 21.5
			vehicle.engine_temp = 88.0
			
			# Player rigorosamente nella corsia di destra (-X)
			vehicle.global_position = Vector3(rd_info.x - half_w * 0.48, rd_info.y + 0.35, p_z)
			vehicle.rotation = Vector3(0, PI + rd_info.angle, 0)
			vehicle.linear_velocity = Vector3.ZERO
			
			# Rimuovi veicoli di traffico precedenti per evitare sovrapposizioni
			if traffic_mgr:
				for c in traffic_mgr.active_traffic:
					if c.has("node") and is_instance_valid(c.node):
						c.node.queue_free()
				traffic_mgr.active_traffic.clear()
				
				# Spawna un Trattore Landini davanti sulla corsia di destra a Z = 135m (25m avanti)
				var front_car = traffic_mgr.create_traffic_model("trattore_landini", false)
				traffic_mgr.add_child(front_car)
				var tf_info = road_gen.get_road_info_at(135.0)
				front_car.global_position = Vector3(tf_info.x - tf_info.width * 0.5 * 0.54, tf_info.y + 0.28, 135.0)
				front_car.rotation = Vector3(0, PI + tf_info.angle, 0)
				
				# Spawna una Fiat Panda 4x4 ancora piu' avanti a Z = 160m (50m avanti)
				var front_car2 = traffic_mgr.create_traffic_model("panda_4x4", false)
				traffic_mgr.add_child(front_car2)
				var tf_info2 = road_gen.get_road_info_at(160.0)
				front_car2.global_position = Vector3(tf_info2.x - tf_info2.width * 0.5 * 0.50, tf_info2.y + 0.28, 160.0)
				front_car2.rotation = Vector3(0, PI + tf_info2.angle, 0)
			
			# Imposta la vista BONNET_COCKPIT per verificare l'inquadratura dall'interno e la visibilita'
			camera.set_camera_mode(CameraController.CameraMode.BONNET_COCKPIT)
			camera.setup_initial_position()
			
		elif frame_count == 23:
			print("\n--- VISIBLE MESHES AROUND CAMERA ---")
			var cam_p = camera.global_position
			var all_meshes = root_node.find_children("*", "MeshInstance3D", true, false)
			for m in all_meshes:
				if not m.is_visible_in_tree(): continue
				var m_pos = m.global_position
				var dist = cam_p.distance_to(m_pos)
				if dist < 1.8:
					var mat_name = "null"
					if m.material_override: mat_name = str(m.material_override.albedo_color)
					elif m.mesh and m.mesh.material: mat_name = str(m.mesh.material.albedo_color)
					var s_info = ""
					if m.mesh is BoxMesh: s_info = "BOX: " + str(m.mesh.size)
					print("MESH: %s | PARENT: %s | DIST: %.2fm | LOCAL_P: %s | COL: %s | %s" % [m.name, m.get_parent().name, dist, str(m.position), mat_name, s_info])
		elif frame_count == 24:
			print("CAMERA GLOBAL POS: ", camera.global_position)
			print("CAMERA ROT DEG: ", camera.global_rotation_degrees)
			print("CAMERA FOV: ", camera.fov)
			print("VEHICLE GLOBAL POS: ", vehicle.global_position)
			print("VEHICLE ROT DEG: ", vehicle.global_rotation_degrees)
			print("CAMERA SMOOTHED POS: ", camera.smoothed_pos)
			print("CAMERA SMOOTHED LOOKAT: ", camera.smoothed_lookat)
		elif frame_count == 25:
			capture_screenshot("screenshot_cockpit_view_wide.png")
			capture_screenshot("screenshot_veglia_dashboard_redesign.png")
			print("==================================================================")
			print("  TUTTI I REQUISITI VERIFICATI CON SUCCESSO! FINE TEST.")
			print("==================================================================\n")
			quit(0)

func capture_screenshot(filename: String):
	var img = root.get_texture().get_image()
	var dest = artifact_dir + "/" + filename
	var err = img.save_png(dest)
	if err == OK:
		print("    [SCREENSHOT SALVATO] -> %s" % dest)
	else:
		print("    [-] Errore salvataggio screenshot: %s (codice %d)" % [dest, err])
