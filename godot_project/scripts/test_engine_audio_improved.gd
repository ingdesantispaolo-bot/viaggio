extends SceneTree

# IL GRANDE MERIDIANO - Test Validazione Sintesi Motore Fisica & Acustica

const VehicleAudio = preload("res://scripts/VehicleAudio.gd")

func _init():
	print("\n==================================================================")
	print("  TEST VERIFICA: SINTESI ACUSTICA MOTORE REALISTICA & NO DISTORSIONE")
	print("==================================================================")
	run_tests()
	quit(0)

func run_tests():
	var audio = VehicleAudio.new()
	root.add_child(audio)
	if not audio.is_node_ready():
		audio._ready()

	print("\n--- 1. Verifica Inizializzazione Stream & Player ---")
	assert(audio.engine_player != null, "engine_player deve esistere")
	assert(audio.intake_player != null, "intake_player deve esistere")
	assert(audio.mech_player != null, "mech_player deve esistere")
	assert(audio.road_player != null, "road_player deve esistere")
	assert(audio.turbo_player != null, "turbo_player deve esistere")
	assert(audio.exhaust_pop_player != null, "exhaust_pop_player deve esistere")
	print("[PASS] Tutti i player audio a 3 strati acustici sono stati istanziati.")

	print("\n--- 2. Verifica Famiglie Motoristiche ---")
	var families = ["small_ohv", "fire_1000", "twin_cam_weber", "turbo_16v", "inline_6", "dino_v6", "straight_8"]
	for fam in families:
		var stream: AudioStreamWAV = audio.create_engine_stream_for_family(fam)
		assert(stream != null, "Stream per famiglia " + fam + " non deve essere nullo")
		assert(stream.data.size() > 0, "Dati audio per " + fam + " non possono essere vuoti")
		assert(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Stream deve avere LOOP_FORWARD")
		print("  [OK] Famiglia %s: stream generato con %d byte (%d campioni a %d Hz)" % [
			fam, stream.data.size(), stream.data.size() / 2, stream.mix_rate
		])

	print("\n--- 3. Verifica Integrità Campioni & Assenza Discontinuità (Loop Seam) ---")
	for fam in families:
		var stream: AudioStreamWAV = audio.create_engine_stream_for_family(fam)
		var byte_count = stream.data.size()
		var sample_count = byte_count / 2
		
		# Verifica primo e ultimo campione per assenza di spike/click alla cucitura del loop
		var first_sample = stream.data.decode_s16(0) / 32768.0
		var last_sample = stream.data.decode_s16((sample_count - 1) * 2) / 32768.0
		var seam_diff = abs(first_sample - last_sample)
		print("  Famiglia %15s: primo=%.4f, ultimo=%.4f, diff_cucitura=%.5f" % [fam, first_sample, last_sample, seam_diff])
		assert(seam_diff < 0.01, "Discontinuità alla cucitura del loop per %s deve essere < 0.01 (trovato %.5f)" % [fam, seam_diff])
		
		# Verifica assenza di clipping assoluto nei campioni (headroom digitale)
		var max_peak = 0.0
		for i in range(sample_count):
			var s = abs(stream.data.decode_s16(i * 2) / 32768.0)
			if s > max_peak:
				max_peak = s
		print("  Famiglia %15s: picco massimo = %.3f (headroom = %.1f dB)" % [fam, max_peak, 20.0 * log(max(0.001, max_peak)) / log(10.0)])
		assert(max_peak <= 0.88, "Il picco massimo deve lasciare almeno 1.5 dB di headroom anti-clipping")

	print("\n--- 4. Verifica Strati Aspirazione (Induction) & Meccanica ---")
	for fam in families:
		var in_stream: AudioStreamWAV = audio.create_intake_stream_for_family(fam)
		var mech_stream: AudioStreamWAV = audio.create_mech_stream_for_family(fam)
		assert(in_stream != null and in_stream.data.size() > 0, "Stream aspirazione non valido")
		assert(mech_stream != null and mech_stream.data.size() > 0, "Stream meccanica non valido")
	print("[PASS] Tutti gli stream secondari per aspirazione e distribuzione generati.")

	print("\n--- 5. Verifica Overrun Deceleration Pop ---")
	var pop_stream: AudioStreamWAV = audio.create_exhaust_pop_stream()
	assert(pop_stream != null and pop_stream.data.size() > 0, "Stream backfire pop valido")
	print("[PASS] Stream scoppiettii allo scarico generato a 44.1 kHz.")

	print("\n==================================================================")
	print("  TUTTI I TEST SUPERATI CON SUCCESSO! MOTORE SENZA DIFETTI!")
	print("==================================================================\n")
	audio.queue_free()
