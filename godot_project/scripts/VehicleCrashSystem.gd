extends RefCounted
class_name VehicleCrashSystem

# ==============================================================================
# THE LONG MERIDIAN - REALISTIC INELASTIC VEHICLE CRASH & DEFORMATION SYSTEM
# ==============================================================================
# Rigorous Physical Principles:
# 1. Inelastic Momentum Conservation (Coefficient of Restitution e ~ 0.15)
# 2. Linear and Angular Momentum Exchange:
#    Delta v1 = -J / m1, Delta v2 = +J / m2
#    Delta omega1 = I1^-1 * (r1 x -J) -> Realistic Yaw Spin / Fishtail / Rollover Torque
# 3. Tangential Friction Impulse (Side Scrapes & Barrier Scrubbing)
# 4. Realistic Structural Crumple Deformation:
#    - Bumper crushing and angular skewing
#    - Hood buckling upward (Crumple zone hinge fold)
#    - Fender/Door indentation toward chassis centerline
#    - Mirror dislocation and shattered headlight filaments
# 5. Dynamic Civilian Traffic Crash Response (Traffic spins & deforms, not on rails!)
# ==============================================================================

static var spark_material: StandardMaterial3D = null
static var smoke_material: StandardMaterial3D = null

static func init_fx_materials():
	if spark_material != null: return
	
	spark_material = StandardMaterial3D.new()
	spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_material.albedo_color = Color(1.0, 0.75, 0.20)
	spark_material.emission_enabled = true
	spark_material.emission = Color(1.0, 0.85, 0.35)
	spark_material.emission_energy_multiplier = 3.5
	
	smoke_material = StandardMaterial3D.new()
	smoke_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_material.albedo_color = Color(0.85, 0.88, 0.92, 0.45)
	smoke_material.roughness = 0.95

# --- 1. RIGID BODY INELASTIC IMPACT CALCULATION (LAWS OF PHYSICS) ---
static func calculate_impact_impulse(
	m1: float, v1: Vector3,
	m2: float, v2: Vector3,
	contact_normal: Vector3,
	contact_point: Vector3,
	com1: Vector3,
	e_restitution: float = 0.15,
	friction_coeff: float = 0.45
) -> Dictionary:
	var n = contact_normal.normalized()
	var rel_v = v1 - v2
	var v_normal_mag = rel_v.dot(n)
	
	# If normal was provided pointing Body 1 -> Body 2, orient n against rel_v (closing)
	if v_normal_mag > 0.0 and rel_v.length_squared() > 0.001:
		n = -n
		v_normal_mag = rel_v.dot(n)
	
	# If bodies are separating, no impulse
	if v_normal_mag >= 0.0 or rel_v.length_squared() < 0.001:
		return { "impulse": Vector3.ZERO, "energy_dissipated": 0.0, "is_impact": false, "torque1": Vector3.ZERO }
		
	# Reduced / Effective mass
	var mu = m1 if m2 <= 0.0 or m2 > 100000.0 else (m1 * m2) / (m1 + m2)
	
	# Normal impulse magnitude (Jn)
	var j_n_mag = -(1.0 + e_restitution) * mu * v_normal_mag
	var j_normal = n * j_n_mag
	
	# Tangential friction impulse (Jt) - side scraping
	var v_tangent = rel_v - (n * v_normal_mag)
	var j_tangent = Vector3.ZERO
	if v_tangent.length_squared() > 0.001:
		var t_dir = v_tangent.normalized()
		var max_friction = friction_coeff * j_n_mag
		var friction_mag = min(max_friction, mu * v_tangent.length() * 0.85)
		j_tangent = -t_dir * friction_mag
		
	var total_impulse = j_normal + j_tangent
	
	# Dissipated deformation energy: Ediss = 1/2 * (1 - e^2) * mu * v_normal^2
	var energy_dissipated = 0.5 * (1.0 - (e_restitution * e_restitution)) * mu * (v_normal_mag * v_normal_mag)
	
	# Angular torque arm on Body 1
	var r1 = contact_point - com1
	var torque1 = r1.cross(-total_impulse)
	
	return {
		"impulse": total_impulse,
		"energy_dissipated": energy_dissipated,
		"v_impact_kmh": abs(v_normal_mag) * 3.6,
		"torque1": torque1,
		"is_impact": true
	}

