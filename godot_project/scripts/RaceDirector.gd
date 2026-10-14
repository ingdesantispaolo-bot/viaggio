extends Node3D
class_name RaceDirector

# ==============================================================================
# VALICO DEI MOTORI '93 - 3D RACE DIRECTOR & DRAG STRIP SYSTEM (Godot 4)
# ==============================================================================
# Coordinates physical 3D side-by-side racing:
# 1. 3D Start Line Gantry with overhead banner, checkered boxes & Christmas Tree
# 2. Physical 3D Rival Vehicle placed on the starting grid beside player
# 3. 3D Finish Line Gantry at +400m with checkered flags, laser beam & strobes
# 4. Realistic countdown sequence, AI rival driving physics & gear shifts
# 5. Clean, non-intrusive racing HUD (100% road visibility, zero screen blocking)
# 6. Automatic resolution with StreetRodManager (Lire bets, pink slips, career)
# ==============================================================================

signal race_started(rival_id: String)
signal race_finished(result: Dictionary)

enum RaceState {
	IDLE,
	STAGING,
	COUNTDOWN,
	RACING,
	FINISHED
}

var current_state: RaceState = RaceState.IDLE

# Node References
var road_generator: Node3D = null
var player_vehicle: VehicleController = null
var rival_vehicle: VehicleController = null
var street_rod_manager: Node = null
var camera_controller: CameraController = null
var street_rod_ui: Node = null

# Race Staging & Geometry
var race_start_z: float = 30.0
var race_finish_z: float = 430.0 # 400m drag
var race_road_center_x: float = 0.0
var race_road_y: float = 0.0

var start_gantry_node: Node3D = null
var finish_gantry_node: Node3D = null

# 3D Christmas Tree Lights
var tree_lights_mesh: Array = []
var tree_omni_lights: Array = []

# Finish Line Strobes
var finish_strobes: Array = []
var finish_strobe_timer: float = 0.0

# Race Timing & State
var rival_id: String = "gino"
var is_pink_slip: bool = false
var countdown_timer: float = 0.0
var race_time_elapsed: float = 0.0
var player_reaction_time: float = 0.0
var player_finish_time: float = 0.0
var rival_finish_time: float = 0.0
var player_trap_speed: float = 0.0
var rival_trap_speed: float = 0.0
var player_crossed: bool = false
var rival_crossed: bool = false
var rival_reaction_delay: float = 0.28
var rival_launched: bool = false

# Standalone Race State & Exploration Preservation
var pre_race_transform: Transform3D = Transform3D()
var pre_race_linear_velocity: Vector3 = Vector3.ZERO
var pre_race_angular_velocity: Vector3 = Vector3.ZERO
var has_pre_race_state: bool = false
var race_source_tab: int = 3
var auto_return_timer: float = -1.0

# Minimal Non-Blocking 3D Racing HUD
var hud_root: Control = null
var race_hud_layer: CanvasLayer = null
var hud_banner_panel: PanelContainer = null
var hud_banner_label: Label = null
var hud_countdown_label: Label = null
var hud_result_card: PanelContainer = null
var hud_auto_return_label: Label = null

# Audio stream players
var countdown_beep_player: AudioStreamPlayer = null
var go_chime_player: AudioStreamPlayer = null
var finish_fanfare_player: AudioStreamPlayer = null

func _ready():
	setup_audio_players()
	setup_race_hud()

func setup_audio_players():
	# 1. Beep countdown (880 Hz)
	var beep_wav = create_beep_stream(880.0, 0.12)
	countdown_beep_player = AudioStreamPlayer.new()
	countdown_beep_player.stream = beep_wav
	countdown_beep_player.volume_db = -2.0
	add_child(countdown_beep_player)
	
	# 2. Go Chime (1760 Hz brillante)
	var go_wav = create_beep_stream(1760.0, 0.35)
	go_chime_player = AudioStreamPlayer.new()
	go_chime_player.stream = go_wav
	go_chime_player.volume_db = 0.0
	add_child(go_chime_player)
	
	# 3. Finish Fanfare (Accordo trionfale)
	var fanfare_wav = create_fanfare_stream()
	finish_fanfare_player = AudioStreamPlayer.new()
	finish_fanfare_player.stream = fanfare_wav
	finish_fanfare_player.volume_db = -1.0
	add_child(finish_fanfare_player)

func create_beep_stream(freq: float, duration: float) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	var num_samples = int(22050 * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)
	for i in range(num_samples):
		var t = float(i) / 22050.0
		var env = 1.0 - (t / duration)
		var s = sin(t * freq * TAU) * env * 0.75
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
	wav.data = bytes
	return wav

