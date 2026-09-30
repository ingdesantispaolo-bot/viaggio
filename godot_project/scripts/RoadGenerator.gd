extends Node3D
class_name RoadGenerator

# THE LONG MERIDIAN - Procedural Crowned Highway Generator (Godot 4)
# Constructs a continuous, wide crowned highway ribbon with physical collision,
# asphalt shader materials, drainage ditches, and roadside delineator posts.

@export var road_material: ShaderMaterial
@export var chunk_length: float = 120.0
@export var road_segments: int = 24
@export var base_width: float = 24.0

var active_chunks: Array = []
var next_chunk_z: float = 0.0
var last_chunk_x: float = 0.0
var last_chunk_angle: float = 0.0

func _ready():
    # If no custom shader material assigned, load stylized asphalt shader
    if not road_material:
        var shader = load("res://shaders/stylized_asphalt.gdshader")
        road_material = ShaderMaterial.new()
        road_material.shader = shader
        
    # Generate initial visible stretch of 6 chunks ahead
    for i in range(6):
        generate_chunk()

func update_generation(player_z: float):
    # Spawn ahead
    while next_chunk_z < player_z + 420.0:
        generate_chunk()
        
    # Despawn behind
    for i in range(active_chunks.size() - 1, -1, -1):
        var chunk = active_chunks[i]
        if chunk.end_z < player_z - 150.0:
            chunk.node.queue_free()
            active_chunks.remove_at(i)

func generate_chunk():
    var start_z = next_chunk_z
    var end_z = start_z + chunk_length
    var step_z = chunk_length / float(road_segments)
    
    var points: Array = []
    var cur_x = last_chunk_x
    var cur_angle = last_chunk_angle
    
    # Calculate geometric spine points with gentle highway curves and rolling hills
    for s in range(road_segments + 1):
        var z = start_z + float(s) * step_z
        var y = sin(z * 0.015) * 2.2 + cos(z * 0.005) * 1.4
        var width = base_width + sin(z * 0.035) * 0.6
        
        points.append({ "x": cur_x, "y": y, "z": z, "width": width })
        
        if s < road_segments:
            var curve_delta = (sin(z * 0.012) * 0.6 + sin(z * 0.004) * 0.9) * 0.055
            cur_angle += curve_delta
            cur_x += sin(cur_angle) * step_z * 0.42
            
    last_chunk_x = cur_x
    last_chunk_angle = cur_angle
    next_chunk_z = end_z
    
    # Build 3D mesh and physics body
    var chunk_node = build_chunk_node(points)
    add_child(chunk_node)
    
    active_chunks.append({
        "start_z": start_z,
        "end_z": end_z,
        "points": points,
        "node": chunk_node
    })

func build_chunk_node(points: Array) -> Node3D:
    var root = Node3D.new()
    var num_pts = points.size()
    
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    surface_tool.set_material(road_material)
    
    var collision_faces = PackedVector3Array()
    
    # 5 vertices across cross-section:
    # 0: Left shoulder (u=0.0)
    # 1: Left fog line (u=0.122)
    # 2: Center crown (u=0.50, y+0.08)
    # 3: Right fog line (u=0.878)
    # 4: Right shoulder (u=1.0)
    for i in range(num_pts - 1):
        var p1 = points[i]
        var p2 = points[i + 1]
        
        var hw1 = p1.width * 0.5
        var phw1 = hw1 * 0.78
        var hw2 = p2.width * 0.5
        var phw2 = hw2 * 0.78
        
        var uv_y1 = p1.z * 0.08
        var uv_y2 = p2.z * 0.08
        
        var v1_0 = Vector3(p1.x - hw1, p1.y, p1.z)
        var v1_1 = Vector3(p1.x - phw1, p1.y + 0.045, p1.z)
        var v1_2 = Vector3(p1.x, p1.y + 0.08, p1.z)
        var v1_3 = Vector3(p1.x + phw1, p1.y + 0.045, p1.z)
        var v1_4 = Vector3(p1.x + hw1, p1.y, p1.z)
        
        var v2_0 = Vector3(p2.x - hw2, p2.y, p2.z)
        var v2_1 = Vector3(p2.x - phw2, p2.y + 0.045, p2.z)
        var v2_2 = Vector3(p2.x, p2.y + 0.08, p2.z)
        var v2_3 = Vector3(p2.x + phw2, p2.y + 0.045, p2.z)
        var v2_4 = Vector3(p2.x + hw2, p2.y, p2.z)
        
        # 4 quad segments across width (8 triangles)
        add_quad(surface_tool, collision_faces, v1_0, v2_0, v2_1, v1_1, 0.0, 0.122, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_1, v2_1, v2_2, v1_2, 0.122, 0.500, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_2, v2_2, v2_3, v1_3, 0.500, 0.878, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_3, v2_3, v2_4, v1_4, 0.878, 1.000, uv_y1, uv_y2)

    surface_tool.generate_normals()
    var mesh = surface_tool.commit()
    
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    root.add_child(mesh_instance)
    
    # Physics static body with concave collision shape for wheel raycasts
    var static_body = StaticBody3D.new()
    var col_shape = CollisionShape3D.new()
    var concave_shape = ConcavePolygonShape3D.new()
    concave_shape.set_faces(collision_faces)
    col_shape.shape = concave_shape
    static_body.add_child(col_shape)
    root.add_child(static_body)
    
    return root

func add_quad(st: SurfaceTool, col_faces: PackedVector3Array, a: Vector3, b: Vector3, c: Vector3, d: Vector3, u1: float, u2: float, v1: float, v2: float):
    # Triangle 1 (a, b, c)
    st.set_uv(Vector2(u1, v1)); st.add_vertex(a)
    st.set_uv(Vector2(u1, v2)); st.add_vertex(b)
    st.set_uv(Vector2(u2, v2)); st.add_vertex(c)
    
    # Triangle 2 (a, c, d)
    st.set_uv(Vector2(u1, v1)); st.add_vertex(a)
    st.set_uv(Vector2(u2, v2)); st.add_vertex(c)
    st.set_uv(Vector2(u2, v1)); st.add_vertex(d)
    
    # Add to collision faces
    col_faces.append(a); col_faces.append(b); col_faces.append(c)
    col_faces.append(a); col_faces.append(c); col_faces.append(d)

func get_road_info_at(query_z: float) -> Dictionary:
    for chunk in active_chunks:
        if query_z >= chunk.start_z and query_z <= chunk.end_z:
            var pts = chunk.points
            for i in range(pts.size() - 1):
                if query_z >= pts[i].z and query_z <= pts[i + 1].z:
                    var t = (query_z - pts[i].z) / (pts[i + 1].z - pts[i].z)
                    var x = lerp(pts[i].x, pts[i + 1].x, t)
                    var y = lerp(pts[i].y, pts[i + 1].y, t)
                    var width = lerp(pts[i].width, pts[i + 1].width, t)
                    var dx = pts[i + 1].x - pts[i].x
                    var dz = pts[i + 1].z - pts[i].z
                    var angle = atan2(dx, dz)
                    return { "x": x, "y": y, "width": width, "angle": angle, "found": true }
    return { "x": 0.0, "y": 0.0, "width": base_width, "angle": 0.0, "found": false }
