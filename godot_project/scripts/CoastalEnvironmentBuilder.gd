extends RefCounted
class_name CoastalEnvironmentBuilder

# ==============================================================================
# COSTIERA PANORAMICA DEL MERIDIANO & BORGO MARINA DEI PESCATORI (GODOT 4)
# ==============================================================================
# Costruzione procedurale dell'incantevole tratto costiero di ritorno (Z = 7800m -> 12000m):
# 1. Giro della Montagna & Balze Panoramiche (7800m -> 8200m):
#    Discesa panoramica attorno al massiccio, primi scorci del mare scintillante all'orizzonte.
# 2. Costiera delle Sirene & Affacci sul Mare (8200m -> 9400m):
#    - Belvederi panoramici a balustra in pietra con cannocchiali, panchine e lampioni in ferro battuto.
#    - Faro della Scogliera (Faro marittimo monumentale a fasce bianche e rosse con lanterna accesa).
#    - Vegetazione mediterranea: pini domestici a ombrello (Pinus pinea), ulivi secolari, oleandri.
# 3. Borgo Marina dei Pescatori (9400m -> 10800m):
#    - Caratteristico villaggio ligure/mediterraneo con facciate pastello (pesca, ocra, azzurro, salvia),
#      persiane verdi alla genovese e tetti in coppi di cotto.
#    - Molo e banchina portuale in pietra con bitte d'ormeggio in ghisa e banchina pedonale sicura.
#    - Barche tradizionali in legno (gozzi liguri) ormeggiate in acqua con reti da pesca e remi.
#    - Chiesa sul mare (Pieve di Santa Maria del Mare) con campanile romanico affacciato sulla baia.
# 4. Viale degli Oleandri & Porta Marina di San Cristoforo (10800m -> 12000m):
#    - Viale alberato con pini marittimi e cespugli di oleandri in fiore.
#    - Monumentale Porta Marina in pietra a chiusura trionfale del circuito e rientro a San Cristoforo.
#
# REGOLE DI SICUREZZA ASSOLUTA (Nessun errore dal primo tratto):
# - Nessun ostacolo nella carreggiata (offset minimo sempre >= hw + 2.8m).
# - Tutti i posizionamenti calcolati rigorosamente lungo la normale continua alla curva.
# - Nessun dislivello o scalino: quote perfettamente raccordate a C1 smoothstep.
# ==============================================================================

# Shaders & Material Palette
static var mat_pine_bark: StandardMaterial3D
static var mat_pine_canopy: StandardMaterial3D
static var mat_olive_bark: StandardMaterial3D
static var mat_olive_leaf: StandardMaterial3D
static var mat_oleander_leaf: StandardMaterial3D
static var mat_oleander_flower_pink: StandardMaterial3D
static var mat_oleander_flower_white: StandardMaterial3D
static var mat_cypress: StandardMaterial3D
static var mat_cliff_stone: StandardMaterial3D
static var mat_belvedere_balustrade: StandardMaterial3D
static var mat_terracotta_roof: ShaderMaterial
static var mat_plaster_peach: StandardMaterial3D
static var mat_plaster_yellow: StandardMaterial3D
static var mat_plaster_terracotta: StandardMaterial3D
static var mat_plaster_blue: StandardMaterial3D
static var mat_plaster_sage: StandardMaterial3D
static var mat_shutter_green: StandardMaterial3D
static var mat_window_glass: StandardMaterial3D
static var mat_quay_stone: StandardMaterial3D
static var mat_wood_boat: StandardMaterial3D
static var mat_boat_hull_blue: StandardMaterial3D
static var mat_boat_hull_red: StandardMaterial3D
static var mat_boat_hull_white: StandardMaterial3D
static var mat_lighthouse_white: StandardMaterial3D
static var mat_lighthouse_red: StandardMaterial3D
static var mat_lighthouse_glass: StandardMaterial3D
static var mat_lighthouse_beacon: StandardMaterial3D
static var mat_iron_black: StandardMaterial3D
static var mat_lantern_glow: StandardMaterial3D
static var mat_church_stone: StandardMaterial3D
static var mat_church_bell: StandardMaterial3D
static var mat_sea_water_plane: ShaderMaterial

