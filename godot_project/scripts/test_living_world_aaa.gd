extends SceneTree

# ==============================================================================
# TEST LIVING WORLD AAA - VALICO DEI MOTORI '93
# ==============================================================================
# Tests all 5 Pillars:
# 1. Narrative Chapters ("I Quaderni del Passo '93")
# 2. Topographic Map & Elevation Profile (7 waypoints)
# 3. Italian Town Civic Life (Ape 50, Vespa Special, Cabina SIP, Bar dello Sport)
# 4. Deep Character Dialogue Trees & Affinity System
# 5. Authentic 1993 Car Radio & Acoustic Church Bells
# ==============================================================================

const StreetRodManager = preload("res://scripts/StreetRodManager.gd")
const StreetRodUI = preload("res://scripts/StreetRodUI.gd")
const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const VehicleAudio = preload("res://scripts/VehicleAudio.gd")

func _init():
	print("\n=======================================================")
	print(">>> AVVIO TEST: LIVING WORLD AAA - VALICO DEI MOTORI '93")
	print("=======================================================\n")
	
	var pass_count = 0
	var total_tests = 0
	
	# --------------------------------------------------------------------------
	# PILLAR 1 & 4: STREET ROD MANAGER - NARRATIVE, DIALOGUE & AFFINITY
	# --------------------------------------------------------------------------
	total_tests += 1
	var srm = StreetRodManager.new()
	root.add_child(srm)
	
	var expected_chars = ["bepi", "gino", "chiara", "kurt", "sandra", "don_attilio", "hans", "duca"]
	var all_chars_present = true
	for c_id in expected_chars:
		if not srm.rivals.has(c_id):
			all_chars_present = false
			print("[-] ERRORE: Personaggio mancante: ", c_id)
			break
			
	if all_chars_present and srm.rivals.size() >= 8:
		pass_count += 1
		print("[+] TEST 1 PASSATO: Tutti gli 8 personaggi storici sono presenti nel roster del Diner.")
	else:
		print("[-] TEST 1 FALLITO: Roster personaggi incompleto.")
		
	# Test dialogue tree & affinity gain
	total_tests += 1
	var initial_bepi_aff = srm.rivals["bepi"].affinity
	var talk_adv = srm.talk_to_character("bepi", "advice")
	var talk_rum = srm.talk_to_character("bepi", "rumors")
	
	if talk_adv.affinity > initial_bepi_aff and talk_adv.text.length() > 20 and talk_rum.text.length() > 20:
		pass_count += 1
		print("[+] TEST 2 PASSATO: Alberi di dialogo interattivi e guadagno affinità verificati (Mastro Bepi: %d%% -> %d%%)." % [initial_bepi_aff, talk_rum.affinity])
	else:
		print("[-] TEST 2 FALLITO: Errore nel sistema di dialogo o affinità.")

	# --------------------------------------------------------------------------
	# PILLAR 2: TOPOGRAPHIC MAP LOCATIONS & CHAPTERS
	# --------------------------------------------------------------------------
	total_tests += 1
	var map_locs = srm.get_map_locations()
	var chapters = srm.get_notebook_chapters()
	
	if map_locs.size() == 7 and chapters.size() == 4:
		pass_count += 1
		print("[+] TEST 3 PASSATO: 7 Settori della Carta Topografica IGM e 4 Capitoli Narrativi verificati.")
		for loc in map_locs:
			print("    * [%dm s.l.m.] %s (%s, Pendenza: %s)" % [loc.altitude_m, loc.name, loc.km_range, loc.gradient_pct])
	else:
		print("[-] TEST 3 FALLITO: Località mappa o capitoli non conformi (%d locs, %d caps)." % [map_locs.size(), chapters.size()])

	# --------------------------------------------------------------------------
	# PILLAR 5: DYNAMIC PRESS HEADLINES & CAR RADIO
	# --------------------------------------------------------------------------
	total_tests += 1
	var headlines = srm.get_dynamic_news_headlines()
	var rad1 = srm.get_current_radio_station()
	var rad2 = srm.switch_radio_station()
	
	if headlines.size() >= 3 and rad1.has("name") and rad2.has("freq"):
		pass_count += 1
		print("[+] TEST 4 PASSATO: Prima pagina dinamica de 'La Gazzetta del Valico' e sintonia autoradio 1993 verificati.")
		print("    * Titolo di prima pagina: ", headlines[0])
	else:
		print("[-] TEST 4 FALLITO: Errore in titoli giornale o commutazione radio.")

	# --------------------------------------------------------------------------
	# PILLAR 3: 3D PROPS IN ROADGENERATOR
	# --------------------------------------------------------------------------
	total_tests += 1
	var rg = RoadGenerator.new()
	root.add_child(rg)
	
	var ape = rg.create_parked_ape_piaggio(Vector3(10, 0, 10), 0.0, Color.BLUE)
	var vespa = rg.create_parked_vespa_special(Vector3(12, 0, 10), 0.0, Color.RED)
	var sip = rg.create_cabina_sip(Vector3(14, 0, 10), 0.0)
	var terrace = rg.create_bar_terrace(Vector3(18, 0, 10), 0.0)
	var sign = rg.create_vintage_sign(Vector3(22, 0, 10), 0.0, "BAR DELLO SPORT", "Caffè", Color.RED)
	var villager = rg.create_villager_silhouette(Vector3(26, 0, 10), 0.0, false)
	var villager_sit = rg.create_villager_silhouette(Vector3(28, 0, 10), 0.0, true)
	
	if ape != null and vespa != null and sip != null and terrace != null and sign != null and villager != null and villager_sit != null:
		pass_count += 1
		print("[+] TEST 5 PASSATO: Generazione modelli 3D epoca (Ape 50, Vespa Special, Cabina SIP, Bar dello Sport, Insegne, Paesani) riuscita.")
	else:
		print("[-] TEST 5 FALLITO: Errore nella creazione dei nodi 3D dei modelli.")

	# --------------------------------------------------------------------------
	# PILLAR 5: PROCEDURAL AUDIO SYNTHESIS & ACOUSTICS
	# --------------------------------------------------------------------------
	total_tests += 1
	var va = VehicleAudio.new()
	va._ready()
	root.add_child(va)
	
	var bell_wav = va.create_church_bell_stream()
	var valico_wav = va.synth_radio_valico_stream()
	var verde_wav = va.synth_onda_verde_stream()
	var rosa_wav = va.synth_monte_rosa_stream()
	
	var radio_cycle_name = va.cycle_radio_station()
	
	if bell_wav.data.size() > 1000 and valico_wav.data.size() > 1000 and verde_wav.data.size() > 1000 and rosa_wav.data.size() > 1000:
		pass_count += 1
		print("[+] TEST 6 PASSATO: Sintesi audio procedurale 1993 (Campane Borgo San Cristoforo, Radio Valico Synthwave, Onda Verde, Monte Rosa) verificata.")
		print("    * Stazione radio sintonizzata: ", radio_cycle_name)
	else:
		print("[-] TEST 6 FALLITO: Buffer audio non validi.")

	# --------------------------------------------------------------------------
	# UI RETRO AMIGA 500 VERIFICATION
	# --------------------------------------------------------------------------
	total_tests += 1
	var ui = StreetRodUI.new()
	ui.street_rod_manager = srm
	ui.setup_amiga_interface()
	root.add_child(ui)
	ui.open_screen(2) # Diner Tab
	ui.select_diner_character("don_attilio")
	ui.open_screen(4) # Topographic Map Tab
	ui.select_map_waypoint(4) # Tornanti dei Larici
	
	if ui.map_detail_name != null and ui.map_detail_name.text.contains("LARICI"):
		pass_count += 1
		print("[+] TEST 7 PASSATO: Interfaccia Amiga 500 (Diner con affinità & Carta Topografica con Waypoint Inspector) pienamente reattiva.")
	else:
		print("[-] TEST 7 FALLITO: Errore di rendering o stato in StreetRodUI.")

	# Summary
	print("\n=======================================================")
	print(">>> RISULTATO COMPLESSIVO: %d / %d TEST SUPERATI (%.1f%%)" % [pass_count, total_tests, (float(pass_count) / float(total_tests)) * 100.0])
	print("=======================================================\n")
	
	if pass_count == total_tests:
		print(">>> SUCCESSO TOTALE: IL MONDO DI GIOCO 'VALICO DEI MOTORI '93' È ORA VIVO, IMMERSIVO E DI LIVELLO AAA!")
	
	quit(0 if pass_count == total_tests else 1)
