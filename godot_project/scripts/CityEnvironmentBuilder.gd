extends RefCounted
class_name CityEnvironmentBuilder

# ==============================================================================
# CITTÀ DI "SAN CRISTOFORO SUL MERIDIANO" - AAA RETRO DIORAMA CITY BUILDER
# ==============================================================================
# Ricostruzione architettonica completa e fedele all'artwork:
# 1. Tetti a falde spioventi (Gable roofs & Hipped roofs) con coppi in laterizio
# 2. Materiali procedurali shader per pietra, malta, tegole e lastricato
# 3. Finestre rientrate con davanzali in pietra, architravi e persiane a lamelle
# 4. Angolari in pietra a bugnato (quoins), cornicioni di gronda e comignoli
# 5. Campanile traforato con cella a bifore aperte, campana visibile e cuspide
# 6. Municipio con porticato ad archi, loggia, balcone tricolore e torre orologio
# 7. Piazza della Repubblica con lastricato a ventaglio, fontana monumentale e tigli
# 8. Negozi storici: Panetteria, Macelleria, Bar dello Sport, Poste e Carabinieri
# 9. Periferia residenziale: condomini anni '70/'80 e villette con giardino
# ==============================================================================

# Shaders and Materials Palette
static var mat_pave: ShaderMaterial
static var mat_terracotta_roof: ShaderMaterial
static var mat_slate_roof: ShaderMaterial
static var mat_church_stone: ShaderMaterial
static var mat_curb: StandardMaterial3D
static var mat_sidewalk: StandardMaterial3D
static var mat_plaster_ochre: StandardMaterial3D
static var mat_plaster_sienna: StandardMaterial3D
static var mat_plaster_terracotta: StandardMaterial3D
static var mat_plaster_olive: StandardMaterial3D
static var mat_plaster_cream: StandardMaterial3D
static var mat_concrete_suburb: StandardMaterial3D
static var mat_shutter_green: StandardMaterial3D
static var mat_shutter_brown: StandardMaterial3D
static var mat_window_glass: StandardMaterial3D
static var mat_window_glow: StandardMaterial3D
static var mat_iron_wrought: StandardMaterial3D
static var mat_awning_red: StandardMaterial3D
static var mat_awning_yellow: StandardMaterial3D
static var mat_awning_white: StandardMaterial3D
static var mat_brass_bell: StandardMaterial3D
static var mat_water: StandardMaterial3D
static var mat_carabinieri_blue: StandardMaterial3D
static var mat_carabinieri_white: StandardMaterial3D
static var mat_carabinieri_red: StandardMaterial3D
static var mat_poste_yellow: StandardMaterial3D
static var mat_sign_wood: StandardMaterial3D
static var mat_grass: StandardMaterial3D
static var mat_straw_bale: StandardMaterial3D

static func init_materials():
	if mat_curb != null: return
	
	var building_shader = load("res://shaders/stylized_building.gdshader")
	var pave_shader = load("res://shaders/stylized_pave.gdshader")
	
	# 1. Porphyry Cobblestone Piazza & Streets (Procedural Sanpietrini)
	mat_pave = ShaderMaterial.new()
	mat_pave.shader = pave_shader
	mat_pave.set_shader_parameter("porphyry_red", Color(0.48, 0.35, 0.30))
	mat_pave.set_shader_parameter("porphyry_grey", Color(0.36, 0.37, 0.39))
	mat_pave.set_shader_parameter("porphyry_ochre", Color(0.54, 0.48, 0.38))
	mat_pave.set_shader_parameter("mortar_color", Color(0.25, 0.23, 0.20))
	mat_pave.set_shader_parameter("granite_curb_color", Color(0.78, 0.79, 0.82))
	mat_pave.set_shader_parameter("block_scale", 16.0)
	
	# 2. Terracotta Barrel Tiles Roof (Coppi toscani con ombra e curva barrel)
	mat_terracotta_roof = ShaderMaterial.new()
	mat_terracotta_roof.shader = building_shader
	mat_terracotta_roof.set_shader_parameter("material_type", 2)
	mat_terracotta_roof.set_shader_parameter("base_color", Color(0.76, 0.40, 0.24))
	mat_terracotta_roof.set_shader_parameter("alt_color", Color(0.62, 0.30, 0.18))
	mat_terracotta_roof.set_shader_parameter("mortar_color", Color(0.35, 0.20, 0.12))
	mat_terracotta_roof.set_shader_parameter("texture_scale", 2.4)
	
	# 3. Slate Shingles Roof (Ardesia alpina per chiesa e campanile)
	mat_slate_roof = ShaderMaterial.new()
	mat_slate_roof.shader = building_shader
	mat_slate_roof.set_shader_parameter("material_type", 1)
	mat_slate_roof.set_shader_parameter("base_color", Color(0.32, 0.34, 0.38))
	mat_slate_roof.set_shader_parameter("alt_color", Color(0.22, 0.24, 0.26))
	mat_slate_roof.set_shader_parameter("mortar_color", Color(0.14, 0.15, 0.16))
	mat_slate_roof.set_shader_parameter("texture_scale", 1.8)
	
	# 4. Church Stone Masonry (Pietra scolpita con malta)
	mat_church_stone = ShaderMaterial.new()
	mat_church_stone.shader = building_shader
	mat_church_stone.set_shader_parameter("material_type", 0)
	mat_church_stone.set_shader_parameter("base_color", Color(0.74, 0.70, 0.64))
	mat_church_stone.set_shader_parameter("alt_color", Color(0.58, 0.54, 0.48))
	mat_church_stone.set_shader_parameter("mortar_color", Color(0.38, 0.34, 0.30))
	mat_church_stone.set_shader_parameter("texture_scale", 1.6)
	
	# 5. Sidewalks & Curbs
	mat_sidewalk = StandardMaterial3D.new()
	mat_sidewalk.albedo_color = Color(0.62, 0.60, 0.58)
	mat_sidewalk.roughness = 0.85
	
	mat_curb = StandardMaterial3D.new()
	mat_curb.albedo_color = Color(0.82, 0.83, 0.85)
	mat_curb.roughness = 0.75
	
	# 6. Historic Plaster Walls (Colori caldi italiani)
	mat_plaster_ochre = StandardMaterial3D.new()
	mat_plaster_ochre.albedo_color = Color(0.85, 0.70, 0.42) # Giallo ocra classico
	mat_plaster_ochre.roughness = 0.90
	
	mat_plaster_sienna = StandardMaterial3D.new()
	mat_plaster_sienna.albedo_color = Color(0.78, 0.52, 0.35) # Terra di Siena
	mat_plaster_sienna.roughness = 0.90
	
	mat_plaster_terracotta = StandardMaterial3D.new()
	mat_plaster_terracotta.albedo_color = Color(0.72, 0.38, 0.24) # Rosso mattone
	mat_plaster_terracotta.roughness = 0.90
	
	mat_plaster_olive = StandardMaterial3D.new()
	mat_plaster_olive.albedo_color = Color(0.58, 0.64, 0.50) # Verde salvia ligure
	mat_plaster_olive.roughness = 0.92
	
	mat_plaster_cream = StandardMaterial3D.new()
	mat_plaster_cream.albedo_color = Color(0.90, 0.88, 0.82) # Calce chiara
	mat_plaster_cream.roughness = 0.92
	
	mat_concrete_suburb = StandardMaterial3D.new()
	mat_concrete_suburb.albedo_color = Color(0.74, 0.72, 0.68)
	mat_concrete_suburb.roughness = 0.85
	
	# 7. Shutters, Glass & Metal
	mat_shutter_green = StandardMaterial3D.new()
	mat_shutter_green.albedo_color = Color(0.18, 0.38, 0.22)
	mat_shutter_green.roughness = 0.65
	
	mat_shutter_brown = StandardMaterial3D.new()
	mat_shutter_brown.albedo_color = Color(0.38, 0.24, 0.16)
	mat_shutter_brown.roughness = 0.70
	
	mat_window_glass = StandardMaterial3D.new()
	mat_window_glass.albedo_color = Color(0.12, 0.18, 0.25)
	mat_window_glass.metallic = 0.40
	mat_window_glass.roughness = 0.10
	
	mat_window_glow = StandardMaterial3D.new()
	mat_window_glow.albedo_color = Color(1.0, 0.92, 0.65)
	mat_window_glow.emission_enabled = true
	mat_window_glow.emission = Color(1.0, 0.88, 0.50)
	mat_window_glow.emission_energy_multiplier = 1.4
	
	mat_iron_wrought = StandardMaterial3D.new()
	mat_iron_wrought.albedo_color = Color(0.18, 0.18, 0.20)
	mat_iron_wrought.metallic = 0.85
	mat_iron_wrought.roughness = 0.35
	
	# 8. Fabric Awnings & Details
	mat_awning_red = StandardMaterial3D.new()
	mat_awning_red.albedo_color = Color(0.88, 0.16, 0.14)
	mat_awning_red.roughness = 0.80
	
	mat_awning_yellow = StandardMaterial3D.new()
	mat_awning_yellow.albedo_color = Color(0.96, 0.78, 0.14)
	mat_awning_yellow.roughness = 0.80
	
	mat_awning_white = StandardMaterial3D.new()
	mat_awning_white.albedo_color = Color(0.96, 0.96, 0.96)
	mat_awning_white.roughness = 0.80
	
	mat_brass_bell = StandardMaterial3D.new()
	mat_brass_bell.albedo_color = Color(0.85, 0.72, 0.28)
	mat_brass_bell.metallic = 0.85
	mat_brass_bell.roughness = 0.25
	
	mat_water = StandardMaterial3D.new()
	mat_water.albedo_color = Color(0.20, 0.62, 0.72, 0.90)
	mat_water.roughness = 0.05
	
	mat_carabinieri_blue = StandardMaterial3D.new()
	mat_carabinieri_blue.albedo_color = Color(0.06, 0.12, 0.28)
	mat_carabinieri_blue.metallic = 0.35
	mat_carabinieri_blue.roughness = 0.35
	
	mat_carabinieri_white = StandardMaterial3D.new()
	mat_carabinieri_white.albedo_color = Color(0.96, 0.96, 0.98)
	mat_carabinieri_white.roughness = 0.40
	
	mat_carabinieri_red = StandardMaterial3D.new()
	mat_carabinieri_red.albedo_color = Color(0.88, 0.10, 0.10)
	mat_carabinieri_red.roughness = 0.40
	
	mat_poste_yellow = StandardMaterial3D.new()
	mat_poste_yellow.albedo_color = Color(0.98, 0.84, 0.08)
	mat_poste_yellow.roughness = 0.40
	
	mat_sign_wood = StandardMaterial3D.new()
	mat_sign_wood.albedo_color = Color(0.44, 0.30, 0.18)
	mat_sign_wood.roughness = 0.85
	
	mat_grass = StandardMaterial3D.new()
	mat_grass.albedo_color = Color(0.24, 0.38, 0.16)
	mat_grass.roughness = 0.95
	
	mat_straw_bale = StandardMaterial3D.new()
	mat_straw_bale.albedo_color = Color(0.86, 0.68, 0.32) # Dorato crosta di pane
	mat_straw_bale.roughness = 0.90