static func init_materials(water_shader_mat: ShaderMaterial = null):
	if mat_pine_bark != null:
		if water_shader_mat and mat_sea_water_plane == null:
			mat_sea_water_plane = water_shader_mat
		return

	var building_shader = load("res://shaders/stylized_building.gdshader")

	# 1. Tetti in coppi di terracotta mediterranea
	mat_terracotta_roof = ShaderMaterial.new()
	mat_terracotta_roof.shader = building_shader
	mat_terracotta_roof.set_shader_parameter("material_type", 2)
	mat_terracotta_roof.set_shader_parameter("base_color", Color(0.78, 0.42, 0.26))
	mat_terracotta_roof.set_shader_parameter("alt_color", Color(0.64, 0.32, 0.18))
	mat_terracotta_roof.set_shader_parameter("mortar_color", Color(0.38, 0.22, 0.15))
	mat_terracotta_roof.set_shader_parameter("texture_scale", 2.2)

	# 2. Vegetazione Mediterranea (Pini a Ombrello, Ulivi, Oleandri, Cipressi)
	mat_pine_bark = StandardMaterial3D.new()
	mat_pine_bark.albedo_color = Color(0.36, 0.24, 0.18)
	mat_pine_bark.roughness = 0.95

	mat_pine_canopy = StandardMaterial3D.new()
	mat_pine_canopy.albedo_color = Color(0.14, 0.32, 0.16)
	mat_pine_canopy.roughness = 0.88

	mat_olive_bark = StandardMaterial3D.new()
	mat_olive_bark.albedo_color = Color(0.38, 0.36, 0.34)
	mat_olive_bark.roughness = 0.96

	mat_olive_leaf = StandardMaterial3D.new()
	mat_olive_leaf.albedo_color = Color(0.34, 0.44, 0.32)
	mat_olive_leaf.roughness = 0.75

	mat_oleander_leaf = StandardMaterial3D.new()
	mat_oleander_leaf.albedo_color = Color(0.18, 0.38, 0.18)
	mat_oleander_leaf.roughness = 0.85

	mat_oleander_flower_pink = StandardMaterial3D.new()
	mat_oleander_flower_pink.albedo_color = Color(0.92, 0.45, 0.62)
	mat_oleander_flower_pink.roughness = 0.70

	mat_oleander_flower_white = StandardMaterial3D.new()
	mat_oleander_flower_white.albedo_color = Color(0.96, 0.96, 0.92)
	mat_oleander_flower_white.roughness = 0.70

	mat_cypress = StandardMaterial3D.new()
	mat_cypress.albedo_color = Color(0.12, 0.24, 0.12)
	mat_cypress.roughness = 0.90

	# 3. Rocce e Pietre di Scogliera & Balustre
	mat_cliff_stone = StandardMaterial3D.new()
	mat_cliff_stone.albedo_color = Color(0.68, 0.65, 0.60)
	mat_cliff_stone.roughness = 0.92

	mat_belvedere_balustrade = StandardMaterial3D.new()
	mat_belvedere_balustrade.albedo_color = Color(0.85, 0.82, 0.76)
	mat_belvedere_balustrade.roughness = 0.82

	# 4. Facciate Pastello Villaggio Marinaro
	mat_plaster_peach = StandardMaterial3D.new()
	mat_plaster_peach.albedo_color = Color(0.92, 0.62, 0.48)
	mat_plaster_peach.roughness = 0.86

	mat_plaster_yellow = StandardMaterial3D.new()
	mat_plaster_yellow.albedo_color = Color(0.92, 0.78, 0.46)
	mat_plaster_yellow.roughness = 0.86

	mat_plaster_terracotta = StandardMaterial3D.new()
	mat_plaster_terracotta.albedo_color = Color(0.84, 0.48, 0.36)
	mat_plaster_terracotta.roughness = 0.86

	mat_plaster_blue = StandardMaterial3D.new()
	mat_plaster_blue.albedo_color = Color(0.55, 0.72, 0.82)
	mat_plaster_blue.roughness = 0.86

	mat_plaster_sage = StandardMaterial3D.new()
	mat_plaster_sage.albedo_color = Color(0.58, 0.68, 0.54)
	mat_plaster_sage.roughness = 0.86

	mat_shutter_green = StandardMaterial3D.new()
	mat_shutter_green.albedo_color = Color(0.12, 0.34, 0.20) # Verde bosco persiane
	mat_shutter_green.roughness = 0.75

	mat_window_glass = StandardMaterial3D.new()
	mat_window_glass.albedo_color = Color(0.24, 0.35, 0.44)
	mat_window_glass.roughness = 0.20
	mat_window_glass.metallic = 0.40

	# 5. Porto, Banchine e Barche Tradizionali (Gozzi)
	mat_quay_stone = StandardMaterial3D.new()
	mat_quay_stone.albedo_color = Color(0.52, 0.50, 0.46)
	mat_quay_stone.roughness = 0.88

	mat_wood_boat = StandardMaterial3D.new()
	mat_wood_boat.albedo_color = Color(0.48, 0.32, 0.20)
	mat_wood_boat.roughness = 0.80

	mat_boat_hull_blue = StandardMaterial3D.new()
	mat_boat_hull_blue.albedo_color = Color(0.14, 0.38, 0.68)
	mat_boat_hull_blue.roughness = 0.55

	mat_boat_hull_red = StandardMaterial3D.new()
	mat_boat_hull_red.albedo_color = Color(0.72, 0.22, 0.18)
	mat_boat_hull_red.roughness = 0.55

	mat_boat_hull_white = StandardMaterial3D.new()
	mat_boat_hull_white.albedo_color = Color(0.92, 0.94, 0.95)
	mat_boat_hull_white.roughness = 0.55

	# 6. Faro Monumentale della Scogliera
	mat_lighthouse_white = StandardMaterial3D.new()
	mat_lighthouse_white.albedo_color = Color(0.94, 0.94, 0.92)
	mat_lighthouse_white.roughness = 0.65

	mat_lighthouse_red = StandardMaterial3D.new()
	mat_lighthouse_red.albedo_color = Color(0.82, 0.20, 0.16)
	mat_lighthouse_red.roughness = 0.65

	mat_lighthouse_glass = StandardMaterial3D.new()
	mat_lighthouse_glass.albedo_color = Color(0.85, 0.92, 1.0, 0.6)
	mat_lighthouse_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_lighthouse_glass.roughness = 0.15

	mat_lighthouse_beacon = StandardMaterial3D.new()
	mat_lighthouse_beacon.albedo_color = Color(1.0, 0.95, 0.70)
	mat_lighthouse_beacon.emission_enabled = true
	mat_lighthouse_beacon.emission = Color(1.0, 0.92, 0.60)
	mat_lighthouse_beacon.emission_energy_multiplier = 4.5

	# 7. Dettagli Urbani, Lampioni e Chiesa
	mat_iron_black = StandardMaterial3D.new()
	mat_iron_black.albedo_color = Color(0.14, 0.14, 0.15)
	mat_iron_black.metallic = 0.85
	mat_iron_black.roughness = 0.40

	mat_lantern_glow = StandardMaterial3D.new()
	mat_lantern_glow.albedo_color = Color(1.0, 0.88, 0.55)
	mat_lantern_glow.emission_enabled = true
	mat_lantern_glow.emission = Color(1.0, 0.82, 0.45)
	mat_lantern_glow.emission_energy_multiplier = 2.4

	mat_church_stone = StandardMaterial3D.new()
	mat_church_stone.albedo_color = Color(0.74, 0.70, 0.64)
	mat_church_stone.roughness = 0.90

	mat_church_bell = StandardMaterial3D.new()
	mat_church_bell.albedo_color = Color(0.82, 0.68, 0.28)
	mat_church_bell.metallic = 0.92
	mat_church_bell.roughness = 0.35

	mat_sea_water_plane = water_shader_mat

