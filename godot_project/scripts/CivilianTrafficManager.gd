extends Node3D
class_name CivilianTrafficManager

const VehicleCrashSystem = preload("res://scripts/VehicleCrashSystem.gd")
const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")

# ==============================================================================
# VALICO DEI MOTORI '93 - DYNAMIC CIVILIAN TRAFFIC & LIVING MOUNTAIN ROADS
# ==============================================================================
# Authentic civilian traffic populated directly from our vehicle catalog:
# - Fiat 127 Special (1974)
# - Fiat Panda 4x4 Steyr-Puch (1983)
# - Renault 4 GTL (1982)
# - Volkswagen Golf GTI Mk2 (1990)
# - BMW 320i E30 (1988)
# - Mercedes-Benz G-Wagen W460 (1985)
# - Fiat 500 Topolino d'Epoca
# - Ape Piaggio 50 cassonata (mountain payload) & Trattore agricolo
#
# Strict Codice della Strada Rules:
# - Uphill traffic (player direction) drives strictly in the right lane [+half_w * 0.50]
# - Downhill oncoming traffic drives strictly in the left lane [-half_w * 0.50]
# - Zero wrong-way driving (nessun contromano)
# - Zero shoulder driving (nessun transito su ciglio o banchina)
# - Complete crash freeze: vehicles immediately stop after an accident with hazard lights
# - Bidirectional structural crash deformation on both player and civilian cars
# ==============================================================================

signal civilian_collision(relative_speed: float, vehicle_type: String)
signal clean_overtake_completed(vehicle_type: String)

@export var road_generator: Node3D = null
@export var player_vehicle: VehicleController = null
@export var street_rod_manager: Node = null
@export var dashboard_ui: Control = null

# Active Traffic Pool
var active_traffic: Array = []
var max_active_vehicles: int = 7
var spawn_cooldown: float = 0.0

# Scala del 75% richiesta per proporzioni armoniose su carreggiata alpina
const CIVILIAN_SCALE: float = 0.75

# Sound Player for Horn & Impacts
var sfx_player: AudioStreamPlayer3D = null

# Shared Materials
var mat_ape_body: StandardMaterial3D
var mat_tractor_body: StandardMaterial3D
var mat_rubber: StandardMaterial3D
var mat_chrome: StandardMaterial3D
var mat_headlight: StandardMaterial3D
var mat_taillight_off: StandardMaterial3D
var mat_taillight_on: StandardMaterial3D
var mat_amber_indicator: StandardMaterial3D
var mat_timber: StandardMaterial3D

# Catalog vehicle models
const CIVILIAN_CATALOG_MODELS = [
	"panda_4x4",
	"fiat_127",
	"renault_4",
	"golf_gti_1990",
	"bmw_320_e30",
	"gwagen_w460",
	"fiat_topolino"
]

func _ready():
	setup_materials()
	setup_audio()

func setup_audio():
	sfx_player = AudioStreamPlayer3D.new()
	sfx_player.unit_size = 12.0
	sfx_player.max_distance = 65.0
	add_child(sfx_player)

func setup_materials():
	mat_ape_body = StandardMaterial3D.new()
	mat_ape_body.albedo_color = Color(0.18, 0.42, 0.28) # Verde Muschio Piaggio
	mat_ape_body.roughness = 0.55
	
	mat_tractor_body = StandardMaterial3D.new()
	mat_tractor_body.albedo_color = Color(0.72, 0.20, 0.12) # Rosso Same Trattori
	mat_tractor_body.roughness = 0.70
	
	mat_rubber = StandardMaterial3D.new()
	mat_rubber.albedo_color = Color(0.12, 0.12, 0.14)
	mat_rubber.roughness = 0.90
	
	mat_chrome = StandardMaterial3D.new()
	mat_chrome.albedo_color = Color(0.92, 0.94, 0.96)
	mat_chrome.metallic = 0.95
	mat_chrome.roughness = 0.15
	
	mat_headlight = StandardMaterial3D.new()
	mat_headlight.albedo_color = Color(1.0, 0.95, 0.75)
	mat_headlight.emission_enabled = true
	mat_headlight.emission = Color(1.0, 0.95, 0.75)
	mat_headlight.emission_energy_multiplier = 1.4
	
	mat_taillight_off = StandardMaterial3D.new()
	mat_taillight_off.albedo_color = Color(0.55, 0.08, 0.08)
	
	mat_taillight_on = StandardMaterial3D.new()
	mat_taillight_on.albedo_color = Color(1.0, 0.15, 0.10)
	mat_taillight_on.emission_enabled = true
	mat_taillight_on.emission = Color(1.0, 0.15, 0.10)
	mat_taillight_on.emission_energy_multiplier = 1.6
	
	mat_amber_indicator = StandardMaterial3D.new()
	mat_amber_indicator.albedo_color = Color(1.0, 0.65, 0.05)
	mat_amber_indicator.emission_enabled = true
	mat_amber_indicator.emission = Color(1.0, 0.65, 0.05)
	mat_amber_indicator.emission_energy_multiplier = 1.8
	
	mat_timber = StandardMaterial3D.new()
	mat_timber.albedo_color = Color(0.42, 0.30, 0.18)
	mat_timber.roughness = 0.85

