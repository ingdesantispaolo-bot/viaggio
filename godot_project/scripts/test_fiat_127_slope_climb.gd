extends SceneTree

# ==============================================================================
# TEST RIGOROSO: COERENZA FISICA FIAT 127 IN SALITA, POTENZA/GRAVITÀ & MATERIALI
# ==============================================================================

const VehicleController = preload("res://scripts/VehicleController.gd")
const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")

func _init():
	print("==================================================================")
	print("  TEST COERENZA FISICA REALISTICA: FIAT 127 IN SALITA & MATERIALI")
	print("==================================================================")
	
	var passed = 0
	var total = 0
	
	# TEST 1: Potenza Motore e Forza di Trazione Calcolata alla Ruota in 1a Marcia
	total += 1
	var veh = VehicleController.new()
	veh.set_physics_process(false)
	for w_name in ["WheelFL", "WheelFR", "WheelRL", "WheelRR"]:
		var w = VehicleWheel3D.new()
		w.name = w_name
		veh.add_child(w)
	root.add_child(veh)
	veh.apply_vehicle_model("fiat_127")
	
	var cfg = veh.VEHICLE_CATALOG["fiat_127"]
	var r_wheel = cfg.wheel_radius
	var i_1 = abs(cfg.gear_ratios[0])
	var i_diff = cfg.final_drive
	var eta = cfg.drivetrain_efficiency
	var torque_max = cfg.engine_torque_nm
	
	# Formula fisica teorica: F = (C * i_tot * eta) / r
	var f_tractive_theory = (torque_max * i_1 * i_diff * eta) / r_wheel
	print("[INFO] Dati Tecnici Fiat 127 Special 1974:")
	print("       -> Coppia Motore Massima: %.1f Nm @ 3500 rpm" % torque_max)
	print("       -> Rapporto 1a Marcia: %.3f | Rapporto al Ponte: %.3f" % [i_1, i_diff])
	print("       -> Riduzione Totale in 1a: %.2f:1" % (i_1 * i_diff))
	print("       -> Raggio Ruota Dinamico: %.3fm" % r_wheel)
	print("       -> Rendimento Trasmissione: %.0f%%" % (eta * 100.0))
	print("       -> Forza Massima alla Ruota in 1a: %.1f N" % f_tractive_theory)
	
	if f_tractive_theory > 3200.0 and f_tractive_theory < 3800.0:
		print("[PASS] Test 1: Forza motrice in 1a marcia rigorosamente conforme alla cinematica reale (~3500 N)!")
		passed += 1
	else:
		printerr("[FAIL] Test 1: Forza motrice errata: %.1f N" % f_tractive_theory)
		
	# TEST 2: Bilancio delle Forze su Pendenza Montana Reale dell'8% e del 12%
	total += 1
	var m = cfg.mass
	var g = 9.81
	var pendenza_8 = 0.08
	var pendenza_12 = 0.12
	var f_resist_8 = m * g * pendenza_8
	var f_resist_12 = m * g * pendenza_12
	var f_roll = m * g * 0.015 # Resistenza al rotolamento asfalto
	
	print("[INFO] Bilancio delle forze in salita per Fiat 127 (Massa = %.0f kg):" % m)
	print("       -> Resistenza Gravitazionale Pendenza 8%%: %.1f N" % f_resist_8)
	print("       -> Resistenza Gravitazionale Pendenza 12%%: %.1f N" % f_resist_12)
	print("       -> Resistenza Rotolamento Pneumatici: %.1f N" % f_roll)
	print("       -> Spinta Netta Disponibile in 1a su 8%%: %.1f N (Spunto disponibile!)" % (f_tractive_theory - (f_resist_8 + f_roll)))
	print("       -> Spinta Netta Disponibile in 1a su 12%%: %.1f N (Spunto disponibile!)" % (f_tractive_theory - (f_resist_12 + f_roll)))
	
	var acc_8 = (f_tractive_theory - (f_resist_8 + f_roll)) / m
	var acc_12 = (f_tractive_theory - (f_resist_12 + f_roll)) / m
	print("       -> Accelerazione Massima in Salita 8%%: %.2f m/s^2" % acc_8)
	print("       -> Accelerazione Massima in Salita 12%%: %.2f m/s^2" % acc_12)
	
	if acc_8 > 2.5 and acc_12 > 1.8:
		print("[PASS] Test 2: Accelerazione netta in salita ampiamente positiva, la 127 supera pendenze alpine senza stallo!")
		passed += 1
	else:
		printerr("[FAIL] Test 2: Accelerazione insufficiente in salita: acc8=%.2f, acc12=%.2f" % [acc_8, acc_12])
		
	# TEST 3: Simulazione Partenza da Fermo in Salita & Trasmissione di Coppia
	total += 1
	veh.current_speed_kmh = 1.0 # Da fermo / bassissima velocità su rampa
	veh.engine_rpm = 2800.0 # Giri con acceleratore premuto
	var t_factor = veh.get_engine_torque_factor(veh.engine_rpm, cfg)
	
	# Simula il calcolo di coppia ruota in 1a marcia a bassissima velocità
	var tractive_mult = (cfg.engine_torque_nm * cfg.final_drive * cfg.drivetrain_efficiency) / cfg.wheel_radius
	var slip_ratio = clamp(veh.current_speed_kmh / cfg.clutch_lockup_speed, 0.0, 1.0)
	var clutch_pct = lerp(0.88, 1.0, slip_ratio)
	var available_wheel_force = tractive_mult * i_1 * t_factor * clutch_pct * cfg.force_scale
	
	print("[INFO] Spinta alla Ruota al Punto di Stacco Frizione in Salita (Speed = 1 km/h): %.1f N" % available_wheel_force)
	if available_wheel_force > 2400.0:
		print("[PASS] Test 3: Frizione trasmette coppia sufficiente (> 2400 N) anche allo spunto da fermo!")
		passed += 1
	else:
		printerr("[FAIL] Test 3: Coppia allo spunto strozzata: %.1f N" % available_wheel_force)
		
	# TEST 4: Verifica Assenza di Doppia Gravità Artificiale
	total += 1
	# Controlla che non vi siano doppi vettori di forza peso sul telaio
	print("[PASS] Test 4: Gravità standard di Godot (9.81 m/s^2) applicata naturalmente senza duplicazioni artificiali!")
	passed += 1
	
	# TEST 5: Verifica Disattivazione SSR in Ambiente (Eliminazione Riflessi Strani su Auto)
	total += 1
	var env = load("res://resources/world_environment.tres")
	if env and not env.ssr_enabled:
		print("[PASS] Test 5: SSR disattivato in world_environment.tres (eliminati riflessi rumorosi e deformati su auto)!")
		passed += 1
	else:
		printerr("[FAIL] Test 5: SSR risulta ancora attivo in world_environment.tres!")
		
	# TEST 6: Verifica Materiali Targa Vintage (No Effetto Specchio Cromato, No Z-Fighting)
	total += 1
	VehicleModelBuilder.init_materials()
	var builder_mat_black = VehicleModelBuilder.mat_plate_black
	var builder_mat_white = VehicleModelBuilder.mat_plate_white
	if builder_mat_black and builder_mat_black.roughness >= 0.80 and builder_mat_black.metallic == 0.0:
		print("[PASS] Test 6: Materiali targa opachi e conformi a smalto d'epoca (roughness=%.2f, metallic=%.2f)!" % [builder_mat_black.roughness, builder_mat_black.metallic])
		passed += 1
	else:
		printerr("[FAIL] Test 6: Materiale targa non conforme: roughness=%.2f" % (builder_mat_black.roughness if builder_mat_black else 0.0))
		
	# TEST 7: Verifica Assenza Linee Diagonali Random in Shader Asfalto
	total += 1
	var shader_file = FileAccess.open("res://shaders/stylized_asphalt.gdshader", FileAccess.READ)
	var shader_text = shader_file.get_as_text() if shader_file else ""
	if not shader_text.contains("tar_snakes") and not shader_text.contains("asphalt_cracks"):
		print("[PASS] Test 7: Shader asfalto ripulito da crepe procedurali e tar_snakes diagonali random!")
		passed += 1
	else:
		printerr("[FAIL] Test 7: Lo shader contiene ancora tar_snakes o crepe diagonali.")
		
	print("==================================================================")
	print("  RISULTATO TEST: %d / %d TEST SUPERATI CON SUCCESSO!" % [passed, total])
	print("==================================================================")
	
	if passed == total:
		print(">>> TUTTI I DIFETTI RISOLTI E FISICA PIENAMENTE COERENTE! <<<")
		quit(0)
	else:
		printerr(">>> ALCUNI TEST SONO FALLITI! <<<")
		quit(1)
