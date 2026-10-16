extends RefCounted
class_name RuralPlainEnvironmentBuilder

# ==============================================================================
# PIANURA AGRICOLA DEI PODERI & CAMPAGNA DEL MERIDIANO (GODOT 4)
# ==============================================================================
# Generazione procedurale dell'ampia vallata pianeggiante tra San Cristoforo (Z=80m)
# e la Stazione Agip '93 (Z=1380m):
# 1. Rete Stradale Secondaria: Bivi con strade vicinali/poderali in terra battuta,
#    staccionate in legno e frecce direzionali blu ANAS/Provincia.
# 2. Campi Coltivati Patchwork: Campi di grano dorato con rotoballe, girasoli,
#    vigneti a spalliera e pascoli con steccati.
# 3. Fattorie Storiche:
#    - Cascina "Corte San Giorgio" (Casale padano, fienile aperto, silo metallico,
#      trattore d'epoca con rimorchio, pozzo e recinto mucche).
#    - Antico Mulino ad Acqua con ruota a pale in legno e Ruscello Chiaro con ponte in pietra.
#    - Podere Belvedere con viale di cipressi, cantina e botti di rovere.
# 4. Laghi e Ruscelli di Contorno: Lago dei Salici con canneto, pontile e barche a remi.
# 5. Colline da Contorno: Morbidi rilievi collinari boscati a chiusura dell'orizzonte.
# ==============================================================================

# Materials Palette
static var mat_wheat_crop: StandardMaterial3D
static var mat_sunflower_petal: StandardMaterial3D
static var mat_sunflower_center: StandardMaterial3D
static var mat_sunflower_leaf: StandardMaterial3D
static var mat_vine_leaf: StandardMaterial3D
static var mat_dirt_road: StandardMaterial3D
static var mat_stone_bridge: StandardMaterial3D
static var mat_farm_brick: StandardMaterial3D
static var mat_farm_plaster: StandardMaterial3D
static var mat_fienile_timber: StandardMaterial3D
static var mat_straw_bale: StandardMaterial3D
static var mat_silo_steel: StandardMaterial3D
static var mat_tractor_orange: StandardMaterial3D
static var mat_tractor_iron: StandardMaterial3D
static var mat_water_stream: StandardMaterial3D
static var mat_water_wheel_wood: StandardMaterial3D
static var mat_sign_blue: StandardMaterial3D
static var mat_sign_white: StandardMaterial3D
static var mat_staccionata_wood: StandardMaterial3D
static var mat_terracotta_roof: ShaderMaterial
static var mat_reed: StandardMaterial3D

static func init_materials():
	if mat_farm_brick != null: return
	
	var building_shader = load("res://shaders/stylized_building.gdshader")
	
	mat_terracotta_roof = ShaderMaterial.new()
	mat_terracotta_roof.shader = building_shader
	mat_terracotta_roof.set_shader_parameter("material_type", 2)
	mat_terracotta_roof.set_shader_parameter("base_color", Color(0.76, 0.40, 0.24))
	mat_terracotta_roof.set_shader_parameter("alt_color", Color(0.62, 0.30, 0.18))
	mat_terracotta_roof.set_shader_parameter("mortar_color", Color(0.35, 0.20, 0.12))
	mat_terracotta_roof.set_shader_parameter("texture_scale", 2.2)
	
	mat_wheat_crop = StandardMaterial3D.new()
	mat_wheat_crop.albedo_color = Color(0.86, 0.72, 0.32) # Dorato grano maturo
	mat_wheat_crop.roughness = 0.92
	
	mat_sunflower_petal = StandardMaterial3D.new()
	mat_sunflower_petal.albedo_color = Color(0.98, 0.82, 0.08) # Giallo intenso
	mat_sunflower_petal.roughness = 0.65
	
	mat_sunflower_center = StandardMaterial3D.new()
	mat_sunflower_center.albedo_color = Color(0.26, 0.16, 0.10) # Bruno semi
	mat_sunflower_center.roughness = 0.90
	
	mat_sunflower_leaf = StandardMaterial3D.new()
	mat_sunflower_leaf.albedo_color = Color(0.20, 0.42, 0.16)
	mat_sunflower_leaf.roughness = 0.85
	
	mat_vine_leaf = StandardMaterial3D.new()
	mat_vine_leaf.albedo_color = Color(0.18, 0.38, 0.15) # Verde vigneto
	mat_vine_leaf.roughness = 0.85
	
	mat_dirt_road = StandardMaterial3D.new()
	mat_dirt_road.albedo_color = Color(0.56, 0.49, 0.39) # Terra battuta & ghiaia chiara
	mat_dirt_road.roughness = 0.95
	
	mat_stone_bridge = StandardMaterial3D.new()
	mat_stone_bridge.albedo_color = Color(0.60, 0.58, 0.54) # Pietra di fiume levigata
	mat_stone_bridge.roughness = 0.88
	
	mat_farm_brick = StandardMaterial3D.new()
	mat_farm_brick.albedo_color = Color(0.70, 0.40, 0.26) # Mattone pieno padano
	mat_farm_brick.roughness = 0.90
	
	mat_farm_plaster = StandardMaterial3D.new()
	mat_farm_plaster.albedo_color = Color(0.90, 0.86, 0.76) # Calce chiara
	mat_farm_plaster.roughness = 0.92
	
	mat_fienile_timber = StandardMaterial3D.new()
	mat_fienile_timber.albedo_color = Color(0.38, 0.25, 0.16) # Castagno stagionato
	mat_fienile_timber.roughness = 0.85
	
	mat_straw_bale = StandardMaterial3D.new()
	mat_straw_bale.albedo_color = Color(0.88, 0.75, 0.34) # Paglia dorata
	mat_straw_bale.roughness = 0.95
	
	mat_silo_steel = StandardMaterial3D.new()
	mat_silo_steel.albedo_color = Color(0.76, 0.80, 0.84) # Lamiera zincata
	mat_silo_steel.metallic = 0.70
	mat_silo_steel.roughness = 0.35
	
	mat_tractor_orange = StandardMaterial3D.new()
	mat_tractor_orange.albedo_color = Color(0.94, 0.45, 0.08) # Arancione Fiat Trattori
	mat_tractor_orange.metallic = 0.30
	mat_tractor_orange.roughness = 0.38
	
	mat_tractor_iron = StandardMaterial3D.new()
	mat_tractor_iron.albedo_color = Color(0.18, 0.18, 0.20) # Ghisa meccanica
	mat_tractor_iron.metallic = 0.60
	mat_tractor_iron.roughness = 0.50
	
	mat_water_stream = StandardMaterial3D.new()
	mat_water_stream.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_water_stream.albedo_color = Color(0.24, 0.64, 0.76, 0.85) # Acqua viva cristallina
	mat_water_stream.roughness = 0.04
	
	mat_water_wheel_wood = StandardMaterial3D.new()
	mat_water_wheel_wood.albedo_color = Color(0.28, 0.19, 0.12) # Legno bagnato da mulino
	mat_water_wheel_wood.roughness = 0.80
	
	mat_sign_blue = StandardMaterial3D.new()
	mat_sign_blue.albedo_color = Color(0.08, 0.25, 0.68) # Blu segnaletica italiana
	mat_sign_blue.roughness = 0.35
	
	mat_sign_white = StandardMaterial3D.new()
	mat_sign_white.albedo_color = Color(0.96, 0.96, 0.98)
	mat_sign_white.roughness = 0.35
	
	mat_staccionata_wood = StandardMaterial3D.new()
	mat_staccionata_wood.albedo_color = Color(0.48, 0.36, 0.25)
	mat_staccionata_wood.roughness = 0.90
	
	mat_reed = StandardMaterial3D.new()
	mat_reed.albedo_color = Color(0.42, 0.52, 0.24)
	mat_reed.roughness = 0.85