# --- 2. PROGRESSIVE STRUCTURAL VEHICLE DEFORMATION ---
static func apply_structural_deformation(vehicle_node: Node3D, contact_point_global: Vector3, impact_kmh: float, impact_normal: Vector3):
	if vehicle_node == null or impact_kmh < 6.0:
		return
		
	# Transform contact point to vehicle local space
	var xform_inv = vehicle_node.global_transform.affine_inverse()
	var local_contact = xform_inv * contact_point_global
	var local_normal = (xform_inv.basis * impact_normal).normalized()
	
	# Intrusion crush depth (proportional to physical impact severity)
	var crush_depth = clamp((impact_kmh - 5.0) * 0.009, 0.05, 0.55) # 5cm to 55cm
	
	# Find active vehicle model rig
	var model_root = find_vehicle_model_root(vehicle_node)
	if model_root == null:
		return
		
	# Spawn impact sparks & smoke particles
	spawn_crash_sparks(vehicle_node, contact_point_global, local_normal, impact_kmh)
	if impact_kmh > 35.0:
		spawn_radiator_steam(vehicle_node, contact_point_global)
		
	# Progressive deformation of individual mechanical & bodywork parts
	var parts = model_root.get_children()
	for p in parts:
		if not (p is Node3D): continue
		var p_name = p.name.to_lower()
		var p_pos = p.position
		var dist_to_contact = p_pos.distance_to(local_contact)
		
		# Influence radius around impact (covers adjacent panels)
		var max_radius = 1.65 + crush_depth * 1.8
		if dist_to_contact > max_radius:
			continue
			
		var falloff = 1.0 - (dist_to_contact / max_radius)
		falloff = falloff * falloff # Non-linear decay
		var part_crush = crush_depth * falloff
		
		# A. FRONTAL IMPACT (Bumper, Hood, Grille, Headlamps, Front Fenders)
		if local_contact.z < -0.2:
			var is_front_bumper = ("bumper" in p_name or "rostro" in p_name or "skid" in p_name) or (p.position.z < -1.2 and p.position.y < 0.45)
			var is_hood = ("hood" in p_name or "bonnet" in p_name or "scoop" in p_name or "dome" in p_name) or (p.position.z > -1.6 and p.position.z < -0.4 and p.position.y > 0.45)
			
			if is_front_bumper:
				# Push bumper rearward and compress
				p.position.z += part_crush * 0.95
				p.position.y += randf_range(-0.04, 0.05) * part_crush
				p.rotation.y += deg_to_rad(local_contact.x * -22.0 * falloff)
				p.rotation.z += deg_to_rad(randf_range(-8.0, 8.0) * falloff)
				p.scale.z = max(0.35, p.scale.z - part_crush * 0.50)
				
			elif is_hood:
				# Classic safety crumple zone fold: hood buckles upward and tilts back
				p.position.y += part_crush * 0.95
				p.position.z += part_crush * 0.50
				p.rotation.x += deg_to_rad(crush_depth * 75.0 * max(0.40, falloff))
				p.rotation.z += deg_to_rad(local_contact.x * -15.0 * falloff)
				p.scale.y = max(0.70, p.scale.y + part_crush * 0.35)
				
			elif "headlight" in p_name or "hl_" in p_name or "fog" in p_name or "blinker" in p_name or "lamp" in p_name:
				# Headlight knocked askew / pushed back / shattered
				p.position.z += part_crush * 1.05
				p.position.x += randf_range(-0.06, 0.06) * part_crush
				p.rotation.x += deg_to_rad(randf_range(-22.0, 22.0))
				p.rotation.y += deg_to_rad(randf_range(-25.0, 25.0))
				disable_lamp_emission(p)
				
			elif "nose" in p_name or "grille" in p_name or "bar" in p_name:
				p.position.z += part_crush * 0.85
				p.rotation.y += deg_to_rad(local_contact.x * -16.0 * falloff)
				p.scale.z = max(0.40, p.scale.z - part_crush * 0.45)
				
			elif "body" in p_name or "tub" in p_name or "fender" in p_name or "arch" in p_name or "cab" in p_name:
				p.position.z += part_crush * 0.35
				p.scale.z = max(0.75, p.scale.z - part_crush * 0.20)
				
		# B. REAR IMPACT (Rear bumper, Tailgate, Exhaust, Taillights)
		elif local_contact.z > 0.2:
			var is_rear_bumper = ("bumper" in p_name or "diffuser" in p_name or "rostro" in p_name) or (p.position.z > 1.2 and p.position.y < 0.45)
			if is_rear_bumper:
				p.position.z -= part_crush * 0.95
				p.rotation.y += deg_to_rad(local_contact.x * 22.0 * falloff)
				p.rotation.z += deg_to_rad(randf_range(-8.0, 8.0) * falloff)
				p.scale.z = max(0.35, p.scale.z - part_crush * 0.50)
				
			elif "deck" in p_name or "tailgate" in p_name or "plate" in p_name or "boot" in p_name:
				p.position.z -= part_crush * 0.70
				p.position.y += randf_range(-0.04, 0.04) * part_crush
				p.rotation.x -= deg_to_rad(crush_depth * 45.0 * falloff)
				
			elif "exhaust" in p_name or "pipe" in p_name or "tip" in p_name:
				# Exhaust tailpipe bent down or sideways
				p.position.y -= part_crush * 0.55
				p.rotation.x += deg_to_rad(part_crush * 45.0)
				p.rotation.y += deg_to_rad(randf_range(-25.0, 25.0))
				
			elif "tail" in p_name or "tl_" in p_name:
				p.position.z -= part_crush * 0.85
				p.rotation.y += deg_to_rad(randf_range(-20.0, 20.0))
				disable_lamp_emission(p)
				
			elif "body" in p_name or "tub" in p_name or "cab" in p_name:
				p.position.z -= part_crush * 0.35
				p.scale.z = max(0.75, p.scale.z - part_crush * 0.20)
				
		# C. LATERAL FLANK IMPACT (Side doors, mirrors, sills, wheel arches)
		if abs(local_contact.x) > 0.30:
			var side_sign = sign(local_contact.x)
			if "mirror" in p_name or "mir_" in p_name:
				# Side mirror knocked back or snapped
				p.rotation.y += deg_to_rad(-side_sign * 75.0)
				p.rotation.z += deg_to_rad(-side_sign * 35.0)
				p.position.x -= side_sign * part_crush * 0.90
				
			elif "door" in p_name or "clad" in p_name or "waist" in p_name or "handle" in p_name or "skirt" in p_name:
				# Side door panel dented inward toward car center
				p.position.x -= side_sign * part_crush * 0.75
				p.rotation.y += deg_to_rad(side_sign * part_crush * 24.0)
				p.scale.x = max(0.50, p.scale.x - part_crush * 0.35)
				
			elif "arch" in p_name or "fender" in p_name or "sill" in p_name:
				p.position.x -= side_sign * part_crush * 0.65
				p.scale.x = max(0.60, p.scale.x - part_crush * 0.30)
				
		# Additional dent deformation on meshes
		if p is MeshInstance3D and dist_to_contact < (0.95 + crush_depth):
			var dent_dir = (local_contact - p_pos).normalized()
			p.position += dent_dir * (part_crush * 0.35)

	# B. PROCEDURAL SOFT-BODY VERTEX DEFORMATION (Real sheet metal crumple & denting)
	var deform_radius = 1.25 + crush_depth * 1.6
	apply_mesh_deformation_recursive(model_root, local_contact, local_normal, deform_radius, crush_depth)

