extends RefCounted
class_name VehicleModelBuilder

# THE LONG MERIDIAN - Authentic Period-Accurate Vehicle 3D Model Builder (Godot 4)
# Crafts detailed, faithful exterior bodies & 3D cockpit interiors for:
# 1. Fiat Panda 4x4 Steyr-Puch (1983 - Tipo 141A Giorgetto Giugiaro)
# 2. Lancia Delta HF Integrale Evoluzione (1991 - Martini Racing Legend)
# 3. Mercedes-Benz G-Klasse W460 / 280GE (1985 - Geländewagen)

# PBR Shared Materials
static var mat_glass: StandardMaterial3D
static var mat_plastic_black: StandardMaterial3D
static var mat_plastic_grey: StandardMaterial3D
static var mat_chrome: StandardMaterial3D
static var mat_steel: StandardMaterial3D
static var mat_headlight: StandardMaterial3D
static var mat_fog_yellow: StandardMaterial3D
static var mat_tail_red: StandardMaterial3D
static var mat_blinker_orange: StandardMaterial3D
static var mat_reverse_white: StandardMaterial3D
static var mat_interior_dark: StandardMaterial3D
static var mat_interior_fabric: StandardMaterial3D
static var mat_leather: StandardMaterial3D
static var mat_brembo_red: StandardMaterial3D
static var mat_jerrycan: StandardMaterial3D
static var mat_exhaust: StandardMaterial3D
static var mat_fiat_blue: StandardMaterial3D
static var mat_lancia_hf: StandardMaterial3D
static var mat_plate_white: StandardMaterial3D
static var mat_plate_black: StandardMaterial3D
static var mat_plate_orange: StandardMaterial3D
static var mat_gti_red: StandardMaterial3D
static var mat_tartan: StandardMaterial3D
static var mat_tail_smoke: StandardMaterial3D
static var mat_bbs_gold: StandardMaterial3D
static var mat_bmw_blue: StandardMaterial3D
static var mat_led_daylight: StandardMaterial3D
static var mat_alfa_red: StandardMaterial3D
static var mat_alfa_amaranto: StandardMaterial3D
static var mat_borrani_wire: StandardMaterial3D
static var mat_topolino_maroon: StandardMaterial3D
static var mat_lancia_blue: StandardMaterial3D
static var mat_wood_steering: StandardMaterial3D
static var mat_stratos_lime: StandardMaterial3D
static var mat_campagnolo_gold: StandardMaterial3D
static var mat_abarth_navy: StandardMaterial3D
static var mat_abarth_yellow: StandardMaterial3D
static var mat_cromodora_silver: StandardMaterial3D
static var mat_autodelta_white: StandardMaterial3D
static var mat_wood_walnut: StandardMaterial3D
static var mat_gauge_amber: StandardMaterial3D
static var mat_gauge_green: StandardMaterial3D
static var mat_mirror_glass: StandardMaterial3D

static func init_materials():
	if mat_glass: return
	
	mat_glass = StandardMaterial3D.new()
	mat_glass.albedo_color = Color(0.92, 0.96, 0.98, 0.16)
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_glass.roughness = 0.04
	mat_glass.metallic = 0.35
	mat_glass.clearcoat_enabled = true
	mat_glass.clearcoat = 1.0
	
	mat_plastic_black = StandardMaterial3D.new()
	mat_plastic_black.albedo_color = Color(0.10, 0.10, 0.11)
	mat_plastic_black.roughness = 0.88
	
	mat_plastic_grey = StandardMaterial3D.new()
	mat_plastic_grey.albedo_color = Color(0.24, 0.25, 0.26)
	mat_plastic_grey.roughness = 0.85
	
	mat_chrome = StandardMaterial3D.new()
	mat_chrome.albedo_color = Color(0.92, 0.94, 0.96)
	mat_chrome.metallic = 0.78
	mat_chrome.metallic_specular = 0.35
	mat_chrome.roughness = 0.30
	
	mat_steel = StandardMaterial3D.new()
	mat_steel.albedo_color = Color(0.68, 0.70, 0.72)
	mat_steel.metallic = 0.80
	mat_steel.roughness = 0.32
	
	mat_headlight = StandardMaterial3D.new()
	mat_headlight.albedo_color = Color(0.95, 0.97, 1.0, 0.92)
	mat_headlight.emission_enabled = true
	mat_headlight.emission = Color(1.0, 0.98, 0.90)
	mat_headlight.emission_energy_multiplier = 1.5
	mat_headlight.roughness = 0.10
	
	mat_fog_yellow = StandardMaterial3D.new()
	mat_fog_yellow.albedo_color = Color(1.0, 0.82, 0.12)
	mat_fog_yellow.emission_enabled = true
	mat_fog_yellow.emission = Color(1.0, 0.78, 0.10)
	mat_fog_yellow.emission_energy_multiplier = 1.8
	mat_fog_yellow.roughness = 0.12
	
	mat_tail_red = StandardMaterial3D.new()
	mat_tail_red.albedo_color = Color(0.88, 0.08, 0.08)
	mat_tail_red.emission_enabled = true
	mat_tail_red.emission = Color(0.95, 0.05, 0.05)
	mat_tail_red.emission_energy_multiplier = 1.8
	mat_tail_red.roughness = 0.15
	
	mat_blinker_orange = StandardMaterial3D.new()
	mat_blinker_orange.albedo_color = Color(1.0, 0.55, 0.05)
	mat_blinker_orange.emission_enabled = true
	mat_blinker_orange.emission = Color(1.0, 0.50, 0.0)
	mat_blinker_orange.emission_energy_multiplier = 1.8
	mat_blinker_orange.roughness = 0.15
	
	mat_reverse_white = StandardMaterial3D.new()
	mat_reverse_white.albedo_color = Color(0.92, 0.95, 0.98)
	mat_reverse_white.roughness = 0.15
	
	mat_interior_dark = StandardMaterial3D.new()
	mat_interior_dark.albedo_color = Color(0.12, 0.13, 0.14)
	mat_interior_dark.roughness = 0.92
	
	mat_interior_fabric = StandardMaterial3D.new()
	mat_interior_fabric.albedo_color = Color(0.38, 0.42, 0.36) # Giugiaro olive canvas
	mat_interior_fabric.roughness = 0.95
	
	mat_leather = StandardMaterial3D.new()
	mat_leather.albedo_color = Color(0.15, 0.15, 0.16)
	mat_leather.roughness = 0.70
	
	mat_brembo_red = StandardMaterial3D.new()
	mat_brembo_red.albedo_color = Color(0.88, 0.08, 0.10)
	mat_brembo_red.roughness = 0.35
	
	mat_jerrycan = StandardMaterial3D.new()
	mat_jerrycan.albedo_color = Color(0.75, 0.18, 0.15)
	mat_jerrycan.roughness = 0.45
	
	mat_exhaust = StandardMaterial3D.new()
	mat_exhaust.albedo_color = Color(0.85, 0.86, 0.88)
	mat_exhaust.metallic = 0.90
	mat_exhaust.roughness = 0.20
	
	mat_fiat_blue = StandardMaterial3D.new()
	mat_fiat_blue.albedo_color = Color(0.08, 0.25, 0.65)
	mat_fiat_blue.roughness = 0.30
	mat_fiat_blue.metallic_specular = 0.35
	
	mat_lancia_hf = StandardMaterial3D.new()
	mat_lancia_hf.albedo_color = Color(0.95, 0.85, 0.10)
	mat_lancia_hf.roughness = 0.30
	
	mat_plate_white = StandardMaterial3D.new()
	mat_plate_white.albedo_color = Color(0.95, 0.95, 0.92)
	mat_plate_white.roughness = 0.82
	mat_plate_white.metallic = 0.0
	mat_plate_white.metallic_specular = 0.12
	
	mat_plate_black = StandardMaterial3D.new()
	mat_plate_black.albedo_color = Color(0.08, 0.08, 0.09)
	mat_plate_black.roughness = 0.88
	mat_plate_black.metallic = 0.0
	mat_plate_black.metallic_specular = 0.10
	
	mat_plate_orange = StandardMaterial3D.new()
	mat_plate_orange.albedo_color = Color(0.95, 0.50, 0.08)
	mat_plate_orange.roughness = 0.82
	mat_plate_orange.metallic = 0.0
	mat_plate_orange.metallic_specular = 0.12
	
	mat_gti_red = StandardMaterial3D.new()
	mat_gti_red.albedo_color = Color(0.88, 0.08, 0.08)
	mat_gti_red.roughness = 0.20
	mat_gti_red.clearcoat_enabled = true
	mat_gti_red.clearcoat = 0.80
	
	mat_tartan = StandardMaterial3D.new()
	mat_tartan.albedo_color = Color(0.24, 0.25, 0.28)
	mat_tartan.roughness = 0.92
	
	mat_tail_smoke = StandardMaterial3D.new()
	mat_tail_smoke.albedo_color = Color(0.22, 0.20, 0.20, 0.95)
	mat_tail_smoke.roughness = 0.25
	
	mat_bbs_gold = StandardMaterial3D.new()
	mat_bbs_gold.albedo_color = Color(0.85, 0.72, 0.40)
	mat_bbs_gold.metallic = 0.75
	mat_bbs_gold.roughness = 0.25

	mat_bmw_blue = StandardMaterial3D.new()
	mat_bmw_blue.albedo_color = Color(0.05, 0.42, 0.85)
	mat_bmw_blue.roughness = 0.30

	mat_led_daylight = StandardMaterial3D.new()
	mat_led_daylight.albedo_color = Color(0.92, 0.96, 1.0)
	mat_led_daylight.emission_enabled = true
	mat_led_daylight.emission = Color(0.90, 0.95, 1.0)
	mat_led_daylight.emission_energy_multiplier = 2.8
	mat_led_daylight.roughness = 0.10

	# Period Materials (1930s - 1970s Historic Icons)
	mat_alfa_red = StandardMaterial3D.new()
	mat_alfa_red.albedo_color = Color(0.72, 0.05, 0.07)
	mat_alfa_red.roughness = 0.15
	mat_alfa_red.metallic = 0.10
	mat_alfa_red.clearcoat_enabled = true
	mat_alfa_red.clearcoat = 0.95

	mat_alfa_amaranto = StandardMaterial3D.new()
	mat_alfa_amaranto.albedo_color = Color(0.42, 0.06, 0.10)
	mat_alfa_amaranto.roughness = 0.18
	mat_alfa_amaranto.metallic = 0.15
	mat_alfa_amaranto.clearcoat_enabled = true
	mat_alfa_amaranto.clearcoat = 0.90

	mat_borrani_wire = StandardMaterial3D.new()
	mat_borrani_wire.albedo_color = Color(0.94, 0.95, 0.98)
	mat_borrani_wire.metallic = 0.94
	mat_borrani_wire.roughness = 0.12

	mat_topolino_maroon = StandardMaterial3D.new()
	mat_topolino_maroon.albedo_color = Color(0.36, 0.07, 0.09)
	mat_topolino_maroon.roughness = 0.22
	mat_topolino_maroon.metallic = 0.05
	mat_topolino_maroon.clearcoat_enabled = true
	mat_topolino_maroon.clearcoat = 0.85

	mat_lancia_blue = StandardMaterial3D.new()
	mat_lancia_blue.albedo_color = Color(0.06, 0.12, 0.32)
	mat_lancia_blue.roughness = 0.16
	mat_lancia_blue.metallic = 0.30
	mat_lancia_blue.clearcoat_enabled = true
	mat_lancia_blue.clearcoat = 0.95

	mat_wood_steering = StandardMaterial3D.new()
	mat_wood_steering.albedo_color = Color(0.40, 0.22, 0.10)
	mat_wood_steering.roughness = 0.45
	mat_wood_steering.metallic = 0.0

	mat_stratos_lime = StandardMaterial3D.new()
	mat_stratos_lime.albedo_color = Color(0.70, 0.84, 0.14)
	mat_stratos_lime.roughness = 0.18
	mat_stratos_lime.clearcoat_enabled = true
	mat_stratos_lime.clearcoat = 0.90

	mat_campagnolo_gold = StandardMaterial3D.new()
	mat_campagnolo_gold.albedo_color = Color(0.85, 0.70, 0.28)
	mat_campagnolo_gold.metallic = 0.82
	mat_campagnolo_gold.roughness = 0.25

	mat_abarth_navy = StandardMaterial3D.new()
	mat_abarth_navy.albedo_color = Color(0.07, 0.14, 0.42)
	mat_abarth_navy.roughness = 0.18
	mat_abarth_navy.metallic = 0.25
	mat_abarth_navy.clearcoat_enabled = true
	mat_abarth_navy.clearcoat = 0.90

	mat_abarth_yellow = StandardMaterial3D.new()
	mat_abarth_yellow.albedo_color = Color(0.96, 0.82, 0.08)
	mat_abarth_yellow.roughness = 0.22
	mat_abarth_yellow.clearcoat_enabled = true
	mat_abarth_yellow.clearcoat = 0.80

	mat_cromodora_silver = StandardMaterial3D.new()
	mat_cromodora_silver.albedo_color = Color(0.78, 0.80, 0.82)
	mat_cromodora_silver.metallic = 0.78
	mat_cromodora_silver.roughness = 0.28

	mat_autodelta_white = StandardMaterial3D.new()
	mat_autodelta_white.albedo_color = Color(0.95, 0.95, 0.96)
	mat_autodelta_white.roughness = 0.20
	mat_autodelta_white.clearcoat_enabled = true
	mat_autodelta_white.clearcoat = 0.85
	
	mat_wood_walnut = StandardMaterial3D.new()
	mat_wood_walnut.albedo_color = Color(0.36, 0.20, 0.11)
	mat_wood_walnut.roughness = 0.32
	mat_wood_walnut.clearcoat_enabled = true
	mat_wood_walnut.clearcoat = 0.85
	
	mat_gauge_amber = StandardMaterial3D.new()
	mat_gauge_amber.albedo_color = Color(1.0, 0.55, 0.10)
	mat_gauge_amber.emission_enabled = true
	mat_gauge_amber.emission = Color(1.0, 0.50, 0.08)
	mat_gauge_amber.emission_energy_multiplier = 2.2
	
	mat_gauge_green = StandardMaterial3D.new()
	mat_gauge_green.albedo_color = Color(0.20, 0.95, 0.40)
	mat_gauge_green.emission_enabled = true
	mat_gauge_green.emission = Color(0.20, 0.95, 0.40)
	mat_gauge_green.emission_energy_multiplier = 2.0
	
	mat_mirror_glass = StandardMaterial3D.new()
	mat_mirror_glass.albedo_color = Color(0.88, 0.90, 0.94)
	mat_mirror_glass.metallic = 0.95
	mat_mirror_glass.roughness = 0.04

	# Calibrazione PBR specular e roughness per eliminare bagliori speculari innaturali e firefly
	var auto_mats = [
		mat_glass, mat_chrome, mat_steel, mat_fiat_blue, mat_lancia_hf, mat_gti_red, mat_bmw_blue,
		mat_alfa_red, mat_alfa_amaranto, mat_borrani_wire, mat_topolino_maroon, mat_lancia_blue,
		mat_stratos_lime, mat_campagnolo_gold, mat_abarth_navy, mat_abarth_yellow, mat_cromodora_silver,
		mat_autodelta_white
	]
	for m in auto_mats:
		if m is StandardMaterial3D and m != mat_glass:
			m.metallic_specular = 0.35
			m.roughness = max(0.18, m.roughness)