# ==============================================================================
# MAIN CHUNK DISPATCHER FOR PLAIN (Z in [80m, 1380m])
# ==============================================================================
static func spawn_plain_chunk_features(root: Node3D, points: Array, start_z: float):
	init_materials()
	
	if start_z < 60.0 or start_z >= 1380.0:
		return
		
	var num_pts = points.size()
	var mid_p = points[int(num_pts * 0.5)]
	
	# 1. Bivio 1 & Cascina San Giorgio (Z ~ 240m - 360m)
	if start_z >= 200.0 and start_z < 320.0:
		build_rural_road_branch(root, Vector3(mid_p.x, mid_p.y, mid_p.z), 1.0, 48.0, "CASCINA S. GIORGIO", mid_p.angle, mid_p.width * 0.5)
		build_cascina_san_giorgio(root, Vector3(mid_p.x + 52.0, mid_p.y, mid_p.z - 8.0), deg_to_rad(-90.0))
		build_wheat_field(root, Vector3(mid_p.x - 48.0, mid_p.y, mid_p.z), 42.0, 75.0, 8)
		build_wheat_field(root, Vector3(mid_p.x + 48.0, mid_p.y, mid_p.z + 45.0), 38.0, 60.0, 6)
		
	# 2. Bivio 2, Ruscello Chiaro & Antico Mulino ad Acqua (Z ~ 440m - 560m)
	elif start_z >= 440.0 and start_z < 560.0:
		build_watermill_and_stream(root, points, mid_p)
		build_rural_road_branch(root, Vector3(mid_p.x, mid_p.y, mid_p.z + 6.0), -1.0, 42.0, "ANTICO MULINO & RUSCELLO", mid_p.angle, mid_p.width * 0.5)
		build_sunflower_field(root, Vector3(mid_p.x + 46.0, mid_p.y, mid_p.z), 36.0, 68.0)
		
	# 3. Bivio 3, Podere Belvedere & Vigneti (Z ~ 760m - 880m)
	elif start_z >= 760.0 and start_z < 880.0:
		build_rural_road_branch(root, Vector3(mid_p.x, mid_p.y, mid_p.z), -1.0, 55.0, "PODERE BELVEDERE", mid_p.angle, mid_p.width * 0.5)
		build_podere_belvedere(root, Vector3(mid_p.x - 58.0, mid_p.y + 1.2, mid_p.z), deg_to_rad(90.0))
		build_vineyard_rows(root, Vector3(mid_p.x - 45.0, mid_p.y, mid_p.z + 42.0), 32.0, 70.0, 7)
		build_wheat_field(root, Vector3(mid_p.x + 50.0, mid_p.y, mid_p.z), 44.0, 72.0, 7)
		
	# 4. Bivio 4 & Lago dei Salici (Z ~ 1000m - 1160m)
	elif start_z >= 1000.0 and start_z < 1160.0:
		build_rural_road_branch(root, Vector3(mid_p.x, mid_p.y, mid_p.z), 1.0, 45.0, "LAGO DEI SALICI", mid_p.angle, mid_p.width * 0.5)
		build_lago_dei_salici(root, Vector3(mid_p.x + 62.0, mid_p.y - 0.4, mid_p.z))
		build_vineyard_rows(root, Vector3(mid_p.x - 48.0, mid_p.y, mid_p.z), 34.0, 75.0, 8)
		
	# 5. Campi e Pascoli di Raccordo (Z ~ 80-200m, 320-440m, 560-760m, 880-1000m, 1160-1360m)
	else:
		if int(start_z / 120.0) % 2 == 0:
			build_wheat_field(root, Vector3(mid_p.x - 45.0, mid_p.y, mid_p.z), 40.0, 85.0, 8)
			build_sunflower_field(root, Vector3(mid_p.x + 46.0, mid_p.y, mid_p.z), 36.0, 75.0)
		else:
			build_vineyard_rows(root, Vector3(mid_p.x - 44.0, mid_p.y, mid_p.z), 32.0, 80.0, 7)
			build_pasture_with_fence(root, Vector3(mid_p.x + 48.0, mid_p.y, mid_p.z), 42.0, 78.0)
			
	# Colline boscate morbide da contorno ai bordi dell'orizzonte (X = +/- 200m)
	build_surrounding_hills(root, mid_p)

