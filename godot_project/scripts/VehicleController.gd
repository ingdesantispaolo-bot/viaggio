extends VehicleBody3D
class_name VehicleController

# THE LONG MERIDIAN - Authentic Multi-Vehicle Physics & Drivetrain Controller (Godot 4 / Jolt)
# Faithfully simulates 3 iconic European vehicles:
# 1. Fiat Panda 4x4 Steyr-Puch (1983)
# 2. Lancia Delta HF Integrale Evoluzione (1991)
# 3. Mercedes-Benz G-Klasse W460 280 GE (1979)

signal telemetry_updated(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, pitch_deg, roll_deg, is_4wd, boost_bar, model_info)

# Complete real-world technical catalog
var VEHICLE_CATALOG = {
    "panda_4x4": {
        "id": "panda_4x4",
        "name": "Fiat Panda 4x4 Steyr-Puch (1983)",
        "short_name": "PANDA 4x4 STEYR",
        "maker": "Fiat / Steyr-Puch",
        "year": 1983,
        "engine": "965cc A112 Asta e Bilancieri",
        "mass": 780.0,
        "engine_force": 840.0,
        "brake_force": 85.0,
        "steer_angle": 29.0,
        "redline_rpm": 6000.0,
        "idle_rpm": 850.0,
        "top_speed": 135.0,
        "drivetrain": "4WD STEYR-PUCH [50:50]",
        "drivetrain_2wd": "TRAZIONE ANTERIORE [FWD]",
        "has_turbo": false,
        "turbo_boost_max": 0.0,
        "tank_l": 35.0,
        "gear_ratios": [4.8, 3.2, 2.1, 1.45, 1.02, -3.8],
        "cluster_style": "veglia_panda",
        "speedo_max": 160
    },
    "delta_integrale": {
        "id": "delta_integrale",
        "name": "Lancia Delta HF Integrale Evo (1991)",
        "short_name": "DELTA HF INTEGRALE",
        "maker": "Lancia Martini Racing",
        "year": 1991,
        "engine": "2.0L 16V Turbo Garrett T3",
        "mass": 1300.0,
        "engine_force": 1650.0,
        "brake_force": 145.0,
        "steer_angle": 26.0,
        "redline_rpm": 6800.0,
        "idle_rpm": 950.0,
        "top_speed": 220.0,
        "drivetrain": "TORSEN AWD PERMANENTE [47:53]",
        "drivetrain_2wd": "TORSEN AWD PERMANENTE [47:53]",
        "has_turbo": true,
        "turbo_boost_max": 1.45,
        "tank_l": 57.0,
        "gear_ratios": [3.6, 2.3, 1.6, 1.22, 0.94, -3.2],
        "cluster_style": "veglia_corse",
        "speedo_max": 260
    },
    "mercedes_gwagen": {
        "id": "mercedes_gwagen",
        "name": "Mercedes-Benz G-Klasse W460 (1979)",
        "short_name": "G-KLASSE W460",
        "maker": "Mercedes-Benz / Steyr",
        "year": 1979,
        "engine": "2.8L M110 6 Cilindri DOHC",
        "mass": 1980.0,
        "engine_force": 1420.0,
        "brake_force": 125.0,
        "steer_angle": 27.0,
        "redline_rpm": 6000.0,
        "idle_rpm": 800.0,
        "top_speed": 155.0,
        "drivetrain": "3x DIFF-LOCK MECCANICI 100%",
        "drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
        "has_turbo": false,
        "turbo_boost_max": 0.0,
        "tank_l": 68.0,
        "gear_ratios": [4.6, 2.9, 1.8, 1.30, 0.98, -4.0],
        "cluster_style": "vdo_stuttgart",
        "speedo_max": 200
    }
}

var model_keys = ["panda_4x4", "delta_integrale", "mercedes_gwagen"]
var current_model_idx: int = 0
var current_model_id: String = "panda_4x4"

# Internal dynamic telemetry
var current_speed_kmh: float = 0.0
var engine_rpm: float = 850.0
var current_gear: int = 1
var gear_name: String = "D1"
var current_fuel: float = 28.5
var engine_temp: float = 82.0
var current_boost_bar: float = 0.0
var hazard_timer: float = 0.0
var hazard_state: bool = false
var is_4wd_engaged: bool = true
var headlights_on: bool = true
var hazard_lights_on: bool = false

# Wheel nodes
@onready var wheel_fl: VehicleWheel3D = $WheelFL
@onready var wheel_fr: VehicleWheel3D = $WheelFR
@onready var wheel_rl: VehicleWheel3D = $WheelRL
@onready var wheel_rr: VehicleWheel3D = $WheelRR

# Lights
@onready var headlight_l: SpotLight3D = $HeadlightL
@onready var headlight_r: SpotLight3D = $HeadlightR
@onready var taillight_l: OmniLight3D = $TaillightL
@onready var taillight_r: OmniLight3D = $TaillightR
@onready var hazard_fl: MeshInstance3D = $HazardFL
@onready var hazard_fr: MeshInstance3D = $HazardFR
@onready var hazard_rl: MeshInstance3D = $HazardRL
@onready var hazard_rr: MeshInstance3D = $HazardRR

