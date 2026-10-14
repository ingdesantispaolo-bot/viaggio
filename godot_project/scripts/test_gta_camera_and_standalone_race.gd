extends SceneTree

# ==============================================================================
# COLLAUDO AUTOMATIZZATO: CAMERA GTA CHASE & GARA STANDALONE CON RITORNO AL MENU
# ==============================================================================

const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const RaceDirector = preload("res://scripts/RaceDirector.gd")
const StreetRodManager = preload("res://scripts/StreetRodManager.gd")
const StreetRodUI = preload("res://scripts/StreetRodUI.gd")
const CameraController = preload("res://scripts/CameraController.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

var frame_count: int = 0
var test_phase: int = 0

var root_node: Node3D = null
var road_gen: RoadGenerator = null
var vehicle: VehicleController = null
var camera: CameraController = null
var race_dir: RaceDirector = null
var sr_mgr: StreetRodManager = null
var sr_ui: StreetRodUI = null

var saved_exploration_pos = Vector3(2.5, 14.2, 780.0)

func _init():
	print("\n=======================================================")
	print(">>> COLLAUDO: TELECAMERA GTA CHASE & GARA STANDALONE")
	print("=======================================================\n")

func _process(_delta: float):
	frame_count += 1
	
	if test_phase == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			
			road_gen = root_node.get_node("RoadGenerator")
			vehicle = root_node.get_node("Vehicle")
			camera = root_node.get_node("CameraController")
			race_dir = root_node.get_node("RaceDirector")
			sr_mgr = root_node.find_child("StreetRodManager", true, false)
			sr_ui = root_node.find_child("StreetRodUI", true, false)
			
			if sr_ui and sr_ui.has_method("close_screen"):
				sr_ui.close_screen()
				
		elif frame_count == 4:
			# ------------------------------------------------------------------
			# TEST 1: TELECAMERA GTA CHASE DINAMICA (SEMPRE DIETRO ALL'AUTO)
			# ------------------------------------------------------------------
			print("\n[TEST 1/5] Verifica Modalita' Telecamera Default GTA...")
			assert(camera.current_mode == CameraController.CameraMode.CHASE_DINAMICA, "La modalita' di default deve essere CHASE_DINAMICA (GTA)!")
			var p = camera.PRESETS[camera.current_mode]
			assert(p.height == 2.2 and p.distance == 5.8, "I parametri GTA chase devono essere height: 2.2, distance: 5.8!")
			print("  ✓ Modalita' attiva: %s (Altezza: %.1fm, Distanza: %.1fm, Lookahead: %.1fm, FOV: %.1f°)" % [
				p.name, p.height, p.distance, p.lookahead, p.fov
			])
			
			# Posiziona veicolo rivolto in avanti lungo la strada (+Z)
			vehicle.global_position = Vector3(0.0, 1.0, 100.0)
			vehicle.rotation = Vector3(0.0, 0.0, 0.0) # -basis.z points towards -Z, let's set rotation.y = PI for +Z
			vehicle.rotation.y = PI # facing +Z
			camera.setup_initial_position()
			
		elif frame_count == 8:
			# Veicolo rivolto verso +Z: telecamera deve essere DIETRO (Z < 100.0)
			var cam_pos = camera.global_position
			var veh_pos = vehicle.global_position
			var behind_delta = cam_pos.z - veh_pos.z
			print("  ✓ Marcia in avanti (+Z): Car Z=%.1f, Cam Z=%.1f (Delta Z = %.2f -> Telecamera DIETRO)" % [
				veh_pos.z, cam_pos.z, behind_delta
			])
			assert(cam_pos.z < veh_pos.z, "La telecamera deve trovarsi dietro l'auto (Z minore quando l'auto guarda verso +Z)!")
			
			# ------------------------------------------------------------------
			# TEST 2: INVERSIONE DI MARCIA 180° ("CAMBIA DIREZIONE E TORNA INDIETRO")
			# ------------------------------------------------------------------
			print("\n[TEST 2/5] Inversione a U (180°) - Verifica che la telecamera resti DIETRO all'auto...")
			# L'auto compie un'inversione completa e punta a tornare indietro lungo la strada (-Z)
			vehicle.rotation.y = 0.0 # -basis.z points towards -Z
			
		elif frame_count == 25:
			# Dopo interpolazione, la telecamera deve aver ruotato di 180° e trovarsi DIETRO alla coda (ora Z > 100.0)
			var cam_pos = camera.global_position
			var veh_pos = vehicle.global_position
			var behind_delta = cam_pos.z - veh_pos.z
			print("  ✓ Dopo inversione (-Z, torna indietro): Car Z=%.1f, Cam Z=%.1f (Delta Z = +%.2f -> Telecamera DIETRO)" % [
				veh_pos.z, cam_pos.z, behind_delta
			])
			assert(cam_pos.z > veh_pos.z, "La telecamera DEVE restare dietro all'auto anche dopo aver fatto inversione (Z maggiore quando l'auto guarda a -Z)!")
			
			# Test GTA Look-Back (Tasto C)
			var ev = InputEventKey.new()
			ev.keycode = KEY_C
			ev.pressed = true
			camera._unhandled_input(ev)
			assert(abs(camera.orbit_yaw - PI) < 0.01, "Il tasto C deve attivare istantaneamente la visuale posteriore a 180°!")
			print("  ✓ Tasto C (Look-Back GTA): visuale posteriore a 180° attivata con successo (orbit_yaw: %.2f rad)" % camera.orbit_yaw)
			
			# Reset look-back
			camera.reset_camera_orbit()
			test_phase = 1
			frame_count = 0

	elif test_phase == 1:
		if frame_count == 2:
			capture_screenshot("screenshot_gta_camera_behind_uturn.png")
			
			# ------------------------------------------------------------------
			# TEST 3: GARA STANDALONE ("LA GARA DEVE ESSERE UNA COSA A PARTE")
			# ------------------------------------------------------------------
			print("\n[TEST 3/5] Schieramento Gara Standalone su Rettifilo Dedicato (Z=40m - 440m)...")
			# Simuliamo il giocatore in esplorazione libera a km 0.78 (Z = 780m)
			vehicle.global_position = saved_exploration_pos
			vehicle.linear_velocity = Vector3(0.0, 0.0, 15.0)
			
			# Il giocatore apre il Diner (Tab 2) o la Sfida Drag e lancia la gara contro Gino
			assert(race_dir != null, "RaceDirector deve essere istanziato")
			race_dir.start_drag_race("gino", false, 2)
			
			assert(race_dir.has_pre_race_state == true, "Lo stato di esplorazione pre-gara deve essere memorizzato!")
			assert(abs(race_dir.pre_race_transform.origin.z - saved_exploration_pos.z) < 1.0, "La coordinata Z di esplorazione deve essere preservata!")
			print("  ✓ Stato pre-gara salvato: coordinate esplorazione = (%.1f, %.1f, %.1f)" % [
				race_dir.pre_race_transform.origin.x, race_dir.pre_race_transform.origin.y, race_dir.pre_race_transform.origin.z
			])
			
		elif frame_count == 6:
			# Verifica griglia di partenza
			var p_pos = vehicle.global_position
			var r_veh = race_dir.rival_vehicle
			assert(r_veh != null, "Il veicolo rivale 3D deve essere istanziato sulla griglia!")
			var r_pos = r_veh.global_position
			
			print("  ✓ Posizionamento Griglia: Giocatore (Lane 1 Left) Z=%.1f, X=%.2f, Y=%.2f | Rivale (Lane 2 Right) Z=%.1f, X=%.2f, Y=%.2f" % [
				p_pos.z, p_pos.x, p_pos.y, r_pos.z, r_pos.x, r_pos.y
			])
			assert(abs(p_pos.z - 40.0) < 3.0, "Il giocatore deve trovarsi sulla linea di partenza (Z ~ 40m)!")
			assert(abs(r_pos.z - 40.0) < 3.0, "Il rivale deve trovarsi sulla linea di partenza (Z ~ 40m)!")
			assert(p_pos.x < r_pos.x, "Lane 1 deve essere a sinistra di Lane 2!")
			assert(p_pos.y > 0.3 and r_pos.y > 0.3, "Nessuna auto deve finire nel vuoto sotto la strada!")
			
			assert(race_dir.start_gantry_node != null, "Il portale 3D di partenza deve essere presente!")
			assert(race_dir.finish_gantry_node != null, "Il portale 3D del traguardo deve essere presente a 400m!")
			
		elif frame_count == 10:
			capture_screenshot("screenshot_standalone_drag_staging_3d.png")
			
			# ------------------------------------------------------------------
			# TEST 4: SVOLGIMENTO DELLA GARA E TAGLIO DEL TRAGUARDO (400M)
			# ------------------------------------------------------------------
			print("\n[TEST 4/5] Esecuzione Gara e Traguardo a 400m...")
			# Avanzamento al verde del semaforo
			race_dir.countdown_timer = 4.2
			race_dir.update_countdown(0.1)
			assert(race_dir.current_state == RaceDirector.RaceState.RACING, "Al termine del countdown lo stato deve essere RACING!")
			assert(vehicle.is_ai_controlled == false, "I comandi devono essere restituiti al giocatore al verde!")
			print("  ✓ Semaforo Verde scattato! Controllo veicolo sbloccato per il giocatore.")
			
			# Simuliamo l'attraversamento del traguardo (+400m -> Z = 445m)
			vehicle.global_position.z = 445.0
			vehicle.current_speed_kmh = 148.0
			race_dir.rival_vehicle.global_position.z = 442.0
			race_dir.rival_vehicle.current_speed_kmh = 142.0
			race_dir.update_race(0.05)
			
			assert(race_dir.current_state == RaceDirector.RaceState.FINISHED, "All'attraversamento del traguardo lo stato deve essere FINISHED!")
			assert(race_dir.hud_result_card.visible == true, "La scheda risultati vittoria/sconfitta deve essere visibile!")
			print("  ✓ Traguardo 400m tagliato! Scheda esito visualizzata a schermo con pulsante 'Torna al Menu'")
			
		elif frame_count == 14:
			capture_screenshot("screenshot_drag_finish_result_card.png")
			
			# ------------------------------------------------------------------
			# TEST 5: RITORNO AL MENU DELLE GARE E RIPRISTINO ESPLORAZIONE
			# ------------------------------------------------------------------
			print("\n[TEST 5/5] Ritorno al Menu Gare ('Finita la gara si torna al menu delle gare')...")
			# Il giocatore preme il pulsante / SPAZIO per tornare al menu gare
			race_dir.return_to_race_menu()
			
			assert(race_dir.current_state == RaceDirector.RaceState.IDLE, "Lo stato di gara deve essere ritornato a IDLE!")
			assert(race_dir.start_gantry_node == null, "I portali di gara devono essere stati rimossi!")
			assert(race_dir.rival_vehicle.visible == false, "L'auto rivale deve essere nascosta / dismessa!")
			
			# Verifica ripristino posizione giocatore nell'open world
			var restored_pos = vehicle.global_position
			print("  ✓ Posizione Giocatore Ripristinata: (%.1f, %.1f, %.1f) - Target pre-gara: (%.1f, %.1f, %.1f)" % [
				restored_pos.x, restored_pos.y, restored_pos.z,
				saved_exploration_pos.x, saved_exploration_pos.y, saved_exploration_pos.z
			])
			assert(abs(restored_pos.z - saved_exploration_pos.z) < 1.0, "L'auto del giocatore DEVE essere tornata alle coordinate pre-gara!")
			
			# Verifica riapertura menu gare / StreetRodUI
			assert(sr_ui != null and sr_ui.is_open == true, "StreetRodUI DEVE essere riaperto automaticamente!")
			assert(sr_ui.current_tab == 2, "StreetRodUI deve tornare esattamente al tab di origine della gara (Tab 2 Diner / 3 Drag)!")
			print("  ✓ StreetRodUI riaperto con successo al Tab %d (Menu Gare / Diner Da Bepi)!" % sr_ui.current_tab)
			
		elif frame_count == 18:
			capture_screenshot("screenshot_return_to_race_menu.png")
			
			print("\n=======================================================")
			print(">>> ESITO COLLAUDO: TUTTI I TEST SUPERATI CON SUCCESSO!")
			print("  1. Telecamera GTA Chase dinamica sempre dietro all'auto: OK")
			print("  2. Inversione a U (180°) e marcia a ritroso: Camera resta DIETRO: OK")
			print("  3. Tasto C Look-Back istantaneo: OK")
			print("  4. Gara 3D standalone a parte (Z=40-440m, corsie dedicate, no cadute): OK")
			print("  5. Traguardo e Ritorno automatico al Menu Gare con ripristino open world: OK")
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