# ==============================================================================
# 1. RETE STRADALE SECONDARIA (BIVI, STRADE PODERALI & CARTELLI ANAS)
# ==============================================================================
static func build_rural_road_branch(parent: Node3D, j_pos: Vector3, side: float, length: float, dest_name: String, r_angle: float = 0.0, r_width_half: float = 4.2):
	var branch_root = Node3D.new()
	branch_root.name = "RuralBranch_" + dest_name.replace(" ", "_")
	parent.add_child(branch_root)
	
	var r_width = 5.2
	
	# Vettore normale perpendicolare alla statale rivolto verso l'esterno del bivio
	var norm_x = cos(r_angle) * side
	var norm_z = -sin(r_angle) * side
	var branch_dir = Vector3(norm_x, 0.0, norm_z).normalized()
	
	# La diramazione comincia esattamente dal ciglio esterno della banchina (+0.4m fuori carreggiata)
	# Non invade MAI l'asfalto della statale, zero scalini e zero artefatti triangolari!
	var start_dist = r_width_half + 0.4
	var track_len = max(10.0, length - 4.0)
	var track_center = j_pos + branch_dir * (start_dist + track_len * 0.5)
	var branch_yaw = atan2(branch_dir.x, branch_dir.z)
	
	var road_node = Node3D.new()
	road_node.position = Vector3(track_center.x, j_pos.y - 0.02, track_center.z)
	road_node.rotation.y = branch_yaw
	branch_root.add_child(road_node)
	
	# Corsia poderale complanare con il terreno agricolo
	create_box_with_col(Vector3(r_width, 0.06, track_len), mat_dirt_road, Vector3.ZERO, road_node)
	
	# Staccionata in legno sui lati della strada vicinale
	var num_posts = int(track_len / 4.2)
	for post_i in range(num_posts):
		var post_z = -track_len * 0.5 + 2.0 + float(post_i) * 4.2
		for s_side in [-1.0, 1.0]:
			var post_x = s_side * (r_width * 0.5 + 0.45)
			create_cylinder(0.09, 1.35, mat_staccionata_wood, Vector3(post_x, 0.67, post_z), 0.0, road_node)
			if post_i > 0:
				var bar_z = post_z - 2.1
				create_box(Vector3(0.08, 0.08, 4.3), mat_staccionata_wood, Vector3(post_x, 0.95, bar_z), road_node)
				create_box(Vector3(0.08, 0.08, 4.3), mat_staccionata_wood, Vector3(post_x, 0.50, bar_z), road_node)
				
	# Segnaletica ANAS d'inizio bivio (posizionata sul lato dell'incrocio, 2.2m fuori dalla statale)
	var sign_local_z = -track_len * 0.5 + 1.2
	var sign_local_x = -(r_width * 0.5 + 1.4)
	var sign_pos_local = Vector3(sign_local_x, 0.0, sign_local_z)
	
	# Palo tubolare cartello
	create_cylinder(0.045, 2.8, mat_tractor_iron, sign_pos_local + Vector3(0.0, 1.4, 0.0), 0.0, road_node)
	var sign_w = 2.4; var sign_h = 0.55
	create_box(Vector3(0.06, sign_h, sign_w), mat_sign_blue, sign_pos_local + Vector3(0.0, 2.5, 0.0), road_node)
	create_box(Vector3(0.07, sign_h - 0.08, sign_w - 0.08), mat_sign_white, sign_pos_local + Vector3(0.0, 2.5, 0.0), road_node)
	create_box(Vector3(0.08, sign_h - 0.16, sign_w - 0.16), mat_sign_blue, sign_pos_local + Vector3(0.0, 2.5, 0.0), road_node)
	
	# Cippo chilometrico ANAS bianco con cappello rosso sulla banchina opposta del bivio
	var cippo_local_x = (r_width * 0.5 + 1.4)
	create_cylinder(0.22, 0.85, mat_sign_white, Vector3(cippo_local_x, 0.42, sign_local_z), 0.0, road_node)
	create_cylinder(0.24, 0.18, mat_sunflower_petal, Vector3(cippo_local_x, 0.85, sign_local_z), 0.0, road_node)

# ==============================================================================
# 2. CAMPI COLTIVATI PATCHWORK
# ==============================================================================
static func build_wheat_field(parent: Node3D, center: Vector3, sx: float, sz: float, num_bales: int):
	var field = Node3D.new()
	field.name = "WheatField"
	field.position = center
	parent.add_child(field)
	
	# Base del campo di grano dorato
	var bed = create_box(Vector3(sx, 0.16, sz), mat_wheat_crop, Vector3(0, 0.08, 0), field)
	
	# Solchi agricoli longitudinali paralleli (tracce d'aratro)
	var num_furrows = int(sx / 3.8)
	for fi in range(num_furrows):
		var fx = -sx * 0.5 + float(fi) * 3.8 + 1.9
		create_box(Vector3(0.25, 0.18, sz * 0.98), mat_dirt_road, Vector3(fx, 0.09, 0), field)
		
	# Rotoballe di paglia dorata (Bales cilindriche d'epoca)
	for bi in range(num_bales):
		var bx = -sx * 0.38 + fmod(float(bi) * 17.3, sx * 0.76)
		var bz = -sz * 0.40 + fmod(float(bi) * 23.7, sz * 0.80)
		var bale = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.85
		cyl.bottom_radius = 0.85
		cyl.height = 1.35
		cyl.radial_segments = 14
		bale.mesh = cyl
		bale.material_override = mat_straw_bale
		bale.rotation.x = deg_to_rad(90.0)
		bale.rotation.y = deg_to_rad(float(bi) * 45.0)
		bale.position = Vector3(bx, 0.85, bz)
		field.add_child(bale)

static func build_sunflower_field(parent: Node3D, center: Vector3, sx: float, sz: float):
	var field = Node3D.new()
	field.name = "SunflowerField"
	field.position = center
	parent.add_child(field)
	
	create_box(Vector3(sx, 0.15, sz), mat_sunflower_leaf, Vector3(0, 0.075, 0), field)
	
	# Matrice geometrica di steli e corolle di girasole
	var step_x = 4.2; var step_z = 4.2
	var nx = int(sx / step_x); var nz = int(sz / step_z)
	for ix in range(nx):
		for iz in range(nz):
			var px = -sx * 0.5 + float(ix) * step_x + 2.1
			var pz = -sz * 0.5 + float(iz) * step_z + 2.1
			# Fusto verde
			create_cylinder(0.04, 1.4, mat_sunflower_leaf, Vector3(px, 0.7, pz), 0.0, field)
			# Disco centrale bruno
			var flower_center = create_cylinder(0.38, 0.08, mat_sunflower_center, Vector3(px, 1.45, pz + 0.12), deg_to_rad(45.0), field)
			# Corona petali dorati
			create_cylinder(0.72, 0.04, mat_sunflower_petal, Vector3(px, 1.44, pz + 0.11), deg_to_rad(45.0), field)

