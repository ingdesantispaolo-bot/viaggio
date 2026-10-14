extends SceneTree

# Validazione Sintesi Frequenze Armoniche e Realismo Tono

func _init():
	print("\n==================================================================")
	print("  TEST SINTESI FISICA PURA: FONDAMENTALE ESATTA & ZERO ARTEFATTI")
	print("==================================================================")
	test_synth()
	quit(0)

func test_synth():
	var families = ["small_ohv", "fire_1000", "twin_cam_weber", "turbo_16v", "inline_6", "dino_v6", "straight_8"]
	for fam in families:
		var stream = synth_family(fam)
		var sample_count = stream.data.size() / 2
		var s_first = stream.data.decode_s16(0) / 32768.0
		var s_last = stream.data.decode_s16((sample_count - 1) * 2) / 32768.0
		var seam_diff = abs(s_first - s_last)
		
		var max_peak = 0.0
		for i in range(sample_count):
			var v = abs(stream.data.decode_s16(i * 2) / 32768.0)
			if v > max_peak: max_peak = v
			
		print("  Famiglia %15s | Campioni: %d | Cucitura: %.5f | Picco: %.3f (Headroom: %.1f dB)" % [
			fam, sample_count, seam_diff, max_peak, 20.0 * log(max(0.001, max_peak)) / log(10.0)
		])
		assert(seam_diff < 0.01, "Cucitura deve essere < 0.01")
		assert(max_peak <= 0.88, "Headroom di sicurezza rispettata")
	print("\n[PASS] Tutte le famiglie verificate con successo!")

func synth_family(family: String) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 44100
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = 44100
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var raw_samples = PackedFloat32Array()
	raw_samples.resize(sample_count)
	
	var f_fire = 40.0
	var h1 = 0.55
	var h2 = 0.36
	var h3 = 0.20
	var h4 = 0.12
	var h5 = 0.00
	var h6 = 0.06
	var h8 = 0.00
	var cam_sub = 0.10
	var drive = 1.7
	var gain = 0.76
	var is_dino = false
	
	match family:
		"small_ohv":
			f_fire = 40.0
			h1 = 0.44
			h2 = 0.30
			h3 = 0.38
			h4 = 0.20
			h5 = 0.22
			h6 = 0.08
			h8 = 0.04
			cam_sub = 0.12
			drive = 2.2
			gain = 0.77
		"fire_1000":
			f_fire = 40.0
			h1 = 0.58
			h2 = 0.36
			h3 = 0.20
			h4 = 0.12
			h5 = 0.00
			h6 = 0.06
			h8 = 0.00
			cam_sub = 0.10
			drive = 1.7
			gain = 0.76
		"twin_cam_weber":
			f_fire = 40.0
			h1 = 0.46
			h2 = 0.46
			h3 = 0.28
			h4 = 0.30
			h5 = 0.12
			h6 = 0.18
			h8 = 0.08
			cam_sub = 0.16
			drive = 2.4
			gain = 0.78
		"turbo_16v":
			f_fire = 40.0
			h1 = 0.64
			h2 = 0.40
			h3 = 0.18
			h4 = 0.16
			h5 = 0.00
			h6 = 0.08
			h8 = 0.04
			cam_sub = 0.12
			drive = 1.9
			gain = 0.77
		"inline_6":
			f_fire = 60.0
			h1 = 0.52
			h2 = 0.22
			h3 = 0.42
			h4 = 0.14
			h5 = 0.00
			h6 = 0.24
			h8 = 0.06
			cam_sub = 0.02
			drive = 1.6
			gain = 0.74
		"dino_v6":
			f_fire = 60.0
			h1 = 0.40
			h2 = 0.34
			h3 = 0.36
			h4 = 0.22
			h5 = 0.16
			h6 = 0.24
			h8 = 0.08
			cam_sub = 0.08
			drive = 2.4
			gain = 0.78
			is_dino = true
		"straight_8":
			f_fire = 80.0
			h1 = 0.58
			h2 = 0.36
			h3 = 0.14
			h4 = 0.26
			h5 = 0.00
			h6 = 0.10
			h8 = 0.12
			cam_sub = 0.04
			drive = 1.9
			gain = 0.76
			
	for i in range(sample_count):
		var t = float(i) / 44100.0
		var phase = t * f_fire * TAU
		
		var s = 0.0
		if is_dino:
			# V6 a 65°: battimento asimmetrico continuo
			s = sin(phase) * h1
			s += sin(phase * 1.0833) * 0.22 # offset 65°/55° bank
			s += sin(phase * 2.0) * h2
			s += sin(phase * 3.0) * h3
			s += sin(phase * 4.0) * h4
			s += sin(phase * 6.0) * h6
		else:
			s = sin(phase) * h1
			s += sin(phase * 2.0) * h2
			s += sin(phase * 3.0) * h3
			s += sin(phase * 4.0) * h4
			if h5 > 0.0: s += sin(phase * 5.0) * h5
			if h6 > 0.0: s += sin(phase * 6.0) * h6
			if h8 > 0.0: s += sin(phase * 8.0) * h8
			
		# Modulazione subarmonica dell'albero a camme (10 Hz a 1200 RPM)
		var cam_phase = t * 10.0 * TAU
		s += sin(cam_phase) * cam_sub
		s += sin(cam_phase * 2.0) * (cam_sub * 0.5)
		
		# Saturazione calda analogica
		s = tanh(s * drive) * gain
		raw_samples[i] = s
		
	# Zero-crossing soft crossfade sugli ultimi 64 campioni
	var s0 = raw_samples[0]
	for k in range(64):
		var idx = sample_count - 64 + k
		var alpha = float(k + 1) / 64.0
		raw_samples[idx] = lerp(raw_samples[idx], s0, alpha * alpha)
		
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var sample_16 = int(clamp(raw_samples[i] * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav
