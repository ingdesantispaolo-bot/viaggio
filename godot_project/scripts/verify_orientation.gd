extends SceneTree

func _init():
	print("--- VERIFICA ORIENTAMENTO ASSI MODELLI 3D ---")
	var models = [
		{"id": "porsche_930_turbo", "path": "res://models/porsche_930_turbo.glb"},
		{"id": "porsche_carrera_4s", "path": "res://models/porsche_carrera_4s.glb"},
		{"id": "countach_lpi800", "path": "res://models/countach_lpi800.glb"}
	]
	for m in models:
		var gltf_doc = GLTFDocument.new()
		var gltf_state = GLTFState.new()
		gltf_doc.append_from_file(m.path, gltf_state)
		var root = gltf_doc.generate_scene(gltf_state)
		
		# Cerca fari anteriori o windshield per capire quale asse è il fronte
		var stack = [root]
		while stack.size() > 0:
			var c = stack.pop_back()
			var name_l = c.name.to_lower()
			if ("windshield" in name_l or "headlight" in name_l or "light" in name_l or "faro" in name_l) and c is MeshInstance3D and c.mesh:
				var aabb = c.get_aabb()
				print(m.id, " -> Nodo: ", c.name, " AABB center: ", aabb.get_center())
			for ch in c.get_children():
				stack.push_back(ch)
	quit(0)
