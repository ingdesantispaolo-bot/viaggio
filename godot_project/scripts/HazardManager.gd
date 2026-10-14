extends Node3D
class_name HazardManager

# THE LONG MERIDIAN - Highway Scenario & Road Event Director (Godot 4)
# Spawns authentic, spaced road events (Roadworks with interactive physics cones,
# disabled vehicles with flashing hazards, rockfall boulders in the lane, oil slicks, fallen timber).

@export var road_generator: Node3D
@export var spawn_interval: float = 340.0 # Spaced every 280-400m for realistic mountain drive feel
@export var enabled: bool = false # Disabled by default so random obstacles DO NOT block normal roads

var next_hazard_z: float = 240.0
var active_scenarios: Array = []
var slippery_patches: Array = []

func update_hazards(player_z: float):
	if not enabled:
		for i in range(active_scenarios.size() - 1, -1, -1):
			var sc = active_scenarios[i]
			if sc.get("node") and is_instance_valid(sc.node):
				sc.node.queue_free()
			active_scenarios.remove_at(i)
		slippery_patches.clear()
		return
		
	# Spawn upcoming scenarios ahead
	while next_hazard_z < player_z + 320.0:
		spawn_highway_scenario(next_hazard_z)
		next_hazard_z += spawn_interval + randf_range(-60.0, 60.0)
		
	# Despawn scenarios left behind
	for i in range(active_scenarios.size() - 1, -1, -1):
		var sc = active_scenarios[i]
		if sc.z < player_z - 90.0:
			sc.node.queue_free()
			active_scenarios.remove_at(i)
			
	for j in range(slippery_patches.size() - 1, -1, -1):
		if slippery_patches[j].z < player_z - 90.0:
			slippery_patches.remove_at(j)

func spawn_highway_scenario(z: float):
	if not road_generator: return
	var r_info = road_generator.get_road_info_at(z)
	var half_w = r_info.width * 0.5
	var side = -1.0 if randf() < 0.5 else 1.0 # Closed lane (-1 left, +1 right)
	
	var roll = randf()
	var scenario_node = Node3D.new()
	
	if roll < 0.30:
		build_roadworks_zone(scenario_node, z, side, r_info)
	elif roll < 0.50:
		build_oil_slick_hazard(scenario_node, z, side, r_info)
	elif roll < 0.70:
		build_rockfall_scree(scenario_node, z, side, r_info)
	elif roll < 0.85:
		build_disabled_vehicle(scenario_node, z, side, r_info)
	else:
		build_fallen_timber_hazard(scenario_node, z, side, r_info)
		
	add_child(scenario_node)
	active_scenarios.append({ "z": z, "node": scenario_node })

func build_roadworks_zone(root: Node3D, z: float, side: float, r_info: Dictionary):
	var half_w = r_info.width * 0.5
	var closed_x = r_info.x + side * (half_w * 0.48)
	var y = r_info.y
	
	# 1. Cartello lavori in corso su banchina esterna (+1.45m fuori dall'asfalto, campionato a Z esatto)
	var sign_z = z - 110.0
	var s_info = road_generator.get_road_info_at(sign_z) if road_generator else r_info
	var sign_x = s_info.x + side * (s_info.width * 0.5 + 1.45)
	var sign = create_warning_sign(sign_x, s_info.y, sign_z, "LAVORI IN CORSO", s_info.angle)
	root.add_child(sign)
	
	# 2. Coni stradali fisici abbattibili (RigidBody3D) che delimitano la corsia chiusa
	for k in range(7):
		var t = float(k) / 6.0
		var cone_z = z - 38.0 + t * 28.0
		var c_road = road_generator.get_road_info_at(cone_z) if road_generator else r_info
		var cone_x = c_road.x + side * (c_road.width * 0.5 * 0.78 - t * (c_road.width * 0.5 * 0.56))
		var cone = create_traffic_cone_rigidbody(cone_x, c_road.y, cone_z)
		root.add_child(cone)
		
	# 3. Carrello freccia luminosa a Z - 9m
	var trailer = create_arrow_trailer(closed_x, y, z - 9.0, -side, r_info.angle)
	root.add_child(trailer)

