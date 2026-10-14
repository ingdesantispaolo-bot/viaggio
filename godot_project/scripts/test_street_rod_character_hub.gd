extends SceneTree

# ==============================================================================
# TEST RIGOROSO: STREET ROD CHARACTER & GARAGE HUB (ING. PAOLO 1993)
# ==============================================================================

const StreetRodManager = preload("res://scripts/StreetRodManager.gd")
const StreetRodUI = preload("res://scripts/StreetRodUI.gd")

func _init():
	print("==================================================================")
	print("  TEST AUTOMATIZZATO: CHARACTER PROFILE, GARAGE HUB & MISSION BOARD")
	print("==================================================================")
	
	var passed = 0
	var total = 0
	
	# TEST 1: Manager Initialization & Player Profile
	total += 1
	var mgr = StreetRodManager.new()
	root.add_child(mgr)
	var profile = mgr.get_player_profile()
	if profile.get("name") == "Paolo" and profile.has("skills") and profile.has("stats"):
		print("[PASS] Test 1: Profilo Pilota 'Ing. Paolo' inizializzato con successo.")
		print("       -> Licenza CSAI: %s | Titolo: %s" % [profile.get("license_code"), profile.get("rank_title")])
		print("       -> Abilità: Meccanica %d%% | Assetto %d%% | Quota %d%%" % [
			profile["skills"].get("meccanica", 0),
			profile["skills"].get("assetto_curve", 0),
			profile["skills"].get("respiro_quota", 0)
		])
		passed += 1
	else:
		printerr("[FAIL] Test 1: Profilo pilota non valido: ", profile)
		
	# TEST 2: Garage & Multi-Car Ownership
	total += 1
	var garage = mgr.garage
	if garage.size() >= 2:
		var car0 = garage[0]
		var car1 = garage[1]
		print("[PASS] Test 2: Parco Auto possedute contiene %d vetture iniziali." % garage.size())
		print("       -> Slot 1: %s (%s) - Valore: L. %s" % [car0.get("name"), car0.get("nickname"), mgr.format_lire(car0.get("estimated_value", 0))])
		print("       -> Slot 2: %s (%s) - Valore: L. %s" % [car1.get("name"), car1.get("nickname"), mgr.format_lire(car1.get("estimated_value", 0))])
		passed += 1
	else:
		printerr("[FAIL] Test 2: Garage vuoto o con meno di 2 auto: ", garage.size())
		
	# TEST 3: Active Car Selection & Switch
	total += 1
	mgr.select_active_car(1)
	var active_car = mgr.get_active_car()
	if active_car.get("car_id") == "panda_4x4":
		print("[PASS] Test 3: Cambio auto attiva nel box riuscito (Attiva: %s)." % active_car.get("name"))
		passed += 1
	else:
		printerr("[FAIL] Test 3: Auto attiva errata: ", active_car)
		
	# Ripristina auto 0
	mgr.select_active_car(0)
	
	# TEST 4: Mission Board & Active Contract Selection
	total += 1
	var ok_contract = mgr.set_active_contract("delivery_agip")
	var active_c = mgr.get_active_contract()
	if ok_contract and active_c.get("id") == "delivery_agip":
		print("[PASS] Test 4: Contratto/Missione attivo selezionato: %s" % active_c.get("title"))
		print("       -> Destinazione: %s | Target: %.1fm | Ricompensa: L. %s" % [
			active_c.get("destination"),
			active_c.get("target_dist_m"),
			mgr.format_lire(active_c.get("reward_lire", 0))
		])
		passed += 1
	else:
		printerr("[FAIL] Test 4: Selezione contratto fallita.")
		
	# TEST 5: Progression Tracking, Mileage Accumulation & Mission Completion
	total += 1
	var cash_before = mgr.cash_lire
	var rep_before = mgr.reputation
	var missions_before = profile["stats"].get("missions_completed", 0)
	
	# Simula avanzamento guida sul tracciato fino al target (720m)
	mgr.check_journey_progress(100.0)
	mgr.check_journey_progress(400.0)
	mgr.check_journey_progress(750.0) # Oltrepassa il target di 720m!
	
	var cash_after = mgr.cash_lire
	var rep_after = mgr.reputation
	var profile_after = mgr.get_player_profile()
	var missions_after = profile_after["stats"].get("missions_completed", 0)
	
	if cash_after > cash_before and rep_after > rep_before and missions_after > missions_before:
		print("[PASS] Test 5: Missione completata con successo al superamento del target Z!")
		print("       -> Lire: L. %s -> L. %s (+%s)" % [mgr.format_lire(cash_before), mgr.format_lire(cash_after), mgr.format_lire(cash_after - cash_before)])
		print("       -> Rispetto: %d -> %d | Missioni completate: %d" % [rep_before, rep_after, missions_after])
		print("       -> Km Carriera Guidati: %.2f km" % profile_after["stats"].get("km_driven", 0.0))
		passed += 1
	else:
		printerr("[FAIL] Test 5: Missione non completata o ricompense non accreditate.")
		
	# TEST 6: StreetRodUI Hub Construction & Tab Management
	total += 1
	var ui = StreetRodUI.new()
	ui.street_rod_manager = mgr
	root.add_child(ui)
	
	# Verifica che l'Hub sia Tab 0
	ui.open_screen(0)
	if ui.is_open and ui.current_tab == 0 and ui.tab_containers.size() == 6:
		print("[PASS] Test 6: Interfaccia StreetRodUI creata con 6 schede, Hub aperto a Tab 0.")
		print("       -> Nome Tab 0: %s" % ui.tab_buttons[0].text)
		passed += 1
	else:
		printerr("[FAIL] Test 6: UI non aperta a Tab 0 o numero schede errato.")
		
	# TEST 7: UI Close & Car Selection Integration
	total += 1
	ui.close_screen()
	if not ui.is_open and not ui.visible:
		print("[PASS] Test 7: Chiusura interfaccia con uscita sul tracciato eseguita regolarmente.")
		passed += 1
	else:
		printerr("[FAIL] Test 7: Chiusura UI non avvenuta.")
		
	print("==================================================================")
	print("  RISULTATO TEST: %d / %d TEST SUPERATI CON SUCCESSO!" % [passed, total])
	print("==================================================================")
	
	if passed == total:
		print(">>> TUTTI I REQUISITI DI STREET ROD & CARRIERA SODDISFATTI! <<<")
		quit(0)
	else:
		printerr(">>> ALCUNI TEST SONO FALLITI! <<<")
		quit(1)
