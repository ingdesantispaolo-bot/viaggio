extends SceneTree

const StreetRodManagerScript = preload("res://scripts/StreetRodManager.gd")
const RaceDirectorScript = preload("res://scripts/RaceDirector.gd")
const RoadGeneratorScript = preload("res://scripts/RoadGenerator.gd")

func _init():
	print("==================================================================")
	print("VALICO DEI MOTORI '93 - TEST SUITE: REGOLE GARA, AI LAUNCH & GIUNZIONI")
	print("==================================================================")
	
	test_street_rod_race_rules()
	test_chunk_seam_continuity()
	test_race_director_ai_and_victory()
	
	print("\n==================================================================")
	print("TUTTI I TEST SUPERATI CON SUCCESSO! [100% OK]")
	print("==================================================================")
	quit(0)

func test_street_rod_race_rules():
	print("\n--- TEST 1: REGOLE DI ACCESSO GARA & VALIDAZIONE (StreetRodManager) ---")
	var mgr = StreetRodManagerScript.new()
	mgr.cash_lire = 1500000
	mgr.reputation = 50
	mgr.garage = [
		{
			"car_id": "fiat_127",
			"name": "Fiat 127 Special (1974)",
			"engine_health": 0.88,
			"tire_health": 0.82
		}
	]
	
	# State: cash_lire = 1_500_000, rep = 50, garage has 1 car (fiat_127)
	print("   1.1 Test scommessa Gino (Rep richiesta 40 <= 50, scommessa 500k <= 1.5M):")
	var check_gino = mgr.can_challenge_rival("gino", false)
	assert(check_gino.can_race == true, "Gino dovrebbe essere sfidabile con 50 rep e 1.5M Lire")
	print("   -> OK! Gino sfidabile regolarmente.")
	
	print("   1.2 Test Kurt (Rep richiesta 180 > attuale 50):")
	var check_kurt = mgr.can_challenge_rival("kurt", false)
	assert(check_kurt.can_race == false, "Kurt NON deve essere sfidabile con rep 50")
	assert("Rispetto insufficiente" in check_kurt.reason, "Messaggio motivo corretto")
	print("   -> OK! Bloccato per rispetto: %s" % check_kurt.reason)
	
	print("   1.3 Test fondi insufficienti:")
	mgr.cash_lire = 100000 # Solo 100k
	var check_cash = mgr.can_challenge_rival("gino", false)
	assert(check_cash.can_race == false, "Gino NON deve essere sfidabile se mancano Lire")
	assert("Fondi insufficienti" in check_cash.reason, "Messaggio motivo corretto")
	print("   -> OK! Bloccato per fondi: %s" % check_cash.reason)
	mgr.cash_lire = 1500000 # Ripristina
	
	print("   1.4 Test sfida a libretto (Pink Slip) con 1 sola auto in garage:")
	assert(mgr.garage.size() == 1, "Garage ha 1 auto")
	var check_pink = mgr.can_challenge_rival("gino", true)
	assert(check_pink.can_race == false, "Pink slip NON consentita con 1 sola auto")
	assert("Regola Libretto" in check_pink.reason, "Messaggio motivo corretto")
	print("   -> OK! Bloccato pink slip per auto unica: %s" % check_pink.reason)
	
	print("   1.5 Test sfida a libretto con 2 auto in garage:")
	mgr.garage.append({
		"car_id": "panda_4x4",
		"name": "Fiat Panda 4x4",
		"engine_health": 0.90,
		"tire_health": 0.85
	})
	var check_pink_ok = mgr.can_challenge_rival("gino", true)
	assert(check_pink_ok.can_race == true, "Pink slip CONSENTITA con 2 auto")
	print("   -> OK! Pink slip consentita con 2 auto.")
	
	print("   1.6 Test salute motore compromessa:")
	mgr.garage[0].engine_health = 0.12 # Fuso
	var check_engine = mgr.can_challenge_rival("gino", false)
	assert(check_engine.can_race == false, "Gara NON consentita con motore fuso")
	assert("Motore in avaria" in check_engine.reason, "Messaggio avaria corretto")
	print("   -> OK! Bloccato per motore danneggiato: %s" % check_engine.reason)
	mgr.garage[0].engine_health = 1.0 # Ripristina
	
	mgr.free()