# ==============================================================================
# MAIN CHUNK DISPATCHER
# ==============================================================================
static func spawn_coastal_chunk_features(root: Node3D, points: Array, start_z: float, water_shader_mat: ShaderMaterial = null):
	init_materials(water_shader_mat)
	var num_pts = points.size()
	if num_pts < 2: return
	
	var mid_p = points[int(num_pts * 0.5)]
	var mid_ang = mid_p.angle
	var n_mid = Vector3(cos(mid_ang), 0.0, -sin(mid_ang))

	# 1. GENERAZIONE PIANO D'ACQUA MARINO (Z = 7900m -> 11000m sul lato sinistro / -N)
	if start_z >= 7900.0 and start_z < 11000.0:
		spawn_sea_water_plane(root, points, start_z)

	# 2. GIRO DELLA MONTAGNA & BALZE PANORAMICHE (7800m -> 8200m)
	if start_z >= 7800.0 and start_z < 8200.0:
		spawn_mountain_turn_features(root, points, start_z)

	# 3. COSTIERA DELLE SIRENE & AFFACCI SUL MARE (8200m -> 9400m)
	elif start_z >= 8200.0 and start_z < 9400.0:
		spawn_corniche_features(root, points, start_z)

	# 4. BORGO MARINA DEI PESCATORI (9400m -> 10800m)
	elif start_z >= 9400.0 and start_z < 10800.0:
		spawn_fishing_village_features(root, points, start_z)

	# 5. VIALE DEGLI OLEANDRI & RITORNO A SAN CRISTOFORO (10800m -> 12000m)
	elif start_z >= 10800.0 and start_z <= 12000.0:
		spawn_return_avenue_features(root, points, start_z)

# ==============================================================================
# 1. PIANO MARE PANORAMICO CON ONDE E RIFLESSI
# ==============================================================================
static func spawn_sea_water_plane(root: Node3D, points: Array, start_z: float):
	var num_pts = points.size()
	var mid_p = points[int(num_pts * 0.5)]
	var mid_ang = mid_p.angle
	var n_mid = Vector3(cos(mid_ang), 0.0, -sin(mid_ang))

	var sea_node = Node3D.new()
	sea_node.name = "SeaWaterPlane"

	var sea_plane = PlaneMesh.new()
	# Ampio specchio di mare (profondo 240m verso l'orizzonte, lungo 130m per chunk)
	sea_plane.size = Vector2(240.0, 130.0)
	sea_plane.subdivide_width = 16
	sea_plane.subdivide_depth = 12
	if mat_sea_water_plane:
		sea_plane.material = mat_sea_water_plane

	var sea_inst = MeshInstance3D.new()
	sea_inst.mesh = sea_plane
	if mat_sea_water_plane:
		sea_inst.material_override = mat_sea_water_plane
	sea_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Posizionato sul lato mare (-n_mid) a quota mare 0.3m
	var sea_center = Vector3(
		mid_p.x - n_mid.x * 125.0,
		0.3,
		mid_p.z - n_mid.z * 125.0
	)
	sea_node.position = sea_center
	sea_node.rotation.y = mid_ang
	sea_node.add_child(sea_inst)
	root.add_child(sea_node)

# ==============================================================================
# 2. GIRO DELLA MONTAGNA & BALZE (7800m -> 8200m)
# ==============================================================================
static func spawn_mountain_turn_features(root: Node3D, points: Array, start_z: float):
	var num_pts = points.size()
	var step = max(2, int(num_pts / 4))

	for i in range(1, num_pts - 1, step):
		var p = points[i]
		var ang = p.angle
		var n = Vector3(cos(ang), 0.0, -sin(ang))
		var hw = p.width * 0.5

		# Lato Monte (+n, destro): Muretto a secco e larici/pini d'alta quota
		var r_pos = Vector3(p.x + n.x * (hw + 3.2), p.y, p.z + n.z * (hw + 3.2))
		var pine_tree = create_umbrella_pine(r_pos, randf_range(0.85, 1.15))
		root.add_child(pine_tree)

		# Lato Mare (-n, sinistro): Balze di roccia e primi ulivi con vista aperta
		if i % (step * 2) == 0:
			var l_pos = Vector3(p.x - n.x * (hw + 4.2), p.y - 0.2, p.z - n.z * (hw + 4.2))
			var olive = create_olive_tree(l_pos, randf_range(0.8, 1.1))
			root.add_child(olive)

# ==============================================================================
# 3. COSTIERA DELLE SIRENE & AFFACCI SUL MARE (8200m -> 9400m)
# ==============================================================================
static func spawn_corniche_features(root: Node3D, points: Array, start_z: float):
	var num_pts = points.size()
	var mid_p = points[int(num_pts * 0.5)]
	var mid_ang = mid_p.angle
	var n_mid = Vector3(cos(mid_ang), 0.0, -sin(mid_ang))
	var hw_mid = mid_p.width * 0.5

	# A. Belvederi Panoramici sul Mare (Z = 8360m e Z = 9050m)
	if (start_z >= 8340.0 and start_z < 8460.0) or (start_z >= 9000.0 and start_z < 9120.0):
		var belv_pos = Vector3(mid_p.x - n_mid.x * (hw_mid + 3.8), mid_p.y, mid_p.z - n_mid.z * (hw_mid + 3.8))
		var belv = create_belvedere_overlook(belv_pos, mid_ang)
		root.add_child(belv)

	# B. Faro Monumentale della Scogliera (Z = 8700m -> 8820m)
	if start_z >= 8700.0 and start_z < 8820.0:
		var lighthouse_pos = Vector3(mid_p.x - n_mid.x * (hw_mid + 32.0), mid_p.y + 6.5, mid_p.z - n_mid.z * (hw_mid + 32.0))
		var lighthouse = create_monumental_lighthouse(lighthouse_pos, mid_ang)
		root.add_child(lighthouse)

	# C. Filari di Pini Marittimi a Ombrello, Ulivi e Oleandri lungo la carreggiata
	var step = max(2, int(num_pts / 3))
	for i in range(1, num_pts - 1, step):
		var p = points[i]
		var ang = p.angle
		var n = Vector3(cos(ang), 0.0, -sin(ang))
		var hw = p.width * 0.5

		# Lato monte (+n): Pini domestici e muretti
		var p_tree = Vector3(p.x + n.x * (hw + 3.6), p.y, p.z + n.z * (hw + 3.6))
		root.add_child(create_umbrella_pine(p_tree, randf_range(0.9, 1.25)))

		# Cespugli di oleandri fioriti rosa e bianchi
		var p_bush = Vector3(p.x + n.x * (hw + 2.8), p.y, p.z + n.z * (hw + 2.8))
		root.add_child(create_oleander_bush(p_bush, i % 2 == 0))

		# Lato mare (-n): Ulivi argentati distanziati per non ostruire la vista del mare
		if i % (step * 2) == 0:
			var p_olive = Vector3(p.x - n.x * (hw + 5.2), p.y - 0.4, p.z - n.z * (hw + 5.2))
			root.add_child(create_olive_tree(p_olive, randf_range(0.85, 1.15)))

