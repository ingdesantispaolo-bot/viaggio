extends Node3D
class_name RoadGenerator

# THE LONG MERIDIAN - Procedural Crowned Highway & Countryside Generator (Godot 4)
# Constructs a continuous crowned highway ribbon with physical collision,
# stylized asphalt shader, grassy meadows, roadside guide posts, and pines.

@export var road_material: ShaderMaterial
@export var chunk_length: float = 120.0
@export var road_segments: int = 24
@export var base_width: float = 24.0

var active_chunks: Array = []
var next_chunk_z: float = 0.0
var last_chunk_x: float = 0.0
var last_chunk_angle: float = 0.0

var grass_material: StandardMaterial3D
var post_material: StandardMaterial3D
var pine_material: ShaderMaterial
var rock_material: StandardMaterial3D
var guardrail_material: StandardMaterial3D
var bush_material: ShaderMaterial
var crop_material: ShaderMaterial

func _ready():
    # If no custom shader material assigned, load stylized asphalt shader
    if not road_material:
        var shader = load("res://shaders/stylized_asphalt.gdshader")
        road_material = ShaderMaterial.new()
        road_material.shader = shader
        
    grass_material = StandardMaterial3D.new()
    grass_material.albedo_color = Color(0.26, 0.40, 0.23, 1.0)
    grass_material.roughness = 0.90
    grass_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    
    post_material = StandardMaterial3D.new()
    post_material.albedo_color = Color(0.92, 0.92, 0.92)
    post_material.roughness = 0.5
    
    # Load synchronized wind & vehicle wake shader for vegetation
    var foliage_shader = load("res://shaders/stylized_foliage.gdshader")
    
    pine_material = ShaderMaterial.new()
    pine_material.shader = foliage_shader
    pine_material.set_shader_parameter("base_foliage_color", Color(0.12, 0.24, 0.15))
    pine_material.set_shader_parameter("tip_foliage_color", Color(0.26, 0.46, 0.20))
    pine_material.set_shader_parameter("wind_amplitude", 0.15)
    pine_material.set_shader_parameter("wake_sensitivity", 1.1)
    
    bush_material = ShaderMaterial.new()
    bush_material.shader = foliage_shader
    bush_material.set_shader_parameter("base_foliage_color", Color(0.18, 0.32, 0.18))
    bush_material.set_shader_parameter("tip_foliage_color", Color(0.35, 0.52, 0.22))
    bush_material.set_shader_parameter("wind_amplitude", 0.18)
    bush_material.set_shader_parameter("wake_sensitivity", 1.4)
    
    # Dorfromantik golden crops & wildflower patches
    crop_material = ShaderMaterial.new()
    crop_material.shader = foliage_shader
    crop_material.set_shader_parameter("base_foliage_color", Color(0.68, 0.50, 0.18))
    crop_material.set_shader_parameter("tip_foliage_color", Color(0.94, 0.78, 0.30))
    crop_material.set_shader_parameter("wind_amplitude", 0.28)
    crop_material.set_shader_parameter("wake_sensitivity", 1.9)
    
    rock_material = StandardMaterial3D.new()
    rock_material.albedo_color = Color(0.38, 0.36, 0.35)
    rock_material.roughness = 0.92
    
    guardrail_material = StandardMaterial3D.new()
    guardrail_material.albedo_color = Color(0.72, 0.74, 0.76)
    guardrail_material.metallic = 0.85
    guardrail_material.roughness = 0.32
    
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
        var y = 0.0
        var width = base_width
        
        # Keep initial spawn area (first 50 meters) perfectly flat and straight
        if z > 50.0:
            var curve_z = z - 50.0
            y = sin(curve_z * 0.015) * 2.2 + (cos(curve_z * 0.005) - 1.0) * 1.4
            width = base_width + sin(curve_z * 0.035) * 0.6
            
        points.append({ "x": cur_x, "y": y, "z": z, "width": width })
        
        if s < road_segments and z > 50.0:
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
    
    # 1. Road surface
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    surface_tool.set_material(road_material)
    
    # 2. Side meadows (grass)
    var grass_tool = SurfaceTool.new()
    grass_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    grass_tool.set_material(grass_material)
    
    var collision_faces = PackedVector3Array()
    
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
        
        # 4 road quad segments across width (8 triangles)
        add_quad(surface_tool, collision_faces, v1_0, v2_0, v2_1, v1_1, 0.0, 0.122, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_1, v2_1, v2_2, v1_2, 0.122, 0.500, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_2, v2_2, v2_3, v1_3, 0.500, 0.878, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_3, v2_3, v2_4, v1_4, 0.878, 1.000, uv_y1, uv_y2)
        
        # Left grass meadow (width 42m)
        var grass_l1 = Vector3(p1.x - hw1 - 42.0, p1.y - 0.4, p1.z)
        var grass_l2 = Vector3(p2.x - hw2 - 42.0, p2.y - 0.4, p2.z)
        add_quad(grass_tool, collision_faces, grass_l1, grass_l2, v2_0, v1_0, 0.0, 1.0, uv_y1, uv_y2)
        
        # Right grass meadow (width 42m)
        var grass_r1 = Vector3(p1.x + hw1 + 42.0, p1.y - 0.4, p1.z)
        var grass_r2 = Vector3(p2.x + hw2 + 42.0, p2.y - 0.4, p2.z)
        add_quad(grass_tool, collision_faces, v1_4, v2_4, grass_r2, grass_r1, 0.0, 1.0, uv_y1, uv_y2)

    surface_tool.generate_normals()
    var mesh = surface_tool.commit()
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    root.add_child(mesh_instance)
    
    grass_tool.generate_normals()
    var grass_mesh = grass_tool.commit()
    var grass_instance = MeshInstance3D.new()
    grass_instance.mesh = grass_mesh
    grass_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    root.add_child(grass_instance)
    
    # Physics static body with concave collision shape for wheel raycasts
    var static_body = StaticBody3D.new()
    var col_shape = CollisionShape3D.new()
    var concave_shape = ConcavePolygonShape3D.new()
    concave_shape.set_faces(collision_faces)
    col_shape.shape = concave_shape
    static_body.add_child(col_shape)
    root.add_child(static_body)
    
    # Roadside delineator posts and pines
    spawn_roadside_props(root, points)
    
    return root