func _physics_process(delta: float):
	if not player_vehicle or not road_generator:
		return
		
	var player_z = player_vehicle.global_position.z
	var player_pos = player_vehicle.global_position
	
	# 1. Update and stream civilian vehicles
	update_traffic_movement(player_pos, player_z, delta)
	
	# 2. Despawn vehicles outside the active perimeter (behind > 140m, ahead > 300m)
	clean_distant_traffic(player_z)
	
	# 3. Spawn new upcoming civilian vehicles
	spawn_cooldown -= delta
	if spawn_cooldown <= 0.0 and active_traffic.size() < max_active_vehicles:
		try_spawn_traffic_vehicle(player_z)
		spawn_cooldown = randf_range(3.2, 5.5)

func update_traffic_movement(player_pos: Vector3, player_z: float, delta: float):
	for i in range(active_traffic.size()):
		var car = active_traffic[i]
		if not is_instance_valid(car.node):
			continue
			
		# SE IL VEICOLO È INCIDENTATO (CRASH STOP):
		# Deve fermarsi all'istante, spegnere la trazione, non avanzare più cinematica
		# e accendere le 4 frecce di emergenza (hazard). Zero bulldozer sul giocatore!
		if car.get("is_crashed", false):
			car.speed_kmh = 0.0
			car.target_speed_kmh = 0.0
			car.indicator_state = "hazard"
			update_taillights(car, true)
			update_indicators(car, delta)
			update_headlights(car, delta)
			# Continua a verificare eventuale interazione fisica residua senza avanzare
			check_player_interaction(car, player_pos, delta)
			continue
			
		# Campiona curvatura, pendenza e profilo stradale a Z attuale
		var r_info = road_generator.get_road_info_at(car.current_z)
		if not r_info.get("found", false):
			continue
			
		var half_w = r_info.width * 0.5
		var is_braking = false
		
		# ----------------------------------------------------------------------
		# 1. CAR-FOLLOWING & ANTI-TAMPONAMENTO TRA VEICOLI NPC
		# ----------------------------------------------------------------------
		var min_lead_dist = 999.0
		var lead_car: Dictionary = {}
		for other in active_traffic:
			if other == car:
				continue
			if other.is_oncoming != car.is_oncoming:
				continue
				
			# Verifica veicolo davanti nella stessa direzione di marcia
			var dz_rel = (other.current_z - car.current_z) if not car.is_oncoming else (car.current_z - other.current_z)
			if dz_rel > 0.2 and dz_rel < 55.0:
				if abs(other.lane_offset - car.lane_offset) < 1.4:
					if dz_rel < min_lead_dist:
						min_lead_dist = dz_rel
						lead_car = other
						
		# Controllo decelerazione e frenata di sicurezza
		if not lead_car.is_empty():
			if lead_car.get("is_crashed", false) or min_lead_dist < 8.0:
				# Frenata energica per arrestarsi prima del veicolo fermo o rallentato
				car.speed_kmh = max(0.0, move_toward(car.speed_kmh, lead_car.speed_kmh * 0.40, delta * 32.0))
				is_braking = true
			elif min_lead_dist < 18.0:
				# Decelerazione morbida per agganciare la velocità del veicolo davanti
				car.speed_kmh = move_toward(car.speed_kmh, min(car.speed_kmh, lead_car.speed_kmh), delta * 14.0)
				is_braking = true
			else:
				car.speed_kmh = move_toward(car.speed_kmh, car.target_speed_kmh, delta * 7.5)
		else:
			car.speed_kmh = move_toward(car.speed_kmh, car.target_speed_kmh, delta * 8.0)
			
		# ----------------------------------------------------------------------
		# 2. RIGOROSO RISPETTO DEL CODICE DELLA STRADA (TUTTI A DESTRA!)
		# ----------------------------------------------------------------------
		# In Italia si tiene la destra!
		# Con il veicolo orientato verso monte (+Z, rotazione PI), la corsia di DESTRA
		# corrisponde alla coordinata X negativa (-X): offset = -half_w * 0.50.
		# La corsia di sinistra (+X) resta completamente libera per i sorpassi del giocatore.
		var base_offset = -half_w * 0.50
		if car.get("is_slow_vehicle", false):
			# Veicolo lento (Ape / Trattore): tiene il margine destro della corsia
			base_offset = -half_w * 0.56
			
		car.target_lane_offset = base_offset
		car.indicator_state = "none"
		
		if abs(r_info.angle) > 0.35:
			car.speed_kmh = min(car.speed_kmh, car.target_speed_kmh * 0.78)
			is_braking = true
			
		# CLAMPING MATEMATICO RIGIDO SULLA CORSIA DI DESTRA (valori negativi):
		# Impossibile invadere la mezzeria contromana a sinistra (> -half_w * 0.35)
		# Impossibile salire sul ciglio/banchina destra (< -half_w * 0.65)
		car.target_lane_offset = clamp(car.target_lane_offset, -half_w * 0.65, -half_w * 0.35)
		car.lane_offset = move_toward(car.lane_offset, car.target_lane_offset, delta * 2.5)
		car.lane_offset = clamp(car.lane_offset, -half_w * 0.65, -half_w * 0.35)
			
		# ----------------------------------------------------------------------
		# 3. CINEMATICA E POSIZIONAMENTO 3D PERFETTO SULLA CARREGGIATA
		# ----------------------------------------------------------------------
		var speed_ms = (car.speed_kmh / 3.6)
		# Tutti i veicoli procedono in marcia avanti verso monte (+Z)
		car.current_z += speed_ms * delta
		
		# world_x = r_info.x + car.lane_offset garantisce che l'auto rimanga millimetricamente in corsia.
		var world_x = r_info.x + car.lane_offset
		var world_y = r_info.y + 0.05
		var world_z = car.current_z
		
		# Calcolo pendenza longitudinale per aderenza ruote
		var dz_probe = 2.0
		var y_ahead = road_generator.calculate_road_elevation(car.current_z + dz_probe)
		var y_behind = road_generator.calculate_road_elevation(car.current_z - dz_probe)
		var slope_pitch = atan2(y_ahead - y_behind, dz_probe * 2.0)
		
		car.node.global_position = Vector3(world_x, world_y, world_z)
		# Orientamento marcia in avanti conforme al Codice della Strada:
		# Il modello ha il muso a -Z locale e la coda a +Z locale.
		# Chi sale verso monte (+Z mondo) ha rotazione Y = angle + PI (muso in avanti verso la salita)
		car.node.rotation.y = r_info.angle + PI
		car.node.rotation.x = slope_pitch
		
		# Aggiornamento luci, indicatori e fari
		update_taillights(car, is_braking)
		update_indicators(car, delta)
		update_headlights(car, delta)
		
		# Telemetria interazione e collisione con il giocatore
		check_player_interaction(car, player_pos, delta)