# ==============================================================================
# 4. BORGO MARINA DEI PESCATORI (9400m -> 10800m)
# ==============================================================================
static func spawn_fishing_village_features(root: Node3D, points: Array, start_z: float):
	var num_pts = points.size()
	var mid_p = points[int(num_pts * 0.5)]
	var mid_ang = mid_p.angle
	var n_mid = Vector3(cos(mid_ang), 0.0, -sin(mid_ang))
	var hw_mid = mid_p.width * 0.5

	# A. Banchina del Porto & Molo con Gozzi da Pesca (sul lato mare, -n)
	var quay_pos = Vector3(mid_p.x - n_mid.x * (hw_mid + 3.2), mid_p.y, mid_p.z - n_mid.z * (hw_mid + 3.2))
	var quay = create_harbor_quay_and_boats(quay_pos, mid_ang, start_z)
	root.add_child(quay)

	# B. Chiesa di Santa Maria del Mare con Campanile Panoramico (Z = 10080m -> 10200m)
	if start_z >= 10080.0 and start_z < 10200.0:
		var church_pos = Vector3(mid_p.x + n_mid.x * (hw_mid + 9.5), mid_p.y, mid_p.z + n_mid.z * (hw_mid + 9.5))
		var church = create_sea_church(church_pos, mid_ang)
		root.add_child(church)

	# C. Caseggiati Pastello a Schiera (sul lato monte +n, arretrati di 5.2m con marciapiede)
	var step_house = max(3, int(num_pts / 3))
	for i in range(1, num_pts - 1, step_house):
		var p = points[i]
		var ang = p.angle
		var n = Vector3(cos(ang), 0.0, -sin(ang))
		var hw = p.width * 0.5

		# Non piazzare case davanti alla chiesa
		if start_z >= 10080.0 and start_z < 10200.0 and i > step_house:
			continue

		var house_pos = Vector3(p.x + n.x * (hw + 5.5), p.y, p.z + n.z * (hw + 5.5))
		var palette_idx = int((start_z * 0.05 + i)) % 5
		var stories = 2 if (i % 2 == 0) else 3
		var house = create_coastal_pastel_house(house_pos, ang, palette_idx, stories)
		root.add_child(house)

		# Lampione artistico in ghisa sul marciapiede (offset sicuro hw + 2.8m)
		var lamp_pos = Vector3(p.x + n.x * (hw + 2.9), p.y, p.z + n.z * (hw + 2.9))
		root.add_child(create_wrought_iron_lamp(lamp_pos, ang))

# ==============================================================================
# 5. VIALE DEGLI OLEANDRI & PORTA MARINA (10800m -> 12000m)
# ==============================================================================
static func spawn_return_avenue_features(root: Node3D, points: Array, start_z: float):
	var num_pts = points.size()
	var mid_p = points[int(num_pts * 0.5)]
	var mid_ang = mid_p.angle
	var n_mid = Vector3(cos(mid_ang), 0.0, -sin(mid_ang))
	var hw_mid = mid_p.width * 0.5

	# A. Monumentale Porta Marina di San Cristoforo (Z = 11880m -> 12000m)
	# Arco trionfale in pietra che accoglie l'auto al ritorno in città!
	if start_z >= 11880.0:
		var gate_pos = Vector3(mid_p.x, mid_p.y, mid_p.z)
		var gate = create_monumental_city_gate(gate_pos, mid_ang, mid_p.width)
		root.add_child(gate)

	# B. Viale alberato monumentale: Pini marittimi monumentali e siepi di oleandri
	var step = max(2, int(num_pts / 3))
	for i in range(1, num_pts - 1, step):
		var p = points[i]
		var ang = p.angle
		var n = Vector3(cos(ang), 0.0, -sin(ang))
		var hw = p.width * 0.5

		# Lato destro (+n)
		var r_tree = Vector3(p.x + n.x * (hw + 3.8), p.y, p.z + n.z * (hw + 3.8))
		root.add_child(create_umbrella_pine(r_tree, 1.15))
		var r_bush = Vector3(p.x + n.x * (hw + 2.8), p.y, p.z + n.z * (hw + 2.8))
		root.add_child(create_oleander_bush(r_bush, true))

		# Lato sinistro (-n)
		var l_tree = Vector3(p.x - n.x * (hw + 3.8), p.y, p.z - n.z * (hw + 3.8))
		root.add_child(create_umbrella_pine(l_tree, 1.15))
		var l_bush = Vector3(p.x - n.x * (hw + 2.8), p.y, p.z - n.z * (hw + 2.8))
		root.add_child(create_oleander_bush(l_bush, false))

# ==============================================================================
# PROPS & MODELLI ARCHITETTONICI MEDITERRANEI
# ==============================================================================

