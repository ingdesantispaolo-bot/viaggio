extends SceneTree

func _init():
	print("--- VERIFICA MODELLI NORMALIZZATI IN GODOT ---")
	var models = [
		{"id": "porsche_930_turbo", "path": "res://models/porsche_930_turbo.glb"},
		{"id": "porsche_carrera_4s", "path": "res://models/porsche_carrera_4s.glb"},
		{"id": "countach_lpi800", "path": "res://models/countach_lpi800.glb"}
	]
	for m in models:
		var gltf_doc = GLTFDocument.new()
		var gltf_state = GLTFState.new()
		var err = gltf_doc.append_from_file(m.path, gltf_state)
		if err != OK:
			print("ERRORE: ", m.id)
			continue
		var root = gltf_doc.generate_scene(gltf_state)
		var total_aabb = AABB()
		var first = true
		var stack = [root]
		while stack.size() > 0:
			var c = stack.pop_back()
			if c is MeshInstance3D and c.mesh:
				var a = c.get_aabb()
				if first:
					total_aabb = a
					first = false
				else:
					total_aabb = total_aabb.merge(a)
			for ch in c.get_children():
				stack.push_back(ch)
		print(m.id, " -> Size (X,Y,Z): ", total_aabb.size, " | Min Y: ", total_aabb.position.y, " | Max Y: ", total_aabb.end.y)
	quit(0)
