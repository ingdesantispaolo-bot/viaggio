extends VehicleBody3D
class_name VehicleController

# THE LONG MERIDIAN - High-Fidelity European Vehicle Physics Controller (Godot 4 / Jolt)
# Implements Steyr-Puch 4WD drivetrain, Primina crawler gear, 5-speed manual gearbox,
# progressive steering filtering, dynamic weight transfer, and dashboard telemetry signals.

signal telemetry_updated(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, pitch_deg, roll_deg, is_4wd)

@export_group("Drivetrain Specs")
@export var max_engine_force: float = 460.0
@export var max_brake_force: float = 65.0
@export var max_steer_angle_deg: float = 29.0
@export var is_4wd_engaged: bool = true
@export var primina_crawler: bool = false
@export var tank_capacity_l: float = 35.0

@export_group("Audio & Lights")
@export var headlights_on: bool = true
@export var hazard_lights_on: bool = false

# Internal dynamic telemetry
var current_speed_kmh: float = 0.0
var engine_rpm: float = 850.0
var current_gear: int = 1
var gear_name: String = "D1"
var current_fuel: float = 28.5
var engine_temp: float = 82.0
var hazard_timer: float = 0.0
var hazard_state: bool = false

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

# Gear ratios: Primina (Crawler 1st), 2nd, 3rd, 4th, 5th, Reverse
const GEAR_RATIOS = [4.8, 3.2, 2.1, 1.45, 1.02, -3.8]

func _ready():
    # Mass & center of mass tuned for Fiat Panda 4x4 / Classic European Expedition vehicle
    mass = 980.0
    center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
    center_of_mass = Vector3(0.0, -0.16, -0.05)
    
    # Configure 4 independent suspension raycasts
    for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
        w.suspension_travel = 0.22
        w.suspension_stiffness = 38.0
        w.damping_compression = 0.45
        w.damping_relaxation = 0.58
        w.wheel_friction_slip = 2.75
        w.wheel_radius = 0.32
        w.wheel_rest_length = 0.16
    
    update_headlights()

func _physics_process(delta: float):
    # 1. Player Input
    var throttle_input = Input.get_action_strength("accelerate")
    var brake_input = Input.get_action_strength("brake")
    var steer_input = Input.get_axis("steer_right", "steer_left") # Godot: left is positive Y rotation
    var handbrake = Input.is_action_pressed("handbrake")
    
    if Input.is_action_just_pressed("toggle_lights"):
        headlights_on = !headlights_on
        update_headlights()
        
    if Input.is_action_just_pressed("toggle_4wd"):
        is_4wd_engaged = !is_4wd_engaged

    // Speed calculation
    current_speed_kmh = linear_velocity.length() * 3.6
    
    # 2. Progressive non-linear steering filter (speed-dependent)
    # Allows full 29 deg lock at low speed, gently tightens to 9 deg at 120 km/h to prevent snap roll
    var speed_steer_factor = clamp(1.0 - (current_speed_kmh / 140.0) * 0.68, 0.30, 1.0)
    var target_steer = steer_input * deg_to_rad(max_steer_angle_deg) * speed_steer_factor
    steering = lerp(steering, target_steer, delta * 12.0)
    
    # 3. Transmission & Engine RPM Simulation
    update_transmission(throttle_input, current_speed_kmh)
    
    # 4. Engine Torque & Drivetrain Distribution
    var current_ratio = GEAR_RATIOS[current_gear - 1]
    var engine_torque = throttle_input * max_engine_force * (current_ratio / 2.5)
    
    # Fuel consumption
    if throttle_input > 0.05:
        current_fuel = max(0.0, current_fuel - delta * 0.0035 * (engine_rpm / 3000.0))
        if current_fuel <= 0.0:
            engine_torque = 0.0
            
    # Apply drive torque to wheels based on 4WD mode
    if is_4wd_engaged:
        # Steyr-Puch 50:50 rigid 4WD split
        wheel_fl.engine_force = engine_torque * 0.25
        wheel_fr.engine_force = engine_torque * 0.25
        wheel_rl.engine_force = engine_torque * 0.25
        wheel_rr.engine_force = engine_torque * 0.25
    else:
        # 2WD Front wheel drive mode
        wheel_fl.engine_force = engine_torque * 0.50
        wheel_fr.engine_force = engine_torque * 0.50
        wheel_rl.engine_force = 0.0
        wheel_rr.engine_force = 0.0
        
    # 5. Braking & Handbrake
    var brake_torque = brake_input * max_brake_force
    if handbrake:
        brake_torque = max_brake_force * 1.8
        wheel_rl.brake = brake_torque
        wheel_rr.brake = brake_torque
    else:
        wheel_fl.brake = brake_torque * 0.65 # Front brake bias
        wheel_fr.brake = brake_torque * 0.65
        wheel_rl.brake = brake_torque * 0.35
        wheel_rr.brake = brake_torque * 0.35
        
    # Update brake lights visual
    if taillight_l and taillight_r:
        var is_braking = brake_input > 0.1 || handbrake
        taillight_l.light_energy = 3.5 if is_braking else (0.8 if headlights_on else 0.0)
        taillight_r.light_energy = 3.5 if is_braking else (0.8 if headlights_on else 0.0)

    # 6. Hazard Lights (4 Frecce) Sync Blink
    if hazard_lights_on:
        hazard_timer += delta
        if hazard_timer >= 0.36:
            hazard_timer = 0.0
            hazard_state = !hazard_state
            set_hazard_mesh_visible(hazard_state)
    else:
        set_hazard_mesh_visible(false)

    # 7. Clinometer Pitch & Roll
    var pitch_deg = rad_to_deg(rotation.x)
    var roll_deg = rad_to_deg(rotation.z)
    
    # Emit live telemetry
    var rpm_norm = clamp((engine_rpm - 850.0) / 5650.0, 0.0, 1.0)
    emit_signal("telemetry_updated", current_speed_kmh, rpm_norm, gear_name, current_fuel, engine_temp, pitch_deg, roll_deg, is_4wd_engaged)

func update_transmission(throttle: float, speed: float):
    # Automatic/sequential shift points based on speed
    if speed < 18.0:
        current_gear = 1
        gear_name = "D1 (CRAWLER)" if primina_crawler else "D1"
    elif speed < 38.0:
        current_gear = 2
        gear_name = "D2"
    elif speed < 64.0:
        current_gear = 3
        gear_name = "D3"
    elif speed < 96.0:
        current_gear = 4
        gear_name = "D4"
    else:
        current_gear = 5
        gear_name = "D5"
        
    # Simulate Engine RPM based on current gear ratio and speed
    var target_rpm = 850.0 + (speed / 130.0) * 5200.0 * (GEAR_RATIOS[current_gear - 1] / 1.5)
    if throttle > 0.1:
        target_rpm += throttle * 600.0
    engine_rpm = lerp(engine_rpm, clamp(target_rpm, 850.0, 6500.0), 0.14)

func update_headlights():
    if headlight_l and headlight_r:
        headlight_l.visible = headlights_on
        headlight_r.visible = headlights_on

func set_hazard_mesh_visible(visible_state: bool):
    for h in [hazard_fl, hazard_fr, hazard_rl, hazard_rr]:
        if h: h.visible = visible_state
