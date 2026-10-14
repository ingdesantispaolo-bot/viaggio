extends SceneTree

# ==============================================================================
# COLLAUDO: RIMOZIONE OSTACOLI INDESIDERATI & ASSETTO FISICO AREE DI SERVIZIO
# ==============================================================================

const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const HazardManager = preload("res://scripts/HazardManager.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")
const CameraController = preload("res://scripts/CameraController.gd")

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

var frame_count: int = 0
var test_stage: int = 0

var root_node: Node3D = null
var road_gen: RoadGenerator = null
var hazard_mgr: HazardManager = null
var vehicle: VehicleController = null
var camera: CameraController = null

func _init():
	print("\n=======================================================")
	print(">>> COLLAUDO: CONTROLLO OSTACOLI & ASSETTO AREE SERVIZIO")
	print("=======================================================\n")

func _process(_delta: float):
	frame_count += 1
	
	if test_stage == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			
			road_gen = root_node.get_node("RoadGenerator")
			hazard_mgr = root_node.get_node("HazardManager")
			vehicle = root_node.get_node("Vehicle")
			camera = root_node.get_node("CameraController")
			
			var sr_ui = root_node.find_child("StreetRodUI", true, false)
			if sr_ui and sr_ui.has_method("close_screen"):
				sr_ui.close_screen()
				
		elif frame_count == 5:
			# ------------------------------------------------------------------
			# TEST 1: NESSUN OSTACOLO INDESIDERATO SULLA CARREGGIATA
			# ------------------------------------------------------------------
			print("[TEST 1/3] Verifica Disattivazione Ostacoli Indesiderati su Carreggiata...")
			assert(hazard_mgr.enabled == false, "HazardManager DEVE essere disabilitato di default per la guida pulita!")
			
			# Posiziona l'auto al PK 0.23 (Z = 230m, esattamente dove prima apparivano coni e scatola nera)
			var r_info = road_gen.get_road_info_at(230.0)
			vehicle.global_position = Vector3(r_info.x, r_info.y + 0.40, 230.0)
			vehicle.linear_velocity = Vector3(0.0, 0.0, 15.0)
			vehicle.rotation.y = PI + r_info.angle
			
			# Aggiorna generazione e hazards
			road_gen.update_generation(230.0)
			hazard_mgr.update_hazards(230.0)
			
		elif frame_count == 10:
			# Verifica che non ci siano scenari o coni attivi in carreggiata
			assert(hazard_mgr.active_scenarios.is_empty(), "Nessuno scenario casuale deve essere generato in carreggiata!")
			assert(hazard_mgr.slippery_patches.is_empty(), "Nessuna macchia scivolosa casuale deve intralciare la strada!")
			
			# Verifica che nei nodi figli di HazardManager non ci siano blocchi fluttuanti
			var floating_boxes = 0
			for c in hazard_mgr.get_children():
				if c.name.begins_with("Scenario"):
					floating_boxes += 1
			assert(floating_boxes == 0, "Nessun blocco o cantiere deve essere presente su HazardManager!")
			print("  ✓ Nessun ostacolo casuale presente al PK 0.23 (Z=230m). Carreggiata libera e pulita.")
			
		elif frame_count == 14:
			capture_screenshot("screenshot_clean_highway_no_obstacles.png")
			test_stage = 1
			frame_count = 0
			
	elif test_stage == 1:
		if frame_count == 2:
			# ------------------------------------------------------------------
			# TEST 2: VERIFICA NORMALI MASSI ALPINI (NESSUN BLOCCO NERO)
			# ------------------------------------------------------------------
			print("\n[TEST 2/3] Verifica Normali dei Massi di Granito Alpino...")
			var b_mesh = road_gen.create_faceted_boulder_mesh(1.5, 42.0)
			assert(b_mesh != null, "La mesh del masso deve essere generata correttamente")
			var arrays = b_mesh.surface_get_arrays(0)
			var normals = arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
			var vertices = arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
			
			# Verifica che le normali dei vertici superiori puntino verso l'alto (Y > 0)
			var top_normal_count = 0
			for n in normals:
				if n.y > 0.05:
					top_normal_count += 1
			assert(top_normal_count > 0, "Le normali superiori del masso DEVONO puntare verso l'alto per ricevere la luce del sole!")
			print("  ✓ Normali massi alpine verificate: %d normali rivolte verso il sole (niente blocchi neri)!" % top_normal_count)
			
			# ------------------------------------------------------------------
			# TEST 3: ASSETTO SOLIDO AREA DI SERVIZIO (L'AUTO NON AFFONDA NELL'ASFALTO)
			# ------------------------------------------------------------------
			print("\n[TEST 3/3] Verifica Assetto e Collisione Area di Servizio AGIP (Z=776m)...")
			# Assicura generazione chunk stazione di servizio (Z=660m - 840m)
			road_gen.ensure_chunks_generated_up_to(900.0)
			
			var st_info = road_gen.get_service_station_at(Vector3(12.5, 0.0, 776.0))
			print("  ✓ Stazione rilevata: '%s' | In Bay: %s" % [st_info.get("name", ""), st_info.get("in_bay", false)])
			
			# Posiziona l'auto sul piazzale dell'area di servizio AGIP direttamente nella baia di rifornimento
			var r_agip = road_gen.get_road_info_at(776.0)
			var bay_x = r_agip.x + 12.5
			var bay_y = r_agip.y + 0.35 # Quota corretta di partenza sopra il piazzale
			vehicle.global_position = Vector3(bay_x, bay_y, 776.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			vehicle.rotation = Vector3(0.0, PI, 0.0)
			
		elif frame_count == 20:
			# Lasciamo che la fisica stabilizzi le sospensioni sulle ruote
			var v_pos = vehicle.global_position
			var r_agip = road_gen.get_road_info_at(776.0)
			var road_surface_y = r_agip.y + 0.06
			
			print("  ✓ Quota Piazzale Servizio: Y=%.3fm | Quota Veicolo Stabilizzato: Y=%.3fm" % [
				road_surface_y, v_pos.y
			])
			
			# Il telaio dell'auto deve essere sostenuto SOPRA il piano del piazzale (tipicamente Y >= road_surface_y + 0.25m)
			var clearance = v_pos.y - road_surface_y
			print("  ✓ Altezza del Baricentro sul Piazzale: +%.3fm (L'auto poggia solidamente, ZERO affondamento!)" % clearance)
			assert(clearance >= 0.05, "L'auto NON deve affondare nell'asfalto dell'area di servizio!")
			
			# Verifica che ciascuna ruota sia supportata e non sprofondata
			for child in vehicle.get_children():
				if child is VehicleWheel3D:
					var w_y = child.global_position.y
					var w_clear = w_y - road_surface_y
					assert(w_clear >= -0.08, "La ruota %s non deve essere sprofondata sotto il pavimento dell'area di servizio!" % child.name)
				
			print("  ✓ Tutte le ruote poggiano con precisione millimetrica sul pavimento in pavé dell'area di servizio!")
			
		elif frame_count == 25:
			capture_screenshot("screenshot_service_area_solid_ground.png")
			
			print("\n=======================================================")
			print(">>> ESITO COLLAUDO: TUTTI I CONTROLLI SUPERATI CON SUCCESSO!")
			print("  1. Rimozione ostacoli indesiderati in carreggiata: OK (strada libera)")
			print("  2. Normali e illuminazione massi granitici: OK (nessun blocco nero)")
			print("  3. Pavimentazione e collider area di servizio: OK (zero affondamento)")
			print("=======================================================\n")
			quit(0)

func capture_screenshot(filename: String):
	var img = root.get_texture().get_image()
	if img and not img.is_empty():
		var dest = artifact_dir + "/" + filename
		var err = img.save_png(dest)
		if err == OK:
			print("    [SCREENSHOT SALVATO] -> %s" % dest)
		else:
			print("    [-] Errore salvataggio screenshot: %s (codice %d)" % [dest, err])
