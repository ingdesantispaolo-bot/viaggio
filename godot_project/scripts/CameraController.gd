extends Camera3D
class_name CameraController

# THE LONG MERIDIAN - Precision Multi-Angle Smooth Follow Camera (Godot 4)
# Solves jitter/stutter via physics-aligned dual asymptotic damping,
# provides 3 authentic camera presets (Low Chase, Bonnet/Cockpit, Scenic Diorama),
# interactive player adjustments (Mouse Wheel zoom, Q/E height, V view toggle),
# and full mouse orbit/free-look rotation like in AAA racing games.

signal camera_mode_changed(mode_name: String, height: float, dist: float)

enum CameraMode {
	DIORAMA_ALTO,       # Art of Rally elevated miniature road-tracking diorama (DEFAULT)
	DIORAMA_ISOMETRICO, # Dorfromantik / Tiny Glade high 45-degree panoramic view
	CHASE_DINAMICA,     # Lower classic tracking chase
	BONNET_COCKPIT      # On the hood / windshield driver perspective
}

@export var target_node: Node3D
@export var road_generator: Node3D

@export var current_mode: CameraMode = CameraMode.CHASE_DINAMICA

# Preset configurations [height, distance, lookahead, fov] (GTA Driving Physics Inspired)
var PRESETS = {
	CameraMode.CHASE_DINAMICA: {
		"name": "CHASE DINAMICA (GTA)",
		"height": 1.85,
		"distance": 4.85,
		"lookahead": 3.6,
		"fov": 58.0
	},
	CameraMode.BONNET_COCKPIT: {
		"name": "COCKPIT GUIDATORE",
		"height": 0.88,
		"distance": 0.0,
		"lookahead": 8.0,
		"fov": 86.0
	},
	CameraMode.DIORAMA_ALTO: {
		"name": "DIORAMA ALPINO",
		"height": 8.5,
		"distance": 12.8,
		"lookahead": 4.2,
		"fov": 40.0
	},
	CameraMode.DIORAMA_ISOMETRICO: {
		"name": "ISOMETRICA PANORAMICA",
		"height": 12.0,
		"distance": 15.5,
		"lookahead": 4.0,
		"fov": 34.0
	}
}

# Player runtime adjustments
var user_dist_offset: float = 0.0
var user_height_offset: float = 0.0

# Mouse Orbit & Free-Look state
var is_mouse_orbiting: bool = false
var orbit_yaw: float = 0.0          # Target orbit yaw (radians)
var orbit_pitch: float = 0.0        # Target orbit pitch (radians)
var smoothed_orbit_yaw: float = 0.0
var smoothed_orbit_pitch: float = 0.0
var orbit_idle_timer: float = 0.0
@export var mouse_sensitivity: float = 0.0036
@export var auto_recenter_delay: float = 1.8
@export var auto_recenter_speed: float = 3.6

# Damping & Smoothing state (prevents physics-tick micro-stutter & suspension snap)
var current_heading: float = 0.0
var smoothed_pos: Vector3 = Vector3.ZERO
var smoothed_lookat: Vector3 = Vector3.ZERO
var target_lookat_filtered: Vector3 = Vector3.ZERO
var trauma: float = 0.0
var shake_offset: Vector3 = Vector3.ZERO
var initialized: bool = false
var cam_attributes: CameraAttributesPractical = null

func _ready():
	current = true
	var p = PRESETS[current_mode]
	fov = p.fov
	setup_optical_attributes()
	if target_node:
		setup_initial_position()

func setup_optical_attributes():
	if attributes == null:
		cam_attributes = CameraAttributesPractical.new()
		attributes = cam_attributes
	elif attributes is CameraAttributesPractical:
		cam_attributes = attributes as CameraAttributesPractical

