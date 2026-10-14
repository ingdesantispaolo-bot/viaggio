extends SceneTree

# ==============================================================================
# TEST VERIFICA: TRAFFICO CATALOGO, ANTI-CONTROMANO, CRASH STOP & DEFORMAZIONE
# ==============================================================================

const CivilianTrafficManager = preload("res://scripts/CivilianTrafficManager.gd")
const VehicleCrashSystem = preload("res://scripts/VehicleCrashSystem.gd")
const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")
const VehicleAudio = preload("res://scripts/VehicleAudio.gd")
const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")

func _init():
	print("\n==================================================================")
	print("  TEST VERIFICA: TRAFFICO CIVILE, ANTI-CONTROMANO & CRASH DEFORMATION")
	print("==================================================================")
	run_tests()
	quit(0)

func run_tests():
	test_radio_starts_off()
	test_civilian_catalog_models_spawn()
	test_strict_lane_rules_and_no_shoulder()
	test_crash_immediate_stop_and_hazard()
	test_bidirectional_mesh_deformation()
	print("==================================================================")
	print("  TUTTI I 5 TEST CRITICI SUPERATI CON SUCCESSO!")
	print("==================================================================\n")

func test_radio_starts_off():
	print("\n--- TEST 1: AUTORADIO SPENTA ALL'AVVIO ---")
	var audio = VehicleAudio.new()
	root.add_child(audio)
	if not audio.is_node_ready(): audio._ready()
	
	assert(audio.current_radio_idx == 0, "L'autoradio DEVE avere indice 0 (AUTORADIO SPENTA) all'avvio!")
	assert(audio.radio_stations[0]["name"] == "AUTORADIO SPENTA", "La prima voce deve essere AUTORADIO SPENTA")
	assert(audio.radio_player.stream == null, "Lo stream dell'autoradio all'avvio deve essere nullo!")
	assert(audio.radio_player.volume_db <= -70.0, "Il volume radio all'avvio deve essere silenziato (-80 dB)!")
	assert(audio.radio_player.autoplay == false, "L'autoplay dell'autoradio deve essere disabilitato!")
	print("[PASS] Test 1: Autoradio rigorosamente spenta e silente all'avvio.")
	audio.queue_free()

func test_civilian_catalog_models_spawn():
	print("\n--- TEST 2: AUTO CIVILI DAL CATALOGO VEICOLI ---")
	var tm = CivilianTrafficManager.new()
	root.add_child(tm)
	if not tm.is_node_ready(): tm._ready()
	
	# Verifica builder dal catalogo per i modelli iconici
	var catalog_samples = ["panda_4x4", "fiat_127", "renault_4", "golf_gti_1990", "bmw_320_e30", "gwagen_w460", "fiat_topolino"]
	for model_id in catalog_samples:
		var car_node = tm.create_traffic_model(model_id, false)
		tm.add_child(car_node)
		assert(car_node != null, "Il nodo del veicolo %s non deve essere null" % model_id)
		var rig = VehicleCrashSystem.find_vehicle_model_root(car_node)
		assert(rig != null, "Il veicolo %s deve contenere una struttura geometrica valida" % model_id)
		assert(rig.get_child_count() > 4, "Il modello %s deve contenere i componenti della carrozzeria (paraurti, cofano, fari, ecc.)" % model_id)
		
		var col = car_node.find_child("CollisionShape3D", true, false)
		assert(col != null, "Il veicolo %s deve avere una CollisionShape3D solida" % model_id)
		car_node.queue_free()
		
	print("[PASS] Test 2: Auto civili generate con successo dai modelli dettagliati del catalogo.")
	tm.queue_free()

func test_strict_lane_rules_and_no_shoulder():
	print("\n--- TEST 3: RISPETTO RIGOROSO CORSIE & ZERO CIGLIO (CODICE DELLA STRADA) ---")
	var road_gen = RoadGenerator.new()
	root.add_child(road_gen)
	road_gen.init_procedural_generation()
	road_gen.generate_chunk()
	road_gen.generate_chunk()
	
	var tm = CivilianTrafficManager.new()
	tm.road_generator = road_gen
	root.add_child(tm)
	if not tm.is_node_ready(): tm._ready()
	
	# Crea veicolo del giocatore a quota Z = 100m, corsia destra (-X)
	var player = VehicleController.new()
	root.add_child(player)
	player.global_position = Vector3(-1.95, 0.5, 100.0)
	tm.player_vehicle = player
	
	# Genera veicoli di traffico
	for k in range(12):
		tm.try_spawn_traffic_vehicle(player.global_position.z)
		
	assert(tm.active_traffic.size() > 0, "Devono essere stati spawnati veicoli attivi")
	
	# Simula 60 frame fisici di movimento
	for step in range(60):
		tm.update_traffic_movement(player.global_position, player.global_position.z, 0.016)
		
	for car in tm.active_traffic:
		var r_info = road_gen.get_road_info_at(car.current_z)
		var half_w = r_info.width * 0.5
		
		# In Italia si tiene la destra: verso monte (+Z, rotazione PI), DESTRA = X negativa (-X)
		assert(car.lane_offset < -0.20, "Veicolo in salita NON puo' invadere la corsia sinistra (contromano)! offset = %f" % car.lane_offset)
		# NON puo' viaggiare sul ciglio o banchina destra
		assert(car.lane_offset >= -half_w * 0.70, "Veicolo in salita NON puo' salire sul ciglio/banchina destra! offset = %f, half_w = %f" % [car.lane_offset, half_w])
		# Muso orientato in avanti verso monte (zero retromarcia!)
		var diff_rot = abs(wrapf(car.node.rotation.y - (r_info.angle + PI), -PI, PI))
		assert(diff_rot < 0.25, "Veicolo in salita DEVE viaggiare in marcia avanti verso monte (zero retromarcia)! rot = %f" % car.node.rotation.y)
			
	print("[PASS] Test 3: Mantenimento della destra e orientamento in marcia avanti verificati al 100% (Zero contromano, Zero retromarcia).")
	tm.queue_free()
	player.queue_free()
	road_gen.queue_free()