func spawn_roadside_props(root: Node3D, points: Array):
    var num_points = points.size()
    
    for i in range(0, num_points - 1, 3):
        var p = points[i]
        var p_next = points[min(i + 1, num_points - 1)]
        var hw = p.width * 0.5
        var hw_next = p_next.width * 0.5
        
        # 1. Delineator posts on shoulders every 3 steps (~15m)
        for side in [-1.0, 1.0]:
            var post = MeshInstance3D.new()
            var cyl = CylinderMesh.new()
            cyl.top_radius = 0.05; cyl.bottom_radius = 0.06; cyl.height = 0.88
            cyl.material = post_material
            post.mesh = cyl
            post.position = Vector3(p.x + side * (hw + 0.38), p.y + 0.44, p.z)
            root.add_child(post)
            
        # 2. Guardrails along mountain curves or scenic sections
        var is_curving = abs(p_next.x - p.x) > 0.08
        if is_curving or (i % 12 >= 6 and p.z > 60.0):
            var g_side = 1.0 if (p_next.x - p.x) >= 0.0 else -1.0
            var rail = MeshInstance3D.new()
            var box = BoxMesh.new()
            var seg_len = p_next.z - p.z
            box.size = Vector3(0.08, 0.32, seg_len * 1.05)
            box.material = guardrail_material
            rail.mesh = box
            var mid_x = lerp(p.x + g_side * (hw + 0.25), p_next.x + g_side * (hw_next + 0.25), 0.5)
            var mid_y = lerp(p.y, p_next.y, 0.5) + 0.50
            var mid_z = (p.z + p_next.z) * 0.5
            rail.position = Vector3(mid_x, mid_y, mid_z)
            rail.rotation.y = atan2(p_next.x - p.x, p_next.z - p.z)
            root.add_child(rail)
            
        # 3. Stylized conifer pines in outer meadows (varying sizes)
        if i % 6 == 0:
            for side in [-1.0, 1.0]:
                var pine = Node3D.new()
                var p_mesh = MeshInstance3D.new()
                var cone = CylinderMesh.new()
                var h = randf_range(3.8, 6.4)
                var r = h * 0.36
                cone.top_radius = 0.08; cone.bottom_radius = r; cone.height = h
                cone.material = pine_material
                p_mesh.mesh = cone
                p_mesh.position.y = h * 0.5
                pine.add_child(p_mesh)
                
                var dist_x = side * (hw + randf_range(8.0, 24.0))
                pine.position = Vector3(p.x + dist_x, p.y - 0.3, p.z + randf_range(-3.0, 3.0))
                root.add_child(pine)
                
        # 4. Alpine granite boulders and bushes
        if i % 8 == 2 and p.z > 40.0:
            var r_side = -1.0 if randf() < 0.5 else 1.0
            var rock = MeshInstance3D.new()
            var s = SphereMesh.new()
            var rock_r = randf_range(0.9, 1.8)
            s.radius = rock_r; s.height = rock_r * 1.5
            s.material = rock_material
            rock.mesh = s
            rock.position = Vector3(p.x + r_side * (hw + randf_range(6.0, 18.0)), p.y + rock_r * 0.4, p.z)
            root.add_child(rock)
            
            # Small alpine bush near rock
            var bush = MeshInstance3D.new()
            var b_sph = SphereMesh.new()
            b_sph.radius = 0.65; b_sph.height = 0.8
            b_sph.material = bush_material
            bush.mesh = b_sph
            bush.position = Vector3(rock.position.x + randf_range(-1.2, 1.2), p.y + 0.3, p.z + randf_range(-1.0, 1.0))
            root.add_child(bush)
            
        # 5. Dorfromantik roadside reactive crop patches & wildflowers
        if i % 2 == 0 and p.z > 20.0:
            for side in [-1.0, 1.0]:
                var crop_node = Node3D.new()
                var c_mesh = MeshInstance3D.new()
                var cyl = CylinderMesh.new()
                var cr_h = randf_range(0.95, 1.45)
                cyl.top_radius = 0.58; cyl.bottom_radius = 0.14; cyl.height = cr_h
                cyl.material = crop_material
                c_mesh.mesh = cyl
                c_mesh.position.y = cr_h * 0.5
                crop_node.add_child(c_mesh)
                
                # Close to the roadside verge so car wake visibly displaces them
                var c_dist = side * (hw + randf_range(1.1, 3.4))
                crop_node.position = Vector3(p.x + c_dist, p.y - 0.05, p.z + randf_range(-1.2, 1.2))
                root.add_child(crop_node)

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