func setup_initial_position():
	if not target_node: return
	current = true
	var p = PRESETS[current_mode]
	var target_pos = target_node.global_position if target_node.is_inside_tree() else target_node.position
	var h = p.height + user_height_offset
	var d = p.distance + user_dist_offset
	
	var fwd = -target_node.global_transform.basis.z if target_node.is_inside_tree() else -target_node.transform.basis.z
	current_heading = atan2(fwd.x, fwd.z)
	var sin_h = sin(current_heading)
	var cos_h = cos(current_heading)
	
	if current_mode == CameraMode.BONNET_COCKPIT:
		var m_id = target_node.get("current_model_id")
		var s = 0.75 # VehicleController.PLAYER_SCALE
		var eye_model = Vector3(-0.30, 0.81, -0.04)
		if m_id == "delta_integrale": eye_model = Vector3(-0.36, 0.84, -0.04)
		elif m_id == "mercedes_gwagen": eye_model = Vector3(-0.38, 1.10, -0.04)
		elif m_id == "fiat_127": eye_model = Vector3(-0.30, 0.81, -0.04)
		elif m_id == "golf_gti_1990": eye_model = Vector3(-0.32, 0.84, -0.04)
		elif m_id == "renault_4": eye_model = Vector3(-0.30, 0.90, -0.04)
		elif m_id == "bmw_320_e30": eye_model = Vector3(-0.32, 0.84, -0.04)
		elif m_id == "mercedes_a250": eye_model = Vector3(-0.32, 0.84, -0.04)
		var eye_init = eye_model * s
		smoothed_pos = target_node.global_transform * eye_init
		smoothed_lookat = smoothed_pos + (target_node.global_transform.basis * Vector3(0.0, -1.15, -12.0))
	else:
		smoothed_pos = Vector3(target_pos.x - sin_h * d, target_pos.y + h, target_pos.z - cos_h * d)
		smoothed_lookat = Vector3(target_pos.x + sin_h * p.lookahead, target_pos.y + 0.55, target_pos.z + cos_h * p.lookahead)
	target_lookat_filtered = target_pos
	if is_inside_tree():
		global_position = smoothed_pos
		look_at(smoothed_lookat, Vector3.UP)
	else:
		position = smoothed_pos
		look_at_from_position(position, smoothed_lookat, Vector3.UP)
	initialized = true

func cycle_camera_mode():
	match current_mode:
		CameraMode.DIORAMA_ALTO:
			set_camera_mode(CameraMode.DIORAMA_ISOMETRICO)
		CameraMode.DIORAMA_ISOMETRICO:
			set_camera_mode(CameraMode.CHASE_DINAMICA)
		CameraMode.CHASE_DINAMICA:
			set_camera_mode(CameraMode.BONNET_COCKPIT)
		CameraMode.BONNET_COCKPIT:
			set_camera_mode(CameraMode.DIORAMA_ALTO)

func set_camera_mode(new_mode: CameraMode):
	current_mode = new_mode
	user_dist_offset = 0.0
	user_height_offset = 0.0
	reset_camera_orbit()
	var p = PRESETS[current_mode]
	emit_signal("camera_mode_changed", p.name, p.height, p.distance)

func adjust_height(amount: float):
	user_height_offset = clamp(user_height_offset + amount, -3.0, 8.0)
	var p = PRESETS[current_mode]
	emit_signal("camera_mode_changed", p.name, p.height + user_height_offset, p.distance + user_dist_offset)

func adjust_distance(amount: float):
	user_dist_offset = clamp(user_dist_offset + amount, -8.0, 16.0)
	var p = PRESETS[current_mode]
	emit_signal("camera_mode_changed", p.name, p.height + user_height_offset, p.distance + user_dist_offset)

func reset_adjustments():
	user_dist_offset = 0.0
	user_height_offset = 0.0
	reset_camera_orbit()
	var p = PRESETS[current_mode]
	emit_signal("camera_mode_changed", p.name, p.height, p.distance)

func reset_camera_orbit():
	orbit_yaw = 0.0
	orbit_pitch = 0.0
	smoothed_orbit_yaw = 0.0
	smoothed_orbit_pitch = 0.0
	orbit_idle_timer = 0.0