func create_fanfare_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	var duration = 0.95
	var num_samples = int(22050 * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)
	for i in range(num_samples):
		var t = float(i) / 22050.0
		var env = exp(-t * 2.8)
		var s = (sin(t * 523.25 * TAU) * 0.35 + sin(t * 659.25 * TAU) * 0.30 + sin(t * 783.99 * TAU) * 0.30 + sin(t * 1046.50 * TAU) * 0.20) * env
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
	wav.data = bytes
	return wav

# ==============================================================================
# MINIMAL NON-BLOCKING 3D RACING HUD
# ==============================================================================
func setup_race_hud():
	race_hud_layer = CanvasLayer.new()
	race_hud_layer.layer = 5
	add_child(race_hud_layer)
	
	hud_root = Control.new()
	hud_root.name = "HudRoot"
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	race_hud_layer.add_child(hud_root)
	
	# 1. Top Compact Telemetry Bar
	hud_banner_panel = PanelContainer.new()
	hud_banner_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_banner_panel.offset_left = 60
	hud_banner_panel.offset_right = -60
	hud_banner_panel.offset_top = 10
	hud_banner_panel.offset_bottom = 44
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.06, 0.10, 0.88)
	sb.border_color = Color(0.95, 0.80, 0.15, 0.95)
	sb.border_width_bottom = 2
	sb.set_corner_radius_all(4)
	hud_banner_panel.add_theme_stylebox_override("panel", sb)
	hud_root.add_child(hud_banner_panel)
	
	hud_banner_label = Label.new()
	hud_banner_label.text = "🏁 RETTIFILO DEL LAGO 400M | PRONTI ALLA PARTENZA"
	hud_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_banner_label.add_theme_font_size_override("font_size", 12)
	hud_banner_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.30))
	hud_banner_panel.add_child(hud_banner_label)
	hud_banner_panel.visible = false
	
	# 2. Center Countdown Flash Text
	hud_countdown_label = Label.new()
	hud_countdown_label.set_anchors_preset(Control.PRESET_CENTER)
	hud_countdown_label.offset_left = -200
	hud_countdown_label.offset_right = 200
	hud_countdown_label.offset_top = -140
	hud_countdown_label.offset_bottom = -60
	hud_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_countdown_label.add_theme_font_size_override("font_size", 38)
	hud_countdown_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.10))
	hud_root.add_child(hud_countdown_label)
	hud_countdown_label.visible = false
	
	# 3. Post-Race Victory/Defeat Compact Result Card
	build_result_card()

func build_result_card():
	hud_result_card = PanelContainer.new()
	hud_result_card.set_anchors_preset(Control.PRESET_CENTER)
	hud_result_card.offset_left = -260
	hud_result_card.offset_right = 260
	hud_result_card.offset_top = -70
	hud_result_card.offset_bottom = 140
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	sb.border_color = Color(0.0, 0.50, 0.90)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(8)
	sb.shadow_size = 20
	sb.shadow_color = Color(0, 0, 0, 0.85)
	hud_result_card.add_theme_stylebox_override("panel", sb)
	hud_root.add_child(hud_result_card)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	hud_result_card.add_child(vbox)
	
	var head = Label.new()
	head.name = "ResultTitle"
	head.text = "🏆 VITTORIA AL TRAGUARDO!"
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 16)
	head.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	vbox.add_child(head)
	
	var details = Label.new()
	details.name = "ResultDetails"
	details.text = "Tu: 15.62s @ 142 km/h | Gino: 15.85s @ 138 km/h\nPremio Incassato: +L. 500.000 | Reputazione +30"
	details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details.add_theme_font_size_override("font_size", 11)
	details.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	vbox.add_child(details)
	
	hud_auto_return_label = Label.new()
	hud_auto_return_label.text = "⏱️ Ritorno al menu gare tra 7 secondi... [SPAZIO per saltare]"
	hud_auto_return_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_auto_return_label.add_theme_font_size_override("font_size", 10)
	hud_auto_return_label.add_theme_color_override("font_color", Color(0.65, 0.78, 0.90))
	vbox.add_child(hud_auto_return_label)
	
	var hbox_btns = HBoxContainer.new()
	hbox_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_btns.add_theme_constant_override("separation", 14)
	vbox.add_child(hbox_btns)
	
	var btn_return = Button.new()
	btn_return.text = "🏁 TORNA AL MENU GARE [SPAZIO / INVIO]"
	btn_return.add_theme_font_size_override("font_size", 11)
	var sb_ret = StyleBoxFlat.new()
	sb_ret.bg_color = Color(0.0, 0.40, 0.80, 0.95)
	sb_ret.border_color = Color(1.0, 0.85, 0.20, 0.95)
	sb_ret.set_border_width_all(1)
	sb_ret.set_corner_radius_all(4)
	btn_return.add_theme_stylebox_override("normal", sb_ret)
	btn_return.pressed.connect(return_to_race_menu)
	hbox_btns.add_child(btn_return)
	
	var btn_rematch = Button.new()
	btn_rematch.text = "🔄 RIVINCITA [R]"
	btn_rematch.add_theme_font_size_override("font_size", 11)
	btn_rematch.pressed.connect(func(): start_drag_race(rival_id, is_pink_slip, race_source_tab))
	hbox_btns.add_child(btn_rematch)
	
	hud_result_card.visible = false