# Pino Domestico a Ombrello (Pinus pinea)
static func create_umbrella_pine(pos: Vector3, scale_mult: float = 1.0) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	node.scale = Vector3.ONE * scale_mult

	# 1. Tronco slanciato e leggermente arcuato
	var trunk = MeshInstance3D.new()
	var t_cyl = CylinderMesh.new()
	t_cyl.top_radius = 0.28
	t_cyl.bottom_radius = 0.44
	t_cyl.height = 6.2
	t_cyl.radial_segments = 8
	t_cyl.material = mat_pine_bark
	trunk.mesh = t_cyl
	trunk.position.y = 3.1
	trunk.rotation.z = deg_to_rad(randf_range(-3.5, 3.5))
	node.add_child(trunk)

	# 2. Chioma ad ombrello ampia e appiattita (tipica ligure/romana)
	var canopy = MeshInstance3D.new()
	var c_cyl = CylinderMesh.new()
	c_cyl.top_radius = 3.6
	c_cyl.bottom_radius = 4.4
	c_cyl.height = 1.6
	c_cyl.radial_segments = 10
	c_cyl.material = mat_pine_canopy
	canopy.mesh = c_cyl
	canopy.position.y = 6.2
	node.add_child(canopy)

	var canopy_top = MeshInstance3D.new()
	var ct_cyl = CylinderMesh.new()
	ct_cyl.top_radius = 2.4
	ct_cyl.bottom_radius = 3.6
	ct_cyl.height = 0.9
	ct_cyl.radial_segments = 9
	ct_cyl.material = mat_pine_canopy
	canopy_top.mesh = ct_cyl
	canopy_top.position.y = 7.1
	node.add_child(canopy_top)

	return node

# Ulivo Secolare (Olea europaea)
static func create_olive_tree(pos: Vector3, scale_mult: float = 1.0) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	node.scale = Vector3.ONE * scale_mult

	# Tronco nodoso e ritorto
	var trunk = MeshInstance3D.new()
	var t_cyl = CylinderMesh.new()
	t_cyl.top_radius = 0.32
	t_cyl.bottom_radius = 0.52
	t_cyl.height = 2.4
	t_cyl.radial_segments = 7
	t_cyl.material = mat_olive_bark
	trunk.mesh = t_cyl
	trunk.position.y = 1.2
	trunk.rotation.z = deg_to_rad(randf_range(-7.0, 7.0))
	node.add_child(trunk)

	# 3 volumi sferici di foglie argentate
	for i in range(3):
		var sphere = MeshInstance3D.new()
		var sp_mesh = SphereMesh.new()
		sp_mesh.radius = 1.3
		sp_mesh.height = 2.1
		sp_mesh.radial_segments = 8
		sp_mesh.rings = 6
		sp_mesh.material = mat_olive_leaf
		sphere.mesh = sp_mesh
		var ang_i = float(i) * 2.094
		sphere.position = Vector3(cos(ang_i) * 0.9, 2.7 + float(i) * 0.25, sin(ang_i) * 0.9)
		node.add_child(sphere)

	return node

# Cespuglio di Oleandro Fiorito
static func create_oleander_bush(pos: Vector3, is_pink: bool = true) -> Node3D:
	var node = Node3D.new()
	node.position = pos

	# Foglie verdi dense
	var foliage = MeshInstance3D.new()
	var f_mesh = SphereMesh.new()
	f_mesh.radius = 0.85
	f_mesh.height = 1.3
	f_mesh.radial_segments = 7
	f_mesh.rings = 5
	f_mesh.material = mat_oleander_leaf
	foliage.mesh = f_mesh
	foliage.position.y = 0.65
	node.add_child(foliage)

	# Fiori colorati
	var flowers = MeshInstance3D.new()
	var fl_mesh = SphereMesh.new()
	fl_mesh.radius = 0.72
	fl_mesh.height = 1.1
	fl_mesh.radial_segments = 6
	fl_mesh.rings = 4
	fl_mesh.material = mat_oleander_flower_pink if is_pink else mat_oleander_flower_white
	flowers.mesh = fl_mesh
	flowers.position.y = 0.78
	node.add_child(flowers)

	return node

# Belvedere Panoramico sul Mare (Semicircolare ad archi con cannocchiale e panchine)
static func create_belvedere_overlook(pos: Vector3, road_ang: float) -> Node3D:
	var node = Node3D.new()
	node.name = "BelvedereOverlook"
	node.position = pos
	node.rotation.y = road_ang

	# 1. Piattaforma semicircolare in pietra protesa verso il mare
	var floor_box = MeshInstance3D.new()
	var fb_box = BoxMesh.new()
	fb_box.size = Vector3(6.5, 0.45, 4.2)
	fb_box.material = mat_belvedere_balustrade
	floor_box.mesh = fb_box
	floor_box.position = Vector3(-1.2, 0.22, 0.0)
	node.add_child(floor_box)

	# 2. Balustra di sicurezza in pietra sagomata
	var balustrade = MeshInstance3D.new()
	var bal_box = BoxMesh.new()
	bal_box.size = Vector3(0.4, 0.95, 4.4)
	bal_box.material = mat_belvedere_balustrade
	balustrade.mesh = bal_box
	balustrade.position = Vector3(-4.3, 0.85, 0.0)
	node.add_child(balustrade)

	# Collider della balustra per sicurezza assoluta
	var col_body = StaticBody3D.new()
	var col_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5, 1.2, 4.5)
	col_shape.shape = box_shape
	col_shape.position = Vector3(-4.3, 0.85, 0.0)
	col_body.add_child(col_shape)
	node.add_child(col_body)

	# 3. Panchina in pietra affacciata sul mare
	var bench = MeshInstance3D.new()
	var b_box = BoxMesh.new()
	b_box.size = Vector3(0.65, 0.45, 1.6)
	b_box.material = mat_belvedere_balustrade
	bench.mesh = b_box
	bench.position = Vector3(-2.8, 0.45, 1.1)
	node.add_child(bench)

	# 4. Cannocchiale panoramico su piedistallo in ottone
	var scope = Node3D.new()
	scope.position = Vector3(-3.8, 0.8, -1.0)
	var ped = MeshInstance3D.new()
	var p_cyl = CylinderMesh.new()
	p_cyl.top_radius = 0.08
	p_cyl.bottom_radius = 0.16
	p_cyl.height = 0.9
	p_cyl.material = mat_iron_black
	ped.mesh = p_cyl
	ped.position.y = 0.45
	scope.add_child(ped)

	var tube = MeshInstance3D.new()
	var t_cyl = CylinderMesh.new()
	t_cyl.top_radius = 0.07
	t_cyl.bottom_radius = 0.09
	t_cyl.height = 0.65
	t_cyl.material = mat_church_bell
	tube.mesh = t_cyl
	tube.position.y = 0.92
	tube.rotation.x = deg_to_rad(90.0)
	tube.rotation.z = deg_to_rad(15.0)
	scope.add_child(tube)
	node.add_child(scope)

	return node