func build_oil_slick_hazard(root: Node3D, z: float, side: float, r_info: Dictionary):
	var half_w = r_info.width * 0.5
	var lane_x = r_info.x + side * (half_w * 0.45)
	var y = r_info.y
	
	# Cartello di pericolo fondo viscido su banchina esterna (+1.45m fuori asfalto)
	var sign_z = z - 75.0
	var s_info = road_generator.get_road_info_at(sign_z) if road_generator else r_info
	var sign_x = s_info.x + side * (s_info.width * 0.5 + 1.45)
	var sign = create_warning_sign(sign_x, s_info.y, sign_z, "FONDO VISCIDO", s_info.angle)
	root.add_child(sign)
	
	# Macchia d'olio / pozzanghera viscida sull'asfalto
	var slick_mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 2.2; cyl.bottom_radius = 2.0; cyl.height = 0.02
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.04, 0.05, 0.06, 0.95)
	mat.roughness = 0.04 # Altamente riflettente / viscido
	mat.metallic = 0.85
	cyl.material = mat
	slick_mesh.mesh = cyl
	slick_mesh.position = Vector3(lane_x, y + 0.015, z)
	slick_mesh.scale = Vector3(1.0, 1.0, 1.8) # Allungata in direzione di marcia
	root.add_child(slick_mesh)
	
	slippery_patches.append({
		"x": lane_x,
		"z": z,
		"radius": 2.4,
		"friction": 0.28
	})

func build_rockfall_scree(root: Node3D, z: float, side: float, r_info: Dictionary):
	var half_w = r_info.width * 0.5
	var lane_x = r_info.x + side * (half_w * 0.45)
	var y = r_info.y
	
	# Cartello caduta massi su banchina esterna (+1.45m fuori asfalto)
	var sign_z = z - 80.0
	var s_info = road_generator.get_road_info_at(sign_z) if road_generator else r_info
	var sign_x = s_info.x + side * (s_info.width * 0.5 + 1.45)
	var sign = create_warning_sign(sign_x, s_info.y, sign_z, "CADUTA MASSI", s_info.angle)
	root.add_child(sign)
	
	# Masso principale sulla corsia con collisione fisica
	var rock_rb = RigidBody3D.new()
	rock_rb.mass = 450.0
	rock_rb.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	rock_rb.center_of_mass = Vector3(0, 0.15, 0)
	
	var col = CollisionShape3D.new()
	var s_shape = SphereShape3D.new()
	s_shape.radius = 0.55
	col.shape = s_shape
	col.position.y = 0.50
	rock_rb.add_child(col)
	
	var r_mesh = MeshInstance3D.new()
	var sph = SphereMesh.new()
	sph.radius = 0.55; sph.height = 0.95
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.38, 0.36, 0.34)
	mat.roughness = 0.92
	sph.material = mat
	r_mesh.mesh = sph
	r_mesh.position.y = 0.50
	rock_rb.add_child(r_mesh)
	
	rock_rb.position = Vector3(lane_x, y, z)
	root.add_child(rock_rb)
	
	# Pietrisco e ciottoli sparsi sulla banchina
	for p in range(4):
		var sm_rock = MeshInstance3D.new()
		var s_sm = SphereMesh.new()
		s_sm.radius = randf_range(0.18, 0.30); s_sm.height = s_sm.radius * 1.6
		s_sm.material = mat
		sm_rock.mesh = s_sm
		sm_rock.position = Vector3(lane_x + randf_range(-0.8, 0.8), y + 0.15, z + randf_range(-3.0, 3.0))
		root.add_child(sm_rock)

