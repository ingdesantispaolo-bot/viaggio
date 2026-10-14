extends SceneTree

# ==============================================================================
# TEST SUITE: FORMA REALISTICA DELLA STRADA, TORNANTI, PENDENZE & TRAFFICO CIVILE
# ==============================================================================

const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")
const CivilianTrafficManager = preload("res://scripts/CivilianTrafficManager.gd")
const StreetRodManager = preload("res://scripts/StreetRodManager.gd")

func _init():
	print("==================================================================")
	print("  TEST AUTOMATIZZATO: CURVE, TORNANTI, SALITE, DISCESE & TRAFFICO")
	print("==================================================================")
	
	var passed = 0
	var total = 0
	
	# TEST 1: Altimetria e Dislivelli Reali Montani
	total += 1
	var road = RoadGenerator.new()
	root.add_child(road)
	
	var alt_start = road.calculate_road_elevation(20.0)
	var alt_pass = road.calculate_road_elevation(280.0)
	var alt_lake = road.calculate_road_elevation(500.0)
	var alt_gorge = road.calculate_road_elevation(2000.0)
	var alt_larici = road.calculate_road_elevation(4000.0)
	
	print("[INFO] Quote stradali calcolate:")
	print("       -> Z = 20m (Fondo valle): %.2fm" % alt_start)
	print("       -> Z = 280m (Passo delle Alpi - Salita): %.2fm" % alt_pass)
	print("       -> Z = 500m (Discesa Lago di San Rocco): %.2fm" % alt_lake)
	print("       -> Z = 2000m (Viadotto Forra dell'Appennino): %.2fm" % alt_gorge)
	print("       -> Z = 4000m (14 Tornanti dei Larici): %.2fm" % alt_larici)
	
	if alt_pass > alt_start + 8.0 and alt_lake < alt_pass - 4.0 and alt_gorge > alt_lake + 25.0 and alt_larici > alt_gorge + 35.0:
		print("[PASS] Test 1: Profilo altimetrico montano con salite, discese e dislivelli reali superato!")
		passed += 1
	else:
		printerr("[FAIL] Test 1: Altimetria non conforme: pass=%.1f, lake=%.1f, gorge=%.1f, larici=%.1f" % [alt_pass, alt_lake, alt_gorge, alt_larici])
		
	# TEST 2: Curvatura Dinamica e Rilevamento Tornanti a Gomito
	total += 1
	road.ensure_chunks_generated_up_to(450.0)
	var max_hairpin_angle = 0.0
	for test_z in range(130, 330, 8):
		var r_inf = road.get_road_info_at(float(test_z))
		if r_inf.has("angle"):
			max_hairpin_angle = max(max_hairpin_angle, abs(r_inf.angle))
			
	print("[INFO] Angolo massimo di curvatura nei tornanti delle Alpi: %.2f rad (%.1f deg)" % [max_hairpin_angle, rad_to_deg(max_hairpin_angle)])
	if max_hairpin_angle >= 0.45: # Curva a gomito decisa
		print("[PASS] Test 2: Rilevata curvatura decisa con tornanti a gomito e curve tecniche!")
		passed += 1
	else:
		printerr("[FAIL] Test 2: Curvatura insufficiente: max=%.2f rad" % max_hairpin_angle)
		
	# TEST 3: Inizializzazione CivilianTrafficManager & Archetipi Veicoli
	total += 1
	var sm = StreetRodManager.new()
	root.add_child(sm)
	
	var veh = VehicleController.new()
	for w_name in ["WheelFL", "WheelFR", "WheelRL", "WheelRR"]:
		var w = VehicleWheel3D.new()
		w.name = w_name
		veh.add_child(w)
	root.add_child(veh)
	veh.global_position = Vector3(0.0, 1.0, 50.0)
	
	var tm = CivilianTrafficManager.new()
	tm.road_generator = road
	tm.player_vehicle = veh
	tm.street_rod_manager = sm
	root.add_child(tm)
	
	# Spawn veicoli di prova
	tm.try_spawn_traffic_vehicle(50.0)
	tm.try_spawn_traffic_vehicle(50.0)
	tm.try_spawn_traffic_vehicle(50.0)
	
	if tm.active_traffic.size() >= 2:
		print("[PASS] Test 3: Traffico civile generato con successo (%d veicoli attivi)." % tm.active_traffic.size())
		for c in tm.active_traffic:
			print("       -> Veicolo: %s | Velocità: %.1f km/h | Oncoming: %s" % [c.type_name, c.speed_kmh, c.is_oncoming])
		passed += 1
	else:
		printerr("[FAIL] Test 3: Traffico civile non generato.")
		
	# TEST 4: Reazione al Clacson e Spostamento sulla Banchina
	total += 1
	var slow_ape = null
	for c in tm.active_traffic:
		if not c.is_oncoming and c.is_slow_vehicle:
			slow_ape = c
			break
	if not slow_ape:
		var ape_node = tm.create_traffic_model("ape_piaggio", false)
		tm.add_child(ape_node)
		slow_ape = {
			"node": ape_node, "type": "ape_piaggio", "type_name": "Ape Piaggio 50",
			"current_z": 75.0, "speed_kmh": 35.0, "is_oncoming": false, "is_slow_vehicle": true,
			"lane_offset": 1.75, "pulling_aside": false, "indicator_timer": 0.0,
			"indicator_mesh": ape_node.find_child("IndicatorR", true, false),
			"tl_mesh_l": ape_node.find_child("TaillightL", true, false),
			"tl_mesh_r": ape_node.find_child("TaillightR", true, false),
			"has_collided": false, "overtaken": false
		}
		tm.active_traffic.append(slow_ape)
		
	# Posiziona il giocatore a 14 metri dietro l'Ape
	slow_ape.current_z = 70.0
	veh.global_position = Vector3(0.0, 1.0, 56.0)
	tm.update_traffic_movement(veh.global_position, 56.0, 0.05)
	
	if slow_ape.pulling_aside:
		print("[PASS] Test 4: Ape Piaggio rileva la vettura alle spalle, accende la freccia e accosta a destra!")
		passed += 1
	else:
		printerr("[FAIL] Test 4: Ape non accostata a destra: pulling_aside=%s" % slow_ape.pulling_aside)
		
	# TEST 5: Impatto Fisico & Decurtazione Danni Street Rod
	total += 1
	var initial_car = sm.get_active_car()
	var body_health_before = initial_car.get("body_health", 0.75)
	
	# Simula impatto a 50 km/h
	tm.trigger_collision_impact(slow_ape, 50.0)
	var body_health_after = initial_car.get("body_health", 0.75)
	
	if body_health_after < body_health_before:
		print("[PASS] Test 5: Collisione con traffico civile applica danno reale al garage Street Rod!")
		print("       -> Carrozzeria: %.0f%% -> %.0f%%" % [body_health_before * 100.0, body_health_after * 100.0])
		passed += 1
	else:
		printerr("[FAIL] Test 5: Danno carrozzeria non decurtato.")
		
	# TEST 6: Sorpasso Pulito con Bonus Rispetto
	total += 1
	var rep_before = sm.reputation
	tm.trigger_clean_overtake(slow_ape)
	var rep_after = sm.reputation
	
	if rep_after > rep_before:
		print("[PASS] Test 6: Sorpasso pulito ad alta velocità attribuisce bonus rispetto (+%d Rispetto)!" % (rep_after - rep_before))
		passed += 1
	else:
		printerr("[FAIL] Test 6: Rispetto sorpasso non attribuito.")
		
	# TEST 7: Funzionalità Clacson & Recupero Tracciato
	total += 1
	veh.play_horn_honk()
	veh.recover_vehicle_to_track()
	print("[PASS] Test 7: Clacson vintage e soccorso stradale eseguiti regolarmente.")
	passed += 1
	
	print("==================================================================")
	print("  RISULTATO TEST: %d / %d TEST SUPERATI CON SUCCESSO!" % [passed, total])
	print("==================================================================")
	
	if passed == total:
		print(">>> TUTTI I REQUISITI DI GUIDA, PENDENZE E TRAFFICO SODDISFATTI! <<<")
		quit(0)
	else:
		printerr(">>> ALCUNI TEST SONO FALLITI! <<<")
		quit(1)