# Audio Engine
@onready var audio_engine: VehicleAudio = $VehicleAudio

# Model 3D Meshes Groups
@onready var model_panda: Node3D = $ModelPanda
@onready var model_delta: Node3D = $ModelDelta
@onready var model_gwagen: Node3D = $ModelGwagen

func _ready():
    apply_vehicle_model(current_model_id)
    update_headlights()

func switch_vehicle():
    current_model_idx = (current_model_idx + 1) % model_keys.size()
    current_model_id = model_keys[current_model_idx]
    apply_vehicle_model(current_model_id)

func apply_vehicle_model(model_id: String):
    var cfg = VEHICLE_CATALOG[model_id]
    current_model_id = model_id
    
    # 1. Physics Tuning
    mass = cfg.mass
    center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
    center_of_mass = Vector3(0.0, -0.16, -0.05)
    
    current_fuel = cfg.tank_l * 0.85
    engine_rpm = cfg.idle_rpm
    current_boost_bar = 0.0
    
    # Ensure wheel nodes are resolved
    if not wheel_fl and has_node("WheelFL"):
        wheel_fl = $WheelFL
        wheel_fr = $WheelFR
        wheel_rl = $WheelRL
        wheel_rr = $WheelRR

    # 2. Suspension setup
    for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
        if not w: continue
        w.suspension_travel = 0.22 if model_id != "delta_integrale" else 0.16
        w.suspension_stiffness = 36.0 if model_id == "panda_4x4" else (48.0 if model_id == "delta_integrale" else 42.0)
        w.damping_compression = 0.45
        w.damping_relaxation = 0.58
        w.wheel_friction_slip = 2.85 if model_id == "delta_integrale" else 2.65
        w.wheel_radius = 0.30 if model_id == "delta_integrale" else (0.35 if model_id == "mercedes_gwagen" else 0.32)
        w.wheel_rest_length = 0.16
        
    # 3. Model Exterior Visibility
    if not model_panda and has_node("ModelPanda"):
        model_panda = $ModelPanda
        model_delta = $ModelDelta
        model_gwagen = $ModelGwagen
        
    if model_panda: model_panda.visible = (model_id == "panda_4x4")
    if model_delta: model_delta.visible = (model_id == "delta_integrale")
    if model_gwagen: model_gwagen.visible = (model_id == "mercedes_gwagen")
    
    # 4. Audio Engine Model Switch
    if audio_engine and audio_engine.has_method("set_sound_profile"):
        audio_engine.set_sound_profile(model_id)

