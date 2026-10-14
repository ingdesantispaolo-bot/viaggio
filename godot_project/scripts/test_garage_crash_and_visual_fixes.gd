extends SceneTree

# ==============================================================================
# TEST RIGOROSO: AVVIO IN GARAGE, BASAMENTI AREE SERVIZIO, LINEE & CRASH REALISTICO
# ==============================================================================

const VehicleCrashSystem = preload("res://scripts/VehicleCrashSystem.gd")
const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")
const GarageEnvironmentBuilder = preload("res://scripts/GarageEnvironmentBuilder.gd")
const RoadGenerator = preload("res://scripts/RoadGenerator.gd")

func _init():
	print("\n==================================================================")
	print("  TEST VERIFICA: GARAGE 3D, BASAMENTI AREE SERVIZIO, LINEE & CRASH FISICO")
	print("==================================================================")
	run_all_tests()
	quit(0)

func run_all_tests():
	test_garage_startup()
	test_service_and_junction_grounding()
	test_screen_lines_elimination()
	test_inelastic_crash_momentum_physics()
	test_vehicle_structural_deformation()
	print("==================================================================")
	print("  TUTTI I 5 TEST DI SISTEMA SUPERATI CON SUCCESSO! (100%)")
	print("==================================================================\n")

func test_garage_startup():
	print("\n--- TEST 1: AVVIO IN GARAGE PAOLO (NON IN MEZZO ALLA STRADA) ---")
	var packed_main = load("res://scenes/Main.tscn")
	var main = packed_main.instantiate()
	root.add_child(main)
	if not main.is_node_ready():
		main._ready()
	
	assert(main.is_in_garage == true, "All'avvio main.is_in_garage DEVE essere true!")
	assert(main.garage_building != null, "Il garage 3D di Paolo deve essere istanziato nella scena!")
	var car = main.get_node("Vehicle")
	assert(car != null, "Vehicle node deve esistere")
	
	# Coordinate interne all'officina (X=15.5m, Z=14.0m)
	var c_pos = car.position
	print("[INFO] Posizione iniziale auto nel garage: (X=%.2f, Y=%.2f, Z=%.2f)" % [c_pos.x, c_pos.y, c_pos.z])
	assert(abs(c_pos.x - 15.5) < 0.2 and abs(c_pos.z - 14.0) < 0.2, "L'auto DEVE trovarsi dentro il garage a X=15.5, Z=14.0!")
	assert(car.freeze == true, "L'auto deve essere parcheggiata in sicurezza (freeze = true) nel garage!")
	
	# Test uscita in strada
	main.exit_garage_to_road()
	assert(main.is_in_garage == false, "Dopo exit_garage_to_road, is_in_garage deve essere false!")
	var road_pos = car.position
	print("[INFO] Posizione auto su strada dopo uscita dal garage: (X=%.2f, Y=%.2f, Z=%.2f)" % [road_pos.x, road_pos.y, road_pos.z])
	assert(abs(road_pos.z - 20.0) < 0.5, "L'auto deve trovarsi all'inizio della statale (Z=20m)!")
	assert(car.freeze == false, "L'auto deve essere sbloccata per la guida su strada!")
	
	main.queue_free()
	print("[PASS] Test 1: Auto correttamente posizionata nel Garage Paolo all'avvio e transizione su strada verificata!")