# ==============================================================================
# 1. FIAT PANDA 4x4 STEYR-PUCH (1983 - Tipo 141A Giorgetto Giugiaro)
# ==============================================================================
static func build_panda_4x4(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "PandaRig"
	parent.add_child(root)
	
	# --- 1. LOWER BODY & GIUGIARO TWO-BOX CHASSIS ---
	var lower_body = create_box(Vector3(1.44, 0.38, 3.36), body_mat, Vector3(0.0, 0.44, 0.0))
	root.add_child(lower_body)
	
	# Sloping Wedge Hood (Rakes forward from cowl Y=0.70 to nose Y=0.58)
	var hood = create_box(Vector3(1.38, 0.18, 1.15), body_mat, Vector3(0.0, 0.64, -1.05))
	hood.rotation.x = deg_to_rad(-4.5)
	root.add_child(hood)
	
	# Central bonnet indentation crease (Giugiaro feature)
	var hood_crease = create_box(Vector3(0.38, 0.03, 1.05), mat_plastic_black, Vector3(0.0, 0.72, -1.05))
	hood_crease.rotation.x = deg_to_rad(-4.5)
	root.add_child(hood_crease)
	
	# Rear Quarter & Tailgate Panels
	var rear_deck = create_box(Vector3(1.40, 0.42, 0.48), body_mat, Vector3(0.0, 0.68, 1.40))
	root.add_child(rear_deck)
	
	# --- 2. FRONT NOSE & ASYMMETRIC FIAT 5-BAR GRILLE ---
	var nose_panel = create_box(Vector3(1.36, 0.24, 0.08), mat_plastic_black, Vector3(0.0, 0.55, -1.68))
	root.add_child(nose_panel)
	
	# Asymmetric 5-bar chrome Fiat Logo (1980s signature /// / /)
	for bar_i in range(5):
		var bar = create_box(Vector3(0.022, 0.14, 0.03), mat_chrome, Vector3(-0.16 + float(bar_i) * 0.055, 0.55, -1.72))
		bar.rotation.z = deg_to_rad(-22.0)
		root.add_child(bar)
		
	# Square Carello Halogen Headlights
	var hl_l = create_box(Vector3(0.24, 0.17, 0.04), mat_headlight, Vector3(-0.48, 0.55, -1.70))
	var hl_r = create_box(Vector3(0.24, 0.17, 0.04), mat_headlight, Vector3(0.48, 0.55, -1.70))
	root.add_child(hl_l); root.add_child(hl_r)
	
	# Corner Wrap-around Amber Turn Indicators
	var bl_l = create_box(Vector3(0.10, 0.17, 0.08), mat_blinker_orange, Vector3(-0.64, 0.55, -1.67))
	var bl_r = create_box(Vector3(0.10, 0.17, 0.08), mat_blinker_orange, Vector3(0.64, 0.55, -1.67))
	root.add_child(bl_l); root.add_child(bl_r)
	
	# --- 3. BUMPERS & STEYR-PUCH BULLBAR ---
	var front_bumper = create_box(Vector3(1.48, 0.16, 0.24), mat_plastic_black, Vector3(0.0, 0.32, -1.72))
	root.add_child(front_bumper)
	
	var rear_bumper = create_box(Vector3(1.48, 0.16, 0.22), mat_plastic_black, Vector3(0.0, 0.32, 1.70))
	root.add_child(rear_bumper)
	
	# Steyr-Puch Tubular Steel Bullbar with skid plate
	var bb_frame = create_box(Vector3(1.05, 0.32, 0.06), mat_steel, Vector3(0.0, 0.44, -1.82))
	var skid_plate = create_box(Vector3(0.70, 0.06, 0.42), mat_steel, Vector3(0.0, 0.18, -1.62))
	skid_plate.rotation.x = deg_to_rad(20.0)
	root.add_child(bb_frame); root.add_child(skid_plate)
	
	# Twin Round Yellow Carello Fog Lamps
	for fog_x in [-0.26, 0.26]:
		var fog = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.09; cyl.bottom_radius = 0.09; cyl.height = 0.06; cyl.radial_segments = 14
		cyl.material = mat_fog_yellow
		fog.mesh = cyl
		fog.position = Vector3(fog_x, 0.48, -1.86)
		fog.rotation.x = PI * 0.5
		root.add_child(fog)
		
	# Front Vintage Italian License Plate: TO 48312M
	var f_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.26, -1.84), false)
	root.add_child(f_plate)
	var r_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.48, 1.72), true)
	root.add_child(r_plate)
	
	# --- 4. GIUGIARO RIBBED CORRUGATED SIDE CLADDING ---
	for side in [-1.0, 1.0]:
		var clad = create_box(Vector3(0.04, 0.26, 1.72), mat_plastic_grey, Vector3(side * 0.73, 0.42, 0.05))
		root.add_child(clad)
		for rib_i in range(3):
			var rib = create_box(Vector3(0.02, 0.03, 1.68), mat_plastic_black, Vector3(side * 0.75, 0.34 + float(rib_i) * 0.07, 0.05))
			root.add_child(rib)
		var badge = create_box(Vector3(0.02, 0.06, 0.16), mat_steel, Vector3(side * 0.75, 0.50, 0.55))
		root.add_child(badge)
		var arch_f = create_box(Vector3(0.06, 0.12, 0.72), mat_plastic_black, Vector3(side * 0.73, 0.48, -1.08))
		var arch_r = create_box(Vector3(0.06, 0.12, 0.72), mat_plastic_black, Vector3(side * 0.73, 0.48, 1.08))
		root.add_child(arch_f); root.add_child(arch_r)
		var mirror = create_box(Vector3(0.14, 0.10, 0.06), mat_plastic_black, Vector3(side * 0.74, 0.82, -0.48))
		root.add_child(mirror)
		# Recessed door handle
		var handle = create_box(Vector3(0.02, 0.04, 0.12), mat_plastic_black, Vector3(side * 0.73, 0.68, -0.15))
		root.add_child(handle)
		
	# --- 5. CABIN GREENHOUSE, PILLARS & TRANSPARENT GLASS ---
	var windshield = create_box(Vector3(1.22, 0.04, 0.72), mat_glass, Vector3(0.0, 0.90, -0.28))
	windshield.rotation.x = deg_to_rad(-42.0)
	root.add_child(windshield)
	
	# Single Large Pantograph Windshield Wiper (Giugiaro Signature! - Parked flat along cowl)
	var wiper = create_box(Vector3(0.020, 0.42, 0.015), mat_plastic_black, Vector3(0.06, 0.73, -0.36))
	wiper.rotation.x = deg_to_rad(-42.0)
	wiper.rotation.z = deg_to_rad(-82.0)
	root.add_child(wiper)
	
	var side_glass_l = create_box(Vector3(0.03, 0.44, 1.48), mat_glass, Vector3(-0.62, 0.94, 0.44))
	var side_glass_r = create_box(Vector3(0.03, 0.44, 1.48), mat_glass, Vector3(0.62, 0.94, 0.44))
	root.add_child(side_glass_l); root.add_child(side_glass_r)
	
	var bp_l = create_box(Vector3(0.05, 0.46, 0.10), mat_plastic_black, Vector3(-0.62, 0.94, 0.38))
	var bp_r = create_box(Vector3(0.05, 0.46, 0.10), mat_plastic_black, Vector3(0.62, 0.94, 0.38))
	root.add_child(bp_l); root.add_child(bp_r)
	
	var rear_glass = create_box(Vector3(1.18, 0.42, 0.03), mat_glass, Vector3(0.0, 0.95, 1.44))
	root.add_child(rear_glass)
	
	var roof_panel = create_box(Vector3(1.26, 0.05, 1.82), body_mat, Vector3(0.0, 1.18, 0.44))
	root.add_child(roof_panel)
	
	# --- 6. AUTHENTIC 3D COCKPIT INTERIOR ---
	# Giugiaro Padded "Marsupio" Dashboard Shelf (canvas pouch spanning entire cabin)
	var marsupio = create_box(Vector3(1.18, 0.14, 0.36), mat_interior_fabric, Vector3(0.0, 0.72, -0.32))
	root.add_child(marsupio)
	
	# Veglia Borletti "Cubo" Instrument Binnacle
	var cubo = create_box(Vector3(0.36, 0.18, 0.22), mat_plastic_black, Vector3(-0.35, 0.84, -0.35))
	var speedo_face = create_box(Vector3(0.32, 0.14, 0.02), mat_interior_dark, Vector3(-0.35, 0.84, -0.24))
	root.add_child(cubo); root.add_child(speedo_face)
	
	# Circular Speedometer Bezel, dial & fluorescent needle
	var p_sp_bezel = create_round_lamp(0.058, mat_chrome, Vector3(-0.42, 0.84, -0.235))
	var p_sp_dial = create_round_lamp(0.050, mat_plastic_black, Vector3(-0.42, 0.84, -0.231))
	var p_sp_needle = create_box(Vector3(0.008, 0.042, 0.005), mat_gauge_amber, Vector3(-0.42, 0.86, -0.228))
	p_sp_needle.rotation.z = deg_to_rad(-22.0)
	var p_sp_pin = create_round_lamp(0.009, mat_steel, Vector3(-0.42, 0.84, -0.226))
	root.add_child(p_sp_bezel); root.add_child(p_sp_dial); root.add_child(p_sp_needle); root.add_child(p_sp_pin)
	
	# Horizontal Fuel & Water meters in right section of Cubo
	var p_fuel_bar = create_box(Vector3(0.11, 0.022, 0.008), mat_steel, Vector3(-0.27, 0.86, -0.235))
	var p_fuel_n = create_box(Vector3(0.008, 0.018, 0.006), mat_gauge_amber, Vector3(-0.25, 0.86, -0.230))
	var p_temp_bar = create_box(Vector3(0.11, 0.022, 0.008), mat_steel, Vector3(-0.27, 0.825, -0.235))
	var p_temp_n = create_box(Vector3(0.008, 0.018, 0.006), mat_gauge_amber, Vector3(-0.27, 0.825, -0.230))
	root.add_child(p_fuel_bar); root.add_child(p_fuel_n); root.add_child(p_temp_bar); root.add_child(p_temp_n)
	
	# Indicator Warning Lamps (GEN, OLIO, LUCI, 4WD)
	var p_lamp_gen = create_box(Vector3(0.02, 0.014, 0.008), mat_tail_red, Vector3(-0.31, 0.795, -0.232))
	var p_lamp_oil = create_box(Vector3(0.02, 0.014, 0.008), mat_tail_red, Vector3(-0.27, 0.795, -0.232))
	var p_lamp_luc = create_box(Vector3(0.02, 0.014, 0.008), mat_gauge_green, Vector3(-0.23, 0.795, -0.232))
	root.add_child(p_lamp_gen); root.add_child(p_lamp_oil); root.add_child(p_lamp_luc)
	
	# Steyr-Puch Dual Spherical Clinometer on center of dash
	var clino_pod = create_box(Vector3(0.24, 0.10, 0.12), mat_plastic_black, Vector3(0.05, 0.82, -0.32))
	var clino_face_l = create_box(Vector3(0.09, 0.07, 0.01), mat_plastic_black, Vector3(-0.02, 0.82, -0.255))
	var clino_face_r = create_box(Vector3(0.09, 0.07, 0.01), mat_plastic_black, Vector3(0.12, 0.82, -0.255))
	var clino_cross_l = create_box(Vector3(0.06, 0.008, 0.006), mat_gauge_green, Vector3(-0.02, 0.82, -0.250))
	var clino_cross_r = create_box(Vector3(0.06, 0.008, 0.006), mat_gauge_green, Vector3(0.12, 0.82, -0.250))
	root.add_child(clino_pod); root.add_child(clino_face_l); root.add_child(clino_face_r)
	root.add_child(clino_cross_l); root.add_child(clino_cross_r)
	
	# Devioluci Stalks on steering column
	var p_stalk_l = create_box(Vector3(0.08, 0.012, 0.012), mat_plastic_black, Vector3(-0.43, 0.81, -0.19))
	p_stalk_l.rotation.z = deg_to_rad(-16.0)
	var p_stalk_r = create_box(Vector3(0.08, 0.012, 0.012), mat_plastic_black, Vector3(-0.27, 0.81, -0.19))
	p_stalk_r.rotation.z = deg_to_rad(16.0)
	root.add_child(p_stalk_l); root.add_child(p_stalk_r)
	
	# Interior Rearview Mirror and Sun Visors
	var p_mir_stem = create_box(Vector3(0.018, 0.06, 0.018), mat_plastic_black, Vector3(0.0, 1.10, -0.32))
	var p_mir_case = create_box(Vector3(0.16, 0.05, 0.022), mat_plastic_black, Vector3(0.0, 1.06, -0.30))
	var p_mir_glass = create_box(Vector3(0.145, 0.04, 0.008), mat_mirror_glass, Vector3(0.0, 1.06, -0.29))
	root.add_child(p_mir_stem); root.add_child(p_mir_case); root.add_child(p_mir_glass)
	for vx in [-0.36, 0.36]:
		var visor = create_box(Vector3(0.32, 0.075, 0.015), mat_interior_fabric, Vector3(vx, 1.12, -0.26))
		visor.rotation.x = deg_to_rad(22.0)
		root.add_child(visor)
	
	# Dynamic Rotating 2-Spoke Giugiaro Steering Wheel (Clean pivot hierarchy)
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.35, 0.82, -0.16)
	steer_pivot.rotation.x = deg_to_rad(-24.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_Panda"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.14; torus.outer_radius = 0.17; torus.rings = 16; torus.ring_segments = 10
	torus.material = mat_plastic_black
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5 # Aligns torus to XY plane of steering wheel!
	steer_node.add_child(sw_rim)
	
	var spoke = create_box(Vector3(0.30, 0.04, 0.02), mat_plastic_black, Vector3(0, 0, 0))
	var fiat_badge = create_box(Vector3(0.06, 0.03, 0.02), mat_fiat_blue, Vector3(0, 0, 0.015))
	steer_node.add_child(spoke); steer_node.add_child(fiat_badge)
	
	# Front Canvas Deckchair Seats with Headrests
	for seat_x in [-0.34, 0.34]:
		var seat_base = create_box(Vector3(0.42, 0.14, 0.44), mat_interior_fabric, Vector3(seat_x, 0.50, 0.12))
		var seat_back = create_box(Vector3(0.40, 0.44, 0.10), mat_interior_fabric, Vector3(seat_x, 0.75, 0.32))
		seat_back.rotation.x = deg_to_rad(12.0)
		var headrest = create_box(Vector3(0.24, 0.12, 0.08), mat_plastic_black, Vector3(seat_x, 1.02, 0.38))
		root.add_child(seat_base); root.add_child(seat_back); root.add_child(headrest)
		
	# Rear Seat Bench
	var rear_seat = create_box(Vector3(1.10, 0.14, 0.42), mat_interior_fabric, Vector3(0.0, 0.54, 0.95))
	var rear_back = create_box(Vector3(1.10, 0.42, 0.10), mat_interior_fabric, Vector3(0.0, 0.78, 1.16))
	root.add_child(rear_seat); root.add_child(rear_back)
	
	# Center Floor: Gear Lever & Steyr 4WD Lever with yellow knob
	var shift_knob = create_box(Vector3(0.04, 0.20, 0.04), mat_plastic_black, Vector3(0.0, 0.60, -0.05))
	var steyr_lever = create_box(Vector3(0.03, 0.16, 0.03), mat_fog_yellow, Vector3(0.08, 0.58, 0.05))
	root.add_child(shift_knob); root.add_child(steyr_lever)
	
	# --- 7. REAR TAIL LIGHTS & MUD FLAPS ---
	for side in [-1.0, 1.0]:
		var tl_group = Node3D.new()
		tl_group.position = Vector3(side * 0.58, 0.68, 1.66)
		var amber_t = create_box(Vector3(0.12, 0.10, 0.03), mat_blinker_orange, Vector3(0.0, 0.10, 0.0))
		var red_m = create_box(Vector3(0.12, 0.10, 0.03), mat_tail_red, Vector3(0.0, 0.0, 0.0))
		var white_b = create_box(Vector3(0.12, 0.08, 0.03), mat_reverse_white, Vector3(0.0, -0.09, 0.0))
		tl_group.add_child(amber_t); tl_group.add_child(red_m); tl_group.add_child(white_b)
		root.add_child(tl_group)
		
		var flap = create_box(Vector3(0.18, 0.18, 0.02), mat_plastic_black, Vector3(side * 0.62, 0.22, 1.34))
		var flap_txt = create_box(Vector3(0.12, 0.04, 0.01), mat_steel, Vector3(side * 0.62, 0.22, 1.35))
		root.add_child(flap); root.add_child(flap_txt)
		
	# --- 8. EXPEDITION ROOF BASKET & EQUIPMENT ---
	var rack_frame = create_box(Vector3(1.18, 0.05, 1.48), mat_steel, Vector3(0.0, 1.25, 0.44))
	root.add_child(rack_frame)
	var roof_tire = MeshInstance3D.new()
	var rt_cyl = CylinderMesh.new()
	rt_cyl.top_radius = 0.27; rt_cyl.bottom_radius = 0.27; rt_cyl.height = 0.16; rt_cyl.radial_segments = 16
	rt_cyl.material = mat_plastic_black
	roof_tire.mesh = rt_cyl
	roof_tire.position = Vector3(-0.24, 1.34, 0.46)
	root.add_child(roof_tire)
	
	var jerrycan = create_box(Vector3(0.18, 0.28, 0.24), mat_jerrycan, Vector3(0.28, 1.38, 0.32))
	var chest = create_box(Vector3(0.32, 0.18, 0.42), mat_steel, Vector3(0.24, 1.33, 0.72))
	root.add_child(jerrycan); root.add_child(chest)
	
	return root

# ==============================================================================
# 2. LANCIA DELTA HF INTEGRALE EVOLUZIONE (1991 - Martini Racing Icon)
# ==============================================================================
static func build_delta_integrale(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "DeltaRig"
	parent.add_child(root)
	
	# --- 1. WIDE-BODY RALLY CHASSIS & POWER-BULGE HOOD ---
	var lower_body = create_box(Vector3(1.64, 0.38, 3.86), body_mat, Vector3(0.0, 0.42, 0.0))
	root.add_child(lower_body)
	
	# Sculpted Rally Hood with Power-Bulge & Cooling Extraction Louvres
	var hood = create_sculpted_hood(Vector3(0.0, 0.52, -0.55), 1.48, 1.38, 1.25, 0.12, -0.06, 0.055, body_mat, 10, 10)
	root.add_child(hood)
	
	var power_dome = create_box(Vector3(0.86, 0.06, 0.95), body_mat, Vector3(0.0, 0.67, -1.15))
	power_dome.rotation.x = deg_to_rad(-3.5)
	root.add_child(power_dome)
	
	for l_side in [-0.28, 0.28]:
		var vent = create_box(Vector3(0.18, 0.02, 0.32), mat_plastic_black, Vector3(l_side, 0.72, -1.05))
		root.add_child(vent)
		
	# --- 2. FRONT RALLY AIR DAM & QUAD PARABOLIC HEADLIGHTS ---
	var front_bumper = create_curved_bumper(Vector3(0.0, 0.30, -1.94), 1.72, 0.28, 0.24, 0.10, body_mat, false, 18)
	root.add_child(front_bumper)
	
	var splitter = create_box(Vector3(1.74, 0.04, 0.36), mat_plastic_black, Vector3(0.0, 0.16, -1.94))
	var intercooler_intake = create_box(Vector3(0.84, 0.14, 0.08), mat_plastic_black, Vector3(0.0, 0.26, -2.06))
	root.add_child(splitter); root.add_child(intercooler_intake)
	
	var grille_frame = create_box(Vector3(0.48, 0.20, 0.06), mat_chrome, Vector3(0.0, 0.54, -1.96))
	var hf_badge = create_box(Vector3(0.08, 0.08, 0.02), mat_lancia_hf, Vector3(0.12, 0.54, -1.99))
	root.add_child(grille_frame); root.add_child(hf_badge)
	
	for side in [-1.0, 1.0]:
		var outer_lamp = create_parabolic_headlamp(Vector3(side * 0.62, 0.54, -1.96), 0.08, 0.06, mat_chrome, mat_headlight)
		var inner_lamp = create_parabolic_headlamp(Vector3(side * 0.42, 0.54, -1.96), 0.075, 0.06, mat_chrome, mat_fog_yellow)
		var blinker = create_box(Vector3(0.12, 0.08, 0.08), mat_blinker_orange, Vector3(side * 0.78, 0.44, -1.92))
		root.add_child(outer_lamp); root.add_child(inner_lamp); root.add_child(blinker)
		
	# Italian White Rally Plate: TO 1991HF
	var f_plate = create_license_plate_italian_modern(Vector3(0.0, 0.22, -2.10))
	var r_plate = create_license_plate_italian_modern(Vector3(0.0, 0.40, 1.98))
	root.add_child(f_plate); root.add_child(r_plate)
	
	# Twin Stainless Steel Rally Exhaust
	var exh_delta = create_curved_exhaust_pipe(Vector3(-0.52, 0.26, 1.95), 0.065, 0.24, mat_exhaust, true)
	root.add_child(exh_delta)
	
	# --- 3. ICONIC BLISTER BOX-FLARES ("BOMBATURE EVOLUZIONE") ---
	var arch_fl = create_flared_rally_box_arch(Vector3(-0.84, 0.38, -1.24), 0.35, 0.08, 0.12, true, body_mat, 18)
	var arch_fr = create_flared_rally_box_arch(Vector3(0.84, 0.38, -1.24), 0.35, 0.08, 0.12, false, body_mat, 18)
	var arch_rl = create_flared_rally_box_arch(Vector3(-0.84, 0.38, 1.24), 0.35, 0.08, 0.12, true, body_mat, 18)
	var arch_rr = create_flared_rally_box_arch(Vector3(0.84, 0.38, 1.24), 0.35, 0.08, 0.12, false, body_mat, 18)
	root.add_child(arch_fl); root.add_child(arch_fr); root.add_child(arch_rl); root.add_child(arch_rr)
	
	for side in [-1.0, 1.0]:
		var skirt = create_box(Vector3(0.08, 0.12, 1.45), mat_plastic_black, Vector3(side * 0.83, 0.24, 0.0))
		root.add_child(skirt)
		
		var mirror = create_box(Vector3(0.14, 0.08, 0.06), mat_plastic_black, Vector3(side * 0.80, 0.78, -0.58))
		root.add_child(mirror)
		
		# Red Brembo 4-Piston Calipers behind wheels
		var caliper_f = create_box(Vector3(0.06, 0.12, 0.10), mat_brembo_red, Vector3(side * 0.78, 0.32, -1.20))
		var caliper_r = create_box(Vector3(0.06, 0.10, 0.08), mat_brembo_red, Vector3(side * 0.78, 0.32, 1.28))
		root.add_child(caliper_f); root.add_child(caliper_r)
		
	# --- 4. GREENHOUSE, WINDOWS & ADJUSTABLE RALLY ROOF WING ---
	var windshield = create_box(Vector3(1.36, 0.04, 0.78), mat_glass, Vector3(0.0, 0.86, -0.38))
	windshield.rotation.x = deg_to_rad(-48.0)
	root.add_child(windshield)
	
	# Twin Aerodynamic Rally Wipers (Parked flat along cowl)
	for wx in [-0.30, 0.20]:
		var w = create_box(Vector3(0.015, 0.40, 0.015), mat_plastic_black, Vector3(wx, 0.72, -0.46))
		w.rotation.x = deg_to_rad(-48.0)
		w.rotation.z = deg_to_rad(-82.0)
		root.add_child(w)
		
	var side_glass_l = create_box(Vector3(0.03, 0.38, 1.70), mat_glass, Vector3(-0.70, 0.88, 0.40))
	var side_glass_r = create_box(Vector3(0.03, 0.38, 1.70), mat_glass, Vector3(0.70, 0.88, 0.40))
	root.add_child(side_glass_l); root.add_child(side_glass_r)
	
	var rear_glass = create_box(Vector3(1.30, 0.44, 0.03), mat_glass, Vector3(0.0, 0.90, 1.62))
	rear_glass.rotation.x = deg_to_rad(28.0)
	root.add_child(rear_glass)
	
	var roof_panel = create_box(Vector3(1.42, 0.05, 1.85), body_mat, Vector3(0.0, 1.10, 0.42))
	root.add_child(roof_panel)
	
	# High-Mounted Adjustable Rally Wing with Twin Alloy Brackets
	var wing_blade = create_box(Vector3(1.55, 0.06, 0.32), mat_plastic_black, Vector3(0.0, 1.28, 1.60))
	wing_blade.rotation.x = deg_to_rad(18.0)
	var wing_b1 = create_box(Vector3(0.04, 0.18, 0.12), mat_steel, Vector3(-0.52, 1.20, 1.58))
	var wing_b2 = create_box(Vector3(0.04, 0.18, 0.12), mat_steel, Vector3(0.52, 1.20, 1.58))
	root.add_child(wing_blade); root.add_child(wing_b1); root.add_child(wing_b2)
	
	# --- 5. 3D RALLY COCKPIT INTERIOR ---
	var dash = create_box(Vector3(1.30, 0.20, 0.40), mat_interior_dark, Vector3(0.0, 0.68, -0.42))
	var cluster_pod = create_box(Vector3(0.44, 0.16, 0.24), mat_interior_dark, Vector3(-0.38, 0.80, -0.44))
	var turbo_gauge_pod = create_box(Vector3(0.16, 0.12, 0.16), mat_interior_dark, Vector3(0.0, 0.78, -0.40))
	root.add_child(dash); root.add_child(cluster_pod); root.add_child(turbo_gauge_pod)
	
	# Veglia Corse Yellow Dials: Speedometer (260 km/h) & Tachometer (8000 rpm)
	var d_sp_dial = create_round_lamp(0.058, mat_fog_yellow, Vector3(-0.46, 0.80, -0.315))
	var d_sp_needle = create_box(Vector3(0.008, 0.042, 0.006), mat_plastic_black, Vector3(-0.46, 0.82, -0.310))
	d_sp_needle.rotation.z = deg_to_rad(-24.0)
	var d_tac_dial = create_round_lamp(0.058, mat_fog_yellow, Vector3(-0.30, 0.80, -0.315))
	var d_tac_needle = create_box(Vector3(0.008, 0.042, 0.006), mat_plastic_black, Vector3(-0.30, 0.82, -0.310))
	d_tac_needle.rotation.z = deg_to_rad(-30.0)
	root.add_child(d_sp_dial); root.add_child(d_sp_needle); root.add_child(d_tac_dial); root.add_child(d_tac_needle)
	
	# Garrett T3 Center Turbo Boost Gauge (Yellow dial with red needle)
	var d_tb_dial = create_round_lamp(0.048, mat_fog_yellow, Vector3(0.0, 0.78, -0.315))
	var d_tb_needle = create_box(Vector3(0.008, 0.035, 0.006), mat_tail_red, Vector3(0.0, 0.80, -0.310))
	root.add_child(d_tb_dial); root.add_child(d_tb_needle)
	
	# Check Control Matrix on center console
	var d_chk = create_box(Vector3(0.18, 0.09, 0.02), mat_plastic_black, Vector3(0.0, 0.65, -0.35))
	var d_chk_car = create_box(Vector3(0.06, 0.07, 0.005), mat_gauge_amber, Vector3(0.0, 0.65, -0.338))
	root.add_child(d_chk); root.add_child(d_chk_car)
	
	# Column Stalks, Rearview Mirror & Sun Visors
	var d_stalk_l = create_box(Vector3(0.09, 0.012, 0.012), mat_plastic_black, Vector3(-0.46, 0.77, -0.25))
	var d_stalk_r = create_box(Vector3(0.09, 0.012, 0.012), mat_plastic_black, Vector3(-0.30, 0.77, -0.25))
	root.add_child(d_stalk_l); root.add_child(d_stalk_r)
	var d_mir_stem = create_box(Vector3(0.018, 0.06, 0.018), mat_plastic_black, Vector3(0.0, 1.05, -0.38))
	var d_mir_case = create_box(Vector3(0.18, 0.05, 0.02), mat_plastic_black, Vector3(0.0, 1.01, -0.36))
	var d_mir_glass = create_box(Vector3(0.165, 0.04, 0.008), mat_mirror_glass, Vector3(0.0, 1.01, -0.35))
	root.add_child(d_mir_stem); root.add_child(d_mir_case); root.add_child(d_mir_glass)
	for vx in [-0.38, 0.38]:
		var visor = create_box(Vector3(0.34, 0.08, 0.015), mat_interior_dark, Vector3(vx, 1.06, -0.32))
		visor.rotation.x = deg_to_rad(22.0)
		root.add_child(visor)
	
	# Momo Corse 3-Spoke Sports Steering Wheel with yellow 12 o'clock center stripe
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.38, 0.78, -0.22)
	steer_pivot.rotation.x = deg_to_rad(-20.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_Delta"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.13; torus.outer_radius = 0.16; torus.rings = 16; torus.ring_segments = 10
	torus.material = mat_leather
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5
	steer_node.add_child(sw_rim)
	
	var yellow_stripe = create_box(Vector3(0.03, 0.04, 0.03), mat_lancia_hf, Vector3(0, 0.145, 0))
	steer_node.add_child(yellow_stripe)
	
	for a in [-PI * 0.5, PI * 0.15, PI * 0.85]:
		var spoke = create_box(Vector3(0.12, 0.025, 0.02), mat_plastic_black, Vector3(cos(a) * 0.07, sin(a) * 0.07, 0))
		spoke.rotation.z = a
		steer_node.add_child(spoke)
	var momo_hub = create_box(Vector3(0.07, 0.07, 0.03), mat_plastic_black, Vector3(0, 0, 0.01))
	steer_node.add_child(momo_hub)
	
	# Recaro High-Bolster Rally Bucket Seats
	for seat_x in [-0.38, 0.38]:
		var base = create_box(Vector3(0.44, 0.14, 0.46), mat_interior_dark, Vector3(seat_x, 0.46, 0.10))
		var back = create_box(Vector3(0.42, 0.52, 0.10), mat_interior_dark, Vector3(seat_x, 0.74, 0.34))
		back.rotation.x = deg_to_rad(12.0)
		var bolster_l = create_box(Vector3(0.08, 0.46, 0.22), mat_interior_dark, Vector3(seat_x - 0.20, 0.72, 0.30))
		var bolster_r = create_box(Vector3(0.08, 0.46, 0.22), mat_interior_dark, Vector3(seat_x + 0.20, 0.72, 0.30))
		root.add_child(base); root.add_child(back); root.add_child(bolster_l); root.add_child(bolster_r)
		
	# Tall Sequential Rally Shifter & Fly-off Handbrake
	var shifter = create_box(Vector3(0.03, 0.24, 0.03), mat_chrome, Vector3(-0.06, 0.62, -0.08))
	var hbrake = create_box(Vector3(0.03, 0.28, 0.03), mat_plastic_black, Vector3(0.04, 0.64, 0.02))
	root.add_child(shifter); root.add_child(hbrake)
	
	# --- 6. REAR END & TWIN POLISHED STAINLESS EXHAUST ---
	var rear_bumper = create_box(Vector3(1.72, 0.24, 0.26), body_mat, Vector3(0.0, 0.34, 1.88))
	root.add_child(rear_bumper)
	
	for side in [-1.0, 1.0]:
		var tl = create_box(Vector3(0.24, 0.12, 0.04), mat_tail_red, Vector3(side * 0.62, 0.52, 1.94))
		var tl_blink = create_box(Vector3(0.10, 0.12, 0.04), mat_blinker_orange, Vector3(side * 0.76, 0.52, 1.94))
		root.add_child(tl); root.add_child(tl_blink)
		
	for ex_x in [-0.42, -0.30]:
		var pipe = MeshInstance3D.new()
		var p_cyl = CylinderMesh.new()
		p_cyl.top_radius = 0.048; p_cyl.bottom_radius = 0.048; p_cyl.height = 0.20; p_cyl.radial_segments = 14
		p_cyl.material = mat_exhaust
		pipe.mesh = p_cyl
		pipe.position = Vector3(ex_x, 0.22, 1.98)
		pipe.rotation.x = PI * 0.5
		root.add_child(pipe)
		
	return root

# ==============================================================================
# 3. MERCEDES-BENZ G-KLASSE W460 / 280GE (1985 - Geländewagen)
# ==============================================================================
static func build_gwagen_w460(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "GwagenRig"
	parent.add_child(root)
	
	# --- 1. UTILITARIAN BOX CHASSIS & UPRIGHT PROFILE ---
	var lower_body = create_box(Vector3(1.68, 0.56, 4.10), body_mat, Vector3(0.0, 0.55, 0.0))
	root.add_child(lower_body)
	
	var hood = create_box(Vector3(1.58, 0.14, 1.35), body_mat, Vector3(0.0, 0.85, -1.25))
	root.add_child(hood)
	
	var front_axle = create_box(Vector3(1.42, 0.12, 0.12), mat_plastic_black, Vector3(0.0, 0.24, -1.35))
	var rear_axle = create_box(Vector3(1.42, 0.12, 0.12), mat_plastic_black, Vector3(0.0, 0.24, 1.35))
	root.add_child(front_axle); root.add_child(rear_axle)
	
	# --- 2. FLAT RADIATOR GRILLE & THREE-POINTED MERCEDES STAR ---
	var grille_housing = create_box(Vector3(1.52, 0.36, 0.08), mat_plastic_black, Vector3(0.0, 0.72, -2.06))
	root.add_child(grille_housing)
	
	var star_ring = MeshInstance3D.new()
	var t_mesh = TorusMesh.new()
	t_mesh.inner_radius = 0.12; t_mesh.outer_radius = 0.15; t_mesh.rings = 18; t_mesh.ring_segments = 10
	t_mesh.material = mat_chrome
	star_ring.mesh = t_mesh
	star_ring.position = Vector3(0.0, 0.72, -2.11)
	star_ring.rotation.x = PI * 0.5
	root.add_child(star_ring)
	
	for a_deg in [90.0, 210.0, 330.0]:
		var sp = create_box(Vector3(0.02, 0.12, 0.02), mat_chrome, Vector3(0, 0, 0))
		sp.position = Vector3(cos(deg_to_rad(a_deg)) * 0.06, 0.72 + sin(deg_to_rad(a_deg)) * 0.06, -2.11)
		sp.rotation.z = deg_to_rad(a_deg - 90.0)
		root.add_child(sp)
		
	for side in [-1.0, 1.0]:
		var hl = create_round_lamp(0.12, mat_headlight, Vector3(side * 0.55, 0.72, -2.08))
		root.add_child(hl)
		
	# ICONIC TOP-OF-FENDER ORANGE BLINKERS (W460 Signature!)
	for side in [-1.0, 1.0]:
		var blinker_base = create_box(Vector3(0.12, 0.04, 0.16), mat_plastic_black, Vector3(side * 0.72, 0.94, -1.82))
		var blinker_lens = create_box(Vector3(0.10, 0.06, 0.14), mat_blinker_orange, Vector3(side * 0.72, 0.98, -1.82))
		root.add_child(blinker_base); root.add_child(blinker_lens)
		
	var bullbar = create_box(Vector3(1.36, 0.42, 0.08), mat_steel, Vector3(0.0, 0.54, -2.18))
	root.add_child(bullbar)
	
	var fb = create_box(Vector3(1.68, 0.18, 0.22), mat_plastic_black, Vector3(0.0, 0.38, -2.08))
	var rb = create_box(Vector3(1.68, 0.18, 0.22), mat_plastic_black, Vector3(0.0, 0.38, 2.08))
	root.add_child(fb); root.add_child(rb)
	
	# German DIN License Plate: S-GE 280
	var f_plate = create_license_plate_german(Vector3(0.0, 0.28, -2.20))
	var r_plate = create_license_plate_german(Vector3(-0.35, 0.44, 2.14))
	root.add_child(f_plate); root.add_child(r_plate)
	
	# --- 3. SIDE RUBBING STRIPS & EXPOSED DOOR HINGES ---
	for side in [-1.0, 1.0]:
		var rub_strip = create_box(Vector3(0.04, 0.08, 3.82), mat_plastic_black, Vector3(side * 0.85, 0.62, 0.0))
		var chrome_insert = create_box(Vector3(0.02, 0.02, 3.80), mat_chrome, Vector3(side * 0.87, 0.62, 0.0))
		root.add_child(rub_strip); root.add_child(chrome_insert)
		
		# Exposed chunky door hinges (W460 signature)
		for hz in [-0.85, 0.05, 0.85]:
			var hinge = create_box(Vector3(0.04, 0.06, 0.05), mat_plastic_black, Vector3(side * 0.86, 0.72, hz))
			root.add_child(hinge)
			
		var step = create_box(Vector3(0.10, 0.06, 2.10), mat_steel, Vector3(side * 0.90, 0.32, 0.05))
		root.add_child(step)
		
		var mirror = create_box(Vector3(0.16, 0.18, 0.06), mat_plastic_black, Vector3(side * 0.88, 1.05, -0.62))
		root.add_child(mirror)
		
	# Raised Expedition Snorkel along Passenger A-Pillar
	var snorkel_pipe = create_box(Vector3(0.08, 1.25, 0.08), mat_plastic_black, Vector3(0.86, 1.25, -0.68))
	var snorkel_head = create_box(Vector3(0.14, 0.12, 0.14), mat_plastic_black, Vector3(0.86, 1.88, -0.68))
	root.add_child(snorkel_pipe); root.add_child(snorkel_head)
	
	# --- 4. CABIN GREENHOUSE, TALL FLAT GLASS & ROOF ---
	var windshield = create_box(Vector3(1.48, 0.04, 0.68), mat_glass, Vector3(0.0, 1.15, -0.42))
	windshield.rotation.x = deg_to_rad(-24.0)
	root.add_child(windshield)
	
	# Twin Upright Wipers
	for wx in [-0.35, 0.15]:
		var w = create_box(Vector3(0.02, 0.42, 0.02), mat_plastic_black, Vector3(wx, 1.10, -0.46))
		w.rotation.x = deg_to_rad(-24.0)
		w.rotation.z = deg_to_rad(25.0)
		root.add_child(w)
		
	var side_glass_l = create_box(Vector3(0.03, 0.58, 2.25), mat_glass, Vector3(-0.76, 1.25, 0.65))
	var side_glass_r = create_box(Vector3(0.03, 0.58, 2.25), mat_glass, Vector3(0.76, 1.25, 0.65))
	root.add_child(side_glass_l); root.add_child(side_glass_r)
	
	var rear_glass = create_box(Vector3(1.36, 0.52, 0.03), mat_glass, Vector3(0.0, 1.25, 1.95))
	root.add_child(rear_glass)
	
	var roof_panel = create_box(Vector3(1.56, 0.06, 2.55), body_mat, Vector3(0.0, 1.56, 0.65))
	root.add_child(roof_panel)
	
	# --- 5. 3D COCKPIT INTERIOR ---
	var dash = create_box(Vector3(1.42, 0.22, 0.42), mat_interior_dark, Vector3(0.0, 0.88, -0.45))
	var vdo_hood = create_box(Vector3(0.44, 0.18, 0.26), mat_interior_dark, Vector3(-0.40, 1.02, -0.46))
	root.add_child(dash); root.add_child(vdo_hood)
	
	# Passenger "Angstgriff" (Heavy-duty grab handle with rubber grip)
	var grab_bar = create_box(Vector3(0.32, 0.05, 0.06), mat_plastic_black, Vector3(0.38, 0.95, -0.32))
	root.add_child(grab_bar)
	
	# 4-Spoke Heavy-Duty Mercedes Steering Wheel (Clean pivot hierarchy)
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.40, 0.98, -0.25)
	steer_pivot.rotation.x = deg_to_rad(-18.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_Gwagen"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.16; torus.outer_radius = 0.19; torus.rings = 16; torus.ring_segments = 10
	torus.material = mat_plastic_black
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5
	steer_node.add_child(sw_rim)
	
	for a_deg in [45.0, 135.0, 225.0, 315.0]:
		var spoke = create_box(Vector3(0.14, 0.035, 0.02), mat_plastic_black, Vector3(0, 0, 0))
		spoke.position = Vector3(cos(deg_to_rad(a_deg)) * 0.08, sin(deg_to_rad(a_deg)) * 0.08, 0)
		spoke.rotation.z = deg_to_rad(a_deg)
		steer_node.add_child(spoke)
	var horn_pad = create_box(Vector3(0.12, 0.10, 0.03), mat_plastic_black, Vector3(0, 0, 0.01))
	var mb_star = create_box(Vector3(0.04, 0.04, 0.01), mat_chrome, Vector3(0, 0, 0.025))
	steer_node.add_child(horn_pad); steer_node.add_child(mb_star)
	
	# Ergonomic Seats
	for seat_x in [-0.40, 0.40]:
		var base = create_box(Vector3(0.48, 0.16, 0.48), mat_interior_dark, Vector3(seat_x, 0.58, 0.15))
		var back = create_box(Vector3(0.46, 0.58, 0.12), mat_interior_dark, Vector3(seat_x, 0.90, 0.38))
		back.rotation.x = deg_to_rad(10.0)
		var headrest = create_box(Vector3(0.28, 0.14, 0.10), mat_plastic_black, Vector3(seat_x, 1.25, 0.44))
		root.add_child(base); root.add_child(back); root.add_child(headrest)
		
	var rear_seat = create_box(Vector3(1.35, 0.16, 0.48), mat_interior_dark, Vector3(0.0, 0.64, 1.15))
	var rear_back = create_box(Vector3(1.35, 0.54, 0.12), mat_interior_dark, Vector3(0.0, 0.96, 1.40))
	root.add_child(rear_seat); root.add_child(rear_back)
	
	# Center Floor 3x Diff Lock Pull Knobs (Sperren) with red illuminated caps
	for d_i in range(3):
		var knob = create_box(Vector3(0.03, 0.12, 0.03), mat_chrome, Vector3(-0.06 + float(d_i) * 0.06, 0.72, -0.12))
		var red_cap = create_box(Vector3(0.025, 0.03, 0.025), mat_tail_red, Vector3(-0.06 + float(d_i) * 0.06, 0.78, -0.12))
		root.add_child(knob); root.add_child(red_cap)
		
	# --- 6. EXTERNAL SPARE TIRE & ROOF RACK WITH SPOTLIGHTS ---
	var spare_tire = MeshInstance3D.new()
	var st_cyl = CylinderMesh.new()
	st_cyl.top_radius = 0.34; st_cyl.bottom_radius = 0.34; st_cyl.height = 0.22; st_cyl.radial_segments = 18
	st_cyl.material = mat_plastic_black
	spare_tire.mesh = st_cyl
	spare_tire.position = Vector3(0.18, 0.85, 2.14)
	spare_tire.rotation.x = PI * 0.5
	root.add_child(spare_tire)
	
	var cover_disc = create_box(Vector3(0.58, 0.58, 0.02), mat_steel, Vector3(0.18, 0.85, 2.26))
	var star_emboss = create_box(Vector3(0.16, 0.16, 0.02), mat_chrome, Vector3(0.18, 0.85, 2.27))
	root.add_child(cover_disc); root.add_child(star_emboss)
	
	for side in [-1.0, 1.0]:
		var tl = create_box(Vector3(0.24, 0.08, 0.03), mat_tail_red, Vector3(side * 0.65, 0.42, 2.14))
		var bl = create_box(Vector3(0.10, 0.08, 0.03), mat_blinker_orange, Vector3(side * 0.78, 0.42, 2.14))
		root.add_child(tl); root.add_child(bl)
		
	var roof_rack = create_box(Vector3(1.48, 0.08, 2.40), mat_steel, Vector3(0.0, 1.64, 0.65))
	root.add_child(roof_rack)
	for sp_x in [-0.48, -0.16, 0.16, 0.48]:
		var spot = create_round_lamp(0.08, mat_headlight, Vector3(sp_x, 1.72, -0.55))
		root.add_child(spot)
		
	return root

# ==============================================================================
# 4. FIAT 127 SPECIAL (1974 - Capolavoro di Pio Manzù & Dante Giacosa)
# ==============================================================================
static func build_fiat_127(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "Fiat127Rig"
	parent.add_child(root)
	
	# --- 1. LOWER BODY & PIO MANZÙ TWO-BOX COMPACT SILHOUETTE ---
	var lower_body = create_box(Vector3(1.42, 0.36, 3.42), body_mat, Vector3(0.0, 0.42, 0.0))
	root.add_child(lower_body)
	
	# Sloping Sculpted Hood (Pio Manzù characteristic forward rake & crown camber)
	var hood = create_sculpted_hood(Vector3(0.0, 0.52, -0.48), 1.36, 1.28, 1.18, 0.10, -0.05, 0.045, body_mat, 10, 10)
	hood.name = "Hood"
	root.add_child(hood)
	
	# Asymmetric hood air intake scoop (Firma distintiva Fiat 127 sul lato guida)
	var scoop = create_box(Vector3(0.24, 0.03, 0.28), mat_plastic_black, Vector3(-0.32, 0.69, -0.92))
	scoop.name = "HoodScoop"
	scoop.rotation.x = deg_to_rad(-4.0)
	root.add_child(scoop)
	
	# Fastback Rear Quarter & Tailgate Deck
	var rear_deck = create_box(Vector3(1.38, 0.38, 0.46), body_mat, Vector3(0.0, 0.64, 1.42))
	rear_deck.name = "RearDeck"
	root.add_child(rear_deck)
	
	# --- 2. FRONT NOSE, HONEYCOMB GRILLE & 4-RHOMBUS FIAT EMBLEM ---
	var nose_panel = create_box(Vector3(1.34, 0.22, 0.06), mat_plastic_black, Vector3(0.0, 0.52, -1.68))
	nose_panel.name = "NosePanel"
	root.add_child(nose_panel)
	
	# Vintage Fiat 4-Rhombus / Chrome Horizontal Line
	var chrome_strip = create_box(Vector3(0.85, 0.015, 0.02), mat_chrome, Vector3(0.0, 0.52, -1.71))
	root.add_child(chrome_strip)
	for b_i in range(4):
		var bar = create_box(Vector3(0.022, 0.07, 0.02), mat_fiat_blue, Vector3(-0.09 + float(b_i) * 0.06, 0.52, -1.72))
		bar.rotation.z = deg_to_rad(-18.0)
		root.add_child(bar)
		
	# Rectangular Carello Halogen Headlights with chrome bezels
	for side in [-1.0, 1.0]:
		var hl_bezel = create_box(Vector3(0.24, 0.16, 0.03), mat_chrome, Vector3(side * 0.46, 0.52, -1.69))
		var hl_glass = create_box(Vector3(0.21, 0.13, 0.04), mat_headlight, Vector3(side * 0.46, 0.52, -1.71))
		hl_glass.name = "Headlight_L" if side < 0 else "Headlight_R"
		root.add_child(hl_bezel); root.add_child(hl_glass)
		
	# --- 3. CLASSIC WIDE CHROME BUMPERS WITH RUBBER ROSTRI & AMBER BLINKERS ---
	var front_bumper = create_curved_bumper(Vector3(0.0, 0.32, -1.72), 1.44, 0.22, 0.08, 0.06, mat_chrome, false, 18)
	front_bumper.name = "FrontBumper"
	root.add_child(front_bumper)
	for r_side in [-1.0, 1.0]:
		var rostro = create_box(Vector3(0.06, 0.16, 0.10), mat_plastic_black, Vector3(r_side * 0.36, 0.32, -1.73))
		var blinker = create_box(Vector3(0.12, 0.06, 0.04), mat_blinker_orange, Vector3(r_side * 0.58, 0.32, -1.72))
		root.add_child(rostro); root.add_child(blinker)
		
	var rear_bumper = create_curved_bumper(Vector3(0.0, 0.32, 1.70), 1.44, 0.22, 0.08, 0.06, mat_chrome, true, 18)
	rear_bumper.name = "RearBumper"
	root.add_child(rear_bumper)
	for r_side in [-1.0, 1.0]:
		var r_rostro = create_box(Vector3(0.06, 0.16, 0.10), mat_plastic_black, Vector3(r_side * 0.36, 0.32, 1.71))
		root.add_child(r_rostro)
		
	# Vintage Italian Black-and-Orange License Plates: MI 74127A
	var f_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.22, -1.78), false)
	var r_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.44, 1.73), true)
	root.add_child(f_plate); root.add_child(r_plate)
	
	# Period Rolled Chrome Exhaust Tip
	var exh_127 = create_curved_exhaust_pipe(Vector3(0.48, 0.24, 1.74), 0.048, 0.22, mat_exhaust)
	root.add_child(exh_127)
	
	# --- 4. SIDES, CHROMED PUSH-BUTTON DOOR HANDLES & CURVED WHEEL ARCHES ---
	for side in [-1.0, 1.0]:
		var waist = create_box(Vector3(0.02, 0.02, 2.75), mat_plastic_black, Vector3(side * 0.72, 0.54, 0.0))
		root.add_child(waist)
		var handle = create_box(Vector3(0.02, 0.03, 0.10), mat_chrome, Vector3(side * 0.72, 0.64, -0.12))
		root.add_child(handle)
		
	# Smooth 180° Curved Wheel Arch Flanges (Front & Rear)
	var arch_fl = create_curved_wheel_arch(Vector3(-0.71, 0.38, -1.11), 0.32, 0.05, 0.035, true, body_mat, 18)
	var arch_fr = create_curved_wheel_arch(Vector3(0.71, 0.38, -1.11), 0.32, 0.05, 0.035, false, body_mat, 18)
	var arch_rl = create_curved_wheel_arch(Vector3(-0.71, 0.38, 1.11), 0.32, 0.05, 0.035, true, body_mat, 18)
	var arch_rr = create_curved_wheel_arch(Vector3(0.71, 0.38, 1.11), 0.32, 0.05, 0.035, false, body_mat, 18)
	root.add_child(arch_fl); root.add_child(arch_fr); root.add_child(arch_rl); root.add_child(arch_rr)
		
	# Vintage Round Chrome Driver Mirror (montato basso sulla portiera)
	var mir_arm = create_box(Vector3(0.05, 0.015, 0.015), mat_chrome, Vector3(-0.74, 0.66, -0.48))
	var mir_head = create_round_lamp(0.038, mat_chrome, Vector3(-0.77, 0.66, -0.48))
	root.add_child(mir_arm); root.add_child(mir_head)
	
	# --- 5. CABIN GREENHOUSE, SLOPING LUNOTTO & THIN PILLARS ---
	var windshield = create_box(Vector3(1.22, 0.03, 0.70), mat_glass, Vector3(0.0, 0.88, -0.28))
	windshield.rotation.x = deg_to_rad(-42.0)
	root.add_child(windshield)
	
	for wx in [-0.28, 0.20]:
		var wp = create_box(Vector3(0.012, 0.38, 0.012), mat_chrome, Vector3(wx, 0.71, -0.42))
		wp.rotation.x = deg_to_rad(-42.0)
		wp.rotation.z = deg_to_rad(-82.0)
		root.add_child(wp)
		
	var side_glass_l = create_box(Vector3(0.03, 0.40, 1.40), mat_glass, Vector3(-0.62, 0.92, 0.42))
	var side_glass_r = create_box(Vector3(0.03, 0.40, 1.40), mat_glass, Vector3(0.62, 0.92, 0.42))
	root.add_child(side_glass_l); root.add_child(side_glass_r)
	
	var bp_l = create_box(Vector3(0.05, 0.42, 0.08), mat_interior_dark, Vector3(-0.62, 0.92, 0.35))
	var bp_r = create_box(Vector3(0.05, 0.42, 0.08), mat_interior_dark, Vector3(0.62, 0.92, 0.35))
	root.add_child(bp_l); root.add_child(bp_r)
	
	var rear_glass = create_box(Vector3(1.18, 0.03, 0.62), mat_glass, Vector3(0.0, 0.88, 1.34))
	rear_glass.rotation.x = deg_to_rad(36.0)
	root.add_child(rear_glass)
	
	var roof_panel = create_box(Vector3(1.24, 0.04, 1.75), body_mat, Vector3(0.0, 1.14, 0.42))
	root.add_child(roof_panel)
	
	# --- 6. AUTHENTIC 3D COCKPIT INTERIOR (Pio Manzù 1974 Special) ---
	# Ripiano inferiore e palpebra superiore plancia imbottita (finitura opaca antiriflesso)
	var dash_lower = create_box(Vector3(1.18, 0.08, 0.28), mat_interior_dark, Vector3(0.0, 0.54, -0.32))
	var dash_upper = create_box(Vector3(1.18, 0.09, 0.22), mat_interior_dark, Vector3(0.0, 0.62, -0.34))
	root.add_child(dash_lower); root.add_child(dash_upper)
	
	# Fascia orizzontale in pregiata radica di noce "Special 1974" con profilo cromato
	var walnut_strip = create_box(Vector3(1.16, 0.045, 0.02), mat_wood_walnut, Vector3(0.0, 0.59, -0.23))
	var walnut_chrome = create_box(Vector3(1.16, 0.006, 0.024), mat_chrome, Vector3(0.0, 0.565, -0.228))
	root.add_child(walnut_strip); root.add_child(walnut_chrome)
	
	# Bocchette di ventilazione orientabili con ghiere cromate
	for vx in [-0.52, 0.0, 0.52]:
		var vent_ring = create_box(Vector3(0.055, 0.055, 0.015), mat_chrome, Vector3(vx, 0.59, -0.235))
		var vent_core = create_box(Vector3(0.042, 0.042, 0.02), mat_interior_dark, Vector3(vx, 0.59, -0.23))
		root.add_child(vent_ring); root.add_child(vent_core)
		
	# Quadro Strumenti Veglia Borletti (Palpebra sagomata e quadri incassati)
	var binnacle_hood = create_box(Vector3(0.38, 0.10, 0.15), mat_interior_dark, Vector3(-0.30, 0.67, -0.30))
	var binnacle_back = create_box(Vector3(0.35, 0.08, 0.02), mat_interior_dark, Vector3(-0.30, 0.66, -0.225))
	root.add_child(binnacle_hood); root.add_child(binnacle_back)
	
	# Tachimetro circolare Veglia Borletti con ghiera cromata e lancetta fluorescente
	var sp_bezel = create_round_lamp(0.052, mat_chrome, Vector3(-0.36, 0.66, -0.22))
	var sp_dial = create_round_lamp(0.046, mat_plastic_black, Vector3(-0.36, 0.66, -0.216))
	var sp_needle = create_box(Vector3(0.005, 0.034, 0.005), mat_gauge_amber, Vector3(-0.36, 0.675, -0.210))
	sp_needle.rotation.z = deg_to_rad(-24.0)
	var sp_pin = create_round_lamp(0.008, mat_steel, Vector3(-0.36, 0.66, -0.208))
	root.add_child(sp_bezel); root.add_child(sp_dial); root.add_child(sp_needle); root.add_child(sp_pin)
	
	# Riquadri orizzontali Livello Carburante e Temperatura Acqua
	var fuel_frame = create_box(Vector3(0.12, 0.024, 0.008), mat_steel, Vector3(-0.24, 0.68, -0.22))
	var fuel_n = create_box(Vector3(0.006, 0.018, 0.005), mat_gauge_amber, Vector3(-0.22, 0.68, -0.215))
	var temp_frame = create_box(Vector3(0.12, 0.024, 0.008), mat_steel, Vector3(-0.24, 0.645, -0.22))
	var temp_n = create_box(Vector3(0.006, 0.018, 0.005), mat_gauge_amber, Vector3(-0.24, 0.645, -0.215))
	root.add_child(fuel_frame); root.add_child(fuel_n); root.add_child(temp_frame); root.add_child(temp_n)
	
	# Spie luminose (Dinamo rossa, Olio rossa, Luci verde, Frecce verde)
	var lamp_din = create_box(Vector3(0.02, 0.012, 0.006), mat_tail_red, Vector3(-0.29, 0.625, -0.22))
	var lamp_oil = create_box(Vector3(0.02, 0.012, 0.006), mat_tail_red, Vector3(-0.26, 0.625, -0.22))
	var lamp_luc = create_box(Vector3(0.02, 0.012, 0.006), mat_gauge_green, Vector3(-0.23, 0.625, -0.22))
	var lamp_frc = create_box(Vector3(0.02, 0.012, 0.006), mat_gauge_amber, Vector3(-0.20, 0.625, -0.22))
	root.add_child(lamp_din); root.add_child(lamp_oil); root.add_child(lamp_luc); root.add_child(lamp_frc)
	
	# Consolle Centrale con Autoradio Voxson, manettino starter "ARIA" e 4 frecce
	var radio_body = create_box(Vector3(0.20, 0.06, 0.03), mat_interior_dark, Vector3(0.0, 0.52, -0.24))
	var radio_dial = create_box(Vector3(0.12, 0.022, 0.008), mat_gauge_amber, Vector3(0.0, 0.525, -0.222))
	var knob_rad_l = create_box(Vector3(0.018, 0.018, 0.015), mat_chrome, Vector3(-0.07, 0.52, -0.22))
	var knob_rad_r = create_box(Vector3(0.018, 0.018, 0.015), mat_chrome, Vector3(0.07, 0.52, -0.22))
	root.add_child(radio_body); root.add_child(radio_dial); root.add_child(knob_rad_l); root.add_child(knob_rad_r)
	
	var switch_bar = create_box(Vector3(0.22, 0.04, 0.03), mat_interior_dark, Vector3(0.0, 0.46, -0.24))
	var choke_knob = create_box(Vector3(0.022, 0.022, 0.025), mat_plastic_black, Vector3(-0.06, 0.46, -0.22))
	var hazard_sw = create_box(Vector3(0.025, 0.022, 0.02), mat_tail_red, Vector3(0.06, 0.46, -0.22))
	root.add_child(switch_bar); root.add_child(choke_knob); root.add_child(hazard_sw)
	
	# Volante 2 Razze Pio Manzù a calice ribassato
	var col_shaft = create_box(Vector3(0.05, 0.05, 0.16), mat_plastic_black, Vector3(-0.30, 0.62, -0.24))
	col_shaft.rotation.x = deg_to_rad(-22.0)
	root.add_child(col_shaft)
	
	# Steli devioluci al volante
	var stalk_l = create_box(Vector3(0.08, 0.01, 0.01), mat_chrome, Vector3(-0.38, 0.63, -0.20))
	stalk_l.rotation.z = deg_to_rad(-16.0)
	var stalk_r = create_box(Vector3(0.08, 0.01, 0.01), mat_chrome, Vector3(-0.22, 0.63, -0.20))
	stalk_r.rotation.z = deg_to_rad(16.0)
	root.add_child(stalk_l); root.add_child(stalk_r)
	
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.30, 0.64, -0.18)
	steer_pivot.rotation.x = deg_to_rad(-22.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_127"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.125; torus.outer_radius = 0.150; torus.rings = 18; torus.ring_segments = 12
	torus.material = mat_plastic_black
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5
	steer_node.add_child(sw_rim)
	
	var spoke = create_box(Vector3(0.26, 0.025, 0.012), mat_steel, Vector3(0, 0, 0))
	var horn_hub = create_box(Vector3(0.055, 0.055, 0.018), mat_plastic_black, Vector3(0, 0, 0.01))
	var hub_crest = create_box(Vector3(0.028, 0.028, 0.01), mat_fiat_blue, Vector3(0, 0, 0.018))
	steer_node.add_child(spoke); steer_node.add_child(horn_hub); steer_node.add_child(hub_crest)
	
	# Specchietto retrovisore interno centrale
	var mirror_stem = create_box(Vector3(0.018, 0.06, 0.018), mat_chrome, Vector3(0.0, 1.05, -0.28))
	var mirror_case = create_box(Vector3(0.18, 0.055, 0.025), mat_plastic_black, Vector3(0.0, 1.01, -0.26))
	var mirror_refl = create_box(Vector3(0.165, 0.045, 0.01), mat_mirror_glass, Vector3(0.0, 1.01, -0.25))
	root.add_child(mirror_stem); root.add_child(mirror_case); root.add_child(mirror_refl)
	
	# Alette parasole coordinate (appoggiate al cielo dell'abitacolo)
	for vx in [-0.34, 0.34]:
		var visor = create_box(Vector3(0.32, 0.065, 0.012), mat_interior_dark, Vector3(vx, 1.13, -0.24))
		visor.rotation.x = deg_to_rad(6.0)
		root.add_child(visor)
	
	for seat_x in [-0.32, 0.32]:
		var seat_base = create_box(Vector3(0.40, 0.12, 0.42), mat_interior_dark, Vector3(seat_x, 0.48, 0.10))
		var seat_back = create_box(Vector3(0.38, 0.42, 0.08), mat_interior_dark, Vector3(seat_x, 0.72, 0.28))
		seat_back.rotation.x = deg_to_rad(12.0)
		var hr = create_box(Vector3(0.22, 0.10, 0.06), mat_interior_dark, Vector3(seat_x, 0.98, 0.34))
		root.add_child(seat_base); root.add_child(seat_back); root.add_child(hr)
		
	var rear_seat = create_box(Vector3(1.08, 0.12, 0.40), mat_interior_dark, Vector3(0.0, 0.52, 0.95))
	var rear_back = create_box(Vector3(1.08, 0.40, 0.08), mat_interior_dark, Vector3(0.0, 0.74, 1.15))
	root.add_child(rear_seat); root.add_child(rear_back)
	
	# Leva cambio lunga al pavimento con soffietto in similpelle e pomello sferico
	var shift_gaiter = create_box(Vector3(0.08, 0.06, 0.08), mat_interior_dark, Vector3(0.0, 0.46, -0.06))
	var shift_rod = create_box(Vector3(0.016, 0.22, 0.016), mat_chrome, Vector3(0.0, 0.56, -0.06))
	shift_rod.rotation.x = deg_to_rad(-8.0)
	var shift_ball = create_box(Vector3(0.042, 0.042, 0.042), mat_plastic_black, Vector3(0.0, 0.67, -0.08))
	root.add_child(shift_gaiter); root.add_child(shift_rod); root.add_child(shift_ball)
	
	# --- 7. REAR VERTICAL TAIL LAMPS & CHROME EXHAUST ---
	for side in [-1.0, 1.0]:
		var tl_group = Node3D.new()
		tl_group.position = Vector3(side * 0.56, 0.62, 1.66)
		var amber_t = create_box(Vector3(0.10, 0.08, 0.03), mat_blinker_orange, Vector3(0.0, 0.08, 0.0))
		var red_m = create_box(Vector3(0.10, 0.10, 0.03), mat_tail_red, Vector3(0.0, -0.01, 0.0))
		var white_b = create_box(Vector3(0.10, 0.06, 0.03), mat_reverse_white, Vector3(0.0, -0.09, 0.0))
		tl_group.add_child(amber_t); tl_group.add_child(red_m); tl_group.add_child(white_b)
		root.add_child(tl_group)
		
	var pipe = MeshInstance3D.new()
	var p_cyl = CylinderMesh.new()
	p_cyl.top_radius = 0.032; p_cyl.bottom_radius = 0.032; p_cyl.height = 0.18; p_cyl.radial_segments = 12
	p_cyl.material = mat_chrome
	pipe.mesh = p_cyl
	pipe.position = Vector3(-0.46, 0.20, 1.74)
	pipe.rotation.x = PI * 0.48
	root.add_child(pipe)
	
	return root

# ==============================================================================
# 5. VOLKSWAGEN GOLF GTI 16V Mk2 (1990 - Die Legende aus Wolfsburg)
# ==============================================================================
static func build_golf_gti_1990(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "GolfGtiRig"
	parent.add_child(root)
	
	# --- 1. LOWER BODY & ICONIC Mk2 HATCHBACK PROPORTIONS ---
	var lower_body = create_box(Vector3(1.62, 0.40, 3.84), body_mat, Vector3(0.0, 0.44, 0.0))
	root.add_child(lower_body)
	
	# Sculpted hood with subtle central power ridge
	var hood = create_sculpted_hood(Vector3(0.0, 0.54, -1.18), 1.50, 1.38, 1.25, 0.10, 0.0, 0.035, body_mat, 12, 12)
	root.add_child(hood)
	
	# --- 2. FRONT FASCIA: 4-LAMP GRILLE, ICONIC GTI RED STRIPE & BIG BUMPERS ---
	var front_bumper = create_curved_bumper(Vector3(0.0, 0.34, -1.90), 1.68, 0.22, 0.26, 0.14, body_mat, false, 12)
	root.add_child(front_bumper)
	
	var chin_spoiler = create_box(Vector3(1.66, 0.12, 0.30), mat_plastic_black, Vector3(0.0, 0.18, -1.90))
	root.add_child(chin_spoiler)
	
	for f_side in [-1.0, 1.0]:
		var fog = create_box(Vector3(0.14, 0.06, 0.03), mat_headlight, Vector3(f_side * 0.55, 0.24, -2.02))
		root.add_child(fog)
		
	var grille_back = create_box(Vector3(1.54, 0.22, 0.06), mat_plastic_black, Vector3(0.0, 0.56, -1.92))
	root.add_child(grille_back)
	
	# ICONIC GTI RED STRIPE
	var red_top = create_box(Vector3(1.52, 0.016, 0.02), mat_gti_red, Vector3(0.0, 0.66, -1.95))
	var red_bot = create_box(Vector3(1.52, 0.016, 0.02), mat_gti_red, Vector3(0.0, 0.46, -1.95))
	var red_l = create_box(Vector3(0.016, 0.20, 0.02), mat_gti_red, Vector3(-0.75, 0.56, -1.95))
	var red_r = create_box(Vector3(0.016, 0.20, 0.02), mat_gti_red, Vector3(0.75, 0.56, -1.95))
	root.add_child(red_top); root.add_child(red_bot); root.add_child(red_l); root.add_child(red_r)
	
	# Quad Round Parabolic Headlights
	for side in [-1.0, 1.0]:
		var outer_h4 = create_parabolic_headlamp(Vector3(side * 0.58, 0.56, -1.94), 0.082, 0.06, mat_plastic_black, mat_headlight)
		var inner_spot = create_parabolic_headlamp(Vector3(side * 0.34, 0.56, -1.94), 0.062, 0.05, mat_plastic_black, mat_headlight)
		root.add_child(outer_h4); root.add_child(inner_spot)
		
		var bl = create_box(Vector3(0.14, 0.06, 0.06), mat_blinker_orange, Vector3(side * 0.78, 0.36, -1.86))
		root.add_child(bl)
		
	var vw_logo = create_round_lamp(0.050, mat_chrome, Vector3(0.0, 0.56, -1.95))
	root.add_child(vw_logo)
	
	var gti_badge = create_box(Vector3(0.12, 0.04, 0.02), mat_gti_red, Vector3(0.18, 0.56, -1.96))
	root.add_child(gti_badge)
	
	var f_plate = create_license_plate_german(Vector3(0.0, 0.26, -2.04))
	var r_plate = create_license_plate_german(Vector3(0.0, 0.40, 1.96))
	root.add_child(f_plate); root.add_child(r_plate)
	
	# --- 3. CURVED 180° GTI WHEEL ARCH FLARES & SIDE PROTECTION ---
	for side in [-1.0, 1.0]:
		var is_left = (side < 0)
		var arch_f = create_curved_wheel_arch(Vector3(side * 0.81, 0.44, -1.22), 0.35, 0.10, 0.05, is_left, mat_plastic_black, 18)
		var arch_r = create_curved_wheel_arch(Vector3(side * 0.81, 0.44, 1.22), 0.35, 0.10, 0.05, is_left, mat_plastic_black, 18)
		var skirt = create_box(Vector3(0.06, 0.10, 1.58), mat_plastic_black, Vector3(side * 0.82, 0.24, 0.0))
		root.add_child(arch_f); root.add_child(arch_r); root.add_child(skirt)
		
		var rub_strip = create_box(Vector3(0.025, 0.04, 2.90), mat_plastic_black, Vector3(side * 0.82, 0.52, 0.0))
		var red_door_badge = create_box(Vector3(0.03, 0.03, 0.08), mat_gti_red, Vector3(side * 0.825, 0.52, -0.45))
		root.add_child(rub_strip); root.add_child(red_door_badge)
		
		var mirror = create_box(Vector3(0.14, 0.09, 0.06), mat_plastic_black, Vector3(side * 0.78, 0.80, -0.52))
		root.add_child(mirror)
		
	# --- 4. GREENHOUSE, THICK C-PILLAR & REAR SPOILER ---
	var windshield = create_box(Vector3(1.36, 0.04, 0.76), mat_glass, Vector3(0.0, 0.88, -0.36))
	windshield.rotation.x = deg_to_rad(-46.0)
	root.add_child(windshield)
	
	for wx in [-0.28, 0.20]:
		var w = create_box(Vector3(0.02, 0.45, 0.02), mat_plastic_black, Vector3(wx, 0.84, -0.40))
		w.rotation.x = deg_to_rad(-46.0)
		w.rotation.z = deg_to_rad(28.0)
		root.add_child(w)
		
	var side_glass_l = create_box(Vector3(0.03, 0.38, 1.62), mat_glass, Vector3(-0.69, 0.90, 0.38))
	var side_glass_r = create_box(Vector3(0.03, 0.38, 1.62), mat_glass, Vector3(0.69, 0.90, 0.38))
	root.add_child(side_glass_l); root.add_child(side_glass_r)
	
	var cp_l = create_box(Vector3(0.06, 0.40, 0.45), body_mat, Vector3(-0.70, 0.90, 1.35))
	var cp_r = create_box(Vector3(0.06, 0.40, 0.45), body_mat, Vector3(0.70, 0.90, 1.35))
	root.add_child(cp_l); root.add_child(cp_r)
	
	var rear_glass = create_box(Vector3(1.28, 0.40, 0.03), mat_glass, Vector3(0.0, 0.92, 1.58))
	rear_glass.rotation.x = deg_to_rad(24.0)
	root.add_child(rear_glass)
	
	var roof_panel = create_box(Vector3(1.40, 0.05, 1.85), body_mat, Vector3(0.0, 1.12, 0.42))
	root.add_child(roof_panel)
	
	var spoiler = create_box(Vector3(1.34, 0.06, 0.22), mat_plastic_black, Vector3(0.0, 1.14, 1.52))
	root.add_child(spoiler)
	
	# --- 5. 3D COCKPIT INTERIOR ---
	var dash = create_box(Vector3(1.28, 0.22, 0.40), mat_interior_dark, Vector3(0.0, 0.72, -0.42))
	var cluster_pod = create_box(Vector3(0.42, 0.16, 0.24), mat_interior_dark, Vector3(-0.36, 0.84, -0.44))
	root.add_child(dash); root.add_child(cluster_pod)
	
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.36, 0.82, -0.22)
	steer_pivot.rotation.x = deg_to_rad(-20.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_Golf"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.14; torus.outer_radius = 0.17; torus.rings = 16; torus.ring_segments = 10
	torus.material = mat_leather
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5
	steer_node.add_child(sw_rim)
	
	for a_deg in [45.0, 135.0, 225.0, 315.0]:
		var sp = create_box(Vector3(0.10, 0.03, 0.02), mat_plastic_black, Vector3(cos(deg_to_rad(a_deg)) * 0.07, sin(deg_to_rad(a_deg)) * 0.07, 0))
		sp.rotation.z = deg_to_rad(a_deg)
		steer_node.add_child(sp)
		var btn = create_box(Vector3(0.025, 0.025, 0.01), mat_plastic_black, Vector3(cos(deg_to_rad(a_deg)) * 0.09, sin(deg_to_rad(a_deg)) * 0.09, 0.01))
		steer_node.add_child(btn)
		
	var hub = create_box(Vector3(0.07, 0.07, 0.025), mat_plastic_black, Vector3(0, 0, 0.01))
	var wolfsburg_crest = create_box(Vector3(0.035, 0.035, 0.01), mat_chrome, Vector3(0, 0, 0.02))
	steer_node.add_child(hub); steer_node.add_child(wolfsburg_crest)
	
	for seat_x in [-0.36, 0.36]:
		var base = create_box(Vector3(0.44, 0.14, 0.44), mat_interior_dark, Vector3(seat_x, 0.48, 0.10))
		var back = create_box(Vector3(0.42, 0.50, 0.10), mat_interior_dark, Vector3(seat_x, 0.74, 0.32))
		back.rotation.x = deg_to_rad(12.0)
		var tartan_cushion = create_box(Vector3(0.24, 0.42, 0.03), mat_tartan, Vector3(seat_x, 0.74, 0.28))
		tartan_cushion.rotation.x = deg_to_rad(12.0)
		var bolster_l = create_box(Vector3(0.07, 0.44, 0.18), mat_interior_dark, Vector3(seat_x - 0.18, 0.72, 0.30))
		var bolster_r = create_box(Vector3(0.07, 0.44, 0.18), mat_interior_dark, Vector3(seat_x + 0.18, 0.72, 0.30))
		root.add_child(base); root.add_child(back); root.add_child(tartan_cushion); root.add_child(bolster_l); root.add_child(bolster_r)
		
	# GOLF BALL SHIFT KNOB
	var shift_lever = create_box(Vector3(0.025, 0.18, 0.025), mat_chrome, Vector3(-0.02, 0.58, -0.06))
	var golf_ball = MeshInstance3D.new()
	var g_sphere = SphereMesh.new()
	g_sphere.radius = 0.032; g_sphere.height = 0.064
	g_sphere.material = mat_plastic_black
	golf_ball.mesh = g_sphere
	golf_ball.position = Vector3(-0.02, 0.68, -0.06)
	root.add_child(shift_lever); root.add_child(golf_ball)
	
	# --- 6. REAR END, SMOKED GTI LIGHTS & TWIN EXHAUST ---
	var rear_bumper = create_curved_bumper(Vector3(0.0, 0.36, 1.86), 1.68, 0.24, 0.26, 0.14, body_mat, true, 12)
	root.add_child(rear_bumper)
	
	for side in [-1.0, 1.0]:
		var smoked_top = create_box(Vector3(0.24, 0.075, 0.04), mat_tail_smoke, Vector3(side * 0.62, 0.58, 1.90))
		var red_bottom = create_box(Vector3(0.24, 0.075, 0.04), mat_tail_red, Vector3(side * 0.62, 0.50, 1.90))
		root.add_child(smoked_top); root.add_child(red_bottom)
		
	var r_badge = create_box(Vector3(0.12, 0.04, 0.01), mat_gti_red, Vector3(0.48, 0.65, 1.88))
	var r_vw = create_round_lamp(0.045, mat_chrome, Vector3(0.0, 0.65, 1.89))
	root.add_child(r_badge); root.add_child(r_vw)
	
	# TWIN CURVED EXHAUST PIPES
	var pipe1 = create_curved_exhaust_pipe(Vector3(-0.46, 0.22, 1.92), 0.034, 0.24, mat_exhaust)
	var pipe2 = create_curved_exhaust_pipe(Vector3(-0.38, 0.22, 1.92), 0.034, 0.24, mat_exhaust)
	root.add_child(pipe1); root.add_child(pipe2)
		
	return root

# --- Helper Mesh Constructors ---
static func create_box(size: Vector3, mat: Material, pos: Vector3) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var b = BoxMesh.new()
	b.size = size
	b.subdivide_width = 1
	b.subdivide_height = 1
	b.subdivide_depth = 1
	b.material = mat
	mi.mesh = b
	mi.position = pos
	return mi

static func create_beveled_box(size: Vector3, mat: Material, pos: Vector3, _bevel: float = 0.02) -> MeshInstance3D:
	# Genera pannellature con bordi ammorbiditi per eliminare le spigolature secche a 90 gradi
	var mi = MeshInstance3D.new()
	var b = BoxMesh.new()
	b.size = size
	b.subdivide_width = 2
	b.subdivide_height = 2
	b.subdivide_depth = 2
	b.material = mat
	mi.mesh = b
	mi.position = pos
	return mi

static func create_round_lamp(radius: float, mat: Material, pos: Vector3) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = radius; cyl.bottom_radius = radius; cyl.height = 0.015; cyl.radial_segments = 14
	cyl.material = mat
	mi.mesh = cyl
	mi.material_override = mat
	mi.position = pos
	mi.rotation.x = PI * 0.5
	return mi

# ==============================================================================
# ADVANCED PROCEDURAL CURVED AUTOMOTIVE GEOMETRY BUILDERS (SURFACETOOL HIGH-POLY)
# ==============================================================================
static func create_curved_wheel_arch(center: Vector3, radius: float, width: float, flare_out: float, is_left: bool, mat: Material, segments: int = 18) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var side_mul = -1.0 if is_left else 1.0
	for i in range(segments):
		var a0 = float(i) / float(segments) * PI
		var a1 = float(i + 1) / float(segments) * PI
		
		# Semicircular profile in Y-Z plane
		var in_y0 = sin(a0) * radius; var in_z0 = cos(a0) * radius
		var in_y1 = sin(a1) * radius; var in_z1 = cos(a1) * radius
		
		var out_y0 = sin(a0) * (radius + width); var out_z0 = cos(a0) * (radius + width)
		var out_y1 = sin(a1) * (radius + width); var out_z1 = cos(a1) * (radius + width)
		
		var p0_in = center + Vector3(0.0, in_y0, in_z0)
		var p0_out = center + Vector3(side_mul * flare_out, out_y0, out_z0)
		var p1_in = center + Vector3(0.0, in_y1, in_z1)
		var p1_out = center + Vector3(side_mul * flare_out, out_y1, out_z1)
		
		# Inner return flange into wheel tub
		var p0_deep = center + Vector3(-side_mul * 0.06, in_y0, in_z0)
		var p1_deep = center + Vector3(-side_mul * 0.06, in_y1, in_z1)
		
		# Outer face
		if is_left:
			st.add_vertex(p0_in); st.add_vertex(p0_out); st.add_vertex(p1_out)
			st.add_vertex(p0_in); st.add_vertex(p1_out); st.add_vertex(p1_in)
			# Flange
			st.add_vertex(p0_deep); st.add_vertex(p0_in); st.add_vertex(p1_in)
			st.add_vertex(p0_deep); st.add_vertex(p1_in); st.add_vertex(p1_deep)
		else:
			st.add_vertex(p0_in); st.add_vertex(p1_out); st.add_vertex(p0_out)
			st.add_vertex(p0_in); st.add_vertex(p1_in); st.add_vertex(p1_out)
			# Flange
			st.add_vertex(p0_deep); st.add_vertex(p1_in); st.add_vertex(p0_in)
			st.add_vertex(p0_deep); st.add_vertex(p1_deep); st.add_vertex(p1_in)
			
	st.generate_normals()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	return mi

static func create_sculpted_hood(pos: Vector3, width_rear: float, width_front: float, length: float, height_rear: float, height_front: float, camber: float, mat: Material, segs_x: int = 8, segs_z: int = 8) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	for iz in range(segs_z):
		var tz0 = float(iz) / float(segs_z)
		var tz1 = float(iz + 1) / float(segs_z)
		
		var z0 = pos.z - tz0 * length
		var z1 = pos.z - tz1 * length
		
		var w0 = lerp(width_rear, width_front, tz0)
		var w1 = lerp(width_rear, width_front, tz1)
		
		var base_y0 = pos.y + lerp(height_rear, height_front, pow(tz0, 1.25))
		var base_y1 = pos.y + lerp(height_rear, height_front, pow(tz1, 1.25))
		
		for ix in range(segs_x):
			var tx0 = float(ix) / float(segs_x) * 2.0 - 1.0
			var tx1 = float(ix + 1) / float(segs_x) * 2.0 - 1.0
			
			var x00 = tx0 * (w0 * 0.5)
			var x01 = tx1 * (w0 * 0.5)
			var x10 = tx0 * (w1 * 0.5)
			var x11 = tx1 * (w1 * 0.5)
			
			var cam00 = cos(tx0 * PI * 0.5) * camber
			var cam01 = cos(tx1 * PI * 0.5) * camber
			var cam10 = cos(tx0 * PI * 0.5) * camber
			var cam11 = cos(tx1 * PI * 0.5) * camber
			
			var p00 = Vector3(x00, base_y0 + cam00, z0)
			var p01 = Vector3(x01, base_y0 + cam01, z0)
			var p10 = Vector3(x10, base_y1 + cam10, z1)
			var p11 = Vector3(x11, base_y1 + cam11, z1)
			
			st.add_vertex(p00); st.add_vertex(p10); st.add_vertex(p01)
			st.add_vertex(p01); st.add_vertex(p10); st.add_vertex(p11)
			
	st.generate_normals()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	return mi

static func create_curved_bumper(pos: Vector3, width: float, depth_wrap: float, b_height: float, b_thickness: float, mat: Material, is_rear: bool = false, segments: int = 16) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var half_w = width * 0.5
	var corner_r = 0.12
	var corner_segs = max(4, segments / 3)
	var pts = []
	
	var z_dir = 1.0 if not is_rear else -1.0
	
	# Left wrap around corner
	for i in range(corner_segs):
		var ang = PI + float(i) / float(corner_segs) * (PI * 0.5)
		var cx = -half_w + corner_r + cos(ang) * corner_r
		var cz = pos.z + z_dir * (depth_wrap - corner_r) + sin(ang) * corner_r * z_dir
		pts.append(Vector3(cx, pos.y, cz))
		
	# Front straight segment
	pts.append(Vector3(0.0, pos.y, pos.z))
	
	# Right wrap around corner
	for i in range(corner_segs + 1):
		var ang = PI * 1.5 + float(i) / float(corner_segs) * (PI * 0.5)
		var cx = half_w - corner_r + cos(ang) * corner_r
		var cz = pos.z + z_dir * (depth_wrap - corner_r) + sin(ang) * corner_r * z_dir
		pts.append(Vector3(cx, pos.y, cz))
		
	for i in range(pts.size() - 1):
		var p0 = pts[i]
		var p1 = pts[i + 1]
		var top0 = p0 + Vector3(0, b_height * 0.5, 0)
		var bot0 = p0 - Vector3(0, b_height * 0.5, 0)
		var top1 = p1 + Vector3(0, b_height * 0.5, 0)
		var bot1 = p1 - Vector3(0, b_height * 0.5, 0)
		
		st.add_vertex(bot0); st.add_vertex(top0); st.add_vertex(top1)
		st.add_vertex(bot0); st.add_vertex(top1); st.add_vertex(bot1)
		
	st.generate_normals()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	return mi

static func create_parabolic_headlamp(pos: Vector3, radius: float, depth: float, mat_chrome: Material, mat_lens: Material, segments: int = 18) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	
	# 1. Outer chrome bezel ring
	var bezel_mi = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = radius * 1.12
	cyl.bottom_radius = radius * 1.12
	cyl.height = depth * 0.6
	cyl.radial_segments = segments
	cyl.material = mat_chrome
	bezel_mi.mesh = cyl
	bezel_mi.rotation.x = PI * 0.5
	node.add_child(bezel_mi)
	
	# 2. Convex front lens
	var lens_mi = MeshInstance3D.new()
	var sph = SphereMesh.new()
	sph.radius = radius * 0.98
	sph.height = radius * 0.45
	sph.radial_segments = segments
	sph.rings = 6
	sph.material = mat_lens
	lens_mi.mesh = sph
	lens_mi.position = Vector3(0, 0, -depth * 0.3)
	lens_mi.rotation.x = PI * 0.5
	node.add_child(lens_mi)
	
	return node

static func create_swept_pontoon_fender(start_p: Vector3, crest_p: Vector3, end_p: Vector3, width: float, radius: float, is_left: bool, mat: Material, segments: int = 18) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var side_mul = -1.0 if is_left else 1.0
	
	# Sample along quadratic Bézier curve from front bumper over wheel to running board
	for i in range(segments):
		var t0 = float(i) / float(segments)
		var t1 = float(i + 1) / float(segments)
		
		# Bézier center points
		var c0 = (1.0 - t0) * (1.0 - t0) * start_p + 2.0 * (1.0 - t0) * t0 * crest_p + t0 * t0 * end_p
		var c1 = (1.0 - t1) * (1.0 - t1) * start_p + 2.0 * (1.0 - t1) * t1 * crest_p + t1 * t1 * end_p
		
		# Generate cross-section slice (5 radial points per slice)
		for s in range(5):
			var a0 = float(s) / 4.0 * PI
			var a1 = float(s + 1) / 4.0 * PI
			
			var dy0 = sin(a0) * radius; var dx0 = side_mul * (width * 0.5 + cos(a0) * radius * 0.6)
			var dy1 = sin(a1) * radius; var dx1 = side_mul * (width * 0.5 + cos(a1) * radius * 0.6)
			
			var p00 = c0 + Vector3(dx0, dy0, 0.0)
			var p01 = c0 + Vector3(dx1, dy1, 0.0)
			var p10 = c1 + Vector3(dx0, dy0, 0.0)
			var p11 = c1 + Vector3(dx1, dy1, 0.0)
			
			if is_left:
				st.add_vertex(p00); st.add_vertex(p10); st.add_vertex(p01)
				st.add_vertex(p01); st.add_vertex(p10); st.add_vertex(p11)
			else:
				st.add_vertex(p00); st.add_vertex(p01); st.add_vertex(p10)
				st.add_vertex(p01); st.add_vertex(p11); st.add_vertex(p10)
				
	st.generate_normals()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	return mi

static func create_flared_rally_box_arch(pos: Vector3, radius: float, width: float, flare_dist: float, is_left: bool, mat: Material, segments: int = 16) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var side_mul = -1.0 if is_left else 1.0
	for i in range(segments):
		var a0 = float(i) / float(segments) * PI
		var a1 = float(i + 1) / float(segments) * PI
		
		var in_y0 = sin(a0) * radius; var in_z0 = cos(a0) * radius
		var in_y1 = sin(a1) * radius; var in_z1 = cos(a1) * radius
		
		# Box flare: vertical cheek + horizontal top blister
		var flare_y0 = sin(a0) * (radius + width)
		var flare_z0 = cos(a0) * (radius + width)
		var flare_y1 = sin(a1) * (radius + width)
		var flare_z1 = cos(a1) * (radius + width)
		
		var p0_in = pos + Vector3(0.0, in_y0, in_z0)
		var p0_box = pos + Vector3(side_mul * flare_dist, flare_y0, flare_z0)
		var p1_in = pos + Vector3(0.0, in_y1, in_z1)
		var p1_box = pos + Vector3(side_mul * flare_dist, flare_y1, flare_z1)
		
		if is_left:
			st.add_vertex(p0_in); st.add_vertex(p0_box); st.add_vertex(p1_box)
			st.add_vertex(p0_in); st.add_vertex(p1_box); st.add_vertex(p1_in)
		else:
			st.add_vertex(p0_in); st.add_vertex(p1_box); st.add_vertex(p0_box)
			st.add_vertex(p0_in); st.add_vertex(p1_in); st.add_vertex(p1_box)
			
	st.generate_normals()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	return mi

static func create_stratos_aerodynamic_wedge(pos: Vector3, length: float, width_rear: float, width_front: float, height_rear: float, height_front: float, mat: Material) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	var segs = 10
	for i in range(segs):
		var t0 = float(i) / float(segs)
		var t1 = float(i + 1) / float(segs)
		
		var z0 = pos.z - t0 * length
		var z1 = pos.z - t1 * length
		
		var w0 = lerp(width_rear, width_front, t0) * 0.5
		var w1 = lerp(width_rear, width_front, t1) * 0.5
		
		var y0 = pos.y + lerp(height_rear, height_front, pow(t0, 1.4))
		var y1 = pos.y + lerp(height_rear, height_front, pow(t1, 1.4))
		
		# Center to left and center to right with aerodynamic camber
		for side in [-1.0, 1.0]:
			var p0_c = Vector3(0.0, y0 + 0.04, z0)
			var p1_c = Vector3(0.0, y1 + 0.04, z1)
			var p0_edge = Vector3(side * w0, y0 - 0.02, z0)
			var p1_edge = Vector3(side * w1, y1 - 0.02, z1)
			
			if side < 0:
				st.add_vertex(p0_c); st.add_vertex(p0_edge); st.add_vertex(p1_edge)
				st.add_vertex(p0_c); st.add_vertex(p1_edge); st.add_vertex(p1_c)
			else:
				st.add_vertex(p0_c); st.add_vertex(p1_edge); st.add_vertex(p0_edge)
				st.add_vertex(p0_c); st.add_vertex(p1_c); st.add_vertex(p1_edge)
				
	st.generate_normals()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	return mi

static func create_curved_exhaust_pipe(pos: Vector3, diameter: float, length: float, mat: Material, is_twin: bool = false) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	
	var count = 2 if is_twin else 1
	var spacing = diameter * 1.3
	for i in range(count):
		var off_x = (float(i) - (float(count - 1) * 0.5)) * spacing
		var mi = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = diameter * 0.5
		cyl.bottom_radius = diameter * 0.5
		cyl.height = length
		cyl.radial_segments = 14
		cyl.material = mat
		mi.mesh = cyl
		mi.position = Vector3(off_x, 0, 0)
		mi.rotation.x = PI * 0.5
		node.add_child(mi)
		
		# Dark hollow interior cap
		var cap = MeshInstance3D.new()
		var cap_c = CylinderMesh.new()
		cap_c.top_radius = diameter * 0.38
		cap_c.bottom_radius = diameter * 0.38
		cap_c.height = 0.02
		cap_c.radial_segments = 14
		cap_c.material = mat_plastic_black
		cap.mesh = cap_c
		cap.position = Vector3(off_x, 0, length * 0.49)
		cap.rotation.x = PI * 0.5
		node.add_child(cap)
		
	return node

static func create_license_plate_italian_vintage(pos: Vector3, is_rear: bool) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	var base_w = 0.38 if not is_rear else 0.42
	var base_h = 0.12 if not is_rear else 0.22
	var plate_bg = create_box(Vector3(base_w, base_h, 0.014), mat_plate_black, Vector3(0, 0, 0))
	node.add_child(plate_bg)
	# Determine outward face based on position (pos.z < 0 means front of vehicle facing forward)
	var z_face = 0.010 if pos.z >= 0.0 else -0.010
	if is_rear and base_h > 0.16:
		# Formato quadro posteriore vintage (2 righe: provincia arancione sopra, numeri bianchi sotto)
		var orange_to = create_box(Vector3(0.08, 0.05, 0.005), mat_plate_orange, Vector3(-base_w * 0.22, 0.045, z_face))
		var white_num_top = create_box(Vector3(0.12, 0.045, 0.005), mat_plate_white, Vector3(base_w * 0.18, 0.045, z_face))
		var white_num_bot = create_box(Vector3(base_w * 0.70, 0.055, 0.005), mat_plate_white, Vector3(0, -0.045, z_face))
		node.add_child(orange_to); node.add_child(white_num_top); node.add_child(white_num_bot)
	else:
		# Formato rettangolare (provincia arancione a sinistra, numeri bianchi a destra)
		var orange_to = create_box(Vector3(0.06, 0.05, 0.005), mat_plate_orange, Vector3(-base_w * 0.32, 0, z_face))
		var white_num = create_box(Vector3(base_w * 0.52, 0.05, 0.005), mat_plate_white, Vector3(base_w * 0.12, 0, z_face))
		node.add_child(orange_to); node.add_child(white_num)
	return node

static func create_license_plate_italian_modern(pos: Vector3) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	var plate_bg = create_box(Vector3(0.48, 0.11, 0.016), mat_plate_white, Vector3(0, 0, 0))
	node.add_child(plate_bg)
	var z_face = 0.010 if pos.z >= 0.0 else -0.010
	var blue_l = create_box(Vector3(0.04, 0.11, 0.005), mat_fiat_blue, Vector3(-0.22, 0, z_face))
	var blue_r = create_box(Vector3(0.04, 0.11, 0.005), mat_fiat_blue, Vector3(0.22, 0, z_face))
	var text_bar = create_box(Vector3(0.36, 0.05, 0.005), mat_plate_black, Vector3(0, 0, z_face))
	node.add_child(blue_l); node.add_child(blue_r); node.add_child(text_bar)
	return node

static func create_license_plate_german(pos: Vector3) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	var plate_bg = create_box(Vector3(0.46, 0.11, 0.016), mat_plate_white, Vector3(0, 0, 0))
	node.add_child(plate_bg)
	var z_face = 0.010 if pos.z >= 0.0 else -0.010
	var blue_eu = create_box(Vector3(0.04, 0.11, 0.005), mat_fiat_blue, Vector3(-0.21, 0, z_face))
	var text_bar = create_box(Vector3(0.36, 0.05, 0.005), mat_plate_black, Vector3(0.02, 0, z_face))
	node.add_child(blue_eu); node.add_child(text_bar)
	return node

static func create_license_plate_french_vintage(pos: Vector3) -> Node3D:
	var node = Node3D.new()
	node.position = pos
	var plate_bg = create_box(Vector3(0.44, 0.11, 0.016), mat_plate_black, Vector3(0, 0, 0))
	node.add_child(plate_bg)
	var z_face = 0.010 if pos.z >= 0.0 else -0.010
	var silver_num = create_box(Vector3(0.38, 0.05, 0.005), mat_steel, Vector3(0, 0, z_face))
	node.add_child(silver_num)
	return node

# ==============================================================================
# 6. RENAULT 4 GTL (1980 - Type 1128 "Quatrelle")
# ==============================================================================
static func build_renault_4(parent: Node3D, body_mat: Material):
	init_materials()
	for child in parent.get_children():
		child.queue_free()
		
	var root = Node3D.new()
	root.name = "R4_BodyRoot"
	parent.add_child(root)
	
	# --- 1. CHASSIS & LOWER BODY TUB ---
	var lower_tub = create_box(Vector3(1.44, 0.44, 3.44), body_mat, Vector3(0.0, 0.40, 0.05))
	root.add_child(lower_tub)
	
	# Sloped bonnet / hood
	var hood = create_box(Vector3(1.22, 0.22, 1.05), body_mat, Vector3(0.0, 0.64, -1.14))
	hood.rotation.x = deg_to_rad(6.0)
	root.add_child(hood)
	
	# Rounded front wings / fenders
	for side in [-1.0, 1.0]:
		var fender = create_box(Vector3(0.14, 0.32, 1.15), body_mat, Vector3(side * 0.66, 0.54, -1.12))
		root.add_child(fender)
		
	# --- 2. FRONT FASCIA: GTL GREY PLASTIC GRILLE & VASARELY DIAMOND ---
	var grille_frame = create_box(Vector3(1.08, 0.28, 0.05), mat_plastic_grey, Vector3(0.0, 0.58, -1.68))
	root.add_child(grille_frame)
	
	# Vasarely Renault Chrome Diamond (Losange)
	var diamond_bg = create_box(Vector3(0.065, 0.085, 0.02), mat_plastic_black, Vector3(0.0, 0.58, -1.71))
	var diamond_rim = create_box(Vector3(0.055, 0.075, 0.025), mat_chrome, Vector3(0.0, 0.58, -1.715))
	root.add_child(diamond_bg); root.add_child(diamond_rim)
	
	# 2 Round Headlights with chrome trim
	for side in [-1.0, 1.0]:
		var lamp_bezel = create_round_lamp(0.09, mat_chrome, Vector3(side * 0.40, 0.58, -1.70))
		var lamp = create_round_lamp(0.075, mat_headlight, Vector3(side * 0.40, 0.58, -1.71))
		root.add_child(lamp_bezel); root.add_child(lamp)
		
		# Amber turn signals below headlights
		var blinker = create_box(Vector3(0.08, 0.045, 0.03), mat_blinker_orange, Vector3(side * 0.40, 0.42, -1.70))
		root.add_child(blinker)
		
	# Thin front chrome bumper with rubber overriders
	var front_bumper = create_box(Vector3(1.42, 0.08, 0.08), mat_chrome, Vector3(0.0, 0.34, -1.74))
	root.add_child(front_bumper)
	for side in [-1.0, 1.0]:
		var overrider = create_box(Vector3(0.045, 0.16, 0.09), mat_plastic_black, Vector3(side * 0.46, 0.34, -1.745))
		root.add_child(overrider)
		
	var front_plate = create_license_plate_french_vintage(Vector3(0.0, 0.24, -1.75))
	root.add_child(front_plate)
	
	# --- 3. GTL SIDE RUBBING PROTECTIVE STRIPS & WHEEL ARCHES ---
	for side in [-1.0, 1.0]:
		var gtl_band = create_box(Vector3(0.03, 0.16, 2.10), mat_plastic_grey, Vector3(side * 0.73, 0.38, 0.18))
		root.add_child(gtl_band)
		var arch_f = create_box(Vector3(0.04, 0.04, 0.65), mat_plastic_grey, Vector3(side * 0.72, 0.46, -1.15))
		var arch_r = create_box(Vector3(0.04, 0.04, 0.65), mat_plastic_grey, Vector3(side * 0.72, 0.46, 1.15))
		root.add_child(arch_f); root.add_child(arch_r)
		
	# --- 4. GREENHOUSE: WINDSHIELD, ROOF & 3RD SIDE WINDOW ---
	var windshield = create_box(Vector3(1.22, 0.44, 0.03), mat_glass, Vector3(0.0, 0.88, -0.58))
	windshield.rotation.x = deg_to_rad(24.0)
	root.add_child(windshield)
	
	# Wipers
	for wx in [-0.28, 0.12]:
		var wiper = create_box(Vector3(0.02, 0.36, 0.02), mat_steel, Vector3(wx, 0.82, -0.46))
		wiper.rotation.x = deg_to_rad(-48.0)
		wiper.rotation.z = deg_to_rad(32.0)
		root.add_child(wiper)
		
	# Side windows & B-pillar
	for side in [-1.0, 1.0]:
		var front_glass = create_box(Vector3(0.03, 0.38, 0.78), mat_glass, Vector3(side * 0.68, 0.90, -0.16))
		var b_pillar = create_box(Vector3(0.04, 0.40, 0.06), body_mat, Vector3(side * 0.69, 0.90, 0.26))
		var mid_glass = create_box(Vector3(0.03, 0.38, 0.68), mat_glass, Vector3(side * 0.68, 0.90, 0.66))
		var c_pillar = create_box(Vector3(0.04, 0.40, 0.06), body_mat, Vector3(side * 0.69, 0.90, 1.03))
		# Famous 3rd side window (custode posteriore)
		var rear_quarter_glass = create_box(Vector3(0.03, 0.34, 0.42), mat_glass, Vector3(side * 0.68, 0.89, 1.28))
		root.add_child(front_glass); root.add_child(b_pillar); root.add_child(mid_glass); root.add_child(c_pillar); root.add_child(rear_quarter_glass)
		
	var rear_glass = create_box(Vector3(1.18, 0.40, 0.03), mat_glass, Vector3(0.0, 0.89, 1.62))
	rear_glass.rotation.x = deg_to_rad(10.0)
	root.add_child(rear_glass)
	
	# Roof panel with longitudinal ribbing
	var roof_panel = create_box(Vector3(1.36, 0.05, 2.24), body_mat, Vector3(0.0, 1.13, 0.50))
	root.add_child(roof_panel)
	for rx in [-0.40, -0.18, 0.0, 0.18, 0.40]:
		var rib = create_box(Vector3(0.025, 0.02, 2.05), body_mat, Vector3(rx, 1.16, 0.50))
		root.add_child(rib)
		
	# --- 5. 3D COCKPIT INTERIOR: UMBRELLA SHIFTER & HAMMOCK SEATS ---
	var dash_shelf = create_box(Vector3(1.22, 0.18, 0.32), mat_interior_dark, Vector3(0.0, 0.72, -0.48))
	var jaeger_pod = create_box(Vector3(0.28, 0.14, 0.18), mat_interior_dark, Vector3(-0.35, 0.82, -0.46))
	root.add_child(dash_shelf); root.add_child(jaeger_pod)
	
	# Steering wheel
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.35, 0.82, -0.22)
	steer_pivot.rotation.x = deg_to_rad(-22.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_R4"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.14; torus.outer_radius = 0.165; torus.rings = 14; torus.ring_segments = 8
	torus.material = mat_plastic_black
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5
	steer_node.add_child(sw_rim)
	
	var spoke_h = create_box(Vector3(0.28, 0.03, 0.015), mat_plastic_black, Vector3(0, 0, 0))
	var center_hub = create_box(Vector3(0.06, 0.06, 0.025), mat_plastic_black, Vector3(0, 0, 0.01))
	steer_node.add_child(spoke_h); steer_node.add_child(center_hub)
	
	# THE ICONIC DASH-MOUNTED UMBRELLA SHIFTER (Leva a manico d'ombrello / revolver)
	var umbrella_rod = create_box(Vector3(0.018, 0.018, 0.28), mat_chrome, Vector3(-0.06, 0.75, -0.32))
	var umbrella_handle = create_box(Vector3(0.018, 0.09, 0.018), mat_chrome, Vector3(-0.06, 0.80, -0.18))
	var knob_ball = MeshInstance3D.new()
	var sp_knob = SphereMesh.new()
	sp_knob.radius = 0.028; sp_knob.height = 0.056
	sp_knob.material = mat_plastic_black
	knob_ball.mesh = sp_knob
	knob_ball.position = Vector3(-0.06, 0.85, -0.18)
	root.add_child(umbrella_rod); root.add_child(umbrella_handle); root.add_child(knob_ball)
	
	# Tubular hammock seats in fabric
	for seat_x in [-0.35, 0.35]:
		var frame_bot = create_box(Vector3(0.42, 0.08, 0.42), mat_steel, Vector3(seat_x, 0.46, 0.10))
		var cushion = create_box(Vector3(0.38, 0.06, 0.38), mat_interior_fabric, Vector3(seat_x, 0.48, 0.10))
		var frame_back = create_box(Vector3(0.42, 0.48, 0.06), mat_steel, Vector3(seat_x, 0.72, 0.31))
		frame_back.rotation.x = deg_to_rad(14.0)
		var back_cloth = create_box(Vector3(0.38, 0.44, 0.03), mat_interior_fabric, Vector3(seat_x, 0.72, 0.30))
		back_cloth.rotation.x = deg_to_rad(14.0)
		root.add_child(frame_bot); root.add_child(cushion); root.add_child(frame_back); root.add_child(back_cloth)
		
	# --- 6. REAR END & SLIM TAILLIGHTS ---
	var rear_bumper = create_box(Vector3(1.42, 0.08, 0.08), mat_chrome, Vector3(0.0, 0.34, 1.76))
	root.add_child(rear_bumper)
	for side in [-1.0, 1.0]:
		var overrider = create_box(Vector3(0.045, 0.16, 0.09), mat_plastic_black, Vector3(side * 0.46, 0.34, 1.765))
		root.add_child(overrider)
		# Slim vertical taillights
		var orange_top = create_box(Vector3(0.06, 0.075, 0.03), mat_blinker_orange, Vector3(side * 0.62, 0.58, 1.76))
		var red_bot = create_box(Vector3(0.06, 0.075, 0.03), mat_tail_red, Vector3(side * 0.62, 0.50, 1.76))
		root.add_child(orange_top); root.add_child(red_bot)
		
	var boot_handle = create_box(Vector3(0.12, 0.03, 0.03), mat_chrome, Vector3(0.0, 0.65, 1.76))
	var rear_plate = create_license_plate_french_vintage(Vector3(0.0, 0.46, 1.76))
	root.add_child(boot_handle); root.add_child(rear_plate)
	
	# Slanted single exhaust pipe under left rear
	var pipe = MeshInstance3D.new()
	var p_cyl = CylinderMesh.new()
	p_cyl.top_radius = 0.025; p_cyl.bottom_radius = 0.025; p_cyl.height = 0.22; p_cyl.radial_segments = 12
	p_cyl.material = mat_exhaust
	pipe.mesh = p_cyl
	pipe.position = Vector3(-0.48, 0.20, 1.82)
	pipe.rotation.x = PI * 0.48
	root.add_child(pipe)
	
	return root

# ==============================================================================
# 7. BMW 320i E30 (1990 - "Der 3er" Bayerische Motoren Werke)
# ==============================================================================
static func build_bmw_320_e30(parent: Node3D, body_mat: Material):
	init_materials()
	for child in parent.get_children():
		child.queue_free()
		
	var root = Node3D.new()
	root.name = "BMW_E30_BodyRoot"
	parent.add_child(root)
	
	# --- 1. CHASSIS & 3-BOX NOTCHBACK SILHOUETTE ---
	var lower_tub = create_box(Vector3(1.64, 0.38, 4.18), body_mat, Vector3(0.0, 0.38, 0.06))
	root.add_child(lower_tub)
	
	# Sculpted low bonnet / hood with subtle twin power ridges
	var hood = create_sculpted_hood(Vector3(0.0, 0.50, -1.26), 1.48, 1.34, 1.34, 0.12, 0.0, 0.04, body_mat, 14, 14)
	root.add_child(hood)
	
	# Short square rear trunk deck
	var trunk = create_box(Vector3(1.48, 0.22, 0.88), body_mat, Vector3(0.0, 0.62, 1.62))
	root.add_child(trunk)
	
	# Subtle trunk lip spoiler
	var lip = create_box(Vector3(1.42, 0.03, 0.06), mat_plastic_black, Vector3(0.0, 0.73, 2.05))
	root.add_child(lip)
	
	# --- 2. FRONT FASCIA: TWIN HORIZONTAL GRILLES & BMW KIDNEYS ---
	var grille_black = create_box(Vector3(1.52, 0.24, 0.04), mat_plastic_black, Vector3(0.0, 0.54, -1.96))
	root.add_child(grille_black)
	
	# THE BMW KIDNEYS (Doppio Rene BMW cromato)
	for side in [-1.0, 1.0]:
		var kidney_chrome = create_box(Vector3(0.075, 0.19, 0.03), mat_chrome, Vector3(side * 0.048, 0.54, -1.98))
		var kidney_slats = create_box(Vector3(0.055, 0.17, 0.035), mat_plastic_black, Vector3(side * 0.048, 0.54, -1.985))
		root.add_child(kidney_chrome); root.add_child(kidney_slats)
		
	# 4 Parabolic Round Headlights (2 per side)
	for side in [-1.0, 1.0]:
		var lamp_out = create_parabolic_headlamp(Vector3(side * 0.52, 0.54, -1.97), 0.068, 0.05, mat_chrome, mat_headlight)
		var lamp_in = create_parabolic_headlamp(Vector3(side * 0.35, 0.54, -1.97), 0.068, 0.05, mat_chrome, mat_headlight)
		root.add_child(lamp_out); root.add_child(lamp_in)
		
	# BMW Roundel emblem on hood front edge
	var bmw_badge_base = create_round_lamp(0.034, mat_chrome, Vector3(0.0, 0.67, -1.92))
	var bmw_q1 = create_box(Vector3(0.016, 0.016, 0.01), mat_bmw_blue, Vector3(-0.008, 0.672, -1.92))
	var bmw_q2 = create_box(Vector3(0.016, 0.016, 0.01), mat_plate_white, Vector3(0.008, 0.672, -1.92))
	var bmw_q3 = create_box(Vector3(0.016, 0.016, 0.01), mat_plate_white, Vector3(-0.008, 0.668, -1.92))
	var bmw_q4 = create_box(Vector3(0.016, 0.016, 0.01), mat_bmw_blue, Vector3(0.008, 0.668, -1.92))
	root.add_child(bmw_badge_base); root.add_child(bmw_q1); root.add_child(bmw_q2); root.add_child(bmw_q3); root.add_child(bmw_q4)
	
	# Curved Front Bumper with integrated amber blinkers & lower chin apron
	var front_bumper = create_curved_bumper(Vector3(0.0, 0.38, -1.98), 1.66, 0.16, 0.20, 0.14, body_mat, false, 12)
	var bumper_strip = create_box(Vector3(1.64, 0.04, 0.22), mat_plastic_black, Vector3(0.0, 0.40, -1.98))
	root.add_child(front_bumper); root.add_child(bumper_strip)
	
	for side in [-1.0, 1.0]:
		var blinker = create_box(Vector3(0.14, 0.05, 0.04), mat_blinker_orange, Vector3(side * 0.58, 0.38, -2.08))
		root.add_child(blinker)
		
	var chin_spoiler = create_box(Vector3(1.58, 0.10, 0.16), mat_plastic_black, Vector3(0.0, 0.24, -1.96))
	root.add_child(chin_spoiler)
	
	var front_plate = create_license_plate_german(Vector3(0.0, 0.28, -2.08))
	root.add_child(front_plate)
	
	# --- 3. SIDE PROFILE: CURVED WHEEL ARCHES & SHADOWLINE MOULDINGS ---
	for side in [-1.0, 1.0]:
		var is_left = (side < 0)
		var arch_f = create_curved_wheel_arch(Vector3(side * 0.82, 0.40, -1.32), 0.35, 0.09, 0.04, is_left, body_mat, 18)
		var arch_r = create_curved_wheel_arch(Vector3(side * 0.82, 0.40, 1.30), 0.35, 0.09, 0.04, is_left, body_mat, 18)
		root.add_child(arch_f); root.add_child(arch_r)
		
		var rub_strip = create_box(Vector3(0.03, 0.045, 3.40), mat_plastic_black, Vector3(side * 0.83, 0.48, 0.08))
		var handle = create_box(Vector3(0.04, 0.03, 0.14), mat_plastic_black, Vector3(side * 0.84, 0.68, -0.06))
		root.add_child(rub_strip); root.add_child(handle)
		
	# Raked windshield
	var windshield = create_box(Vector3(1.36, 0.46, 0.03), mat_glass, Vector3(0.0, 0.86, -0.48))
	windshield.rotation.x = deg_to_rad(32.0)
	root.add_child(windshield)
	
	# Side glass & Hofmeister Kink
	for side in [-1.0, 1.0]:
		var side_glass = create_box(Vector3(0.03, 0.36, 1.65), mat_glass, Vector3(side * 0.73, 0.88, 0.42))
		var b_pillar = create_box(Vector3(0.04, 0.38, 0.06), mat_plastic_black, Vector3(side * 0.74, 0.88, 0.30))
		# Hofmeister kink body-colored corner
		var kink_corner = create_box(Vector3(0.05, 0.14, 0.16), body_mat, Vector3(side * 0.74, 0.76, 1.20))
		root.add_child(side_glass); root.add_child(b_pillar); root.add_child(kink_corner)
		
	# Slanted rear window
	var rear_glass = create_box(Vector3(1.32, 0.44, 0.03), mat_glass, Vector3(0.0, 0.88, 1.32))
	rear_glass.rotation.x = deg_to_rad(-30.0)
	root.add_child(rear_glass)
	
	# Roof
	var roof_panel = create_box(Vector3(1.42, 0.05, 1.72), body_mat, Vector3(0.0, 1.08, 0.44))
	root.add_child(roof_panel)
	
	# --- 4. 3D COCKPIT INTERIOR: DRIVER-ANGLED CONSOLE & M-TECH WHEEL ---
	var dash = create_box(Vector3(1.34, 0.24, 0.42), mat_interior_dark, Vector3(0.0, 0.70, -0.38))
	var cluster_pod = create_box(Vector3(0.48, 0.16, 0.26), mat_interior_dark, Vector3(-0.36, 0.82, -0.40))
	# Angled center console (turned ~8 degrees towards driver)
	var center_stack = create_box(Vector3(0.24, 0.32, 0.26), mat_interior_dark, Vector3(-0.04, 0.60, -0.26))
	center_stack.rotation.y = deg_to_rad(-8.0)
	root.add_child(dash); root.add_child(cluster_pod); root.add_child(center_stack)
	
	# Steering wheel
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.36, 0.80, -0.20)
	steer_pivot.rotation.x = deg_to_rad(-18.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_BMW"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.14; torus.outer_radius = 0.17; torus.rings = 16; torus.ring_segments = 10
	torus.material = mat_leather
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5
	steer_node.add_child(sw_rim)
	
	# 3-spoke M-Technik design
	var sp_left = create_box(Vector3(0.12, 0.03, 0.02), mat_leather, Vector3(-0.08, 0, 0))
	var sp_right = create_box(Vector3(0.12, 0.03, 0.02), mat_leather, Vector3(0.08, 0, 0))
	var sp_bot = create_box(Vector3(0.03, 0.12, 0.02), mat_leather, Vector3(0, -0.08, 0))
	var center_crest = create_round_lamp(0.046, mat_interior_dark, Vector3(0, 0, 0.015))
	var badge_ring = create_round_lamp(0.022, mat_steel, Vector3(0, 0, 0.022))
	var sw_bmw_q1 = create_box(Vector3(0.009, 0.009, 0.003), mat_bmw_blue, Vector3(-0.005, 0.005, 0.025))
	var sw_bmw_q2 = create_box(Vector3(0.009, 0.009, 0.003), mat_plate_white, Vector3(0.005, 0.005, 0.025))
	var sw_bmw_q3 = create_box(Vector3(0.009, 0.009, 0.003), mat_plate_white, Vector3(-0.005, -0.005, 0.025))
	var sw_bmw_q4 = create_box(Vector3(0.009, 0.009, 0.003), mat_bmw_blue, Vector3(0.005, -0.005, 0.025))
	steer_node.add_child(sp_left); steer_node.add_child(sp_right); steer_node.add_child(sp_bot)
	steer_node.add_child(center_crest); steer_node.add_child(badge_ring)
	steer_node.add_child(sw_bmw_q1); steer_node.add_child(sw_bmw_q2); steer_node.add_child(sw_bmw_q3); steer_node.add_child(sw_bmw_q4)
	
	# Short floor-mounted shift lever on transmission tunnel
	var shift_console = create_box(Vector3(0.20, 0.14, 0.40), mat_interior_dark, Vector3(0.0, 0.46, -0.05))
	var shift_lever = create_box(Vector3(0.02, 0.16, 0.02), mat_chrome, Vector3(0.0, 0.58, -0.05))
	var shift_knob = create_box(Vector3(0.04, 0.05, 0.04), mat_leather, Vector3(0.0, 0.66, -0.05))
	root.add_child(shift_console); root.add_child(shift_lever); root.add_child(shift_knob)
	
	# Sport seats in anthracite fabric
	for seat_x in [-0.36, 0.36]:
		var s_base = create_box(Vector3(0.44, 0.12, 0.46), mat_interior_dark, Vector3(seat_x, 0.44, 0.10))
		var s_back = create_box(Vector3(0.42, 0.52, 0.10), mat_interior_dark, Vector3(seat_x, 0.72, 0.32))
		s_back.rotation.x = deg_to_rad(14.0)
		var bolster_l = create_box(Vector3(0.08, 0.46, 0.16), mat_interior_dark, Vector3(seat_x - 0.18, 0.70, 0.30))
		var bolster_r = create_box(Vector3(0.08, 0.46, 0.16), mat_interior_dark, Vector3(seat_x + 0.18, 0.70, 0.30))
		root.add_child(s_base); root.add_child(s_back); root.add_child(bolster_l); root.add_child(bolster_r)
		
	# --- 5. REAR END: LATE E30 LIGHTS & TWIN ANGLED EXHAUST ---
	var rear_bumper = create_curved_bumper(Vector3(0.0, 0.38, 2.06), 1.66, 0.18, 0.22, 0.14, body_mat, true, 12)
	var rear_strip = create_box(Vector3(1.64, 0.04, 0.23), mat_plastic_black, Vector3(0.0, 0.40, 2.06))
	root.add_child(rear_bumper); root.add_child(rear_strip)
	
	# Late E30 rectangular taillights
	for side in [-1.0, 1.0]:
		var amber_top = create_box(Vector3(0.12, 0.075, 0.03), mat_blinker_orange, Vector3(side * 0.62, 0.58, 2.08))
		var rev_top = create_box(Vector3(0.12, 0.075, 0.03), mat_reverse_white, Vector3(side * 0.48, 0.58, 2.08))
		var red_bot = create_box(Vector3(0.26, 0.075, 0.03), mat_tail_red, Vector3(side * 0.55, 0.50, 2.08))
		root.add_child(amber_top); root.add_child(rev_top); root.add_child(red_bot)
		
	var rear_plate = create_license_plate_german(Vector3(0.0, 0.54, 2.09))
	root.add_child(rear_plate)
	
	# Twin angled chrome curved exhaust pipes
	var twin_exhaust = create_curved_exhaust_pipe(Vector3(-0.48, 0.22, 2.06), 0.034, 0.26, mat_chrome, true)
	twin_exhaust.rotation_degrees = Vector3(0.0, -12.0, 0.0)
	root.add_child(twin_exhaust)
		
	return root

# ==============================================================================
# 8. MERCEDES-BENZ A 250 SPORT W176 (2016 - AMG Line Facelift)
# ==============================================================================
static func build_mercedes_a250(parent: Node3D, body_mat: Material):
	init_materials()
	for child in parent.get_children():
		child.queue_free()
		
	var root = Node3D.new()
	root.name = "A250_BodyRoot"
	parent.add_child(root)
	
	# --- 1. CHASSIS & SCULPTED HOT-HATCH SILHOUETTE ---
	var lower_tub = create_box(Vector3(1.76, 0.40, 4.22), body_mat, Vector3(0.0, 0.40, 0.05))
	root.add_child(lower_tub)
	
	# Curved aerodynamic bonnet / hood
	var hood = create_box(Vector3(1.52, 0.18, 1.25), body_mat, Vector3(0.0, 0.62, -1.22))
	hood.rotation.x = deg_to_rad(8.0)
	root.add_child(hood)
	
	# AMG Side Skirts in gloss black
	for side in [-1.0, 1.0]:
		var skirt = create_box(Vector3(0.04, 0.10, 2.60), mat_plastic_black, Vector3(side * 0.88, 0.24, 0.15))
		root.add_child(skirt)
		
	# --- 2. FRONT FASCIA: DIAMOND MATRIX GRILLE & AMG SPLITTER ---
	# Diamond Grille background
	var grille_matrix = create_box(Vector3(1.22, 0.32, 0.04), mat_plastic_black, Vector3(0.0, 0.54, -1.98))
	root.add_child(grille_matrix)
	
	# Single horizontal chrome wing slat
	var chrome_wing = create_box(Vector3(0.96, 0.035, 0.03), mat_chrome, Vector3(0.0, 0.54, -2.01))
	root.add_child(chrome_wing)
	
	# Large central 3-pointed Star with radar plate
	var star_plate = create_round_lamp(0.08, mat_plastic_black, Vector3(0.0, 0.54, -2.015))
	var star_rim = create_round_lamp(0.075, mat_chrome, Vector3(0.0, 0.54, -2.02))
	root.add_child(star_plate); root.add_child(star_rim)
	
	# 3 Star points
	for a in [90.0, 210.0, 330.0]:
		var pt = create_box(Vector3(0.015, 0.065, 0.01), mat_chrome, Vector3(cos(deg_to_rad(a)) * 0.035, 0.54 + sin(deg_to_rad(a)) * 0.035, -2.025))
		pt.rotation.z = deg_to_rad(a - 90.0)
		root.add_child(pt)
		
	# High Performance LED Headlights & Eyebrow DRLs
	for side in [-1.0, 1.0]:
		var lamp_body = create_box(Vector3(0.25, 0.13, 0.06), mat_headlight, Vector3(side * 0.68, 0.56, -1.95))
		var drl_eyebrow = create_box(Vector3(0.24, 0.02, 0.03), mat_led_daylight, Vector3(side * 0.68, 0.63, -1.98))
		drl_eyebrow.rotation.z = deg_to_rad(side * -10.0)
		root.add_child(lamp_body); root.add_child(drl_eyebrow)
		
	# AMG Line front bumper with massive shark-fin side intakes & splitter
	var amg_bumper = create_box(Vector3(1.76, 0.20, 0.24), body_mat, Vector3(0.0, 0.36, -1.96))
	root.add_child(amg_bumper)
	
	for side in [-1.0, 1.0]:
		var amg_intake = create_box(Vector3(0.30, 0.20, 0.10), mat_plastic_black, Vector3(side * 0.70, 0.32, -1.98))
		root.add_child(amg_intake)
		
	var amg_splitter = create_box(Vector3(1.58, 0.04, 0.14), mat_plastic_black, Vector3(0.0, 0.21, -2.02))
	root.add_child(amg_splitter)
	
	var front_plate = create_license_plate_german(Vector3(0.0, 0.32, -2.08))
	root.add_child(front_plate)
	
	# --- 3. GREENHOUSE: RAKED SCREEN, PRIVACY GLASS & ROOF SPOILER ---
	var windshield = create_box(Vector3(1.42, 0.48, 0.03), mat_glass, Vector3(0.0, 0.88, -0.46))
	windshield.rotation.x = deg_to_rad(36.0)
	root.add_child(windshield)
	
	# Dark privacy side windows & gloss black pillars
	for side in [-1.0, 1.0]:
		var side_glass = create_box(Vector3(0.03, 0.36, 1.75), mat_glass, Vector3(side * 0.78, 0.90, 0.44))
		var pillar_b = create_box(Vector3(0.04, 0.38, 0.08), mat_plastic_black, Vector3(side * 0.79, 0.90, 0.32))
		root.add_child(side_glass); root.add_child(pillar_b)
		
	var rear_glass = create_box(Vector3(1.36, 0.38, 0.03), mat_glass, Vector3(0.0, 0.88, 1.48))
	rear_glass.rotation.x = deg_to_rad(-28.0)
	root.add_child(rear_glass)
	
	# Curved roof ending in roof spoiler
	var roof_panel = create_box(Vector3(1.46, 0.05, 1.80), body_mat, Vector3(0.0, 1.10, 0.44))
	var roof_spoiler = create_box(Vector3(1.38, 0.06, 0.34), mat_plastic_black, Vector3(0.0, 1.12, 1.62))
	root.add_child(roof_panel); root.add_child(roof_spoiler)
	
	# --- 4. 3D COCKPIT INTERIOR: 5 TURBINE AIR VENTS & TABLET COMAND SCREEN ---
	var modern_dash = create_box(Vector3(1.42, 0.22, 0.42), mat_interior_dark, Vector3(0.0, 0.70, -0.36))
	root.add_child(modern_dash)
	
	# 5 Aviation turbine circular air vents (3 center, 2 lateral)
	for vx in [-0.10, 0.0, 0.10, -0.62, 0.62]:
		var vent = create_round_lamp(0.038, mat_chrome, Vector3(vx, 0.70, -0.30))
		var core = create_round_lamp(0.024, mat_plastic_black, Vector3(vx, 0.70, -0.295))
		root.add_child(vent); root.add_child(core)
		
	# Floating 8-inch COMAND tablet screen
	var screen_body = create_box(Vector3(0.28, 0.16, 0.025), mat_plastic_black, Vector3(0.0, 0.86, -0.32))
	var screen_bezel = create_box(Vector3(0.29, 0.17, 0.015), mat_chrome, Vector3(0.0, 0.86, -0.325))
	root.add_child(screen_body); root.add_child(screen_bezel)
	
	# Steering wheel: AMG flat-bottom sport wheel
	var steer_pivot = Node3D.new()
	steer_pivot.position = Vector3(-0.37, 0.80, -0.18)
	steer_pivot.rotation.x = deg_to_rad(-16.0)
	root.add_child(steer_pivot)
	
	var steer_node = Node3D.new()
	steer_node.name = "SteeringWheel_A250"
	steer_pivot.add_child(steer_node)
	
	var sw_rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.135; torus.outer_radius = 0.168; torus.rings = 16; torus.ring_segments = 10
	torus.material = mat_leather
	sw_rim.mesh = torus
	sw_rim.rotation.x = PI * 0.5
	steer_node.add_child(sw_rim)
	
	# Flat bottom bar
	var flat_bottom = create_box(Vector3(0.18, 0.03, 0.025), mat_steel, Vector3(0, -0.14, 0))
	var hub_amg = create_round_lamp(0.048, mat_interior_dark, Vector3(0, 0, 0.015))
	var star_ring = create_round_lamp(0.022, mat_steel, Vector3(0, 0, 0.022))
	var star_v = create_box(Vector3(0.003, 0.024, 0.004), mat_steel, Vector3(0, 0.004, 0.026))
	var star_d1 = create_box(Vector3(0.020, 0.003, 0.004), mat_steel, Vector3(0, -0.004, 0.026))
	star_d1.rotation.z = deg_to_rad(30.0)
	var star_d2 = create_box(Vector3(0.020, 0.003, 0.004), mat_steel, Vector3(0, -0.004, 0.026))
	star_d2.rotation.z = deg_to_rad(-30.0)
	var paddle_l = create_box(Vector3(0.02, 0.08, 0.01), mat_steel, Vector3(-0.16, 0.02, -0.02))
	var paddle_r = create_box(Vector3(0.02, 0.08, 0.01), mat_steel, Vector3(0.16, 0.02, -0.02))
	steer_node.add_child(flat_bottom); steer_node.add_child(hub_amg); steer_node.add_child(star_ring)
	steer_node.add_child(star_v); steer_node.add_child(star_d1); steer_node.add_child(star_d2)
	steer_node.add_child(paddle_l); steer_node.add_child(paddle_r)
	
	# Modern Integral Sport Seats (guscio anatomico)
	for seat_x in [-0.37, 0.37]:
		var s_base = create_box(Vector3(0.46, 0.12, 0.48), mat_interior_dark, Vector3(seat_x, 0.44, 0.10))
		var s_back = create_box(Vector3(0.44, 0.58, 0.10), mat_interior_dark, Vector3(seat_x, 0.74, 0.32))
		s_back.rotation.x = deg_to_rad(14.0)
		var int_headrest = create_box(Vector3(0.24, 0.22, 0.08), mat_interior_dark, Vector3(seat_x, 1.04, 0.40))
		int_headrest.rotation.x = deg_to_rad(14.0)
		root.add_child(s_base); root.add_child(s_back); root.add_child(int_headrest)
		
	# --- 5. REAR END: LED TAILLAMPS, DIFFUSER & INTEGRATED TRAPEZOIDAL EXHAUSTS ---
	var rear_bumper = create_box(Vector3(1.76, 0.26, 0.24), body_mat, Vector3(0.0, 0.40, 2.06))
	root.add_child(rear_bumper)
	
	# Horizontal LED Taillamps
	for side in [-1.0, 1.0]:
		var outer_led = create_box(Vector3(0.24, 0.11, 0.04), mat_tail_red, Vector3(side * 0.70, 0.62, 2.08))
		var inner_led = create_box(Vector3(0.18, 0.08, 0.04), mat_tail_red, Vector3(side * 0.48, 0.62, 2.10))
		root.add_child(outer_led); root.add_child(inner_led)
		
	# Rear Diffuser with aerodynamic fins
	var diffuser = create_box(Vector3(1.42, 0.16, 0.18), mat_plastic_black, Vector3(0.0, 0.24, 2.08))
	root.add_child(diffuser)
	
	# Twin wide chrome trapezoidal exhaust outlets
	for side in [-1.0, 1.0]:
		var tip = create_box(Vector3(0.18, 0.065, 0.08), mat_chrome, Vector3(side * 0.58, 0.26, 2.12))
		var tip_hole = create_box(Vector3(0.16, 0.05, 0.085), mat_plastic_black, Vector3(side * 0.58, 0.26, 2.125))
		root.add_child(tip); root.add_child(tip_hole)
		
	var rear_plate = create_license_plate_german(Vector3(0.0, 0.48, 2.12))
	root.add_child(rear_plate)
	
	return root

# ==============================================================================
# 9. ALFA ROMEO 8C 2900B SPIDER CORSA (1938 - Touring Superleggera Vittorio Jano)
# ==============================================================================
# Iconic pre-war masterpiece: twin Roots superchargers, 8-cyl in-line, transaxle 50:50,
# swooping teardrop pontoon fenders, towering Alfa heart grille & Borrani wire wheels.
static func build_alfa_8c_2900b(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "Alfa8CRig"
	parent.add_child(root)
	
	var actual_mat = body_mat if body_mat else mat_alfa_amaranto
	
	# --- 1. CHASSIS & TORPEDO LOWER TUB ---
	var lower_tub = create_box(Vector3(1.36, 0.34, 3.85), actual_mat, Vector3(0.0, 0.40, 0.05))
	root.add_child(lower_tub)
	
	# Underside ladder frame chassis members
	for s in [-0.55, 0.55]:
		var frame_rail = create_box(Vector3(0.12, 0.14, 3.95), mat_steel, Vector3(s, 0.22, 0.0))
		root.add_child(frame_rail)
		
	# --- 2. ENDLESS HOOD & DUAL ROOTS SUPERCHARGER BONNET ---
	# Long, sculpted aerodynamic hood tapering forward with central crown camber
	var hood_main = create_sculpted_hood(Vector3(0.0, 0.52, -0.20), 1.12, 0.88, 1.75, 0.16, 0.02, 0.075, actual_mat, 12, 12)
	root.add_child(hood_main)
	
	# Center bonnet hinge line & chrome trim
	var hood_spine = create_box(Vector3(0.025, 0.03, 1.76), mat_chrome, Vector3(0.0, 0.79, -1.05))
	hood_spine.rotation.x = deg_to_rad(-2.0)
	root.add_child(hood_spine)
	
	# Lateral engine cooling louvres (venting the 2.9L straight-8)
	for side in [-1.0, 1.0]:
		for l_idx in range(6):
			var louvre = create_box(Vector3(0.025, 0.04, 0.12), mat_plastic_black, Vector3(side * 0.56, 0.60, -1.45 + float(l_idx) * 0.16))
			louvre.rotation.z = deg_to_rad(side * 15.0)
			root.add_child(louvre)
			
	# Leather bonnet tie-down straps (Cinghie in cuoio con fibbie da corsa)
	for strap_z in [-1.55, -0.65]:
		var strap = create_box(Vector3(1.14, 0.025, 0.05), mat_wood_steering, Vector3(0.0, 0.78, strap_z))
		var buckle_l = create_box(Vector3(0.03, 0.04, 0.06), mat_chrome, Vector3(-0.56, 0.64, strap_z))
		var buckle_r = create_box(Vector3(0.03, 0.04, 0.06), mat_chrome, Vector3(0.56, 0.64, strap_z))
		root.add_child(strap); root.add_child(buckle_l); root.add_child(buckle_r)
		
	# --- 3. MAJESTIC TALL ALFA SCUDETTO & FRONT NOSE ---
	# Tall triangular chrome grille with polished mesh
	var grille_frame = create_box(Vector3(0.46, 0.58, 0.12), mat_chrome, Vector3(0.0, 0.58, -1.96))
	var grille_mesh = create_box(Vector3(0.38, 0.52, 0.08), mat_plastic_black, Vector3(0.0, 0.58, -1.98))
	root.add_child(grille_frame); root.add_child(grille_mesh)
	
	# Vertical grille bars
	for bar_i in range(-3, 4):
		var bar = create_box(Vector3(0.018, 0.48, 0.04), mat_chrome, Vector3(float(bar_i) * 0.052, 0.58, -2.01))
		root.add_child(bar)
		
	# Enamelled Alfa Romeo Biscione emblem on radiator top
	var alfa_badge = create_round_lamp(0.045, mat_alfa_red, Vector3(0.0, 0.84, -1.97))
	root.add_child(alfa_badge)
	
	# --- 4. FLUID PONTOON TEARDROP FENDERS & RUNNING BOARDS ---
	for side in [-1.0, 1.0]:
		var is_left = (side < 0)
		# Smooth continuous pontoon fenders sweeping over front wheels and rear haunches
		var fender_front = create_swept_pontoon_fender(Vector3(side * 0.72, 0.36, -2.05), Vector3(side * 0.76, 0.74, -1.15), Vector3(side * 0.74, 0.38, -0.45), 0.28, 0.18, is_left, actual_mat, 20)
		var fender_rear = create_swept_pontoon_fender(Vector3(side * 0.74, 0.38, 0.45), Vector3(side * 0.76, 0.72, 1.15), Vector3(side * 0.58, 0.42, 2.05), 0.28, 0.18, is_left, actual_mat, 20)
		root.add_child(fender_front); root.add_child(fender_rear)
		
		# Classic wooden/rubber running board (pedana di salita)
		var running_board = create_box(Vector3(0.22, 0.06, 0.95), mat_plastic_black, Vector3(side * 0.74, 0.25, 0.0))
		root.add_child(running_board)
		
	# --- 5. FREESTANDING 3D PARABOLIC HEADLIGHTS (CARELLO TORPEDOES) ---
	for side in [-1.0, 1.0]:
		var hl_bracket = create_box(Vector3(0.12, 0.04, 0.08), mat_chrome, Vector3(side * 0.42, 0.58, -1.82))
		var hl = create_parabolic_headlamp(Vector3(side * 0.48, 0.64, -1.94), 0.13, 0.14, mat_chrome, mat_headlight)
		root.add_child(hl_bracket); root.add_child(hl)
		
	# Front slim curved bumper bar
	var front_bumper = create_curved_bumper(Vector3(0.0, 0.32, -2.05), 1.35, 0.22, 0.07, 0.05, mat_chrome, false, 18)
	root.add_child(front_bumper)
	
	# Twin straight-8 side exhaust
	var exh_8c = create_curved_exhaust_pipe(Vector3(-0.72, 0.34, 0.40), 0.052, 1.80, mat_exhaust, true)
	root.add_child(exh_8c)
	
	# --- 6. 1930s SPIDER COCKPIT: V-SPLIT WINDSCREEN, WOODEN WHEEL & DIALS ---
	# Twin aerodynamic aero-screens / V-split windscreen with brass/chrome frames
	for side in [-1.0, 1.0]:
		var screen_frame = create_box(Vector3(0.48, 0.22, 0.02), mat_chrome, Vector3(side * 0.28, 0.94, -0.16))
		screen_frame.rotation.x = deg_to_rad(-24.0)
		screen_frame.rotation.y = deg_to_rad(-side * 8.0)
		var screen_glass = create_box(Vector3(0.44, 0.18, 0.015), mat_glass, Vector3(side * 0.28, 0.94, -0.16))
		screen_glass.rotation.x = deg_to_rad(-24.0)
		screen_glass.rotation.y = deg_to_rad(-side * 8.0)
		root.add_child(screen_frame); root.add_child(screen_glass)
		
	# Engine cowl scuttle & cockpit surround
	var cowl = create_box(Vector3(1.24, 0.24, 0.35), actual_mat, Vector3(0.0, 0.78, -0.25))
	root.add_child(cowl)
	
	# Cockpit tub cutout
	var cockpit_floor = create_box(Vector3(1.08, 0.08, 0.90), mat_interior_dark, Vector3(0.0, 0.32, 0.35))
	root.add_child(cockpit_floor)
	
	# Fluted Bordeaux Leather Twin Bucket Seats
	for side in [-0.28, 0.28]:
		var seat_base = create_box(Vector3(0.42, 0.12, 0.42), mat_alfa_amaranto, Vector3(side, 0.38, 0.32))
		var seat_back = create_box(Vector3(0.40, 0.46, 0.10), mat_alfa_amaranto, Vector3(side, 0.62, 0.52))
		seat_back.rotation.x = deg_to_rad(12.0)
		root.add_child(seat_base); root.add_child(seat_back)
		
	# Aerodynamic headrest fairing behind driver (Pilota sinistro)
	var driver_fairing = create_box(Vector3(0.36, 0.24, 0.55), actual_mat, Vector3(-0.28, 0.82, 0.85))
	driver_fairing.rotation.x = deg_to_rad(-14.0)
	root.add_child(driver_fairing)
	
	# Machined Aluminium Dashboard & Vintage Veglia gauges
	var dash = create_box(Vector3(1.02, 0.26, 0.04), mat_steel, Vector3(0.0, 0.68, -0.06))
	root.add_child(dash)
	
	# Large circular tachometer & speedometer (white dials with brass rims)
	for dial_x in [-0.36, -0.20, 0.0, 0.20]:
		var dial = create_round_lamp(0.055, mat_headlight, Vector3(dial_x, 0.70, -0.04))
		root.add_child(dial)
		
	# Thin-spoke sprung steering wheel (Volante a tre razze in metallo con corona nera)
	var steer_col = create_box(Vector3(0.04, 0.04, 0.28), mat_steel, Vector3(-0.28, 0.64, 0.08))
	steer_col.rotation.x = deg_to_rad(-22.0)
	root.add_child(steer_col)
	var steer_wheel = create_round_lamp(0.17, mat_plastic_black, Vector3(-0.28, 0.74, 0.18))
	steer_wheel.rotation.x = deg_to_rad(68.0)
	root.add_child(steer_wheel)
	
	# Long external gearshift and handbrake levers on cockpit sill
	var gear_lever = create_box(Vector3(0.02, 0.26, 0.02), mat_chrome, Vector3(-0.02, 0.48, 0.18))
	gear_lever.rotation.x = deg_to_rad(15.0)
	root.add_child(gear_lever)
	
	# --- 7. TAPERED BOAT-TAIL STERN WITH SPARE WHEEL ---
	var rear_deck = create_box(Vector3(1.18, 0.34, 1.45), actual_mat, Vector3(0.0, 0.58, 1.25))
	rear_deck.rotation.x = deg_to_rad(-10.0)
	root.add_child(rear_deck)
	
	# Tapered tail spine
	var tail_point = create_box(Vector3(0.85, 0.24, 0.65), actual_mat, Vector3(0.0, 0.46, 1.88))
	root.add_child(tail_point)
	
	# Recessed spare Borrani wire wheel on tail deck
	var spare_tire = create_box(Vector3(0.18, 0.54, 0.54), mat_plastic_black, Vector3(0.0, 0.62, 1.45))
	spare_tire.rotation.x = deg_to_rad(45.0)
	var spare_hub = create_box(Vector3(0.20, 0.24, 0.24), mat_borrani_wire, Vector3(0.0, 0.64, 1.45))
	spare_hub.rotation.x = deg_to_rad(45.0)
	var spare_strap = create_box(Vector3(0.03, 0.62, 0.62), mat_wood_steering, Vector3(0.0, 0.63, 1.45))
	spare_strap.rotation.x = deg_to_rad(45.0)
	root.add_child(spare_tire); root.add_child(spare_hub); root.add_child(spare_strap)
	
	# Long side-exit fishtail straight-through racing exhaust pipe
	var exh_header = create_box(Vector3(0.06, 0.06, 0.85), mat_exhaust, Vector3(0.68, 0.32, -0.65))
	var exh_pipe = create_box(Vector3(0.07, 0.07, 2.20), mat_chrome, Vector3(0.72, 0.24, 0.85))
	var fishtail_tip = create_box(Vector3(0.12, 0.04, 0.16), mat_chrome, Vector3(0.73, 0.24, 1.98))
	root.add_child(exh_header); root.add_child(exh_pipe); root.add_child(fishtail_tip)
	
	# Vintage Italian Pre-War Black License Plate
	var rear_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.36, 2.12), true)
	root.add_child(rear_plate)
	
	return root

# ==============================================================================
# 10. FIAT 500A "TOPOLINO" (1936 - Ing. Dante Giacosa Masterpiece)
# ==============================================================================
# The ingenious aerodynamic people's car: front overhung engine with rear radiator,
# curved bullet nose, suicide doors, rollback soft-top & rear-mounted spare wheel.
static func build_fiat_topolino(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "TopolinoRig"
	parent.add_child(root)
	
	var actual_mat = body_mat if body_mat else mat_topolino_maroon
	
	# --- 1. COMPACT TWO-BOX TEARDROP BODY ---
	var main_body = create_box(Vector3(1.18, 0.42, 2.75), actual_mat, Vector3(0.0, 0.44, 0.05))
	root.add_child(main_body)
	
	# Rounded curving roof cab
	var roof_cab = create_box(Vector3(1.10, 0.48, 1.45), actual_mat, Vector3(0.0, 0.88, 0.15))
	root.add_child(roof_cab)
	
	# Giacosa Rollback canvas sunroof (Capote in tela nera ripiegabile)
	var canvas_roof = create_box(Vector3(0.82, 0.04, 1.15), mat_plastic_black, Vector3(0.0, 1.13, 0.12))
	root.add_child(canvas_roof)
	
	# --- 2. BULLET NOSE & GIACOSA RADIATOR SLOTS ---
	# Sculpted aerodynamic tapering front bonnet with authentic crown
	var front_bonnet = create_sculpted_hood(Vector3(0.0, 0.50, -0.92), 0.94, 0.70, 0.95, 0.16, 0.02, 0.065, actual_mat, 12, 12)
	root.add_child(front_bonnet)
	
	# Rounded bullet nose grille (Mascherina bombata con feritoie orizzontali)
	var nose_shield = create_box(Vector3(0.68, 0.38, 0.14), mat_plastic_black, Vector3(0.0, 0.46, -1.45))
	root.add_child(nose_shield)
	
	# Horizontal Giacosa chrome whisker grille bars
	for gi in range(5):
		var bar = create_box(Vector3(0.60 - float(gi) * 0.07, 0.016, 0.04), mat_chrome, Vector3(0.0, 0.34 + float(gi) * 0.065, -1.48))
		root.add_child(bar)
		
	# Red round Fiat vintage logo on nose crown
	var fiat_crest = create_round_lamp(0.038, mat_alfa_red, Vector3(0.0, 0.66, -1.44))
	root.add_child(fiat_crest)
	
	# --- 3. SWEPT PONTOON FENDERS & 3D PARABOLIC HEADLIGHTS ---
	for side in [-1.0, 1.0]:
		var is_left = (side < 0)
		# Smooth swept pontoon teardrop front fender
		var fender_f = create_swept_pontoon_fender(Vector3(side * 0.56, 0.28, -1.48), Vector3(side * 0.64, 0.64, -0.92), Vector3(side * 0.60, 0.26, -0.32), 0.22, 0.16, is_left, actual_mat, 18)
		root.add_child(fender_f)
		
		# Curved 180° rear wheel arch
		var arch_r = create_curved_wheel_arch(Vector3(side * 0.60, 0.42, 0.95), 0.32, 0.08, 0.04, is_left, actual_mat, 16)
		root.add_child(arch_r)
		
		# Round parabolic torpedo headlamps with chrome bezel
		var hl = create_parabolic_headlamp(Vector3(side * 0.52, 0.68, -1.35), 0.11, 0.12, mat_chrome, mat_headlight)
		root.add_child(hl)
		
		# Running board step
		var step = create_box(Vector3(0.18, 0.04, 0.70), mat_plastic_black, Vector3(side * 0.60, 0.22, 0.05))
		root.add_child(step)
		
		# Chrome suicide door handle with rear hinge
		var handle = create_box(Vector3(0.025, 0.035, 0.09), mat_chrome, Vector3(side * 0.57, 0.62, -0.32))
		root.add_child(handle)
		
	# Chrome curved blade bumpers front and back
	var b_front = create_curved_bumper(Vector3(0.0, 0.28, -1.50), 1.12, 0.06, 0.05, 0.09, mat_chrome, false, 12)
	var b_rear = create_curved_bumper(Vector3(0.0, 0.30, 1.48), 1.12, 0.06, 0.05, 0.09, mat_chrome, true, 12)
	root.add_child(b_front); root.add_child(b_rear)
	
	# --- 4. GLASS CABIN & PERIOD MINIMALIST DASHBOARD ---
	# Upright curved windshield with chrome frame
	var ws_glass = create_box(Vector3(0.96, 0.34, 0.02), mat_glass, Vector3(0.0, 0.88, -0.45))
	ws_glass.rotation.x = deg_to_rad(-16.0)
	var ws_frame = create_box(Vector3(1.02, 0.38, 0.03), mat_chrome, Vector3(0.0, 0.88, -0.45))
	ws_frame.rotation.x = deg_to_rad(-16.0)
	root.add_child(ws_frame); root.add_child(ws_glass)
	
	# Side windows & rear split quarter lights
	for side in [-1.0, 1.0]:
		var side_w = create_box(Vector3(0.02, 0.30, 0.75), mat_glass, Vector3(side * 0.53, 0.88, 0.08))
		root.add_child(side_w)
		
	# Rear window
	var rear_w = create_box(Vector3(0.55, 0.24, 0.02), mat_glass, Vector3(0.0, 0.86, 0.84))
	rear_w.rotation.x = deg_to_rad(22.0)
	root.add_child(rear_w)
	
	# Minimalist interior seats and two-spoke Bakelite steering wheel
	for side in [-0.25, 0.25]:
		var seat = create_box(Vector3(0.36, 0.38, 0.38), mat_interior_dark, Vector3(side, 0.44, 0.12))
		root.add_child(seat)
	var steer_wheel = create_round_lamp(0.14, mat_plastic_black, Vector3(-0.25, 0.72, -0.16))
	steer_wheel.rotation.x = deg_to_rad(65.0)
	root.add_child(steer_wheel)
	
	# Central circular Veglia speedometer
	var center_dial = create_round_lamp(0.045, mat_headlight, Vector3(0.0, 0.66, -0.42))
	root.add_child(center_dial)
	
	# --- 5. REAR SLOPING BUSTLE WITH EXTERNAL ENCLOSED SPARE WHEEL ---
	var rear_deck = create_box(Vector3(1.02, 0.36, 0.65), actual_mat, Vector3(0.0, 0.52, 1.05))
	rear_deck.rotation.x = deg_to_rad(-24.0)
	root.add_child(rear_deck)
	
	# External vintage spare wheel cover with chrome hubcap
	var spare_wheel = create_round_lamp(0.24, mat_plastic_black, Vector3(0.0, 0.55, 1.44))
	spare_wheel.rotation.x = deg_to_rad(78.0)
	var spare_cap = create_round_lamp(0.09, mat_chrome, Vector3(0.0, 0.55, 1.47))
	spare_cap.rotation.x = deg_to_rad(78.0)
	root.add_child(spare_wheel); root.add_child(spare_cap)
	
	# Single small teardrop taillamp
	var tail_lamp = create_round_lamp(0.038, mat_tail_red, Vector3(-0.42, 0.58, 1.42))
	root.add_child(tail_lamp)
	
	# Upright vintage Italian license plate
	var rear_plate = create_license_plate_italian_vintage(Vector3(0.38, 0.52, 1.44), true)
	root.add_child(rear_plate)
	
	return root

# ==============================================================================
# 11. LANCIA AURELIA B20 GT 2500 (1953 - The World's First True Gran Turismo)
# ==============================================================================
# First production V6 engine, De Dion transaxle with inboard brakes, Pininfarina fastback,
# iconic Lancia shield grille, chrome bumper overriders & Nardi wood steering wheel.
static func build_lancia_aurelia_b20(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "AureliaB20Rig"
	parent.add_child(root)
	
	var actual_mat = body_mat if body_mat else mat_lancia_blue
	
	# --- 1. PININFARINA FASTBACK MONOCOQUE SCULPTURE ---
	var lower_body = create_box(Vector3(1.54, 0.38, 4.15), actual_mat, Vector3(0.0, 0.42, 0.0))
	root.add_child(lower_body)
	
	# Sleek curving bonnet with central crown camber
	var hood = create_sculpted_hood(Vector3(0.0, 0.52, -1.25), 1.36, 1.15, 1.48, 0.16, 0.02, 0.05, actual_mat, 14, 14)
	root.add_child(hood)
	
	# Elegant Fastback roof curving smoothly down into trunk
	var roof_cabin = create_box(Vector3(1.32, 0.44, 1.65), actual_mat, Vector3(0.0, 0.88, 0.05))
	root.add_child(roof_cabin)
	
	var fastback_sweep = create_box(Vector3(1.28, 0.32, 1.15), actual_mat, Vector3(0.0, 0.76, 1.35))
	fastback_sweep.rotation.x = deg_to_rad(-22.0)
	root.add_child(fastback_sweep)
	
	var trunk_lid = create_box(Vector3(1.30, 0.24, 0.85), actual_mat, Vector3(0.0, 0.56, 1.75))
	trunk_lid.rotation.x = deg_to_rad(-8.0)
	root.add_child(trunk_lid)
	
	# Curved 180° front and rear wheel arches
	for side in [-1.0, 1.0]:
		var is_left = (side < 0)
		var arch_f = create_curved_wheel_arch(Vector3(side * 0.77, 0.42, -1.35), 0.35, 0.09, 0.04, is_left, actual_mat, 18)
		var arch_r = create_curved_wheel_arch(Vector3(side * 0.77, 0.42, 1.25), 0.35, 0.09, 0.04, is_left, actual_mat, 18)
		root.add_child(arch_f); root.add_child(arch_r)
	
	# --- 2. NOBLE LANCIA CUSP SHIELD & FRONT GRILLE ---
	# Chrome Lancia shield shaped grille (Scudetto a calice)
	var lancia_shield = create_box(Vector3(0.38, 0.42, 0.06), mat_chrome, Vector3(0.0, 0.54, -2.06))
	var shield_mesh = create_box(Vector3(0.32, 0.36, 0.04), mat_plastic_black, Vector3(0.0, 0.54, -2.08))
	root.add_child(lancia_shield); root.add_child(shield_mesh)
	
	# Lancia Blue enamel flag emblem inside shield
	var lancia_flag = create_box(Vector3(0.08, 0.12, 0.02), mat_fiat_blue, Vector3(0.0, 0.60, -2.10))
	root.add_child(lancia_flag)
	
	# Horizontal chrome air whisker trim on both sides of shield
	for side in [-1.0, 1.0]:
		for wi in range(3):
			var whisker = create_box(Vector3(0.28, 0.016, 0.03), mat_chrome, Vector3(side * 0.42, 0.46 + float(wi) * 0.06, -2.04))
			root.add_child(whisker)
			
	# Inset 3D parabolic headlights with deep chrome bezels
	for side in [-1.0, 1.0]:
		var hl = create_parabolic_headlamp(Vector3(side * 0.62, 0.58, -2.02), 0.125, 0.08, mat_chrome, mat_headlight)
		root.add_child(hl)
		
		# Round amber turn indicators below headlights
		var turn_ind = create_round_lamp(0.042, mat_blinker_orange, Vector3(side * 0.62, 0.40, -2.03))
		root.add_child(turn_ind)
		
	# Slender wraparound chrome bumpers with upright bumper overriders (Rostri)
	var front_bumper = create_curved_bumper(Vector3(0.0, 0.32, -2.08), 1.54, 0.09, 0.08, 0.14, mat_chrome, false, 12)
	root.add_child(front_bumper)
	for rostri_x in [-0.35, 0.35]:
		var r_f = create_box(Vector3(0.05, 0.22, 0.09), mat_chrome, Vector3(rostri_x, 0.38, -2.10))
		root.add_child(r_f)
		
	var rear_bumper = create_curved_bumper(Vector3(0.0, 0.34, 2.08), 1.54, 0.09, 0.08, 0.14, mat_chrome, true, 12)
	root.add_child(rear_bumper)
	for rostri_x in [-0.35, 0.35]:
		var r_r = create_box(Vector3(0.05, 0.22, 0.09), mat_chrome, Vector3(rostri_x, 0.40, 2.10))
		root.add_child(r_r)
		
	var exhaust_aurelia = create_curved_exhaust_pipe(Vector3(0.42, 0.28, 2.08), 0.038, 0.26, mat_chrome, false)
	exhaust_aurelia.rotation_degrees = Vector3(0.0, -8.0, 0.0)
	root.add_child(exhaust_aurelia)
		
	# --- 3. AERODYNAMIC GREENHOUSE & CONTINUOUS CHROME DRIP RAILS ---
	# Curved panoramic front windshield
	var ws = create_box(Vector3(1.24, 0.38, 0.02), mat_glass, Vector3(0.0, 0.88, -0.65))
	ws.rotation.x = deg_to_rad(-28.0)
	root.add_child(ws)
	
	# Sloping fastback rear window
	var rear_window = create_box(Vector3(1.10, 0.42, 0.02), mat_glass, Vector3(0.0, 0.82, 0.95))
	rear_window.rotation.x = deg_to_rad(34.0)
	root.add_child(rear_window)
	
	# Side quarter glass with delicate chrome frames
	for side in [-1.0, 1.0]:
		var side_glass = create_box(Vector3(0.02, 0.32, 1.35), mat_glass, Vector3(side * 0.65, 0.86, 0.12))
		var chrome_strip = create_box(Vector3(0.015, 0.018, 2.20), mat_chrome, Vector3(side * 0.66, 0.72, 0.20))
		root.add_child(side_glass); root.add_child(chrome_strip)
		
	# --- 4. LUXURIOUS GT COCKPIT: NARDI WOOD STEERING WHEEL & VEGLIA CLUSTER ---
	var dash = create_box(Vector3(1.24, 0.22, 0.12), actual_mat, Vector3(0.0, 0.66, -0.45))
	root.add_child(dash)
	
	# Dual ivory-face Veglia dials (speedometer & rev counter)
	for dial_x in [-0.38, -0.22]:
		var d = create_round_lamp(0.065, mat_headlight, Vector3(dial_x, 0.68, -0.40))
		root.add_child(d)
		
	# Three-spoke Nardi steering wheel with genuine mahogany wood rim
	var sw_col = create_box(Vector3(0.03, 0.03, 0.25), mat_chrome, Vector3(-0.30, 0.62, -0.26))
	sw_col.rotation.x = deg_to_rad(-24.0)
	root.add_child(sw_col)
	var sw_hub = create_round_lamp(0.045, mat_chrome, Vector3(-0.30, 0.70, -0.15))
	sw_hub.rotation.x = deg_to_rad(66.0)
	var sw_rim = create_round_lamp(0.18, mat_wood_steering, Vector3(-0.30, 0.70, -0.14))
	sw_rim.rotation.x = deg_to_rad(66.0)
	root.add_child(sw_hub); root.add_child(sw_rim)
	
	# Lancia grey/blue cloth luxury GT seats
	for side in [-0.34, 0.34]:
		var s_base = create_box(Vector3(0.44, 0.14, 0.48), mat_interior_dark, Vector3(side, 0.40, 0.05))
		var s_back = create_box(Vector3(0.42, 0.50, 0.12), mat_interior_dark, Vector3(side, 0.66, 0.28))
		s_back.rotation.x = deg_to_rad(14.0)
		root.add_child(s_base); root.add_child(s_back)
		
	# --- 5. STERN DETAILS: JEWEL TEARDROP TAILLIGHTS & DUAL EXHAUSTS ---
	for side in [-1.0, 1.0]:
		var tail_fin = create_round_lamp(0.048, mat_tail_red, Vector3(side * 0.65, 0.58, 2.06))
		var amber_turn = create_round_lamp(0.038, mat_blinker_orange, Vector3(side * 0.65, 0.50, 2.06))
		root.add_child(tail_fin); root.add_child(amber_turn)
		
		# Chrome exhaust tips from inboard transaxle
		var exh = create_box(Vector3(0.055, 0.055, 0.22), mat_chrome, Vector3(side * 0.38, 0.25, 2.14))
		root.add_child(exh)
		
	var rear_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.44, 2.10), true)
	root.add_child(rear_plate)
	
	return root

# ==============================================================================
# 12. ALFA ROMEO GIULIA SPRINT GTA CORSA (1965 - Autodelta Carlo Chiti Legend)
# ==============================================================================
# "Gran Turismo Alleggerita": 1570cc Twin Spark DOHC with twin Weber 45 DCOEs,
# Peraluman 25 riveted alloy body (745 kg!), Bertone step-front nose & Quadrifoglio Verde.
static func build_alfa_giulia_gta(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "GiuliaGTARig"
	parent.add_child(root)
	
	var actual_mat = body_mat if body_mat else mat_alfa_red
	
	# --- 1. BERTONE STEP-FRONT COUPE CHASSIS (GIORGETTO GIUGIARO DESIGN) ---
	var lower_body = create_box(Vector3(1.56, 0.36, 4.05), actual_mat, Vector3(0.0, 0.42, 0.0))
	root.add_child(lower_body)
	
	# The legendary "Scalino" (sculpted aerodynamic hood with step-front edge)
	var hood = create_sculpted_hood(Vector3(0.0, 0.56, -1.22), 1.36, 1.22, 1.35, 0.12, 0.0, 0.045, actual_mat, 14, 14)
	root.add_child(hood)
	
	# Step nose flange (il gradino aerodinamico da 1.5 cm)
	var scalino_edge = create_box(Vector3(1.34, 0.04, 0.12), actual_mat, Vector3(0.0, 0.69, -1.86))
	root.add_child(scalino_edge)
	
	# Lightweight coupe roofline (Padiglione ribassato Peraluman)
	var roof_cab = create_box(Vector3(1.28, 0.42, 1.70), actual_mat, Vector3(0.0, 0.88, 0.08))
	root.add_child(roof_cab)
	
	var rear_trunk = create_box(Vector3(1.34, 0.28, 0.95), actual_mat, Vector3(0.0, 0.60, 1.45))
	rear_trunk.rotation.x = deg_to_rad(-5.0)
	root.add_child(rear_trunk)
	
	# --- 2. FRONT GRILLE, HEART SCUDETTO & AUTODELTA TRUMPET INLETS ---
	# Central Alfa triangular heart scudetto
	var scudetto = create_box(Vector3(0.24, 0.32, 0.05), mat_chrome, Vector3(0.0, 0.52, -2.02))
	var scudetto_inner = create_box(Vector3(0.18, 0.26, 0.04), mat_plastic_black, Vector3(0.0, 0.52, -2.04))
	root.add_child(scudetto); root.add_child(scudetto_inner)
	
	# 7-slot black racing mesh with horizontal chrome slats
	for side in [-1.0, 1.0]:
		var grille_mesh = create_box(Vector3(0.45, 0.22, 0.04), mat_plastic_black, Vector3(side * 0.42, 0.52, -2.00))
		root.add_child(grille_mesh)
		for si in range(3):
			var slat = create_box(Vector3(0.42, 0.012, 0.03), mat_chrome, Vector3(side * 0.42, 0.46 + float(si) * 0.06, -2.02))
			root.add_child(slat)
			
	# Outer round 3D parabolic Carello headlights
	for side in [-1.0, 1.0]:
		var hl = create_parabolic_headlamp(Vector3(side * 0.64, 0.54, -2.00), 0.12, 0.07, mat_chrome, mat_headlight)
		root.add_child(hl)
		
		# Autodelta signature: Inner circular cold-air mesh trumpet intake
		var ram_intake = create_parabolic_headlamp(Vector3(side * 0.36, 0.54, -2.01), 0.085, 0.08, mat_steel, mat_plastic_black)
		root.add_child(ram_intake)
		
	# Autodelta Quadrifoglio Verde triangle decal on front fenders
	for side in [-1.0, 1.0]:
		var qv_triangle = create_box(Vector3(0.01, 0.12, 0.12), mat_stratos_lime, Vector3(side * 0.79, 0.64, -1.35))
		qv_triangle.rotation.y = deg_to_rad(side * 90.0)
		root.add_child(qv_triangle)
		
	# Minimal racing split bumperettes
	for side in [-1.0, 1.0]:
		var bump_f = create_box(Vector3(0.24, 0.06, 0.08), mat_steel, Vector3(side * 0.60, 0.34, -2.04))
		var bump_r = create_box(Vector3(0.24, 0.06, 0.08), mat_steel, Vector3(side * 0.60, 0.36, 1.95))
		root.add_child(bump_f); root.add_child(bump_r)
		
	# --- 3. FLARED PERALUMAN WHEEL ARCHES & RACING STANCE ---
	for side in [-1.0, 1.0]:
		var is_left = (side < 0)
		var arch_f = create_curved_wheel_arch(Vector3(side * 0.79, 0.42, -1.25), 0.35, 0.09, 0.05, is_left, actual_mat, 18)
		var arch_r = create_curved_wheel_arch(Vector3(side * 0.79, 0.42, 1.15), 0.35, 0.09, 0.05, is_left, actual_mat, 18)
		root.add_child(arch_f); root.add_child(arch_r)
		
	# Side-exit Autodelta racing exhaust pipe
	var side_exhaust = create_curved_exhaust_pipe(Vector3(-0.76, 0.22, 0.85), 0.042, 0.32, mat_steel, false)
	side_exhaust.rotation_degrees = Vector3(0.0, -45.0, 0.0)
	root.add_child(side_exhaust)
		
	# Sebring bullet aerodynamic wing mirror on driver front fender
	var sebring_mirror = create_round_lamp(0.05, mat_chrome, Vector3(-0.76, 0.72, -0.85))
	sebring_mirror.rotation.y = deg_to_rad(180.0)
	root.add_child(sebring_mirror)
	
	# --- 4. GLASS GREENHOUSE & RACING STRIPES ---
	var ws = create_box(Vector3(1.22, 0.36, 0.02), mat_glass, Vector3(0.0, 0.86, -0.62))
	ws.rotation.x = deg_to_rad(-26.0)
	root.add_child(ws)
	
	var rear_win = create_box(Vector3(1.14, 0.38, 0.02), mat_glass, Vector3(0.0, 0.84, 0.86))
	rear_win.rotation.x = deg_to_rad(30.0)
	root.add_child(rear_win)
	
	# Historic white nose band or hood biscione (Bianco Spino)
	var hood_stripe = create_box(Vector3(0.18, 0.01, 1.30), mat_autodelta_white, Vector3(0.0, 0.75, -1.22))
	hood_stripe.rotation.x = deg_to_rad(-2.5)
	root.add_child(hood_stripe)
	
	# --- 5. STRIPPED AUTODELTA CORSA INTERIOR & ROLLBAR ---
	# Black steel tubular rollbar cage
	var rb_main = create_box(Vector3(1.14, 0.52, 0.04), mat_steel, Vector3(0.0, 0.84, 0.35))
	var rb_brace = create_box(Vector3(0.04, 0.58, 0.65), mat_steel, Vector3(-0.35, 0.76, 0.65))
	rb_brace.rotation.x = deg_to_rad(45.0)
	root.add_child(rb_main); root.add_child(rb_brace)
	
	# Deep-dish racing bucket seat with 4-point harness
	var seat_race = create_box(Vector3(0.42, 0.12, 0.45), mat_interior_dark, Vector3(-0.34, 0.40, 0.05))
	var seat_back = create_box(Vector3(0.40, 0.55, 0.08), mat_interior_dark, Vector3(-0.34, 0.68, 0.25))
	seat_back.rotation.x = deg_to_rad(12.0)
	root.add_child(seat_race); root.add_child(seat_back)
	
	# Three-spoke Hellebore/Momo deep-dish suede wheel
	var sw = create_round_lamp(0.16, mat_leather, Vector3(-0.34, 0.70, -0.22))
	sw.rotation.x = deg_to_rad(66.0)
	root.add_child(sw)
	
	# --- 6. KAMMTURN REAR END & AUTODELTA RACING EXHAUST ---
	var rear_valance = create_box(Vector3(1.48, 0.32, 0.15), actual_mat, Vector3(0.0, 0.46, 1.96))
	root.add_child(rear_valance)
	
	# Compact rectangular rear lights
	for side in [-1.0, 1.0]:
		var r_light = create_box(Vector3(0.16, 0.08, 0.04), mat_tail_red, Vector3(side * 0.58, 0.54, 2.02))
		var r_turn = create_box(Vector3(0.08, 0.08, 0.04), mat_blinker_orange, Vector3(side * 0.46, 0.54, 2.02))
		root.add_child(r_light); root.add_child(r_turn)
		
	# Straight-pipe Autodelta exhaust trumpet poking diagonally out rear left
	var exh_tube = create_box(Vector3(0.065, 0.065, 0.35), mat_chrome, Vector3(-0.46, 0.28, 2.02))
	exh_tube.rotation.y = deg_to_rad(-8.0)
	root.add_child(exh_tube)
	
	var rear_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.46, 2.02), true)
	root.add_child(rear_plate)
	
	return root

