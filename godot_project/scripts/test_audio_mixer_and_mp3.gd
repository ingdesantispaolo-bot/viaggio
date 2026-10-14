extends SceneTree

const VehicleAudio = preload("res://scripts/VehicleAudio.gd")

func _init():
	print("\n==================================================================")
	print("  TEST UNITARIO: CONTROLLO VOLUMI A SEZIONI & AUTORADIO MP3")
	print("==================================================================")
	
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var va = VehicleAudio.new()
	root_node.add_child(va)
	va._ready()
	
	print("\n[TEST 1] Verifica Inizializzazione Mixer Volumi (Default 100%):")
	print("  Master:  %.2f (Gain: %.2f dB)" % [va.get_master_volume(), va.get_master_gain_db()])
	print("  Engine:  %.2f (Gain: %.2f dB)" % [va.get_engine_volume(), va.get_engine_gain_db()])
	print("  Ambient: %.2f (Gain: %.2f dB)" % [va.get_ambient_volume(), va.get_ambient_gain_db()])
	print("  Radio:   %.2f (Gain: %.2f dB)" % [va.get_radio_volume(), va.get_radio_gain_db()])
	
	assert(va.get_master_volume() == 1.0, "Master deve essere 1.0 di default")
	assert(abs(va.get_engine_gain_db() - 0.0) < 0.01, "Gain a 100% deve essere 0.0 dB")
	
	print("\n[TEST 2] Regolazione per sezioni (Differenziazione Volumi):")
	# Abbassa motore al 40%, alza radio al 130%, silenzia ambiente
	va.set_engine_volume(0.40)
	va.set_radio_volume(1.30)
	va.set_ambient_volume(0.0)
	
	var eg_gain = va.get_engine_gain_db()
	var rad_gain = va.get_radio_gain_db()
	var amb_gain = va.get_ambient_gain_db()
	
	print("  Motore (40%%):    %.2f dB" % eg_gain)
	print("  Radio (130%%):   +%.2f dB" % rad_gain)
	print("  Ambiente (0%%):   %.2f dB" % amb_gain)
	
	assert(eg_gain < -7.0, "Motore al 40% deve attenuare di almeno -7 dB")
	assert(rad_gain > 2.0, "Radio al 130% deve incrementare di oltre +2 dB")
	assert(amb_gain <= -80.0, "Ambiente allo 0% deve essere mutato a -80 dB")
	print("  -> Differenziazione volumi perfettamente funzionante!")
	
	print("\n[TEST 3] Salvataggio e Ripristino Persistente delle Impostazioni:")
	va.save_audio_settings()
	assert(FileAccess.file_exists(va.AUDIO_CONFIG_PATH), "Il file di configurazione audio deve esistere")
	
	# Crea una nuova istanza per testare il caricamento da disco
	var va_loaded = VehicleAudio.new()
	root_node.add_child(va_loaded)
	va_loaded.load_audio_settings()
	print("  Valori ricaricati da file: Engine=%.2f | Radio=%.2f | Ambient=%.2f" % [
		va_loaded.get_engine_volume(),
		va_loaded.get_radio_volume(),
		va_loaded.get_ambient_volume()
	])
	assert(abs(va_loaded.get_engine_volume() - 0.40) < 0.01, "Engine volume salvato correttamente")
	assert(abs(va_loaded.get_radio_volume() - 1.30) < 0.01, "Radio volume salvato correttamente")
	assert(abs(va_loaded.get_ambient_volume() - 0.0) < 0.01, "Ambient volume salvato correttamente")
	print("  -> Persistenza impostazioni audio verificata con successo!")
	
	# Ripristina a 100% per i test successivi
	va.set_engine_volume(1.0)
	va.set_ambient_volume(1.0)
	va.set_radio_volume(1.0)
	va.set_master_volume(1.0)
	
	print("\n[TEST 4] Verifica Struttura e Scansione Autoradio & Cartelle MP3:")
	print("  Cartelle scansionate per MP3: ", va.MP3_SEARCH_DIRS)
	print("  Numero canali autoradio registrati: ", va.radio_stations.size())
	for idx in range(va.radio_stations.size()):
		var st = va.radio_stations[idx]
		print("    [%d] %s (%s) | MP3: %s" % [idx, st.name, st.freq, st.get("is_mp3", false)])
		
	assert(va.radio_stations.size() >= 4, "Devono essere presenti almeno 'Spenta' + stazioni procedurali")
	assert(va.radio_stations[0].name == "AUTORADIO SPENTA", "La prima stazione deve essere spenta")
	
	# Test cycling
	var st1 = va.cycle_radio_station()
	print("  Premuto [R] -> Canale: ", st1)
	assert(va.is_radio_playing(), "La radio deve essere in riproduzione dopo il primo cambio")
	
	var st_prev = va.prev_radio_station()
	print("  Premuto [PREC] -> Canale: ", st_prev)
	assert(st_prev.begins_with("AUTORADIO SPENTA"), "Tornando indietro deve spegnersi")
	assert(not va.is_radio_playing(), "La radio deve essere spenta")
	
	var st_pwr = va.toggle_radio_power()
	print("  Premuto [POWER ON] -> Canale: ", st_pwr)
	assert(va.is_radio_playing(), "La radio deve essere accesa")
	
	print("\n[TEST 5] Verifica Overlay e Modal Mixer in DashboardUI:")
	var packed_ui = load("res://scenes/DashboardUI.tscn")
	var ui = packed_ui.instantiate()
	root_node.add_child(ui)
	ui._ready()
	
	assert(ui.has_method("setup_audio_mixer_modal"), "DashboardUI deve avere setup_audio_mixer_modal")
	assert(ui.btn_hud_mixer != null, "Pulsante [O] MIXER deve essere presente nella barra HUD")
	
	ui.open_audio_mixer_modal()
	assert(ui.is_audio_mixer_open(), "Il modal Mixer Audio deve risultare aperto")
	print("  Pannello Mixer Audio aperto: ", ui.is_audio_mixer_open())
	
	ui.close_audio_mixer_modal()
	assert(not ui.is_audio_mixer_open(), "Il modal Mixer Audio deve risultare chiuso")
	print("  Pannello Mixer Audio chiuso con successo: ", not ui.is_audio_mixer_open())
	
	print("\n==================================================================")
	print("  [PASS] TUTTI I TEST DEL MIXER AUDIO E AUTORADIO MP3 SUPERATI!")
	print("==================================================================")
	quit(0)