# --- 2b. RECURSIVE MESH VERTEX CRUMPLE ZONE DEFORMATION ---
static func apply_mesh_deformation_recursive(node: Node, vehicle_local_contact: Vector3, vehicle_local_normal: Vector3, max_radius: float, crush_depth: float):
	if node is MeshInstance3D:
		deform_mesh_node_vertices(node, vehicle_local_contact, vehicle_local_normal, max_radius, crush_depth)
	for child in node.get_children():
		apply_mesh_deformation_recursive(child, vehicle_local_contact, vehicle_local_normal, max_radius, crush_depth)

static func deform_mesh_node_vertices(mi: MeshInstance3D, vehicle_local_contact: Vector3, vehicle_local_normal: Vector3, max_radius: float, crush_depth: float):
	if mi == null or mi.mesh == null:
		return
	var mi_name = mi.name.to_lower()
	# Don't deform mechanical wheels or glass directly with dent noise
	if "wheel" in mi_name or "rim" in mi_name or "tire" in mi_name:
		return
		
	var orig_mesh = mi.mesh
	var array_mesh: ArrayMesh = null
	
	if orig_mesh is ArrayMesh:
		array_mesh = orig_mesh
	elif orig_mesh is PrimitiveMesh:
		var st = SurfaceTool.new()
		st.create_from(orig_mesh, 0)
		array_mesh = st.commit()
		mi.mesh = array_mesh
		
	if array_mesh == null:
		return
		
	if not mi.has_meta("is_deformed_copy"):
		array_mesh = array_mesh.duplicate()
		mi.mesh = array_mesh
		mi.set_meta("is_deformed_copy", true)
		
	var mi_inv = mi.transform.affine_inverse()
	var mesh_local_contact = mi_inv * vehicle_local_contact
	var mesh_local_dir = (mi_inv.basis * vehicle_local_normal).normalized()
	
	var surf_count = array_mesh.get_surface_count()
	for s in range(surf_count):
		var arrays = array_mesh.surface_get_arrays(s)
		if arrays.is_empty(): continue
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		if verts.is_empty(): continue
		var changed = false
		
		for vi in range(verts.size()):
			var v = verts[vi]
			var dist = v.distance_to(mesh_local_contact)
			if dist < max_radius:
				var falloff = 1.0 - (dist / max_radius)
				var d_amount = falloff * falloff * crush_depth
				var wrinkle = 1.0 + sin(v.x * 24.0 + v.z * 18.0) * 0.22
				verts[vi] += mesh_local_dir * (d_amount * wrinkle)
				changed = true
				
		if changed:
			arrays[Mesh.ARRAY_VERTEX] = verts
			var mat = array_mesh.surface_get_material(s)
			if mat == null: mat = mi.material_override
			var st = SurfaceTool.new()
			st.create_from_arrays(arrays)
			st.generate_normals()
			var new_mesh = st.commit()
			mi.mesh = new_mesh
			if mat != null:
				mi.material_override = mat

