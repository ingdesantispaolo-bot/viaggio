extends SceneTree

func _init():
	var packed = load("res://scenes/Main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	
	var road_gen = main.get_node("RoadGenerator")
	road_gen.update_generation(400.0)
	
	print("\n=== INSPECTING MESH VERTICES AT Z = 240.0 ===")
	# Find Chunk 2 (start 120, end 240) and Chunk 3 (start 240, end 360)
	var c2_node = null
	var c3_node = null
	for c in road_gen.active_chunks:
		if abs(c.start_z - 120.0) < 1.0:
			c2_node = c.node
		elif abs(c.start_z - 240.0) < 1.0:
			c3_node = c.node
			
	if not c2_node or not c3_node:
		print("Could not find chunk 2 or chunk 3!")
		quit(1)
		
	print("Found Chunk 2 node: ", c2_node.name, " and Chunk 3 node: ", c3_node.name)
	
	# Inspect collision shapes in c2 and c3
	print("\n--- Chunk 2 (120->240) Colliders near Z=240 ---")
	print_colliders_near(c2_node, 240.0)
	
	print("\n--- Chunk 3 (240->360) Colliders near Z=240 ---")
	print_colliders_near(c3_node, 240.0)
	
	# Inspect all MeshInstance3Ds in c2 and c3 near Z=240
	print("\n--- Chunk 2 Meshes near Z=240 ---")
	print_meshes_near(c2_node, 240.0)
	
	print("\n--- Chunk 3 Meshes near Z=240 ---")
	print_meshes_near(c3_node, 240.0)
	
	quit(0)

func print_colliders_near(node: Node, target_z: float):
	for child in node.get_children():
		if child is StaticBody3D:
			for cs in child.get_children():
				if cs is CollisionShape3D:
					var shape = cs.shape
					if shape is ConcavePolygonShape3D:
						var faces = shape.get_faces()
						var seam_faces = []
						for i in range(0, faces.size(), 3):
							var v1 = faces[i]
							var v2 = faces[i+1]
							var v3 = faces[i+2]
							if abs(v1.z - target_z) < 1.0 or abs(v2.z - target_z) < 1.0 or abs(v3.z - target_z) < 1.0:
								seam_faces.append([v1, v2, v3])
						print("  ConcavePolygonShape: %d faces total, %d faces touching Z=%.1f" % [faces.size() / 3, seam_faces.size(), target_z])
						for f in seam_faces.slice(0, 4):
							print("    Face: v1=%s, v2=%s, v3=%s" % [f[0], f[1], f[2]])
					elif shape is BoxShape3D:
						var g_pos = cs.global_position
						if abs(g_pos.z - target_z) < 15.0:
							print("  BoxShape3D at %s size %s" % [g_pos, shape.size])
		print_colliders_near(child, target_z)

func print_meshes_near(node: Node, target_z: float):
	if node is MeshInstance3D:
		var g_pos = node.global_position
		if abs(g_pos.z - target_z) < 10.0:
			print("  MeshInstance3D '%s' at %s, mesh=%s" % [node.name, g_pos, node.mesh])
	for child in node.get_children():
		print_meshes_near(child, target_z)
