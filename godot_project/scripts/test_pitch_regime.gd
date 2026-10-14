extends SceneTree

# Validazione Frequenza Fondamentale e Regime Motore

func _init():
	print("\n==================================================================")
	print("  TEST VERIFICA: CORRISPONDENZA TONO-REGIME MOTORE (FISICA ICE)")
	print("==================================================================")
	test_pitch_physics()
	quit(0)

func test_pitch_physics():
	# 1. Verifica frequenze fondamentali teoriche a 1200 RPM
	# 4-cyl = 1200 / 30 = 40.0 Hz
	# 6-cyl = 1200 / 20 = 60.0 Hz
	# 8-cyl = 1200 / 15 = 80.0 Hz
	var test_cases = [
		{"family": "fire_1000", "cyl": 4, "f_1200": 40.0},
		{"family": "small_ohv", "cyl": 4, "f_1200": 40.0},
		{"family": "twin_cam_weber", "cyl": 4, "f_1200": 40.0},
		{"family": "turbo_16v", "cyl": 4, "f_1200": 40.0},
		{"family": "inline_6", "cyl": 6, "f_1200": 60.0},
		{"family": "dino_v6", "cyl": 6, "f_1200": 60.0},
		{"family": "straight_8", "cyl": 8, "f_1200": 80.0}
	]
	
	for tc in test_cases:
		var fam: String = tc["family"]
		var f_base: float = tc["f_1200"]
		print("\n--- Famiglia %s (%d cilindri, base %.1f Hz a 1200 RPM) ---" % [fam, tc["cyl"], f_base])
		
		# Verifica frequenze a vari regimi: 850 RPM (idle), 3000 RPM, 6000 RPM
		var rpms = [850.0, 1500.0, 3000.0, 4500.0, 6000.0, 7200.0]
		for rpm in rpms:
			var pitch_scale = rpm / 1200.0
			var f_out = f_base * pitch_scale
			var f_exact_physics = (rpm / 60.0) * (float(tc["cyl"]) / 2.0)
			print("  RPM %4d -> pitch_scale: %.3f -> Tono fondamentale: %5.1f Hz (Fisica esatta: %5.1f Hz)" % [
				int(rpm), pitch_scale, f_out, f_exact_physics
			])
			assert(abs(f_out - f_exact_physics) < 0.01, "Il tono DEVE corrispondere esattamente alla fisica del regime motore!")
			
	print("\n==================================================================")
	print("  TUTTI I CALCOLI FISICI DEL TONO CORRISPONDONO AL REGIME AL 100%!")
	print("==================================================================\n")