func check_player_interaction(car: Dictionary, player_pos: Vector3, _delta: float):
	var traffic_pos = car.node.global_position
	var dx = player_pos.x - traffic_pos.x
	var dy = player_pos.y - traffic_pos.y
	var dz = player_pos.z - traffic_pos.z
	var dist_sq = dx * dx + dz * dz
	
	# 1. COLLISION DETECTION: Physical Body Overlap (scalata per veicoli al 75%)
	var col_radius_sq = 2.5 # ~1.58m radius
	if dist_sq < col_radius_sq and abs(dy) < 1.3:
		# INCIDENTE STRADALE: L'auto si ferma immediatamente!
		car.is_crashed = true
		car.speed_kmh = 0.0
		car.target_speed_kmh = 0.0
		car.indicator_state = "hazard"
		
		if not car.has_collided:
			car.has_collided = true
			var p_speed = player_vehicle.current_speed_kmh if player_vehicle else 50.0
			var t_speed = car.speed_kmh
			var rel_speed = max(18.0, abs(p_speed - t_speed))
			
			trigger_collision_impact(car, rel_speed)
	else:
		car.has_collided = false
		
	# 2. CLEAN OVERTAKE DETECTION (Sorpasso Pulito a sinistra):
	if not car.overtaken and not car.get("is_crashed", false) and player_vehicle:
		if player_pos.z > car.current_z + 3.2 and (player_pos.z - car.current_z) < 14.0:
			if abs(dx) > 1.0 and abs(dx) < 3.6 and player_vehicle.current_speed_kmh > 45.0:
				car.overtaken = true
				trigger_clean_overtake(car)