# Faro Monumentale della Scogliera (Faro marittimo con lanterna attiva)
static func create_monumental_lighthouse(pos: Vector3, road_ang: float) -> Node3D:
	var node = Node3D.new()
	node.name = "MonumentalLighthouse"
	node.position = pos
	node.rotation.y = road_ang

	# 1. Base su scogliera rocciosa
	var cliff = MeshInstance3D.new()
	var c_box = BoxMesh.new()
	c_box.size = Vector3(14.0, 7.0, 14.0)
	c_box.material = mat_cliff_stone
	cliff.mesh = c_box
	cliff.position.y = 3.5
	node.add_child(cliff)

	# 2. Torre cilindrica a fasce bicolori bianco / rosso
	var tower_base_y = 7.0
	for band in range(5):
		var band_mesh = MeshInstance3D.new()
		var b_cyl = CylinderMesh.new()
		var r_bot = lerp(3.2, 2.3, float(band) / 5.0)
		var r_top = lerp(3.2, 2.3, float(band + 1) / 5.0)
		b_cyl.bottom_radius = r_bot
		b_cyl.top_radius = r_top
		b_cyl.height = 3.6
		b_cyl.radial_segments = 12
		b_cyl.material = mat_lighthouse_white if (band % 2 == 0) else mat_lighthouse_red
		band_mesh.mesh = b_cyl
		band_mesh.position.y = tower_base_y + 1.8 + float(band) * 3.6
		node.add_child(band_mesh)

	var gallery_y = tower_base_y + 5.0 * 3.6

	# 3. Galleria e ringhiera di ronda
	var gallery = MeshInstance3D.new()
	var g_cyl = CylinderMesh.new()
	g_cyl.top_radius = 2.9
	g_cyl.bottom_radius = 2.9
	g_cyl.height = 0.4
	g_cyl.radial_segments = 12
	g_cyl.material = mat_belvedere_balustrade
	gallery.mesh = g_cyl
	gallery.position.y = gallery_y + 0.2
	node.add_child(gallery)

	# 4. Lanterna in vetro con cuore luminoso pulsante
	var lantern_glass = MeshInstance3D.new()
	var l_cyl = CylinderMesh.new()
	l_cyl.top_radius = 1.9
	l_cyl.bottom_radius = 1.9
	l_cyl.height = 2.6
	l_cyl.radial_segments = 12
	l_cyl.material = mat_lighthouse_glass
	lantern_glass.mesh = l_cyl
	lantern_glass.position.y = gallery_y + 1.7
	node.add_child(lantern_glass)

	var beacon = MeshInstance3D.new()
	var b_sph = SphereMesh.new()
	b_sph.radius = 0.95
	b_sph.height = 1.9
	b_sph.radial_segments = 10
	b_sph.rings = 6
	b_sph.material = mat_lighthouse_beacon
	beacon.mesh = b_sph
	beacon.position.y = gallery_y + 1.7
	node.add_child(beacon)

	# 5. Cupola di copertura in rame verde
	var dome = MeshInstance3D.new()
	var d_sph = SphereMesh.new()
	d_sph.radius = 2.05
	d_sph.height = 1.8
	d_sph.radial_segments = 12
	d_sph.rings = 6
	d_sph.material = mat_iron_black
	dome.mesh = d_sph
	dome.position.y = gallery_y + 3.4
	node.add_child(dome)

	# 6. Luce omnidirezionale del faro
	var omni = OmniLight3D.new()
	omni.light_color = Color(1.0, 0.92, 0.65)
	omni.light_energy = 5.0
	omni.omni_range = 120.0
	omni.position.y = gallery_y + 1.7
	node.add_child(omni)

	return node

# Casa Pastello del Villaggio Marinaro (2-3 piani con persiane verdi e tetto in coppi)
static func create_coastal_pastel_house(pos: Vector3, road_ang: float, palette_idx: int, stories: int = 2) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	node.rotation.y = road_ang

	var plaster_mat: StandardMaterial3D
	match palette_idx:
		0: plaster_mat = mat_plaster_peach
		1: plaster_mat = mat_plaster_yellow
		2: plaster_mat = mat_plaster_terracotta
		3: plaster_mat = mat_plaster_blue
		_: plaster_mat = mat_plaster_sage

	var width = 6.4
	var depth = 7.5
	var height = 3.6 * float(stories)

	# 1. Corpo principale dell'edificio
	var body = MeshInstance3D.new()
	var b_box = BoxMesh.new()
	b_box.size = Vector3(width, height, depth)
	b_box.material = plaster_mat
	body.mesh = b_box
	body.position.y = height * 0.5
	node.add_child(body)

	# 2. Tetto a due falde in coppi di terracotta
	var roof = MeshInstance3D.new()
	var r_box = BoxMesh.new()
	r_box.size = Vector3(width + 0.6, 1.4, depth + 0.6)
	if mat_terracotta_roof:
		r_box.material = mat_terracotta_roof
	roof.mesh = r_box
	roof.position.y = height + 0.7
	node.add_child(roof)

	# 3. Finestre con persiane verdi alla genovese
	for s in range(stories):
		var wy = 1.6 + float(s) * 3.4
		for wx in [-1.8, 1.8]:
			# Vetro
			var win = MeshInstance3D.new()
			var w_box = BoxMesh.new()
			w_box.size = Vector3(0.9, 1.3, 0.15)
			w_box.material = mat_window_glass
			win.mesh = w_box
			win.position = Vector3(wx, wy, -depth * 0.5 - 0.02)
			node.add_child(win)

			# Persiane aperte ai lati
			for side in [-1.0, 1.0]:
				var shutter = MeshInstance3D.new()
				var sh_box = BoxMesh.new()
				sh_box.size = Vector3(0.42, 1.32, 0.08)
				sh_box.material = mat_shutter_green
				shutter.mesh = sh_box
				shutter.position = Vector3(wx + side * 0.62, wy, -depth * 0.5 - 0.04)
				node.add_child(shutter)

	# 4. Portone d'ingresso in legno al piano terra
	var door = MeshInstance3D.new()
	var d_box = BoxMesh.new()
	d_box.size = Vector3(1.3, 2.2, 0.12)
	d_box.material = mat_wood_boat
	door.mesh = d_box
	door.position = Vector3(0.0, 1.1, -depth * 0.5 - 0.03)
	node.add_child(door)

	# 5. Comignolo in cotto sul tetto
	var chimney = MeshInstance3D.new()
	var ch_box = BoxMesh.new()
	ch_box.size = Vector3(0.65, 1.2, 0.65)
	ch_box.material = mat_cliff_stone
	chimney.mesh = ch_box
	chimney.position = Vector3(width * 0.3, height + 1.8, 0.0)
	node.add_child(chimney)

	# Collider solido dell'edificio
	var col_b = StaticBody3D.new()
	var col_s = CollisionShape3D.new()
	var b_shape = BoxShape3D.new()
	b_shape.size = Vector3(width, height, depth)
	col_s.shape = b_shape
	col_s.position.y = height * 0.5
	col_b.add_child(col_s)
	node.add_child(col_b)

	return node