func _physics_process(delta: float):
    var cfg = VEHICLE_CATALOG[current_model_id]
    
    # 1. Player Input
    var throttle_input = Input.get_action_strength("accelerate")
    var brake_input = Input.get_action_strength("brake")
    var steer_input = Input.get_axis("steer_right", "steer_left")
    var handbrake = Input.is_action_pressed("handbrake")
    
    if Input.is_action_just_pressed("toggle_lights"):
        headlights_on = !headlights_on
        update_headlights()
        
    if Input.is_action_just_pressed("toggle_4wd"):
        is_4wd_engaged = !is_4wd_engaged
        
    if Input.is_action_just_pressed("change_vehicle"):
        switch_vehicle()

    current_speed_kmh = linear_velocity.length() * 3.6
    
    # 2. Progressive non-linear steering filter (speed-dependent)
    var max_angle = cfg.steer_angle
    var speed_steer_factor = clamp(1.0 - (current_speed_kmh / 160.0) * 0.65, 0.28, 1.0)
    var target_steer = steer_input * deg_to_rad(max_angle) * speed_steer_factor
    steering = lerp(steering, target_steer, delta * 12.0)
    
    # 3. Transmission & Engine RPM Simulation
    update_transmission(throttle_input, current_speed_kmh, cfg)
    
    # 4. Turbo boost simulation (Garrett T3 on Lancia Delta)
    if cfg.has_turbo:
        var target_boost = 0.0
        if throttle_input > 0.08 and engine_rpm > 2100.0:
            var spool = clamp((engine_rpm - 2100.0) / 3600.0, 0.0, 1.0)
            target_boost = throttle_input * cfg.turbo_boost_max * spool
        current_boost_bar = lerp(current_boost_bar, target_boost, delta * 4.2)
    else:
        current_boost_bar = 0.0
        
    # 5. Engine Torque & Drivetrain Distribution
    var gear_ratios = cfg.gear_ratios
    var current_ratio = gear_ratios[current_gear - 1]
    var base_torque = throttle_input * cfg.engine_force * (current_ratio / 2.4)
    if cfg.has_turbo:
        base_torque += current_boost_bar * 420.0 # Turbo overboost kick!
        
    var engine_torque = base_torque
    var is_reversing = false
    
    if brake_input > 0.3 and current_speed_kmh < 3.0:
        is_reversing = true
        engine_torque = -brake_input * cfg.engine_force * 0.55
        gear_name = "R"
        
    # Fuel consumption
    if throttle_input > 0.05 or is_reversing:
        current_fuel = max(0.0, current_fuel - delta * 0.0035 * (engine_rpm / 3000.0))
        if current_fuel <= 0.0:
            engine_torque = 0.0
            
    # Apply drive torque to wheels based on car drivetrain
    if current_model_id == "delta_integrale":
        # Torsen AWD 47:53 split permanent
        wheel_fl.engine_force = engine_torque * 0.235
        wheel_fr.engine_force = engine_torque * 0.235
        wheel_rl.engine_force = engine_torque * 0.265
        wheel_rr.engine_force = engine_torque * 0.265
    elif current_model_id == "mercedes_gwagen":
        if is_4wd_engaged:
            # 3x diff lock rigid 50:50
            wheel_fl.engine_force = engine_torque * 0.25
            wheel_fr.engine_force = engine_torque * 0.25
            wheel_rl.engine_force = engine_torque * 0.25
            wheel_rr.engine_force = engine_torque * 0.25
        else:
            # RWD mode
            wheel_fl.engine_force = 0.0
            wheel_fr.engine_force = 0.0
            wheel_rl.engine_force = engine_torque * 0.50
            wheel_rr.engine_force = engine_torque * 0.50
    else:
        # Panda 4x4 Steyr-Puch 4WD
        if is_4wd_engaged:
            wheel_fl.engine_force = engine_torque * 0.25
            wheel_fr.engine_force = engine_torque * 0.25
            wheel_rl.engine_force = engine_torque * 0.25
            wheel_rr.engine_force = engine_torque * 0.25
        else:
            wheel_fl.engine_force = engine_torque * 0.50
            wheel_fr.engine_force = engine_torque * 0.50
            wheel_rl.engine_force = 0.0
            wheel_rr.engine_force = 0.0
            
    # 6. Braking
    var max_brake = cfg.brake_force
    var brake_torque = 0.0 if is_reversing else (brake_input * max_brake)
    if handbrake:
        brake_torque = max_brake * 1.8
        wheel_rl.brake = brake_torque
        wheel_rr.brake = brake_torque
    else:
        wheel_fl.brake = brake_torque * 0.65
        wheel_fr.brake = brake_torque * 0.65
        wheel_rl.brake = brake_torque * 0.35
        wheel_rr.brake = brake_torque * 0.35
        
    if taillight_l and taillight_r:
        var is_braking = brake_input > 0.1 || handbrake
        taillight_l.light_energy = 3.5 if is_braking else (0.8 if headlights_on else 0.0)
        taillight_r.light_energy = 3.5 if is_braking else (0.8 if headlights_on else 0.0)

    # 7. Hazard Lights
    if hazard_lights_on:
        hazard_timer += delta
        if hazard_timer >= 0.36:
            hazard_timer = 0.0
            hazard_state = !hazard_state
            set_hazard_mesh_visible(hazard_state)
    else:
        set_hazard_mesh_visible(false)

    # 8. Pitch & Roll
    var pitch_deg = rad_to_deg(rotation.x)
    var roll_deg = rad_to_deg(rotation.z)
    
    # Emit live telemetry with model_info
    var rpm_norm = clamp((engine_rpm - cfg.idle_rpm) / (cfg.redline_rpm - cfg.idle_rpm), 0.0, 1.0)
    emit_signal("telemetry_updated", current_speed_kmh, rpm_norm, gear_name, current_fuel, engine_temp, pitch_deg, roll_deg, is_4wd_engaged, current_boost_bar, cfg)

func update_transmission(throttle: float, speed: float, cfg: Dictionary):
    var top_spd = cfg.top_speed
    var step = top_spd / 5.0
    
    if speed < step * 0.22:
        current_gear = 1
        gear_name = "D1 (CRAWLER)" if (current_model_id == "panda_4x4") else "D1"
    elif speed < step * 0.44:
        current_gear = 2
        gear_name = "D2"
    elif speed < step * 0.70:
        current_gear = 3
        gear_name = "D3"
    elif speed < step * 1.05:
        current_gear = 4
        gear_name = "D4"
    else:
        current_gear = 5
        gear_name = "D5"
        
    var gear_ratio = cfg.gear_ratios[current_gear - 1]
    var target_rpm = cfg.idle_rpm + (speed / top_spd) * (cfg.redline_rpm - cfg.idle_rpm) * (gear_ratio / 1.6)
    if throttle > 0.1:
        target_rpm += throttle * 550.0
    engine_rpm = lerp(engine_rpm, clamp(target_rpm, cfg.idle_rpm, cfg.redline_rpm), 0.14)

func update_headlights():
    if headlight_l and headlight_r:
        headlight_l.visible = headlights_on
        headlight_r.visible = headlights_on

func set_hazard_mesh_visible(visible_state: bool):
    for h in [hazard_fl, hazard_fr, hazard_rl, hazard_rr]:
        if h: h.visible = visible_state