func trigger_collision_impact(car: Dictionary, rel_speed: float):
	if not player_vehicle or not car.node: return
	
	# Arresto immediato dell'auto civile (zero bulldozer)
	car.is_crashed = true
	car.speed_kmh = 0.0
	car.target_speed_kmh = 0.0
	car.indicator_state = "hazard"
	
	var m1 = player_vehicle.mass if player_vehicle.mass > 0.0 else 710.0
	var m2 = 780.0
	match car.type:
		"ape_piaggio": m2 = 280.0
		"fiat_topolino", "fiat_500": m2 = 540.0
		"fiat_127": m2 = 710.0
		"panda_4x4": m2 = 790.0
		"renault_4": m2 = 720.0
		"golf_gti_1990": m2 = 960.0
		"bmw_320_e30": m2 = 1120.0
		"gwagen_w460": m2 = 1950.0
		"trattore": m2 = 2400.0
		
	var p_pos = player_vehicle.global_position
	var t_pos = car.node.global_position
	var contact_pt = (p_pos + t_pos) * 0.5
	var normal = (p_pos - t_pos).normalized()
	if normal.length_squared() < 0.01:
		normal = Vector3(0, 0, 1)
		
	var v1 = player_vehicle.linear_velocity
	var v2 = Vector3.ZERO # L'auto civile si arresta all'impatto
	
	# Calcolo dinamico dell'impulso anelastico
	var impact_res = VehicleCrashSystem.calculate_impact_impulse(
		m1, v1,
		m2, v2,
		normal,
		contact_pt,
		p_pos,
		0.10, # Urti anelastici (energia assorbita dalla carrozzeria)
		0.55
	)
	
	if impact_res.is_impact:
		var impulse = impact_res.impulse
		
		# 1. Conservazione quantità di moto applicata al giocatore
		player_vehicle.linear_velocity -= impulse / m1
		var yaw_spin = clamp(impact_res.torque1.y / 720.0, -3.2, 3.2)
		player_vehicle.angular_velocity.y += yaw_spin
		
		# 2. Deformazione plastica reale per ENTRAMBE le auto!
		VehicleCrashSystem.apply_structural_deformation(player_vehicle, contact_pt, rel_speed, normal)
		VehicleCrashSystem.apply_structural_deformation(car.node, contact_pt, rel_speed, -normal)
		
		# 3. Audio incidente metallico
		if player_vehicle.audio_engine and player_vehicle.audio_engine.has_method("play_impact_thud"):
			player_vehicle.audio_engine.play_impact_thud()
			
		# 4. Danno proporzionale nel garage Street Rod
		if street_rod_manager:
			var dmg_body = clamp(rel_speed * 0.0035, 0.08, 0.40)
			var dmg_eng = clamp(rel_speed * 0.0018, 0.03, 0.25)
			
			var cur_car = street_rod_manager.get_active_car()
			if not cur_car.is_empty():
				cur_car["body_health"] = max(0.10, cur_car.get("body_health", 0.85) - dmg_body)
				cur_car["engine_health"] = max(0.15, cur_car.get("engine_health", 0.90) - dmg_eng)
				street_rod_manager.reputation = max(10, street_rod_manager.reputation - int(rel_speed * 0.35))
				
				var msg = "Incidente contro %s!\nCarrozzeria deformata -%d%% | -%d Rispetto" % [
					car.type_name,
					int(dmg_body * 100),
					int(rel_speed * 0.35)
				]
				street_rod_manager.post_notification("💥 INCIDENTE STRADALE!", msg, "💥", "error")
				street_rod_manager.broadcast_career()
				
	emit_signal("civilian_collision", rel_speed, car.type_name)

