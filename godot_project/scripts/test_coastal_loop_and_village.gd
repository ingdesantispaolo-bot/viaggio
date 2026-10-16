extends SceneTree

# Automated Verification & Screenshot Test for Coastal Riviera Loop & Borgo Marina
func _init():
	print("================================================================================")
	print("🧪 TEST EXPANSION: CIRCUITO COSTIERO 12.0 KM & BORGO MARINA DEI PESCATORI")
	print("================================================================================")
	
	# 1. Test BiomeGraph Segments
	var BiomeGraphClass = load("res://scripts/BiomeGraph.gd")
	var bg = BiomeGraphClass.new(1991)
	print("1. Verifica BiomeGraph Segments (Totale segmenti: %d)..." % bg.segments.size())
	assert(bg.segments.size() >= 10, "Devono esserci almeno 10 segmenti fino a 12000m!")
	
	var b_mountain = bg.get_biome_at(7200.0)
	print("   Z = 7200m Biome: %s" % b_mountain.get("name", ""))
	assert(b_mountain.get("name") == "GIRO DEL MASSICCIO & BALZE PANORAMICHE", "Z=7200m deve essere il Giro del Massiccio!")
	
	var b_costiera = bg.get_biome_at(8500.0)
	print("   Z = 8500m Biome: %s" % b_costiera.get("name", ""))
	assert(b_costiera.get("name") == "COSTIERA DELLE SIRENE & AFFACCI SUL MARE", "Z=8500m deve essere la Costiera delle Sirene!")
	
	var b_village = bg.get_biome_at(10000.0)
	print("   Z = 10000m Biome: %s" % b_village.get("name", ""))
	assert(b_village.get("name") == "BORGO MARINA DEI PESCATORI & PORTO", "Z=10000m deve essere Borgo Marina!")
	
	var b_gate = bg.get_biome_at(11500.0)
	print("   Z = 11500m Biome: %s" % b_gate.get("name", ""))
	assert(b_gate.get("name") == "VIALE DEGLI OLEANDRI & PORTA MARINA (CIRCUITO)", "Z=11500m deve essere il Viale degli Oleandri!")
	print("   ✅ BiomeGraph: 100% Corretto!")

	# 2. Test RoadGenerator Altimetry & Continuity to 12000m
	var RoadGenClass = load("res://scripts/RoadGenerator.gd")
	var rg = RoadGenClass.new()
	root.add_child(rg)
	
	print("\n2. Verifica Continuità Altimetrica C1 (Hermite) & Ritorno a Quota 0m...")
	var test_alt_z = [0.0, 80.0, 1380.0, 3240.0, 6000.0, 6800.0, 8200.0, 8700.0, 9600.0, 10200.0, 11700.0, 12000.0]
	for tz in test_alt_z:
		var alt = rg.calculate_road_elevation(tz)
		print("   Quota stradale a Z = %6.0fm: %6.2fm" % [tz, alt])
	
	var y_start = rg.calculate_road_elevation(0.0)
	var y_end = rg.calculate_road_elevation(12000.0)
	print("   Dislivello tra Partenza (Z=0) e Arrivo (Z=12000m): %.4f mm" % [abs(y_end - y_start) * 1000.0])
	assert(abs(y_end - y_start) < 0.001, "La quota a 12000m deve essere identica a 0m (0.000 mm)!")
	print("   ✅ Quota stradale perfettamente raccordata a quota 0m!")

	# 3. Test Generazione Chunk fino a 12000m
	print("\n3. Generazione e streaming chunk fino a 12000m...")
	rg.ensure_chunks_generated_up_to(12120.0)
	print("   Chunk attivi generati: %d (da Z=%.0f a Z=%.0f)" % [
		rg.active_chunks.size(),
		rg.active_chunks[0].start_z,
		rg.active_chunks[rg.active_chunks.size() - 1].end_z
	])
	assert(rg.active_chunks[rg.active_chunks.size() - 1].end_z >= 12000.0, "La generazione deve coprire l'intero anello a 12000m!")

	# 4. Verifica Assenza di Ostacoli e Barriere sulla Carreggiata (Zero Collision Errors)
	print("\n4. Verifica Sicurezza Carreggiata & Posizionamento Dettagli...")
	var found_sea_plane = false
	var found_lighthouse = false
	var found_belvedere = false
	var found_church = false
	var found_harbor_quay = false
	var found_city_gate = false
	var min_lateral_clearance_found = 999.0
	
	# Scandaglia i nodi generati
	for chunk in rg.active_chunks:
		var c_node = chunk.node
		if chunk.start_z >= 7800.0:
			for child in c_node.get_children():
				var cname = str(child.name).to_lower()
				if "seawaterplane" in cname:
					found_sea_plane = true
				if "lighthouse" in cname or child.has_node("OmniLight3D"):
					found_lighthouse = true
				if "belvedere" in cname:
					found_belvedere = true
				if "church" in cname or "pieve" in cname or "seachurch" in cname:
					found_church = true
				if "quay" in cname or "harbor" in cname:
					found_harbor_quay = true
				if "gate" in cname or "monumentalcitygate" in cname:
					found_city_gate = true
				for sub in child.get_children():
					var sname = str(sub.name).to_lower()
					if "lighthouse" in sname or sub.has_node("OmniLight3D"):
						found_lighthouse = true
					if "belvedere" in sname:
						found_belvedere = true
					if "church" in sname or "pieve" in sname:
						found_church = true
					if "quay" in sname or "boat" in sname:
						found_harbor_quay = true
					if "gate" in sname or "attico" in sname:
						found_city_gate = true

	# Verifica se la vecchia barriera a Z=5400m è sparita
	var found_5400_barrier = false
	for chunk in rg.active_chunks:
		if chunk.start_z >= 5400.0 and chunk.start_z < 5520.0:
			if chunk.node.has_node("SummitClosureBarrier"):
				found_5400_barrier = true
				break
	print("   Presenza vecchia barriera New Jersey al Valico (Z=5400m): %s" % ("SI (ERRORE!)" if found_5400_barrier else "NO (ELIMINATA! Strada libera!)"))
	assert(not found_5400_barrier, "La barriera di sbarramento a 5400m deve essere rimossa per permettere il transito!")

	print("   Piano Mare con Onde: %s" % ("TROVATO ✅" if found_sea_plane else "NON TROVATO ❌"))
	print("   Belvederi Panoramici: %s" % ("TROVATI ✅" if found_belvedere else "NON TROVATI ❌"))
	print("   Faro della Scogliera: %s" % ("TROVATO ✅" if found_lighthouse else "NON TROVATO ❌"))
	print("   Borgo Marina & Banchina Gozzi: %s" % ("TROVATO ✅" if found_harbor_quay else "NON TROVATO ❌"))
	print("   Pieve di Santa Maria del Mare: %s" % ("TROVATA ✅" if found_church else "NON TROVATA ❌"))
	print("   Porta Marina di San Cristoforo: %s" % ("TROVATA ✅" if found_city_gate else "NON TROVATA ❌"))
	
	assert(found_sea_plane, "Il piano d'acqua marino deve essere generato!")
	assert(found_belvedere, "I belvederi sul mare devono essere generati!")
	assert(found_lighthouse, "Il faro deve essere generato!")
	assert(found_harbor_quay, "La banchina con gozzi deve essere generata!")
	assert(found_church, "La chiesa sul mare deve essere generata!")
	assert(found_city_gate, "La Porta Marina deve essere generata!")

	# 5. Test Circuit Lap Reset logic
	print("\n5. Test Chiusura Anello & Wrap Circuito...")
	var pre_count = rg.active_chunks.size()
	rg.on_circuit_lap_completed()
	var post_count = rg.active_chunks.size()
	print("   Chunk prima del reset lap: %d | Chunk dopo il reset lap: %d" % [pre_count, post_count])
	assert(post_count < pre_count, "I chunk oltre 540m devono essere ripuliti per riprendere il giro!")
	assert(rg.next_chunk_z == 540.0, "next_chunk_z deve resettarsi a 540m!")
	print("   ✅ Reset circuito a 12000m perfettamente funzionante!")

	print("\n================================================================================")
	print("🎉 TUTTI I TEST DEL CIRCUITO COSTIERO E BORGO MARINA SUPERATI CON SUCCESSO! (EXIT 0)")
	print("================================================================================")
	quit(0)