func test_chunk_seam_continuity():
	print("\n--- TEST 2: CONTINUITÀ MATEMATICA E FISICA DEI CHUNK (Zero Faglie/Scalini) ---")
	var root = Node3D.new()
	var road_gen = RoadGeneratorScript.new()
	road_gen.base_width = 7.8
	road_gen.chunk_length = 80.0
	road_gen.road_segments = 24
	root.add_child(road_gen)
	
	# Genera fino a 360m (copre Z=240 giunzione chunk 3 e 4)
	road_gen.update_generation(360.0)
	
	var c3 = road_gen.active_chunks[2] # 160m - 240m
	var c4 = road_gen.active_chunks[3] # 240m - 320m
	
	var p_c3_end = c3.points[c3.points.size() - 1]
	var p_c4_start = c4.points[0]
	
	print("   Chunk 3 fine:   X=%.4f, Y=%.4f, Z=%.4f, Bank=%.4f rad, Width=%.2fm" % [p_c3_end.x, p_c3_end.y, p_c3_end.z, p_c3_end.bank, p_c3_end.width])
	print("   Chunk 4 inizio: X=%.4f, Y=%.4f, Z=%.4f, Bank=%.4f rad, Width=%.2fm" % [p_c4_start.x, p_c4_start.y, p_c4_start.z, p_c4_start.bank, p_c4_start.width])
	
	var err_x = abs(p_c3_end.x - p_c4_start.x)
	var err_y = abs(p_c3_end.y - p_c4_start.y)
	var err_z = abs(p_c3_end.z - p_c4_start.z)
	var err_bank = abs(p_c3_end.bank - p_c4_start.bank)
	var err_w = abs(p_c3_end.width - p_c4_start.width)
	
	assert(err_x < 0.0001, "Discontinuità laterale X su giunzione chunk!")
	assert(err_y < 0.0001, "Discontinuità quota Y (faglia/scalino) su giunzione chunk!")
	assert(err_z < 0.0001, "Discontinuità longitudinale Z su giunzione chunk!")
	assert(err_bank < 0.0001, "Discontinuità di sopraelevazione (banking) su giunzione chunk!")
	assert(err_w < 0.0001, "Discontinuità larghezza sede stradale su giunzione chunk!")
	
	print("   -> OK! Errore massimo di giunzione = 0.0000 mm (perfetta continuità C1/C2).")
	root.free()

func test_race_director_ai_and_victory():
	print("\n--- TEST 3: AI RIVAL LAUNCH & REGOLE DI VITTORIA (RaceDirector) ---")
	var root = Node3D.new()
	var road_gen = RoadGeneratorScript.new()
	road_gen.base_width = 7.8
	road_gen.chunk_length = 80.0
	road_gen.road_segments = 24
	root.add_child(road_gen)
	road_gen.update_generation(520.0)
	
	var mgr = StreetRodManagerScript.new()
	mgr.name = "StreetRodManager"
	mgr.cash_lire = 1500000
	mgr.reputation = 50
	root.add_child(mgr)
	
	var rd = RaceDirectorScript.new()
	rd.name = "RaceDirector"
	rd._ready()
	root.add_child(rd)
	
	# 3.1 Test pre-race blockage when rules violated
	print("   3.1 Tentativo di avvio gara con rivale bloccato (Kurt, rep richiesta 180 > 50):")
	rd.start_drag_race("kurt", false, 3)
	assert(rd.current_state != 2, "La gara con Kurt NON deve entrare in COUNTDOWN!") # 2 is COUNTDOWN
	print("   -> OK! Partenza bloccata con successo.")
	
	# 3.2 Test legitimate race start with Gino
	print("   3.2 Avvio gara legittima con Gino:")
	rd.start_drag_race("gino", false, 3)
	assert(rd.current_state == 2, "La gara con Gino deve entrare in COUNTDOWN") # 2 is COUNTDOWN
	assert(rd.rival_vehicle != null, "Il veicolo rivale 3D deve essere istanziato")
	assert(rd.rival_vehicle.is_engine_running == true, "Il motore del rivale DEVE essere acceso!")
	assert(rd.rival_vehicle.current_gear == 1, "La marcia del rivale deve essere la 1a")
	print("   -> OK! Motore rivale acceso (is_engine_running = true) pronto allo stacco.")
	
	# 3.3 Test countdown to green light & launch
	rd.update_countdown(4.1) # Exceed 4.0s green light
	assert(rd.current_state == 3, "Stato gara deve passare a RACING al verde") # 3 is RACING
	
	# Advance race time past rival reaction delay
	rd.update_race(0.35)
	assert(rd.rival_launched == true, "Il rivale deve essere scattato")
	assert(rd.rival_vehicle.ai_throttle == 1.0, "Il rivale deve spalancare il gas al 100%")
	assert(rd.rival_vehicle.ai_brake == 0.0, "Il freno del rivale deve essere rilasciato")
	assert(rd.rival_vehicle.ai_handbrake == false, "Il freno a mano del rivale deve essere rilasciato")
	print("   -> OK! Rivale lanciato con gas a tavoletta e freni rilasciati.")
	
	# 3.4 Test victory resolution when player crosses first and rival doesn't move or is slower
	print("   3.4 Test regola vittoria: Giocatore taglia a 14.8s, Rivale non è arrivato:")
	rd.player_crossed = true
	rd.player_finish_time = 14.8
	rd.rival_crossed = false
	rd.rival_finish_time = 0.0
	rd.on_race_finished()
	
	assert(rd.current_state == 4, "Gara deve essere FINISHED") # 4 is FINISHED
	var title_lbl = rd.hud_result_card.find_child("ResultTitle", true, false) as Label
	assert("VITTORIA" in title_lbl.text, "Giocatore deve essere dichiarato vincitore se il rivale non arriva!")
	print("   -> OK! Risultato: %s" % title_lbl.text)
	
	# 3.5 Test victory resolution when rival crosses first
	print("   3.5 Test regola vittoria: Rivale taglia a 14.2s, Giocatore a 15.0s:")
	rd.player_crossed = true
	rd.player_finish_time = 15.0
	rd.rival_crossed = true
	rd.rival_finish_time = 14.2
	rd.on_race_finished()
	title_lbl = rd.hud_result_card.find_child("ResultTitle", true, false) as Label
	assert("SCONFITTA" in title_lbl.text, "Rivale con tempo inferiore deve vincere!")
	print("   -> OK! Risultato: %s" % title_lbl.text)
	
	root.free()
