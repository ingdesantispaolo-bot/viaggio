extends RefCounted
class_name GarageEnvironmentBuilder

# ==============================================================================
# GARAGE & OFFICINA PAOLO (1993) - 3D RETRO WORKSHOP ENVIRONMENT
# ==============================================================================
# Dedicated physical 3D garage where player's car resides on game startup:
# - Concrete grease-stained workshop floor & paved driveway leading to the highway
# - Industrial brick & plastered walls with wide open sliding workshop doors
# - Authentic Period Equipment:
#   * 2-Post Hydraulic Vehicle Lift (Giallo/Blu industriale)
#   * Heavy Mechanic Workbench with Bench Vice (Morsa da banco)
#   * Red Beta Tool Chest Trolley (Carrello attrezzi)
#   * Agip Sint 2000 vintage oil barrels
#   * Stack of Pirelli P7 rally tires
#   * Warm overhead halogen inspection work-lights
#   * "OFFICINA MECCANICA PAOLO" vintage Italian enamel sign
# ==============================================================================

static var mat_concrete: StandardMaterial3D
static var mat_brick: StandardMaterial3D
static var mat_metal_yellow: StandardMaterial3D
static var mat_metal_blue: StandardMaterial3D
static var mat_metal_red: StandardMaterial3D
static var mat_wood: StandardMaterial3D
static var mat_steel: StandardMaterial3D
static var mat_agip_yellow: StandardMaterial3D
static var mat_tire_rubber: StandardMaterial3D
static var mat_sign_enamel: StandardMaterial3D
static var mat_chrome: StandardMaterial3D
static var mat_plastic_black: StandardMaterial3D
static var mat_carb_brass: StandardMaterial3D

static func init_materials():
	if mat_concrete != null: return
	
	mat_concrete = StandardMaterial3D.new()
	mat_concrete.albedo_color = Color(0.32, 0.33, 0.35)
	mat_concrete.roughness = 0.85
	
	mat_brick = StandardMaterial3D.new()
	mat_brick.albedo_color = Color(0.68, 0.42, 0.28) # Warm Italian terracotta brick
	mat_brick.roughness = 0.90
	
	mat_metal_yellow = StandardMaterial3D.new()
	mat_metal_yellow.albedo_color = Color(0.92, 0.75, 0.12) # Industrial lift yellow
	mat_metal_yellow.metallic = 0.45
	mat_metal_yellow.roughness = 0.38
	
	mat_metal_blue = StandardMaterial3D.new()
	mat_metal_blue.albedo_color = Color(0.12, 0.28, 0.65) # Industrial machine blue
	mat_metal_blue.metallic = 0.50
	mat_metal_blue.roughness = 0.35
	
	mat_metal_red = StandardMaterial3D.new()
	mat_metal_red.albedo_color = Color(0.82, 0.15, 0.12) # Beta tool chest red
	mat_metal_red.metallic = 0.40
	mat_metal_red.roughness = 0.30
	
	mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.42, 0.28, 0.16)
	mat_wood.roughness = 0.80
	
	mat_steel = StandardMaterial3D.new()
	mat_steel.albedo_color = Color(0.70, 0.72, 0.75)
	mat_steel.metallic = 0.85
	mat_steel.roughness = 0.28
	
	mat_agip_yellow = StandardMaterial3D.new()
	mat_agip_yellow.albedo_color = Color(0.95, 0.78, 0.08)
	mat_agip_yellow.metallic = 0.30
	mat_agip_yellow.roughness = 0.40
	
	mat_tire_rubber = StandardMaterial3D.new()
	mat_tire_rubber.albedo_color = Color(0.12, 0.12, 0.13)
	mat_tire_rubber.roughness = 0.95
	
	mat_sign_enamel = StandardMaterial3D.new()
	mat_sign_enamel.albedo_color = Color(0.08, 0.20, 0.45)
	mat_sign_enamel.roughness = 0.25
	
	mat_chrome = StandardMaterial3D.new()
	mat_chrome.albedo_color = Color(0.92, 0.94, 0.96)
	mat_chrome.metallic = 0.95
	mat_chrome.roughness = 0.12
	mat_chrome.clearcoat_enabled = true
	mat_chrome.clearcoat = 1.0
	
	mat_plastic_black = StandardMaterial3D.new()
	mat_plastic_black.albedo_color = Color(0.12, 0.12, 0.13)
	mat_plastic_black.roughness = 0.85
	
	mat_carb_brass = StandardMaterial3D.new()
	mat_carb_brass.albedo_color = Color(0.85, 0.70, 0.28)
	mat_carb_brass.metallic = 0.75
	mat_carb_brass.roughness = 0.28

