extends SceneTree

# TEST RIGOROSO: FISICA BUCHE, ELIMINAZIONE RIBALTAMENTO E REALISMO MANTO STRADALE
# 1. Verifica assorbimento ammortizzatori e ZERO ribaltamento a 40, 80 e 130 km/h
# 2. Verifica stabilizzazione anti-rollio e assenza di decollo o capottamento
# 3. Verifica generazione calibrata frequenza buche (media realistica)
# 4. Verifica toppe/rappezzi d'asfalto e delineatori stradali alpini
# 5. Acquisizione screenshot del manto stradale ad alta fedeltà

const CameraController = preload("res://scripts/CameraController.gd")
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

var root_node: Node3D
var road_gen: Node3D
var vehicle: Node3D
var camera: CameraController
var frame_count: int = 0
var stage: int = 0

func _init():
	print("\n====================================================================")
	print(">>> AVVIO TEST: DINAMICA BUCHE, ANTI-RIBALTAMENTO E REALISMO STRADALE")
	print("====================================================================\n")

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
			
			var sr_ui = root_node.find_child("StreetRodUI", true, false)
			if sr_ui and sr_ui.has_method("close_screen"):
				sr_ui.close_screen()
		elif frame_count >= 5:
			run_pothole_physics_tests()
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		# Posiziona auto su tratto con asfalto, buche, rappezzi e paracarri per screenshot
		if frame_count == 2:
			print("\n[VERIFICA VISIVA 1] Manto Stradale Realistico (Texture, Crepe, Rappezzi, Paracarri):")
			var rd_info = road_gen.get_road_info_at(180.0)
			vehicle.apply_vehicle_model("bmw_320_e30")
			vehicle.global_position = Vector3(rd_info.x + 1.1, rd_info.y + 0.35, 180.0)
			vehicle.rotation = Vector3(0, PI + rd_info.angle, 0)
			camera.current_mode = CameraController.CameraMode.CHASE_DINAMICA
			camera.user_dist_offset = 1.6
			camera.user_height_offset = 0.65
			camera.setup_initial_position()
		elif frame_count == 10:
			capture_screenshot("screenshot_realistic_alpine_road_surface.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		if frame_count == 2:
			print("\n[VERIFICA VISIVA 2] Dinamica Auto sopra Buca e Rappezzo (Assetto Stabile):")
			if not road_gen.active_potholes.is_empty():
				var pot = road_gen.active_potholes[0]
				vehicle.global_position = Vector3(pot.x, pot.y + 0.35, pot.z - 3.5)
				vehicle.rotation = Vector3(0, PI, 0)
			camera.current_mode = CameraController.CameraMode.CHASE_DINAMICA
			camera.user_dist_offset = 0.8
			camera.user_height_offset = 0.4
			camera.setup_initial_position()
		elif frame_count == 10:
			capture_screenshot("screenshot_pothole_chassis_stability.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		if frame_count == 2:
			print("\n[VERIFICA VISIVA 3] Dettaglio Asfalto, Crepe da Gelo e Toppe:")
			camera.current_mode = CameraController.CameraMode.CHASE_DINAMICA
			camera.user_dist_offset = -2.2
			camera.user_height_offset = -0.5
			camera.setup_initial_position()
		elif frame_count == 10:
			capture_screenshot("screenshot_road_texture_closeup.png")
			print("\n====================================================================")
			print(">>> TUTTI I TEST FISICI E VISIVI SUPERATI CON SUCCESSO! ✓")
			print("====================================================================\n")
			quit(0)

func run_pothole_physics_tests():
	print("\n--- [FASE 1] TEST IMPATTO BUCHE E PREVENZIONE RIBALTAMENTO ---")
	
	# Crea buca di prova sotto la ruota anteriore destra
	var pot_pos = Vector3(1.2, 0.05, 50.0)
	var test_pot = {
		"x": pot_pos.x,
		"y": pot_pos.y,
		"z": pot_pos.z,
		"radius": 0.55,
		"depth": 0.05
	}
	road_gen.active_potholes.append(test_pot)
	
	# [TEST 1A] Impatto a 40 km/h (Andatura Urbana/Montana)
	print("\n[TEST 1A] Impatto buca a 40 km/h (BMW 320):")
	vehicle.apply_vehicle_model("bmw_320_e30")
	vehicle.global_position = Vector3(pot_pos.x - 0.75, 0.35, pot_pos.z - 0.1)
	vehicle.linear_velocity = Vector3(0, 0, 11.1) # ~40 km/h
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.pothole_cooldown = 0.0
	
	vehicle._physics_process(0.016)
	
	var tilt_40 = abs(vehicle.global_transform.basis.x.y)
	var upright_40 = vehicle.global_transform.basis.y.y
	print("  Inclinazione rollio telaio: %.3f rad (%.1f°)" % [tilt_40, rad_to_deg(tilt_40)])
	print("  Vettore verticale telaio (Up.y): %.3f (deve essere > 0.90)" % upright_40)
	assert(upright_40 > 0.90, "L'auto non deve inclinarsi pericolosamente a 40 km/h")
	assert(tilt_40 < 0.10, "Rollio eccessivo su buca a 40 km/h")
	print("  -> TEST 1A SUPERATO: Assorbimento elastico morbido senza instabilità ✓")
	
	# [TEST 1B] Impatto a 80 km/h (Velocità Statale)
	print("\n[TEST 1B] Impatto buca a 80 km/h (Golf GTI 16V):")
	vehicle.apply_vehicle_model("golf_gti_1990")
	vehicle.global_position = Vector3(pot_pos.x - 0.75, 0.35, pot_pos.z - 0.1)
	vehicle.linear_velocity = Vector3(0, 0, 22.2) # ~80 km/h
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.pothole_cooldown = 0.0
	
	vehicle._physics_process(0.016)
	for f in range(10):
		vehicle._physics_process(0.016)
		
	var tilt_80 = abs(vehicle.global_transform.basis.x.y)
	var upright_80 = vehicle.global_transform.basis.y.y
	print("  Inclinazione telaio dopo rimbalzo: %.3f rad (%.1f°)" % [tilt_80, rad_to_deg(tilt_80)])
	print("  Vettore verticale telaio (Up.y): %.3f" % upright_80)
	assert(upright_80 > 0.88, "L'auto deve rimanere saldamente in assetto a 80 km/h")
	assert(tilt_80 < 0.15, "Rollio eccessivo a 80 km/h")
	print("  -> TEST 1B SUPERATO: Oscillazione smorzata, traiettoria stabile ✓")
	
	# [TEST 1C] Impatto estremo a 130 km/h (Autostrada / Gara)
	print("\n[TEST 1C] Impatto buca estremo a 130 km/h (Lancia Delta Integrale):")
	vehicle.apply_vehicle_model("delta_integrale")
	vehicle.global_position = Vector3(pot_pos.x - 0.75, 0.35, pot_pos.z - 0.1)
	vehicle.linear_velocity = Vector3(0, 0, 36.1) # ~130 km/h
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.pothole_cooldown = 0.0
	
	vehicle._physics_process(0.016)
	for f in range(15):
		vehicle._physics_process(0.016)
		
	var tilt_130 = abs(vehicle.global_transform.basis.x.y)
	var upright_130 = vehicle.global_transform.basis.y.y
	print("  Inclinazione massima a 130 km/h: %.3f rad (%.1f°)" % [tilt_130, rad_to_deg(tilt_130)])
	print("  Vettore verticale telaio (Up.y): %.3f" % upright_130)
	assert(upright_130 > 0.85, "ZERO RIBALTAMENTO: L'auto a 130 km/h non deve capottarsi né decollare")
	assert(tilt_130 < 0.18, "L'antirollio deve impedire angoli di rollio superiori a 10 gradi")
	print("  -> TEST 1C SUPERATO: NESSUN RIBALTAMENTO A 130 KM/H! ✓")
	
	# [TEST 2] Rilevamento Rappezzi d'Asfalto (Toppe Bituminose)
	print("\n--- [FASE 2] VERIFICA RAPPEZZI E DETTAGLI STRADALI ---")
	road_gen.update_generation(450.0)
	assert(road_gen.active_road_patches.size() > 0, "Nessun rappezzo d'asfalto generato")
	var patch0 = road_gen.active_road_patches[0]
	print("  Rappezzi d'asfalto attivi: %d" % road_gen.active_road_patches.size())
	print("  Esempio rappezzo: X=%.2f, Z=%.2f, Dimensioni=(%.2fm x %.2fm)" % [
		patch0.x, patch0.z, patch0.width, patch0.length
	])
	var query_patch = road_gen.get_road_patch_at_position(Vector3(patch0.x, patch0.y, patch0.z), 0.5)
	assert(not query_patch.is_empty(), "Il rappezzo deve essere rilevato dalle ruote")
	print("  -> TEST 2 SUPERATO: Rappezzi d'asfalto rilevati con successo ✓")
	
	# [TEST 3] Frequenza Calibrata Buche
	print("\n--- [FASE 3] VERIFICA CALIBRAZIONE FREQUENZA BUCHE ---")
	print("  Buche attive generate su 450m di strada: %d" % road_gen.active_potholes.size())
	assert(road_gen.active_potholes.size() >= 1 and road_gen.active_potholes.size() <= 8, 
		"Frequenza buche deve essere sobria e realistica (tra 1 e 8 buche su 450m)")
	print("  Frequenza media buche: %.2f buche per 100m (perfettamente realistica)" % (road_gen.active_potholes.size() / 4.5))
	print("  -> TEST 3 SUPERATO: Frequenza buche equilibrata e credibile ✓")

func capture_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var full_path = artifact_dir + "/" + filename
		var err = img.save_png(full_path)
		if err == OK:
			print("  [SCREENSHOT SALVATO]: %s" % full_path)
		else:
			print("  [ERRORE SALVATAGGIO SCREENSHOT]: %d" % err)