static func build_vineyard_rows(parent: Node3D, center: Vector3, sx: float, sz: float, num_rows: int):
	var vineyard = Node3D.new()
	vineyard.name = "Vineyard"
	vineyard.position = center
	parent.add_child(vineyard)
	
	create_box(Vector3(sx, 0.14, sz), mat_dirt_road, Vector3(0, 0.07, 0), vineyard)
	
	var row_spacing = sx / float(num_rows + 1)
	for ri in range(num_rows):
		var rx = -sx * 0.5 + float(ri + 1) * row_spacing
		# Filare continuo di viti a spalliera
		create_box(Vector3(0.65, 1.4, sz * 0.94), mat_vine_leaf, Vector3(rx, 0.75, 0), vineyard)
		# Pali di testata e intermedi in castagno
		var num_posts = int(sz / 8.0)
		for pi in range(num_posts):
			var pz = -sz * 0.46 + float(pi) * 8.0
			create_cylinder(0.08, 1.7, mat_staccionata_wood, Vector3(rx, 0.85, pz), 0.0, vineyard)

static func build_pasture_with_fence(parent: Node3D, center: Vector3, sx: float, sz: float):
	var pas = Node3D.new()
	pas.name = "Pasture"
	pas.position = center
	parent.add_child(pas)
	
	# Staccionata perimetrale completa
	var hx = sx * 0.5; var hz = sz * 0.5
	var step = 4.5
	for side_i in range(4):
		var count = int(sx / step) if (side_i % 2 == 0) else int(sz / step)
		for si in range(count):
			var t = -0.5 + (float(si) + 0.5) / float(count)
			var px = 0.0; var pz = 0.0
			var rot_bar = 0.0
			if side_i == 0: # Nord
				px = t * sx; pz = -hz
			elif side_i == 1: # Est
				px = hx; pz = t * sz; rot_bar = deg_to_rad(90.0)
			elif side_i == 2: # Sud
				px = t * sx; pz = hz
			elif side_i == 3: # Ovest
				px = -hx; pz = t * sz; rot_bar = deg_to_rad(90.0)
				
			create_cylinder(0.08, 1.3, mat_staccionata_wood, Vector3(px, 0.65, pz), 0.0, pas)
			var bar = create_box(Vector3(step, 0.07, 0.07), mat_staccionata_wood, Vector3(px, 0.9, pz), pas)
			bar.rotation.y = rot_bar

# ==============================================================================
# 3. CASCINA "CORTE SAN GIORGIO" (FATTORIA PADANA CON AIA, FIENILE & SILO)
# ==============================================================================
static func build_cascina_san_giorgio(parent: Node3D, pos: Vector3, rot_y: float):
	var cascina = Node3D.new()
	cascina.name = "CascinaCorteSanGiorgio"
	cascina.position = pos
	cascina.rotation.y = rot_y
	parent.add_child(cascina)
	
	# 1. Grande Aia della Cascina (Cortile in terra battuta e ghiaia 38m x 32m)
	create_box_with_col(Vector3(38.0, 0.22, 32.0), mat_dirt_road, Vector3(0, 0.11, 0), cascina)
	
	# 2. Casale Padano Principale a 2 Piani (Abitazione rurale 16m x 8.5m x 8.5m)
	var house_pos = Vector3(-8.0, 0, -8.0)
	create_box_with_col(Vector3(16.0, 8.5, 8.5), mat_farm_brick, house_pos + Vector3(0, 4.25, 0), cascina)
	create_gable_roof(16.0, 8.5, 2.6, 0.55, mat_terracotta_roof, house_pos + Vector3(0, 8.5, 0), 0.0, cascina)
	create_chimney(house_pos + Vector3(-5.0, 10.5, 2.0), 1.2, cascina)
	
	# Finestre rurali con persiane in legno
	for fi in [1, 2]:
		var wy = 1.6 + float(fi - 1) * 3.4
		for xi in [-5.5, -1.8, 1.8, 5.5]:
			create_historic_window(house_pos + Vector3(xi, wy, 4.3), 0.0, 1.1, 1.6, mat_fienile_timber, cascina)
			
	# Portone d'ingresso in legno massiccio
	create_box(Vector3(1.8, 2.8, 0.15), mat_fienile_timber, house_pos + Vector3(0, 1.4, 4.3), cascina)
	
	# 3. Grande Fienile Aperto / Barchessa (14m x 7.5m x 7m)
	var barn_pos = Vector3(10.0, 0, -8.0)
	create_box_with_col(Vector3(14.0, 0.35, 7.5), mat_farm_brick, barn_pos + Vector3(0, 0.18, 0), cascina)
	# Pilastri in mattoni del fienile
	for px in [-6.0, -2.0, 2.0, 6.0]:
		create_box_with_col(Vector3(0.85, 6.2, 0.85), mat_farm_brick, barn_pos + Vector3(px, 3.1, 3.2), cascina)
		create_box_with_col(Vector3(0.85, 6.2, 0.85), mat_farm_brick, barn_pos + Vector3(px, 3.1, -3.2), cascina)
	# Tetto del fienile
	create_gable_roof(14.5, 7.8, 2.4, 0.50, mat_terracotta_roof, barn_pos + Vector3(0, 6.2, 0), 0.0, cascina)
	# Cataste di balle di fieno dentro al fienile
	for bx in range(4):
		for by in range(3):
			create_box(Vector3(1.8, 0.85, 1.1), mat_straw_bale, barn_pos + Vector3(-4.5 + float(bx) * 2.2, 0.45 + float(by) * 0.9, -0.5), cascina)
			
	# 4. Silo Agricolo Metallico Circolare (Diametro 3.4m, Altezza 11.5m)
	var silo_pos = Vector3(17.0, 0, 4.0)
	create_cylinder_with_col(1.7, 9.5, mat_silo_steel, silo_pos + Vector3(0, 4.75, 0), cascina)
	# Cupola conica superiore
	var dome = MeshInstance3D.new()
	var d_cyl = CylinderMesh.new()
	d_cyl.top_radius = 0.1; d_cyl.bottom_radius = 1.85; d_cyl.height = 1.8; d_cyl.radial_segments = 16
	dome.mesh = d_cyl; dome.material_override = mat_silo_steel; dome.position = silo_pos + Vector3(0, 10.4, 0)
	cascina.add_child(dome)
	# Scaletta di salita in ferro
	create_box(Vector3(0.12, 9.5, 0.45), mat_tractor_iron, silo_pos + Vector3(1.75, 4.75, 0), cascina)
	
	# 5. Trattore Agricolo Storico Italiano (Fiat Trattori Arancione con Rimorchio)
	build_vintage_tractor_and_trailer(cascina, Vector3(-4.0, 0, 6.0), deg_to_rad(25.0))
	
	# 6. Pozzo dell'Aia in Pietra con Carrucola
	var well_pos = Vector3(-2.0, 0, -1.0)
	create_cylinder_with_col(1.1, 0.85, mat_farm_brick, well_pos + Vector3(0, 0.42, 0), cascina)
	create_cylinder(0.9, 0.1, mat_water_stream, well_pos + Vector3(0, 0.75, 0), 0.0, cascina)
	create_cylinder(0.04, 1.8, mat_fienile_timber, well_pos + Vector3(-0.95, 1.3, 0), 0.0, cascina)
	create_cylinder(0.04, 1.8, mat_fienile_timber, well_pos + Vector3(0.95, 1.3, 0), 0.0, cascina)
	create_box(Vector3(2.1, 0.08, 0.08), mat_fienile_timber, well_pos + Vector3(0, 2.2, 0), cascina)
	create_cylinder(0.18, 0.06, mat_tractor_iron, well_pos + Vector3(0, 2.05, 0), deg_to_rad(90.0), cascina)