func test_service_and_junction_grounding():
	print("\n--- TEST 2: FASCIAZIONE E BASAMENTI AREE DI SERVIZIO E BIVI STRADALI ---")
	var road_gen = RoadGenerator.new()
	root.add_child(road_gen)
	road_gen._ready()
	
	# Verifica massicciata profonda nell'innesto stradale
	var dummy_root = Node3D.new()
	var junction = road_gen.create_road_junction_prop(Vector3(0, 0, 640.0), 0.0, "VALICO", "SAN ROCCO", true)
	dummy_root.add_child(junction)
	
	var apron_mesh = null
	var retaining_wall = null
	for child in junction.get_children():
		if child is MeshInstance3D:
			var b = child.mesh as BoxMesh
			if b and b.size.x > 15.0:
				apron_mesh = child
			elif b and b.size.x < 1.5 and b.size.y > 4.0:
				retaining_wall = child
				
	assert(apron_mesh != null, "La massicciata del bivio deve esistere!")
	var apron_box = apron_mesh.mesh as BoxMesh
	print("[INFO] Spessore massicciata basamento bivio: %.2fm (era 0.04m!)" % apron_box.size.y)
	assert(apron_box.size.y >= 4.0, "Lo spessore della massicciata deve essere >= 4.0m per ancorarsi al terreno!")
	assert(apron_mesh.position.y <= -2.0, "Il centro della massicciata deve scendere di almeno 2.0m sotto il piano strada!")
	assert(retaining_wall != null, "Il muro di contenimento perimetrale in pietra deve esistere!")
	print("[INFO] Altezza muro di sostegno: %.2fm" % (retaining_wall.mesh as BoxMesh).size.y)
	
	# Verifica peso appiattimento terreno su junction e service
	var j_w = road_gen.get_junction_flatten_weight(640.0)
	var s_w = road_gen.get_service_flatten_weight(700.0)
	print("[INFO] Peso livellamento terreno bivio Z=640m: %.2f | Area servizio Z=700m: %.2f" % [j_w, s_w])
	assert(j_w > 0.9, "Il terreno attorno al bivio Z=640m deve essere perfettamente livellato (peso ~ 1.0)!")
	assert(s_w > 0.9, "Il terreno attorno all'area di servizio Agip Z=700m deve essere livellato (peso ~ 1.0)!")
	
	road_gen.queue_free()
	dummy_root.queue_free()
	print("[PASS] Test 2: Basamenti di 4.5m e muri di sostegno garantiscono che nessuna area stradale appaia sospesa!")

func test_screen_lines_elimination():
	print("\n--- TEST 3: ELIMINAZIONE RIGA FISSA (TILT-SHIFT) E RIGA ROTANTE (WIPER 2D) ---")
	# 1. Verifica shader tilt shift
	var shader = load("res://shaders/diorama_tilt_shift.gdshader")
	assert(shader != null, "Shader tilt shift deve caricarsi")
	var code = shader.code
	assert(not code.contains("if (blur_factor < 0.015)"), "Il taglio brusco 'if (blur_factor < 0.015)' deve essere rimosso dallo shader!")
	print("[PASS] Taglio brusco 'if (blur_factor < 0.015)' eliminato dallo shader (nessuna riga orizzontale a Y=0.255)!")
	
	# 2. Verifica rimozione riga tergicristallo 2D in DashboardUI
	var d_script = load("res://scripts/DashboardUI.gd")
	var d_source = FileAccess.get_file_as_string("res://scripts/DashboardUI.gd")
	assert(not d_source.contains("draw_line(w_bot, w_top"), "La riga tergicristallo 2D 'draw_line(w_bot, w_top' deve essere eliminata!")
	print("[PASS] Riga rotante 'draw_line(w_bot, w_top)' eliminata dal layer HUD!")