# ==============================================================================
# MAIN ENTRY POINT
# ==============================================================================
static func build_starting_city(parent: Node3D) -> Node3D:
	init_materials()
	
	var city_root = Node3D.new()
	city_root.name = "CitySanCristoforo"
	parent.add_child(city_root)
	
	# 1. Rete Stradale Urbana & Marciapiedi
	build_street_network(city_root)
	
	# 2. Piazza Centrale della Repubblica (Porfido, cordoli, fontana, panchine, lampioni)
	build_piazza_centrale(city_root)
	
	# 3. Chiesa Monumentale con Tetto a Capanna e Campanile Traforato (24m)
	build_monumental_church(city_root, Vector3(38.0, 0.0, 14.0), deg_to_rad(90.0))
	
	# 4. Palazzo del Comune (Municipio) con Tetto a 4 Falde, Porticato ad Archi e Torre Orologio
	build_municipio(city_root, Vector3(38.0, 0.0, -14.0), deg_to_rad(90.0))
	
	# 5. Bar dello Sport "Caffè della Piazza" con Dehors, Ombrelloni e Vespa
	build_bar_sport(city_root, Vector3(20.0, 0.0, -23.0), 0.0)
	
	# 6. Comando Stazione Carabinieri / Polizia con Gazzella di Pattuglia
	build_carabinieri_station(city_root, Vector3(34.0, 0.0, -32.0), deg_to_rad(-90.0))
	
	# 7. Ufficio Postale (Poste Italiane) con Ape Piaggio e Cabina SIP
	build_poste_italiane(city_root, Vector3(8.0, 0.0, -23.0), 0.0)
	
	# 8. Panetteria "Il Forno Antico" con Vetrina e Tenda a Righe
	build_panetteria(city_root, Vector3(14.0, 0.0, 23.0), deg_to_rad(180.0))
	
	# 9. Macelleria "Da Gino & Figli" con Banco Carni e Tenda Rossa
	build_macelleria(city_root, Vector3(-18.0, 0.0, 32.0), deg_to_rad(90.0))
	
	# 10. Palazzi Storici del Centro Urbano con Tetti a Falde, Comignoli e Persiane
	build_historic_palazzi_quarter(city_root)
	
	# 11. Periferia: Condomini Civili Anni '70/'80 e Villette con Giardino
	build_suburban_residential_quarter(city_root)
	
	# 12. Bosco Alpino di Fondo (Pini e Cipressi che incorniciano il borgo)
	build_backdrop_forest(city_root)
	
	# 13. Arredo Urbano d'Epoca: Segnaletica, Lampioni in Ghisa e Panchine
	build_urban_details_and_signs(city_root)
	
	# 14. Mura Perimetrali e Porta Monumentale San Cristoforo (Barriera fisica di fine mappa a Sud Z = -80m)
	build_city_boundary_walls_and_gate(city_root)
	
	print("[CityEnvironmentBuilder] 🏛️ Città di San Cristoforo sul Meridiano generata con successo!")
	return city_root

# ==============================================================================
# 1. RETE STRADALE URBANA & INTERSEZIONI
# ==============================================================================
static func build_street_network(parent: Node3D):
	var net = Node3D.new()
	net.name = "UrbanStreetNetwork"
	parent.add_child(net)
	
	# Asse Principale: Corso Garibaldi in Porfido (Z in [-80, 80], larghezza 9.2m)
	# Top della carreggiata perfettamente a Y = 0.00m (complanare con RoadGenerator e Garage)
	create_box_with_col(Vector3(9.2, 0.30, 160.0), mat_pave, Vector3(0.0, -0.15, 0.0), net)
	
	# Incrocio 1: Via Roma (Z = 14.0, da X = 4.6 a X = 55.0 verso la piazza e la chiesa, larghezza 7.6m)
	# Si estende verso Est e non invade mai il lato Ovest, eliminando collisioni col Garage Paolo!
	create_box_with_col(Vector3(50.4, 0.30, 7.6), mat_pave, Vector3(29.8, -0.15, 14.0), net)
	
	# Raccordo Carrabile per Officina / Garage Paolo (Z = 8.0, da X = -4.6 a X = -11.5, larghezza 8.0m, complanare Y = 0.00m)
	create_box_with_col(Vector3(7.0, 0.30, 8.0), mat_pave, Vector3(-8.1, -0.15, 8.0), net)
	
	# Incrocio 2: Vicolo del Municipio / Accesso Piazza Sud (Z = -34.0, da X = 4.6 a X = 55.0, larghezza 7.0m)
	create_box_with_col(Vector3(50.4, 0.30, 7.0), mat_pave, Vector3(29.8, -0.15, -34.0), net)
	
	# Incrocio 3: Viale della Circonvallazione Nord (Z = 65.0, da X = -45.0 a X = 45.0, larghezza 7.6m)
	create_box_with_col(Vector3(90.0, 0.30, 7.6), mat_pave, Vector3(0.0, -0.15, 65.0), net)
	
	# Marciapiedi rialzati in granito lungo Corso Garibaldi (altezza cordolo standard +12cm, top Y = 0.12m)
	# Lato Ovest (aperto per l'accesso al Garage Paolo tra Z = 4.0 e Z = 12.0)
	create_box_with_col(Vector3(2.0, 0.24, 76.0), mat_sidewalk, Vector3(-5.6, -0.01, -42.0), net)
	create_box(Vector3(0.18, 0.25, 76.0), mat_curb, Vector3(-4.51, 0.00, -42.0), net)
	create_box_with_col(Vector3(2.0, 0.24, 68.0), mat_sidewalk, Vector3(-5.6, -0.01, 46.0), net)
	create_box(Vector3(0.18, 0.25, 68.0), mat_curb, Vector3(-4.51, 0.00, 46.0), net)
	
	# Lato Est (aperto per Via Roma a Z = 14 e Vicolo Municipio a Z = -34)
	create_box_with_col(Vector3(2.0, 0.24, 42.0), mat_sidewalk, Vector3(5.6, -0.01, -59.0), net)
	create_box(Vector3(0.18, 0.25, 42.0), mat_curb, Vector3(4.51, 0.00, -59.0), net)
	create_box_with_col(Vector3(2.0, 0.24, 44.0), mat_sidewalk, Vector3(5.6, -0.01, -10.0), net)
	create_box(Vector3(0.18, 0.25, 44.0), mat_curb, Vector3(4.51, 0.00, -10.0), net)
	create_box_with_col(Vector3(2.0, 0.24, 46.0), mat_sidewalk, Vector3(5.6, -0.01, 41.0), net)
	create_box(Vector3(0.18, 0.25, 46.0), mat_curb, Vector3(4.51, 0.00, 41.0), net)
	
	# Strisce pedonali zebrate regolamentari Codice della Strada (interamente attraverso la carreggiata da X = -4.0 a X = +4.0)
	for z_cross in [-14.0, 20.0]:
		for stripe_i in range(9):
			var sx = -4.0 + float(stripe_i) * 1.00
			create_box(Vector3(0.50, 0.015, 3.2), mat_carabinieri_white, Vector3(sx, 0.008, z_cross), net)