# ==============================================================================
# 13. LANCIA STRATOS HF STRADALE (1974 - Bertone Marcello Gandini Rally Wedge)
# ==============================================================================
# The purpose-built WRC world champion: mid-mounted Ferrari Dino 2.4L V6,
# ultra-short 2.18m wheelbase, wraparound helmet-visor windscreen, roof & ducktail spoilers.
static func build_lancia_stratos(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "StratosHFRig"
	parent.add_child(root)
	
	var actual_mat = body_mat if body_mat else mat_stratos_lime
	
	# --- 1. RAZOR-SHARP AERODYNAMIC WEDGE MONOCOQUE NOSE ---
	# Gandini razor-sharp continuous wedge nose with crown camber
	var wedge_nose = create_stratos_aerodynamic_wedge(Vector3(0.0, 0.44, -0.45), 1.35, 1.65, 1.35, 0.14, -0.22, actual_mat)
	root.add_child(wedge_nose)
	
	# Sharp front lower chin spoiler (spoilers rasoterra Bertone)
	var chin_spoiler = create_box(Vector3(1.68, 0.08, 0.32), mat_plastic_black, Vector3(0.0, 0.22, -1.75))
	root.add_child(chin_spoiler)
	
	# Front Curved Wheel Arches
	var arch_fl = create_curved_wheel_arch(Vector3(-0.80, 0.36, -1.05), 0.33, 0.06, 0.05, true, actual_mat, 18)
	var arch_fr = create_curved_wheel_arch(Vector3(0.80, 0.36, -1.05), 0.33, 0.06, 0.05, false, actual_mat, 18)
	root.add_child(arch_fl); root.add_child(arch_fr)
	
	# Pop-up headlights & radiator cooling louvres on front hood
	for side in [-1.0, 1.0]:
		var popup_hl = create_box(Vector3(0.24, 0.04, 0.18), actual_mat, Vector3(side * 0.52, 0.49, -1.50))
		popup_hl.rotation.x = deg_to_rad(-10.0)
		root.add_child(popup_hl)
		
	# Black radiator extraction grille vents on nose center
	var nose_vent = create_box(Vector3(0.58, 0.02, 0.42), mat_plastic_black, Vector3(0.0, 0.50, -1.18))
	nose_vent.rotation.x = deg_to_rad(-10.0)
	root.add_child(nose_vent)
	
	# Quad Carello rally foglamps across the nose with 3D lenses
	for fog_x in [-0.46, -0.16, 0.16, 0.46]:
		var fog = create_round_lamp(0.085, mat_fog_yellow, Vector3(fog_x, 0.36, -1.78))
		root.add_child(fog)
		
	# --- 2. WRAPAROUND HELMET VISOR WINDSHIELD & CABIN ---
	# Semicircular panoramic curved glass cockpit
	var ws_center = create_box(Vector3(1.18, 0.44, 0.02), mat_glass, Vector3(0.0, 0.78, -0.32))
	ws_center.rotation.x = deg_to_rad(-34.0)
	root.add_child(ws_center)
	
	# Curved wraparound quarter glass wrapping into side door windows
	for side in [-1.0, 1.0]:
		var ws_curve = create_box(Vector3(0.32, 0.42, 0.02), mat_glass, Vector3(side * 0.62, 0.78, -0.22))
		ws_curve.rotation.x = deg_to_rad(-34.0)
		ws_curve.rotation.y = deg_to_rad(side * 36.0)
		var door_glass = create_box(Vector3(0.02, 0.32, 0.65), mat_glass, Vector3(side * 0.70, 0.78, 0.15))
		root.add_child(ws_curve); root.add_child(door_glass)
		
	# High roofline with integrated rear roof bridge aerofoil (Alettone sul tetto)
	var roof_panel = create_box(Vector3(1.20, 0.06, 0.85), actual_mat, Vector3(0.0, 0.98, 0.12))
	var roof_wing = create_box(Vector3(1.36, 0.04, 0.18), mat_plastic_black, Vector3(0.0, 1.06, 0.48))
	roof_wing.rotation.x = deg_to_rad(-8.0)
	root.add_child(roof_panel); root.add_child(roof_wing)
	
	# --- 3. MID-ENGINE CLAMSHELL & FERRARI DINO V6 LOUVRED DECK ---
	# Massive wide rear clamshell engine cover
	var rear_clam = create_box(Vector3(1.76, 0.44, 1.45), actual_mat, Vector3(0.0, 0.56, 1.05))
	root.add_child(rear_clam)
	
	# Black horizontal cooling louvres venting the 2.4L Ferrari Dino V6
	for li in range(6):
		var louvre = create_box(Vector3(0.85, 0.02, 0.08), mat_plastic_black, Vector3(0.0, 0.76 - float(li) * 0.04, 0.65 + float(li) * 0.15))
		root.add_child(louvre)
		
	# Integrated ducktail rear spoiler (Becco d'anatra posteriore)
	var ducktail_spoiler = create_box(Vector3(1.72, 0.14, 0.16), actual_mat, Vector3(0.0, 0.76, 1.74))
	ducktail_spoiler.rotation.x = deg_to_rad(25.0)
	root.add_child(ducktail_spoiler)
	
	# Massive muscular flared blister rear wheel arches
	var arch_rl = create_flared_rally_box_arch(Vector3(-0.84, 0.38, 0.95), 0.36, 0.10, 0.12, true, actual_mat, 18)
	var arch_rr = create_flared_rally_box_arch(Vector3(0.84, 0.38, 0.95), 0.36, 0.10, 0.12, false, actual_mat, 18)
	root.add_child(arch_rl); root.add_child(arch_rr)
		
	# --- 4. ICONIC REAR END: ROUND FIAT 850 LIGHTS & ANSA RACING EXHAUST ---
	var rear_transom = create_box(Vector3(1.70, 0.32, 0.12), mat_plastic_black, Vector3(0.0, 0.46, 1.78))
	root.add_child(rear_transom)
	
	# Ansa twin megaphone competition rally exhaust
	var exh_str = create_curved_exhaust_pipe(Vector3(0.0, 0.30, 1.84), 0.068, 0.28, mat_exhaust, true)
	root.add_child(exh_str)
	
	# Circular twin taillamps on each side (Fiat 850 Spider heritage)
	for side in [-1.0, 1.0]:
		var lamp_out = create_round_lamp(0.09, mat_tail_red, Vector3(side * 0.68, 0.52, 1.84))
		var lamp_in = create_round_lamp(0.075, mat_blinker_orange, Vector3(side * 0.48, 0.52, 1.84))
		root.add_child(lamp_out); root.add_child(lamp_in)
		
	# Twin Ansa racing exhaust silencers with quad chrome trumpets
	for side in [-1.0, 1.0]:
		for ex_i in [0, 1]:
			var tip = create_box(Vector3(0.045, 0.045, 0.22), mat_chrome, Vector3(side * 0.18 + float(ex_i) * 0.06 * side, 0.26, 1.88))
			root.add_child(tip)
			
	# Compact Stratos cockpit with Momo steering wheel and bucket seats
	for side in [-0.28, 0.28]:
		var seat = create_box(Vector3(0.42, 0.45, 0.45), mat_interior_dark, Vector3(side, 0.44, 0.05))
		root.add_child(seat)
	var sw = create_round_lamp(0.15, mat_leather, Vector3(-0.28, 0.68, -0.12))
	sw.rotation.x = deg_to_rad(65.0)
	root.add_child(sw)
	
	var rear_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.44, 1.85), true)
	root.add_child(rear_plate)
	
	return root

