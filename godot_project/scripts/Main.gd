extends Node3D

# THE LONG MERIDIAN - Master Scene Coordinator (Godot 4)
# Coordinates vehicle physics, procedural road generation, hazard scenarios,
# diorama camera tracking, sunlight orientation, and dashboard telemetry.

@onready var vehicle: VehicleController = $Vehicle
@onready var road_gen: RoadGenerator = $RoadGenerator
@onready var hazard_mgr: HazardManager = $HazardManager
@onready var camera: CameraController = $CameraController
@onready var dashboard_ui: DashboardUI = $DashboardUI
@onready var sun_light: DirectionalLight3D = $SunLight

func _ready():
    # Connect vehicle live telemetry to dashboard UI
    if vehicle and dashboard_ui:
        vehicle.telemetry_updated.connect(dashboard_ui.update_telemetry)
        
    # Assign references to camera and hazards
    if camera and vehicle:
        camera.target_node = vehicle
        camera.road_generator = road_gen
        
    if hazard_mgr and road_gen:
        hazard_mgr.road_generator = road_gen

func _process(_delta: float):
    if not vehicle: return
    
    var player_z = vehicle.global_position.z
    
    # 1. Update procedural road streaming
    if road_gen:
        road_gen.update_generation(player_z)
        
    # 2. Update highway events & hazard scenarios
    if hazard_mgr:
        hazard_mgr.update_hazards(player_z)
        
    # 3. Directional sun follows vehicle along highway
    if sun_light:
        sun_light.global_position = Vector3(vehicle.global_position.x + 22.0, 45.0, player_z + 15.0)

func _unhandled_input(event: InputEvent):
    if event.is_action_pressed("toggle_fullscreen"):
        if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        else:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