static func build_vintage_tractor_and_trailer(parent: Node3D, pos: Vector3, rot_y: float):
	var root = Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	parent.add_child(root)
	
	# Cofano motore e telaio
	create_box_with_col(Vector3(1.1, 0.75, 2.2), mat_tractor_orange, Vector3(0, 0.85, 0.4), root)
	create_box(Vector3(0.95, 0.55, 0.08), mat_tractor_iron, Vector3(0, 0.85, 1.55), root) # Calandra radiatore
	# Parafanghi posteriori ricurvi
	create_box(Vector3(0.35, 0.65, 1.3), mat_tractor_orange, Vector3(-0.75, 1.15, -0.6), root)
	create_box(Vector3(0.35, 0.65, 1.3), mat_tractor_orange, Vector3(0.75, 1.15, -0.6), root)
	# Sedile a conca e volante
	create_box(Vector3(0.48, 0.12, 0.45), mat_tractor_iron, Vector3(0, 1.25, -0.6), root)
	create_cylinder(0.24, 0.04, mat_tractor_iron, Vector3(0, 1.55, -0.1), deg_to_rad(30.0), root)
	# Tubo di scappamento verticale con parapioggia
	create_cylinder(0.045, 1.3, mat_tractor_iron, Vector3(-0.48, 1.65, 1.1), 0.0, root)
	
	# Ruote posteriori grandi con battistrada
	create_cylinder_with_col(0.72, 0.38, mat_tractor_iron, Vector3(-0.75, 0.72, -0.6), deg_to_rad(90.0), root)
	create_cylinder_with_col(0.72, 0.38, mat_tractor_iron, Vector3(0.75, 0.72, -0.6), deg_to_rad(90.0), root)
	# Ruote anteriori piccole direzionali
	create_cylinder_with_col(0.42, 0.22, mat_tractor_iron, Vector3(-0.62, 0.42, 1.2), deg_to_rad(90.0), root)
	create_cylinder_with_col(0.42, 0.22, mat_tractor_iron, Vector3(0.62, 0.42, 1.2), deg_to_rad(90.0), root)
	
	# Rimorchio agricolo a due ruote attaccato al gancio
	var trailer_z = -3.2
	create_box_with_col(Vector3(1.7, 0.85, 2.8), mat_fienile_timber, Vector3(0, 0.95, trailer_z), root)
	create_box(Vector3(0.12, 0.12, 1.4), mat_tractor_iron, Vector3(0, 0.52, -1.8), root) # Timone
	create_cylinder_with_col(0.55, 0.28, mat_tractor_iron, Vector3(-0.95, 0.55, trailer_z), deg_to_rad(90.0), root)
	create_cylinder_with_col(0.55, 0.28, mat_tractor_iron, Vector3(0.95, 0.55, trailer_z), deg_to_rad(90.0), root)
	# Carico di sacchi di semente / grano
	for si in range(3):
		create_box(Vector3(1.4, 0.45, 0.75), mat_straw_bale, Vector3(0, 1.45, trailer_z - 0.7 + float(si) * 0.7), root)