# ==============================================================================
# RACE INITIALIZATION & 3D STAGING
# ==============================================================================
func start_drag_race(r_id: String, pink_slip: bool = false, src_tab: int = 3):
	rival_id = r_id
	is_pink_slip = pink_slip
	race_source_tab = src_tab
	auto_return_timer = -1.0
	current_state = RaceState.STAGING
	countdown_timer = 0.0
	race_time_elapsed = 0.0
	player_reaction_time = 0.0
	player_finish_time = 0.0
	rival_finish_time = 0.0
	player_crossed = false
	rival_crossed = false
	rival_launched = false
	
	# Determine rival reaction delay
	match rival_id:
		"gino": rival_reaction_delay = 0.22
		"kurt": rival_reaction_delay = 0.25
		"hans": rival_reaction_delay = 0.32
		"bepi": rival_reaction_delay = 0.36
		"chiara": rival_reaction_delay = 0.20
		_: rival_reaction_delay = 0.28
		
	# 1. Resolve node references
	if not road_generator and get_parent() and get_parent().has_node("RoadGenerator"):
		road_generator = get_parent().get_node("RoadGenerator")
	if not player_vehicle and get_parent() and get_parent().has_node("Vehicle"):
		player_vehicle = get_parent().get_node("Vehicle")
	if not street_rod_manager and get_parent() and get_parent().has_node("StreetRodManager"):
		street_rod_manager = get_parent().get_node("StreetRodManager")
	if not camera_controller and get_parent() and get_parent().has_node("CameraController"):
		camera_controller = get_parent().get_node("CameraController")
		
	# 1a. Preserve pre-race exploration state (la gara e' una cosa a parte!)
	if player_vehicle and not has_pre_race_state:
		pre_race_transform = player_vehicle.global_transform
		pre_race_linear_velocity = player_vehicle.linear_velocity
		pre_race_angular_velocity = player_vehicle.angular_velocity
		has_pre_race_state = true
		
	# Dedicated drag strip at the scenic Lake straightaway (Z = 40m to 440m)
	race_start_z = 40.0
	race_finish_z = 440.0
	
	# 1b. Ensure chunks along the entire 400m drag strip exist with solid collision
	if road_generator and road_generator.has_method("update_generation"):
		road_generator.update_generation(race_finish_z + 120.0)
	
	# 1c. Sample road coordinates at race start
	var r_info = road_generator.get_road_info_at(race_start_z) if road_generator else { "x": 0.0, "y": 0.0, "angle": 0.0, "width": 7.8 }
	race_road_center_x = r_info.x
	race_road_y = r_info.y
	var r_angle = r_info.angle
	var r_hw = r_info.width * 0.5
	var lane_offset = min(1.95, r_hw * 0.50)
	
	# 2. Build 3D Start & Finish Gantries
	build_3d_start_gantry(race_start_z, r_info)
	build_3d_finish_gantry(race_finish_z)
	
	# 3. Position Player Vehicle in Lane 1 (Left) with correct road heading and safe elevation
	if player_vehicle:
		player_vehicle.linear_velocity = Vector3.ZERO
		player_vehicle.angular_velocity = Vector3.ZERO
		var p_x = race_road_center_x - lane_offset * cos(r_angle)
		var p_z = race_start_z + lane_offset * sin(r_angle)
		var p_tf = Transform3D(Basis(Vector3.UP, PI + r_angle), Vector3(p_x, race_road_y + 0.65, p_z))
		player_vehicle.global_transform = p_tf
		PhysicsServer3D.body_set_state(player_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, p_tf)
		PhysicsServer3D.body_set_state(player_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
		PhysicsServer3D.body_set_state(player_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)
		player_vehicle.current_speed_kmh = 0.0
		# Lock player throttle and apply brake until green
		player_vehicle.ai_handbrake = true
		player_vehicle.is_ai_controlled = true
		player_vehicle.ai_throttle = 0.0
		player_vehicle.ai_brake = 1.0
		player_vehicle.headlights_on = true
		if player_vehicle.has_method("update_headlights"):
			player_vehicle.update_headlights()
		
	# 4. Spawn / Position Physical 3D Rival Vehicle in Lane 2 (Right)
	setup_rival_vehicle(race_start_z, r_info)
	
	# 5. Switch Camera to GTA Chase Angle behind cars
	if camera_controller:
		camera_controller.current_mode = CameraController.CameraMode.CHASE_DINAMICA
		camera_controller.user_dist_offset = 0.0
		camera_controller.user_height_offset = 0.0
		camera_controller.setup_initial_position()
		
	# 6. Show minimal racing HUD
	if hud_result_card:
		hud_result_card.visible = false
	if hud_banner_panel:
		hud_banner_panel.visible = true
	var riv_name = rival_id.to_upper()
	if street_rod_manager and street_rod_manager.rivals.has(rival_id):
		riv_name = street_rod_manager.rivals[rival_id].name
	if hud_banner_label:
		hud_banner_label.text = "🏁 SFIDA AL RETTIFILO CONTRO %s | SCHIERAMENTO SULLA GRIGLIA" % riv_name
	
	if hud_countdown_label:
		hud_countdown_label.visible = true
		hud_countdown_label.text = "SCHIERAMENTO SULLA GRIGLIA..."
		hud_countdown_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.15))
	
	current_state = RaceState.COUNTDOWN
	countdown_timer = 0.0
	emit_signal("race_started", rival_id)

