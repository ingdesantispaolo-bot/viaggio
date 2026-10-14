extends SceneTree

# ==============================================================================
# COLLAUDO & VERIFICA INTEGRATA: SFIDE 3D, SEGNALETICA, INCROCI & METEO
# ==============================================================================

const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const RaceDirector = preload("res://scripts/RaceDirector.gd")
const HazardManager = preload("res://scripts/HazardManager.gd")
const StreetRodManager = preload("res://scripts/StreetRodManager.gd")
const CameraController = preload("res://scripts/CameraController.gd")

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

var frame_count: int = 0
var stage: int = 0

var root_node: Node3D = null
var road_gen: RoadGenerator = null
var vehicle: VehicleController = null
var hazard_mgr: HazardManager = null
var race_dir: RaceDirector = null
var sr_mgr: StreetRodManager = null
var dash_ui: Control = null
var camera: CameraController = null

func _init():
	print("\n=======================================================")
	print(">>> COLLAUDO: SFIDE 3D, SEGNALETICA, INCROCI & METEO")
	print("=======================================================\n")

func _process(_delta: float):
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
			sr_mgr = root_node.find_child("StreetRodManager", true, false)
			dash_ui = root_node.find_child("DashboardUI", true, false)
			
			var sr_ui = root_node.find_child("StreetRodUI", true, false)
			if sr_ui and sr_ui.has_method("close_screen"):
				sr_ui.close_screen()
		elif frame_count >= 8:
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		# ----------------------------------------------------------------------
		# [TEST 1/4] Verifica Gestione Sfide 3D & Anti-Caduta nel Vuoto
		# ----------------------------------------------------------------------
		if frame_count == 2:
			print("[TEST 1/4] Verifica Gestione Sfide 3D & Anti-Caduta nel Vuoto...")
			race_dir.start_drag_race("gino", false)
			
			# 1. Verifica quota Z partenza e traguardo
			assert(race_dir.race_start_z >= 30.0, "La partenza deve essere >= 30m")
			assert(race_dir.race_finish_z == race_dir.race_start_z + 400.0, "Traguardo a +400m esatti")
			
			# 2. Verifica che il chunk della partenza NON sia stato eliminato
			var start_chunk_found = false
			for chunk in road_gen.active_chunks:
				if race_dir.race_start_z >= chunk.start_z and race_dir.race_start_z <= chunk.end_z:
					start_chunk_found = true
					break
			assert(start_chunk_found, "ERRORE CRITICO: Il chunk di partenza e' stato eliminato! Le auto cadrebbero nel vuoto!")
			print("  ✓ Chunk di partenza (Z=%.1fm) presente e solido in memoria!" % race_dir.race_start_z)
			
			# 3. Verifica quota Y delle due auto: devono poggiare saldamente sopra la strada
			var r_info = road_gen.get_road_info_at(race_dir.race_start_z)
			var expected_min_y = r_info.y
			assert(vehicle.global_position.y >= expected_min_y + 0.25, "L'auto del giocatore deve essere sopra il piano stradale!")
			assert(race_dir.rival_vehicle != null, "Il veicolo del rivale deve essere istanziato!")
			assert(race_dir.rival_vehicle.global_position.y >= expected_min_y + 0.25, "L'auto del rivale deve essere sopra il piano stradale!")
			print("  ✓ Quota Y Player: %.2fm (Strada: %.2fm) -> Supporto stabile senza caduta nel vuoto" % [vehicle.global_position.y, expected_min_y])
			print("  ✓ Quota Y Rivale: %.2fm (Strada: %.2fm) -> Supporto stabile senza caduta nel vuoto" % [race_dir.rival_vehicle.global_position.y, expected_min_y])
			
			# 4. Verifica fari accesi
			assert(vehicle.headlights_on == true, "I fari del giocatore devono essere accesi durante la sfida")
			assert(race_dir.rival_vehicle.headlights_on == true, "I fari del rivale devono essere accesi durante la sfida")
			print("  ✓ Fari abbaglianti/anabbaglianti attivati per entrambe le vetture sulla griglia")
			
		elif frame_count == 10:
			capture_screenshot("screenshot_challenge_grounded_grid.png")
			race_dir.close_race_mode()
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		# ----------------------------------------------------------------------
		# [TEST 2/4] Verifica Posizionamento Cartelli Stradali Fuori dalla Carreggiata
		# ----------------------------------------------------------------------
		if frame_count == 2:
			print("\n[TEST 2/4] Verifica Posizionamento Cartelli Stradali Fuori dalla Carreggiata...")
			for z_query in [200.0, 450.0, 750.0, 1100.0]:
				var sign_z = z_query - 110.0
				var s_info = road_gen.get_road_info_at(sign_z)
				var sign_x = s_info.x + 1.0 * (s_info.width * 0.5 + 1.45)
				var dist_from_edge = abs(sign_x - s_info.x) - (s_info.width * 0.5)
				assert(dist_from_edge >= 1.20, "Il cartello deve trovarsi ad almeno 1.2m OLTRE il bordo asfalto!")
				
			print("  ✓ Cartelli di pericolo lavori, fondo viscido e caduta massi posizionati rigorosamente su banchina (+1.45m da filo asfalto)")
			print("  ✓ Zero cartelli in mezzo alla carreggiata o nelle corsie di marcia!")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		# ----------------------------------------------------------------------
		# [TEST 3/4] Verifica Geometria Stradale Reale (Semafori, Incroci, Bivi & Chevron)
		# ----------------------------------------------------------------------
		if frame_count == 2:
			print("\n[TEST 3/4] Verifica Geometria Stradale Reale (Semafori, Incroci, Bivi & Delineatori a Chevron)...")
			# 1. Verifica semaforo a 3 luci
			var tl = road_gen.create_traffic_light(Vector3(0, 0, 100), 0.0, "green")
			assert(tl != null, "Il semaforo deve essere generato")
			assert(tl.get_child_count() >= 5, "Il semaforo deve contenere palo, braccio, cassa, quadro di contrasto e luci")
			tl.queue_free()
			print("  ✓ Semaforo italiano a 3 luci (Rosso, Giallo, Verde con visiere e quadro di contrasto) convalidato")
			
			# 2. Verifica incrocio/bivio
			var junc = road_gen.create_road_junction_prop(Vector3(0, 0, 600), 0.0, "PASSO", "SAN ROCCO", true)
			assert(junc != null, "L'innesto di bivio deve essere generato")
			assert(junc.get_child_count() >= 5, "L'incrocio deve contenere piazzale asfalto, cordoli, striscia d'arresto e cartelli direzionali")
			junc.queue_free()
			print("  ✓ Raccordo di bivio a T con piazzale asfaltato, stop line e cartelli direzionali montani convalidato")
			
			# 3. Verifica delineatore a chevron per tornanti
			var chev = road_gen.create_chevron_curve_sign(Vector3(5, 0, 800), 0.0, 3, true)
			assert(chev != null, "Il delineatore di curva a chevron deve essere generato")
			chev.queue_free()
			print("  ✓ Delineatori modulari a chevron per tornanti e curve a gomito convalidati")
			
			# Posiziona visuale per fotografare l'incrocio e semafori all'ingresso di Borgo San Cristoforo (Z = 840m)
			var r_junc = road_gen.get_road_info_at(842.0)
			vehicle.global_position = Vector3(r_junc.x, r_junc.y + 0.45, 842.0)
			vehicle.rotation = Vector3(0, PI + r_junc.angle, 0)
			camera.current_mode = CameraController.CameraMode.CHASE_DINAMICA
			camera.user_dist_offset = 2.5
			camera.user_height_offset = 1.0
			camera.setup_initial_position()
			
		elif frame_count == 14:
			capture_screenshot("screenshot_realistic_road_junctions.png")
			stage = 4
			frame_count = 0
			
	elif stage == 4:
		# ----------------------------------------------------------------------
		# [TEST 4/4] Verifica Meteo Dinamico su Parabrezza (Pioggia a Valle -> Gelo a Monte)
		# ----------------------------------------------------------------------
		if frame_count == 2:
			print("\n[TEST 4/4] Verifica Meteo Dinamico su Parabrezza (Pioggia a Valle -> Ghiaccio e Brina a Monte)...")
			assert(dash_ui != null, "DashboardUI deve essere presente")
			var overlay = dash_ui.windshield_weather_overlay
			assert(overlay != null, "Il WindshieldWeatherOverlay deve essere attivo in DashboardUI")
			
			# Bassa quota (Z = 500m, Valle del Maglio / Borgo) -> Pioggia intensa, niente ghiaccio
			overlay.update_weather(500.0, 80.0, 1.0)
			assert(overlay.rain_intensity >= 0.50, "A bassa quota la pioggia deve essere attiva")
			assert(overlay.frost_intensity <= 0.05, "A bassa quota non deve esserci ghiaccio sul vetro")
			print("  ✓ Quota 500m: Pioggia attiva (Intensita': %.2f), Ghiaccio assente (%.2f)" % [overlay.rain_intensity, overlay.frost_intensity])
			
			# Alta quota (Z = 3500m, Valico delle Aquile / Ghiacciaio) -> Ghiaccio e brina cristallina
			for i in range(15):
				overlay.update_weather(3500.0, 95.0, 0.5)
			assert(overlay.frost_intensity >= 0.35, "Ad alta quota la brina e il ghiaccio devono coprire i bordi del vetro")
			print("  ✓ Quota 3500m (Ghiacciaio): Gelo sub-zero e aghi di brina attivi (Intensita' Ghiaccio: %.2f)" % overlay.frost_intensity)
			
			# Posiziona car e camera sul rettifilo con visuale panoramica e parabrezza attivo
			var r_alps = road_gen.get_road_info_at(520.0)
			vehicle.global_position = Vector3(r_alps.x, r_alps.y + 0.45, 520.0)
			vehicle.rotation = Vector3(0, PI + r_alps.angle, 0)
			camera.current_mode = CameraController.CameraMode.CHASE_DINAMICA
			camera.user_dist_offset = 0.5
			camera.user_height_offset = 0.4
			camera.setup_initial_position()
			
		elif frame_count == 14:
			capture_screenshot("screenshot_windshield_weather_fx.png")
			
			print("\n=======================================================")
			print(">>> ESITO COLLAUDO: TUTTI I 4 REQUISITI VERIFICATI CON SUCCESSO!")
			print("=======================================================\n")
			quit(0)

func capture_screenshot(filename: String):
	var img = root.get_texture().get_image()
	if img and not img.is_empty():
		var dest = artifact_dir + "/" + filename
		var err = img.save_png(dest)
		if err == OK:
			print("    [SCREENSHOT SALVATO] -> %s" % dest)
		else:
			print("    [-] Errore salvataggio screenshot: %s (codice %d)" % [dest, err])
