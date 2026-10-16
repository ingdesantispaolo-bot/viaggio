extends SceneTree

var frame = 0
var main = null

func _process(_delta):
	frame += 1
	if frame == 1:
		var packed = load("res://scenes/Main.tscn")
		main = packed.instantiate()
		root.add_child(main)
		var road_gen = main.get_node("RoadGenerator")
		road_gen.update_generation(400.0)
	elif frame == 5:
		print("\n=== SCANNING ALL 3D NODES BETWEEN Z = 230 and Z = 250 ===")
		scan_nodes_recursive(main, 240.0, 15.0)
		quit(0)

func scan_nodes_recursive(node: Node, target_z: float, radius: float):
	if node is Node3D:
		var pos = node.global_position
		if abs(pos.z - target_z) <= radius:
			var extra = ""
			if node is MeshInstance3D:
				var m = node.mesh
				var mat = node.material_override
				if not mat and m and m.has_method("get_material"):
					mat = m.material
				extra = " [Mesh: %s, Mat: %s]" % [m.get_class() if m else "null", mat.resource_name if mat else "default"]
				if m is BoxMesh:
					extra += " BoxSize: %s" % m.size
				elif m is CylinderMesh:
					extra += " Cyl: r=%.2f, h=%.2f" % [m.top_radius, m.height]
			elif node is CollisionShape3D:
				extra = " [ColShape: %s]" % node.shape.get_class()
			print("Node: %s (%s) at pos=%s%s" % [node.name, node.get_class(), pos, extra])
	for child in node.get_children():
		scan_nodes_recursive(child, target_z, radius)