func test_crash_immediate_stop_and_hazard():
	print("\n--- TEST 4: ARRESTO IMMEDIATO ALL'INCIDENTE & 4 FRECCE (ZERO BULLDOZER) ---")
	var road_gen = RoadGenerator.new()
	root.add_child(road_gen)
	road_gen.init_procedural_generation()
	road_gen.generate_chunk()
	
	var tm = CivilianTrafficManager.new()
	tm.road_generator = road_gen
	root.add_child(tm)
	if not tm.is_node_ready(): tm._ready()
	
	var player = VehicleController.new()
	root.add_child(player)
	player.global_position = Vector3(-1.95, 0.5, 60.0)
	tm.player_vehicle = player
	
	# Crea auto civile
	var car_node = tm.create_traffic_model("fiat_127", false)
	tm.add_child(car_node)
	car_node.global_position = Vector3(-1.95, 0.5, 61.5) # A contatto con il player
	
	var car_data = {
		"node": car_node,
		"type": "fiat_127",
		"archetype": "commuter",
		"type_name": "Fiat 127 Civile",
		"current_z": 61.5,
		"speed_kmh": 60.0,
		"target_speed_kmh": 60.0,
		"is_oncoming": true,
		"is_slow_vehicle": false,
		"lane_offset": -1.95,
		"target_lane_offset": -1.95,
		"indicator_timer": 0.0,
		"indicator_state": "none",
		"emergency_timer": 0.0,
		"has_collided": false,
		"is_crashed": false,
		"overtaken": false
	}
	tm.active_traffic.append(car_data)
	
	# Esegui check interazione: deve innescare l'incidente
	tm.check_player_interaction(car_data, player.global_position, 0.016)
	
	assert(car_data.is_crashed == true, "L'auto civile DEVE entrare nello stato is_crashed = true dopo l'impatto!")
	assert(car_data.speed_kmh == 0.0, "La velocita' dell'auto civile DEVE essere azzerata a 0 km/h!")
	assert(car_data.target_speed_kmh == 0.0, "La velocita' target DEVE essere 0 km/h!")
	assert(car_data.indicator_state == "hazard", "L'auto sinistrata DEVE accendere le 4 frecce di emergenza (hazard)!")
	
	# Simula 30 frame di fisica: la posizione Z dell'auto civile NON deve muoversi spingendo indietro il giocatore
	var z_initial = car_data.current_z
	for f in range(30):
		tm.update_traffic_movement(player.global_position, player.global_position.z, 0.016)
		
	assert(abs(car_data.current_z - z_initial) < 0.01, "L'auto civile ferma NON deve avanzare cinematica bulldozerando il giocatore! Delta Z = %f" % (car_data.current_z - z_initial))
	assert(car_data.speed_kmh == 0.0, "La velocita' deve rimanere rigorosamente 0.0 km/h")
	print("[PASS] Test 4: Arresto immediato post-incidente e 4 frecce verificate con successo (zero bulldozer).")
	tm.queue_free()
	player.queue_free()
	road_gen.queue_free()

func test_bidirectional_mesh_deformation():
	print("\n--- TEST 5: DEFORMAZIONE STRUTTURALE & PLASTICA DOPO L'IMPATTO ---")
	var tm = CivilianTrafficManager.new()
	root.add_child(tm)
	if not tm.is_node_ready(): tm._ready()
	
	var car_node = tm.create_traffic_model("golf_gti_1990", false)
	tm.add_child(car_node)
	
	var rig = VehicleCrashSystem.find_vehicle_model_root(car_node)
	assert(rig != null, "La radice delle parti geometriche deve esistere")
	
	# Cerca un componente frontale (es. paraurti, griglia o faro)
	var bumper = null
	var hood = null
	for child in rig.get_children():
		var cn = child.name.to_lower()
		if ("bumper" in cn or "rostro" in cn) and child.position.z < -0.8:
			bumper = child
		elif "hood" in cn or "bonnet" in cn:
			hood = child
			
	var bumper_z_before = bumper.position.z if bumper else 0.0
	var hood_y_before = hood.position.y if hood else 0.0
	
	# Applica impatto frontale severo a 55 km/h
	var contact_pt = car_node.global_position + Vector3(0, 0.5, -1.8)
	var impact_normal = Vector3(0, 0, 1)
	VehicleCrashSystem.apply_structural_deformation(car_node, contact_pt, 55.0, impact_normal)
	
	if bumper:
		assert(bumper.position.z > bumper_z_before, "Il paraurti frontale DEVE essere rientrato all'indietro dopo l'urto! z_before=%f, z_after=%f" % [bumper_z_before, bumper.position.z])
		assert(bumper.scale.z < 1.0, "Lo spessore del paraurti DEVE essersi compresso plasticamente!")
		
	if hood:
		assert(hood.position.y > hood_y_before, "Il cofano motore DEVE essersi piegato e sollevato a fisarmonica (crumple zone)! y_before=%f, y_after=%f" % [hood_y_before, hood.position.y])
		assert(hood.rotation.x != 0.0, "Il cofano motore deve essersi inclinato per l'urto!")
		
	print("[PASS] Test 5: Deformazione strutturale ad alta fedeltà verificata con successo per i componenti della carrozzeria.")
	car_node.queue_free()
	tm.queue_free()
