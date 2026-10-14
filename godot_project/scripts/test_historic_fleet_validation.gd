extends SceneTree

# ==============================================================================
# TEST AUTOMATIZZATO: VALIDAZIONE FLOTTA STORICA ICONICA (1930s -> 1990s)
# ==============================================================================

const VehicleController = preload("res://scripts/VehicleController.gd")
const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")
const StreetRodManager = preload("res://scripts/StreetRodManager.gd")

func _init():
	print("\n==================================================================")
	print(">>> TEST VALIDAZIONE: ESPANSIONE PARCO MACCHINE ICONICHE ANNI '30+ <<<")
	print("==================================================================")
	
	var passed = 0
	var total = 0
	
	# --------------------------------------------------------------------------
	# TEST 1: Verifica Catalogo Completo & Dimensioni (14 vetture)
	# --------------------------------------------------------------------------
	total += 1
	var veh = VehicleController.new()
	for w_name in ["WheelFL", "WheelFR", "WheelRL", "WheelRR"]:
		var w = VehicleWheel3D.new()
		w.name = w_name
		veh.add_child(w)
	root.add_child(veh)
	veh._ready()
	
	var historic_target_ids = [
		"alfa_8c",
		"fiat_topolino",
		"lancia_aurelia",
		"alfa_gta",
		"lancia_stratos",
		"fiat_131_abarth"
	]
	
	if veh.model_keys.size() >= 14:
		print("[PASS] Test 1: Catalogo vetture ampliato con successo a %d modelli!" % veh.model_keys.size())
		passed += 1
	else:
		printerr("[FAIL] Test 1: Catalogo contiene solo %d modelli (attesi >= 14)" % veh.model_keys.size())
		
	# --------------------------------------------------------------------------
	# TEST 2: Validazione 3D e Parametri Meccanici per ciascuna icona storica
	# --------------------------------------------------------------------------
	var all_cars_ok = true
	for c_id in historic_target_ids:
		total += 1
		if not veh.VEHICLE_CATALOG.has(c_id):
			printerr("[FAIL] %s non trovato in VEHICLE_CATALOG!" % c_id)
			all_cars_ok = false
			continue
			
		var cfg = veh.VEHICLE_CATALOG[c_id]
		veh.apply_vehicle_model(c_id)
		
		# Verifica nodo 3D e gerarchia mesh
		var node_name = ""
		match c_id:
			"alfa_8c": node_name = "ModelAlfa8C"
			"fiat_topolino": node_name = "ModelTopolino"
			"lancia_aurelia": node_name = "ModelLanciaAurelia"
			"alfa_gta": node_name = "ModelAlfaGTA"
			"lancia_stratos": node_name = "ModelLanciaStratos"
			"fiat_131_abarth": node_name = "ModelFiat131"
			
		var m_node = veh.get_node_or_null(node_name)
		if not m_node or not m_node.visible or m_node.get_child_count() == 0:
			printerr("[FAIL] Nodo 3D %s non valido o non visibile!" % node_name)
			all_cars_ok = false
			continue
			
		# Verifica trazione e fisica
		assert(veh.mass == cfg.mass, "Massa configurata correttamente")
		assert(cfg.drivetrain_2wd == "TRAZIONE POSTERIORE [RWD]", "Le icone storiche devono essere RWD")
		
		print("[PASS] %s (%d): %s | %s | Massa: %.0fkg | %d parti 3D procedurali" % [
			cfg.short_name, cfg.year, cfg.name, cfg.engine, cfg.mass, m_node.get_child_count()
		])
		passed += 1
		
	# --------------------------------------------------------------------------
	# TEST 3: Verifica StreetRodManager (Mercatino d'epoca & Garage ampliato)
	# --------------------------------------------------------------------------
	total += 1
	var sm = StreetRodManager.new()
	root.add_child(sm)
	sm._ready()
	
	if sm.max_garage_slots >= 14 and sm.classified_ads.size() >= 5:
		print("[PASS] Test 3: StreetRodManager pronto! Slot garage: %d | Annunci mercatino attivi: %d" % [
			sm.max_garage_slots, sm.classified_ads.size()
		])
		passed += 1
	else:
		printerr("[FAIL] Test 3: StreetRodManager slot o annunci non conformi")
		
	# --------------------------------------------------------------------------
	# RESOCONTO FINALE
	# --------------------------------------------------------------------------
	print("\n==================================================================")
	print("ESITO TEST FLOTTA STORICA: %d / %d TEST SUPERATI CON SUCCESSO!" % [passed, total])
	print("==================================================================\n")
	
	if passed == total:
		quit(0)
	else:
		quit(1)