func setup_rival_vehicle(start_z: float, r_info: Dictionary):
	if not rival_vehicle:
		# Instance vehicle scene as rival
		var v_scene = load("res://scenes/Vehicle.tscn")
		rival_vehicle = v_scene.instantiate()
		rival_vehicle.name = "RivalVehicle"
		rival_vehicle.is_ai_controlled = true
		get_parent().add_child(rival_vehicle)
	else:
		rival_vehicle.visible = true
		rival_vehicle.is_ai_controlled = true
		
	if road_generator and rival_vehicle:
		rival_vehicle.road_generator = road_generator
		
	# Assign rival model
	var r_data = street_rod_manager.rivals.get(rival_id, {}) if street_rod_manager else {}
	var rival_model = r_data.get("car_id", "golf_gti_1990")
	rival_vehicle.apply_vehicle_model(rival_model)
	
	# Place in Lane 2 (Right)
	var r_angle = r_info.angle
	var r_hw = r_info.width * 0.5
	var lane_offset = min(1.95, r_hw * 0.50)
	var riv_x = r_info.x + lane_offset * cos(r_angle)
	var riv_z = start_z - lane_offset * sin(r_angle)
	
	var riv_tf = Transform3D(Basis(Vector3.UP, PI + r_angle), Vector3(riv_x, r_info.y + 0.65, riv_z))
	rival_vehicle.global_transform = riv_tf
	PhysicsServer3D.body_set_state(rival_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, riv_tf)
	PhysicsServer3D.body_set_state(rival_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
	PhysicsServer3D.body_set_state(rival_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)
	rival_vehicle.current_speed_kmh = 0.0
	rival_vehicle.ai_throttle = 0.0
	rival_vehicle.ai_brake = 1.0
	rival_vehicle.ai_handbrake = true
	rival_vehicle.headlights_on = true
	if rival_vehicle.has_method("update_headlights"):
		rival_vehicle.update_headlights()

# ==============================================================================
# 3D START & FINISH ARCHES CONSTRUCTION
# ==============================================================================
func build_3d_start_gantry(z: float, r_info: Dictionary):
	if start_gantry_node:
		start_gantry_node.queue_free()
		
	start_gantry_node = Node3D.new()
	start_gantry_node.name = "StartGantry3D"
	start_gantry_node.position = Vector3(r_info.x, r_info.y, z)
	start_gantry_node.rotation.y = r_info.angle
	get_parent().add_child(start_gantry_node)
	
	# Materials
	var truss_mat = StandardMaterial3D.new()
	truss_mat.albedo_color = Color(0.72, 0.75, 0.78)
	truss_mat.metallic = 0.85
	truss_mat.roughness = 0.25
	
	# Left & Right Truss Towers
	for side in [-1.0, 1.0]:
		var tower = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.16; cyl.bottom_radius = 0.20; cyl.height = 5.2
		cyl.material = truss_mat
		tower.mesh = cyl
		tower.position = Vector3(side * 4.6, 2.6, 0.0)
		start_gantry_node.add_child(tower)
		
	# Crossbar Bridge Truss
	var crossbar = MeshInstance3D.new()
	var bar_mesh = BoxMesh.new()
	bar_mesh.size = Vector3(9.6, 0.45, 0.45)
	bar_mesh.material = truss_mat
	crossbar.mesh = bar_mesh
	crossbar.position = Vector3(0.0, 5.0, 0.0)
	start_gantry_node.add_child(crossbar)
	
	# Banner Overhead "🏁 PARTENZA - VALICO DEI MOTORI '93 🏁"
	var banner = MeshInstance3D.new()
	var b_box = BoxMesh.new()
	b_box.size = Vector3(8.2, 1.1, 0.08)
	var b_mat = StandardMaterial3D.new()
	b_mat.albedo_color = Color(0.04, 0.25, 0.65) # Royal Amiga Header Blue
	b_mat.emission_enabled = true
	b_mat.emission = Color(0.04, 0.25, 0.65)
	b_mat.emission_energy_multiplier = 0.35
	b_box.material = b_mat
	banner.mesh = b_box
	banner.position = Vector3(0.0, 4.3, 0.0)
	start_gantry_node.add_child(banner)
	
	# Start Line on Asphalt (Checkered Bar)
	var checker_line = MeshInstance3D.new()
	var c_box = BoxMesh.new()
	c_box.size = Vector3(7.8, 0.02, 1.2)
	var c_mat = StandardMaterial3D.new()
	c_mat.albedo_color = Color(0.95, 0.95, 0.95)
	c_mat.roughness = 0.8
	c_box.material = c_mat
	checker_line.mesh = c_box
	checker_line.position = Vector3(0.0, 0.015, 0.0)
	start_gantry_node.add_child(checker_line)
	
	# Alternating dark squares on start line
	for s in range(8):
		var sq = MeshInstance3D.new()
		var sq_box = BoxMesh.new()
		sq_box.size = Vector3(0.95, 0.025, 0.6)
		var sq_mat = StandardMaterial3D.new()
		sq_mat.albedo_color = Color(0.10, 0.10, 0.12)
		sq_box.material = sq_mat
		sq.mesh = sq_box
		sq.position = Vector3(-3.4 + float(s) * 0.98, 0.02, (0.3 if s % 2 == 0 else -0.3))
		start_gantry_node.add_child(sq)
		
	# 3D Christmas Tree (Semaforo di Partenza) mounted in center
	build_3d_christmas_tree(start_gantry_node)

func build_3d_christmas_tree(parent: Node3D):
	tree_lights_mesh.clear()
	tree_omni_lights.clear()
	
	var post = MeshInstance3D.new()
	var p_mesh = CylinderMesh.new()
	p_mesh.top_radius = 0.08; p_mesh.bottom_radius = 0.08; p_mesh.height = 3.6
	var p_mat = StandardMaterial3D.new()
	p_mat.albedo_color = Color(0.12, 0.12, 0.15)
	p_mesh.material = p_mat
	post.mesh = p_mesh
	post.position = Vector3(0.0, 3.2, -0.6)
	parent.add_child(post)
	
	# Christmas tree box casing
	var box = MeshInstance3D.new()
	var b_mesh = BoxMesh.new()
	b_mesh.size = Vector3(0.65, 2.2, 0.35)
	var b_mat = StandardMaterial3D.new()
	b_mat.albedo_color = Color(0.18, 0.20, 0.24)
	b_mesh.material = b_mat
	box.mesh = b_mesh
	box.position = Vector3(0.0, 2.8, -0.6)
	parent.add_child(box)
	
	# 4 light stages:
	# 0: Pre-stage (Amber)
	# 1: Amber 1
	# 2: Amber 2
	# 3: GREEN (GO!)
	var light_colors = [
		Color(1.0, 0.75, 0.10),
		Color(1.0, 0.75, 0.10),
		Color(1.0, 0.75, 0.10),
		Color(0.15, 1.0, 0.25)
	]
	var y_offsets = [3.5, 3.0, 2.5, 2.0]
	
	for i in range(4):
		var lamp = MeshInstance3D.new()
		var sph = SphereMesh.new()
		sph.radius = 0.14; sph.height = 0.28
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.15, 0.15, 0.15) # Off
		mat.emission_enabled = false
		sph.material = mat
		lamp.mesh = sph
		lamp.position = Vector3(0.0, y_offsets[i], -0.42)
		parent.add_child(lamp)
		tree_lights_mesh.append(lamp)
		
		var omni = OmniLight3D.new()
		omni.light_color = light_colors[i]
		omni.light_energy = 0.0 # Off initially
		omni.omni_range = 8.0
		omni.position = Vector3(0.0, y_offsets[i], -0.30)
		parent.add_child(omni)
		tree_omni_lights.append(omni)