func add_trauma(amount: float):
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _unhandled_input(event: InputEvent):
	# 1. Keyboard Controls
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_V:
			cycle_camera_mode()
		elif event.keycode == KEY_1:
			set_camera_mode(CameraMode.DIORAMA_ALTO)
		elif event.keycode == KEY_2:
			set_camera_mode(CameraMode.DIORAMA_ISOMETRICO)
		elif event.keycode == KEY_3:
			set_camera_mode(CameraMode.CHASE_DINAMICA)
		elif event.keycode == KEY_4:
			set_camera_mode(CameraMode.BONNET_COCKPIT)
		elif event.keycode == KEY_Q or event.keycode == KEY_PAGEUP:
			adjust_height(+0.15)
		elif event.keycode == KEY_E or event.keycode == KEY_PAGEDOWN:
			adjust_height(-0.15)
		elif event.keycode == KEY_C:
			# GTA-Style Look Back (180° Rear Mirror / Trunk Check)
			orbit_yaw = PI if abs(orbit_yaw) < 0.1 else 0.0
			orbit_idle_timer = 0.0
		elif event.keycode == KEY_ESCAPE:
			is_mouse_orbiting = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	# 2. Mouse Buttons
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_mouse_orbiting = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				orbit_idle_timer = 0.0
			else:
				is_mouse_orbiting = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				orbit_idle_timer = 0.0
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			reset_camera_orbit()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			adjust_distance(-0.30)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			adjust_distance(+0.30)
			
	# 3. Mouse Motion (Orbit / Free-look)
	elif event is InputEventMouseMotion and is_mouse_orbiting:
		orbit_yaw -= event.relative.x * mouse_sensitivity
		orbit_pitch -= event.relative.y * mouse_sensitivity
		orbit_idle_timer = 0.0
		
		# Clamp pitch depending on camera mode
		if current_mode == CameraMode.BONNET_COCKPIT:
			orbit_yaw = clamp(orbit_yaw, -1.35, 1.35)    # ~77 deg left/right head turn
			orbit_pitch = clamp(orbit_pitch, -0.45, 0.45) # ~26 deg up/down head tilt
		else:
			# Chase / Diorama orbit: unrestricted 360 yaw, pitch clamped
			orbit_pitch = clamp(orbit_pitch, -0.25, 1.05) # -14 deg to +60 deg