# ==============================================================================
# 2. PIAZZA DELLA REPUBBLICA (PIAZZA CENTRALE)
# ==============================================================================
static func build_piazza_centrale(parent: Node3D):
	var pz = Node3D.new()
	pz.name = "PiazzaDellaRepubblica"
	parent.add_child(pz)
	
	# Lastricato monumentale Piazza della Repubblica (top a Y = 0.00m, complanare con Corso Garibaldi)
	create_box_with_col(Vector3(68.0, 0.30, 82.0), mat_pave, Vector3(38.6, -0.15, 0.0), pz)
	
	# Cordolo perimetrale in pietra bianca
	create_box(Vector3(68.4, 0.36, 0.40), mat_curb, Vector3(38.6, -0.12, -41.0), pz)
	create_box(Vector3(68.4, 0.36, 0.40), mat_curb, Vector3(38.6, -0.12, 41.0), pz)
	create_box(Vector3(0.40, 0.36, 82.0), mat_curb, Vector3(72.6, -0.12, 0.0), pz)
	
	# GRANDE FONTANA OTTAGONALE IN PIETRA (Centrata sulla piazza a quota +38cm)
	var f_pos = Vector3(26.0, 0.00, 0.0)
	create_box(Vector3(9.2, 0.16, 9.2), mat_curb, f_pos + Vector3(0, 0.08, 0), pz)
	create_cylinder_with_col(3.8, 0.70, mat_church_stone, f_pos + Vector3(0, 0.45, 0), pz)
	create_cylinder(3.4, 0.08, mat_water, f_pos + Vector3(0, 0.72, 0), 0.0, pz)
	create_cylinder_with_col(0.70, 2.4, mat_church_stone, f_pos + Vector3(0, 1.35, 0), pz)
	create_cylinder(1.6, 0.35, mat_curb, f_pos + Vector3(0, 2.35, 0), 0.0, pz)
	create_cylinder(0.30, 0.90, mat_brass_bell, f_pos + Vector3(0, 2.95, 0), 0.0, pz)
	
	# Anelli concentrici e curve ornamentali in travertino intarsiate nel porfido
	create_cylinder(7.4, 0.03, mat_curb, f_pos + Vector3(0, 0.015, 0), 0.0, pz)
	create_cylinder(7.0, 0.035, mat_pave, f_pos + Vector3(0, 0.02, 0), 0.0, pz)
	create_cylinder(5.6, 0.04, mat_curb, f_pos + Vector3(0, 0.025, 0), 0.0, pz)
	create_cylinder(5.2, 0.045, mat_pave, f_pos + Vector3(0, 0.03, 0), 0.0, pz)
	for angle_deg in [35.0, 145.0, 215.0, 325.0]:
		var ray = create_box(Vector3(14.0, 0.03, 0.45), mat_curb, f_pos + Vector3(0, 0.025, 0), pz)
		ray.rotation.y = deg_to_rad(angle_deg)
	
	# Fioriere e cipressi (posizionate a debita distanza dal corso, X = 7.8m, zero ostacoli sulla strada)
	for tz in [-22.0, 0.0, 22.0]:
		create_cylinder(0.70, 0.48, mat_curb, Vector3(7.8, 0.24, tz), 0.0, pz)
		create_cylinder(0.18, 2.2, mat_shutter_brown, Vector3(7.8, 1.25, tz), 0.0, pz)
		create_cylinder(0.85, 4.2, mat_shutter_green, Vector3(7.8, 3.8, tz), 0.0, pz)
	
	# Lampioni in ghisa ornamentali attorno alla piazza (con illuminazione attiva)
	for lc in [Vector3(14.0, 0.00, -18.0), Vector3(38.0, 0.00, -18.0), Vector3(14.0, 0.00, 18.0), Vector3(38.0, 0.00, 18.0)]:
		build_ornate_lamppost(pz, lc)
		
	# Panchine attorno alla fontana
	build_park_bench(pz, f_pos + Vector3(-5.8, 0, 0), deg_to_rad(90.0))
	build_park_bench(pz, f_pos + Vector3(5.8, 0, 0), deg_to_rad(-90.0))
	build_park_bench(pz, f_pos + Vector3(0, 0, -5.8), 0.0)
	build_park_bench(pz, f_pos + Vector3(0, 0, 5.8), deg_to_rad(180.0))