func build_fallen_timber_hazard(root: Node3D, z: float, side: float, r_info: Dictionary):
	var half_w = r_info.width * 0.5
	var lane_x = r_info.x + side * (half_w * 0.38)
	var y = r_info.y
	
	var log_rb = RigidBody3D.new()
	log_rb.mass = 180.0
	
	var col = CollisionShape3D.new()
	var c_shape = BoxShape3D.new()
	c_shape.size = Vector3(2.4, 0.40, 0.45)
	col.shape = c_shape
	col.position.y = 0.22
	log_rb.add_child(col)
	
	var l_mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.20; cyl.bottom_radius = 0.24; cyl.height = 2.4
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.26, 0.18, 0.12) # Corteccia pino
	mat.roughness = 0.94
	cyl.material = mat
	l_mesh.mesh = cyl
	l_mesh.rotation.z = deg_to_rad(90.0)
	l_mesh.position.y = 0.22
	log_rb.add_child(l_mesh)
	
	log_rb.position = Vector3(lane_x, y, z)
	log_rb.rotation.y = deg_to_rad(randf_range(-25.0, 25.0))
	root.add_child(log_rb)

func build_disabled_vehicle(root: Node3D, z: float, side: float, r_info: Dictionary):
	var half_w = r_info.width * 0.5
	var shoulder_x = r_info.x + side * (half_w * 0.76)
	var y = r_info.y
	
	# 1. Triangolo d'emergenza catarifrangente a 38m su banchina esterna
	var tri_z = z - 38.0
	var tri_info = road_generator.get_road_info_at(tri_z) if road_generator else r_info
	var triangle = create_emergency_triangle(tri_info.x + side * (tri_info.width * 0.5 + 0.45), tri_info.y, tri_z)
	root.add_child(triangle)
	
	# 2. Vettura ferma con 4 frecce
	var car = Node3D.new()
	var car_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(1.75, 1.35, 4.2)
	var c_mat = StandardMaterial3D.new()
	c_mat.albedo_color = Color(0.18, 0.28, 0.38) # Blu scuro
	c_mat.roughness = 0.40
	box.material = c_mat
	car_mesh.mesh = box
	car_mesh.position.y = 0.7
	car.add_child(car_mesh)
	
	# Luci 4 frecce lampeggianti
	var blinker = OmniLight3D.new()
	blinker.light_color = Color(1.0, 0.6, 0.0)
	blinker.light_energy = 3.5
	blinker.position.y = 1.0
	car.add_child(blinker)
	
	# Collisione solida
	var sb = StaticBody3D.new()
	var sc = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = Vector3(1.85, 1.45, 4.3)
	sc.shape = bs
	sc.position.y = 0.7
	sb.add_child(sc)
	car.add_child(sb)
	
	car.position = Vector3(shoulder_x, y, z)
	car.rotation.y = r_info.angle + (0.1 if side < 0 else -0.1)
	root.add_child(car)

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

func create_warning_sign(x: float, y: float, z: float, _label: String, rot_y: float = 0.0) -> Node3D:
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
	
	var pole = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.03; cyl.bottom_radius = 0.03; cyl.height = 1.8
	pole.mesh = cyl
	pole.position.y = 0.9
	sign_node.add_child(pole)
	
	sign_node.position = Vector3(x, y, z)
	sign_node.rotation.y = rot_y
	return sign_node