func _physics_process(delta: float):
	if not target_node:
		return
		
	if not initialized:
		setup_initial_position()
		
	var target_pos = target_node.global_position if target_node.is_inside_tree() else target_node.position
	var speed_ms = 0.0
	if target_node is VehicleBody3D:
		speed_ms = target_node.linear_velocity.length()
		
	var speed_ratio = clamp(speed_ms / 35.0, 0.0, 1.5)
	var p = PRESETS[current_mode]
	
	# 1. FOV slight dynamic breathing on acceleration (chase modes only, stable in cockpit)
	var target_fov = p.fov + (speed_ratio * 3.5 if current_mode != CameraMode.BONNET_COCKPIT else 0.0)
	fov = lerp(fov, target_fov, delta * 3.0)
	
	# 2. Heading interpolation: PURE GTA-STYLE VEHICLE TRACKING
	# Camera ALWAYS stays directly behind the vehicle's heading, even when turning 180° or driving backwards
	var fwd = -target_node.global_transform.basis.z if target_node.is_inside_tree() else -target_node.transform.basis.z
	var vehicle_heading = atan2(fwd.x, fwd.z)
	
	# Pure vehicle heading tracking (zero road bias lock)
	var effective_heading = vehicle_heading
	var angle_diff = wrapf(effective_heading - current_heading, -PI, PI)
	
	# Dynamic follow responsiveness: smooth elastic catch-up at speed, swift turning on hairpins & U-turns
	var follow_speed = 6.2 + clamp(speed_ms / 4.5, 0.0, 5.0)
	current_heading += angle_diff * clamp(delta * follow_speed, 0.0, 1.0)
	current_heading = wrapf(current_heading, -PI, PI)
	
	# 3. Auto-recenter logic (smooth spring back when driving)
	if not is_mouse_orbiting:
		orbit_idle_timer += delta
		if orbit_idle_timer > auto_recenter_delay:
			var decay_mult = auto_recenter_speed
			if speed_ms > 2.5:
				decay_mult *= 1.8 # Recenter faster when accelerating
			orbit_yaw = lerp(orbit_yaw, 0.0, delta * decay_mult)
			orbit_pitch = lerp(orbit_pitch, 0.0, delta * decay_mult)
			if abs(orbit_yaw) < 0.002: orbit_yaw = 0.0
			if abs(orbit_pitch) < 0.002: orbit_pitch = 0.0

	# Smooth user orbit angles for silky AAA responsiveness
	smoothed_orbit_yaw = lerp(smoothed_orbit_yaw, orbit_yaw, delta * 15.0)
	smoothed_orbit_pitch = lerp(smoothed_orbit_pitch, orbit_pitch, delta * 15.0)
	
	# 4. Dynamic distance & height
	var eff_height = p.height + user_height_offset + (speed_ratio * 0.25 if current_mode != CameraMode.BONNET_COCKPIT else 0.0)
	var eff_dist = p.distance + user_dist_offset + (speed_ratio * 0.8 if current_mode != CameraMode.BONNET_COCKPIT else 0.0)
	var eff_lookahead = p.lookahead + speed_ratio * 1.2

	# Service Area Framing: lower and zoom slightly closer to emphasize vehicle and bay
	var is_service_active = false
	if target_node and target_node.get("is_in_service_zone"):
		is_service_active = target_node.is_in_service_zone

	if is_service_active and current_mode != CameraMode.BONNET_COCKPIT:
		eff_height = min(eff_height, 10.5)
		eff_dist = min(eff_dist, 16.5)
	
	var desired_pos = Vector3.ZERO
	var desired_lookat = Vector3.ZERO
	
	if current_mode == CameraMode.BONNET_COCKPIT and target_node:
		var m_id = target_node.get("current_model_id")
		var s = 0.75 # VehicleController.PLAYER_SCALE
		var eye_model = Vector3(-0.30, 0.81, -0.04)
		if m_id == "delta_integrale": eye_model = Vector3(-0.36, 0.84, -0.04)
		elif m_id == "mercedes_gwagen": eye_model = Vector3(-0.38, 1.10, -0.04)
		elif m_id == "fiat_127": eye_model = Vector3(-0.30, 0.81, -0.04)
		elif m_id == "golf_gti_1990": eye_model = Vector3(-0.32, 0.84, -0.04)
		elif m_id == "renault_4": eye_model = Vector3(-0.30, 0.90, -0.04)
		elif m_id == "bmw_320_e30": eye_model = Vector3(-0.32, 0.84, -0.04)
		elif m_id == "mercedes_a250": eye_model = Vector3(-0.32, 0.84, -0.04)
		elif m_id == "alfa_8c": eye_model = Vector3(-0.24, 0.84, 0.02)
		elif m_id == "fiat_topolino": eye_model = Vector3(-0.24, 0.82, -0.04)
		elif m_id == "lancia_aurelia": eye_model = Vector3(-0.30, 0.85, -0.04)
		elif m_id == "alfa_gta": eye_model = Vector3(-0.30, 0.85, -0.04)
		elif m_id == "lancia_stratos": eye_model = Vector3(-0.28, 0.78, -0.04)
		elif m_id == "fiat_131_abarth": eye_model = Vector3(-0.32, 0.85, -0.04)
		
		var eye_local = eye_model * s
		eye_local.y += user_height_offset
		eye_local.z += user_dist_offset
		desired_pos = target_node.global_transform * eye_local
		
		# Free-look driver head rotation inside the cabin:
		# Inclinazione naturale verso la strada (-1.15m su 12m avanti = -5.5° pitch)
		var head_basis = Basis.from_euler(Vector3(smoothed_orbit_pitch, smoothed_orbit_yaw, 0.0))
		var look_target_local = head_basis * Vector3(0.0, -1.15, -12.0)
		desired_lookat = desired_pos + (target_node.global_transform.basis * look_target_local)
	else:
		var total_heading = current_heading + smoothed_orbit_yaw
		var sin_th = sin(total_heading)
		var cos_th = cos(total_heading)
		
		var pitch_cos = cos(smoothed_orbit_pitch)
		var pitch_sin = sin(smoothed_orbit_pitch)
		
		var h_dist = eff_dist * pitch_cos
		var v_height = eff_height + eff_dist * pitch_sin
		v_height = max(v_height, 0.45) # Prevent clipping through ground
		
		desired_pos = Vector3(
			target_pos.x - sin_th * h_dist,
			target_pos.y + v_height,
			target_pos.z - cos_th * h_dist
		)
		
		var target_y_damped = lerp(target_lookat_filtered.y, target_pos.y + 0.55, delta * 6.0)
		target_lookat_filtered = Vector3(target_pos.x, target_y_damped, target_pos.z)
		
		var speed_lookahead_scale = 0.15 if is_service_active else clamp(speed_ms / 16.0, 0.22, 1.0)
		var active_lookahead = eff_lookahead * speed_lookahead_scale
		
		# When orbiting, point directly at vehicle center; when trailing forward, add lookahead
		var forward_bias = clamp(1.0 - abs(smoothed_orbit_yaw) * 1.4, 0.0, 1.0)
		var sin_h = sin(current_heading)
		var cos_h = cos(current_heading)
		# Pitch camera down gently towards road so vehicle is framed at screen Y ~ 0.58-0.62
		var lookat_y_boost = -0.25 if current_mode == CameraMode.DIORAMA_ALTO else (-0.15 if current_mode == CameraMode.DIORAMA_ISOMETRICO else 0.15)
		desired_lookat = Vector3(
			target_lookat_filtered.x + sin_h * active_lookahead * forward_bias,
			target_lookat_filtered.y + lookat_y_boost,
			target_lookat_filtered.z + cos_h * active_lookahead * forward_bias
		)

		# Anti-Blind Crest: dynamically lift camera and angle downwards over hill crests & descents
		var veh_fwd_y = -target_node.global_transform.basis.z.y if target_node.is_inside_tree() else -target_node.transform.basis.z.y
		if veh_fwd_y < -0.03 and current_mode != CameraMode.BONNET_COCKPIT:
			var crest_bias = abs(veh_fwd_y)
			desired_pos.y += crest_bias * 2.4
			desired_lookat.y -= crest_bias * 1.6

		# Anti-Blind Spot: Line-of-Sight Physics Raycast to prevent clipping behind terrain, rocks, buildings
		if is_inside_tree() and get_world_3d() and current_mode != CameraMode.BONNET_COCKPIT:
			var space_state = get_world_3d().direct_space_state
			if space_state:
				var focus_pt = target_pos + Vector3(0.0, 1.15, 0.0)
				var ray_query = PhysicsRayQueryParameters3D.create(focus_pt, desired_pos)
				if target_node is CollisionObject3D:
					ray_query.exclude = [target_node.get_rid()]
				var hit = space_state.intersect_ray(ray_query)
				if not hit.is_empty():
					var hit_pos: Vector3 = hit.position
					var hit_norm: Vector3 = hit.normal
					var safe_pos = hit_pos + hit_norm * 0.45
					var dir_to_cam = (desired_pos - focus_pt).normalized()
					var min_cam_dist = 2.2
					if safe_pos.distance_to(focus_pt) < min_cam_dist:
						safe_pos = focus_pt + dir_to_cam * min_cam_dist + Vector3(0.0, 0.55, 0.0)
					desired_pos = safe_pos

	# 5. Trauma Screen Shake
	if trauma > 0.0:
		var shake_mag = pow(trauma, 2.0) * 0.8
		shake_offset = Vector3(
			randf_range(-1.0, 1.0) * shake_mag,
			randf_range(-0.5, 0.5) * shake_mag,
			randf_range(-1.0, 1.0) * shake_mag
		)
		trauma = max(0.0, trauma - delta * 2.2)
	else:
		shake_offset = Vector3.ZERO
		
	# 6. Dual Asymptotic Damping (Eliminates physics-step stuttering in chase modes)
	# In BONNET_COCKPIT mode: the camera is rigidly locked to the driver's head inside the cabin.
	# Zero world-space lag on acceleration, braking, or high speeds!
	if current_mode == CameraMode.BONNET_COCKPIT:
		smoothed_pos = desired_pos
		smoothed_lookat = desired_lookat
	else:
		var pos_smoothing = 8.5
		smoothed_pos = smoothed_pos.lerp(desired_pos, delta * pos_smoothing)
		smoothed_lookat = smoothed_lookat.lerp(desired_lookat, delta * 10.0)
	
	if is_inside_tree():
		global_position = smoothed_pos + shake_offset
		look_at(smoothed_lookat, Vector3.UP)
	else:
		position = smoothed_pos + shake_offset
		look_at_from_position(position, smoothed_lookat, Vector3.UP)
	
	# 7. Screen-Space Framing Guard (Guarantees vehicle is ALWAYS visible above bottom dashboard HUD)
	if current_mode != CameraMode.BONNET_COCKPIT and is_inside_tree():
		var vp = get_viewport()
		if vp != null:
			var vp_rect = vp.get_visible_rect()
			if vp_rect.size.y > 10.0 and not is_position_behind(target_pos):
				var s_pos = unproject_position(target_pos)
				var norm_y = s_pos.y / vp_rect.size.y
				# If vehicle drifts down towards the dashboard (Y > 0.65), dynamically tilt camera down
				if norm_y > 0.65:
					var y_guard = (norm_y - 0.65) * 6.5
					smoothed_lookat.y -= y_guard
					look_at(smoothed_lookat, Vector3.UP)

	# 8. Dynamic Physical Depth of Field (Tilt-Shift ottico basato su Z-depth 3D reale)
	update_optical_dof(delta, target_pos)