func build_3d_finish_gantry(z: float):
	if finish_gantry_node:
		finish_gantry_node.queue_free()
		
	var r_info = road_generator.get_road_info_at(z) if road_generator else { "x": 0.0, "y": 0.0, "angle": 0.0, "width": 7.8 }
	finish_gantry_node = Node3D.new()
	finish_gantry_node.name = "FinishGantry3D"
	finish_gantry_node.position = Vector3(r_info.x, r_info.y, z)
	finish_gantry_node.rotation.y = r_info.angle
	get_parent().add_child(finish_gantry_node)
	
	var truss_mat = StandardMaterial3D.new()
	truss_mat.albedo_color = Color(0.85, 0.85, 0.88)
	truss_mat.metallic = 0.88
	
	# Towers
	for side in [-1.0, 1.0]:
		var tower = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.18; cyl.bottom_radius = 0.22; cyl.height = 5.4
		cyl.material = truss_mat
		tower.mesh = cyl
		tower.position = Vector3(side * 4.6, 2.7, 0.0)
		finish_gantry_node.add_child(tower)
		
	# Overhead Finish Banner "🏁 TRAGUARDO 400 METRI - ARRIVO 🏁"
	var banner = MeshInstance3D.new()
	var b_box = BoxMesh.new()
	b_box.size = Vector3(8.6, 1.25, 0.10)
	var b_mat = StandardMaterial3D.new()
	b_mat.albedo_color = Color(0.80, 0.12, 0.12) # Rosso Corsa Traguardo
	b_mat.emission_enabled = true
	b_mat.emission = Color(0.80, 0.12, 0.12)
	b_mat.emission_energy_multiplier = 0.40
	b_box.material = b_mat
	banner.mesh = b_box
	banner.position = Vector3(0.0, 4.4, 0.0)
	finish_gantry_node.add_child(banner)
	
	# Checkered Finish Line on Asphalt
	var fin_line = MeshInstance3D.new()
	var c_box = BoxMesh.new()
	c_box.size = Vector3(7.8, 0.02, 1.4)
	var c_mat = StandardMaterial3D.new()
	c_mat.albedo_color = Color(0.96, 0.96, 0.98)
	c_box.material = c_mat
	fin_line.mesh = c_box
	fin_line.position = Vector3(0.0, 0.015, 0.0)
	finish_gantry_node.add_child(fin_line)
	
	# Laser timing beam
	var laser = MeshInstance3D.new()
	var l_cyl = CylinderMesh.new()
	l_cyl.top_radius = 0.025; l_cyl.bottom_radius = 0.025; l_cyl.height = 8.8
	var l_mat = StandardMaterial3D.new()
	l_mat.albedo_color = Color(1.0, 0.15, 0.15)
	l_mat.emission_enabled = true
	l_mat.emission = Color(1.0, 0.15, 0.15)
	l_mat.emission_energy_multiplier = 3.5
	l_cyl.material = l_mat
	laser.mesh = l_cyl
	laser.rotation.z = deg_to_rad(90.0)
	laser.position = Vector3(0.0, 0.40, 0.0)
	finish_gantry_node.add_child(laser)
	
	# Twin Finish Strobe Beacons
	finish_strobes.clear()
	for s_x in [-4.4, 4.4]:
		var strobe = OmniLight3D.new()
		strobe.light_color = Color(1.0, 0.95, 0.85)
		strobe.light_energy = 0.0
		strobe.omni_range = 14.0
		strobe.position = Vector3(s_x, 5.2, 0.0)
		finish_gantry_node.add_child(strobe)
		finish_strobes.append(strobe)