func trigger_clean_overtake(car: Dictionary):
	if street_rod_manager:
		var bonus_rep = 15
		street_rod_manager.reputation += bonus_rep
		street_rod_manager.post_notification(
			"SORPASSO PULITO! ⚡",
			"Hai superato %s a tutta velocità! (+%d Rispetto)" % [car.type_name, bonus_rep],
			"🏎️",
			"wrench"
		)
	emit_signal("clean_overtake_completed", car.type_name)

func update_taillights(car: Dictionary, is_braking: bool):
	if car.has("tl_mesh_l") and car.has("tl_mesh_r"):
		var mat = mat_taillight_on if is_braking else mat_taillight_off
		if is_instance_valid(car.tl_mesh_l): car.tl_mesh_l.material_override = mat
		if is_instance_valid(car.tl_mesh_r): car.tl_mesh_r.material_override = mat

func update_indicators(car: Dictionary, delta: float):
	car.indicator_timer += delta * 4.5
	var flash_on = fmod(car.indicator_timer, 1.0) < 0.5
	
	var left_vis = false
	var right_vis = false
	
	match car.get("indicator_state", "none"):
		"left":
			left_vis = flash_on
		"right":
			right_vis = flash_on
		"hazard":
			left_vis = flash_on
			right_vis = flash_on
			
	if car.has("ind_mesh_l") and is_instance_valid(car.ind_mesh_l):
		car.ind_mesh_l.visible = left_vis
	if car.has("ind_mesh_r") and is_instance_valid(car.ind_mesh_r):
		car.ind_mesh_r.visible = right_vis

func update_headlights(car: Dictionary, delta: float):
	if not car.has("headlight") or not is_instance_valid(car.headlight):
		return
		
	if car.get("emergency_timer", 0.0) > 0.0:
		car.emergency_timer -= delta
		var flash = fmod(car.emergency_timer * 8.0, 1.0) < 0.5
		car.headlight.light_energy = 4.8 if flash else 0.4
	else:
		car.headlight.light_energy = 2.4

func clean_distant_traffic(player_z: float):
	for i in range(active_traffic.size() - 1, -1, -1):
		var car = active_traffic[i]
		if car.current_z < player_z - 130.0 or car.current_z > player_z + 320.0:
			if is_instance_valid(car.node):
				car.node.queue_free()
			active_traffic.remove_at(i)

func try_spawn_traffic_vehicle(player_z: float):
	var roll = randf()
	var v_type = "panda_4x4"
	var archetype = "commuter"
	# RIGOROSO RISPETTO DEL CODICE DELLA STRADA (Art. 143):
	# Tutti i veicoli civili circolano rigorosamente nella corsia di destra (salita verso monte).
	# La corsia di sinistra resta completamente sgombra per consentire i sorpassi al giocatore.
	var is_oncoming = false
	var speed = 54.0
	
	# Selezione autentica dal catalogo o veicolo rurale
	if roll < 0.12:
		v_type = "ape_piaggio"
		archetype = "slow_worker"
		speed = randf_range(30.0, 36.0)
	elif roll < 0.22:
		v_type = "trattore"
		archetype = "slow_worker"
		speed = randf_range(20.0, 26.0)
	else:
		# Auto scelta dal catalogo veicoli
		v_type = CIVILIAN_CATALOG_MODELS.pick_random()
		archetype = "commuter"
		speed = randf_range(50.0, 68.0)
		
	# POSIZIONAMENTO SPAWN: Sempre davanti al giocatore nella corsia di destra
	var spawn_z = player_z + randf_range(75.0, 180.0)
		
	# Distanza minima di sicurezza per evitare auto accodate
	for existing in active_traffic:
		if abs(existing.current_z - spawn_z) < 45.0:
			return
			
	var r_info = road_generator.get_road_info_at(spawn_z)
	if not r_info.get("found", false):
		return
		
	var half_w = r_info.width * 0.5
	var initial_offset = -half_w * 0.50  # Corsia destra rigorosa (-X con rotazione PI)
	if archetype == "slow_worker":
		initial_offset = -half_w * 0.56  # Veicolo lento (Ape / Trattore): tiene il margine destro
			
	var car_node = create_traffic_model(v_type, is_oncoming)
	add_child(car_node)
	
	# Inizializza istantaneamente posizione 3D e orientamento di marcia allo spawn
	var world_x = r_info.x + initial_offset
	var world_y = r_info.y + 0.05
	car_node.global_position = Vector3(world_x, world_y, spawn_z)
	car_node.rotation.y = r_info.angle + PI
	
	var car_data = {
		"node": car_node,
		"type": v_type,
		"archetype": archetype,
		"type_name": get_type_display_name(v_type),
		"current_z": spawn_z,
		"speed_kmh": speed,
		"target_speed_kmh": speed,
		"is_oncoming": is_oncoming,
		"is_slow_vehicle": (archetype == "slow_worker"),
		"lane_offset": initial_offset,
		"target_lane_offset": initial_offset,
		"pulling_aside": false,
		"indicator_timer": randf_range(0.0, 1.0),
		"indicator_state": "none",
		"emergency_timer": 0.0,
		"ind_mesh_l": car_node.find_child("IndicatorL", true, false),
		"ind_mesh_r": car_node.find_child("IndicatorR", true, false),
		"tl_mesh_l": car_node.find_child("TaillightL", true, false),
		"tl_mesh_r": car_node.find_child("TaillightR", true, false),
		"headlight": car_node.find_child("TrafficHeadlight", true, false),
		"has_collided": false,
		"is_crashed": false,
		"overtaken": false
	}
	
	active_traffic.append(car_data)

