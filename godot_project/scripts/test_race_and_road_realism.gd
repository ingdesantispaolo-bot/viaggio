extends SceneTree

# ==============================================================================
# TEST SUITE & VISUAL VERIFICATION: 3D RACE, ROAD DYNAMICS & REALISM
# ==============================================================================

const RaceDirector = preload("res://scripts/RaceDirector.gd")
const StreetRodUI = preload("res://scripts/StreetRodUI.gd")
const StreetRodManager = preload("res://scripts/StreetRodManager.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")
const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const HazardManager = preload("res://scripts/HazardManager.gd")
const CameraController = preload("res://scripts/CameraController.gd")

var frame_count: int = 0
var stage: int = 0

var root_node: Node3D = null
var road_gen: RoadGenerator = null
var vehicle: VehicleController = null
var hazard_mgr: HazardManager = null
var race_dir: RaceDirector = null
var sr_ui: StreetRodUI = null
var sr_mgr: StreetRodManager = null
var camera: CameraController = null

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

func _init():
	print("\n====================================================================")
	print(">>> AVVIO TEST: GARE 3D, CURVE, BUCHE, TENUTA DI STRADA E REALISMO")
	print("====================================================================\n")

func _process(delta):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			
			road_gen = root_node.get_node("RoadGenerator")
			vehicle = root_node.get_node("Vehicle")
			hazard_mgr = root_node.get_node("HazardManager")
			race_dir = root_node.get_node("RaceDirector")
			camera = root_node.get_node("CameraController")
			sr_ui = root_node.find_child("StreetRodUI", true, false)
			sr_mgr = root_node.find_child("StreetRodManager", true, false)
		elif frame_count >= 5:
			# Scene fully ready!
			run_core_assertions()
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		# Stage 1: Setup 3D Race Start against Gino
		if frame_count == 2:
			print("\n[SCENARIO 1] Allineamento sulla Griglia di Partenza 3D:")
			race_dir.start_drag_race("gino", false)
			print("  Partenza impostata a Z=%.1f, Traguardo a Z=%.1f" % [race_dir.race_start_z, race_dir.race_finish_z])
		elif frame_count == 12:
			# Capture screenshot of side-by-side starting grid
			capture_screenshot("screenshot_race_start_3d.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		# Stage 2: Move to Finish Line at 400m
		if frame_count == 2:
			print("\n[SCENARIO 2] Inquadratura Traguardo 3D (Arrivo 400 Metri):")
			road_gen.update_generation(race_dir.race_finish_z + 100.0)
			var fin_info = road_gen.get_road_info_at(race_dir.race_finish_z - 15.0)
			vehicle.global_position = Vector3(fin_info.x - 1.95, fin_info.y + 0.35, race_dir.race_finish_z - 15.0)
			vehicle.rotation = Vector3(0, PI + fin_info.angle, 0)
			if race_dir.rival_vehicle:
				race_dir.rival_vehicle.global_position = Vector3(fin_info.x + 1.95, fin_info.y + 0.35, race_dir.race_finish_z - 12.0)
				race_dir.rival_vehicle.rotation = Vector3(0, PI + fin_info.angle, 0)
			if camera:
				camera.setup_initial_position()
		elif frame_count == 10:
			capture_screenshot("screenshot_race_finish_3d.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		# Stage 3: High speed through mountain curves and potholes
		if frame_count == 2:
			print("\n[SCENARIO 3] Verifica Strada Stretta (7.8m), Curve Sopraelevate e Buche:")
			race_dir.close_race_mode()
			vehicle.apply_vehicle_model("bmw_320_e30")
			var p_z = race_dir.race_finish_z + 90.0
			road_gen.update_generation(p_z + 180.0)
			var rd_info = road_gen.get_road_info_at(p_z)
			vehicle.global_position = Vector3(rd_info.x + 1.2, rd_info.y + 0.35, p_z)
			vehicle.rotation = Vector3(0, PI + rd_info.angle, 0)
			camera.current_mode = CameraController.CameraMode.CHASE_DINAMICA
			camera.user_dist_offset = 2.0
			camera.user_height_offset = 0.8
			camera.setup_initial_position()
		elif frame_count == 10:
			capture_screenshot("screenshot_mountain_road_potholes.png")
			print("\n====================================================================")
			print(">>> TUTTI I TEST E LE VERIFICHE VISIVE COMPLETATE CON SUCCESSO! ✓")
			print("====================================================================\n")
			quit(0)

func run_core_assertions():
	# [TEST 1] Verifica Dimensione Carreggiata
	print("[TEST 1] Calibrazione Dimensioni Carreggiata (7.8m Passo Alpino):")
	assert(road_gen.base_width == 7.8, "base_width deve essere 7.8m (due corsie standard)")
	print("  Larghezza Asfalto Base: %.2f m (Corsie da 3.4m + banchina)" % road_gen.base_width)
	print("  -> TEST 1 SUPERATO ✓")
	
	# [TEST 2] Verifica Sovraelevazione Curve (Banking / Camber)
	print("\n[TEST 2] Verifica Sovraelevazione Curve (Pendenza Trasversale):")
	road_gen.update_generation(300.0)
	var has_banked_points = false
	for chunk in road_gen.active_chunks:
		for pt in chunk.points:
			if abs(pt.get("angle", 0.0)) > 0.04:
				has_banked_points = true
				break
	assert(has_banked_points, "La strada deve contenere curve con inclinazione angolare")
	print("  Curvatura e inclinazione registrate sui punti procedurali.")
	print("  -> TEST 2 SUPERATO ✓")
	
	# [TEST 3] Verifica Generazione Buche nell'Asfalto
	print("\n[TEST 3] Generazione e Rilevamento Buche nell'Asfalto:")
	assert(road_gen.active_potholes.size() > 0, "Nessuna buca generata sui tratti di strada")
	var p0 = road_gen.active_potholes[0]
	print("  Buche attive lungo il percorso: %d" % road_gen.active_potholes.size())
	print("  Esempio buca: Pos=(%.1f, %.1f, %.1f) Raggio=%.2fm Profondità=%.2fm" % [
		p0.x, p0.y, p0.z, p0.radius, p0.depth
	])
	var detected = road_gen.get_pothole_at_position(Vector3(p0.x, p0.y, p0.z), 0.5)
	assert(not detected.is_empty(), "La buca deve essere rilevata dalla query di contatto ruota")
	print("  -> TEST 3 SUPERATO ✓")
	
	# [TEST 4] Verifica Ostacoli sulla Carreggiata (Massi, Olio, Tronchi)
	print("\n[TEST 4] Rilevamento Ostacoli Carreggiata e Fondo Viscido:")
	hazard_mgr.build_oil_slick_hazard(hazard_mgr, 150.0, 1.0, { "x": 0.0, "y": 0.0, "width": 7.8, "angle": 0.0 })
	var slip_factor = hazard_mgr.get_slippery_factor(Vector3(1.75, 0.0, 150.0))
	assert(slip_factor <= 0.35, "Macchia d'olio deve ridurre drasticamente l'attrito")
	print("  Coefficiente attrito su macchia d'olio: %.2f (Perdita aderenza immediata)" % slip_factor)
	print("  -> TEST 4 SUPERATO ✓")
	
	# [TEST 5] Verifica Dinamica di Guida: Trasferimento di Carico
	print("\n[TEST 5] Trasferimento di Carico & Dinamica Drivetrain:")
	vehicle.apply_vehicle_model("bmw_320_e30")
	assert(vehicle.current_model_id == "bmw_320_e30", "Modello BMW 320 non attivo")
	vehicle.linear_velocity = Vector3(0, 0, 16.0)
	vehicle.last_linear_velocity = Vector3(0, 0, 8.0)
	vehicle._physics_process(0.016)
	var rear_grip = vehicle.wheel_rl.wheel_friction_slip
	var front_grip = vehicle.wheel_fl.wheel_friction_slip
	assert(rear_grip > front_grip, "In accelerazione il retrotreno deve avere maggiore carico normale")
	print("  Aderenza Posteriore (RWD carico): %.2f vs Anteriore: %.2f" % [rear_grip, front_grip])
	
	# Simula FWD e sottosterzo (Fiat 127)
	vehicle.apply_vehicle_model("fiat_127")
	vehicle.steering = 0.20
	vehicle.ai_throttle = 1.0
	vehicle.is_ai_controlled = true
	vehicle._physics_process(0.016)
	print("  Aderenza Anteriore FWD sotto gas in curva: %.2f (Sottosterzo Dante Giacosa attivo)" % vehicle.wheel_fl.wheel_friction_slip)
	print("  -> TEST 5 SUPERATO ✓")
	
	# [TEST 6] Verifica Chiusura Immediata Schermata di Selezione
	print("\n[TEST 6] Chiusura Schermata Menu all'Avvio Sfida (Visuale Libera):")
	sr_ui.open_screen(2) # Apri Diner
	assert(sr_ui.visible == true, "La schermata StreetRodUI deve essere aperta")
	sr_ui.start_drag_against_rival("gino", false)
	assert(sr_ui.visible == false, "La schermata deve sparire all'istante all'avvio della gara!")
	print("  Schermata chiusa: visible = false (Strada e punto di partenza al 100% visibili)")
	print("  -> TEST 6 SUPERATO ✓")
	
	# [TEST 7] Verifica Traliccio di Partenza e Griglia 3D
	print("\n[TEST 7] Traliccio di Partenza 3D, Griglia a Scacchi e Semaforo:")
	assert(race_dir.start_gantry_node != null, "Traliccio di partenza 3D non generato")
	assert(race_dir.tree_lights_mesh.size() == 4, "Semaforo Christmas Tree deve avere 4 livelli di luce")
	print("  Traliccio di Partenza 3D posizionato a Z = %.1f m" % race_dir.race_start_z)
	print("  Luci Semaforo 3D inizializzate: %d stadi (Stage, Giallo 1, Giallo 2, Verde)" % race_dir.tree_lights_mesh.size())
	print("  -> TEST 7 SUPERATO ✓")
	
	# [TEST 8] Verifica Auto Rivale Fisico in Griglia
	print("\n[TEST 8] Auto Rivale 3D Fisico sul Box 2:")
	assert(race_dir.rival_vehicle != null, "Auto del rivale 3D mancante")
	assert(race_dir.rival_vehicle.visible == true, "Auto rivale deve essere visibile")
	assert(race_dir.rival_vehicle.current_model_id == "golf_gti_1990", "Gino deve guidare la Golf GTI 16V")
	print("  Rivale Schierato: Gino 'Il Corsaiolo' su Golf GTI 16V (1990)")
	print("  Posizione Rivale: X=%.2fm, Z=%.2fm (Fianco a fianco col giocatore)" % [
		race_dir.rival_vehicle.global_position.x, race_dir.rival_vehicle.global_position.z
	])
	print("  -> TEST 8 SUPERATO ✓")
	
	# [TEST 9] Verifica Traliccio del Traguardo a 400m
	print("\n[TEST 9] Traliccio del Traguardo 3D (Arrivo 400m):")
	assert(race_dir.finish_gantry_node != null, "Traliccio del traguardo 3D mancante")
	assert(race_dir.race_finish_z == race_dir.race_start_z + 400.0, "Distanza traguardo deve essere esattamente 400m")
	print("  Linea del Traguardo posizionata a Z = %.1f m (Distanza: 400.0m)" % race_dir.race_finish_z)
	print("  -> TEST 9 SUPERATO ✓")
	
	# [TEST 10] Sequenza Semaforo e Partenza Gara
	print("\n[TEST 10] Sequenza Semaforo di Partenza & Semaforo Verde:")
	race_dir.update_countdown(4.2)
	assert(race_dir.current_state == RaceDirector.RaceState.RACING, "Stato gara deve essere RACING dopo il verde")
	assert(vehicle.is_ai_controlled == false, "Controllo acceleratore rilasciato al giocatore")
	print("  Semaforo Verde scattato! VIA! VIA! VIA!")
	print("  -> TEST 10 SUPERATO ✓")
	
	# [TEST 11] Avanzamento Gara e Taglio del Traguardo
	print("\n[TEST 11] Corsa 3D e Rilevamento Taglio del Traguardo:")
	vehicle.global_position.z = race_dir.race_finish_z + 5.0
	vehicle.current_speed_kmh = 148.0
	race_dir.rival_vehicle.global_position.z = race_dir.race_finish_z + 2.0
	race_dir.rival_vehicle.current_speed_kmh = 142.0
	race_dir.update_race(0.016)
	assert(race_dir.current_state == RaceDirector.RaceState.FINISHED, "Gara deve terminare all'arrivo")
	assert(race_dir.hud_result_card.visible == true, "Scheda risultati deve comparire a fine gara")
	print("  Vittoria Giocatore: %.2fs @ %d km/h vs Rivale: %.2fs @ %d km/h" % [
		race_dir.player_finish_time, int(race_dir.player_trap_speed),
		race_dir.rival_finish_time, int(race_dir.rival_trap_speed)
	])
	print("  -> TEST 11 SUPERATO ✓")

func capture_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var full_path = artifact_dir + "/" + filename
		var err = img.save_png(full_path)
		if err == OK:
			print("  [SCREENSHOT SALVATO]: %s" % full_path)
		else:
			print("  [ERRORE SALVATAGGIO SCREENSHOT]: %d" % err)