# ==============================================================================
# MAIN PROCESS: COUNTDOWN, RACING, AI CONTROL & FINISH DETECTION
# ==============================================================================
func _process(delta: float):
	if current_state == RaceState.COUNTDOWN:
		update_countdown(delta)
	elif current_state == RaceState.RACING:
		update_race(delta)
	elif current_state == RaceState.FINISHED:
		if finish_strobe_timer > 0.0:
			finish_strobe_timer -= delta
			var blink = int(finish_strobe_timer * 10.0) % 2 == 0
			for s in finish_strobes:
				s.light_energy = 5.0 if blink else 0.0
		else:
			for s in finish_strobes:
				s.light_energy = 0.0
				
		if auto_return_timer > 0.0:
			auto_return_timer -= delta
			if hud_auto_return_label:
				hud_auto_return_label.text = "⏱️ Ritorno automatico al menu gare tra %d secondi... [SPAZIO per saltare]" % int(ceil(auto_return_timer))
			if auto_return_timer <= 0.0:
				return_to_race_menu()

func update_countdown(delta: float):
	countdown_timer += delta
	
	# Stage 0: Staging (0.0s - 1.0s)
	if countdown_timer < 1.0:
		set_tree_light(0, true)
		hud_countdown_label.text = "🟡 STAGING..."
		hud_countdown_label.add_theme_color_override("font_color", Color(1.0, 0.80, 0.20))
	# Stage 1: Amber 1 (1.0s)
	elif countdown_timer >= 1.0 and countdown_timer < 2.0:
		if not tree_lights_mesh[1].mesh.material.emission_enabled:
			set_tree_light(1, true)
			countdown_beep_player.play()
		hud_countdown_label.text = "🟡 3"
	# Stage 2: Amber 2 (2.0s)
	elif countdown_timer >= 2.0 and countdown_timer < 3.0:
		if not tree_lights_mesh[2].mesh.material.emission_enabled:
			set_tree_light(2, true)
			countdown_beep_player.play()
		hud_countdown_label.text = "🟡 2"
	# Stage 3: Amber 3 (3.0s)
	elif countdown_timer >= 3.0 and countdown_timer < 4.0:
		hud_countdown_label.text = "🟡 1"
	# Stage 4: GREEN LIGHT! (4.0s) -> LAUNCH!
	elif countdown_timer >= 4.0:
		set_tree_light(3, true)
		go_chime_player.play()
		hud_countdown_label.text = "🟢 VIA! VIA! VIA!"
		hud_countdown_label.add_theme_color_override("font_color", Color(0.20, 1.0, 0.35))
		
		# Hand off control to player
		if player_vehicle:
			player_vehicle.is_ai_controlled = false
			player_vehicle.ai_handbrake = false
			player_vehicle.ai_brake = 0.0
			
		current_state = RaceState.RACING
		race_time_elapsed = 0.0
		
		# Fade out countdown text after 1.2s
		get_tree().create_timer(1.2).timeout.connect(func():
			if current_state == RaceState.RACING:
				hud_countdown_label.visible = false
		)