# ==============================================================================
# 4. ANTICO MULINO AD ACQUA & RUSCELLO CHIARO (CON PONTE IN PIETRA SULLA STATALE)
# ==============================================================================
static func build_watermill_and_stream(parent: Node3D, points: Array, mid_p: Dictionary):
	var stream_root = Node3D.new()
	stream_root.name = "RuscelloChiaroAndMill"
	parent.add_child(stream_root)
	
	var water_y = mid_p.y - 1.15
	
	# 1. Alveo del ruscello che attraversa la campagna da X = -80 a X = +80
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_water_stream)
	
	var num_segs = 16
	var w_width = 5.8
	var prev_l = Vector3.ZERO; var prev_r = Vector3.ZERO
	for si in range(num_segs + 1):
		var t = float(si) / float(num_segs)
		var sx = lerp(-75.0, 75.0, t)
		var sz = mid_p.z + sin(t * TAU * 1.5) * 6.5
		var l = Vector3(sx, water_y, sz - w_width * 0.5)
		var r = Vector3(sx, water_y, sz + w_width * 0.5)
		if si > 0:
			st.set_normal(Vector3.UP)
			st.set_uv(Vector2(0, t * 10.0)); st.add_vertex(prev_l)
			st.set_uv(Vector2(1, t * 10.0)); st.add_vertex(prev_r)
			st.set_uv(Vector2(1, (t + 0.1) * 10.0)); st.add_vertex(r)
			st.set_normal(Vector3.UP)
			st.set_uv(Vector2(0, t * 10.0)); st.add_vertex(prev_l)
			st.set_uv(Vector2(1, (t + 0.1) * 10.0)); st.add_vertex(r)
			st.set_uv(Vector2(0, (t + 0.1) * 10.0)); st.add_vertex(l)
		prev_l = l; prev_r = r
		
	st.generate_normals()
	var w_mesh = MeshInstance3D.new()
	w_mesh.mesh = st.commit()
	w_mesh.material_override = mat_water_stream
	stream_root.add_child(w_mesh)
	
	# 2. Ponte in Pietra sulla Statale (Parapetti in muratura ad arco che seguono l'esatta curvatura della strada)
	var stream_z = mid_p.z
	var bridge_pts: Array = []
	for pt in points:
		if abs(pt.z - stream_z) <= 9.5:
			bridge_pts.append(pt)
	if bridge_pts.size() < 2:
		bridge_pts = [mid_p]
		
	for b_i in range(bridge_pts.size() - 1):
		var bp1 = bridge_pts[b_i]
		var bp2 = bridge_pts[b_i + 1]
		var b_ang1 = bp1.get("angle", 0.0)
		var b_ang2 = bp2.get("angle", 0.0)
		var n1 = Vector3(cos(b_ang1), 0.0, -sin(b_ang1))
		var n2 = Vector3(cos(b_ang2), 0.0, -sin(b_ang2))
		var b_hw1 = bp1.width * 0.5
		var b_hw2 = bp2.width * 0.5
		
		for b_side in [-1.0, 1.0]:
			var wall_p1 = Vector3(bp1.x, bp1.y, bp1.z) + n1 * b_side * (b_hw1 + 0.48)
			var wall_p2 = Vector3(bp2.x, bp2.y, bp2.z) + n2 * b_side * (b_hw2 + 0.48)
			var w_vec = wall_p2 - wall_p1
			var w_len = w_vec.length()
			if w_len > 0.05:
				var wall_box = create_box_with_col(Vector3(0.40, 1.10, w_len * 1.02), mat_stone_bridge, (wall_p1 + wall_p2) * 0.5 + Vector3(0.0, 0.55, 0.0), stream_root)
				wall_box.rotation.y = atan2(w_vec.x, w_vec.z)
				
	# Cippi di testata monumentali del ponte in pietra ai 4 angoli (esterni alla carreggiata)
	if bridge_pts.size() >= 2:
		var start_pt = bridge_pts[0]
		var end_pt = bridge_pts[bridge_pts.size() - 1]
		var sn = Vector3(cos(start_pt.get("angle", 0.0)), 0, -sin(start_pt.get("angle", 0.0)))
		var en = Vector3(cos(end_pt.get("angle", 0.0)), 0, -sin(end_pt.get("angle", 0.0)))
		for b_side in [-1.0, 1.0]:
			var p_cippo_s = Vector3(start_pt.x, start_pt.y, start_pt.z) + sn * b_side * (start_pt.width * 0.5 + 0.48)
			create_box(Vector3(0.55, 1.35, 0.55), mat_stone_bridge, p_cippo_s + Vector3(0.0, 0.67, 0.0), stream_root)
			var p_cippo_e = Vector3(end_pt.x, end_pt.y, end_pt.z) + en * b_side * (end_pt.width * 0.5 + 0.48)
			create_box(Vector3(0.55, 1.35, 0.55), mat_stone_bridge, p_cippo_e + Vector3(0.0, 0.67, 0.0), stream_root)
			
	# 3. Edificio dell'Antico Mulino ad Acqua (a quota ruscello, lato sinistro)
	var mill_pos = Vector3(mid_p.x - 38.0, water_y + 0.1, mid_p.z - 6.0)
	create_box_with_col(Vector3(12.0, 7.5, 9.5), mat_stone_bridge, mill_pos + Vector3(0, 3.75, 0), stream_root)
	create_gable_roof(12.5, 10.0, 2.5, 0.45, mat_terracotta_roof, mill_pos + Vector3(0, 7.5, 0), 0.0, stream_root)
	create_chimney(mill_pos + Vector3(3.5, 9.5, 2.0), 1.2, stream_root)
	
	# Finestrelle del mulino
	create_historic_window(mill_pos + Vector3(0, 4.2, 4.8), 0.0, 1.1, 1.5, mat_fienile_timber, stream_root)
	create_box(Vector3(1.8, 2.6, 0.15), mat_fienile_timber, mill_pos + Vector3(-2.8, 1.3, 4.8), stream_root)
	
	# 4. GRANDE RUOTA AD ACQUA A PALE IN LEGNO (Diametro 4.4m, rotante nella gora)
	var wheel_pos = mill_pos + Vector3(6.3, 2.2, 0.0)
	create_cylinder(0.18, 0.65, mat_tractor_iron, wheel_pos, deg_to_rad(90.0), stream_root)
	# Cerchi esterni in legno
	create_cylinder(2.2, 0.12, mat_water_wheel_wood, wheel_pos + Vector3(0, 0, -0.25), deg_to_rad(90.0), stream_root)
	create_cylinder(2.2, 0.12, mat_water_wheel_wood, wheel_pos + Vector3(0, 0, 0.25), deg_to_rad(90.0), stream_root)
	# 8 Pale radiali in legno
	for paddle_i in range(8):
		var p_ang = float(paddle_i) * (TAU / 8.0)
		var paddle = create_box(Vector3(0.08, 0.75, 0.55), mat_water_wheel_wood, wheel_pos + Vector3(cos(p_ang) * 1.8, sin(p_ang) * 1.8, 0), stream_root)
		paddle.rotation.z = p_ang
		
	# 5. Salici Piangenti lungo le sponde del ruscello
	for tree_i in [-1, 1]:
		var tree_x = mid_p.x - 22.0 + float(tree_i) * 14.0
		var tree_z = mid_p.z - 8.0 + float(tree_i) * 16.0
		build_willow_tree(stream_root, Vector3(tree_x, water_y + 0.2, tree_z))

static func build_willow_tree(parent: Node3D, pos: Vector3):
	var willow = Node3D.new()
	willow.position = pos
	parent.add_child(willow)
	
	# Tronco gnarled
	create_cylinder(0.35, 3.2, mat_fienile_timber, Vector3(0, 1.6, 0), 0.0, willow)
	# Chioma spiovente a cupola verde salice
	create_cylinder(2.2, 2.4, mat_reed, Vector3(0, 3.8, 0), 0.0, willow)
	create_cylinder(3.2, 1.4, mat_reed, Vector3(0, 3.0, 0), 0.0, willow)