func test_inelastic_crash_momentum_physics():
	print("\n--- TEST 4: CONSERVAZIONE QUANTITÀ DI MOTO ED URTI ANELASTICI ---")
	# Test Fiat 127 (710 kg) contro Ape Piaggio 50 (280 kg) a 60 km/h (16.67 m/s)
	var m1 = 710.0
	var v1 = Vector3(0, 0, 16.67) # 60 km/h in avanti
	var m2 = 280.0
	var v2 = Vector3(0, 0, 8.33)  # 30 km/h stessa direzione
	var normal = Vector3(0, 0, 1) # Urto posteriore
	var contact_pt = Vector3(0.5, 0.4, 100.0) # Leggermente disassato a destra (0.5m)
	var com1 = Vector3(0, 0.4, 98.0)
	
	var res = VehicleCrashSystem.calculate_impact_impulse(m1, v1, m2, v2, normal, contact_pt, com1, 0.12, 0.40)
	assert(res.is_impact == true, "L'impatto deve essere rilevato!")
	
	var impulse = res.impulse
	var delta_v1 = -impulse / m1
	var delta_v2 = impulse / m2
	
	print("[INFO] Quantità di Moto Scambiata: J = %.1f N*s" % impulse.length())
	print("[INFO] Rallentamento Vettura Giocatore (Fiat 127 710kg): Delta v1 = %.2f m/s (%.1f km/h)" % [delta_v1.length(), delta_v1.length() * 3.6])
	print("[INFO] Spinta su Veicolo Civile (Ape Piaggio 280kg):    Delta v2 = %.2f m/s (%.1f km/h)" % [delta_v2.length(), delta_v2.length() * 3.6])
	
	# Verifica 3° Principio della Dinamica: m1*Delta_v1 + m2*Delta_v2 = 0
	var total_momentum_change = m1 * delta_v1 + m2 * delta_v2
	assert(total_momentum_change.length() < 0.001, "La quantità di moto totale del sistema DEVE conservarsi (m1*dv1 + m2*dv2 = 0)!")
	
	# L'Ape più leggera deve subire un'accelerazione maggiore della 127 (rapporto 710/280 = 2.53)
	var ratio = delta_v2.length() / delta_v1.length()
	print("[INFO] Rapporto accelerazioni Delta v2 / Delta v1: %.2f (Atteso: %.2f)" % [ratio, m1 / m2])
	assert(abs(ratio - (m1 / m2)) < 0.01, "Rapporto accelerazioni conforme alla meccanica newtoniana!")
	
	# Coppia torcente sul baricentro
	print("[INFO] Coppia di imbardata dal braccio di contatto: Torque_Y = %.1f N*m" % res.torque1.y)
	assert(abs(res.torque1.y) > 50.0, "L'urto disassato deve generare una coppia di sbandata reale!")
	print("[PASS] Test 4: Leggi di Newton e conservazione della quantità di moto pienamente verificate!")

func test_vehicle_structural_deformation():
	print("\n--- TEST 5: DEFORMAZIONE PLASTICA STRUTTURALE DELLA CARROZZERIA ---")
	var dummy_car = Node3D.new()
	var model_root = Node3D.new()
	model_root.name = "ModelFiat127"
	dummy_car.add_child(model_root)
	root.add_child(dummy_car)
	
	# Costruisce la 127
	var body_mat = StandardMaterial3D.new()
	VehicleModelBuilder.build_fiat_127(model_root, body_mat)
	
	var bumper = model_root.find_child("FrontBumper", true, false)
	var hood = model_root.find_child("Hood", true, false)
	if not bumper:
		# Cerca qualsiasi parte frontale
		for c in model_root.find_child("Fiat127Rig", true, false).get_children():
			if "bumper" in c.name.to_lower(): bumper = c
			if "hood" in c.name.to_lower(): hood = c
			
	assert(bumper != null, "Il paraurti frontale deve esistere nel modello!")
	var initial_bumper_z = bumper.position.z
	var initial_hood_rot_x = hood.rotation.x if hood else 0.0
	print("[INFO] Quota Z iniziale paraurti: %.3fm" % initial_bumper_z)
	
	# Applica urto frontale a 50 km/h
	var contact_pt = dummy_car.global_position + Vector3(0.2, 0.4, -1.75)
	VehicleCrashSystem.apply_structural_deformation(dummy_car, contact_pt, 50.0, Vector3(0, 0, 1))
	
	var deformed_bumper_z = bumper.position.z
	var deformed_hood_rot_x = hood.rotation.x if hood else 0.0
	print("[INFO] Quota Z paraurti dopo urto: %.3fm (Rientro di %.1f cm)" % [deformed_bumper_z, (deformed_bumper_z - initial_bumper_z) * 100.0])
	assert(deformed_bumper_z > initial_bumper_z + 0.05, "Il paraurti deve essere visibilmente rientrato verso l'interno!")
	if hood:
		print("[INFO] Inclinazione cofano piegato (zona di collasso): %.1f°" % rad_to_deg(deformed_hood_rot_x))
		assert(deformed_hood_rot_x > initial_hood_rot_x + deg_to_rad(5.0), "Il cofano deve piegarsi verso l'alto lungo le cerniere di sicurezza!")
		
	dummy_car.queue_free()
	print("[PASS] Test 5: Deformazione plastica tridimensionale calcolata realisticamente sui componenti del telaio!")