func set_tree_light(idx: int, is_on: bool):
	if idx >= tree_lights_mesh.size(): return
	var lamp = tree_lights_mesh[idx]
	var omni = tree_omni_lights[idx]
	var mat = lamp.mesh.material as StandardMaterial3D
	
	var col = omni.light_color
	if is_on:
		mat.albedo_color = col
		mat.emission_enabled = true
		mat.emission = col
		mat.emission_energy_multiplier = 4.0
		omni.light_energy = 3.5
	else:
		mat.albedo_color = Color(0.15, 0.15, 0.15)
		mat.emission_enabled = false
		omni.light_energy = 0.0

func update_race(delta: float):
	race_time_elapsed += delta
	
	# 1. AI Rival Launch & Driving Controller
	if not rival_launched and race_time_elapsed >= rival_reaction_delay:
		rival_launched = true
		if rival_vehicle:
			rival_vehicle.ai_handbrake = false
			rival_vehicle.ai_brake = 0.0
			rival_vehicle.ai_throttle = 1.0
			
	if rival_vehicle and rival_launched:
		# Drive rival straight along Lane 2 (+1.95m from road center)
		var r_z = rival_vehicle.global_position.z
		var r_info = road_generator.get_road_info_at(r_z) if road_generator else { "x": 0.0 }
		var target_x = r_info.x + 1.95
		var cur_x = rival_vehicle.global_position.x
		var x_err = target_x - cur_x
		rival_vehicle.ai_steer = clamp(x_err * 0.45, -0.25, 0.25)
		rival_vehicle.ai_throttle = 1.0
		
	# 2. Update Live Racing HUD
	var p_z = player_vehicle.global_position.z if player_vehicle else 0.0
	var r_z = rival_vehicle.global_position.z if rival_vehicle else 0.0
	var dist_remaining = max(0.0, race_finish_z - p_z)
	var p_spd = int(player_vehicle.current_speed_kmh) if player_vehicle else 0
	var r_spd = int(rival_vehicle.current_speed_kmh) if rival_vehicle else 0
	var riv_name = rival_id.to_upper()
	if street_rod_manager and street_rod_manager.rivals.has(rival_id):
		riv_name = street_rod_manager.rivals[rival_id].name
		
	hud_banner_label.text = "🏁 400M DRAG | TU: %d KM/H | %s: %d KM/H | TRAGUARDO: %d M" % [
		p_spd, riv_name, r_spd, int(dist_remaining)
	]
	
	# 3. Check Finish Line Crossings
	if not player_crossed and p_z >= race_finish_z:
		player_crossed = true
		player_finish_time = race_time_elapsed
		player_trap_speed = player_vehicle.current_speed_kmh
		
	if not rival_crossed and r_z >= race_finish_z:
		rival_crossed = true
		rival_finish_time = race_time_elapsed
		rival_trap_speed = rival_vehicle.current_speed_kmh
		
	# 4. Resolve Race when both crossed or timeout
	if (player_crossed and rival_crossed) or race_time_elapsed > 35.0:
		on_race_finished()