func update_optical_dof(delta: float, target_pos: Vector3):
	if cam_attributes == null:
		return
	var cam_pos = global_position if is_inside_tree() else position
	var dist_to_car = cam_pos.distance_to(target_pos)
	
	match current_mode:
		CameraMode.DIORAMA_ALTO, CameraMode.DIORAMA_ISOMETRICO:
			# Visuale Diorama Nitida e Meticolosa: zero sfocatura vicina, paesaggio e auto a fuoco chirurgico
			cam_attributes.dof_blur_near_enabled = false
			cam_attributes.dof_blur_far_enabled = true
			var target_far = dist_to_car + 75.0 # Ampia profondità di campo: tutto il tracciato e i dettagli visibili
			cam_attributes.dof_blur_far_distance = lerp(cam_attributes.dof_blur_far_distance, target_far, delta * 4.0)
			cam_attributes.dof_blur_far_transition = 50.0
			cam_attributes.dof_blur_amount = 0.020 # Solo lieve ammorbidimento atmosferico sui crinali all'orizzonte
		CameraMode.CHASE_DINAMICA:
			# Visione pura ad alta velocità senza aloni
			cam_attributes.dof_blur_near_enabled = false
			cam_attributes.dof_blur_far_enabled = false
		CameraMode.BONNET_COCKPIT:
			# Driver POV: strada e cruscotto perfettamente nitidi
			cam_attributes.dof_blur_near_enabled = false
			cam_attributes.dof_blur_far_enabled = false