static func build_paolo_garage(parent: Node3D, pos: Vector3 = Vector3(-16.0, 0.0, 8.0), rot_y: float = PI) -> Node3D:
	init_materials()
	
	var garage_root = Node3D.new()
	garage_root.name = "GaragePaolo3D"
	garage_root.position = pos
	garage_root.rotation.y = rot_y
	parent.add_child(garage_root)
	
	# 1. FLOOR & DRIVEWAY APRON TO MAIN ROAD
	var floor_box = BoxMesh.new()
	floor_box.size = Vector3(14.0, 0.30, 16.0)
	var floor_mesh = MeshInstance3D.new()
	floor_mesh.mesh = floor_box
	floor_mesh.material_override = mat_concrete
	floor_mesh.position = Vector3(0, -0.15, 0)
	garage_root.add_child(floor_mesh)
	
	# Solid StaticBody3D floor collider
	var floor_body = StaticBody3D.new()
	var col_shape = CollisionShape3D.new()
	var b_shape = BoxShape3D.new()
	b_shape.size = Vector3(14.0, 0.40, 16.0)
	col_shape.shape = b_shape
	floor_body.add_child(col_shape)
	floor_mesh.add_child(floor_body)
	
	# Paved connecting driveway towards highway (spans toward -X to merge with road shoulder)
	var driveway_mesh = MeshInstance3D.new()
	var d_box = BoxMesh.new()
	d_box.size = Vector3(9.5, 0.30, 12.0)
	driveway_mesh.mesh = d_box
	driveway_mesh.material_override = mat_concrete
	driveway_mesh.position = Vector3(-10.5, -0.15, 0)
	garage_root.add_child(driveway_mesh)
	
	var drive_body = StaticBody3D.new()
	var drive_col = CollisionShape3D.new()
	var d_shape = BoxShape3D.new()
	d_shape.size = Vector3(9.5, 0.40, 12.0)
	drive_col.shape = d_shape
	drive_body.add_child(drive_col)
	driveway_mesh.add_child(drive_body)
	
	# 2. WORKSHOP WALLS
	# Back Wall (+X)
	var back_wall = create_box(Vector3(0.40, 4.4, 16.0), mat_brick, Vector3(6.8, 2.05, 0))
	garage_root.add_child(back_wall)
	# Lateral Wall Left (-Z)
	var lat_l = create_box(Vector3(13.6, 4.4, 0.40), mat_brick, Vector3(0, 2.05, -7.8))
	garage_root.add_child(lat_l)
	# Lateral Wall Right (+Z)
	var lat_r = create_box(Vector3(13.6, 4.4, 0.40), mat_brick, Vector3(0, 2.05, 7.8))
	garage_root.add_child(lat_r)
	
	# Front Wall Portal (-X) - Wide opening for driving out
	var front_l = create_box(Vector3(0.40, 4.4, 4.2), mat_brick, Vector3(-6.8, 2.05, -5.7))
	var front_r = create_box(Vector3(0.40, 4.4, 4.2), mat_brick, Vector3(-6.8, 2.05, 5.7))
	var lintel = create_box(Vector3(0.45, 1.1, 8.4), mat_brick, Vector3(-6.8, 3.7, 0))
	garage_root.add_child(front_l); garage_root.add_child(front_r); garage_root.add_child(lintel)
	
	# Handcrafted Terracotta Pitched Gable Roof with Cornice Overhangs
	var roof_eaves = create_box(Vector3(14.8, 0.22, 16.8), mat_concrete, Vector3(0, 4.4, 0))
	garage_root.add_child(roof_eaves)
	var pm = PrismMesh.new()
	pm.left_to_right = 0.5
	pm.size = Vector3(15.2, 2.5, 17.2)
	var p_mi = MeshInstance3D.new()
	p_mi.mesh = pm
	var t_mat = StandardMaterial3D.new()
	t_mat.albedo_color = Color(0.74, 0.38, 0.22)
	t_mat.roughness = 0.88
	p_mi.material_override = t_mat
	p_mi.position = Vector3(0, 4.5 + 1.25, 0)
	garage_root.add_child(p_mi)
	var ridge = create_box(Vector3(0.35, 0.18, 17.4), mat_concrete, Vector3(0, 4.5 + 2.55, 0))
	garage_root.add_child(ridge)
	
	# 3. VINTAGE ITALIAN ENAMEL SIGN OVER PORTAL: "OFFICINA MECCANICA PAOLO"
	var sign_board = create_box(Vector3(0.12, 0.85, 6.5), mat_sign_enamel, Vector3(-7.05, 3.65, 0))
	garage_root.add_child(sign_board)
	
	# Italian Tricolour Stripe underneath sign
	var green_s = create_box(Vector3(0.14, 0.08, 2.0), StandardMaterial3D.new(), Vector3(-7.08, 3.16, -2.0))
	(green_s.material_override as StandardMaterial3D).albedo_color = Color(0.0, 0.58, 0.24)
	var white_s = create_box(Vector3(0.14, 0.08, 2.0), StandardMaterial3D.new(), Vector3(-7.08, 3.16, 0.0))
	(white_s.material_override as StandardMaterial3D).albedo_color = Color(0.95, 0.95, 0.95)
	var red_s = create_box(Vector3(0.14, 0.08, 2.0), StandardMaterial3D.new(), Vector3(-7.08, 3.16, 2.0))
	(red_s.material_override as StandardMaterial3D).albedo_color = Color(0.85, 0.12, 0.10)
	garage_root.add_child(green_s); garage_root.add_child(white_s); garage_root.add_child(red_s)
	
	# 4. HYDRAULIC 2-POST VEHICLE LIFT (Side Bay)
	for col_z in [-2.4, 2.4]:
		var col = create_box(Vector3(0.28, 3.4, 0.32), mat_metal_blue, Vector3(4.8, 1.7, col_z))
		var base = create_box(Vector3(0.60, 0.10, 0.60), mat_metal_blue, Vector3(4.8, 0.05, col_z))
		var arm = create_box(Vector3(0.14, 0.10, 1.6), mat_metal_yellow, Vector3(4.8, 0.28, col_z * 0.45))
		garage_root.add_child(col); garage_root.add_child(base); garage_root.add_child(arm)
	var lift_beam = create_box(Vector3(0.18, 0.18, 4.8), mat_metal_blue, Vector3(4.8, 3.3, 0))
	garage_root.add_child(lift_beam)
	
	# 5. MECHANIC'S WORKBENCH WITH BENCH VICE (Banco da Lavoro con Morsa)
	var bench_top = create_box(Vector3(1.2, 0.10, 3.2), mat_wood, Vector3(6.0, 0.90, -4.5))
	var bench_legs = create_box(Vector3(1.1, 0.85, 3.1), mat_metal_blue, Vector3(6.0, 0.42, -4.5))
	var vice_body = create_box(Vector3(0.24, 0.18, 0.20), mat_steel, Vector3(5.7, 1.04, -3.4))
	var vice_handle = create_box(Vector3(0.04, 0.28, 0.04), mat_steel, Vector3(5.55, 1.04, -3.4))
	garage_root.add_child(bench_top); garage_root.add_child(bench_legs); garage_root.add_child(vice_body); garage_root.add_child(vice_handle)
	
	# 6. BETA TOOL TROLLEY (Carrello Porta-Attrezzi Rosso)
	var tool_cart = create_box(Vector3(0.65, 0.95, 0.85), mat_metal_red, Vector3(5.8, 0.48, -2.0))
	var cart_handle = create_box(Vector3(0.06, 0.04, 0.70), mat_steel, Vector3(5.45, 0.92, -2.0))
	garage_root.add_child(tool_cart); garage_root.add_child(cart_handle)
	
	# 7. AGIP SINT 2000 OIL DRUMS (Fusti Olio Vintage)
	for d_i in range(3):
		var drum = MeshInstance3D.new()
		var d_cyl = CylinderMesh.new()
		d_cyl.top_radius = 0.32; d_cyl.bottom_radius = 0.32; d_cyl.height = 0.95; d_cyl.radial_segments = 14
		drum.mesh = d_cyl
		drum.material_override = mat_agip_yellow
		drum.position = Vector3(6.0, 0.48, 2.5 + float(d_i) * 0.75)
		garage_root.add_child(drum)
		
	# 8. STACK OF PIRELLI RALLY TIRES (Pila di Pneumatici)
	for t_i in range(4):
		var tire = MeshInstance3D.new()
		var t_cyl = CylinderMesh.new()
		t_cyl.top_radius = 0.30; t_cyl.bottom_radius = 0.30; t_cyl.height = 0.22; t_cyl.radial_segments = 16
		tire.mesh = t_cyl
		tire.material_override = mat_tire_rubber
		tire.position = Vector3(6.0, 0.11 + float(t_i) * 0.23, 5.5)
		garage_root.add_child(tire)
		
	# 9. WARM HALOGEN INSPECTION OVERHEAD LIGHTS
	var work_light = OmniLight3D.new()
	work_light.name = "GarageInspectionLight"
	work_light.light_color = Color(1.0, 0.92, 0.78) # Warm halogen incandescent glow
	work_light.light_energy = 2.4
	work_light.omni_range = 14.0
	work_light.omni_attenuation = 0.75
	work_light.shadow_enabled = true
	work_light.position = Vector3(0.0, 3.8, 0.0)
	garage_root.add_child(work_light)
	
	return garage_root