func on_race_finished():
	current_state = RaceState.FINISHED
	finish_strobe_timer = 5.0
	auto_return_timer = 7.0 # Auto-return to race menu after 7s if not skipped
	finish_fanfare_player.play()
	
	var player_won = player_finish_time < rival_finish_time
	var r_data = street_rod_manager.rivals.get(rival_id, {}) if street_rod_manager else {}
	var riv_name = r_data.get("name", rival_id)
	
	# Resolve with career economy in StreetRodManager
	var res = {}
	if street_rod_manager and street_rod_manager.has_method("resolve_drag_race"):
		res = street_rod_manager.resolve_drag_race(rival_id, player_finish_time, is_pink_slip)
	
	# Show clean post-race results card
	var title_lbl = hud_result_card.find_child("ResultTitle", true, false) as Label
	var details_lbl = hud_result_card.find_child("ResultDetails", true, false) as Label
	
	if player_won:
		title_lbl.text = "🏆 VITTORIA AL RETTIFILO! HAI VINTO LA SFIDA!"
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	else:
		title_lbl.text = "💨 SCONFITTA AL TRAGUARDO... TI HA STACCATO!"
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.40, 0.35))
		
	var bet_str = street_rod_manager.format_lire(r_data.get("bet_lire", 500000)) if street_rod_manager else "500.000"
	var cash_effect = ("+L. %s" % bet_str) if player_won else ("-L. %s" % bet_str)
	if is_pink_slip:
		cash_effect = "AUTO VINTA (LIBRETTO AGGIUNTO AL GARAGE!)" if player_won else "AUTO PERSA A LIBRETTO!"
		
	details_lbl.text = "Il Tuo Tempo 1/4 Miglio: %.2fs (Velocità: %d km/h)\nTempo %s: %.2fs (Velocità: %d km/h)\nEsito Scommessa: %s | Reputazione: %s" % [
		player_finish_time, int(player_trap_speed),
		riv_name, rival_finish_time, int(rival_trap_speed),
		cash_effect, ("+35 PT" if player_won else "-15 PT")
	]
	
	hud_result_card.visible = true
	emit_signal("race_finished", {
		"won": player_won,
		"player_time": player_finish_time,
		"rival_time": rival_finish_time,
		"rival_id": rival_id
	})

func return_to_race_menu():
	auto_return_timer = -1.0
	close_race_mode()
	
	# Restore player vehicle to pre-race exploration position (la gara e' una cosa a parte!)
	if has_pre_race_state and player_vehicle:
		player_vehicle.global_transform = pre_race_transform
		PhysicsServer3D.body_set_state(player_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, pre_race_transform)
		PhysicsServer3D.body_set_state(player_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
		PhysicsServer3D.body_set_state(player_vehicle.get_rid(), PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)
		player_vehicle.linear_velocity = Vector3.ZERO
		player_vehicle.angular_velocity = Vector3.ZERO
		has_pre_race_state = false
		
	if camera_controller:
		camera_controller.setup_initial_position()
		
	# Re-open StreetRodUI directly on the race menu tab
	var ui = street_rod_ui
	if not ui and get_tree() and get_tree().root:
		ui = get_tree().root.find_child("StreetRodUI", true, false)
	if ui and ui.has_method("open_screen"):
		ui.open_screen(race_source_tab)

func _unhandled_input(event: InputEvent):
	if current_state == RaceState.FINISHED:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
				get_viewport().set_input_as_handled()
				return_to_race_menu()
			elif event.keycode == KEY_R:
				get_viewport().set_input_as_handled()
				start_drag_race(rival_id, is_pink_slip, race_source_tab)
	elif current_state in [RaceState.STAGING, RaceState.COUNTDOWN, RaceState.RACING]:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				get_viewport().set_input_as_handled()
				return_to_race_menu()

func close_race_mode():
	current_state = RaceState.IDLE
	auto_return_timer = -1.0
	hud_banner_panel.visible = false
	hud_countdown_label.visible = false
	hud_result_card.visible = false
	
	# Despawn rival vehicle or hide and reset controls
	if rival_vehicle:
		rival_vehicle.visible = false
		rival_vehicle.is_ai_controlled = false
		rival_vehicle.ai_throttle = 0.0
		rival_vehicle.ai_brake = 0.0
		rival_vehicle.ai_steer = 0.0
		
	# Restore player vehicle controls
	if player_vehicle:
		player_vehicle.is_ai_controlled = false
		player_vehicle.ai_handbrake = false
		player_vehicle.ai_brake = 0.0
		player_vehicle.ai_throttle = 0.0
		
	# Restore camera offsets
	if camera_controller:
		camera_controller.user_dist_offset = 0.0
		camera_controller.user_height_offset = 0.0
		
	# Clean up start and finish gantries
	if start_gantry_node:
		start_gantry_node.queue_free()
		start_gantry_node = null
	if finish_gantry_node:
		finish_gantry_node.queue_free()
		finish_gantry_node = null
