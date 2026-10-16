extends SceneTree

# Script di verifica automatica per VehicleAudio e integrazione modelli 3D GLB
func _init():
	print("==================================================================")
	print(" [TEST COLLAUDO] VERIFICA AUDIO MOTORE E INTEGRAZIONE VEICOLI GLB ")
	print("==================================================================")
	
	# 1. Verifica compilazione e istanziazione di VehicleAudio
	var VehicleAudioClass = load("res://scripts/VehicleAudio.gd")
	if not VehicleAudioClass:
		push_error("ERRORE: Impossibile caricare VehicleAudio.gd!")
		quit(1)
		return
	
	var audio = VehicleAudioClass.new()
	print("[OK] VehicleAudio.gd caricato e istanziato con successo.")
	
	# 2. Verifica di tutte le 17 famiglie motore e campioni sintetizzati
	var test_families = [
		"vintage_sidevalve",
		"straight_8_supercharged",
		"aurelia_v6",
		"twin_cam_weber",
		"small_ohv",
		"twin_cam_16v",
		"dino_v6",
		"flat_6_aircooled_turbo",
		"renault_cleon",
		"inline_6_m110",
		"fire_1000",
		"vw_16v_na",
		"inline_6_m20",
		"turbo_16v",
		"modern_turbo_4",
		"flat_6_twinturbo_modern",
		"v12_italian_screamer"
	]
	
	print("\n--- TEST 1: Sintesi acustica per le 17 famiglie motore ---")
	for fam in test_families:
		var eng_stream = audio.create_engine_stream_for_family(fam)
		var int_stream = audio.create_intake_stream_for_family(fam)
		var mech_stream = audio.create_mech_stream_for_family(fam)
		
		assert(eng_stream != null and eng_stream.data.size() > 0, "Engine stream nullo per " + fam)
		assert(int_stream != null and int_stream.data.size() > 0, "Intake stream nullo per " + fam)
		assert(mech_stream != null and mech_stream.data.size() > 0, "Mech stream nullo per " + fam)
		print("  -> Famiglia '%s': Engine(%d bytes), Intake(%d bytes), Mech(%d bytes) - OK" % [
			fam, eng_stream.data.size(), int_stream.data.size(), mech_stream.data.size()
		])
	
	# 3. Verifica BOV (Blow-Off Valve) e Turbo Whistle
	print("\n--- TEST 2: Sintesi Blow-Off Valve e Turbo Whistle ---")
	var bov = audio.create_bov_stream()
	var turbo = audio.create_turbo_stream()
	assert(bov != null and bov.data.size() > 0, "BOV stream fallito")
	assert(turbo != null and turbo.data.size() > 0, "Turbo stream fallito")
	print("  -> BOV Stream: %d bytes - OK" % bov.data.size())
	print("  -> Turbo Whistle Stream: %d bytes - OK" % turbo.data.size())
	
	# 4. Verifica VehicleController e catalogo modelli
	print("\n--- TEST 3: Verifica catalogo VehicleController e mapping audio ---")
	var VehicleCtrlClass = load("res://scripts/VehicleController.gd")
	if not VehicleCtrlClass:
		push_error("ERRORE: Impossibile caricare VehicleController.gd!")
		quit(1)
		return
		
	var v_ctrl = VehicleCtrlClass.new()
	var catalog = v_ctrl.VEHICLE_CATALOG
	print("  -> Totale veicoli registrati nel catalogo: %d" % catalog.size())
	
	for model_id in catalog.keys():
		var cfg = catalog[model_id]
		var fam = audio.get_engine_family_for_model(model_id)
		print("  -> Auto: [%s] '%s' (%d) -> Motore: '%s' | Famiglia Audio: '%s' | Redline: %d RPM" % [
			model_id, cfg.name, cfg.year, cfg.engine, fam, int(cfg.redline_rpm)
		])
		assert(fam != "", "Famiglia audio vuota per " + model_id)
		
	# 5. Verifica modelli GLB sul disco
	print("\n--- TEST 4: Verifica presenza file GLB sul filesystem ---")
	var glb_files = [
		"res://models/fiat_127.glb",
		"res://models/porsche_930_turbo.glb",
		"res://models/porsche_carrera_4s.glb",
		"res://models/countach_lpi800.glb"
	]
	for g in glb_files:
		var exists = FileAccess.file_exists(g)
		print("  -> File %s presente: %s" % [g, str(exists)])
		assert(exists, "File GLB mancante: " + g)
		
	print("\n==================================================================")
	print(" [ESITO] TUTTI I TEST SONO PASSATI CON SUCCESSO SENZA ERRORI! ")
	print("==================================================================")
	quit(0)