static func find_vehicle_model_root(vehicle_node: Node3D) -> Node3D:
	if vehicle_node == null: return null
	
	# 1. Se il veicolo ha un ModelRoot esplicito (utilizzato per le auto del catalogo)
	var root_direct = vehicle_node.get_node_or_null("ModelRoot")
	if root_direct is Node3D:
		for sub in root_direct.get_children():
			if sub is Node3D and sub.get_child_count() > 2:
				return sub
		return root_direct
		
	# 2. Cerca container attivo del modello del giocatore (es. ModelFiat127, ModelPanda, ecc.)
	for child in vehicle_node.get_children():
		if child is Node3D and child.name.begins_with("Model") and child.visible:
			for sub in child.get_children():
				if sub is Node3D and sub.get_child_count() > 2:
					return sub
			return child
			
	# Fallback su primo container Model
	for child in vehicle_node.get_children():
		if child is Node3D and child.name.begins_with("Model"):
			for sub in child.get_children():
				if sub is Node3D and sub.get_child_count() > 2:
					return sub
			return child
			
	# 3. Se il veicolo contiene direttamente parti di carrozzeria
	return vehicle_node

static func disable_lamp_emission(node: Node):
	if node is MeshInstance3D and node.material_override is StandardMaterial3D:
		var mat = node.material_override.duplicate()
		mat.emission_enabled = false
		mat.albedo_color = mat.albedo_color * 0.40 # Dark broken glass
		node.material_override = mat
	for c in node.get_children():
		disable_lamp_emission(c)

# --- 3. IMPACT PARTICLES (SPARKS & RADIATOR STEAM) ---
static func spawn_crash_sparks(parent: Node3D, pos_global: Vector3, normal_local: Vector3, impact_kmh: float):
	init_fx_materials()
	var sparks = CPUParticles3D.new()
	sparks.name = "CrashSparks"
	sparks.emitting = false
	sparks.one_shot = true
	sparks.explosiveness = 0.95
	sparks.amount = clamp(int(impact_kmh * 0.8), 12, 45)
	sparks.lifetime = 0.45
	sparks.lifetime_randomness = 0.4
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	sparks.emission_sphere_radius = 0.12
	sparks.direction = -normal_local + Vector3(0, 0.4, 0)
	sparks.spread = 45.0
	sparks.gravity = Vector3(0, -9.8, 0)
	sparks.initial_velocity_min = 4.0
	sparks.initial_velocity_max = 10.0 + impact_kmh * 0.15
	sparks.material_override = spark_material
	
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.04, 0.04, 0.14)
	sparks.mesh = mesh
	
	var tree = parent.get_tree() if parent else null
	if tree and tree.root:
		tree.root.add_child(sparks)
		sparks.global_position = pos_global
		sparks.emitting = true
		sparks.finished.connect(func(): sparks.queue_free())
	else:
		sparks.queue_free()

static func spawn_radiator_steam(parent: Node3D, pos_global: Vector3):
	init_fx_materials()
	var steam = CPUParticles3D.new()
	steam.name = "RadiatorSteam"
	steam.emitting = false
	steam.one_shot = true
	steam.explosiveness = 0.3
	steam.amount = 20
	steam.lifetime = 1.6
	steam.direction = Vector3(0, 1.0, 0.2)
	steam.spread = 28.0
	steam.gravity = Vector3(0, 0.6, 0)
	steam.initial_velocity_min = 1.2
	steam.initial_velocity_max = 2.8
	steam.scale_amount_min = 0.3
	steam.scale_amount_max = 1.4
	steam.material_override = smoke_material
	
	var sphere = SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	steam.mesh = sphere
	
	var tree = parent.get_tree() if parent else null
	if tree and tree.root:
		tree.root.add_child(steam)
		steam.global_position = pos_global + Vector3(0, 0.2, 0)
		steam.emitting = true
		steam.finished.connect(func(): steam.queue_free())
	else:
		steam.queue_free()