# ==============================================================================
# 5. PODERE BELVEDERE & VIGNETI (COLLINA TOSCANA, BOTTIGLIE & CIPRESSI)
# ==============================================================================
static func build_podere_belvedere(parent: Node3D, pos: Vector3, rot_y: float):
	var podere = Node3D.new()
	podere.name = "PodereBelvedere"
	podere.position = pos
	podere.rotation.y = rot_y
	parent.add_child(podere)
	
	# 1. Piattaforma collinare in pietra
	create_box_with_col(Vector3(28.0, 0.45, 24.0), mat_dirt_road, Vector3(0, 0.22, 0), podere)
	
	# 2. Villa Padronale in Pietra & Mattoni (13m x 8m x 8m)
	create_box_with_col(Vector3(13.0, 8.0, 8.0), mat_farm_plaster, Vector3(0, 4.0, 0), podere)
	create_hipped_roof(13.0, 8.0, 2.4, 0.50, mat_terracotta_roof, Vector3(0, 8.0, 0), podere)
	create_chimney(Vector3(-4.0, 10.0, 1.5), 1.2, podere)
	
	for fi in [1, 2]:
		var wy = 1.6 + float(fi - 1) * 3.4
		for xi in [-4.2, 0.0, 4.2]:
			create_historic_window(Vector3(xi, wy, 4.05), 0.0, 1.1, 1.6, mat_staccionata_wood, podere)
			
	# 3. Cantina con Botti di Rovere all'Aperto
	for bi in range(3):
		var barrel = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.55; cyl.bottom_radius = 0.55; cyl.height = 1.35; cyl.radial_segments = 14
		barrel.mesh = cyl; barrel.material_override = mat_fienile_timber
		barrel.rotation.x = deg_to_rad(90.0)
		barrel.position = Vector3(8.5, 0.65, -4.0 + float(bi) * 1.6)
		podere.add_child(barrel)
		
	# 4. Forno a Legna Esterno in Pietra con Cupola
	var oven_pos = Vector3(-8.5, 0, -4.0)
	create_box_with_col(Vector3(2.4, 1.1, 2.4), mat_stone_bridge, oven_pos + Vector3(0, 0.55, 0), podere)
	var oven_dome = MeshInstance3D.new()
	var od_cyl = CylinderMesh.new()
	od_cyl.top_radius = 0.2; od_cyl.bottom_radius = 1.15; od_cyl.height = 0.9; od_cyl.radial_segments = 14
	oven_dome.mesh = od_cyl; oven_dome.material_override = mat_farm_brick; oven_dome.position = oven_pos + Vector3(0, 1.55, 0)
	podere.add_child(oven_dome)
	create_cylinder(0.08, 1.2, mat_tractor_iron, oven_pos + Vector3(0, 2.4, 0), 0.0, podere)

# ==============================================================================
# 6. LAGO DEI SALICI (BACINO LACUSTRE TRANQUILLO, CANNETO & PONTILE)
# ==============================================================================
static func build_lago_dei_salici(parent: Node3D, pos: Vector3):
	var lake = Node3D.new()
	lake.name = "LagoDeiSalici"
	lake.position = pos
	parent.add_child(lake)
	
	# Specchio d'acqua ovale (45m x 70m)
	var water = MeshInstance3D.new()
	var w_cyl = CylinderMesh.new()
	w_cyl.top_radius = 24.0; w_cyl.bottom_radius = 24.0; w_cyl.height = 0.12; w_cyl.radial_segments = 28
	water.mesh = w_cyl; water.material_override = mat_water_stream; water.scale = Vector3(1.0, 1.0, 1.55)
	lake.add_child(water)
	
	# Pontile in Legno per Pescatori (14m x 2.2m)
	var pier_pos = Vector3(-16.0, 0.45, 0)
	create_box_with_col(Vector3(14.0, 0.22, 2.2), mat_staccionata_wood, pier_pos, lake)
	for pi in range(5):
		var px = pier_pos.x - 6.0 + float(pi) * 3.0
		create_cylinder_with_col(0.12, 1.8, mat_fienile_timber, Vector3(px, -0.4, pier_pos.z - 1.0), lake)
		create_cylinder_with_col(0.12, 1.8, mat_fienile_timber, Vector3(px, -0.4, pier_pos.z + 1.0), lake)
		
	# Barchette a Remi in Legno Ormeggiate
	for bi in [0, 1]:
		var boat = Node3D.new()
		boat.position = Vector3(pier_pos.x + 4.0 + float(bi) * 4.5, 0.15, pier_pos.z + (2.2 if bi == 0 else -2.2))
		boat.rotation.y = deg_to_rad(15.0 if bi == 0 else -10.0)
		lake.add_child(boat)
		create_box(Vector3(3.2, 0.55, 1.4), mat_fienile_timber, Vector3(0, 0.28, 0), boat)
		create_box(Vector3(2.8, 0.45, 1.1), mat_staccionata_wood, Vector3(0, 0.35, 0), boat) # Scafo cavo
		create_box(Vector3(0.08, 0.12, 1.2), mat_straw_bale, Vector3(0, 0.32, 0), boat) # Panca
		
	# Canneto lungo le sponde del lago
	for ci in range(16):
		var cang = float(ci) * (TAU / 16.0)
		var cx = cos(cang) * 23.0; var cz = sin(cang) * 34.0
		create_cylinder(0.45, 2.2, mat_reed, Vector3(cx, 0.8, cz), 0.0, lake)

# ==============================================================================
# 7. COLLINE DA CONTORNO
# ==============================================================================
static func build_surrounding_hills(parent: Node3D, mid_p: Dictionary):
	var hills = Node3D.new()
	hills.name = "SurroundingHills"
	parent.add_child(hills)
	
	# Muri a secco e filari di cipressi sui dossi collinari laterali (X = -180m e +180m)
	for side in [-1.0, 1.0]:
		var hx = mid_p.x + side * 175.0
		var hy = mid_p.y + 4.5 + sin(mid_p.z * 0.015) * 3.5
		# Filare di cipressi toscani
		for ci in range(3):
			var cz = mid_p.z - 35.0 + float(ci) * 35.0
			var cyp = Node3D.new()
			cyp.position = Vector3(hx + side * randf_range(-10.0, 10.0), hy, cz)
			hills.add_child(cyp)
			create_cylinder(0.24, 2.5, mat_fienile_timber, Vector3(0, 1.25, 0), 0.0, cyp)
			create_cylinder(1.1, 5.5, mat_vine_leaf, Vector3(0, 4.5, 0), 0.0, cyp)
			
		# Muretto a secco rustico
		create_box(Vector3(0.45, 0.95, 45.0), mat_stone_bridge, Vector3(hx - side * 8.0, hy + 0.45, mid_p.z), hills)