func create_arrow_trailer(x: float, y: float, z: float, _arrow_dir: float, angle: float) -> Node3D:
	var trailer = Node3D.new()
	
	# 1. Steel Chassis & Tow Frame resting on ground
	var frame = MeshInstance3D.new()
	var f_box = BoxMesh.new()
	f_box.size = Vector3(1.7, 0.15, 2.2)
	var steel_mat = StandardMaterial3D.new()
	steel_mat.albedo_color = Color(0.72, 0.74, 0.76)
	steel_mat.metallic = 0.8
	steel_mat.roughness = 0.3
	frame.mesh = f_box
	frame.material_override = steel_mat
	frame.position.y = 0.32
	trailer.add_child(frame)
	
	# Tow Hitch Bar
	var hitch = MeshInstance3D.new()
	var h_box = BoxMesh.new()
	h_box.size = Vector3(0.12, 0.10, 1.2)
	hitch.mesh = h_box
	hitch.material_override = steel_mat
	hitch.position = Vector3(0.0, 0.30, -1.6)
	trailer.add_child(hitch)
	
	# 2. Road Wheels (Left & Right)
	var tire_mat = StandardMaterial3D.new()
	tire_mat.albedo_color = Color(0.15, 0.15, 0.16)
	tire_mat.roughness = 0.95
	for w_side in [-0.95, 0.95]:
		var wheel = MeshInstance3D.new()
		var w_cyl = CylinderMesh.new()
		w_cyl.top_radius = 0.28
		w_cyl.bottom_radius = 0.28
		w_cyl.height = 0.18
		wheel.mesh = w_cyl
		wheel.material_override = tire_mat
		wheel.rotation.z = PI * 0.5
		wheel.position = Vector3(w_side, 0.28, 0.1)
		trailer.add_child(wheel)
		
	# Ground Stabilizer Support Legs
	for leg_z in [-0.9, 0.9]:
		var leg = MeshInstance3D.new()
		var l_cyl = CylinderMesh.new()
		l_cyl.top_radius = 0.03
		l_cyl.bottom_radius = 0.04
		l_cyl.height = 0.32
		leg.mesh = l_cyl
		leg.material_override = steel_mat
		leg.position = Vector3(0.0, 0.16, leg_z)
		trailer.add_child(leg)
		
	# 3. Twin Vertical Support Poles
	for p_x in [-0.55, 0.55]:
		var pole = MeshInstance3D.new()
		var p_cyl = CylinderMesh.new()
		p_cyl.top_radius = 0.04
		p_cyl.bottom_radius = 0.04
		p_cyl.height = 1.4
		pole.mesh = p_cyl
		pole.material_override = steel_mat
		pole.position = Vector3(p_x, 1.0, 0.0)
		trailer.add_child(pole)
		
	# 4. Sign Board Backing (High-Visibility Roadworks Yellow with Red/White Stripes)
	var board = MeshInstance3D.new()
	var b_mesh = BoxMesh.new()
	b_mesh.size = Vector3(1.6, 1.2, 0.08)
	var board_mat = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.95, 0.82, 0.10)
	board_mat.roughness = 0.5
	board.mesh = b_mesh
	board.material_override = board_mat
	board.position.y = 1.70
	trailer.add_child(board)
	
	# High-Contrast Black Center Display Panel
	var panel = MeshInstance3D.new()
	var p_mesh = BoxMesh.new()
	p_mesh.size = Vector3(1.4, 1.0, 0.04)
	var pan_mat = StandardMaterial3D.new()
	pan_mat.albedo_color = Color(0.06, 0.07, 0.08)
	pan_mat.roughness = 0.8
	panel.mesh = p_mesh
	panel.material_override = pan_mat
	panel.position = Vector3(0.0, 1.70, 0.04)
	trailer.add_child(panel)
	
	# 5. Glowing Directional Chevron Arrow (Amber LEDs)
	var arrow = MeshInstance3D.new()
	var a_mesh = BoxMesh.new()
	a_mesh.size = Vector3(0.85, 0.22, 0.06)
	var a_mat = StandardMaterial3D.new()
	a_mat.albedo_color = Color(1.0, 0.75, 0.05)
	a_mat.emission_enabled = true
	a_mat.emission = Color(1.0, 0.75, 0.05)
	a_mat.emission_energy_multiplier = 2.4
	arrow.mesh = a_mesh
	arrow.material_override = a_mat
	arrow.position = Vector3(0.0, 1.70, 0.08)
	arrow.rotation.z = deg_to_rad(45.0 if _arrow_dir > 0 else -45.0)
	trailer.add_child(arrow)
	
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

func get_slippery_factor(pos: Vector3) -> float:
	for p in slippery_patches:
		if abs(pos.z - p.z) <= p.radius:
			var dx = pos.x - p.x
			var dz = pos.z - p.z
			if (dx * dx + dz * dz) <= p.radius * p.radius:
				return p.friction
	return 1.0