# Banchina del Porto con Bitte in Ghisa e Gozzi da Pesca in Legno
static func create_harbor_quay_and_boats(pos: Vector3, road_ang: float, start_z: float) -> Node3D:
	var node = Node3D.new()
	node.name = "HarborQuay"
	node.position = pos
	node.rotation.y = road_ang

	# 1. Banchina pedonale in blocchi di pietra squadrata
	var quay_mesh = MeshInstance3D.new()
	var q_box = BoxMesh.new()
	q_box.size = Vector3(3.8, 0.8, 28.0)
	q_box.material = mat_quay_stone
	quay_mesh.mesh = q_box
	quay_mesh.position = Vector3(0.0, 0.4, 0.0)
	node.add_child(quay_mesh)

	# Bitte d'ormeggio in ghisa nera lungo il ciglio banchina
	for b in [-9.0, 0.0, 9.0]:
		var bollard = MeshInstance3D.new()
		var b_cyl = CylinderMesh.new()
		b_cyl.top_radius = 0.16
		b_cyl.bottom_radius = 0.12
		b_cyl.height = 0.45
		b_cyl.radial_segments = 6
		b_cyl.material = mat_iron_black
		bollard.mesh = b_cyl
		bollard.position = Vector3(-1.6, 0.95, b)
		node.add_child(bollard)

	# 2. Barche Tradizionali in Legno (Gozzi Liguri) ormeggiate in acqua (-X)
	var boat_colors = [mat_boat_hull_blue, mat_boat_hull_red, mat_boat_hull_white]
	for bi in range(2):
		var boat_z = -6.0 + float(bi) * 12.0
		var boat_color = boat_colors[(int(start_z * 0.1) + bi) % 3]
		var boat = create_wooden_gozzo_boat(Vector3(-4.5, 0.35, boat_z), boat_color)
		node.add_child(boat)

	# 3. Lampione in ferro battuto sulla banchina
	var lamp = create_wrought_iron_lamp(Vector3(1.2, 0.8, 0.0), 0.0)
	node.add_child(lamp)

	return node

# Gozzo Tradizionale Ligure in Legno
static func create_wooden_gozzo_boat(pos: Vector3, hull_color: StandardMaterial3D) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	node.rotation.y = deg_to_rad(randf_range(-15.0, 15.0))

	# Scafo arrotondato a doppio cuneo tipico del gozzo marinaro
	var hull = MeshInstance3D.new()
	var h_box = BoxMesh.new()
	h_box.size = Vector3(1.6, 0.75, 4.2)
	h_box.material = hull_color
	hull.mesh = h_box
	hull.position.y = 0.15
	node.add_child(hull)

	# Coperta in listoni di tek/legno
	var deck = MeshInstance3D.new()
	var d_box = BoxMesh.new()
	d_box.size = Vector3(1.3, 0.12, 3.8)
	d_box.material = mat_wood_boat
	deck.mesh = d_box
	deck.position.y = 0.52
	node.add_child(deck)

	# Banco centrale con coppia di remi in legno
	var oar = MeshInstance3D.new()
	var o_cyl = CylinderMesh.new()
	o_cyl.top_radius = 0.03
	o_cyl.bottom_radius = 0.03
	o_cyl.height = 2.4
	o_cyl.material = mat_wood_boat
	oar.mesh = o_cyl
	oar.position = Vector3(0.0, 0.65, 0.2)
	oar.rotation.z = deg_to_rad(75.0)
	node.add_child(oar)

	return node