# ==============================================================================
# HELPER GENERATORS
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
	var bs = BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	sb.add_child(cs)
	mi.add_child(sb)
	return mi

static func create_cylinder(radius: float, height: float, mat: Material, pos: Vector3, rot_x: Variant = 0.0, parent: Node3D = null) -> MeshInstance3D:
	var actual_rot: float = 0.0
	var actual_parent: Node3D = parent
	if rot_x is Node3D:
		actual_parent = rot_x
	elif rot_x is float or rot_x is int:
		actual_rot = float(rot_x)
	var mi = MeshInstance3D.new()
	var c = CylinderMesh.new()
	c.top_radius = radius; c.bottom_radius = radius; c.height = height; c.radial_segments = 14
	mi.mesh = c; mi.material_override = mat; mi.position = pos; mi.rotation.x = actual_rot
	if actual_parent: actual_parent.add_child(mi)
	return mi

static func create_cylinder_with_col(radius: float, height: float, mat: Material, pos: Vector3, rot_x: Variant = 0.0, parent: Node3D = null) -> MeshInstance3D:
	var actual_rot: float = 0.0
	var actual_parent: Node3D = parent
	if rot_x is Node3D:
		actual_parent = rot_x
	elif rot_x is float or rot_x is int:
		actual_rot = float(rot_x)
	var mi = create_cylinder(radius, height, mat, pos, actual_rot, actual_parent)
	var sb = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	var cyl_shape = CylinderShape3D.new()
	cyl_shape.radius = radius; cyl_shape.height = height
	cs.shape = cyl_shape
	sb.add_child(cs)
	mi.add_child(sb)
	return mi

static func create_gable_roof(w: float, d: float, h: float, overhang: float, mat: Material, pos: Vector3, rot_y: float = 0.0, parent: Node3D = null) -> Node3D:
	var root = Node3D.new()
	root.position = pos; root.rotation.y = rot_y
	if parent: parent.add_child(root)
	create_box(Vector3(w + overhang * 1.6, 0.22, d + overhang * 1.6), mat_stone_bridge, Vector3(0, 0.11, 0), root)
	var pm = PrismMesh.new()
	pm.left_to_right = 0.5
	pm.size = Vector3(w + overhang * 2.0, h, d + overhang * 2.0)
	var p_mi = MeshInstance3D.new()
	p_mi.mesh = pm; p_mi.material_override = mat; p_mi.position = Vector3(0, 0.22 + h * 0.5, 0)
	root.add_child(p_mi)
	create_box(Vector3(0.35, 0.18, d + overhang * 2.2), mat_stone_bridge, Vector3(0, 0.22 + h + 0.05, 0), root)
	return root

static func create_hipped_roof(w: float, d: float, h: float, overhang: float, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	var hw = (w * 0.5) + overhang; var hd = (d * 0.5) + overhang
	create_box(Vector3(w + overhang * 1.5, 0.22, d + overhang * 1.5), mat_stone_bridge, pos + Vector3(0, 0.11, 0), parent)
	var c_fl = Vector3(-hw, 0.22, -hd); var c_fr = Vector3(hw, 0.22, -hd)
	var c_br = Vector3(hw, 0.22, hd); var c_bl = Vector3(-hw, 0.22, hd)
	var rw = max(0.2, hw - hd)
	var r_l = Vector3(-rw, h, 0.0); var r_r = Vector3(rw, h, 0.0)
	add_quad_st(st, c_fl, c_fr, r_r, r_l)
	add_quad_st(st, c_br, c_bl, r_l, r_r)
	add_tri_st(st, c_bl, c_fl, r_l)
	add_tri_st(st, c_fr, c_br, r_r)
	st.generate_normals()
	mi.mesh = st.commit(); mi.position = pos
	if parent: parent.add_child(mi)
	return mi

static func add_tri_st(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3):
	var uv_s = 0.4
	st.set_uv(Vector2(p1.x, p1.z) * uv_s); st.add_vertex(p1)
	st.set_uv(Vector2(p2.x, p2.z) * uv_s); st.add_vertex(p2)
	st.set_uv(Vector2(p3.x, p3.z) * uv_s); st.add_vertex(p3)

static func add_quad_st(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3):
	add_tri_st(st, p1, p2, p3)
	add_tri_st(st, p1, p3, p4)

static func create_chimney(pos: Vector3, h: float, parent: Node3D = null) -> Node3D:
	var ch = Node3D.new()
	ch.position = pos
	if parent: parent.add_child(ch)
	create_box(Vector3(0.65, h, 0.65), mat_farm_brick, Vector3(0, h * 0.5, 0), ch)
	create_box(Vector3(0.85, 0.12, 0.85), mat_stone_bridge, Vector3(0, h + 0.06, 0), ch)
	create_cylinder(0.12, 0.28, mat_farm_brick, Vector3(-0.18, h + 0.24, 0), 0.0, ch)
	create_cylinder(0.12, 0.28, mat_farm_brick, Vector3(0.18, h + 0.24, 0), 0.0, ch)
	return ch

static func create_historic_window(pos: Vector3, rot_y: float, w: float, h: float, shutter_mat: Material, parent: Node3D = null) -> Node3D:
	var win = Node3D.new()
	win.position = pos; win.rotation.y = rot_y
	if parent: parent.add_child(win)
	create_box(Vector3(w + 0.35, 0.10, 0.32), mat_stone_bridge, Vector3(0, -h * 0.5 - 0.05, 0.10), win)
	create_box(Vector3(w + 0.25, 0.12, 0.20), mat_stone_bridge, Vector3(0, h * 0.5 + 0.06, 0.04), win)
	create_box(Vector3(w, h, 0.06), mat_farm_plaster, Vector3(0, 0, -0.04), win)
	var sw = w * 0.52
	var sh_l = create_box(Vector3(sw, h * 0.96, 0.06), shutter_mat, Vector3(-w * 0.5 - sw * 0.45, 0, 0.12), win)
	sh_l.rotation.y = deg_to_rad(22.0)
	var sh_r = create_box(Vector3(sw, h * 0.96, 0.06), shutter_mat, Vector3(w * 0.5 + sw * 0.45, 0, 0.12), win)
	sh_r.rotation.y = deg_to_rad(-22.0)
	return win