func get_type_display_name(v_type: String) -> String:
	match v_type:
		"fiat_127": return "Fiat 127 Special (1974)"
		"panda_4x4": return "Fiat Panda 4x4 Steyr-Puch"
		"renault_4": return "Renault 4 GTL"
		"golf_gti_1990": return "Volkswagen Golf GTI Mk2"
		"bmw_320_e30": return "BMW 320i E30"
		"gwagen_w460": return "Mercedes-Benz G-Wagen W460"
		"fiat_topolino", "fiat_500": return "Fiat 500 Topolino d'Epoca"
		"ape_piaggio": return "Ape Piaggio 50"
		"trattore": return "Trattore Agricolo con Fieno"
	return "Veicolo Civile d'Epoca"

func get_random_vintage_color(v_type: String) -> Color:
	var vintage_palette = [
		Color(0.12, 0.32, 0.65), # Blu Notte Metallizzato
		Color(0.82, 0.22, 0.15), # Rosso Corsa
		Color(0.18, 0.42, 0.25), # Verde Muschio
		Color(0.92, 0.82, 0.28), # Giallo Ginestra
		Color(0.90, 0.90, 0.92), # Bianco Neve
		Color(0.48, 0.50, 0.52), # Grigio Metallizzato
		Color(0.72, 0.60, 0.44), # Sabbia Alpina
		Color(0.24, 0.52, 0.72)  # Celeste Polvere
	]
	return vintage_palette.pick_random()

# ==============================================================================
# PROCEDURAL 3D MODELS FOR CIVILIAN VEHICLES (BUILT FROM VEHICLE CATALOG)
# ==============================================================================

