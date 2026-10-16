extends SceneTree

func _init():
	print("--- TEST PROCEDURALE: PIANURA AGRICOLA DEI PODERI & RETE STRADALE ---")
	
	# 1. Test BiomeGraph
	var BiomeGraphClass = load("res://scripts/BiomeGraph.gd")
	var bg = BiomeGraphClass.new(1991)
	var b_city = bg.get_biome_at(40.0)
	var b_plain = bg.get_biome_at(300.0)
	var b_agip = bg.get_biome_at(1450.0)
	print("[1] BiomeGraph: 40m -> %s" % b_city.get("name", "N/A"))
	print("    BiomeGraph: 300m -> %s (Type: %d)" % [b_plain.get("name", "N/A"), b_plain.get("type", -1)])
	print("    BiomeGraph: 1450m -> %s" % b_agip.get("name", "N/A"))
	assert(b_plain.get("type", -1) == 10, "Errore: Biome 300m non è AGRICULTURAL_PLAIN (10)")
	
	# 2. Test RuralPlainEnvironmentBuilder
	var RuralBuilder = load("res://scripts/RuralPlainEnvironmentBuilder.gd")
	var root = Node3D.new()
	
	# Bivio 1 & Cascina Corte San Giorgio (Z = 240)
	var dummy_pts1 = []
	for i in range(25):
		dummy_pts1.append({"x": 0.0, "y": 0.6, "z": 200.0 + i * 4.0, "width": 7.8, "angle": 0.0, "bank": 0.0})
	RuralBuilder.spawn_plain_chunk_features(root, dummy_pts1, 200.0)
	print("[2] Cascina Corte San Giorgio generata: %d nodi generati in root" % root.get_child_count())
	
	# Bivio 2 & Mulino con Ruscello (Z = 460)
	var dummy_pts2 = []
	for i in range(25):
		dummy_pts2.append({"x": 0.0, "y": 1.2, "z": 440.0 + i * 4.0, "width": 7.8, "angle": 0.0, "bank": 0.0})
	RuralBuilder.spawn_plain_chunk_features(root, dummy_pts2, 440.0)
	print("[3] Mulino ad Acqua & Ruscello Chiaro generati: %d nodi totali" % root.get_child_count())
	
	# Bivio 3 & Podere Belvedere (Z = 780)
	var dummy_pts3 = []
	for i in range(25):
		dummy_pts3.append({"x": 0.0, "y": 1.5, "z": 760.0 + i * 4.0, "width": 7.8, "angle": 0.0, "bank": 0.0})
	RuralBuilder.spawn_plain_chunk_features(root, dummy_pts3, 760.0)
	print("[4] Podere Belvedere & Vigneti generati: %d nodi totali" % root.get_child_count())
	
	# Bivio 4 & Lago dei Salici (Z = 1040)
	var dummy_pts4 = []
	for i in range(25):
		dummy_pts4.append({"x": 0.0, "y": 1.4, "z": 1000.0 + i * 4.0, "width": 7.8, "angle": 0.0, "bank": 0.0})
	RuralBuilder.spawn_plain_chunk_features(root, dummy_pts4, 1000.0)
	print("[5] Lago dei Salici & Pontile generati: %d nodi totali" % root.get_child_count())
	
	# 3. Test TopographicMapControl
	var MapClass = load("res://scripts/TopographicMapControl.gd")
	var map_ctrl = MapClass.new()
	print("[6] TopographicMapControl caricato con %d waypoints ufficiali" % map_ctrl.WAYPOINTS.size())
	assert(map_ctrl.WAYPOINTS.size() == 9, "Errore: TopographicMapControl deve avere 9 waypoints")
	
	print("\n>>> TUTTI I TEST DELLA PIANURA E DELLA RETE STRADALE SUPERATI CON SUCCESSO! <<<")
	quit(0)