# ==============================================================================
# 14. FIAT 131 ABARTH RALLY (1976 - 3-Time World Rally Champion Bertone)
# ==============================================================================
# Legendary Lampredi 2.0L 16V DOHC twin-cam, boxy 2-door silhouette with flared box fenders,
# asymmetric bonnet scoop, trunk wing, roof air foil & Olio Fiat / Abarth navy-yellow livery.
static func build_fiat_131_abarth(parent: Node3D, body_mat: Material):
	init_materials()
	for c in parent.get_children():
		c.queue_free()
		
	var root = Node3D.new()
	root.name = "Fiat131AbarthRig"
	parent.add_child(root)
	
	var actual_mat = body_mat if body_mat else mat_abarth_navy
	
	# --- 1. THREE-BOX TOUGH RALLY SALOON BODY ---
	var lower_body = create_box(Vector3(1.64, 0.40, 4.15), actual_mat, Vector3(0.0, 0.42, 0.0))
	root.add_child(lower_body)
	
	# Sculpted aggressive hood with central crown camber
	var hood = create_sculpted_hood(Vector3(0.0, 0.54, -0.55), 1.48, 1.38, 1.40, 0.12, -0.06, 0.045, actual_mat, 10, 10)
	root.add_child(hood)
	
	# Prominent asymmetric offset scoop (Presa d'aria rialzata sul cofano per i Weber/Kugelfischer)
	var hood_scoop = create_box(Vector3(0.36, 0.09, 0.65), mat_abarth_yellow, Vector3(-0.28, 0.77, -1.15))
	hood_scoop.rotation.x = deg_to_rad(6.0)
	var scoop_hole = create_box(Vector3(0.30, 0.06, 0.04), mat_plastic_black, Vector3(-0.28, 0.77, -1.48))
	root.add_child(hood_scoop); root.add_child(scoop_hole)
	
	# Boxy 2-door passenger cabin
	var cabin = create_box(Vector3(1.42, 0.46, 1.75), actual_mat, Vector3(0.0, 0.90, 0.08))
	root.add_child(cabin)
	
	# Notched 3-box boot lid
	var boot = create_box(Vector3(1.46, 0.28, 1.05), actual_mat, Vector3(0.0, 0.62, 1.48))
	root.add_child(boot)
	
	# Roof trailing-edge aerodynamic lip spoiler
	var roof_spoiler = create_box(Vector3(1.40, 0.04, 0.12), mat_plastic_black, Vector3(0.0, 1.14, 0.88))
	roof_spoiler.rotation.x = deg_to_rad(-12.0)
	root.add_child(roof_spoiler)
	
	# Massive high rear boot-mounted wing (Alettone baule Abarth)
	var wing_blade = create_box(Vector3(1.52, 0.05, 0.24), mat_abarth_yellow, Vector3(0.0, 0.86, 1.88))
	wing_blade.rotation.x = deg_to_rad(10.0)
	for wing_mount_x in [-0.55, 0.55]:
		var mount = create_box(Vector3(0.05, 0.16, 0.18), mat_plastic_black, Vector3(wing_mount_x, 0.76, 1.88))
		root.add_child(mount)
	root.add_child(wing_blade)
	
	# --- 2. BOXY NOSE, ABARTH SCORPION GRILLE & FRONT AIR DAM ---
	var grille_panel = create_box(Vector3(1.54, 0.26, 0.08), mat_plastic_black, Vector3(0.0, 0.54, -2.00))
	root.add_child(grille_panel)
	
	# Quad round parabolic Carello rally headlights
	for side in [-1.0, 1.0]:
		var hl_outer = create_parabolic_headlamp(Vector3(side * 0.62, 0.54, -2.03), 0.105, 0.06, mat_chrome, mat_headlight)
		var hl_inner = create_parabolic_headlamp(Vector3(side * 0.38, 0.54, -2.03), 0.095, 0.06, mat_chrome, mat_headlight)
		root.add_child(hl_outer); root.add_child(hl_inner)
		
	# Red & Yellow Abarth Scorpion badge on center grille
	var abarth_badge = create_round_lamp(0.05, mat_abarth_yellow, Vector3(0.0, 0.54, -2.04))
	root.add_child(abarth_badge)
	
	# Deep rally front chin air dam spoiler
	var chin_spoiler = create_box(Vector3(1.68, 0.18, 0.22), mat_plastic_black, Vector3(0.0, 0.24, -1.96))
	root.add_child(chin_spoiler)
	
	# --- 3. BERTONE BOX FLARED FENDERS & EXTRACTION VENTS ---
	var arch_fl = create_flared_rally_box_arch(Vector3(-0.84, 0.38, -1.25), 0.35, 0.08, 0.12, true, actual_mat, 18)
	var arch_fr = create_flared_rally_box_arch(Vector3(0.84, 0.38, -1.25), 0.35, 0.08, 0.12, false, actual_mat, 18)
	var arch_rl = create_flared_rally_box_arch(Vector3(-0.85, 0.38, 1.20), 0.35, 0.08, 0.13, true, actual_mat, 18)
	var arch_rr = create_flared_rally_box_arch(Vector3(0.85, 0.38, 1.20), 0.35, 0.08, 0.13, false, actual_mat, 18)
	root.add_child(arch_fl); root.add_child(arch_fr); root.add_child(arch_rl); root.add_child(arch_rr)
	
	for side in [-1.0, 1.0]:
		# Rear wheel arch cooling extraction slats
		for si in range(3):
			var slat = create_box(Vector3(0.04, 0.02, 0.14), mat_plastic_black, Vector3(side * 0.91, 0.44 + float(si) * 0.06, 0.85))
			root.add_child(slat)
			
	# Abarth competition twin exhaust
	var exh_131 = create_curved_exhaust_pipe(Vector3(-0.52, 0.26, 2.05), 0.065, 0.25, mat_exhaust, true)
	root.add_child(exh_131)
	
	# Olio Fiat yellow side rocker sill stripe
	for side in [-1.0, 1.0]:
		var side_stripe = create_box(Vector3(0.015, 0.08, 2.80), mat_abarth_yellow, Vector3(side * 0.83, 0.30, 0.0))
		root.add_child(side_stripe)
		
	# --- 4. GLASS GREENHOUSE & CORSA ROLLBAR CABIN ---
	var ws = create_box(Vector3(1.36, 0.42, 0.02), mat_glass, Vector3(0.0, 0.88, -0.65))
	ws.rotation.x = deg_to_rad(-24.0)
	root.add_child(ws)
	
	var rear_win = create_box(Vector3(1.32, 0.40, 0.02), mat_glass, Vector3(0.0, 0.86, 0.82))
	rear_win.rotation.x = deg_to_rad(25.0)
	root.add_child(rear_win)
	
	for side in [-1.0, 1.0]:
		var side_glass = create_box(Vector3(0.02, 0.34, 1.40), mat_glass, Vector3(side * 0.72, 0.88, 0.08))
		root.add_child(side_glass)
		
	# Full tubular rally roll cage
	var cage_main = create_box(Vector3(1.28, 0.52, 0.04), mat_steel, Vector3(0.0, 0.86, 0.35))
	root.add_child(cage_main)
	
	# Twin Abarth rally bucket seats
	for side in [-0.34, 0.34]:
		var seat = create_box(Vector3(0.44, 0.50, 0.45), mat_interior_dark, Vector3(side, 0.42, 0.05))
		root.add_child(seat)
	var sw = create_round_lamp(0.16, mat_leather, Vector3(-0.34, 0.70, -0.22))
	sw.rotation.x = deg_to_rad(65.0)
	root.add_child(sw)
	
	# --- 5. REAR FASCIA & RALLY EXHAUST ---
	var rear_panel = create_box(Vector3(1.58, 0.28, 0.06), mat_plastic_black, Vector3(0.0, 0.52, 2.02))
	root.add_child(rear_panel)
	
	# Horizontal rectangular Fiat taillights
	for side in [-1.0, 1.0]:
		var tl_red = create_box(Vector3(0.18, 0.10, 0.03), mat_tail_red, Vector3(side * 0.62, 0.54, 2.05))
		var tl_amb = create_box(Vector3(0.10, 0.10, 0.03), mat_blinker_orange, Vector3(side * 0.47, 0.54, 2.05))
		root.add_child(tl_red); root.add_child(tl_amb)
		
	# Large bore Abarth sports silencer with twin chrome tips
	for tip_x in [-0.42, -0.32]:
		var exh = create_box(Vector3(0.06, 0.06, 0.24), mat_chrome, Vector3(tip_x, 0.26, 2.12))
		root.add_child(exh)
		
	var rear_plate = create_license_plate_italian_vintage(Vector3(0.0, 0.52, 2.06), true)
	root.add_child(rear_plate)
	
	return root