func create_traffic_model(v_type: String, is_oncoming: bool) -> Node3D:
	var root = AnimatableBody3D.new()
	root.sync_to_physics = false
	
	var model_root = Node3D.new()
	model_root.name = "ModelRoot"
	# Scala rigorosa al 75% per armonia visiva diorama e proporzione con la carreggiata
	model_root.scale = Vector3(CIVILIAN_SCALE, CIVILIAN_SCALE, CIVILIAN_SCALE)
	root.add_child(model_root)
	
	# Scelta colore carrozzeria armonioso d'epoca
	var body_color = get_random_vintage_color(v_type)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.roughness = 0.35
	body_mat.clearcoat_enabled = true
	body_mat.clearcoat = 0.60
	
	VehicleModelBuilder.init_materials()
	
	var box_size = Vector3(1.50, 0.85, 3.50)
	var col_y = 0.55
	
	match v_type:
		"fiat_127":
			VehicleModelBuilder.build_fiat_127(model_root, body_mat)
			box_size = Vector3(1.44, 0.76, 3.44)
			col_y = 0.54
		"panda_4x4":
			VehicleModelBuilder.build_panda_4x4(model_root, body_mat)
			box_size = Vector3(1.48, 0.82, 3.40)
			col_y = 0.58
		"renault_4":
			VehicleModelBuilder.build_renault_4(model_root, body_mat)
			box_size = Vector3(1.48, 0.85, 3.62)
			col_y = 0.59
		"golf_gti_1990":
			VehicleModelBuilder.build_golf_gti_1990(model_root, body_mat)
			box_size = Vector3(1.64, 0.78, 3.86)
			col_y = 0.54
		"bmw_320_e30":
			VehicleModelBuilder.build_bmw_320_e30(model_root, body_mat)
			box_size = Vector3(1.65, 0.74, 4.25)
			col_y = 0.52
		"gwagen_w460":
			VehicleModelBuilder.build_gwagen_w460(model_root, body_mat)
			box_size = Vector3(1.82, 1.15, 4.15)
			col_y = 0.76
		"fiat_topolino", "fiat_500":
			VehicleModelBuilder.build_fiat_topolino(model_root, body_mat)
			box_size = Vector3(1.36, 0.78, 3.25)
			col_y = 0.52
		"ape_piaggio":
			build_ape_mesh(model_root)
			box_size = Vector3(1.35, 1.45, 2.70)
			col_y = 0.72
		"trattore":
			build_tractor_mesh(model_root)
			box_size = Vector3(1.80, 1.95, 4.20)
			col_y = 0.95
		_:
			VehicleModelBuilder.build_fiat_127(model_root, body_mat)
			box_size = Vector3(1.44, 0.76, 3.44)
			col_y = 0.54
			
	# Solida collision box fisica proporzionata alla vettura scalata al 75%
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var box = BoxShape3D.new()
	box.size = box_size * CIVILIAN_SCALE
	col.shape = box
	col.position.y = col_y * CIVILIAN_SCALE
	root.add_child(col)
	
	# Proiettore fari anteriori direzionale
	add_traffic_headlights(root, is_oncoming)
	
	# Indicatori di direzione e luci di coda proporzionati al 75%
	if not root.find_child("TaillightL", true, false):
		add_taillights(root, Vector3(box_size.x * 0.42, 0.62, box_size.z * 0.48) * CIVILIAN_SCALE, Vector3(-box_size.x * 0.42, 0.62, box_size.z * 0.48) * CIVILIAN_SCALE)
	if not root.find_child("IndicatorL", true, false):
		add_indicators(root, Vector3(box_size.x * 0.46, 0.65, box_size.z * 0.48) * CIVILIAN_SCALE, Vector3(-box_size.x * 0.46, 0.65, box_size.z * 0.48) * CIVILIAN_SCALE)
		
	return root

func build_ape_mesh(root: Node3D):
	# 1. Cabina Ape
	var cab = MeshInstance3D.new()
	cab.name = "BodyCab"
	var cb = BoxMesh.new()
	cb.size = Vector3(1.10, 1.15, 1.05)
	cab.mesh = cb
	cab.material_override = mat_ape_body
	cab.position = Vector3(0.0, 0.85, -0.45)
	root.add_child(cab)
	
	# Faro centrale anteriore
	var head = MeshInstance3D.new()
	head.name = "HeadlightCenter"
	var hm = CylinderMesh.new()
	hm.top_radius = 0.12; hm.bottom_radius = 0.12; hm.height = 0.08
	head.mesh = hm
	head.material_override = mat_headlight
	head.rotation.x = deg_to_rad(90.0)
	head.position = Vector3(0.0, 0.72, -1.00)
	root.add_child(head)
	
	# 2. Cassone di legno con carico legna
	var bed = MeshInstance3D.new()
	bed.name = "Flatbed"
	var bb = BoxMesh.new()
	bb.size = Vector3(1.25, 0.38, 1.45)
	bed.mesh = bb
	bed.material_override = mat_timber
	bed.position = Vector3(0.0, 0.60, 0.60)
	root.add_child(bed)
	
	for lx in [-0.35, 0.0, 0.35]:
		for ly in [0.0, 0.16]:
			var log = MeshInstance3D.new()
			var lc = CylinderMesh.new()
			lc.top_radius = 0.09; lc.bottom_radius = 0.09; lc.height = 1.30
			log.mesh = lc
			log.material_override = mat_timber
			log.rotation.x = deg_to_rad(90.0)
			log.position = Vector3(lx, 0.80 + ly, 0.60)
			root.add_child(log)
			
	# 3 Ruote
	add_wheel(root, Vector3(0.0, 0.22, -0.80), 0.22, 0.12)
	add_wheel(root, Vector3(-0.58, 0.24, 0.62), 0.24, 0.14)
	add_wheel(root, Vector3(0.58, 0.24, 0.62), 0.24, 0.14)
	
	add_taillights(root, Vector3(0.52, 0.60, 1.34), Vector3(-0.52, 0.60, 1.34))
	add_indicators(root, Vector3(0.58, 0.68, 1.34), Vector3(-0.58, 0.68, 1.34))