static func create_box(size: Vector3, mat: Material, pos: Vector3) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var b = BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.material_override = mat
	mi.position = pos
	return mi

static func create_cylinder(radius: float, height: float, mat: Material, pos: Vector3, rot_x: float = 0.0) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var c = CylinderMesh.new()
	c.top_radius = radius
	c.bottom_radius = radius
	c.height = height
	c.radial_segments = 14
	mi.mesh = c
	mi.material_override = mat
	mi.position = pos
	if rot_x != 0.0:
		mi.rotation.x = rot_x
	return mi

# ==============================================================================
# STREET ROD (AMIGA 500) - VANO MOTORE 3D INTERATTIVO & MODULARE
# ==============================================================================
static func build_interactive_engine_bay(parent: Node3D, car_id: String, tuning_parts: Array) -> Node3D:
	init_materials()
	var old_bay = parent.get_node_or_null("EngineBayRig")
	if old_bay:
		old_bay.name = "EngineBayRig_Old"
		old_bay.queue_free()
		
	var bay_root = Node3D.new()
	bay_root.name = "EngineBayRig"
	parent.add_child(bay_root)
	
	var bay_center_z = -1.05
	var bay_y = 0.42
	if car_id == "fiat_127":
		bay_center_z = -0.96
		bay_y = 0.40
	elif car_id == "delta_integrale":
		bay_center_z = -1.18
		bay_y = 0.42
	elif car_id == "golf_gti_1990":
		bay_center_z = -1.15
		bay_y = 0.42
		
	# 1. BLOCCO MOTORE & SCATOLA CAMBIO
	var block = create_box(Vector3(0.52, 0.32, 0.46), mat_steel, Vector3(0.0, bay_y + 0.16, bay_center_z))
	bay_root.add_child(block)
	
	# 2. TESTATA & COPERCHIO VALVOLE CON COLORAZIONE STORICA
	var valve_mat = mat_metal_red if car_id in ["delta_integrale", "alfa_gta"] else (mat_metal_blue if car_id == "fiat_127" else mat_steel)
	var valve_cover = create_box(Vector3(0.50, 0.10, 0.42), valve_mat, Vector3(0.0, bay_y + 0.36, bay_center_z))
	bay_root.add_child(valve_cover)
	
	var oil_cap = create_cylinder(0.04, 0.05, mat_agip_yellow, Vector3(0.16, bay_y + 0.43, bay_center_z - 0.08))
	bay_root.add_child(oil_cap)
	
	# 3. SPINTEROGENO E 4 CAVI CANDELE ROSSI MAGNETI MARELLI
	var dist_pos = Vector3(-0.24, bay_y + 0.32, bay_center_z + 0.12)
	var distributor = create_cylinder(0.045, 0.12, mat_plastic_black, dist_pos)
	bay_root.add_child(distributor)
	
	for i in range(4):
		var plug_z = bay_center_z - 0.13 + float(i) * 0.09
		var plug = create_cylinder(0.02, 0.06, mat_chrome, Vector3(-0.06, bay_y + 0.42, plug_z))
		var lead = create_box(Vector3(0.12, 0.02, 0.02), mat_metal_red, Vector3(-0.15, bay_y + 0.40, plug_z))
		bay_root.add_child(plug)
		bay_root.add_child(lead)
		
	# 4. ALTERNATORE, PULEGGIA E CINGHIA TRAPEZOIDALE
	var alt_cyl = create_cylinder(0.06, 0.12, mat_steel, Vector3(0.30, bay_y + 0.22, bay_center_z - 0.10), PI * 0.5)
	var belt = create_box(Vector3(0.03, 0.22, 0.34), mat_tire_rubber, Vector3(0.30, bay_y + 0.23, bay_center_z))
	bay_root.add_child(alt_cyl)
	bay_root.add_child(belt)
	
	# 5. RADIATORE IN ALLUMINIO CON TUBAZIONE LIQUIDO
	var rad_z = bay_center_z - 0.36
	var radiator = create_box(Vector3(0.62, 0.34, 0.06), mat_steel, Vector3(0.0, bay_y + 0.24, rad_z))
	var rad_hose = create_cylinder(0.03, 0.22, mat_tire_rubber, Vector3(-0.18, bay_y + 0.36, rad_z + 0.11), deg_to_rad(35.0))
	bay_root.add_child(radiator)
	bay_root.add_child(rad_hose)
	
	# 6. BATTERIA MAGNETI MARELLI 12V
	var bat = create_box(Vector3(0.20, 0.16, 0.26), mat_plastic_black, Vector3(-0.34, bay_y + 0.18, bay_center_z + 0.18))
	var pos_pole = create_cylinder(0.015, 0.04, mat_metal_red, Vector3(-0.31, bay_y + 0.28, bay_center_z + 0.10))
	var neg_pole = create_cylinder(0.015, 0.04, mat_metal_blue, Vector3(-0.31, bay_y + 0.28, bay_center_z + 0.25))
	bay_root.add_child(bat)
	bay_root.add_child(pos_pole)
	bay_root.add_child(neg_pole)
	
	# 7. ASPIRAZIONE DINAMICA: FILTRO ORIGINALE VS DOPPI CORPI WEBER DCOE
	var has_webers = tuning_parts.has("carburatori_doppi")
	if has_webers:
		for c_idx in range(2):
			var carb_z = bay_center_z - 0.07 + float(c_idx) * 0.16
			var carb_body = create_box(Vector3(0.16, 0.11, 0.13), mat_carb_brass, Vector3(-0.25, bay_y + 0.33, carb_z))
			bay_root.add_child(carb_body)
			for t_idx in [-0.035, 0.035]:
				var trumpet = create_cylinder(0.032, 0.08, mat_chrome, Vector3(-0.34, bay_y + 0.33, carb_z + t_idx), deg_to_rad(90.0))
				bay_root.add_child(trumpet)
	else:
		var air_canister = create_cylinder(0.15, 0.08, mat_plastic_black, Vector3(-0.15, bay_y + 0.42, bay_center_z))
		var intake_snorkel = create_box(Vector3(0.16, 0.05, 0.06), mat_plastic_black, Vector3(-0.24, bay_y + 0.42, bay_center_z - 0.11))
		bay_root.add_child(air_canister)
		bay_root.add_child(intake_snorkel)
		
	# 8. SCARICO DINAMICO: GHISA STANDARD VS 4-IN-1 TUBOLARE ABARTH CROMATO
	var has_sport_exhaust = tuning_parts.has("scarico_sport")
	if has_sport_exhaust:
		for p_i in range(4):
			var p_z = bay_center_z - 0.13 + float(p_i) * 0.09
			var header_pipe = create_cylinder(0.02, 0.20, mat_chrome, Vector3(0.22, bay_y + 0.27, p_z), deg_to_rad(-45.0))
			bay_root.add_child(header_pipe)
		var collector = create_cylinder(0.038, 0.15, mat_chrome, Vector3(0.28, bay_y + 0.14, bay_center_z), deg_to_rad(-65.0))
		bay_root.add_child(collector)
	else:
		var cast_manifold = create_box(Vector3(0.09, 0.13, 0.40), mat_tire_rubber, Vector3(0.22, bay_y + 0.28, bay_center_z))
		bay_root.add_child(cast_manifold)
		
	# 9. TURBOCOMPRESSORE GARRETT (SE DELTA O KIT OVERBOOST)
	var has_turbo = (car_id in ["delta_integrale", "mercedes_a250"]) or tuning_parts.has("overboost_turbo")
	if has_turbo:
		var turbo_housing = create_cylinder(0.065, 0.09, mat_chrome, Vector3(0.26, bay_y + 0.34, bay_center_z + 0.15), PI * 0.5)
		var wastegate_actuator = create_cylinder(0.032, 0.07, mat_metal_yellow, Vector3(0.33, bay_y + 0.40, bay_center_z + 0.15))
		var samco_pipe = create_box(Vector3(0.05, 0.05, 0.28), mat_metal_blue, Vector3(0.20, bay_y + 0.38, bay_center_z - 0.05))
		bay_root.add_child(turbo_housing)
		bay_root.add_child(wastegate_actuator)
		bay_root.add_child(samco_pipe)
		
	# 10. LAMPADA ALOGENA D'ISPEZIONE OFFICINA SOSPESA SUL VANO MOTORE
	var inspect_light = OmniLight3D.new()
	inspect_light.name = "EngineInspectionLamp"
	inspect_light.light_color = Color(1.0, 0.94, 0.82)
	inspect_light.light_energy = 2.0
	inspect_light.omni_range = 3.2
	inspect_light.omni_attenuation = 0.70
	inspect_light.position = Vector3(0.0, bay_y + 0.80, bay_center_z)
	bay_root.add_child(inspect_light)
	
	var lamp_body = create_box(Vector3(0.07, 0.12, 0.07), mat_metal_yellow, Vector3(0.0, bay_y + 0.88, bay_center_z))
	bay_root.add_child(lamp_body)
	
	return bay_root