# Chiesa di Santa Maria del Mare con Campanile Panoramico
static func create_sea_church(pos: Vector3, road_ang: float) -> Node3D:
	var node = Node3D.new()
	node.name = "SeaChurch"
	node.position = pos
	node.rotation.y = road_ang

	# 1. Navata centrale della chiesa
	var nave = MeshInstance3D.new()
	var n_box = BoxMesh.new()
	n_box.size = Vector3(9.0, 6.5, 14.0)
	n_box.material = mat_church_stone
	nave.mesh = n_box
	nave.position.y = 3.25
	node.add_child(nave)

	# Tetto spiovente in tegole di cotto
	var roof = MeshInstance3D.new()
	var r_box = BoxMesh.new()
	r_box.size = Vector3(9.6, 1.8, 14.6)
	if mat_terracotta_roof:
		r_box.material = mat_terracotta_roof
	roof.mesh = r_box
	roof.position.y = 7.2
	node.add_child(roof)

	# Rosone circolare sulla facciata
	var rosette = MeshInstance3D.new()
	var rs_cyl = CylinderMesh.new()
	rs_cyl.top_radius = 1.1
	rs_cyl.bottom_radius = 1.1
	rs_cyl.height = 0.15
	rs_cyl.radial_segments = 12
	rs_cyl.material = mat_church_bell
	rosette.mesh = rs_cyl
	rosette.position = Vector3(0.0, 4.8, -7.05)
	rosette.rotation.x = deg_to_rad(90.0)
	node.add_child(rosette)

	# Portale romanico con architrave in pietra
	var portal = MeshInstance3D.new()
	var p_box = BoxMesh.new()
	p_box.size = Vector3(2.2, 3.2, 0.25)
	p_box.material = mat_wood_boat
	portal.mesh = p_box
	portal.position = Vector3(0.0, 1.6, -7.05)
	node.add_child(portal)

	# 2. Campanile Slanciato con Cella Campanaria a Bifore e Campana in Bronzo
	var tower = MeshInstance3D.new()
	var t_box = BoxMesh.new()
	t_box.size = Vector3(3.6, 15.0, 3.6)
	t_box.material = mat_church_stone
	tower.mesh = t_box
	tower.position = Vector3(5.8, 7.5, -4.5)
	node.add_child(tower)

	# Cuspide piramidale del campanile
	var spire = MeshInstance3D.new()
	var sp_pyr = CylinderMesh.new()
	sp_pyr.top_radius = 0.05
	sp_pyr.bottom_radius = 2.1
	sp_pyr.height = 3.8
	sp_pyr.radial_segments = 4
	sp_pyr.material = mat_belvedere_balustrade
	spire.mesh = sp_pyr
	spire.position = Vector3(5.8, 16.9, -4.5)
	spire.rotation.y = deg_to_rad(45.0)
	node.add_child(spire)

	# Campana in bronzo visibile
	var bell = MeshInstance3D.new()
	var b_cyl = CylinderMesh.new()
	b_cyl.top_radius = 0.28
	b_cyl.bottom_radius = 0.52
	b_cyl.height = 0.75
	b_cyl.radial_segments = 8
	b_cyl.material = mat_church_bell
	bell.mesh = b_cyl
	bell.position = Vector3(5.8, 13.5, -4.5)
	node.add_child(bell)

	# Collider solido della chiesa
	var col_b = StaticBody3D.new()
	var col_s = CollisionShape3D.new()
	var b_shape = BoxShape3D.new()
	b_shape.size = Vector3(14.0, 7.0, 16.0)
	col_s.shape = b_shape
	col_s.position.y = 3.5
	col_b.add_child(col_s)
	node.add_child(col_b)

	return node

# Lampione Artistico in Ferro Battuto (con luce calda notturna)
static func create_wrought_iron_lamp(pos: Vector3, road_ang: float) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	node.rotation.y = road_ang

	# Palo scanalato in ghisa
	var post = MeshInstance3D.new()
	var p_cyl = CylinderMesh.new()
	p_cyl.top_radius = 0.08
	p_cyl.bottom_radius = 0.14
	p_cyl.height = 3.2
	p_cyl.radial_segments = 6
	p_cyl.material = mat_iron_black
	post.mesh = p_cyl
	post.position.y = 1.6
	node.add_child(post)

	# Braccio a voluta e lanterna a lanternino esagonale
	var lantern = MeshInstance3D.new()
	var l_cyl = CylinderMesh.new()
	l_cyl.top_radius = 0.22
	l_cyl.bottom_radius = 0.14
	l_cyl.height = 0.55
	l_cyl.radial_segments = 6
	l_cyl.material = mat_lantern_glow
	lantern.mesh = l_cyl
	lantern.position = Vector3(0.0, 3.4, 0.0)
	node.add_child(lantern)

	return node

# Monumentale Porta Marina di San Cristoforo (Arco Trionfale d'ingresso)
static func create_monumental_city_gate(pos: Vector3, road_ang: float, road_width: float) -> Node3D:
	var node = Node3D.new()
	node.name = "MonumentalCityGate"
	node.position = pos
	node.rotation.y = road_ang

	var arch_span = max(11.0, road_width + 3.2)
	var pillar_width = 2.4
	var pillar_depth = 2.8
	var pillar_height = 8.5

	# Pilone Sinistro (offset sicuro dal bordo strada)
	var p_left = MeshInstance3D.new()
	var pl_box = BoxMesh.new()
	pl_box.size = Vector3(pillar_width, pillar_height, pillar_depth)
	pl_box.material = mat_church_stone
	p_left.mesh = pl_box
	p_left.position = Vector3(-arch_span * 0.5 - pillar_width * 0.5, pillar_height * 0.5, 0.0)
	node.add_child(p_left)

	# Pilone Destro
	var p_right = MeshInstance3D.new()
	var pr_box = BoxMesh.new()
	pr_box.size = Vector3(pillar_width, pillar_height, pillar_depth)
	pr_box.material = mat_church_stone
	p_right.mesh = pr_box
	p_right.position = Vector3(arch_span * 0.5 + pillar_width * 0.5, pillar_height * 0.5, 0.0)
	node.add_child(p_right)

	# Architrave / Attico superiore con iscrizione monumentale
	var attico = MeshInstance3D.new()
	var at_box = BoxMesh.new()
	at_box.size = Vector3(arch_span + pillar_width * 2.0 + 0.8, 2.6, pillar_depth + 0.6)
	at_box.material = mat_belvedere_balustrade
	attico.mesh = at_box
	attico.position = Vector3(0.0, pillar_height + 1.3, 0.0)
	node.add_child(attico)

	# Cornicione superiore con cuspide e stemmi
	var cornice = MeshInstance3D.new()
	var c_box = BoxMesh.new()
	c_box.size = Vector3(arch_span + pillar_width * 2.0 + 1.6, 0.6, pillar_depth + 1.0)
	c_box.material = mat_church_stone
	cornice.mesh = c_box
	cornice.position = Vector3(0.0, pillar_height + 2.8, 0.0)
	node.add_child(cornice)

	# Lanterne gemelle in ferro battuto appese sui due piloni
	for side in [-1.0, 1.0]:
		var gate_lamp = create_wrought_iron_lamp(
			Vector3(side * (arch_span * 0.5 + 0.4), 3.2, -pillar_depth * 0.5 - 0.2),
			0.0
		)
		node.add_child(gate_lamp)

	# Collider fisici dei due piloni laterali (strada completamente libera e sicura al centro!)
	for side in [-1.0, 1.0]:
		var col_body = StaticBody3D.new()
		var col_shape = CollisionShape3D.new()
		var box_s = BoxShape3D.new()
		box_s.size = Vector3(pillar_width, pillar_height, pillar_depth)
		col_shape.shape = box_s
		col_shape.position = Vector3(side * (arch_span * 0.5 + pillar_width * 0.5), pillar_height * 0.5, 0.0)
		col_body.add_child(col_shape)
		node.add_child(col_body)

	return node