# ==============================================================================
# 3. LA CHIESA MONUMENTALE DI SAN CRISTOFORO
# ==============================================================================
static func build_monumental_church(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var ch = Node3D.new()
	ch.name = "ChiesaSanCristoforo"
	ch.position = pos
	ch.rotation.y = rot_y
	parent.add_child(ch)
	
	# Sagrato (Gradinata monumentale in pietra bianca)
	for st_i in range(3):
		var sw = 16.0 - float(st_i) * 0.8
		var sd = 3.6 - float(st_i) * 0.6
		create_box_with_col(Vector3(sw, 0.18, sd), mat_curb, Vector3(0, 0.09 + float(st_i) * 0.18, -11.0 - float(st_i) * 0.4), ch)
	
	# Corpo Principale della Navata (13.6m largh, 9.5m alt, 20m prof)
	create_box_with_col(Vector3(13.6, 9.5, 20.0), mat_church_stone, Vector3(0, 4.75, 0), ch)
	
	# Facciata Romanica con Timpano Triangolare
	create_box_with_col(Vector3(14.4, 11.5, 1.2), mat_church_stone, Vector3(0, 5.75, -10.2), ch)
	
	# Tetto a Capanna della Navata in Coppi/Ardesia con Gronde Sporgenti
	create_gable_roof(14.0, 20.4, 3.6, 0.60, mat_slate_roof, Vector3(0, 9.5, 0), 0.0, ch)
	
	# Portale d'Ingresso Scolpito con Lunetta
	create_box(Vector3(4.4, 5.2, 0.45), mat_curb, Vector3(0, 2.6, -10.9), ch)
	create_box(Vector3(3.2, 4.4, 0.20), mat_shutter_brown, Vector3(0, 2.2, -10.95), ch)
	# Lunetta semicircolare sopra il portale
	create_cylinder(1.6, 0.22, mat_church_stone, Vector3(0, 4.4, -10.9), deg_to_rad(90.0), ch)
	
	# Rosone Circolare Centrale Traforato
	create_cylinder(1.75, 0.35, mat_curb, Vector3(0, 8.8, -10.7), deg_to_rad(90.0), ch)
	create_cylinder(1.45, 0.20, mat_window_glow, Vector3(0, 8.8, -10.75), deg_to_rad(90.0), ch)
	# Raggi traforati del rosone
	create_box(Vector3(2.6, 0.12, 0.25), mat_curb, Vector3(0, 8.8, -10.78), ch)
	create_box(Vector3(0.12, 2.6, 0.25), mat_curb, Vector3(0, 8.8, -10.78), ch)
	
	# IL CAMPANILE ROMANICO (Base 4.4m x 4.4m, Altezza 24.5m)
	var camp_x = 9.8
	var camp_z = -6.0
	# Fusto in pietra con angolari bugnati
	create_box_with_col(Vector3(4.4, 18.0, 4.4), mat_church_stone, Vector3(camp_x, 9.0, camp_z), ch)
	create_corner_quoins(Vector3(camp_x, 0, camp_z), 18.0, 4.4, 4.4, ch)
	
	# Cella Campanaria APERTA con 4 Pilastri ad Arco (La campana è visibile dall'esterno!)
	var belfry_y = 18.0
	for cx in [-1.7, 1.7]:
		for cz in [-1.7, 1.7]:
			create_box_with_col(Vector3(0.9, 3.4, 0.9), mat_curb, Vector3(camp_x + cx, belfry_y + 1.7, camp_z + cz), ch)
	# Trabeazione superiore della cella
	create_box(Vector3(4.6, 0.40, 4.6), mat_curb, Vector3(camp_x, belfry_y + 3.6, camp_z), ch)
	
	# Campana di Bronzo sospesa tra le colonne
	create_cylinder(0.70, 0.90, mat_brass_bell, Vector3(camp_x, belfry_y + 2.0, camp_z), 0.0, ch)
	
	# Orologio del Campanile sul lato sud
	create_cylinder(0.95, 0.20, mat_carabinieri_white, Vector3(camp_x, 15.5, camp_z - 2.25), deg_to_rad(90.0), ch)
	
	# Cuspide Piramidale a 4 Falde in Rame con Croce d'Oro
	create_hipped_roof(4.4, 4.4, 4.8, 0.40, mat_slate_roof, Vector3(camp_x, belfry_y + 3.8, camp_z), ch)
	var cross_v = create_box(Vector3(0.08, 1.2, 0.08), mat_brass_bell, Vector3(camp_x, belfry_y + 9.0, camp_z), ch)
	var cross_h = create_box(Vector3(0.75, 0.08, 0.08), mat_brass_bell, Vector3(camp_x, belfry_y + 9.2, camp_z), ch)

# ==============================================================================
# 4. IL PALAZZO DEL COMUNE (MUNICIPIO)
# ==============================================================================
static func build_municipio(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var mun = Node3D.new()
	mun.name = "PalazzoMunicipio"
	mun.position = pos
	mun.rotation.y = rot_y
	parent.add_child(mun)
	
	var w = 18.5; var h = 10.5; var d = 11.5
	# Corpo Principale a 3 Piani
	create_box_with_col(Vector3(w, h, d), mat_plaster_sienna, Vector3(0, h * 0.5, 0), mun)
	# Basamento a Bugnato di Pietra al Piano Terra
	create_box(Vector3(w + 0.25, 3.6, d + 0.25), mat_church_stone, Vector3(0, 1.8, 0), mun)
	create_corner_quoins(Vector3.ZERO, h, w, d, mun)
	
	# TETTO A 4 FALDE (Hipped Roof a padiglione in coppi con gronda sporgente)
	create_hipped_roof(w, d, 2.8, 0.65, mat_terracotta_roof, Vector3(0, h, 0), mun)
	
	# Comignoli sul tetto
	create_chimney(Vector3(-6.5, h + 2.4, 2.5), 1.2, mun)
	create_chimney(Vector3(6.5, h + 2.4, -2.5), 1.2, mun)
	
	# Porticato d'Ingresso ad Archi al Piano Terra
	for col_i in range(5):
		var cx = -7.2 + float(col_i) * 3.6
		create_box_with_col(Vector3(0.85, 3.4, 0.85), mat_curb, Vector3(cx, 1.7, -5.9), mun)
	create_box(Vector3(w + 0.4, 0.50, 2.4), mat_curb, Vector3(0, 3.65, -5.9), mun)
	
	# Balcone d'Onore al Primo Piano con Balaustra
	create_box(Vector3(5.2, 0.22, 1.6), mat_curb, Vector3(0, 4.0, -6.2), mun)
	create_box(Vector3(5.2, 0.85, 0.08), mat_iron_wrought, Vector3(0, 4.5, -6.95), mun)
	
	# Bandiere Istituzionali
	var f_italy = create_box(Vector3(0.95, 0.65, 0.05), StandardMaterial3D.new(), Vector3(-1.3, 5.5, -6.9), mun)
	(f_italy.material_override as StandardMaterial3D).albedo_color = Color(0.12, 0.65, 0.22)
	var f_eu = create_box(Vector3(0.95, 0.65, 0.05), mat_carabinieri_blue, Vector3(0.0, 5.5, -6.9), mun)
	var f_red = create_box(Vector3(0.95, 0.65, 0.05), mat_awning_red, Vector3(1.3, 5.5, -6.9), mun)
	
	# Torretta dell'Orologio Civico sul Tetto con Cupolino
	var clock_tower = create_box_with_col(Vector3(3.6, 4.0, 3.6), mat_plaster_sienna, Vector3(0, h + 2.0, -1.0), mun)
	create_cylinder(0.95, 0.20, mat_carabinieri_white, Vector3(0, h + 2.4, -2.85), deg_to_rad(90.0), mun)
	create_hipped_roof(3.6, 3.6, 1.8, 0.30, mat_slate_roof, Vector3(0, h + 4.0, -1.0), mun)
	
	# Finestre Nobili con Davanzali e Persiane ai Piani Superiori
	for fi in [1, 2]:
		var wy = 3.6 + float(fi) * 2.8
		for xi in [-6.5, -3.2, 3.2, 6.5]:
			create_historic_window(Vector3(xi, wy, -d * 0.5), 0.0, 1.2, 1.8, mat_shutter_green, mun)

# ==============================================================================
# 5. BAR DELLO SPORT ("CAFFÈ DELLA PIAZZA")
# ==============================================================================
static func build_bar_sport(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var bar = Node3D.new()
	bar.name = "BarDelloSport"
	bar.position = pos
	bar.rotation.y = rot_y
	parent.add_child(bar)
	
	var w = 12.0; var h = 7.5; var d = 9.5
	create_box_with_col(Vector3(w, h, d), mat_plaster_ochre, Vector3(0, h * 0.5, 0), bar)
	create_corner_quoins(Vector3.ZERO, h, w, d, bar)
	
	# Tetto a Falde in Coppi con Gronda e Comignolo
	create_gable_roof(w, d, 2.4, 0.50, mat_terracotta_roof, Vector3(0, h, 0), deg_to_rad(90.0), bar)
	create_chimney(Vector3(-3.5, h + 2.2, 2.0), 1.1, bar)
	
	# Finestre al primo piano con persiane
	create_historic_window(Vector3(-3.5, 5.2, d * 0.5), 0.0, 1.1, 1.6, mat_shutter_green, bar)
	create_historic_window(Vector3(3.5, 5.2, d * 0.5), 0.0, 1.1, 1.6, mat_shutter_green, bar)
	
	# Vetrina con Porte in Vetro e Luce Calda Interna
	create_box(Vector3(4.8, 2.6, 0.15), mat_window_glow, Vector3(0, 1.3, d * 0.5 + 0.05), bar)
	
	# Tenda parasole a strisce rosse e bianche
	var awning = create_box(Vector3(6.8, 0.12, 2.8), mat_awning_red, Vector3(0, 2.9, d * 0.5 + 1.4), bar)
	awning.rotation.x = deg_to_rad(14.0)
	
	# Insegna Storica: "BAR DELLO SPORT - CAFFÈ & APERITIVI"
	create_box(Vector3(6.5, 0.75, 0.15), mat_awning_red, Vector3(0, 3.45, d * 0.5 + 0.12), bar)
	create_box(Vector3(6.3, 0.65, 0.18), mat_awning_white, Vector3(0, 3.45, d * 0.5 + 0.13), bar)
	
	# Dehors Estivo: 3 Tavolini rotondi con tovaglie e sedie
	for ti in range(3):
		var tx = -2.6 + float(ti) * 2.6
		var table_p = Vector3(tx, 0.0, d * 0.5 + 2.6)
		create_cylinder(0.48, 0.72, mat_iron_wrought, table_p + Vector3(0, 0.36, 0), 0.0, bar)
		create_cylinder(0.55, 0.04, mat_carabinieri_white, table_p + Vector3(0, 0.73, 0), 0.0, bar)
		create_box(Vector3(0.35, 0.45, 0.35), mat_awning_red, table_p + Vector3(-0.55, 0.22, 0), bar)
		create_box(Vector3(0.35, 0.45, 0.35), mat_awning_red, table_p + Vector3(0.55, 0.22, 0), bar)
		
	# Ombrellone da bar aperto
	var umbrella_p = Vector3(-3.4, 0.0, d * 0.5 + 3.8)
	create_cylinder(0.04, 2.4, mat_iron_wrought, umbrella_p + Vector3(0, 1.2, 0), 0.0, bar)
	create_cylinder(1.5, 0.25, mat_awning_red, umbrella_p + Vector3(0, 2.3, 0), 0.0, bar)
	
	# Vespa 50 Special Parcheggiata
	build_parked_vespa(bar, Vector3(4.5, 0.0, d * 0.5 + 1.8), deg_to_rad(75.0))

# ==============================================================================
# 6. COMANDO STAZIONE CARABINIERI / POLIZIA
# ==============================================================================
static func build_carabinieri_station(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var pol = Node3D.new()
	pol.name = "ComandoStazioneCarabinieri"
	pol.position = pos
	pol.rotation.y = rot_y
	parent.add_child(pol)
	
	var w = 13.5; var h = 8.0; var d = 10.0
	create_box_with_col(Vector3(w, h, d), mat_plaster_cream, Vector3(0, h * 0.5, 0), pol)
	create_box(Vector3(w + 0.3, 0.85, d + 0.3), mat_carabinieri_blue, Vector3(0, 0.42, 0), pol)
	create_corner_quoins(Vector3.ZERO, h, w, d, pol)
	
	# Tetto a 4 falde in coppi
	create_hipped_roof(w, d, 2.2, 0.50, mat_terracotta_roof, Vector3(0, h, 0), pol)
	create_chimney(Vector3(-4.0, h + 2.0, 2.0), 1.0, pol)
	
	# Finestre con inferriate di sicurezza
	for wi in [-3.8, 3.8]:
		create_historic_window(Vector3(wi, 1.8, d * 0.5), 0.0, 1.3, 1.8, mat_iron_wrought, pol)
		create_box(Vector3(1.4, 1.9, 0.08), mat_iron_wrought, Vector3(wi, 1.8, d * 0.5 + 0.15), pol)
		create_historic_window(Vector3(wi, 5.2, d * 0.5), 0.0, 1.3, 1.8, mat_shutter_green, pol)
		
	# Insegna Ufficiale: "CARABINIERI - COMANDO STAZIONE"
	create_box(Vector3(5.6, 0.85, 0.12), mat_carabinieri_blue, Vector3(0, 3.8, d * 0.5 + 0.1), pol)
	create_box(Vector3(5.6, 0.08, 0.14), mat_carabinieri_red, Vector3(0, 3.42, d * 0.5 + 0.1), pol)
	create_cylinder(0.18, 0.28, mat_carabinieri_blue, Vector3(0, 4.6, d * 0.5 + 0.15), 0.0, pol)
	create_cylinder(0.04, 5.2, mat_iron_wrought, Vector3(4.5, h + 2.6, 0), 0.0, pol)
	
	# Gazzella Carabinieri 1980s Parcheggiata
	build_carabinieri_patrol_car(pol, Vector3(0.0, 0.0, d * 0.5 + 3.2), deg_to_rad(90.0))

# ==============================================================================
# 7. UFFICIO POSTALE (POSTE ITALIANE)
# ==============================================================================
static func build_poste_italiane(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var pst = Node3D.new()
	pst.name = "PosteItaliane"
	pst.position = pos
	pst.rotation.y = rot_y
	parent.add_child(pst)
	
	var w = 10.5; var h = 7.0; var d = 8.5
	create_box_with_col(Vector3(w, h, d), mat_plaster_cream, Vector3(0, h * 0.5, 0), pst)
	create_corner_quoins(Vector3.ZERO, h, w, d, pst)
	create_gable_roof(w, d, 2.0, 0.45, mat_terracotta_roof, Vector3(0, h, 0), 0.0, pst)
	
	# Insegna Gialla "POSTE ITALIANE"
	create_box(Vector3(5.8, 0.90, 0.15), mat_poste_yellow, Vector3(0, 3.6, d * 0.5 + 0.1), pst)
	create_box(Vector3(0.70, 0.70, 0.18), mat_carabinieri_blue, Vector3(-2.2, 3.6, d * 0.5 + 0.11), pst)
	
	# Buca delle Lettere Rossa & Cabina Telefonica SIP
	create_box_with_col(Vector3(0.48, 1.15, 0.38), mat_awning_red, Vector3(3.2, 0.58, d * 0.5 + 0.6), pst)
	var cabina_p = Vector3(-3.2, 0.0, d * 0.5 + 1.0)
	create_box_with_col(Vector3(1.1, 2.3, 1.1), mat_carabinieri_red, cabina_p + Vector3(0, 1.15, 0), pst)
	create_box(Vector3(1.05, 1.4, 1.05), mat_window_glass, cabina_p + Vector3(0, 1.35, 0), pst)
	
	# Ape Piaggio Postale Giallo
	build_parked_ape(pst, Vector3(1.8, 0.0, d * 0.5 + 3.2), deg_to_rad(15.0), mat_poste_yellow)

# ==============================================================================
# 8. PANETTERIA "IL FORNO ANTICO"
# ==============================================================================
static func build_panetteria(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var pan = Node3D.new()
	pan.name = "PanetteriaFornoAntico"
	pan.position = pos
	pan.rotation.y = rot_y
	parent.add_child(pan)
	
	var w = 9.5; var h = 8.0; var d = 8.5
	create_box_with_col(Vector3(w, h, d), mat_plaster_ochre, Vector3(0, h * 0.5, 0), pan)
	create_corner_quoins(Vector3.ZERO, h, w, d, pan)
	create_gable_roof(w, d, 2.2, 0.45, mat_terracotta_roof, Vector3(0, h, 0), deg_to_rad(90.0), pan)
	create_chimney(Vector3(-2.5, h + 2.0, 1.5), 1.2, pan)
	
	# Finestre superiori con persiane
	create_historic_window(Vector3(0, 5.2, d * 0.5), 0.0, 1.1, 1.6, mat_shutter_brown, pan)
	
	# Vetrina con telaio in legno scuro, luce calda e scaffali con pane
	create_box(Vector3(4.0, 2.4, 0.12), mat_iron_wrought, Vector3(0, 1.5, d * 0.5 + 0.04), pan)
	create_box(Vector3(3.6, 2.1, 0.06), mat_window_glow, Vector3(0, 1.5, d * 0.5 + 0.06), pan)
	# Scaffalature e ceste con pagnotte e filoni dorati
	create_box(Vector3(3.0, 0.08, 0.40), mat_shutter_brown, Vector3(0, 1.0, d * 0.5 - 0.12), pan)
	create_box(Vector3(3.0, 0.08, 0.40), mat_shutter_brown, Vector3(0, 1.5, d * 0.5 - 0.12), pan)
	for bi in range(4):
		var bx = -1.05 + float(bi) * 0.70
		create_cylinder(0.12, 0.35, mat_straw_bale, Vector3(bx, 1.15, d * 0.5 - 0.12), deg_to_rad(90.0), pan)
		create_cylinder(0.10, 0.45, mat_straw_bale, Vector3(bx, 1.65, d * 0.5 - 0.12), deg_to_rad(90.0), pan)
	
	# Tenda parasole a strisce e insegna in legno
	var awning = create_box(Vector3(4.8, 0.12, 1.9), mat_awning_yellow, Vector3(0, 2.9, d * 0.5 + 0.95), pan)
	awning.rotation.x = deg_to_rad(14.0)
	create_box(Vector3(5.2, 0.65, 0.15), mat_sign_wood, Vector3(0, 3.4, d * 0.5 + 0.1), pan)

# ==============================================================================
# 9. MACELLERIA "DA GINO & FIGLI"
# ==============================================================================
static func build_macelleria(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var mac = Node3D.new()
	mac.name = "MacelleriaDaGino"
	mac.position = pos
	mac.rotation.y = rot_y
	parent.add_child(mac)
	
	var w = 9.5; var h = 8.0; var d = 8.5
	create_box_with_col(Vector3(w, h, d), mat_plaster_terracotta, Vector3(0, h * 0.5, 0), mac)
	create_corner_quoins(Vector3.ZERO, h, w, d, mac)
	create_gable_roof(w, d, 2.2, 0.45, mat_terracotta_roof, Vector3(0, h, 0), deg_to_rad(90.0), mac)
	create_chimney(Vector3(2.5, h + 2.0, 1.5), 1.2, mac)
	
	create_historic_window(Vector3(0, 5.2, d * 0.5), 0.0, 1.1, 1.6, mat_shutter_green, mac)
	
	# Vetrina con telaio, banco carni refrigerato in marmo e salumi appesi
	create_box(Vector3(4.0, 2.4, 0.12), mat_iron_wrought, Vector3(0, 1.5, d * 0.5 + 0.04), mac)
	create_box(Vector3(3.6, 2.1, 0.06), mat_window_glow, Vector3(0, 1.5, d * 0.5 + 0.06), mac)
	create_box(Vector3(2.8, 0.85, 0.50), mat_curb, Vector3(0, 0.45, d * 0.5 - 0.15), mac)
	for si in range(5):
		var sx = -1.1 + float(si) * 0.55
		create_cylinder(0.08, 0.35, mat_plaster_terracotta, Vector3(sx, 2.1, d * 0.5 - 0.10), 0.0, mac)
	
	var awning = create_box(Vector3(4.6, 0.12, 1.9), mat_awning_red, Vector3(0, 2.9, d * 0.5 + 0.95), mac)
	awning.rotation.x = deg_to_rad(14.0)
	create_box(Vector3(5.2, 0.65, 0.15), mat_awning_white, Vector3(0, 3.4, d * 0.5 + 0.1), mac)

# ==============================================================================
# 10. PALAZZI STORICI DEL CENTRO URBANO
# ==============================================================================
static func build_historic_palazzi_quarter(parent: Node3D):
	var pal = Node3D.new()
	pal.name = "HistoricPalazziQuarter"
	parent.add_child(pal)
	
	var palazzi_data = [
		[Vector3(25.5, 0.0, 25.0), deg_to_rad(180.0), 11.5, 11.0, 9.0, 3, mat_plaster_sienna],
		[Vector3(-14.0, 0.0, 52.0), deg_to_rad(90.0), 10.5, 10.5, 8.5, 3, mat_plaster_olive],
		[Vector3(54.0, 0.0, -14.0), deg_to_rad(-90.0), 12.0, 12.0, 9.5, 4, mat_plaster_ochre],
		[Vector3(54.0, 0.0, 14.0), deg_to_rad(-90.0), 12.0, 11.5, 9.5, 4, mat_plaster_cream],
		[Vector3(-14.0, 0.0, -26.0), deg_to_rad(90.0), 10.5, 9.0, 8.5, 3, mat_plaster_sienna],
		[Vector3(-14.0, 0.0, -45.0), deg_to_rad(90.0), 11.0, 9.5, 8.5, 3, mat_plaster_olive]
	]
	
	for pd in palazzi_data:
		build_single_historic_palazzo(pal, pd[0], pd[1], pd[2], pd[3], pd[4], pd[5], pd[6])

static func build_single_historic_palazzo(parent: Node3D, pos: Vector3, rot_y: float, w: float, h: float, d: float, stories: int, plaster_mat: Material):
	var root = Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	parent.add_child(root)
	
	# Corpo dell'edificio
	create_box_with_col(Vector3(w, h, d), plaster_mat, Vector3(0, h * 0.5, 0), root)
	# Basamento in pietra con elegante risalto solido (senza Z-fighting o salti di coordinate)
	create_box(Vector3(w + 0.16, 2.4, d + 0.16), mat_concrete_suburb, Vector3(0, 1.2, 0), root)
	create_box(Vector3(w + 0.22, 0.12, d + 0.22), mat_curb, Vector3(0, 2.46, 0), root)
	create_corner_quoins(Vector3.ZERO, h, w, d, root)
	
	# TETTO A PADIGLIONE (4 falde con tegole in cotto)
	create_hipped_roof(w, d, 2.4, 0.55, mat_terracotta_roof, Vector3(0, h, 0), root)
	create_chimney(Vector3(-w * 0.3, h + 2.0, d * 0.2), 1.2, root)
	
	# Finestre nobili con davanzali e persiane aperte
	var floor_h = (h - 2.6) / float(stories)
	for floor_idx in range(stories):
		var wy = 2.6 + (float(floor_idx) + 0.5) * floor_h
		for col_idx in range(3):
			var wx = -w * 0.30 + float(col_idx) * (w * 0.30)
			create_historic_window(Vector3(wx, wy, d * 0.5), 0.0, 1.1, 1.7, mat_shutter_green, root)
			
			# Balconcino in ferro battuto al piano nobile
			if floor_idx == 1 and col_idx == 1:
				create_box(Vector3(2.4, 0.16, 0.95), mat_curb, Vector3(wx, wy - 0.85, d * 0.5 + 0.48), root)
				create_box(Vector3(2.4, 0.85, 0.06), mat_iron_wrought, Vector3(wx, wy - 0.45, d * 0.5 + 0.95), root)

# ==============================================================================
# 11. PERIFERIA: PALAZZI CIVILI ANNI '70/'80 & VILLETTE CON GIARDINO
# ==============================================================================
static func build_suburban_residential_quarter(parent: Node3D):
	var sub = Node3D.new()
	sub.name = "SuburbanQuarter"
	parent.add_child(sub)
	
	for cp in [Vector3(-55.0, 0.0, -35.0), Vector3(-55.0, 0.0, 25.0), Vector3(68.0, 0.0, -45.0), Vector3(68.0, 0.0, 15.0)]:
		build_civilian_apartment_block(sub, cp)
		
	for vp in [Vector3(-48.0, 0.0, 75.0), Vector3(-24.0, 0.0, 85.0), Vector3(25.0, 0.0, 85.0), Vector3(52.0, 0.0, 75.0)]:
		build_suburban_villa(sub, vp)

static func build_civilian_apartment_block(parent: Node3D, pos: Vector3):
	var blk = Node3D.new()
	blk.position = pos
	parent.add_child(blk)
	
	var w = 15.0; var h = 13.5; var d = 11.0
	create_box_with_col(Vector3(w, h, d), mat_concrete_suburb, Vector3(0, h * 0.5, 0), blk)
	create_box(Vector3(w + 0.5, 0.45, d + 0.5), mat_curb, Vector3(0, h + 0.22, 0), blk)
	
	# Balconi continui a sbalzo in cemento
	for fi in range(1, 4):
		var by = float(fi) * 3.2
		create_box(Vector3(12.2, 0.22, 1.4), mat_curb, Vector3(0, by, d * 0.5 + 0.7), blk)
		create_box(Vector3(12.2, 0.90, 0.08), mat_iron_wrought, Vector3(0, by + 0.50, d * 0.5 + 1.38), blk)
		
	# Portoni garage basculanti
	for gi in range(3):
		var gx = -4.2 + float(gi) * 4.2
		create_box(Vector3(2.6, 2.2, 0.15), mat_iron_wrought, Vector3(gx, 1.1, d * 0.5 + 0.08), blk)
		
	# Antenna TV sul tetto
	create_cylinder(0.04, 3.2, mat_iron_wrought, Vector3(0, h + 1.8, 0), 0.0, blk)
	create_box(Vector3(1.4, 0.04, 0.04), mat_iron_wrought, Vector3(0, h + 2.5, 0), blk)

static func build_suburban_villa(parent: Node3D, pos: Vector3):
	var vil = Node3D.new()
	vil.position = pos
	parent.add_child(vil)
	
	create_box(Vector3(16.0, 0.15, 16.0), mat_grass, Vector3(0, 0.05, 0), vil)
	create_box_with_col(Vector3(16.2, 0.85, 0.30), mat_curb, Vector3(0, 0.45, 8.0), vil)
	create_box_with_col(Vector3(0.30, 0.85, 16.0), mat_curb, Vector3(-8.0, 0.45, 0.0), vil)
	create_box_with_col(Vector3(0.30, 0.85, 16.0), mat_curb, Vector3(8.0, 0.45, 0.0), vil)
	
	var w = 8.5; var h = 6.8; var d = 8.0
	create_box_with_col(Vector3(w, h, d), mat_plaster_cream, Vector3(0, h * 0.5, 0), vil)
	create_gable_roof(w, d, 2.4, 0.50, mat_terracotta_roof, Vector3(0, h, 0), 0.0, vil)
	create_chimney(Vector3(2.2, h + 2.0, 1.5), 1.1, vil)

# ==============================================================================
# 12. BOSCO ALPINO DI FONDO (PINI & CIPRESSI CHE INCORNICIANO IL BORGO)
# ==============================================================================
static func build_alpine_pine(parent: Node3D, pos: Vector3, h_scale: float = 1.0):
	var tree = Node3D.new()
	tree.position = pos
	parent.add_child(tree)
	
	create_cylinder(0.25 * h_scale, 2.5 * h_scale, mat_shutter_brown, Vector3(0, 1.25 * h_scale, 0), 0.0, tree)
	for tier in range(3):
		var ty = (2.2 + float(tier) * 1.8) * h_scale
		var tr = (2.4 - float(tier) * 0.6) * h_scale
		var th = 2.4 * h_scale
		var cone = CylinderMesh.new()
		cone.top_radius = 0.04
		cone.bottom_radius = tr
		cone.height = th
		cone.radial_segments = 12
		var c_mi = MeshInstance3D.new()
		c_mi.mesh = cone
		var f_mat = StandardMaterial3D.new()
		f_mat.albedo_color = Color(0.12 + float(tier)*0.02, 0.30 + float(tier)*0.04, 0.16)
		f_mat.roughness = 0.92
		c_mi.material_override = f_mat
		c_mi.position = Vector3(0, ty, 0)
		tree.add_child(c_mi)

static func build_backdrop_forest(parent: Node3D):
	var forest = Node3D.new()
	forest.name = "AlpineBackdropForest"
	parent.add_child(forest)
	
	# Pini alpini posizionati rigorosamente sui declivi perimetrali a Est e Ovest, ad almeno 35m dalla strada
	var tree_coords = [
		# Crinale Orientale (dietro Piazza e Chiesa, X >= 45.0m)
		Vector3(48.0, 0.0, -32.0), Vector3(52.0, 0.0, -26.0), Vector3(55.0, 0.0, -20.0),
		Vector3(51.0, 0.0, -14.0), Vector3(54.0, 0.0, -8.0), Vector3(50.0, 0.0, -2.0),
		Vector3(49.0, 0.0, 4.0), Vector3(53.0, 0.0, 10.0), Vector3(56.0, 0.0, 16.0),
		Vector3(52.0, 0.0, 22.0), Vector3(50.0, 0.0, 28.0), Vector3(47.0, 0.0, 34.0),
		Vector3(48.0, 0.0, 42.0), Vector3(52.0, 0.0, 50.0), Vector3(46.0, 0.0, 58.0),
		# Crinale Occidentale (dietro l'Officina Paolo e le case a schiera, X <= -38.0m)
		Vector3(-42.0, 0.0, -35.0), Vector3(-46.0, 0.0, -22.0), Vector3(-44.0, 0.0, -8.0),
		Vector3(-48.0, 0.0, 8.0), Vector3(-45.0, 0.0, 24.0), Vector3(-42.0, 0.0, 40.0),
		Vector3(-47.0, 0.0, 52.0)
	]
	for idx in range(tree_coords.size()):
		var tp = tree_coords[idx]
		var sc = 1.15 + sin(float(idx) * 1.7) * 0.35
		build_alpine_pine(forest, tp, sc)

# ==============================================================================
# 13. VEICOLI PARCHEGGIATI & ARREDO URBANO
# ==============================================================================
static func build_carabinieri_patrol_car(parent: Node3D, pos: Vector3, rot_y: float):
	var car = Node3D.new()
	car.position = pos
	car.rotation.y = rot_y
	parent.add_child(car)
	
	create_box_with_col(Vector3(1.75, 0.75, 4.2), mat_carabinieri_blue, Vector3(0, 0.55, 0), car)
	create_box(Vector3(1.50, 0.60, 2.0), mat_carabinieri_white, Vector3(0, 1.15, -0.25), car)
	create_box(Vector3(0.04, 0.12, 3.8), mat_carabinieri_red, Vector3(-0.90, 0.62, 0), car)
	create_box(Vector3(0.04, 0.12, 3.8), mat_carabinieri_red, Vector3(0.90, 0.62, 0), car)
	
	create_box(Vector3(0.95, 0.12, 0.22), mat_carabinieri_white, Vector3(0, 1.50, -0.25), car)
	create_cylinder(0.12, 0.18, mat_carabinieri_blue, Vector3(-0.35, 1.62, -0.25), 0.0, car)
	create_cylinder(0.12, 0.18, mat_carabinieri_blue, Vector3(0.35, 1.62, -0.25), 0.0, car)
	
	for wx in [-0.85, 0.85]:
		for wz in [-1.25, 1.25]:
			create_cylinder(0.32, 0.22, mat_iron_wrought, Vector3(wx, 0.32, wz), deg_to_rad(90.0), car)

static func build_parked_vespa(parent: Node3D, pos: Vector3, rot_y: float):
	var v = Node3D.new()
	v.position = pos
	v.rotation.y = rot_y
	parent.add_child(v)
	
	create_box(Vector3(0.28, 0.55, 1.1), mat_carabinieri_white, Vector3(0, 0.40, 0), v)
	create_box(Vector3(0.42, 0.52, 0.12), mat_carabinieri_white, Vector3(0, 0.50, 0.42), v)
	create_cylinder(0.18, 0.09, mat_iron_wrought, Vector3(0, 0.18, 0.42), deg_to_rad(90.0), v)
	create_cylinder(0.18, 0.09, mat_iron_wrought, Vector3(0, 0.18, -0.42), deg_to_rad(90.0), v)
	create_box(Vector3(0.24, 0.12, 0.48), mat_shutter_brown, Vector3(0, 0.70, -0.15), v)
	create_cylinder(0.08, 0.08, mat_window_glow, Vector3(0, 0.88, 0.40), deg_to_rad(90.0), v)

static func build_parked_ape(parent: Node3D, pos: Vector3, rot_y: float, color_mat: Material):
	var ape = Node3D.new()
	ape.position = pos
	ape.rotation.y = rot_y
	parent.add_child(ape)
	
	create_box(Vector3(1.1, 1.3, 1.1), color_mat, Vector3(0, 0.85, 0.65), ape)
	create_box(Vector3(0.95, 0.55, 0.12), mat_window_glass, Vector3(0, 1.10, 1.22), ape)
	create_box(Vector3(1.3, 0.85, 1.6), color_mat, Vector3(0, 0.65, -0.65), ape)
	create_cylinder(0.22, 0.14, mat_iron_wrought, Vector3(0, 0.22, 1.10), deg_to_rad(90.0), ape)
	create_cylinder(0.22, 0.14, mat_iron_wrought, Vector3(-0.62, 0.22, -0.65), deg_to_rad(90.0), ape)
	create_cylinder(0.22, 0.14, mat_iron_wrought, Vector3(0.62, 0.22, -0.65), deg_to_rad(90.0), ape)

static func build_ornate_lamppost(parent: Node3D, pos: Vector3, rot_y: float = 0.0):
	var post = Node3D.new()
	post.position = pos
	post.rotation.y = rot_y
	parent.add_child(post)
	
	create_cylinder(0.18, 0.85, mat_iron_wrought, Vector3(0, 0.42, 0), 0.0, post)
	create_cylinder(0.08, 3.2, mat_iron_wrought, Vector3(0, 2.2, 0), 0.0, post)
	create_box(Vector3(0.75, 0.08, 0.08), mat_iron_wrought, Vector3(0.35, 3.8, 0), post)
	create_cylinder(0.20, 0.38, mat_window_glow, Vector3(0.75, 3.65, 0), 0.0, post)
	create_box(Vector3(0.28, 0.06, 0.28), mat_iron_wrought, Vector3(0.75, 3.86, 0), post)
	
	# Illuminazione attiva calda e avvolgente
	var omni = OmniLight3D.new()
	omni.light_color = Color(1.0, 0.88, 0.65)
	omni.light_energy = 1.8
	omni.omni_range = 14.0
	omni.shadow_enabled = true
	omni.position = Vector3(0.75, 3.5, 0)
	post.add_child(omni)

static func build_park_bench(parent: Node3D, pos: Vector3, rot_y: float):
	var b = Node3D.new()
	b.position = pos
	b.rotation.y = rot_y
	parent.add_child(b)
	
	create_box_with_col(Vector3(0.12, 0.55, 0.55), mat_iron_wrought, Vector3(-0.85, 0.28, 0), b)
	create_box_with_col(Vector3(0.12, 0.55, 0.55), mat_iron_wrought, Vector3(0.85, 0.28, 0), b)
	for si in range(3):
		create_box(Vector3(1.85, 0.05, 0.14), mat_shutter_brown, Vector3(0, 0.45, -0.18 + float(si) * 0.16), b)
	for bi in range(2):
		create_box(Vector3(1.85, 0.14, 0.05), mat_shutter_brown, Vector3(0, 0.65 + float(bi) * 0.18, -0.24), b)

static func build_urban_details_and_signs(parent: Node3D):
	var det = Node3D.new()
	det.name = "UrbanDetails"
	parent.add_child(det)
	
	# Lampioni in ghisa d'epoca con illuminazione attiva lungo Corso Garibaldi
	for l_z in [-55.0, -25.0, 5.0, 35.0, 65.0]:
		build_ornate_lamppost(det, Vector3(-5.3, 0.12, l_z), deg_to_rad(90.0))
		build_ornate_lamppost(det, Vector3(5.3, 0.12, l_z), deg_to_rad(-90.0))
	
	var street_signs = [
		[Vector3(-5.8, 3.2, 12.0), deg_to_rad(90.0), "VIA DELLE BOTTEGHE"],
		[Vector3(5.8, 3.2, 12.0), deg_to_rad(-90.0), "VIA ROMA"],
		[Vector3(5.8, 3.2, -26.0), deg_to_rad(-90.0), "PIAZZA DELLA REPUBBLICA"],
		[Vector3(-5.8, 3.2, -45.0), deg_to_rad(90.0), "CORSO GARIBALDI"]
	]
	for ss in street_signs:
		var marble = create_box(Vector3(1.4, 0.42, 0.06), mat_curb, ss[0], det)
		marble.rotation.y = ss[1]

# ==============================================================================
# 14. MURA PERIMETRALI & PORTA SAN CRISTOFORO (BARRIERA ANTI-CADUTA A SUD Z = -80m)
# ==============================================================================
static func build_city_boundary_walls_and_gate(parent: Node3D):
	var bnd = Node3D.new()
	bnd.name = "CityBoundaryAndGate"
	parent.add_child(bnd)
	
	# --- 1. PORTA MONUMENTALE SAN CRISTOFORO (Fine Mappa Sud, Z = -80.0m) ---
	# Torri gemelle medievali a pianta cilindrica (raggio 2.2m, altezza 9.5m)
	for t_x in [-5.8, 5.8]:
		create_cylinder_with_col(2.2, 9.5, mat_church_stone, Vector3(t_x, 4.75, -80.0), bnd)
		create_cylinder(2.5, 0.45, mat_curb, Vector3(t_x, 9.75, -80.0), 0.0, bnd)
		for mi in range(4):
			var ang = float(mi) * (PI * 0.5)
			create_box(Vector3(0.55, 0.65, 0.55), mat_church_stone, Vector3(t_x + cos(ang) * 2.1, 10.25, -80.0 + sin(ang) * 2.1), bnd)
			
	# Arco a tutto sesto di collegamento sopra la carreggiata (luce 7.4m, altezza 6.2m)
	create_box_with_col(Vector3(8.0, 2.2, 2.4), mat_church_stone, Vector3(0.0, 7.3, -80.0), bnd)
	
	# Portone / Cancellata storica in ferro battuto chiusa (barriera fisica solida anti-caduta)
	var gate = create_box_with_col(Vector3(7.6, 3.8, 0.35), mat_iron_wrought, Vector3(0.0, 1.9, -80.0), bnd)
	for bi in range(12):
		var bx = -3.3 + float(bi) * 0.60
		create_cylinder(0.04, 3.8, mat_iron_wrought, Vector3(bx, 1.9, -80.0), 0.0, bnd)
		create_box(Vector3(0.12, 0.25, 0.12), mat_brass_bell, Vector3(bx, 3.9, -80.0), bnd)
		
	# Segnaletica stradale retro-riflettente ANAS anni '80 di chiusura tracciato
	create_box(Vector3(4.8, 0.60, 0.08), mat_carabinieri_red, Vector3(0.0, 1.4, -79.6), bnd)
	create_box(Vector3(4.6, 0.48, 0.10), mat_carabinieri_white, Vector3(0.0, 1.4, -79.58), bnd)
	create_box(Vector3(3.6, 0.38, 0.12), mat_carabinieri_red, Vector3(0.0, 1.4, -79.56), bnd)
	
	# Mura difensive perimetrali a Sud (collegano le torri ai bastioni laterali a X = +/- 65m)
	create_box_with_col(Vector3(56.0, 4.5, 1.8), mat_church_stone, Vector3(-36.0, 2.25, -80.0), bnd)
	create_box_with_col(Vector3(56.0, 4.5, 1.8), mat_church_stone, Vector3(36.0, 2.25, -80.0), bnd)
	
	# --- 2. MURA DIFENSIVE LATERALI DEL BORGO (X = -65m e X = +65m, Z in [-80, 80]) ---
	# Impediscono tassativamente all'auto di cadere nei burroni laterali
	create_box_with_col(Vector3(1.6, 3.2, 160.0), mat_church_stone, Vector3(-65.0, 1.6, 0.0), bnd)
	create_box_with_col(Vector3(1.6, 3.2, 160.0), mat_church_stone, Vector3(65.0, 1.6, 0.0), bnd)
	
	# --- 3. PILASTRI D'USCITA VERSO LA PIANURA (Nord, Z = 80.0m) ---
	for px in [-5.8, 5.8]:
		create_box_with_col(Vector3(1.2, 3.6, 1.2), mat_church_stone, Vector3(px, 1.8, 80.0), bnd)
		create_cylinder(0.70, 0.50, mat_brass_bell, Vector3(px, 3.85, 80.0), 0.0, bnd)

# ==============================================================================
# ARCHITECTURAL ROOF, WINDOW & MESH GENERATORS
# ==============================================================================
static func create_hipped_roof(w: float, d: float, h: float, overhang: float, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var hw = (w * 0.5) + overhang
	var hd = (d * 0.5) + overhang
	
	# Eaves cornice slab underneath
	create_box(Vector3(w + overhang * 1.5, 0.22, d + overhang * 1.5), mat_curb, pos + Vector3(0, 0.11, 0), parent)
	
	# 4 Base corners
	var c_fl = Vector3(-hw, 0.22, -hd)
	var c_fr = Vector3(hw, 0.22, -hd)
	var c_br = Vector3(hw, 0.22, hd)
	var c_bl = Vector3(-hw, 0.22, hd)
	
	# Ridge vertices at apex
	var rw = max(0.2, hw - hd)
	var r_l = Vector3(-rw, h, 0.0)
	var r_r = Vector3(rw, h, 0.0)
	
	# Front slope (Z = -hd)
	add_quad_st(st, c_fl, c_fr, r_r, r_l)
	# Back slope (Z = +hd)
	add_quad_st(st, c_br, c_bl, r_l, r_r)
	# Left hip
	add_tri_st(st, c_bl, c_fl, r_l)
	# Right hip
	add_tri_st(st, c_fr, c_br, r_r)
	
	st.generate_normals()
	mi.mesh = st.commit()
	mi.position = pos
	if parent: parent.add_child(mi)
	return mi

static func create_gable_roof(w: float, d: float, h: float, overhang: float, mat: Material, pos: Vector3, rot_y: float = 0.0, parent: Node3D = null) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	if parent: parent.add_child(root)
	
	create_box(Vector3(w + overhang * 1.6, 0.22, d + overhang * 1.6), mat_curb, Vector3(0, 0.11, 0), root)
	
	var pm = PrismMesh.new()
	pm.left_to_right = 0.5
	pm.size = Vector3(w + overhang * 2.0, h, d + overhang * 2.0)
	var p_mi = MeshInstance3D.new()
	p_mi.mesh = pm
	p_mi.material_override = mat
	p_mi.position = Vector3(0, 0.22 + h * 0.5, 0)
	root.add_child(p_mi)
	
	create_box(Vector3(0.35, 0.18, d + overhang * 2.2), mat_curb, Vector3(0, 0.22 + h + 0.05, 0), root)
	return root

static func add_tri_st(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3):
	var uv_s = 0.4
	st.set_uv(Vector2(p1.x, p1.z) * uv_s)
	st.add_vertex(p1)
	st.set_uv(Vector2(p2.x, p2.z) * uv_s)
	st.add_vertex(p2)
	st.set_uv(Vector2(p3.x, p3.z) * uv_s)
	st.add_vertex(p3)

static func add_quad_st(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3):
	add_tri_st(st, p1, p2, p3)
	add_tri_st(st, p1, p3, p4)

static func create_chimney(pos: Vector3, h: float, parent: Node3D = null) -> Node3D:
	var ch = Node3D.new()
	ch.position = pos
	if parent: parent.add_child(ch)
	create_box(Vector3(0.65, h, 0.65), mat_plaster_terracotta, Vector3(0, h * 0.5, 0), ch)
	create_box(Vector3(0.85, 0.12, 0.85), mat_curb, Vector3(0, h + 0.06, 0), ch)
	create_cylinder(0.12, 0.28, mat_plaster_terracotta, Vector3(-0.18, h + 0.24, 0), 0.0, ch)
	create_cylinder(0.12, 0.28, mat_plaster_terracotta, Vector3(0.18, h + 0.24, 0), 0.0, ch)
	return ch

static func create_historic_window(pos: Vector3, rot_y: float, w: float, h: float, shutter_mat: Material, parent: Node3D = null) -> Node3D:
	var win = Node3D.new()
	win.position = pos
	win.rotation.y = rot_y
	if parent: parent.add_child(win)
	
	create_box(Vector3(w + 0.35, 0.10, 0.32), mat_curb, Vector3(0, -h * 0.5 - 0.05, 0.10), win)
	create_box(Vector3(w + 0.25, 0.12, 0.20), mat_curb, Vector3(0, h * 0.5 + 0.06, 0.04), win)
	create_box(Vector3(w, h, 0.06), mat_window_glass, Vector3(0, 0, -0.04), win)
	create_box(Vector3(w, 0.04, 0.08), mat_carabinieri_white, Vector3(0, 0, -0.02), win)
	create_box(Vector3(0.04, h, 0.08), mat_carabinieri_white, Vector3(0, 0, -0.02), win)
	
	var sw = w * 0.52
	var sh_l = create_box(Vector3(sw, h * 0.96, 0.06), shutter_mat, Vector3(-w * 0.5 - sw * 0.45, 0, 0.12), win)
	sh_l.rotation.y = deg_to_rad(22.0)
	var sh_r = create_box(Vector3(sw, h * 0.96, 0.06), shutter_mat, Vector3(w * 0.5 + sw * 0.45, 0, 0.12), win)
	sh_r.rotation.y = deg_to_rad(-22.0)
	return win

static func create_corner_quoins(pos: Vector3, h: float, w: float, d: float, parent: Node3D = null):
	var q = Node3D.new()
	q.position = pos
	if parent: parent.add_child(q)
	
	var num_blocks = int(h / 0.65)
	for bi in range(num_blocks):
		var by = 0.32 + float(bi) * 0.65
		var is_long = (bi % 2 == 0)
		var lx = 0.65 if is_long else 0.40
		var lz = 0.40 if is_long else 0.65
		var th = 0.05
		# Pietre d'angolo sulla facciata frontale e posteriore (aggettanti di 3cm, zero Z-fighting)
		create_box(Vector3(lx, 0.48, th), mat_curb, Vector3(-w * 0.5 + lx * 0.5, by, -d * 0.5 - th * 0.5), q)
		create_box(Vector3(lx, 0.48, th), mat_curb, Vector3(w * 0.5 - lx * 0.5, by, -d * 0.5 - th * 0.5), q)
		create_box(Vector3(lx, 0.48, th), mat_curb, Vector3(-w * 0.5 + lx * 0.5, by, d * 0.5 + th * 0.5), q)
		create_box(Vector3(lx, 0.48, th), mat_curb, Vector3(w * 0.5 - lx * 0.5, by, d * 0.5 + th * 0.5), q)
		# Pietre d'angolo sui fianchi laterali che completano l'angolo a 90°
		create_box(Vector3(th, 0.48, lz), mat_curb, Vector3(-w * 0.5 - th * 0.5, by, -d * 0.5 + lz * 0.5), q)
		create_box(Vector3(th, 0.48, lz), mat_curb, Vector3(w * 0.5 + th * 0.5, by, -d * 0.5 + lz * 0.5), q)
		create_box(Vector3(th, 0.48, lz), mat_curb, Vector3(-w * 0.5 - th * 0.5, by, d * 0.5 - lz * 0.5), q)
		create_box(Vector3(th, 0.48, lz), mat_curb, Vector3(w * 0.5 + th * 0.5, by, d * 0.5 - lz * 0.5), q)

# ==============================================================================
# BASIC PRIMITIVES
# ==============================================================================
static func create_box(size: Vector3, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var b = BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.material_override = mat
	mi.position = pos
	if parent: parent.add_child(mi)
	return mi

static func create_box_with_col(size: Vector3, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi = create_box(size, mat, pos, parent)
	var sb = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	cs.shape = box_shape
	sb.add_child(cs)
	mi.add_child(sb)
	return mi

static func create_cylinder(radius: float, height: float, mat: Material, pos: Vector3, rot_x: Variant = 0.0, parent: Node3D = null) -> MeshInstance3D:
	var actual_rot: float = 0.0
	var actual_parent: Node3D = parent
	if rot_x is Node3D:
		actual_parent = rot_x
		actual_rot = 0.0
	elif rot_x is float or rot_x is int:
		actual_rot = float(rot_x)
		
	var mi = MeshInstance3D.new()
	var c = CylinderMesh.new()
	c.top_radius = radius
	c.bottom_radius = radius
	c.height = height
	c.radial_segments = 16
	mi.mesh = c
	mi.material_override = mat
	mi.position = pos
	mi.rotation.x = actual_rot
	if actual_parent: actual_parent.add_child(mi)
	return mi

static func create_cylinder_with_col(radius: float, height: float, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi = create_cylinder(radius, height, mat, pos, 0.0, parent)
	var sb = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	var cyl_shape = CylinderShape3D.new()
	cyl_shape.radius = radius
	cyl_shape.height = height
	cs.shape = cyl_shape
	sb.add_child(cs)
	mi.add_child(sb)
	return mi