func build_tractor_mesh(root: Node3D):
	# Cofano motore rosso Same
	var hood = MeshInstance3D.new()
	hood.name = "TractorHood"
	var hb = BoxMesh.new(); hb.size = Vector3(0.85, 0.85, 1.65)
	hood.mesh = hb; hood.material_override = mat_tractor_body
	hood.position = Vector3(0.0, 0.85, -0.65)
	root.add_child(hood)
	
	# Telaio cabina alta
	var cab = MeshInstance3D.new()
	cab.name = "TractorCab"
	var cb = BoxMesh.new(); cb.size = Vector3(1.05, 1.25, 1.05)
	cab.mesh = cb; cab.material_override = mat_tractor_body
	cab.position = Vector3(0.0, 1.55, 0.55)
	root.add_child(cab)
	
	# Canna di scarico verticale
	var ex = MeshInstance3D.new()
	ex.name = "ExhaustPipe"
	var ec = CylinderMesh.new(); ec.top_radius = 0.05; ec.bottom_radius = 0.05; ec.height = 1.10
	ex.mesh = ec; ex.material_override = mat_chrome
	ex.position = Vector3(0.35, 1.45, -1.15)
	root.add_child(ex)
	
	# Ruote (piccole anteriori, giganti posteriori)
	add_wheel(root, Vector3(-0.55, 0.32, -1.15), 0.32, 0.18)
	add_wheel(root, Vector3(0.55, 0.32, -1.15), 0.32, 0.18)
	add_wheel(root, Vector3(-0.72, 0.65, 0.65), 0.65, 0.32)
	add_wheel(root, Vector3(0.72, 0.65, 0.65), 0.65, 0.32)
	
	add_taillights(root, Vector3(0.55, 0.95, 1.12), Vector3(-0.55, 0.95, 1.12))
	add_indicators(root, Vector3(0.62, 1.05, 1.12), Vector3(-0.62, 1.05, 1.12))

func add_wheel(parent: Node3D, pos: Vector3, radius: float, width: float):
	var w = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = radius; cyl.bottom_radius = radius; cyl.height = width
	w.mesh = cyl; w.material_override = mat_rubber
	w.rotation.z = deg_to_rad(90.0)
	w.position = pos
	parent.add_child(w)

func add_taillights(parent: Node3D, pos_r: Vector3, pos_l: Vector3):
	var tr = MeshInstance3D.new()
	tr.name = "TaillightR"
	var box = BoxMesh.new(); box.size = Vector3(0.14, 0.10, 0.05) * CIVILIAN_SCALE
	tr.mesh = box; tr.material_override = mat_taillight_off
	tr.position = pos_r
	parent.add_child(tr)
	
	var tl = MeshInstance3D.new()
	tl.name = "TaillightL"
	tl.mesh = box; tl.material_override = mat_taillight_off
	tl.position = pos_l
	parent.add_child(tl)

func add_indicators(parent: Node3D, pos_r: Vector3, pos_l: Vector3):
	var ind_r = MeshInstance3D.new()
	ind_r.name = "IndicatorR"
	var box = BoxMesh.new(); box.size = Vector3(0.12, 0.08, 0.05) * CIVILIAN_SCALE
	ind_r.mesh = box; ind_r.material_override = mat_amber_indicator
	ind_r.position = pos_r
	ind_r.visible = false
	parent.add_child(ind_r)
	
	var ind_l = MeshInstance3D.new()
	ind_l.name = "IndicatorL"
	ind_l.mesh = box; ind_l.material_override = mat_amber_indicator
	ind_l.position = pos_l
	ind_l.visible = false
	parent.add_child(ind_l)

func add_traffic_headlights(parent: Node3D, _is_oncoming: bool):
	var light = SpotLight3D.new()
	light.name = "TrafficHeadlight"
	light.light_color = Color(1.0, 0.96, 0.88)
	light.light_energy = 2.4
	light.spot_range = 38.0 * CIVILIAN_SCALE
	light.spot_angle = 32.0
	light.position = Vector3(0.0, 0.65 * CIVILIAN_SCALE, -1.55 * CIVILIAN_SCALE)
	# Proiettore puntato in avanti lungo l'asse del muso (-Z locale)
	light.rotation.y = 0.0
	parent.add_child(light)
