extends Camera3D
class_name CameraController

# THE LONG MERIDIAN - Art of Rally 3/4 Diorama Follow Camera (Godot 4)
# Tracks the vehicle along the highway with silky smooth asymptotic damping,
# dynamic lookahead, speed-dependent FOV expansion, and trauma screen shake.

@export var target_node: Node3D
@export var road_generator: Node3D

@export var base_offset: Vector3 = Vector3(0.0, 20.8, -17.2)
@export var base_lookahead: float = 21.0
@export var pos_damping: float = 6.2
@export var rot_damping: float = 4.5

var current_heading: float = 0.0
var trauma: float = 0.0
var shake_offset: Vector3 = Vector3.ZERO

func _ready():
    fov = 48.0
    if target_node:
        position = target_node.position + base_offset
        look_at(target_node.position + Vector3(0, 1.2, base_lookahead), Vector3.UP)

func add_trauma(amount: float):
    trauma = clamp(trauma + amount, 0.0, 1.0)

func _process(delta: float):
    if not target_node:
        return
        
    var target_pos = target_node.global_position
    var speed_ms = 0.0
    if target_node is VehicleBody3D:
        speed_ms = target_node.linear_velocity.length()
        
    var speed_ratio = clamp(speed_ms / 35.0, 0.0, 1.6)
    
    # 1. Dynamic FOV (48 deg at rest to 53 deg at 125 km/h)
    var target_fov = 48.0 + speed_ratio * 4.5
    fov = lerp(fov, target_fov, delta * 4.0)
    
    # 2. Heading interpolation (blend road angle 70% and vehicle yaw 30%)
    var road_angle = 0.0
    if road_generator and road_generator.has_method("get_road_info_at"):
        var r_info = road_generator.get_road_info_at(target_pos.z)
        if r_info.has("angle"):
            road_angle = r_info.angle
            
    var vehicle_yaw = target_node.rotation.y
    var effective_heading = road_angle * 0.70 + vehicle_yaw * 0.30
    
    var angle_diff = wrapf(effective_heading - current_heading, -PI, PI)
    current_heading += angle_diff * clamp(delta * rot_damping, 0.0, 1.0)
    
    # 3. Dynamic distance & lookahead
    var dynamic_dist = abs(base_offset.z) + speed_ratio * 3.5
    var dynamic_height = base_offset.y + speed_ratio * 2.8
    var dynamic_lookahead = base_lookahead + speed_ratio * 10.0
    
    var sin_h = sin(current_heading)
    var cos_h = cos(current_heading)
    
    var desired_pos = Vector3(
        target_pos.x - sin_h * dynamic_dist,
        target_pos.y + dynamic_height,
        target_pos.z - cos_h * dynamic_dist
    )
    
    var desired_lookat = Vector3(
        target_pos.x + sin_h * dynamic_lookahead,
        target_pos.y + 1.2,
        target_pos.z + cos_h * dynamic_lookahead
    )
    
    # 4. Trauma Screen Shake
    if trauma > 0.0:
        var shake_mag = pow(trauma, 2.0) * 1.5
        shake_offset = Vector3(
            randf_range(-1.0, 1.0) * shake_mag,
            randf_range(-0.5, 0.5) * shake_mag,
            randf_range(-1.0, 1.0) * shake_mag
        )
        trauma = max(0.0, trauma - delta * 1.8)
    else:
        shake_offset = Vector3.ZERO
        
    # 5. Position & LookAt Damping
    global_position.z = lerp(global_position.z, desired_pos.z, delta * 22.0)
    global_position.x = lerp(global_position.x, desired_pos.x, delta * pos_damping)
    global_position.y = lerp(global_position.y, desired_pos.y, delta * pos_damping * 1.2)
    
    global_position += shake_offset
    look_at(desired_lookat, Vector3.UP)
