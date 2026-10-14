extends SceneTree

func _init():
	print("\n==================================================================")
	print("  TEST DECELERAZIONE E RITORNO AL REGIME DI MINIMO (AUDIO & RPM)")
	print("==================================================================")
	
	var packed_vehicle = load("res://scenes/Vehicle.tscn")
	var vehicle = packed_vehicle.instantiate()
	root.add_child(vehicle)
	
	var audio = vehicle.get_node_or_null("VehicleAudio")
	assert(audio != null, "VehicleAudio deve essere presente in Vehicle.tscn")
	if not audio.engine_player:
		audio._ready()
	vehicle.audio_engine = audio
	vehicle.apply_vehicle_model("fiat_127")
	vehicle.set_engine_running(true)
	audio.set_engine_running(true)
	audio.set_sound_profile("fiat_127")
	
	var cfg = vehicle.VEHICLE_CATALOG["fiat_127"]
	var dt = 0.02 # 50 Hz physics
	
	print("\n[FASE 1] Avvio da fermo (Standstill Idle):")
	for i in range(15):
		vehicle.linear_velocity = Vector3.ZERO
		var spd_ms = vehicle.linear_velocity.length()
		if spd_ms < 0.05: spd_ms = 0.0
		vehicle.current_speed_kmh = spd_ms * 3.6
		vehicle.update_transmission(0.0, 0.0, spd_ms, dt, cfg)
		audio._process(dt)
		
	var idle_rpm = vehicle.engine_rpm
	var idle_pitch = audio.engine_player.pitch_scale
	print("  -> Spd: %.1f km/h | Gear: %s | RPM: %.1f | Pitch: %.3f" % [vehicle.current_speed_kmh, vehicle.gear_name, idle_rpm, idle_pitch])
	assert(abs(idle_rpm - 850.0) < 50.0, "RPM al minimo deve essere ~850")
	assert(abs(idle_pitch - (850.0 / 1200.0)) < 0.05, "Pitch al minimo deve essere ~0.708")
	
	print("\n[FASE 2] Accelerazione piena (Full Throttle Pull fino a 80 km/h):")
	var sim_speed = 0.0
	for step in range(120): # 2.4 secondi
		sim_speed = min(80.0, sim_speed + 0.75)
		vehicle.linear_velocity = Vector3(0, 0, -sim_speed / 3.6)
		var spd_ms = vehicle.linear_velocity.length()
		vehicle.current_speed_kmh = spd_ms * 3.6
		vehicle.update_transmission(1.0, 0.0, spd_ms, dt, cfg)
		audio._process(dt)
		
	var top_spd = vehicle.current_speed_kmh
	var top_rpm = vehicle.engine_rpm
	var top_pitch = audio.engine_player.pitch_scale
	var top_gear = vehicle.gear_name
	print("  -> Spd: %.1f km/h | Gear: %s | RPM: %.1f | Pitch: %.3f" % [top_spd, top_gear, top_rpm, top_pitch])
	assert(top_rpm > 3500.0, "RPM ad alta velocità deve essere elevato")
	assert(top_pitch > 2.8, "Pitch ad alta velocità deve essere elevato")
	
	print("\n[FASE 3] Frenata brusca fino all'arresto (Hard Braking to 0 km/h):")
	for step in range(80): # 1.6 secondi
		sim_speed = max(0.0, sim_speed - 1.2)
		vehicle.linear_velocity = Vector3(0, 0, -sim_speed / 3.6)
		var spd_ms = vehicle.linear_velocity.length()
		if spd_ms < 0.05:
			spd_ms = 0.0
		vehicle.current_speed_kmh = spd_ms * 3.6
		
		vehicle.update_transmission(0.0, 1.0, spd_ms, dt, cfg)
		audio._process(dt)
		if step % 20 == 0:
			print("  [t=%.2fs] Spd: %.1f km/h | Gear: %s | RPM: %.1f | Pitch: %.3f" % [step * dt, vehicle.current_speed_kmh, vehicle.gear_name, vehicle.engine_rpm, audio.engine_player.pitch_scale])

	print("\n[FASE 4] Stabilizzazione a veicolo fermo (Standstill Settle):")
	for step in range(40):
		vehicle.linear_velocity = Vector3.ZERO
		var spd_ms = 0.0
		vehicle.current_speed_kmh = 0.0
		vehicle.update_transmission(0.0, 0.0, spd_ms, dt, cfg)
		audio._process(dt)
		
	var end_spd = vehicle.current_speed_kmh
	var end_rpm = vehicle.engine_rpm
	var end_pitch = audio.engine_player.pitch_scale
	var end_gear = vehicle.gear_name
	print("  -> Finale: Spd: %.1f km/h | Gear: %s | RPM: %.1f | Pitch: %.3f" % [end_spd, end_gear, end_rpm, end_pitch])
	
	print("\n--- RISULTATO DEI CONTROLLI ---")
	print("1. Velocita' tornata a 0.0 km/h: ", end_spd == 0.0)
	print("2. Giri motore tornati al minimo (850 RPM): ", abs(end_rpm - 850.0) < 5.0, " (RPM = %.1f)" % end_rpm)
	print("3. Tono audio tornato al minimo (Pitch = 0.708): ", abs(end_pitch - 0.708) < 0.02, " (Pitch = %.3f)" % end_pitch)
	print("4. Cambio scalato automaticamente in 1ª marcia: ", end_gear in ["1a", "D1"])
	
	if end_spd == 0.0 and abs(end_rpm - 850.0) < 5.0 and abs(end_pitch - 0.708) < 0.02 and (end_gear in ["1a", "D1"]):
		print("\n[PASS] SUCCESSO! Il regime e il tono del suono tornano perfettamente al minimo quando la macchina si ferma!")
	else:
		printerr("\n[FAIL] Errore nei controlli di decelerazione!")
		quit(1)
		return
		
	quit(0)
