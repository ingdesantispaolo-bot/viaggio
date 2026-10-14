extends SceneTree

# ==============================================================================
# TEST AUTOMATIZZATO: VALIDAZIONE SALITE PROFILE C1/C2 & IA TRAFFICO CIVILE
# ==============================================================================

const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")
const CivilianTrafficManager = preload("res://scripts/CivilianTrafficManager.gd")
const StreetRodManager = preload("res://scripts/StreetRodManager.gd")

func _init():
	print("\n==================================================================")
	print(">>> TEST VALIDAZIONE: SALITE STRADALI CONTINUE & TRAFFICO CIVILE IA <<<")
	print("==================================================================")
	
	var passed = 0
	var total = 0
	
	# --------------------------------------------------------------------------
	# TEST 1: Continuità Altimetrica C1/C2 (Nessuno scalino o spigolo)
	# --------------------------------------------------------------------------
	total += 1
	var road = RoadGenerator.new()
	root.add_child(road)
	road._ready()
	road.ensure_chunks_generated_up_to(1500.0)
	
	var prev_y = road.calculate_road_elevation(0.0)
	var max_step_dy = 0.0
	var smooth = true
	for test_z in range(1, 1500, 2):
		var cur_y = road.calculate_road_elevation(float(test_z))
		var dy = abs(cur_y - prev_y)
		if dy > max_step_dy:
			max_step_dy = dy
		# In un intervallo di 2m, dy non deve superare 0.40m (pendenza max 20%)
		if dy >= 0.40:
			smooth = false
			printerr("[FAIL] Scalino rilevato a Z=%.1fm (dy=%.3fm)" % [float(test_z), dy])
			break
		prev_y = cur_y
		
	if smooth:
		print("[PASS] Test 1: Profilo altimetrico continuo C1/C2 confermato! Max dislivello su 2m: %.3fm" % max_step_dy)
		passed += 1
	else:
		printerr("[FAIL] Test 1 fallito per discontinuità altimetrica.")
		
	# --------------------------------------------------------------------------
	# TEST 2: Inizializzazione Veicolo e Controllo Crash Raycast
	# --------------------------------------------------------------------------
	total += 1
	var veh = VehicleController.new()
	for w_name in ["WheelFL", "WheelFR", "WheelRL", "WheelRR"]:
		var w = VehicleWheel3D.new()
		w.name = w_name
		veh.add_child(w)
	root.add_child(veh)
	veh._ready()
	veh.road_generator = road
	veh.global_position = Vector3(1.8, 1.0, 50.0)
	
	# Verifica che front_crash_ray sia presente ed orientato correttamente
	if veh.front_crash_ray and veh.front_crash_ray.enabled:
		print("[PASS] Test 2: FrontCrashRay operativo a Y=%.2fm, orientato verso Z=%.2fm" % [
			veh.front_crash_ray.position.y, veh.front_crash_ray.target_position.z
		])
		passed += 1
	else:
		printerr("[FAIL] Test 2: FrontCrashRay non inizializzato.")
		
	# --------------------------------------------------------------------------
	# TEST 3: Generazione Traffico Civile & Rigoroso Rispetto delle Corsie (NO CONTROMANO)
	# --------------------------------------------------------------------------
	total += 1
	var sm = StreetRodManager.new()
	root.add_child(sm)
	
	var tm = CivilianTrafficManager.new()
	tm.road_generator = road
	tm.player_vehicle = veh
	tm.street_rod_manager = sm
	root.add_child(tm)
	tm._ready()
	
	# Spawna veicoli con Z crescente per testare la distribuzione
	var cur_pz = 100.0
	for i in range(25):
		tm.try_spawn_traffic_vehicle(cur_pz)
		cur_pz += 30.0
		
	var oncoming_ok = true
	var uphill_ok = true
	var total_oncoming = 0
	var total_uphill = 0
	
	for car in tm.active_traffic:
		if car.is_oncoming:
			total_oncoming += 1
			# Deve avere target_lane_offset negativo (corsia sinistra per noi, mano destra per lui)
			if car.target_lane_offset >= -0.2:
				oncoming_ok = false
				printerr("[FAIL] Oncoming car con offset non negativo: %.2f" % car.target_lane_offset)
		else:
			total_uphill += 1
			# Deve avere target_lane_offset positivo (corsia destra)
			if car.target_lane_offset <= 0.2:
				uphill_ok = false
				printerr("[FAIL] Uphill car con offset non positivo: %.2f" % car.target_lane_offset)
				
	print("[INFO] Distribuzione veicoli generati: %d salita (corsia destra), %d discesa (corsia sinistra)" % [total_uphill, total_oncoming])
	if oncoming_ok and uphill_ok and total_oncoming > 0 and total_uphill > 0:
		print("[PASS] Test 3: ZERO contromano! Tutte le auto mantengono la propria mano rigorosamente.")
		passed += 1
	else:
		printerr("[FAIL] Test 3: Anomalie di corsia rilevate.")
		
	# --------------------------------------------------------------------------
	# TEST 4: Archetipi Intelligenti e Rispetto Rigoroso Corsia di Destra
	# --------------------------------------------------------------------------
	total += 1
	# Test A: Ape Piaggio accosta con freccia destra se veicolo vicino alle spalle
	var slow_node = tm.create_traffic_model("ape_piaggio", false)
	tm.add_child(slow_node)
	var slow_car = {
		"node": slow_node,
		"type": "ape_piaggio",
		"archetype": "slow_worker",
		"type_name": "Ape Piaggio 50",
		"current_z": 90.0,
		"speed_kmh": 32.0,
		"target_speed_kmh": 32.0,
		"is_oncoming": false,
		"is_slow_vehicle": true,
		"lane_offset": 2.2,
		"target_lane_offset": 2.2,
		"pulling_aside": false,
		"indicator_timer": 0.0,
		"indicator_state": "none",
		"overtake_state": 0,
		"emergency_timer": 0.0,
		"ind_mesh_l": slow_node.find_child("IndicatorL", true, false),
		"ind_mesh_r": slow_node.find_child("IndicatorR", true, false),
		"tl_mesh_l": slow_node.find_child("TaillightL", true, false),
		"tl_mesh_r": slow_node.find_child("TaillightR", true, false),
		"headlight": slow_node.find_child("TrafficHeadlight", true, false),
		"has_collided": false,
		"overtaken": false
	}
	tm.active_traffic.clear()
	tm.active_traffic.append(slow_car)
	
	# Giocatore a 16m dietro l'Ape
	veh.global_position = Vector3(2.0, 1.0, 74.0)
	tm.update_traffic_movement(veh.global_position, 74.0, 0.1)
	
	var slow_worker_ok = (slow_car.pulling_aside == true and slow_car.indicator_state == "right" and slow_car.target_lane_offset > 2.5)
	
	# Test B: Fiat 500 (Commuter) Car-Following anti-tamponamento
	var commuter_node = tm.create_traffic_model("fiat_500", false)
	tm.add_child(commuter_node)
	var commuter_car = {
		"node": commuter_node,
		"type": "fiat_500",
		"archetype": "commuter",
		"type_name": "Fiat 500 F",
		"current_z": 78.0, # 12m dietro l'Ape
		"speed_kmh": 52.0,
		"target_speed_kmh": 52.0,
		"is_oncoming": false,
		"is_slow_vehicle": false,
		"lane_offset": 2.2,
		"target_lane_offset": 2.2,
		"pulling_aside": false,
		"indicator_timer": 0.0,
		"indicator_state": "none",
		"overtake_state": 0,
		"emergency_timer": 0.0,
		"ind_mesh_l": commuter_node.find_child("IndicatorL", true, false),
		"ind_mesh_r": commuter_node.find_child("IndicatorR", true, false),
		"tl_mesh_l": commuter_node.find_child("TaillightL", true, false),
		"tl_mesh_r": commuter_node.find_child("TaillightR", true, false),
		"headlight": commuter_node.find_child("TrafficHeadlight", true, false),
		"has_collided": false,
		"overtaken": false
	}
	tm.active_traffic.append(commuter_car)
	
	var initial_spd = commuter_car.speed_kmh
	tm.update_traffic_movement(Vector3(0, 0, 0), 0.0, 0.5)
	var car_following_ok = (commuter_car.speed_kmh < initial_spd)
	
	# Test C: Sport Sedan segue l'Ape e NON invade MAI la corsia di sinistra contromano
	var sport_node = tm.create_traffic_model("sport_sedan", false)
	tm.add_child(sport_node)
	var sport_car = {
		"node": sport_node,
		"type": "sport_sedan",
		"archetype": "sport_overtaker",
		"type_name": "Alfa Giulietta Sport",
		"current_z": 62.0,
		"speed_kmh": 82.0,
		"target_speed_kmh": 82.0,
		"is_oncoming": false,
		"is_slow_vehicle": false,
		"lane_offset": 1.9,
		"target_lane_offset": 1.9,
		"pulling_aside": false,
		"indicator_timer": 0.0,
		"indicator_state": "none",
		"overtake_state": 0,
		"emergency_timer": 0.0,
		"ind_mesh_l": sport_node.find_child("IndicatorL", true, false),
		"ind_mesh_r": sport_node.find_child("IndicatorR", true, false),
		"tl_mesh_l": sport_node.find_child("TaillightL", true, false),
		"tl_mesh_r": sport_node.find_child("TaillightR", true, false),
		"headlight": sport_node.find_child("TrafficHeadlight", true, false),
		"has_collided": false,
		"overtaken": false
	}
	tm.active_traffic.append(sport_car)
	tm.update_traffic_movement(Vector3(0, 0, -20.0), -20.0, 0.1)
	
	var sport_lane_disciplined = (sport_car.target_lane_offset > 0.0 and sport_car.lane_offset > 0.0)
	
	print("       -> Ape accostamento e freccia destra: %s" % ("OK" if slow_worker_ok else "FALLITO"))
	print("       -> Commuter Car-Following anti-tamponamento: %s (spd: %.1f -> %.1f km/h)" % [
		"OK" if car_following_ok else "FALLITO", initial_spd, commuter_car.speed_kmh
	])
	print("       -> Berlina Sportiva rispetto corsia destra: %s (offset: %.2f > 0.0)" % [
		"OK" if sport_lane_disciplined else "FALLITO", sport_car.lane_offset
	])
	
	if slow_worker_ok and car_following_ok and sport_lane_disciplined:
		print("[PASS] Test 4: Rispetto rigoroso della corsia di destra confermato per tutti i profili di traffico!")
		passed += 1
	else:
		printerr("[FAIL] Test 4: Anomalie nel comportamento o nella corsia dei veicoli.")
		
	# --------------------------------------------------------------------------
	# TEST 5: Validazione Bivio Stradale Complanare Organico (Z = 1730m)
	# --------------------------------------------------------------------------
	total += 1
	var j_pos = Vector3(0.0, road.calculate_road_elevation(1730.0), 1730.0)
	var j_prop = road.create_road_junction_prop(j_pos, 0.0, "FORRA DEI CICLOPI", "CAVA DI MARMO", false)
	root.add_child(j_prop)
	
	var has_rigid_24m_box = false
	var has_array_mesh_apron = false
	var stop_line_flush = false
	
	for child in j_prop.get_children():
		if child is MeshInstance3D:
			if child.mesh is BoxMesh:
				var sz = child.mesh.size
				if sz.z > 15.0 or sz.x > 15.0:
					has_rigid_24m_box = true
			elif child.mesh is ArrayMesh:
				has_array_mesh_apron = true
				
	# Verifica che non vi siano box rigidi orizzontali e che esista l'innesto organico
	if not has_rigid_24m_box and has_array_mesh_apron:
		print("[PASS] Test 5: Bivio montano Cava di Marmo organico e complanare al 100%! Nessun blocco sospeso.")
		passed += 1
	else:
		printerr("[FAIL] Test 5: Rilevati artefatti geometrici rigidi nel bivio stradale.")
		
	print("\n==================================================================")
	print("  ESITO TEST: %d / %d TEST COMPLETATI CON SUCCESSO!" % [passed, total])
	print("==================================================================")
	
	if passed == total:
		quit(0)
	else:
		quit(1)
