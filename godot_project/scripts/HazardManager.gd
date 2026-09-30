extends Node3D
class_name HazardManager

# THE LONG MERIDIAN - Highway Scenario & Road Event Director (Godot 4)
# Spawns authentic, spaced road events (Roadworks with interactive physics cones,
# disabled vehicles with flashing 4-way hazards & emergency triangles, alpine scree).

@export var road_generator: Node3D
@export var spawn_interval: float = 520.0 # Spaced every 450-680m for real road trip feel

var next_hazard_z: float = 280.0
var active_scenarios: Array = []

func update_hazards(player_z: float):
    # Spawn upcoming scenarios ahead
    while next_hazard_z < player_z + 320.0:
        spawn_highway_scenario(next_hazard_z)
        next_hazard_z += spawn_interval + randf_range(-110.0, 110.0)
        
    # Despawn scenarios left behind
    for i in range(active_scenarios.size() - 1, -1, -1):
        var sc = active_scenarios[i]
        if sc.z < player_z - 90.0:
            sc.node.queue_free()
            active_scenarios.remove_at(i)

func spawn_highway_scenario(z: float):
    if not road_generator: return
    var r_info = road_generator.get_road_info_at(z)
    var half_w = r_info.width * 0.5
    var side = -1.0 if randf() < 0.5 else 1.0 # Closed lane (-1 left, +1 right)
    
    var roll = randf()
    var scenario_node = Node3D.new()
    
    if roll < 0.55:
        build_roadworks_zone(scenario_node, z, side, r_info)
    elif roll < 0.85:
        build_disabled_vehicle(scenario_node, z, side, r_info)
    else:
        build_rockfall_scree(scenario_node, z, side, r_info)
        
    add_child(scenario_node)
    active_scenarios.append({ "z": z, "node": scenario_node })

func build_roadworks_zone(root: Node3D, z: float, side: float, r_info: Dictionary):
    var half_w = r_info.width * 0.5
    var closed_x = r_info.x + side * (half_w * 0.48)
    var shoulder_x = r_info.x + side * (half_w * 0.88)
    var y = r_info.y
    
    # 1. Advance warning sign at Z - 110m on shoulder
    var sign = create_warning_sign(shoulder_x, y, z - 110.0, "LAVORI IN CORSO")
    root.add_child(sign)
    
    # 2. Taper of 7 interactive knockable traffic cones (RigidBody3D)
    for k in range(7):
        var t = float(k) / 6.0
        var cone_z = z - 38.0 + t * 28.0
        var cone_x = r_info.x + side * (half_w * 0.78 - t * (half_w * 0.56))
        var cone = create_traffic_cone_rigidbody(cone_x, y, cone_z)
        root.add_child(cone)
        
    # 3. Flashing Arrow Trailer Board at Z - 9m on closed lane
    var trailer = create_arrow_trailer(closed_x, y, z - 9.0, -side, r_info.angle)
    root.add_child(trailer)

func build_disabled_vehicle(root: Node3D, z: float, side: float, r_info: Dictionary):
    var half_w = r_info.width * 0.5
    var shoulder_x = r_info.x + side * (half_w * 0.76)
    var y = r_info.y
    
    # 1. Red reflective emergency triangle 38m behind
    var triangle = create_emergency_triangle(r_info.x + side * (half_w * 0.82), y, z - 38.0)
    root.add_child(triangle)
    
    # 2. Broken down vehicle body
    var car = Node3D.new()
    var car_mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(1.75, 1.35, 4.2)
    car_mesh.mesh = box
    car_mesh.position.y = 0.7
    car.add_child(car_mesh)
    
    # 4-way hazard blinker omni lights
    var blinker = OmniLight3D.new()
    blinker.light_color = Color(1.0, 0.6, 0.0)
    blinker.light_energy = 3.0
    blinker.position.y = 1.0
    car.add_child(blinker)
    
    car.position = Vector3(shoulder_x, y, z)
    car.rotation.y = r_info.angle + (0.1 if side < 0 else -0.1)
    root.add_child(car)

func build_rockfall_scree(root: Node3D, z: float, side: float, r_info: Dictionary):
    var half_w = r_info.width * 0.5
    var shoulder_x = r_info.x + side * (half_w * 0.88)
    var lane_x = r_info.x + side * (half_w * 0.44)
    var y = r_info.y
    
    var sign = create_warning_sign(shoulder_x, y, z - 90.0, "CADUTA MASSI")
    root.add_child(sign)
    
    # Shoulder granite boulder
    var boulder = MeshInstance3D.new()
    var s = SphereMesh.new()
    s.radius = 1.2; s.height = 2.0
    boulder.mesh = s
    boulder.position = Vector3(shoulder_x, y + 0.9, z + 2.0)
    root.add_child(boulder)

func create_traffic_cone_rigidbody(x: float, y: float, z: float) -> RigidBody3D:
    var rb = RigidBody3D.new()
    rb.mass = 4.5
    rb.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
    rb.center_of_mass = Vector3(0, 0.08, 0)
    
    var col = CollisionShape3D.new()
    var c_shape = CylinderShape3D.new()
    c_shape.radius = 0.22; c_shape.height = 0.75
    col.shape = c_shape
    col.position.y = 0.38
    rb.add_child(col)
    
    var mesh = MeshInstance3D.new()
    var cone_mesh = CylinderMesh.new()
    cone_mesh.top_radius = 0.04; cone_mesh.bottom_radius = 0.20; cone_mesh.height = 0.72
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.35, 0.0)
    cone_mesh.material = mat
    mesh.mesh = cone_mesh
    mesh.position.y = 0.38
    rb.add_child(mesh)
    
    rb.position = Vector3(x, y, z)
    return rb

func create_warning_sign(x: float, y: float, z: float, _label: String) -> Node3D:
    var sign_node = Node3D.new()
    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(0.85, 0.85, 0.05)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.8, 0.1)
    box.material = mat
    mesh.mesh = box
    mesh.position.y = 1.8
    mesh.rotation.z = PI / 4.0 # Diamond orientation
    sign_node.add_child(mesh)
    
    sign_node.position = Vector3(x, y, z)
    return sign_node

func create_arrow_trailer(x: float, y: float, z: float, _arrow_dir: float, angle: float) -> Node3D:
    var trailer = Node3D.new()
    var board = MeshInstance3D.new()
    var b_mesh = BoxMesh.new()
    b_mesh.size = Vector3(1.6, 1.2, 0.1)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.08, 0.08, 0.1)
    b_mesh.material = mat
    board.mesh = b_mesh
    board.position.y = 1.4
    trailer.add_child(board)
    
    trailer.position = Vector3(x, y, z)
    trailer.rotation.y = angle
    return trailer

func create_emergency_triangle(x: float, y: float, z: float) -> Node3D:
    var tri = Node3D.new()
    var mesh = MeshInstance3D.new()
    var torus = TorusMesh.new()
    torus.inner_radius = 0.25; torus.outer_radius = 0.38
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.1, 0.1)
    mat.emission_enabled = true
    mat.emission = Color(1.0, 0.1, 0.1)
    torus.material = mat
    mesh.mesh = torus
    mesh.position.y = 0.4
    mesh.rotation.x = PI / 2.0
    tri.add_child(mesh)
    
    tri.position = Vector3(x, y, z)
    return tri
